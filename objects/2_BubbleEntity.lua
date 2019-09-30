BubbleEntity = Entity:extend()

function BubbleEntity:new(area, x, y, vx)
    BubbleEntity.super.new(self, area, x, y)

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
                        local direction = Vector.dot(x, y, math.cos(self.r), math.sin(self.r))
                        if (love.math.random() * math.max(direction, 0) < 0.2 and Vector.len(xv, yv) > 10) then
                            self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                        end
                    end
                end
            end
            self.timer:after(0.1, f)
        end
    )
end

function BubbleEntity:update(dt)
    BubbleEntity.super.update(self, dt)

    if (self.water and self.collider) then
        self.water:splash(self.collider)

        if (self.y > 1000) then
            self.collider:applyForce(0, -30000 * dt)
        end

        if (self.x > 2000) then
            self.collider:applyForce(-30000 * dt, 0)
        end

        if (self.x < -2000) then
            self.collider:applyForce(30000 * dt, 0)
        end
    end
end

function BubbleEntity:draw()
end
