Ground = Entity:extend()

local poly = {
    -2074.8,
    322,
    -1961.4,
    317.5,
    -1873.2,
    326.5
}

function map(func, array)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v, i)
    end
    return new_array
end

function double(p, i)
    return p
    -- local isX = i % 2

    -- if isX == 1 then
    --     return p * 4 - 2000
    -- else
    --     return p * 2 - 200
    -- end
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
