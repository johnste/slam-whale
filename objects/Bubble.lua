Bubble = Entity:extend()

function Bubble:new(area, x, y, vx)
    Bubble.super.new(self, area, x, y)
    self.radius = love.math.randomNormal(2, 2)
    self.vy = 0
    self.vx = vx
end

function Bubble:update(dt)
    Bubble.super.update(self, dt)

    self.vy = self.vy + dt
    self.vx = self.vx * 0.9
    self.y = self.y - self.vy
    self.x = self.x + self.vx * dt

    if (self.y <= 0) then
        self.dead = true
    end
end

function Bubble:draw()
    love.graphics.circle("line", self.x, self.y, self.radius)
end
