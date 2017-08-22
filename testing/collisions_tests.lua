require("collisions")

wallRect = {xPos = 10, yPos = 10, width = 10, height = 10, dx = 0, dy = 0}
rectAbove = {xPos = 15, yPos = 5, width = 2, height = 6, dx = 0, dy = 1}
rectBelow = {xPos = 15, yPos = 19, width = 2, height = 6, dx = 0, dy = 1}
rectToLeft = {xPos = 10, yPos = 15, width = 5, height = 6, dx = 0, dy = 1}
rectToRight = {xPos = 15, yPos = 15, width = 5, height = 6, dx = 0, dy = 1}
rectInside = {xPos = 11, yPos = 11, width = 5, height = 6, dx = 0, dy = 1}

function test_checkOverlap_returnsTrueWhenIntersectsFromAbove()
    local overlaps = collisions.checkOverlap(wallRect, rectAbove)
    luaunit.assertEquals(overlaps, true)
end

function test_checkOverlap_returnsTrueWhenIntersectsFromBelow()
    local overlaps = collisions.checkOverlap(wallRect, rectBelow)
    luaunit.assertEquals(overlaps, true)
end

function test_checkOverlap_returnsTrueWhenIntersectsFromLeft()
    local overlaps = collisions.checkOverlap(wallRect, rectToLeft)
    luaunit.assertEquals(overlaps, true)
end

function test_checkOverlap_returnsTrueWhenIntersectsFromRight()
    local overlaps = collisions.checkOverlap(wallRect, rectToRight)
    luaunit.assertEquals(overlaps, true)
end

function test_checkOverlap_returnsTrueWhenInside()
    local overlaps = collisions.checkOverlap(wallRect, rectToRight)
    luaunit.assertEquals(overlaps, true)
end

function test_checkOverlap_returnsFalseWhenAbove()
    rectAbove.yPos = 4
    local overlaps = collisions.checkOverlap(wallRect, rectAbove)
    rectAbove.yPos = 5
    luaunit.assertEquals(overlaps, false)
end

function test_checkOverlap_returnsFalseWhenBelow()
    rectBelow.yPos = 20
    local overlaps = collisions.checkOverlap(wallRect, rectBelow)
    rectBelow.yPos = 19
    luaunit.assertEquals(overlaps, false)
end

function test_checkOverlap_returnsFalseWhenToLeft()
    rectToLeft.xPos = 5
    local overlaps = collisions.checkOverlap(wallRect, rectToLeft)
    rectToLeft.xPos = 10
    luaunit.assertEquals(overlaps, false)
end

function test_checkOverlap_returnsFalseWhenToRight()
    rectToRight.xPos = 20
    local overlaps = collisions.checkOverlap(wallRect, rectToRight)
    rectToRight.xPos = 15
    luaunit.assertEquals(overlaps, false)
end