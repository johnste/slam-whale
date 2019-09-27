Stage = Object:extend()
wf = require "libraries/windfield"

function Stage:new()
    self.area = Area(self)
    love.physics.setMeter(10)
    self.area:addPhysicsWorld(0, 0)
    self.area.world:addCollisionClass("Sub")

    --self.player = self.area:addEntity(Submarine(self.area, -1800, 100))
    self.water = self.area:addEntity(Water(self.area, 0, 0))

    self.player = self.area:addEntity(Submarine(self.area, 0, 200, self.water))

    -- self.area:addEntity(Boat(self.area, -1200, 0, nil, self.water))

    -- self.area:addEntity(Ship(self.area, -700, 0, 2))
    -- self.area:addEntity(Boat(self.area, -100, 0, 2, self.water))
    -- self.area:addEntity(Ship(self.area, 200, 0))
    -- self.area:addEntity(Boat(self.area, 800, 0, nil, self.water))

    -- self.area:addEntity(Tanker(self.area, 1300, 0))

    self.player = self.area:addEntity(Ship(self.area, 1800, 0))
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.timer = Timer()
    LEVEL = 15
    self.timer:after(
        16,
        function(f)
            if love.math.random() < 0.5 then
                self.player = self.area:addEntity(Ship(self.area, 2700, 0))
            elseif love.math.random() < 0.3 then
                self.area:addEntity(Boat(self.area, 2700, 0, 1, nil, self.water))
            end

            self.timer:after(
                30,
                function(f)
                    LEVEL = LEVEL * 0.8
                    if love.math.random() < 0.5 then
                        self.player = self.area:addEntity(Ship(self.area, 2700, 0))
                    elseif love.math.random() < 0.3 then
                        self.area:addEntity(Boat(self.area, 2700, 0, 1, self.water))
                    elseif love.math.random() < 0.5 then
                        self.player = self.area:addEntity(Tanker(self.area, 2700, 0))
                    elseif love.math.random() < 0.5 then
                        self.area:addEntity(Plane(self.area, 2700, 0, 1))
                    end
                    self.timer:after(math.max(7, LEVEL), f)
                end
            )
        end
    )

    self.paused = false
    self.survivaltime = 0

    port = love.graphics.newImage("img/port.png")

    self.gameOver = false
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

    self.song = love.audio.newSource("sfx/traska.ogg", "stream")
    self.song:setLooping(true)

    self.song:play()
end

function Stage:update(dt)
    if (self.paused or self.gameOver) then
        if (self.gameOverX and self.gameOverY) then
            camera:follow(self.gameOverX, self.gameOverY)

            if input:pressed("turbo") then
                self.song:stop()
                CurrentRoom = Menu()
            end
        end
        return
    end
    self.area:update(dt)
    self.timer:update(dt)
    self.survivaltime = self.survivaltime + dt
end

function Stage:setGameOver(x, y)
    self.gameOver = true
    self.gameOverX = x
    self.gameOverY = y
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()

    if self.gameOver then
        love.graphics.printf("- Game Over -", 0, 40, gw, "center", 0, 1, 1)
        love.graphics.printf("You lasted " .. math.floor(self.survivaltime) .. " s", 0, 60, gw, "center", 0, 1, 1)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.printf(math.floor(self.survivaltime) .. " s", 0, 10, gw, "center", 0, 1, 1)
    end

    if self.paused then
        love.graphics.printf("- paused -", 0, 40, gw, "center", 0, 1, 1)
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end

    camera:attach(0, 0, gw, gh)
    -- love.graphics.circle("line", gw / 2, gh / 2, 50)
    -- love.graphics.print("Hello World!", gw / 2, gh / 2, 0, 1, 1, -30.5, -20.5)

    local points = {}
    for i = 1, 1000 do -- The range includes both ends.
        local y = 20
        if i % 2 == 0 then
            y = -0
        end

        points[i * 2 - 1] = 500 * 100 - i * 100
        points[i * 2] = y
    end
    self.area:draw()

    -- love.graphics.line(points)

    love.graphics.setLineWidth(3)
    love.graphics.line(-2000, -100, -2000, 1000)
    love.graphics.line(-2020, -100, -2020, 1010)

    love.graphics.line(2000, -100, 2000, 1000)
    love.graphics.line(2020, -100, 2020, 1010)

    love.graphics.line(-2000, 1000, 2000, 1000)
    love.graphics.line(-2020, 1010, 2020, 1010)

    love.graphics.setLineWidth(1)

    love.graphics.draw(port, -2400, -200)
    love.graphics.rectangle("fill", -3000, -83, 900, 2000)

    camera:detach()

    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
