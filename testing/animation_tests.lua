require("animation")

startFrame = 1
endFrame = 2
timerMax = 1

function test_update_advancesFrame_whenWholePeriodPassedIn()
    local testAnimation = animation.Animation:new(timerMax, startFrame, endFrame)
    testAnimation:update(1)
    luaunit.assertEquals(testAnimation.currentFrame, startFrame+1)
end

function test_update_frameUnchanged_whenLessThanPeriodPassedIn()
    local testAnimation = animation.Animation:new(timerMax, startFrame, endFrame)
    testAnimation:update(0.9)
    luaunit.assertEquals(testAnimation.currentFrame, startFrame)
end

function test_update_frameUnchanged_whenTimerMax0()
    local testAnimation = animation.Animation:new(0, startFrame, endFrame)
    testAnimation:update(1)
    luaunit.assertEquals(testAnimation.currentFrame, startFrame)
end

function test_update_frameWrapsAround_whenAnimationDone()
    local testAnimation = animation.Animation:new(timerMax, startFrame, endFrame)
    testAnimation:update(1)
    testAnimation:update(1)
    luaunit.assertEquals(testAnimation.currentFrame, startFrame)
end

function test_update_frameSkips_whenTimerOverflows()
    local testAnimation = animation.Animation:new(timerMax, startFrame, endFrame)
    testAnimation:update(3)
    luaunit.assertEquals(testAnimation.currentFrame, startFrame+1)
end