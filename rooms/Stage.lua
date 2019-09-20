Stage = Object:extend()
wf = require "libraries/windfield"

function Stage:new()
    self.area = Area(self)
    love.physics.setMeter(10)
    self.area:addPhysicsWorld(0, 0)
    self.area.world:addCollisionClass("Sub")

    self.player = self.area:addEntity(Submarine(self.area, -1800, 100))

    self.area:addEntity(Ship(self.area, -1300, 0))
    self.area:addEntity(Ship(self.area, -600, 0))
    self.area:addEntity(Ship(self.area, -0, 0))

    self.area:addEntity(Ship(self.area, 600, 0))

    self.area:addEntity(Water(self.area, 200, 100))

    self.player = self.area:addEntity(Ship(self.area, 1800, 0))
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.timer = Timer()
    self.timer:after(
        10,
        function(f)
            self.player = self.area:addEntity(Ship(self.area, 2700, 0))
            self.timer:after(10, f)
        end
    )

    self.survivaltime = 0

    port = love.graphics.newImage("img/port.png")
end

function Stage:update(dt)
    self.area:update(dt)
    self.timer:update(dt)
    self.survivaltime = self.survivaltime + dt
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()

    love.graphics.printf(math.floor(self.survivaltime) .. " s", 0, 10, gw, "center", 0, 1, 1)

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

    love.graphics.setLineWidth(3)
    love.graphics.line(-2000, -100, -2000, 2000)
    love.graphics.line(-2020, -100, -2020, 2000)

    love.graphics.line(2000, -100, 2000, 2000)
    love.graphics.line(2020, -100, 2020, 2000)

    love.graphics.line(-2000, 1000, 2000, 1000)
    love.graphics.line(-2000, 1010, 2000, 1010)

    love.graphics.setLineWidth(1)

    love.graphics.draw(port, -2400, -200)
    love.graphics.rectangle("fill", -3000, -83, 900, 2000)

    self.area:draw()

    camera:detach()

    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
