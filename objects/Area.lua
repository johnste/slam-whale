Area = Object:extend()

function Area:new(room)
    self.room = room
    self.entities = {}
end

function Area:addPhysicsWorld(xgrav, ygrav)
    self.world = wf.newWorld(xgrav or 0, ygrav or 0, true)
end

function Area:update(dt)
    if self.world then
        self.world:update(dt)
    end

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        entity:update(dt)

        if (entity.dead) then
            table.remove(self.entities, i)
            entity:destroy()
        end
    end
end

function Area:draw()
    if DebugMode then
        if self.world then
            self.world:draw()
        end
    end

    for _, entity in ipairs(self.entities) do
        entity:draw()
    end
end

function Area:addEntity(entity)
    table.insert(self.entities, entity)
    return entity
end
