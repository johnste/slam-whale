Water = Entity:extend()

function Water:new(area, x, y, vx)
    Water.super.new(self, area, x, y)
    self.radius = love.math.randomNormal(2, 2)
    self.vy = 0
    self.vx = vx
end

function Water:update(dt)
    Water.super.update(self, dt)
end

function Water:draw()
end
