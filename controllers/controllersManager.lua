local mt = {}
mt.__index = mt

local init = false
local instance = {}

function getControllersManager()
    if not init then
        local this = {}
        
        this.unbindedControllers = {}
        this.bindedControllers = {}
        this.unusedControllers = {}
        
        for i, j in ipairs(love.joystick.getJoysticks()) do
            this.unbindedControllers[#this.unbindedControllers + 1] = newGamepadController(j)
        end
		this.unbindedControllers[#this.unbindedControllers + 1] = newKeyboardController()
    
        instance = setmetatable(this, mt)
        init = true
    end
    return instance
end

function mt:getFirstNewController()
    local controller = nil
    local pos = -1
    for i, c in ipairs(self.unbindedControllers) do
        if c:isAnyDown() then
            controller = c
            pos = i
            break
        end
    end
    return controller, pos
end

function mt:tryBindingNewController()
    local c, pos = self:getFirstNewController()
    if c ~= nil then
        self.bindedControllers[#self.bindedControllers + 1] = c
        self.unusedControllers[#self.unusedControllers + 1] = c
        table.remove(self.unbindedControllers, pos)
        return true
    end
    return false
end

function mt:getUnbindedControllers()
    return self.unbindedControllers
end

function mt:getBindedControllers()
    return self.bindedControllers
end

function mt:getBindedControllersNb()
    return #self.bindedControllers
end

function mt:getUnusedController()
    local size = #self.unusedControllers
    if size == 0 then
        return nil
    end
    
    local c = self.unusedControllers[size]
    table.remove(self.unusedControllers, size)
    return c
end

function mt:debugInfo()
    local res = "unbinded = { "
    for i, c in ipairs(self.unbindedControllers) do
        res = res .. c:getID() .. ", "
    end
    res = res .. "} - binded = { "
    for i, c in ipairs(self.bindedControllers) do
        res = res .. i .. " = " .. c:getID() .. ", "
    end
    res = res .. "}"
    return res
end

function mt:updateAll(dt)
	for _,c in ipairs(self.bindedControllers) do
		c:update(dt)
	end
end