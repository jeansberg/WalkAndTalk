-- Package: character
-- This package contains the Character table used for the player character, friend and other NPCs

local animation = require "animation"
local spriteSheet = require "spriteSheet"
local gameObject = require "gameObject"

local character = {}

-- Constants
local speechImage = love.graphics.newImage("resources/images/speech.png")
local shoutImage = love.graphics.newImage("resources/images/shout.png")
local heartImage = love.graphics.newImage("resources/images/heart.png")
local bubbleTimerMax = 1.5
local scale = 2

-- Character inherits from GameObject
local Character = gameObject.newGameObject()

function Character:new(xPos, yPos, width, height, speed, animations, frames, image)
    local o = {
        xPos = xPos,
        yPos = yPos,
        width = width,
        height = height,
        speed = speed,
        animations = animations,
        frames = frames,
        image = image
    }
    setmetatable(o, self)
    self.__index = self
    -- Initial position can be used when resetting characters
    o.initialX = o.xPos
    o.initialY = o.yPos
    o.bubbleTimer = 0
    o.bubbleVisible = false
    o.currentAnimation = "standing"
    return o
end

-- Resets the character
function Character:reset()
    self.xPos = self.initialX
    self.yPos = self.initialY
    self.bubbleVisible = false
    self.bubbleTimer = 0
end

-- Updates character logic
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

-- Sets a new animation for the character
function Character:setAnimation(animation)
    if (animation == self.currentAnimation) then
        return
    end

    self.currentAnimation = animation
    self.animations[animation]:reset()
end

-- Draws the character
function Character:draw()
    -- Draws the current frame
    love.graphics.draw(
        self.image,
        self.frames[self.animations[self.currentAnimation].currentFrame],
        self.xPos,
        self.yPos,
        0,
        scale,
        scale
    )

    -- Draws the speech bubble if one is visible
    if self.bubbleVisible then
        love.graphics.draw(
            self.bubbleImage,
            self.xPos - self.bubbleImage:getWidth() * 0.7,
            self.yPos - self.bubbleImage:getHeight()
        )
    end
end

-- Shows the specified type of speech bubble above the character
function Character:showBubble(bubbleType)
    if bubbleType == "speech" then
        self.bubbleImage = speechImage
    elseif bubbleType == "shout" then
        self.bubbleImage = shoutImage
    else
        self.bubbleImage = heartImage
    end
    self.bubbleTimer = 0
    self.bubbleVisible = true
end

function character.newCharacter(xPos, yPos, width, height, speed, animations, frames, image)
    return Character:new(xPos, yPos, width, height, speed, animations, frames, image)
end

return character