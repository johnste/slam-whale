Ground = Entity:extend()

local poly = {
    6,
    78,
    6,
    3,
    45,
    6,
    48,
    75,
    93,
    75,
    117,
    60,
    135,
    42,
    147,
    33,
    162,
    30,
    174,
    27,
    189,
    33,
    219,
    45,
    216,
    54,
    216,
    69,
    210,
    51,
    168,
    45,
    144,
    57,
    141,
    72,
    171,
    72,
    195,
    441,
    222,
    564,
    252,
    621,
    273,
    648,
    276,
    678,
    261,
    711,
    240,
    741,
    222,
    756,
    201,
    759,
    186,
    765,
    180,
    783,
    204,
    792,
    225,
    786,
    240,
    777,
    258,
    771,
    303,
    750,
    330,
    720,
    345,
    720,
    390,
    726,
    441,
    747,
    492,
    759,
    570,
    768,
    630,
    774,
    735,
    771,
    801,
    768,
    879,
    771,
    960,
    768,
    987,
    765,
    993,
    795,
    3,
    798,
    6,
    75
}

function map(func, array)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v, i)
    end
    return new_array
end

function double(p, i)
    local isX = i % 2

    if isX == 1 then
        return p * 4 - 2000
    else
        return p * 2 - 200
    end
end

function Ground:new(area, x, y, water)
    Ground.super.new(self, area, x, y, water)

    self.w = 4000
    self.h = 200

    --local body = self.area.world:newRectangleCollider(-self.w / 2, 1000, 4000, 200)

    local poly2 = (map(double, poly))

    local triangles = love.math.triangulate(poly2)

    for _, triangle in ipairs(triangles) do
        love.graphics.polygon("line", triangle)
        local body = self.area.world:newPolygonCollider(triangle)
        body:setObject(self)
        body:setType("static")
    end

    -- self.collider = body
end

function Ground:update(dt)
    Ground.super.update(self, dt)
end

function Ground:draw()
    Ground.super.draw(self)

    local poly2 = (map(double, poly))

    local triangles = love.math.triangulate(poly2)

    for _, triangle in ipairs(triangles) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.polygon("fill", triangle)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
