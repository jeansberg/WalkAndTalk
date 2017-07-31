-- Package: character
-- This package contains the Character table used for the player character, friend and other NPCs

require "animation"
require "spriteSheet"

local P = {}
character = P

-- Imports
local print = print
local setmetatable = setmetatable
setfenv(1, P)

Character = {width = 32, height = 32}

function Character:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.defaultX = o.xPos
    o.defaultY = o.yPos
    o.currentAnimation = "standing"
    return o
end

function Character:setAnimation(animation)
    if(animation == self.currentAnimation) then
        return
    end

    self.currentAnimation = animation
    self.animations[animation]:reset()
end

function Character:reset()
    self.xPos = self.defaultX
    self.yPos = self.defaultY
end

function Character:bottom()
    return self.yPos + self.height
end

function Character:right()
    return self.xPos + self.width
end