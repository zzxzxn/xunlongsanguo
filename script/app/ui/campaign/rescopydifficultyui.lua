local RescopyDifficultyUI = class("RescopyDifficultyUI", BaseUI)

function RescopyDifficultyUI:ctor(currId, difficulty)
	self.uiIndex = GAME_UI.UI_RESCOPY_DIFFICULTY
    self.currId = currId
    self.rescopyListConf = GameData:getConfData("rescplist")[currId]
    self.rescopyInfoConf = GameData:getConfData("rescpinfo")[self.rescopyListConf.id]
    self.difficulty = difficulty
end

function RescopyDifficultyUI:init()
    local difficulty_bg_img = self.root:getChildByName("difficulty_bg_img")
    local difficulty_alpha_img = difficulty_bg_img:getChildByName("difficulty_alpha_img")
    self:adaptUI(difficulty_bg_img, difficulty_alpha_img)

    difficulty_bg_img:addClickEventListener(function ()
        CampaignMgr:hideRescopyDifficulty()
    end)

    local middle_img = difficulty_alpha_img:getChildByName("middle_img")
    local title_tx = middle_img:getChildByName("title_tx")
    title_tx:setString(self.rescopyListConf.name)
    local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local rescopyCount = vipConf[tostring(vip)].rescopyCount
    for i = 1, 3 do
        local difficultyImg = middle_img:getChildByName("difficulty_" .. i)
        difficultyImg:addClickEventListener(function ()
            local info = UserData:getUserObj():getRescopyinfo()
            if self.rescopyListConf.limit - info[self.rescopyListConf.type].count + info[self.rescopyListConf.type].buy > 0 then
                self:startFight(i)
            else
                if info[self.rescopyListConf.type].buy < rescopyCount then
                    CampaignMgr:updateRescopyAddBtn()
                    return
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                    return
                end
            end
        end)
        local infoLabel = middle_img:getChildByName("info_tx_" .. i)
        infoLabel:setString(self.rescopyInfoConf[i].tips)
        local sweepBtn = middle_img:getChildByName("sweep_btn_" .. i)
        local sweepLabel = sweepBtn:getChildByName("label")
        sweepLabel:setString(GlobalApi:getLocalStr("MAX_SWEEP"))
        if i > self.difficulty then
            ShaderMgr:setGrayForWidget(difficultyImg)
            difficultyImg:setTouchEnabled(false)
            infoLabel:setTextColor(COLOR_TYPE.RED)
            sweepBtn:setVisible(false)
        else
            infoLabel:setVisible(false)
            if UserData:getUserObj():getRescopyinfo()[self.rescopyListConf.type].first == i then
                sweepBtn:setVisible(false)
            else
                sweepBtn:setVisible(true)
                sweepBtn:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        local info = UserData:getUserObj():getRescopyinfo()
                        if self.rescopyListConf.limit - info[self.rescopyListConf.type].count + info[self.rescopyListConf.type].buy > 0 then
                            promptmgr:showMessageBox(GlobalApi:getLocalStr("WHETHER_CONTINUE_SWEEP"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                                local args = {
                                    id = i,
                                    auto = 1
                                }
                                MessageMgr:sendPost("fight_" .. self.rescopyListConf.type, "rescopy", json.encode(args), function (jsonObj)
                                    local code = jsonObj.code
                                    if code == 0 then
                                        local info = UserData:getUserObj():getRescopyinfo()
                                        info[self.rescopyListConf.type].count = info[self.rescopyListConf.type].count + 1
                                        GlobalApi:parseAwardData(jsonObj.data.awards)
                                        if jsonObj.data.costs then
                                            GlobalApi:parseAwardData(jsonObj.data.costs)
                                        end
                                        CampaignMgr:updateExtraInfo()
                                        if jsonObj.data.awards then
                                            GlobalApi:showAwardsCommon(jsonObj.data.awards,true,nil,true)
                                        end
                                    end
                                end)
                            end, GlobalApi:getLocalStr("STR_SWEEP"), GlobalApi:getLocalStr("STR_CANCEL"), nil, "rescopy_" .. self.rescopyListConf.type .. "_" .. i)
                        else
                            if info[self.rescopyListConf.type].buy < rescopyCount then
                                CampaignMgr:updateRescopyAddBtn()
                                return
                            else
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                                return
                            end
                        end
                    end
                end)
            end
        end

    end
end

function RescopyDifficultyUI:startFight(difficulty)
    local info = UserData:getUserObj():getRescopyinfo()
    local index = self.rescopyListConf.id
    local id = self.currId
    if index == 3 then
        local customObj = {
            conf = self.rescopyInfoConf[difficulty],
            id = difficulty,
            highestDmg = info.gold.damage,
            desc = self.rescopyListConf.desc2
        }
        BattleMgr:playBattle(BATTLE_TYPE.GOLD, customObj, function ()
            MainSceneMgr:showMainCity(function ()
                CampaignMgr:showCampaignMain(1,id)
            end, nil, GAME_UI.UI_CAMPAIGN)
        end)
    elseif index == 2 then
        local obj = {
            type = self.rescopyListConf.type,
            id = difficulty
        }
        MessageMgr:sendPost("get_enemy", "rescopy", json.encode(obj), function (jsonObj)
            if jsonObj.code == 0 then
                local customObj = {
                    info = jsonObj.data.enemy,
                    id = difficulty,
                    highestKill = info.xp.kill,
                    conf = self.rescopyInfoConf[difficulty],
                    roundConf = GameData:getConfData("rescpposcount")[difficulty],
                    desc = self.rescopyListConf.desc2
                }
                BattleMgr:playBattle(BATTLE_TYPE.EXP, customObj, function ()
                    MainSceneMgr:showMainCity(function ()
                        CampaignMgr:showCampaignMain(1,id)
                    end, nil, GAME_UI.UI_CAMPAIGN)
                end)
            end
        end)
    elseif index == 1 then
        local obj = {
            type = self.rescopyListConf.type,
            id = difficulty
        }
        MessageMgr:sendPost("get_enemy", "rescopy", json.encode(obj), function (jsonObj)
            if jsonObj.code == 0 then
                local customObj = {
                    info = jsonObj.data.enemy,
                    id = difficulty,
                    highestTime = info.reborn.time,
                    conf = self.rescopyInfoConf[difficulty],
                    desc = self.rescopyListConf.desc2
                }
                BattleMgr:playBattle(BATTLE_TYPE.REBORN, customObj, function ()
                    MainSceneMgr:showMainCity(function ()
                        CampaignMgr:showCampaignMain(1,id)
                    end, nil, GAME_UI.UI_CAMPAIGN)
                end)
            end
        end)
    elseif index == 4 then
        local obj = {
            type = self.rescopyListConf.type,
            id = difficulty
        }
        MessageMgr:sendPost("get_enemy", "rescopy", json.encode(obj), function (jsonObj)
            if jsonObj.code == 0 then
                local customObj = {
                    info = jsonObj.data.enemy,
                    boss = jsonObj.data.boss,
                    id = difficulty,
                    highestRound = info.destiny.round,
                    conf = self.rescopyInfoConf[difficulty],
                    roundConf = GameData:getConfData("rescpposcount")[difficulty],
                    desc = self.rescopyListConf.desc2
                }
                BattleMgr:playBattle(BATTLE_TYPE.DESTINY, customObj, function ()
                    MainSceneMgr:showMainCity(function ()
                        CampaignMgr:showCampaignMain(1,id)
                    end, nil, GAME_UI.UI_CAMPAIGN)
                end)
            end
        end)
    end
end

return RescopyDifficultyUI

