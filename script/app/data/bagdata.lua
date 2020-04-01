local ClassEquipObj = require('script/app/obj/equipobj')
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassGemObj = require('script/app/obj/gemobj')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')
local ClassItemObj = require('script/app/obj/itemobj')
local ClassDressObj = require('script/app/obj/dressobj')
local ClassDragonGemObj = require('script/app/obj/dragongemobj')
local ClassLimitItemObj = require('script/app/obj/limititemobj')

cc.exports.BagData = {
	equipMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
	},
	equipNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
	},
	itemNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
		[9] = 0,
	},
	dragongemMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	},
	dragongemNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	},
	exclusiveMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	},
	exclusiveNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	},
	gemMap = {},
	gemNum = {},
	roleCardMap = {},
	roleCardNum = 0,
	fragmentMap = {},
	fragmentNum = 0,
	materialMap = {},
	materialNum = 0,
	dressMap = {},
	dressNum = 0,
	limitMatMap = {},
	limitMatNum = 0,
}

local MAX_NUM = {
	[1] = -1,
	[2] = -1,
	[3] = 200,
	[4] = -1,
	[5] = -1,
	[6] = -1,
	[7] = 200,
	[8] = 50,
}

cc.exports.ITEM_TYPE = {
	MATERIAL = 1,
	CARD = 2,
	EQUIP = 3,
	FRAGMENT = 4,
	GEM = 5,
	DRESS = 6,
	DRAGONGEM = 7,
	LIMITMAT = 8,
	EXCLUSIVE = 9,
}

function BagData:removeAllData()
	self.equipMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
	}
	self.equipNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
	}
	self.itemNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
        [9] = 0,
	}
	self.dragongemMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	}
	self.dragongemNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	}
	self.exclusiveMap = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
	}
	self.exclusiveNum = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	}
	self.gemMap = {}
	self.gemNum = {}
	self.roleCardMap = {}
	self.roleCardNum = 0
	self.fragmentMap = {}
	self.fragmentNum = 0
	self.materialMap = {}
	self.materialNum = 0
	self.dressMap = {}
	self.dressNum = 0
	self.limitMatMap = {}
	self.limitMatNum = 0
end

-- ↓↓↓↓↓↓从登陆的json解析背包数据↓↓↓↓↓↓
function BagData:parseBagData(jsonData)
	for k, v in pairs(jsonData) do
		if k == "material" then
			self:parseMaterial(v)
		elseif k == "card" then
			self:parseCard(v)
		elseif k == "equip" then
			self:parseEquip(v)
		elseif k == "fragment" then
			self:parseFragment(v)
		elseif k == "gem" then
			self:parseGem(v)
		elseif k == "dress" then
			self:parseDress(v)
		elseif k == "dragon" then
			self:parseDragonGem(v)
		elseif k == "limitmat" then
			self:parseLimitMat(v)
		elseif k == "exclusive" then
			self:parseExclusive(v)
		end
	end
end

function BagData:parseMaterial(materialData)
	for id, v in pairs(materialData) do
		local materialobj = ClassItemObj.new(tonumber(id), v,false)
		self:addItem(ITEM_TYPE.MATERIAL, materialobj)
	end
end

function BagData:parseCard(cardData)
	for id, v in pairs(cardData) do
		local rolecard = ClassRoleObj.new(tonumber(id),v)
		self:addItem(ITEM_TYPE.CARD,rolecard)
	end
end

function BagData:parseEquip(equipData)
	for sid, v in pairs(equipData) do
		local equipObj = ClassEquipObj.new(tonumber(sid), v)
		if v.pos == 0 then -- 背包里的装备
			self:addItem(ITEM_TYPE.EQUIP, equipObj)
		else -- 人物身上的装备
			RoleData:putOnEquip(v.pos, equipObj)
		end
	end
end

function BagData:parseLimitMat(limitData)
	for sid, v in pairs(limitData) do
		local limititemobj = ClassLimitItemObj.new(tonumber(sid), v)
		self:addItem(ITEM_TYPE.LIMITMAT, limititemobj)
	end
end

function BagData:parseDragonGem(dragongemData)
	for sid, v in pairs(dragongemData) do
		local dragongemObj = ClassDragonGemObj.new(tonumber(sid), v)
		if v.dragon == 0 then
			self:addItem(ITEM_TYPE.DRAGONGEM, dragongemObj)
		else -- 穿戴到龙身上
			RoleData:mountDragonGem(v.dragon, dragongemObj)
		end
	end
end

function BagData:parseFragment(fragmentData)
	for id, v in pairs(fragmentData) do
		local materialobj = ClassItemObj.new(tonumber(id), v)
		self:addItem(ITEM_TYPE.FRAGMENT,materialobj)
	end
end

function BagData:parseGem(gemData)
	for id, v in pairs(gemData) do
		local gemObj = ClassGemObj.new(tonumber(id), v)
		self:addItem(ITEM_TYPE.GEM, gemObj)
	end
end

function BagData:parseExclusive(exclusiveData)
	for id, v in pairs(exclusiveData) do
		local exclusiveObj = ClassExclusiveObj.new(tonumber(id), v)
		self:addItem(ITEM_TYPE.EXCLUSIVE, exclusiveObj)
	end
end

function BagData:parseDress(dressData)
	for id, v in pairs(dressData) do
		local dressObj = ClassDressObj.new(tonumber(id), v,false)
		self:addItem(ITEM_TYPE.DRESS, dressObj)
	end
end

-- ↑↑↑↑↑↑从登陆的json解析背包数据↑↑↑↑↑↑

-- ↓↓↓↓↓↓从服务器发来的数组解析背包数据↓↓↓↓↓↓
function BagData:parseMaterialAward(awardData)
	local noNewLevel = tonumber(GlobalApi:getGlobalValue('bagNewItemLimitLevel'))
	local level = UserData:getUserObj():getLv()
	local isNew = false
	if awardData[3] > 0 and level < noNewLevel then
		isNew = true
	end
	local materialobj = ClassItemObj.new(awardData[2], awardData[3],isNew)
	self:addItem(ITEM_TYPE.MATERIAL, materialobj,isNew)
end

function BagData:parseCardAward(awardData)
	local rolecard = ClassRoleObj.new(awardData[2], awardData[3])
	self:addItem(ITEM_TYPE.CARD, rolecard)
end

function BagData:parseGemAward(awardData)
	local gemObj = ClassGemObj.new(awardData[2], awardData[3])
	self:addItem(ITEM_TYPE.GEM, gemObj)
end

function BagData:parseExclusiveAward(awardData)
	local gemObj = ClassExclusiveObj.new(awardData[2], awardData[3])
	self:addItem(ITEM_TYPE.EXCLUSIVE, gemObj)
end

function BagData:parseFragmentAward(awardData)
	local materialobj = ClassItemObj.new(awardData[2], awardData[3])
	self:addItem(ITEM_TYPE.FRAGMENT, materialobj)
end

function BagData:parseEquipAward(awardData)
	if type(awardData[3]) == "number" then
		self:reduceItem(ITEM_TYPE.EQUIP, awardData[2])
	else
		local equipObj = ClassEquipObj.new(awardData[2], awardData[3])
		self:addItem(ITEM_TYPE.EQUIP, equipObj)
	end
end

function BagData:parseLimitMatAward(awardData)
	if type(awardData[3]) == "number" then
		self:reduceItem(ITEM_TYPE.LIMITMAT, awardData[2],awardData[3])
	else
		local limititemobj = ClassLimitItemObj.new(awardData[2], awardData[3])
		self:addItem(ITEM_TYPE.LIMITMAT, limititemobj)
	end
end

function BagData:parseDressAward(awardData)
	local noNewLevel = tonumber(GlobalApi:getGlobalValue('bagNewItemLimitLevel'))
	local level = UserData:getUserObj():getLv()
	local isNew = false
	if awardData[3] > 0 and level < noNewLevel then
		isNew = true
	end
	local dressObj = ClassDressObj.new(awardData[2], awardData[3],isNew)
	self:addItem(ITEM_TYPE.DRESS, dressObj,isNew)
end

function BagData:parseDragonGemAward(awardData)
	if type(awardData[3]) == "number" then
		self:reduceItem(ITEM_TYPE.DRAGONGEM, awardData[2])
	else
		local dragongemObj = ClassDragonGemObj.new(awardData[2], awardData[3])
		if awardData[3].dragon == 0 then
			self:addItem(ITEM_TYPE.DRAGONGEM, dragongemObj)
		else -- 穿戴到龙身上
			RoleData:mountDragonGem(awardData[3].dragon, dragongemObj)
		end
	end
end
-- ↑↑↑↑↑↑从服务器发来的数组解析背包数据↑↑↑↑↑↑

-- ↓↓↓↓↓↓背包添加一个物品↓↓↓↓↓↓
function BagData:addItem(itemType, obj,isNew)
	local flag = 0
	if itemType == ITEM_TYPE.MATERIAL then
		flag = self:addMaterial(obj,isNew)
	elseif itemType == ITEM_TYPE.CARD then
		flag = self:addCard(obj)
	elseif itemType == ITEM_TYPE.EQUIP then
		flag = self:addEquip(obj)
	elseif itemType == ITEM_TYPE.FRAGMENT then
		flag = self:addFragment(obj)
	elseif itemType == ITEM_TYPE.GEM then
		flag = self:addGem(obj)
	elseif itemType == ITEM_TYPE.DRESS then
		flag = self:addDress(obj,isNew)
	elseif itemType == ITEM_TYPE.DRAGONGEM then
		flag = self:addDragonGem(obj)
	elseif itemType == ITEM_TYPE.LIMITMAT then
		flag = self:addLimitMat(obj)
	elseif itemType == ITEM_TYPE.EXCLUSIVE then
		flag = self:addExclusive(obj)
	end
	if flag then
		self.itemNum[itemType] = self.itemNum[itemType] + flag
	end
end

function BagData:addMaterial(newObj,isNew)
	local id = newObj:getId()
	local materialObj = self.materialMap[id]
	if materialObj then
		materialObj:addNum(newObj:getNum())
		materialObj:setNew(isNew)
		if materialObj:getNum() <= 0 then
			self.materialMap[id] = nil
			self.materialNum = self.materialNum - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.materialMap[id] = newObj
			self.materialNum = self.materialNum + 1
			return 1
		end
	end
	return 0
end

function BagData:addCard(newObj)
	local id = newObj:getId()
	local cardObj = self.roleCardMap[id]
	if cardObj and cardObj ~= 0 then
		cardObj:addNum(newObj:getNum())
		if cardObj:getNum() <= 0 then
			self.roleCardMap[id] = 0
			self.roleCardNum = self.roleCardNum - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.roleCardMap[id] = newObj
			self.roleCardNum = self.roleCardNum + 1
			return 1
        elseif newObj:getNum() == 0 then
            self.roleCardMap[id] = 0
            return 0
		end
	end
	return 0
end

function BagData:addEquip(equipObj)
	local equipType = equipObj:getType()
	local sid = equipObj:getSId()
	if not self.equipMap[equipType][sid] then
		self.equipMap[equipType][sid] = equipObj
		self.equipNum[equipType] = self.equipNum[equipType] + 1
		return 1
	end
	return 0
end

function BagData:addLimitMat(limitObj)
	local sid = limitObj:getSId()
	if not self.limitMatMap[tonumber(sid)] then
		self.limitMatMap[tonumber(sid)] = limitObj
		self.limitMatNum = self.limitMatNum + 1
		return 1
	end
	return 0
end

function BagData:addDragonGem(newObj)
	local dragongemType = newObj:getType()
	local sid = newObj:getSId()
	if not self.dragongemMap[dragongemType][sid] then
		self.dragongemMap[dragongemType][sid] = newObj
		self.dragongemNum[dragongemType] = self.dragongemNum[dragongemType] + 1
		return 1
	end
	return 0
end

function BagData:addFragment(newObj)
	local id = newObj:getId()
	local fragmentObj = self.fragmentMap[id]
	if fragmentObj then
		fragmentObj:addNum(newObj:getNum())
		if fragmentObj:getNum() <= 0 then
			self.fragmentMap[id] = nil
			self.fragmentNum = self.fragmentNum - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.fragmentMap[id] = newObj
			self.fragmentNum = self.fragmentNum + 1
			return 1
		end
	end
	return 0
end

function BagData:addExclusive(newObj)
	local exclusiveType = newObj:getType()
	local exclusiveId = newObj:getId()
	self.exclusiveMap[exclusiveType] = self.exclusiveMap[exclusiveType] or {}
	self.exclusiveNum[exclusiveType] = self.exclusiveNum[exclusiveType] or 0
	local exclusiveObj = self.exclusiveMap[exclusiveType][exclusiveId]
	if exclusiveObj then
		local exclusiveNum = newObj:getNum()
		exclusiveObj:addNum(exclusiveNum)
		if exclusiveObj:getNum() <= 0 then
			self.exclusiveMap[exclusiveType][exclusiveId] = nil
			self.exclusiveNum[exclusiveType] = self.exclusiveNum[exclusiveType] - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.exclusiveMap[exclusiveType][exclusiveId] = newObj
			self.exclusiveNum[exclusiveType] = self.exclusiveNum[exclusiveType] + 1
			return 1
		end
	end
	return 0
end

function BagData:addGem(newObj)
	local gemType = newObj:getType()
	local gemId = newObj:getId()
	self.gemMap[gemType] = self.gemMap[gemType] or {}
	self.gemNum[gemType] = self.gemNum[gemType] or 0
	local gemObj = self.gemMap[gemType][gemId]
	if gemObj then -- 已经有这个宝石了
		local gemNum = newObj:getNum()
		gemObj:addNum(gemNum)
		if gemObj:getNum() <= 0 then
			self.gemMap[gemType][gemId] = nil
			self.gemNum[gemType] = self.gemNum[gemType] - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.gemMap[gemType][gemId] = newObj
			self.gemNum[gemType] = self.gemNum[gemType] + 1
			return 1
		end
	end
	return 0
end

function BagData:addDress(newObj,isNew)
	local id = newObj:getId()
	local dressObj = self.dressMap[id]
	if dressObj then
		dressObj:addNum(newObj:getNum())
		dressObj:setNew(isNew)
		if dressObj:getNum() <= 0 then
			self.dressMap[id] = nil
			self.dressNum = self.dressNum - 1
			return -1
		end
	else
		if newObj:getNum() > 0 then
			self.dressMap[id] = newObj
			self.dressNum = self.dressNum + 1
			return 1
		end
	end
	return 0
end

-- ↑↑↑↑↑↑背包添加一个物品↑↑↑↑↑↑

-- ↓↓↓↓↓↓背包减少一个物品↓↓↓↓↓↓
function BagData:reduceItem(itemType, obj, number)
	local flag = 0
	if itemType == ITEM_TYPE.MATERIAL then
		flag = self:reduceMaterial(obj)
	elseif itemType == ITEM_TYPE.CARD then
		flag = self:reduceCard(obj)
	elseif itemType == ITEM_TYPE.EQUIP then
		flag = self:reduceEquip(obj)
	elseif itemType == ITEM_TYPE.FRAGMENT then
		flag = self:reduceFragment(obj)
	elseif itemType == ITEM_TYPE.GEM then
		flag = self:reduceGem(obj)
	elseif itemType == ITEM_TYPE.DRESS then
		flag = self:reduceDress(obj)
	elseif itemType == ITEM_TYPE.DRAGONGEM then
		flag = self:reduceDragongem(obj)
	elseif itemType == ITEM_TYPE.LIMITMAT then
		flag = self:reduceLimitMat(obj,number)
	elseif itemType == ITEM_TYPE.EXCLUSIVE then
		flag = self:reduceExclusive(obj)
	end
	if flag then
		self.itemNum[itemType] = self.itemNum[itemType] + flag
	end
end

function BagData:reduceCard(cardObj)
	local id = cardObj:getId()
	if self.roleCardMap[id] and self.roleCardMap[id] ~= 0 then
		local cardnum = cardObj:getNum()
		self.roleCardMap[id]:addNum(-cardnum)
		if self.roleCardMap[id]:getNum() <= 0 then
			self.roleCardMap[id] = 0
			self.roleCardNum = self.roleCardNum - 1
			return -1
		end
	end
	return 0	
end

function BagData:reduceEquip(equipObj)
	local sid = 0
	if type(equipObj) == "number" then
	 	sid = equipObj
	else
		sid = equipObj:getSId()
	end
	
	for i = 1, 6 do
		if self.equipMap[i][sid] then
			self.equipMap[i][sid] = nil
			self.equipNum[i] = self.equipNum[i] - 1
			return -1
		end
	end
	return 0
end

function BagData:reduceLimitMat(sid,number)
	sid = tonumber(sid)
	if self.limitMatMap[tonumber(sid)] then
		self.limitMatMap[tonumber(sid)]:addNum(number)
		if self.limitMatMap[tonumber(sid)]:getNum() <= 0 then
			self.limitMatMap[tonumber(sid)] = nil
			self.limitMatNum = self.limitMatNum - 1
			return -1
		end
	end
	return 0
end

function BagData:reduceLimitMatByTime(sid)
	self.limitMatMap[tonumber(sid)] = nil
end

function BagData:reduceDragongem(dragongemObj)
	local sid = 0
	if type(dragongemObj) == "number" then
	 	sid = dragongemObj
	else
		sid = dragongemObj:getSId()
	end
	for i = 1, 4 do
		if self.dragongemMap[i][sid] then
			self.dragongemMap[i][sid] = nil
			self.dragongemNum[i] = self.dragongemNum[i] - 1
			return -1
		end
	end
	return 0
end

function BagData:reduceMaterial(itemObj)
	local id = itemObj:getId()
	if self.materialMap[id] then
		local materialNum = itemObj:getNum()
		self.materialMap[id]:addNum(-materialNum)
		if self.materialMap[id]:getNum() <= 0 then
			self.materialMap[id] = nil
			self.materialNum = self.materialNum - 1
			return -1
		end
	end
	return 0
end

function BagData:reduceFragment(itemObj)
	local id = itemObj:getId()
	if self.fragmentMap[id] then
		local fragmentnum = itemObj:getNum()
		self.fragmentMap[id]:addNum(-fragmentnum)
		if self.fragmentMap[id]:getNum() <= 0 then
			self.fragmentMap[id] = nil
			self.fragmentNum = self.fragmentNum - 1
			return -1
		end
	end
	return 0	
end

function BagData:reduceExclusive(exclusiveObj)
	local exclusiveType = exclusiveObj:getType()
	local exclusiveId = exclusiveObj:getId()
	if self.exclusiveMap[exclusiveType] then
		if self.exclusiveMap[exclusiveType][exclusiveId] then
			local exclusiveNum = exclusiveObj:getNum()
			self.exclusiveMap[exclusiveType][exclusiveId]:addNum(-exclusiveNum)
			if self.exclusiveMap[exclusiveType][exclusiveId]:getNum() <= 0 then
				self.exclusiveMap[exclusiveType][exclusiveId] = nil
				self.exclusiveNum[exclusiveType] = self.exclusiveNum[exclusiveType] - 1
				return -1
			end
		end
	end
	return 0
end

function BagData:reduceGem(gemObj)
	local gemType = gemObj:getType()
	local gemId = gemObj:getId()
	if self.gemMap[gemType] then
		if self.gemMap[gemType][gemId] then
			local gemNum = gemObj:getNum()
			self.gemMap[gemType][gemId]:addNum(-gemNum)
			if self.gemMap[gemType][gemId]:getNum() <= 0 then
				self.gemMap[gemType][gemId] = nil
				self.gemNum[gemType] = self.gemNum[gemType] - 1
				return -1
			end
		end
	end
	return 0
end

function BagData:reduceGemByClient(gemObj,gemNum)
	local gemType = gemObj:getType()
	local gemId = gemObj:getId()
	if self.gemMap[gemType] then
		if self.gemMap[gemType][gemId] then
			self.gemMap[gemType][gemId]:addNum(-gemNum)
			if self.gemMap[gemType][gemId]:getNum() <= 0 then
				self.gemMap[gemType][gemId] = nil
				self.gemNum[gemType] = self.gemNum[gemType] - 1
				return -1
			end
		end
	end
	return 0
end

function BagData:reduceDress(dressObj)
	local id = dressObj:getId()
	if self.dressMap[id] then
		local dressnum = dressObj:getNum()
		self.dressMap[id]:addNum(-dressnum)
		if self.dressMap[id]:getNum() <= 0 then
			self.dressMap[id] = nil
			self.dressNum = self.dressNum - 1
			return -1
		end
	end
	return 0
end
-- ↑↑↑↑↑↑背包减少一个物品↑↑↑↑↑↑

function BagData:getEquipMapById(id)
	local equip = nil
	for i,v in ipairs(self.equipMap) do
		for k,j in pairs(v) do
			if tonumber(id) == j:getSId() then
				equip = j
				return equip
			end
		end
	end
end

function BagData:getEquipMapByType(type)
	return self.equipMap[type]
end

function BagData:getAllEquips()
	return self.equipMap
end

function BagData:getEquipNumByPos(pos)
	return self.equipNum[pos]
end

function BagData:getEquipFull()
    local num = 0
    for i=1,6 do
        local n = self:getEquipNumByPos(i)
        num = num + (n or 0)
    end
    if not UserData:getUserObj() then
    	return false
    end
    local valume = UserData:getUserObj():getEquipValume()
    if num >= valume then
        return true
    end
    return false
end

function BagData:getDragongemMapById(id)
	local Dragongem = nil
	for i,v in ipairs(self.dragongemMap) do
		for k,j in pairs(v) do
			if tonumber(id) == j:getSId() then
				Dragongem = j
				return Dragongem
			end
		end
	end
end

function BagData:getDragongemMapByType(type)
	return self.dragongemMap[type]
end

function BagData:getDragongemNumByPos(pos)
	return self.dragongemNum[pos]
end

function BagData:getDragongemTotalNum()
	local num = 0
	for k, v in ipairs(self.dragongemNum) do
		num = num + v
	end
	return num
end

function BagData:getDragongemFull()
    local num = 0
    for i=1,4 do
        local n = self:getDragongemNumByPos(i)
        num = num + (n or 0)
    end
    if not UserData:getUserObj() then
    	return false
    end
    local valume = UserData:getUserObj():getDragonGemValume()
    if num >= valume then
        return true
    end
    return false
end

function BagData:getAllDragongems()
	return self.dragongemMap
end

function BagData:getDragonGemById(dragonType, id)
	return self.dragongemMap[dragonType][id]
end

function BagData:getAllExclusive()
	return self.exclusiveMap
end

function BagData:getExclusiveById(id)
	local exclusiveType = math.floor(id/100)
	if self.exclusiveMap[exclusiveType] then
		return self.exclusiveMap[exclusiveType][id]
	end
	return nil
end

function BagData:getExclusiveObjById(id)
	local exclusiveType = math.floor(id/100)
	local obj
	if self.exclusiveMap[exclusiveType] then
		obj = self.exclusiveMap[exclusiveType][id]
	end
	if not obj then
		obj = ClassExclusiveObj.new(id, 0)
	end
	return obj
end

function BagData:getAllGems()
	return self.gemMap
end

function BagData:getGemById(id)
	local gemType = math.floor(id/100)
	if self.gemMap[gemType] then
		return self.gemMap[gemType][id]
	end
	return nil
end

function BagData:getGemObjById(id)
	local gemType = math.floor(id/100)
	local obj
	if self.gemMap[gemType] then
		obj = self.gemMap[gemType][id]
	end
	if not obj then
		obj = ClassGemObj.new(id, 0)
	end
	return obj
end

function BagData:getItemNum(itemType)
	return self.itemNum[itemType]
end

function BagData:isItemFull(itemType)
	return self.itemNum[itemType] >= MAX_NUM[itemType]
end

function BagData:getMaterialById(id)
	if not self.materialMap[id] then
		local materialobj = ClassItemObj.new(id, 0)
		return materialobj
	else
		return self.materialMap[id]
	end
end

function BagData:getAllMaterial()
	return self.materialMap
end

function BagData:getFragmentNum()
	return self.fragmentNum
end

function BagData:getFragment()
	return self.fragmentMap
end

function BagData:getFragmentById(id)
	return self.fragmentMap[id]
end

function BagData:getAllLimitMat()
	return self.limitMatMap
end

function BagData:getAllCards()
    local roleCardMap = self.roleCardMap
    local temp = {}
    for k,v in pairs(roleCardMap) do
        if v ~= 0 then
            temp[k] = v
        end
    end

	return temp
end

function BagData:getCardById(id)
    if self.roleCardMap[id] and self.roleCardMap[id] == 0 then
        return nil
    end

	return self.roleCardMap[id]
end

function BagData:getCardNum()
	return self.roleCardNum
end

function BagData:getAllDresses()
	return self.dressMap
end

function BagData:getDressByIdForShop(id)
	local obj = self.dressMap[id]
	if obj == nil then
		obj = ClassDressObj.new(tonumber(id),0)
	end
	return obj
end

function BagData:getDressById(id)
	return self.dressMap[id]
end

function BagData:getDressNum()
	return self.dressNum
end

function BagData:getLimitMatBySid(sid)
	return self.limitMatMap[tonumber(sid)]
end

function BagData:getLimitMatNum()
	return self.limitMatNum
end

function BagData:getLimitMatNumById(id)
	local num = 0
	for k,v in pairs(self.limitMatMap) do
		if v.id == id then
			num = num + v.num
		end
	end
	return num 
end
function BagData:getBagobjByObj(obj)
	local bagobj
	local typestr = obj:getObjType()
	if typestr =='material' then
		bagobj = self:getMaterialById(obj:getId())
	elseif typestr == 'card' then
		bagobj = self:getCardById(obj:getId())
	elseif typestr == 'fragment' then
		bagobj = self:getFragmentById(obj:getId())
	elseif typestr == 'gem' then
		bagobj = self:getGemById(obj:getId())
	elseif typestr == 'dress' then
		bagobj = self:getDressById(obj:getId())
	elseif typestr == 'limitmat' then
		bagobj = self:getLimitMatBySid(obj:getId())
	end
	if not bagobj then
		return obj
	end
	return bagobj
end