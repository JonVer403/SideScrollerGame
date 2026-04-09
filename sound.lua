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
        -- Player actions
        jump = "sounds/jump.wav",
        land = "sounds/land.wav",
        
        -- NOS system
        nos_pickup = "sounds/nos_pickup.wav",
        nos_activate = "sounds/nos_activate.wav",
        nos_end = "sounds/nos_end.wav",
        
        -- Obstacles
        hit = "sounds/hit.wav",
        ramp = "sounds/ramp.wav",
        
        -- Game events
        finish = "sounds/finish.wav",
        gameover = "sounds/gameover.wav",
        
        -- UI
        select = "sounds/select.wav",
        confirm = "sounds/confirm.wav",
        highscore = "sounds/highscore.wav",
        
        -- Ambient/Engine (optional looping sounds)
        engine = "sounds/engine.ogg",
        wind = "sounds/wind.ogg"
    }
    
    -- Try to load available sounds
    self:loadSounds()
end

function Sound:loadSounds()
    for name, path in pairs(self.soundDefinitions) do
        local info = love.filesystem.getInfo(path)
        if info then
            -- Use "static" for short effects, "stream" for longer audio
            local sourceType = "static"
            if name == "engine" or name == "wind" then
                sourceType = "stream"
            end
            self.sounds[name] = love.audio.newSource(path, sourceType)
            print("Loaded sound: " .. name)
        else
            -- Create placeholder (no actual file)
            self.sounds[name] = nil
            print("Sound not found: " .. path .. " (will use placeholder)")
        end
    end
end

function Sound:play(name, loop)
    if self.muted then return end
    
    local sound = self.sounds[name]
    if sound then
        sound:setVolume(self.sfxVolume)
        sound:setLooping(loop or false)
        sound:stop() -- Stop if already playing
        sound:play()
        return true
    else
        -- Placeholder: just print for now
        print("[SFX] " .. name)
        return false
    end
end

function Sound:stop(name)
    local sound = self.sounds[name]
    if sound then
        sound:stop()
    end
end

function Sound:setVolume(sfx, music)
    if sfx then self.sfxVolume = math.max(0, math.min(1, sfx)) end
    if music then self.musicVolume = math.max(0, math.min(1, music)) end
end

function Sound:toggleMute()
    self.muted = not self.muted
    -- Stop all playing sounds when muting
    if self.muted then
        for name, sound in pairs(self.sounds) do
            if sound then sound:stop() end
        end
    end
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

Player sounds:
- jump.wav       : Jump sound effect
- land.wav       : Landing sound

NOS sounds:
- nos_pickup.wav : NOS canister pickup
- nos_activate.wav : NOS boost activation  
- nos_end.wav    : NOS boost ending

Obstacle sounds:
- hit.wav        : Obstacle collision (negative)
- ramp.wav       : Ramp boost (positive)

Game event sounds:
- finish.wav     : Level completion
- gameover.wav   : Game over / time's up
- highscore.wav  : New high score

UI sounds:
- select.wav     : Menu navigation
- confirm.wav    : Menu selection

Ambient sounds (optional):
- engine.ogg     : Engine loop (for NOS boost)
- wind.ogg       : Wind/speed ambient

Supported formats: WAV, MP3, OGG
Recommended: WAV for short effects, OGG for loops
]]
end
