Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self .y = y
    self.height = height
    self.width = width

    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy *dt)
    end
end

function Paddle:reset(x, y, width, height)    
    self.x = x
    self .y = y
    self.height = height
    self.width = width
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end