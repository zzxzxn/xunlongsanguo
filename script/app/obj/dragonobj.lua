local ClassDragonGemObj = require('script/app/obj/dragongemobj')
local DragonObj = class("DragonObj")

function DragonObj:ctor(id, obj)
	self.id = id
	self.level = obj.level
	self.gems = {}
	self.baseAttr = {}
	self.attr = {}
	self.attr_check = {}
	local treasureConf = GameData:getConfData("treasure")
	local dragonMap = RoleData:getDragonMap()
	local attrCoefficients = {}
	for k, v in pairs(dragonMap) do
		local gems = v:getGems()
		for k2, v2 in pairs(gems) do
			attrCoefficients[v2:getAttId()] = attrCoefficients[v2:getAttId()] or 0
			attrCoefficients[v2:getAttId()] = attrCoefficients[v2:getAttId()] + v2:getAttNum()
		end
	end
	local maxActive = #treasureConf[id]
	local attr = {}
	for i = 1, maxActive do
		for k = 1, 4 do
			local baseValue = treasureConf[id][i]["value"..k]
			local attrId = treasureConf[id][i]["attr"..k]
			local value
			if attrCoefficients[attrId] then
				value = baseValue*(1 + attrCoefficients[attrId]/100)
			else
				value = baseValue
			end
			self.baseAttr[attrId] = (self.baseAttr[attrId] or 0) + baseValue
			attr[attrId] = (attr[attrId] or 0) + value
		end
	end
	for k, v in pairs(attr) do
		self.attr_check[k] = GlobalApi:fuckAttribute(v)
		self.attr[k] = v
	end
	self.gemsTotalLevel = 0
end

function DragonObj:getId()
	return self.id
end

function DragonObj:getLevel()
	return self.level
end

function DragonObj:getUrl()
	local conf = GameData:getConfData("treasure")
	return conf[self.id][#conf[self.id]].url
end

function DragonObj:setLevel(level)
	self.level = level
end
-- 镶嵌龙晶
function DragonObj:mountDragonGem(slotIndex, dragonGemObj)
	if self.gems[slotIndex] then -- 这个位置有宝石
		self.gemsTotalLevel = self.gemsTotalLevel - self.gems[slotIndex]:getLevel()
		self.gems[slotIndex]:demount()
	end
	self.gemsTotalLevel = self.gemsTotalLevel + dragonGemObj:getLevel()
	dragonGemObj:mount(self.id)
	self.gems[slotIndex] = dragonGemObj
end
-- 卸下龙晶
function DragonObj:demount(slotIndex)
	if self.gems[slotIndex] then
		self.gemsTotalLevel = self.gemsTotalLevel - self.gems[slotIndex]:getLevel()
		self.gems[slotIndex]:demount()
		self.gems[slotIndex] = nil
	end
end

function DragonObj:getDragonGemBySlot(slotIndex)
	return self.gems[slotIndex]
end

function DragonObj:getDragonGemTotalLevel()
	return self.gemsTotalLevel
end

function DragonObj:getGems()
	return self.gems
end

function DragonObj:upgrade()
	self.level = self.level + 1
end

function DragonObj:updateAttr(id, value)
	local diffV = self.baseAttr[id]*value
	local currValue = GlobalApi:defuckAttribute(self.attr_check[id])
	currValue = currValue + diffV
	self.attr_check[id] = GlobalApi:fuckAttribute(currValue)
	self.attr[id] = currValue
end

function DragonObj:getAttr()
	for k, v in pairs(self.attr) do
		GlobalApi:checkAttribute(v, self.attr_check[k])
	end
	return self.attr
end

function DragonObj:getChangeEquipState(customObj)
	local s = {}
	if customObj and customObj.advanced then
		s.advanced = customObj.advanced
	else
		s.advanced = self.level
	end
	return s
end

return DragonObj