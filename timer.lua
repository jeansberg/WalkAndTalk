-- Package: timer.
-- This package contains code for creating timers.
local P = {}
timer = P

-- Imports
local setmetatable = setmetatable
local print = print
setfenv(1, P)
--

Timer = {running = true}

function Timer:new(period)
    local o = {period = period, currentTime = period}
    setmetatable(o, self)
    self.__index = self
    print(o.currentTime)
    return o
end

function Timer:reset()
    self.running = false
    self.currentTime = 0
end

function Timer:update(dt)
    if not self.running then
        return false
    end

    self.currentTime = self.currentTime - dt

    if self.currentTime <= 0 then
        self:reset()
        return true
    end

    return false
end