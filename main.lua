require "gameLevel"
require "gameScreen"
require "input"
require "collisions"
require "conversation"
require "character"

-----------------------------------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------------------------------
walkingScreenWidth = love.graphics.getWidth() / 2
screenHeight = 600
playerSpeed = 150
friendSpeed = 100
carSpeed = 600
carWidth = 172
carHeight = 56
scrollSpeed = 100
numScreens = 10
frameSide = 32
playerStartX = 3/4 * walkingScreenWidth - frameSide * 2
playerStartY = screenHeight/4 - frameSide / 2
friendStartX = 3/4 * walkingScreenWidth - frameSide
friendStartY = screenHeight/4
restartTimerMax = 3
restartTimer = 0
restarting = false

function love.load()
    playerImage = love.graphics.newImage("resources/images/player.png")
    charImage = love.graphics.newImage("resources/images/character.png")
    friendImage = love.graphics.newImage("resources/images/friend.png")
    carImage = love.graphics.newImage("resources/images/car2.png")
    victory = love.audio.newSource("resources/sound/Jingle_Win_01.mp3")
    failure = love.audio.newSource("resources/sound/Jingle_Lose_01.mp3")
    skid = love.audio.newSource("resources/sound/skid.mp3")
    music = love.audio.newSource("resources/sound/Sound Way NES.mp3")

    imageWidth = playerImage:getWidth()
    imageHeight = playerImage:getHeight()

    local playerFrames = spriteSheet.SpriteSheet:new(charImage:getWidth(), charImage:getHeight(), frameSide, 16, "columnsFirst")
    local friendFrames = spriteSheet.SpriteSheet:new(imageWidth, imageHeight, frameSide, 3, "rowsFirst")

    local playerAnimations = {standing = animation.Animation:new(0, 2, 2), walking = animation.Animation:new(0.1, 1, 4)}
    local friendAnimations = {standing = animation.Animation:new(0, 1, 1), walking = animation.Animation:new(0.2, 2, 3)}

    objects = {}
<<<<<<< HEAD
    player = character.Character:new(playerStartX, playerStartY, playerSpeed, playerAnimations, playerFrames, charImage)
    friend = character.Character:new(friendStartX, friendStartY, friendSpeed, friendAnimations, friendFrames, friendImage)
=======
    player = character.Character:new(playerStartX, playerStartY, 28, 10, playerSpeed, playerAnimations, playerFrames, playerImage)
    friend = character.Character:new(friendStartX, friendStartY, 28, 10, friendSpeed, friendAnimations, friendFrames, friendImage)
>>>>>>> 338d936f0c16a773c0aa9c1c1ee441cd398db4dc
    car = {xPos = walkingScreenWidth, yPos = screenHeight, image = carImage}
    table.insert(objects, player)
    table.insert(objects, friend)
    table.insert(objects, car)

    screens = {}

    conversation.init(onNewTopic, onAnswer)
    startGame()
end

function startGame()
    music:setVolume(0.5)
    love.audio.rewind(music)
    love.audio.play(music)
    gameState = "Running"
    conversation.reset()
    player:reset()
    friend:reset()
    car = {xPos = walkingScreenWidth + carWidth, yPos = screenHeight, image = carImage}

    screens = gameLevel.generateScreens(numScreens, walkingScreenWidth, screenHeight)
end

function love.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end

    if car.flipped then
        love.graphics.draw(car.image, car.xPos, car.yPos, 0, 1.5, 1.5)
    else
        love.graphics.draw(car.image, car.xPos, car.yPos, 0, -1.5, 1.5)
    end
    
    if( player.yPos > friend.yPos) then
        friend:draw()
        player:draw()
    else
        player:draw()
        friend:draw()
    end

    conversation.draw()
end

function love.update(dt)
    friend:update(dt)
    player:update(dt)
    if restarting then
        conversation.interrupt(gameState)
        if restartTimer < restartTimerMax then
            restartTimer = restartTimer + dt
            updateEnding(dt)
        else
            restartTimer = 0
            restarting = false
            startGame()
        end
    else
        conversation.update(dt)

        --[[
        if not success then
            gameState = "WrongAnswer"
            restart()
        end
        ]]

        updateCharacter(friend, dt, getFriendDirections)
        moveCharacter(friend, dt)

        setFriendSpeed()
        updateCharacter(player, dt, input.getMovementInput)
        moveCharacter(player, dt)

        for i = 1, table.getn(screens) do
            screens[i]:update(scrollSpeed, dt)
        end
    end
end

function updateCharacter(char, dt, getDirections)
    char.dx = 0
    char.dy = -scrollSpeed
    local directions = getDirections()

    local up, left, down, right = directions["up"], directions["left"], directions["down"], directions["right"]
    char.animations[char.currentAnimation]:update(dt)

    if not (up or left or down or right) then
        char:setAnimation("standing")
        return
    end

    char:setAnimation("walking")

    local speed = char.speed
    if((down or up) and (left or right)) then
        speed = speed / math.sqrt(2)
    end

    if down and char.yPos<screenHeight - char.height then
        char.dy = char.dy + speed
    elseif up then
        char.dy = char.dy - speed
    end

    if right and char.xPos < walkingScreenWidth - char.width then
        char.dx = char.dx + speed
    elseif left and char.xPos > 0 then
        char.dx = char.dx - speed
    end
end

function moveCharacter(char, dt)
    -- Update character position
    char.xPos = char.xPos + char.dx * dt
    char.yPos = char.yPos + char.dy * dt

    if collisions.checkOverlap(player, friend) then
        collisions.resolveCollision(player, friend, dt)
    end

    for i = 1, table.getn(screens) do
        local screen = screens[i]
        if collisions.checkOverlap(char, screen) then
            char.screenLayout = screen.layout

            if char == player and char.screenLayout == "finish" then
                gameState = "Finished"
                restart("")
            end
            
            for j = 1, table.getn(screens) do
                local barrier = screens[j]:getBarrier()
                if barrier then
                    if collisions.checkOverlap(char, barrier) then
                        collisions.resolveCollision(char, barrier, scrollSpeed, dt)
                        break
                    end
                else
                    local hazard = screens[j]:getHazard()
                    if hazard then
                        if collisions.checkOverlap(char, hazard) then
                            love.audio.play(skid)
                            positionCar()
                            gameState = "NearMiss"
                            player.hazard = hazard
                            restart()
                        end
                    end
                end
            end
        end
    end

    if char == player and char.yPos < 0 then
        gameState = "EatenByScroll"
        restart()
    end
end

function getFriendDirections()
    down = true
    up = false
    left = false
    right = false
    
    if friend.screenLayout == "leftToRight" and friend.xPos < friendStartX then
        right = true
    elseif friend.screenLayout == "rightToLeft" and friend.xPos > 1/4 * walkingScreenWidth + frameSide then
        left = true
    end

    return {up=up, left=left, down=down, right=right}
end

function setFriendSpeed()
    if friend.yPos < screenHeight / 2 then
        friend.speed = friendSpeed * 1.2
    else
        friend.speed = friendSpeed
    end
end

function restart()
    love.audio.stop(music)
    if gameState == "Finished" then
        friend:showBubble("heart")
        love.audio.play(victory)
    else
        love.audio.play(failure)
        friend:showBubble("shout")
    end

    restarting = true
end

function updateEnding(dt)
    if gameState == "NearMiss" then
        updateCar(dt)
    end
end

function positionCar()
    if string.find(player.screenLayout, "left") then
        car.xPos = -carWidth
    end
end

function updateCar(dt)
    if player.yPos < player.hazard.yPos + 400 - carHeight then
        car.yPos = player.yPos
    else
        car.yPos = player.hazard.yPos + 400 - carHeight
    end

    if string.find(player.screenLayout, "left") then
        car.flipped = true
        if car.xPos < player.xPos - carWidth then
            car.xPos = car.xPos + dt * carSpeed
        end
    else
        if car.xPos > player.xPos + player.width + carWidth then
            car.xPos = car.xPos - dt * carSpeed
        end
    end
end

function onNewTopic()
    friend:showBubble("speech")
end

function onAnswer()
    player:showBubble("speech")
end