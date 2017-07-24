GameScreen = {}

function GameScreen:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function GameScreen:update(dt)
    self.position = self.position - scrollSpeed * dt
end

function GameScreen:draw()
    if self.flipped then
        scale = - 1
    else
        scale = 0
    end

    love.graphics.draw(self.left, 0, self.position, 0, scale)
    love.graphics.draw(self.right, levelWidth/2, self.position, 0, scale)
end