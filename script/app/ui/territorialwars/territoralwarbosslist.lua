local TerritoralwarBossListUI = class("TerritoralwarBossListUI", BaseUI)


function TerritoralwarBossListUI:ctor(myLegionBossInfo,enemyBossInfo1,enemyBossInfo2)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_BOSS_LIST
    self.BossInfo = {}
    self.BossInfo[1] = enemyBossInfo1
    self.BossInfo[2] = myLegionBossInfo
    self.BossInfo[3] = enemyBossInfo2

    self.lid = UserData:getUserObj():getLid()
end

function TerritoralwarBossListUI:init()

    local alphaBg = self.root:getChildByName("alpha_img")
    local bg = alphaBg:getChildByName("bg_img")
    self:adaptUI(alphaBg, bg)

    local dfbaseCfg = GameData:getConfData("dfbasepara")
    self.attckTime = dfbaseCfg["bossActivityTime"].value[1] .. "-" .. dfbaseCfg["bossActivityTime"].value[2]

    self.bossBg = {}
    local innerBg = bg:getChildByName("inner_bg")
    for i=1,3 do
        local bossBg = innerBg:getChildByName("boss_bg_" .. i)
        self.bossBg[i] = bossBg
        self:bossInfo(i)
    end

    --按钮事件
    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:closeBossListUI()
        end
    end)

end

function  TerritoralwarBossListUI:bossInfo(i)
    
    local titleNameTx = self.bossBg[i]:getChildByName("name_tx")
    local timeInfo = self.bossBg[i]:getChildByName("time_info")
    local rankInfo = self.bossBg[i]:getChildByName("rank_info")
    local belongInfo = self.bossBg[i]:getChildByName("belong_info")
    local belongBtn = self.bossBg[i]:getChildByName("belong_btn")
    local infoBg = self.bossBg[i]:getChildByName("info_bg")
    local legionNameTx = infoBg:getChildByName("legion_name")
    local legionTx = infoBg:getChildByName("legion_tx")
    self.modeNode = infoBg:getChildByName("mode_node")
    local noneBg = infoBg:getChildByName("none_bg")
    local zhandouBg = infoBg:getChildByName("zhan_bg_img")
    local fightforceTx = zhandouBg:getChildByName("fightforce_tx")
    local hurtRankBtn = infoBg:getChildByName("hurtrank_btn")


    --军团名字
    local isSelfLegion = (self.lid == self.BossInfo[i].lid) and true or false
    local leginName = self.BossInfo[i].legionName or ""
    local nameColor = COLOR_TYPE.RED
    if isSelfLegion then
        leginName = GlobalApi:getLocalStr("TERRITORIAL_WAL_INF11")
        nameColor = COLOR_TYPE.GREEN
    end
    legionNameTx:setString(leginName)
    legionNameTx:setColor(nameColor)
    legionTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_INF10"))


    --挑战时间
    local timeTx = timeInfo:getChildByName("time_tx")
    timeTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT33"))
    local time = timeInfo:getChildByName("time_num")
    time:setString(self.attckTime)
    time:setColor(COLOR_TYPE.GREEN)

    --是否存在军团    
    local exitLegion = next(self.BossInfo[i]) and true or false
    legionTx:setVisible(exitLegion)
    legionNameTx:setVisible(exitLegion)

    local exitBoss = (exitLegion and self.BossInfo[i].bossLevel and self.BossInfo[i].bossLevel ~= 0) and true or false
    noneBg:setVisible(not exitBoss)
    timeInfo:setVisible(not exitBoss)
    rankInfo:setVisible(exitBoss)
    belongInfo:setVisible(exitBoss)
    belongBtn:setVisible(exitBoss)
    
    --显示BOSS名字，战斗力，模型
    local bossName,bossUrl,fighForce = self:getBossInfo(self.BossInfo[i].bossLevel,self.BossInfo[i].bossIndex)
    if exitBoss and bossName and bossUrl and fighForce then
        titleNameTx:setString("BOSS·" .. bossName)
        self:showSpine(bossUrl)
        fightforceTx:setString("")
        local forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
        forceLabel:setPosition(cc.p(130, 22))
        forceLabel:setScale(0.7)
        zhandouBg:addChild(forceLabel)
        forceLabel:setString(fighForce)

    else
        local str = GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT32')
        titleNameTx:setString("BOSS" .. str) 
        fightforceTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT29"))
    end

    --底部信息显示
    local ownerLid = self.BossInfo[i].ownerLid or 0
    local ownLegionLv = self.BossInfo[i].ownerLegionLevel or 0 
    ownerLid = tonumber(ownerLid)
    local haveOwner = (ownerLid ~= 0 or ownLegionLv ~= 0) and true or false
    if exitBoss then
        rankInfo:setVisible(not haveOwner)
        belongInfo:setVisible(haveOwner)

        --显示伤害第一信息
        if not haveOwner then
            local tx = rankInfo:getChildByName("tx")
            tx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT34"))
            local tx1 = rankInfo:getChildByName("tx1")
            tx1:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT35"))
        else  --归属信息显示
            local tx = belongInfo:getChildByName("tx")
            tx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT12"))
            local tx1 = belongInfo:getChildByName("tx1")
            tx1:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT36"))
            local belonglegion = belongInfo:getChildByName("legion_name")

            if ownerLid == self.lid then
                belonglegion:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_INF11"))
                belonglegion:setColor(COLOR_TYPE.GREEN)
            else
                belonglegion:setString(self.BossInfo[i].ownerLegionName)
                belonglegion:setColor(COLOR_TYPE.RED)
            end
        end
    end

    --归属按钮
    local legionLv = self.BossInfo[i].legionLevel or 1
    if exitBoss then
        local btnTx = belongBtn:getChildByName("btn_tx")
        btnTx:setString("Lv" .. legionLv)
        belongBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:showAwardBelongUI(2,legionLv)
            end
        end) 
    end

    --伤害排行榜
    hurtRankBtn:setTouchEnabled(exitBoss)
    hurtRankBtn:setBright(exitBoss)
    hurtRankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showDamageRankUI(self.BossInfo[i].lid)
        end
    end) 
end

function TerritoralwarBossListUI:showSpine(url,y)
    y = y or 0
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display')
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
    spineAni:setPosition(cc.p(0,-70))
    self.modeNode:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function TerritoralwarBossListUI:getBossInfo(bossLv,bossIndex)

    if not bossLv or not bossIndex or bossLv == 0 then
        return
    end
    
    local dfbossforceCfg = GameData:getConfData("dfbossforce")[bossLv]
    bossIndex = bossIndex+1
    local maxNum = #dfbossforceCfg.battleId
    bossIndex = (bossIndex > maxNum or bossIndex < 1) and 1 or bossIndex
    local fomationConfig = GameData:getConfData("formation")[dfbossforceCfg.battleId[bossIndex]]
    if not fomationConfig then
        return
    end

    local monsterId = fomationConfig['pos'..fomationConfig.boss]
    local monsterConfig = GameData:getConfData("monster")[monsterId]

    return monsterConfig.heroName,monsterConfig.url,fomationConfig.fightforce
end

return TerritoralwarBossListUI