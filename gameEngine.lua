-- ##################################################################
-- # Package: Game Engine
-- # This package initializes and controls the game through the
-- # conversation and walking engines. 
-- ##################################################################
local conversation = require "conversation"
local walking = require "walking"
local sounds = require "resources".sounds

local gameEngine = {}

-- ##################################################################
-- # Callback functions used by the conversation engine
-- ##################################################################
local function onNewTopic()
    walking.sendMessage("NewTopic")
end

local function onAnswer()
    walking.sendMessage("TopicAnswered")
end

local function onLose()
    walking.sendMessage("TopicFailed")
end

local function onGameEnd(gameState)
    conversation.interrupt(gameState)
end

-- ##################################################################
-- # Starts a new game
-- ##################################################################
local function startGame()
    sounds.music:setVolume(0.5)
    love.audio.rewind(sounds.music)
    love.audio.play(sounds.music)
    conversation.reset("Get ready!")
    walking.reset()
end

-- ##################################################################
-- # Initializes the game engine. This is called when the app
-- # is started.
-- ##################################################################
function gameEngine.init()
    walking.init(onGameEnd)
    conversation.init(onNewTopic, onAnswer, onLose)
    startGame()
end

-- ##################################################################
-- # Updates the state of the walking and conversation engines.
-- ##################################################################
function gameEngine.update(dt)
    walking.update(dt, startGame)
    conversation.update(dt)
end

-- ##################################################################
-- # Draws the objects from the walking and conversation engines.
-- ##################################################################
function gameEngine.draw()
    walking.draw()
    conversation.draw()
end

return gameEngine