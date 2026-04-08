-- sound.lua
-- Sound Effects Framework

Sound = {}

function Sound:load()
    self.sounds = {}
    self.musicVolume = 0.7
    self.sfxVolume = 1.0
    self.muted = false
    
    -- Define sound effects (will need actual audio files)
    self.soundDefinitions = {
        jump = "sounds/jump.wav",
        nos_pickup = "sounds/nos_pickup.wav",
        nos_activate = "sounds/nos_activate.wav",
        nos_end = "sounds/nos_end.wav",
        hit = "sounds/hit.wav",
        finish = "sounds/finish.wav",
        select = "sounds/select.wav",
        highscore = "sounds/highscore.wav"
    }
    
    -- Try to load available sounds
    self:loadSounds()
end

function Sound:loadSounds()
    for name, path in pairs(self.soundDefinitions) do
        local info = love.filesystem.getInfo(path)
        if info then
            self.sounds[name] = love.audio.newSource(path, "static")
            print("Loaded sound: " .. name)
        else
            -- Create placeholder (no actual file)
            self.sounds[name] = nil
            print("Sound not found: " .. path .. " (placeholder created)")
        end
    end
end

function Sound:play(name)
    if self.muted then return end
    
    local sound = self.sounds[name]
    if sound then
        sound:setVolume(self.sfxVolume)
        sound:stop() -- Stop if already playing
        sound:play()
    else
        -- Placeholder: just print for now
        print("[SFX] " .. name)
    end
end

function Sound:setVolume(sfx, music)
    if sfx then self.sfxVolume = math.max(0, math.min(1, sfx)) end
    if music then self.musicVolume = math.max(0, math.min(1, music)) end
end

function Sound:toggleMute()
    self.muted = not self.muted
    return self.muted
end

function Sound:isMuted()
    return self.muted
end

-- Create sounds directory structure info
function Sound:getSetupInfo()
    return [[
Sound Effects Setup:
Create a 'sounds' folder in your game directory with these files:
- jump.wav       : Jump sound effect
- nos_pickup.wav : NOS canister pickup
- nos_activate.wav : NOS boost activation
- nos_end.wav    : NOS boost ending
- hit.wav        : Obstacle collision
- finish.wav     : Level completion
- select.wav     : Menu selection
- highscore.wav  : New high score

Supported formats: WAV, MP3, OGG
]]
end
