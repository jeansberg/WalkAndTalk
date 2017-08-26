-- ##################################################################
-- # Package: conversation.
-- # This package contains code for generating and displaying
-- # questions/statements and answers.
-- ##################################################################

require "input"
require "timer"
require "constants"

local conversation = {}

-- ##################################################################
-- # Paths
-- ##################################################################
local topicsPath = "resources/text/topics.txt"
local fillerPath = "resources/text/filler.txt"
local backgroundImage = love.graphics.newImage("resources/images/background.png")
local rightAnswer = love.audio.newSource("resources/sound/Collect_Point_00.mp3")
local wrongAnswer = love.audio.newSource("resources/sound/Hit_02.mp3")

-- ##################################################################
-- # Constants
-- ##################################################################
local topicRate = 2
local coolDownPeriod = 0.5
local startingTime = 2
local gameOverTime = 3

-- ##################################################################
-- # Variables
-- ##################################################################
local fillerAnswers = {}
local topicStrings = {}
local questionTimerPercent = 100
local attentionPercent = 100

-- ##################################################################
-- # Table for holding a conversation topic.
-- ##################################################################
local Topic = {}

function Topic:new(comment, answer, wrongAnswer1, wrongAnswer2, fillerAnswer, fillerAllowed)
    local o = {
        comment = comment,
        answer = answer,
        wrongAnswer1 = wrongAnswer1,
        wrongAnswer2 = wrongAnswer2,
        fillerAnswer = fillerAnswer,
        fillerAllowed = fillerAllowed
    }

    setmetatable(o, self)
    self.__index = self
    return o
end

-------------------------------------
-- Deep copy implementation from http://lua-users.org/wiki/CopyTable
-- @param the table to copy.
-------------------------------------
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
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

--[[Loads conversation data from disk]]
local function loadData()
    for line in love.filesystem.lines(fillerPath) do
        table.insert(fillerAnswers, line)
    end

    for line in love.filesystem.lines(topicsPath) do
        local topicString = {}
        local wordIterator = string.gmatch(line, "([^;]+)")
        do
            topicString["comment"] = wordIterator()
            topicString["answer"] = wordIterator()
            topicString["fillerAllowed"] = wordIterator()
        end
        table.insert(topicStrings, topicString)
    end
end

-- Updates the attention value without letting it go below 0 or above 100
local function modifyAttention(value)
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

-- Checks the selected answer against the correct answer
-- Returns true if the answer is correct or
-- if the filler answer is selected and filler answers are allowed
local function checkAnswer(selectedAnswer)
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

-------------------------------------
-- Checks if a table contains a value.
-- @param table The table to search.
-- @param element The element to search for.
-------------------------------------
local function tableContains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

-- Returns a random answer from the topics table.
-- excluding answers that have already been selected.
local function getNewAnswer(usedAnswers)
    local answer = ""

    while answer == "" do
        local newAnswer = topicStrings[love.math.random(1, table.getn(topicStrings))]["answer"]
        if not tableContains(usedAnswers, newAnswer) then
            answer = newAnswer
        end
    end

    return answer
end

-- Returns a new Topic instance from the remaining topics list.
local function generateTopic()
    local index = math.random(1, table.getn(remainingTopics))
    local newTopic = remainingTopics[index]
    local fillerAnswer = fillerAnswers[love.math.random(1, table.getn(fillerAnswers))]
    local wrongAnswer1 = getNewAnswer({newTopic["answer"]})
    local wrongAnswer2 = getNewAnswer({newTopic["answer"], wrongAnswer1})
    local topic =
        Topic:new(
        newTopic["comment"],
        newTopic["answer"],
        wrongAnswer1,
        wrongAnswer2,
        fillerAnswer,
        newTopic["fillerAllowed"]
    )

    table.remove(remainingTopics, index)
    return topic
end

-- Gets a new topic and randomly assigns answers to positions
local function getNewTopic()
    newTopicCallback()
    topic = generateTopic()

    local answers = {topic["answer"], topic["wrongAnswer1"], topic["wrongAnswer2"]}

    comment = topic["comment"]
    topPosition = conversation.popRandom(answers)
    rightPosition = conversation.popRandom(answers)
    bottomPosition = answers[1]
    leftPosition = topic["fillerAnswer"]

    state = questionState
end


local function failAnswer()
    love.audio.rewind(wrongAnswer)
    love.audio.play(wrongAnswer)
    modifyAttention(-34)
end

-- ##################################################################
-- # State machine
-- ##################################################################

local StateMachine = {}
local State = {}

function State:new(timer)
    local o = {timer = timer}
    setmetatable(o, self)
    self.__index = self
    return o
end

function State:updateTimer(dt)
    local done = self.timer:update(dt)
    return done
end

function setState(newState)
    state = newState
end

-- The question state counts down the question timer, which triggers a "failed question" state if not interrupted
State.QuestionState = State:new(timer)

function State.QuestionState:update(dt)
    local selectedAnswer = input.getConversationInput()

    if selectedAnswer then
        if checkAnswer(selectedAnswer) then
            love.audio.rewind(rightAnswer)
            love.audio.play(rightAnswer)
        else
            failAnswer()
        end
        setState(State.CoolDownState:new(timer.Timer:new(coolDownPeriod)))
    else
        if (self.timer:update(dt)) then
            failAnswer()
            setState(State.CoolDownState:new(timer.Timer:new(coolDownPeriod)))
        end
        updateQuestionTimer(self.timer.currentTime)
    end
end

-- The cooldown state counts down the cooldown timer, which triggers a new question and transfers control to the question state
State.CoolDownState = State:new(timer)

function State.CoolDownState:update(dt)
    if (self:updateTimer(dt)) then
        getNewTopic()
        input.resetConversation()
        setState(State.QuestionState:new(timer.Timer:new(topicRate)))
    end
end

State.StoppedState = State:new(timer)

function State.StoppedState:update(dt)

end

-------------------------------------
-- Removes and returns a random value from a table.
-- @param t The table to look in.
-------------------------------------
function conversation.popRandom(t)
    random = love.math.random(1, table.getn(t))
    local value = t[random]
    table.remove(t, random)
    return value
end

--[[Initializes the conversation engine, with callback functions for notifying
when a new topic is generated and when an answer is chosen]]
function conversation.init(_newTopicCallback, _answerCallback, _loseCallback)
    newTopicCallback = _newTopicCallback
    answerCallback = _answerCallback
    loseCallback = _loseCallback
    loadData()
end

--[[Resets the conversation engine.]]
function conversation.reset(comment)
    -- Make sure questions are not in the same order
    math.randomseed(os.time())

    finalComment = comment
    remainingTopics = deepcopy(topicStrings)
    comment = ""
    attentionPercent = 100
    questionTimerPercent = 0

    setState(State.CoolDownState:new(timer.Timer:new(startingTime)))
end

--[[Updates the state of the conversation engine.]]
function conversation.update(dt)
    state:update(dt)

    if table.getn(remainingTopics) == 0 then
        remainingTopics = deepcopy(topicStrings)
    end
end

-- Draws boxes around answers
local function drawBoxes()
    love.graphics.rectangle("line", 510, 200, 180, 60)
    love.graphics.rectangle("line", 610, 300, 180, 60)
    love.graphics.rectangle("line", 510, 400, 180, 60)
    love.graphics.rectangle("line", 410, 300, 180, 60)
end

-- Draws the background image
local function drawBackground()
    love.graphics.draw(backgroundImage, 400, 0)
end

-- Draws the timer and attention meters
local function drawMeters()
    if attentionPercent > 0 then
        love.graphics.setColor(26, 99, 24, 255)
        love.graphics.rectangle("fill", 400, 565, attentionPercent * 4, 25)
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

-- Draws the current topic and the rest of the conversation UI.
function conversation.draw()
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

-- Interrupts the conversation to show a comment
-- depending on the game state that was reached
function conversation.interrupt(gameState)
    setState(State.StoppedState:new())
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

return conversation