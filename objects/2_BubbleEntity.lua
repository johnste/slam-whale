BubbleEntity = Entity:extend()

function BubbleEntity:new(area, x, y, vx)
    BubbleEntity.super.new(self, area, x, y)

    print("agesbvb")
    self.timer:after(
        1,
        function(f)
            print("agesb")
            if (self.y > 0) then
                print("agxesx")
                --and self.collider ~= nil
                local xv, yv = 0, 0
                if (self.collider) then
                    xv, yv = self.collider:getLinearVelocity()
                end

                --x1, y1, x2, y2, x3, y3, x4, y4 = self.collider:getBoundingBox()
                if (not self.alive) then
                    self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                elseif (love.math.random() > 0.8) then
                    self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                else
                    if (self.collider) then
                        print("ages")
                        local xv, yv = self.collider:getLinearVelocity()
                        local direction = Vector.dot(x, y, math.cos(self.r), math.sin(self.r))
                        if (love.math.random() * math.max(direction, 0) < 0.2 and Vector.len(xv, yv) > 10) then
                            self.area:addEntity(Bubble(self.area, self.x, self.y, xv))
                        end
                    else
                        print("agexs")
                    end
                end
                self.timer:after(0.1, f)
            end
        end
    )
end

function BubbleEntity:update(dt)
    BubbleEntity.super.update(self, dt)
end

function BubbleEntity:draw()
end
