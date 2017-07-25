require("GameLevel")
require("GameScreen")

levelWidth = love.graphics.getWidth() / 2
levelHeight = love.graphics.getHeight()

function love.load()
    playerSprite = love.graphics.newImage("resources/images/player.png")
    frameSide = 32
    frameHeight = 32
    imageWidth = playerSprite:getWidth()
    imageHeight = playerSprite:getHeight()

    walkingFrames = {
        love.graphics.newQuad(0, 0, frameSide, frameSide, imageWidth, imageHeight),
        love.graphics.newQuad(0, frameSide + 2, frameSide, frameSide, imageWidth, imageHeight),
        love.graphics.newQuad(frameSide, frameSide + 2, frameSide, frameSide, imageWidth, imageHeight)
    }

    player = {width = 32, height = 32, speed = 120}
    screens = {}

    startGame()
end

function startGame()
    scrollSpeed = 100
    player.xPos = levelWidth-levelWidth/4 - player.width/2
    player.yPos = levelHeight/4 - player.height/2
    player.dx = 0
    player.dy = -scrollSpeed
    resetStep()
    screens = generateScreens(2)
end

function love.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end
    love.graphics.draw(playerSprite, walkingFrames[currentFrame], player.xPos, player.yPos)
end

function love.update(dt)
    directions = getInput()
    updatePlayer(directions, dt)
    movePlayer(dt)

    if screens[table.getn(screens)].position <= 0 then
        scrollSpeed = 0
        return
    end

    for i = 1, table.getn(screens) do
        screens[i]:update(dt)
    end
end

function getInput(dt)
    up = love.keyboard.isDown("w")
    left = love.keyboard.isDown("a")
    down = love.keyboard.isDown("s")
    right = love.keyboard.isDown("d")

    return {up=up, left=left, down=down, right=right}
end

function updatePlayer(directions, dt)
    player.dx = 0
    player.dy = -scrollSpeed
    if not (directions["up"] or directions["left"] or directions["down"] or directions["right"]) then
        resetStep()
        return
    end

    speed = player.speed
    if((down or up) and (left or right)) then
        speed = speed / math.sqrt(2)
    end

    if directions["down"] and player.yPos<levelHeight-player.height then
        player.dy = speed
    elseif up then
        player.dy = -speed
    end

    if right and player.xPos<levelWidth-player.width then
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
        if checkCollision(player, screens[i]:getWall()) then
            resolveWallCollision(player, screens[i]:getWall())
            break
        end
    end

    if player.yPos < 0 then
        startGame()
    end

    if player.yPos >= levelHeight -player.height and scrollSpeed == 0 then
        startGame()
    end
end

function checkCollision(player, wall)
    if not (player and wall) then
        return false
    end

    if  player.xPos < wall.xPos and player.xPos + player.width > wall.xPos and
        player.yPos > wall.yPos and player.yPos + player.height < wall.yPos + wall.height then
            print("Collide")
        return true
    elseif wall.xPos < player.xPos and wall.xPos + wall.width > player.xPos and
            wall.yPos < player.yPos and wall.yPos + wall.height > player.yPos then
        return true
    else
        return false
    end
end

function resolveWallCollision(player, wall)
    if player.dx > 0 then
        player.xPos = wall.xPos - player.width
    elseif player.dx < 0 then
        player.xPos = wall.xPos + wall.width
    end

    if player.dy > scrollSpeed then
        player.yPos = wall.yPos - player.height
    elseif player.dy < -scrollSpeed then
        player.yPos = wall.yPos + wall.height
    end
end