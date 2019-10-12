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

function Water:immersion(collider)
    local xmin, _, xmax, _ = collider:getBoundingBox()

    if (xmax - xmin < 100) then
        local resultAll = {self:getImmersion(collider, xmin, xmax)}

        if (resultAll[1] and resultAll[2]) then
            return {resultAll}
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

function Water:splash(collider)
    local xmin, _, xmax, _ = collider:getBoundingBox()
    local nmin = getClosestIndex(xmin, self.maxPoints, #self.points)
    local nmax = getClosestIndex(xmax, self.maxPoints, #self.points)

    if not nmin or not nmax then
        return
    end

    local immersions = self:immersion(collider)

    for immersionNum, val in pairs(immersions) do
        local cx = val[1]
        local cy = val[2]
        local area = val[3]
        local fullArea = val[4]
        local waterAngle = val[7]

        --local cx, cy, area, fullArea = self:immersion(collider)

        local vx, vy = collider:getLinearVelocity()

        local percentage = area / fullArea
        local obj = collider:getObject()
        local lift = -percentage * collider:getMass() * 900
        if obj.swim then
            lift = -percentage * collider:getMass() * 900
        else
            self:applyFriction(collider)
        end

        if not obj.swim then
        --print(math.round(lift, 0.1), math.round(percentage, 0.1))
        -- prettyprint(immersionNum, lift, percentage, collider:getMass() * 900)
        end

        local mass = collider:getMass()

        local force =
            math.sqrt(
            math.min(
                10,
                math.max(
                    -10,
                    ((-math.sqrt(math.sqrt(math.abs(vx))) + math.sqrt(math.abs(vy))) * (mass or 1) / (nmax - nmin + 1) /
                        1 *
                        area) /
                        200
                )
            )
        )

        if percentage > 0.1 and percentage < 0.9 then
            -- for n = nmin, nmax do
            --     print("splashing", n)
            --     self.points[n].y = math.min(20, math.max(self.points[n].y + force, -20))
            -- end
            --print("splash", nmin, nmax, force)
            -- print(
            --     math.round(percentage, 0.1),
            --     math.round(vx, 0.1),
            --     math.round(vy, 0.1),
            --     math.round(mass, 0.1),
            --     math.round(area, 0.1),
            --     math.round(force, 0.1),
            --     nmax - nmin + 1
            -- )
            -- if on/through surface let it slide down
            collider:applyForce(lift * math.cos(waterAngle), lift * 1.99, cx, cy)
        elseif percentage > 0.9 then
            collider:applyForce(0, lift, cx, cy)
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

            local dy = self.y - p.y + math.sin(n / 5 * love.math.random()) * 50 * love.math.random()

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

    -- love.graphics.setColor(0.3, 0.3, 1, 0.5)
    -- for v = 1, 1 do
    --     local a = self:getHeight(100 * v)
    --     local b = self:getHeight(100 + 100 * v)

    --     if (a and b) then
    --         local vertices = {
    --             100 * v,
    --             a,
    --             100 + 100 * v,
    --             b,
    --             100 + 100 * v,
    --             1000,
    --             100 * v,
    --             1000
    --         }

    --         love.graphics.polygon("fill", vertices)

    --         local vertices2 = {
    --             100 * v,
    --             -200,
    --             100 + 100 * v,
    --             -200,
    --             100 + 100 * v,
    --             0,
    --             100 * v,
    --             0
    --         }
    --         love.graphics.setColor(0.3, 1, 0.3, 0.5)
    --         love.graphics.polygon("fill", vertices2)

    --         local displayed = clip(vertices, vertices2)
    --         love.graphics.setColor(1, 0.3, 0.3, 0.5)

    --         if (type(displayed) == "table" and #displayed >= 6) then
    --             love.graphics.polygon("fill", displayed)

    --             love.graphics.setColor(1, 0.3, 1, 0.7)
    --             local cx, cy = mlib.polygon.getCentroid(displayed)
    --             local area = mlib.polygon.getArea(displayed)

    --             love.graphics.print("" .. area, cx, cy)
    --         end
    --     end
    -- end
    -- love.graphics.setColor(1, 1, 1, 1)
end
