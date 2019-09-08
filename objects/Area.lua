Area = Object:extend()

function Area:new(room)
    self.room = room
    self.entities = {}
end

function Area:update(dt)
    for _, entity in ipairs(self.entities) do
        entity:update(dt)
    end
end

function Area:draw()
    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

function Area:addEntity(entity)
    table.insert(self.entities, entity)
end
