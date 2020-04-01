local ShopTipsUI = class("ShopTipsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local SHOP_TYPE = {
    MYSTERYSHOP = 11,
    GODSHOP = 12,
    MARKET = 13,
    TOWERSHOP = 21,
    TOWERGEMSHOP = 22,
    LISTSHOP = 31,
    MILITARYSHOP = 32,
    WORLDWARSHOP = 41,
    LEGIONSHOP = 51,
    LEGIONDRESSSHOP = 52,
    LEGIONWARSHOP = 53,
    LEGIONTRIALSHOP = 54,
}

function ShopTipsUI:ctor(obj,sztab,status,callback,sidebarList,count,showType,page)
    self.uiIndex = GAME_UI.UI_SHOPTIPS
    self.obj = obj
    self.sztab = sztab
    self.status = status
    self.callback = callback
    self.sidebarList = sidebarList
    self.maxTimes = count
    self.times = 1
    self.showType = showType
    self.page = page
end

function ShopTipsUI:updatePanel()
    local stype = self.obj:getCategory()
    local num = 0
    local num1 = self.obj:getNum()
    local name = self.obj:getName()
    local visible = true
    for i=1,3 do
        self.infoTxs[i]:ignoreContentAdaptWithSize(false)
        self.infoTxs[i]:setTextAreaSize(cc.size(360,150))
    end
    if stype == 'material' then
        local obj = BagData:getMaterialById(self.obj:getId())
        num = 0
        if obj then
            num = obj:getNum()
        end
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        if self.obj:getResCategory() == 'equip' then
            stype = 'fragment'
        end
    elseif stype == 'card' then
        -- local obj = BagData:getCardById(tonumber(self.obj:getId()))
        local obj = RoleData:getRoleInfoById(tonumber(self.obj:getId()))
        num = obj:getNum()
        num1 = self.sztab.sellNum
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        self.awardImgs.awardBgImg:setTouchEnabled(true)
        self.awardImgs.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, self.obj)
            end
        end)
    elseif stype == 'gem' then
        -- local obj = BagData:getCardById(tonumber(self.obj:getId()))
        local obj = BagData:getGemById(self.obj:getId())
        num = 0
        if obj then
            num = obj:getNum()
        end
        num1 = self.sztab.sellNum
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'dress' then
        local obj = BagData:getDressByIdForShop(self.obj:getId())
        num = obj:getNum()
        num1 = self.sztab.sellNum
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))    
    elseif stype == 'fragment' then
        local obj = BagData:getFragmentById(self.obj:getId())
        if not obj then
            obj = RoleData:getRoleInfoById(tonumber(self.obj:getId()))
            num = 0
        else
            num = obj:getNum()
        end
        self.awardImgs.awardBgImg:setTouchEnabled(true)
        self.awardImgs.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, self.obj)
            end
        end)
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'equip' then
        num = 0
        local equipObj = self.obj:getObj()
        local mainInfo = equipObj:getMainAttribute()
        self.infoTxs[1]:setString(mainInfo.name..':  +'..mainInfo.value)
        self.infoTxs[1]:enableOutline(COLOR_TYPE.BLACK,1)
        self.infoTxs[1]:setColor(COLOR_TYPE.WHITE)
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        local godId = equipObj:getGodId()
        if godId > 0 then
            local godInfo = clone(equipObj:getGodAttr())
            for i,v in ipairs(godInfo) do
                if godInfo[i].type == 1 then
                    godInfo[i].value = math.floor(godInfo[i].value/100)
                end
                self.infoTxs[i+1]:setString(godInfo[i].name..'    +'..godInfo[i].value..'%')
                self.infoTxs[i+1]:enableOutline(COLOROUTLINE_TYPE[godInfo[i].color],1)
                self.infoTxs[i+1]:setColor(COLOR_TYPE[godInfo[i].color])
                self.infoTxs[i+1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            end
        end
        name = 'Lv. '..self.obj:getLevel()..'  '..name
        visible = false
    elseif stype == 'user' then
        num = UserData:getUserObj()[self.obj:getId()]
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    else
        num = UserData:getUserObj()[self.obj:getId()]
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    end
    self.awardImgs.chipImg:setVisible(stype == 'fragment')
    self.awardImgs.chipImg:loadTexture(self.obj:getChip())
    self.awardImgs.awardBgImg:loadTexture(self.obj:getBgImg())
    self.awardImgs.awardImg:loadTexture(self.obj:getIcon())
    self.awardImgs.awardImg:ignoreContentAdaptWithSize(true)
    self.awardImgs.nameTx:setAnchorPoint(cc.p(0,0.5))
    self.awardImgs.nameTx:setString(name)
    self.awardImgs.nameTx:setPosition(cc.p(105,75))
    self.awardImgs.nameTx:enableOutline(self.obj:getNameOutlineColor(),1)
    self.awardImgs.nameTx:setColor(self.obj:getNameColor())
    self.awardImgs.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    if stype == 'equip' then
        ClassItemCell:setGodLight(self.awardImgs.awardBgImg,self.obj:getGodId())
    else
        self.obj:setLightEffect(self.awardImgs.awardBgImg)
    end

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(230, 30))
    local tx1 = GlobalApi:getLocalStr('STR_HAD')
    local tx2 = GlobalApi:toWordsNumber(num)
    local tx3 = GlobalApi:getLocalStr('STR_JIAN')
    local re1 = xx.RichTextLabel:create(tx1,23,COLOR_TYPE.ORANGE)
    local re2 = xx.RichTextLabel:create(tx2,23,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(tx3,23,COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re2:setStroke(COLOR_TYPE.BLACK, 1)
    re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    --richText:formatText()
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(105 ,37))
    self.awardImgs.awardBgImg:addChild(richText)
    richText:setVisible(visible)
    

    if not self.rts then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(230, 30))
        local tx1 = GlobalApi:getLocalStr('BUY')
        local tx2 = tostring(num1*self.times)
        local tx3 = GlobalApi:getLocalStr('STR_JIAN')
        local re1 = xx.RichTextLabel:create(tx1,23,COLOR_TYPE.ORANGE)
        local re2 = xx.RichTextLabel:create(tx2,23,COLOR_TYPE.WHITE)
        local re3 = xx.RichTextLabel:create(tx3,23,COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re2:setStroke(COLOR_TYPE.BLACK, 1)
        re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        --richText:formatText()
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(cc.p(12 ,106))
        self.neiBgImg:addChild(richText)
        self.rts = {richText = richText,re2 = re2}
    else
        self.rts.re2:setString(num1*self.times)
        self.rts.richText:format(true)
    end
    
    if self.maxTimes then
        local price = self:getPrice()
        local cash = UserData:getUserObj()[self.sztab.id]
        self.szTx:setString(GlobalApi:toWordsNumber(price))
        if price > cash then
            self.szTx:enableOutline(COLOROUTLINE_TYPE.RED,1)
            self.szTx:setColor(COLOR_TYPE.RED)
        else
            self.szTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
            self.szTx:setColor(COLOR_TYPE.WHITE)
        end

        self.rts.richText:setVisible(false)
        if self.maxTimes < 0 then
            self.maxTimes = 0
        end
        
        if self.times > self.maxTimes then
            self.times = self.maxTimes 
        end
        self.timesTx:setString(self.times)

        self.addBtn:setTouchEnabled(true)
        self.addBtn:setBright(true)
        self.lessBtn:setTouchEnabled(true)
        self.lessBtn:setBright(true)

        if self.times <= 1 then
            self.lessBtn:setTouchEnabled(false)
            self.lessBtn:setBright(false)
        end

        if self.times == self.maxTimes then
            self.addBtn:setTouchEnabled(false)
            self.addBtn:setBright(false)
        end
    else
        local sz = UserData:getUserObj()[self.sztab.id]
        local price = self.sztab.costNum*self.times
        if price > sz then
            self.szTx:enableOutline(COLOROUTLINE_TYPE.RED,1)
            self.szTx:setColor(COLOR_TYPE.RED)
        else
            self.szTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
            self.szTx:setColor(COLOR_TYPE.WHITE)
        end
        self.szTx:setString(GlobalApi:toWordsNumber(price))
    end
end

function ShopTipsUI:getPrice()
    local allPrice = 0
    if self.page == SHOP_TYPE.MARKET then
        if not self.sztab.confId then
            return self.times * self.sztab.costNum
        end

        local conf = GameData:getConfData('market')[self.sztab.confId]
        local currNum = self.times
        local vip = UserData:getUserObj():getVip()
        local oldCount = conf['vip'..vip] - self.maxTimes
        local maxNum = tonumber(GlobalApi:getGlobalValue('marketPriceCount'))
        for i=1,maxNum do
            local times,times1 = conf['time'..i],conf['time'..(i + 1)]
            if times == 0 and k == 1 then
                allPrice = allPrice + conf.originPrice * currNum
                currNum = 0
            elseif not times1 or times1 == 0 then
                allPrice = allPrice + conf['price'..i] * currNum
                currNum = 0
            elseif oldCount < times then
                local num = ((times1 - times > currNum) and currNum) or (times1 - times)
                allPrice = allPrice + conf['price'..i] * num
                currNum = currNum - num
            elseif oldCount < (times1 - 1) then
                local num = ((times1 - oldCount > currNum) and currNum) or (times1 - times - (times + 1 - oldCount))
                allPrice = allPrice + conf['price'..i] * num
                currNum = currNum - num
            end
            if currNum <= 0 then
                break
            end
        end
    elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
        allPrice = self.sztab.costNum*self.times
    else
        allPrice = self.sztab.costNum*self.times
    end
    return allPrice
end

function ShopTipsUI:setBright(buyBtn)
    local infoTx = buyBtn:getChildByName('info_tx')
    if (self.maxTimes and self.maxTimes > 0) or self.status == 0 then
        infoTx:setString(GlobalApi:getLocalStr('STR_TO_BUY'))
        buyBtn:setBright(true)
        buyBtn:setTouchEnabled(true)
        infoTx:setColor(COLOR_TYPE['WHITE'])
        infoTx:enableOutline(cc.c3b(165,70,6),1)
        infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    else
        infoTx:setString(GlobalApi:getLocalStr('SOLD_OUT'))
        buyBtn:setBright(false)
        buyBtn:setTouchEnabled(false)
        infoTx:setColor(COLOR_TYPE['WHITE'])
        infoTx:enableOutline(COLOROUTLINE_TYPE['WHITE'],1)
        infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    end
end

function ShopTipsUI:init()
    local tipsBgImg = self.root:getChildByName("tips_bg_img")
    local tipsImg = tipsBgImg:getChildByName("tips_img")
    self:adaptUI(tipsBgImg, tipsImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    tipsImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    self.neiBgImg = tipsImg:getChildByName('nei_bg_img')

    local des = self.neiBgImg:getChildByName('des')
    if self.showType and self.showType == 'show_at_limit_group' then
        des:setVisible(true)
        des:setString(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES11'))
    else
        des:setVisible(false)
    end

    local awardBgNode = self.neiBgImg:getChildByName('award_bg_node')
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    local awardBgImg = tab.awardBgImg
    awardBgNode:addChild(tab.awardBgImg)
    tab.awardBgImg:setTouchEnabled(true)

    self.awardImgs = tab
    local closeBtn = tipsImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local szBgImg = self.neiBgImg:getChildByName('sz_bg_img')
    local szImg = szBgImg:getChildByName('sz_img')
    self.szTx = szBgImg:getChildByName('sz_tx')
    local attrBgImg = self.neiBgImg:getChildByName('attr_bg_img')
    local pl = attrBgImg:getChildByName('pl')
    self.infoTxs = {}
    for i=1,3 do
        local tx = pl:getChildByName('info_'..i..'_tx')
        self.infoTxs[i] = tx
    end
    szImg:loadTexture(self.sztab.icon)
    szImg:ignoreContentAdaptWithSize(true)

    local buyBtn = self.neiBgImg:getChildByName('buy_btn')
    self:setBright(buyBtn)
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.callback then
                local num = self.times
                local needCash = nil
                if self.maxTimes then
                    needCash = self:getPrice()
                end
                self.callback(function()
                    self:hideUI()
                end,num,needCash)
            end
        end
    end)

    local btnPl = self.neiBgImg:getChildByName('pl_btn')
    local descTx = btnPl:getChildByName("desc_1_tx")
    local descTx1 = btnPl:getChildByName("desc_2_tx")
    self.lessBtn = btnPl:getChildByName("less_btn")
    self.addBtn = btnPl:getChildByName("add_btn")
    self.timesTx = btnPl:getChildByName("times_tx")
    if self.maxTimes then
        descTx:setString(GlobalApi:getLocalStr('ENTER_THE_NUM'))
        descTx1:setString(string.format(GlobalApi:getLocalStr('SHOP_DESC_6'),self.maxTimes))
        btnPl:setVisible(true)
        self.editbox = cc.EditBox:create(cc.size(130, 40), 'uires/ui/common/name_bg9.png')
        self.editbox:setPosition(self.timesTx:getPosition())
        self.editbox:setMaxLength(10)
        self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        btnPl:addChild(self.editbox)
        self.timesTx:setLocalZOrder(2)

        self.editbox:registerScriptEditBoxHandler(function(event,pSender)
            local edit = pSender
            local strFmt 
            if event == "began" then
                self.editbox:setText(self.times)
                self.timesTx:setString('')
            elseif event == "ended" then
                local num = tonumber(self.editbox:getText())
                if not num then
                    self.editbox:setText('')
                    self.timesTx:setString('1')
                    self.times = 0
                    return
                end
                local times = num
                if times > self.maxTimes then
                    self.times = self.maxTimes
                elseif times < 1 then
                    self.times = 0
                else
                    self.times = times
                end
                self.editbox:setText('')
                self:updatePanel()
            end
        end)
        self.lessBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.times > 1 then
                    self.times = self.times - 1
                    self:updatePanel()
                end
            end
        end)

        self.addBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.times < self.maxTimes then
                    self.times = self.times + 1
                    self:updatePanel()
                end
            end
        end)
    else
        btnPl:setVisible(false)
    end

    self:updatePanel()
    if self.sidebarList then
        UIManager:showSidebar(self.sidebarList[1],self.sidebarList[2])
    end

    if self.showType and self.showType == 'show_at_surprise_step' then
        descTx1:setVisible(false)
    end
end

return ShopTipsUI