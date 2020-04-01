local CountryWarMainUI = class("CountryWarMainUI", BaseUI)

local CALLBACK_TYPES = {
    'task',
    'list',
    'shop',
}
function CountryWarMainUI:ctor(data)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_MAIN
    self.data = data
    self.isOpen = false
    self.isOpen2 = false
    local num = 0
    for i=1,3 do
        for j,v in ipairs(self.data.roomServers[tostring(i)]) do
            if v.status == 1 then
                num = num + 1
                break
            end
        end
    end
    if num >= 3 then
        self.isOpen2 = true
    end
    self.num = num
    self.isOpen1 = self:getMyServerStatus()
end

function CountryWarMainUI:getMyServerStatus()
    local isOpen = false
    for i=1,3 do
        for j,v in ipairs(self.data.roomServers[tostring(i)]) do
            if v.serverId == GlobalData:getServerId() and v.status == 1 then
                isOpen = true
                break
            end
        end
    end
    return isOpen
end

function CountryWarMainUI:updatePanel()
    local descImg = self.pl:getChildByName('desc_img')
    local descTx = descImg:getChildByName('desc_tx')
    local timeTx = descImg:getChildByName('time_tx')
    if timeTx then
        timeTx:removeFromParent()
    end
    local timeTx = cc.Label:createWithTTF('', "font/gamefont.ttf", 32)
    timeTx:setName('time_tx')
    timeTx:setPosition(cc.p(500,25))
    timeTx:setAnchorPoint(cc.p(0,0.5))
    descImg:addChild(timeTx)
    if self.isOpen1 and self.num >= 3 then
        local str = ''
        local diffTime = 0
        local nowTime = self.data.curTime or (GlobalData:getServerTime() + CountryWarMgr.diffTime)
        if nowTime < self.data.beginTime then
            diffTime = self.data.beginTime - nowTime
            str = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_26')
            self.isOpen = false
        elseif nowTime < self.data.endTime then
            diffTime = self.data.endTime - nowTime
            str = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_27')
            self.isOpen = true
        -- else
        --     diffTime = self.data.beginTime - nowTime + 86400
        --     str = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_26')
        --     self.isOpen = false
        end
        descTx:setString('')
        Utils:createCDLabel(timeTx,diffTime,COLOR_TYPE.WHITE,COLOR_TYPE.RED,CDTXTYPE.FRONT,str,
            COLOR_TYPE.WHITE,COLOR_TYPE.RED,32,function ()
            CountryWarMgr:getOpenTime(function(data)
                self.data = data
                self:updatePanel()
            end)
        end)
    elseif not self.isOpen1 then
        descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_62'))
    else
        descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_92'))
    end
end

function CountryWarMainUI:onShow()
    self:updateNewImg()
end

function CountryWarMainUI:updateNewImg()
    local marks = {
        UserData:getUserObj():getSignByType('countrywartask'),
        false,
        false,
    }
    for i=1,3 do
        local btn = self.root:getChildByName("bottom_btn_"..i)
        local newImg = btn:getChildByName('new_img')
        if newImg then
            newImg:setVisible(marks[i])
        end
    end
end

function CountryWarMainUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local pl = self.root:getChildByName("pl")
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarMain()
        end
    end)
    local winSize = cc.Director:getInstance():getVisibleSize()
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    pl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.pl = pl

    local functions = {
        ['task'] = function()
            if not self.isOpen2 or not self.isOpen1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_91'), COLOR_TYPE.RED)
                return
            end
            local isOpen = false
            for i=1,3 do
                for j,v in ipairs(self.data.roomServers[tostring(i)]) do
                    if v.status == 1 and v.serverId == GlobalData:getSelectSeverUid() then
                        isOpen = true
                        break
                    end
                end
            end
            if not isOpen then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_79'), COLOR_TYPE.RED)
                return
            end
            local isOpen = GlobalApi:getOpenInfo('countrywar')
            if not isOpen then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_80'), COLOR_TYPE.RED)
                return
            end
            CountryWarMgr:showCountryWarTask()
        end,
        ['list'] = function()
            if not self.isOpen2 or not self.isOpen1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_91'), COLOR_TYPE.RED)
                return
            end
            CountryWarMgr:showCountryWarList()
        end,
        ['shop'] = function()
            MainSceneMgr:showShop(61,{min = 61,max = 61})
        end,
    }

    for i=1,3 do
        local btn = self.root:getChildByName("bottom_btn_"..i)
        local size = btn:getContentSize()
        btn:setPosition(cc.p(winSize.width - (i - 0.5)*size.width,size.height/2))
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if functions[CALLBACK_TYPES[i]] then
                    functions[CALLBACK_TYPES[i]]()
                end
            end
        end)
    end

    local enterBtn = pl:getChildByName('enter_btn')
    local infoTx = enterBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_10'))
    enterBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if not self.isOpen1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_62'), COLOR_TYPE.RED)
            elseif self.num < 3 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_92'), COLOR_TYPE.RED)
            elseif not self.isOpen then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_29'), COLOR_TYPE.RED)
            else
                CountryWarMgr:showCountryWarMap()
            end
        end
    end)

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.COUNTRYWAR_HELP)
    local size = btn:getContentSize()
    btn:setPosition(cc.p(size.width/2 + 10, winSize.height - size.height/2 - 10))
    self.root:addChild(btn)

    self:updateInfoSv(pl)
    self:updatePanel()
    self:updateNewImg()
end

function CountryWarMainUI:updateInfoSv(pl)
    local neiBgImg = pl:getChildByName('nei_bg_img')
    local titleTx = neiBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_11'))
    local infoSv = neiBgImg:getChildByName('info_sv')
    infoSv:setScrollBarEnabled(false)
    local diffHeights = {24,40,40,64,32}
    local size1 = infoSv:getContentSize()
    local maxNum = #self.data.roomServers[tostring(1)]
    if maxNum > 2 then
        infoSv:setInnerContainerSize(cc.size(size1.width,size1.height + (maxNum - 2)*38))
    else
        infoSv:setInnerContainerSize(size1)
    end
    local size = infoSv:getInnerContainerSize()
    local diff = 0
    diff = diff + diffHeights[1]
    local titleTx = infoSv:getChildByName('title_tx_1')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_TITLE_1'))
    titleTx:setPosition(cc.p(80,size.height - diff))
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(500, 30))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
    local timeStr = CountryWarMgr:getBaseValue('openTime')
    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_1'),20,COLOR_TYPE.WHITE)
    local re1 = xx.RichTextLabel:create(timeStr[1],20,COLOR_TYPE.GREEN)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_2'),20,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(timeStr[2],20,COLOR_TYPE.GREEN)
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_3'),20,COLOR_TYPE.WHITE)
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(152,size.height - diff))
    infoSv:addChild(richText)

    diff = diff + diffHeights[2]
    local titleTx = infoSv:getChildByName('title_tx_2')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_TITLE_2'))
    titleTx:setPosition(cc.p(80,size.height - diff))
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(500, 30))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
    local conf = GameData:getConfData('moduleopen')['countrywar']
    local limitLv = conf.level
    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_4'),20,COLOR_TYPE.WHITE)
    local re1 = xx.RichTextLabel:create(limitLv,20,COLOR_TYPE.GREEN)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_5'),20,COLOR_TYPE.WHITE)
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(152,size.height - diff))
    infoSv:addChild(richText)

    diff = diff + diffHeights[3]
    local titleTx = infoSv:getChildByName('title_tx_3')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_TITLE_3'))
    titleTx:setPosition(cc.p(80,size.height - diff))
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(500, 30))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_6'),20,COLOR_TYPE.WHITE)
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_15'),20,COLOR_TYPE.ORANGE)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_16'),20,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_7'),20,COLOR_TYPE.ORANGE)
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_8'),20,COLOR_TYPE.WHITE)
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(152,size.height - diff))
    infoSv:addChild(richText)

    diff = diff + diffHeights[4]
    local titleTx = infoSv:getChildByName('title_tx_4')
    titleTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_TITLE_4'))
    titleTx:setPosition(cc.p(80,size.height - diff))

    diff = diff + diffHeights[5]
    local descTx = infoSv:getChildByName('desc_tx')
    -- descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_9'))
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(500, 30))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_9'),20,COLOR_TYPE.WHITE)
    local re1 = xx.RichTextLabel:create('1',20,COLOR_TYPE.RED)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_12'),20,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_13'),CountryWarMgr:getBaseValue('serverOpenDayLimit')),20,COLOR_TYPE.RED)
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_MAIN_DESC_14'),20,COLOR_TYPE.WHITE)
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.RED, 1)
    re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(26,size.height - diff))
    infoSv:addChild(richText)
    -- descTx:setPosition(cc.p(26,size.height - diff))

    diff = diff + 40
    local posXs = {125,350,575}
    for i=1,3 do
        for j,v in ipairs(self.data.roomServers[tostring(i)]) do
            local bgImg,dianImg,nameTx,fuTx = self:createServerBg()
            bgImg:setPosition(cc.p(posXs[i],size.height - diff - (j - 1)*40))
            infoSv:addChild(bgImg)
            dianImg:loadTexture('uires/ui/countrywar/fu_dian_'..i..'.png')
            nameTx:setString(self:getServer(v.serverId))
            fuTx:setString(string.format('%03d', v.serverId)..GlobalApi:getLocalStr('FU'))
            if v.status ~= 1 then
                fuTx:setColor(COLOR_TYPE.GRAY)
                nameTx:setColor(COLOR_TYPE.GRAY)
                fuTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
                nameTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
            end
        end
        -- for j=1,10 do
        --     local bgImg,dianImg,nameTx,fuTx = self:createServerBg()
        --     bgImg:setPosition(cc.p(posXs[i],size.height - diff - (j - 1)*40))
        --     infoSv:addChild(bgImg)
        --     dianImg:loadTexture('uires/ui/countrywar/fu_dian_'..i..'.png')
        --     nameTx:setString(self:getServer(self.data.roomServers[tostring(i)][1].serverId))
        --     fuTx:setString(string.format('%03d',self.data.roomServers[tostring(i)][1].serverId)..GlobalApi:getLocalStr('FU'))
        -- end
    end
end

function CountryWarMainUI:getServer(id)
    local tab = GlobalData:getServerTab()
    for k,v in pairs(tab) do
        if v.id == id then
            return v.name
        end
    end
    return ''
end

function CountryWarMainUI:createServerBg()
    local bgImg = ccui.ImageView:create('uires/ui/common/common_bg_31.png')
    bgImg:ignoreContentAdaptWithSize(true)
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(200,36))
    bgImg:setName('bg_img')

    local dianImg = ccui.ImageView:create('uires/ui/common/common_bg_31.png')
    dianImg:setName('dian_img')
    dianImg:setPosition(cc.p(18,18))

    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setPosition(cc.p(145,18))
    nameTx:setName('name_tx')

    local fuTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    fuTx:setColor(COLOR_TYPE.WHITE)
    fuTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    fuTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fuTx:setAnchorPoint(cc.p(0.5,0.5))
    fuTx:setPosition(cc.p(62,18))
    fuTx:setName('fu_tx')

    bgImg:addChild(dianImg)
    bgImg:addChild(nameTx)
    bgImg:addChild(fuTx)

    return bgImg,dianImg,nameTx,fuTx
end

return CountryWarMainUI