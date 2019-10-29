BubbleEntity = Entity:extend()

function BubbleEntity:new(area, x, y, water)
    BubbleEntity.super.new(self, area, x, y)
    self.water = water
    self.waterContained = 0

    self.timer:after(
        1,
        function(f)
            if (self.y > 0) then
                --and self.collider ~= nil
                local xv, yv = 0, 0
                if (self.collider) then
                    xv, yv = self.collider:getLinearVelocity()
                end

                if (not self.alive) then
                    self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                elseif (love.math.random() > 0.8) then
                    self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                else
                    if (self.collider) then
                        local xv, yv = self.collider:getLinearVelocity()
                        local direction =
                            Vector.dot(x, y, math.cos(self.collider:getAngle()), math.sin(self.collider:getAngle()))
                        if (love.math.random() * math.max(direction, 0) < 0.2 and Vector.len(xv, yv) > 10) then
                            self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                        end
                    end
                end
            end
            self.timer:after(math.max(0.1, 1 - self.waterContained), f)
        end
    )
end

function BubbleEntity:update(dt)
    BubbleEntity.super.update(self, dt)

    if (self.speed) then
        self.collider:applyForce(
            -self.speed * math.cos(self.collider:getAngle()),
            self.speed / 10 * math.sin(self.collider:getAngle())
        )
    end

    if (self.water and self.collider) then
        self.water:splash(dt, self.collider, self.swim)

        if (self.x > 4000) then
            self.collider:applyForce(-30000, 0)
        end

        if (self.x < 0) then
            self.collider:applyForce(30000, 0)
        end

        if (not self.collider:getObject().swim) then
            if (self.collider:getAngle() < 0) then
                self.collider:applyTorque(self.collider:getMass() * 100)
            else
                self.collider:applyTorque(-self.collider:getMass() * 100)
            end
        end
    end

    if self.collider:enter("Sub") then
        camera:shake(8, 0.7, 30)
        local collision_data = self.collider:getEnterCollisionData("Sub")
        local enemy = collision_data.collider:getObject()

        if (enemy.isSlamming) then
            self.collider:applyLinearImpulse(0, 800 * collision_data.collider:getMass())
        end
    end
end

function BubbleEntity:leak(dt, percentage)
    self.waterContained = math.min(1, self.waterContained + dt * percentage * 0.5)
end

function BubbleEntity:draw()
    if not DebugMode then
        return
    end

    if (self.collider and self.water) then
        love.graphics.print(
            inspect(
                {
                    mass = self.collider:getMass(),
                    -- density = self.collider:getDensity(),
                    -- grav = self.gravity,
                    -- debug = self.debug
                    x = math.round(self.x, 0.1),
                    y = math.round(self.y, 0.1),
                    water = math.round(self.waterContained * 100, 0.1)
                }
            ),
            self.x,
            self.y + 44
        )

        local immersions = self.water:immersion(self.collider)

        for _, val in pairs(immersions) do
            local cx = val[1]
            local cy = val[2]
            local area = val[3]
            local fullArea = val[4]
            local intersectionVertices = val[5]
            local waterPolygon = val[6]
            local waterAngle = val[7]

            local percentage = area / fullArea

            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.setLineWidth(1)
            -- print(
            --     math.round(cx, 0.1),
            --     math.round(cy, 0.1),
            --     #intersectionVertices,
            --     inspect(intersectionVertices),
            --     inspect(#{self.collider:getWorldPoints(self.collider:getPoints())})
            -- )
            love.graphics.polygon("line", intersectionVertices)

            local force = percentage * 100
            love.graphics.setColor(1, 1, 0, 0.4)
            love.graphics.rectangle("fill", cx - math.sqrt(area) / 2, cy + 200, math.sqrt(area), 20)
            love.graphics.setColor(0, 1, 1, 0.1)
            love.graphics.polygon("fill", waterPolygon)
            love.graphics.setColor(1, 0.5, 1, 1)
            love.graphics.rectangle("line", cx - math.sqrt(area) / 2, cy + 200, math.sqrt(fullArea), 20)
            --love.graphics.print(math.round(area / fullArea, 0.1), cx, cy + 200)
            love.graphics.line(cx, cy, cx - force * math.cos(waterAngle), cy - force * math.sin(waterAngle))
            love.graphics.circle("fill", cx - force * math.cos(waterAngle), cy - force * math.sin(waterAngle), 5)

            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end
