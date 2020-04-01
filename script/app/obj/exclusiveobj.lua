local ExclusiveObj = class("ExclusiveObj")
local MAX_ATTR_NUM = 8

function ExclusiveObj:ctor(id, num)
	self.id = id
	self.num = num
	local exclusiveConf = GameData:getConfData("exclusive")[tonumber(self.id)]
	self.baseConf = exclusiveConf
end

function ExclusiveObj:getBaseAttrInfo(showAll)
	local attributeConf = GameData:getConfData("attribute")
	local attrs = {}
	local attrNames = {}
	for i=1,MAX_ATTR_NUM do
		local attr = self.baseConf['fixed'..i]
		if showAll then
			attrs[i] = attr
			attrNames[i] = attributeConf[i].name
		else
			if attr > 0 then
				attrs[i] = attr
				attrNames[i] = attributeConf[i].name
			end
		end
	end
	return attrs,attrNames
end

function ExclusiveObj:getSpecialAttrInfo(showAll)
	local attributeConf = GameData:getConfData("attribute")
	local attrs = {}
	local attrNames = {}
	for i=1,MAX_ATTR_NUM do
		local attr = self.baseConf['per'..i]
		if showAll then
			attrs[i] = attr
			attrNames[i] = attributeConf[i].name
		else
			if attr > 0 then
				attrs[i] = attr
				attrNames[i] = attributeConf[i].name
			end
		end
	end
	return attrs,attrNames
end

function ExclusiveObj:getObjType()
	return 'exclusive'
end

function ExclusiveObj:getId()
	return self.id
end

function ExclusiveObj:getShopId()
    return self.id
end

-- 名称
function ExclusiveObj:getName()
	return self.baseConf.name
end

-- 颜色
function ExclusiveObj:getNameColor()
	return COLOR_QUALITY[self.baseConf.quality]
end

-- 描边颜色
function ExclusiveObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY
end
-- 图标
function ExclusiveObj:getIcon()
	return "uires/icon/exclusive/" .. self.baseConf.icon
end

function ExclusiveObj:getBgImg()
	return COLOR_FRAME[self.baseConf.quality]
end

-- 获取星星url
function ExclusiveObj:getStarUrl()
	local stars = {1,1,2,2,6,3,7}
	return 'uires/ui/role/role_star_'..stars[self.baseConf.level]..'.png'
end

-- 边框
function ExclusiveObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 等级
function ExclusiveObj:getLevel()
	return self.baseConf.level
end

function ExclusiveObj:judgeHasDrop()
	return false
end

-- 类型
function ExclusiveObj:getType()
	return self.baseConf.type
end

-- 品质
function ExclusiveObj:getQuality()
	return self.baseConf.quality
end

-- 属性值
function ExclusiveObj:getValue()
	return self.baseConf.value
end

-- 数量
function ExclusiveObj:getNum()
	return self.num
end

function ExclusiveObj:addNum(num)
	self.num = self.num + num
end

-- 是否有特殊效果
function ExclusiveObj:showEffectDesc()
	return self.baseConf.showEffectDesc ~= 0
end

-- 是否专属
function ExclusiveObj:isExclusive()
	return self.baseConf.exclusiveId ~= 0
end

-- 专属武将id
function ExclusiveObj:getExclusiveHeroId()
	return self.baseConf.exclusiveId
end

-- 专属特殊效果Id
function ExclusiveObj:getSpecialId()
	return self.baseConf.effectId
end

-- 专属特殊效果颜色
function ExclusiveObj:getSpecialColor()
	local effectConf = GameData:getConfData("exclusiveeffect")
	return COLOR_QUALITY[effectConf[self.baseConf.effectId].quality]
end

-- 专属特殊效果描述
function ExclusiveObj:getSpecialDesc()
	local effectConf = GameData:getConfData("exclusiveeffect")
	local baseAttr,baseAttrName = self:getSpecialAttrInfo()
	local tab = {}
	for i=1,MAX_ATTR_NUM do
		if baseAttr[i] then
			tab[#tab + 1] = i
		end
	end
	local str = ''
	if #tab == 1 then
		str = effectConf[self.baseConf.effectId].name..'：'..string.format(effectConf[self.baseConf.effectId].desc,
			baseAttrName[tab[1]],baseAttr[tab[1]]..'%')
	elseif #tab == 2 then
		str = effectConf[self.baseConf.effectId].name..'：'..string.format(effectConf[self.baseConf.effectId].desc,
			baseAttrName[tab[1]],baseAttr[tab[1]]..'%',
			baseAttrName[tab[2]],baseAttr[tab[2]]..'%')
	elseif #tab == 3 then
		str = effectConf[self.baseConf.effectId].name..'：'..string.format(effectConf[self.baseConf.effectId].desc,
			baseAttrName[tab[1]],baseAttr[tab[1]]..'%',
			baseAttrName[tab[2]],baseAttr[tab[2]]..'%',
			baseAttrName[tab[3]],baseAttr[tab[3]]..'%')
	elseif #tab == 4 then
		str = effectConf[self.baseConf.effectId].name..'：'..string.format(effectConf[self.baseConf.effectId].desc,
			baseAttrName[tab[1]],baseAttr[tab[1]]..'%',
			baseAttrName[tab[2]],baseAttr[tab[2]]..'%',
			baseAttrName[tab[3]],baseAttr[tab[3]]..'%',
			baseAttrName[tab[4]],baseAttr[tab[4]]..'%')
	end
	-- str = string.gsub(str,'-','%%')
	-- str = string.gsub(str,'=','\n')
	return str
end

-- 专属武将描述
function ExclusiveObj:getExclusiveHeroDesc()
	local exclusiveHerotConf = GameData:getConfData("exclusivehero")
	if self.baseConf.exclusiveId and self.baseConf.exclusiveId > 0 then
		return exclusiveHerotConf[self.baseConf.exclusiveId].specialName ..'：'.. exclusiveHerotConf[self.baseConf.exclusiveId].specialDes
	end
	return ''
end

-- 描述
function ExclusiveObj:getDesc()
	return self.baseConf.desc
end

-- 是否可出售
function ExclusiveObj:getSellable()
	return 1
end

-- 出售价格
function ExclusiveObj:getSell()
	return self.baseConf['sell']
end

-- 消耗宝石品质
function ExclusiveObj:getCostQuality()
    return self.baseConf.costQuality
end

-- 获取消耗
function ExclusiveObj:getCosts()
    return self.baseConf.cost[1]
end

-- 红色碎片特效
function ExclusiveObj:setLightEffect(awardBgImg,scale)
    local isNotLight = false
    if self.baseConf.quality ~= 6 or scale == 0 then
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

return ExclusiveObj
