-- Package: gameObject
-- This package contains the GameObject table which is the base class for all objects
local gameObject = {}

local GameObject = {}

function GameObject:new(xPos, yPos, width, height)
    local o = {xPos = xPos, yPos = yPos, width = width, height = height}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Draws the game object
function GameObject:draw()
    local scaleX = self.scaleX or 1
    local scaleY = self.scaleY or 1

    love.graphics.draw(self.image, self.xPos, self.yPos, 0, scaleX, scaleY)
end

-- Returns the bottom y position
function GameObject:bottom()
    return self.yPos + self.height
end

-- Returns the right x position
function GameObject:right()
    return self.xPos + self.width
end

function gameObject.newGameObject(xPos, yPos, width, height) 
    return GameObject:new(xPos, yPos, width, height)
end

return gameObject