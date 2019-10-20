Plane = BubbleEntity:extend()
local sub_body = love.graphics.newImage("img/biplane.png")

function Plane:new(area, x, y, water)
    self.level = -love.math.random() * 200 - 50
    Plane.super.new(self, area, x, y + self.level, water)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 40

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 12, self.w, 20)
    body:setObject(self)
    body:setMass(1)
    body:setAngularDamping(1)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)
    body:setFriction(1)

    self.collider = body
end

function Plane:update(dt)
    Plane.super.update(self, dt)
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
