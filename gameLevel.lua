-- Package: gameLevel.
-- This package contains functions for generating a level made up of GameScreen objects.
local gameScreen = require "gameScreen"

-- Returns a walkable image to be used for the first screen
local function loadWalkableStart()
    local image = love.graphics.newImage("resources/images/walkable/start.png")
    return image
end

-- Returns a walkable image
local function loadWalkable()
    local image = love.graphics.newImage("resources/images/walkable/sidewalk.png")
    return image
end

-- Returns a blocked image
local function loadBlocked()
    local image = love.graphics.newImage("resources/images/blocked/buildings.png")
    return image
end

-- Returns an image that starts a transition
local function loadTransitionStart()
    local image = love.graphics.newImage("resources/images/transitionStart/sidewalkCrosswalk.png")
    return image
end

-- Returns an image that ends a transition
local function loadTransitionEnd()
    local image = love.graphics.newImage("resources/images/transitionEnd/crosswalk.png")
    return image
end

-- Returns an appropriate set of left and right images
-- for the layout
local function getImages(layout)
    local left, right
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

local gameLevel = {}

-- Generate a sequence of screens that will make up the level
function gameLevel.generateScreens(numScreens, width, height)
    local screens = {}
    local layout
    local coin

    for i = 1, numScreens do
        local flipped = false
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
        local left, right = getImages(layout)
        screens[i] =
            gameScreen.newGameScreen(0, (i - 1) * 600, width, height, left, right, flipped, layout)
    end
    screens[numScreens + 1] =
        gameScreen.newGameScreen(0, (numScreens) * 600, width, height, nil, nil, false, "finish")
    return screens
end

return gameLevel