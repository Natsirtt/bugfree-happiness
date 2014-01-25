local mt = {}
mt.__index = mt

local MAX_LIFE = 10
local SPEED_BASE = 500
local RADIUS = 20
local DEFENDING_MAX_TIME = 5
local ANIMATION_RATE = 0.1

function newPlayer(gameManager, playerNo)
    local this = {}
	
	local tileSet = love.graphics.newImage("assets/player"..playerNo..".png")
	
	this.assets = {}
	this.assets["idle"] = {}
	this.assets["walkDown"] = {}
	this.assets["walkRight"] = {}
	this.assets["walkLeft"] = {}
	this.assets["walkUp"] = {}
	this.assets["attackRight"] = {}
	this.assets["attackLeft"] = {}
	this.assets["attackUp"] = {}
	this.assets["attackDown"] = {}

	this.assetsX = "idle"
	this.assetsY = 0
	this.temporaryAsset = false
	this.temporaryRemainingFrame = 0
	this.assetsMod = 4
	this.assestsLastChange = love.timer.getTime()

	local imageData = tileSet:getData()
	local nid = love.image.newImageData(150, 150)
	local j = 0

	for i = 1, 4 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["idle"], love.graphics.newImage(nid))
	end

	j = j + 1

	for i = 1, 4 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["walkDown"], love.graphics.newImage(nid))
	end

	j = j + 1

	for i = 1, 4 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["walkRight"], love.graphics.newImage(nid))
	end

	j = j + 1

	for i = 1, 4 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["walkLeft"], love.graphics.newImage(nid))
	end

	j = j + 1

	for i = 1, 4 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["walkUp"], love.graphics.newImage(nid))
	end

	j = j + 1

	for i = 1, 2 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["attackRight"], love.graphics.newImage(nid))
	end
	table.insert(this.assets["attackRight"], love.graphics.newImage(nid))
	nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
	table.insert(this.assets["attackRight"], love.graphics.newImage(nid))

	j = j + 1

	for i = 1, 2 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["attackLeft"], love.graphics.newImage(nid))
	end
	table.insert(this.assets["attackLeft"], love.graphics.newImage(nid))
	nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
	table.insert(this.assets["attackLeft"], love.graphics.newImage(nid))

	j = j + 1

	for i = 1, 2 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["attackUp"], love.graphics.newImage(nid))
	end
	table.insert(this.assets["attackUp"], love.graphics.newImage(nid))
	nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
	table.insert(this.assets["attackUp"], love.graphics.newImage(nid))

	j = j + 1

	for i = 1, 2 do
		nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
		table.insert(this.assets["attackDown"], love.graphics.newImage(nid))
	end
	table.insert(this.assets["attackDown"], love.graphics.newImage(nid))
	nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
	table.insert(this.assets["attackDown"], love.graphics.newImage(nid))

	this.deathSound = love.audio.newSource("death.wav", "static")

	this.gameManager = gameManager
    
	this.angle = 0
    this.x = 400
    this.y = 400
    this.dx = 0
    this.dy = 0
    this.isDefendingBool = false
    this.defendingTimeLeft = DEFENDING_MAX_TIME
    this.speed = SPEED_BASE
    this.hitbox = {}
    this.controller = getControllersManager():getUnusedController()
	
	this.deathTimer = 0
	this.deathParticleSystem = nil
	
	
    
    --if this.controller == nil then
        -- should not happen if we use stuff correctly
    --end
    
    this.life = MAX_LIFE
    
    return setmetatable(this, mt)
end

function mt:getQuad()
	return {
		{x = self.x - RADIUS, y = self.y - RADIUS},
		{x = self.x + RADIUS, y = self.y - RADIUS},
		{x = self.x + RADIUS, y = self.y + RADIUS},
		{x = self.x - RADIUS, y = self.y + RADIUS}
	}
end

function mt:oldGetQuad()
    return {x = self.x - RADIUS,
            y = self.y - RADIUS,
            w = RADIUS * 2,
            h = RADIUS * 2}
end

function mt:setPositionFromQuad(quad)
	local pm1 = getMiddlePoint(quad[1], quad[3])
	local pm2 = getMiddlePoint(quad[2], quad[4])
	
	local middle = getMiddlePoint(pm1, pm2)

    self.x = middle.x
    self.y = middle.y
end

function mt:setDefending(isDefending)
	self.isDefendingBool = isDefending
end

function mt:isDefending()
	return self.isDefendingBool
end

function mt:canAttack()
	return not self:isDefending()
end

function mt:switchAttackAsset()
	local str = self.assetsX
	if str == "walkUp" then
		self.assetsX = "attackUp"
	elseif (str == "walkDown") or (str == "idle") then
		self.assetsX = "attackDown"
	elseif str == "walkLeft" then
		self.assetsX = "attackLeft"
	elseif str == "walkRight" then
		self.assetsX = "attackRight"
	elseif str == "attackUp" then
		self.assetsX = "walkUp"
	elseif str == "attackDown" then
		self.assetsX = "walkDown"
	elseif str == "attackRight" then
		self.assetsX = "walkRight"
	else
		self.assetsX = "walkLeft"
	end
end

function mt:attack()
	if self:canAttack() then
		self.gameManager:playerAttack(self)
	end
end

function mt:update(dt)
	if (not self:isDead()) then
		-- position checking
		self.dx, self.dy = self.controller:getAxes()
		if (self.controller:isDown(10)) then
			self.gameManager.camera:shake()
			self.gameManager.camera:blink({r = 180, g = 20, b = 20})
		end
		if (self.controller:isDown(13)) then
			if not self.temporaryAsset then
				self:attack()
				self:switchAttackAsset()
				self.temporaryRemainingFrame = 4
				self.temporaryAsset = true
			end
		end
		if (self.controller:isDown(11)) then
			self:hit(self.life)
		end
		
		self.x = self.x + dt * self.dx * self.speed
		self.y = self.y + dt * self.dy * self.speed
		
		if (self.dx == -1) and (self.dy == -1) then
			self.angle = 45
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == -1) and (self.dy == 0) then
			self.angle = 90
			if not self.temporaryAsset then
				self.assetsX = "walkLeft"
			end
		elseif (self.dx == -1) and (self.dy == 1) then
			self.angle = 135
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		elseif (self.dx == 1) and (self.dy == -1) then		
			self.angle = -45
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == 1) and (self.dy == 0) then
			self.angle = -90
			if not self.temporaryAsset then
				self.assetsX = "walkRight"
			end
		elseif (self.dx == 1) and (self.dy == 1) then
			self.angle = -135
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		elseif (self.dx == 0) and (self.dy == -1) then
			self.angle = 0
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == 0) and (self.dy == 1) then
			self.angle = 180
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		end

		if (self.dx == 0) and (self.dy == 0) then
			if not self.temporaryAsset then
				self.assetsX = "idle"
			end
		end

		-- defending checking
		if self:isDefending() then
			self.defendingTimeLeft = self.defendingTimeLeft - dt
			if self.defendingTimeLeft <= 0 then
				self:setDefending(false)
			end
		else

		end

		--animation
		if love.timer.getTime() - self.assestsLastChange >= ANIMATION_RATE then
			self.assestsLastChange = love.timer.getTime()
			self.assetsY = (self.assetsY + 1) % self.assetsMod

			if self.temporaryAsset then
				if self.temporaryRemainingFrame <= 0 then
					self:switchAttackAsset()
					self.temporaryAsset = false
				else
					self.temporaryRemainingFrame = self.temporaryRemainingFrame - 1
				end
			end
		end
	else
		self.deathTimer = self.deathTimer + dt
		self.deathParticleSystem:update(dt)
	end
end

function mt:draw()
	love.graphics.push()
	--love.graphics.translate(self.x, self.y)
	--love.graphics.rotate(math.rad(-self.angle))

	local tex = self.assets[self.assetsX][self.assetsY + 1]
	love.graphics.draw(tex, self.x - tex:getWidth() / 2, self.y - tex:getHeight() / 2)
	
	
	if (self:isDead()) then
		love.graphics.draw(self.deathParticleSystem)
	end
	
	love.graphics.pop()
	
	if (self:isDead()) then
		love.graphics.print("Le joueur est mort x(", 100, 100)
	end
end

function mt:isDead()
    return self.life <= 0
end

function mt:getLife()
    return self.life
end

function mt:hit(lifePoints)
    self.life = self.life - lifePoints
	if (self:isDead()) then
		local p = love.graphics.newParticleSystem(self.assets[self.assetsX][self.assetsY + 1], 1000)
		p:setEmissionRate(100)
		p:setSpeed(300, 400)
		p:setPosition(self.x, self.y)
		p:setEmitterLifetime(0.3)
		p:setParticleLifetime(1)
		p:setDirection(0)
		p:setSpread(360)
		p:setRadialAcceleration(-3000)
		p:setTangentialAcceleration(1000)
		p:stop()
		self.deathParticleSystem = p
		p:start()
		
		self.deathSound:play()
	end
end

function mt:heal(lifePoints)
    self.life = self.life + lifePoints
    if self.life > MAX_LIFE then
        self.life = MAX_LIFE
    end
end
