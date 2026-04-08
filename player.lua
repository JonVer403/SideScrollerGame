-- player.lua

Player = {}

function Player:load()
    self.x = 100
    self.y = love.graphics.getHeight() - 100 -- Start on ground
    self.width = 80
    self.height = 80

    self.dy = 0
    self.gravity = 900
    self.jumpPower = -500          -- Base jump power
    self.maxJumpPower = -900       -- Maximum charged jump power
    self.grounded = false
    
    -- Jump charge system
    self.jumpCharge = 0            -- 0 to 1
    self.chargeRate = 2            -- How fast charge builds (per second)
    self.isCharging = false
    self.maxChargeTime = 0.5       -- Time to reach full charge
    
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

    -- Floor Collision
    local ground = love.graphics.getHeight() - self.height
    if self.y >= ground then
        self.y = ground
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
    if self.sprite then
        -- Draw sprite
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.sprite, self.x, self.y)
    else
        -- Draw placeholder rectangle
        -- Color based on state
        if self.isCharging then
            -- Orange glow when charging
            local glow = 0.5 + self.jumpCharge * 0.5
            love.graphics.setColor(1, glow, 0)
        elseif not self.grounded then
            -- Light blue when airborne
            love.graphics.setColor(0.5, 0.7, 1)
        else
            -- White normally
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Draw charge bar when charging
        if self.isCharging and self.jumpCharge > 0 then
            love.graphics.setColor(1, 0.5, 0)
            local barWidth = self.width * self.jumpCharge
            love.graphics.rectangle("fill", self.x, self.y - 10, barWidth, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", self.x, self.y - 10, self.width, 5)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

