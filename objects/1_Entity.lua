Entity = Object:extend()

function Entity:new(area, x, y)
    self.area = area
    self.x = x
    self.y = y
    self.dead = false
    self.timer = Timer()
end

function Entity:update(dt)
    if self.collider then
        self.x, self.y = self.collider:getPosition()
    end

    self.timer:update(dt)
end

function Entity:draw()
end

function Entity:destroy()
end
