local level_mt = {}
level_mt.__index = level_mt


local LEVEL_MAP = {
{2, 1, 1, 0, 0, 0, 1, 1, 3},
{1, 1, 1, 0, 0, 0, 1, 1, 1},
{1, 1, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 1, 1, 1},
{1, 1, 1, 0, 0, 0, 1, 1, 1},
{1, 1, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 1, 1, 1},
{1, 1, 1, 0, 0, 0, 1, 1, 1, 3},
{1, 1, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 0, 0, 0, 1},
{1, 1, 0, 0, 0, 0, 0, 0, 1, 5},
{1, 1, 0, 0, 0, 0, 0, 0, 1},
{1, 0, 0, 0, 0, 0, 0, 0, 1},
{1, 0, 0, 0, 1, 1, 1, 1, 1},
{1, 0, 0, 0, 0, 0, 1, 1, 1},
{1, 1, 1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 0, 0, 0, 1, 1, 1},
{4, 1, 1, 0, 0, 0, 1, 1, 5}
}

local LEVEL_WIDTH = 10
local LEVEL_HEIGHT = 25

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

function newLevel()
	local level = {}
	
	level.tileSet = love.graphics.newImage("tileset.png")
	
	local dx = TILE_SIZE * LEVEL_WIDTH / 2
	local dy = -TILE_SIZE * LEVEL_HEIGHT
	
	level.boxes = {}
	for j, t in ipairs(LEVEL_MAP) do
		level.boxes[j] = {}
		for i, tileID in ipairs(t) do
			if (tileID ~= 0) then
				level.boxes[j][i] = {
					{x = (i - 1) * TILE_SIZE + dx,             y = (j - 1) * TILE_SIZE + dy},
					{x = (i - 1) * TILE_SIZE + dx + TILE_SIZE, y = (j - 1) * TILE_SIZE + dy},
					{x = (i - 1) * TILE_SIZE + dx + TILE_SIZE, y = (j - 1) * TILE_SIZE + dy + TILE_SIZE},
					{x = (i - 1) * TILE_SIZE + dx,             y = (j - 1) * TILE_SIZE + dy + TILE_SIZE}
				}
			end
		end
	end

	return setmetatable(level, level_mt)
end

function level_mt:update(dt)
	
end

function level_mt:draw()
	for j, t in ipairs(LEVEL_MAP) do
		for i, tileID in ipairs(t) do
			local tile = nil
			if (tileID == 0) then
				tile = center
			elseif (tileID == 2) then
				tile = topLeft
			elseif (tileID == 3) then
				tile = topRight
			elseif (tileID == 4) then
				tile = bottomLeft
			elseif (tileID == 5) then
				tile = bottomRight
			elseif (tileID == 1) then 
				tile = left
			else

			end
			if (tile ~= nil) then
				local quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, self.tileSet:getWidth(), self.tileSet:getHeight())
				love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, 0, TILE_SIZE / 100, TILE_SIZE / 100)
			end
		end
	end
end

function level_mt:getWidth()
	return TILE_SIZE * LEVEL_WIDTH
end

function level_mt:getHeight()
	return TILE_SIZE * LEVEL_HEIGHT
end

-- Renvoie une position valide pour un deplacement de lastQuad vers newQuad (lastQuad est supposé valide)
function level_mt:getValidQuad(lastQuad, newQuad, dx, dy)
	local quad = newQuad
	for j, t in ipairs(self.boxes) do
		for i, box in ipairs(t) do
			if (box ~= nil) and (quad ~= nil) then
				if (rectCollision(box, quad)) then
					local c1 = getQuadCenter(quad)
					local newDX = dx
					local newDY = dy
					if (c1.x >= box[1].x) and (c1.x <= box[2].x) then
						newDY = 0
					end
					if (c1.y >= box[1].y) and (c1.y <= box[3].y) then
						newDX = 0
					end
					local x = lastQuad[1].x + newDX
					if (dx > 0) and (newDX == 0) then
						x = box[1].x - getQuadWidth(quad) - 1
					elseif (dx < 0) and (newDX == 0) then
						x = box[2].x + 1
					end
					local y = lastQuad[1].y + newDY
					if (dy > 0) and (newDY == 0) then
						y = box[1].y - getQuadHeight(quad) - 1
					elseif (dy < 0) and (newDY == 0) then
						y = box[3].y + 1
					end
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
	return quad
end


