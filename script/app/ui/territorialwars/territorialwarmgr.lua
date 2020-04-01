local ClassTerritorialWarsUI = require("script/app/ui/territorialwars/territorialwars")
local ClassTerritorialWarsElement = require("script/app/ui/territorialwars/territorialwarelement")
local ClassTerritorialWarsCreature = require("script/app/ui/territorialwars/territorialwarcreature")
local ClassTerritorialWarsPlayer = require("script/app/ui/territorialwars/territorialwarplayer")
local ClassTerritorialWarsFunc = require("script/app/ui/territorialwars/territorialwarfunc")
local ClassTerritorialWarsExplor = require("script/app/ui/territorialwars/territoralwarexplor")                                                                        
local ClassTerritorialWarsAchieve = require("script/app/ui/territorialwars/territoralwarachieve")
local ClassTerritorialWarsMaterial = require("script/app/ui/territorialwars/territoralwarmaterial")
local ClassTerritorialWarReport = require("script/app/ui/territorialwars/territorialwarreport")
local ClassTerritorialWarsEnemylist = require("script/app/ui/territorialwars/territoralwarenemylist")
local ClassTerritorialWarsMsg = require("script/app/ui/territorialwars/territoralwarmsg")
local ClassTerritorialWarsElementVT = require("script/app/ui/territorialwars/territorialwarelementvt")
local ClassTerritorialWarsSmallMap = require("script/app/ui/territorialwars/territorialwarsmallmap")
local ClassTerritorialwarBoss = require("script/app/ui/territorialwars/territoralwarBoss")
local ClassTerritoralwarAwardBelong = require("script/app/ui/territorialwars/territoralwarAwardBelong")
local ClassTerritoralwardamageRank = require("script/app/ui/territorialwars/territoralwardamageRank")
local ClassTerritoralwarBossList = require("script/app/ui/territorialwars/territoralwarbosslist")
local ClassTerritoralwarRuleBook = require("script/app/ui/territorialwars/territorialwarbook")
local ClassTerritoralwarGetAll = require("script/app/ui/territorialwars/territoralwargetall")

cc.exports.TerritorialWarMgr = {
	uiClass = {
		TerritorialWarsUI = nil,
        TerritorialWarsElementUI = nil,
        TerritorialWarsCreature = nil,
        TerritorialWarsPlayer = nil,
        TerritorialWarsFunc = nil,
        TerritorialWarsExplor = nil,
        TerritorialWarsAchieve = nil,
        TerritorialWarsMaterial = nil,
        TerritorialWarReport = nil,
        TerritorialWarsEnemylist = nil,
        TerritorialWarsMsg = nil,
        TerritorialWarsElementVTUI = nil,
        TerritorialWarsSmallMapUI = nil,
        TerritorialwarBossUI = nil,
        TerritoralwardamageRankUI = nil,
        TerritoralwarBossListUI = nil,
        TerritoralwarRuleBook = nil,
        TerritoralwarGetAll = nil,
	},

    VisitType = {
       transfer_out = 1,                    --浼犻€佸叆鍙?
       transfer_in = 2,                     --浼犻€佸嚭鍙?                    
       flow_resource = 3,                   --娴佸姩鎬ц祫婧?鏈ㄥ爢锛岀熆闃?
       fixed_resource = 4,                  --鍥哄畾璧勬簮(姘翠簳闆曞儚绛?
       stone_tablet = 5,                    --鐭崇
       light_house = 6,                     --鐏(寮€瑙嗛噹)
       relic = 7,                           --閬楄抗
    },

    resourceType = {
       transfer_out = 1,                    --寤烘湪绁炴爲
       transfer_in = 2,                     --寤烘湪鏍戞礊                     
       stone_tower = 3,                     --鐭冲
       drogon_statue = 4,                   --鍦ｉ緳闆曞儚
       well = 5,                            --姘翠簳
       stele = 6,                           --鐭崇
       watchtower = 7,                      --鐬湜濉?
       relic = 8,                           --绁炵閬楄抗
       stone_heap = 9,                      --鐭冲爢
       wood_heap = 10,                      --鏈ㄥ爢
       spindle_heap = 11,                   --閿爢
       rock_heap = 12,                      --宀╁爢
       tear_heap = 13,                      --娉爢
       signet = 14,                         --榫欏鍗拌
    },

    cityState = 
    {
        cango = 1,                  --鐐瑰嚮浼犻€?
        not_visited = 2,            --灏氭湭鍗犻
        not_count = 3,              --娆℃暟涓嶈冻
        exit_enemy =4,               --鏁屼汉骞叉壈
    },

    achieveMentType = 
    {
        stele = 101,            --璁块棶鐭崇
        drgon = 102,            --鍗拌
        endurance = 103,        --鑰愬姏
        heap_base = 200,        --鐭垮爢璧峰
        stone_heap = 201,       --鐭冲爢
        wood_heap = 202,        --鏈ㄥ爢
        spindle_heap = 203,     --閿爢
        rock_heap = 204,        --宀╁爢
        tear_heap = 205,        --娉爢
        puppet = 301,           --鍌€鍎″嚮鏉€姒?
    },
    win = false,
    cost = 0,
    mapClose = false,

    msgType = 
    {
        player_move = 1,
        player_enter = 2,
        player_leave = 3,
        fight_player = 4,
        visit_stele = 5,
        visit_tower = 6,
        occupy_mine = 7,
        member_visit_cell = 8,
        monster_dead = 9,
        kick_player = 10,
        state_change = 11,
        hp_change = 12,
    },

    -- 缓存推送信息
    msgCache = {};
    myselfMsgCache = {}
}


setmetatable(TerritorialWarMgr.uiClass, {__mode = "v"})

function TerritorialWarMgr:init()
    self:registerSynMsg()
    self.opacityFlag = true
end

function TerritorialWarMgr:setOpactityFlag(flag)
    self.opacityFlag = flag
end

function TerritorialWarMgr:getOpactityFlag()
     return self.opacityFlag
end

function  TerritorialWarMgr:shoWarBossListUI()
    TerritorialWarMgr:showMapUI(function ()
        self:showBossListUI()
    end)
end

function  TerritorialWarMgr:showMapUI(callback)
    
    local legionCfg = GameData:getConfData("legion")
    local limitLv = tonumber(legionCfg["legionDfOpenLevel"].value)
    local llevel = tonumber(UserData:getUserObj():getLLevel())
          llevel = llevel and llevel or 0
    local legionOpen = (llevel >= limitLv) and true or false 
    if not legionOpen then
        local errStr = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO46'),limitLv)
        promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
        return
    end
    MessageMgr:sendPost('get','territorywar',json.encode({}),function (response)
	    local code = response.code
	    local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end

        local awards = response.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
        end

        local stayingPower = response.data.staying_power
        local stayingPowerTime = response.data.staying_power_time
        UserData:getUserObj():setStayingPower(stayingPower)
        UserData:getUserObj():setStayingPowerTime(stayingPowerTime)

        local actionPoint = response.data.action_point
        local actionPointTime = response.data.action_point_time
        UserData:getUserObj():setActionPoint(actionPoint)
        UserData:getUserObj():setActionPointTime(actionPointTime)

        UIManager:closeAllUI()
        
        if self.uiClass['TerritorialWarsUI'] == nil then
            self.uiClass['TerritorialWarsUI'] = ClassTerritorialWarsUI.new(data,callback)
        end
        self.uiClass['TerritorialWarsUI']:showUI(UI_SHOW_TYPE.CUSTOM)
    end)
	
end

function TerritorialWarMgr:clearAroundCells(args)
    if self.uiClass['TerritorialWarsUI'] then
        self.uiClass['TerritorialWarsUI']:clearAroundCells()
    end
end

function TerritorialWarMgr:hideMapUI()
    LegionMgr:showMainUI(function()
        if self.uiClass['TerritorialWarsUI'] ~= nil then
            self.uiClass['TerritorialWarsUI']:hideUI()
            self.uiClass['TerritorialWarsUI'] = nil
        end
    end)
end

function TerritorialWarMgr:showSmallMapUI(openCells,posCellTab,territoryWar,hextab,curHexPos,otherObj,bossCellId)
    if self.uiClass['TerritorialWarsSmallMapUI'] == nil then
        self.uiClass['TerritorialWarsSmallMapUI'] = ClassTerritorialWarsSmallMap.new(openCells,posCellTab,territoryWar,hextab,curHexPos,otherObj,bossCellId)
        self.uiClass['TerritorialWarsSmallMapUI']:showUI()
    end
end

function TerritorialWarMgr:hideSmallMapUI()
    if self.uiClass['TerritorialWarsSmallMapUI'] ~= nil then
        self.uiClass['TerritorialWarsSmallMapUI']:hideUI()
        self.uiClass['TerritorialWarsSmallMapUI'] = nil
    end
end

function TerritorialWarMgr:showElementUI(resId,cellId,around,visited,myselfLand)

    if self.uiClass['TerritorialWarsElementUI'] == nil then
        self.uiClass['TerritorialWarsElementUI'] = ClassTerritorialWarsElement.new(resId,cellId,around,visited,myselfLand)
		self.uiClass['TerritorialWarsElementUI']:showUI()
    end
end

function TerritorialWarMgr:hideElementUI()
	if self.uiClass['TerritorialWarsElementUI'] ~= nil then
		self.uiClass['TerritorialWarsElementUI']:hideUI()
		self.uiClass['TerritorialWarsElementUI'] = nil
	end
end


function TerritorialWarMgr:showElementVTUI(resId,cellId,around,tab,showtype)
    if self.uiClass['TerritorialWarsElementVTUI'] == nil then
        self.uiClass['TerritorialWarsElementVTUI'] = ClassTerritorialWarsElementVT.new(resId,cellId,around,tab,showtype)
        self.uiClass['TerritorialWarsElementVTUI']:showUI()
    end
end

function TerritorialWarMgr:hideElementVTUI()
    if self.uiClass['TerritorialWarsElementVTUI'] ~= nil then
        self.uiClass['TerritorialWarsElementVTUI']:hideUI()
        self.uiClass['TerritorialWarsElementVTUI'] = nil
    end
end

function TerritorialWarMgr:showCreatureUI(resId,cellId,around,stayingPower)
    if self.uiClass['TerritorialWarsCreature'] == nil then
        self.uiClass['TerritorialWarsCreature'] = ClassTerritorialWarsCreature.new(resId,cellId,around,stayingPower)
		self.uiClass['TerritorialWarsCreature']:showUI()
    end
end

function TerritorialWarMgr:hideCreatureUI()
	if self.uiClass['TerritorialWarsCreature'] ~= nil then
		self.uiClass['TerritorialWarsCreature']:hideUI()
		self.uiClass['TerritorialWarsCreature'] = nil
	end
end

function TerritorialWarMgr:showPlayerUI(playerInfo,around)
    if self.uiClass['TerritorialWarsPlayer'] == nil then
            self.uiClass['TerritorialWarsPlayer'] = ClassTerritorialWarsPlayer.new(playerInfo,around)
		    self.uiClass['TerritorialWarsPlayer']:showUI()
        end
end

function TerritorialWarMgr:hidePlayerUI()
	if self.uiClass['TerritorialWarsPlayer'] ~= nil then
		self.uiClass['TerritorialWarsPlayer']:hideUI()
		self.uiClass['TerritorialWarsPlayer'] = nil
	end
end

function TerritorialWarMgr:showFuncUI(id)
    if self.uiClass['TerritorialWarsFunc'] == nil then
        MessageMgr:sendPost('get_city_state','territorywar',json.encode(args),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                return
            end 
            self.uiClass['TerritorialWarsFunc'] = ClassTerritorialWarsFunc.new(id,data.cities)
		    self.uiClass['TerritorialWarsFunc']:showUI()
        end)
    end
end

function TerritorialWarMgr:hideFuncUI()
	if self.uiClass['TerritorialWarsFunc'] ~= nil then
		self.uiClass['TerritorialWarsFunc']:hideUI()
		self.uiClass['TerritorialWarsFunc'] = nil
	end
end

function TerritorialWarMgr:showExplorUI(relicId)
    if self.uiClass['TerritorialWarsExplor'] == nil then
            self.uiClass['TerritorialWarsExplor'] = ClassTerritorialWarsExplor.new(relicId)
		    self.uiClass['TerritorialWarsExplor']:showUI()
        end
end

function TerritorialWarMgr:hideExplorUI()
	if self.uiClass['TerritorialWarsExplor'] ~= nil then
		self.uiClass['TerritorialWarsExplor']:hideUI()
		self.uiClass['TerritorialWarsExplor'] = nil
	end
end

function TerritorialWarMgr:showAchieveUI(i)
    if self.uiClass['TerritorialWarsAchieve'] == nil then
            self.uiClass['TerritorialWarsAchieve'] = ClassTerritorialWarsAchieve.new(i)
		    self.uiClass['TerritorialWarsAchieve']:showUI()
        end
end

function TerritorialWarMgr:hideAchieveUI()
	if self.uiClass['TerritorialWarsAchieve'] ~= nil then
		self.uiClass['TerritorialWarsAchieve']:hideUI()
		self.uiClass['TerritorialWarsAchieve'] = nil
	end
end

function TerritorialWarMgr:showMaterialUI()
    if self.uiClass['TerritorialWarsMaterial'] == nil then
            self.uiClass['TerritorialWarsMaterial'] = ClassTerritorialWarsMaterial.new()
		    self.uiClass['TerritorialWarsMaterial']:showUI()
        end
end

function TerritorialWarMgr:hideMaterialUI()
	if self.uiClass['TerritorialWarsMaterial'] ~= nil then
		self.uiClass['TerritorialWarsMaterial']:hideUI()
		self.uiClass['TerritorialWarsMaterial'] = nil
	end
end

function TerritorialWarMgr:showReportUI()
    if self.uiClass['TerritorialWarReport'] == nil then
        self.uiClass['TerritorialWarReport'] = ClassTerritorialWarReport.new()
		self.uiClass['TerritorialWarReport']:showUI()
    end
end

function TerritorialWarMgr:hideReportUI()
    if self.uiClass['TerritorialWarReport'] ~= nil then
		self.uiClass['TerritorialWarReport']:hideUI()
		self.uiClass['TerritorialWarReport'] = nil
	end
end

function TerritorialWarMgr:showEnemylistUI(enemylist,isaround)
    if self.uiClass['TerritorialWarsEnemylist'] == nil then
            self.uiClass['TerritorialWarsEnemylist'] = ClassTerritorialWarsEnemylist.new(enemylist,isaround)
		    self.uiClass['TerritorialWarsEnemylist']:showUI()
        end
end

function TerritorialWarMgr:hideEnemylistUI()
	if self.uiClass['TerritorialWarsEnemylist'] ~= nil then
		self.uiClass['TerritorialWarsEnemylist']:hideUI()
		self.uiClass['TerritorialWarsEnemylist'] = nil
	end
end

function TerritorialWarMgr:showMsgUI(nType,win,staying)
    if self.uiClass['TerritorialWarsMsg'] == nil then
            self.uiClass['TerritorialWarsMsg'] = ClassTerritorialWarsMsg.new(nType,win,staying)
		    self.uiClass['TerritorialWarsMsg']:showUI()
        end
end

function TerritorialWarMgr:hideMsgUI()
	if self.uiClass['TerritorialWarsMsg'] ~= nil then
		self.uiClass['TerritorialWarsMsg']:hideUI()
		self.uiClass['TerritorialWarsMsg'] = nil
	end
end

function TerritorialWarMgr:getDragonResCount()

    local resCount = 0
    if self.uiClass['TerritorialWarsUI'] then
        resCount = self.uiClass['TerritorialWarsUI']:getDragonResCount()
    end
    return resCount
end

function TerritorialWarMgr:showBossUI(bossforceCfg,indexParam,cellId,curLid,level,isAround)

    if not bossforceCfg or not indexParam then
        return
    end
    if self.uiClass['TerritorialwarBossUI'] == nil then
        MessageMgr:sendPost('get_boss_info','territorywar',json.encode(args),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                return
            end 
            self.uiClass['TerritorialwarBossUI'] = ClassTerritorialwarBoss.new(bossforceCfg,indexParam,cellId,curLid,level,data.challengeCount,data.legionIcon,data.legionName,isAround)
            self.uiClass['TerritorialwarBossUI']:showUI()
        end)
    end
end
function TerritorialWarMgr:closeBossUI()
    if self.uiClass['TerritorialwarBossUI'] ~= nil then
        self.uiClass['TerritorialwarBossUI']:hideUI()
        self.uiClass['TerritorialwarBossUI'] = nil
    end
end

function TerritorialWarMgr:showAwardBelongUI(type,legionlv)
    if self.uiClass['TerritoralwarAwardBelongUI'] == nil then
        self.uiClass['TerritoralwarAwardBelongUI'] = ClassTerritoralwarAwardBelong.new(type,legionlv)
        self.uiClass['TerritoralwarAwardBelongUI']:showUI()
    end
end

function TerritorialWarMgr:closeAwardBelongUI()
    if self.uiClass['TerritoralwarAwardBelongUI'] ~= nil then
        self.uiClass['TerritoralwarAwardBelongUI']:hideUI()
        self.uiClass['TerritoralwarAwardBelongUI'] = nil
    end
end

function TerritorialWarMgr:showDamageRankUI(curLid)
    if self.uiClass['TerritoralwardamageRankUI'] == nil then
        MessageMgr:sendPost('get_boss_rank','territorywar',json.encode({lid = curLid}),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                return
            end 
            self.uiClass['TerritoralwardamageRankUI'] = ClassTerritoralwardamageRank.new(data.self,data.boss.legions,data.boss.players)
            self.uiClass['TerritoralwardamageRankUI']:showUI()
        end)
    end
end

function TerritorialWarMgr:closeDamageRankUI()
    if self.uiClass['TerritoralwardamageRankUI'] ~= nil then
        self.uiClass['TerritoralwardamageRankUI']:hideUI()
        self.uiClass['TerritoralwardamageRankUI'] = nil
    end
end

function TerritorialWarMgr:showBossListUI()
    if self.uiClass['TerritoralwarBossListUI'] == nil then
        MessageMgr:sendPost('get_boss_list','territorywar',json.encode({}),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                return
            end 
            self.uiClass['TerritoralwarBossListUI'] = ClassTerritoralwarBossList.new(data.self,data.enemy1,data.enemy2)
            self.uiClass['TerritoralwarBossListUI']:showUI()
        end)
    end
end

function TerritorialWarMgr:closeBossListUI()
    if self.uiClass['TerritoralwarBossListUI'] ~= nil then
        self.uiClass['TerritoralwarBossListUI']:hideUI()
        self.uiClass['TerritoralwarBossListUI'] = nil
    end
end

function TerritorialWarMgr:showRuleBookUI()
    if self.uiClass['TerritoralwarRuleBook'] == nil then

        self.uiClass['TerritoralwarRuleBook'] = ClassTerritoralwarRuleBook.new()
        self.uiClass['TerritoralwarRuleBook']:showUI()
    end
end

function TerritorialWarMgr:closeRuleBookUI()
    if self.uiClass['TerritoralwarRuleBook'] ~= nil then
        self.uiClass['TerritoralwarRuleBook']:hideUI()
        self.uiClass['TerritoralwarRuleBook'] = nil
    end
end

function TerritorialWarMgr:showTerritoralwarGetAll(awards,notHome,callback)
    if self.uiClass['TerritoralwarGetAll'] == nil then
        self.uiClass['TerritoralwarGetAll'] = ClassTerritoralwarGetAll.new(awards,notHome,callback)
        self.uiClass['TerritoralwarGetAll']:showUI()
    end
end

function TerritorialWarMgr:hideTerritoralwarGetAll()
    if self.uiClass['TerritoralwarGetAll'] ~= nil then
        self.uiClass['TerritoralwarGetAll']:hideUI()
        self.uiClass['TerritoralwarGetAll'] = nil
    end
end

-------------------------------------------

function  TerritorialWarMgr:locationPos(target)
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    self.uiClass['TerritorialWarsUI']:locationPos(target)
end

function TerritorialWarMgr:isCellCanClick(cellId)
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:isCellCanClick(cellId)
end

function TerritorialWarMgr:collectElement(cellId,gone)

    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    self.uiClass['TerritorialWarsUI']:CollectElement(cellId,gone)
end

function TerritorialWarMgr:occupyMineral(cellId,name)

    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    self.uiClass['TerritorialWarsUI']:OccupyMineral(cellId,name)
end

function TerritorialWarMgr:getSteleCount()

    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    local count = self.uiClass['TerritorialWarsUI']:getSteleCount()
    return count
end

function TerritorialWarMgr:updateMapInfo()
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    MessageMgr:sendPost('get','territorywar',json.encode({}),function (response)

		local code = response.code
		local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end

        local awards = response.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
        end

        local stayingPower = response.data.staying_power
        local stayingPowerTime = response.data.staying_power_time
        UserData:getUserObj():setStayingPower(stayingPower)
        UserData:getUserObj():setStayingPowerTime(stayingPowerTime)

        local actionPoint = response.data.action_point
        local actionPointTime = response.data.action_point_time
        UserData:getUserObj():setActionPoint(actionPoint)
        UserData:getUserObj():setActionPointTime(actionPointTime)

        self.uiClass['TerritorialWarsUI']:setData(data.territoryWar, data.territoryData, data.playerList, data.enemies, data.stele, data.visitedCells, true)
        if self.ntype ~= nil and self.ntype == 1 or self.ntype == 3 then
            self:showMsgUI(self.ntype,self.win,self.cost)
        end
    end)
    
end

function TerritorialWarMgr:transportCityState(cellId,cost)
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    local stateId = self.uiClass['TerritorialWarsUI']:transportCityState(cellId,cost)
    return stateId
end

function TerritorialWarMgr:getTransferCount()
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    return self.uiClass['TerritorialWarsUI']:getTransferCount()
end

function TerritorialWarMgr:getKillPuppetCount()
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    return self.uiClass['TerritorialWarsUI']:getKillPuppetCount()
end

function TerritorialWarMgr:getAchieveAwardState(nType,target,goldId)
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    return self.uiClass['TerritorialWarsUI']:getAchieveAwardState(nType,target,goldId)
end

function TerritorialWarMgr:setAchieveRecord(nType,goldId)
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end

    return self.uiClass['TerritorialWarsUI']:setAchieveRecord(nType,goldId)
end

function TerritorialWarMgr:getRelicList()
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:getRelicList()
end

function TerritorialWarMgr:setRelicListData(id,info)

    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:setRelicListData(id,info)
end

function TerritorialWarMgr:removeFinishRelic(id)

    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:removeFinishRelic(id)
end

function  TerritorialWarMgr:updateWeekAchieve()
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:updateWeekAchieve()
end

function  TerritorialWarMgr:setBattleEnd(ntype,win,cost)
    
    self.ntype,self.win,self.cost = ntype,win,cost

end

function  TerritorialWarMgr:getBattleEnd()
    return self.ntype,self.win,self.cost
end
function TerritorialWarMgr:getSteleState(cellId)
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:getSteleState(cellId)

end

function TerritorialWarMgr:deleteMonster(cellId)
    
    if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    return self.uiClass['TerritorialWarsUI']:deleteMonster(cellId)

end
function TerritorialWarMgr:getTime(time1,timeShowType)
    local h = string.format("%02d", math.floor(time1/3600))
    local m = string.format("%02d", math.floor(time1%3600/60))
    local s = string.format("%02d", math.floor(time1%3600%60%60))
    if timeShowType == true then
        return m..':'..s
    elseif timeShowType == false then
        return string.format("%d", math.floor(time1%3600%60%60))
    else
        return h..':'..m..':'..s
    end
end

-- 澶勭悊閿欒娑堟伅
function TerritorialWarMgr:handleErrorCode(errorCode)
    local errStr = GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_' .. errorCode)
    if errStr == nil then
        errStr = 'unknow error'
    end

    promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
end

--鑾峰彇鍔犳垚鍙傛暟
function TerritorialWarMgr:getAddParam(name)
    
    local buildId = self:getBuildingId(name)
    local buildLv = UserData:getUserObj():getLegionCityBuildingLevel(buildId)
    local addValue = 0
    local leginCityCfg = GameData:getConfData('legioncityconf')[buildId]
    for k,v in pairs(leginCityCfg) do
        if k ~= 'type' and tonumber(v.level) == buildLv then
            addValue = v.value[1]
        end
    end
    return addValue
end

--鑾峰彇鐜╁鍩庢睜Id
function TerritorialWarMgr:getBuildingId(name)
    
   local leginCityBaseCfg = GameData:getConfData('legioncitybase')
   local buildId = 0
   for k,v in ipairs(leginCityBaseCfg) do
      for i=1,4 do
        if v['buildFunction' .. i] == name then
            buildId = tonumber(v['buildId' .. i])
            break
        end
      end
   end
   return buildId
end

--璁＄畻濂栧姳瀹為檯浜у嚭
function TerritorialWarMgr:getRealCount(name,base,param,param1)

    --print('name: ' ,name,base,param,param1)
    local addParam = self:getAddParam(name)
    --print('addparam:' ,addParam,type(addParam))
    if type(addParam) ~= 'number' then
       return 0
    end

    local result = 0
    --1.閬楄抗鍩虹濂栧姳 2.閬楄抗鎺㈢储鏃堕棿 3.閬楄抗鍔犻€熸秷鑰?4.鐭跨偣鎺犲ず鏀剁泭 5.姘翠簳琛屽姩鍔涙仮澶?6.鎴樻枟鑰愬姏鎹熻€?7.姘翠簳鑰愬姏鍥炲
    if name == 'relicBaseAward' or name == 'relicExploreTime' or name == 'relicAccelerateCost' or name == 'minePillageAward' or
       name == 'actionRecover' or name == 'enduranceLoseDamping' or name == 'enduranceRecover' then

       result = math.floor(base*(1+addParam/100))

    --1.琛屽姩鍔涙仮澶嶉€熷害 2.鑰愬姏鎭㈠閫熷害
    elseif name == 'actionRecoverRate' or name == 'enduranceRecoverRate' then
        
        result = math.floor(base*(1-addParam/100))

    --鍏抽殬浼ゅ鍑忓厤
    elseif name == 'defendLose' then
        result = 0
    --鐭跨偣浜у嚭鏀剁泭
    elseif name == 'mineAward' then
      
      result = math.floor(base*param/100*(1+addParam/100)+base*param1/100)
    --琛屽姩鍔涗笂闄?
    elseif name == 'actionMax' then
       result = base + addParam

    else
       result = 0
    end

    --print('result: ' ,result)
    return result
end

--注册消息
function TerritorialWarMgr:registerSynMsg()

    CustomEventMgr:addEventListener("territorywar_player_position_change",self,function (msg)
        self:OtherPlayerPosChange(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_player_enter",self,function (msg) 
        self:otherPlayerEnter(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_player_leave",self,function (msg) 
     self:removeOthers(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_fight_player",self,function (msg) 
     self:showResult(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_visit_stele",self,function (msg) 
     self:updateStele(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_visit_tower",self,function (msg) 
     self:updateWatchTowerState(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_occupy_mine",self,function (msg) 
     self:updateMine(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_legion_member_visit_cell",self,function (msg) 
     self:onLegionMemberVisitCell(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_monster_dead",self,function (msg) 
        self:updateShareMonsterDeath(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_kick_player",self,function (msg) 
        self:kickPlayer(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_fight_state_change",self,function (msg) 
        self:fightStateChange(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_boss_birth",self,function (msg) 
        self:bossbirth(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_player_hp_change",self,function (msg) 
        self:playerHpChange(msg)
    end)

    CustomEventMgr:addEventListener("territorywar_monster_hp_change",self,function (msg) 
        self:monsterHpChange(msg)
    end)
end

function TerritorialWarMgr:removeSynMsg()
    CustomEventMgr:removeEventListener("territorywar_player_position_change",self)

    CustomEventMgr:removeEventListener("territorywar_player_enter",self)

    CustomEventMgr:removeEventListener("territorywar_player_leave",self)

    CustomEventMgr:removeEventListener("territorywar_fight_player",self)

    CustomEventMgr:removeEventListener("territorywar_visit_stele",self)

    CustomEventMgr:removeEventListener("territorywar_visit_tower",self)

    CustomEventMgr:removeEventListener("territorywar_occupy_mine",self)

    CustomEventMgr:removeEventListener("territorywar_legion_member_visit_cell",self)

    CustomEventMgr:removeEventListener("territorywar_monster_dead",self)

    CustomEventMgr:removeEventListener("territorywar_kick_player",self)

    CustomEventMgr:removeEventListener("territorywar_fight_state_change",self)

    CustomEventMgr:removeEventListener("territorywar_boss_birth",self)
end

function TerritorialWarMgr:cacheMsg(msg_type, msg)
    local msgObj = {}
    msgObj.type = msg_type
    msgObj.msg = msg

    print('+++++++++++++++++cache msg type = ' .. msg_type)

    if msg_type == TerritorialWarMgr.msgType.player_move or 
        msg_type == TerritorialWarMgr.msgType.player_enter or 
        msg_type == TerritorialWarMgr.msgType.player_leave or
        msg_type == TerritorialWarMgr.msgType.hp_change then

        -- 无差别消息，服务器有发uid
        if self.msgCache == nil then
            self.msgCache = {}
        end

        self.msgCache[msg.uid] = msgObj
    else
        -- 针对自己的消息，服务器没发uid
        if self.myselfMsgCache == nil then
            self.myselfMsgCache = {}
        end

        table.insert(self.myselfMsgCache, msgObj)
    end
end

function TerritorialWarMgr:processCacheMsg(data)
    for k, v in pairs(self.msgCache) do
        local key = tostring(k)
        if v.type == TerritorialWarMgr.msgType.player_move then
            if data.playerList[key] ~= nil then
                data.playerList[key].pos.lid = v.msg.lid
                data.playerList[key].pos.cellId = v.msg.cellId
            end
        elseif v.type == TerritorialWarMgr.msgType.player_enter then
            local playerObj = data.playerList[key]
            if not playerObj then
                return
            end
            playerObj.uid = v.msg.uid
            playerObj.un = v.msg.un
            playerObj.lid = v.msg.lid
            playerObj.dragon = v.msg.dragon
            playerObj.pos = {}
            playerObj.pos.lid = v.msg.pos.lid
            playerObj.pos.cellId = v.msg.pos.cellId
            playerObj.stayingPower = v.msg.stayingPower
            data.playerList[key] = playerObj
        elseif v.type == TerritorialWarMgr.msgType.hp_change then

            local hp = (v.msg.stayingPower == 0) and 100 or v.msg.stayingPower
            if data.playerList[key] then
                data.playerList[key].stayingPower = hp
            end

        elseif v.type == TerritorialWarMgr.msgType.player_leave then
            data.playerList[key] = nil
        end
    end

    self.msgCache = {}
end

function TerritorialWarMgr:updateAfterLoading()
    
    for k, v in ipairs(self.myselfMsgCache) do
        if v.type == TerritorialWarMgr.msgType.fight_player then
            self.uiClass['TerritorialWarsUI']:showResult(v.msg)
        elseif v.type == TerritorialWarMgr.msgType.visit_stele then
            self.uiClass['TerritorialWarsUI']:updateStele(v.msg)
        elseif v.type == TerritorialWarMgr.msgType.visit_tower then
            self.uiClass['TerritorialWarsUI']:updateWatchTowerState(v.msg)
        elseif v.type == TerritorialWarMgr.msgType.occupy_mine then
            self.uiClass['TerritorialWarsUI']:updateMine(v.msg)
        elseif v.type == TerritorialWarMgr.msgType.member_visit_cell then
        elseif v.type == TerritorialWarMgr.msgType.monster_dead then
            self.uiClass['TerritorialWarsUI']:updateShareMonsterDeath(v.msg)
        elseif v.type == TerritorialWarMgr.msgType.kick_player then
            self.uiClass['TerritorialWarsUI']:kickPlayer(v.msg)
        end
    end
    self.myselfMsgCache = {}
end

--鐜╁绉诲姩
function TerritorialWarMgr:OtherPlayerPosChange(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.player_move, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:OtherPlayerPosChange(msg)
end

 --鐜╁杩涘叆鍦板浘閫氱煡
function TerritorialWarMgr:otherPlayerEnter(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.player_enter, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:otherPlayerEnter(msg)
end

function TerritorialWarMgr:playerHpChange(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.hp_change, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:playerHpChange(msg)
end

function TerritorialWarMgr:monsterHpChange(msg)
     if self.uiClass['TerritorialWarsUI'] == nil then
        return
    end
    self.uiClass['TerritorialWarsUI']:monsterHpChange(msg)
end

--鐜╁绂诲紑棰嗗湴閫氱煡
function TerritorialWarMgr:removeOthers(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.player_leave, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:removeOthers(msg.uid)
end

--鍙楁敾鍑绘柟
function TerritorialWarMgr:showResult(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.fight_player, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:showResult(msg)
end

--鍚屾鐭崇
function TerritorialWarMgr:updateStele(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.visit_stele, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:updateStele(msg)
end

--鍚屾鐬湜濉?
function TerritorialWarMgr:updateWatchTowerState(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.visit_tower, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:updateWatchTowerState(msg)
end

-- 鍚屾鐭垮崰棰?
function TerritorialWarMgr:updateMine(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.occupy_mine, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:updateMine(msg)
end

-- 鍚屾鍐涘洟鎴愬憳璁块棶鏍煎瓙
function TerritorialWarMgr:onLegionMemberVisitCell(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.member_visit_cell, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:onLegionMemberVisitCell(msg)
end

-- 鍚屾鍏变韩鎬墿姝讳骸
function TerritorialWarMgr:updateShareMonsterDeath(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.monster_dead, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:updateShareMonsterDeath(msg)
end

function TerritorialWarMgr:kickPlayer(msg)
     if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.kick_player, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:kickPlayer(msg)
end

function TerritorialWarMgr:fightStateChange(msg)
    if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        self:cacheMsg(TerritorialWarMgr.msgType.state_change, msg)
        return
    end
    self.uiClass['TerritorialWarsUI']:onPlayerFightStateChange(msg)
end

function TerritorialWarMgr:bossbirth(msg)
    if self.uiClass['TerritorialWarsUI'] == nil or self.uiClass['TerritorialWarsUI']:isLoadFinish() == false then
        return
    end
    self.uiClass['TerritorialWarsUI']:bossbirth(msg)
end


function TerritorialWarMgr:getPuppetNewImg()
    local obj = BagData:getMaterialById(310001)
    if obj and obj:getNum() > 0 then
        return true
    end
    return false
end

function TerritorialWarMgr:getSecretboxNewImg()
    local obj = BagData:getMaterialById(310002)
    if obj and obj:getNum() > 0 then
        return true
    end
    local obj = BagData:getMaterialById(310003)
    if obj and obj:getNum() > 0 then
        return true
    end
    return false
end

function TerritorialWarMgr:getRelicNewImg()
    local relicList = self:getRelicList()
    for k,v in pairs(relicList) do
        if v.endTime == 0 then
            return true
        end
    end
    return false
end

function TerritorialWarMgr:getAllFuncNewImg()
    return self:getPuppetNewImg() or self:getSecretboxNewImg() or self:getRelicNewImg()
end

function TerritorialWarMgr:getMaterialNewImg()
    local territoryData = UserData:getUserObj():getTerritorialWar()
    local userLevel = territoryData.level
    if userLevel == nil then
        print("territoryData.level nil in mgr line 867")
        userLevel = UserData:getUserObj():getLv()
    end

    for i = 1,5 do
        local achieveType = self.achieveMentType.heap_base+i
        local typeConfig = GameData:getConfData("dfachievementtype")
        local levels = typeConfig[achieveType].level
        local awardIndex = 1
        for k,v in pairs(levels) do
            if userLevel >= v then
                awardIndex = k
            end
        end
        local dfachieveConfig = GameData:getConfData("dfachievement")[achieveType]
        local achieve = {}
        for k,v in pairs(dfachieveConfig) do
            if k ~= 'type' then
                achieve[#achieve+1] = v
            end
        end
        --1-宸查鍙?2-鏈揪鎴?3-鍙互棰嗗彇
        local index,notgetIndex = 0,0
        for k,v in ipairs(achieve) do
            local state,finishCount = self:getAchieveAwardState(achieveType,v.target,v.goalId)
            if state == 3 then
                notgetIndex = tonumber(k)
                break
            end
            if state == 2 then
                index = tonumber(k)
                break
            end
        end
        local realKey = 1
        if index == 0 and notgetIndex == 0 then
            realKey = #achieve
        elseif notgetIndex ~= 0 then
            realKey = notgetIndex
        elseif notgetIndex == 0 and index ~= 0 then
            realKey = index
        end
        --1-宸查鍙?2-鏈揪鎴?3-鍙互棰嗗彇
        local state,finishCount = self:getAchieveAwardState(achieveType,achieve[realKey].target,achieve[realKey].goalId)
        if state == 3 then
            return true
        end
    end
    return false
end