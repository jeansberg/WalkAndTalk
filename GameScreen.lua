-- Package: gameScreen.
-- This package contains the GameScreen type which represents a part of a level.
local P = {}
gameScreen = P

-- Imports
local love = love
local setmetatable = setmetatable
setfenv(1, P)

GameScreen = {}

function GameScreen:new(o)
  local o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function GameScreen:update(scrollSpeed, dt)
    self.yPos = self.yPos - scrollSpeed * dt
end

function GameScreen:draw()
    if self.left == nil then
        return
    end

    if self.flipped then
        scale = - 1
        xOffset = 200
    else
        scale = 1
        xOffset = 0
    end
    love.graphics.draw(self.left, xOffset, self.yPos, 0, scale, 1)
    love.graphics.draw(self.right, self.width/2 + xOffset, self.yPos, 0, scale, 1)
end

function GameScreen:getBarrier()
    if self.layout == "left" then
        return {xPos = self.width/2, yPos = self.yPos, width = 200, height = 600}
    elseif self.layout == "right" or self.layout == "start" then
        return {xPos = 0, yPos = self.yPos, width = 200, height = 600}
    else
        return nil
    end
end