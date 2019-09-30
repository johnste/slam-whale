Boat = BubbleEntity:extend()
local sub_body

function Boat:new(area, x, y, colrows, water)
    Boat.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 64
    self.water = water

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y, self.w, 24)
    body:setObject(self)
    body:setMass(0.3)
    body:setAngularDamping(1)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)
    body:setFriction(1)

    self.collider = body

    sub_body = love.graphics.newImage("img/boat.png")

    self.explosion = love.audio.newSource("sfx/explosion.wav", "static")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")

    local rows = 1
    local cols = colrows or math.floor(love.math.random() * 2) + 1

    for i = 1, rows do
        for j = 1, cols do
            if (colrows or love.math.random() > 0.4) then
                self.area:addEntity(Lovebox(self.area, self.x - j * 16, self.y - i * 16 + 4))
            else
                self.area:addEntity(Box(self.area, self.x - j * 16, self.y - i * 16 + 4))
            end
        end
    end
end

function Boat:update(dt)
    Boat.super.update(self, dt)

    self.r = self.collider:getAngle()

    if (self.y < -50) then
        self.alive = false

        self.collider:applyTorque(100)
    end

    if (self.y > 1000) then
        self.dead = true
    end

    local vx, vy = self.collider:getLinearVelocity()

    if (not self.alive) then
        return
    end

    if (self.y > 40) then
        self.alive = false
        self.collider:setLinearDamping(0.14)
        self.collider:applyAngularImpulse(500)
        self.explosion_underwater:play()
    end

    --self.collider:applyForce(-3 * math.cos(self.r), -200 * math.sin(self.r))

    if self.collider:enter("Sub") then
        camera:shake(8, 0.7, 30)
        self.explosion:play()
    end
end

function Boat:draw()
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
