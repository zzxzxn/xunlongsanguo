local CountryWarCityPlayerInfoUI = class("CountryWarCityPlayerInfoUI", BaseUI)

function CountryWarCityPlayerInfoUI:ctor(data,camp)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_CITY_PLAYER_INFO
    self.data = data
    self.camp = camp
    -- for i=3,10 do
    --     self.data.players[i] = self.data.players[1]
    -- end
end

function CountryWarCityPlayerInfoUI:createCell()
    local positionTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    positionTx:setColor(COLOR_TYPE.WHITE)
    positionTx:enableOutline(COLOR_TYPE.BLACK, 1)
    positionTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    positionTx:setAnchorPoint(cc.p(0,0.5))

    local scoreTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    scoreTx:setColor(COLOR_TYPE.WHITE)
    scoreTx:enableOutline(COLOR_TYPE.BLACK, 1)
    scoreTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    scoreTx:setAnchorPoint(cc.p(0.5,0.5))

    local lvTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    lvTx:setColor(COLOR_TYPE.WHITE)
    lvTx:enableOutline(COLOR_TYPE.BLACK, 1)
    lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lvTx:setAnchorPoint(cc.p(0,0.5))

    local fightforceTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    fightforceTx:setColor(COLOR_TYPE.WHITE)
    fightforceTx:enableOutline(COLOR_TYPE.BLACK, 1)
    fightforceTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fightforceTx:setAnchorPoint(cc.p(0,0.5))

    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0,0.5))

    local fuTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    fuTx:setColor(COLOR_TYPE.WHITE)
    fuTx:enableOutline(COLOR_TYPE.BLACK, 1)
    fuTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fuTx:setAnchorPoint(cc.p(0,0.5))

    return positionTx,fuTx,nameTx,scoreTx,lvTx,fightforceTx
end

function CountryWarCityPlayerInfoUI:init()
    local bgImg = self.root:getChildByName("countrywar_bg_img")
    local bgImg1 = bgImg:getChildByName("countrywar_img")
    self:adaptUI(bgImg,bgImg1)
    self.bgImg1 = bgImg1
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg1:getChildByName("close_btn")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarCityPlayerInfo()
        end
    end)

    local titleTx = bgImg1:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_87'))
    local flagImg = bgImg1:getChildByName('flag_img')
    flagImg:loadTexture('uires/ui/countrywar/countrywar_flag_small_'..self.camp..'.png')

    local titleTx1 = bgImg1:getChildByName('title_tx_1')
    local titleTx2 = bgImg1:getChildByName('title_tx_2')
    titleTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_86')..':')
    titleTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_52')..':')

    local descTx1 = bgImg1:getChildByName('desc_tx_1')
    local descTx2 = bgImg1:getChildByName('desc_tx_2')
    local descTx3 = bgImg1:getChildByName('desc_tx_3')
    local descTx4 = bgImg1:getChildByName('desc_tx_4')
    local descTx5 = bgImg1:getChildByName('desc_tx_5')
    descTx1:setString(GlobalApi:getLocalStr('STR_OFFICE'))
    descTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_86'))
    descTx3:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_90'))
    descTx4:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES2'))
    descTx5:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES3'))

    local sv = bgImg1:getChildByName("sv")
    local meImg = sv:getChildByName('me_img')
    meImg:setVisible(false)
    sv:setScrollBarEnabled(false)
    local size1 = sv:getContentSize()
    local maxNum = #self.data.players
    if maxNum > 7 then
        sv:setInnerContainerSize(cc.size(size1.width,maxNum*30))
    else
        sv:setInnerContainerSize(size1)
    end
    
    local npcNum = 0
    local size = sv:getInnerContainerSize()
    local diff = 30
    local totalHeight = -10
    local conf = GameData:getConfData("position")
    local uid = UserData:getUserObj():getUid()
    table.sort(self.data.players,function(a,b)
        if a.position == b.position then
            return a.fight_force < b.fight_force
        end
        return a.position < b.position
    end )
    for i,v in ipairs(self.data.players) do
        totalHeight = totalHeight + diff
        local positionTx,fuTx,nameTx,scoreTx,lvTx,fightforceTx = self:createCell()
        positionTx:setString(conf[v.position].title)
        if v.serverId <= 0 then
            fuTx:setString('['..GlobalApi:getLocalStr("COUNTRY_WAR_DESC_52")..']')
        else
            fuTx:setString('['..v.serverId..GlobalApi:getLocalStr('FU')..']')
        end
        nameTx:setString(v.un)
        scoreTx:setString(v.score)
        lvTx:setString(v.level..GlobalApi:getLocalStr('LEGION_LV_DESC'))
        fightforceTx:setString(v.fight_force)

        positionTx:setPosition(cc.p(50,size.height - totalHeight))
        fuTx:setPosition(cc.p(155,size.height - totalHeight))
        local size1 = fuTx:getContentSize()
        nameTx:setPosition(cc.p(155 + size1.width,size.height - totalHeight))
        scoreTx:setPosition(cc.p(393,size.height - totalHeight))
        lvTx:setPosition(cc.p(465,size.height - totalHeight))
        fightforceTx:setPosition(cc.p(555,size.height - totalHeight))

        if uid == v.uid then
            positionTx:setColor(COLOR_TYPE.GREEN)
            fuTx:setColor(COLOR_TYPE.GREEN)
            nameTx:setColor(COLOR_TYPE.GREEN)
            scoreTx:setColor(COLOR_TYPE.GREEN)
            lvTx:setColor(COLOR_TYPE.GREEN)
            fightforceTx:setColor(COLOR_TYPE.GREEN)
            meImg:setVisible(true)
            meImg:setPosition(cc.p(50,size.height - totalHeight - 15))
        end
        if v.uid < 100000 then
            npcNum = npcNum + 1
        end
        sv:addChild(positionTx)
        sv:addChild(fuTx)
        sv:addChild(nameTx)
        sv:addChild(scoreTx)
        sv:addChild(lvTx)
        sv:addChild(fightforceTx)
    end
    local numTx1 = bgImg1:getChildByName('num_tx_1')
    local numTx2 = bgImg1:getChildByName('num_tx_2')
    numTx1:setString(#self.data.players - npcNum)
    numTx2:setString(npcNum)
end

return CountryWarCityPlayerInfoUI