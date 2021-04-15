require 'src/Dependencies'

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
-- this one will display the number of seconds
currentSecond = 0
--this one will count a second
secondTimer = 0

love.graphics.setDefaultFilter('nearest', 'nearest')
love.window.setTitle('Match 3')

math.randomseed(os.time())

push: setupScreen (VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
fullscreen = false,
vsync = true,
resizable = true
})

gSounds['music']:setLooping(true)
gSounds['music']:play()

backgroundX = 0
backgroundScrollSpeed = 80

gStateMachine = StateMachine {
['start'] = function() return StartState() end ,
['begin-game'] = function() return BeginGameState() end,
['play'] = function() return PlayState() end,
['game-over'] = function() return GameOverState() end
}
gStateMachine:change('start')

love.keyboard.keysPressed ={}
end

function love.resize(w, h)
push: resize(w,h)
end

function love.keypressed (key)
love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
if love.keyboard.keysPressed[key] then
return true
else
return false
end
end

function love.update(dt)
backgroundX = backgroundX - backgroundScrollSpeed * dt

if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
backgroundX = 0
end

gStateMachine:update(dt)
love.keyboard.keysPressed = {}
end

function love.draw()
push:start()

love.graphics.draw(gTextures['background'], backgroundX, 0)

gStateMachine:render()
push:finish()
end