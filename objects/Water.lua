Water = Entity:extend()

function Water:new(area, x, y, vx)
    Water.super.new(self, area, x, y)

    self.points = {}
    local maxPoints = 400
    for n = 1, maxPoints do
        self.points[n] = {
            x = getPosition(n, maxPoints),
            y = self.y + 0,
            speed = {y = 0},
            mass = 1
        }
    end
end

function getPosition(n, max)
    return n / max * 4000 - 2000
end

function getClosestIndex(x, max)
    return ((x + 2000) / 4000) * max
end

function Water:getIndex()
    local closestIndex
    local closestDistance
    for n, p in ipairs(self.points) do
        if closestDistance == nil or math.abs(p.x - x) < closestDistance then
            closestDistance = math.abs(p.x - x)
            closestIndex = n
        end
    end
end

function Water:splash(collider)
    local x, y = collider:getPosition()
    return
    -- local x1, y1, x2, y2, x3, y3, x4, y4 = collider:getBoundingBox()

    -- local xmin = x1 < x2 and x1 or x2

    -- local xmax = x3 > x4 and x3 or x4

    -- local nmin = getClosestIndex(xmin)
    -- local nmax = getClosestIndex(xmax)

    -- local vx, vy = collider:getLinearVelocity()
    -- local mass = collider:getMass()

    -- local index = getIndex()
    -- local force = (-math.sqrt(math.abs(vx)) + vy / 10) * (mass or 1) / (nmax - nmin + 1)

    -- --print(closestIndex)

    -- if math.abs(y) < 10 then
    --     for n = nmin, nmax do
    --         self.points[n].y = self.points[n].y + force
    --     end
    -- end
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

            p.speed.y = 0.99 * p.speed.y + acceleration

            p.y = p.y + p.speed.y
        end
    end
end

function Water:draw()
    for n, point in ipairs(self.points) do
        if (n > 1) then
            local lastPoint = self.points[n - 1]

            love.graphics.line(point.x, point.y, lastPoint.x, lastPoint.y)
        end
    end
end
