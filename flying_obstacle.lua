-- flying_obstacle.lua
-- Flying Obstacle (Bird, Drone, Bat, etc.)

FlyingObstacle = {}
FlyingObstacle.__index = FlyingObstacle

-- Static sprite (loaded once, shared by all flying obstacles)
FlyingObstacle.sprite = nil
FlyingObstacle.spriteLoaded = false

-- Default dimensions (larger for better visibility)
FlyingObstacle.DEFAULT_WIDTH = 80
FlyingObstacle.DEFAULT_HEIGHT = 60

function FlyingObstacle:loadSprite()
    if FlyingObstacle.spriteLoaded then return end
    
    local paths = {
        "Sprites/obstacle_flying.png",
        "Sprites/flying_obstacle.png",
        "Sprites/bird.png",
        "Sprites/drone.png"
    }
    
    for _, path in ipairs(paths) do
        if love.filesystem.getInfo(path) then
            FlyingObstacle.sprite = love.graphics.newImage(path)
            print("Flying obstacle sprite loaded: " .. path)
            break
        end
    end
    
    FlyingObstacle.spriteLoaded = true
end

function FlyingObstacle:new(x, y, speed)
    local screenH = love.graphics.getHeight()
    local roadHeight = 80
    
    local obj = {
        x = x or love.graphics.getWidth(),
        y = y or (screenH - roadHeight - 180),  -- Fly above the road
        width = FlyingObstacle.DEFAULT_WIDTH,
        height = FlyingObstacle.DEFAULT_HEIGHT,
        speed = speed or 200,
        isHit = false,
        remove = false,
        obstacleType = "flying",
        
        -- Flying behavior
        floatTimer = math.random() * 6.28,  -- Random start phase
        floatAmplitude = 35,                 -- How much it bobs up/down
        floatSpeed = 3                       -- How fast it bobs
    }
    
    -- Store base Y for floating movement
    obj.baseY = obj.y
    
    setmetatable(obj, FlyingObstacle)
    return obj
end

function FlyingObstacle:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    -- Move left
    self.x = self.x - self.speed * speedMultiplier * dt
    
    -- Bobbing up and down motion
    self.floatTimer = self.floatTimer + dt * self.floatSpeed
    self.y = self.baseY + math.sin(self.floatTimer) * self.floatAmplitude
    
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
            print("Flying obstacle hit!")
            TimeScore = TimeScore - 5
            if Sound then
                Sound:play("hit")
            end
        end
    end
end

function FlyingObstacle:draw()
    if FlyingObstacle.sprite then
        -- Draw sprite
        if self.isHit then
            love.graphics.setColor(1, 0.5, 0.5, 0.7)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        local imgW = FlyingObstacle.sprite:getWidth()
        local imgH = FlyingObstacle.sprite:getHeight()
        local scaleX = self.width / imgW
        local scaleY = self.height / imgH
        
        love.graphics.draw(FlyingObstacle.sprite, self.x, self.y, 0, scaleX, scaleY)
    else
        -- Fallback: draw bird/bat shape
        self:drawFallback()
    end
    
    love.graphics.setColor(1, 1, 1)
end

function FlyingObstacle:drawFallback()
    local cx = self.x + self.width / 2
    local cy = self.y + self.height / 2
    
    -- Body color
    if self.isHit then
        love.graphics.setColor(0.5, 0.2, 0.5, 0.7)
    else
        love.graphics.setColor(0.6, 0.15, 0.7)  -- Purple
    end
    
    -- Main body (oval)
    love.graphics.ellipse("fill", cx, cy, self.width * 0.35, self.height * 0.4)
    
    -- Head
    love.graphics.ellipse("fill", cx + self.width * 0.25, cy - 5, self.width * 0.18, self.height * 0.22)
    
    -- Animated wings
    local wingOffset = math.sin(self.floatTimer * 4) * 12
    love.graphics.setColor(0.8, 0.3, 0.95)
    
    -- Left wing
    love.graphics.polygon("fill",
        cx - self.width * 0.15, cy,
        cx - self.width * 0.5, cy - 20 + wingOffset,
        cx - self.width * 0.55, cy + wingOffset,
        cx - self.width * 0.5, cy + 15 + wingOffset
    )
    
    -- Right wing
    love.graphics.polygon("fill",
        cx - self.width * 0.15, cy,
        cx - self.width * 0.5, cy - 20 - wingOffset,
        cx - self.width * 0.55, cy - wingOffset,
        cx - self.width * 0.5, cy + 15 - wingOffset
    )
    
    -- Tail feathers
    love.graphics.setColor(0.5, 0.1, 0.6)
    love.graphics.polygon("fill",
        cx - self.width * 0.3, cy,
        cx - self.width * 0.5, cy - 8,
        cx - self.width * 0.55, cy,
        cx - self.width * 0.5, cy + 8
    )
    
    -- Eye (bright yellow)
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", cx + self.width * 0.32, cy - 8, 6)
    
    -- Pupil
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", cx + self.width * 0.34, cy - 8, 3)
    
    -- Beak
    love.graphics.setColor(1, 0.6, 0)
    love.graphics.polygon("fill",
        cx + self.width * 0.4, cy - 2,
        cx + self.width * 0.55, cy + 2,
        cx + self.width * 0.4, cy + 6
    )
end
