-- player.lua

Player = {}

function Player:load()
    self.x = 100
    self.y = love.graphics.getHeight() / 2
    self.width = 200
    self.height = 100

    self.dy = 0
    self.gravity = 900
    self.jumpPower = -700
    self.grounded = false
end

function Player:update(dt)
    -- Gravity
    self.dy = self.dy + self.gravity * dt
    self.y = self.y + self.dy * dt

    -- Movement
    if love.keyboard.isDown("left") then
        self.x = self.x - 200 * dt
    end
    
    if love.keyboard.isDown("right") then
        self.x = self.x + 200 * dt
    end

    -- Floor Collision
    local ground = love.graphics.getHeight() - self.height
    if self.y >= ground then
        self.y = ground
        self.dy = 0
        self.grounded = true
    end
end

function Player:jump()
    if self.grounded then
        self.dy = self.jumpPower
        self.grounded = false
    end
end

function Player:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
