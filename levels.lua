-- levels.lua
-- Level System with Level Selector

Levels = {}

function Levels:load()
    self.currentLevel = 1
    self.inSelector = true -- Start in level selector
    
    -- Define all levels with spawn patterns
    -- Types: "ground", "flying", "ramp", "nos"
    self.data = {
        {
            name = "Easy Street",
            baseSpeed = 150,
            timeLimit = 60,
            -- {time, type} - better spacing (minimum 1.5s between obstacles)
            schedule = {
                {2.0, "ground"},
                {4.0, "ramp"},
                {6.5, "ground"},
                {8.5, "nos"},
                {10.0, "flying"},
                {12.5, "ground"},
                {15.0, "ramp"},
            },
            nosSpawnChance = 0.3,
            backgroundColor = {0.2, 0.3, 0.5}
        },
        {
            name = "Highway Rush",
            baseSpeed = 200,
            timeLimit = 50,
            schedule = {
                {1.5, "ground"},
                {3.5, "flying"},
                {5.5, "ramp"},
                {7.0, "nos"},
                {9.0, "ground"},
                {11.0, "flying"},
                {13.0, "ground"},
                {15.0, "ramp"},
                {17.0, "nos"},
            },
            nosSpawnChance = 0.25,
            backgroundColor = {0.3, 0.2, 0.4}
        },
        {
            name = "Night Race",
            baseSpeed = 250,
            timeLimit = 45,
            schedule = {
                {1.5, "ground"},
                {3.0, "flying"},
                {4.5, "ramp"},
                {6.0, "nos"},
                {7.5, "flying"},
                {9.0, "ground"},
                {10.5, "flying"},
                {12.0, "ramp"},
                {14.0, "ground"},
                {16.0, "nos"},
            },
            nosSpawnChance = 0.2,
            backgroundColor = {0.1, 0.1, 0.2}
        },
        {
            name = "Extreme Circuit",
            baseSpeed = 300,
            timeLimit = 40,
            schedule = {
                {1.2, "ground"},
                {2.5, "flying"},
                {3.8, "ramp"},
                {5.0, "flying"},
                {6.2, "nos"},
                {7.5, "ground"},
                {8.8, "flying"},
                {10.0, "ramp"},
                {11.2, "ground"},
                {12.5, "flying"},
                {13.8, "nos"},
                {15.0, "ground"},
            },
            nosSpawnChance = 0.35,
            backgroundColor = {0.4, 0.1, 0.1}
        }
    }
    
    -- Selector UI settings
    self.selectorIndex = 1
    self.boxWidth = 250
    self.boxHeight = 120
    self.boxSpacing = 30
end

function Levels:getCurrentLevel()
    return self.data[self.currentLevel]
end

function Levels:getSchedule()
    return self.data[self.currentLevel].schedule
end

function Levels:getSpeed()
    return self.data[self.currentLevel].baseSpeed
end

function Levels:getTimeLimit()
    return self.data[self.currentLevel].timeLimit
end

function Levels:selectLevel(index)
    if index >= 1 and index <= #self.data then
        self.currentLevel = index
        return true
    end
    return false
end

function Levels:drawSelector()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SELECT LEVEL", 0, 50, screenW, "center")
    
    -- Calculate starting X for centered boxes
    local totalWidth = #self.data * self.boxWidth + (#self.data - 1) * self.boxSpacing
    local startX = (screenW - totalWidth) / 2
    local boxY = (screenH - self.boxHeight) / 2
    
    for i, level in ipairs(self.data) do
        local boxX = startX + (i - 1) * (self.boxWidth + self.boxSpacing)
        
        -- Box background
        if i == self.selectorIndex then
            love.graphics.setColor(0.3, 0.5, 0.8)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", boxX, boxY, self.boxWidth, self.boxHeight, 10, 10)
        
        -- Box border
        if i == self.selectorIndex then
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", boxX, boxY, self.boxWidth, self.boxHeight, 10, 10)
        love.graphics.setLineWidth(1)
        
        -- Level number
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Level " .. i, boxX, boxY + 15, self.boxWidth, "center")
        
        -- Level name
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(level.name, boxX, boxY + 40, self.boxWidth, "center")
        
        -- Speed indicator
        love.graphics.setColor(0.6, 0.8, 0.6)
        love.graphics.printf("Speed: " .. level.baseSpeed, boxX, boxY + 70, self.boxWidth, "center")
        
        -- Time limit
        love.graphics.setColor(0.8, 0.6, 0.6)
        love.graphics.printf("Time: " .. level.timeLimit .. "s", boxX, boxY + 90, self.boxWidth, "center")
    end
    
    -- Instructions
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Use LEFT/RIGHT to select, ENTER to start", 0, screenH - 80, screenW, "center")
    love.graphics.printf("Press ESC to return to level select during game", 0, screenH - 50, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
end

function Levels:selectorKeypressed(key)
    if key == "left" then
        self.selectorIndex = math.max(1, self.selectorIndex - 1)
    elseif key == "right" then
        self.selectorIndex = math.min(#self.data, self.selectorIndex + 1)
    elseif key == "return" or key == "space" then
        self:selectLevel(self.selectorIndex)
        self.inSelector = false
        return true -- Signal to start game
    end
    return false
end

function Levels:returnToSelector()
    self.inSelector = true
end

function Levels:isInSelector()
    return self.inSelector
end
