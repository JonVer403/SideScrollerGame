-- ramp_obstacle.lua
-- Ramp / Jump Boost Obstacle

RampObstacle = {}
RampObstacle.__index = RampObstacle

-- Static sprite (loaded once, shared by all ramps)
RampObstacle.sprite = nil
RampObstacle.spriteLoaded = false

-- Default dimensions (larger for better visibility)
RampObstacle.DEFAULT_WIDTH = 100
RampObstacle.DEFAULT_HEIGHT = 60

function RampObstacle:loadSprite()
    if RampObstacle.spriteLoaded then return end
    
    local paths = {
        "Sprites/obstacle_ramp.png",
        "Sprites/ramp.png",
        "Sprites/jump_ramp.png"
    }
    
    for _, path in ipairs(paths) do
        if love.filesystem.getInfo(path) then
            RampObstacle.sprite = love.graphics.newImage(path)
            print("Ramp sprite loaded: " .. path)
            break
        end
    end
    
    RampObstacle.spriteLoaded = true
end

function RampObstacle:new(x, y, speed)
    local obj = {
        x = x or love.graphics.getWidth(),
        y = y or (love.graphics.getHeight() - RampObstacle.DEFAULT_HEIGHT),
        width = RampObstacle.DEFAULT_WIDTH,
        height = RampObstacle.DEFAULT_HEIGHT,
        speed = speed or 200,
        isHit = false,
        remove = false,
        obstacleType = "ramp"
    }
    
    -- Adjust Y so ramp sits on road (road is 80px tall)
    local roadHeight = 80
    obj.y = love.graphics.getHeight() - roadHeight - obj.height
    
    setmetatable(obj, RampObstacle)
    return obj
end

function RampObstacle:update(dt, speedMultiplier)
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
            print("Ramp hit - LAUNCH!")
            
            -- Give player a boost
            Player.dy = -550
            Player.grounded = false
            
            -- Bonus points
            TimeScore = TimeScore + 2
            
            if Sound then
                Sound:play("ramp")
            end
        end
    end
end

function RampObstacle:draw()
    if RampObstacle.sprite then
        -- Draw sprite
        if self.isHit then
            love.graphics.setColor(0.7, 0.7, 0.5, 0.8)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        local imgW = RampObstacle.sprite:getWidth()
        local imgH = RampObstacle.sprite:getHeight()
        local scaleX = self.width / imgW
        local scaleY = self.height / imgH
        
        love.graphics.draw(RampObstacle.sprite, self.x, self.y, 0, scaleX, scaleY)
    else
        -- Fallback: draw ramp shape
        self:drawFallback()
    end
    
    love.graphics.setColor(1, 1, 1)
end

function RampObstacle:drawFallback()
    -- Main ramp color (yellow/gold)
    if self.isHit then
        love.graphics.setColor(0.6, 0.6, 0.3)
    else
        love.graphics.setColor(1, 0.85, 0.2)
    end
    
    -- Triangle ramp shape (sloped to the right)
    love.graphics.polygon("fill", 
        self.x, self.y + self.height,                    -- Bottom left
        self.x + self.width, self.y + self.height,       -- Bottom right
        self.x + self.width, self.y                      -- Top right
    )
    
    -- Highlight stripe on ramp surface
    love.graphics.setColor(1, 0.95, 0.5)
    love.graphics.polygon("fill",
        self.x + 20, self.y + self.height - 8,
        self.x + self.width - 8, self.y + self.height - 8,
        self.x + self.width - 8, self.y + 12
    )
    
    -- Grip strips on ramp
    love.graphics.setColor(0.4, 0.4, 0.4)
    local numStrips = 5
    for i = 1, numStrips do
        local t = i / (numStrips + 1)
        local stripX = self.x + t * self.width
        local stripY = self.y + self.height - t * self.height
        love.graphics.setLineWidth(2)
        love.graphics.line(
            stripX - 5, stripY + 5,
            stripX + 5, stripY - 5
        )
    end
    love.graphics.setLineWidth(1)
    
    -- Outline
    love.graphics.setColor(0.6, 0.5, 0.1)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", 
        self.x, self.y + self.height,
        self.x + self.width, self.y + self.height,
        self.x + self.width, self.y
    )
    love.graphics.setLineWidth(1)
    
    -- Green arrow indicator (shows this is a boost)
    if not self.isHit then
        love.graphics.setColor(0, 0.8, 0.2)
        local arrowX = self.x + self.width - 25
        local arrowY = self.y + self.height - 30
        
        -- Up arrow
        love.graphics.polygon("fill",
            arrowX, arrowY + 15,
            arrowX + 10, arrowY + 15,
            arrowX + 10, arrowY + 5,
            arrowX + 15, arrowY + 5,
            arrowX + 5, arrowY - 5,
            arrowX - 5, arrowY + 5,
            arrowX, arrowY + 5
        )
    end
end
