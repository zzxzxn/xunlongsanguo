local WorldWarGoWarUI = class("WorldWarGoWarUI", BaseUI)

function WorldWarGoWarUI:ctor(data)
	self.uiIndex = GAME_UI.UI_WORLDWARGOWAR
    self.data = data
end

function WorldWarGoWarUI:updateRightPanel()
    -- local nameTx = self.pl2:getChildByName('name_tx')
    local serverTx = self.pl2:getChildByName('server_tx')
    local scoreTx = self.pl2:getChildByName('score_tx')
    -- nameTx:setString(GlobalApi:getLocalStr('NAME')..self.data.name)
    serverTx:setString(self.data.sid..GlobalApi:getLocalStr('FU')..'  '..self.data.name)
    scoreTx:setString(GlobalApi:getLocalStr('SCORE')..self.data.score)

    if self.eSpineAni then
        self.eSpineAni:removeFromParent()
    end
    local promote = nil
    local weapon_illusion = nil
    local wing_illusion = nil
    if self.data.promote and self.data.promote[1] then
        promote = self.data.promote[1]
    end
    local heroConf = GameData:getConfData("hero")
    if heroConf[tonumber(self.data.max_hid)].camp == 5 then
        if self.data.weapon_illusion and self.data.weapon_illusion > 0 then
            weapon_illusion = self.data.weapon_illusion
        end
        if self.data.wing_illusion and self.data.wing_illusion > 0 then
            wing_illusion = self.data.wing_illusion
        end
    end
    local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
    self.eSpineAni = GlobalApi:createLittleLossyAniByRoleId(tonumber(self.data.max_hid), changeEquipObj)
    self.eSpineAni:setPosition(cc.p(100,150))
    self.pl2:addChild(self.eSpineAni)
    -- self.spineAni:setAnimation(0, 'idle', true)
    self.eSpineAni:getAnimation():play('idle', -1, 1)
    self.eSpineAni:setScaleX(-1)

    if not self.eForceLabel then
        self.eForceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        self.eForceLabel:setAnchorPoint(cc.p(0, 0.5))
        self.eForceLabel:setPosition(cc.p(80, 90))
        self.eForceLabel:setScale(0.7)
        self.pl2:addChild(self.eForceLabel)
    end
    self.eForceLabel:setString(self.data.fight_force)
end

function WorldWarGoWarUI:updateLeftPanel()
    local serverTx = self.pl1:getChildByName('server_tx')
    local scoreTx = self.pl1:getChildByName('score_tx')
    local role = clone(RoleData:getRoleMap())
    table.sort( role, function(a,b)
        return a:getFightForce() > b:getFightForce()
    end )
    if not self.mSpineAni then
        self.mSpineAni = GlobalApi:createLittleLossyAniByRoleId(tonumber(role[1]:getId()), role[1]:getChangeEquipState())
        self.mSpineAni:setPosition(cc.p(100,150))
        self.pl1:addChild(self.mSpineAni)
        -- self.spineAni:setAnimation(0, 'idle', true)
        self.mSpineAni:getAnimation():play('idle', -1, 1)
    end
    if not self.mForceLabel then
        self.mForceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        self.mForceLabel:setAnchorPoint(cc.p(0, 0.5))
        self.mForceLabel:setPosition(cc.p(80, 90))
        self.mForceLabel:setScale(0.7)
        self.pl1:addChild(self.mForceLabel)
    end
    serverTx:setString(WorldWarMgr.serverId..GlobalApi:getLocalStr('FU'))
    scoreTx:setString(GlobalApi:getLocalStr('SCORE')..WorldWarMgr.score)
    self.mForceLabel:setString(RoleData:getFightForce())
end

function WorldWarGoWarUI:updatePanel()
    local times
    if WorldWarMgr.battleTimes and WorldWarMgr.maxBattleTimes > WorldWarMgr.battleTimes then
        times = WorldWarMgr.maxBattleTimes - WorldWarMgr.battleTimes
    else
        times = 0
    end
    self.fightingTx:setString(string.format(GlobalApi:getLocalStr('E_STR_PVP_WAR_BATTLE_TIMES'),times))

    if WorldWarMgr.matchTimes and WorldWarMgr.maxMatchTimes > WorldWarMgr.matchTimes then
        times = WorldWarMgr.maxMatchTimes - WorldWarMgr.matchTimes
    else
        times = 0
    end
    self.refreshTx:setString(string.format(GlobalApi:getLocalStr('E_STR_PVP_WAR_MATCH_TIMES'),times))
    self.newImg:setVisible(UserData:getUserObj():getSignByType('worldwar_battle'))

    self:updateLeftPanel()
    self:updateRightPanel()
end

function WorldWarGoWarUI:replaceEnemy(cash)
    -- self.challengeBtn:setNormalButtonGray(false)
    -- self.challengeBtn:setTouchEnable(true)
    WorldWarMgr:matchEnemy(function(data)
        self.data = data.enemy
        self:updatePanel()
    end,cash)
end

function WorldWarGoWarUI:rankFight(cash)
    -- WorldWarMgr:rankFight(function(data)
    --     WorldWarMgr.fighted = 1
    --     if tonumber(WorldWarMgr.matchTimes) < WorldWarMgr.maxMatchTimes then
    --         self:replaceEnemy()
    --     end
    --     self:updatePanel()
    -- end,self.data.uid,cash)
    WorldWarMgr:rankFight(nil,self.data.uid,cash)
end

function WorldWarGoWarUI:init()
	local goWarBgImg = self.root:getChildByName("go_war_bg_img")
    local goWarImg = goWarBgImg:getChildByName("go_war_img")
    self:adaptUI(goWarBgImg,goWarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local checkBtn = goWarImg:getChildByName("check_btn")
    local infoTx = checkBtn:getChildByName('info_tx')
    checkBtn:setVisible(false)
    infoTx:setString(GlobalApi:getLocalStr("LOOK_UP_EM"))
    local changeBtn = goWarImg:getChildByName("change_btn")
    infoTx = changeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr("CHANGE_ONE"))
    local fightingBtn = goWarImg:getChildByName("fighting_btn")
    self.newImg = fightingBtn:getChildByName('new_img')
    infoTx = fightingBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr("CHALLENGE_1"))
    self.fightingTx = goWarImg:getChildByName("fighting_times_tx")
    self.refreshTx = goWarImg:getChildByName("refresh_times_tx")
    self.pl1 = goWarImg:getChildByName('pl1')
    self.pl1:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_106'))
    self.pl2 = goWarImg:getChildByName('pl2')
    self.pl2:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_107'))
	local closeBtn = goWarBgImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideGoWar()
        end
    end)
    changeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(WorldWarMgr.matchTimes) >= WorldWarMgr.maxMatchTimes then
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("E_STR_PVP_WAR_MATCH_DESC"),WorldWarMgr.maxBuyMatchCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    local cash = WorldWarMgr.maxBuyMatchCash
                    local myCash = UserData:getUserObj():getCash()
                    if myCash < cash then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
                    else
                        self:replaceEnemy(cash)
                    end
                end)
            else
                self:replaceEnemy()
            end
        end
    end)
    fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if WorldWarMgr.fighted ~= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_CANNOT_FIGHT"), COLOR_TYPE.RED)
            else
                print(WorldWarMgr.battleTimes,WorldWarMgr.maxBattleTimes)
                if tonumber(WorldWarMgr.battleTimes) >= WorldWarMgr.maxBattleTimes then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('E_STR_PVP_WAR_BATTLE_DESC'),WorldWarMgr.maxBuyBattle), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()
                        local cash = WorldWarMgr.maxBuyBattle
                        local myCash = UserData:getUserObj():getCash()
                        if myCash < cash then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
                        else
                            self:rankFight(cash)
                        end
                    end)
                else
                    self:rankFight()
                end
            end
        end
    end)

    closeBtn:setPosition(cc.p(winSize.width,winSize.height))

    self:updatePanel()
end

return WorldWarGoWarUI