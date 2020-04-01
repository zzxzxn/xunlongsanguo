local ShopUI = class("ShopUI", BaseUI)
local ClassSellTips = require('script/app/ui/tips/selltips')
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
    COUNTRYWARSHOP = 61,
    COUNTRYCITYCRAFTPOSITION = 71,
    COUNTRYCITYCRAFTSALARY = 72,
}

local SIDEBAR_LIST = {
    [11] = {{1},{6,2,3}},
    [12] = {{1},{6,2,3}},
    [13] = {{1},{6,2,3}},
    [21] = {{1},{8,2,3}},
    [22] = {{1},{8,2,3}},
    [31] = {{1},{7,2,3}},
    [32] = {{1},{7,2,3}},
    [41] = {{1},{10,2,3}},
    [51] = {{1},{9,2,3}},
    [52] = {{1},{9,2,3}},
    [53] = {{1},{12,2,3}},
    [54] = {{1},{13,2,3}},
    [61] = {{1},{24,2,3}},
    [71] = {{1},{25,3}},
    [72] = {{1},{25,3}},
}

function ShopUI:ctor(page,data,pageTab,custom,targetAward,targetNum,targetAwardIds)
	self.uiIndex = GAME_UI.UI_SHOP
    self.page = page or 1
    self.data = data
    self.pageTab = pageTab
    self.oldMaxFrame = 0
    self.custom = tonumber(custom) or 0
    -- self.intervalSize = 13.5
    self.isExpensive = 0
    self.cellNameTxs = {}
    self.targetFirst = true
    self.targetAward = targetAward
    self.targetNum = targetNum
    self.targetAwardIds = targetAwardIds
end

function ShopUI:updateTime()
    local time = MainSceneMgr.refreshIntervalTab[self.page]*3600
    local diffTime = time - (Time.getCorrectServerTime() - Time.beginningOfToday())%time
    if diffTime < 0 or self.page == SHOP_TYPE.MARKET then
        return
    end
    local label = self.panel1:getChildByTag(9999)
    local size = self.panel1:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 21)
    label:setTag(9999)
    label:setPosition(cc.p(size.width/2,size.height/2))
    label:setAnchorPoint(cc.p(0,0.5))
    self.panel1:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,CDTXTYPE.FRONT, GlobalApi:getLocalStr('REFRESH_TIME'),COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,21,function ()
        MainSceneMgr:shopGet(self.page,function(data)
            self.data = data.shop
            self.custom = data.maxStar or self.custom
            self:getGoodsIds()
            self:updatePanel()
            self:updatePageBtn(self.page)
        end)
    end)
end

function ShopUI:getTokenRes()
    local token = 0
    local res = ''
    local freeTimes = 0
    if self.page == SHOP_TYPE.MYSTERYSHOP then
        token = UserData:getUserObj():getMToken()
        freeTimes = UserData:getUserObj():getFreeMToken()
        print("freeTimes" ,freeTimes)
        res = 'uires/ui/res/res_m_token.png'
    elseif self.page == SHOP_TYPE.GODSHOP then
        token = UserData:getUserObj():getGToken()
        freeTimes = UserData:getUserObj():getFreeGToken()
        res = 'uires/ui/res/res_g_token.png'
    elseif self.page == SHOP_TYPE.MARKET then
        res = 'uires/ui/res/res_b_token.png'
    elseif self.page == SHOP_TYPE.TOWERSHOP or self.page == SHOP_TYPE.TOWERGEMSHOP then
        token = UserData:getUserObj():getTToken()
    elseif self.page == SHOP_TYPE.MILITARYSHOP then
        token = UserData:getUserObj():getRToken()
        res = 'uires/ui/res/res_r_token.png'
    elseif self.page == SHOP_TYPE.LISTSHOP then
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
    elseif self.page == SHOP_TYPE.WORLDWARSHOP then
    elseif self.page == SHOP_TYPE.LEGIONSHOP then
    end
    return token,res,freeTimes
end

function ShopUI:refresh()
    local function _refresh(args,tokenRes)
        MainSceneMgr:shopRefresh(self.page,args,function(data)
            self.data = data.shop
            self:getGoodsIds()
            self:updatePanel()
        end,tokenRes)
    end

    local tokenRes,res,freeTimes = self:getTokenRes()
    if freeTimes <= 0 then
        if tokenRes > 0 then
            _refresh({token = 1},tokenRes)
        else
            local cash = UserData:getUserObj():getCash()
            local needCash = MainSceneMgr.needCashTab[self.page]
            if cash < needCash then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
            else
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ARE_YOU_SURE_COST'),needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                    _refresh({},tokenRes)
                end)
            end
        end
    else
        _refresh({},tokenRes)
    end
    
end

function ShopUI:getIconRes(id)
    local tab = {}
    if id == 'soul' then
        tab.icon = 'uires/ui/res/res_soul.png'
        tab.num = UserData:getUserObj():getSoul()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_SOUL')
    elseif id == 'cash' then
        tab.icon = 'uires/ui/res/res_cash.png'
        tab.num = UserData:getUserObj():getCash()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
    elseif id == 'gold' then
        tab.icon = 'uires/ui/res/res_gold.png'
        tab.num = UserData:getUserObj():getGold()
        tab.desc = GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH')
    elseif id == 'arena' then
        tab.icon = 'uires/ui/res/res_arena.png'
        tab.num = UserData:getUserObj():getArena()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_ARENA')
    elseif id == 'tower' then
        tab.icon = 'uires/ui/res/res_tower.png'
        tab.num = UserData:getUserObj():getTower()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_TOWER')
    elseif id == 'legion' then
        tab.icon = 'uires/ui/res/res_legion.png'
        tab.num = UserData:getUserObj():getLegion()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_LEGION')
    elseif id == 'token' then
        tab.icon = 'uires/ui/res/res_token.png'
        tab.num = UserData:getUserObj():getToken()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_TOKEN')
    elseif id == 'legionwar' then
        tab.icon = 'uires/ui/res/res_legionwar.png'
        tab.num = UserData:getUserObj():getLegionwar()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_LEGIONWAR')
    elseif id == 'trial_coin' then
        tab.icon = 'uires/ui/res/res_trial_coin.png'
        tab.num = UserData:getUserObj():getTrialCoin()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_LEGIONTIRAL')
    elseif id == 'countrywar' then
        tab.icon = 'uires/ui/res/res_countrywar.png'
        tab.num = UserData:getUserObj():getCountryWar()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_COUNTRYWAR')
    elseif id == 'salary' then
        tab.icon = 'uires/ui/res/res_salary.png'
        tab.num = UserData:getUserObj():getSalary()
        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_COUNTRY_SALARY')
    end
    tab.id = id
    return tab
end

function ShopUI:setSidebar()
    UIManager:showSidebar(SIDEBAR_LIST[self.page][1],SIDEBAR_LIST[self.page][2])
end

function ShopUI:onShow()
    self:setSidebar()
end

function ShopUI:updateCellPanel()
    -- if self.page == SHOP_TYPE.GODSHOP then
        local refreshBtn = self.panel1:getChildByName("refresh_btn")
        local szBgImg = self.panel1:getChildByName("sz_bg_img")
        local szImg = szBgImg:getChildByName("sz_img")
        local szTx = szBgImg:getChildByName("sz_tx")
        local infoTx1 = refreshBtn:getChildByName("info_tx")
        infoTx1:setString(GlobalApi:getLocalStr('REFRESH_1'))
        refreshBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.isExpensive == 1 then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr('SHOP_DESC_2'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        self:refresh()
                    end)
                elseif self.isExpensive == 2 then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr('SHOP_DESC_3'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        self:refresh()
                    end)
                else
                    self:refresh()
                end
            end
        end)
    if self.page == SHOP_TYPE.LISTSHOP or self.page == SHOP_TYPE.TOWERSHOP or self.page == SHOP_TYPE.LEGIONDRESSSHOP 
        or self.page == SHOP_TYPE.MILITARYSHOP or self.page == SHOP_TYPE.TOWERGEMSHOP or self.page == SHOP_TYPE.COUNTRYWARSHOP
        or self.page == SHOP_TYPE.COUNTRYCITYCRAFTSALARY then
        self.panel1:setVisible(false)
    else
        local showTimeTx = false
        local showRichtext = false
        if self.page == SHOP_TYPE.WORLDWARSHOP then
            refreshBtn:setVisible(false)
            szBgImg:setVisible(false)
            self.descTx2:setVisible(false)
            self.descTx1:setVisible(true)
            self.descTx1:setString(GlobalApi:getLocalStr('SHOP_DESC_1'))
            showTimeTx = true
        elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
            refreshBtn:setVisible(false)
            szBgImg:setVisible(false)
            self.descTx1:setVisible(false)
            self.descTx2:setVisible(false)
            local richText = self.panel1:getChildByName('rich_text')
            if not richText then
	            richText = xx.RichText:create()
	            richText:setAlignment('middle')
	            richText:setVerticalAlignment('middle')
	            richText:setContentSize(cc.size(700, 30))
	            local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHOP_DESC_15'),20,COLOR_TYPE.WHITE)
	            local re2 = xx.RichTextLabel:create(GlobalApi:getGlobalValue("resetHour")..':00',20,COLOR_TYPE.GREEN)
	            local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES4'),20,COLOR_TYPE.WHITE)
	            re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	            re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
	            re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	            richText:addElement(re1)
	            richText:addElement(re2)
	            richText:addElement(re3)
	            richText:setName('rich_text')
	            richText:setAnchorPoint(cc.p(0.5,0.5))
	            richText:setPosition(cc.p(420,40))
	            self.panel1:addChild(richText)
	        end
            showRichtext = true
        elseif self.page == SHOP_TYPE.MARKET then
            refreshBtn:setVisible(false)
            szBgImg:setVisible(false)
            self.descTx1:setVisible(false)
            self.descTx2:setVisible(true)
            self.descTx2:setString(GlobalApi:getLocalStr('SHOP_DESC_4'))
        else
            refreshBtn:setVisible(true)
            szBgImg:setVisible(true)
            self.descTx1:setVisible(false)
            self.descTx2:setVisible(false)
            showTimeTx = true
        end
        if not showTimeTx then
            local timeTx = self.panel1:getChildByTag(9999)
            if timeTx then
                timeTx:removeFromParent()
            end
        end
        if not showRichtext then
	        local richText = self.panel1:getChildByName('rich_text')
	        if richText then
	            richText:removeFromParent()
	        end
        end
        self.panel1:setVisible(true)
        local token,res,freeTimes = self:getTokenRes()
        local needCash = 0
        -- if self.page == SHOP_TYPE.BLACKSHOP then
        --     local conf = GameData:getConfData('buy')
        --     if not conf[self.data.count + 1] then
        --         needCash = conf[#conf].blackShopRefresh
        --     else
        --         needCash = conf[self.data.count + 1].blackShopRefresh
        --     end
        -- else
            needCash = MainSceneMgr.needCashTab[self.page]
        -- end
        --SHOP_DESC_14
        if freeTimes <= 0 then
            if token > 0 then
                szTx:setString(token)
                szImg:loadTexture(res)
            else
                szTx:setString(needCash)
                szImg:loadTexture('uires/ui/res/res_cash.png')
            end
            refreshBtn:setPositionX(755.00)
        else
            local str = string.format(GlobalApi:getLocalStr("SHOP_DESC_14"),freeTimes)
            szTx:setString(str)
            szImg:loadTexture(res)
            refreshBtn:setPositionX(765.00)
        end
        szImg:ignoreContentAdaptWithSize(true)
    
        if self.page == SHOP_TYPE.GODSHOP then
            local times = MainSceneMgr:getRefreshTimes(self.page)
            local size = self.panel1:getContentSize()
            local tx1 = GlobalApi:getLocalStr('RESCP_DESC2')
            local tx2 = times - self.data.count
            local tx3 = GlobalApi:getLocalStr('TIMES')
            if not self.timesRt then
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(230, 30))
                local re1 = xx.RichTextLabel:create(tx1,21,COLOR_TYPE.ORANGE)
                local re2 = xx.RichTextLabel:create(tx2,21,COLOR_TYPE.WHITE)
                local re3 = xx.RichTextLabel:create(tx3,21,COLOR_TYPE.ORANGE)
                re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                re2:setStroke(COLOR_TYPE.BLACK, 1)
                re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:addElement(re3)
                --richText:formatText()
                richText:setAnchorPoint(cc.p(0,0.5))
                richText:setPosition(cc.p(100,size.height/2))
                self.panel1:addChild(richText)
                self.timesRt = {richText = richText,re2 = re2,re1 = re1,re3 = re3}
            else
                self.timesRt.richText:setVisible(true)
                self.timesRt.re1:setString(tx1)
                self.timesRt.re2:setString(tx2)
                self.timesRt.re3:setString(tx3)
                self.timesRt.richText:format(true)
            end
        else
            if self.timesRt then
                self.timesRt.richText:setVisible(false)
            end
        end
    end
end

function ShopUI:setBtnTouch(b)
    for i=1,self.currMax do
        local cell = self.cellSv:getChildByTag(i + 100)
        if cell then
            local cellBgImg = cell:getChildByName('shop_bg_img')
            for j=1,2 do
                local cellImg = cellBgImg:getChildByName('cell_'..j..'_img')
                local buyBtn = cellImg:getChildByName('buy_btn')
                local goods = self.goodsIds[(i-1)*2+j]
                local status = goods.status
                buyBtn:setTouchEnabled(b == true and status == 0)
            end
        end

    end
end

function ShopUI:setBright(cell,b,award,isLockVisible)
    local awardBgImg = cell:getChildByName('award_bg_img')
    local awardImg = awardBgImg:getChildByName('award_img')
    local chipImg = awardBgImg:getChildByName('chip_img')
    local upImg = awardBgImg:getChildByName('up_img')
    local fireImg = cell:getChildByName('fire_img')

    local buyBtn = cell:getChildByName('buy_btn')
    local priceTx = buyBtn:getChildByName('price_tx')
    local bg_icon = buyBtn:getChildByName('bg_icon')
    local szIcon = buyBtn:getChildByName('sz_icon')
    if b == false then
        ShaderMgr:setGrayForWidget(awardBgImg)
        ShaderMgr:setGrayForWidget(awardImg)
        ShaderMgr:setGrayForWidget(chipImg)
        ShaderMgr:setGrayForWidget(upImg)
        ShaderMgr:setGrayForWidget(fireImg)
        ShaderMgr:setGrayForWidget(szIcon)
        ShaderMgr:setGrayForWidget(bg_icon)
        buyBtn:setBright(false)
        buyBtn:setTouchEnabled(false)
        priceTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,2)
        priceTx:setColor(COLOR_TYPE.WHITE)
        ClassItemCell:setGodLight(awardBgImg,0)
        award:setLightEffect(awardBgImg,0)
    else
        ShaderMgr:restoreWidgetDefaultShader(awardBgImg)
        ShaderMgr:restoreWidgetDefaultShader(awardImg)
        ShaderMgr:restoreWidgetDefaultShader(chipImg)
        ShaderMgr:restoreWidgetDefaultShader(upImg)
        ShaderMgr:restoreWidgetDefaultShader(fireImg)
        ShaderMgr:restoreWidgetDefaultShader(szIcon)
        ShaderMgr:restoreWidgetDefaultShader(bg_icon)
        buyBtn:setBright(true)
        buyBtn:setTouchEnabled(true)
        priceTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,2)
        priceTx:setColor(COLOR_TYPE.WHITE)
        award:setLightEffect(awardBgImg)
    end
end

function ShopUI:fly(award,index,index1)
    local cell = self.cellSv:getChildByTag(index + 100)
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, self.flyBgImg)
    tab.awardBgImg:setTouchEnabled(false)
    local num = ((award:getCategory() == 'equip') and award:getLevel()) or award:getNum()
    if award:getCategory() == 'equip' then
        tab.lvTx:setString('Lv.'..num)
    else
        tab.lvTx:setString('x'..num)
    end
    tab.awardImg:ignoreContentAdaptWithSize(true)
    award:setLightEffect(tab.awardBgImg)

    local winSize = cc.Director:getInstance():getVisibleSize()
    local shopImgSize = self.shopImg:getContentSize()
    local neiBgImgSize = self.neiBgImg:getContentSize()
    local cellBgImg = cell:getChildByName('shop_bg_img')
    local cellBgSize = cellBgImg:getContentSize()
    local cellImg = cellBgImg:getChildByName('cell_'..index1..'_img')
    local cellImgSize = cellImg:getContentSize()
    local awardBgImg = cellImg:getChildByName('award_bg_img')
    local awardBgSize = awardBgImg:getContentSize()
    local pos = self.cellSv:getInnerContainerPosition()
    local posX = self.shopImg:getPositionX() - shopImgSize.width/2 +
                 self.neiBgImg:getPositionX() - neiBgImgSize.width/2 + 
                 cell:getPositionX() +
                 cellImg:getPositionX() - cellImgSize.width/2 + 
                 awardBgImg:getPositionX() + pos.x + 6

    local posY = self.shopImg:getPositionY() - shopImgSize.height/2 + 
                 self.neiBgImg:getPositionY() - neiBgImgSize.height/2 + 
                 cell:getPositionY() +
                 cellImg:getPositionY() - cellImgSize.height/2 + 
                 awardBgImg:getPositionY() + pos.y + 6
                 
    tab.awardBgImg:setPosition(cc.p(posX,posY))
    tab.awardBgImg:setScale(1)
    
    if self.page ~= SHOP_TYPE.MILITARYSHOP 
        and self.page ~= SHOP_TYPE.LEGIONDRESSSHOP 
        and self.page ~= SHOP_TYPE.MARKET
        and self.page ~= SHOP_TYPE.COUNTRYWARSHOP
        and self.page ~= SHOP_TYPE.COUNTRYCITYCRAFTSALARY
        and self.page ~= SHOP_TYPE.TOWERGEMSHOP then
        self:setBright(cellImg,false,award)
    end
    
    tab.awardBgImg:runAction(
        cc.Sequence:create(cc.ScaleTo:create(0.1, 1.6),
        cc.ScaleTo:create(0.1, 1.1),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            local isHide = UIManager:getIsHide()
            tab.awardBgImg:runAction(cc.MoveTo:create(0.5,cc.p(winSize.width - 55 - ((isHide == true and 0) or 1)*220, 55)))
            tab.awardBgImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,0.1),cc.CallFunc:create(function()
                tab.awardBgImg:removeFromParent()
                self:updatePanel()
            end)))
        end))
        )
end

function ShopUI:buy(index,index1,callback,num,cash)
    local i = (index-1)*2+index1
    local conf
    if self.page == SHOP_TYPE.LISTSHOP then
        conf = GameData:getConfData('arenarank')
    elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
        conf = GameData:getConfData('dress')
    elseif self.page == SHOP_TYPE.TOWERSHOP then
        conf = GameData:getConfData('towerstarshop')
    elseif self.page == SHOP_TYPE.MARKET then
        conf = GameData:getConfData('market')
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
        conf = GameData:getConfData('positionshop')
    else
        conf = GameData:getConfData("shop")
    end

    local award
    local goods = self.goodsIds[i]
    local good
    local status = goods.status
    local cost
    local lid
    local rid
    local level = 0
    if self.page == SHOP_TYPE.LISTSHOP then
        good = conf[goods.id].award[1]
        lid = conf[goods.id].cost[1][2]
        level = conf[goods.id].count
        rid = goods.id
        cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
        good = conf[goods.id].award[1]
        lid = conf[goods.id].cost[1][2]
        level = conf[goods.id].position
        rid = goods.id
        cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
    elseif self.page == SHOP_TYPE.TOWERSHOP then
        good = conf[goods.id].award[1]
        lid = conf[goods.id].cost[1][2]
        level = conf[goods.id].starNum
        rid = goods.id
        cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
    elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
        local dress = BagData:getDressByIdForShop(goods.id)
        -- good = conf[goods.id].award[1]
        good = {'dress',goods.id,1}
        rid = goods.id
        lid = 5
        cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
    elseif self.page == SHOP_TYPE.MARKET then
        good = conf[goods.id].award[1]
        local vip = UserData:getUserObj():getVip()
        local price = 0
        status = 1
        for k=1,5 do
            local times = conf[goods.id]['time'..k]
            if times == 0 then
                price = conf[goods.id].originPrice
                status = 0
            elseif goods.count < times then
                price = conf[goods.id]['price'..k]
                status = 0
            end
        end
        rid = goods.id
        cost = DisplayData:getDisplayObj({'user','cash',price})
    else
        rid = goods.rid
        lid = goods.lid
        good = conf[rid]['get'][1]
        cost = DisplayData:getDisplayObj(conf[rid]['cost'..lid][1])
    end

    if goods.eid then
        award = DisplayData:getDisplayObj({'equip',goods.eid,goods.godid,1})
        -- self.flyImgs.flyAwardBgImg:loadTexture(award:getBgImg())
    else
        award = DisplayData:getDisplayObj(good)
        -- self.flyImgs.flyAwardBgImg:loadTexture(award:getBgImg())
    end
    -- local cost = DisplayData:getDisplayObj(good)
    local isEquip = (award:getType() == 'equip')
    if isEquip == true then
        if BagData:getEquipFull() then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
            return
        end
    end
    local function _buy(i)
        if callback then
            callback()
        end
        MainSceneMgr:shopBuy(self.page,{id = rid,num = num},function()
            if self.page ~= SHOP_TYPE.MILITARYSHOP 
                and self.page ~= SHOP_TYPE.LEGIONDRESSSHOP
                and self.page ~= SHOP_TYPE.MARKET
                and self.page ~= SHOP_TYPE.COUNTRYWARSHOP
                and self.page ~= SHOP_TYPE.COUNTRYCITYCRAFTSALARY
                and self.page ~= SHOP_TYPE.TOWERGEMSHOP then
                self.goodsIds[i].status = 1
            elseif self.page == SHOP_TYPE.MARKET then
                self.goodsIds[i].count = (self.goodsIds[i].count or 0) + num
            end

            if self.page == SHOP_TYPE.MYSTERYSHOP then
                local num = 0
                for i,v in ipairs(self.goodsIds) do
                    if v.status == 1 then
                        num = num + 1
                    end
                end
                if num >= #self.goodsIds then
                    MainSceneMgr:shopGet(11,function(data,page)
                        self.page = page
                        self.data = data.shop
                        self.custom = data.maxStar or self.custom
                        self:getGoodsIds()
                        self:updatePanel()
                        self:updatePageBtn(self.page)
                    end)
                end
            end

            -- 购买逻辑错误
            -- if self.page == SHOP_TYPE.LISTSHOP then
            --     ArenaMgr.arenaData.shop[tostring(rid)] = 1
            -- end

            self:updatePanel()
            self:updateSigns()
            self:fly(award,index,index1)
        end)
    end

    local tab = self:getIconRes(cost:getUserId())
    local needNum = cash or cost:getNum()
    if needNum > tab.num then
        local function goto(lid)
            if not lid or lid == 2 then
                -- TODO
                -- promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CASH_NOT_ENOUGH'),1000,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                --     GlobalApi:getGotoByModule(cost:getUserId())
                -- end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                UserData:getUserObj():cost('cash',needNum,function()
                    GlobalApi:getGotoByModule(cost:getUserId())
                end)     
            else
                promptmgr:showSystenHint(tab.desc, COLOR_TYPE.RED)
            end
        end
        self.imgs[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,2),cc.ScaleTo:create(0.15,1),cc.CallFunc:create(function()
            goto(lid)
        end)))
        return
    elseif self.page == SHOP_TYPE.LISTSHOP and self.custom > level then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_ARENA_RANK'), COLOR_TYPE.RED)
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION and self.custom > level then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_POSITION'), COLOR_TYPE.RED)
    elseif self.page == SHOP_TYPE.TOWERSHOP and self.custom < level then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_TOWER_STAR'), COLOR_TYPE.RED)
    else
        if lid == 2 then
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('COST_CASH_TO_BUY'),needNum,award:getName()..award:getNum()), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                _buy(i)
            end)
        else
            _buy(i)
        end
    end
end

function ShopUI:setInnerContainerPositon()
    if self.targetIndex <= 3 then
    elseif self.currMax - self.targetIndex <= 3 then
        self.cellSv:jumpToRight()
    elseif self.targetIndex > 3 then
        local innerContainer = self.cellSv:getInnerContainer()
        innerContainer:setPositionX(-(self.targetSize.width + self.intervalSize)*(self.targetIndex - 1))
    end
    self.targetIndex = nil
    self.targetSize = nil
end

function ShopUI:updateCell()
    local conf
    print("SHOP_TYPE:"..self.page)
    if self.page == SHOP_TYPE.LISTSHOP then
        conf = GameData:getConfData('arenarank')
    elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
        conf = GameData:getConfData('dress')
    elseif self.page == SHOP_TYPE.TOWERSHOP then
        conf = GameData:getConfData('towerstarshop')
    elseif self.page == SHOP_TYPE.MARKET then
        conf = GameData:getConfData('market')
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
        conf = GameData:getConfData('positionshop')
    else
        conf = GameData:getConfData("shop")
    end
    local size
    local function getPos(i)
        return cc.p((i-1)*(self.intervalSize + size.width) + self.intervalSize,5)
    end
    self.currMax = ((#self.goodsIds - 1) - (#self.goodsIds - 1)%2)/2 + 1
    self.imgs = {}
    for i=1,self.currMax do
        local cell = self.cellSv:getChildByTag(i + 100)
        local cellBgImg
        if not cell then
            local cellNode = cc.CSLoader:createNode("csb/shopcell.csb")
            cellBgImg = cellNode:getChildByName('shop_bg_img')
            cellBgImg:removeFromParent(false)
            cell = ccui.Widget:create()
            cell:setName("shopcell_" .. i)
            cell:addChild(cellBgImg)
            self.singleSize = size
            self.cellSv:addChild(cell,1,i + 100)
        else
            cellBgImg = cell:getChildByName("shop_bg_img")
        end
        size = cellBgImg:getContentSize()
        cell:setPosition(getPos(i))
        cell:setVisible(true)
        for j=1,2 do
            local cellImg = cellBgImg:getChildByName('cell_'..j..'_img')
            local awardBgImg = cellImg:getChildByName('award_bg_img')
            local size = cellImg:getContentSize()
            if not awardBgImg then
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
                tab.awardImg:ignoreContentAdaptWithSize(true)
                awardBgImg = tab.awardBgImg
                awardBgImg:setTouchEnabled(false)
                awardBgImg:setPosition(cc.p(size.width/2,95))
                awardBgImg:setScale(0.9)
                tab.nameTx:setPosition(cc.p(47,110))
                cellImg:addChild(awardBgImg)
            end
            cellImg:setVisible(true)
            local nameTx = awardBgImg:getChildByName('name_tx')
            local numTx = awardBgImg:getChildByName('lv_tx')
            local upImg = awardBgImg:getChildByName('up_img')

            local buyBtn = cellImg:getChildByName('buy_btn')
            local lockTx = buyBtn:getChildByName('lock_tx')
            local szIcon = buyBtn:getChildByName('sz_icon')
            local bg_icon = buyBtn:getChildByName('bg_icon')
            local priceTx = buyBtn:getChildByName('price_tx')
            local fireImg = cellImg:getChildByName('fire_img')
            local itemPl = cellImg:getChildByName('item_pl')
			local soliderImg = cellImg:getChildByName('solider_img')
            itemPl:setLocalZOrder(9999)

            local index = (i-1)*2+j
            self.imgs[index] = priceTx
            local goods = self.goodsIds[index]
            if not goods then
                cellImg:setVisible(false)
                break
            end
            local good
            local status = goods.status
            local cost
            local level = 0
            local count = nil
            local minCount = nil
            local maxCount = nil
            local needCash = nil
            local isLockVisible = false
			if soliderImg then
				soliderImg:setVisible(false)
			end
            if self.page == SHOP_TYPE.LISTSHOP then
                good = conf[goods.id].award[1]
                level = conf[goods.id].count
                cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
                if level == 0 or self.custom == 0 then
                    lockTx:setString('')
                else
                    if self.custom <= level then
                        lockTx:setString('')
                    else
                        local str = string.format(GlobalApi:getLocalStr('UNLOCK_ARENA'),level)
                        lockTx:setString((self.page == SHOP_TYPE.LISTSHOP and str) or '')
                        isLockVisible = true
                    end
                end
                fireImg:setVisible(false)
            elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
                good = conf[goods.id].award[1]
                level = conf[goods.id].position
                cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
                if self.custom < 0 then
                    lockTx:setString('')
                else
                    if self.custom <= level then
                        lockTx:setString('')
                    else
                    	local positionConf = GameData:getConfData('position')
                    	local str = ''
                    	if level == 0 then
                    		str = GlobalApi:getLocalStr('STR_OFFICE_DESC_6')
                    	else
	                    	for i,v in ipairs(positionConf) do
	                    		if v.position == level then
	                    			str = v.posName
	                    			break
	                    		end
	                    	end
	                    	str = string.format(GlobalApi:getLocalStr('STR_OFFICE_DESC_5'),str)
	                    end
                        lockTx:setString((self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION and str) or '')
                        isLockVisible = true
                    end
                end
                fireImg:setVisible(false)
            elseif self.page == SHOP_TYPE.TOWERSHOP then
                good = conf[goods.id].award[1]
                level = conf[goods.id].starNum
                cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
                if level == 0 then
                    lockTx:setString('')
                else
                    if self.custom >= level then
                        lockTx:setString('')
                    else
                        local str = string.format(GlobalApi:getLocalStr('UNLOCK_TOWER'),level)
                        lockTx:setString((self.page == SHOP_TYPE.TOWERSHOP and str) or '')
                        isLockVisible = true
                    end
                end
                fireImg:setVisible(false)
            elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
                local dress = BagData:getDressByIdForShop(goods.id)
                good = {'dress',goods.id,1}
                cost = DisplayData:getDisplayObj(conf[goods.id].cost[1])
                lockTx:setString('')
                fireImg:setVisible(false)
            elseif self.page == SHOP_TYPE.MARKET then
                fireImg:setLocalZOrder(999)
                local infoTx = fireImg:getChildByName('info_tx')
                good = conf[goods.id].award[1]
                local vip = UserData:getUserObj():getVip()
                local price = 0
                local currCount = goods.count + 1
                local maxNum = tonumber(GlobalApi:getGlobalValue('marketPriceCount'))
                for k=1,maxNum do
                    local times,times1 = conf[goods.id]['time'..k],conf[goods.id]['time'..(k + 1)]
                    maxCount = conf[goods.id]['vip'..vip]
                    if times == 0 and k == 1 then
                        price = conf[goods.id].originPrice
                        minCount = nil
                        break
                    elseif not times1 or times1 == 0 then
                        price = conf[goods.id]['price'..k]
                        minCount = conf[goods.id]['vip'..vip] - goods.count
                        break
                    elseif currCount >= times and currCount < times1 then
                        price = conf[goods.id]['price'..k]
                        minCount = conf[goods.id]['vip'..vip] - goods.count
                        break
                    end
                end
                if minCount then
                    fireImg:setVisible(conf[goods.id].originPrice > price)
                    if minCount > 0 then
                        status = 0
                    else
                        status = 1
                    end
                else
                    fireImg:setVisible(false)
                    status = 0
                end
                lockTx:setString('')
                infoTx:setString(GlobalApi:roundOff(price/conf[goods.id].originPrice*10, 1)..GlobalApi:getLocalStr('STR_ZHE'))
                cost = DisplayData:getDisplayObj({'user','cash',price})
                needCash = price
            elseif self.page == SHOP_TYPE.GODSHOP then
                local rid = goods.rid
                local lid = goods.lid
                good = conf[rid]['get'][1]
                cost = DisplayData:getDisplayObj(conf[rid]['cost'..lid][1])
                lockTx:setString('')

                fireImg:setLocalZOrder(999)
                local infoTx = fireImg:getChildByName('info_tx')
                infoTx:setString(GlobalApi:getLocalStr('SHOP_RECOMMOND'))
                if (good[1] == 'fragment') or (good[1] == 'card') then
                    if UserData:getUserObj():judgeIsHasRoleOrSpecialFate(good[2]) == true then
                        fireImg:setVisible(true)
                    else
                        fireImg:setVisible(false)
                    end
                else
                    fireImg:setVisible(false)
                end

				if not soliderImg then
					local soliderImg = ccui.ImageView:create()
					soliderImg:setLocalZOrder(9999)
					soliderImg:setScale(0.6)
					soliderImg:setPosition(cc.p(99,72))
					soliderImg:setName('solider_img')
					cellImg:addChild(soliderImg)
				end
				local soliderImg = cellImg:getChildByName('solider_img')
				if (good[1] == 'fragment') or (good[1] == 'card') then  --神将或碎片
					soliderImg:setVisible(true)
					local data = GameData:getConfData('hero')[tonumber(good[2])]
					soliderImg:loadTexture('uires/ui/common/'..'soldier_'..data.soldierId ..'.png')
				else    --道具
					soliderImg:setVisible(false)
				end
			elseif self.page == SHOP_TYPE.LEGIONWARSHOP then
				fireImg:setVisible(false)
                local rid = goods.rid
                local lid = goods.lid
                good = conf[rid]['get'][1]
                cost = DisplayData:getDisplayObj(conf[rid]['cost'..lid][1])
                lockTx:setString('')

				if not soliderImg then
					local soliderImg = ccui.ImageView:create()
					soliderImg:setLocalZOrder(9999)
					soliderImg:setScale(0.6)
					soliderImg:setPosition(cc.p(99,72))
					soliderImg:setName('solider_img')
					cellImg:addChild(soliderImg)
				end
				local soliderImg = cellImg:getChildByName('solider_img')
				if (good[1] == 'fragment') or (good[1] == 'card') then
					soliderImg:setVisible(true)
					local data = GameData:getConfData('hero')[tonumber(good[2])]
					soliderImg:loadTexture('uires/ui/common/'..'soldier_'..data.soldierId ..'.png')
				else
					soliderImg:setVisible(false)
				end
            else
                fireImg:setVisible(false)
                local rid = goods.rid
                local lid = goods.lid
                good = conf[rid]['get'][1]
                cost = DisplayData:getDisplayObj(conf[rid]['cost'..lid][1])
                lockTx:setString('')
            end
            buyBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                    szIcon:setScale(1.3)
                elseif eventType == ccui.TouchEventType.moved then
                    szIcon:setScale(1.3)
                elseif eventType == ccui.TouchEventType.canceled then
                    szIcon:setScale(1.2)
                elseif eventType == ccui.TouchEventType.ended then
                    self:buy(i,j,nil,1,needCash)
                    szIcon:setScale(1.2)
                end
            end)
            local award
            local num = 0
            local name = ''
            local nameColor
            local nameOutline
            if goods.eid then
                award = DisplayData:getDisplayObj({'equip',goods.eid,goods.godid,1})
                local isUp = false
                local equipObj = award:getObj()
                for i=1,RoleData:getRoleNum() do
                    local roleObj = RoleData:getRoleByPos(i)
                    if roleObj and roleObj:getId() > 0 then
                        local eauiped = roleObj:getEquipByIndex(tonumber(equipObj:getType()))
                        if eauiped then
                            local up = GlobalApi:getProFightForce(equipObj,eauiped,tonumber(equipObj:getQuality()) - 1)
                            local diffLevel = tonumber(equipObj:getLevel()) - UserData:getUserObj():getLv()
                            isUp = up and (diffLevel <= 10)
                            if isUp then
                                break
                            end
                        else
                            isUp = true
                            break
                        end
                    end
                end
                upImg:setVisible(isUp)
                ClassItemCell:setGodLight(awardBgImg,award:getGodId())
            else
                award = DisplayData:getDisplayObj(good)
                upImg:setVisible(false)
                ClassItemCell:setGodLight(awardBgImg,award:getGodId())
            end
            ClassItemCell:updateItem(awardBgImg, award, 3)      --神将商店卡不用加阵营图标,所以传3
            name,nameColor,nameOutline = award:getName(),award:getNameColor(),award:getNameOutlineColor()
            num = ((good[1] == 'equip') and award:getLevel()) or award:getNum()
            if good[1] == 'fragment' and award:getQuality() >= 6 and status == 0 then
                self.isExpensive = 2
            elseif good[1] == 'card' and status == 0 then
                self.isExpensive = 1
            end

            if self.page == SHOP_TYPE.MARKET then
                if not self.cellNameTxs[tostring(i..'_'..j)] then
                    local richText = xx.RichText:create()
                    richText:setPosition(cc.p(47,110))
                    richText:setContentSize(cc.size(250, 40))
                    richText:setAlignment('middle')
                    richText:setVerticalAlignment('middle')
                    local re1 = xx.RichTextLabel:create(name,25,nameColor)
                    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                    local re2 = xx.RichTextLabel:create('('..minCount..'/'..maxCount..')', 25, COLOR_TYPE.WHITE)
                    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                    richText:addElement(re1)
                    richText:addElement(re2)
                    awardBgImg:addChild(richText)
                    self.cellNameTxs[tostring(i..'_'..j)] = {richText = richText,re1 = re1,re2 = re2}
                else
                    self.cellNameTxs[tostring(i..'_'..j)].re1:setString(name)
                    self.cellNameTxs[tostring(i..'_'..j)].re2:setString('('..minCount..'/'..maxCount..')')
                    self.cellNameTxs[tostring(i..'_'..j)].richText:format(true)
                end
                self.cellNameTxs[tostring(i..'_'..j)].richText:setVisible(true)
                nameTx:setString('')
            else
                nameTx:setString(name)
                nameTx:enableOutline(nameOutline,1)
                nameTx:setColor(nameColor)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                if self.cellNameTxs[tostring(i..'_'..j)] then
                    self.cellNameTxs[tostring(i..'_'..j)].richText:setVisible(false)
                end
            end
            if good[1] == 'equip' then
                numTx:setString('Lv.'..num)
            else
                numTx:setString('x'..num)
            end
            award:setLightEffect(awardBgImg)

            local costNum = cost:getNum()
            local tab = self:getIconRes(cost:getUserId())
            tab.sellNum = good[3]
            tab.costNum = costNum
            tab.confId = goods.id
            szIcon:loadTexture(tab.icon)
            szIcon:ignoreContentAdaptWithSize(true)
            priceTx:setString(costNum)
            self:setBright(cellImg,status == 0,award,isLockVisible)
            szIcon:setScale(1.2)
            if isLockVisible then
                bg_icon:setVisible(false)
                szIcon:setVisible(false)
                priceTx:setVisible(false)
            else
                bg_icon:setVisible(true)
                szIcon:setVisible(true)
                priceTx:setVisible(true)
            end
            lockTx:setColor(COLOR_TYPE.WHITE)
            lockTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
            lockTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            if status == 0 then
                if tab.num < costNum then
                    priceTx:enableOutline(COLOROUTLINE_TYPE['RED'],1)
                    priceTx:setColor(COLOR_TYPE['RED'])
                    priceTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                else
                    priceTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
                    priceTx:setColor(COLOR_TYPE.WHITE)
                    priceTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                end
            end

            local function gotoBuy()
                local status = self.goodsIds[index].status
                if (self.page == SHOP_TYPE.MARKET 
                	or self.page == SHOP_TYPE.LEGIONDRESSSHOP 
                	or self.page == SHOP_TYPE.COUNTRYCITYCRAFTSALARY) and not minCount then
                    minCount = 999
                end
                self:showTips(award,tab,status,function(callback,num,cash)
                    self:buy(i,j,callback,num,cash)
                end,SIDEBAR_LIST[self.page],minCount)
            end
            if self.targetAward and self.targetAward:getId() == award:getId() then
                local descTx = itemPl:getChildByName('desc_tx')
                local numTx = itemPl:getChildByName('num_tx')
                descTx:setString(GlobalApi:getLocalStr('SHOP_DESC_7'))
                local obj = BagData:getBagobjByObj(self.targetAward)
                numTx:setString(obj:getNum()..'/'..self.targetNum)
                if self.targetFirst then
                    gotoBuy()
                    self.targetFirst = false
                end
                self.targetIndex = i
                self.targetSize = size
            else
                itemPl:setVisible(false)
                if self.targetAwardIds then
                    local isHad = false
                    if type(self.targetAwardIds) == 'table' then
                        for i,v in ipairs(self.targetAwardIds) do
                            if award:getObjType() == 'material' and award:getId() == v then
                                isHad = true
                                break
                            end
                        end
                    elseif type(self.targetAwardIds) == 'number' or type(self.targetAwardIds) == 'string' then
                        if self.targetAwardIds == award:getId() then
                            isHad = true
                        end
                    end
                    if isHad then
                        gotoBuy()
                        self.targetIndex = i
                        self.targetSize = size
                        self.targetAwardIds = nil
                    end
                end
            end

            GlobalApi:regiesterBtnHandler(cellImg,function()
                gotoBuy()
            end)
        end
    end
    self:updateCellPanel()
    self:updateTime()
end

function ShopUI:updatePanel()
    self.isExpensive = 0
    self.currMax = 0
    self:updateCell()

    if self.currMax ~= self.oldMaxFrame then
        local size = self.cellSv:getContentSize()
        -- if self.currMax * (self.singleSize.width + self.intervalSize) + 10 > size.width then
        if self.currMax > 3 then
            self.cellSv:setInnerContainerSize(cc.size(self.currMax*self.singleSize.width + (self.currMax - 1)*self.intervalSize + 10,size.height))
        else
            self.cellSv:setInnerContainerSize(size)
        end
    end
    
    if self.targetIndex and self.targetSize then
        self:setInnerContainerPositon()
    end

    if self.currMax < self.oldMaxFrame then
        for i=self.currMax + 1,self.oldMaxFrame do
            local awardBgImg = self.cellSv:getChildByTag(i + 100)
            if awardBgImg then
                awardBgImg:setVisible(false)
            end
        end
    end
    self.oldMaxFrame = self.currMax
    self:setSidebar()
end

function ShopUI:getGoods()
    local num = RoleData:getRoleNum()
    local temp = {}
    local levelTab = {}
    local maxNum = 0
    for i=1,7 do
        local role = RoleData:getRoleByPos(i)
        if role:getId() > 0 then
            local soldierArr = role:getSoldierArmArr()
            levelTab[i] = {i,role:getSoldierLv()}
            for j=1,6 do
                local equiped = role:getSoldierdress(j)
                if equiped ~= 1 then
                    if temp[soldierArr[j].id] == nil then
                        maxNum = maxNum + 1
                    end
                    temp[soldierArr[j].id] = 1
                end
            end
        end
    end
    if maxNum < 6 or maxNum%2 == 1 then
        table.sort(levelTab, function(a,b)
            return a[1] > b[1]
        end )
        for i,v in ipairs(levelTab) do
            local role = RoleData:getRoleByPos(v[1])
            local soldierArr = role:getSoldierArmArr()
            for j=1,6 do
                local equiped = role:getSoldierdress(j)
                if equiped == 1 and temp[soldierArr[j].id] == nil then
                    temp[soldierArr[j].id] = 1
                    maxNum = maxNum + 1
                end
                if maxNum >= 6 and maxNum%2 == 0 then
                    break
                end
            end
        end
    end
    for k,v in pairs(temp) do
        self.goodsIds[#self.goodsIds + 1] = {status = 0 ,id = tonumber(k)}
    end
    local function sortFn(a,b)
        local a1 = math.floor(a.id/100)
        local a2 = a.id%100 - a.id%10
        local a3 = a.id%10
        local b1 = math.floor(b.id/100)
        local b2 = b.id%100 - b.id%10
        local b3 = b.id%10
        if a2 == b2 then
            if a1 == b1 then
                return a3 < b3
            end
            return a1 < b1
        end
        return a2 < b2
    end
    table.sort(self.goodsIds,sortFn)
end

function ShopUI:getGoodsIds()
    self.goodsIds = {}
    local function sortFn(a,b)
        if a.status == b.status then
            if self.custom <= a.count and self.custom <= b.count then
                return a.count > b.count
            end
            if self.custom > a.count and self.custom > b.count then
                return a.count > b.count
            end
            if self.custom <= a.count then
                return true
            end
            if self.custom <= b.count then
                return false
            end
            return true
        end
        return a.status == 0
    end
    local function sortFn1(a,b)
        if a.status == b.status then
            if self.custom <= a.count and self.custom <= b.count then
                return a.count < b.count
            end
            if self.custom > a.count and self.custom > b.count then
                return a.count < b.count
            end
            if self.custom <= a.count then
                return false
            end
            if self.custom <= b.count then
                return true
            end
            return true
        end
        return a.status == 0
    end
    if self.page == SHOP_TYPE.LISTSHOP then
        local conf = GameData:getConfData('arenarank')
        for i,v in ipairs(conf) do
            self.goodsIds[#self.goodsIds + 1] = {status = self.data[tostring(i)] or 0,
            eid = ((#v.award == 4 )and v.award[2]) or nil,count = tonumber(v.count),
            id = v.id}
        end
        table.sort(self.goodsIds,sortFn)
    elseif self.page == SHOP_TYPE.COUNTRYCITYCRAFTPOSITION then
        local conf = GameData:getConfData('positionshop')
        for i,v in ipairs(conf) do
            self.goodsIds[#self.goodsIds + 1] = {status = self.data[tostring(i)] or 0,
            eid = ((#v.award == 4 )and v.award[2]) or nil,count = tonumber(v.position),
            id = v.id}
        end
        table.sort(self.goodsIds,sortFn)
    elseif self.page == SHOP_TYPE.TOWERSHOP then
        local conf = GameData:getConfData('towerstarshop')
        for i,v in ipairs(conf) do
            self.goodsIds[#self.goodsIds + 1] = {status = self.data[tostring(i)] or 0,count = v.starNum,id = v.id}
        end
        table.sort(self.goodsIds,sortFn1)
    elseif self.page == SHOP_TYPE.MARKET then
        local conf = GameData:getConfData('market')
        local lv = UserData:getUserObj():getLv()
        for i,v in ipairs(conf) do
            if lv >= v.lowLevel and lv <= v.highLevel then
                self.goodsIds[#self.goodsIds + 1] = {count = self.data[tostring(v.id)] or 0,id = v.id}
            end
        end
    elseif self.page == SHOP_TYPE.LEGIONDRESSSHOP then
        self:getGoods()
    else
        for k,v in pairs(self.data.goods) do
            self.goodsIds[#self.goodsIds + 1] = {rid = tonumber(k),lid = tonumber(v[1]),status = tonumber(v[2]),eid = tonumber(v[3]),godid = tonumber(v[4])}
        end
        table.sort(self.goodsIds,function(a,b)
            return a.rid < b.rid
        end )
    end
    -- if self.page == SHOP_TYPE.MILITARYSHOP or self.page == SHOP_TYPE.LEGIONWARSHOP then
    --     table.sort(self.goodsIds,function(a,b)
    --         return a.rid < b.rid
    --     end )
    -- end
    if #self.goodsIds > 6 then
        self.intervalSize = 3
    else
        self.intervalSize = 21
    end
    -- for k,v in pairs(self.data.goods) do
    --     self.goodsIds[#self.goodsIds + 1] = {rid = tonumber(k),lid = tonumber(v[1]),status = tonumber(v[2])}
    -- end
end

function ShopUI:showTips(award,tab,status,callback,sidebarList,num)
    local stype = award:getCategory()
    if stype == "skyweapon" or stype == "skywing" then
        GetWayMgr:showGetwayUI(award,false)
    else
        local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num,nil,self.page)
        sellTipsUI:showUI()
    end
end

function ShopUI:updatePageBtn(page)
    for k,v in pairs(self.pageBtns) do
        local infoTx = v:getChildByName('info_tx')
        if k == page then
            v:setBrightStyle(ccui.BrightStyle.highlight)
            v:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.NEWPURPLE)
            -- infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
            infoTx:setFontSize(22)
            -- infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            v:setBrightStyle(ccui.BrightStyle.normal)
            v:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.WHITE)
            -- infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
            infoTx:setFontSize(20)
            -- infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
    -- for i=self.pageTab.min,self.pageTab.max do
    --     local infoTx = self.pageBtns[i]:getChildByName('info_tx')
    --     if i == page then
    --         self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
    --         self.pageBtns[i]:setTouchEnabled(false)
    --         infoTx:setColor(COLOR_TYPE.PALE)
    --         infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
    --         infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    --     else
    --         self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
    --         self.pageBtns[i]:setTouchEnabled(true)
    --         infoTx:setColor(COLOR_TYPE.DARK)
    --         infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
    --         infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    --     end
    -- end
end

function ShopUI:init()
    self.goodsIds = {}
    self.imgs = {}
    self.flyImgs = {}
    local bgImg = self.root:getChildByName("shop_bg_img")
    self.node_btns = bgImg:getChildByName("node_btns")
    self.node_top = bgImg:getChildByName("node_top")
    self.node_items = bgImg:getChildByName("node_items")

    self.btn_sv = self.node_btns:getChildByName("btn_sv")

    self.shopImg = bgImg:getChildByName("node_bottom")
    self:adaptUI(bgImg, self.shopImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.shopImg:setPosition(cc.p(winSize.width/2 - 30,-5))

    local closeBtn = self.shopImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideShop()
        end
    end)
    
    self.cellSv = self.node_items:getChildByName('cell_sv')
    self.cellSv:setScrollBarEnabled(false)
    self.flyBgImg = bgImg

    self.neiBgImg = bgImg:getChildByName("bg_img")

    self.neiBgImg:setPositionX(winSize.width/2 + 40)
    self.node_top:setPositionX(self.neiBgImg:getPositionX())
    self.shopImg:setPositionX(self.neiBgImg:getPositionX() - 70)
    self.node_items:setPositionX(self.neiBgImg:getPositionX() - 70)
    self.node_btns:setPositionX(self.neiBgImg:getPositionX() - 540)

    self.panel1 = self.shopImg:getChildByName("panel_1")
    self.descTx1 = self.panel1:getChildByName('desc_1_tx')
    self.descTx2 = self.panel1:getChildByName('desc_2_tx')
    
    self.pageBtns = {}
    local function get(page)
        MainSceneMgr:shopGet(page,function(data,page1)
            self.page = page1
            self.data = data.shop
            self.custom = data.maxStar or self.custom
            self:getGoodsIds()
            self:updatePanel()
            self:updatePageBtn(self.page)
        end)
    end
    local function btnInit(min,max)
        -- print("go---------------------------->")
        -- print(min,max)
        -- print("end----------------------------->")
        -- if min == max then
        --     local btn = self.btn_sv:getChildByName('page_'..min..'_btn')
        --     local newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
        --     newImg:setPosition(cc.p(165,48))
        --     newImg:setName('new_img')
        --     newImg:setVisible(false)
        --     btn:addChild(newImg)
        --     btn.newImg = newImg

        --     local infoTx = btn:getChildByName('info_tx')
        --     infoTx:setString(GlobalApi:getLocalStr('SHOP_'..min))
        --     infoTx:setPosition(55,34)
        --     infoTx:setFontSize(20)
        --     -- btn:setVisible(self.page == min)
        --     btn:setVisible(true)
        --     self.pageBtns[min] = btn
        -- else
            for i = min,max do
                local btn = self.btn_sv:getChildByName('page_'..i..'_btn')
                local newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
                newImg:setPosition(cc.p(95,55))
                newImg:setName('new_img')
                newImg:setVisible(false)
                newImg:setLocalZOrder(9)
                btn:addChild(newImg)
                btn.newImg = newImg

                local infoTx = btn:getChildByName('info_tx')
                infoTx:setPosition(55,34)
                infoTx:setFontSize(20)
                infoTx:setString(GlobalApi:getLocalStr('SHOP_'..i))
                -- if self.pageTab then
                --     btn:setVisible((i >= self.pageTab.min) and (i <= self.pageTab.max) and i ~= 51)
                -- else
                    btn:setVisible(i ~= 51)
                -- end
                self.pageBtns[i] = btn
                btn:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        self.page = i
                        get(i)
                    end
                end)
            end
        end
    -- end
    btnInit(11,13)
    btnInit(21,22)
    btnInit(31,32)
    btnInit(41,41)
    btnInit(51,54)
    btnInit(61,61)
    btnInit(71,72)
    if self.page == 51 then
        self.page = 52
    end
    -- local leftBtn = bgImg:getChildByName('left_btn')
    -- local rightBtn = bgImg:getChildByName('right_btn')
    -- leftBtn:setPosition(cc.p(0,winSize.height/2))
    -- rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    -- leftBtn:setVisible(false)
    -- rightBtn:setVisible(false)

    -- GlobalApi:arrowBtnMove(leftBtn,rightBtn)
    -- leftBtn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         local page = (self.page - 2)%self.pageTab.max+1
    --         page = ((page < self.pageTab.min) and self.pageTab.max) or page
    --         get(page)
    --     end
    -- end)
    -- rightBtn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         local page = self.page%self.pageTab.max+1
    --         page = ((page < self.pageTab.min) and self.pageTab.min) or page
    --         get(page)
    --     end
    -- end)
    -- leftBtn:setVisible(self.pageTab.min ~= self.pageTab.max)
    -- rightBtn:setVisible(self.pageTab.min ~= self.pageTab.max)
    -- leftBtn:setPosition(cc.p(0,winSize.height/2))
    -- rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    self:updatePageBtn(self.page)
    self:getGoodsIds()
    self:updatePanel()
    self:updateSigns()
end
    
function ShopUI:updateSigns()
    if self.page == SHOP_TYPE.LISTSHOP then
        if self.pageBtns[self.page] and self.pageBtns[self.page].newImg then
            -- if ArenaMgr:getArenaShopSign() then
            --     print("这个按钮应该有小红点:"..self.page)
            -- end
            self.pageBtns[self.page].newImg:setVisible(ArenaMgr:getArenaShopSign())
        end
    end
end

return ShopUI