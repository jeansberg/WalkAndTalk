-- Package: collisions
-- This package contains functions for detecting and resolving collisions

local collisions = {}

-- Checks if two rectangles overlap
-- Returns false if either of the rectangles is nil
function collisions.checkOverlap(rect1, rect2)
    if not (rect1 and rect2) then
        return false
    end

    local r1 = rect1
    local r2 = rect2

    if
        ((r1.xPos < r2.xPos and r1.xPos + r1.width > r2.xPos) or
            (r1.xPos > r2.xPos and r1.xPos + r1.width < r2.xPos + r2.width) or
            (r1.xPos < r2.xPos + r2.width and r1.xPos + r1.width > r2.xPos + r2.width)) and
            ((r1.yPos < r2.yPos and r1.yPos + r1.height > r2.yPos) or
                (r1.yPos > r2.yPos and r1.yPos + r1.height < r2.yPos + r2.width) or
                (r1.yPos < r2.yPos + r2.height and r1.yPos + r2.height > r2.yPos + r2.height))
     then
        return true
    else
        return false
    end
end

-- Resolves a collision between two rectangles by moving
-- the first one back based on its speed
function collisions.resolveCollision(rect1, rect2, dt)
    rect2.dx = rect2.dx or 0
    rect2.dy = rect2.dy or 0
    if rect1.dx - rect2.dx > 0 then
        -- Moving right
        local destX = rect2.xPos - rect1.width
        if rect1.xPos - destX < 4 then
            rect1.xPos = destX
        end
    elseif rect1.dx - rect2.dx < 0 then
        -- Moving left
        local destX = rect2.xPos + rect2.width
        if destX - rect1.xPos < 4 then
            rect1.xPos = destX
        end
    end

    if rect1.dy - rect2.dy > 0 then
        -- Moving down
        local destY = rect2.yPos - rect1.height
        if rect1.yPos - destY < 4 then
            rect1.yPos = destY
        end
    elseif rect1.dy - rect2.dy < 0 then
        -- Moving up
        local destY = rect2.yPos + rect2.height
        if destY - rect1.yPos < 4 then
            rect1.yPos = rect2.yPos + rect2.height
        end
    end
end

return collisions
