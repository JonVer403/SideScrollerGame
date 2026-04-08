require("player")
require("obstacle")
require("background")
require("nos")
require("levels")
require("leaderboard")
require("sound")

local obstacles = {}
local scheduleIndex = 1
local gameTime = 0
local gameState = "menu" -- menu, playing, gameover, finished

TimeScore = 100 

function love.load()
    -- Initialize all systems
    Background:load()
    Player:load()
    NOS:load()
    Levels:load()
    Leaderboard:load()
    Sound:load()
end

function love.update(dt)
    -- Level selector
    if Levels:isInSelector() then
        return
    end
    
    -- Leaderboard view
    if Leaderboard:isShowing() then
        return
    end
    
    -- Game over check
    if TimeScore <= 0 then
        if gameState == "playing" then
            gameState = "gameover"
            -- Add score to leaderboard
            local rank = Leaderboard:addScore(Levels.currentLevel, Leaderboard.playerName, math.max(0, TimeScore))
            if rank then
                Sound:play("highscore")
            end
        end
        return
    end
    
    gameState = "playing"
    gameTime = gameTime + dt
    
    -- Get current speed multiplier (NOS boost)
    local speedMult = NOS:getSpeedMultiplier()
    
    -- Update time score
    TimeScore = TimeScore - dt
    
    -- If NOS is active, bonus points
    if NOS.isActive then
        TimeScore = TimeScore + dt * 0.5 -- Slow down timer during boost
    end

    -- Get level schedule
    local levelSchedule = Levels:getSchedule()
    
    -- Spawn obstacles and NOS pickups based on level schedule
    if scheduleIndex <= #levelSchedule and gameTime >= levelSchedule[scheduleIndex] then
        spawnObstacle()
        
        -- Chance to spawn NOS pickup
        if math.random() < Levels:getCurrentLevel().nosSpawnChance then
            NOS:spawnPickup(nil, nil, Levels:getSpeed())
        end
        
        scheduleIndex = scheduleIndex + 1
    end
    
    -- Check if level complete (all obstacles spawned and gone)
    if scheduleIndex > #levelSchedule and #obstacles == 0 and gameState == "playing" then
        gameState = "finished"
        Sound:play("finish")
        local rank = Leaderboard:addScore(Levels.currentLevel, Leaderboard.playerName, TimeScore)
        if rank and rank <= 3 then
            Sound:play("highscore")
        end
    end

    -- Update systems
    Background:update(dt, speedMult)
    Player:update(dt, speedMult)
    NOS:update(dt)

    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs:update(dt, speedMult)

        if obs.remove then
            table.remove(obstacles, i)
        end
    end
end

function love.draw()
    -- Level selector screen
    if Levels:isInSelector() then
        Levels:drawSelector()
        return
    end
    
    -- Draw background first
    Background:draw()
    
    -- Draw player
    Player:draw()

    -- Draw obstacles
    for i, obs in ipairs(obstacles) do
        obs:draw()
    end
    
    -- Draw NOS pickups and meter
    NOS:draw()
    
    -- Draw HUD
    drawHUD()
    
    -- Draw leaderboard if showing
    if Leaderboard:isShowing() then
        Leaderboard:draw(Levels.currentLevel)
    end
    
    -- Game over screen
    if gameState == "gameover" then
        drawGameOver()
    end
    
    -- Level complete screen
    if gameState == "finished" then
        drawLevelComplete()
    end
end

function drawHUD()
    local screenW = love.graphics.getWidth()
    
    -- Time/Score display
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Time: " .. string.format("%.1f", math.max(0, TimeScore)), 10, 10)
    
    -- Level name
    love.graphics.print("Level " .. Levels.currentLevel .. ": " .. Levels:getCurrentLevel().name, screenW - 250, 10)
    
    -- Jump charge indicator
    if Player.jumpCharge > 0 then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("CHARGING: " .. string.format("%.0f%%", Player.jumpCharge * 100), 10, 70)
    end
    
    -- NOS active indicator
    if NOS.isActive then
        local flash = math.sin(love.timer.getTime() * 15) * 0.5 + 0.5
        love.graphics.setColor(0, flash, 1)
        love.graphics.print(">>> NOS BOOST ACTIVE <<<", screenW/2 - 100, 10)
    end
    
    -- Sound mute indicator
    if Sound:isMuted() then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("[MUTED]", screenW - 80, 40)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function drawGameOver()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, screenH/2 - 50, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. string.format("%.0f", 0), 0, screenH/2, screenW, "center")
    love.graphics.printf("Press R to restart | ESC for level select | L for leaderboard", 0, screenH/2 + 50, screenW, "center")
end

function drawLevelComplete()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.printf("LEVEL COMPLETE!", 0, screenH/2 - 50, screenW, "center")
    
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.printf("Score: " .. string.format("%.0f", TimeScore), 0, screenH/2, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press R to replay | ESC for level select | L for leaderboard", 0, screenH/2 + 50, screenW, "center")
end

function love.keypressed(key)
    -- Level selector input
    if Levels:isInSelector() then
        if Levels:selectorKeypressed(key) then
            startLevel()
        end
        return
    end
    
    -- Leaderboard input
    if Leaderboard:isShowing() then
        Leaderboard:keypressed(key)
        return
    end
    
    -- Jump (release-based for jump charge)
    if key == "space" then
        Player:startJumpCharge()
        Sound:play("jump")
    end
    
    -- NOS boost activation
    if key == "lshift" or key == "rshift" then
        if NOS:activate() then
            Sound:play("nos_activate")
        end
    end
    
    -- Restart level
    if key == "r" then
        startLevel()
    end
    
    -- Return to level selector
    if key == "escape" then
        Levels:returnToSelector()
        resetGame()
    end
    
    -- Toggle leaderboard
    if key == "l" then
        Leaderboard:toggle(Levels.currentLevel)
    end
    
    -- Toggle mute
    if key == "m" then
        Sound:toggleMute()
    end
end

function love.keyreleased(key)
    -- Jump charge release
    if key == "space" then
        Player:releaseJumpCharge()
    end
end

function love.textinput(text)
    Leaderboard:textinput(text)
end

function startLevel()
    gameTime = 0
    scheduleIndex = 1
    obstacles = {}
    TimeScore = Levels:getTimeLimit()
    NOS:reset()
    Player:load()
    gameState = "playing"
end

function resetGame()
    gameTime = 0
    scheduleIndex = 1
    obstacles = {}
    TimeScore = 100
    NOS:reset()
    gameState = "menu"
end

function spawnObstacle()
    local speed = Levels:getSpeed() * NOS:getSpeedMultiplier()
    
    local newObstacle = {
        x = love.graphics.getWidth(),
        y = love.graphics.getHeight() - 100, -- Ground level
        width = 80,
        height = 80,
        isHit = false,
        speed = speed
    }
    
    setmetatable(newObstacle, Obstacle)
    
    table.insert(obstacles, newObstacle)
end
