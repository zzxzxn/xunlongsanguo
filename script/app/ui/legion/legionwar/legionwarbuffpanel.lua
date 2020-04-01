local LegionWarBuffUI = class("LegionWarBuffUI", BaseUI)


cc.exports.LEGIONCARD_ITEMFRAME = {
    ['blue'] = "uires/ui/legionwar/legionwar_card_blue.png",
    ['purple'] = "uires/ui/legionwar/legionwar_card_purple.png",
    ['orange'] = "uires/ui/legionwar/legionwar_card_yellow.png"
}

function LegionWarBuffUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGIONWAR_BUFF
    self.selectid = 1
    self.battledata = LegionMgr:getLegionBattleData()
end

function LegionWarBuffUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	local bgimg2 = bgimg1:getChildByName('bg_img1')
    local winSize = cc.Director:getInstance():getVisibleSize()
	local closebtn = bgimg1:getChildByName('close_btn')
	self:adaptUI(bgimg1, bgimg2)
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarBuffUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width,winSize.height))
    local topbg = bgimg2:getChildByName('top_bg_img')
    topbg:setContentSize(cc.size(winSize.width,60))
    local descpl = topbg:getChildByName('legion_1_bg')
    local cointx = descpl:getChildByName('coin_tx')
    cointx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC10')..':')
    self.coinnumtx = descpl:getChildByName('num_tx')
    
    self.maincard = {}
    self.maincard.bg = bgimg2:getChildByName('main_card')
    self.maincard.iconimg = self.maincard.bg:getChildByName('icon_img')
    self.maincard.nametx = self.maincard.bg:getChildByName('name_tx')
    self.maincard.desctx = self.maincard.bg:getChildByName('desc_tx')
    self.maincard.numtx = self.maincard.bg:getChildByName('num_tx')
    self.maincard.numtx:setString('')
    self.cardarr = {}
    for i=1,7 do
        local tab = {}
        local cardpl = bgimg2:getChildByName('card_'..i)
        cardpl:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.selectid = i
                for j=1,7 do
                     self.cardarr[j].light:setVisible(false)
                end
                self:update()
            end
        end)
        tab.light = cardpl:getChildByName('card_light')
        tab.bg = cardpl:getChildByName('card_info')
        local cardbg = cardpl:getChildByName('card_bg2')
        tab.nametx = cardbg:getChildByName('name_tx')
        tab.iconimg = tab.bg:getChildByName('icon_img')
        tab.numtx = tab.bg:getChildByName('num_tx')
        tab.numtx:setString('')
        tab.nametx2 = tab.bg:getChildByName('name_tx')
        tab.desctx = tab.bg:getChildByName('desc_tx')
        self.cardarr[i] = tab
    end

    local infobg = bgimg2:getChildByName('info_bg')
    local desctx1 = infobg:getChildByName('desc_tx_1')
    desctx1:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC50')..':')
    local desctx2 = infobg:getChildByName('desc_tx_2')
    desctx2:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC43')..':')
    local desctx3 = infobg:getChildByName('desc_tx_3')
    desctx3:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC44')..':')
    local desctx4 = infobg:getChildByName('desc_tx_4')
    desctx4:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC45')..':')
    self.numtx1 = infobg:getChildByName('num_tx_1')
    self.numtx2 = infobg:getChildByName('num_tx_2')
    self.numtx3 = infobg:getChildByName('num_tx_3')
    self.numtx4 = infobg:getChildByName('num_tx_4')

    local cardeffectconf = GameData:getConfData('legionwarcard')
    local funcbtn = infobg:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('text')
    funcbtntx:setString(GlobalApi:getLocalStr('BUY'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        local legioncanbuy = 0
        if self.battledata.legion.cards[tostring(self.selectid)] then
            legioncanbuy = cardeffectconf[self.selectid].legionLimit - self.battledata.legion.cards[tostring(self.selectid)].buy 
        else
            legioncanbuy = cardeffectconf[self.selectid].legionLimit
        end

        local personcanbuy = 0
        if self.battledata.user.cards[tostring(self.selectid)] then
            personcanbuy = cardeffectconf[self.selectid].personLimit - self.battledata.user.cards[tostring(self.selectid)].buy 
        else
            personcanbuy = cardeffectconf[self.selectid].personLimit
        end

        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if LegionMgr:getSelfLegionPos() >  cardeffectconf[self.selectid].buyLimit then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC47'),COLOR_TYPE.RED)
            else
                if LegionMgr:getLegionWarData().stage ~= 2 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC72'),COLOR_TYPE.RED)
                    return
                end
                if personcanbuy <= 0 and  cardeffectconf[self.selectid].legionLimit > 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC48'),COLOR_TYPE.RED)
                    return
                end
                if legioncanbuy <= 0 and cardeffectconf[self.selectid].legionLimit > 0  then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC48'),COLOR_TYPE.RED)
                    return
                end
                if cardeffectconf[self.selectid].price > self.battledata.user.coin then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC49'),COLOR_TYPE.RED)
                    return
                end

                self:sendMsg()
            end
        end
    end)
    self:update()
end

function LegionWarBuffUI:update()
    self.battledata = LegionMgr:getLegionBattleData()
    self.coinnumtx:setString(self.battledata.user.coin)
    local cardeffectconf = GameData:getConfData('legionwarcard')
    for i=1,7 do
        self.cardarr[i].nametx:setString(cardeffectconf[i].name)
        self.cardarr[i].iconimg:loadTexture('uires/ui/legionwar/legionwar_'..cardeffectconf[i].icon)
        self.cardarr[i].bg:loadTexture(LEGIONCARD_ITEMFRAME[cardeffectconf[i].color])
        if self.selectid == i then
            self.cardarr[i].light:setVisible(true)
        else
            self.cardarr[i].light:setVisible(false)
        end
        if self.battledata.user.cards[tostring(i)] and self.battledata.user.cards[tostring(i)].have > 0 then
            self.cardarr[i].numtx:setString(self.battledata.user.cards[tostring(i)].have)
        else
            self.cardarr[i].numtx:setString('')
        end
    end
    self.maincard.bg:loadTexture(LEGIONCARD_ITEMFRAME[cardeffectconf[self.selectid].color])
    self.maincard.iconimg:loadTexture('uires/ui/legionwar/legionwar_'..cardeffectconf[self.selectid].icon)
    self.maincard.nametx:setString(cardeffectconf[self.selectid].name)
    self.maincard.desctx:setString(cardeffectconf[self.selectid].desc)
    self.numtx1:setColor(COLOR_TYPE.WHITE)
    self.numtx2:setColor(COLOR_TYPE.WHITE)
    self.numtx3:setColor(COLOR_TYPE.WHITE)
    self.numtx4:setColor(COLOR_TYPE.WHITE)
    if cardeffectconf[self.selectid].personLimit > 0 then
        local canbuy = 0
        if self.battledata.user.cards[tostring(self.selectid)] then
            canbuy = cardeffectconf[self.selectid].personLimit - self.battledata.user.cards[tostring(self.selectid)].buy
        else
            canbuy = cardeffectconf[self.selectid].personLimit
        end
        if  canbuy == 0 then
            self.numtx1:setColor(COLOR_TYPE.RED)
        else
            self.numtx1:setColor(COLOR_TYPE.WHITE)
        end
        self.numtx1:setString(canbuy..'/'..cardeffectconf[self.selectid].personLimit)
    else
        self.numtx1:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC42'))
    end

    if cardeffectconf[self.selectid].legionLimit > 0 then
        local canbuy = 0
        if self.battledata.legion.cards[tostring(self.selectid)] then
            canbuy = cardeffectconf[self.selectid].legionLimit - self.battledata.legion.cards[tostring(self.selectid)].buy
        else
            canbuy = cardeffectconf[self.selectid].legionLimit
        end
        if  canbuy == 0 then
            self.numtx2:setColor(COLOR_TYPE.RED)
        else
            self.numtx2:setColor(COLOR_TYPE.WHITE)
        end
        self.numtx2:setString(canbuy..'/'..cardeffectconf[self.selectid].legionLimit)
    else
        self.numtx2:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC42'))
    end
    --团员能购买，相当于无限制
    if cardeffectconf[self.selectid].buyLimit == 4 then
        self.numtx3:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC42'))
    else
        self.numtx3:setString(GlobalApi:getLocalStr('LEGION_POS'..cardeffectconf[self.selectid].buyLimit)..GlobalApi:getLocalStr('LEGION_WAR_DESC20'))
    end
    if LegionMgr:getSelfLegionPos() >  cardeffectconf[self.selectid].buyLimit then
        self.numtx3:setColor(COLOR_TYPE.RED)
    else
        self.numtx3:setColor(COLOR_TYPE.WHITE)
    end
    self.numtx4:setString(cardeffectconf[self.selectid].price)
    if cardeffectconf[self.selectid].price >  self.battledata.user.coin then
        self.numtx4:setColor(COLOR_TYPE.RED)
    else
        self.numtx4:setColor(COLOR_TYPE.WHITE)
    end
end

 function LegionWarBuffUI:sendMsg()
    local cardeffectconf = GameData:getConfData('legionwarcard')
    local obj = {
        card = self.selectid
    }
    MessageMgr:sendPost("buy_card","legionwar", json.encode(obj), function (response)
        local code = response.code
        local data = response.data        
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.battledata.user.coin = self.battledata.user.coin - cardeffectconf[self.selectid].price
            if not self.battledata.user.cards[tostring(self.selectid)] then
                local tab = {}
                tab.have = 1
                tab.buy = 1
                self.battledata.user.cards[tostring(self.selectid)] = tab
            else
                self.battledata.user.cards[tostring(self.selectid)].have = self.battledata.user.cards[tostring(self.selectid)].have + 1
                self.battledata.user.cards[tostring(self.selectid)].buy = self.battledata.user.cards[tostring(self.selectid)].buy + 1
            end
            if cardeffectconf[self.selectid].legionLimit > 0 then
                if not self.battledata.legion.cards[tostring(self.selectid)] then
                    local tab = {}
                    tab.buy = 1
                    self.battledata.legion.cards[tostring(self.selectid)] = tab
                else
                    self.battledata.legion.cards[tostring(self.selectid)].buy = self.battledata.legion.cards[tostring(self.selectid)].buy + 1
                end
                
            end
            
            --增加攻击次数的卡买了直接使用
            if  self.selectid == 6 then
                self.battledata.user.attackNum = self.battledata.user.attackNum + 1
                UserData:getUserObj():setSignByType('legionwar_attacknum',1)
                self.battledata.user.cards[tostring(self.selectid)].have = 0
                self:update()
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY')..'，'..GlobalApi:getLocalStr('LEGION_WAR_DESC58'),COLOR_TYPE.GREEN)
            else
                self:update()
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'),COLOR_TYPE.GREEN)
            end
            
            
        elseif code == 150 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC46'),COLOR_TYPE.RED)
        end
    end)
 end
return LegionWarBuffUI