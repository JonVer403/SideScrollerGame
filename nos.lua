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
    
    -- Pickup settings
    self.pickups = {}
    self.pickupSize = 40
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
    
    -- Update pickups
    for i = #self.pickups, 1, -1 do
        local pickup = self.pickups[i]
        pickup.x = pickup.x - pickup.speed * dt
        
        -- Remove if off-screen
        if pickup.x + self.pickupSize < 0 then
            table.remove(self.pickups, i)
        else
            -- Check collision with player
            if self:checkCollision(pickup) then
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

function NOS:collect(pickup)
    -- Add charge, cap at max
    self.charge = math.min(self.charge + self.chargePerPickup, self.maxCharge)
    
    -- Could play sound here
    print("NOS Collected! Charge: " .. self.charge)
end

function NOS:spawnPickup(x, y, speed)
    local pickup = {
        x = x or love.graphics.getWidth(),
        y = y or (love.graphics.getHeight() - 100 - self.pickupSize),
        speed = speed or 200
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
        -- Draw NOS canister (blue with N)
        if self.isActive then
            love.graphics.setColor(0, 0.5, 1, 0.5 + math.sin(love.timer.getTime() * 5) * 0.5)
        else
            love.graphics.setColor(0, 0.7, 1)
        end
        love.graphics.rectangle("fill", pickup.x, pickup.y, self.pickupSize, self.pickupSize)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", pickup.x, pickup.y, self.pickupSize, self.pickupSize)
        love.graphics.print("N", pickup.x + 12, pickup.y + 10)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function NOS:reset()
    self.charge = 0
    self.isActive = false
    self.boostTimer = 0
    self.pickups = {}
end
