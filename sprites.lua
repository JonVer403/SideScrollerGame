-- sprites.lua
-- Sprite Management System

Sprites = {}

function Sprites:load()
    self.images = {}
    self.quads = {}
    
    -- Define sprite paths
    self.definitions = {
        player = {
            path = "sprites/player.png",
            frameWidth = 80,
            frameHeight = 80,
            frames = 4
        },
        player_jump = {
            path = "sprites/player_jump.png",
            frameWidth = 80,
            frameHeight = 80,
            frames = 2
        },
        obstacle = {
            path = "sprites/obstacle.png",
            frameWidth = 80,
            frameHeight = 80,
            frames = 1
        },
        nos_pickup = {
            path = "sprites/nos_pickup.png",
            frameWidth = 40,
            frameHeight = 40,
            frames = 4
        },
        background_sky = {
            path = "sprites/bg_sky.png"
        },
        background_mountains = {
            path = "sprites/bg_mountains.png"
        },
        background_ground = {
            path = "sprites/bg_ground.png"
        }
    }
    
    self:loadAll()
end

function Sprites:loadAll()
    for name, def in pairs(self.definitions) do
        if love.filesystem.getInfo(def.path) then
            local img = love.graphics.newImage(def.path)
            self.images[name] = img
            
            -- Create animation quads if applicable
            if def.frames and def.frames > 1 then
                self.quads[name] = {}
                local imgWidth = img:getWidth()
                local imgHeight = img:getHeight()
                
                for i = 0, def.frames - 1 do
                    self.quads[name][i + 1] = love.graphics.newQuad(
                        i * def.frameWidth, 0,
                        def.frameWidth, def.frameHeight,
                        imgWidth, imgHeight
                    )
                end
            end
            
            print("Loaded sprite: " .. name)
        else
            print("Sprite not found: " .. def.path)
        end
    end
end

function Sprites:get(name)
    return self.images[name]
end

function Sprites:getQuad(name, frame)
    if self.quads[name] then
        return self.quads[name][frame] or self.quads[name][1]
    end
    return nil
end

function Sprites:draw(name, x, y, frame, r, sx, sy)
    local img = self.images[name]
    if not img then return false end
    
    local quad = nil
    if frame then
        quad = self:getQuad(name, frame)
    end
    
    if quad then
        love.graphics.draw(img, quad, x, y, r or 0, sx or 1, sy or 1)
    else
        love.graphics.draw(img, x, y, r or 0, sx or 1, sy or 1)
    end
    
    return true
end

function Sprites:isLoaded(name)
    return self.images[name] ~= nil
end

-- Helper to get setup instructions
function Sprites:getSetupInfo()
    return [[
Sprites Setup:
Create a 'sprites' folder in your game directory with these files:

Player sprites:
- player.png       : Spritesheet 320x80 (4 frames of 80x80)
- player_jump.png  : Spritesheet 160x80 (2 frames of 80x80)

Obstacles:
- obstacle.png     : Single 80x80 image

Pickups:
- nos_pickup.png   : Spritesheet 160x40 (4 frames of 40x40, animated glow)

Backgrounds (tileable horizontally):
- bg_sky.png       : 1280x290 (sky layer)
- bg_mountains.png : 1280x220 (mountains)
- bg_ground.png    : 1280x50 (ground)

All images should be PNG format with transparency where needed.
]]
end
