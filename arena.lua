local arena_mt = {}
arena_mt.__index = arena_mt

local ARENA_WIDTH = 20
local ARENA_HEIGHT = 20

local TILE_SIZE = 50

--                  x, y, width , height
local left          = {x = 0, y = 100, width = 100, height = 100}
local right         = {x = 200,y = 100, 100, width = 100, height = 100}
local top           = {x = 100, y = 0, width = 100, height = 100}
local bottom        = {x = 100, y = 200, width = 100, height = 100}
local topLeft       = {x = 0, y = 0, width = 100, height = 100}
local bottomLeft    = {x = 0, y = 200, width = 100, height = 100}
local topRight      = {x = 200, y = 0, width = 100, height = 100}
local bottomRight   = {x = 200, y = 200, width = 100, height = 100}
local center        = {x = 100, y = 100, width = 100, height = 100}
local porteGauche         = {x = 300, y = 100, width = 100, height = 100}
local porteGaucheDetruite = {x = 300, y = 200, width = 100, height = 100}
local porteDroite         = {x = 300, y = 100, width = 100, height = 100} -- TODO ajouter au tileset
local porteDroiteDetruite = {x = 300, y = 200, width = 100, height = 100} -- TODO ajouter au tileset
local public              = {x = 300, y = 0, width = 15, height = 15}
local public2             = {x = 300, y = 15, width = 15, height = 15}
local publicDown          = {x = 315, y = 0, width = 15, height = 15}
local publicDown2         = {x = 315, y = 15, width = 15, height = 15}

function newArena()
	local arena = {}
	
	arena.tileSet = love.graphics.newImage("tileset.png")
	arena.tiles = {}
	arena.publicTimer = 0
	arena.hasLeftDoor = true
	arena.hasRightDoor = true
	arena.boxes = {}
	
	for i = 1, ARENA_WIDTH do
		arena.tiles[i] = {}
		for j = 1, ARENA_HEIGHT do
			local tile = nil
			if (i == 1) and (j == 1) then
				-- Partie haute gauche
				tile = topLeft
			elseif (i == 1) and (j == ARENA_HEIGHT) then
				-- Partie bas gauche
				tile = bottomLeft
			elseif (j == ARENA_HEIGHT / 2) and (i == 1) then
				-- Porte gauche
				tile = porteGauche
				arena.porteGauche = {x = i, y = j}
			elseif (j == ARENA_HEIGHT / 2) and (i == ARENA_WIDTH) then
				-- Porte droite
				tile = porteDroite
				arena.porteDroite = {x = i, y = j}
			elseif (i == 1) then
				-- Partie gauche
				tile = left
			elseif (j == 1) and (i == ARENA_WIDTH) then
				-- Partie haute droite
				tile = topRight
			elseif (j == 1)  then
				-- Partie haute
				tile = top
			elseif (i == ARENA_WIDTH) and (j == ARENA_HEIGHT) then
				-- PARTIE bas droite
				tile = bottomRight
			elseif (i == ARENA_WIDTH) then
				-- PARTIE droite
				tile = right
			elseif (j == ARENA_HEIGHT) then
				-- PARTIE bas
				tile = bottom
			else
				tile = center
			end
			
			arena.tiles[i][j] = tile;
		end
	end
	
	for i, t in ipairs(arena.tiles) do
		arena.boxes[i] = {}
		for j, tile in ipairs(t) do
			if (tile ~= center) then
				arena.boxes[i][j] = {
					{x = (i - 1) * TILE_SIZE,             y = (j - 1) * TILE_SIZE},
					{x = (i - 1) * TILE_SIZE + TILE_SIZE, y = (j - 1) * TILE_SIZE},
					{x = (i - 1) * TILE_SIZE + TILE_SIZE, y = (j - 1) * TILE_SIZE + TILE_SIZE},
					{x = (i - 1) * TILE_SIZE,             y = (j - 1) * TILE_SIZE + TILE_SIZE}
				}
			end
		end
	end
	
	arena.lvl = newLevel()

	return setmetatable(arena, arena_mt)
end

function arena_mt:update(dt)
	self.lvl:update(dt)
end

function arena_mt:draw()
	local p = nil
	if (self.publicTimer < 10) then
		p1 = public
		p2 = publicDown
	else
		p1 = public2
		p2 = publicDown2
		if (self.publicTimer >= 20) then
			self.publicTimer = 0
		end
	end
	self.publicTimer = self.publicTimer + 1
	
	for i, t in ipairs(self.tiles) do
		for j, tile in ipairs(t) do
			local quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, self.tileSet:getWidth(), self.tileSet:getHeight())
			love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, 0, TILE_SIZE / 100, TILE_SIZE / 100)
			-- Dessin du public du haut
			if (j == 1) and (i ~= 1) and (i < ARENA_WIDTH) then
				for ip = 1, TILE_SIZE / p1.width do
					for jp = 1, TILE_SIZE / ((p1.height/2) + 1) do
						local quad = love.graphics.newQuad(p1.x, p1.y, p1.width, p1.height, self.tileSet:getWidth(), self.tileSet:getHeight())
						local off = 0
						if (jp % 2) == 0 then
							off = 7
						end
						love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE + (ip - 1) * p1.width + off, (jp - 1) * p1.height / 2)
					end
				end
			end
			-- Dessin du public du bas
			if (j == ARENA_HEIGHT) and (i ~= 1) and (i < ARENA_WIDTH) then
				for ip = 1, TILE_SIZE / p2.width do
					for jp = 1, TILE_SIZE / ((p2.height/2) + 1) do
						local quad = love.graphics.newQuad(p2.x, p2.y, p2.width, p2.height, self.tileSet:getWidth(), self.tileSet:getHeight())
						local off = 0
						if (jp % 2) == 0 then
							off = 7
						end
						love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE + (ip - 1) * p2.width + off,
																(j - 1) * TILE_SIZE + (jp - 1) * p2.height / 2)
					end
				end
			end
		end
	end
	love.graphics.push()
	love.graphics.translate(self.lvl:getWidth() / 2, -self.lvl:getHeight())
	self.lvl:draw()
	love.graphics.pop()
end

function arena_mt:destroyLeftDoor()
	self.tiles[self.porteGauche.x][self.porteGauche.y] = porteGaucheDetruite
	self.hasLeftDoor = false
end

function arena_mt:destroyRightDoor()
	self.tiles[self.porteDroite.x][self.porteDroite.y] = porteGaucheDetruite
	self.hasRightDoor = false
end

-- Renvoie une position valide pour un deplacement de lastQuad vers newQuad (lastQuad est supposé valide)
function arena_mt:getValidQuad(lastQuad, newQuad, dx, dy)
	local quad = newQuad
	for j, t in ipairs(self.boxes) do
		for i, box in ipairs(t) do
			if (box ~= nil) and (quad ~= nil) then
				if (rectCollision(box, quad)) then
					local c1 = getQuadCenter(quad)
					local newDX = dx
					local newDY = dy
					if ((c1.x >= box[1].x) and (c1.x <= box[2].x) and
						(c1.y >= box[1].y) and (c1.y <= box[3].y))then
						newDY = 0
						newDX = 0
					elseif (c1.x >= box[1].x) and (c1.x <= box[2].x) then
						newDY = 0
					elseif (c1.y >= box[1].y) and (c1.y <= box[3].y) then
						newDX = 0
					else
						newDY = 0
						newDX = 0
					end
					
					local x = lastQuad[1].x + newDX
					-- if (dx > 0) and (newDX == 0) then
						-- x = box[1].x - getQuadWidth(quad) - 1
					-- elseif (dx < 0) and (newDX == 0) then
						-- x = box[2].x + 1
					-- end
					local y = lastQuad[1].y + newDY
					-- if (dy > 0) and (newDY == 0) then
						-- y = box[1].y - getQuadHeight(quad) - 1
					-- elseif (dy < 0) and (newDY == 0) then
						-- y = box[3].y + 1
					-- end
					quad = {
						{x = x,                      y = y},
						{x = x + getQuadWidth(quad), y = y},
						{x = x + getQuadWidth(quad), y = y + getQuadHeight(quad)},
						{x = x,                      y = y + getQuadHeight(quad)}
					}
				end
			end
		end
	end
	return self.lvl:getValidQuad(lastQuad, quad, dx, dy)
end


function arena_mt:getWidth()
	return TILE_SIZE * ARENA_WIDTH
end

function arena_mt:getHeight()
	return TILE_SIZE * ARENA_HEIGHT
end
