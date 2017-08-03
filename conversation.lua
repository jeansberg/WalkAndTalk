-- Package: conversation.
-- This package contains code for generating and displaying questions/statements and answers.
require "input"
local P = {}
conversation = P

-- Imports
local love = love
local table = table
local getmetatable = getmetatable
local setmetatable = setmetatable
local pairs = pairs
local next = next
local string = string
local print = print
local input = input
local type = type
local math = math
local os = os
setfenv(1, P)

-- Constants
topicsPath = "resources/text/topics.txt"
fillerPath = "resources/text/filler.txt"
backgroundImage = love.graphics.newImage("resources/images/background.png")

-------------------------------------
-- Table for holding a conversation topic.
-------------------------------------
Topic = {}

function Topic:new (o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-------------------------------------
-- Initializes the conversation engine.
-- @param rate The rate at which new questions are generated.
-------------------------------------
function init(rate, _maxFailures)
    topicRate = rate or 5
    maxFailures = _maxFailures or 3

    fillerAnswers = {}
    for line in love.filesystem.lines(fillerPath) do
        table.insert(fillerAnswers, line)
    end

    topics = {}
    for line in love.filesystem.lines(topicsPath) do
        local topic = {}
            wordIterator = string.gmatch(line, '([^;]+)') do
            topic["comment"] = wordIterator()
            topic["answer"] = wordIterator()
            topic["fillerAllowed"] = wordIterator()
        end
        table.insert(topics, topic)
    end
end

-------------------------------------
-- Resets the conversation engine.
-------------------------------------
function reset()
    math.randomseed(os.time())
    failures = 0
    timer = topicRate
    remainingTopics = deepcopy(topics)
    comment = ""
    finalComment = ""
end

-------------------------------------
-- Updates the state of the conversation engine.
-- @param dt Time passed in seconds since the last update call.
-------------------------------------
function update(dt)
    if table.getn(remainingTopics) == 0 then
        remainingTopics = deepcopy(topics)
    end

    if timer > 0 then
        timer = timer - dt
    elseif topic then
        failures = failures + 1
        updateTopic()
    else
        updateTopic()
    end

    if not topic then
        return true
    end

    local selectedAnswer = input.getConversationInput()

    if selectedAnswer then
        if not checkAnswer(selectedAnswer) then
            failures = failures + 1
        end
        updateTopic()
    end

    if failures == maxFailures then
        return false
    end

    return true
end

-------------------------------------
-- Gets a new topic and randomly assigns answers to positions
-------------------------------------
function updateTopic()
    topic = generateTopic()
    local answers = {topic["answer"], topic["wrongAnswer1"], topic["wrongAnswer2"]}
    
    comment = topic["comment"]
    topPosition = popRandom(answers)
    rightPosition = popRandom(answers)
    bottomPosition = answers[1]
    leftPosition = topic["fillerAnswer"]

    timer = topicRate
end

function checkAnswer(selectedAnswer)
    if selectedAnswer == "up" then
        return topic["answer"] == topPosition
    elseif selectedAnswer == "down" then
        return topic["answer"] == bottomPosition
    elseif selectedAnswer == "left" then
        return topic["fillerAllowed"]
    elseif selectedAnswer == "right" then
        return topic["answer"] == rightPosition
    end

    return false
end

-------------------------------------
-- Draws the current topic and the rest of the conversation UI.
-------------------------------------
function draw()
    drawBackground()
    

    if topic then
        drawBoxes()
        
        love.graphics.setNewFont(20)
        love.graphics.printf(comment, 500, 50, 200, "center")
        love.graphics.setNewFont(14)
        love.graphics.printf(topPosition, 515, 205, 175, "center")
        love.graphics.printf(rightPosition, 615, 305, 175, "center")
        love.graphics.printf(bottomPosition, 515, 405, 175, "center")
        love.graphics.printf(leftPosition, 415, 305, 175, "center")
    else
        love.graphics.setNewFont(20)
        love.graphics.printf(finalComment, 500, 50, 200, center)
    end
end

-------------------------------------
-- Returns a new Topic instance from the remaining topics list.
-------------------------------------
function generateTopic()
    local index = math.random(1, table.getn(remainingTopics))
    local newTopic = remainingTopics[index]
    local fillerAnswer = fillerAnswers[love.math.random(1, table.getn(fillerAnswers))]
    local wrongAnswer1 = getNewAnswer({newTopic["answer"]})
    local wrongAnswer2 = getNewAnswer({newTopic["answer"], wrongAnswer1})
    local topic = {comment = newTopic["comment"], 
        answer = newTopic["answer"],
        wrongAnswer1 = wrongAnswer1,
        wrongAnswer2 = wrongAnswer2, 
        fillerAnswer = fillerAnswer, 
        fillerAllowed = newTopic["fillerAllowed"]}
    
    table.remove(remainingTopics, index)

    return topic
end

-------------------------------------
-- Returns a random answer from the topics table.
-- @param usedAnswers A table of answers that will be excluded.
-------------------------------------
function getNewAnswer(usedAnswers)
    local answer = ""
    
    while answer == "" do
        local newAnswer = topics[love.math.random(1, table.getn(topics))]["answer"]
        if not tableContains(usedAnswers, newAnswer) then
            answer = newAnswer
        end
    end

    return answer
end

function interrupt(gameState)
    topic = nil
    if gameState == "WrongAnswer" then
        finalComment = "You're not listening! Will you please stop daydreaming?"
    elseif gameState == "NearMiss" then
        finalComment = "Watch out! You're always dreaming!"
    elseif gameState == "EatenByScroll" then
        finalComment = "Catch up! Stop daydreaming!"
    elseif gameState == "Finished" then
        finalComment = "We're here. Thank you for the company!"
    end
    comment = ""
    topPosition = ""
    rightPosition = ""
    bottomPosition = ""
    leftPosition = ""
end

-------------------------------------
-- Checks if a table contains a value.
-- @param table The table to search.
-- @param element The element to search for.
-------------------------------------
function tableContains(t, element)
  for _, value in pairs(t) do
    if value == element then
      return true
    end
  end
  return false
end

-------------------------------------
-- Removes and returns a random value from a table.
-- @param t The table to look in.
-------------------------------------
function popRandom(t)
    random = love.math.random(1, table.getn(t))
    value = t[random]
    table.remove(t, random)
    return value
end

-------------------------------------
-- Deep copy implementation from http://lua-users.org/wiki/CopyTable
-- @param the table to copy.
-------------------------------------
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function drawBoxes()
    love.graphics.rectangle("line", 510, 200, 180, 60)
    love.graphics.rectangle("line", 610, 300, 180, 60)
    love.graphics.rectangle("line", 510, 400, 180, 60)
    love.graphics.rectangle("line", 410, 300, 180, 60)
end

function drawBackground()
    love.graphics.draw(backgroundImage, 400, 0)
end