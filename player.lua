Player = {}

function Player:load()
    self.x = 100
    self.y = love.graphics.getHeight() / 2
    self.width = 200
    self.height = 100
end

function Player:update(dt)
    if love.keyboard.isDown("space") then
        self.y = self.y - 500 * dt
    end
    if love.keyboard.isDown("lshift") then
        self.y = self.y + 500 * dt
    end
end

function Player:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end