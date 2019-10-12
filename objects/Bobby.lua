Bobby = BubbleEntity:extend()
local boximg

function Bobby:new(area, x, y, colrows, water)
    Bobby.super.new(self, area, x, y, water)
    self.r = 0
    self.w = 12
    self.water = water

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    body:setObject(self)
    body:setDensity(0.1)
    body:setAngularDamping(1)
    body:setLinearDamping(0.4)
    body:setFriction(0.36)

    self.collider = body

    boximg = love.graphics.newImage("img/bobby.png")
end

function Bobby:update(dt)
    Bobby.super.update(self, dt)

    self.r = self.collider:getAngle()

    local waterHeight = self.water:getHeight(self.x)

    if (waterHeight and self.y > waterHeight) then
        self.collider:applyForce(0, -10)
    else
        self.collider:applyForce(0, 100)
    end
end

function Bobby:draw()
    love.graphics.draw(boximg, self.x, self.y, self.r, 1, 1, boximg:getWidth() / 2, boximg:getHeight() / 2)

    local waterHeight = self.water:getHeight(self.x)

    if (waterHeight) then
        love.graphics.line(self.x, self.y, self.x, waterHeight)
    end
end
