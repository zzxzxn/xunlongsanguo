local CountryWarBattlefieldInfoUI = class("CountryWarBattlefieldInfoUI", BaseUI)

local MAX_WIDTH = 3584

function CountryWarBattlefieldInfoUI:ctor(data)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_BATTLEFIELD_INFO
    self.data = data
    self.cells = {}
end

function CountryWarBattlefieldInfoUI:updateRightPanel()
    local rightImg = self.bgImg1:getChildByName('right_img')
    local descTx = rightImg:getChildByName('desc_tx')
    local descTx1 = rightImg:getChildByName('desc_tx_1')
    local descTx3 = rightImg:getChildByName('desc_tx_3')
    local descTx4 = rightImg:getChildByName('desc_tx_4')
    local descTx5 = rightImg:getChildByName('desc_tx_5')
    local scoreTx = rightImg:getChildByName('jifen_tx')
    local timeTx = rightImg:getChildByName('time_tx')
    local boxBtn = rightImg:getChildByName('box_btn')
    for i=1,3 do
        local numTx = rightImg:getChildByName('num_tx_'..i)
        local scoreNumTx = rightImg:getChildByName('jifen_num_tx_'..i)
        numTx:setString(self.data.country[tostring(i)].count)
        scoreNumTx:setString(self.data.country[tostring(i)].score.week)
    end
    descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_50')..self.data.campRank)
    descTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_55'))
    descTx3:setString(GlobalApi:getLocalStr('COUNTRY_WAR_LIST_TITLE_DESC_1'))
    descTx4:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_56'))
    descTx5:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_57'))
    local boxId = {3,2,1}
    boxBtn:loadTextures('uires/icon/material/b'..boxId[self.data.campRank]..'.png', '', '')
    boxBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:showCountryWarAward(1,self.data.campRank,self.data.campRank,self.data.weekRank,self.data.dayRank)
        end
    end)
end

function CountryWarBattlefieldInfoUI:updateLeftCitys()
    local leftImg = self.bgImg1:getChildByName('left_img')
    local descTx = leftImg:getChildByName('desc_tx')
    local descTx1 = leftImg:getChildByName('desc_tx_1')
    local descTx2 = leftImg:getChildByName('desc_tx_2')
    descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_44'))
    descTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_45'))
    descTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_46'))
    local data = {self.data.day,self.data.week}
    local score = {self.data.personal.day,self.data.personal.week}
    for i=1,2 do
        local numBgImg = leftImg:getChildByName('num_bg_img_'..i)
        local numTx = numBgImg:getChildByName('num_tx')
        local killTx = leftImg:getChildByName('kill_tx_'..i)
        local deathTx = leftImg:getChildByName('death_tx_'..i)
        numTx:setString(score[i])
        killTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_47')..data[i].kill or 0)
        deathTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_48')..data[i].dead or 0)
    end
end

function CountryWarBattlefieldInfoUI:updatePanel()
    self:updateLeftCitys()
    self:updateRightPanel()
end

function CountryWarBattlefieldInfoUI:init()
    local bgImg = self.root:getChildByName("countrywar_bg_img")
    local bgImg1 = bgImg:getChildByName("countrywar_img")
    self:adaptUI(bgImg, bgImg1)
    self.bgImg1 = bgImg1
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarBattlefieldInfo()
        end
    end)

    local leftBgImg = bgImg1:getChildByName('left_title_img')
    local titleTx1 = leftBgImg:getChildByName('title_tx_1')
    local titleTx2 = leftBgImg:getChildByName('title_tx_2')
    titleTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_58'))
    titleTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_59'))
    local rightBgImg = bgImg1:getChildByName('right_title_img')
    local titleTx1 = rightBgImg:getChildByName('title_tx_1')
    local titleTx2 = rightBgImg:getChildByName('title_tx_2')
    titleTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_60'))
    titleTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_61'))

    self:updatePanel()
end

return CountryWarBattlefieldInfoUI