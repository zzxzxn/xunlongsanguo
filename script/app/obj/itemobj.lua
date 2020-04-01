local ItemObj = class("ItemObj")
local ALPHA = 'uires/ui/common/bg1_alpha.png'
local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED',
	[7] = 'GOLD'
}

function ItemObj:ctor(id,num,isNew)
	self.conf = GameData:getConfData("item")[tonumber(id)]
	if self.conf == nil then
		print('[ERROR]: item can`t find, item id ==', id)
	end
	self.num = num or 1
	self.isNew = isNew
end

function ItemObj:getObjType()
	local rv = ''
	if self:getCategory() == 'fragment' then
		rv = 'fragment'
	elseif self:getCategory() == 'material' then
		rv = 'material'
	end
	return rv
end
-- ID
function ItemObj:getId()
	return self.conf['id']
end

function ItemObj:getNum()
	return self.num
end
--tips用
function ItemObj:getOwnNum()
	return self.num
end

function ItemObj:addNum( num )
	self.num = self.num + num
end
-- 名称
function ItemObj:getName()
	return self.conf['name']
end

-- RES类别
function ItemObj:getResCategory()
	return self.conf['resource']
end

-- 类别
function ItemObj:getCategory()
	return self.conf['category']
end

function ItemObj:judgeHasDrop()
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

-- 显示颜色
function ItemObj:getQuality()
	return self.conf['quality']
end

function ItemObj:getShopId()
	return self.conf['shopId']
end

function ItemObj:getBgImg()
	return COLOR_FRAME_TYPE[self.conf.color]
end

function ItemObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 名称颜色
function ItemObj:getNameColor()
	return COLOR_QUALITY[self.conf['quality']]
end

-- 描边颜色
function ItemObj:getNameOutlineColor()
	return COLOROUTLINE_TYPE[FRAME_COLOR[self.conf['quality']]]
end

-- 是否可使用
function ItemObj:getUseable()
	return self.conf['useable']
end

-- 是否在背包显示
function ItemObj:getShowable()
	return self.conf['showable']
end

-- 使用类型
function ItemObj:getUseType()
	return self.conf['useType']
end

-- 使用效果
function ItemObj:getUseEffect()
	return self.conf['useEffect']
end

-- 合成等级限制
function ItemObj:getMergeLvLimit()
	return self.conf['mergeLvLimit']
end

-- 合成数量
function ItemObj:getMergeNum()
	return self.conf['mergeNum']
end

-- 是否可出售
function ItemObj:getSellable()
	return self.conf['sellable']
end

-- 出售价格
function ItemObj:getSell()
	return self.conf['sell']
end

-- 图标
function ItemObj:getIcon()
	if self.conf.resource == 'fragment' then
		return "uires/icon/hero/".. self.conf['icon']
	else
		return "uires/icon/" .. self.conf.resource .. "/" .. self.conf['icon']
	end
end

function ItemObj:getCost()
	local cost
	if self.conf.cost and self.conf.cost[1] and self.conf.cost ~= 0 then
		cost = DisplayData:getDisplayObj(self.conf.cost[1])
	end
	return cost
end

function ItemObj:getCost1()
	local cost1
	if self.conf.cost1 and self.conf.cost1[1] and self.conf.cost1 ~= 0 then
		cost1 = DisplayData:getDisplayObj(self.conf.cost1[1])
	end
	return cost1
end

-- 得到GetWay类型
function ItemObj:getShowGetWayType()
	if self.conf then
        return self.conf.showgetwaytype
	else
		return 0
	end
end

-- 子类型
function ItemObj:getSubType()
	return self.conf['subType']
end

-- 描述
function ItemObj:getDesc()
	return self.conf['desc']
end

-- 功能开启
function ItemObj:getModule()
	return self.conf['module']
end

-- 红色碎片特效
function ItemObj:setLightEffect(awardBgImg,scale)
	-- if self.conf.category ~= 'fragment' or self.conf.quality ~= 6 or scale == 0 
	-- 	or (self.conf.category == 'material' and  self.conf['id'] ~= 200010 ) then
	-- 	local effect = awardBgImg:getChildByName('chip_light')
	-- 	if effect then
	-- 		effect:setVisible(false)
	-- 	end
	-- 	return
	-- end
	local isNotLight = false
	if self.conf.showeffect ~= 1 or scale == 0 then
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

function ItemObj:getNew()
	return self.isNew
end

function ItemObj:setNew(isNew)
	self.isNew = isNew
end

function ItemObj:getChip()
	if self:getCategory() == "fragment" then
		return COLOR_CHIP[self:getQuality()]
	elseif self:getCategory() == "material" then
		if self:getResCategory() == 'equip' then
			return COLOR_CHIP[5]
		else
			return ALPHA
		end
	else
		return ALPHA
	end
end

return ItemObj
