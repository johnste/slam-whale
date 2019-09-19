Ship = Entity:extend()
local sub_body

function Ship:new(area, x, y)
    Ship.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 128

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 12, self.w, 24)
    body:setObject(self)
    body:setMass(8)
    body:setAngularDamping(1)
    body:setLinearDamping(0.04)

    local cabin = self.area.world:newRectangleCollider(self.x + self.w / 2 - 28 - 8, self.y - 22 - 10, 28, 20)

    self.area.world:addJoint("WeldJoint", body, cabin, self.x + self.w / 2, self.y - 12)

    self.collider = body

    sub_body = love.graphics.newImage("img/ship.png")

    self.explosion = love.audio.newSource("sfx/explosion.wav", "static")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")

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

function Ship:update(dt)
    Ship.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.r = self.collider:getAngle()

    if (self.y > 1000) then
        self.dead = true
    end

    if (not self.alive) then
        return
    end

    if (self.y > 35) then
        self.alive = false
        self.collider:setLinearDamping(0.14)
        self.collider:applyAngularImpulse(5000)
        self.explosion_underwater:play()
    end

    if (self.y < 0) then
        self.collider:applyForce(0, 30000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -10000 * dt)
    end

    if (self.collider:getAngle() < 0) then
        self.collider:applyTorque(1000000 * dt)
    else
        self.collider:applyTorque(-1000000 * dt)
    end

    self.collider:applyForce(-40 * math.cos(self.r), -40 * math.sin(self.r))

    if self.collider:enter("Sub") then
        self.collider:applyLinearImpulse(0, 100)
        camera:shake(8, 0.7, 30)
        self.explosion:play()
    --self.collider:applyAngularImpulse(5000)
    end
end

function Ship:draw()
    -- for k, v in pairs(image) do
    --     print(k, v)
    -- end
    if not self.alive then
        love.graphics.setColor(0.1, 0.1, 0.1, 1)
    end

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
        --love.graphics.circle("line", self.x, self.y, self.w)
        love.graphics.line(self.x, 800, self.x, 4000)
        love.graphics.line(self.x, 800, self.x + 20, 820)
        love.graphics.line(self.x, 800, self.x - 20, 820)
    end

    -- love.graphics.print("x:" .. math.round(self.x, 0.1), self.x, self.y + 30)
    --love.graphics.print("y:" .. math.round(self.y, 0.1), self.x, self.y + 44)

    if not self.alive then
        love.graphics.setColor(1, 1, 1, 1)
    end
end
