Lovebox = BubbleEntity:extend()
local boximg

function Lovebox:new(area, x, y, water)
    Lovebox.super.new(self, area, x, y, water)
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
    body:setFriction(0.4)

    self.collider = body
    self.isLoveBox = true

    boximg = love.graphics.newImage("img/lovebox.png")
    boombox = love.graphics.newImage("img/boombox.png")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")
end

function Lovebox:update(dt)
    Lovebox.super.update(self, dt)
end

function Lovebox:draw()
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
