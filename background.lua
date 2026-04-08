-- background.lua
-- Parallax scrolling background system

Background = {}

function Background:load()
    self.layers = {}
    
    -- Create placeholder colored layers for parallax effect
    -- Layer 1: Sky (slowest)
    self.layers[1] = {
        color = {0.2, 0.3, 0.5},
        y = 0,
        height = love.graphics.getHeight() * 0.4,
        speed = 20,
        x = 0
    }
    
    -- Layer 2: Mountains (medium slow)
    self.layers[2] = {
        color = {0.3, 0.3, 0.4},
        y = love.graphics.getHeight() * 0.3,
        height = love.graphics.getHeight() * 0.3,
        speed = 50,
        x = 0
    }
    
    -- Layer 3: Hills (medium)
    self.layers[3] = {
        color = {0.2, 0.4, 0.2},
        y = love.graphics.getHeight() * 0.5,
        height = love.graphics.getHeight() * 0.3,
        speed = 100,
        x = 0
    }
    
    -- Layer 4: Ground (fastest, matches obstacle speed)
    self.layers[4] = {
        color = {0.3, 0.25, 0.2},
        y = love.graphics.getHeight() - 50,
        height = 50,
        speed = 200,
        x = 0
    }
    
    self.screenWidth = love.graphics.getWidth()
end

function Background:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    for i, layer in ipairs(self.layers) do
        layer.x = layer.x - layer.speed * speedMultiplier * dt
        
        -- Reset position for seamless scrolling
        if layer.x <= -self.screenWidth then
            layer.x = layer.x + self.screenWidth
        end
    end
end

function Background:draw()
    for i, layer in ipairs(self.layers) do
        love.graphics.setColor(layer.color)
        
        -- Draw two rectangles for seamless scrolling
        love.graphics.rectangle("fill", layer.x, layer.y, self.screenWidth, layer.height)
        love.graphics.rectangle("fill", layer.x + self.screenWidth, layer.y, self.screenWidth, layer.height)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Background:setSpeedMultiplier(multiplier)
    -- Used when NOS boost is active
    self.speedMultiplier = multiplier
end
