Box = BubbleEntity:extend()
local boximg

function Box:new(area, x, y)
    Box.super.new(self, area, x, y, water)
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
end

function Box:draw()
    Box.super.draw(self)
    love.graphics.draw(
        boximg,
        self.x,
        self.y,
        self.collider:getAngle(),
        1,
        1,
        boximg:getWidth() / 2,
        boximg:getHeight() / 2
    )
end
