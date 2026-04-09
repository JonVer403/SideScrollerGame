-- levels.lua
-- Level System with Level Selector

Levels = {}

function Levels:load()
    self.currentLevel = 1
    self.inSelector = true -- Start in level selector
    
    -- Define all levels with spawn patterns
    -- Types: "ground", "flying", "ramp", "nos"
    -- Tips: 
    --   - "ramp" after "ground" gives a good jump flow
    --   - "flying" + "ground" combo forces decision making
    --   - "nos" before difficult sections gives advantage
    
    self.data = {
        {
            name = "Tutorial Track",
            description = "Learn the basics",
            baseSpeed = 130,
            timeLimit = 70,
            -- Gentle introduction with lots of spacing
            schedule = {
                {2.5, "ground"},       -- Simple start
                {5.0, "ramp"},         -- Learn ramps
                {8.0, "nos"},          -- Get first NOS
                {11.0, "ground"},
                {14.0, "ramp"},
                {17.0, "flying"},      -- Introduce flying
                {20.0, "ground"},
                {23.0, "nos"},
                {26.0, "ramp"},
            },
            nosSpawnChance = 0.4,
            backgroundColor = {0.3, 0.5, 0.3}  -- Green (daytime grass)
        },
        {
            name = "City Sprint",
            description = "Urban obstacles",
            baseSpeed = 170,
            timeLimit = 55,
            -- City environment - traffic cones and flying drones
            schedule = {
                {2.0, "ground"},
                {4.0, "ground"},       -- Double obstacle
                {6.5, "ramp"},         -- Escape route
                {9.0, "flying"},
                {11.0, "nos"},
                {13.5, "ground"},
                {15.5, "ramp"},
                {18.0, "flying"},
                {20.0, "ground"},
                {22.5, "flying"},
                {25.0, "nos"},
                {27.5, "ramp"},
            },
            nosSpawnChance = 0.3,
            backgroundColor = {0.2, 0.25, 0.35}  -- Urban blue-grey
        },
        {
            name = "Highway Rush",
            description = "High speed action",
            baseSpeed = 220,
            timeLimit = 50,
            -- Fast paced with rewarding ramp chains
            schedule = {
                {1.8, "ground"},
                {3.5, "ramp"},
                {5.0, "nos"},
                {7.0, "flying"},
                {8.5, "ground"},
                {10.5, "ramp"},
                {12.0, "flying"},
                {14.0, "ground"},
                {15.5, "ramp"},        -- Ramp chain
                {17.5, "ramp"},
                {19.5, "nos"},
                {21.5, "flying"},
                {23.0, "ground"},
                {25.0, "ramp"},
            },
            nosSpawnChance = 0.25,
            backgroundColor = {0.3, 0.2, 0.4}  -- Purple dusk
        },
        {
            name = "Night Race",
            description = "Darkness awaits",
            baseSpeed = 250,
            timeLimit = 45,
            -- Tricky patterns requiring good timing
            schedule = {
                {1.5, "flying"},       -- Start high
                {3.0, "ground"},
                {4.5, "ramp"},
                {6.0, "nos"},
                {7.5, "flying"},
                {9.0, "ground"},
                {10.2, "flying"},      -- Quick combo
                {11.8, "ramp"},
                {13.5, "ground"},
                {15.0, "flying"},
                {16.5, "nos"},
                {18.0, "ground"},
                {19.5, "ramp"},
                {21.0, "flying"},
                {22.5, "ground"},
            },
            nosSpawnChance = 0.2,
            backgroundColor = {0.08, 0.08, 0.15}  -- Dark night
        },
        {
            name = "Extreme Circuit",
            description = "For experts only",
            baseSpeed = 300,
            timeLimit = 40,
            -- Intense final challenge
            schedule = {
                {1.2, "ground"},
                {2.3, "flying"},
                {3.5, "ramp"},
                {4.5, "ground"},
                {5.5, "nos"},          -- Early boost needed!
                {6.8, "flying"},
                {7.8, "ground"},
                {9.0, "ramp"},
                {10.0, "flying"},
                {11.0, "ground"},
                {12.2, "flying"},
                {13.3, "ramp"},
                {14.5, "nos"},
                {15.5, "ground"},
                {16.5, "flying"},
                {17.5, "ramp"},
                {18.8, "ground"},
                {20.0, "flying"},
            },
            nosSpawnChance = 0.35,
            backgroundColor = {0.4, 0.1, 0.1}  -- Red danger
        },
        {
            name = "Endless Mode",
            description = "How far can you go?",
            baseSpeed = 180,
            timeLimit = 90,
            -- Long level with increasing difficulty patterns
            schedule = {
                -- Warm up
                {2.0, "ground"},
                {4.5, "ramp"},
                {7.0, "nos"},
                -- Phase 1
                {10.0, "ground"},
                {12.0, "flying"},
                {14.0, "ramp"},
                {16.0, "ground"},
                -- Phase 2 - getting harder
                {18.0, "flying"},
                {19.5, "ground"},
                {21.0, "ramp"},
                {22.5, "nos"},
                {24.5, "flying"},
                {26.0, "ground"},
                -- Phase 3 - expert section
                {28.0, "flying"},
                {29.5, "ramp"},
                {31.0, "ground"},
                {32.5, "flying"},
                {34.0, "nos"},
                {35.5, "ground"},
                {37.0, "ramp"},
                {38.5, "flying"},
                -- Final sprint
                {40.0, "ground"},
                {41.2, "ramp"},
                {42.5, "flying"},
                {44.0, "ground"},
                {45.5, "nos"},
                {47.0, "ramp"},
            },
            nosSpawnChance = 0.3,
            backgroundColor = {0.15, 0.15, 0.2}  -- Twilight
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
    
    -- Background with gradient effect
    love.graphics.setColor(0.08, 0.08, 0.12)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Title
    love.graphics.setColor(1, 0.9, 0.3)
    love.graphics.printf("SELECT LEVEL", 0, 30, screenW, "center")
    
    -- Grid layout: 3 columns x 2 rows
    local cols = 3
    local rows = 2
    local boxW = 200
    local boxH = 100
    local spacingX = 25
    local spacingY = 20
    
    local totalW = cols * boxW + (cols - 1) * spacingX
    local totalH = rows * boxH + (rows - 1) * spacingY
    local startX = (screenW - totalW) / 2
    local startY = (screenH - totalH) / 2 - 10
    
    for i, level in ipairs(self.data) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local boxX = startX + col * (boxW + spacingX)
        local boxY = startY + row * (boxH + spacingY)
        
        -- Box background with level theme color
        if i == self.selectorIndex then
            love.graphics.setColor(0.3, 0.5, 0.8)
        else
            local bg = level.backgroundColor or {0.2, 0.2, 0.3}
            love.graphics.setColor(bg[1] * 0.8, bg[2] * 0.8, bg[3] * 0.8, 0.9)
        end
        love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 8, 8)
        
        -- Box border
        if i == self.selectorIndex then
            love.graphics.setColor(1, 1, 0)
            love.graphics.setLineWidth(3)
        else
            love.graphics.setColor(0.5, 0.5, 0.6)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 8, 8)
        love.graphics.setLineWidth(1)
        
        -- Level number badge
        love.graphics.setColor(0.2, 0.2, 0.3, 0.9)
        love.graphics.circle("fill", boxX + 20, boxY + 20, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tostring(i), boxX + 5, boxY + 13, 30, "center")
        
        -- Level name
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(level.name, boxX + 40, boxY + 12, boxW - 50, "left")
        
        -- Description if available
        if level.description then
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.printf(level.description, boxX + 10, boxY + 35, boxW - 20, "center")
        end
        
        -- Stats row
        love.graphics.setColor(0.5, 0.8, 0.5)
        love.graphics.printf("SPD:" .. level.baseSpeed, boxX + 10, boxY + 58, 60, "left")
        
        love.graphics.setColor(0.8, 0.6, 0.5)
        love.graphics.printf("TIME:" .. level.timeLimit .. "s", boxX + 75, boxY + 58, 70, "left")
        
        -- Obstacle count
        love.graphics.setColor(0.6, 0.6, 0.8)
        love.graphics.printf(#level.schedule .. " OBJ", boxX + 145, boxY + 58, 50, "left")
        
        -- Difficulty indicator (stars based on speed)
        local difficulty = math.floor((level.baseSpeed - 100) / 50) + 1
        difficulty = math.max(1, math.min(5, difficulty))
        love.graphics.setColor(1, 0.8, 0.2)
        local stars = string.rep("*", difficulty)
        love.graphics.printf(stars, boxX + 10, boxY + 78, boxW - 20, "center")
    end
    
    -- Instructions
    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.printf("Arrow keys to select | ENTER or SPACE to start", 0, screenH - 60, screenW, "center")
    love.graphics.printf("ESC during game to return here | L for leaderboard", 0, screenH - 35, screenW, "center")
    
    love.graphics.setColor(1, 1, 1)
end

function Levels:selectorKeypressed(key)
    local cols = 3
    
    if key == "left" then
        self.selectorIndex = math.max(1, self.selectorIndex - 1)
    elseif key == "right" then
        self.selectorIndex = math.min(#self.data, self.selectorIndex + 1)
    elseif key == "up" then
        if self.selectorIndex > cols then
            self.selectorIndex = self.selectorIndex - cols
        end
    elseif key == "down" then
        if self.selectorIndex + cols <= #self.data then
            self.selectorIndex = self.selectorIndex + cols
        end
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
