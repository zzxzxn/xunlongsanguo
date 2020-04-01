local ClassCountryWarMapUI = require("script/app/ui/country/countrywar/countrywarmapui")
local ClassCountryWarMainUI = require("script/app/ui/country/countrywar/countrywarmainui")
local ClassCountryWarAwardUI = require("script/app/ui/country/countrywar/countrywarawardui")
local ClassCountryWarListUI = require("script/app/ui/country/countrywar/countrywarlistui")
local ClassCountryWarOrderUI = require("script/app/ui/country/countrywar/countrywarorderui")
local ClassCountryWarTaskUI = require("script/app/ui/country/countrywar/countrywartaskui")
local ClassCountryWarBattlefieldInfoUI = require("script/app/ui/country/countrywar/countrywarbattlefieldinfoui")
local ClassCountryWarMatchUI = require("script/app/ui/country/countrywar/countrywarmatchui")
local ClassCountryWarCityInfoUI = require("script/app/ui/country/countrywar/countrywarcityinfoui")
local ClassCountryWarVictoryUI = require("script/app/ui/country/countrywar/countrywarvictoryui")
local ClassCountryWarDefeatUI = require("script/app/ui/country/countrywar/countrywardefeatui")
local ClassCountryWarCityLogUI = require("script/app/ui/country/countrywar/countrywarcitylogui")
local CountryWarCityPlayerInfoUI = require("script/app/ui/country/countrywar/countrywarcityplayerinfoui")

cc.exports.CountryWarMgr = {
    uiClass = {
        countryWarMapUI = nil,
        countryWarMainUI = nil,
        countryWarAwardUI = nil,
        countryWarListUI = nil,
        countryWarOrderUI = nil,
        countryWarTaskUI = nil,
        countryWarBattlefieldInfoUI = nil,
        countryWarMatchUI = nil,
        countryWarVictoryUI = nil,
        countryWarDefeatUI = nil,
        countryWarCityLogUI = nil,
    },
    mapClose = false,
    rank = 0,
    countrywar = nil,
    citys = nil,
    countryCities = nil,
    move = nil,
    myCity = nil,
    roomId = nil,
    camp = nil,
    victoryHide = true,
    defeatHide = true,
    callCount = 0,
    diffTime = 0,
}

setmetatable(CountryWarMgr.uiClass, {__mode = "v"})

function CountryWarMgr:getBaseValue(key)
    local conf = GameData:getConfData("countrywarbase")
    if conf[key].value and #conf[key].value == 1 then
        return conf[key].value[1]
    else
        return conf[key].value or ''
    end
end

function CountryWarMgr:showCountryWarCityInfo(cityId)
    local args = {
        target_city = cityId
    }
    if self.uiClass["countryWarCityInfoUI"] == nil then
        MessageMgr:sendPost("get_city_info", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.uiClass["countryWarCityInfoUI"] = ClassCountryWarCityInfoUI.new(cityId,data.cityInfo)
                self.uiClass["countryWarCityInfoUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarCityInfo()
    if self.uiClass["countryWarCityInfoUI"] then
        self.uiClass["countryWarCityInfoUI"]:hideUI()
        self.uiClass["countryWarCityInfoUI"] = nil
    end
end

function CountryWarMgr:showCountryWarMap(cityId,callback)
    local level = UserData:getUserObj():getLv()
    local conf = GameData:getConfData('moduleopen')['countrywar']
    if level < conf.level then
        promptmgr:showSystenHint(conf.level..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'), COLOR_TYPE.RED)
        return
    end
    if self.uiClass["countryWarMapUI"] == nil then
        MessageMgr:sendPost("get", "countrywar", "{}", function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.rank = data.rank
                self.countrywar = data.countrywar
                -- self.countrywar.city = tonumber(self.countrywar.city) 
                self.citys = data.cities
                self.countryCities = data.countryCities
                self.callOfDutyData = data.callOfDuty
                self.move = data.move
                self.myCity = tonumber(self.countrywar.city)
                self.deadCoolingTime = data.countrywar.deathTime
                self.coolingTime = data.countrywar.coolTime
                self.roomId = data.countrywar.roomId
                self.camp = data.countrywar.camp
                self.callCount = data.count
                local chatLog = data.chatLog
                local chatDatas = {}
                for i = #chatLog,1,-1 do
                    local chatData = chatLog[i]
                    if chatData.user and chatData.user.camp and chatData.user.camp == CountryWarMgr.camp then
                        table.insert(chatDatas,chatLog[i])
                    end
                end
                ChatNewMgr.countryWarChannelDatas = chatDatas
                local shoutLog = data.shoutLog
                local shoutDatas = {}
                for i = #shoutLog,1,-1 do
                    table.insert(shoutDatas,shoutLog[i])
                end
                ChatNewMgr.countryWarShoutChannelDatas = shoutDatas
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                CountryWarMgr:GetMsg()
                self.uiClass["countryWarMapUI"] = ClassCountryWarMapUI.new(cityId,callback,function()
                    local awards = data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                    end
                end)
                self.uiClass["countryWarMapUI"]:showUI()
            else
                self:errorCode(code)
            end
        end)
    else
        if callback then
            callback()
        end
    end
end

function CountryWarMgr:isDead()
    if not self.deadCoolingTime then
        return false
    else
        local reliveTime = tonumber(CountryWarMgr:getBaseValue('reliveTime'))
        local nowTime = GlobalData:getServerTime() + self.diffTime
        if nowTime >= reliveTime + self.deadCoolingTime then
            return false
        else
            return true,reliveTime + self.deadCoolingTime - nowTime
        end
    end
end

function CountryWarMgr:updateSpinePos(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateSpinePos(cityId or self.myCity)
    end
end

function CountryWarMgr:udpateCallOfDuty(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:udpateCallOfDuty(cityId)
    end
end

function CountryWarMgr:getMoveFlag()
    if self.uiClass["countryWarMapUI"] then
        return self.uiClass["countryWarMapUI"]:getMoveFlag()
    else
        return true
    end
end

function CountryWarMgr:setSyncMove(msg)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:syncMove(msg)
    end
end

function CountryWarMgr:setMapChatMsg(msg)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:setChatMsg(msg)
    end
end

function CountryWarMgr:setMapLittleChatMsg(msg)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:setLittleChatMsg(msg)
    end
end

function CountryWarMgr:updateSpecialMoveImg(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateSpecialMoveImg(cityId)
    end
end

function CountryWarMgr:setWinPosition(pos,isNotAction,cityId,callback)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:setWinPosition(pos,isNotAction,cityId,callback)
    end
end

function CountryWarMgr:updateCountryWarMapWithoutSpine(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updatePanelWithoutSpine(cityId)
    end
end

function CountryWarMgr:removeOldPoint()
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:removeOldPoint()
    end
end

function CountryWarMgr:updateCountryWarMap(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updatePanel(cityId)
    end
end

function CountryWarMgr:updateCountryWarMapCityBtnCell(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateCityBtnCell(cityId)
    end
end

function CountryWarMgr:startMoving(beginId,endId,way)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:startMoving(beginId,endId,way)
    end
end

function CountryWarMgr:goBack()
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:goBack()
    end
end

function CountryWarMgr:hideCountryWarMap()
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:hideUI()
        self.uiClass["countryWarMapUI"] = nil
    end
end

function CountryWarMgr:updateChatShowStatus()
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateChatShowStatus()
    end
end

function CountryWarMgr:showCountryWarVictory(data,enemy,callback)
    if self.uiClass["countryWarVictoryUI"] == nil then
        self.victoryHide = false
        self.uiClass["countryWarVictoryUI"] = ClassCountryWarVictoryUI.new(data,enemy,callback)
        self.uiClass["countryWarVictoryUI"]:showUI()
    end
end

function CountryWarMgr:hideCountryWarVictory()
    if self.uiClass["countryWarVictoryUI"] then
        self.victoryHide = true
        self.uiClass["countryWarVictoryUI"]:hideUI()
        self.uiClass["countryWarVictoryUI"] = nil
    end
end

function CountryWarMgr:getOpenTime(callback)
    MessageMgr:sendPost("get_open_time", "countrywar", "{}", function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            if callback then
                callback(data)
            end
        else
            self:errorCode(code)
        end
    end)
end

function CountryWarMgr:showCountryWarMain()
    if self.uiClass["countryWarMainUI"] == nil then
        MessageMgr:sendPost("get_open_time", "countrywar", "{}", function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.openTimeBeginTime = data.beginTime
                self.openTimeEndTime = data.endTime
                self.openTimeCurTime = data.curTime
                self.diffTime = data.curTime - response.serverTime
                self.openTimeNowTime = GlobalData:getServerTime() + self.diffTime
                self.uiClass["countryWarMainUI"] = ClassCountryWarMainUI.new(data)
                self.uiClass["countryWarMainUI"]:showUI()
            else
                self:errorCode(code)
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarMain()
    if self.uiClass["countryWarMainUI"] then
        self.uiClass["countryWarMainUI"]:hideUI()
        self.uiClass["countryWarMainUI"] = nil
    end
end

function CountryWarMgr:showCountryWarAward(page,page1,countryRank,weekRank,dayRank)
    if self.uiClass["countryWarAwardUI"] == nil then
        self.uiClass["countryWarAwardUI"] = ClassCountryWarAwardUI.new(page,page1,countryRank,weekRank,dayRank)
        self.uiClass["countryWarAwardUI"]:showUI()
    end
end

function CountryWarMgr:hideCountryWarAward()
    if self.uiClass["countryWarAwardUI"] then
        self.uiClass["countryWarAwardUI"]:hideUI()
        self.uiClass["countryWarAwardUI"] = nil
    end
end

function CountryWarMgr:showCountryWarDefeat(data,callback)
    if self.uiClass["countryWarDefeatUI"] == nil then
        self.defeatHide = false
        self.uiClass["countryWarDefeatUI"] = ClassCountryWarDefeatUI.new(data,callback)
        self.uiClass["countryWarDefeatUI"]:showUI()
    end
end

function CountryWarMgr:hideCountryWarDefeat()
    if self.uiClass["countryWarDefeatUI"] then
        self.defeatHide = true
        self.uiClass["countryWarDefeatUI"]:hideUI()
        self.uiClass["countryWarDefeatUI"] = nil
    end
end

function CountryWarMgr:showCountryWarCityLog()
    if self.uiClass["countryWarCityLogUI"] == nil then
        local args = {
            city_id = self.myCity
        }
        MessageMgr:sendPost('get_events','countrywar',json.encode(args),function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.uiClass["countryWarCityLogUI"] = ClassCountryWarCityLogUI.new(data)
                self.uiClass["countryWarCityLogUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarCityLog()
    if self.uiClass["countryWarCityLogUI"] then
        self.uiClass["countryWarCityLogUI"]:hideUI()
        self.uiClass["countryWarCityLogUI"] = nil
    end
end

function CountryWarMgr:showCountryWarList(page)
    if self.uiClass["countryWarListUI"] == nil then
        local args = {}
        MessageMgr:sendPost('get_rank_list','countrywar',json.encode(args),function (response)
            local code = response.code
            if code == 0 then
                local data = response.data
                self.camp = tonumber(data.camp)
                self.uiClass["countryWarListUI"] = ClassCountryWarListUI.new(data,page)
                self.uiClass["countryWarListUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarList()
    if self.uiClass["countryWarListUI"] then
        self.uiClass["countryWarListUI"]:hideUI()
        self.uiClass["countryWarListUI"] = nil
    end
end

function CountryWarMgr:showCountryWarOrder()
    if self.uiClass["countryWarOrderUI"] == nil then
        MessageMgr:sendPost("get_call_list", "countrywar", "{}", function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local num = 0
                for k,v in pairs(data.callList) do
                    num = num + 1
                end
                self.callOfDutyData = data.callList
                if num > 0 then
                    self.uiClass["countryWarOrderUI"] = ClassCountryWarOrderUI.new(data.callList)
                    self.uiClass["countryWarOrderUI"]:showUI()
                else
                    self:errorCode(1004)
                end
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarOrder()
    if self.uiClass["countryWarOrderUI"] then
        self.uiClass["countryWarOrderUI"]:hideUI()
        self.uiClass["countryWarOrderUI"] = nil
    end
end

function CountryWarMgr:showCountryWarCityPlayerInfo(camp)
    local args = {
        city_id = self.myCity,
        camp = camp,
    }
    if self.uiClass["countryWarCityPlayerInfoUI"] == nil then
        MessageMgr:sendPost("get_city_camp_players", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                if #data.players <= 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_88'), COLOR_TYPE.RED)
                    return
                else
                    self.uiClass["countryWarCityPlayerInfoUI"] = CountryWarCityPlayerInfoUI.new(data,camp)
                    self.uiClass["countryWarCityPlayerInfoUI"]:showUI()
                end
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarCityPlayerInfo()
    if self.uiClass["countryWarCityPlayerInfoUI"] then
        self.uiClass["countryWarCityPlayerInfoUI"]:hideUI()
        self.uiClass["countryWarCityPlayerInfoUI"] = nil
    end
end

function CountryWarMgr:showCountryWarTask(page)
    if self.uiClass["countryWarTaskUI"] == nil then
        MessageMgr:sendPost("get_country_task", "countrywar", "{}", function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.uiClass["countryWarTaskUI"] = ClassCountryWarTaskUI.new(page,data)
                self.uiClass["countryWarTaskUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarTask()
    if self.uiClass["countryWarTaskUI"] then
        self.uiClass["countryWarTaskUI"]:hideUI()
        self.uiClass["countryWarTaskUI"] = nil
    end
end

function CountryWarMgr:showCountryWarBattlefieldInfo()
    if self.uiClass["countryWarBattlefieldInfoUI"] == nil then
        MessageMgr:sendPost("get_score", "countrywar", "{}", function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.uiClass["countryWarBattlefieldInfoUI"] = ClassCountryWarBattlefieldInfoUI.new(data)
                self.uiClass["countryWarBattlefieldInfoUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:hideCountryWarBattlefieldInfo()
    if self.uiClass["countryWarBattlefieldInfoUI"] then
        self.uiClass["countryWarBattlefieldInfoUI"]:hideUI()
        self.uiClass["countryWarBattlefieldInfoUI"] = nil
    end
end

function CountryWarMgr:showCountryWarMatch(cityId)
    if  self:isDead() then
        self:errorCode(212)
        return
    end
    if self.uiClass["countryWarMatchUI"] == nil then
        local args = {
            target_city = cityId or self.myCity
        }
        MessageMgr:sendPost("get_city_battle_info", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                CountryWarMgr.countrywar = data.countrywar
                self.citys[tostring(cityId or self.myCity)].players = data.players
                self.uiClass["countryWarMatchUI"] = ClassCountryWarMatchUI.new(cityId or self.myCity)
                self.uiClass["countryWarMatchUI"]:showUI()
            end
        end)
    end
end

function CountryWarMgr:setCountryWarActionMsg(msg)
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:setActionMsg(msg)
        self.uiClass["countryWarMatchUI"]:updatePanel()
    end
end

function CountryWarMgr:updateCountryWarMatchPlayers()
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:updateCountryWarMatchPlayers()
        self.uiClass["countryWarMatchUI"]:updatePanel()
    end
end

function CountryWarMgr:updateCountryWarMatchPrompt(msg)
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:updatePrompt(msg)
        self.uiClass["countryWarMatchUI"]:updatePanel()
    end
end

function CountryWarMgr:updateCountryWarMatch(cityId)
    if self.uiClass["countryWarMatchUI"] then
        local args = {
            target_city = cityId or CountryWarMgr.myCity
        }
        MessageMgr:sendPost("get_city_battle_info", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                CountryWarMgr.countrywar = data.countrywar
                self.citys[tostring(cityId or self.myCity)].players = data.players
                if self.uiClass["countryWarMatchUI"] then
                    self.uiClass["countryWarMatchUI"]:updateCountryWarMatchPlayers()
                    self.uiClass["countryWarMatchUI"]:updatePanel()
                end
            end
        end)
    end
end

function CountryWarMgr:setMatchLittleChatMsg(msg)
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:setLittleChatMsg(msg)
    end
end

function CountryWarMgr:setMatchLittleChatMsg1(msg)
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:setLittleChatMsg1(msg)
    end
end

-- function CountryWarMgr:updateCountryWarMatch()
--     if self.uiClass["countryWarMatchUI"] then
--         self.uiClass["countryWarMatchUI"]:updatePanel()
--     end
-- end

function CountryWarMgr:hideCountryWarMatch()
    if self.uiClass["countryWarMatchUI"] then
        self.uiClass["countryWarMatchUI"]:hideUI()
        self.uiClass["countryWarMatchUI"] = nil
        self.hideMatch = false
        CountryWarMgr:setWinPosition()
    end
end

function CountryWarMgr:hideAllCountryWarPanel()
    self:hideCountryWarCityInfo()
    self:hideCountryWarAward()
    self:hideCountryWarList()
    self:hideCountryWarOrder()
    self:hideCountryWarTask()
    self:hideCountryWarBattlefieldInfo()
    self:hideCountryWarVictory()
    self:hideCountryWarDefeat()
    self:hideCountryWarCityLog()
    -- CountryWarMgr:hideCountryWarMatch()
end

function CountryWarMgr:getMoveData()
    return self.move
end

-- 错误码
function CountryWarMgr:errorCode(code)
    if code == 224 then
        promptmgr:showMessageBox(GlobalApi:getLocalStr('COUNTRY_WAR_ERROR_CODE_'..code), MESSAGE_BOX_TYPE.MB_OK, function ()
            self:hideAllCountryWarPanel()
            self:hideCountryWarMatch()
            self:hideCountryWarMain()
            self:hideCountryWarMap()
        end)
    else
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_ERROR_CODE_'..code), COLOR_TYPE.RED)
    end
end

--布阵
function CountryWarMgr:embattle(callback)
    local args = {}
    MessageMgr:sendPost('get_team', 'countrywar', json.encode(args), function( res )
        local code = res.code
        if code == 0 then
            BattleMgr:showEmbattleForWorldwarUI(res.data,function(args)
                MessageMgr:sendPost('set_team', 'countrywar', json.encode(args), function( response )
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        -- BattleMgr:showEmbattleForWorldwarUI(pos)
                        if callback then
                            callback()
                        end
                    end
                end)
            end,'countrywar')
        else
            self:errorCode(code)
        end
    end)
end

-- 跑路
function CountryWarMgr:runMap(endId,callback)
    if  self:isDead() then
        self:errorCode(212)
        return
    end
    local args = {
        target_city = endId
    }
    MessageMgr:sendPost("move_to_city", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            -- self.countrywar.city = endId
            self.move = {}
            self.move.path = data.path
            self.move.startTime = data.startTime or (GlobalData:getServerTime() + self.diffTime)
            self.move.reachTime = data.time
            self.runTime = data.startTime or (GlobalData:getServerTime() + self.diffTime)
            promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_34'),COLOR_TYPE.GREEN)
            if callback then
                callback()
            end
        elseif code == 227 or code == 233 then
            self:errorCode(code)
            self:updateSpinePos()
        else
            self:errorCode(code)
        end
    end)
end

-- 突进
function CountryWarMgr:specialMove(endId,callback)
    if  self:isDead() then
        self:errorCode(212)
        return
    end
    local args = {
        target_city = endId
    }
    MessageMgr:sendPost("special_move", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            -- self.countrywar.city = endId
            self.move = {}
            self.move.path = data.path
            self.move.startTime = data.startTime or (GlobalData:getServerTime() + self.diffTime)
            self.move.reachTime = data.time
            if callback then
                callback()
            end
        elseif code == 1 then
            self:errorCode(1006)
        else
            self:errorCode(code)
        end
    end)
end

-- 到达城池
function CountryWarMgr:reachCity(cityId,callback)
    local args = {
        target_city = cityId
    }
    MessageMgr:sendPost("reach_city", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            self.myCity = cityId
            if callback then
                callback()
            end
        elseif code == 202 then
            self:errorCode(code)
            self.move = {}
            self.move.path = data.path
            self.move.startTime = (GlobalData:getServerTime() + self.diffTime)
            self.move.reachTime = data.time
            local way = data.path
            self:startMoving(way[1],way[#way],way)
        else
            self:errorCode(code)
        end
    end)
end

--随机匹配
function CountryWarMgr:matchEnemy(root,cityId,country,callback,callback1)
    if  self:isDead() then
        self:errorCode(212)
        return
    end
    local args = {
        target = country
    }
    MessageMgr:sendPost("match_enemy", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local customObj = {
                info = data.info,
                city_id = cityId,
                enemy_uid = data.enemy.uid,
                enemy = data.enemy,
                rand1 = data.rand1,
                rand2 = data.rand2,
                node = root,
            }
            -- 初始化死亡人数
            BattleMgr:initLegionDie()
            BattleMgr:calculateReport(BATTLE_TYPE.COUNTRY_WAR, customObj, function (reportField,sig)
                local args1 = {
                    star = 0,
                    sig = sig,
                    enemy_uid = customObj.enemy_uid,
                    winner_pos = {},
                    -- winner_uid = nil,
                }
                local uid = UserData:getUserObj():getUid()
                -- print("----------------------->log")
                -- dump(reportField.totalReport)
                local legionArr = reportField.totalReport.isWin and reportField.armyArr[1] or reportField.armyArr[2]
                -- args1.winner_uid = reportField.totalReport.isWin and uid or customObj.enemy_uid
                args1.star = reportField.totalReport.isWin and reportField.totalReport.starNum or 0
                local isHeroAlive = false
                for i,v in ipairs(legionArr) do
                    local hp = 100*v.heroObj.hp/v.heroObj.maxMp
                    if hp > 0 then
                        isHeroAlive = true
                        break
                    end
                end
                for k, v in ipairs(legionArr) do
                    local aliveSoldierNum = 0
                    for k2, v2 in ipairs(v.soldierObjs) do
                        if not v2:isDead() then
                            aliveSoldierNum = aliveSoldierNum + 1
                        end
                    end
                    local hp = 100*v.heroObj.hp/v.heroObj.maxMp
                    if hp <= 0 then
                        if isHeroAlive then
                            if aliveSoldierNum > 0 then
                                aliveSoldierNum = 0
                            end
                        else
                            if aliveSoldierNum > 0 then
                                hp = 1
                                aliveSoldierNum = 0
                            end
                        end
                    end
                    args1.winner_pos[tostring(v.legionInfo.rolePos)] = {hp = hp, soldierNum = aliveSoldierNum}
                end
                MessageMgr:sendPost('fight', 'countrywar', json.encode(args1), function (response1)
                    local code1 = response1.code
                    local data1 = response1.data
                    if code1 == 0 then
                        self.countrywar.coolTime = data1.coolTime
                        if args1.star <= 0 then
                            self.deadCoolingTime = (GlobalData:getServerTime() + self.diffTime)
                            local camp = self.camp
                            CountryWarMgr.myCity = 1 + (camp - 1)*25
                            data1.enemy = data.enemy
                            data1.cityId = cityId
                            local index
                            local uid = UserData:getUserObj():getUid()
                            for i,v in ipairs(CountryWarMgr.citys[tostring(data1.cityId)].players[tostring(camp)]) do
                                if v.uid == uid then
                                    index = i
                                end
                            end
                            if index then
                                table.remove(CountryWarMgr.citys[tostring(data1.cityId)].players[tostring(camp)],index)
                            end

                            CountryWarMgr:showCountryWarDefeat(data1,function()
                                CountryWarMgr:hideAllCountryWarPanel()
                                CountryWarMgr:hideCountryWarMatch()
                                CountryWarMgr:setWinPosition()
                                CountryWarMgr:updateCountryWarMap()
                                -- CountryWarMgr:showCountryWarMatch()
                            end)
                        else
                            reportField.winner_pos = args1.winner_pos
                            self.countrywar.pos = args1.winner_pos
                            reportField.score = data1.score
                            CountryWarMgr:showCountryWarVictory(reportField,data.enemy,function()
                                if self.hideMatch then
                                    CountryWarMgr:hideCountryWarMatch()
                                end
                            end)
                            if callback then
                                callback(args1.star,reportField,data.enemy)
                            end
                        end
                    else
                        if callback1 then
                            callback1()
                        end
                        self:errorCode(code1)
                    end
                end)
            end)
        elseif code == 205 then
            if callback1 then
                callback1()
            end
            self:errorCode(code)
        else
            if callback1 then
                callback1()
            end
            self:errorCode(code)
        end
    end)
end

--撤军
function CountryWarMgr:goBack(callback)
    if self:isDead() then
        self:errorCode(212)
        return
    end
    -- local needNum = tonumber(CountryWarMgr:getBaseValue('backToCityConsume'))
    -- local needNumCash = tonumber(CountryWarMgr:getBaseValue('reliveConsumeCash'))
    -- local num = UserData:getUserObj():getGoods()
    -- local moneyType = 0
    -- local str = ''
    -- if needNum <= num then
    --     str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_20'),needNum)
    -- else
    --     moneyType = 1
    --     str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_42'),needNumCash)
    -- end
    local function send()
        local args = {
            -- money_type = moneyType
        }
        MessageMgr:sendPost("back_to_city", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                local camp = self.camp
                local oldCity = clone(self.myCity)
                self.myCity = 1 + (camp - 1)*25
                if callback then
                    callback()
                    self:updateSpecialMoveImg(oldCity)
                end
                local data1 = {}
                data1.deadBattleInfo = clone(data)
                self:setWinPosition(nil,nil,nil,function()
                    CountryWarMgr:showCountryWarDefeat(data1,function()
                        CountryWarMgr:hideAllCountryWarPanel()
                        CountryWarMgr:hideCountryWarMatch()
                    end)
                end)
            else
                self:errorCode(code)
            end
        end)
    end
    local contentWidget = ccui.Widget:create()
    contentWidget:setAnchorPoint(cc.p(0.5,0.5))
    contentWidget:setPosition(cc.p(75, 250))
    local richText = cc.Label:createWithTTF(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_81'), 'font/gamefont.ttf', 24)
    richText:setAnchorPoint(cc.p(0, 1))
    richText:setPosition(cc.p(0, 10))
    richText:setColor(COLOR_TYPE.WHITE)
    richText:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
    richText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))


    local richText2 = cc.Label:createWithTTF(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_82'), 'font/gamefont.ttf', 22)
    richText2:setAnchorPoint(cc.p(0, 1))
    richText2:setPosition(cc.p(5, -45))
    richText2:setColor(COLOR_TYPE.ORANGE)
    richText2:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
    richText2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

    contentWidget:addChild(richText)
    contentWidget:addChild(richText2)
    promptmgr:showMessageBox(contentWidget,MESSAGE_BOX_TYPE.MB_OK_CANCEL,send)
    contentWidget:setLocalZOrder(10000)
end

--响应集结令
function CountryWarMgr:responseCallOfDuty(cityId,callback)
    if  self:isDead() then
        self:errorCode(212)
        return
    end
    if self.myCity == cityId then
        self:errorCode(1003)
        return
    end
    print('==================xxx',cityId)
    local args = {
        target_city = cityId,
    }
    MessageMgr:sendPost("respond_call_of_duty", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            -- local costs = data.costs
            -- if costs then
            --     GlobalApi:parseAwardData(costs)
            -- end
            self.myCity = cityId
            if callback then
                CountryWarMgr:updateCountryWarMap()
                CountryWarMgr:hideCountryWarMatch()
                callback(function()
                    if CountryWarMgr.citys[tostring(self.myCity)].fight_state == 1 then
                         CountryWarMgr:showCountryWarMatch()
                    end
                end)
            end
        else
            self:errorCode(code)
        end
    end)
end

--发布集结令
function CountryWarMgr:broadcastCallOfDuty(cityId,callback)
    local position = UserData:getUserObj():getPosition()
    local conf = GameData:getConfData("position")
    print('===========================',position,tonumber(CountryWarMgr:getBaseValue('callNeedPosition')))
    if position > tonumber(CountryWarMgr:getBaseValue('callNeedPosition')) then
        self:errorCode(1002)
        return
    end
    -- local needNum = tonumber(CountryWarMgr:getBaseValue('callConsume'))
    local needNumCashTab = CountryWarMgr:getBaseValue('callConsumeCash')
    local needNumCash = tonumber(needNumCashTab[#needNumCashTab])
    if self.callCount < #needNumCashTab then
        needNumCash = tonumber(needNumCashTab[self.callCount + 1])
    end
    -- local num = UserData:getUserObj():getGoods()
    -- local moneyType = 0
    local str = ''
    local time = tonumber(CountryWarMgr:getBaseValue('callKeepTime'))
    -- if needNum <= num then
    --     str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_18'),needNum,time)
    -- else
    --     moneyType = 1
        str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_32'),self.callCount + 1,needNumCash,time)
    -- end
    local function send()
        local args = {
            target_city = cityId,
            money_type = moneyType
        }
        MessageMgr:sendPost("broadcast_call_of_duty", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.callCount = self.callCount + 1
                self.callOfDutyData = data.callList
                local costs = data.costs
                local awards = data.awards
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                if awards then
                    GlobalApi:parseAwardData(awards)
                    local conf = GameData:getConfData("countrywarcity")[cityId]
                    GlobalApi:showAwardsCommon(awards,nil,function()
                        if self.myCity ~= cityId then
                            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_43'),conf.name),MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                                CountryWarMgr:responseCallOfDuty(cityId,function(callback)
                                    CountryWarMgr:hideAllCountryWarPanel()
                                    CountryWarMgr:setWinPosition(nil,nil,nil,callback)
                                end)
                            end)
                        end
                    end,true)
                end
                if callback then
                    callback()
                end
                CountryWarMgr:updateMapNewImgs()
            else
                self:errorCode(code)
            end
        end)
    end
    -- if moneyType == 1 then
        UserData:getUserObj():cost('cash',needNumCash,send,true,str)
    -- else
    --     promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL,send)
    -- end
end

-- 领取国家任务奖励
function CountryWarMgr:getCountryTaskAward(taskType,taskId,callback)
    local args = {
        taskType = taskType,
        taskId = taskId,
    }
    MessageMgr:sendPost("get_country_task_award", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            if callback then
                callback()
            end
        else
            self:errorCode(code)
        end
    end)
end

-- 领取个人任务奖励
function CountryWarMgr:getPersonalTaskAward(taskId,callback)
    local args = {
        taskId = taskId
    }
    MessageMgr:sendPost("get_personal_task_award", "countrywar", json.encode(args), function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            if callback then
                callback()
            end
        else
            self:errorCode(code)
        end
    end)
end

-- 清除战斗冷却
function CountryWarMgr:cleanUpCooltime(callback)
    -- local needNum = tonumber(CountryWarMgr:getBaseValue('reliveConsume'))
    local needNumCash = tonumber(CountryWarMgr:getBaseValue('battleDiffTimeCash'))
    local num = UserData:getUserObj():getGoods()
    local moneyType = 0
    local str = ''
    -- if needNum <= num then
    --     str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_19'),needNum)
    -- else
    --     moneyType = 1
        str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_73'),needNumCash)
    -- end
    local function send()
        local args = {
            money_type = moneyType
        }
        MessageMgr:sendPost("clear_fight_cool_time", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                self.countrywar.coolTime = (GlobalData:getServerTime() + self.diffTime)
                if callback then
                    callback()
                end
            else
                self:errorCode(code)
            end
        end)
    end
    -- if moneyType == 1 then
        UserData:getUserObj():cost('cash',needNumCash,send,true,str)
    -- else
    --     promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL,send)
    -- end
end

-- 快速复活
function CountryWarMgr:fastRelive()
    local needNum = tonumber(CountryWarMgr:getBaseValue('reliveConsume'))
    local needNumCash = tonumber(CountryWarMgr:getBaseValue('reliveConsumeCash'))
    local num = UserData:getUserObj():getGoods()
    local moneyType = 0
    local str = ''
    if needNum <= num then
        str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_19'),needNum)
    else
        moneyType = 1
        str = string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_41'),needNumCash)
    end
    local function send()
        local args = {
            money_type = moneyType
        }
        MessageMgr:sendPost("fast_relive", "countrywar", json.encode(args), function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                self.deadCoolingTime = nil
                self:updateCountryWarMap()
            else
                self:errorCode(code)
            end
        end)
    end
    if moneyType == 1 then
        UserData:getUserObj():cost('cash',needNumCash,send,true,str)
    else
        promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL,send)
    end
end

function CountryWarMgr:updateCityNameBg(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateCityNameBg(cityId)
    end
end

function CountryWarMgr:refreshCityFightState(cityId)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateCityFightState(cityId)
    end
end

function CountryWarMgr:updateMapNewImgs()
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:updateNewImgs()
    end
end

function CountryWarMgr:getCallOfDutySign()
    for k,v in pairs(self.callOfDutyData) do
        local beginTime = v.time
        local endTime = v.time + tonumber(CountryWarMgr:getBaseValue('callKeepTime'))
        local nowTime = (GlobalData:getServerTime() + self.diffTime)
        if nowTime > beginTime and nowTime < endTime then
            return true
        end
    end
end

function CountryWarMgr:GetMsg()
    print('==============================GetMsg')
    CustomEventMgr:addEventListener("countrywar_city_owner_change",self,CountryWarMgr.cityOnwerChange)
    CustomEventMgr:addEventListener("countrywar_fight",self,CountryWarMgr.fight)
    CustomEventMgr:addEventListener("countrywar_call_of_duty",self,CountryWarMgr.callOfDuty)
    CustomEventMgr:addEventListener("countrywar_city_fight_state_change",self,CountryWarMgr.cityFightStateChange)
    CustomEventMgr:addEventListener("countrywar_city_player_change",self,CountryWarMgr.cityPlayerChange)
    CustomEventMgr:addEventListener("countrywar_continuous_kill",self,CountryWarMgr.continuousKill)
    CustomEventMgr:addEventListener("countrywar_kill_player",self,CountryWarMgr.killPlayer)
    CustomEventMgr:addEventListener("countrywar_on_player_fight",self,CountryWarMgr.onPlayerFight)
    CustomEventMgr:addEventListener("countrywar_sync_move",self,CountryWarMgr.syncMove)
end

function CountryWarMgr.syncMove(msg)
    print('=======================syncMove')
    printall(msg)
    local uid = UserData:getUserObj():getUid()
    if uid == msg.uid then
        return
    end
    CountryWarMgr:setSyncMove(msg)
end

function CountryWarMgr.continuousKill(msg)
    print('=======================continuousKill')
    printall(msg)
    -- promptmgr:showSystenHint(msg.un..'获取了'..msg.killCount..'连杀', COLOR_TYPE.RED)
    -- local localtextConf = GameData:getConfData("countrywarlocaltext")[5]
    -- local msg1 = {}
    -- msg1.user = clone(msg)
    -- msg1.content = string.format(localtextConf.text,msg.un,msg.killCount)
    -- msg1.mod = 'countrywar'
    -- CountryWarMgr:setMapLittleChatMsg(msg1)
    -- CountryWarMgr:setMatchLittleChatMsg(msg1)
    CountryWarMgr:setMapChatMsg(msg)
end

function CountryWarMgr.killPlayer(msg)
    print('=======================killPlayer')
    printall(msg)
    local conf = GameData:getConfData("countrywarcity")[msg.city]
    local positionConf = GameData:getConfData("position")
    -- promptmgr:showSystenHint(msg.un..'在'..conf.name..'击杀了'..
    --     GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..msg.deadCountry)..'的'..msg.deadPosition..msg.deadName, COLOR_TYPE.RED)
    local localtextConf = GameData:getConfData("countrywarlocaltext")[4]
    local msg1 = {}
    msg1.user = clone(msg)
    msg1.content = string.format(localtextConf.text,msg.un,conf.name,GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..msg.deadCountry),
        positionConf[msg.deadPosition].title,msg.deadName)
    msg1.mod = 'countrywar'
    CountryWarMgr:setMapLittleChatMsg(msg1)
    CountryWarMgr:setMatchLittleChatMsg(msg1)
end

function CountryWarMgr.cityPlayerChange(msg)
    print('=======================cityPlayerChange')
    printall(msg)
    if CountryWarMgr.citys[tostring(msg.city)].players then
        local index
        if msg.enter == 1 then
            for i,v in ipairs(CountryWarMgr.citys[tostring(msg.city)].players[tostring(msg.country)]) do
                if v.uid == msg.uid then
                    index = i
                end
            end
            if not index then
                table.insert(CountryWarMgr.citys[tostring(msg.city)].players[tostring(msg.country)],
                    {uid = msg.uid,hid = msg.hid,un = msg.un,fight_force = msg.fight_force})
                -- printall(CountryWarMgr.citys[tostring(msg.city)].players[tostring(msg.country)])
            end
        else
            for i,v in ipairs(CountryWarMgr.citys[tostring(msg.city)].players[tostring(msg.country)]) do
                if v.uid == msg.uid then
                    index = i
                end
            end
            if index then
                table.remove(CountryWarMgr.citys[tostring(msg.city)].players[tostring(msg.country)],index)
            end
        end
        CountryWarMgr:updateCountryWarMatchPlayers()
    else
        if msg.city == CountryWarMgr.myCity then
            local moveFlag = CountryWarMgr:getMoveFlag()
            if not moveFlag then
                CountryWarMgr:updateCountryWarMatch(msg.city)
            end
        end
    end
    CountryWarMgr:updateCountryWarMapCityBtnCell(msg.city)

    if msg.enter == 1 and msg.city == CountryWarMgr.myCity and msg.country == CountryWarMgr.camp then
        local msg1 = {}
        msg1.user = clone(msg)
        if msg.call then
            msg1.content = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_77')
        else
            msg1.content = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_76')
        end
        msg1.mod = 'countrywarcity'
        CountryWarMgr:setMatchLittleChatMsg1(msg1)
    end
end

function CountryWarMgr.cityOnwerChange(msg)
    print('=======================cityOnwerChange')
    printall(msg)
    -- promptmgr:showSystenHint(msg.city..'被攻占了', COLOR_TYPE.RED)
    local conf = GameData:getConfData("countrywarcity")[msg.city]
    local localtextConf = GameData:getConfData("countrywarlocaltext")[3]
    local msg1 = {}
    msg1.user = clone(msg)
    msg1.content = string.format(localtextConf.text,GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..msg.cityInfo.hold_camp),conf.name)
    msg1.mod = 'countrywar'
    CountryWarMgr:setMapLittleChatMsg(msg1)
    CountryWarMgr:setMatchLittleChatMsg(msg1)
    CountryWarMgr.citys[tostring(msg.city)].hold_camp = msg.cityInfo.hold_camp
    -- CountryWarMgr.citys[tostring(msg.city)].fight_state = msg.cityInfo.fight_state

    CountryWarMgr:updateCountryWarMapWithoutSpine()
    CountryWarMgr:updateCityNameBg()
    if tonumber(msg.city) == tonumber(CountryWarMgr.myCity) then
        print('==============xxxx1',CountryWarMgr.victoryHide , CountryWarMgr.defeatHide)
        if CountryWarMgr.victoryHide and CountryWarMgr.defeatHide then
            CountryWarMgr:hideCountryWarMatch()
        else
            CountryWarMgr:updateCountryWarMatch()
            CountryWarMgr.hideMatch = true
        end
    end
end

function CountryWarMgr.onPlayerFight(msg)
    print('=======================onPlayerFight')
    printall(msg)
    local camp = msg.winner == msg.uid1 and msg.camp2 or msg.camp1
    local uid = msg.winner == msg.uid1 and msg.uid2 or msg.uid1
    local index
    for i,v in ipairs(CountryWarMgr.citys[tostring(msg.city)].players[tostring(camp)]) do
        if v.uid == uid then
            index = i
        end
    end
    if index then
        table.remove(CountryWarMgr.citys[tostring(msg.city)].players[tostring(camp)],index)
    end
    CountryWarMgr:setCountryWarActionMsg(msg)
end

function CountryWarMgr.fight(msg)
    print('=======================fight')
    printall(msg)
    local uid = UserData:getUserObj():getUid()
    if uid ~= msg.winner_uid then
        local camp = CountryWarMgr.camp
        CountryWarMgr.myCity = 1 + (camp - 1)*25
        CountryWarMgr.deadCoolingTime = (GlobalData:getServerTime() + CountryWarMgr.diffTime)
        CountryWarMgr:updateSpinePos()
        CountryWarMgr:showCountryWarDefeat(msg,function()
            CountryWarMgr:hideAllCountryWarPanel()
            CountryWarMgr:hideCountryWarMatch()
            CountryWarMgr:setWinPosition()
            CountryWarMgr:updateCountryWarMap()
            CountryWarMgr:updateCountryWarMatch()
        end)
    else
        CountryWarMgr:updateCountryWarMapWithoutSpine(CountryWarMgr.myCity)
        CountryWarMgr:updateCountryWarMatch()
        CountryWarMgr:updateCountryWarMatchPrompt(msg)
    end
end

function CountryWarMgr.callOfDuty(msg)
    print('=======================callOfDuty')
    printall(msg)
    if CountryWarMgr.callOfDutyData[tostring(msg.city)] then
        CountryWarMgr.callOfDutyData[tostring(msg.city)].time = msg.time
        CountryWarMgr.callOfDutyData[tostring(msg.city)].caller = msg.uid
    else
        CountryWarMgr.callOfDutyData[tostring(msg.city)] = {time = msg.time , caller = msg.uid}
    end
    local conf = GameData:getConfData("countrywarcity")[msg.city]
    -- if msg.city ~= CountryWarMgr.myCity then
        local localtextConf = GameData:getConfData("countrywarlocaltext")[2]
        local msg1 = {}
        msg1.user = clone(msg)
        msg1.content = string.format(localtextConf.text,conf.name)
        msg1.mod = 'countrywar'
        msg1.user.serverId = nil
        CountryWarMgr:setMapLittleChatMsg(msg1)
        CountryWarMgr:setMatchLittleChatMsg(msg1)
        CountryWarMgr:udpateCallOfDuty(msg.city)
    -- end
    local uid = UserData:getUserObj():getUid()
    if msg.city ~= CountryWarMgr.myCity and msg.caller == uid then
        -- CountryWarMgr.callOfDutyCallback = function()
        --     promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_43'),conf.name),MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
        --         CountryWarMgr:responseCallOfDuty(msg.city,function()
        --             CountryWarMgr:hideAllCountryWarPanel()
        --             CountryWarMgr:setWinPosition()
        --         end)
        --     end)
        -- end
    end
end

function CountryWarMgr.cityFightStateChange(msg)
    print('=======================cityFightStateChange')
    printall(msg)
    CountryWarMgr.citys[tostring(msg.city)].hold_camp = msg.cityInfo.hold_camp
    CountryWarMgr.citys[tostring(msg.city)].fight_state = msg.cityInfo.fight_state

    CountryWarMgr:refreshCityFightState(msg.city)
    CountryWarMgr:updateCityNameBg()
    if tonumber(msg.city) == tonumber(CountryWarMgr.myCity) and CountryWarMgr.citys[tostring(msg.city)].fight_state == 1 then
         CountryWarMgr:showCountryWarMatch()
    end
end

function CountryWarMgr:setMapChatShoutMsg(msg)
    if self.uiClass["countryWarMapUI"] then
        self.uiClass["countryWarMapUI"]:setMapChatShoutMsg(msg)
    end
end