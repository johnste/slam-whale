Bubble = Entity:extend()

function Bubble:new(area, x, y, vx)
    Bubble.super.new(self, area, x, y)
    self.radius = love.math.randomNormal(2, 2)
    self.vy = 0
    self.vx = vx
end

function Bubble:update(dt)
    Bubble.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.vy = self.vy + dt
    self.vx = self.vx * 0.6
    self.y = self.y - self.vy
    self.x = self.x + self.vx * dt
end

function Bubble:draw()
    love.graphics.circle("line", self.x, self.y, self.radius)
    --love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))

    -- love.graphics.print("x:" .. math.round(self.x, 0.1), self.x, self.y + 30)
    -- love.graphics.print("y:" .. math.round(self.y, 0.1), self.x, self.y + 44)
end
