local ClassExclusiveMainUI = require("script/app/ui/exclusive/exclusivemain")
local ClassExclusiveExchangeUI = require("script/app/ui/exclusive/exclusiveexchange")
local ClassExclusivePokedexUI = require("script/app/ui/exclusive/exclusivepokedex")
local ClassExclusiveTipsUI = require("script/app/ui/exclusive/exclusivetips")
local ClassExclusiveRecruitEntranceUI = require("script/app/ui/exclusive/exclusiverecruitentrance")
local ClassExclusiveCheckMainUI = require("script/app/ui/exclusive/exclusivecheckmain")
local ClassExclusiveCheckTenMainUI = require("script/app/ui/exclusive/exclusivechecktenmain")
local ClassExclusiveAnimateUI = require("script/app/ui/exclusive/exclusiveanimate")
local ClassExclusivePutUI = require("script/app/ui/exclusive/exclusiveput")

-- 宝物
cc.exports.ExclusiveMgr = {
	uiClass = {
        exclusiveMainUI = nil,
        exclusiveExchangeUI = nil,
		exclusivePokedexUI = nil,
        exclusiveTipsUI = nil,
        exclusiveRecruitEntranceUI = nil,
        exclusiveCheckMainUI = nil,
        exclusiveCheckTenMainUI = nil,
        exclusiveAnimateUI = nil,
		exclusivePutUI = nil,
	},
    dirty = false
}

function ExclusiveMgr:showExclusiveAnimateUI(awards, func, recuitetype,drawNum)
    if self.uiClass["exclusiveAnimateUI"] == nil then
        self.uiClass["exclusiveAnimateUI"] = ClassExclusiveAnimateUI.new(awards, func, recuitetype,drawNum)
        self.uiClass["exclusiveAnimateUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveAnimateUI()
    if self.uiClass["exclusiveAnimateUI"] then
        self.uiClass["exclusiveAnimateUI"]:hideUI()
        self.uiClass["exclusiveAnimateUI"] = nil
    end
end

function ExclusiveMgr:recuit(recuitetype)
    if self.uiClass["exclusiveCheckMainUI"] then
        self.uiClass["exclusiveCheckMainUI"]:recuit(recuitetype)
    end
end

function ExclusiveMgr:recuitTen(recuitType,drawNum)
    if self.uiClass["exclusiveCheckTenMainUI"] then
        self.uiClass["exclusiveCheckTenMainUI"]:recuitTen(recuitType,drawNum)
    end
end

function ExclusiveMgr:showExclusiveCheckTenMainUI(type)
    if self.uiClass["exclusiveCheckTenMainUI"] == nil then
        self.uiClass["exclusiveCheckTenMainUI"] = ClassExclusiveCheckTenMainUI.new(type)
        self.uiClass["exclusiveCheckTenMainUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveCheckTenMainUI()
    if self.uiClass["exclusiveCheckTenMainUI"] then
        self.uiClass["exclusiveCheckTenMainUI"]:hideUI()
        self.uiClass["exclusiveCheckTenMainUI"] = nil
    end
end

function ExclusiveMgr:showExclusiveCheckMainUI(special)
	if special == true then
        ExclusiveMgr:hideExclusivePokedexUI()
		ExclusiveMgr:hideExclusiveMainUI()
    end
    if self.uiClass["exclusiveCheckMainUI"] == nil then
        self.uiClass["exclusiveCheckMainUI"] = ClassExclusiveCheckMainUI.new()
        self.uiClass["exclusiveCheckMainUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveCheckMainUI()
    if self.uiClass["exclusiveCheckMainUI"] then
        self.uiClass["exclusiveCheckMainUI"]:hideUI()
        self.uiClass["exclusiveCheckMainUI"] = nil
    end
end

function ExclusiveMgr:showExclusiveRecruitEntranceUI()
    if self.uiClass["exclusiveRecruitEntranceUI"] == nil then
        self.uiClass["exclusiveRecruitEntranceUI"] = ClassExclusiveRecruitEntranceUI.new()
        self.uiClass["exclusiveRecruitEntranceUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveRecruitEntranceUI()
    if self.uiClass["exclusiveRecruitEntranceUI"] then
        self.uiClass["exclusiveRecruitEntranceUI"]:hideUI()
        self.uiClass["exclusiveRecruitEntranceUI"] = nil
    end
end

function ExclusiveMgr:showExclusiveTipsUI(obj,pos)
    if self.uiClass["exclusiveTipsUI"] == nil then
        self.uiClass["exclusiveTipsUI"] = ClassExclusiveTipsUI.new(obj,pos)
        self.uiClass["exclusiveTipsUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveTipsUI()
    if self.uiClass["exclusiveTipsUI"] then
        self.uiClass["exclusiveTipsUI"]:hideUI()
        self.uiClass["exclusiveTipsUI"] = nil
    end
end

function ExclusiveMgr:showExclusivePutUI(obj,pos,callBack)
    if self.uiClass["exclusivePutUI"] == nil then
        self.uiClass["exclusivePutUI"] = ClassExclusivePutUI.new(obj,pos,callBack)
        self.uiClass["exclusivePutUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusivePutUI()
    if self.uiClass["exclusivePutUI"] then
        self.uiClass["exclusivePutUI"]:hideUI()
        self.uiClass["exclusivePutUI"] = nil
    end
end

local function sortFn(a, b)
    local q1 = a:getQuality()
    local q2 = b:getQuality()
    local godId1 = (a.getGodId and a:getGodId()) or 0
    local godId2 = (b.getGodId and b:getGodId()) or 0
    local level1 = (a.getGodLevel and a:getGodLevel()) or 0
    local level2 = (b.getGodLevel and b:getGodLevel()) or 0
    if godId1 == 2 then
    	godId1 = 1
    end
    if godId2 == 2 then
    	godId2 = 1
    end
    if godId1 == godId2 then
	    if q1 == q2 then
	    	if level1 == level2 then
		        local l1 = a:getLevel()
		        local l2 = b:getLevel()
		        if l1 == l2 then
		        	local id1 = a:getId()
		        	local id2 = b:getId()
		        	return id1 < id2
		        else
		        	return l1 > l2
		        end
		    else
		    	return level1 > level2
		    end
	    else
	        return q1 > q2
	    end
	else
		return godId1 > godId2
	end
end

setmetatable(ExclusiveMgr.uiClass, {__mode = "v"})

function ExclusiveMgr:showExclusivePokedexUI()
	if self.uiClass["exclusivePokedexUI"] == nil then
		self.uiClass["exclusivePokedexUI"] = ClassExclusivePokedexUI.new()
		self.uiClass["exclusivePokedexUI"]:showUI()
	end
end

function ExclusiveMgr:hideExclusivePokedexUI()
	if self.uiClass["exclusivePokedexUI"] then
		self.uiClass["exclusivePokedexUI"]:hideUI()
		self.uiClass["exclusivePokedexUI"] = nil
	end
end

function ExclusiveMgr:getDirty()
    return self.dirty
end

function ExclusiveMgr:setDirty(dirty)
    self.dirty = dirty
end

function ExclusiveMgr:showExclusiveMainUI(index,special)
    if special == true then
        ExclusiveMgr:hideExclusiveMainUI()
        ExclusiveMgr:hideExclusivePokedexUI()
    end
	if self.uiClass["exclusiveMainUI"] == nil then
		self.uiClass["exclusiveMainUI"] = ClassExclusiveMainUI.new(index)
		self.uiClass["exclusiveMainUI"]:showUI()
	end
end

function ExclusiveMgr:hideExclusiveMainUI()
	if self.uiClass["exclusiveMainUI"] then
		self.uiClass["exclusiveMainUI"]:hideUI()
		self.uiClass["exclusiveMainUI"] = nil
	end
end

function ExclusiveMgr:showExclusiveExchangeUI(showTab,exclusiveObj,roleObj)
    if self.uiClass["exclusiveExchangeUI"] == nil then
        self.uiClass["exclusiveExchangeUI"] = ClassExclusiveExchangeUI.new(showTab,exclusiveObj,roleObj)
        self.uiClass["exclusiveExchangeUI"]:showUI()
    end
end

function ExclusiveMgr:hideExclusiveExchangeUI()
    if self.uiClass["exclusiveExchangeUI"] then
        self.uiClass["exclusiveExchangeUI"]:hideUI()
        self.uiClass["exclusiveExchangeUI"] = nil
    end
end

function ExclusiveMgr:getMakeExclusiveMap()
    local showTab = {}
    local exclusiveConf = GameData:getConfData("exclusive")
    for k,v in pairs(exclusiveConf) do
        if v.level <= tonumber(GlobalApi:getGlobalValue('showStarLvl')) then
            local exclusiveObj = BagData:getExclusiveObjById(tonumber(k))
            table.insert(showTab, exclusiveObj)
        end
    end
	table.sort( showTab, sortFn )
    return showTab
end

function ExclusiveMgr:getMergeExclusiveMap()
    local exclusiveMap = BagData:getAllExclusive()
    local showTab = {}

    for j = 1,tonumber(GlobalApi:getGlobalValue('openStarLvl')) - 1 do
        showTab[j] = {}
        for i = 1,4 do
            local tab = exclusiveMap[i]
            if tab then
                for k, v in pairs(tab) do
                    if v:getLevel() == j then
                        table.insert(showTab[j], v)
                    end
                end
	        end
        end
        table.sort( showTab[j], sortFn )
    end

    return showTab
end

function ExclusiveMgr:getRecastExclusiveMap()
    local exclusiveMap = BagData:getAllExclusive()
    local showTab = {}

    for j = 1,tonumber(GlobalApi:getGlobalValue('openStarLvl')) do
        showTab[j] = {}
        for i = 1,4 do
            local tab = exclusiveMap[i]
            if tab then
                for k, v in pairs(tab) do
                    if v:getLevel() == j then
                        table.insert(showTab[j], v)
                    end
                end
	        end
        end
        table.sort( showTab[j], sortFn )
    end

    return showTab
end

function ExclusiveMgr:getExclusiveMapByType(type,id)
    local exclusiveMap = BagData:getAllExclusive()
    local showTab = {}
	local tab = exclusiveMap[type]
	if tab then
        for k, v in pairs(tab) do
            if id and id ~= v:getId() then
                table.insert(showTab, v)
            end
        end
	end
	table.sort( showTab, sortFn )
    return showTab
end

function ExclusiveMgr:sortData(tab)
    table.sort( tab, sortFn )
end

function ExclusiveMgr:putOnExclusive(roleObj,id,callBack)
    local args = {
        pos = roleObj:getPosId(),
        id = id
    }
    MessageMgr:sendPost("equip", "exclusive", json.encode(args), function (response)
	    local code = response.code
	    if code == 0 then
            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				--GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end
            local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
            roleObj:putOnExclusive(id)
            if callBack then
                callBack()
            end
	    end
    end)
end

function ExclusiveMgr:takeOffExclusive(roleObj,id,callBack)
    local args = {
        pos = roleObj:getPosId(),
        id = id
    }
    MessageMgr:sendPost("unequip", "exclusive", json.encode(args), function (response)
	    local code = response.code
	    if code == 0 then
            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				--GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end
            local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
            roleObj:takeOffExclusive(id)
            if callBack then
                callBack()
            end
	    end
    end)
end

function ExclusiveMgr:makeExclusive(num,callBack,callBack2)
    local args = {
        num = num
    }
    MessageMgr:sendPost("build", "exclusive", json.encode(args), function (response)
	    local code = response.code
	    if code == 0 then
            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
			end
            local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
            if callBack then
                callBack(awards)
            end
        else
            if callBack2 then
                callBack2()
            end
	    end
    end)
end

function ExclusiveMgr:mergeExclusive(ids,except,callBack,errorCallBack)
    local args = {
        ids = ids,
        except = except
    }
    MessageMgr:sendPost("compose", "exclusive", json.encode(args), function (response)
	    local code = response.code
	    if code == 0 then
            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
			end
            local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
            if callBack then
                callBack(awards)
            end
		else
			if errorCallBack then
				errorCallBack()
			end
	    end
    end)
end

function ExclusiveMgr:recastExclusive(id,callBack,errorCallBack)
    local args = {
        id = id
    }
    MessageMgr:sendPost("recast", "exclusive", json.encode(args), function (response)
	    local code = response.code
	    if code == 0 then
            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
			end
            local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
            if callBack then
                callBack(awards,response.data.group)
            end
		else
			if errorCallBack then
				errorCallBack()
			end
	    end
    end)
end

function ExclusiveMgr:canMakeExclusive()
    local canMake = false

    local wday = tonumber(Time.date('%w', GlobalData:getServerTime()))
    if wday == 0 then
        wday = 7
    end
    local exclusiveBuildData = GameData:getConfData('exclusivebuild')[wday]
    local disPlayData = DisplayData:getDisplayObjs(exclusiveBuildData.cost)

    local countLimit = tonumber(GlobalApi:getGlobalValue('makeTimes'))
    local judge = true
    for i = 1,6 do
        local awards = disPlayData[i]
        local num = math.floor(awards:getOwnNum()/awards:getNum())
        if num < countLimit then
            judge = false
            break
        end
    end
    if judge == true then
        local costCoin = disPlayData[7]:getNum()*countLimit
        if UserData:getUserObj():getGold() >= costCoin then
            canMake = true
        end
    end

    return canMake
end

function ExclusiveMgr:canTreasureExclusive()
    local haveNew = false
    for i=1,MAXROlENUM do
        local obj = RoleData:getRoleByPos(i)
        if obj and obj:getId() > 0 and obj:isCanEquipExclusive() == true then
            return true
        end
    end
    return haveNew
end