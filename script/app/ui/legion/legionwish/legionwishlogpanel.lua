local LegionWishLogPanelUI = class("LegionWishLogPanelUI", BaseUI)

function LegionWishLogPanelUI:ctor(data)
    self.uiIndex = GAME_UI.UI_LEGION_WISH_LOG
    self.data = data 
    self.days = 0
    self.begionday = 0
end

function LegionWishLogPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    self:adaptUI(bgimg1, bgimg2)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hideLegionWishLogPanelUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC33'))
    self.sv = bgimg2:getChildByName('log_sv')
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(310,320))
    self.sv:addChild(self.contentWidget)

    table.sort( self.data.wish_log, function (a,b)
        return a[1] > b[1]
    end )
    self.num = #self.data.wish_log
    self.allHeight = 0
    for i=1,self.num do
        self:addCells(i,self.data.wish_log[i])
    end

    self.sv:scrollToTop(0.1,true)
end

function LegionWishLogPanelUI:addCells(index,celldata)
    local node = cc.CSLoader:createNode("csb/legionloginfocell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)
    local bgimg2 = bgimg:getChildByName('bg_img')
    local localday = self.days
    self.num = self.num + 1
    if  not self:isSameDay(self.begionday,celldata[1]) then
        self.begionday = Time.beginningOfOneDay(celldata[1])
        self.days = self.days + 1
        self.num = 0
        local daynode = cc.CSLoader:createNode("csb/legionloginfocell.csb")
        local daybgimg = daynode:getChildByName('bg_img')
        local daybgimg2 = daybgimg:getChildByName('bg_img')
        daybgimg2:setVisible(false)
        daybgimg:removeFromParent(false)
        local daycell = ccui.Widget:create()
        daycell:addChild(daybgimg)
        local infotx = daybgimg:getChildByName('info_tx')
        infotx:setString('')
        local timetx = daybgimg:getChildByName('time_tx')
        timetx:setString('')
        local daytx = daybgimg:getChildByName('day_tx')

        local nowHeight = self.contentsize.height
        self.allHeight = self.allHeight + nowHeight
        local dayposy = -self.allHeight

        daycell:setPosition(cc.p(0,dayposy))
        daytx:setString(GlobalApi:toStringTime(tonumber(celldata[1]),'YMD'))
        self.contentWidget:addChild(daycell)
    end
    if  localday ~= self.days then
        bgimg2:setVisible(true)
    else
        if self.num%2 == 0 then
            bgimg2:setVisible(true)
        else
            bgimg2:setVisible(false)
        end
    end
    local logconf = GameData:getConfData('legionlog')
    local infotx = bgimg:getChildByName('info_tx')
    infotx:setPositionX(infotx:getPositionX() - 150)

    local str = ''
    str = celldata[2]
    infotx:setString('')

    -- ¸»ÎÄ±¾infotx
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(630, 40))

	local re1 = xx.RichTextLabel:create(str, 21, COLOR_TYPE.GREEN)
	re1:setStroke(COLOR_TYPE.BLACK,1)
    re1:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WISH_DESC32'), 21, COLOR_TYPE.WHITE)
	re2:setStroke(COLOR_TYPE.BLACK,1)
    re2:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local fragmentId = celldata[3]
    local awardData = {{'fragment',tostring(fragmentId),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]
    local re3 = xx.RichTextLabel:create(awards:getName() .. '*' .. celldata[4], 21, awards:getNameColor())
	re3:setStroke(COLOR_TYPE.BLACK,1)
    re3:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('top')
	richText:setAnchorPoint(cc.p(0,1))

    bgimg:addChild(richText)
    richText:format(true)

    local addHeight = 0
    local infoTxHeihgt = richText:getBrushY()

    if infoTxHeihgt >= 27 then
        addHeight = infoTxHeihgt - 27
    end

    bgimg2:setContentSize(cc.size(bgimg:getContentSize().width,bgimg:getContentSize().height + addHeight))
    richText:setPosition(cc.p(infotx:getPositionX(),bgimg:getContentSize().height + addHeight - (50-38.5)))

    local timetx = bgimg:getChildByName('time_tx')
    timetx:setPosition(cc.p(timetx:getPositionX() - 60,(bgimg:getContentSize().height + addHeight)/2))

    timetx:setString(Time.date('%X',tonumber(celldata[1])))
    local daytx = bgimg:getChildByName('day_tx')
    daytx:setString('')

    local nowHeight = self.contentsize.height + addHeight
    self.allHeight = self.allHeight + nowHeight
    local posy = -self.allHeight

    cell:setPosition(cc.p(0,posy))
    self.contentWidget:addChild(cell)
    if self.allHeight > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.allHeight))
    end
    self.contentWidget:setPosition(cc.p(self.sv:getInnerContainerSize().width/2,self.sv:getInnerContainerSize().height))
end

function LegionWishLogPanelUI:isSameDay(t1,t2)
    t1 = tonumber(t1)
    t2 = tonumber(t2)
    local rv = true
    if Time.date('%Y',t1) ~= Time.date('%Y',t2) then
        rv = false
    end
    if Time.date('%m',t1) ~= Time.date('%m',t2) then
        rv = false
    end
    if Time.date('%d',t1) ~= Time.date('%d',t2) then
        rv = false
    end
    return rv
end
return LegionWishLogPanelUI