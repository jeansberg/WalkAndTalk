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
screenHeight = love.graphics.getHeight()
playerSpeed = 120
friendSpeed = 100
scrollSpeed = 100
numScreens = 5
frameSide = 32
playerStartX = 3/4 * walkingScreenWidth - frameSide * 2
playerStartY = screenHeight/4 - frameSide / 2
friendStartX = 3/4 * walkingScreenWidth
friendStartY = screenHeight/4


function love.load()
    playerImage = love.graphics.newImage("resources/images/player.png")
    friendImage = love.graphics.newImage("resources/images/friend.png")
    imageWidth = playerImage:getWidth()
    imageHeight = playerImage:getHeight()

    local playerFrames = spriteSheet.SpriteSheet:new{imageWidth = imageWidth, imageHeight = imageHeight, frameSide = frameSide, numFrames = 3}
    local friendFrames = playerFrames

    local charAnimations = {standing = animation.Animation:new(0, 1, 1), walking = animation.Animation:new(0.2, 2, 3)}

    player = character.Character:new{xPos = playerStartX, yPos = playerStartY, speed = playerSpeed, animations = charAnimations, frames = playerFrames, image = playerImage}
    friend = character.Character:new{xPos = friendStartX, yPos = friendStartY, speed = friendSpeed, animations = charAnimations, frames = friendFrames, image = friendImage}
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
    --print(player.currentAnimation)
    --print(#player.frames)
    love.graphics.draw(player.image, player.frames[player.animations[player.currentAnimation].currentFrame], player.xPos, player.yPos)
    love.graphics.draw(friend.image, friend.frames[friend.animations[friend.currentAnimation].currentFrame], friend.xPos, friend.yPos)

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

    player.animations[player.currentAnimation]:update(dt)

    if not (up or left or down or right) then
        player:setAnimation("standing")
        return
    end

    player:setAnimation("walking")

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