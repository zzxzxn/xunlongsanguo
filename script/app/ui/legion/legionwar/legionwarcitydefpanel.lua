local LegionWarCityDefUI = class("LegionWarCityDefUI", BaseUI)

function LegionWarCityDefUI:ctor(index,cityinfo,legionwardata)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_CITYDEF
  	self.index = index
    self.cityinfo = cityinfo
    self.legionwardata = legionwardata
    printall(self.legionwardata)
end

function LegionWarCityDefUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	self.bgimg2 = bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg1, self.bgimg2)
	local closebtn = self.bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarCityDefUI()
        end
    end)

    local titlebg = self.bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr("LEGION_WAR_DESC14"))

    self:initTop()
    self:initLeft()
    self:initRight()
    self:update()
end

function LegionWarCityDefUI:initTop()
    local topbg = self.bgimg2:getChildByName('bg_img4')
    local nametx = topbg:getChildByName('name_tx')
    local cityconf  = GameData:getConfData('legionwarcity')
    nametx:setString(cityconf[self.index].name)
    local legioncityconf = GameData:getConfData('legionwarcity')
    local maxlv = legioncityconf[self.index].maxBufLevel
    local attsconf  = GameData:getConfData('attribute')
    local topdesctx1 = topbg:getChildByName('desc_tx_1')
    topdesctx1:removeAllChildren()
    topdesctx1:setString('')
    local richText = xx.RichText:create()
    topdesctx1:addChild(richText)
    richText:setContentSize(cc.size(600, 28))
    richText:setPosition(cc.p(0,10))
    richText:setAlignment('left')
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC16')..":", 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create(self.cityinfo.city.buffLevel, 24, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextImage:create("uires/ui/common/arrow11.png")
    
    local re4 = xx.RichTextLabel:create('', 22, COLOR_TYPE.WHITE)
    re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re4:setFont('font/gamefont.ttf')
    if self.cityinfo.city.buffLevel == maxlv then
        if cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel)][1] > 0 then
            richText:addElement(re1)
            richText:addElement(re2)
            richText:addElement(re4)
            
            local str1 = GlobalApi:getLocalStr('LEGION_WAR_DESC22')
            for k,v in pairs(cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel)]) do
                str1 = str1 ..attsconf[v].name .. GlobalApi:getLocalStr('STR_TIGAO') .. cityconf[self.index][tostring('value'..self.cityinfo.city.buffLevel)][k]..'%'
                if k < #cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel)] then
                    str1 = str1.."，"
                end
            end
            local str ="("..str1..')'
            re4:setString(str)
        end
    else
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        if cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel+1)][1] > 0 then
            richText:addElement(re4)
            
            local str1 = GlobalApi:getLocalStr('LEGION_WAR_DESC22')
            for k,v in pairs(cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel+1)]) do
                str1 = str1 ..attsconf[v].name .. GlobalApi:getLocalStr('STR_TIGAO') .. cityconf[self.index][tostring('value'..self.cityinfo.city.buffLevel+1)][k]..'%'
                if k < #cityconf[self.index][tostring('atts'..self.cityinfo.city.buffLevel+1)] then
                    str1 = str1.."，"
                end
            end
            local str = (self.cityinfo.city.buffLevel+1).."("..str1..')'
            re4:setString(str)
        else
            richText:addElement(re4)
            local str = (self.cityinfo.city.buffLevel+1)
            re4:setString(str) 
        end
    end


    richText:setVerticalAlignment('middle')
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))

    local topdesctx2 = topbg:getChildByName('desc_tx_2')
    topdesctx2:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC17')..":")
    local barbg = topbg:getChildByName('bar_bg')
    self.bartx = barbg:getChildByName('bar_tx')
    self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))
    if self.cityinfo.city.buffLevel < maxlv then
        local percent = math.floor(self.cityinfo.city.buffXp/legioncityconf[self.index][tostring('buf'..(self.cityinfo.city.buffLevel+1)..'Xp')]*100)
        self.bar:setPercent(percent)
        self.bartx:setString(self.cityinfo.city.buffXp..'/'..legioncityconf[self.index][tostring('buf'..(self.cityinfo.city.buffLevel+1)..'Xp')])
    else
        self.bar:setPercent(100)
        self.bartx:setString(legioncityconf[self.index][tostring('buf'..maxlv..'Xp')]..'/'..legioncityconf[self.index][tostring('buf'..maxlv..'Xp')])
    end
end

function LegionWarCityDefUI:initLeft()
    local bg = self.bgimg2:getChildByName('bg_img2')
    local citybufconf = GameData:getConfData('legionwarcitybuf')
    local desctx1 = bg:getChildByName('desc_tx_1')
    local rt1 = xx.RichText:create()
    desctx1:addChild(rt1)
    rt1:setPosition(cc.p(0,10))
    rt1:setAlignment('left')
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC10'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create('+'..citybufconf[1].persionCoin, 24, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    rt1:addElement(re1)
    rt1:addElement(re2)
    rt1:setVerticalAlignment('middle')
    rt1:format(true)
    rt1:setAnchorPoint(cc.p(0,0.5))

    -- local desctx2 = bg:getChildByName('desc_tx_2')
    -- local rt2 = xx.RichText:create()
    -- desctx2:addChild(rt2)
    -- rt2:setPosition(cc.p(0,10))
    -- rt2:setAlignment('left')
    -- local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC10'), 24, COLOR_TYPE.WHITE)
    -- re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- re1:setFont('font/gamefont.TTF')
    -- local re4 = xx.RichTextLabel:create('+'..citybufconf[1].legionCoin, 24, COLOR_TYPE.GREEN)
    -- re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- re2:setFont('font/gamefont.TTF')
    -- rt2:addElement(re3)
    -- rt2:addElement(re4)
    -- rt2:setVerticalAlignment('middle')
    -- rt2:format(true)
    -- rt2:setAnchorPoint(cc.p(0,0.5))

    local desctx3 = bg:getChildByName('desc_tx_3')
    local rt3 = xx.RichText:create()
    desctx3:addChild(rt3)
    rt3:setPosition(cc.p(0,10))
    rt3:setAlignment('left')
    local re5 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC17'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re6 = xx.RichTextLabel:create('+'..citybufconf[1].buffAdd, 24, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    rt3:addElement(re5)
    rt3:addElement(re6)
    rt3:setVerticalAlignment('middle')
    rt3:format(true)
    rt3:setAnchorPoint(cc.p(0,0.5))
    local desctx4 = bg:getChildByName('desc_tx_4')
    local rt4 = xx.RichText:create()
    desctx4:addChild(rt4)
    rt4:setPosition(cc.p(0,10))
    rt4:setAlignment('middle')
    local re7 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ATLAR_DESC2'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local cost = DisplayData:getDisplayObj(citybufconf[1].cost[1])
    local re8 = xx.RichTextLabel:create(cost:getNum(), 24, COLOR_TYPE.WHITE)
    if cost:getOwnNum() < cost:getNum() then
        re8:setColor(COLOR_TYPE.RED)
    end
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    local re9 = xx.RichTextImage:create("uires/ui/res/res_gold.png")
    rt4:addElement(re7)
    rt4:addElement(re8)
    rt4:addElement(re9)
    rt4:setVerticalAlignment('middle')
    rt4:format(true)
    rt4:setAnchorPoint(cc.p(0.5,0.5))

    local funcbtn = bg:getChildByName('func_btn')
    local funcbtntx =  funcbtn:getChildByName('text')
    funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC18'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local legionconf = GameData:getConfData('legion')
            if tonumber(legionconf['legionWarAddCityBufNum'].value) - self.legionwardata.user.addCityBufNum <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC11')..GlobalApi:getLocalStr('NOT_ENOUGH'),COLOR_TYPE.RED)
                return
            end
            if cost:getOwnNum() < cost:getNum() then
                promptmgr:showSystenHint(cost:getName()..GlobalApi:getLocalStr('NOT_ENOUGH'),COLOR_TYPE.RED)
            else
                self:sendMsg(1)
            end
        end
    end)
end

function LegionWarCityDefUI:initRight()
    local bg = self.bgimg2:getChildByName('bg_img3')
    local citybufconf = GameData:getConfData('legionwarcitybuf')
    local desctx1 = bg:getChildByName('desc_tx_1')
    local rt1 = xx.RichText:create()
    desctx1:addChild(rt1)
    rt1:setPosition(cc.p(0,10))
    rt1:setAlignment('left')
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC10'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create('+'..citybufconf[2].persionCoin, 24, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    rt1:addElement(re1)
    rt1:addElement(re2)
    rt1:setVerticalAlignment('middle')
    rt1:format(true)
    rt1:setAnchorPoint(cc.p(0,0.5))

    -- local desctx2 = bg:getChildByName('desc_tx_2')
    -- local rt2 = xx.RichText:create()
    -- desctx2:addChild(rt2)
    -- rt2:setPosition(cc.p(0,10))
    -- rt2:setAlignment('left')
    -- local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC10'), 24, COLOR_TYPE.WHITE)
    -- re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- re1:setFont('font/gamefont.TTF')
    -- local re4 = xx.RichTextLabel:create('+'..citybufconf[2].legionCoin, 24, COLOR_TYPE.GREEN)
    -- re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- re2:setFont('font/gamefont.TTF')
    -- rt2:addElement(re3)
    -- rt2:addElement(re4)
    -- rt2:setVerticalAlignment('middle')
    -- rt2:format(true)
    -- rt2:setAnchorPoint(cc.p(0,0.5))

    local desctx3 = bg:getChildByName('desc_tx_3')
    local rt3 = xx.RichText:create()
    desctx3:addChild(rt3)
    rt3:setPosition(cc.p(0,10))
    rt3:setAlignment('left')
    local re5 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC17'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re6 = xx.RichTextLabel:create('+'..citybufconf[2].buffAdd, 24, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    rt3:addElement(re5)
    rt3:addElement(re6)
    rt3:setVerticalAlignment('middle')
    rt3:format(true)
    rt3:setAnchorPoint(cc.p(0,0.5))
    local desctx4 = bg:getChildByName('desc_tx_4')
    local rt4 = xx.RichText:create()
    desctx4:addChild(rt4)
    rt4:setPosition(cc.p(0,10))
    rt4:setAlignment('middle')
    local re7 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ATLAR_DESC2'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local cost = DisplayData:getDisplayObj(citybufconf[2].cost[1])
    local re8 = xx.RichTextLabel:create(cost:getNum(), 24, COLOR_TYPE.WHITE)
    if cost:getOwnNum() < cost:getNum() then
        re8:setColor(COLOR_TYPE.RED)
    end
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    local re9 = xx.RichTextImage:create("uires/ui/res/res_cash.png")
    rt4:addElement(re7)
    rt4:addElement(re8)
    rt4:addElement(re9)
    rt4:setVerticalAlignment('middle')
    rt4:format(true)
    rt4:setAnchorPoint(cc.p(0.5,0.5))

    local funcbtn = bg:getChildByName('func_btn')
    local funcbtntx =  funcbtn:getChildByName('text')
    funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC19'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local legionconf = GameData:getConfData('legion')
            if tonumber(legionconf['legionWarAddCityBufNum'].value) - self.legionwardata.user.addCityBufNum <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC11')..GlobalApi:getLocalStr('NOT_ENOUGH'),COLOR_TYPE.RED)
                return
            end
            if cost:getOwnNum() < cost:getNum() then
                promptmgr:showSystenHint(cost:getName()..GlobalApi:getLocalStr('NOT_ENOUGH'),COLOR_TYPE.RED)
            else
                self:sendMsg(2)
            end
        end
    end)
end

function LegionWarCityDefUI:update()
   self:initTop()
end

function LegionWarCityDefUI:sendMsg(deftype)
    local obj = {
        city = self.index,
        bufType = deftype
    }
    MessageMgr:sendPost("upgrade_citybuf","legionwar", json.encode(obj), function (response)
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
            self.cityinfo.city.buffLevel = data.citybuf.buffLevel
            self.cityinfo.city.buffXp = data.citybuf.buffXp
            self.legionwardata.ownLegion.cities[tostring(self.index)].buffLevel = data.citybuf.buffLevel
            self.legionwardata.ownLegion.cities[tostring(self.index)].buffXp = data.citybuf.buffXp
            self.legionwardata.user.addCityBufNum = self.legionwardata.user.addCityBufNum + 1 

            --玩法指引数据更新
            UserData:getUserObj():setGuideCitybufnum(self.legionwardata.user.addCityBufNum)

            local citybufconf = GameData:getConfData('legionwarcitybuf')
            self.legionwardata.user.coin = data.user.coin
            self:update()
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC24'),COLOR_TYPE.GREEN)
        elseif code == 104 then
            local legioncityconf = GameData:getConfData('legionwarcity')
            local maxlv = legioncityconf[self.index].maxBufLevel
            self.cityinfo.city.buffLevel = maxlv
            self.cityinfo.city.buffXp = legioncityconf[self.index][tostring('buf'..maxlv..'Xp')]
            self.legionwardata.ownLegion.cities[tostring(self.index)].buffLevel = maxlv
            self.legionwardata.ownLegion.cities[tostring(self.index)].buffXp = legioncityconf[self.index][tostring('buf'..maxlv..'Xp')]
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR4'),COLOR_TYPE.RED)
        end
    end)
end

return LegionWarCityDefUI