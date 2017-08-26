-- ##################################################################
-- # Package: walking.
-- # This package contains code for controlling the walking part
-- # of the game.
-- ##################################################################
local gameLevel = require "gameLevel"
local gameScreen = require "gameScreen"
local input = require "input"
local character = require "character"
local spriteSheet = require "spriteSheet"
local collisions = require "collisions"
local images = require "resources".images
local sounds = require("resources").sounds
require "constants"

local walking = {}

function walking.init(_onGameEnd)
    onGameEnd = _onGameEnd

    local playerFrames =
        spriteSheet.newSpriteSheet(
        images.friendImage:getWidth(),
        images.friendImage:getHeight(),
        frameSide,
        16,
        "columnsFirst"
    )
    local friendFrames =
        spriteSheet.newSpriteSheet(
        images.friendImage:getWidth(),
        images.friendImage:getHeight(),
        frameSide,
        16,
        "columnsFirst"
    )

    local playerAnimations = {
        standing = animation.Animation:new(0, 2, 2),
        walking = animation.Animation:new(0.1, 1, 4)
    }
    local friendAnimations = {
        standing = animation.Animation:new(0, 2, 2),
        walking = animation.Animation:new(0.1, 1, 4)
    }

    objects = {}
    player =
        character.newCharacter(
        playerStartX,
        playerStartY,
        40,
        40,
        playerSpeed,
        playerAnimations,
        playerFrames,
        images.playerImage
    )
    friend =
        character.newCharacter(
        friendStartX,
        friendStartY,
        40,
        40,
        friendSpeed,
        friendAnimations,
        friendFrames,
        images.friendImage
    )
    car = {xPos = walkingScreenWidth, yPos = screenHeight, image = images.carImage}
    table.insert(objects, player)
    table.insert(objects, friend)
    table.insert(objects, car)

    screens = {}
end

local function getFriendDirections()
    local down = true
    local up = false
    local left = false
    local right = false

    if friend.screenLayout == "leftToRight" and friend.xPos < friendStartX then
        right = true
    elseif
        friend.screenLayout == "rightToLeft" and
            friend.xPos > 1 / 4 * walkingScreenWidth + frameSide
     then
        left = true
    end

    return {up = up, left = left, down = down, right = right}
end

local function restart()
    love.audio.stop(sounds.music)
    if gameState == "Finished" then
        friend:showBubble("heart")
        love.audio.play(sounds.victory)
    else
        love.audio.play(sounds.failure)
        friend:showBubble("shout")
    end

    restarting = true
end

local function updateCar(dt)
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

local function updateEnding(dt)
    if gameState == "NearMiss" then
        updateCar(dt)
    end
end

local function positionCar()
    if string.find(player.screenLayout, "left") then
        car.xPos = -carWidth
    end
end

local function moveCharacter(char, dt)
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
                            love.audio.play(sounds.skid)
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

local function setFriendSpeed()
    if friend.yPos < screenHeight / 2 then
        friend.speed = friendSpeed * 1.2
    else
        friend.speed = friendSpeed
    end
end

function walking.update(dt, cancel)
    friend:update(dt)
    player:update(dt)
    if restarting then
        onGameEnd(gameState)
        if restartTimer < restartTimerMax then
            restartTimer = restartTimer + dt
            updateEnding(dt)
        else
            restartTimer = 0
            restarting = false
            cancel()
        end
    else
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

function walking.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end

    if car.flipped then
        love.graphics.draw(car.image, car.xPos, car.yPos, 0, 1.4, 1.4)
    else
        love.graphics.draw(car.image, car.xPos, car.yPos, 0, -1.4, 1.4)
    end

    if (player.yPos > friend.yPos) then
        friend:draw()
        player:draw()
    else
        player:draw()
        friend:draw()
    end
end

function walking.reset()
    restartTimer = 0
    restarting = false
    gameState = "Running"

    player:reset()
    friend:reset()
    car = {xPos = walkingScreenWidth + carWidth, yPos = screenHeight, image = images.carImage}

    screens = gameLevel.generateScreens(numScreens, walkingScreenWidth, screenHeight)
end

function updateCharacter(char, dt, getDirections)
    char.dx = 0
    char.dy = -scrollSpeed
    local directions = getDirections()

    local up,
        left,
        down,
        right = directions["up"], directions["left"], directions["down"], directions["right"]
    char.animations[char.currentAnimation]:update(dt)

    if not (up or left or down or right) then
        char:setAnimation("standing")
        return
    end

    char:setAnimation("walking")

    local speed = char.speed
    if ((down or up) and (left or right)) then
        speed = speed / math.sqrt(2)
    end

    if down and char.yPos < screenHeight - char.height then
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

function walking.sendMessage(message)
    local message = message

    if message == "NewTopic" then
        friend:showBubble("speech")
    elseif message == "TopicAnswered" then
        player:showBubble("speech")
    elseif message == "TopicFailed" then
        gameState = "WrongAnswer"
        restart()
    end
end

return walking