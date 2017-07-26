-- Package: collisions
-- This package contains functions for detecting and resolving collisions

local P = {}
collisions = P
setfenv(1, P)

function checkCollision(player, wall)
    if not (player and wall) then
        return false
    end

    if  player.xPos < wall.xPos and player.xPos + player.width > wall.xPos and
        player.yPos > wall.yPos and player.yPos + player.height < wall.yPos + wall.height then
        return true
    elseif wall.xPos < player.xPos and wall.xPos + wall.width > player.xPos and
            wall.yPos < player.yPos + player.height and wall.yPos + wall.height > player.yPos then
        return true
    else
        return false
    end
end

function resolveWallCollision(player, wall, scrollSpeed)
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