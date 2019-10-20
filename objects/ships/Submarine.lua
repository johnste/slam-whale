Submarine = BubbleEntity:extend()

local sub_body = love.graphics.newImage("img/sub-body.png")
local sub_wings = love.graphics.newImage("img/sub-wings.png")
local sub_tower = love.graphics.newImage("img/sub-tower.png")
local jumpsnd = love.audio.newSource("sfx/jump.wav", "static")
local slamsnd = love.audio.newSource("sfx/slam.wav", "static")
-- local splashsnd = love.audio.newSource("sfx/splash.wav", "static")

local SLAM_HEIGHT = -100

function Submarine:new(area, x, y, water)
    Submarine.super.new(self, area, x, y, water)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 200
    self.reversev = 100
    self.a = 200
    self.w = 12
    self.lasty = 0
    self.slamCharge = 0
    self.air = 0
    self.swim = true

    local body = self.area.world:newRectangleCollider(self.x - 16, self.y - 4, 32, 8)
    body:setObject(self)
    body:setAngularDamping(8)
    body:setLinearDamping(0.04)
    body:setCollisionClass("Sub")
    body:setBullet(true)
    body:setMass(2)
    self.collider = body
end

function Submarine:update(dt)
    Submarine.super.update(self, dt)
    camera:follow(self.x, self.y / 1.2)
    self.r = self.collider:getAngle()
    local waterHeight = self.water:getHeight(self.x)
    local turnForce = 400

    if input:down("go right") or input:down("go left") then
        local sign = fif(input:down("go right"), 1, -1)

        self.collider:applyTorque(sign * turnForce * self.collider:getMass())

        local _, vy = self.collider:getLinearVelocity()
        if self.y < waterHeight and math.abs(math.sin(self.r)) > 0.9 and math.abs(vy) < 5 then
            self.collider:applyTorque(sign * 25000 * dt)
            self.collider:applyForce(200, 0)
        end
    end

    if input:down("turbo") then
        -- Release turbo with existing slam charge

        self.slamCharge = math.min(self.air, self.slamCharge + dt)
    elseif self.slamCharge > 0 then
        local vx, vy = self.collider:getLinearVelocity()
        self.collider:setLinearVelocity(vx, vy + 1000 * self.slamCharge * math.sign(waterHeight - self.y))
        self.air = self.air - self.slamCharge
        self.slamCharge = 0
        self.isSlamming = true
        slamsnd:play()
    end

    if (self.y > waterHeight) then
        self.isSlamming = false
    end

    if (self.y < waterHeight) and not input:down("turbo") then
        self.air = math.min(1, self.air + dt / 2)
    end

    if (self.y < waterHeight) then
        if input:down("go down") then
            self.collider:applyForce(-self.reversev * self.collider:getMass() * 4 * math.cos(self.r), 0)
        end
        if input:down("go up") then
            self.collider:applyForce(self.v * self.collider:getMass() * 4 * math.cos(self.r), 0)
        end
    end

    if input:down("go down") then
        self.collider:applyForce(
            -self.reversev * math.cos(self.r) * self.collider:getMass() * 2,
            -self.reversev * math.sin(self.r) * self.collider:getMass() * 2
        )
    end

    if input:down("go up") then
        self.collider:applyForce(
            self.v * math.cos(self.r) * self.collider:getMass() * 2,
            self.v * math.sin(self.r) * self.collider:getMass() * 2
        )
    end

    local angle = self.collider:getAngle()
    local vx, vy = self.collider:getLinearVelocity()

    -- slow down when not facing forwards
    local splash = 1 - math.abs(Vector.dot(math.cos(angle), math.sin(angle), Vector.normalize(vx, vy)))
    if (splash > 0.5) then
        self.collider:setLinearVelocity(vx * 0.98, vy * 0.98)
    end

    self.lasty = self.y
end

function Submarine:draw()
    Submarine.super.draw(self)

    love.graphics.draw(sub_body, self.x, self.y, self.r, 1, 1, sub_body:getWidth() / 2, sub_body:getHeight() / 2)
    love.graphics.draw(
        sub_wings,
        self.x,
        self.y,
        self.r,
        1,
        math.sin(self.r),
        sub_wings:getWidth() / 2,
        sub_wings:getHeight() / 2
    )
    love.graphics.draw(
        sub_tower,
        self.x,
        self.y,
        self.r,
        1,
        math.cos(self.r),
        sub_tower:getWidth() / 2,
        sub_tower:getHeight() / 2
    )

    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.pop()

    love.graphics.rectangle("fill", self.x - 5, self.y - 10 - self.slamCharge * 100, 10, self.slamCharge * 100)
    love.graphics.rectangle("line", self.x - 5, self.y - 10 - self.air * 100, 10, self.air * 100)
end
