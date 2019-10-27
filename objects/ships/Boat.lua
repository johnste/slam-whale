Boat = BubbleEntity:extend()
local sub_body = love.graphics.newImage("img/boat.png")

function Boat:new(area, x, y, water)
    Boat.super.new(self, area, x, y, water)

    self.w = 64

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y, self.w, 12)
    body:setObject(self)
    body:setMass(2)
    body:setAngularDamping(2)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)
    body:setFriction(1)

    self.collider = body
end

function Boat:update(dt)
    Boat.super.update(self, dt)
end

function Boat:draw()
    Boat.super.draw(self)
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
