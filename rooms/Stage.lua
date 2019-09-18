Stage = Object:extend()
wf = require "libraries/windfield"

function Stage:new()
    self.area = Area(self)
    love.physics.setMeter(10)
    self.area:addPhysicsWorld(0, 0)
    self.area.world:addCollisionClass("Sub")

    self.player = self.area:addEntity(Ship(self.area, 100, 0))
    self.player = self.area:addEntity(Ship(self.area, 400, 0))
    self.player = self.area:addEntity(Ship(self.area, 700, 0))

    self.player = self.area:addEntity(Submarine(self.area, 200, 100))
    self.area:addEntity(Water(self.area, 200, 100))
    input:bind(
        "f3",
        function()
            self.player.dead = true
        end
    )

    self.main_canvas = love.graphics.newCanvas(gw, gh)
end

function Stage:update(dt)
    self.area:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    -- love.graphics.circle("line", gw / 2, gh / 2, 50)
    -- love.graphics.print("Hello World!", gw / 2, gh / 2, 0, 1, 1, -30.5, -20.5)

    local points = {}
    for i = 1, 1000 do -- The range includes both ends.
        local y = 10
        if i % 2 == 0 then
            y = -10
        end

        points[i * 2 - 1] = 500 * 100 - i * 100
        points[i * 2] = y
    end

    love.graphics.line(points)

    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
