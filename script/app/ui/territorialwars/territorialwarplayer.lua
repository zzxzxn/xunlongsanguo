local TerritorialWarsPlayerlUI = class("TerritorialWarsPlayer", BaseUI)

function TerritorialWarsPlayerlUI:ctor(playerInfo,around)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_ATTACKPLAYER
    self.playerInfo = playerInfo
    self.around = around
end

function TerritorialWarsPlayerlUI:init()
    local bgImg = self.root:getChildByName("expedition_bg_img")
    self.expeditionImg = bgImg:getChildByName("expedition_img")
    self:adaptUI(bgImg, self.expeditionImg)
    local closeBtn = self.expeditionImg:getChildByName("close_btn")
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.expeditionImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
    local titleImg = self.expeditionImg:getChildByName("title_img")
    local tilteNameTx = titleImg:getChildByName("info_tx")
    tilteNameTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO31'))

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hidePlayerUI()
        end
    end)
    local neiBgImg = self.expeditionImg:getChildByName("nei_bg_img")
    local leftImg = neiBgImg:getChildByName("left_bg_img")
    self.leftImg = leftImg

    local rightPl = neiBgImg:getChildByName("right_pl")
    local npcPl = rightPl:getChildByName('npc_pl')
    local enemyPl = rightPl:getChildByName('enemy_pl')
    npcPl:setVisible(false)
    local bottomImg = enemyPl:getChildByName("bottom_bg_img")
    local topImg = rightPl:getChildByName("top_bg_img")
    local descTx = topImg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO30'))
    local szBgImg = topImg:getChildByName('sz_bg_img')
    local numTx = szBgImg:getChildByName('num_tx')
    numTx:setString(self.playerInfo.stayingPower..'/100')

    self.fightingBtn = bottomImg:getChildByName("fighting_btn")
    local infoTx = self.fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO8'))
    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           if self.playerInfo.fightState == true then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_224'),COLOR_TYPE.RED)
            else
               self:Fighting()
           end
        end
    end)
    self.fightingBtn:setVisible(self.around)
    local zhanBgImg = leftImg:getChildByName('zhan_bg_img')
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    local nameTx = leftImg:getChildByName('name_tx')
    forceLabel:setString('')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)
    self.forceLabel:setString(self.playerInfo.fightForce)

    local id = tonumber(self.playerInfo.dragon)
    if id <= 0 then
        id = 1
    end
    local url = GameData:getConfData("playerskill")[id].roleRes
    self:getSpine(url,0)

    nameTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF13'))
    --个人信息
    local descs = {
        'Lv.' ..self.playerInfo.level..' '..self.playerInfo.un,
        GlobalApi:getLocalStr('TERRITORIAL_WAL_INF14') .. self.playerInfo.legionName,
        GlobalApi:getLocalStr('TERRITORIAL_WAL_INF15') .. self.playerInfo.killCount,
    }
    if self.playerInfo.rank == 0 then
        descs[4] = GlobalApi:getLocalStr('TERRITORIAL_WAL_INF16') .. GlobalApi:getLocalStr('TERRITORIAL_WAL_INF17')
    else
        descs[4] = GlobalApi:getLocalStr('TERRITORIAL_WAL_INF16') .. self.playerInfo.rank
    end
    for i=1,4 do
        local descTx = bottomImg:getChildByName('desc_tx_'..i)
        descTx:setString(descs[i])
    end

end

function TerritorialWarsPlayerlUI:getSpine(url,y)

    local weapon_illusion = self.playerInfo.weapon_illusion or 0
    local wing_illusion = self.playerInfo.wing_illusion or 0

    local changeEquipObj = GlobalApi:getChangeEquipState(nil, weapon_illusion, wing_illusion)
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display',nil,changeEquipObj)
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
    spineAni:setPosition(cc.p(195,135 + y))
    self.leftImg:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function TerritorialWarsPlayerlUI:Fighting()
    
    local conf = GameData:getConfData("dfbasepara")
    local minCost = tonumber(conf['enduranceCostLowest'].value[1])
    local myStayingPower = UserData:getUserObj():getEndurance()
    MessageMgr:sendPost('attack_player', 'territorywar', json.encode({targetUid  = self.playerInfo.uid}), function (jsonObj)

        local data = jsonObj.data					
		if jsonObj.code == 0 then
			local customObj = {
				info = data.info,
                enemyUid = data.enemy.uid,
                enemyStayingPower = data.enemy.stayingPower,
                myStayingPower = myStayingPower,
				enemy = data.enemy,
				rand1 = data.rand1,
				rand2 = data.rand2,
                minCost = minCost,
                node = self.root,
			}

			BattleMgr:playBattle(BATTLE_TYPE.TERRITORALWAR_PLAYER, customObj, function ()
                TerritorialWarMgr:showMapUI()
			end)

        else
            TerritorialWarMgr:handleErrorCode(jsonObj.code)
		end
	end)

end

return TerritorialWarsPlayerlUI