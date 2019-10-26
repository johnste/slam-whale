Ground = Entity:extend()

local poly = {
    0,
    0,
    5,
    0,
    5,
    7,
    4,
    9,
    6,
    12,
    6,
    13,
    4,
    17,
    5,
    18,
    10,
    17,
    17,
    18,
    20,
    17,
    24,
    17,
    27,
    18,
    30,
    17,
    31,
    18,
    30,
    19,
    29,
    19,
    28,
    19,
    27,
    20,
    27,
    22,
    30,
    22,
    30,
    21,
    29,
    20,
    31,
    20,
    32,
    18,
    34,
    17,
    33,
    14,
    34,
    11,
    33,
    7,
    34,
    5,
    35,
    4,
    35,
    25,
    17,
    25,
    0,
    25
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
        return p * 4400 / 35 - 2200
    else
        return p * 60
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
    love.graphics.circle("line", self.x, self.y, 100)

    local poly2 = (map(double, poly))

    local triangles = love.math.triangulate(poly2)

    for _, triangle in ipairs(triangles) do
        love.graphics.setColor(0.2, 0.5, 0.5, 0.2)
        love.graphics.polygon("fill", triangle)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
