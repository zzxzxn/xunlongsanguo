local GemObj = class("GemObj")

function GemObj:ctor(id, num)
	self.id = id
	self.num = num
	local gemConf = GameData:getConfData("gem")[tonumber(self.id)]
	self.baseConf = gemConf

	local attributeConf = GameData:getConfData("attribute")
	self.attrName = attributeConf[gemConf.type].name
end

function GemObj:getObjType()
	return 'gem'
end

function GemObj:getId()
	return self.id
end

function GemObj:getShopId()
    return self.id
end

-- 名称
function GemObj:getName()
	return self.baseConf.name
end

-- 颜色
function GemObj:getNameColor()
	return COLOR_QUALITY[self.baseConf.color]
end

-- 描边颜色
function GemObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY
end
-- 图标
function GemObj:getIcon()
	return "uires/icon/gem/" .. self.baseConf.icon
end

function GemObj:getBgImg()
	return COLOR_FRAME[self.baseConf.color]
end

-- 边框
function GemObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

function GemObj:judgeHasDrop()
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

-- 等级
function GemObj:getLevel()
	return self.baseConf.level
end

-- 类型
function GemObj:getType()
	return self.baseConf.type
end

-- 品质
function GemObj:getQuality()
	return self.baseConf.quality
end

-- 属性名称
function GemObj:getAttrName()
	return self.attrName
end

-- 属性ID
function GemObj:getAttrId()
	return self.baseConf.type
end

-- 属性值
function GemObj:getValue()
	return self.baseConf.value
end

-- 数量
function GemObj:getNum()
	return self.num
end

function GemObj:addNum(num)
	self.num = self.num + num
end

-- 描述
function GemObj:getDesc()
	return self.baseConf.desc
end

-- 是否可出售
function GemObj:getSellable()
	return 1
end

-- 出售价格
function GemObj:getSell()
	return self.baseConf['sell']
end

-- 消耗宝石品质
function GemObj:getCostQuality()
    return self.baseConf.costQuality
end

-- 获取消耗
function GemObj:getCosts()
    return self.baseConf.cost[1]
end

-- 升级后的宝石
function GemObj:getGetGemId()
    return self.baseConf.getGem
end

-- 升级消耗的宝石数量
function GemObj:getCostNum()
    return self.baseConf.costNum
end

-- 红色碎片特效
function GemObj:setLightEffect(awardBgImg,scale)
    local isNotLight = false
    if self.baseConf.color ~= 6 or scale == 0 then
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

-- 是否可升级
function GemObj:getScalable()
	local gemObj = BagData:getGemObjById(self.id)
	if gemObj:getLevel() >= 12 then
		return false
	end

	local ownNum = gemObj:getNum()
	local costNum = gemObj:getCostNum()
	if ownNum < costNum then
		return false
	end

	local costAward = DisplayData:getDisplayObj(gemObj:getCosts())
	local costGold = costAward:getNum()
	if UserData:getUserObj():getGold() < costGold then
		return false
	end

    return true
end

-- 获取基础提升幸运值
function GemObj:getBasePromoteLucky()
    return self.baseConf.basePromoteLucky
end

-- 获取失败提升能量值
function GemObj:getPromoteLucky()
    return self.baseConf.promoteLucky
end

-- 获取提升能量值
function GemObj:getLevelUpLucky()
    return self.baseConf.levelUpLucky
end

function GemObj:eatAll(gemId,equipObj)
    local gemObj = BagData:getGemObjById(gemId)
    local gemObj1 = BagData:getGemObjById(gemId - 1)
    local needLuck = gemObj:getLevelUpLucky()
    local luck = UserData:getUserObj():getLuck()
    local num = 0
    local maxNum = self:getNum()
    if self.id == gemId and not equipObj then
        maxNum = maxNum - 1
    end
    if maxNum < 0 then
        maxNum = 0
    end
    local newLuck = 0
    local isUp = false
    if luck >= needLuck then
        num = 1
        newLuck = luck - needLuck + self:getPromoteLucky()
        isUp = true
    else
        local maxLuck = luck + maxNum * self:getPromoteLucky()
        if maxLuck >= needLuck then
            num = math.ceil((needLuck - luck)/self:getPromoteLucky())
            newLuck = num * self:getPromoteLucky() + luck - needLuck
            isUp = true
        else
            newLuck = maxLuck
            num = maxNum
            isUp = false
        end
    end
    local costs = DisplayData:getDisplayObj(gemObj:getCosts())
    local costGoldNum = costs:getNum() * num
    local gold = UserData:getUserObj():getGold()
    local goldNotEnough = false
    if gold < costGoldNum then
        num = math.floor(gold/costs:getNum())
        costGoldNum = num * costs:getNum()
        newLuck = luck + num * self:getPromoteLucky()
        isUp = false
        goldNotEnough = true
    end
    return isUp,num,newLuck,costGoldNum,goldNotEnough
end

-- 根据合成数量算消耗
-- function GemObj:getAutoMergeCostByNum(num)
--     local costGoldNum = 0
--     local allNum = num
--     local maxId = self.id%100 - 1
--     local ntype = math.floor(self.id/100)
--     local allGems = BagData:getAllGems()
--     local gems = clone(allGems[ntype])
--     if maxId < 1 or not gems then
--         return 0
--     end
--     local lastObj = BagData:getGemObjById(self.id - 1)
--     local oldLuck = UserData:getUserObj():getLuck()
--     local luck = oldLuck
--     local succGemTab = {}
--     local succLuck = 0
--     local succCostGoldNum = 0
--     local mergeLowGem
--     local mergeGem
--     mergeLowGem = function(gemId)
--         local currId = gemId%100
--         if currId <= 1 then
--             return false
--         end
--         local extraGemId = gemId - 1
--         if not gems[extraGemId] or gems[extraGemId]:getNum() <= 0 then
--             local isMerge = mergeLowGem(extraGemId)
--             if not isMerge then
--                 return false
--             end
--         end
--         gems[extraGemId]:addNum(-1)
--         local needLuck = gems[extraGemId]:getLevelUpLucky()
--         local costs = DisplayData:getDisplayObj(gems[extraGemId]:getCosts())
--         if luck >= needLuck then
--             luck = luck - needLuck
--             costGoldNum = costGoldNum + costs:getNum()
--         else
--             local baseLuck = gems[extraGemId]:getBasePromoteLucky()
--             local num = math.ceil((needLuck - luck)/baseLuck)
--             luck = luck + num * baseLuck - needLuck
--             costGoldNum = costGoldNum + num * costs:getNum()
--         end
--         if not gems[gemId] then
--             gems[gemId] = BagData:getGemObjById(gemId)
--         end
--         gems[gemId]:addNum(1)
--         if gemId == self.id then
--             succGemTab = clone(gems)
--             succLuck = luck
--         end
--         return true
--     end
--     -- 合成当前的宝石
--     mergeGem = function (gemId)
--         local currId = gemId%100
--         if currId <= 3 then
--             -- isNotEnd = false
--             local isMerge = mergeLowGem(gemId)
--             if not isMerge then
--                 return false
--             end
--             return true
--         end
--         local maxId = currId - 1
--         local lastObj1 = BagData:getGemObjById(gemId - 1)
--         local costGemTab = {}
--         local costQuality = lastObj1:getCostQuality()
--         for i=3,maxId do
--             local costGemId = ntype*100 + i
--             local obj = BagData:getGemObjById(costGemId)
--             if obj:getQuality() == costQuality then
--                 costGemTab[#costGemTab + 1] = obj:getId()
--             end
--         end
--         local extraGemId = gemId - 1
--         if not gems[extraGemId] or gems[extraGemId]:getNum() <= 0 then
--             local isMerge = mergeGem(extraGemId)
--             if not isMerge then
--                 return false
--             end
--         end
--         gems[extraGemId]:addNum(-1)
--         local needLuck = lastObj1:getLevelUpLucky()
--         local isMerge = false
--         local costs = DisplayData:getDisplayObj(gems[extraGemId]:getCosts())
--         if luck >= needLuck then
--             luck = luck - needLuck
--             costGoldNum = costGoldNum + costs:getNum()
--         else
--             local currLuck = luck
--             local costGems = {}
--             for i,v in ipairs(costGemTab) do
--                 if not gems[v] or gems[v]:getNum() <= 0 or gems[v]:getNum() * gems[v]:getPromoteLucky() + currLuck < needLuck then
--                     local isNotEnd1 = true
--                     local tempLuck = currLuck
--                     while isNotEnd1 do
--                         local isMerge1 = mergeGem(v)
--                         if not isMerge1 then
--                             isNotEnd1 = false
--                         end
--                         if gems[v] then
--                             local maxLuck = tempLuck + gems[v]:getNum() * gems[v]:getPromoteLucky()
--                             if maxLuck >= needLuck then
--                                 isNotEnd1 = false
--                             end
--                         end
--                     end
--                 end
--                 if gems[v] and gems[v]:getNum() > 0 then
--                     local maxLuck = currLuck + gems[v]:getNum() * gems[v]:getPromoteLucky()
--                     if maxLuck >= needLuck then
--                         isMerge = true
--                         local num = math.ceil((needLuck - currLuck)/gems[v]:getPromoteLucky())
--                         luck = num * gems[v]:getPromoteLucky() + currLuck - needLuck
--                         gems[v]:addNum(-num)
--                         costGems[v] = (costGems[v] or 0) + num
--                         costGoldNum = costGoldNum + num * costs:getNum()
--                         break
--                     else
--                         currLuck = gems[v]:getNum() * gems[v]:getPromoteLucky() + currLuck
--                         gems[v]:addNum(-gems[v]:getNum())
--                         costGems[v] = (costGems[v] or 0) + gems[v]:getNum()
--                         costGoldNum = costGoldNum + gems[v]:getNum() * costs:getNum()
--                     end
--                 end
--             end
--             if not isMerge then
--                 gems[extraGemId]:addNum(1)
--                 for k,v in pairs(costGems) do
--                     if gems[tonumber(k)] then
--                         gems[tonumber(k)]:addNum(tonumber(v))
--                     end
--                 end
--                 return false
--             end
--         end
--         if not gems[gemId] then
--             gems[gemId] = BagData:getGemObjById(gemId)
--         end
--         gems[gemId]:addNum(1)
--         if gemId == self.id then
--             succGemTab = clone(gems)
--             succLuck = luck
--         end
--         return true
--     end

--     local isNotEnd = true
--     local nowNum = 0
--     while isNotEnd do
--         local isMerge = mergeGem(self.id)
--         if not isMerge then
--             isNotEnd = false
--         end
--         nowNum = nowNum + 1
--         if nowNum >= allNum then
--             isNotEnd = false
--         end
--     end
--     print('============================== id = ',self.id,nowNum,allNum)
--     print('=============================succLuck = ',succLuck)
--     print('=============================costGoldNum = ',costGoldNum)
--     local costGems = {}
--     local oldGems = BagData:getAllGems()[ntype]
--     for i=1,maxId do
--         local gemId = ntype * 100 + i
--         -- print(gems[gemId]:getId(),gems[gemId]:getNum())
--         if oldGems[gemId] and oldGems[gemId]:getNum() and oldGems[gemId]:getNum() > succGemTab[gemId]:getNum() then
--             costGems[gemId] = (costGems[gemId] or 0) + oldGems[gemId]:getNum() - succGemTab[gemId]:getNum()
--         end
--     end
--     if succLuck >= oldLuck then
--         -- costs[0] = {'user','luck',0}
--     else
--         costGems[0] = {'user','luck',oldLuck - succLuck}
--     end
--     -- print('===============================xxxx',costGoldNum)
--     -- printall(costGems)
--     return costGems,costGoldNum
-- end

-- -- 获取一键合成数量
-- function GemObj:getAutoMergeNum()
--     local allNum = 0
--     local maxId = self.id%100 - 1
--     local ntype = math.floor(self.id/100)
--     local allGems = BagData:getAllGems()
--     local gems = clone(allGems[ntype])
--     local oldNum = 0
--     if maxId < 1 or not gems then
--         return 0
--     end
--     local lastObj = BagData:getGemObjById(self.id - 1)
--     local luck = UserData:getUserObj():getLuck()
--     local succGemTab = {}
--     local succLuck = 0
--     if lastObj:getCostQuality() == 0 then
--         for i=1,maxId do
--             local gemId = ntype*100 + i
--             local obj = gems[gemId]
--             if obj then
--                 allNum = allNum + obj:getNum()
--             end
--         end
--         return allNum
--     else
--         oldNum = self:getNum()
--         local mergeLowGem
--         mergeLowGem = function(gemId)
--             local currId = gemId%100
--             if currId <= 1 then
--                 return false
--             end
--             local extraGemId = gemId - 1
--             if not gems[extraGemId] or gems[extraGemId]:getNum() <= 0 then
--                 local isMerge = mergeLowGem(extraGemId)
--                 if not isMerge then
--                     return false
--                 end
--             end
--             gems[extraGemId]:addNum(-1)
--             local needLuck = gems[extraGemId]:getLevelUpLucky()
--             local costs = DisplayData:getDisplayObj(gems[extraGemId]:getCosts())
--             if luck >= needLuck then
--                 luck = luck - needLuck
--             else
--                 local baseLuck = gems[extraGemId]:getBasePromoteLucky()
--                 local num = math.ceil((needLuck - luck)/baseLuck)
--                 luck = luck + num * baseLuck - needLuck
--             end
--             if not gems[gemId] then
--                 gems[gemId] = BagData:getGemObjById(gemId)
--             end
--             gems[gemId]:addNum(1)
--             -- print('================================xxx2',gems[gemId]:addNum(1))
--             return true
--         end

--         -- 合成当前的宝石
--         local function mergeGem(gemId)
--             local currId = gemId%100
--             if currId <= 3 then
--                 local isMerge = mergeLowGem(gemId)
--                 if not isMerge then
--                     return false
--                 end
--                 return true
--             end
--             local maxId = currId - 1
--             local lastObj1 = BagData:getGemObjById(gemId - 1)
--             local costGemTab = {}
--             local costQuality = lastObj1:getCostQuality()
--             for i=3,maxId do
--                 local costGemId = ntype*100 + i
--                 local obj = BagData:getGemObjById(costGemId)
--                 -- print('=======================xxx',gemId,obj:getQuality(),costQuality)
--                 if obj:getQuality() == costQuality then
--                     costGemTab[#costGemTab + 1] = obj:getId()
--                 end
--             end
--             -- print('==========================costGemTab',gemId)
--             -- printall(costGemTab)
--             local extraGemId = gemId - 1
--             if not gems[extraGemId] or gems[extraGemId]:getNum() <= 0 then
--             --     gems[extraGemId]:addNum(-1)
--             -- else
--                 local isMerge = mergeGem(extraGemId)
--                 if not isMerge then
--                     -- isNotEnd = false
--                     return false
--                 end
--             end
--             gems[extraGemId]:addNum(-1)
--             local needLuck = lastObj1:getLevelUpLucky()
--             -- print('===============================needLuck',needLuck,gemId)
--             local isMerge = false
--             if luck >= needLuck then
--                 luck = luck - needLuck
--             else
--                 local currLuck = luck
--                 local costGems = {}
--                 for i,v in ipairs(costGemTab) do
--                     if not gems[v] or gems[v]:getNum() <= 0 or gems[v]:getNum() * gems[v]:getPromoteLucky() + currLuck < needLuck then
--                         local isNotEnd1 = true
--                         -- local isMergeSucc = true
--                         local tempLuck = currLuck
--                         while isNotEnd1 do
--                             -- isNotEnd = false
--                             local isMerge1 = mergeGem(v)
--                             -- isMergeSucc = isMergeSucc or isMerge
--                             if not isMerge1 then
--                                 isNotEnd1 = false
--                             end
--                             if gems[v] then
--                                 local maxLuck = tempLuck + gems[v]:getNum() * gems[v]:getPromoteLucky()
--                                 if maxLuck >= needLuck then
--                                     isNotEnd1 = false
--                                 end
--                             end
--                         end
--                     end
--                     if gems[v] and gems[v]:getNum() > 0 then
--                         local maxLuck = currLuck + gems[v]:getNum() * gems[v]:getPromoteLucky()
--                         if maxLuck >= needLuck then
--                             isMerge = true
--                             local num = math.ceil((needLuck - currLuck)/gems[v]:getPromoteLucky())
--                             luck = num * gems[v]:getPromoteLucky() + currLuck - needLuck
--                             -- luck = currLuck
--                             gems[v]:addNum(-num)
--                             -- print('===========================v,num,num1',v,num,gems[v]:getNum())
--                             costGems[v] = (costGems[v] or 0) + num
--                             break
--                         else
--                             currLuck = gems[v]:getNum() * gems[v]:getPromoteLucky() + currLuck
--                             gems[v]:addNum(-gems[v]:getNum())
--                             costGems[v] = (costGems[v] or 0) + gems[v]:getNum()
--                         end
--                     end
--                 end
--                 if not isMerge then
--                     gems[extraGemId]:addNum(1)
--                     for k,v in pairs(costGems) do
--                         if gems[tonumber(k)] then
--                             gems[tonumber(k)]:addNum(tonumber(v))
--                         end
--                     end
--                     return false
--                 end
--             end
--             if not gems[gemId] then
--                 gems[gemId] = BagData:getGemObjById(gemId)
--             end
--             gems[gemId]:addNum(1)
--             -- print('=============================2',gemId,luck,gems[gemId]:getNum())
--             -- for i,v in pairs(gems) do
--             --     print(v:getId(),v:getNum())
--             -- end
--             if gemId == self.id then
--                 succGemTab = clone(gems)
--                 succLuck = luck
--             end
--             return true
--         end
--         local isNotEnd = true
--         while isNotEnd do
--             local isMerge = mergeGem(self.id)
--             if not isMerge then
--                 isNotEnd = false
--             end
--         end
--     end
--     if succGemTab[self.id] then
--         allNum = succGemTab[self.id]:getNum() - oldNum
--     end
--     return allNum
-- end

return GemObj
