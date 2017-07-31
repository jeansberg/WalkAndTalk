-- Package: spriteSheet
-- This package contains the SpriteSheet table used to encapsulate animation frames

local P = {}
spriteSheet = P

-- Imports
local print = print
local love = love
local table = table
local setmetatable = setmetatable
setfenv(1, P)

verticalPadding = 2

SpriteSheet = {}

function SpriteSheet:new(o)
    local spriteSheet = getFrames(o.imageWidth, o.imageHeight, o.frameSide, o.numFrames)
    setmetatable(self, o)
    self.__index = self
    return spriteSheet
end 

function getFrames(imageWidth, imageHeight, frameSide, numFrames)
    local frames = {}
    local rowCount = imageWidth / frameSide
    local colCount = imageHeight / frameSide
    for r = 0, rowCount - 1 do
        for c = 0, colCount - 1 do 
            table.insert(frames, love.graphics.newQuad(c * frameSide, r * frameSide + verticalPadding * r+1, frameSide, frameSide, imageWidth, imageHeight))
        end
    end

    return frames
end