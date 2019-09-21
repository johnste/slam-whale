Fish = Entity:extend()

function Fish:new(area, x, y)
    Fish.super.new(self, area, x, y)

    self.vy = 0
    self.vx = (love.math.random() - 0.5) * 5

    if (love.math.random() > 0.5) then
        self.direction = 1
    else
        self.direction = -1
    end

    self.timer:after(
        0.4,
        function(f)
            if (love.math.random() > 0.3) then
                self.area:addEntity(Bubble(self.area, self.x, self.y, self.vx))
            end
            self.timer:after(0.61, f)
        end
    )

    fish = love.graphics.newImage("img/fish.png")
end

function Fish:update(dt)
    Fish.super.update(self, dt)

    self.vx = self.vx + dt * self.direction
    self.vy = self.vy + (love.math.random() - 0.5) / 20
    self.x = self.x - self.vx

    if (self.y <= 100) then
        self.vy = math.max(math.abs(self.vy) * 1.12, math.random() * 10 + 10)
    else
        self.vy = math.abs(self.vy) / 1.22
    end

    self.y = self.y + self.vy * dt

    if (self.x < -3000) or (self.x > 3000) then
        self.dead = true
    end
end

function Fish:draw()
    love.graphics.draw(fish, self.x, self.y, 0, self.direction, 1)
end
