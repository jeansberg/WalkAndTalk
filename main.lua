require "gameLevel"
require "gameScreen"
require "input"
require "collisions"
require "conversation"

walkingScreenWidth = love.graphics.getWidth() / 2
screenHeight = love.graphics.getHeight()
playerSpeed = 120
friendSpeed = 100
scrollSpeed = 100
numScreens = 5

function love.load()
    playerSprite = love.graphics.newImage("resources/images/player.png")
    friendSprite = love.graphics.newImage("resources/images/friend.png")
    imageWidth = playerSprite:getWidth()
    imageHeight = playerSprite:getHeight()
    local frameSide = 32

    local playerFrames = getFrames(playerSprite, imageWidth, imageHeight, frameSide, 3)
    local friendFrames = getFrames(friendSprite, imageWidth, imageHeight, frameSide, 3)

    player = {width = 32, height = 32, speed = playerSpeed, img = playerSprite, frames = playerFrames}
    friend = {width = 32, height = 32, speed = friendSpeed, img = friendSprite, frames = friendFrames}
    screens = {}

    conversation.init(5)
    startGame()
end

function getFrames(img, imgWidth, imgHeight, frameSide, numFrames)
    local frames = {}
    
    local rowCount = imgWidth / frameSide
    local colCount = imgHeight / frameSide
    for r = 0, rowCount-1 do
        for c = 0, colCount-1 do 
            table.insert(frames, love.graphics.newQuad(c * frameSide, r * frameSide, frameSide, frameSide, imgWidth, imgHeight))
        end
    end

    return frames
end

function startGame()
    conversation.reset()
    player.xPos = 3/4 * walkingScreenWidth - player.width * 2
    player.yPos = screenHeight/4 - player.height/2
    resetStep(player)
    screens = gameLevel.generateScreens(numScreens, walkingScreenWidth, screenHeight)
end

function love.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end
    love.graphics.draw(player.img, player.frames[player.currentFrame], player.xPos, player.yPos)
    love.graphics.draw(friend.img, friend.frames[friend.currentFrame], friend.xPos, friend.yPos)

    conversation.draw()
end

function love.update(dt)
    success = conversation.update(dt)

    if not success then
        startGame()
    end

    updateCharacter(player, dt, input.getMovementInput)
    moveCharacter(player, dt)

    for i = 1, table.getn(screens) do
        screens[i]:update(scrollSpeed, dt)
    end
end

function updateCharacter(directions, dt, getDirections)
    player.dx = 0
    player.dy = -scrollSpeed
    directions = getDirections()

    up, left, down, right = directions["up"], directions["left"], directions["down"], directions["right"]

    if not (up or left or down or right) then
        resetStep(player)
        return
    end

    local speed = player.speed
    if((down or up) and (left or right)) then
        speed = speed / math.sqrt(2)
    end

    if down and player.yPos<screenHeight-player.height then
        player.dy = speed
    elseif up then
        player.dy = -speed
    end

    if right and player.xPos<walkingScreenWidth-player.width then
        player.dx = speed
    elseif left and player.xPos>0 then
        player.dx = -speed
    end

    updateStep(player, dt)
end

function resetStep(char)
    char.currentFrame = 1
    char.stepTimer = 0
end

function updateStep(char, dt)
    if char.currentFrame == 1 then
        char.currentFrame = 2
    end

    if char.stepTimer < 0.2 then
        char.stepTimer = char.stepTimer + dt
    else
        toggleFrame(char, dt)
        char.stepTimer = 0
    end
end

function toggleFrame(char)
    if char.currentFrame == 2 or char.currentFrame == 1 then
        char.currentFrame = 3
    else
        char.currentFrame = 2
    end
end

function moveCharacter(char, dt)
    char.xPos = char.xPos + char.dx * dt
    char.yPos = char.yPos + char.dy * dt

    for i = 1, table.getn(screens) do
        local screen = screens[i]
        if collisions.checkOverlap(char, screen) then
            if screen.layout == "finish" then
                startGame()
            end

            local wall = {}
            if screen.layout == "right" and char.xPos < 200 then
                wall = {xPos=screen.xPos, yPos=screen.yPos, width = 200, height = 600}
                collisions.resolveWallCollision(char, wall, scrollSpeed)
            elseif screen.layout == "left" and char.xPos >= 200 - char.width then
                wall = {xPos=screen.xPos + 200, yPos=screen.yPos, width = 200, height = 600}
                collisions.resolveWallCollision(char, wall, scrollSpeed)
            end

            break
        end
    end

    if char.yPos < 0 then
        startGame()
    end
end

function getFriendDirections()

end