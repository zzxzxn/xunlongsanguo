local ClassGemObj = require('script/app/obj/gemobj')
local EquipObj = class("EquipObj")

local ANCIENT_ID_START = 900000

local function creatDefaultObj()
	local FAKE_OBJ = {
		id = 0,
		xp = 0,
		god = 0,
		god_id = 0,
		gems = {},
		pos = 0,
		subattr = {}
	}
	return FAKE_OBJ
end

local GOD_EQUIP_COLOR = {"RED", "RED"}

function EquipObj:ctor(sid, obj, god_id)
	local attributeConf = GameData:getConfData("attribute")
	if obj == nil then
		obj = creatDefaultObj()
		obj.id = sid
		if god_id and god_id > 0 then
			obj.god_id = god_id
			obj.god = 1
		end
	end
	self.sid = sid                          -- 区分不同装备的唯一的id
	self.id = obj.id
	local equipConf = GameData:getConfData("equip")[tonumber(obj.id)]
	self.baseConf = equipConf
	self.xp = obj.xp
	self.god = obj.god
	-- 装备的基础属性，对应attribute表，分别是
	self.allAttr = {}
	self.allAttr_check = {}
	for i=1,#attributeConf do
		self.allAttr[i] = 0
		self.allAttr_check[i] = GlobalApi:fuckAttribute(0)
	end
	-- 	[1] = 0,        -- 攻击
	-- 	[2] = 0,		-- 物防
	-- 	[3] = 0,		-- 法防
	-- 	[4] = 0,		-- 生命
	-- 	[5] = 0,		-- 命中
	-- 	[6] = 0,		-- 闪避
	-- 	[7] = 0,		-- 暴击
	-- 	[8] = 0,		-- 韧性
	-- 	[9] = 0,		-- 移动速度
	-- 	[10] = 0,		-- 攻击速度
	-- 	[11] = 0,		-- 伤害加成
	-- 	[12] = 0,		-- 伤害减免
	-- 	[13] = 0,		-- 暴击伤害
	-- 	[14] = 0,		-- 无视防御几率
	-- 	[15] = 0,		-- 5秒回血
	-- 	[16] = 0,		-- 掉落道具加成
	-- 	[17] = 0,		-- 掉落金币加成
	-- 	[18] = 0,		-- 初始怒气
	-- 	[19] = 0,		-- 怒气回复速度
	-- }
	-- 神器属性
	self.godId = obj.god_id
	self.godAttr = {}
	self.swallowCost = 0
	--self.inheritCost = 0
	self.nextXp = 0
	-- 这件装备所装备的位置
	self.pos = obj.pos
	if self.god and self.god > 0 then
		local godEquipConf = GameData:getConfData("godequip")
		local godEquipObj = godEquipConf[equipConf.type][self.god]
		if self.godId == 3 then -- 两个神器属性
			self.nextXp = godEquipObj.doubleAttExp
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att1"]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value1"]
			self.godAttr[1]["double"] = false
			self.godAttr[1]["doubleatt"] = 0
			self.godAttr[1]['type'] = godEquipObj["valuetype1"]
			self.godAttr[1]["color"] = GOD_EQUIP_COLOR[1]
			self.godAttr[2] = {}
			local attrId2 = godEquipObj["att2"]
			self.godAttr[2]["id"] = attrId2
			self.godAttr[2]["name"] = attributeConf[attrId2].name
			self.godAttr[2]["value"] = godEquipObj["value2"]
			self.godAttr[2]["double"] = false
			self.godAttr[2]["doubleatt"] = 0
			self.godAttr[2]['type'] = godEquipObj["valuetype2"]
			self.godAttr[2]["color"] = GOD_EQUIP_COLOR[2]
			self:updateAllAttr(attrId1, godEquipObj["value1"])
			self:updateAllAttr(attrId2, godEquipObj["value2"])
		else
			self.nextXp = godEquipObj.maxExp
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att" .. self.godId]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value" .. self.godId]
			self.godAttr[1]["double"] = false
			self.godAttr[1]["doubleatt"] = 0
			self.godAttr[1]['type'] = godEquipObj["valuetype".. self.godId]
			self.godAttr[1]["color"] = GOD_EQUIP_COLOR[self.godId]
			self:updateAllAttr(attrId1, godEquipObj["value" .. self.godId])
		end
		self.swallowCost = -godEquipObj.swallowCost[1][3]
		
	end
	self.inheritCost = -self.baseConf.inheritCost
	-- 装备宝石
	self.gems = {}
	for k, v in pairs(obj.gems) do
		local gemObj = ClassGemObj.new(tonumber(v), 1)
		self.gems[tonumber(k)] = gemObj
		local attrId = gemObj:getAttrId()
		self:updateAllAttr(attrId, gemObj:getValue())
	end
	-- 装备主属性
	local mainAttribute = {}
	mainAttribute.name = attributeConf[equipConf.attributeType].name
	mainAttribute.value = equipConf.attributeValue
	self.mainAttribute = mainAttribute
	self:updateAllAttr(equipConf.attributeType, mainAttribute.value)
	-- 装备副属性
	self.subAttr = {}
	self.subAttrNum = 0
	for k, v in pairs(obj.subattr) do
		local attribute = {}
		attribute.name = attributeConf[tonumber(k)].name
		attribute.value = v
		self.subAttr[tonumber(k)] = attribute
		self:updateAllAttr(tonumber(k), v)
		self.subAttrNum = self.subAttrNum + 1
	end
	-- 装备战斗力
	--self.fightForce = self:CalcFightForce()
end

function EquipObj:getObjType()
	return 'equip'
end
-- 配表里对应的装备id
function EquipObj:getId()
	return self.id
end

-- 唯一id
function EquipObj:getSId()
	return self.sid
end

-- 名称
function EquipObj:getName()
	return self.baseConf.name
end

-- 名称颜色
function EquipObj:getNameColor()
	if self.god > 0 or self:isAncient() then -- 神器固定显示红色
		return COLOR_QUALITY[6]
	else
		return COLOR_QUALITY[self.baseConf.quality]
	end
end

function EquipObj:judgeHasDrop()
    local judge = false
    local useEffect = self.baseConf.useEffect
    if useEffect then
        local tab = string.split(useEffect,'.')
        if tab and tab[1] == 'drop' then
	        local tab2 = string.split(tab[2],':')
            local dropId = tab2[1]
            if tonumber(dropId) == 5006 or tonumber(dropId) == 5007 or tonumber(dropId) == 5008 or tonumber(dropId) == 5009 or tonumber(dropId) == 5010 then
                judge = false
            else
                judge = true
            end
        end
    end
    return judge
end

-- 描边颜色
function EquipObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY
end

-- 类型:1-6 对应6个装备位
function EquipObj:getType()
	return self.baseConf.type
end

function EquipObj:getColorType()
	return self.baseConf.color
end

function EquipObj:getBgImg()
	return COLOR_FRAME_TYPE[self.baseConf.color]
end

-- 图标
function EquipObj:getIcon()
	return "uires/icon/equip/" .. self.baseConf.icon
end

-- 边框
function EquipObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 等级
function EquipObj:getLevel()
	return self.baseConf.level
end

-- 战斗力
function EquipObj:getFightForce()
	local attconf =GameData:getConfData('attribute')
	local  fightforce = 0
	local att = self.allAttr
	for i=1,#attconf do
		fightforce = fightforce + math.floor(att[i]*attconf[i].factor)
	end
	return fightforce
end

function EquipObj:getFightForcePre(attarr)
	local arr = attarr
	local attconf =GameData:getConfData('attribute')
	local  fightforce = 0
	for i=1,#attconf do
		fightforce = fightforce + math.floor(arr[i]*attconf[i].factor)
	end
	return fightforce
end
-- 主属性
function EquipObj:getMainAttribute()
	return self.mainAttribute
end

-- 副属性
function EquipObj:getSubAttribute()
	return self.subAttr
end

-- 副属性数量
function EquipObj:getSubAttrNum()
	return self.subAttrNum
end

-- 更新副属性
function EquipObj:updateSubAttr(subattr)
	for k, v in pairs(subattr) do
		local index = tonumber(k)
		self:updateAllAttr(index, v - self.subAttr[index].value)
		self.subAttr[index].value = v
	end
end

-- 品质
function EquipObj:getQuality()
	return self.baseConf.quality
end

-- 洗练花费金币
function EquipObj:getRefineCost(i)
	if i >= 4 then
		return 0
	else
		return self.baseConf['refineCost'..i]
	end
end

-- 描述
function EquipObj:getDesc()
	return self.baseConf.desc
end

-- 出售价格
function EquipObj:getSellPrice()
	return self.baseConf.sellPrice
end

-- 宝石
function EquipObj:getGems()
	return self.gems
end

-- 可装备的宝石数量
function EquipObj:getMaxGem()
	local gemTab = BagData:getAllGems()
	local gems = {}
	for i=1,4 do
		local tab = gemTab[i]
		local gid = 0
		if tab then
			for k,v in pairs(tab) do
				if v:getId() > gid and v:getNum() > 0 then
					gems[i] = {gid = v:getId()}
					gid = v:getId()
				end
			end
		end
	end
	local hadGem = {}
	for k,v in pairs(self.gems) do
		hadGem[tonumber(k)] = 1
		local id = math.floor(v:getId()/100)
		if not gems[id] or gems[id].gid <= v:getId() then
			gems[id] = nil
		else
			gems[id].slot = tonumber(k)
		end
	end

	for i=1,4 do
		if not hadGem[i] then
			for k,v in pairs(gems) do
				if not v.slot then
					gems[k].slot = i
					break
				end
			end
		end
	end
	return gems
end

-- 是否有可镶嵌的宝石
function EquipObj:getGemUp(index)
	local gemTab = BagData:getAllGems()
	local gem = self.gems[index]
	if not gem then
		return self:getEmptyGemNum()
	end
	local id = math.floor(gem:getId()/100)
	local tab = gemTab[id]
	if tab then
		for k,v in pairs(tab) do
			if v:getId() > gem:getId() and v:getNum() > 0 then
				return true
			end
		end
	end
	return false
end

-- 可装备的宝石数量
function EquipObj:getEmptyGemNum()
	local gemTab = BagData:getAllGems()
	local haveGemTab = {}
	for i=1,4 do
		local tab = gemTab[i]
		if tab then
			for k,v in pairs(tab) do
				haveGemTab[i] = true
			end
		end
	end
	for i,v in pairs(self.gems) do
		haveGemTab[tonumber(string.sub(tostring(v:getId()),1,1))] = false
	end
	for k,v in pairs(haveGemTab) do
		if v == true then
			return true
		end
	end
	return false
end

-- 最大可装备的宝石数量
function EquipObj:getMaxGemNum()
	return self.baseConf.quality - 1
end

-- 所装备的role位置1-5, 0表示未被装备
function EquipObj:getPos()
	return self.pos
end

-- 神器吞噬消耗
function EquipObj:getSwallowCost()
	return self.swallowCost
end

-- 神器传承消耗
function EquipObj:getInheritCost()
	return self.inheritCost
end

-- 神器等级
function EquipObj:getGodLevel()
	return self.god
end

-- 拆解消耗
function EquipObj:getDismantlingCost()
	return self.baseConf.dismantlingCost
end

-- 拆解获得
function EquipObj:getDismantlingAward()
	return self.baseConf.dismantlingAward
end

-- 当前所有需要的神器xp,要判断是单属性还是双属性
function EquipObj:getAllXp()
	local godObj = self:getGodAttr()
    local xp = self:getXp()
    local godEquipConf = GameData:getConfData("godequip")
    local godEquipTypes = godEquipConf[self.baseConf.type]
    local godEquipObj = godEquipTypes[self.god]

    if godObj[2] and godObj[2].double then -- 双属性神器，并且开启了
        xp = xp + godEquipObj.doubleAttExp
    else
        if self.god == 1 then
            xp = xp
        else
            for i = 1,self.god - 1 do
                xp = xp + godEquipTypes[i].maxExp

            end
        end

    end
    return xp
end

-- 神器当前经验
function EquipObj:getXp()
	return self.xp
end

-- 神器当前吞噬所需经验
function EquipObj:getNextXp()
	return self.nextXp
end

-- 神器属性id
function EquipObj:getGodId()
	return self.godId
end

-- 神器属性
function EquipObj:getGodAttr()
	return self.godAttr
end

-- 设置神器属性
function EquipObj:setGod(god,godId)
	self.god = tonumber(god)
	self.godId = tonumber(godId)
	self.nextXp = 0
	if self.god > 0 then
		local attributeConf = GameData:getConfData("attribute")
		local godEquipConf = GameData:getConfData("godequip")
		local godEquipObj = godEquipConf[self.baseConf.type][self.god]
		if self.godId == 3 then -- 两个神器属性
			self.nextXp = godEquipObj.doubleAttExp
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att1"]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value1"]
			self.godAttr[1]["double"] = false
			self.godAttr[1]["doubleatt"] = 0
			self.godAttr[1]['type'] = godEquipObj["valuetype1"]
			self.godAttr[1]["color"] = GOD_EQUIP_COLOR[1]
			self.godAttr[2] = {}
			local attrId2 = godEquipObj["att2"]
			self.godAttr[2]["id"] = attrId2
			self.godAttr[2]["name"] = attributeConf[attrId2].name
			self.godAttr[2]["value"] = godEquipObj["value2"]
			self.godAttr[2]["double"] = false
			self.godAttr[2]["doubleatt"] = 0
			self.godAttr[2]['type'] = godEquipObj["valuetype2"]
			self.godAttr[2]["color"] = GOD_EQUIP_COLOR[2]
			self:updateAllAttr(attrId1, godEquipObj["value1"])
			self:updateAllAttr(attrId2, godEquipObj["value2"])
		else
			self.nextXp = godEquipObj.maxExp
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att" .. self.godId]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value" .. self.godId]
			self.godAttr[1]["double"] = false
			self.godAttr[1]["doubleatt"] = 0
			self.godAttr[1]['type'] = godEquipObj["valuetype"..self.godId]
			self.godAttr[1]["color"] = GOD_EQUIP_COLOR[self.godId]
			self:updateAllAttr(attrId1, godEquipObj["value" .. self.godId])
		end
		self.swallowCost = -godEquipObj.swallowCost[1][3]
	end
	self.inheritCost = -self.baseConf.inheritCost
end

-- 更新神器属性
function EquipObj:activateGodByPart(partLv)
	local godEquipConf = GameData:getConfData("godequip")
	
	if self.god > 0 then
		local flag = false
		local actlv = partLv
		if self.god < partLv then
			actlv = self.god
		end
		if actlv > 0 then
			flag = true
		end
		if self.godAttr[1]["double"] and not flag then
			self:updateAllAttr(self.godAttr[1]["id"], -self.godAttr[1]["doubleatt"])
			self.godAttr[1]["doubleatt"] = 0
		elseif not self.godAttr[1]["double"] and flag then
			local godEquipObj = godEquipConf[self.baseConf.type][actlv]
			self.godAttr[1]["doubleatt"] = godEquipObj['value1']
			self:updateAllAttr(self.godAttr[1]["id"], self.godAttr[1]["doubleatt"])
		elseif self.godAttr[1]["double"] and flag then
			self:updateAllAttr(self.godAttr[1]["id"], -self.godAttr[1]["doubleatt"])
			local godEquipObj = godEquipConf[self.baseConf.type][actlv]
			self.godAttr[1]["doubleatt"] = godEquipObj['value1']
			self:updateAllAttr(self.godAttr[1]["id"], self.godAttr[1]["doubleatt"])
		end
		self.godAttr[1]["double"] = flag
		if self.godAttr[2] then
			if self.godAttr[2]["double"] and not flag then
				self:updateAllAttr(self.godAttr[2]["id"], -self.godAttr[2]["doubleatt"])
				self.godAttr[2]["doubleatt"] = 0
			elseif not self.godAttr[2]["double"] and flag then
				local godEquipObj = godEquipConf[self.baseConf.type][actlv]
				self.godAttr[2]["doubleatt"] = godEquipObj['value2']
				self:updateAllAttr(self.godAttr[2]["id"], self.godAttr[2]["doubleatt"])
			elseif self.godAttr[2]["double"] and flag then
				self:updateAllAttr(self.godAttr[2]["id"], -self.godAttr[2]["doubleatt"])
				local godEquipObj = godEquipConf[self.baseConf.type][actlv]
				self.godAttr[2]["doubleatt"] = godEquipObj['value2']
				self:updateAllAttr(self.godAttr[2]["id"], self.godAttr[2]["doubleatt"])
			end
			self.godAttr[2]["double"] = flag
		end
	end
end

function EquipObj:updateGodAttr(level, xp)
	self.god = level
	self.xp = xp
	local godEquipConf = GameData:getConfData("godequip")
	local godEquipObj = godEquipConf[self.baseConf.type][level]
	local value1 = 0
	local value2 = 0
	if self.godId == 3 then -- 两个神器属性
		self.nextXp = godEquipObj.doubleAttExp	
	else
		self.nextXp = godEquipObj.maxExp
	end
	if self.pos > 0 then
		local partLv = RoleData:getRoleByPos(self.pos):getPartInfoByPos(tostring(self:getType())).level
		local actlv = partLv
		if self.god < partLv then
			actlv = self.god
		end
		if actlv > 0 then
			local godEquipObj1 = godEquipConf[self.baseConf.type][actlv]
			value1 = godEquipObj1['value1']
			value2 = godEquipObj1['value2']
		end
		local attrId1 = godEquipObj["att1"]
		local attrId2 = godEquipObj["att2"]
		if self.godId == 3 then -- 两个神器属性
			if self.godAttr[1]["double"] then
				self:updateAllAttr(attrId1, -self.godAttr[1]["value"]-self.godAttr[1]["doubleatt"])
				self.godAttr[1]['doubleatt'] = 0
			else
				self:updateAllAttr(attrId1, -self.godAttr[1]["value"])
			end
			if self.godAttr[2]["double"] then
				self:updateAllAttr(attrId2, -self.godAttr[2]["value"]-self.godAttr[2]["doubleatt"])
				self.godAttr[2]['doubleatt'] = 0
			else
				self:updateAllAttr(attrId2, -self.godAttr[2]["value"])
			end
		else
			if self.godAttr[1]["double"] then
				self:updateAllAttr(attrId1, -self.godAttr[1]["value"]-self.godAttr[1]["doubleatt"])
				self.godAttr[1]['doubleatt'] = 0
			else
				self:updateAllAttr(attrId1, -self.godAttr[1]["value"])
			end
		end
		self:activateGodByPart(partLv)
		if self.godId == 3 then -- 两个神器属性
			self.godAttr[1]["value"] = godEquipObj["value1"]
			self.godAttr[2]["value"] = godEquipObj["value2"]
			self.godAttr[1]['doubleatt'] = value1
			self.godAttr[2]['doubleatt'] = value2
			self:updateAllAttr(attrId1, godEquipObj["value1"])
			self:updateAllAttr(attrId2, godEquipObj["value2"])
		else
			self.godAttr[1]["value"] = godEquipObj["value" .. self.godId]
			self.godAttr[1]['doubleatt'] = value1
			self:updateAllAttr(attrId1, godEquipObj["value" .. self.godId])
		end
		self.swallowCost = -godEquipObj.swallowCost[1][3]
		self.inheritCost = -self.baseConf.inheritCost
	end
end

-- 从其他装备继承神器属性
-- otherEquip一定是神器，自己一定是非神器
function EquipObj:inheritGod(otherEquip)
	self.god = otherEquip:getGodLevel()
	self.xp = otherEquip:getXp()
	self.nextXp = otherEquip:getNextXp()
	self.godId = otherEquip:getGodId()
	self.godAttr = otherEquip:getGodAttr()
	self.swallowCost = otherEquip:getSwallowCost()
	self:setGod(self.god,self.godId)
	otherEquip:resetGod()
end

-- 重置神器属性
function EquipObj:resetGod()
	local godEquipConf = GameData:getConfData("godequip")
	local partLv = 0
	if self.pos > 0 then
		partLv = RoleData:getRoleByPos(self.pos):getPartInfoByPos(tostring(self:getType())).level
	end
	local flag = false
	local actlv = partLv
	local value1 = 0
	local value2 = 0
	if partLv > 0 then
		flag = true
		if self.god < partLv then
			actlv = self.god
		end
		local godEquipObj1 = godEquipConf[self.baseConf.type][actlv]
		value1 = godEquipObj1['value1']
		value2 = godEquipObj1['value2']
	end
	
	local godEquipObj = godEquipConf[self.baseConf.type][self.god]
	local attrId1 = godEquipObj["att1"]
	local attrId2 = godEquipObj["att2"]
	if self.godId == 3 then -- 两个神器属性
		self.godAttr[1]["value"] = godEquipObj["value1"]
		self.godAttr[2]["value"] = godEquipObj["value2"]
		self:updateAllAttr(attrId1, -godEquipObj["value1"]-value1)
		self:updateAllAttr(attrId2, -godEquipObj["value2"]-value2)
	else
		self.godAttr[1]["value"] = godEquipObj["value" .. self.godId]
		self:updateAllAttr(attrId1, -godEquipObj["value" .. self.godId]-value1)
	end
	self.god = 0
	self.xp = 0
	self.nextXp = 0
	self.godId = 0
	self.godAttr = {}
	self.swallowCost = 0
end

-- 获取装备的所有属性
function EquipObj:getAllAttr()
	for k, v in ipairs(self.allAttr) do
		GlobalApi:checkAttribute(v, self.allAttr_check[k])
	end
	local att = clone(self.allAttr)
	return att
end

-- 脱装备
function EquipObj:takeOff()
	if self.pos > 0 then
		self.pos = 0
		self:activateGodByPart(0)
		-- self:removeAllGem()
		BagData:addItem(ITEM_TYPE.EQUIP, self)
	end
end

-- 穿装备
function EquipObj:putOn(rolePos, otherEquip, talent)
	self.pos = rolePos
	if otherEquip then -- 说明是更换装备,需要继承旧装备的部分属性
		self:inheritOtherEquip(otherEquip)
	end
	local partLv = RoleData:getRoleByPos(self.pos):getPartInfoByPos(tostring(self:getType())).level
	self:activateGodByPart(partLv)
	BagData:reduceItem(ITEM_TYPE.EQUIP, self)
end

-- 继承其他装备的属性
function EquipObj:inheritOtherEquip(otherEquipObj)
	local otherGems = otherEquipObj:getGems()
	local otherMaxGemNum = otherEquipObj:getMaxGemNum()
	local currMaxGemNum = self:getMaxGemNum()
	for k, v in pairs(self.gems) do -- 先把准备穿的装备的宝石都卸了
		self:removeGem(k)
	end
	local slotIndex = 1
	for i = 1, otherMaxGemNum do
		if otherGems[i] then -- 如果旧装备这个槽位有宝石就镶嵌到新装备上
			if slotIndex <= currMaxGemNum then
				self:addGemFromOtherEquip(slotIndex, i, otherGems)
				slotIndex = slotIndex + 1
			else -- 新装备的槽位不足, 那么就把宝石放到背包里
				--otherEquipObj:removeGem(i)
			end
			otherEquipObj:removeGem(i)
		end
	end
end

-- 镶嵌宝石
function EquipObj:addGem(slotIndex, gemObj)
	if self.gems[slotIndex] then -- 这个位置有宝石
		return
	end
	local newGemObj = ClassGemObj.new(gemObj:getId(), 1)
	self.gems[slotIndex] = newGemObj
	local attrId = newGemObj:getAttrId()
	self:updateAllAttr(attrId, newGemObj:getValue())
	BagData:reduceItem(ITEM_TYPE.GEM, newGemObj)
end

-- 卸宝石
function EquipObj:removeGem(slotIndex)
	local gemObj = self.gems[slotIndex]
	if gemObj then
		local attrId = gemObj:getAttrId()
		self:updateAllAttr(attrId, -gemObj:getValue())
		self.gems[slotIndex] = nil
	end
end

--卸全部宝石
function EquipObj:removeAllGem()
	for i=1,4 do
		if self.gems[i] then
			local attrId = self.gems[i]:getAttrId()
			self:updateAllAttr(attrId, -self.gems[i]:getValue())
		end
		self.gems[i] = nil
	end
end

--一键镶嵌宝石
function EquipObj:fillGem(slotIndex,gemobj)
	local oldgemobj = self.gems[slotIndex]
	self.gems[slotIndex] = gemobj
	if oldgemobj then
		local attrId = oldgemobj:getAttrId()
		self:updateAllAttr(attrId, gemobj:getValue() - oldgemobj:getValue())
	else
		local attrId = gemobj:getAttrId()
		self:updateAllAttr(attrId, gemobj:getValue())
	end
end

--升级宝石
function EquipObj:upgradeGem(slotIndex,gemobj)
	local oldgemobj = self.gems[slotIndex]
	self.gems[slotIndex] = gemobj
	if oldgemobj then
		local attrId = oldgemobj:getAttrId()
		self:updateAllAttr(attrId, gemobj:getValue() - oldgemobj:getValue())
	end
end

-- 从其他装备上拔下来宝石然后镶嵌上
function EquipObj:addGemFromOtherEquip(slotIndex, otherSlotIndex, otherGems)
	if self.gems[slotIndex] then -- 这个位置有宝石
		return
	end
	local otherGem = otherGems[otherSlotIndex]
	if otherGem then
		self.gems[slotIndex] = otherGem
		local attrId = self.gems[slotIndex]:getAttrId()
		self:updateAllAttr(attrId, self.gems[slotIndex]:getValue())
	end
end
--用作排序
function EquipObj:canEquip(lv)
	local rv = 0
	if lv < self.baseConf.level then
		rv = 1
	end
	return rv
end

-- 是否是远古装备
function EquipObj:isAncient()
	return self.baseConf.isAncient == 1
end

function EquipObj:updateAllAttr(attrId, attrValue)
	local currValue = GlobalApi:defuckAttribute(self.allAttr_check[attrId])
	currValue = currValue + attrValue
	self.allAttr_check[attrId] = GlobalApi:fuckAttribute(currValue)
	self.allAttr[attrId] = currValue
end

function EquipObj:setLightEffect(awardBgImg)
	local effect = awardBgImg:getChildByName('chip_light')
	if effect then
		effect:setVisible(false)
	end
end

return EquipObj
