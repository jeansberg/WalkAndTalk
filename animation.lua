-- Package: animation
-- This package contains the Animation table used to update the current animation frame

local P = {}
animation = P

-- Imports
local math = math
local print = print
local setmetatable = setmetatable
setfenv(1, P)

Animation = {}

function Animation:new(timerMax, startFrame, endFrame)
    local o = {timerMax = timerMax, startFrame = startFrame, endFrame = endFrame}
    setmetatable(o, self)
    self.__index = self
    o.currentFrame = startFrame
    o.timer = 0
    return o
end

-- Resets the animation frame and timer value
function Animation:reset()
    self.currentFrame = self.startFrame
    self.timer = 0
end

-- Updates the animation frame based on delta time and the animation timer
function Animation:update(dt)
    -- The animation is static
    if self.timerMax == 0 then
        return
    end

    local overFlow = 0
    local dFrames = 0
    if dt > self.timerMax then
        overFlow = dt - self.timerMax
        dFrames = math.floor(overFlow)
        self.timer = self.timer + overFlow - dFrames
    else
        self.timer = self.timer + dt
    end

    if self.timer < self.timerMax and dFrames == 0 then
        return
    else
        self:incrementFrame(dFrames)
        self.timer = overFlow - dFrames
    end
end

-- Increments the current frame
function Animation:incrementFrame(dFrame)
    local logicalFrame = self.currentFrame + dFrame

    if logicalFrame >= self.endFrame then
        self.currentFrame = self.startFrame + (logicalFrame % self.endFrame) 
    else
        self.currentFrame = self.currentFrame + 1
    end
end