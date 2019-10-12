Lovebox = BubbleEntity:extend()
local boximg

function Lovebox:new(area, x, y, water)
    Lovebox.super.new(self, area, x, y, water)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 12
    self.water = water

    local body = self.area.world:newRectangleCollider(self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    body:setObject(self)
    body:setMass(0.1)
    body:setAngularDamping(1)
    body:setLinearDamping(0.4)
    body:setFriction(0.4)

    self.collider = body
    self.isLoveBox = true

    boximg = love.graphics.newImage("img/lovebox.png")
    boombox = love.graphics.newImage("img/boombox.png")
    self.explosion_underwater = love.audio.newSource("sfx/underwater-explosion.wav", "static")
end

function Lovebox:update(dt)
    Lovebox.super.update(self, dt)

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    --self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.r = self.collider:getAngle()

    if (self.y > 50 or not self.alive) then
        if not self.exploding then
            self.exploding = true
            self.timer:after(
                1 + love.math.random() * 3,
                function()
                    self.reallyexploding = true
                    camera:shake(8, 1, 60)
                    self.area:addEntity(Fish(self.area, self.x, self.y))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() * 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() - 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() - 5))
                    self.area:addEntity(Fish(self.area, self.x, self.y + love.math.random() * 5))
                    self.explosion_underwater:play()

                    local colliders = self.area.world:queryCircleArea(self.x, self.y, 140)
                    for _, collider in ipairs(colliders) do
                        local posx, posy = collider:getWorldCenter()
                        local vecx, vecy = Vector.normalize(posx - self.x, posy - self.y)
                        collider:applyLinearImpulse(25 * vecx, 25 * vecy)

                        local obj = collider:getObject()
                        if (obj and obj.isLoveBox) then
                            obj.alive = false
                        end
                    end

                    self.timer:after(
                        0.15,
                        function()
                            self.dead = true
                        end
                    )
                end
            )
        end
    end

    if (self.y > 45) then
        self.alive = false
    --self.explosion_underwater:play()
    end

    if (self.y < 0) then
        self.collider:applyForce(0, 1000 * dt)
    elseif (self.y > 0) then
        self.collider:applyForce(0, 100 * dt)
    end

    if (self.x < -2000 and self.alive) then
        self.alive = false
        camera:shake(10, 1, 42)

        -- self.area.room:setGameOver(self.x, self.y)
        print("You're dead")
    end

    -- if self.collider:enter("Sub") then
    --     self.collider:applyLinearImpulse(0, 100)
    --     camera:shake(8, 0.7, 30)
    --     self.explosion:play()

    -- end
end

function Lovebox:draw()
    Lovebox.super.draw(self)
    local scale = 1
    if self.exploding and love.math.random() > 0.5 then
        love.graphics.draw(boombox, self.x, self.y, self.r, 1, 1, boximg:getWidth() / 2, boximg:getHeight() / 2)
    else
        love.graphics.draw(boximg, self.x, self.y, self.r, 1, 1, boximg:getWidth() / 2, boximg:getHeight() / 2)
    end

    if self.reallyexploding then
        love.graphics.circle("fill", self.x, self.y, 25)
    end
end
