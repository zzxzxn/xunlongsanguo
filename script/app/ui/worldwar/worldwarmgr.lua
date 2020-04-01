
local ClassWorldWarMainUI = require("script/app/ui/worldwar/worldwarmainui")
local ClassWorldWarGoWarUI = require("script/app/ui/worldwar/worldwargowarui")
local ClassWorldWarListUI = require("script/app/ui/worldwar/worldwarlistui")
local ClassWorldWarReportUI = require("script/app/ui/worldwar/worldwarreportui")
local ClassWorldWarReplayUI = require("script/app/ui/worldwar/worldwarreplayui")
local ClassWorldWarAwardUI = require("script/app/ui/worldwar/worldwarawardui")
local ClassWorldWarKnockoutUI = require("script/app/ui/worldwar/worldwarknockoutui")
local ClassWorldWarSupportUI = require("script/app/ui/worldwar/worldwarsupportui")
local ClassWorldWarMySupportUI = require("script/app/ui/worldwar/worldwarmysupportui")
local ClassWorldWarPriceRankUI = require("script/app/ui/worldwar/worldwarpricerankui")
local ClassWorldWarMyReplayUI = require("script/app/ui/worldwar/worldwarmyreplayui")
local ClassWorldWarFeatsWallUI = require("script/app/ui/worldwar/worldwarfeatswallui")
local ClassWorldWarHelpUI = require("script/app/ui/worldwar/worldwarhelpui")

cc.exports.WorldWarMgr = {
	uiClass = {
		WorldWarMainUI = nil,
		WorldWarKnockoutUI = nil,
		WorldWarGoWarUI = nil,
		WorldWarListUI = nil,
		WorldWarReportUI = nil,
		WorldWarReplayUI = nil,
		WorldWarAwardUI = nil,
		WorldWarSupportUI = nil,
		WorldWarMySupportUI = nil,
		WorldWarPriceRankUI = nil,
		WorldWarMyReplayUI = nil,
		WorldWarFeatsWallUI = nil,
		WorldWarHelpUI = nil,
	},
    progress = nil, 			-- 当前进度
	serverId = nil, 			-- 服务器
	rank = nil, 				-- 当前名次
	score = nil,				-- 积分
	count = nil, 				-- 当前界数
	lastTop32 = nil, 			-- 上一届前32强
	currTop32 = nil, 			-- 当前32强
	replays = nil, 				-- 回放
	records = nil, 				-- 决赛每轮胜者
	top3 = nil,					-- 上一届3强
    match = nil,      			-- 当日匹配次数
    battleTimes = nil,     		-- 当日挑战次数
    matched = nil,   			-- 上次匹配的对手
    fighted = nil,   			-- 上次匹配的对手是否已经打过
    supportData = nil,   		-- 玩家支持情况
    supCount = nil,  			-- 累计成功支持的次数，是否领奖
    maxWin = nil,    			-- 累计挑战成功次数最大值，是否领奖
    winCount = nil,  			-- 当前连续挑战胜利次数
    maxRank = nil,   			-- 当前最大积分赛排名，是否领奖
    topFight = nil,  			-- 累计在晋级赛胜利的次数，是否领奖
    result = nil,				-- 是否已经准备
    maxMatchTimes = tonumber(GlobalApi:getGlobalValue('worldwarMatchLimitPerDay')),
	maxBuyMatchCash = tonumber(GlobalApi:getGlobalValue('worldwarBuyMatchCash')),
	maxBattleTimes = tonumber(GlobalApi:getGlobalValue('worldwarBattleLimitPerDay')),
	maxBuyBattle = tonumber(GlobalApi:getGlobalValue('worldwarBuyBattleCash')),
}

setmetatable(WorldWarMgr.uiClass, {__mode = "v"})

function WorldWarMgr:showWorldKnockoutWar()
	if self.uiClass['WorldWarKnockoutUI'] == nil then
		self.uiClass['WorldWarKnockoutUI'] = ClassWorldWarKnockoutUI.new(self.lastTop32,self.lastRecords,self.lastReplays)
		self.uiClass['WorldWarKnockoutUI']:showUI()
	end
end

function WorldWarMgr:showWorldMainWar()
	if self.uiClass['WorldWarMainUI'] == nil then
		self.uiClass['WorldWarMainUI'] = ClassWorldWarMainUI.new()
		self.uiClass['WorldWarMainUI']:showUI()
	end
end

function WorldWarMgr:showWorldWar()
	if self.uiClass['WorldWarMainUI'] == nil then
		local args = {}
		MessageMgr:sendPost('get','worldwar',json.encode(args),function (response)
	        
	        local code = response.code
	        local data = response.data
	        if code == 0 then
	        	self.progress = data.progress
	        	self.serverId = data.server_id
	        	self.rank = data.rank
	        	self.score = data.score or 0
	        	self.count = data.count
	        	self.lastTop32 = data.last_top32
	        	self.currTop32 = data.top32
	        	self.replays = data.replays
	        	self.records = data.records
	        	self.result = data.result
	        	self.top3 = data.top3
	        	self.lastRecords = data.last_records
	        	self.lastReplays = data.last_replays
			    self.matchTimes = data.worldwar.match
			    self.battleTimes = data.worldwar.battle
			    UserData:getUserObj():setWorldWarCount(data.worldwar.battle)
			    UserData:getUserObj():setWorldWarMatchCount(data.worldwar.match)
			    UserData:getUserObj():setWorldWarFighted(data.worldwar.fighted)
			    -- self.lastEnemy = data.worldwar.matched
			    self.lastEnemy = data.enemy
			    self.fighted = data.worldwar.fighted
			    self.supportData = data.supports
			    self.supCount = data.worldwar.sup_count
			    self.maxWin = data.worldwar.max_win
			    self.winCount = data.worldwar.win_count
			    self.maxRank = data.worldwar.max_rank
			    self.topFight = data.worldwar.top_fight
			    if self.progress == 'rank' or self.progress == 'stop' then
					self.uiClass['WorldWarMainUI'] = ClassWorldWarMainUI.new()
					self.uiClass['WorldWarMainUI']:showUI(UI_SHOW_TYPE.STUDIO)
			    else
			    	print(self.currTop32,self.records,self.replays)
					self.uiClass['WorldWarKnockoutUI'] = ClassWorldWarKnockoutUI.new(self.currTop32,self.records,self.replays,self.result)
					self.uiClass['WorldWarKnockoutUI']:showUI()
					if data.fight_info then
						self:autoFight(self.uiClass['WorldWarKnockoutUI'].root,data.fight_info)
					end
				end
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
	        end
	    end)
	end
end

function WorldWarMgr:hideWorldWarMain()
	if self.uiClass['WorldWarMainUI'] then
		self.uiClass['WorldWarMainUI']:hideUI()
		self.uiClass['WorldWarMainUI'] = nil
	end
end

function WorldWarMgr:showGoWar()
	if self.uiClass['WorldWarGoWarUI'] == nil then
		if self.lastEnemy and type(self.lastEnemy) == 'table' then
			self.uiClass['WorldWarGoWarUI'] = ClassWorldWarGoWarUI.new(self.lastEnemy)
			self.uiClass['WorldWarGoWarUI']:showUI()
		else
			self:matchEnemy(function(data)
				self.lastEnemy = data.enemy
				self.fighted = 0
				self.uiClass['WorldWarGoWarUI'] = ClassWorldWarGoWarUI.new(self.lastEnemy)
				self.uiClass['WorldWarGoWarUI']:showUI()
			end)
		end
	end
end

function WorldWarMgr:hideGoWar()
	if self.uiClass['WorldWarGoWarUI'] then
		self.uiClass['WorldWarGoWarUI']:hideUI()
		self.uiClass['WorldWarGoWarUI'] = nil
	end
end

function WorldWarMgr:showList()
	if self.uiClass['WorldWarListUI'] == nil then
		self:getRankList(function(data)
			self.uiClass['WorldWarListUI'] = ClassWorldWarListUI.new(data)
			self.uiClass['WorldWarListUI']:showUI()
		end)
	end
end

function WorldWarMgr:hideList()
	if self.uiClass['WorldWarListUI'] then
		self.uiClass['WorldWarListUI']:hideUI()
		self.uiClass['WorldWarListUI'] = nil
	end
end

function WorldWarMgr:showReport()
	if self.uiClass['WorldWarReportUI'] == nil then
		self:getReplayList(function(data)
			self.uiClass['WorldWarReportUI'] = ClassWorldWarReportUI.new(data)
			self.uiClass['WorldWarReportUI']:showUI()
		end)
	end
end

function WorldWarMgr:hideReport()
	if self.uiClass['WorldWarReportUI'] then
		self.uiClass['WorldWarReportUI']:hideUI()
		self.uiClass['WorldWarReportUI'] = nil
	end
end

function WorldWarMgr:showAward()
	if self.uiClass['WorldWarAwardUI'] == nil then
		self.uiClass['WorldWarAwardUI'] = ClassWorldWarAwardUI.new()
		self.uiClass['WorldWarAwardUI']:showUI()
	end
end

function WorldWarMgr:hideAward()
	if self.uiClass['WorldWarAwardUI'] then
		self.uiClass['WorldWarAwardUI']:hideUI()
		self.uiClass['WorldWarAwardUI'] = nil
	end
end

function WorldWarMgr:hideKnockout()
	if self.uiClass['WorldWarKnockoutUI'] then
		self.uiClass['WorldWarKnockoutUI']:hideUI()
		self.uiClass['WorldWarKnockoutUI'] = nil
	end
end

function WorldWarMgr:showReplay(id,top32,records,replays)
	if self.uiClass['WorldWarReplayUI'] == nil then
		self.uiClass['WorldWarReplayUI'] = ClassWorldWarReplayUI.new(id,top32,records,replays)
		self.uiClass['WorldWarReplayUI']:showUI()
	end
end

function WorldWarMgr:hideReplay()
	if self.uiClass['WorldWarReplayUI'] then
		self.uiClass['WorldWarReplayUI']:hideUI()
		self.uiClass['WorldWarReplayUI'] = nil
	end
end

function WorldWarMgr:showSupport(id,top32,records,replays)
	if self.uiClass['WorldWarSupportUI'] == nil then
		self.uiClass['WorldWarSupportUI'] = ClassWorldWarSupportUI.new(id,top32,records,replays)
		self.uiClass['WorldWarSupportUI']:showUI()
	end
end

function WorldWarMgr:hideSupport()
	if self.uiClass['WorldWarSupportUI'] then
		self.uiClass['WorldWarSupportUI']:hideUI()
		self.uiClass['WorldWarSupportUI'] = nil
	end
end

function WorldWarMgr:showMySupport(top32,records,replays)
	if self.uiClass['WorldWarMySupportUI'] == nil then
		self.uiClass['WorldWarMySupportUI'] = ClassWorldWarMySupportUI.new(top32,records,replays)
		self.uiClass['WorldWarMySupportUI']:showUI()
	end
end

function WorldWarMgr:hideMySupport()
	if self.uiClass['WorldWarMySupportUI'] then
		self.uiClass['WorldWarMySupportUI']:hideUI()
		self.uiClass['WorldWarMySupportUI'] = nil
	end
end

function WorldWarMgr:showPriceRank()
	if self.uiClass['WorldWarPriceRankUI'] == nil then
		self:priceRank(function(data)
			self.uiClass['WorldWarPriceRankUI'] = ClassWorldWarPriceRankUI.new(data)
			self.uiClass['WorldWarPriceRankUI']:showUI()
		end)
	end
end

function WorldWarMgr:hidePriceRank()
	if self.uiClass['WorldWarPriceRankUI'] then
		self.uiClass['WorldWarPriceRankUI']:hideUI()
		self.uiClass['WorldWarPriceRankUI'] = nil
	end
end

function WorldWarMgr:showMyReplay(top32,records,replays)
	if self.uiClass['ClassWorldWarMyReplayUI'] == nil then
		self.uiClass['ClassWorldWarMyReplayUI'] = ClassWorldWarMyReplayUI.new(top32,records,replays)
		self.uiClass['ClassWorldWarMyReplayUI']:showUI()
	end
end

function WorldWarMgr:hideMyReplay()
	if self.uiClass['ClassWorldWarMyReplayUI'] then
		self.uiClass['ClassWorldWarMyReplayUI']:hideUI()
		self.uiClass['ClassWorldWarMyReplayUI'] = nil
	end
end

function WorldWarMgr:showFeatsWall()
	if self.uiClass['WorldWarFeatsWallUI'] == nil then
		self:featsWall(function(data)
			self.uiClass['WorldWarFeatsWallUI'] = ClassWorldWarFeatsWallUI.new(data)
			self.uiClass['WorldWarFeatsWallUI']:showUI()
		end)
	end
end

function WorldWarMgr:hideFeatsWall()
	if self.uiClass['WorldWarFeatsWallUI'] then
		self.uiClass['WorldWarFeatsWallUI']:hideUI()
		self.uiClass['WorldWarFeatsWallUI'] = nil
	end
end

function WorldWarMgr:showHelp()
	if self.uiClass['WorldWarHelpUI'] == nil then
		self.uiClass['WorldWarHelpUI'] = ClassWorldWarHelpUI.new()
		self.uiClass['WorldWarHelpUI']:showUI()
	end
end

function WorldWarMgr:hideHelp()
	if self.uiClass['WorldWarHelpUI'] then
		self.uiClass['WorldWarHelpUI']:hideUI()
		self.uiClass['WorldWarHelpUI'] = nil
	end
end

function WorldWarMgr:getScheduleByProgress( progressID )
	local conf = GameData:getConfData('worldwarschedule')
	for i, v in pairs(conf) do
		if v.progress == progressID then
			return v
		end
	end
	return nil
end

function WorldWarMgr:getPlayerById(id,top32)
	local tab
	for i,v in ipairs(top32) do
		if id == v.uid then
			tab = v
			tab.index = i
			return tab
		end
	end
end

function WorldWarMgr:getRise(id,records)
    local recordsId = 0
    local temp = (id + id%2)/2
    local index16 = temp
    temp = (temp + temp%2)/2
    local index8 = temp + 16
    temp = (temp + temp%2)/2
    local index4 = temp + 24
    temp = (temp + temp%2)/2
    local index2 = temp + 28
    temp = (temp + temp%2)/2
    local index1 = temp + 30
    -- print(index1,index2,index4,index8,index16)
    local tab = {index16,index8,index4,index2,index1}
    -- printall(records)
    -- print(index16,index8,index4,index2,index1)
    for i,v in ipairs(tab) do
    	if not records[v] or records[v] == -1 then
    		-- print('===============================11111',id)
    		return true
    	elseif records[v] ~= id - 1 then
    		-- print('===============================22222',id - 1,records[v],v)
    		return false
    	end
    end
end

function WorldWarMgr:getIndexByUid(uid)
	local me = self:getPlayerById(uid,self.currTop32)
	local index = me.index
    local temp = (index + index%2)/2
    local index16 = temp
    temp = (temp + temp%2)/2
    local index8 = temp + 16
    temp = (temp + temp%2)/2
    local index4 = temp + 24
    temp = (temp + temp%2)/2
    local index2 = temp + 28
    temp = (temp + temp%2)/2
    local index1 = temp + 30
    
    local progress = self.progress
    print('===================getIndexByUid',index16,index8,index4,index2,index1,'progress = '..progress,index)
    if progress == 'sup_16' or progress == '16' then
        return index,index16
    elseif progress == 'sup_8' or progress == '8' then
        return index16,index8
    elseif progress == 'sup_4' or progress == '4' then
        return index8,index4
    elseif progress == 'sup_2' or progress == '2' then
        return index4,index2
    elseif progress == 'sup_1' or progress == '1' then
        return index2,index1
    else
    	return index1
    end
end

function WorldWarMgr:getProgressInfo(style,progress)
    local sBtn = {}
    local rImg = {}
    local progressNum = 0
    local desc = ''
    local btnInfo = {
	    [1] = {min = 1,max = 8,desc = '16'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	    [2] = {min = 9,max = 12,desc = '8'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	    [3] = {min = 13,max = 14,desc = '4'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	    [4] = {min = 15,max = 15,desc = '2'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	    [5] = {min = 0,max = 0,desc = '1'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	    [6] = {min = 0,max = 0,desc = '0'..GlobalApi:getLocalStr('KNOCK_QIANG')},
	}
	local index = 1
	if style ~= 0 then
		index = 0
	end
    if progress == 'sup_16' then
        progressNum = 16
    elseif progress == 'sup_8' then
        index = index + 1
        progressNum = 8
    elseif progress == 'sup_4' then
        index = index + 2
        progressNum = 4
    elseif progress == 'sup_2' then
        index = index + 3
        progressNum = 2
    elseif progress == 'sup_1' then
        index = index + 4
        progressNum = 1
    else
    	index = 6
        sBtn.min,sBtn.max = 0,0
    end
    return btnInfo[index],progressNum
end

function WorldWarMgr:getPlayerId(recordId,records)
    local playerId = 0
    local playerId1 = 0
    -- dump(records)
    -- print("recordId:"..recordId)
    local index = tonumber(recordId)
    if index <= 16 then
    	-- if not records[index] or records[index] == -1 then
	        playerId1 = index * 2
	        playerId = index * 2 - 1
    	-- else
	    --     playerId = records[index] + 1
	    --     playerId1 = ((playerId%2 == 1 )and playerId + 1) or playerId - 1
	    -- end
    elseif index <= 24 then
        local index1 = (index - 16)*2
        local index2 = index1 - 1
        playerId = records[index2] + 1
        playerId1 = records[index1] + 1
    elseif index <= 28 then
        local index1 = 16 + (index - 24)*2
        local index2 = index1 - 1
        playerId = records[index2] + 1
        playerId1 = records[index1] + 1
    elseif index <= 30 then
        local index1 = 24 + (index - 28)*2
        local index2 = index1 - 1
        playerId = records[index2] + 1
        playerId1 = records[index1] + 1
    elseif index == 31 then
        playerId = records[29] + 1
        playerId1 = records[30] + 1
    end
    return playerId,playerId1
end

function WorldWarMgr:playReplay(replayId)
    local args = {
        id = replayId
    }
    MessageMgr:sendPost("get_replay", "worldwar", json.encode(args), function (jsonObj)
    	local code = jsonObj.code
        if code == 0 then
        	local data = jsonObj.data
        	if data and data.report then
	            local customObj = {
	                info = jsonObj.data.report.info,
	                enemy = jsonObj.data.report.enemy,
	                rand1 = jsonObj.data.report.rand1,
	                rand2 = jsonObj.data.report.rand2
	            }
	            BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function ()
	            	local stype = GAME_UI.UI_WORLDWARKNOCKOUTUI
	            	if self.progress == 'rank' or self.progress == 'stop' then
	            		stype = GAME_UI.UI_WORLDWAR
		            end
	                MainSceneMgr:showMainCity(function()
	                    self:showWorldWar()
	                end, nil, stype)
	            end)
	        else
	        	promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
	        end
	    else
	    	promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
        end
    end)
end

function WorldWarMgr:getRecords(callback)
	local args = {}
	MessageMgr:sendPost('get_records', 'worldwar', json.encode(args), function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			self.records = data.records
			self.replays = data.replays
			self.progress = data.progress
			if callback then
				callback(data.records,data.replays)
			end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 功勋墙
]]
function WorldWarMgr:featsWall(callback)
	local args = {}
	MessageMgr:sendPost('exploit_wall', 'worldwar', json.encode(args), function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			if callback then
				callback(data)
			end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 身价排行
]]
function WorldWarMgr:priceRank(callback)
	local args = {}
	MessageMgr:sendPost('price_rank', 'worldwar', json.encode(args), function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			if callback then
				callback(data)
			end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 支持玩家
	supportid 支持玩家ID
]]
function WorldWarMgr:support(supportid)
	local args = {
		id = supportid
	}
	MessageMgr:sendPost('support', 'worldwar', json.encode(args), function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			local _,index = self:getProgressInfo(nil,self.progress)
			local level = UserData:getUserObj():getLv()
            local conf = GameData:getConfData('level')
            local num = conf[level].goldAward
			self.supportData[tostring(index)] = {supportid,num}
			UserData:getUserObj():setWorldWarSupSign(0)
			WorldWarMgr:hideSupport()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 战斗记录
]]
function WorldWarMgr:getReplayList(callback)
	MessageMgr:sendPost('get_replay_list', 'worldwar', '{}', function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			if callback then callback(data) end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 排行榜
]]
function WorldWarMgr:getRankList(callback)
	MessageMgr:sendPost('get_rank_list', 'worldwar', '{}', function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			if callback then callback(data) end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 匹配对手
]]
function WorldWarMgr:matchEnemy(callback,cash)
	local args = {
		cash = cash
	}
	MessageMgr:sendPost('match_enemy', 'worldwar', json.encode(args), function( response )
		
		local code = response.code
        local data = response.data
		if code == 0 then
			self.matchTimes = self.matchTimes + 1
			UserData:getUserObj():setWorldWarMatchCount(self.matchTimes)
			UserData:getUserObj():setWorldWarFighted(0)
			self.lastEnemy = data.enemy or {}
			self.fighted = 0
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			if callback then callback(data) end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 布阵
]]
function WorldWarMgr:embattle(callback)
	-- print('=============================0')
	-- printall(data)
	-- print('=============================1')
	local args = {}
	MessageMgr:sendPost('get_team', 'worldwar', json.encode(args), function( res )
		local code = res.code
		if code == 0 then
			BattleMgr:showEmbattleForWorldwarUI(res.data,function(args)
				MessageMgr:sendPost('set_team', 'worldwar', json.encode(args), function( response )
					local code = response.code
			        local data = response.data
					if code == 0 then
						-- BattleMgr:showEmbattleForWorldwarUI(pos)
						if callback then
							callback()
						end
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
					end
				end)
			end,'worldwar')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
		end
	end)
end

--[[ 准备战斗
]]
function WorldWarMgr:prepareFight(root,callback)
	local function succ()
		local uid = UserData:getUserObj():getUid()
		local index,recordId = self:getIndexByUid(uid)
		local parity = index%2
		-- self.result[index] = 1
		if not self.result[recordId] or self.result[recordId] == -1 then
			if parity == 1 then
				self.result[recordId] = 1
			else
				self.result[recordId] = 3
			end
		else
            local isReady = self.result[recordId]%10
			if parity == 1 then
				if isReady == 3 or isReady == 4 then
					self.result[recordId] = 5
				else
					self.result[recordId] = 1
				end
			else
				if isReady == 1 or isReady == 2 then
					self.result[recordId] = 5
				else
					self.result[recordId] = 3
				end
			end
		end
		if callback then
			callback(0)
		end
	end
	local args = {}
	MessageMgr:sendPost('prepare', 'worldwar', json.encode(args), function (jsonObj)
		if jsonObj.code == 0 then
			local customObj = {
				info = jsonObj.data.info,
				enemy = jsonObj.data.enemy,
				rand1 = jsonObj.data.rand1,
				rand2 = jsonObj.data.rand2,
				rand_pos = jsonObj.data.rand_pos,
				rand_attrs = jsonObj.data.rand_attrs,
				node = root,
			}
			BattleMgr:initLegionDie()
			BattleMgr:calculateReport(BATTLE_TYPE.WORLDWAR_2, customObj, function (reportField,sig)
				local report = reportField.totalReport
				local starNum = report.isWin and report.starNum or 0
				local args1 = {
					star = starNum,
					sig = sig,
				}
				print("starNum is :"..starNum)
				MessageMgr:sendPost('prepare_fight', 'worldwar', json.encode(args1), function (jsonObj1)
					if jsonObj1.code == 0 then
						succ()
						promptmgr:showSystenHint(GlobalApi:getLocalStr("PREPARE_SUCC"), COLOR_TYPE.GREEN)
					elseif jsonObj1.code == 102 then
						succ()
					elseif callback then
						callback(1)
					end
				end)
			end)
		elseif jsonObj.code == 102 then
			succ()
		elseif callback then
			callback(1)
		end
	end)
end

--[[ 直接计算战斗
]]
function WorldWarMgr:autoFight(root,data)
	UIManager:setBlockTouch(true)
	local customObj = {
		info = data.info,
		enemy = data.enemy,
		rand1 = data.rand1,
		rand2 = data.rand2,
		rand_pos = data.rand_pos,
		rand_attrs = data.rand_attrs,
		node = root,
	}
	BattleMgr:initLegionDie()
	BattleMgr:calculateReport(BATTLE_TYPE.WORLDWAR_2, customObj, function (reportField,sig)
		local report = reportField.totalReport
		local starNum = report.isWin and report.starNum or 0
		local args1 = {
			star = starNum,
			sig = sig,
		}
		print("starNum is :"..starNum)
		MessageMgr:sendPost('prepare_fight', 'worldwar', json.encode(args1), function (jsonObj1)
			UIManager:setBlockTouch(false)
			if jsonObj1.code == 0 then
				-- promptmgr:showSystenHint(GlobalApi:getLocalStr("PREPARE_SUCC"), COLOR_TYPE.GREEN)
			end
		end)
	end)
end

-- --[[ 战斗
-- ]]
-- function WorldWarMgr:fighting(callback,args)
-- 	local args = {
-- 		enemy = self.enemyArray[index].uid
-- 	}
-- 	MessageMgr:sendPost('prepare_fight', 'worldwar', json.encode(args), function (jsonObj)
-- 		if jsonObj.code == 0 then
-- 			local customObj = {
-- 				headpic = self.enemyArray[index].headpic,
-- 				challengeUid = self.enemyArray[index].uid,
-- 				info = jsonObj.data.info,
-- 				enemy = jsonObj.data.enemy,
-- 				rand1 = jsonObj.data.rand1,
-- 				rand2 = jsonObj.data.rand2,
-- 				rand_pos = jsonObj.data.rand_pos,
-- 				rand_attrs = jsonObj.data.rand_attrs,
-- 				maxRank = self.data.max_rank
-- 			}
-- 			if customObj.challengeUid <= 1000000 then -- 机器人
-- 				customObj.quality = 4
-- 			else
-- 				customObj.quality = self.enemyArray[index].quality
-- 			end
-- 			BattleMgr:playBattle(BATTLE_TYPE.ARENA, customObj, function (battleReportJson)
-- 				MainSceneMgr:showMainCity(function()
-- 					ArenaMgr:showArenaV2(battleReportJson)
-- 				end, nil, GAME_UI.UI_ARENA_V2)
-- 			end)
-- 		end
-- 	end)
-- end

--[[ 挑战
	uid      玩家UID
	cash     花费元宝
	revenge  是否复仇
]]
function WorldWarMgr:rankFight(index,uid,cash,revenge)
	-- local args = {
	-- 	enemy = uid,
	-- 	cash = cash,
	-- 	revenge = revenge,
	-- 	star = 3,
	-- 	replayid = replayid
	-- }
	-- MessageMgr:sendPost('rank_fight', 'worldwar', json.encode(args), function( response )
	-- 	
	-- 	local code = response.code
 --        local data = response.data
	-- 	if code == 0 then
	-- 		self.battleTimes = self.battleTimes + 1
	-- 		self.score = self.score + (data.score_add or 0)
	-- 		if callback then callback(data) end
	-- 	else
	-- 		promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
	-- 	end
	-- end)
    local args = {
        enemy = uid,
		cash = cash,
		revenge = revenge,
		rindex = index,
    }
    MessageMgr:sendPost("challenge", "worldwar", json.encode(args), function (jsonObj)
        -- print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            local customObj = {
                info = jsonObj.data.info,
                challengeUid = uid,
                revenge = revenge,
                rindex = index,
                -- replayid = replayid,
				enemy = jsonObj.data.enemy,
				rand1 = jsonObj.data.rand1,
				rand2 = jsonObj.data.rand2,
            }
            BattleMgr:playBattle(BATTLE_TYPE.WORLDWAR_1, customObj, function ()
            	self.battleTimes = self.battleTimes + 1
            	UserData:getUserObj():setWorldWarCount(self.battleTimes)
            	self.fighted = 1
                MainSceneMgr:showMainCity(function()
                    self:showWorldWar()
                end)
            end)
        end
    end)
end
