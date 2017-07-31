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
<<<<<<< HEAD
    o.currentFrame = startFrame
    o.timer = 0
=======
    self.currentFrame = startFrame
    self.timer = 0
>>>>>>> Work on animation functions
    return o
end

function Animation:reset()
<<<<<<< HEAD
    self.currentFrame = self.startFrame
=======
    self.currentFrame = startFrame
>>>>>>> Work on animation functions
    self.timer = 0
end

function Animation:update(dt)
    if self.timerMax == 0 then
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Finishes friend movement code
        --print("static " .. self.currentFrame)
        return
    end

    
=======
        print(self.currentFrame)
        return
    end

>>>>>>> Work on animation functions
    if self.timer < self.timerMax then
        self.timer = self.timer + dt
    else
        if self.currentFrame == self.endFrame then
<<<<<<< HEAD
            self.currentFrame = self.startFrame
=======
            self.currentFrame = startFrame
>>>>>>> Work on animation functions
        else
            self.currentFrame = self.currentFrame + 1
        end
        self.timer = 0
    end
<<<<<<< HEAD
<<<<<<< HEAD
   --print("walking " .. self.currentFrame)
=======
    print(self.currentFrame)
>>>>>>> Work on animation functions
=======
   --print("walking " .. self.currentFrame)
>>>>>>> Finishes friend movement code
end