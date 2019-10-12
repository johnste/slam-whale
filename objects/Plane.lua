Plane = BubbleEntity:extend()
local sub_body = love.graphics.newImage("img/biplane.png")

function Plane:new(area, x, y, colrows, water)
    self.level = -love.math.random() * 200 - 50
    Plane.super.new(self, area, x, y + self.level)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 40
    self.water = water
    print("HEY", inspect(self.water))

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 12, self.w, 20)
    body:setObject(self)
    body:setMass(0.3)
    body:setAngularDamping(1)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)
    body:setFriction(1)

    self.collider = body

    self.explosion = love.audio.newSource("sfx/explosion.wav", "static")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")

    local rows = 1
    local cols = 1

    self.area:addEntity(Lovebox(self.area, self.x - 1 * 16, self.y - 1 * 16 + 4))
end

function Plane:update(dt)
    Plane.super.update(self, dt)

    self.r = self.collider:getAngle()

    if (self.y > 20) then
        self.alive = false
        self.collider:applyForce(0, 3000 * dt)
    end

    if (self.y > 1000) then
        self.dead = true
    end

    if (not self.alive) then
        return
    end

    if (self.y > 40) then
        self.alive = false
        self.collider:setLinearDamping(0.14)
        self.collider:applyAngularImpulse(500)
        self.explosion_underwater:play()
    end

    if (self.y < self.level) then
        self.collider:applyForce(0, 3000 * dt)
    elseif (self.y > self.level) then
        self.collider:applyForce(0, -1200 * dt)
    end

    self.collider:applyForce(-3 * math.cos(self.r), -20 * math.sin(self.r))

    if self.collider:enter("Sub") then
        camera:shake(8, 0.7, 30)
        self.explosion:play()
    end
end

function Plane:draw()
    Plane.super.draw(self)
    love.graphics.draw(
        sub_body,
        self.x,
        self.y,
        self.collider:getAngle(),
        1,
        1,
        sub_body:getWidth() / 2,
        sub_body:getHeight() / 2
    )

    if self.alive then
        love.graphics.line(self.x, 800, self.x, 1000)
        love.graphics.line(self.x, 800, self.x + 20, 820)
        love.graphics.line(self.x, 800, self.x - 20, 820)
    end
end
