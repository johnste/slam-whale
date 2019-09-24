Water = Entity:extend()

function Water:new(area, x, y, vx)
    Water.super.new(self, area, x, y)

    self.points = {}

    for n = 1, 200 do
        self.points[n] = {
            x = n / 200 * 4000 - 2000,
            y = self.y + 0,
            speed = {y = 0},
            mass = 1
        }
    end
end

function Water:splash(x, speed)
    local closestIndex
    local closestDistance
    for n, p in ipairs(self.points) do
        if closestDistance == nil or math.abs(p.x - x) < closestDistance then
            closestDistance = math.abs(p.x - x)
            closestIndex = n
        end
    end
    print(closestIndex)
    self.points[closestIndex].y = self.points[closestIndex].y + speed
end

function Water:update(dt)
    Water.super.update(self, dt)

    for i = 1, 3 do
        for n, p in ipairs(self.points) do
            local force = 0

            local forceFromLeft, forceFromRight

            if n == 1 then
                forceFromLeft = 0
            else
                local dy = self.points[n - 1].y - p.y
                forceFromLeft = dy * 0.005
            end

            if n == #self.points then
                forceFromRight = 0
            else
                local dy = self.points[n + 1].y - p.y
                forceFromRight = dy * 0.005
            end

            local dy = self.y - p.y
            local forceToBaseLine = dy * 0.005

            local force = force + forceFromLeft + forceFromRight + forceToBaseLine

            local acceleration = force / p.mass

            p.speed.y = 0.98 * p.speed.y + acceleration

            p.y = p.y + p.speed.y
        end
    end
end

function Water:draw()
    for n, point in ipairs(self.points) do
        love.graphics.circle("line", point.x, point.y, 5)
    end
end
