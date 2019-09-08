local Submarine = Object:extend()
local image

function Submarine:new()
    image = love.graphics.newImage("img/submarine.png")    
end

function Submarine:update(dt)
end

function Submarine:draw()
    
    love.graphics.draw(image, 100, 100)
end

return Submarine