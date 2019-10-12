TestStage = Object:extend()

function TestStage:new()
    self.area = Area(self)
    love.physics.setMeter(4)
    self.area:addPhysicsWorld(0, 900)
    self.area.world:addCollisionClass("Sub")

    self.water = self.area:addEntity(Water(self.area, 0, 0))
    self.player = self.area:addEntity(Submarine(self.area, 0, 200, self.water))

    input:bind(
        "5",
        function()
            self.area:addEntity(Bobby(self.area, self.player.x, 0, -200, self.water))
        end
    )

    input:bind(
        "1",
        function()
            self.area:addEntity(Boat(self.area, self.player.x, 0, -200, self.water))
        end
    )

    input:bind(
        "2",
        function()
            self.area:addEntity(Ship(self.area, self.player.x, 0, -200, self.water))
        end
    )
    input:bind(
        "3",
        function()
            self.area:addEntity(Tanker(self.area, self.player.x, 0, -200, self.water))
        end
    )
    input:bind(
        "4",
        function()
            self.area:addEntity(Plane(self.area, self.player.x, 0, -200, self.water))
        end
    )

    input:bind(
        "wheeldown",
        function()
            camera.scale = math.max(0.01, camera.scale - 0.2)
        end
    )

    input:bind(
        "mouse3",
        function()
            camera.scale = 1
        end
    )

    input:bind(
        "wheelup",
        function()
            camera.scale = math.min(10, camera.scale + 0.2)
        end
    )

    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.timer = Timer()

    input:bind(
        "escape",
        function()
            if self.paused then
                self.paused = false
            else
                self.paused = true
            end
        end
    )
end

function TestStage:update(dt)
    self.area:update(dt)
    self.timer:update(dt)
end

function TestStage:setGameOver(x, y)
end

function TestStage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()

    camera:attach(0, 0, gw, gh)
    -- love.graphics.circle("line", gw / 2, gh / 2, 50)
    -- love.graphics.print("Hello World!", gw / 2, gh / 2, 0, 1, 1, -30.5, -20.5)

    self.area:draw()

    love.graphics.setLineWidth(3)
    love.graphics.line(-2000, -100, -2000, 1000)
    love.graphics.line(-2020, -100, -2020, 1010)

    love.graphics.line(2000, -100, 2000, 1000)
    love.graphics.line(2020, -100, 2020, 1010)

    love.graphics.line(-2000, 1000, 2000, 1000)
    love.graphics.line(-2020, 1010, 2020, 1010)

    love.graphics.setLineWidth(1)

    camera:detach()

    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
