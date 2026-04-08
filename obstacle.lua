-- obstacle.lua

Obstacle = {}
Obstacle.__index = Obstacle

-- Obstacle types:
-- "ground" - regular ground obstacle
-- "flying" - floats in the air, moves up/down
-- "ramp"   - gives player a boost when touched

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
                -- Ramp: launch player into the air
                print("Ramp hit - LAUNCH!")
                Player.dy = -800  -- Strong upward boost
                Player.grounded = false
                -- Bonus points for using ramp
                TimeScore = TimeScore + 2
                if Sound then
                    Sound:play("jump")
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
    if self.obstacleType == "ramp" then
        -- Draw ramp (yellow/orange triangle)
        if self.isHit then
            love.graphics.setColor(0.5, 0.5, 0.2)
        else
            love.graphics.setColor(1, 0.8, 0.2)
        end
        
        -- Triangle shape for ramp
        love.graphics.polygon("fill", 
            self.x, self.y + self.height,                    -- Bottom left
            self.x + self.width, self.y + self.height,       -- Bottom right
            self.x + self.width, self.y                      -- Top right
        )
        love.graphics.setColor(0.6, 0.5, 0.1)
        love.graphics.polygon("line", 
            self.x, self.y + self.height,
            self.x + self.width, self.y + self.height,
            self.x + self.width, self.y
        )
        
    elseif self.obstacleType == "flying" then
        -- Draw flying enemy (purple, with "wings")
        if self.isHit then
            love.graphics.setColor(0.5, 0.2, 0.5)
        else
            love.graphics.setColor(0.7, 0.2, 0.8)
        end
        
        -- Main body
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- "Wings" effect
        local wingOffset = math.sin((self.floatTimer or 0) * 2) * 5
        love.graphics.setColor(0.9, 0.4, 1)
        love.graphics.polygon("fill",
            self.x - 10, self.y + self.height/2,
            self.x, self.y + 10 + wingOffset,
            self.x, self.y + self.height - 10 + wingOffset
        )
        love.graphics.polygon("fill",
            self.x + self.width + 10, self.y + self.height/2,
            self.x + self.width, self.y + 10 - wingOffset,
            self.x + self.width, self.y + self.height - 10 - wingOffset
        )
        
        -- Outline
        love.graphics.setColor(0.4, 0.1, 0.5)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        
    else
        -- Ground obstacle (orange/red)
        if self.isHit then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(0.8, 0.3, 0.1)
        end

        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Draw outline
        love.graphics.setColor(0.3, 0.1, 0)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end
