-- Package: gameLevel.
-- This package contains functions for generating a level made up of GameScreen objects.
require "gameScreen"
local P = {}
gameLevel = P

-- Imports
local love = love
local gameScreen = gameScreen
local print = print
setfenv(1, P)

function generateScreens(numScreens, width, height)
    local screens = {}

    for i = 1, numScreens do
        flipped = false
        if i == 1 then
            -- Always start with a layout walkable on the right side
            layout = "start"
        else
            -- Add a layout compatible with the last one
            if layout == "right" or layout == "start" then 
                coin = love.math.random(0, 2)
                if coin > 0 then
                    layout = "rightToLeft"
                else
                    layout = "right"
                end
            elseif layout == "left" then
                flipped = true
                coin = love.math.random(0, 2)
                if coin > 0 then
                    layout = "leftToRight"
                end
            elseif layout == "leftToRight" then
                layout = "right"
            elseif layout == "rightToLeft" then
                flipped = true
                layout = "left"
            end
        end
        left, right = getImages(layout)
        screens[i] = gameScreen.GameScreen:new{width = width, height = height, xPos = 0, yPos = (i - 1)*600, left = left, right = right, flipped = flipped, layout = layout}
    end
    screens[numScreens + 1] = gameScreen.GameScreen:new{width = width, height = height, xPos = 0, yPos = (numScreens)*600, left = nil, right = nil, flipped = false, layout = "finish"}
    return screens
end

function getImages(layout)
    if layout == "start" then
        left = loadBlocked()
        right = loadWalkableStart()
    elseif layout == "right" then
        left = loadBlocked()
        right = loadWalkable()
    elseif layout == "left" then
        left = loadWalkable()
        right = loadBlocked()
    elseif layout == "rightToLeft" then
        right = loadTransitionStart()
        left = loadTransitionEnd()
    elseif layout == "leftToRight" then
        right = loadTransitionEnd()
        left = loadTransitionStart()
    end

    return left, right
end

function loadWalkableStart()
    local image = love.graphics.newImage("resources/images/walkable/start.png")
    return image
end

function loadWalkable()
    local image = love.graphics.newImage("resources/images/walkable/sidewalk.png")
    return image
end

function loadBlocked()
    local image = love.graphics.newImage("resources/images/blocked/buildings.png")
    return image
end

function loadTransitionStart()
    local image = love.graphics.newImage("resources/images/transitionStart/sidewalkCrosswalk.png")
    return image
end

function loadTransitionEnd()
    local image = love.graphics.newImage("resources/images/transitionEnd/crosswalk.png")
    return image
end