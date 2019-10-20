require "utils"
Object = require "libraries/classic/classic"
Input = require "libraries/boipushy/Input"
Camera = require "libraries/stalkerx/Camera"
Timer = require "libraries/enhanced_timer/EnhancedTimer"
Vector = require "libraries/hump/vector-light"
moonshine = require "libraries/moonshine"
mlib = require "libraries/mlib/mlib"
inspect = require "libraries/inspect/inspect"

-- ENTITIES --
require "objects/Entity"
require "objects/BubbleEntity"
require "objects/Area"
require "objects/ships/Boat"
require "objects/ships/Bobby"
require "objects/ships/Box"
require "objects/Bubble"
require "objects/Fish"
require "objects/ships/Lovebox"
require "objects/ships/Plane"
require "objects/ships/Ship"
require "objects/ships/Submarine"
require "objects/ships/Tanker"
require "objects/Ground"
require "objects/Water"

-- ROOMS --
require "rooms/Menu"
require "rooms/Stage"
require "rooms/TestStage"

love.load = function()
    input = Input()

    input:bind("d", "go right")
    input:bind("a", "go left")
    input:bind("w", "go up")
    input:bind("s", "go down")

    input:bind("dpright", "go right")
    input:bind("dpleft", "go left")
    input:bind("dpup", "go up")
    input:bind("dpdown", "go down")

    input:bind("right", "go right")
    input:bind("left", "go left")
    input:bind("up", "go up")
    input:bind("down", "go down")

    input:bind("space", "turbo")

    input:bind("fdown", "turbo")

    input:bind("return", "turbo")
    input:bind("escape", "pause")

    camera = Camera()
    love.audio.setVolume(0)
    camera:setFollowStyle("LOCKON")
    camera:setFollowLerp(0.14)

    DebugMode = false
    input:bind(
        "tab",
        function()
            if DebugMode then
                DebugMode = false
            else
                DebugMode = true
            end
        end
    )

    input:bind(
        "q",
        function()
            love.event.quit()
        end
    )

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    CurrentRoom = Menu()

    resize(1)
end

love.update = function(dt)
    require("libraries/lurker/lurker").update()
    if CurrentRoom then
        CurrentRoom:update(dt)
    end

    camera:update(dt)
end

love.draw = function()
    if CurrentRoom then
        CurrentRoom:draw()
    end
    camera:draw()
    if DebugMode then
        love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    end
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end
