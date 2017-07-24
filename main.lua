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

    player = {width = 32, height = 32, speed = 100}

    startGame()
end

function startGame()
    player.xPos = 0
    player.yPos = 0
    player.dx = 0
    player.dy = 0
    resetStep()
end

function love.draw()
    love.graphics.setColor(200, 200, 255, 255)
    love.graphics.rectangle("fill", 0, 0, levelWidth, levelHeight)
    love.graphics.setColor(255, 200, 255, 255)
    love.graphics.rectangle("fill", levelWidth, 0, levelWidth * 2, levelHeight)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(playerSprite, walkingFrames[currentFrame], player.xPos, player.yPos, 0, 1, 1)
end

function love.update(dt)
    directions = getInput()
    updatePlayer(directions, dt)
    movePlayer(dt)
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
    player.dy = 0
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
    elseif up and player.yPos>0 then
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
end

