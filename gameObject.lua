-- Package: gameObject
-- This package contains the GameObject table which is the base class for all objects

local P = {}
gameObject = P

-- Imports
local print = print
local love = love
local setmetatable = setmetatable
setfenv(1, P)

GameObject = {}

function GameObject:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameObject:draw()
    local scaleX = self.scaleX or 1
    local scaleY = self.scaleY or 1

    love.graphics.draw(self.image, self.xPos, self.yPos, 0, scaleX, scaleY)
end