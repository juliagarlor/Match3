PlayState = Class{__includes = BaseState}

function PlayState:init()
self.transitionAlpha = 0.5

self.boardHighlightX = 0
self.boardHighlightY = 0

self.rectHighlighted = false
self.canInput = true

self.highlightedTile = nil

self.score = 0
self.timer = 60

self.pM = {}

--cursor will highlight on and off
Timer.every(0.5, function()
	self.rectHighlighted = not self.rectHighlighted
end)

Timer.every(1, function()
--timer should go backwards from 60 seconds
	self.timer = self.timer -1
	
	if self.timer<= 5 then
		gSounds['clock']:play()
	end
end)
end

function PlayState:enter(params)
self.level = params.level
--board will be the same coming from the begingamestate or create a new one
self.board = params.board 

if not self.board:possibleMatches() then
self.board = Board(VIRTUAL_WIDTH - 272, 16, self.level)
end

self.score = params.score or 0
--we should reach a certain score to pass to the next level
self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)
if love.keyboard.wasPressed('escape') then
	love.event.quit()
end

if self.timer <= 0 then
	--game is over if we run out of time
	Timer.clear()
	gSounds['game-over']:play()
	gStateMachine:change('game-over', {
		score = self.score
	})
end

Timer.tween(1, {
[self] = {transitionAlpha = 0}
}):finish(function() 
	Timer.tween(1, {
	[self] = {transitionAlpha = 0.5}
	}):finish(function() end)
end)

if self.canInput then
--move cursor based on bounds of grid
	if love.keyboard.wasPressed('up') then
		self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
		gSounds['select']:play()
	elseif love.keyboard.wasPressed('down') then
		self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
		gSounds['select']:play()
	elseif love.keyboard.wasPressed('left') then
		self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
		gSounds['select']:play()
	elseif love.keyboard.wasPressed('right') then
		self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
		gSounds['select']:play()
	end
	
	if love.keyboard.wasPressed('return') then
		--we save the x and y of the current highlighted tile as indices of a table. This is the first tile to be highlighted
		local x = self.boardHighlightX + 1
		local y = self.boardHighlightY + 1
		
		if not self.highlightedTile then
		--if nothing highlighted, highlight the current tile. Asociate the tile on the board with highlightedTile
			self.highlightedTile = self.board.tiles[y][x]
		
		elseif self.highlightedTile == self.board.tiles[y][x] then
		--if this position was already highlighted, remove highlight
			self.highlightedTile = nil
		elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
		--if the selected tiles are further than one position, remove the highlight
			gSounds['error']:play()
			self.highlightedTile = nil
		else
		--otherwise, swap tiles positions
			--save the position of the tile on the table on tempX and tempY. These are the coordinates of the first highlightedTile (I suppose)
			local tempX = self.highlightedTile.gridX
			local tempY = self.highlightedTile.gridY
			
			--now we create a new variant for the second highlightedTile?
			local newTile = self.board.tiles[y][x]
			
			--we associate the position in the board of the second tile with the position of the first one and viceversa... if that made sense.
			--we can do this because we have previously saved the coordinates of the first tile in tempX and tempY
			self.highlightedTile.gridX = newTile.gridX
			self.highlightedTile.gridY = newTile.gridY
			newTile.gridX = tempX
			newTile.gridY = tempY
			
			self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX]=
			self.highlightedTile
			--remember that gridX and gridY are the positions on the table, while x and y are the positions on screen
			
			self.board.tiles[newTile.gridY][newTile.gridX] = newTile
			
			Timer.tween(0.1, {
				[self.highlightedTile] = {x = newTile.x, y = newTile.y},
				[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
			}):finish(function()
				self:calculateMatches()
				if self.highlightedTile then
					self.board:swap(self.highlightedTile, newTile)
					Timer.tween(0.2, {
					[self.highlightedTile] = {x = newTile.x, y = newTile.y},
					[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
					}):finish(function () 
					gSounds['error']:play()
					self.highlightedTile = nil
					end)
				end
				if not self.board:possibleMatches() then
					self.board = Board(VIRTUAL_WIDTH - 272, 16, math.min(6, self.level))
				end
			end)
		end
	end
end

if self.score >= self.scoreGoal then
	--if we reach the goal, then go to the next level
	
	Timer.clear()
	gSounds['next-level']:play()
	gStateMachine:change('begin-game', {
	level = self.level + 1,
	score = self.score,
	board = Board(VIRTUAL_WIDTH - 272, 16, math.min(6, self.level + 1))
	})
end

Timer.update(dt)
end

function PlayState:calculateMatches()
	
	local matches = self.board:calculateMatches()
	
	if matches then
		self.highlightedTile = nil
		gSounds['match']:stop()
		gSounds['match']:play()
		
		for k, match in pairs(matches) do
		local length = #match
			for i=1, length do
			self.score = self.score + 50 * matches[k][i].variety
			end
			--in each match, we will increase the timer in as many seconds as tiles in the match
			self.timer = self.timer + length
		end
		
		self.board:removeMatches()
		local tilesToFall = self.board:getFallingTiles()
		
		Timer.tween(0.25, tilesToFall):finish(function()
			local newTiles = self.board:getNewTiles()
			
			Timer.tween(0.25, newTiles):finish(function()
				self:calculateMatches()
			end)
		end)
		return true
	else
		self.canInput = true		
	end
end

function PlayState:render()
self.board:render()

for k=1, 8 do
	for t= 1, 8 do
		if self.board.tiles[k][t].shiny == true then
			love.graphics.setColor(1, 1, 1, self.transitionAlpha)
			love.graphics.rectangle('fill', self.board.tiles[k][t].x + VIRTUAL_WIDTH - 268, self.board.tiles[k][t].y + 20, 24, 24)
		end
	end
end

if self.highlightedTile then
	love.graphics.setBlendMode('add')
	love.graphics.setColor(1, 1, 1, 96/255)
	love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32
	+ (VIRTUAL_WIDTH - 272), (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)
	love.graphics.setBlendMode('alpha')
end

if self.rectHighlighted then
	 love.graphics.setColor(217/255, 87/255, 99/255, 1)
	
else
	love.graphics.setColor(172/255, 50/255, 50/255, 1)
end

love.graphics.setLineWidth(4)
love.graphics.rectangle('line', self.boardHighlightX * 32
	+ (VIRTUAL_WIDTH - 272), self.boardHighlightY * 32 + 16, 32, 32, 4)
love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
love.graphics.rectangle('fill', 16, 16, 186, 116, 4)	
love.graphics.setColor(99/255, 155/255, 1, 1)
love.graphics.setFont(gFonts['medium'])
love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
love.graphics.printf('Goal: ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')

love.graphics.setColor(1, 1, 1, 1)
end