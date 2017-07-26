-- Package: conversation.
-- This package contains code for generating and displaying questions/statements and answers.
require "input"
local P = {}
conversation = P

-- Imports
local love = love
local table = table
local setmetatable = setmetatable
local pairs = pairs
local next = next
local string = string
local print = print
local input = input
setfenv(1, P)

-- Constants
topicsPath = "resources/text/topics.txt"
fillerPath = "resources/text/filler.txt"

Topic = {}

function Topic:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-------------------------------------
-- Initializes the conversation engine.
-- @param conversationRate The rate at which new questions are generated.
-------------------------------------
function init(conversationRate)
    rate = conversationRate
    timer = rate

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

    remainingTopics = topics
end

-------------------------------------
-- Resets the conversation engine.
-------------------------------------
function reset()
    timer = rate
    remainingTopics = topics
end

-------------------------------------
-- Updates the state of the conversation engine.
-- @param dt Time passed in seconds since the last update call.
-------------------------------------
function update(dt)
    if table.getn(remainingTopics) == 0 then
        return
    end

    local selectedAnswer = input.getConversationInput()
    if selectedAnswer then
        updateTopic()
    end

    if timer > 0 then
        timer = timer - dt
    else
        updateTopic()
    end
end

function updateTopic()
    topic = generateTopic()
    local answers = {topic["answer"], topic["wrongAnswer1"], topic["wrongAnswer2"]}
    
    answer1 = popRandom(answers)
    answer2 = popRandom(answers)
    answer3 = answers[1]

    timer = rate
end

-------------------------------------
-- Draws the current topic and the rest of the conversation UI.
-------------------------------------
function draw()
    if topic then
        love.graphics.printf(topic["comment"], 500, 50, 200)

        love.graphics.printf(answer1, 510, 200, 180)
        love.graphics.printf(answer2, 610, 300, 180)
        love.graphics.printf(answer3, 510, 400, 180)
        love.graphics.printf(topic["fillerAnswer"], 410, 300, 180)
    end
end

-------------------------------------
-- Returns a new Topic instance.
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
        local newAnswer = topics[love.math.random(1, table.getn(topics))]["answer"]
        if not tableContains(usedAnswers, newAnswer) then
            answer = newAnswer
        end
    end

    return answer
end

-------------------------------------
-- Checks if a table contains a value
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

function popRandom(t)
    random = love.math.random(1, table.getn(t))
    value = t[random]
    table.remove(t, random)
    return value
end