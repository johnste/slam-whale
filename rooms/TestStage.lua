TestStage = Object:extend()

function TestStage:new()
    self.area = Area(self)
    love.physics.setMeter(4)
    self.area:addPhysicsWorld(0, 900)
    self.area.world:addCollisionClass("Sub")

    self.water = self.area:addEntity(Water(self.area, 0, 0))
    self.ground = self.area:addEntity(Ground(self.area, 0, 0))
    self.player = self.area:addEntity(Submarine(self.area, 0, 200, self.water))

    self.area:addEntity(Bobby(self.area, self.player.x + 200, 0, self.water))
    self.area:addEntity(Boat(self.area, self.player.x + 400, 0, self.water))
    self.area:addEntity(Ship(self.area, self.player.x + 600, 0, self.water))
    self.area:addEntity(Tanker(self.area, self.player.x + 800, 0, self.water))
    self.area:addEntity(Plane(self.area, self.player.x + 1000, 0, self.water))

    input:bind(
        "5",
        function()
            self.area:addEntity(Bobby(self.area, self.player.x, self.player.y - 250, self.water))
        end
    )

    input:bind(
        "1",
        function()
            self.area:addEntity(Boat(self.area, self.player.x, self.player.y - 250, self.water))
        end
    )

    input:bind(
        "2",
        function()
            self.area:addEntity(Ship(self.area, self.player.x, self.player.y - 250, self.water))
        end
    )
    input:bind(
        "3",
        function()
            self.area:addEntity(Tanker(self.area, self.player.x, self.player.y - 250, self.water))
        end
    )
    input:bind(
        "4",
        function()
            self.area:addEntity(Plane(self.area, self.player.x, self.player.y - 250, self.water))
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
    local slow = math.max(0.2, 1 - self.player.slamCharge / 3 * 2)
    self.area:update(dt * slow)
    self.timer:update(dt * slow)
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

    love.graphics.push("all")
    love.graphics.setLineWidth(3)
    love.graphics.line(-2000, -100, -2000, 1000)
    love.graphics.line(2000, -100, 2000, 1000)

    love.graphics.pop()

    local startX = camera:toWorldCoords(0, 0)
    local stopX = camera:toWorldCoords(camera.w, 0)

    -- for i = startX, stopX, (stopX - startX) / 100 do
    --     for j = 0, self.water:getHeight(i) + 100, 10 do
    --         if (love.math.random() > 0.2) then
    --             love.graphics.points(i, -100 + j)
    --         end
    --     end
    -- end
    camera:detach()

    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
