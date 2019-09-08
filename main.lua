Object = require "libraries/classic/classic"
Submarine = require "objects/Submarine"

love.load = function()
    player = Submarine()
    currentRoom = nil
end

love.update = function(dt)
    require("libraries/lurker/lurker").update()
    if currentRoom then
        currentRoom:update(dt)
    end
end

love.draw = function()
    love.graphics.print("Hello World!", 400, 300)

    if currentRoom then
        currentRoom:draw()
    end
end
