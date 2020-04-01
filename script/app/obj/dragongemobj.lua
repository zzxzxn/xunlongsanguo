local DragonGemObj = class("DragonGemObj")


local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED'
}

local COLOR_QUALITY = {
	[1] = cc.c4b(255,253,249, 255),      	-- 白
	[2] = cc.c4b(115,255,91, 255),			-- 绿
	[3] = cc.c4b(0,246,255, 255),			-- 蓝
	[4] = cc.c4b(255, 73, 253, 255), 		-- 紫
	[5] = cc.c4b(254,165,0, 255),			-- 橙
	[6] = cc.c4b(255, 55, 55, 255),			-- 红
}

function DragonGemObj:ctor(sid,obj,isNew)
	local attributeConf = GameData:getConfData("attribute")
	self.sid = sid
	self.conf = GameData:getConfData("dragongem")[tonumber(obj.id)]
	self.attr = {}
	local i = 0
	for k, v in pairs(obj.attr) do
		i = i + 1
		self.attr[i] = {
			id = tonumber(k),
			name = attributeConf[tonumber(k)].name,
			value = v
		}
	end
	self.dragonId = -1
	self.isNew = isNew or false
end

function DragonGemObj:getMergeNum()
	return 1
end

function DragonGemObj:getSellable()
	return 0
end

function DragonGemObj:getNum()
	return 1
end

function DragonGemObj:getNew()
	return self.isNew
end

function DragonGemObj:setNew(isNew)
	self.isNew = isNew
end

function DragonGemObj:getCategory()
	return 'dragon'
end

function DragonGemObj:getResCategory()
	return 'dragon'
end

function DragonGemObj:getObjType()
	return 'dragon'
end
-- ID
function DragonGemObj:getId()
	return self.conf['id']
end

function DragonGemObj:getSId()
	return self.sid
end

function DragonGemObj:getUseable()
	return 0
end

function DragonGemObj:getShowable()
	return 1
end

-- 名称
function DragonGemObj:getName()
	return self.conf['name']
end

-- 显示颜色
function DragonGemObj:getQuality()
	return self.conf['quality']
end

function DragonGemObj:judgeHasDrop()
    local judge = false
    local useEffect = self.conf.useEffect
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

function DragonGemObj:getBgImg()
	return COLOR_ITEMFRAME[FRAME_COLOR[self.conf['quality']]]
end

function DragonGemObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 名称颜色
function DragonGemObj:getNameColor()
	return COLOR_QUALITY[self.conf['quality']]
end

-- 描边颜色
function DragonGemObj:getNameOutlineColor()
	return COLOROUTLINE_TYPE[FRAME_COLOR[self.conf['quality']]]
end

function DragonGemObj:getType()
	return self.conf['type']
end

-- 图标
function DragonGemObj:getIcon()
	return "uires/icon/dragon/" .. self.conf['icon']
end

-- 描述
function DragonGemObj:getDesc()
	return self.conf['desc'] or ""
end

-- 等级
function DragonGemObj:getLevel()
	return self.conf.level
end
--属性类型
function DragonGemObj:getAttType()
	return self.conf['type']
end
--属性具体数值
function DragonGemObj:getAttNum()
	return self.attr[1].value
end

function DragonGemObj:getAttName()
	return self.attr[1].name
end

function DragonGemObj:getAttId()
	return self.attr[1].id
end

-- 从龙身上卸下来
function DragonGemObj:demount()
	local dragonMap = RoleData:getDragonMap()
	local attrId = self.attr[1].id
	local attrValue = self.attr[1].value/100
	for k, dragon in pairs(dragonMap) do
		dragon:updateAttr(attrId, -attrValue)
	end
	self.dragonId = -1
	BagData:addItem(ITEM_TYPE.DRAGONGEM, self)
end

-- 镶嵌到龙身上
function DragonGemObj:mount(id)
	local dragonMap = RoleData:getDragonMap()
	local attrId = self.attr[1].id
	local attrValue = self.attr[1].value/100
	for k, dragon in pairs(dragonMap) do
		dragon:updateAttr(attrId, attrValue)
	end
	self.dragonId = id
	BagData:reduceItem(ITEM_TYPE.DRAGONGEM, self)
end

function DragonGemObj:setLightEffect(awardBgImg)
	local effect = awardBgImg:getChildByName('chip_light')
	if effect then
		effect:setVisible(false)
	end
end

return DragonGemObj
