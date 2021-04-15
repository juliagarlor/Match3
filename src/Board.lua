Board = Class{}

function Board:init(x,y, variety)
self.x = x
self.y = y
self.variety = variety
self.matches = {}
self.shinyColor = math.random(9)
self:initializeTiles()
self.pMatches = {}
end

function Board:initializeTiles()
self.tiles = {}
for tileY = 1, 8 do
--the board will have 8 rows and 8 columns. In the table self.tiles we create 8 empty tables
	table.insert(self.tiles, {})
	for tileX = 1, 8 do 
	-- each of these 8 subtables will contain 8 Tile objects. 
		table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(9), math.random(self.variety), self.shinyColor))
		--these 8 subtables are divided in another 8 subtables
		--containing tiles of aleatory colour and variety
		if self.tiles[tileY][tileX].color == self.shinyColor then
			self.tiles[tileY][tileX].shiny = true
		end
	end
end

while self:calculateMatches() do
--???
	self:initializeTiles()
end
end

function Board:swap(firstTile, secondTile)
local tempX = firstTile.gridX
local tempY = firstTile.gridY

firstTile.gridX = secondTile.gridX
firstTile.gridY = secondTile.gridY
secondTile.gridX = tempX
secondTile.gridY = tempY

self.tiles[firstTile.gridY][firstTile.gridX] = firstTile
self.tiles[secondTile.gridY][secondTile.gridX] = secondTile
end

function Board:possibleMatches()
-- --down and right
for y = 1, 7 do
	for x = 1, 7 do
		
		--horizontal swap
		self:swap(self.tiles[y][x], self.tiles[y][x + 1])
		
		if self:calculateMatches() then
			self:swap(self.tiles[y][x], self.tiles[y][x + 1])
			return true
		end
		
		self:swap(self.tiles[y][x], self.tiles[y][x + 1])
		
		--vertical swap
		self:swap(self.tiles[y][x], self.tiles[y + 1][x])
		
		if self:calculateMatches() then
			self:swap(self.tiles[y][x], self.tiles[y + 1][x])
			return true
		end
		
		self:swap(self.tiles[y][x], self.tiles[y + 1][x])
	end
end
return false
end

function Board:calculateMatches()
local matches = {}
--it creates an empty table

local matchNum = 1

for y = 1, 8 do
	local colorToMatch = self.tiles[y][1].color
	matchNum = 1
	--line by line. We first save the color of the first tile of the line
	for x = 2, 8 do
		if self.tiles[y][x].color == colorToMatch then
			matchNum = matchNum + 1
			--if the following tile has the same colour as the current one
			--we have 2 tiles matching
		else
			colorToMatch = self.tiles[y][x].color
			--if not, the colour to be examined is the following tile's
			if matchNum >= 3 then
				local match = {}
				--create an empty table for the matching tiles
				for x2 = x - 1, x - matchNum, -1 do
				--look backwards from the last tile matching
				--remember that coordinates on screen begin as 0, not as 1
					if self.tiles[y][x2].shiny == true then
						for i= 1, 8 do
							table.insert(match, self.tiles[y][i])
						end
					else
					table.insert(match, self.tiles[y][x2])
					end
					--we place each tile in the empty table match
				end
				--add the new matching tiles to the table with all the matches
				table.insert(matches, match)
				-- and place the table match just filled with tiles inside the empty matches
			end
			if x >= 7 then
				break
				--stop if we don't have a match in tile 7 of the row
			end
			
			matchNum = 1
		end
		
	end
	
	if matchNum >= 3 then
		local match = {}
		
		--ok, so the thing is that if the final tile is part of the match, it isn't included in the table matches,
		--according to the loop before (because we don't have a next tile not matching). 
		--So, in this part, we analize whether we have match once ended the previous 
		--loop or not, and if so, add that match to matches
		for x= 8, 8 - matchNum + 1, -1 do
			if self.tiles[y][x].shiny == true then
				for i= 1, 8 do
					table.insert(match, self.tiles[y][i])
				end
			else
			table.insert(match, self.tiles[y][x])
			end
		end
		table.insert(matches, match)
	end
end

--vertical
for x = 1, 8 do
	local colorToMatch = self.tiles[1][x].color
	matchNum = 1
	
	for y = 2, 8 do
		if self.tiles[y][x].color == colorToMatch then
			matchNum = matchNum + 1
		else
			colorToMatch = self.tiles[y][x].color
			
			if matchNum >= 3 then
				local match = {}
				
				for y2 = y - 1, y - matchNum, -1 do
					if self.tiles[y2][x].shiny == true then
						for i= 1, 8 do
							table.insert(match, self.tiles[i][x])
						end
					else
					table.insert(match, self.tiles[y2][x])
					end
				end
				table.insert(matches, match)
			end
			matchNum = 1
			
			if y >= 7 then
				break
			end
		end
	end
	
	if matchNum >= 3 then
		local match = {}
		
		for y = 8, 8 - matchNum, -1 do
			if self.tiles[y][x].shiny == true then
				for i= 1, 8 do
					table.insert(match, self.tiles[i][x])
				end
			else
			table.insert(match, self.tiles[y][x])
			end
		end
		
		table.insert(matches, match)
	end
end

self.matches = matches
return #self.matches > 0 and self.matches or false
end

function Board:removeMatches()
for k, match in pairs(self.matches) do
	for k, tile in pairs(match) do
		self.tiles[tile.gridY][tile.gridX] = nil
		--set the matching tiles to nil
	end
end
self.matches = nil
--why this? Just to ensure?
end

function Board:getFallingTiles()
local tweens = {}

for x = 1, 8 do
	local space = false
	local spaceY = 0
	
	local y = 8
	while y >= 1 do
		local tile = self.tiles[y][x]
		
		if space then
			if tile then
			--this case for when we have previously moved a tile and now 
			--we are in the space left by it
			self.tiles[spaceY][x] = tile
			tile.gridY = spaceY
			self.tiles[y][x] = nil
			--put the vertically following tile in the current space,
			--and set that tile to nil
			tweens[tile] = {
			y = (tile.gridY - 1) * 32
			}
			
			space = false
			y = spaceY
			spaceY = 0
			end
		elseif tile == nil then
			space = true
			
			if spaceY == 0 then
				spaceY = y
			end
		end
		y = y - 1
	end
end

--creating new tiles 
for x = 1, 8 do
	for y = 8, 1, -1 do
		local tile = self.tiles[y][x]
		
		if not tile then
			local tile = Tile(x, y, math.random(9), math.random(self.variety))
			tile.y = -32
			self.tiles[y][x] = tile
			
			tweens[tile] = {
			y = (tile.gridY - 1) * 32
			}
		end
	end
end
return tweens
end

function Board:getNewTiles()
return {}
end

function Board:render()
for y = 1, #self.tiles do
	for x = 1, #self.tiles[1] do
		self.tiles[y][x]:render(self.x, self.y)
	end
end
end