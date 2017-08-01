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
playerSpeed = 120
friendSpeed = 100
scrollSpeed = 100
numScreens = 10
frameSide = 32
playerStartX = 3/4 * walkingScreenWidth - frameSide * 2
playerStartY = screenHeight/4 - frameSide / 2
friendStartX = 3/4 * walkingScreenWidth - frameSide
friendStartY = screenHeight/4




function love.load()
    playerImage = love.graphics.newImage("resources/images/player.png")
    friendImage = love.graphics.newImage("resources/images/friend.png")
    imageWidth = playerImage:getWidth()
    imageHeight = playerImage:getHeight()

    local playerFrames = spriteSheet.SpriteSheet:new{imageWidth = imageWidth, imageHeight = imageHeight, frameSide = frameSide, numFrames = 3}
    local friendFrames = spriteSheet.SpriteSheet:new{imageWidth = imageWidth, imageHeight = imageHeight, frameSide = frameSide, numFrames = 3}

    local playerAnimations = {standing = animation.Animation:new(0, 1, 1), walking = animation.Animation:new(0.2, 2, 3)}
    local friendAnimations = {standing = animation.Animation:new(0, 1, 1), walking = animation.Animation:new(0.2, 2, 3)}

    player = character.Character:new{xPos = playerStartX, yPos = playerStartY, speed = playerSpeed, animations = playerAnimations, frames = playerFrames, image = playerImage}
    friend = character.Character:new{xPos = friendStartX, yPos = friendStartY, speed = friendSpeed, animations = friendAnimations, frames = friendFrames, image = friendImage}


    screens = {}

    conversation.init(5)
    startGame()
end

function startGame()
    conversation.reset()
    player:reset()
    friend:reset()

    screens = gameLevel.generateScreens(numScreens, walkingScreenWidth, screenHeight)
end

function love.draw()
    for i = 1, table.getn(screens) do
        screens[i]:draw()
    end

    love.graphics.draw(player.image, player.frames[player.animations[player.currentAnimation].currentFrame], player.xPos, player.yPos)
    love.graphics.draw(friend.image, friend.frames[friend.animations[friend.currentAnimation].currentFrame], friend.xPos, friend.yPos)
    conversation.draw()
end

function love.update(dt)
    success = conversation.update(dt)

    if not success then
        startGame()
    end

    updateCharacter(friend, dt, getFriendDirections)
    moveCharacter(friend, dt)

    setFriendSpeed()
    updateCharacter(player, dt, input.getMovementInput)
    moveCharacter(player, dt)

    for i = 1, table.getn(screens) do
        screens[i]:update(scrollSpeed, dt)
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
        collisions.resolveCollision(player, friend, scrollSpeed, dt)
    end

    for i = 1, table.getn(screens) do
        local screen = screens[i]
        if collisions.checkOverlap(char, screen) then
            char.screenLayout = screen.layout

            if char == player and char.screenLayout == "finish" then
                startGame()
            end
            
            for j = 1, table.getn(screens) do
                local barrier = screens[j]:getBarrier()
                if barrier then
                    if collisions.checkOverlap(char, barrier) then
                        collisions.resolveCollision(char, barrier, scrollSpeed, dt)
                        break
                    end
                end
            end
        end
    end

    if char == player and char.yPos < 0 then
        startGame()
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
        friend.speed = 120
    else
        friend.speed = 100
    end
end