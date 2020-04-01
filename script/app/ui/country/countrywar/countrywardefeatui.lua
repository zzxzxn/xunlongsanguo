local CountryWarDefeatUI = class("CountryWarDefeatUI", BaseUI)
function CountryWarDefeatUI:ctor(data,callback)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_DEFEAT
    self.callback = callback
    self.data = data
end

function CountryWarDefeatUI:updatePanel()

end

function CountryWarDefeatUI:init()
    local bgImg = self.root:getChildByName("country_bg_img")
    local countryImg = bgImg:getChildByName("country_img")
    self:adaptUI(bgImg, countryImg)
    local bgImg1 = countryImg:getChildByName("bg_img1")
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg1:getChildByName("ok_btn")
    local infoTx = closeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr("STR_OK2"))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarDefeat()
            if self.callback then
                self.callback()
            end
        end
    end)

    local bgImg3 = bgImg1:getChildByName("bg_img3")
    local titleTx = bgImg1:getChildByName('title_tx')
    local descTx1 = bgImg3:getChildByName('desc_tx_1')
    local descTx2 = bgImg3:getChildByName('desc_tx_2')
    local descTx3 = bgImg3:getChildByName('desc_tx_3')
    local numTx1 = bgImg3:getChildByName('num_tx_1')
    local numTx2 = bgImg3:getChildByName('num_tx_2')
    numTx1:setString('+'..self.data.deadBattleInfo.continuousKill)
    numTx2:setString('+'..self.data.deadBattleInfo.scoreSinceLastDeath)
    descTx1:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_37"))
    descTx2:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_35"))
    descTx3:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_36"))
    titleTx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_40"))

    local conf = GameData:getConfData("countrywarcity")[self.data.deadBattleInfo.cityId]
    local richText = xx.RichText:create()
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(500, 48))
    if self.data.deadBattleInfo.killer then
        local str = ''
        if self.data.deadBattleInfo.killer.uid < 100000 then
            str = GlobalApi:getLocalStr("COUNTRY_WAR_DESC_52")
        else
            str = self.data.deadBattleInfo.killer.server..GlobalApi:getLocalStr("FU")
        end
        local re = xx.RichTextLabel:create('('..str..')', 25, COLOR_TYPE.RED)
        re:setStroke(COLOROUTLINE_TYPE.RED, 1)
        local re1 = xx.RichTextImage:create('uires/ui/countrywar/countrywar_flag_'..self.data.deadBattleInfo.killer.country..'.png')
        re1:setScale(0.2)
        local re2 = xx.RichTextLabel:create(self.data.deadBattleInfo.killer.un, 25, COLOR_TYPE.ORANGE)
        re2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_38"), 25, COLOR_TYPE.WHITE)
        re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        local re4 = xx.RichTextLabel:create('['..conf.name..']', 25, COLOR_TYPE.BLUE)
        re4:setStroke(COLOROUTLINE_TYPE.BLUE, 1)
        local re5 = xx.RichTextLabel:create(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_39"), 25, COLOR_TYPE.WHITE)
        re5:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        richText:addElement(re)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:addElement(re4)
        richText:addElement(re5)
        richText:setAnchorPoint(cc.p(0,1))
        richText:setPosition(cc.p(25,210))
        bgImg3:addChild(richText)
    else
        local descTx = cc.Label:createWithTTF(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_84"), "font/gamefont.ttf", 24)
        descTx:setColor(COLOR_TYPE.WHITE)
        descTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
        descTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        descTx:setAnchorPoint(cc.p(0.5,0.5))
        descTx:setPosition(cc.p(closeBtn:getPositionX(),closeBtn:getPositionY() + 205))
        bgImg1:addChild(descTx)
    end

    self:updatePanel()
end

return CountryWarDefeatUI