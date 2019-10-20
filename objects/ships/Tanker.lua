Tanker = BubbleEntity:extend()
local sub_body = love.graphics.newImage("img/tanker.png")

function Tanker:new(area, x, y, water)
    Tanker.super.new(self, area, x, y, water)
    self.w = 256
    self.speed = 3500

    local body =
        self.area.world:newPolygonCollider(
        {
            -self.w / 2,
            -25,
            -self.w / 2 + 15,
            25,
            self.w / 2,
            -25,
            self.w / 2,
            25
        }
    )

    body:setPosition(self.x, self.y)

    body:setObject(self)
    body:setMass(80)
    body:setAngularDamping(10)
    body:setLinearDamping(0.104)
    body:setLinearVelocity(-25, 0)

    self.collider = body
end

function Tanker:update(dt)
    Tanker.super.update(self, dt)
end

function Tanker:draw()
    Tanker.super.draw(self)

    love.graphics.draw(
        sub_body,
        self.x,
        self.y,
        self.collider:getAngle(),
        1,
        1,
        sub_body:getWidth() / 2,
        sub_body:getHeight() / 2
    )

    if self.alive then
        love.graphics.line(self.x, 800, self.x, 1000)
        love.graphics.line(self.x, 800, self.x + 20, 820)
        love.graphics.line(self.x, 800, self.x - 20, 820)
    end
end
