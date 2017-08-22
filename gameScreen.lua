-- Package: gameScreen.
-- This package contains the GameScreen type which represents a part of a level.
local P = {}
gameScreen = P

-- Imports
local love = love
local setmetatable = setmetatable
setfenv(1, P)

GameScreen = {}

function GameScreen:new(xPos, yPos, width, height, left, right, flipped, layout)
  local o = {xPos = xPos, yPos = yPos, width = width, height = height, left = left, right = right, flipped = flipped, layout = layout}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Updates the position of the game screen
function GameScreen:update(scrollSpeed, dt)
    self.yPos = self.yPos - scrollSpeed * dt
end

-- Draws the images representing the game screen
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

-- Gets the blocking part of the screen for collision detection
function GameScreen:getBarrier()
    if self.layout == "left" then
        return {xPos = self.width/2, yPos = self.yPos, width = 200, height = 600}
    elseif self.layout == "right" or self.layout == "start" then
        return {xPos = 0, yPos = self.yPos, width = 200, height = 600}
    else
        return nil
    end
end

-- Gets a forbidden zone of the screen that ends the game on contact
function GameScreen:getHazard()
    if self.layout == "rightToLeft" then
        return {xPos = self.width/2, yPos = self.yPos + 200, width = 200, height = 400}
    elseif self.layout == "leftToRight"  then
        return {xPos = 0, yPos = self.yPos + 200, width = 200, height = 400}
    else
        return nil
    end
end