-- Package: collisions
-- This package contains functions for detecting and resolving collisions

local P = {}
collisions = P
setfenv(1, P)

function checkOverlap(rect1, rect2)
    if not (rect1 and rect2) then
        return false
    end

    if  rect1.xPos < rect2.xPos and rect1.xPos + rect1.width > rect2.xPos and
        rect1.yPos < rect2.yPos and rect1.yPos + rect1.height > rect2.yPos then
        return true
    elseif rect2.xPos < rect1.xPos and rect2.xPos + rect2.width > rect1.xPos and
            rect2.yPos < rect1.yPos and rect2.yPos + rect2.height > rect1.yPos then
        return true
    else
        return false
    end
end

function resolveWallCollision(char, wall, scrollSpeed)
    if char.dx > 0 then
        char.xPos = wall.xPos - char.width
    elseif char.dx < 0 then
        char.xPos = wall.xPos + wall.width
    end

    if char.dy > scrollSpeed then
        char.yPos = wall.yPos - char.height
    elseif char.dy < -scrollSpeed then
        char.yPos = wall.yPos + wall.height
    end
end