-- Package: animation
-- This package contains the Animation table used to determine the current animation frame

local P = {}
animation = P

-- Imports
local print = print
local setmetatable = setmetatable
setfenv(1, P)

Animation = {timer = 0}

function Animation:new(timerMax, startFrame, endFrame)
    local o = {timerMax = timerMax, startFrame = startFrame, endFrame = endFrame}
    setmetatable(o, self)
    self.__index = self
    o.currentFrame = startFrame
    o.timer = 0
    return o
end

function Animation:reset()
    self.currentFrame = self.startFrame
    self.timer = 0
end

function Animation:update(dt)
    if self.timerMax == 0 then
        return
    end

    if self.timer < self.timerMax then
        self.timer = self.timer + dt
        return
    end

    if self.currentFrame == self.endFrame then
        self.currentFrame = self.startFrame
    else
        self.currentFrame = self.currentFrame + 1
    end
    self.timer = 0
end