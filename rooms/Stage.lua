Stage = Object:extend()

function Stage:new()
    self.area = Area(self)

    self.area:addEntity(Submarine(200, 100))

    self.main_canvas = love.graphics.newCanvas(gw, gh)
end

function Stage:update(dt)
    self.area:update(dt)

    if input:pressed("go right") then
        pushing = "true"
    end
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    love.graphics.circle("line", gw / 2, gh / 2, 50)
    love.graphics.print("Hello World!", gw / 2, gh / 2, 0, 1, 1, -30.5, -20.5)

    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
