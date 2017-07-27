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
setfenv(1, P)

-- Constants
topicsPath = "resources/text/topics.txt"
fillerPath = "resources/text/filler.txt"

-------------------------------------
-- Table for holding a conversation topic.
-------------------------------------
Topic = {}

function Topic:new (o)
    o = o or {}
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
    failures = 0
    timer = topicRate
    remainingTopics = deepcopy(topics)
end

-------------------------------------
-- Updates the state of the conversation engine.
-- @param dt Time passed in seconds since the last update call.
-------------------------------------
function update(dt)
    if table.getn(remainingTopics) == 0 then
        bottomPosition = ""
        topPosition = ""
        rightPosition = ""
        leftPosition = ""
        comment = ""

        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.rectangle("fill", 400, 0, 400, 600)
        love.graphics.setColor(255, 255, 255, 255)
        return true
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
        print("Return false")
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
    if topic then
        love.graphics.printf(comment, 500, 50, 200)

        love.graphics.printf(topPosition, 510, 200, 180)
        love.graphics.printf(rightPosition, 610, 300, 180)
        love.graphics.printf(bottomPosition, 510, 400, 180)
        love.graphics.printf(leftPosition, 410, 300, 180)
    end
end

-------------------------------------
-- Returns a new Topic instance from the remaining topics list.
-------------------------------------
function generateTopic()
    local index = love.math.random(1, table.getn(remainingTopics))
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
        print("getting new answer")
        local newAnswer = topics[love.math.random(1, table.getn(topics))]["answer"]
        if not tableContains(usedAnswers, newAnswer) then
            answer = newAnswer
        end
    end

    return answer
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
