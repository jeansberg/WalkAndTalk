-- Package: conversation.
-- This package contains code for generating and displaying questions/statements and answers.
local P = {}
conversation = P

-- Imports
require "input"
require "timer"

local love = love
local table = table
local getmetatable = getmetatable
local setmetatable = setmetatable
local pairs = pairs
local next = next
local string = string
local input = input
local timer = timer
local type = type
local math = math
local os = os
local print = print
setfenv(1, P)
--

-- Paths
local topicsPath = "resources/text/topics.txt"
local fillerPath = "resources/text/filler.txt"
local backgroundImage = love.graphics.newImage("resources/images/background.png")
local rightAnswer = love.audio.newSource("resources/sound/Collect_Point_00.mp3")
local wrongAnswer = love.audio.newSource("resources/sound/Hit_02.mp3")

-- Constants
local topicRate = 2
local coolDownPeriod = 0.5
local startingTime = 2
local gameOverTime = 3

-- Variables
local fillerAnswers = {}
local topicStrings = {}
local questionTimerPercent = 100
local attentionPercent = 100

-- Table for holding a conversation topic.
local Topic = {}

function Topic:new(comment, answer, wrongAnswer1, wrongAnswer2, fillerAnswer, fillerAllowed)
    local o =
    {comment = comment, answer = answer, 
    wrongAnswer1 = wrongAnswer1, wrongAnswer2 = wrongAnswer2,
    fillerAnswer = fillerAnswer, fillerAllowed = fillerAllowed}

    setmetatable(o, self)
    self.__index = self
    return o
end

-- Initializes the conversation engine, with callback functions for notifying
-- when a new topic is generated and when an answer is chosen
function init(_newTopicCallback, _answerCallback, _loseCallback)
    newTopicCallback = _newTopicCallback
    answerCallback = _answerCallback
    loseCallback = _loseCallback
    loadData()
end

function loadData()
    -- Load filler answers from file
    for line in love.filesystem.lines(fillerPath) do
        table.insert(fillerAnswers, line)
    end

    -- Load topics from file
    for line in love.filesystem.lines(topicsPath) do
        local topicString = {}
            local wordIterator = string.gmatch(line, '([^;]+)') do
            topicString["comment"] = wordIterator()
            topicString["answer"] = wordIterator()
            topicString["fillerAllowed"] = wordIterator()
        end
        table.insert(topicStrings, topicString)
    end
end

-- Resets the conversation engine.
function reset()
    math.randomseed(os.time())
    
    remainingTopics = deepcopy(topicStrings)
    comment = ""
    finalComment = "Get ready!"
    attentionPercent = 100
    questionTimerPercent = 0

    setState(CoolDownState:new(timer.Timer:new(startingTime)))
end

-- Updates the state of the conversation engine.
function update(dt)
    state:update(dt)

    if table.getn(remainingTopics) == 0 then
        remainingTopics = deepcopy(topicStrings)
    end
end

-- Gets a new topic and randomly assigns answers to positions
function getNewTopic()
    newTopicCallback()
    topic = generateTopic()

    local answers = {topic["answer"], topic["wrongAnswer1"], topic["wrongAnswer2"]}

    comment = topic["comment"]
    topPosition = popRandom(answers)
    rightPosition = popRandom(answers)
    bottomPosition = answers[1]
    leftPosition = topic["fillerAnswer"]

    state = questionState
end

function failAnswer()
    love.audio.rewind(wrongAnswer)
    love.audio.play(wrongAnswer)
    modifyAttention(-34)
end

-- Checks the selected answer against the correct answer
-- Returns true if the answer is correct or
-- if the filler answer is selected and filler answers are allowed
function checkAnswer(selectedAnswer)
    answerCallback()

    if selectedAnswer == "up" and topic["answer"] == topPosition then
            modifyAttention(17)
            return true
    elseif selectedAnswer == "down" and topic["answer"] == bottomPosition then
            modifyAttention(17)
            return true 
    elseif selectedAnswer == "left" and topic["fillerAllowed"] == "true" then
            return true 
    elseif selectedAnswer == "right" and topic["answer"] == rightPosition then
            modifyAttention(17)
            return true 
    end

    return false
end

-- Draws the current topic and the rest of the conversation UI.
function draw()
    drawBackground()
    drawMeters()

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
        love.graphics.printf(finalComment, 500, 50, 200, "center")
    end
end

-- Returns a new Topic instance from the remaining topics list.
function generateTopic()
    local index = math.random(1, table.getn(remainingTopics))
    local newTopic = remainingTopics[index]
    local fillerAnswer = fillerAnswers[love.math.random(1, table.getn(fillerAnswers))]
    local wrongAnswer1 = getNewAnswer({newTopic["answer"]})
    local wrongAnswer2 = getNewAnswer({newTopic["answer"], wrongAnswer1})
    local topic = Topic:new(newTopic["comment"], 
        newTopic["answer"],
        wrongAnswer1,
        wrongAnswer2, 
        fillerAnswer, 
        newTopic["fillerAllowed"])
    
    table.remove(remainingTopics, index)
    return topic
end

-- Returns a random answer from the topics table.
-- excluding answers that have already been selected.
function getNewAnswer(usedAnswers)
    local answer = ""
    
    while answer == "" do
        local newAnswer = topicStrings[love.math.random(1, table.getn(topicStrings))]["answer"]
        if not tableContains(usedAnswers, newAnswer) then
            answer = newAnswer
        end
    end

    return answer
end

-- Interrupts the conversation to show a comment
-- depending on the game state that was reached
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
    local value = t[random]
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

-- Draws boxes around answers
function drawBoxes()
    love.graphics.rectangle("line", 510, 200, 180, 60)
    love.graphics.rectangle("line", 610, 300, 180, 60)
    love.graphics.rectangle("line", 510, 400, 180, 60)
    love.graphics.rectangle("line", 410, 300, 180, 60)
end

-- Draws the background image
function drawBackground()
    love.graphics.draw(backgroundImage, 400, 0)
end

-- Draws the timer and attention meters
function drawMeters()
    if attentionPercent > 0 then
        love.graphics.setColor(26, 99, 24, 255)
        love.graphics.rectangle("fill", 400, 565, attentionPercent*4, 25)
    end

    if questionTimerPercent > 0 then
        love.graphics.setColor(190, 52, 58, 255)
        love.graphics.rectangle("fill", 400, 530, questionTimerPercent * 400, 25)
    end

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setNewFont(14)
    love.graphics.printf("Timer", 400, 535, 400, "center")
    love.graphics.printf("Attention", 400, 570, 400, "center")
end

-- Updates the attention value without letting it go below 0 or above 100
function modifyAttention(value)
    if value > 0 then
        attentionPercent = math.min(attentionPercent + value, 100)
    elseif value < 0 then
        attentionPercent = math.max(attentionPercent + value, 0)
    end

    if attentionPercent == 0 then
        loseCallback()
    end
end

function updateQuestionTimer(value)
    questionTimerPercent = value / topicRate
end

-- ##################################################################
-- # State machine
-- ##################################################################

State = {}

function State:new(timer)
    local o = {timer = timer}
    setmetatable(o, self)
    self.__index = self
    return o
end

function State:updateTimer(dt)
    local done = self.timer:update(dt)
    print("Done: " , done)
    return done
end

-- The question state counts down the question timer, which triggers a failed question state if not interrupted
QuestionState = State:new(timer)

function QuestionState:update(dt)
    local selectedAnswer = input.getConversationInput()

    if selectedAnswer then 
        if checkAnswer(selectedAnswer) then
            love.audio.rewind(rightAnswer)
            love.audio.play(rightAnswer)
        else
            failAnswer()
        end
        setState(CoolDownState:new(timer.Timer:new(coolDownPeriod)))
    else
        if(self.timer:update(dt)) then
            failAnswer()
            setState(CoolDownState:new(timer.Timer:new(coolDownPeriod)))
        end
        updateQuestionTimer(self.timer.currentTime)
    end
end

-- The cooldown state counts down the cooldown timer, which triggers a new question and transfers control to the question state
CoolDownState = State:new(timer)

function CoolDownState:update(dt)
    if(self:updateTimer(dt)) then
        getNewTopic()
        setState(QuestionState:new(timer.Timer:new(topicRate)))
    end
end

-- The gameOver state counts down the gameOver timer, which resets the conversation engine
GameOverState = State:new(timer)

function GameOverState:update(dt)
    print("Game over\n")
    if(timer:update(dt)) then
        reset()
    end
end

function setState(newState)
    print("Setting state")
    state = newState
end