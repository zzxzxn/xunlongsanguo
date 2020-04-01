local CountryWarCityInfoUI = class("CountryWarCityInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CountryWarCityInfoUI:ctor(cityId,data)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_CITY_INFO
    self.data = data
    self.cityId = cityId
    self.maxImportantPlayersNum = 0
end

function CountryWarCityInfoUI:updatePanel()
    local countryBgImg = self.bgImg1:getChildByName("country_bg_img")
    local cityImg = countryBgImg:getChildByName("city_img")
    local cityNameTx = countryBgImg:getChildByName("city_name_tx")
    local descTx1 = self.bgImg1:getChildByName("desc_tx_1")
    local descTx2 = self.bgImg1:getChildByName("desc_tx_2")
    local descTx3 = self.bgImg1:getChildByName("desc_tx_3")
    local neiBgImg1 = self.bgImg1:getChildByName("nei_bg_img_1")
    local titleBgImg = neiBgImg1:getChildByName("title_bg_img")
    local titleTx1 = titleBgImg:getChildByName("title_tx_1")
    local titleTx2 = titleBgImg:getChildByName("title_tx_2")
    local attackTx = neiBgImg1:getChildByName("attack_tx")
    local pl1 = neiBgImg1:getChildByName("pl_1")
    local attackTx = pl1:getChildByName("attack_tx")
    local pl2 = neiBgImg1:getChildByName("pl_2")
    local defenseTx = pl2:getChildByName("defense_tx")
    local vsImg = neiBgImg1:getChildByName("vs_img")
    local neiBgImg2 = self.bgImg1:getChildByName("nei_bg_img_2")
    local titleBgImg1 = neiBgImg2:getChildByName("title_bg_img")
    local titleTx = titleBgImg1:getChildByName("title_tx")
    local sendBtn = self.bgImg1:getChildByName("send_btn")
    local infoTx = sendBtn:getChildByName('info_tx')
    local descTx = self.bgImg1:getChildByName('desc_tx')
    local conf = GameData:getConfData("countrywarcity")[self.cityId]

    descTx:setString(string.format(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_85'),conf.cityScore))
    titleTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_66'))
    titleTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_67'))
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_68'))
    attackTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_69'))
    defenseTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_70'))
    infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_71'))
    local tab = {1,2,3}
    table.remove(tab,self.data.hold_camp)
    local maxAttNum = 0
    local maxDefNum = 0
    for i,v in ipairs(tab) do
        if self.data.players and self.data.players[tostring(v)] and #self.data.players[tostring(v)] > 0 then
            maxAttNum = maxAttNum + 1
        end
    end
    tab[#tab + 1] = 6
    tab[#tab + 1] = self.data.hold_camp
    -- if self.data.players and self.data.players[tostring(self.data.hold_camp)] and #self.data.players[tostring(self.data.hold_camp)] > 0 then
    --     maxDefNum = maxDefNum + 1
    -- end
    -- if self.data.players and self.data.players[tostring(6)] and #self.data.players[tostring(6)] > 0 then
    --     maxDefNum = maxDefNum + 1
    -- end
    local players = {}
    local robots = {}
    for i,v in ipairs(self.data.players[tostring(self.data.hold_camp)]) do
        if v.uid < 100000 then
            robots[#robots + 1] = v
        else
            players[#players + 1] = v
        end
    end
    self.data.players[tostring(self.data.hold_camp)] = players
    self.data.players['6'] = robots
    if #players > 0 then
        maxDefNum = maxDefNum + 1
    end
    if #robots > 0 then
        maxDefNum = maxDefNum + 1
    end

    if maxAttNum <= 0 then
        pl1:setVisible(false)
        vsImg:setVisible(false)
        pl2:setPosition(cc.p(389,82))
    else
        pl1:setVisible(true)
        pl2:setPosition(cc.p(582,82))
        vsImg:setVisible(true)
        local posXs = {60,170}
        for i=1,2 do
            local flagImg = pl1:getChildByName('flag_img_'..i)
            local numTx = pl1:getChildByName('num_tx_'..i)
            flagImg:loadTexture('uires/ui/countrywar/countrywar_flag_' .. tab[i] ..  '.png')
            if self.data.players and self.data.players[tostring(tab[i])] and #self.data.players[tostring(tab[i])] > 0 then
                flagImg:setVisible(true)
                numTx:setVisible(true)
                numTx:setString('x '..#self.data.players[tostring(tab[i])]..GlobalApi:getLocalStr('SOLDIER_REN'))
            else
                flagImg:setVisible(false)
                numTx:setVisible(false)
            end
            if maxAttNum == 1 then
                flagImg:setPosition(cc.p(115,94))
                numTx:setPosition(cc.p(115,23))
            else
                flagImg:setPosition(cc.p(posXs[i],94))
                numTx:setPosition(cc.p(posXs[i],23))
            end
        end
    end
    local posXs = {130,240}
    for i=1,2 do
        local flagImg = pl2:getChildByName('flag_img_'..i)
        local numTx = pl2:getChildByName('num_tx_'..i)
        flagImg:loadTexture('uires/ui/countrywar/countrywar_flag_' .. tab[i + 2] ..  '.png')
        if self.data.players and self.data.players[tostring(tab[i + 2])] and #self.data.players[tostring(tab[i + 2])] > 0 then
            flagImg:setVisible(true)
            numTx:setVisible(true)
            numTx:setString('x '..#self.data.players[tostring(tab[i + 2])]..GlobalApi:getLocalStr('SOLDIER_REN'))
        else
            flagImg:setVisible(false)
            numTx:setVisible(false)
        end
        if maxDefNum == 1 then
            flagImg:setPosition(cc.p(185,94))
            numTx:setPosition(cc.p(185,23))
        else
            flagImg:setPosition(cc.p(posXs[i],94))
            numTx:setPosition(cc.p(posXs[i],23))
        end
    end

    local attributeConf = GameData:getConfData("attribute")
    countryBgImg:loadTexture('uires/ui/countrywar/country_di_'..conf.group..'.png')
    descTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..conf.group)..GlobalApi:getLocalStr('COUNTRY_WAR_DESC_51')..
        GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..self.data.hold_camp)..'）')

    local per = (attributeConf[tonumber(conf.atts[1])].desc == '0') and '' or '%'
    descTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..conf.group)..GlobalApi:getLocalStr('COUNTRY_WAR_LIST_TITLE_DESC_1')
        ..GlobalApi:getLocalStr('STR_WUJIANG')..attributeConf[tonumber(conf.atts[1])].name..conf.value[1]..per)
    local per = (attributeConf[tonumber(conf.atts[2])].desc == '0') and '' or '%'
    descTx3:setString(GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..conf.group)..GlobalApi:getLocalStr('COUNTRY_WAR_LIST_TITLE_DESC_1')
        ..GlobalApi:getLocalStr('STR_WUJIANG')..attributeConf[tonumber(conf.atts[2])].name..conf.value[2]..per)
    cityImg:loadTexture('uires/ui/countrywar/'..self.data.hold_camp..'-'..conf.type..'.png')
    cityImg:ignoreContentAdaptWithSize(true)
    cityImg:setScale(0.6)
    cityNameTx:setString(conf.name)
    sendBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:broadcastCallOfDuty(self.cityId,function()
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_12'), COLOR_TYPE.RED)
            end)
        end
    end)

    -- responseBtn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         CountryWarMgr:responseCallOfDuty(self.cityId,function()
    --             CountryWarMgr:hideCountryWarCityInfo()
    --             -- promptmgr:showSystenHint('集结令响应成功', COLOR_TYPE.RED)
    --         end)
    --     end
    -- end)

    local sv = neiBgImg2:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local num = 0
    local diffWidth = 130
    for k,v in pairs(self.data.importantPlayers) do
        num = num + 1
        local awardBgImg = sv:getChildByTag(1000 + num)
        if not awardBgImg then
            local tab = ClassItemCell:create()
            awardBgImg = tab.awardBgImg
            sv:addChild(awardBgImg,1,1000 + num)
            awardBgImg:setAnchorPoint(cc.p(0,0.5))
            awardBgImg:setPosition(cc.p((num - 1)*diffWidth + 20,55))

            local positionTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
            positionTx:setColor(COLOR_TYPE.ORANGE)
            positionTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
            positionTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            positionTx:setAnchorPoint(cc.p(0.5,0.5))
            positionTx:setName('position_tx')
            awardBgImg:addChild(positionTx)
        end
        local awardImg = awardBgImg:getChildByName('award_img')
        local lvTx = awardBgImg:getChildByName('lv_tx')
        local nameTx = awardBgImg:getChildByName('name_tx')
        local positionTx = awardBgImg:getChildByName('position_tx')

        local obj = RoleData:getHeadPicObj(v.headpic)
        local obj1 = RoleData:getRoleInfoById(v.main_role)
        nameTx:setString(v.un)
        awardBgImg:loadTexture(obj1:getBgImg())
        awardImg:loadTexture(obj:getIcon())
        lvTx:setString('Lv.'..v.level)
        local conf = GameData:getConfData("position")
        positionTx:setString(conf[v.position].title)
        local size = awardBgImg:getContentSize()
        nameTx:setPosition(cc.p(size.width/2,size.height + 15))
        nameTx:setScale(22/24)
        positionTx:setPosition(cc.p(size.width/2,size.height + 42))

        awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                BattleMgr:showCheckInfo(v.uid,nil,"country")
            end
        end)
    end

    for i=1,self.maxImportantPlayersNum do
        local awardBgImg = sv:getChildByTag(1000 + i)
        if i > num then
            awardBgImg:setVisible(false)
        else
            awardBgImg:setVisible(true)
        end
    end
    self.maxImportantPlayersNum = num

    local size = sv:getContentSize()
    if num * diffWidth + 40 > size.width then
        sv:setInnerContainerSize(cc.size(num* diffWidth,size.height))
    else
        sv:setInnerContainerSize(size)
    end
end

function CountryWarCityInfoUI:init()
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
            CountryWarMgr:hideCountryWarCityInfo()
        end
    end)
    -- local bg2 = bgImg1:getChildByName('bg2')
    -- self.sv = bg2:getChildByName('sv')
    -- self.sv:setScrollBarEnabled(false)

    self:updatePanel()
end

return CountryWarCityInfoUI