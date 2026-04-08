-- obstacle.lua

Obstacle = {}
Obstacle.__index = Obstacle

function Obstacle:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    -- 1. Move left (affected by NOS boost)
    self.x = self.x - self.speed * speedMultiplier * dt

    -- 2. Mark for removal if off-screen (left side)
    if self.x + self.width < 0 then
        self.remove = true
    end

    -- 3. Collision Check
    if not self.isHit then
        if self.x < Player.x + Player.width and
           self.x + self.width > Player.x and
           self.y < Player.y + Player.height and
           self.y + self.height > Player.y then
            
            print("Obstacle hit") 
            
            -- Subtract time when hit (penalty)
            TimeScore = TimeScore - 5
            
            self.isHit = true
            
            -- Play sound (if available)
            if Sound then
                Sound:play("hit")
            end
        end
    end
end

function Obstacle:draw()
    if self.isHit then
        love.graphics.setColor(1, 0, 0) -- Red if hit
    else
        love.graphics.setColor(0.8, 0.3, 0.1) -- Orange normally
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw outline
    love.graphics.setColor(0.3, 0.1, 0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(1, 1, 1) -- Reset color
end
