-- nos.lua
-- NOS Boost System (like Asphalt nitro boost)

NOS = {}

function NOS:load()
    -- NOS tank/meter
    self.charge = 0          -- Current NOS charge (0-100)
    self.maxCharge = 100
    self.isActive = false    -- Is boost currently active?
    self.boostDuration = 2   -- How long boost lasts (seconds)
    self.boostTimer = 0
    self.boostMultiplier = 2 -- Speed multiplier when boosting
    
    -- Visual settings
    self.barWidth = 200
    self.barHeight = 20
    self.barX = 10
    self.barY = 40
    
    -- Pickup settings (larger for better visibility)
    self.pickups = {}
    self.pickupSize = 55  -- Larger pickup size
    self.chargePerPickup = 25 -- How much NOS each pickup gives
end

function NOS:update(dt)
    -- Handle active boost
    if self.isActive then
        self.boostTimer = self.boostTimer - dt
        self.charge = self.charge - (self.maxCharge / self.boostDuration) * dt
        
        if self.boostTimer <= 0 or self.charge <= 0 then
            self:deactivate()
        end
    end
    
    -- Get current speed multiplier for pickup movement
    local speedMult = self:getSpeedMultiplier()
    
    -- Update pickups
    for i = #self.pickups, 1, -1 do
        local pickup = self.pickups[i]
        pickup.x = pickup.x - pickup.speed * speedMult * dt
        
        -- Bobbing animation
        pickup.floatTimer = (pickup.floatTimer or 0) + dt * 4
        pickup.drawY = pickup.y + math.sin(pickup.floatTimer) * 10
        
        -- Remove if off-screen
        if pickup.x + self.pickupSize < 0 then
            table.remove(self.pickups, i)
        else
            -- Check collision with player (use base y for collision, not animated)
            if self:checkCollisionAnimated(pickup) then
                self:collect(pickup)
                table.remove(self.pickups, i)
            end
        end
    end
end

function NOS:checkCollision(pickup)
    return pickup.x < Player.x + Player.width and
           pickup.x + self.pickupSize > Player.x and
           pickup.y < Player.y + Player.height and
           pickup.y + self.pickupSize > Player.y
end

function NOS:checkCollisionAnimated(pickup)
    -- Much larger hitbox for easier collection
    local hitboxX = pickup.x - 20
    local hitboxY = pickup.y - 40
    local hitboxWidth = self.pickupSize + 40
    local hitboxHeight = self.pickupSize + 80
    
    return hitboxX < Player.x + Player.width and
           hitboxX + hitboxWidth > Player.x and
           hitboxY < Player.y + Player.height and
           hitboxY + hitboxHeight > Player.y
end

function NOS:collect(pickup)
    -- Add charge, cap at max
    self.charge = math.min(self.charge + self.chargePerPickup, self.maxCharge)
    
    -- Play sound
    if Sound then
        Sound:play("nos_pickup")
    end
    print("NOS Collected! Charge: " .. self.charge)
end

function NOS:spawnPickup(x, y, speed)
    -- Spawn at a height where player can reach it with a jump
    local roadHeight = 140
    local defaultY = love.graphics.getHeight() - roadHeight - 120 - math.random(0, 40)
    local pickup = {
        x = x or love.graphics.getWidth(),
        y = y or defaultY,
        speed = speed or 200,
        floatTimer = math.random() * 6.28  -- For bobbing animation
    }
    table.insert(self.pickups, pickup)
end

function NOS:activate()
    if self.charge >= 25 and not self.isActive then -- Need at least 25% to activate
        self.isActive = true
        self.boostTimer = self.boostDuration * (self.charge / self.maxCharge)
        print("NOS BOOST ACTIVATED!")
        return true
    end
    return false
end

function NOS:deactivate()
    self.isActive = false
    self.charge = math.max(0, self.charge)
    self.boostTimer = 0
    print("NOS boost ended")
end

function NOS:getSpeedMultiplier()
    if self.isActive then
        return self.boostMultiplier
    end
    return 1
end

function NOS:draw()
    -- Draw NOS meter background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.barX, self.barY, self.barWidth, self.barHeight)
    
    -- Draw NOS meter fill
    local fillWidth = (self.charge / self.maxCharge) * self.barWidth
    
    if self.isActive then
        -- Flashing effect when active
        local flash = math.sin(love.timer.getTime() * 10) * 0.3 + 0.7
        love.graphics.setColor(0, flash, 1)
    else
        love.graphics.setColor(0, 0.7, 1)
    end
    
    love.graphics.rectangle("fill", self.barX, self.barY, fillWidth, self.barHeight)
    
    -- Draw border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", self.barX, self.barY, self.barWidth, self.barHeight)
    
    -- Draw NOS label
    love.graphics.print("NOS", self.barX + self.barWidth + 10, self.barY + 2)
    
    -- Draw pickups
    for i, pickup in ipairs(self.pickups) do
        local drawY = pickup.drawY or pickup.y
        
        -- Glow effect
        local glowSize = 5 + math.sin((pickup.floatTimer or 0) * 2) * 3
        love.graphics.setColor(0, 0.5, 1, 0.3)
        love.graphics.rectangle("fill", 
            pickup.x - glowSize, drawY - glowSize, 
            self.pickupSize + glowSize*2, self.pickupSize + glowSize*2,
            5, 5)
        
        -- Draw NOS canister (blue with N)
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.rectangle("fill", pickup.x, drawY, self.pickupSize, self.pickupSize, 3, 3)
        
        -- Border
        love.graphics.setColor(0, 0.4, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", pickup.x, drawY, self.pickupSize, self.pickupSize, 3, 3)
        love.graphics.setLineWidth(1)
        
        -- "N" label
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("N", pickup.x + 14, drawY + 10)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function NOS:reset()
    self.charge = 0
    self.isActive = false
    self.boostTimer = 0
    self.pickups = {}
end
