local ActivityHappyWheelLogUI = class("UI", BaseUI)

function ActivityHappyWheelLogUI:ctor(data)
    self.uiIndex = GAME_UI.UI_ACTIVITY_HAPPY_WHEEL_LOG
    self.data = data 
    self.days = 0
    self.begionday = 0
end

function ActivityHappyWheelLogUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    self:adaptUI(bgimg1, bgimg2)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_17'))
    self.sv = bgimg2:getChildByName('log_sv')
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(310,320))
    self.sv:addChild(self.contentWidget)

    local log = {}
    for k,v in pairs(self.data.log) do
        if type(v) == 'table' then
            table.insert(log,v)
        end
    end

    table.sort( log, function (a,b)
        return a.time > b.time
    end )
    self.num = #log
    self.allHeight = 0
    for i=1,self.num do
        self:addCells(i,log[i])
    end

    self.sv:scrollToTop(0.1,true)
end

function ActivityHappyWheelLogUI:addCells(index,celldata)
    local node = cc.CSLoader:createNode("csb/legionloginfocell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)
    local bgimg2 = bgimg:getChildByName('bg_img')
    local localday = self.days
    self.num = self.num + 1
    if  not self:isSameDay(self.begionday,celldata.time) then
        self.begionday = Time.beginningOfOneDay(celldata.time)
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
        daytx:setString(GlobalApi:toStringTime(tonumber(celldata.time),'YMD'))
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

    infotx:setString('')

    -- 富文本infotx
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(630, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_18'), 21, COLOR_TYPE.WHITE)
	re1:setStroke(COLOR_TYPE.BLACK,1)
    re1:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    richText:addElement(re1)

    local disPlayData = DisplayData:getDisplayObjs(GlobalApi:mergeAwards(celldata.awards))
    for i = 1,#disPlayData do
        local awards = disPlayData[i]
        local des = awards:getName() .. ' x ' .. awards:getNum()
        if i ~= #disPlayData then
            des = des .. '，'
        end
        local re = xx.RichTextLabel:create(des, 21, awards:getNameColor())
	    re:setStroke(COLOR_TYPE.BLACK,1)
        re:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
        re:setFont('font/gamefont.ttf')
        richText:addElement(re)
    end

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

    timetx:setString(Time.date('%X',tonumber(celldata.time)))
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

function ActivityHappyWheelLogUI:isSameDay(t1,t2)
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
return ActivityHappyWheelLogUI