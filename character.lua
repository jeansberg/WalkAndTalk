-- Package: character
-- This package contains the Character table used for the player character, friend and other NPCs

require "animation"
require "spriteSheet"
require "gameObject"

local P = {}
character = P

-- Imports
local print = print
local love = love
local gameObject = gameObject
local setmetatable = setmetatable
setfenv(1, P)

Character = gameObject.GameObject:new{width = 28, height = 38, bubbleTimer = 0}

speechImage = love.graphics.newImage("resources/images/speech.png")
shoutImage = love.graphics.newImage("resources/images/shout.png")
bubbleTimerMax = 1.5

function Character:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.initialX = o.xPos
    o.initialY = o.yPos
    o.currentAnimation = "standing"
    o.bubbleVisible = false
    return o
end

function Character:update(dt)
    if not self.bubbleVisible then
        return
    end
    if self.bubbleTimer < bubbleTimerMax then
        self.bubbleTimer = self.bubbleTimer + dt
    else
        self.bubbleVisible = false
        self.bubbleTimer = 0
    end
end

function Character:setAnimation(animation)
    if(animation == self.currentAnimation) then
        return
    end

    self.currentAnimation = animation
    self.animations[animation]:reset()
end

function Character:reset()
    self.xPos = self.initialX
    self.yPos = self.initialY
end

function Character:bottom()
    return self.yPos + self.height
end

function Character:right()
    return self.xPos + self.width
end

function Character:draw()
    love.graphics.draw(self.image, self.frames[self.animations[self.currentAnimation].currentFrame], self.xPos, self.yPos, 0, 1.2, 1.2)
        
    if self.bubbleVisible then
        local scale = 0.1
        local dx = 30
        local dy = 30

        if self.bubbleImage == shoutImage then
            scale = 0.2
            dx = 80
            dy = 80
        end

        love.graphics.draw(self.bubbleImage, 
                           self.xPos - dx, 
                           self.yPos -dy, 
                           0, 
                           scale, 
                           scale)
    end
end

function Character:showBubble(bubbleType)
    if bubbleType == "speech" then
        self.bubbleImage = speechImage
    else
        self.bubbleImage = shoutImage
    end
    self.bubbleTimer = 0
    self.bubbleVisible = true
end