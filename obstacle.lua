-- obstacle.lua

Obstacle = {}
Obstacle.__index = Obstacle

function Obstacle:update(dt)
    -- 1. Move left
    self.x = self.x - self.speed * dt

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
            
            -- Add 10 to the TimeScore
            TimeScore = TimeScore + 10
            
            self.isHit = true
        end
    end
end

function Obstacle:draw()
    if self.isHit then
        love.graphics.setColor(1, 0, 0) -- Red if hit
    else
        love.graphics.setColor(0, 1, 0) -- Green normally
    end

    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1) -- Reset color
end
