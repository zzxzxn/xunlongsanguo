local DressObj = class("DressObj")

function DressObj:ctor(id,num,isNew)
	self.id = id
	self.conf = GameData:getConfData("dress")[tonumber(id)]
	self.num = num or 1
	self.isNew = isNew
end

function DressObj:getObjType()
	return 'dress'
end
-- ID
function DressObj:getId()
	return self.id
end

function DressObj:getNum()
	return self.num
end

function DressObj:getShopId()
	return self.id
end

function DressObj:addNum( num )
	self.num = self.num + num
end

-- 名称
function DressObj:getName()
	return self.conf['name']
end

function DressObj:getNameColor()
	return COLOR_TYPE.ORANGE
end

function DressObj:getNameOutlineColor()
	return COLOROUTLINE_TYPE.ORANGE
end

-- RES类别
function DressObj:getResCategory()
	return 'dress'
end

function DressObj:judgeHasDrop()
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

-- 图标
function DressObj:getIcon()
	return 'uires/icon/dress/'..self.conf['icon']
end

function DressObj:getBgImg()
	return "uires/ui/common/frame_yellow.png"
end

function DressObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 类别
function DressObj:getQuality()
	return 5
end

-- 类别
function DressObj:getShowable()
	return 1
end

-- 是否可出售
function DressObj:getSellable()
	return 1
end

-- 出售价格
function DressObj:getSell()
	return self.conf['sell']
end

-- 描述
function DressObj:getDesc()
	return self.conf['desc'] or 'NA'
end

-- 类别
function DressObj:getCategory()
	return 'dress'
end

-- 类别
function DressObj:getUseable()
	return 1
end

-- 合成数量
function DressObj:getMergeNum()
	return self.conf['mergeNum']
end

-- 属性
function DressObj:getAttribute()
	local id = self.id
	local soldierid = (id - id%100)/100
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][1]
	local soldconf = GameData:getConfData('soldier')[soldlevelconf['soldierId']]
    local attarr = {}
    for i=1,2 do
        local attid = self.conf['att'.. i]
        local attconf = GameData:getConfData('attribute')[attid]
        local value1 = self.conf['value'.. i]
        if tonumber(attid) == 1 then
        	value1 = value1*soldconf['attPowPercent']/100
        elseif tonumber(attid) == 2 then
        	value1 = value1*soldconf['phyArmPowPercent']/100
        elseif tonumber(attid) == 3 then
        	value1 = value1*soldconf['magArmPowPercent']/100
        elseif tonumber(attid) == 4 then
        	value1 = value1*soldconf['heaPowPercent']/100
        end

        local str = string.format("%.1f", value1) 
	    attarr[i] = {name = attconf.name,value = str}
    end
    return attarr
end

function DressObj:getNew()
	return self.isNew
end

function DressObj:setNew(isNew)
	self.isNew = isNew
end

function DressObj:setLightEffect(awardBgImg)
	local effect = awardBgImg:getChildByName('chip_light')
	if effect then
		effect:setVisible(false)
	end
end

return DressObj