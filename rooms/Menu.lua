Menu = Object:extend()
wf = require "libraries/windfield"

function Menu:new()
    self.area = Area(self)
    love.physics.setMeter(10)
    self.area:addPhysicsWorld(0, 0)

    self.main_canvas = love.graphics.newCanvas(gw, gh)

    logo = love.graphics.newImage("img/logo.png")
end

function Menu:update(dt)
    self.area:update(dt)
end

function Menu:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    -- love.graphics.circle("line", gw / 2, gh / 2, 50)
    -- love.graphics.print("Hello World!", gw / 2, gh / 2, 0, 1, 1, -30.5, -20.5)

    love.graphics.draw(logo, gw / 2, 100, 0, 1, 1, logo:getWidth() / 2)

    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
