-- Package: input
-- This package contains functions for getting player input using love.keyboard
input = {}

-- Gets a dictionary containing currently pressed direction keys for determining movement direction
function input.getMovementInput()
    local up = love.keyboard.isDown("w")
    local left = love.keyboard.isDown("a")
    local down = love.keyboard.isDown("s")
    local right = love.keyboard.isDown("d")

    return {up=up, left=left, down=down, right=right}
end

-- Gets the last pressed arrow key for determining selected answer
function love.keypressed(key)
    if key == "down" or key == "up" or key == "left" or key == "right" then
        lastKey = key
   end
end

-- Returns the last pressed arrow key and clears it
function input.getConversationInput()
    local returnKey
    if lastKey then
        returnKey = lastKey
        lastKey = nil
        return returnKey
    end

    return nil
end

-- Clears the last pressed arrow key
function input.resetConversation()
    lastKey = nil
end

return input