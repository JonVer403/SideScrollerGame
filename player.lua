-- player.lua

Player = {}

function Player:load()
    -- Road height constant
    local roadHeight = 80
    
    -- Collision box dimensions (hitbox) - larger for better gameplay
    self.width = 60
    self.height = 50
    
    self.x = 100
    self.y = love.graphics.getHeight() - roadHeight - self.height -- Start on road
    
    -- Sprite offset relative to collision box (for visual alignment)
    self.spriteOffsetX = -20  -- Sprite drawn left of hitbox
    self.spriteOffsetY = -30  -- Sprite drawn above hitbox
    self.spriteWidth = 100    -- Visual sprite width (larger)
    self.spriteHeight = 100   -- Visual sprite height (larger)

    self.dy = 0
    self.gravity = 1200           -- Faster fall
    self.jumpPower = -480         -- Adjusted for larger sprites
    self.maxJumpPower = -650      -- Adjusted max charged jump
    self.grounded = false
    
    -- Jump charge system
    self.jumpCharge = 0            -- 0 to 1
    self.chargeRate = 3            -- Faster charge
    self.isCharging = false
    self.maxChargeTime = 0.4       -- Quicker to full charge
    
    -- Sprite placeholder (will be nil until actual sprites are loaded)
    self.sprite = nil
    self.spriteQuads = {}          -- For sprite animation frames
    self.currentFrame = 1
    self.animTimer = 0
    self.animSpeed = 0.1           -- Seconds per frame
    
    -- Try to load sprite
    self:loadSprite()
end

function Player:loadSprite()
    -- Try to load player sprite if exists
    local spritePath = "sprites/player.png"
    if love.filesystem.getInfo(spritePath) then
        self.sprite = love.graphics.newImage(spritePath)
        print("Player sprite loaded")
        -- Could set up animation quads here
    else
        self.sprite = nil
        print("No player sprite found at " .. spritePath)
    end
end

function Player:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    -- Jump charging
    if self.isCharging and self.grounded then
        self.jumpCharge = math.min(1, self.jumpCharge + self.chargeRate * dt)
    end
    
    -- Gravity
    self.dy = self.dy + self.gravity * dt
    self.y = self.y + self.dy * dt

    -- Movement (affected by NOS boost)
    local moveSpeed = 200 * speedMultiplier
    
    if love.keyboard.isDown("left") then
        self.x = self.x - moveSpeed * dt
    end
    
    if love.keyboard.isDown("right") then
        self.x = self.x + moveSpeed * dt
    end
    
    -- Keep player in bounds
    self.x = math.max(0, math.min(self.x, love.graphics.getWidth() - self.width))

    -- Floor Collision (road is 80px tall)
    local roadHeight = 80
    local ground = love.graphics.getHeight() - roadHeight
    if self.y + self.height >= ground then
        self.y = ground - self.height
        self.dy = 0
        self.grounded = true
    end
    
    -- Animation update
    if self.sprite then
        self.animTimer = self.animTimer + dt
        if self.animTimer >= self.animSpeed then
            self.animTimer = 0
            self.currentFrame = self.currentFrame + 1
            -- Loop animation (adjust based on actual frame count)
            if self.currentFrame > 4 then
                self.currentFrame = 1
            end
        end
    end
end

function Player:startJumpCharge()
    if self.grounded then
        self.isCharging = true
        self.jumpCharge = 0
    end
end

function Player:releaseJumpCharge()
    if self.isCharging and self.grounded then
        -- Calculate jump power based on charge
        local chargeMultiplier = 1 + self.jumpCharge * 0.8 -- 1.0 to 1.8x
        self.dy = self.jumpPower * chargeMultiplier
        self.grounded = false
    end
    
    self.isCharging = false
    self.jumpCharge = 0
end

function Player:jump()
    -- Simple jump (for quick taps)
    if self.grounded then
        self.dy = self.jumpPower
        self.grounded = false
    end
end

function Player:draw()
    -- Calculate sprite position with offset for proper visual alignment
    local spriteX = self.x + self.spriteOffsetX
    local spriteY = self.y + self.spriteOffsetY
    
    if self.sprite then
        -- Draw sprite at offset position (aligned with collision box)
        love.graphics.setColor(1, 1, 1)
        
        -- Scale sprite to fit spriteWidth/spriteHeight
        local imgW = self.sprite:getWidth()
        local imgH = self.sprite:getHeight()
        local scaleX = self.spriteWidth / imgW
        local scaleY = self.spriteHeight / imgH
        
        love.graphics.draw(self.sprite, spriteX, spriteY, 0, scaleX, scaleY)
        
        -- Debug: draw collision box (uncomment to visualize hitbox)
        -- love.graphics.setColor(1, 0, 0, 0.5)
        -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    else
        -- Draw car-shaped placeholder instead of rectangle
        -- Car body color based on state
        if self.isCharging then
            local glow = 0.5 + self.jumpCharge * 0.5
            love.graphics.setColor(1, glow, 0)
        elseif not self.grounded then
            love.graphics.setColor(0.5, 0.7, 1)
        else
            love.graphics.setColor(0.8, 0.2, 0.2)  -- Red car
        end
        
        -- Draw car body (main rectangle at sprite position for visuals)
        love.graphics.rectangle("fill", spriteX + 5, spriteY + 30, 70, 30)
        
        -- Car roof
        love.graphics.rectangle("fill", spriteX + 20, spriteY + 15, 35, 20)
        
        -- Windows
        love.graphics.setColor(0.6, 0.8, 1)
        love.graphics.rectangle("fill", spriteX + 22, spriteY + 18, 14, 14)
        love.graphics.rectangle("fill", spriteX + 38, spriteY + 18, 14, 14)
        
        -- Wheels
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.circle("fill", spriteX + 20, spriteY + 60, 10)
        love.graphics.circle("fill", spriteX + 60, spriteY + 60, 10)
        
        -- Wheel rims
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.circle("fill", spriteX + 20, spriteY + 60, 4)
        love.graphics.circle("fill", spriteX + 60, spriteY + 60, 4)
        
        -- Debug: draw actual collision box (uncomment to see hitbox)
        -- love.graphics.setColor(0, 1, 0, 0.5)
        -- love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        
        -- Draw charge bar when charging
        if self.isCharging and self.jumpCharge > 0 then
            love.graphics.setColor(1, 0.5, 0)
            local barWidth = self.spriteWidth * self.jumpCharge
            love.graphics.rectangle("fill", spriteX, spriteY - 5, barWidth, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", spriteX, spriteY - 5, self.spriteWidth, 5)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

