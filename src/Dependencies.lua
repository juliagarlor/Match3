Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/Util'
require 'src/Board'
require 'src/StateMachine'
require 'src/Tile'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginGameState'
require 'src/states/GameOverState'
require 'src/states/PlayState'

--we add here our sounds, frames and fonts

gSounds = {
['music'] = love.audio.newSource('sounds/music3.mp3', 'static'),
['select'] = love.audio.newSource('sounds/select.wav', 'static'),
['error'] = love.audio.newSource('sounds/error.wav', 'static'),
['match'] = love.audio.newSource('sounds/match.wav', 'static'),
['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static')
}

gTextures = {
['main'] = love.graphics.newImage('graphics/match3.png'),
['background'] = love.graphics.newImage('graphics/background.png')
}

gFrames = {
--instead of just one table for all of them, we have a different table
--for every type of tiles
['tiles'] = GenerateTileQuads(gTextures['main'])
}

gFonts = {
['small'] = love.graphics.newFont('fonts/font.ttf', 8),
['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}