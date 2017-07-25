require "GameScreen"

function generateScreens(numScreens)
    local screens = {}

    for i = 1, numScreens do
        flipped = false
        if i == 1 then
            -- Always start with a layout walkable on the right side
            layout = "right"
        else
            -- Add a compatible layout
            if layout == "right" then 
                coin = love.math.random(0, 1)
                if coin == 1 then
                    layout = "rightToLeft"
                end
            elseif layout == "left" then
                flipped = true
                coin = love.math.random(0, 1)
                if coin == 1 then
                    layout = "leftToRight"
                end
            elseif layout == "leftToRight" then
                layout = "right"
            elseif layout == "rightToLeft" then
                flipped = true
                layout = "left"
            end
        end
        print(layout)
        leftImage, rightImage = getImages(layout)
        screens[i] = GameScreen:new{position = (i - 1)*600, left = leftImage, right = rightImage, flipped = flipped}
    end

    return screens
end

function getImages(layout)
    if layout == "right" then
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