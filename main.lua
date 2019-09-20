require "utils"
Object = require "libraries/classic/classic"
Input = require "libraries/boipushy/Input"
Camera = require "libraries/stalkerx/Camera"
Timer = require "libraries/enhanced_timer/EnhancedTimer"
Vector = require "libraries/hump/vector-light"
moonshine = require "libraries/moonshine"

pushing = "false"

love.load = function()
    input = Input()
    input:bind("d", "go right")
    input:bind("a", "go left")
    input:bind("w", "go up")
    input:bind("s", "go down")
    input:bind("right", "go right")
    input:bind("left", "go left")
    input:bind("up", "go up")
    input:bind("down", "go down")
    input:bind("space", "turbo")
    input:bind("return", "turbo")

    camera = Camera()
    love.audio.setVolume(0.2)
    camera:setFollowStyle("LOCKON")
    -- input:bind(
    --     "h",
    --     function()
    --         camera:shake(4, 0.5, 60)
    --     end
    -- )

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
    local object_files = {}
    recursiveEnumerate("objects", object_files)
    requireFiles(object_files)

    local room_files = {}
    recursiveEnumerate("rooms", room_files)
    requireFiles(room_files)

    CurrentRoom =
        Menu(
        function()
            CurrentRoom = Stage()
        end
    )

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
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. "/" .. item
        local info = love.filesystem.getInfo(file)
        if info.type == "file" then
            table.insert(file_list, file)
        elseif info.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end
