Submarine = Entity:extend()
local image

function Submarine:new(x, y)
    Submarine.super.new(self, area, x, y, opts)
    image = love.graphics.newImage("img/submarine.png")
end

function Submarine:update(dt)
    Submarine.super.update(dt)

    if input:down("go right") then
        self.x = self.x + 2
    end

    if input:down("go left") then
        self.x = self.x - 2
    end

    if input:down("go up") then
        self.y = self.y - 2
    end

    if input:down("go down") then
        self.y = self.y + 2
    end

    camera:follow(self.x, self.y)
end

function Submarine:draw()
    love.graphics.draw(image, self.x, self.y)
    love.graphics.print("helop" .. self.x, self.x - gw / 2, self.y - gh / 2)
end
