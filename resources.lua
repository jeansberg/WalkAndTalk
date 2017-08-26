-- ##################################################################
-- # Gives access to graphics and audio resources
-- ##################################################################

local resources = {}
resources.images = {}
resources.sounds = {}

resources.images.playerImage = love.graphics.newImage("resources/images/player.png")
resources.images.friendImage = love.graphics.newImage("resources/images/friend.png")
resources.images.carImage = love.graphics.newImage("resources/images/car2.png")

resources.sounds.victory = love.audio.newSource("resources/sound/Jingle_Win_01.mp3")
resources.sounds.failure = love.audio.newSource("resources/sound/Jingle_Lose_01.mp3")
resources.sounds.skid = love.audio.newSource("resources/sound/skid.mp3")
resources.sounds.music = love.audio.newSource("resources/sound/Sound Way NES.mp3")

return resources