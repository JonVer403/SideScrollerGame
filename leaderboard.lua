-- leaderboard.lua
-- Leaderboard System (separate leaderboard per level)

Leaderboard = {}

function Leaderboard:load()
    self.maxEntries = 10
    self.filename = "leaderboard.txt"
    
    -- Initialize empty leaderboards for each level
    self.scores = {
        {}, -- Level 1
        {}, -- Level 2
        {}, -- Level 3
        {}  -- Level 4
    }
    
    -- UI state
    self.showingLeaderboard = false
    self.viewingLevel = 1
    self.playerName = "Player"
    self.inputMode = false
    self.inputBuffer = ""
    
    self:loadFromFile()
end

function Leaderboard:addScore(level, name, score, time)
    local entry = {
        name = name or self.playerName,
        score = score,
        time = time or os.time(),
        date = os.date("%Y-%m-%d")
    }
    
    table.insert(self.scores[level], entry)
    
    -- Sort by score (highest first)
    table.sort(self.scores[level], function(a, b)
        return a.score > b.score
    end)
    
    -- Keep only top entries
    while #self.scores[level] > self.maxEntries do
        table.remove(self.scores[level])
    end
    
    self:saveToFile()
    
    -- Return rank if in top 10, nil otherwise
    for i, e in ipairs(self.scores[level]) do
        if e.time == entry.time and e.score == entry.score then
            return i
        end
    end
    return nil
end

function Leaderboard:getTopScores(level, count)
    count = count or 10
    local result = {}
    for i = 1, math.min(count, #self.scores[level]) do
        table.insert(result, self.scores[level][i])
    end
    return result
end

function Leaderboard:isHighScore(level, score)
    if #self.scores[level] < self.maxEntries then
        return true
    end
    return score > self.scores[level][#self.scores[level]].score
end

function Leaderboard:saveToFile()
    local data = ""
    for level = 1, 4 do
        data = data .. "LEVEL" .. level .. "\n"
        for _, entry in ipairs(self.scores[level]) do
            data = data .. entry.name .. "," .. entry.score .. "," .. entry.date .. "\n"
        end
        data = data .. "END\n"
    end
    
    local success, message = love.filesystem.write(self.filename, data)
    if success then
        print("Leaderboard saved")
    else
        print("Failed to save leaderboard: " .. (message or "unknown error"))
    end
end

function Leaderboard:loadFromFile()
    if not love.filesystem.getInfo(self.filename) then
        print("No leaderboard file found, starting fresh")
        return
    end
    
    local content = love.filesystem.read(self.filename)
    if not content then return end
    
    local currentLevel = 0
    for line in content:gmatch("[^\r\n]+") do
        local levelNum = line:match("^LEVEL(%d+)$")
        if levelNum then
            currentLevel = tonumber(levelNum)
        elseif line == "END" then
            currentLevel = 0
        elseif currentLevel > 0 and currentLevel <= 4 then
            local name, score, date = line:match("([^,]+),([^,]+),([^,]+)")
            if name and score then
                table.insert(self.scores[currentLevel], {
                    name = name,
                    score = tonumber(score),
                    date = date or "unknown"
                })
            end
        end
    end
    
    print("Leaderboard loaded")
end

function Leaderboard:draw(currentLevel)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Title
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.printf("LEADERBOARD", 0, 40, screenW, "center")
    
    -- Level tabs
    local tabWidth = 150
    local tabStartX = (screenW - 4 * tabWidth) / 2
    for i = 1, 4 do
        local tabX = tabStartX + (i - 1) * tabWidth
        
        if i == self.viewingLevel then
            love.graphics.setColor(0.3, 0.5, 0.8)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", tabX, 80, tabWidth - 5, 30, 5, 5)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Level " .. i, tabX, 87, tabWidth - 5, "center")
    end
    
    -- Scores table
    local startY = 130
    local rowHeight = 35
    
    -- Header
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("RANK", screenW/2 - 250, startY, 60, "center")
    love.graphics.printf("NAME", screenW/2 - 150, startY, 150, "center")
    love.graphics.printf("SCORE", screenW/2 + 50, startY, 100, "center")
    love.graphics.printf("DATE", screenW/2 + 170, startY, 100, "center")
    
    -- Line
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.line(screenW/2 - 270, startY + 25, screenW/2 + 270, startY + 25)
    
    -- Entries
    local scores = self:getTopScores(self.viewingLevel, 10)
    for i, entry in ipairs(scores) do
        local y = startY + 30 + (i - 1) * rowHeight
        
        -- Rank colors
        if i == 1 then
            love.graphics.setColor(1, 0.84, 0) -- Gold
        elseif i == 2 then
            love.graphics.setColor(0.75, 0.75, 0.75) -- Silver
        elseif i == 3 then
            love.graphics.setColor(0.8, 0.5, 0.2) -- Bronze
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.printf("#" .. i, screenW/2 - 250, y, 60, "center")
        love.graphics.printf(entry.name, screenW/2 - 150, y, 150, "center")
        love.graphics.printf(string.format("%.0f", entry.score), screenW/2 + 50, y, 100, "center")
        love.graphics.printf(entry.date, screenW/2 + 170, y, 100, "center")
    end
    
    if #scores == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.printf("No scores yet!", 0, startY + 100, screenW, "center")
    end
    
    -- Instructions
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("Press 1-4 to view level | ESC to close | TAB to enter name", 0, screenH - 50, screenW, "center")
    
    -- Name input mode
    if self.inputMode then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", screenW/2 - 150, screenH/2 - 40, 300, 80)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", screenW/2 - 150, screenH/2 - 40, 300, 80)
        love.graphics.printf("Enter your name:", 0, screenH/2 - 30, screenW, "center")
        love.graphics.printf(self.inputBuffer .. "_", 0, screenH/2, screenW, "center")
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Leaderboard:keypressed(key)
    if self.inputMode then
        if key == "return" then
            if #self.inputBuffer > 0 then
                self.playerName = self.inputBuffer
            end
            self.inputMode = false
            self.inputBuffer = ""
        elseif key == "backspace" then
            self.inputBuffer = self.inputBuffer:sub(1, -2)
        elseif key == "escape" then
            self.inputMode = false
            self.inputBuffer = ""
        end
        return true
    end
    
    if key == "1" then self.viewingLevel = 1
    elseif key == "2" then self.viewingLevel = 2
    elseif key == "3" then self.viewingLevel = 3
    elseif key == "4" then self.viewingLevel = 4
    elseif key == "tab" then
        self.inputMode = true
        self.inputBuffer = self.playerName
    elseif key == "escape" then
        self.showingLeaderboard = false
    end
    
    return false
end

function Leaderboard:textinput(text)
    if self.inputMode and #self.inputBuffer < 15 then
        self.inputBuffer = self.inputBuffer .. text
    end
end

function Leaderboard:toggle(level)
    self.showingLeaderboard = not self.showingLeaderboard
    if level then
        self.viewingLevel = level
    end
end

function Leaderboard:isShowing()
    return self.showingLeaderboard
end
