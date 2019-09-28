Box = BubbleEntity:extend()
local boximg

function Box:new(area, x, y)
    Box.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 12

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    body:setObject(self)
    body:setMass(0.1)
    body:setAngularDamping(1)
    body:setLinearDamping(0.4)
    body:setFriction(0.36)

    self.collider = body

    boximg = love.graphics.newImage("img/deathbox.png")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")
end

function Box:update(dt)
    Box.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.r = self.collider:getAngle()

    if (self.y > 1000) then
        self.dead = true
    end

    if (self.y > 75) then
        self.alive = false
    --self.explosion_underwater:play()
    end

    if (self.y < 0) then
        self.collider:applyForce(0, 8000 * dt)
        self.collider:applyTorque(5)
    elseif (self.y > 0) then
        self.collider:applyForce(0, -1000 * dt)
    end
end

function Box:draw()
    love.graphics.draw(boximg, self.x, self.y, self.r, 1, 1, boximg:getWidth() / 2, boximg:getHeight() / 2)
end
