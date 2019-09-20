Menu = Object:extend()
wf = require "libraries/windfield"

function Menu:new(callback)
    self.area = Area(self)
    love.physics.setMeter(10)
    self.area:addPhysicsWorld(0, 0)

    self.main_canvas = love.graphics.newCanvas(gw, gh)

    logo = love.graphics.newImage("img/logo.png")
    menu = love.graphics.newImage("img/menu.png")
    chevron = love.graphics.newImage("img/chevron.png")
    help = love.graphics.newImage("img/help.png")

    self.callback = callback
    self.active = 1
    self.timer = Timer()
    self.pos = {x = 0}

    self.timer:after(
        0,
        function(f)
            self.timer:tween(
                0.4,
                self.pos,
                {x = 10},
                "in-out-cubic",
                function()
                    self.timer:tween(0.4, self.pos, {x = -10}, "in-out-cubic")
                end
            )
            self.timer:after(0.8, f)
        end
    )

    self.select = love.audio.newSource("sfx/select.wav", "static")
    self.start = love.audio.newSource("sfx/start.wav", "static")
    self.song = love.audio.newSource("sfx/darkwater.wav", "stream")
    self.song:setLooping(true)

    self.song:play()
end

function Menu:update(dt)
    self.area:update(dt)
    self.timer:update(dt)

    if input:pressed("go up") then
        self.active = self.active - 1
        if (self.active == 0) then
            self.active = 2
        end
        self.select:play()
    end

    if input:pressed("go down") then
        self.active = self.active + 1
        if (self.active == 3) then
            self.active = 1
        end
        self.select:play()
    end

    if input:pressed("go right") then
        love.audio.setVolume(math.min(1, love.audio.getVolume() + 0.1))
    end

    if input:pressed("go left") then
        love.audio.setVolume(math.max(0, love.audio.getVolume() - 0.1))
    end

    if input:pressed("turbo") then
        self.start:play()
        if (self.active == 1) then
            self.callback()
        end
        if (self.active == 2) then
            love.event.quit()
        end
    end
end

function Menu:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    -- love.graphics.circle("line", gw / 2, gh / 2, 50)

    love.graphics.draw(logo, gw / 2, 100, 0, 1, 1, logo:getWidth() / 2)

    love.graphics.draw(help, gw / 2, 300, 0, 1, 1, help:getWidth() / 2)

    love.graphics.draw(menu, gw / 2, 500, 0, 1, 1, menu:getWidth() / 2)

    love.graphics.printf(
        "Save the fish before they reach the port",
        gw / 2 - logo:getWidth() / 2,
        100 + logo:getHeight(),
        logo:getWidth(),
        "center"
    )

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.circle("fill", gw / 2 + 20 - menu:getWidth() / 2, 500 + 35 + (self.active - 1) * 65, 30)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        chevron,
        gw / 2 + 12 + self.pos.x,
        500 + 19 + (self.active - 1) * 65,
        0,
        1,
        1,
        menu:getWidth() / 2
    )

    love.graphics.printf(
        "A game for spelsylt #3. Change volume (A/D): " .. math.ceil((love.audio.getVolume()) * 10) .. " / 10",
        gw / 2 - 150,
        gh - 60,
        400,
        "center"
    )

    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode("alpha")
end
