local Entity = Object:extend()

function Entity:new(area, x, y)
    self.area = area
    self.x = x
    self.y = y
    self.dead = false
end

function Entity:update(dt)
end

function Entity:draw()
end

return Entity
