-- Package: input
-- This package contains functions for getting player input using love.keyboard
local P = {}
input = P

-- Imports
local love = love
setfenv(1, P)

function getMovementInput()
    local up = love.keyboard.isDown("w")
    local left = love.keyboard.isDown("a")
    local down = love.keyboard.isDown("s")
    local right = love.keyboard.isDown("d")

    return {up=up, left=left, down=down, right=right}
end


function love.keypressed(key)
    if key == "down" or key == "up" or key == "left" or key == "right" then
        lastKey = key
   end
end

function getConversationInput()
    local returnKey
    if lastKey then
        returnKey = lastKey
        lastKey = nil
        return returnKey
    end

    return nil
end

function resetConversation()
    lastKey = nil
end