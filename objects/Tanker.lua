Tanker = Entity:extend()
local sub_body

function Tanker:new(area, x, y, colrows)
    Tanker.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 256

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 25, self.w, 50)

    body:setObject(self)
    body:setMass(80)
    body:setAngularDamping(1)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)

    self.collider = body

    sub_body = love.graphics.newImage("img/tanker.png")

    self.explosion = love.audio.newSource("sfx/explosion.wav", "static")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")

    local rows = colrows or math.floor(love.math.random() * 4) + 3
    local cols = colrows or math.floor(love.math.random() * 4) + 2

    for i = 1, rows do
        for j = 1, cols do
            if (colrows or love.math.random() > 0.4) then
                self.area:addEntity(Lovebox(self.area, self.x + 25 - j * 16, self.y - i * 16))
            else
                self.area:addEntity(Box(self.area, self.x + 25 - j * 16, self.y - i * 16))
            end
        end
    end

    self.timer:after(
        0.4,
        function(f)
            xv, yv = self.collider:getLinearVelocity()

            if (love.math.random() > 0.3 and self.alive == false) then
                xv, yv = self.collider:getLinearVelocity()

                if (love.math.random() > 0.5) then
                    self.area:addEntity(
                        Bubble(self.area, self.x + math.cos(self.r) * self.w / 2, self.y - math.sin(self.r) * 24, xv)
                    )
                else
                    self.area:addEntity(Bubble(self.area, self.x - math.cos(self.r) * self.w / 2, self.y, xv))
                end
            end
            self.timer:after(0.1, f)
        end
    )
end

function Tanker:update(dt)
    Tanker.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.r = self.collider:getAngle()

    if (self.y > 1000) then
        self.dead = true
    end

    if (not self.alive) then
        return
    end

    if (self.y > 40) then
        self.alive = false
        self.collider:setLinearDamping(0.14)
        self.collider:applyAngularImpulse(5000)
        self.explosion_underwater:play()
    end

    if (self.y < 0) then
        self.collider:applyForce(0, 50000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -460000 * dt)
    end

    if (self.collider:getAngle() < 0) then
        self.collider:applyTorque(10000000 * dt)
    else
        self.collider:applyTorque(-10000000 * dt)
    end

    self.collider:applyForce(-160 * math.cos(self.r), -20 * math.sin(self.r))

    if self.collider:enter("Sub") then
        camera:shake(8, 0.7, 30)
        self.explosion:play()
    end
end

function Tanker:draw()
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
