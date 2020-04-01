local TerritorialWarsCreaturelUI = class("TerritorialWarsCreature", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')


function TerritorialWarsCreaturelUI:ctor(resId,cellId,around,stayingPower)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_CREATURE
    self.resId = resId
    self.around = around
    self.cellId = cellId
    self.stayingPower = math.floor(stayingPower)
    self.maxCellCount = 0
end

function TerritorialWarsCreaturelUI:Fighting()
    local customObj = {
        id = self.combatId,
        levelType = 1,
        cellId = self.cellId,
        stayingPower = self.stayingPower
    }
    BattleMgr:playBattle(BATTLE_TYPE.TERRITORALWAL_MONSTER, customObj, function ()
        TerritorialWarMgr:showMapUI()
    end)
end

function TerritorialWarsCreaturelUI:getSpine(url,y)
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display')
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
    spineAni:setPosition(cc.p(195,135 + y))
    self.leftImg:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function TerritorialWarsCreaturelUI:updateAward()
    local awardsTab = GameData:getConfData("drop")[self.dropId]
    local awardsAtt = {}
    if awardsTab.fixed[1] then
        for i = 1,#awardsTab.fixed do
            local data = clone(awardsTab.fixed[i])
            data.isFixed = true
            table.insert(awardsAtt,data)
        end
    end
    for i = 1,10 do
        local str = 'award'..i
        if awardsTab[str] and awardsTab[str][1] then
            table.insert(awardsAtt,awardsTab[str][1])
        end
    end

    for i = 1,#awardsAtt do
        local awardBgImg = self.awardSv:getChildByTag(1000 + i)
        if not awardBgImg then
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            awardBgImg = tab.awardBgImg
            awardBgImg:setTouchEnabled(true)
            self.awardSv:addChild(awardBgImg,1,1000 + i)
            awardBgImg:setAnchorPoint(cc.p(0,0.5))
            awardBgImg:setPosition(cc.p((i - 1)*110 + 10,50))
        end
        local award = DisplayData:getDisplayObj(awardsAtt[i])
        ClassItemCell:updateItem(awardBgImg, award, 2)
        local stype = award:getCategory()
        local lvTx = awardBgImg:getChildByName('lv_tx')
        if stype == 'equip' then
            lvTx:setString('Lv.'..award:getLevel())
        else
            lvTx:setString('x'..award:getNum())
        end
        if awardsAtt[i].isFixed == true then
            local cornerImg = ccui.ImageView:create('uires/ui/common/corner_blue_2.png')
            cornerImg:setScale(0.8)
	        cornerImg:setPosition(cc.p(67,67))
            awardBgImg:addChild(cornerImg)

            local nameTx = ccui.Text:create()
            nameTx:setRotation(45)
	        nameTx:setFontName("font/gamefont.ttf")
	        nameTx:setFontSize(16)
	        nameTx:setPosition(cc.p(76,73))
	        nameTx:setTextColor(COLOR_TYPE.WHITE)
	        nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
	        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	        nameTx:setAnchorPoint(cc.p(0.5,0.5))
            awardBgImg:addChild(nameTx)
            nameTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_100'))
        end
        awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(award,false)
            end
        end)
    end

    local size = self.awardSv:getContentSize()
    if #awardsAtt * 110 + 10 > size.width then
        self.awardSv:setInnerContainerSize(cc.size(#awardsAtt * 110,size.height))
    else
        self.awardSv:setInnerContainerSize(size)
    end

end

function TerritorialWarsCreaturelUI:updatePanel()
    self:updateAward()
end

function TerritorialWarsCreaturelUI:init()
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
            TerritorialWarMgr:hideCreatureUI()
        end
    end)
    local neiBgImg = self.expeditionImg:getChildByName("nei_bg_img")
    local leftImg = neiBgImg:getChildByName("left_bg_img")
    self.leftImg = leftImg

    local rightPl = neiBgImg:getChildByName("right_pl")
    local npcPl = rightPl:getChildByName('npc_pl')
    local enemyPl = rightPl:getChildByName('enemy_pl')
    enemyPl:setVisible(false)
    local bottomImg = npcPl:getChildByName("bottom_bg_img")
    local topImg = rightPl:getChildByName("top_bg_img")
    local descTx = topImg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO30'))
    local szBgImg = topImg:getChildByName('sz_bg_img')
    local numTx = szBgImg:getChildByName('num_tx')
    numTx:setString(self.stayingPower..'/100')

    local titleBgImg = bottomImg:getChildByName("title_bg_img")
    local infoTx = titleBgImg:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO9'))
    local fightingBtn = bottomImg:getChildByName("fighting_btn")
    infoTx = fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO8'))
    self.awardSv = bottomImg:getChildByName("award_sv")
    self.awardSv:setScrollBarEnabled(false)
    fightingBtn:setVisible(self.around)
    fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:Fighting()
        end
    end)

    --碾压
    local oneKillBtn = bottomImg:getChildByName("onekill_btn")
    local btnTx = oneKillBtn:getChildByName("info_tx")
    btnTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT40"))
    oneKillBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('sec_kill_monster','territorywar',json.encode({cellId = self.cellId}),function (response)
                local code = response.code
                local data = response.data
                if code ~= 0 then
                    return
                end 
                GlobalApi:parseAwardData(data.awards)
                GlobalApi:showAwardsCommon(data.awards,2,nil,true)
                TerritorialWarMgr:deleteMonster(self.cellId)
                TerritorialWarMgr:hideCreatureUI()
            end)
        end
    end)

    local zhanBgImg = leftImg:getChildByName('zhan_bg_img')
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    local nameTx = leftImg:getChildByName('name_tx')
    forceLabel:setString('')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)

    local dfmapcreature = GameData:getConfData("dfmapcreature")[self.resId]
    self.dropId = dfmapcreature.lootId
    self.combatId = dfmapcreature.combatId
    local monsterConf = GameData:getConfData("formation")[dfmapcreature.combatId]
    self.forceLabel:setString(monsterConf.fightforce)
    local monsterId = monsterConf['pos'..monsterConf.boss]
    local monsterObj = GameData:getConfData("monster")[monsterId]
    self:getSpine(monsterObj.url,monsterObj.uiOffsetY)
    nameTx:setString(monsterObj.heroName)

    local userLevel = UserData:getUserObj():getLv()
    local size = bottomImg:getContentSize()
    local showOneKilBtn = false
    if self:exitInMonsters() and self.around and userLevel >= monsterObj.level then
        showOneKilBtn = true
    end
    if not showOneKilBtn then
        fightingBtn:setPositionX(size.width/2)
    else
        fightingBtn:setPositionX(size.width/2-97)
    end
    oneKillBtn:setVisible(showOneKilBtn)
    self:updatePanel()
end

function TerritorialWarsCreaturelUI:exitInMonsters()

    local onekillMonster =  UserData:getUserObj():getTerritorialWar().secKill or {}
    for k,v in pairs(onekillMonster) do
        if tonumber(v) == self.resId then
            return true
        end
    end
    return false
end

return TerritorialWarsCreaturelUI