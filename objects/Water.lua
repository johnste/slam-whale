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

    --print(closestIndex)

    --[[ if math.abs(ymin) < 5 or math.abs(ymax) < 5 then
        --print("splash", nmin, nmax, force)
        for n = nmin, nmax do
            --print("splashing", n)

            self.points[n].y = self.points[n].y + force
        end
    end ]]
    local a = self:getHeight(xmin)
    local b = self:getHeight(xmax)

    local vertices = {
        xmin,
        a,
        xmax,
        b,
        xmax,
        2000,
        xmin,
        2000
    }

    local thing = {collider:getWorldPoints(collider:getPoints())}

    local vertices3 = clip(vertices, thing)

    if #vertices3 < 6 then
        return
    end

    local cx, cy = mlib.polygon.getCentroid(vertices3)
    local area = mlib.polygon.getArea(vertices3)
    CX = cx
    CY = cy

    if cx and cy then
        local normalized = Vector.normalize(vx, vy)
        local density = 4
        local dragMag = density * normalized * normalized
        local dragForcex = dragMag * -vx
        local dragForcey = dragMag * -vy
        collider:applyForce(dragForcex, dragForcey)

        collider:applyForce(0, -area * collider:getDensity() * 2, cx, cy)
        local force = ((-math.sqrt(math.abs(vx)) + vy / 10) * (mass or 1) / (nmax - nmin + 1) / 1 * area) / 100000

        if math.abs(ymin) < 5 or math.abs(ymax) < 5 then
            --print("splash", nmin, nmax, force)
            for n = nmin, nmax do
                --print("splashing", n)

                self.points[n].y = self.points[n].y + force
            end
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

SPRING_FORCE = 0.005
BASELINE_FORCE = 0.005
DAMPENING = 0.99

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
                forceFromLeft = dy * SPRING_FORCE
            end

            if n == #self.points then
                forceFromRight = 0
            else
                local dy = self.points[n + 1].y - p.y
                forceFromRight = dy * SPRING_FORCE
            end

            local dy = self.y - p.y
            local forceToBaseLine = dy * BASELINE_FORCE

            local force = force + forceFromLeft + forceFromRight + forceToBaseLine

            local acceleration = force / p.mass

            p.speed.y = DAMPENING * p.speed.y + acceleration

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

    love.graphics.setColor(0.3, 0.3, 1, 0.5)
    for v = 1, 1 do
        local a = self:getHeight(100 * v)
        local b = self:getHeight(100 + 100 * v)

        if (a and b) then
            local vertices = {
                100 * v,
                a,
                100 + 100 * v,
                b,
                100 + 100 * v,
                1000,
                100 * v,
                1000
            }

            love.graphics.polygon("fill", vertices)

            local vertices2 = {
                100 * v,
                -200,
                100 + 100 * v,
                -200,
                100 + 100 * v,
                0,
                100 * v,
                0
            }
            love.graphics.setColor(0.3, 1, 0.3, 0.5)
            love.graphics.polygon("fill", vertices2)

            local vertices3 = clip(vertices, vertices2)
            love.graphics.setColor(1, 0.3, 0.3, 0.5)

            if (type(vertices3) == "table" and #vertices3 >= 6) then
                love.graphics.polygon("fill", vertices3)

                love.graphics.setColor(1, 0.3, 1, 0.7)
                local cx, cy = mlib.polygon.getCentroid(vertices3)
                local area = mlib.polygon.getArea(vertices3)

                love.graphics.print("" .. area, cx, cy)
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    if (CX and CY) then
    --love.graphics.circle("line", CX, CY, 20)
    end
end
