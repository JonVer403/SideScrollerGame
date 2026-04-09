-- background.lua
-- Parallax scrolling background system with smooth movement

Background = {}

-- Global game speed reference (set by main.lua based on current level)
Background.gameSpeed = 200

function Background:load()
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- Try to load background images
    self.images = {}
    self:loadImages()
    
    -- Define parallax layers (from back to front)
    -- Adjusted for better gameplay framing - road is dominant, sky reduced
    self.layers = {
        -- Layer 1: Sky (reduced height - gameplay focus on road)
        {
            imageName = "sky",
            color = {0.4, 0.6, 0.9},
            y = 0,
            height = self.screenHeight * 0.35,  -- Reduced from 0.6
            speedMultiplier = 0.1,  -- 10% of game speed
            x = 0
        },
        -- Layer 2: Clouds / Mountains (higher position, smaller)
        {
            imageName = "clouds",
            color = {0.7, 0.7, 0.8},
            y = self.screenHeight * 0.05,
            height = self.screenHeight * 0.18,
            speedMultiplier = 0.25,  -- 25% of game speed
            x = 0
        },
        -- Layer 3: City/Buildings (larger, more prominent)
        {
            imageName = "city",
            color = {0.3, 0.3, 0.4},
            y = self.screenHeight * 0.22,
            height = self.screenHeight * 0.58,  -- Much larger buildings
            speedMultiplier = 0.5,  -- 50% of game speed
            x = 0
        },
        -- Layer 4: Road/Ground (expanded for gameplay focus)
        {
            imageName = "road",
            color = {0.2, 0.2, 0.2},
            y = self.screenHeight - 140,  -- Larger road area
            height = 140,
            speedMultiplier = 1.0,  -- 100% - matches obstacle speed exactly
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
    
    -- Calculate actual speed based on game speed and NOS multiplier
    local actualGameSpeed = self.gameSpeed * speedMultiplier
    
    for i, layer in ipairs(self.layers) do
        -- Calculate layer speed relative to game speed
        local layerSpeed = actualGameSpeed * layer.speedMultiplier
        
        -- Update position (use precise float math for smoothness)
        layer.x = layer.x - layerSpeed * dt
        
        -- Get the width to use for wrapping
        local wrapWidth = self.screenWidth
        local img = self.images[layer.imageName]
        if img then
            wrapWidth = img:getWidth()
        end
        
        -- Seamless wrapping (use modulo for smooth looping without jumps)
        if layer.x <= -wrapWidth then
            layer.x = layer.x % wrapWidth
            if layer.x > 0 then
                layer.x = layer.x - wrapWidth
            end
        end
    end
end

-- Set the base game speed (called when level starts)
function Background:setGameSpeed(speed)
    self.gameSpeed = speed or 200
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
        local scrollX = math.floor(self.layers[1].x * 0.5)
        
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
        
        -- Use floor for pixel-perfect rendering (no sub-pixel jitter)
        local drawX = math.floor(layer.x)
        local drawY = math.floor(layer.y)
        
        if img then
            -- Draw image layer
            love.graphics.setColor(1, 1, 1)
            local imgW = img:getWidth()
            local imgH = img:getHeight()
            
            -- Scale image to match layer height
            local scaleY = layer.height / imgH
            local scaleX = scaleY  -- Keep aspect ratio
            local scaledWidth = math.ceil(imgW * scaleX)
            
            -- Draw enough copies to cover the screen seamlessly
            local x = drawX
            while x < self.screenWidth + scaledWidth do
                love.graphics.draw(img, x, drawY, 0, scaleX, scaleY)
                x = x + scaledWidth
            end
            -- Draw one before to handle negative x
            love.graphics.draw(img, drawX - scaledWidth, drawY, 0, scaleX, scaleY)
        else
            -- Fallback: draw colored rectangle
            love.graphics.setColor(layer.color)
            
            -- Draw three rectangles for seamless scrolling (covers all edge cases)
            love.graphics.rectangle("fill", drawX - self.screenWidth, drawY, self.screenWidth, layer.height)
            love.graphics.rectangle("fill", drawX, drawY, self.screenWidth, layer.height)
            love.graphics.rectangle("fill", drawX + self.screenWidth, drawY, self.screenWidth, layer.height)
            
            -- Add visual detail to the fallback
            self:drawLayerDetails(i, layer)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Background:drawLayerDetails(layerIndex, layer)
    -- Add visual details to fallback colored layers
    local drawX = math.floor(layer.x)
    
    if layerIndex == 2 then
        -- Clouds - draw simple cloud shapes
        love.graphics.setColor(1, 1, 1, 0.6)
        local cloudSpacing = 200
        local cloudOffset = drawX % cloudSpacing
        for i = -1, 6 do
            local cx = cloudOffset + i * cloudSpacing
            local cy = layer.y + 20 + math.sin(i * 1.5) * 30
            love.graphics.ellipse("fill", cx, cy, 60, 25)
            love.graphics.ellipse("fill", cx + 40, cy - 5, 40, 20)
            love.graphics.ellipse("fill", cx - 30, cy + 5, 35, 18)
        end
        
    elseif layerIndex == 3 then
        -- City silhouette - draw building shapes (scaled up for visual consistency)
        love.graphics.setColor(0.2, 0.2, 0.28)
        local buildingSpacing = 90  -- Closer together for denser skyline
        local buildingOffset = drawX % buildingSpacing
        for i = -1, 16 do
            local bx = buildingOffset + i * buildingSpacing
            -- Taller buildings that fill more of the layer
            local bh = 120 + ((i * 23) % 180)  -- Much taller buildings
            local bw = 50 + ((i * 13) % 35)    -- Wider buildings
            love.graphics.rectangle("fill", bx, layer.y + layer.height - bh, bw, bh)
            
            -- Windows (more windows for taller buildings)
            love.graphics.setColor(1, 0.9, 0.5, 0.5)
            local windowRows = math.floor(bh / 25)
            for wy = 0, windowRows do
                for wx = 0, 3 do
                    -- Use deterministic "random" based on position
                    if ((i + wx + wy) % 3) ~= 0 then
                        love.graphics.rectangle("fill", bx + 6 + wx * 11, layer.y + layer.height - bh + 10 + wy * 22, 7, 12)
                    end
                end
            end
            love.graphics.setColor(0.2, 0.2, 0.28)
        end
        
    elseif layerIndex == 4 then
        -- Road - draw lane markings (scaled for larger road)
        love.graphics.setColor(1, 1, 1, 0.9)
        local lineSpacing = 120
        local lineOffset = drawX % lineSpacing
        for i = -1, 15 do
            local lx = lineOffset + i * lineSpacing
            local ly = layer.y + layer.height / 2 - 5  -- Center of road
            love.graphics.rectangle("fill", lx, ly, 60, 10)  -- Larger dashes
        end
        
        -- Road edges (yellow lines - thicker for visibility)
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.rectangle("fill", 0, layer.y + 3, self.screenWidth, 6)
        love.graphics.rectangle("fill", 0, layer.y + layer.height - 8, self.screenWidth, 6)
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
