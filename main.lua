require("player")
require("obstacle")

local obstacles = {}

-- === LEVEL DESIGN ===
local levelSchedule = {
    2.0,  
    3.5,  
    4.5,  
    6.0,
    7.2
}
-- ====================

local scheduleIndex = 1
local gameTime = 0

TimeScore = 100 

function love.load()
    Player:load()
end

function love.update(dt)
    gameTime = gameTime + dt
    TimeScore = TimeScore - dt

    if scheduleIndex <= #levelSchedule and gameTime >= levelSchedule[scheduleIndex] then
        spawnObstacle()
        scheduleIndex = scheduleIndex + 1
    end

    Player:update(dt)

    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs:update(dt)

        if obs.remove then
            table.remove(obstacles, i)
        end
    end
end

function love.draw()
    Player:draw()

    for i, obs in ipairs(obstacles) do
        obs:draw()
    end
    
    love.graphics.print("Time: " .. string.format("%.0f", TimeScore), 10, 10)
end

function love.keypressed(key)
    if key == "space" then
        Player:jump()
    end
    if key == "r" then
        gameTime = 0
        scheduleIndex = 1
        obstacles = {}
        TimeScore = 100 -- Reset score on restart
    end
end

function spawnObstacle()
    local newObstacle = {
        x = love.graphics.getWidth(),
        y = 300,
        width = 100,
        height = 100,
        isHit = false,
        speed = 200
    }
    
    setmetatable(newObstacle, Obstacle)
    
    table.insert(obstacles, newObstacle)
end
