Bobby = BubbleEntity:extend()
local boximg = love.graphics.newImage("img/bobby.png")

function Bobby:new(area, x, y, water)
    Bobby.super.new(self, area, x, y, water)
    self.w = 24

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    body:setObject(self)
    body:setMass(1)
    body:setAngularDamping(0.1)
    body:setLinearDamping(0.4)
    body:setFriction(0.36)

    self.collider = body
end

function Bobby:update(dt)
    Bobby.super.update(self, dt)
end

function Bobby:draw()
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

    local waterHeight = self.water:getHeight(self.x)

    if (waterHeight) then
        love.graphics.line(self.x, self.y, self.x, waterHeight)
    end
end