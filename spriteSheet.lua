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

function SpriteSheet:new(imageWidth, imageHeight, frameSide, numFrames, layout)
    local o = getFrames(imageWidth, imageHeight, frameSide, numFrames, layout)
    setmetatable(self, o)
    self.__index = self
    return o
end 

-- Returns a list of frame as quads based on the image
function getFrames(imageWidth, imageHeight, frameSide, numFrames, layout)
    local frames = {}
    local rowCount = imageWidth / frameSide
    local colCount = imageHeight / frameSide
    if layout == "rowsFirst" then
        for r = 0, rowCount - 1 do
            for c = 0, colCount - 1 do 
                table.insert(frames, love.graphics.newQuad(c * frameSide, r * frameSide + verticalPadding * r+1, frameSide, frameSide, imageWidth, imageHeight))
            end
        end
    elseif layout == "columnsFirst" then
        for c = 0, colCount - 1 do 
            for r = 0, rowCount - 1 do
                table.insert(frames, love.graphics.newQuad(c * frameSide, r * frameSide, frameSide, frameSide, imageWidth, imageHeight))
            end
        end
    end

    return frames
end