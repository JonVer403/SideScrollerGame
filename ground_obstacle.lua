-- ground_obstacle.lua
-- Ground Obstacle (Traffic Cone, Barrier, etc.)

GroundObstacle = {}
GroundObstacle.__index = GroundObstacle

-- Static sprite (loaded once, shared by all ground obstacles)
GroundObstacle.sprite = nil
GroundObstacle.spriteLoaded = false

-- Default dimensions (larger for better visibility)
GroundObstacle.DEFAULT_WIDTH = 70
GroundObstacle.DEFAULT_HEIGHT = 80

function GroundObstacle:loadSprite()
    if GroundObstacle.spriteLoaded then return end
    
    local paths = {
        "Sprites/obstacle_ground.png",
        "Sprites/ground_obstacle.png",
        "Sprites/cone.png",
        "Sprites/obstacle.png"  -- Fallback
    }
    
    for _, path in ipairs(paths) do
        if love.filesystem.getInfo(path) then
            GroundObstacle.sprite = love.graphics.newImage(path)
            print("Ground obstacle sprite loaded: " .. path)
            break
        end
    end
    
    GroundObstacle.spriteLoaded = true
end

function GroundObstacle:new(x, y, speed)
    local obj = {
        x = x or love.graphics.getWidth(),
        y = y or (love.graphics.getHeight() - 140),
        width = GroundObstacle.DEFAULT_WIDTH,
        height = GroundObstacle.DEFAULT_HEIGHT,
        speed = speed or 200,
        isHit = false,
        remove = false,
        obstacleType = "ground"
    }
    
    -- Adjust Y so obstacle sits on road (road is 140px tall)
    local roadHeight = 140
    obj.y = love.graphics.getHeight() - roadHeight - obj.height
    
    setmetatable(obj, GroundObstacle)
    return obj
end

function GroundObstacle:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    -- Move left
    self.x = self.x - self.speed * speedMultiplier * dt
    
    -- Mark for removal if off-screen
    if self.x + self.width < 0 then
        self.remove = true
    end
    
    -- Collision check with player
    if not self.isHit then
        if self.x < Player.x + Player.width and
           self.x + self.width > Player.x and
           self.y < Player.y + Player.height and
           self.y + self.height > Player.y then
            
            self.isHit = true
            print("Ground obstacle hit!")
            TimeScore = TimeScore - 5
            if Sound then
                Sound:play("hit")
            end
        end
    end
end

function GroundObstacle:draw()
    if GroundObstacle.sprite then
        -- Draw sprite
        if self.isHit then
            love.graphics.setColor(1, 0.5, 0.5, 0.7)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        local imgW = GroundObstacle.sprite:getWidth()
        local imgH = GroundObstacle.sprite:getHeight()
        local scaleX = self.width / imgW
        local scaleY = self.height / imgH
        
        love.graphics.draw(GroundObstacle.sprite, self.x, self.y, 0, scaleX, scaleY)
    else
        -- Fallback: draw traffic cone shape
        self:drawFallback()
    end
    
    love.graphics.setColor(1, 1, 1)
end

function GroundObstacle:drawFallback()
    -- Save state for proper reset
    local prevLineWidth = love.graphics.getLineWidth()
    
    -- Traffic cone / barrier style
    if self.isHit then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 0.5, 0)  -- Orange
    end

    -- Traffic cone shape (trapezoid)
    local baseWidth = self.width
    local topWidth = self.width * 0.35
    local topX = self.x + (baseWidth - topWidth) / 2
    
    love.graphics.polygon("fill",
        self.x, self.y + self.height,                        -- Bottom left
        self.x + baseWidth, self.y + self.height,            -- Bottom right
        topX + topWidth, self.y,                             -- Top right
        topX, self.y                                         -- Top left
    )
    
    -- White reflective stripes
    love.graphics.setColor(1, 1, 1)
    local numStripes = 3
    local stripeHeight = self.height / (numStripes * 2)
    
    for i = 1, numStripes do
        local sy = self.y + (i * 2 - 1) * stripeHeight
        local ratio = 1 - (sy - self.y) / self.height
        local sw = baseWidth * (0.35 + 0.65 * ratio)
        local sx = self.x + (baseWidth - sw) / 2
        love.graphics.rectangle("fill", sx + 2, sy, sw - 4, stripeHeight * 0.7)
    end
    
    -- Orange tip at top
    love.graphics.setColor(1, 0.3, 0)
    love.graphics.polygon("fill",
        topX + 5, self.y + 5,
        topX + topWidth - 5, self.y + 5,
        topX + topWidth / 2 + self.x / self.x, self.y - 5
    )
    
    -- Dark outline
    love.graphics.setColor(0.4, 0.2, 0)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line",
        self.x, self.y + self.height,
        self.x + baseWidth, self.y + self.height,
        topX + topWidth, self.y,
        topX, self.y
    )
    
    -- Reset graphics state
    love.graphics.setLineWidth(prevLineWidth)
    love.graphics.setColor(1, 1, 1, 1)
end
