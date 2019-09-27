Submarine = BubbleEntity:extend()
local sub_body
local sub_wings
local sub_tower

function Submarine:new(area, x, y, water)
    Submarine.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 200
    self.reversev = 100
    self.a = 200
    self.w = 12
    self.lasty = 0
    self.water = water

    -- self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - 16, self.y - 4, 32, 8)
    body:setObject(self)
    body:setAngularDamping(1)
    body:setLinearDamping(0.1)
    body:setCollisionClass("Sub")
    body:setBullet(true)

    self.collider = body

    sub_body = love.graphics.newImage("img/sub-body.png")
    sub_wings = love.graphics.newImage("img/sub-wings.png")
    sub_tower = love.graphics.newImage("img/sub-tower.png")
end

function Submarine:update(dt)
    Submarine.super.update(self, dt)
    -- local xz, vz = self.collider:getLinearVelocity()
    -- camera:follow(self.x + xz / 2 * math.abs(math.cos(self.r)), self.y + vz / 2 * math.abs(math.sin(self.r)))
    camera:follow(self.x, self.y)
    self.r = self.collider:getAngle()

    if input:down("go right") then
        --self.r = self.r + self.rv * dt
        self.collider:applyTorque(15000 * dt)

        local _, vy = self.collider:getLinearVelocity()
        if self.y < 0 and math.abs(math.sin(self.r)) > 0.9 and math.abs(vy) < 5 then
            print("ok" .. math.abs(vy))
            self.collider:applyTorque(25000 * dt)
            self.collider:applyForce(200, 0)
        end
    end

    if input:down("go left") then
        --self.r = self.r - self.rv * dt
        self.collider:applyTorque(-15000 * dt)

        local _, vy = self.collider:getLinearVelocity()
        if self.y < 0 and math.abs(math.sin(self.r)) > 0.9 and math.abs(vy) < 5 then
            print("ok" .. math.abs(vy))
            self.collider:applyTorque(-25000 * dt)
            self.collider:applyForce(-200, 0)
        end
    end

    if input:down("turbo") then
        --self.r = self.r - self.rv * dt
        if (self.y < 0) then
            self.collider:applyForce(0, 500)
        end
    end

    if (self.y < 0) then
        if input:down("go down") then
            self.collider:applyForce(-self.reversev * 1 * math.cos(self.r), 0)
        end
        if input:down("go up") then
            self.collider:applyForce(self.v * 1 * math.cos(self.r), 0)
        end
    end

    if input:pressed("turbo") then
        self.slam:play()
    end

    if input:down("go down") then
        self.collider:applyForce(-self.reversev * math.cos(self.r), -self.reversev * math.sin(self.r))
    end

    if input:down("go up") then
        self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end

    local x, y = Vector.normalize(self.collider:getLinearVelocity())
    self.direction = Vector.dot(x, y, math.cos(self.r), math.sin(self.r))

    self.jump = love.audio.newSource("sfx/jump.wav", "static")
    self.slam = love.audio.newSource("sfx/slam.wav", "static")
    self.splash = love.audio.newSource("sfx/splash.wav", "static")

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if (self.lasty < 0 and self.y >= 0) then
        local vx, vy = self.collider:getLinearVelocity()

        local angle = self.collider:getAngle()

        local splash = math.abs(Vector.dot(math.cos(angle), math.sin(angle), 0, 1))

        self.collider:setLinearVelocity(vx, vy * splash)

        self.splash:play()

        self.water:splash(self.x, vy / 10 + math.abs(vx) / 50)
    end

    -- slow down when facing
    local vx, vy = self.collider:getLinearVelocity()
    local angle = self.collider:getAngle()
    local splash = 1 - math.abs(Vector.dot(math.cos(angle), math.sin(angle), Vector.normalize(vx, vy)))

    if (splash > 0.5) then
        self.collider:setLinearVelocity(vx * 0.98, vy * 0.98)
    end

    if (self.lasty > 0 and self.y <= 0) then
        self.jump:play()
    end

    self.lasty = self.y

    if (self.y < 0) then
        self.collider:applyForce(0, 30000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -100 * dt)
    end

    if (self.y > 1000) then
        self.collider:applyForce(0, -30000 * dt)
    end

    if (self.x > 2000) then
        self.collider:applyForce(-30000 * dt, 0)
    end

    if (self.x < -2000) then
        self.collider:applyForce(30000 * dt, 0)
    end
end

function Submarine:draw()
    -- for k, v in pairs(image) do
    --     print(k, v)
    -- end

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

    local xz, vz = self.collider:getLinearVelocity()
    love.graphics.circle(
        "fill",
        self.x + xz / 2 * math.abs(math.cos(self.r)),
        self.y + vz / 2 * math.abs(math.sin(self.r)),
        5
    )

    --love.graphics.circle("line", self.x, self.y, self.w)
    --love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))

    -- love.graphics.print("x:" .. math.round(self.x, 0.1), self.x, self.y + 30)
    -- love.graphics.print("y:" .. math.round(self.y, 0.1), self.x, self.y + 44)
end
