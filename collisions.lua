-- Package: collisions
-- This package contains functions for detecting and resolving collisions

local P = {}
collisions = P

-- Imports
local print = print
setfenv(1, P)

-- Checks if two rectangles overlap
-- Returns false if either of the rectangles is nil
function checkOverlap(rect1, rect2)
    if not (rect1 and rect2) then
        return false
    end
    if  ((rect1.xPos < rect2.xPos and rect1.xPos + rect1.width > rect2.xPos) or 
        (rect1.xPos > rect2.xPos and rect1.xPos + rect1.width < rect2.xPos + rect2.width) or 
        (rect1.xPos < rect2.xPos + rect2.width and rect1.xPos + rect1.width > rect2.xPos + rect2.width)) and
        ((rect1.yPos < rect2.yPos and rect1.yPos + rect1.height > rect2.yPos) or 
        (rect1.yPos > rect2.yPos and rect1.yPos + rect1.height < rect2.yPos + rect2.width) or
        (rect1.yPos < rect2.yPos + rect2.height and rect1.yPos + rect2.height > rect2.yPos + rect2.height)) then

        return true
    else
        return false
    end
end

-- Resolves a collision between two rectangles by moving
-- the first one back based on its speed
function resolveCollision(rect1, rect2, dt)
    rect2.dx = rect2.dx or 0
    rect2.dy = rect2.dy or 0
    if rect1.dx - rect2.dx > 0 then
        -- Moving right
        local destX = rect2.xPos - rect1.width
        if rect1.xPos - destX < 2 then
            rect1.xPos = destX
        end
    elseif rect1.dx - rect2.dx < 0 then
        -- Moving left
        local destX = rect2.xPos + rect2.width
        if destX - rect1.xPos < 2 then
            rect1.xPos = destX
        end
    end

    if rect1.dy - rect2.dy > 0  then
        -- Moving down
        local destY = rect2.yPos - rect1.height
        if rect1.yPos - destY < 2 then
            rect1.yPos = destY
        end
    elseif rect1.dy - rect2.dy < 0 then
        -- Moving up
        local destY = rect2.yPos + rect2.height
        if destY - rect1.yPos < 2 then
            rect1.yPos = rect2.yPos + rect2.height
        end
  end
end