-- Package: constants
-- This package contains constants used in the game

walkingScreenWidth = love.graphics.getWidth() / 2
screenHeight = 600
playerSpeed = 150
friendSpeed = 100
carSpeed = 600
carWidth = 258
carHeight = 84
scrollSpeed = 100
numScreens = 10
frameSide = 32
playerStartX = 3 / 4 * walkingScreenWidth - frameSide * 2
playerStartY = screenHeight / 4 - frameSide / 2
friendStartX = 3 / 4 * walkingScreenWidth
friendStartY = screenHeight / 4
restartTimerMax = 3