local gameEngine = require("gameEngine")

function love.load()
    -- For ZeroBrane Studio
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end
    --

    gameEngine.init()
end

function love.draw()
    gameEngine.draw()
end

function love.update(dt)
    gameEngine.update(dt)
end