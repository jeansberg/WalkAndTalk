require "gameLevel"
require "gameScreen"
require "input"
require "collisions"
require "conversation"

walkingScreenWidth = love.graphics.getWidth() / 2
walkingScreenHeight = love.graphics.getHeight()
frameSide = 32
frameHeight = 32
playerSpeed = 120
scrollSpeed = 100

function love.load()
    playerSprite = love.graphics.newImage("resources/images/player.png")
    imageWidth = playerSprite:getWidth()
    imageHeight = playerSprite:getHeight()

    walkingFrames = {
        love.graphics.newQuad(0, 0, frameSide, frameSide, imageWidth, imageHeight),
        love.graphics.newQuad(0, frameSide + 2, frameSide, frameSide, imageWidth, imageHeight),
        love.graphics.newQuad(frameSide, frameSide + 2, frameSide, frameSide, imageWidth, imageHeight)
    }

    player = {width = 32, height = 32, speed = playerSpeed}
    screens = {}

    conversation.init(5)
    startGame()
end

function startGame()
    scrolling = true
    player.xPos = 3/4 * walkingScreenWidth - player.width/2
    player.yPos = walkingScreenHeight/4 - player.height/2
    resetStep()
    screens = gameLevel.generateScreens(5, walkingScreenWidth, walkingScreenHeight)
end

function love.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end
    love.graphics.draw(playerSprite, walkingFrames[currentFrame], player.xPos, player.yPos)

    conversation.draw()
end

function love.update(dt)
    conversation.update(dt)
    local directions = input.getMovementInput()
    updatePlayer(directions, dt)
    movePlayer(dt)

    if screens[table.getn(screens)].position <= 0 then
        scrolling = false
        return
    end

    for i = 1, table.getn(screens) do
        screens[i]:update(scrollSpeed, dt)
    end
end

function updatePlayer(directions, dt)
    player.dx = 0

    if scrolling then
        player.dy = -scrollSpeed
    else
        player.dy = 0
    end

    up, left, down, right = directions["up"], directions["left"], directions["down"], directions["right"]

    if not (up or left or down or right) then
        resetStep()
        return
    end

    local speed = player.speed
    if((down or up) and (left or right)) then
        speed = speed / math.sqrt(2)
    end

    if down and player.yPos<walkingScreenHeight-player.height then
        player.dy = speed
    elseif up then
        player.dy = -speed
    end

    if right and player.xPos<walkingScreenWidth-player.width then
        player.dx = speed
    elseif left and player.xPos>0 then
        player.dx = -speed
    end

    updateStep(dt)
end

function resetStep()
    currentFrame = 1
    stepTimer = 0
end

function updateStep(dt)
    if currentFrame == 1 then
        currentFrame = 2
    end

    if stepTimer < 0.2 then
        stepTimer = stepTimer + dt
    else
        toggleFrame(dt)
        stepTimer = 0
    end
end

function toggleFrame()
    if currentFrame == 2 or currentFrame == 1 then
        currentFrame = 3
    else
        currentFrame = 2
    end
end

function movePlayer(dt)
    player.xPos = player.xPos + player.dx * dt
    player.yPos = player.yPos + player.dy * dt

    for i = 1, table.getn(screens) do
        if collisions.checkCollision(player, screens[i]:getWall()) then
            collisions.resolveWallCollision(player, screens[i]:getWall(), scrollSpeed)
            break
        end
    end

    if player.yPos < 0 then
        startGame()
    end

    if player.yPos >= walkingScreenHeight -player.height and not scrolling then
        startGame()
    end
end