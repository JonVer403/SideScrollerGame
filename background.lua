-- background.lua
-- Parallax scrolling background system with image support

Background = {}

function Background:load()
    self.layers = {}
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- Try to load background images
    self.images = {}
    self:loadImages()
    
    -- Define parallax layers (from back to front)
    -- Each layer can have an image OR fallback to colored rectangles
    self.layers = {
        -- Layer 1: Sky (slowest, always visible)
        {
            imageName = "sky",
            color = {0.4, 0.6, 0.9},  -- Light blue fallback
            y = 0,
            height = self.screenHeight * 0.6,
            speed = 20,
            x = 0
        },
        -- Layer 2: Clouds / Mountains (slow)
        {
            imageName = "clouds",
            color = {0.7, 0.7, 0.8},  -- Light grey fallback
            y = self.screenHeight * 0.1,
            height = self.screenHeight * 0.3,
            speed = 40,
            x = 0
        },
        -- Layer 3: City/Buildings (medium)
        {
            imageName = "city",
            color = {0.3, 0.3, 0.4},  -- Dark grey fallback
            y = self.screenHeight * 0.35,
            height = self.screenHeight * 0.35,
            speed = 80,
            x = 0
        },
        -- Layer 4: Road/Ground (fastest, matches game speed)
        {
            imageName = "road",
            color = {0.25, 0.25, 0.25},  -- Asphalt grey fallback
            y = self.screenHeight - 60,
            height = 60,
            speed = 200,
            x = 0
        }
    }
end

function Background:loadImages()
    -- Define image paths - images should be seamlessly tileable horizontally
    local imagePaths = {
        sky = "Sprites/background_sky.png",
        clouds = "Sprites/background_clouds.png", 
        city = "Sprites/background_city.png",
        road = "Sprites/background_road.png",
        -- Alternative: single full background
        full = "Sprites/background.png"
    }
    
    for name, path in pairs(imagePaths) do
        if love.filesystem.getInfo(path) then
            self.images[name] = love.graphics.newImage(path)
            self.images[name]:setWrap("repeat", "clamp")
            print("Background loaded: " .. name)
        else
            print("Background image not found: " .. path)
        end
    end
    
    -- Check for full single background alternative
    if self.images.full then
        self.useFullBackground = true
        print("Using full single background image")
    else
        self.useFullBackground = false
    end
end

function Background:update(dt, speedMultiplier)
    speedMultiplier = speedMultiplier or 1
    
    for i, layer in ipairs(self.layers) do
        layer.x = layer.x - layer.speed * speedMultiplier * dt
        
        -- Get the width to use for wrapping
        local wrapWidth = self.screenWidth
        local img = self.images[layer.imageName]
        if img then
            wrapWidth = img:getWidth()
        end
        
        -- Reset position for seamless scrolling
        if layer.x <= -wrapWidth then
            layer.x = layer.x + wrapWidth
        end
    end
end

function Background:draw()
    -- Option 1: Full single background with scrolling
    if self.useFullBackground and self.images.full then
        love.graphics.setColor(1, 1, 1)
        local img = self.images.full
        local imgW = img:getWidth()
        local imgH = img:getHeight()
        
        -- Scale to fit screen height
        local scale = self.screenHeight / imgH
        local scaledWidth = imgW * scale
        
        -- Calculate x position for seamless scroll (using first layer's x)
        local scrollX = self.layers[1].x * 0.5  -- Slower scroll for full bg
        
        -- Draw image twice for seamless looping
        love.graphics.draw(img, scrollX, 0, 0, scale, scale)
        love.graphics.draw(img, scrollX + scaledWidth, 0, 0, scale, scale)
        
        -- If scrolled past, wrap around
        if scrollX + scaledWidth < 0 then
            love.graphics.draw(img, scrollX + 2 * scaledWidth, 0, 0, scale, scale)
        end
        
        return
    end
    
    -- Option 2: Multi-layer parallax with images or colored rectangles
    for i, layer in ipairs(self.layers) do
        local img = self.images[layer.imageName]
        
        if img then
            -- Draw image layer
            love.graphics.setColor(1, 1, 1)
            local imgW = img:getWidth()
            local imgH = img:getHeight()
            
            -- Scale image to match layer height
            local scaleY = layer.height / imgH
            local scaleX = scaleY  -- Keep aspect ratio
            local scaledWidth = imgW * scaleX
            
            -- Draw enough copies to cover the screen seamlessly
            local drawX = layer.x
            while drawX < self.screenWidth do
                love.graphics.draw(img, drawX, layer.y, 0, scaleX, scaleY)
                drawX = drawX + scaledWidth
            end
            -- Draw one before to handle negative x
            love.graphics.draw(img, layer.x - scaledWidth, layer.y, 0, scaleX, scaleY)
        else
            -- Fallback: draw colored rectangle
            love.graphics.setColor(layer.color)
            
            -- Draw two rectangles for seamless scrolling
            love.graphics.rectangle("fill", layer.x, layer.y, self.screenWidth, layer.height)
            love.graphics.rectangle("fill", layer.x + self.screenWidth, layer.y, self.screenWidth, layer.height)
            
            -- Add some visual detail to the fallback (road lines, cloud shapes, etc.)
            self:drawLayerDetails(i, layer)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Background:drawLayerDetails(layerIndex, layer)
    -- Add visual details to fallback colored layers
    
    if layerIndex == 2 then
        -- Clouds - draw simple cloud shapes
        love.graphics.setColor(1, 1, 1, 0.6)
        local cloudOffset = layer.x % 200
        for i = 0, 5 do
            local cx = cloudOffset + i * 200
            local cy = layer.y + 20 + math.sin(i * 1.5) * 30
            love.graphics.ellipse("fill", cx, cy, 60, 25)
            love.graphics.ellipse("fill", cx + 40, cy - 5, 40, 20)
            love.graphics.ellipse("fill", cx - 30, cy + 5, 35, 18)
        end
        
    elseif layerIndex == 3 then
        -- City silhouette - draw building shapes
        love.graphics.setColor(0.2, 0.2, 0.25)
        local buildingOffset = layer.x % 100
        for i = 0, 12 do
            local bx = buildingOffset + i * 100
            local bh = 40 + (i * 17 % 60)  -- Varying heights
            local bw = 30 + (i * 11 % 40)
            love.graphics.rectangle("fill", bx, layer.y + layer.height - bh, bw, bh)
            -- Windows
            love.graphics.setColor(1, 0.9, 0.5, 0.3)
            for wy = 0, 3 do
                for wx = 0, 2 do
                    if math.random() > 0.3 then
                        love.graphics.rectangle("fill", bx + 5 + wx * 10, layer.y + layer.height - bh + 8 + wy * 12, 6, 8)
                    end
                end
            end
            love.graphics.setColor(0.2, 0.2, 0.25)
        end
        
    elseif layerIndex == 4 then
        -- Road - draw lane markings
        love.graphics.setColor(1, 1, 1, 0.8)
        local lineOffset = layer.x % 80
        for i = 0, 15 do
            local lx = lineOffset + i * 80
            local ly = layer.y + layer.height / 2 - 3
            love.graphics.rectangle("fill", lx, ly, 40, 6)
        end
        
        -- Road edges
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.rectangle("fill", 0, layer.y + 2, self.screenWidth, 3)
    end
end

function Background:setSpeedMultiplier(multiplier)
    -- Used when NOS boost is active
    self.speedMultiplier = multiplier
end

-- Info about setting up background images
function Background:getSetupInfo()
    return [[
Background Image Setup:
Place images in the Sprites folder:
- background_sky.png   : Sky layer (seamlessly tileable)
- background_clouds.png: Clouds layer
- background_city.png  : City/buildings layer  
- background_road.png  : Road/ground layer

OR use a single full background:
- background.png       : Full seamless background

Images should be:
- Seamlessly tileable horizontally
- PNG format with transparency (except sky)
- Recommended width: 800-1200px for smooth tiling
]]
end
