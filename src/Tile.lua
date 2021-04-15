Tile = Class{}

function Tile:init(x, y, color, variety, shinyColor)
--positions in the table
self.gridX = x
self.gridY = y

--positions on screen
self.x = (self.gridX - 1) * 32
self.y = (self.gridY - 1) * 32

self.shiny = false
self.shinyColor = shinyColor

self.color = color
if self.color == self.shinyColor and math.random(5)==1 then
	self.shiny = true
end
self.variety = variety
--variety meaning the figure in the tile
end

function Tile:update(dt)

end

function Tile:render(x, y)
--shadow
love.graphics.setColor(34/255, 32/255, 52/255,1)
love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
self.x + x + 2, self.y + y + 2)
--tile
love.graphics.setColor(1, 1, 1, 1)
love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
self.x + x, self.y + y)
end