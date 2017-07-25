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
        xOffset = 200
    else
        scale = 1
        xOffset = 0
    end
    love.graphics.draw(self.left, xOffset, self.position, 0, scale, 1)
    love.graphics.draw(self.right, levelWidth/2 + xOffset, self.position, 0, scale, 1)
end