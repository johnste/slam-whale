Submarine = Entity:extend()
local sub_body
local sub_wings
local sub_tower

function Submarine:new(area, x, y)
    Submarine.super.new(self, area, x, y)
    self.r = 0
    self.rv = 1.22 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100
    self.w = 12

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    sub_body = love.graphics.newImage("img/sub-body.png")
    sub_wings = love.graphics.newImage("img/sub-wings.png")
    sub_tower = love.graphics.newImage("img/sub-tower.png")

    self.timer:after(
        0.4,
        function(f)
            xv = self.collider:getLinearVelocity()
            self.area:addEntity(
                Bubble(self.area, self.x - math.cos(self.r) * self.w, self.y - math.sin(self.r) * self.w, xv)
            )
            print(self.direction)
            self.timer:after(math.max(0.1, self.direction), f)
        end
    )
end

function Submarine:update(dt)
    Submarine.super.update(self, dt)
    camera:follow(self.x, self.y)

    if input:down("go right") then
        self.r = self.r + self.rv * dt
    end

    if input:down("go left") then
        self.r = self.r - self.rv * dt
    end

    self.v = math.min(self.v + self.a * dt, self.max_v)

    self.v = self.v + self.a * dt
    if self.v >= self.max_v then
        self.v = self.max_v
    end

    local x, y = Vector.normalize(self.collider:getLinearVelocity())
    self.direction = Vector.dot(x, y, math.cos(self.r), math.sin(self.r))

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyForce(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if (self.y < 0) then
        self.collider:applyForce(0, 300)
    end
end

function Submarine:draw()
    -- for k, v in pairs(image) do
    --     print(k, v)
    -- end

    love.graphics.draw(sub_body, self.x, self.y, self.r, 1, 1, sub_body:getWidth() / 2, sub_body:getHeight() / 2)
    love.graphics.draw(
        sub_wings,
        self.x,
        self.y,
        self.r,
        1,
        math.sin(self.r),
        sub_wings:getWidth() / 2,
        sub_wings:getHeight() / 2
    )
    love.graphics.draw(
        sub_tower,
        self.x,
        self.y,
        self.r,
        1,
        math.cos(self.r),
        sub_tower:getWidth() / 2,
        sub_tower:getHeight() / 2
    )

    --love.graphics.circle("line", self.x, self.y, self.w)
    --love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))

    love.graphics.print("x:" .. math.round(self.x, 0.1), self.x, self.y + 30)
    love.graphics.print("y:" .. math.round(self.y, 0.1), self.x, self.y + 44)
end
