local ClassEquipObj = require('script/app/obj/equipobj')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')

local DisplayObj = class("DisplayObj")

local ALPHA = 'uires/ui/common/bg1_alpha.png'

function DisplayObj:ctor(data)
	self.level = 1
	self.category = data[1]
    self.extra = false
    self.time = nil
    self.timetype = nil
    self.sid = nil
	if data[1] == "equip" then
		if #data == 4 then -- 读表
			self.baseinfo = GameData:getConfData("equip")[tonumber(data[2])]
			self.num = math.abs(data[4])
			self.godId = tonumber(data[3])
			self.obj = ClassEquipObj.new(tonumber(data[2]), nil, self.godId)
		else -- 服务器发过来的
			self.baseinfo = GameData:getConfData("equip")[tonumber(data[3]["id"])]
			self.num = 1
			self.godId = data[3].god_id
			self.obj = ClassEquipObj.new(tonumber(data[2]), data[3], nil)
		end
		self.level = self.baseinfo.level
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME_TYPE[self.baseinfo.color]
	elseif data[1] == "user" then
		self.baseinfo = GameData:getConfData("user")[data[2]]
		self.num = math.abs(data[3])
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[self.baseinfo.quality]
        if data[4] then
            self.extra = true
        end
	elseif data[1] == "gem" then
		local gemId = tonumber(data[2])
		self.baseinfo = GameData:getConfData("gem")[gemId]
		self.num = math.abs(data[3])
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[self.baseinfo.color]
        if data[4] then
            self.extra = true
        end
	elseif data[1] == "dragon" then
		self.sid = tonumber(data[2])
		self.baseinfo = GameData:getConfData("dragongem")[data[3]["id"]]
		self.num = 1
		-- self.frame = COLOR_FRAME[self.baseinfo.quality]
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[self.baseinfo.quality]
		local attributeConf = GameData:getConfData("attribute")
		self.attr = {}
		local i = 0
		for k, v in pairs(data[3]["attr"]) do
			i = i + 1
			self.attr[i] = {
				id = tonumber(k),
				name = attributeConf[tonumber(k)].name,
				value = v
			}
		end
        if data[4] then
            self.extra = true
        end
	elseif data[1] == "material" then
		self.baseinfo = GameData:getConfData("item")[tonumber(data[2])]
		self.num = math.abs(data[3])
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME_TYPE[self.baseinfo.color]
		self.mergenum = self.baseinfo['mergeNum']
        if data[4] then
            self.extra = true
        end
    elseif data[1] == "limitmat" then
    	if #data > 3 then -- 读表
    		self.baseinfo = GameData:getConfData("item")[tonumber(data[2])]
    		self.num = math.abs(data[5])
    		self.timetype = data[3]
    		self.time = data[4]
    	else
	    	self.sid = tonumber(data[2])
	    	local info = data[3]
	    	if type(data[3]) == "number" then
	    		self.baseinfo = GameData:getConfData("item")[tonumber(data[2])]
	    		self.num = math.abs(data[3])
	    		self.timetype = 0
	    		self.time = 0
	    	else
				self.baseinfo = GameData:getConfData("item")[tonumber(info.id)]
				self.num = math.abs(info.num)
				self.timetype = info.type
				self.time = info.expire
			end
		end
		self.bgImg = COLOR_FRAME_TYPE[self.baseinfo.color]
		self.frame = ALPHA
		self.mergenum = self.baseinfo['mergeNum']
	elseif data[1] == "fragment" then
		self.baseinfo = GameData:getConfData("item")[tonumber(data[2])]
		self.num = math.abs(data[3])
		local roleobj = RoleData:getRoleInfoById(self.baseinfo.id)
		self.ownnum = havenum
		self.frame = roleobj:getFrame()--COLOR_FRAME[self.baseinfo.quality]
		self.bgImg = roleobj:getBgImg()--COLOR_FRAME[self.baseinfo.quality]
		self.mergenum = self.baseinfo['mergeNum']
        if data[4] then
            self.extra = true
        end
	elseif data[1] == "card" then
		self.baseinfo = GameData:getConfData("hero")[tonumber(data[2])]
		self.baseinfo.icon = self.baseinfo.heroIcon
		self.baseinfo.name = self.baseinfo.heroName
		self.num = math.abs(data[3])
		local roleobj = RoleData:getRoleInfoById(self.baseinfo.id)
		self.frame = roleobj:getFrame()-- COLOR_FRAME[self.baseinfo.quality]
		self.bgImg = roleobj:getBgImg()-- COLOR_FRAME[self.baseinfo.quality]
        if data[4] then
            self.extra = true
        end
	elseif data[1] == "dress" then
		local id = tonumber(data[2])
		self.baseinfo = GameData:getConfData("dress")[id]
		self.num = math.abs(data[3])
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[5]
        if data[4] then
            self.extra = true
        end
    elseif data[1] == "headframe" then
		self.baseinfo = GameData:getConfData("settingheadframe")[tonumber(data[3])]
		self.num = 1
		self.frame = self.baseinfo.icon
		self.bgImg = COLOR_FRAME[5]
	elseif data[1] == "skyweapon" then
		local config = GameData:getConfData("skychange")[1]
		self.baseinfo = config[tonumber(data[2])]
		self.num = 1
		self.timetype = data[3]
    	self.time = data[4]
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[5]
	elseif data[1] == "skywing" then
		local config = GameData:getConfData("skychange")[2]
		self.baseinfo = config[tonumber(data[2])]
		self.num = 1
		self.timetype = data[3]
    	self.time = data[4]
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME[5]
	elseif data[1] == "exclusive" then
		self.baseinfo = GameData:getConfData("exclusive")[tonumber(data[2])]
		self.num = math.abs(data[3])
		self.frame = ALPHA
		self.bgImg = COLOR_FRAME_TYPE[self.baseinfo.quality]
        self.obj = ClassExclusiveObj.new(tonumber(data[2]), tonumber(data[3]))
        self.level = self.obj:getLevel()
	end
	self.type = data[1]
	self.subtype = data[2]
end

function DisplayObj:getName()
	if self.type == "headframe" then
		return self.baseinfo.itemName
	else
		return self.baseinfo.name
	end
end

function DisplayObj:getQuality()
	return self.baseinfo.quality or 1
end
--只是user有
function DisplayObj:getSubtype()
	return self.subtype
end

function DisplayObj:getChip()
	if self.category == "fragment" then
		local quality = self.baseinfo.quality or 1
		return COLOR_CHIP[quality]
	elseif self.category == "material" then
		if self.baseinfo.resource == 'equip' then
			return COLOR_CHIP[5]
		else
			return ALPHA
		end
	else
		return ALPHA
	end
end

function DisplayObj:getType()
	return self.type
end

function DisplayObj:getObjType()
	return self.type
end

function DisplayObj:getExtraBg()
	return self.extra
end

-- 类别
function DisplayObj:getCategory()
	-- return self.baseinfo.category
	return self.category
end

-- RES类别
function DisplayObj:getResCategory()
	if self.category == 'material' or self.category == "limitmat" then
		return self.baseinfo.resource
	else
		return ''
	end
end

function DisplayObj:getOwnNum()
	if self.type == "equip" then
		self.ownnum = 1
	elseif self.type == "user" then
		self.ownnum = UserData:getUserObj()[tostring(self.baseinfo.id)]
	elseif self.type == "gem" then
		local gemObj = BagData:getGemById(self.baseinfo.id)
		if gemObj then
			self.ownnum = gemObj:getNum()
		else
			self.ownnum = 0
		end
	elseif self.type == "dragon" then
		local dragongemObj = BagData:getDragonGemById(self.baseinfo.type, self.sid)
		if dragongemObj then
			self.ownnum = dragongemObj:getNum()
		else
			self.ownnum = 0
		end
	elseif self.type == "material" then
		local materialobj = BagData:getMaterialById(self.baseinfo.id)
		local havenum = 0
		if materialobj ~= nil then
			havenum =materialobj:getNum()
		end
		self.ownnum = havenum
	elseif self.type == "fragment" then
		local materialobj = BagData:getFragmentById(self.baseinfo.id)
		local havenum =0
		if materialobj ~= nil then
			havenum =materialobj:getNum()
		end
		self.ownnum = havenum
	elseif self.type == "card" then
		local materialobj = BagData:getCardById(self.baseinfo.id)
		local havenum =0
		if materialobj ~= nil then
			havenum =materialobj:getNum()
		end
		self.ownnum = havenum
	elseif self.type == "dress" then
		local dressObj = BagData:getDressById(self.baseinfo.id)
		local havenum = 0
		if dressObj ~= nil then
			havenum = dressObj:getNum()
		end
		self.ownnum = havenum
	elseif self.type == "limitmat" then
		self.ownnum = BagData:getLimitMatNumById(self.baseinfo.id)
    elseif self.type == "exclusive" then
		local exclusiveObj = BagData:getExclusiveById(self.baseinfo.id)
        local havenum = 0
		if exclusiveObj ~= nil then
			havenum = exclusiveObj:getNum()
		end
		self.ownnum = havenum
	end
	return self.ownnum
end

function DisplayObj:setNum(num)
	self.num = num
end

function DisplayObj:getNum()
	return self.num
end

function DisplayObj:getTimeType()
	return self.timetype
end

function DisplayObj:getTime()
	return self.time
end

function DisplayObj:getUserId()
	return self.baseinfo.id
end

function DisplayObj:getId()
	
	if self.type == "skywing" or self.type == "skyweapon" then
		return tonumber(self.baseinfo.id) or 0
	else
		return self.baseinfo.id or -1
	end
end

function DisplayObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY
end

function DisplayObj:getNameColor()
	if (self.godId and self.godId > 0) or (self.obj and self.obj:getObjType() == 'equip' and self.obj:isAncient()) then -- 神器、远古装备固定显示红色
		return COLOR_QUALITY[6]
	else
        if self.type == "gem" then
            return COLOR_QUALITY[self.baseinfo.color or 5]
        else
            return COLOR_QUALITY[self.baseinfo.quality or 5]
        end
		
	end
end

function DisplayObj:getBgImg()
	return self.bgImg
end

function DisplayObj:getFrame()
	return self.frame
end

function DisplayObj:getLevel()
	return self.level
end
-- 合成数量
function DisplayObj:getMergeNum()
	if self.mergenum > 0  then
		return self.mergenum
	else
		return 0
	end
end

function DisplayObj:getShopId()
	if self.type == 'material' then
		return self.baseinfo.shopId
	elseif self.type == 'user' then
		return self.baseinfo.id
	else
		return 0
	end
end

function DisplayObj:getDesc()
	if self.type == "headframe" then
		return self.baseinfo.itemDesc
	else
		return self.baseinfo.desc
	end
end

function DisplayObj:getIcon()
	if self.type == 'fragment' or self.type == 'card' then
		return "uires/icon/hero/" .. self.baseinfo.icon
	elseif self.type == 'material' or self.type == "limitmat" then
		return "uires/icon/" .. self.baseinfo.resource .. "/" .. self.baseinfo.icon
	elseif self.type == "headframe" or self.type == "skyweapon" or self.type == "skywing" then
		return self.baseinfo.icon
	else
		return "uires/icon/" .. self.type .. "/" .. self.baseinfo.icon
	end
end

function DisplayObj:getInfo()
	return self.baseinfo
end

function DisplayObj:getCost()
	local cost
	if self.baseinfo.cost and self.baseinfo.cost[1] and self.baseinfo.cost ~= 0 then
		cost = DisplayData:getDisplayObj(self.baseinfo.cost[1])
	end
	return cost
end

function DisplayObj:getCost1()
	local cost1
	if self.baseinfo.cost1 and self.baseinfo.cost1[1] and self.baseinfo.cost1 ~= 0 then
		cost1 = DisplayData:getDisplayObj(self.baseinfo.cost1[1])
	end
	return cost1
end

-- 得到GetWay类型
function DisplayObj:getShowGetWayType()
	if self.baseinfo then
        return self.baseinfo.showgetwaytype
	else
		return 0
	end
end

-- 子类型
function DisplayObj:getSubType()
	return self.baseinfo.subType
end

function DisplayObj:getUseEffect()
	return self.baseinfo.useEffect
end

function DisplayObj:judgeHasDrop()
    local judge = false
    local useEffect = self.baseinfo.useEffect
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

function DisplayObj:getStarUrl()
	if self.obj:getObjType() == 'exclusive' then
        return self.obj:getStarUrl()
    else
        return ''
    end
end

function DisplayObj:getObj()
	return self.obj
end

-- 神器属性id
function DisplayObj:getGodId()
	if self.type == 'equip' then
		return self.obj:getGodId()
	else
		return 0
	end
end

-- 红色碎片特效
function DisplayObj:setLightEffect(awardBgImg,scale)
	local isNotLight = false
	-- if self.category == 'material' then
	-- 	if self.baseinfo.id ~= 200010 then
	-- 		isNotLight = true
	-- 	end
	-- else
	-- 	if self.category ~= 'fragment' or self.baseinfo.quality ~= 6 or scale == 0 then
	-- 		isNotLight = true
	-- 	end
	-- end
	if self.category == 'material' or self.category == 'fragment' then
		if self.baseinfo.showeffect ~= 1 then
			isNotLight = true
		end
	elseif self.category == 'gem' and self.baseinfo.color ~= 6 then
		isNotLight = true
	elseif self.category ~= 'gem' and (self.baseinfo.quality ~= 6 or scale == 0) then
		isNotLight = true
	end

	if isNotLight then
		local effect = awardBgImg:getChildByName('chip_light')
		if effect then
			effect:setVisible(false)
		end
		return
	end
	local effect = awardBgImg:getChildByName('chip_light')
	local size = awardBgImg:getContentSize()
	if not effect then
	    effect = GlobalApi:createLittleLossyAniByName("chip_light")
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('chip_light')
        effect:setVisible(true)
        effect:setPosition(cc.p(size.width/2,size.height/2))
        effect:setScale(scale or 1)
        awardBgImg:addChild(effect)
    else
    	effect:setVisible(true)
    end
end

function DisplayObj:getAttNum()
	if self.type == "dragon" then
		return self.attr[1].value
	else
		return 0
	end
end

function DisplayObj:getAttType()
	if self.type == "dragon" then
		return self.baseinfo.type
	else
		return ""
	end
end

function DisplayObj:getPosId()
	return 0
end

return DisplayObj
