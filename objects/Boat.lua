Boat = Entity:extend()
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
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 12, self.w, 12)
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

    self.timer:after(
        0.4,
        function(f)
            xv, yv = self.collider:getLinearVelocity()

            if (love.math.random() > 0.3 and self.alive == false and self.y > 0) then
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

function Boat:update(dt)
    Boat.super.update(self, dt)

    self.r = self.collider:getAngle()

    if (self.y < -50) then
        self.alive = false
        self.collider:applyForce(0, 3000 * dt)
    end

    if (self.y > 1000) then
        self.dead = true
    end

    local vx, vy = self.collider:getLinearVelocity()

    if (math.abs(vy) < 10) then
        self.water:splash(self.x - self.w / 2, -vx / 40 + vy / 10)
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

    if (self.y < 0) then
        self.collider:applyForce(0, 3000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -1200 * dt)
    end

    if (self.collider:getAngle() < 0.1) then
        self.collider:applyTorque(100000 * dt)
    else
        self.collider:applyTorque(-100000 * dt)
    end

    self.collider:applyForce(-3 * math.cos(self.r), -20 * math.sin(self.r))

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
