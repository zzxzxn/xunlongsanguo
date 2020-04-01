local ClassLegionTrialMainPannelUI = require('script/app/ui/legion/legiontrial/legiontrialmainpannel')
local ClassLegionTrialGetAwardPannelUI = require('script/app/ui/legion/legiontrial/legiontrialgetawardpannel')
local ClassLegionTrialResetCoinPannelUI = require('script/app/ui/legion/legiontrial/legiontrialresetcoinpannel')
local ClassLegionTrialAchievementPannelUI = require('script/app/ui/legion/legiontrial/legiontrialachievementpannel')
local ClassLegionTrialAddRatePannelUI = require('script/app/ui/legion/legiontrial/legiontrialaddratepannel')
local ClassLegionTrialAdventurePannelUI = require('script/app/ui/legion/legiontrial/legiontrialadventurepannel')

cc.exports.LegionTrialMgr = {
	uiClass = {
        legionTrialMainPannelUI = nil,
        legionTrialGetAwardPannelUI = nil,
        legionTrialResetCoinPannelUI = nil,
        legionTrialAchievementPannelUI = nil,
        legionTrialAddRatePannelUI = nil,
        legionTrialAdventurePannelUI = nil
	},
    -- 硬币组合数组
    legionTrialCoinsArray = {
        {{1,2,3},{4,5,6},{7,8,9}},      -- 横  代表位置
        {{1,4,7},{2,5,8},{3,6,9}},      -- 竖
        {{1,5,9},{3,5,7}}               -- 斜
    },
    -- 闪烁数组序列位置
    legionTrialTwinkleArray = {{1,2,3},{1,4,7},{4,5,6},{2,5,8},{7,8,9},{3,6,9},{1,5,9},{3,5,7}},
}

-- 奇遇类型
cc.exports.LEGION_TRIAL_ADVENTURE_TYPE = {
    SHOP = 1,       -- 商人
    MONSTER = 2,    -- 挑战怪人
    CASH = 3,       -- 金币、元宝堆
}

-- 试炼成就类型
cc.exports.LEGION_TRIAL_ACHIVEMENT_TYPE = {
    HORIZONTAL_LINE = 1,        -- 完成n次横相同
    VERTRIAL_LINE = 2,          -- 完成n次竖相同
    DIAGONAL_LINE = 3,          -- 完成n次斜相同
    ALL_DIFFERENT = 4,          -- 完成n次全不同
    SHOP_COUNT = 5,             -- 完成n次商人奇遇
    MONSTER_COUNT = 6,          -- 完成n次挑战怪人奇遇
    CASH_COUNT = 7,             -- 遇见n次金币元宝堆
}

-- 硬币组合类型
cc.exports.LEGION_TRIAL_COINS_TYPE = {
    HORIZONTAL_LINE = 1,        -- 横相同
    VERTRIAL_LINE = 2,          -- 竖相同
    DIAGONAL_LINE = 3,          -- 斜相同
    ALL_DIFFERENT = 4,          -- 全不同
    NONE = 5,                   -- 什么都不是
}

setmetatable(LegionTrialMgr.uiClass, {__mode = "v"})

function LegionTrialMgr:showLegionTrialMainPannelUI(index)
    local function callBack(serverData)
        if self.uiClass["legionTrialMainPannelUI"] == nil then
		    self.uiClass["legionTrialMainPannelUI"] = ClassLegionTrialMainPannelUI.new(serverData,index)
		    self.uiClass["legionTrialMainPannelUI"]:showUI()
	    end
    end
    self:legionTrialEnterFromServer(callBack)
end

function LegionTrialMgr:hideLegionTrialMainPannelUI()
	if self.uiClass["legionTrialMainPannelUI"] then
		self.uiClass["legionTrialMainPannelUI"]:hideUI()
		self.uiClass["legionTrialMainPannelUI"] = nil
	end
end

-- 刷新成就
function LegionTrialMgr:refreshLegionTrialAchievement(data)
    if self.uiClass["legionTrialMainPannelUI"] ~= nil then
		self.uiClass["legionTrialMainPannelUI"]:refreshAchievement(data)
	end
end

-- 刷新奇遇
function LegionTrialMgr:refreshLegionTrialAdventure(data)
    if self.uiClass["legionTrialMainPannelUI"] ~= nil then
		self.uiClass["legionTrialMainPannelUI"]:refreshAdventure(data)
	end
end


function LegionTrialMgr:showLegionTrialGetAwardPannelUI(trial,curChoosePage,callBack)
    if self.uiClass["legionTrialGetAwardPannelUI"] == nil then
		self.uiClass["legionTrialGetAwardPannelUI"] = ClassLegionTrialGetAwardPannelUI.new(trial,curChoosePage,callBack)
		self.uiClass["legionTrialGetAwardPannelUI"]:showUI()
	end
end

function LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
	if self.uiClass["legionTrialGetAwardPannelUI"] then
		self.uiClass["legionTrialGetAwardPannelUI"]:hideUI()
		self.uiClass["legionTrialGetAwardPannelUI"] = nil
	end
end

function LegionTrialMgr:showLegionTrialResetCoinPannelUI(trial,round,index,callBack,callBack2)
    if self.uiClass["legionTrialResetCoinPannelUI"] == nil then
		self.uiClass["legionTrialResetCoinPannelUI"] = ClassLegionTrialResetCoinPannelUI.new(trial,round,index,callBack,callBack2)
		self.uiClass["legionTrialResetCoinPannelUI"]:showUI()
	end
end

function LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
	if self.uiClass["legionTrialResetCoinPannelUI"] then
		self.uiClass["legionTrialResetCoinPannelUI"]:hideUI()
		self.uiClass["legionTrialResetCoinPannelUI"] = nil
	end
end

function LegionTrialMgr:showLegionTrialAchievementPannelUI(trial,callBack)
    if self.uiClass["legionTrialAchievementPannelUI"] == nil then
		self.uiClass["legionTrialAchievementPannelUI"] = ClassLegionTrialAchievementPannelUI.new(trial,callBack)
		self.uiClass["legionTrialAchievementPannelUI"]:showUI()
	end
end

function LegionTrialMgr:hideLegionTrialAchievementPannelUI()
	if self.uiClass["legionTrialAchievementPannelUI"] then
		self.uiClass["legionTrialAchievementPannelUI"]:hideUI()
		self.uiClass["legionTrialAchievementPannelUI"] = nil
	end
end

function LegionTrialMgr:showLegionTrialAddRatePannelUI()
    if self.uiClass["legionTrialAddRatePannelUI"] == nil then
		self.uiClass["legionTrialAddRatePannelUI"] = ClassLegionTrialAddRatePannelUI.new()
		self.uiClass["legionTrialAddRatePannelUI"]:showUI()
	end
end

function LegionTrialMgr:hideLegionTrialAddRatePannelUI()
	if self.uiClass["legionTrialAddRatePannelUI"] then
		self.uiClass["legionTrialAddRatePannelUI"]:hideUI()
		self.uiClass["legionTrialAddRatePannelUI"] = nil
	end
end

function LegionTrialMgr:showLegionTrialAdventurePannelUI(trial,index)
    local adventures = {}
    for k,v in pairs(trial.adventure) do
        if v.award_got == 0 and v.type ~= 3 then
            local time = v.time
            local nowTime = GlobalData:getServerTime()
            if nowTime < time then
                local temp = {}
                temp.index = tonumber(k)
                temp.data = v
                table.insert(adventures,temp)
            end
        end
    end
    if #adventures <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC52'), COLOR_TYPE.RED)
        return
    end
    if self.uiClass["legionTrialAdventurePannelUI"] == nil then
		self.uiClass["legionTrialAdventurePannelUI"] = ClassLegionTrialAdventurePannelUI.new(trial,index)
		self.uiClass["legionTrialAdventurePannelUI"]:showUI()
	end
end

function LegionTrialMgr:hideLegionTrialAdventurePannelUI()
	if self.uiClass["legionTrialAdventurePannelUI"] then
		self.uiClass["legionTrialAdventurePannelUI"]:hideUI()
		self.uiClass["legionTrialAdventurePannelUI"] = nil
	end
end

-- 根据硬币id（1到9,3个的组合）得到硬币组合的类型
function LegionTrialMgr:getCoinType(ids)
    local legionTrialCoinsArray = LegionTrialMgr.legionTrialCoinsArray
    local legionTrialCoinsType = LEGION_TRIAL_COINS_TYPE.NONE
	for i = 1,#legionTrialCoinsArray,1 do
        local temp = legionTrialCoinsArray[i]
        for j = 1,#temp,1 do
            local subTemp = temp[j]
            if self:judgeIsEqualArrays(ids,subTemp) == true then
                return i
            end
        end
    end

    return legionTrialCoinsType
end

-- 判断2个集合（无序的）是否相等
function LegionTrialMgr:judgeIsEqualArrays(array1,array2)
    local array1Clone = clone(array1)
    local array2Clone = clone(array2)

    local array1Num = #array1Clone
    local array2Num = #array2Clone
    if array1Num ~= array2Num then
        return false
    end

    table.sort(array1Clone,function(a, b) return b > a end)
    table.sort(array2Clone,function(a, b) return b > a end)

    local judge = true
    for i = 1,array1Num,1 do
        if array1Clone[i] ~= array2Clone[i] then
            judge = false
            break
        end
    end

    return judge
end

function LegionTrialMgr:calcTrialLv(serverLv)
	local trialconf = GameData:getConfData('legiontrialbaseconfig')
	local tablelv = {}
	for k,v in pairs(trialconf) do
		table.insert(tablelv,k)
	end
	table.sort( tablelv, function(a,b)
		return a < b
	end )

	local serverLv = serverLv
	local lv = tablelv[#tablelv]
	for i=1 ,#tablelv do
		if i < (#tablelv-1) and serverLv >= tablelv[i] and serverLv < tablelv[i+1] then
			lv = tablelv[i]
		end
	end
	return lv
end

-- 军团试炼基础奖励倍率
function LegionTrialMgr:getLegionTrialBaseRate()
    return 1
end

-- 军团试炼总探索次数
function LegionTrialMgr:getLegionTrialAllEcploreCount()
    return 27
end

-- 根据数组（小于等于9个），得到奖励倍率加成
function LegionTrialMgr:getLegionTrialAddAwardRate(ids)
    local allNum = #ids
    local temp = {
        ["1"] = 0,      -- 1是类型，0是倍率
        ["2"] = 0,
        ["3"] = 0,
        ["4"] = 0,
        ["5"] = 0       -- 1 表示 什么都没有
    }

    local rate = 0
    local judge = false
    local reachCount = 0
    for i = 1,allNum,1 do
        if ids[i] > 0 then
            reachCount = reachCount + 1
        end
        for j = i + 1,allNum,1 do
            if judge == true then
                break
            end
            if ids[j] == ids[i] then    -- 至少有1个相同
                judge = true
            end
        end
    end
    
    -- 全不相同
    if judge == false then
        -- 如果达成数量等于9个
        if reachCount == 9 then
            temp[tostring(4)] = 1
        else
            temp[tostring(5)] = 1
        end
        return temp
    end

    local horizontal = 0
    local vertrial = 0
    local diagonal = 0

    local legionTrialCoinsArray = LegionTrialMgr.legionTrialCoinsArray
	for i = 1,#legionTrialCoinsArray,1 do
        local temp2 = legionTrialCoinsArray[i]
        for j = 1,#temp2,1 do
            local subTemp = temp2[j]
            local value1 = ids[subTemp[1]]
            local value2 = ids[subTemp[2]]
            local value3 = ids[subTemp[3]]

            if value1 and value2 and value3 and value1 ~= 0 and value2 ~= 0 and value3 ~= 0 and value1 == value2 and value2 == value3 then
                -- 判断3个是否相同
                if i == LEGION_TRIAL_COINS_TYPE.HORIZONTAL_LINE then
                    horizontal = horizontal + 1
                elseif i == LEGION_TRIAL_COINS_TYPE.VERTRIAL_LINE then
                    vertrial = vertrial + 1
                elseif i == LEGION_TRIAL_COINS_TYPE.DIAGONAL_LINE then
                    diagonal = diagonal + 1
                end
            end

            --[[
            -- 开始寻找 --
            local judge = false
            for k = 1,#temp2,1 do
                if judge == true then
                    break
                end
                local compareTemp = temp2[k]
                if self:judgeIsEqualArrays(judgeTemp,compareTemp) == true then
                    if i == LEGION_TRIAL_COINS_TYPE.HORIZONTAL_LINE then
                        horizontal = horizontal + 1
                    elseif i == LEGION_TRIAL_COINS_TYPE.VERTRIAL_LINE then
                        vertrial = vertrial + 1
                    elseif i == LEGION_TRIAL_COINS_TYPE.DIAGONAL_LINE then
                        diagonal = diagonal + 1
                    end
                end
            end
            -- 开始寻找 --
            --]]

        end
    end
    
    if horizontal == 0  and vertrial == 0 and diagonal == 0 then
        temp[tostring(5)] = 1
    end

    temp[tostring(1)] = horizontal
    temp[tostring(2)] = vertrial
    temp[tostring(3)] = diagonal

    --print('horizontal===========' .. horizontal)
    --print('vertrial===========' .. vertrial)
    --print('diagonal===========' .. diagonal)

    return temp
end

-- 得到闪烁数组
function LegionTrialMgr:getLegionTrialBlink(ids)
    local allNum = #ids
    local temp = {
        ["1"] = 0,      -- 1是类型，0是倍率
        ["2"] = 0,
        ["3"] = 0,
        ["4"] = 0,
        ["5"] = 0       -- 1 表示 什么都没有
    }

    local blinkArrays = {}

    local rate = 0
    local judge = false
    local reachCount = 0
    for i = 1,allNum,1 do
        if ids[i] > 0 then
            reachCount = reachCount + 1
        end
        for j = i + 1,allNum,1 do
            if judge == true then
                break
            end
            if ids[j] == ids[i] then    -- 至少有1个相同
                judge = true
            end
        end
    end
    
    -- 全不相同
    if judge == false then
        -- 如果达成数量等于9个
        if reachCount == 9 then
            temp[tostring(4)] = 1
            blinkArrays[1] = {}
            for i = 1,allNum do
                table.insert(blinkArrays[1],i)  -- 插入位置
            end
        else
            temp[tostring(5)] = 1
        end

        return temp,blinkArrays     -- 全部闪烁
    end

    local legionTrialTwinkleArray = LegionTrialMgr.legionTrialTwinkleArray
	for i = 1,#legionTrialTwinkleArray do
        local temp2 = legionTrialTwinkleArray[i]

        local value1 = ids[temp2[1]]
        local value2 = ids[temp2[2]]
        local value3 = ids[temp2[3]]

        if value1 and value2 and value3 and value1 ~= 0 and value2 ~= 0 and value3 ~= 0 and value1 == value2 and value2 == value3 then
            blinkArrays[#blinkArrays + 1] = temp2
        end

    end
    
    if #blinkArrays == 0 then
        temp[tostring(5)] = 1
    end

    return temp,blinkArrays
end

----------------------------------------------------------- 通讯 ------------------------------------------------------------------
-- 进入试炼
function LegionTrialMgr:legionTrialEnterFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("enterTrial", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 探索
function LegionTrialMgr:legionTrialExploreFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("explore", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 一键探索
function LegionTrialMgr:legionTrialOneExploreFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("explore_round", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 重置硬币 round 第几轮 index 硬币索引
function LegionTrialMgr:legionTrialResetExploreCoinFromServer(round,index,callBack)
    local args = {round = round,index = index}
    MessageMgr:sendPost("resetExploreCoin", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 领取探索奖励 round 第几轮
function LegionTrialMgr:legionTrialGetExploreAwardFromServer(round,callBack)
    local args = {round = round}
    MessageMgr:sendPost("getExploreAward", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 领取成就奖励 achievement_type 成就类型  achievement_level 成就等级
function LegionTrialMgr:legionTrialGetAchievementAwardFromServer(achievement_type,achievement_level,callBack)
    local args = {achievement_type = achievement_type,achievement_level = achievement_level}
    MessageMgr:sendPost("getAchievementAward", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 开始陪玩(以前的直接点击军团开黑)
function LegionTrialMgr:legionTrialStartChallengeMonsterFromServer(index,callBack)
    local args = {index = index}
    MessageMgr:sendPost("startChallengeMonster", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 领取陪玩奖励 index 奇遇索引
function LegionTrialMgr:legionTrialGetMonsterAwardFromServer(index,callBack)
    local args = {index = index}
    MessageMgr:sendPost("getMonsterAward", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 购买商人物品 index
function LegionTrialMgr:legionTrialBuyShopItemFromServer(index,callBack)
    local args = {index = index}
    MessageMgr:sendPost("buyShopItem", "legion", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 里面的描述暂时这样，弹出窗口暂时为一行
function LegionTrialMgr:popErrorInfo(code)
    
end
----------------------------------------------------------- 通讯 ------------------------------------------------------------------
