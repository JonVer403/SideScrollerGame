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
local FinalScore = 0     -- Score saved when level ends
local scoreSubmitted = false  -- Prevent multiple leaderboard submissions

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
    -- Level selector - no game updates
    if Levels:isInSelector() then
        return
    end
    
    -- Leaderboard view - no game updates
    if Leaderboard:isShowing() then
        return
    end
    
    -- Game finished or game over - stop all updates
    if gameState == "finished" or gameState == "gameover" then
        return
    end
    
    -- Game over check (ran out of time)
    if TimeScore <= 0 then
        gameState = "gameover"
        FinalScore = 0
        if not scoreSubmitted then
            scoreSubmitted = true
            local rank = Leaderboard:addScore(Levels.currentLevel, Leaderboard.playerName, 0)
            if rank then
                Sound:play("highscore")
            end
        end
        return
    end
    
    gameTime = gameTime + dt
    
    -- Get current speed multiplier (NOS boost)
    local speedMult = NOS:getSpeedMultiplier()
    
    -- Update time score (countdown)
    TimeScore = TimeScore - dt
    
    -- If NOS is active, timer counts down slower (advantage!)
    if NOS.isActive then
        TimeScore = TimeScore + dt * 0.5
    end

    -- Get level schedule
    local levelSchedule = Levels:getSchedule()
    
    -- Spawn based on level schedule (now with types)
    if scheduleIndex <= #levelSchedule then
        local entry = levelSchedule[scheduleIndex]
        local spawnTime = entry[1]
        local spawnType = entry[2]
        
        if gameTime >= spawnTime then
            if spawnType == "nos" then
                -- Spawn NOS pickup at reachable height
                local nosY = love.graphics.getHeight() - 150 - math.random(0, 40)
                NOS:spawnPickup(nil, nosY, Levels:getSpeed())
            else
                -- Spawn obstacle with type
                spawnObstacle(spawnType)
            end
            
            scheduleIndex = scheduleIndex + 1
        end
    end
    
    -- Check if level complete (all obstacles spawned and cleared)
    if scheduleIndex > #levelSchedule and #obstacles == 0 then
        gameState = "finished"
        FinalScore = math.floor(TimeScore)  -- Save the final score
        Sound:play("finish")
        
        if not scoreSubmitted then
            scoreSubmitted = true
            local rank = Leaderboard:addScore(Levels.currentLevel, Leaderboard.playerName, FinalScore)
            if rank and rank <= 3 then
                Sound:play("highscore")
            end
        end
        return
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
    
    -- Game over screen (only if leaderboard not showing)
    if gameState == "gameover" and not Leaderboard:isShowing() then
        drawGameOver()
    end
    
    -- Level complete screen (only if leaderboard not showing)
    if gameState == "finished" and not Leaderboard:isShowing() then
        drawLevelComplete()
    end
    
    -- Draw leaderboard on top of everything
    if Leaderboard:isShowing() then
        Leaderboard:draw(Levels.currentLevel)
    end
end

function drawHUD()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Time remaining (big, important!)
    local timeColor = {1, 1, 1}
    if TimeScore < 10 then
        timeColor = {1, 0.3, 0.3}  -- Red when low
    elseif TimeScore < 20 then
        timeColor = {1, 0.8, 0.2}  -- Yellow when getting low
    end
    
    love.graphics.setColor(timeColor)
    love.graphics.print("TIME: " .. string.format("%.1f", math.max(0, TimeScore)), 10, 10)
    
    -- Level name and progress
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Level " .. Levels.currentLevel .. ": " .. Levels:getCurrentLevel().name, screenW - 250, 10)
    
    -- Progress bar (how far through the level)
    local levelSchedule = Levels:getSchedule()
    local progress = math.min(1, scheduleIndex / #levelSchedule)
    local barWidth = 200
    local barHeight = 8
    local barX = screenW - barWidth - 20
    local barY = 35
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth * progress, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    
    -- Jump charge indicator (above player)
    if Player.jumpCharge > 0 and Player.isCharging then
        love.graphics.setColor(1, 0.6, 0)
        local chargeWidth = Player.width * Player.jumpCharge
        love.graphics.rectangle("fill", Player.x, Player.y - 12, chargeWidth, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", Player.x, Player.y - 12, Player.width, 6)
    end
    
    -- NOS active indicator
    if NOS.isActive then
        local flash = math.sin(love.timer.getTime() * 15) * 0.5 + 0.5
        love.graphics.setColor(0, flash, 1)
        love.graphics.printf(">>> BOOST <<<", 0, 50, screenW, "center")
    end
    
    -- Controls hint (bottom of screen)
    love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
    love.graphics.printf("SPACE: Jump | SHIFT: Boost | Avoid obstacles!", 0, screenH - 25, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
end

function drawGameOver()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("TIME'S UP!", 0, screenH/2 - 80, screenW, "center")
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("You ran out of time!", 0, screenH/2 - 30, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press R to retry | ESC for level select | L for leaderboard", 0, screenH/2 + 30, screenW, "center")
end

function drawLevelComplete()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.printf("FINISH!", 0, screenH/2 - 80, screenW, "center")
    
    love.graphics.setColor(1, 0.9, 0.2)
    love.graphics.printf("Time Remaining: " .. string.format("%.1f", FinalScore) .. "s", 0, screenH/2 - 30, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press R to replay | ESC for level select | L for leaderboard", 0, screenH/2 + 30, screenW, "center")
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
    
    -- End state (finished or gameover) - only allow menu keys
    if gameState == "finished" or gameState == "gameover" then
        if key == "r" then
            startLevel()
        elseif key == "escape" then
            Levels:returnToSelector()
            resetGame()
        elseif key == "l" then
            Leaderboard:toggle(Levels.currentLevel)
        elseif key == "m" then
            Sound:toggleMute()
        end
        return
    end
    
    -- Gameplay inputs (only when playing)
    if key == "space" then
        Player:startJumpCharge()
    end
    
    if key == "lshift" or key == "rshift" then
        if NOS:activate() then
            Sound:play("nos_activate")
        end
    end
    
    -- Menu keys (always available during gameplay)
    if key == "r" then
        startLevel()
    elseif key == "escape" then
        Levels:returnToSelector()
        resetGame()
    elseif key == "l" then
        Leaderboard:toggle(Levels.currentLevel)
    elseif key == "m" then
        Sound:toggleMute()
    end
end

function love.keyreleased(key)
    -- Only process during gameplay
    if gameState ~= "finished" and gameState ~= "gameover" then
        if key == "space" then
            Player:releaseJumpCharge()
        end
    end
end

function love.textinput(text)
    Leaderboard:textinput(text)
end

function startLevel()
    gameTime = 0
    scheduleIndex = 1
    FinalScore = 0
    scoreSubmitted = false  -- Reset submission flag
    obstacles = {}
    TimeScore = Levels:getTimeLimit()
    NOS:reset()
    Player:load()
    gameState = "playing"
end

function resetGame()
    gameTime = 0
    scheduleIndex = 1
    FinalScore = 0
    scoreSubmitted = false
    obstacles = {}
    TimeScore = 100
    NOS:reset()
    gameState = "menu"
end

function spawnObstacle(obstacleType)
    local speed = Levels:getSpeed() * NOS:getSpeedMultiplier()
    local groundY = love.graphics.getHeight() - 60  -- Match player ground level
    
    local newObstacle = {
        x = love.graphics.getWidth(),
        y = groundY,
        width = 50,
        height = 50,
        isHit = false,
        speed = speed,
        obstacleType = obstacleType or "ground"
    }
    
    -- Adjust properties based on type
    if obstacleType == "flying" then
        -- Flying enemies - lower to be reachable with jump
        newObstacle.y = love.graphics.getHeight() - 160 - math.random(0, 40)
        newObstacle.baseY = newObstacle.y
        newObstacle.width = 50
        newObstacle.height = 40
        newObstacle.floatTimer = math.random() * 6.28
    elseif obstacleType == "ramp" then
        -- Ramps are smaller and on the ground
        newObstacle.y = groundY
        newObstacle.width = 70
        newObstacle.height = 40
    else
        -- Ground obstacle - smaller, jumpable
        newObstacle.y = groundY
        newObstacle.width = 40 + math.random(0, 20)
        newObstacle.height = 40 + math.random(0, 20)
    end
    
    setmetatable(newObstacle, Obstacle)
    
    table.insert(obstacles, newObstacle)
end
