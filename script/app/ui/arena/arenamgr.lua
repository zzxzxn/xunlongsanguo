local ClassArenaUI = require("script/app/ui/arena/arenaui")
local ClassArenaRankUI = require("script/app/ui/arena/arenarankui")
local ClassArenaChangeRankUI = require("script/app/ui/arena/arenachangerankui")
local ClassArenaV2UI = require('script/app/ui/arena/arenav2')
local ClassArenaV2Report = require('script/app/ui/arena/arenav2report')
local ClassArenaAward = require('script/app/ui/arena/arenav2award')
local ClassArenaV2Daily = require('script/app/ui/arena/arenav2daily')
local ClassArenaHighestRank = require('script/app/ui/arena/arenahighestrank')

cc.exports.ArenaMgr = {
	uiClass = {
		arenaUI = nil,
		arenaRankUI = nil,
		arenaChangeRankUI = nil,
		arenaV2UI = nil,
		arenav2reportUI = nil,
		arenaawardUI = nil,
		arenav2dailyUI = nil,
		arenaHighestRankUI = nil
	},
	myRank = 0,
	myLevel = 1,
}

setmetatable(ArenaMgr.uiClass, {__mode = "v"})

function ArenaMgr:showArena()
	if self.uiClass["arenaUI"] == nil then
		self.uiClass["arenaUI"] = ClassArenaUI.new()
		self.uiClass["arenaUI"]:showUI()
	else
		print("========showArena error===========")
	end
end

function ArenaMgr:hideArena()
	if self.uiClass["arenaUI"] ~= nil then
		self.uiClass["arenaUI"]:hideUI()
		self.uiClass["arenaUI"] = nil
	end
end

function ArenaMgr:showArenaRank(index)
	if self.uiClass["arenaRankUI"] == nil then
		self.uiClass["arenaRankUI"] = ClassArenaRankUI.new(index)
		self.uiClass["arenaRankUI"]:showUI()
	end
end

function ArenaMgr:hideArenaRank()
	if self.uiClass["arenaRankUI"] ~= nil then
		self.uiClass["arenaRankUI"]:hideUI()
		self.uiClass["arenaRankUI"] = nil
	end
end

function ArenaMgr:showArenaChangeRank(headpic, quality,frameid, name1, fightforce1, name2, fightforce2, rank1, rank2, diff)
	if self.uiClass["arenaChangeRankUI"] == nil then
		self.uiClass["arenaChangeRankUI"] = ClassArenaChangeRankUI.new(headpic, quality,frameid, name1, fightforce1, name2, fightforce2, rank1, rank2, diff)
		self.uiClass["arenaChangeRankUI"]:showUI()
	end
end

function ArenaMgr:hideArenaChangeRank()
	if self.uiClass["arenaChangeRankUI"] ~= nil then
		self.uiClass["arenaChangeRankUI"]:hideUI()
		self.uiClass["arenaChangeRankUI"] = nil
	end
end

function ArenaMgr:getArenaShopSign()
    if not self.arenaData then
        return false
    end
    local judge = false
    local conf = GameData:getConfData('arenarank')
    for k,v in pairs(conf) do
        if self.arenaData.max_rank <= v.count and not self.arenaData.shop[tostring(k)] then
            local cost = DisplayData:getDisplayObj(v.cost[1])
            if cost:getNum() <= UserData:getUserObj():getArena() then
                judge = true
                break
            end
        end
    end

    return judge
end

function ArenaMgr:showArenaV2(battleReportJson)
	if self.uiClass['arenaV2UI'] == nil then
		MessageMgr:sendPost('get', 'arena', '{}', function (jsonObj)
			if jsonObj.code == 0 then
				local count = jsonObj.data.count
                self.arenaData = jsonObj.data
				UserData:getUserObj():setArenaCount(count)
				self.uiClass['arenaV2UI'] = ClassArenaV2UI.new(jsonObj, battleReportJson)
				self.uiClass['arenaV2UI']:showUI(UI_SHOW_TYPE.STUDIO)
			end
		end)
	else
		print("========showArena error===========")
	end
end

function ArenaMgr:hideArenaV2()
	if self.uiClass['arenaV2UI'] ~= nil then
		self.uiClass['arenaV2UI']:hideUI()
		self.uiClass['arenaV2UI'] = nil
	end
end

function ArenaMgr:showArenaV2Report()
	if self.uiClass.arenav2reportUI == nil then
		UserData:getUserObj():setSignByType('arena_report',0)
		self.uiClass.arenav2reportUI = ClassArenaV2Report.new()
		self.uiClass.arenav2reportUI:showUI()
	end
end

function ArenaMgr:hideArenaV2Report()
	if self.uiClass.arenav2reportUI ~= nil then
		self.uiClass.arenav2reportUI:hideUI()
		self.uiClass.arenav2reportUI = nil
	end
end

function ArenaMgr:showArenaAward(ntype,tx,callback)
	if self.uiClass.arenaawardUI == nil then
		self.uiClass.arenaawardUI = ClassArenaAward.new(ntype,tx,callback)
		self.uiClass.arenaawardUI:showUI(UI_SHOW_TYPE.STUDIO)
	end
end

function ArenaMgr:hideArenaAward()
	if self.uiClass.arenaawardUI ~= nil then
		self.uiClass.arenaawardUI:hideUI()
		self.uiClass.arenaawardUI = nil
	end
end

function ArenaMgr:showArenaV2Daily()
	if self.uiClass.arenav2dailyUI == nil then
		self.uiClass.arenav2dailyUI = ClassArenaV2Daily.new()
		self.uiClass.arenav2dailyUI:showUI()
	end
end

function ArenaMgr:hideArenaV2Daily()
	if self.uiClass.arenav2dailyUI ~= nil then
		self.uiClass.arenav2dailyUI:hideUI()
		self.uiClass.arenav2dailyUI = nil
	end
end

function ArenaMgr:showArenaHighestRank(highestRank, diffRank, displayAwards)
	if self.uiClass.arenaHighestRankUI == nil then
		self.uiClass.arenaHighestRankUI = ClassArenaHighestRank.new(highestRank, diffRank, displayAwards)
		self.uiClass.arenaHighestRankUI:showUI()
	end
end

function ArenaMgr:hideArenaHighestRank()
	if self.uiClass.arenaHighestRankUI ~= nil then
		self.uiClass.arenaHighestRankUI:hideUI()
		self.uiClass.arenaHighestRankUI = nil
	end
end