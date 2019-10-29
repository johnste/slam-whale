Ship = BubbleEntity:extend()
local sub_body = love.graphics.newImage("img/ship.png")

function Ship:new(area, x, y, water)
    Ship.super.new(self, area, x, y, water)
    self.w = 128
    self.speed = 1200

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - 12, self.w, 24)
    body:setObject(self)
    body:setMass(20)
    body:setAngularDamping(3)
    body:setLinearDamping(0.04)
    body:setLinearVelocity(-25, 0)

    local cabin = self.area.world:newRectangleCollider(self.x + self.w / 2 - 28 - 8, self.y - 22 - 20, 28, 30)
    cabin:setMass(0.1)
    self.area.world:addJoint("WeldJoint", body, cabin, self.x + self.w / 2, self.y - 12)
    self.collider = body
end

function Ship:update(dt)
    Ship.super.update(self, dt)
end

function Ship:draw()
    Ship.super.draw(self)

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
