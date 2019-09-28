Water = Entity:extend()

function Water:new(area, x, y, vx)
    Water.super.new(self, area, x, y)

    self.points = {}
    self.maxPoints = 200

    for n = 1, self.maxPoints do
        self.points[n] = {
            x = getPosition(n, self.maxPoints),
            y = self.y + 0,
            speed = {y = 0},
            mass = 1
        }
    end
end

function getPosition(n, max)
    return n / max * 4000 - 2000
end

function getClosestIndex(x, max, numPoints)
    local n = getFromPosition(x, max, numPoints)

    if not n then
        return
    end

    return math.round(n)
end

function getFromPosition(x, max, numPoints)
    local n = ((x + 2000) / 4000) * max

    if (n >= 1 and n < numPoints) then
        return n
    end

    return nil
end

function Water:splash(collider)
    local x, y = collider:getPosition()

    local xmin, ymin, xmax, ymax = collider:getBoundingBox()

    local nmin = getClosestIndex(xmin, self.maxPoints, #self.points)
    local nmax = getClosestIndex(xmax, self.maxPoints, #self.points)

    if not nmin or not nmax then
        return
    end

    local vx, vy = collider:getLinearVelocity()
    local mass = collider:getMass()

    local force = (-math.sqrt(math.abs(vx)) + vy / 10) * (mass or 1) / (nmax - nmin + 1) * 100

    --print(closestIndex)

    if math.abs(ymin) < 5 or math.abs(ymax) < 5 then
        --print("splash", nmin, nmax, force)
        for n = nmin, nmax do
            --print("splashing", n)

            self.points[n].y = self.points[n].y + force
        end
    end
end

function Water:getHeight(x)
    local index = getFromPosition(x, self.maxPoints, #self.points)
    if not index then
        return nil
    end

    local ratio = index - math.floor(index)

    return self.points[math.floor(index)].y * (1 - ratio) + self.points[math.ceil(index)].y * (ratio)
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

function drawPoly(polygon)
    if not polygon or #polygon ~= 4 then
        print("no poly")
        return
    else
        print("yo")
        printTable(polygon)
    end

    love.graphics.polygon(
        "fill",
        polygon[1].x,
        polygon[1].y,
        polygon[2].x,
        polygon[2].y,
        polygon[3].x,
        polygon[3].y,
        polygon[4].x,
        polygon[4].y
    )
end

function Water:draw()
    for n, point in ipairs(self.points) do
        if (n > 1) then
            local lastPoint = self.points[n - 1]

            love.graphics.line(point.x, point.y, lastPoint.x, lastPoint.y)
        end
    end

    love.graphics.setColor(0.3, 0.3, 1, 0.5)
    for v = 1, 1 do
        local a = self:getHeight(100 * v)
        local b = self:getHeight(100 + 100 * v)

        if (a and b) then
            local polygon = {}
            polygon[1] = {x = 100 * v, y = a}
            polygon[2] = {x = 100 + 100 * v, y = b}
            polygon[3] = {x = 100 + 100 * v, y = 1000}
            polygon[4] = {x = 100 * v, y = 1000}

            drawPoly(polygon)

            local polygon2 = {}
            polygon2[1] = {x = 100 * v, y = -200}
            polygon2[2] = {x = 100 + 100 * v, y = -200}
            polygon2[3] = {x = 100 + 100 * v, y = 0}
            polygon2[4] = {x = 100 * v, y = 0}
            love.graphics.setColor(0.3, 1, 0.3, 0.5)
            drawPoly(polygon2)
            local polygon3 = clip(polygon, polygon2)
            love.graphics.setColor(1, 0.3, 0.3, 0.5)
            drawPoly(polygon3)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end
