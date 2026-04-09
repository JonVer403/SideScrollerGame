-- obstacle.lua
-- Obstacle System with Sprite Support

Obstacle = {}
Obstacle.__index = Obstacle

-- Static sprite storage (loaded once, shared by all obstacles)
Obstacle.sprites = {
    ground = nil,
    flying = nil,
    ramp = nil
}
Obstacle.spritesLoaded = false

-- Obstacle types:
-- "ground" - regular ground obstacle (traffic cone, barrier, etc.)
-- "flying" - floats in the air, moves up/down (bird, drone, etc.)
-- "ramp"   - gives player a boost when touched

function Obstacle:loadSprites()
    if Obstacle.spritesLoaded then return end
    
    local spritePaths = {
        ground = "Sprites/obstacle_ground.png",
        flying = "Sprites/obstacle_flying.png",
        ramp = "Sprites/obstacle_ramp.png",
        -- Fallback to generic obstacle sprite
        default = "Sprites/obstacle.png"
    }
    
    for name, path in pairs(spritePaths) do
        if love.filesystem.getInfo(path) then
            Obstacle.sprites[name] = love.graphics.newImage(path)
            print("Obstacle sprite loaded: " .. name)
        end
    end
    
    Obstacle.spritesLoaded = true
end

function Obstacle:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    -- 1. Move left (affected by NOS boost)
    self.x = self.x - self.speed * speedMultiplier * dt

    -- 2. Flying enemy movement (bobbing up and down)
    if self.obstacleType == "flying" then
        self.floatTimer = (self.floatTimer or 0) + dt * 3
        self.y = self.baseY + math.sin(self.floatTimer) * 40
    end

    -- 3. Mark for removal if off-screen (left side)
    if self.x + self.width < 0 then
        self.remove = true
    end

    -- 4. Collision Check
    if not self.isHit then
        if self.x < Player.x + Player.width and
           self.x + self.width > Player.x and
           self.y < Player.y + Player.height and
           self.y + self.height > Player.y then
            
            self.isHit = true
            
            if self.obstacleType == "ramp" then
                -- Ramp: moderate launch
                print("Ramp hit - LAUNCH!")
                Player.dy = -550  -- Moderate upward boost
                Player.grounded = false
                -- Bonus points for using ramp
                TimeScore = TimeScore + 2
                if Sound then
                    Sound:play("ramp")
                end
            else
                -- Regular obstacle or flying: penalty
                print("Obstacle hit - " .. (self.obstacleType or "ground"))
                TimeScore = TimeScore - 5
                if Sound then
                    Sound:play("hit")
                end
            end
        end
    end
end

function Obstacle:draw()
    -- Try to get sprite for this obstacle type
    local sprite = Obstacle.sprites[self.obstacleType] or Obstacle.sprites.default
    
    if sprite then
        -- Draw sprite
        if self.isHit then
            love.graphics.setColor(1, 0.5, 0.5, 0.7)  -- Reddish tint when hit
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        local imgW = sprite:getWidth()
        local imgH = sprite:getHeight()
        local scaleX = self.width / imgW
        local scaleY = self.height / imgH
        
        love.graphics.draw(sprite, self.x, self.y, 0, scaleX, scaleY)
    else
        -- Fallback: draw shapes
        self:drawFallback()
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Obstacle:drawFallback()
    -- Draw obstacle shapes as fallback when no sprites are loaded
    
    if self.obstacleType == "ramp" then
        -- Draw ramp (yellow/orange triangle pointing right)
        if self.isHit then
            love.graphics.setColor(0.5, 0.5, 0.2)
        else
            love.graphics.setColor(1, 0.8, 0.2)  -- Yellow/gold
        end
        
        -- Triangle shape for ramp (sloped to the right)
        love.graphics.polygon("fill", 
            self.x, self.y + self.height,                    -- Bottom left
            self.x + self.width, self.y + self.height,       -- Bottom right
            self.x + self.width, self.y                      -- Top right
        )
        
        -- Highlight stripe on ramp
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.polygon("fill",
            self.x + 15, self.y + self.height - 10,
            self.x + self.width - 10, self.y + self.height - 10,
            self.x + self.width - 10, self.y + 10
        )
        
        -- Outline
        love.graphics.setColor(0.6, 0.5, 0.1)
        love.graphics.polygon("line", 
            self.x, self.y + self.height,
            self.x + self.width, self.y + self.height,
            self.x + self.width, self.y
        )
        
        -- Arrow indicator
        love.graphics.setColor(0, 0.6, 0)
        love.graphics.polygon("fill",
            self.x + self.width - 20, self.y + self.height - 25,
            self.x + self.width - 5, self.y + self.height - 15,
            self.x + self.width - 20, self.y + self.height - 5
        )
        
    elseif self.obstacleType == "flying" then
        -- Draw flying enemy (bird/drone shape)
        if self.isHit then
            love.graphics.setColor(0.5, 0.2, 0.5)
        else
            love.graphics.setColor(0.7, 0.2, 0.8)  -- Purple
        end
        
        -- Main body (oval)
        local cx = self.x + self.width / 2
        local cy = self.y + self.height / 2
        love.graphics.ellipse("fill", cx, cy, self.width / 2, self.height / 2.5)
        
        -- "Wings" effect with animation
        local wingOffset = math.sin((self.floatTimer or 0) * 4) * 8
        love.graphics.setColor(0.9, 0.4, 1)
        
        -- Left wing
        love.graphics.polygon("fill",
            self.x + 5, cy,
            self.x - 15, cy - 10 + wingOffset,
            self.x - 15, cy + 10 + wingOffset
        )
        
        -- Right wing
        love.graphics.polygon("fill",
            self.x + self.width - 5, cy,
            self.x + self.width + 15, cy - 10 - wingOffset,
            self.x + self.width + 15, cy + 10 - wingOffset
        )
        
        -- Eye
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", self.x + self.width - 12, cy - 3, 5)
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", self.x + self.width - 10, cy - 3, 2)
        
    else
        -- Ground obstacle (traffic cone / barrier style)
        if self.isHit then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(1, 0.5, 0)  -- Orange
        end

        -- Traffic cone shape
        local baseWidth = self.width
        local topWidth = self.width * 0.4
        local topX = self.x + (baseWidth - topWidth) / 2
        
        love.graphics.polygon("fill",
            self.x, self.y + self.height,                        -- Bottom left
            self.x + baseWidth, self.y + self.height,            -- Bottom right
            topX + topWidth, self.y,                             -- Top right
            topX, self.y                                         -- Top left
        )
        
        -- White stripes on cone
        love.graphics.setColor(1, 1, 1)
        local stripeHeight = self.height / 4
        for i = 1, 2 do
            local sy = self.y + i * stripeHeight
            local ratio = (self.height - i * stripeHeight) / self.height
            local sw = baseWidth * (0.4 + 0.6 * ratio)
            local sx = self.x + (baseWidth - sw) / 2
            love.graphics.rectangle("fill", sx, sy, sw, stripeHeight * 0.6)
        end
        
        -- Outline
        love.graphics.setColor(0.6, 0.3, 0)
        love.graphics.polygon("line",
            self.x, self.y + self.height,
            self.x + baseWidth, self.y + self.height,
            topX + topWidth, self.y,
            topX, self.y
        )
    end
end

-- Info about setting up obstacle sprites
function Obstacle:getSetupInfo()
    return [[
Obstacle Sprite Setup:
Place images in the Sprites folder:
- obstacle_ground.png : Ground obstacle (cone, barrier)
- obstacle_flying.png : Flying obstacle (bird, drone)  
- obstacle_ramp.png   : Ramp/jump boost
- obstacle.png        : Default fallback sprite

Recommended sizes:
- Ground: 50x60 pixels
- Flying: 60x50 pixels
- Ramp: 80x50 pixels (triangular shape works best)

Use transparent backgrounds (PNG format)
]]
end
