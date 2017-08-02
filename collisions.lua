-- Package: collisions
-- This package contains functions for detecting and resolving collisions

local P = {}
collisions = P

-- Imports
local print = print
setfenv(1, P)

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

function resolveCollision(rect1, rect2, scrollSpeed, dt)
    if rect1.dx > 0 then
        -- Moving right
        rect1.xPos = rect2.xPos - rect1.width
        return
    elseif rect1.dx < 0 then
        -- Moving left
        rect1.xPos = rect2.xPos + rect2.width
        return
    end

    if rect1.dy > 0  then
        -- Moving down
        rect1.yPos = rect2.yPos - rect1.height
    elseif rect1.dy < -scrollSpeed then
        -- Moving up
        rect1.yPos = rect2.yPos + rect2.height
  end
end