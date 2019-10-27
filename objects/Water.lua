Water = Entity:extend()

local CX
local CY

local function getPosition(n, max)
    return n / max * 4000 - 2000
end

local function getFromPosition(x, max, numPoints)
    local n = ((x + 2000) / 4000) * max

    if (n >= 1 and n < numPoints) then
        return n
    end

    return nil
end

local function getClosestIndex(x, max, numPoints)
    local n = getFromPosition(x, max, numPoints)

    if not n then
        return
    end

    return math.round(n)
end

function Water:new(area, x, y)
    Water.super.new(self, area, x, y, water)

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

function Water:getWaterPolygon(xmin, xmax)
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

    -- Vector pointing up from the surface
    local angle = Vector.angleTo(xmin - xmax, a - b) - math.pi / 2

    return vertices, angle
end

function Water:applyFriction(collider)
    local vx, vy = collider:getLinearVelocity()

    local normalizedx, normalizedy = Vector.normalize(vx, vy)
    local density = 40
    local dragMagx = density * normalizedx * normalizedx
    local dragMagy = density * normalizedy * normalizedy
    local dragForcex = dragMagx * -vx
    local dragForcey = dragMagy * -vy

    collider:applyForce(dragForcex, dragForcey)
end

function Water:getImmersion(collider, start, stop)
    local waterPolygon, waterAngle = self:getWaterPolygon(start, stop)

    local intersectionVertices = clip(waterPolygon, {collider:getWorldPoints(collider:getPoints())})

    if #intersectionVertices < 6 then
        return
    end

    local cx, cy = mlib.polygon.getCentroid(table.copy(intersectionVertices))

    local area = mlib.polygon.getArea(table.copy(intersectionVertices))

    local fullArea = mlib.polygon.getArea(collider:getPoints())

    return cx, cy, area, fullArea, intersectionVertices, waterPolygon, waterAngle
end

function Water:immersion(collider, singlePolygon)
    local xmin, _, xmax, _ = collider:getBoundingBox()

    if (singlePolygon or xmax - xmin < 100) then
        local resultAll = {self:getImmersion(collider, xmin, xmax)}

        if (resultAll[1] and resultAll[2]) then
            return {resultAll}
        end

        if (singlePolygon) then
            return {}
        end
    end

    local step = (xmax - xmin) / 2
    local immersions = {}
    for start = xmin, xmax - step, step do
        local stop = math.min(start + step, xmax)
        local result = {self:getImmersion(collider, start, stop)}
        if (result[1] and result[2]) then
            immersions[#immersions + 1] = result
        end
    end

    return immersions
end

function Water:splash(dt, collider, simpleLift)
    simpleLift = simpleLift or false
    local xmin, _, xmax, _ = collider:getBoundingBox()
    local nmin = getClosestIndex(xmin, self.maxPoints, #self.points)
    local nmax = getClosestIndex(xmax, self.maxPoints, #self.points)

    if not nmin or not nmax then
        return
    end

    local obj = collider:getObject()
    local objLift = obj.waterContained * 0.6

    if (simpleLift) then
        local immersions = self:immersion(collider, true) -- simple immersion

        if (#immersions == 1) then
            local cx = immersions[1][1]
            local cy = immersions[1][2]
            local area = immersions[1][3]
            local fullArea = immersions[1][4]
            local waterAngle = immersions[1][7]
            local percentage = area / fullArea
            lift = -percentage * collider:getMass() * 900
            if percentage > 0.1 and percentage < 0.9 then
                collider:applyForce(lift * math.cos(waterAngle), lift * 1.99 * (1 - objLift))
            elseif percentage > 0.9 then
                collider:applyForce(0, lift)
            end
        end
    else
        local immersions = self:immersion(collider)

        local percentageSum = 0
        for _, val in pairs(immersions) do
            local cx = val[1]
            local cy = val[2]
            local area = val[3]
            local fullArea = val[4]
            local waterAngle = val[7]

            local vx, vy = collider:getLinearVelocity()

            local percentage = area / fullArea
            percentageSum = percentageSum + percentage
            local lift = -percentage * collider:getMass() * 900

            self:applyFriction(collider)

            local mass = collider:getMass()

            local force =
                math.sqrt(
                math.min(
                    10,
                    math.max(
                        -10,
                        ((-math.sqrt(math.sqrt(math.abs(vx))) + math.sqrt(math.abs(vy))) * (mass or 1) /
                            (nmax - nmin + 1) /
                            1 *
                            area) /
                            200
                    )
                )
            )

            if percentage > 0.1 and percentage < 0.9 then
                collider:applyForce(lift * math.cos(waterAngle), lift * 1.99 * (1 - objLift), cx, cy)
            elseif percentage > 0.9 then
                collider:applyForce(0, lift * 1.99 * (1 - objLift), cx, cy)
            end
        end

        if (percentageSum > 0.9) then
            if (obj and obj.leak) then
                obj:leak(dt, percentageSum)
            end
        end
    end
end

function Water:getHeight(x)
    local index = getFromPosition(x, self.maxPoints, #self.points)
    if not index then
        return 0
    end

    local ratio = index - math.floor(index)

    return self.points[math.floor(index)].y * (1 - ratio) + self.points[math.ceil(index)].y * (ratio)
end

local SPRING_FORCE = 0.005
local BASELINE_FORCE = 0.0005
local DAMPENING = 0.99

function Water:update(dt)
    Water.super.update(self, dt)

    for _ = 1, 3 do
        for n, p in ipairs(self.points) do
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

            local dy = self.y - p.y + math.sin(love.timer.getTime() / 4 + n / 5) * 10

            local forceToBaseLine = dy * BASELINE_FORCE

            local force = forceFromLeft + forceFromRight + forceToBaseLine

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
end
