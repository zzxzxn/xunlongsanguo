local TodayDouble = class("TodayDouble")

local defaultNor = 'uires/ui/activity/todaybtn1.png'
local defaultSel = 'uires/ui/activity/todaybtn2.png'

local ZORDER1 = 1500
local ZORDER2 = 1000
local ZORDER3 = 500

function TodayDouble:init()
    self.rootBG = self.root:getChildByName("root")

    UserData:getUserObj().todayDoubleTag = 0
    if UserData:getUserObj().todayDoubleTag == 0 and UserData:getUserObj().luckyWheelTag == 0 and UserData:getUserObj().payOnlyTag == 0 then
        UserData:getUserObj().first_login = 0
    end

    self:initData()
    self:initLeft()
    self:initTop()
    self:initRight()
    self:updateMark()
end

function TodayDouble:updateMark()
    if UserData:getUserObj():getSignByType('todaydouble') then
		ActivityMgr:showMark("todaydouble", true)
	else
		ActivityMgr:showMark("todaydouble", false)
	end
end

function TodayDouble:initData()
    self.weekData = 
    {
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES1'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES2'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES3'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES4'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES5'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES6'),
        GlobalApi:getLocalStr('TODAY_DOUBLE_DES7'),
    }
    local time = Time.getCorrectServerTime()
    local conf = GameData:getConfData('activities')['todaydouble']
    local startTime = GlobalApi:convertTime(1,conf.startTime)

    local diffTime = time - startTime
    local wday = math.ceil(diffTime/(24*3600))

    self.curDay = wday
    self.curSelectDay = clone(self.curDay)
    self.todayDoubleConf = GameData:getConfData('avtodaydouble')
end

function TodayDouble:initLeft()
    local image = self.rootBG:getChildByName("image")
    image:ignoreContentAdaptWithSize(true)
    image:setScale(0.8)

    local tipsBg = self.rootBG:getChildByName('tips_bg')
    tipsBg:getChildByName('tips1'):setString(GlobalApi:getLocalStr('TODAY_DOUBLE_DES8'))
    --tipsBg:getChildByName('tips2'):setString(GlobalApi:getLocalStr('TODAY_DOUBLE_DES9'))

end

function TodayDouble:initTop()
    ActivityMgr:showRightTodayDoubleRemainTime()
end

function TodayDouble:initRight()
    -- 按钮
    self.btns = {}
    for i = 1,7 do
        local btn = self.rootBG:getChildByName('btn' .. i)
        btn:setVisible(false)

        btn.curDay = i
        btn.text = btn:getChildByName('tx')
    	btn.text:setString(self.weekData[i])
        table.insert(self.btns,btn)
        btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
                self.curSelectDay = btn.curDay
				self:swtichWeekDay(self.curSelectDay)
			end
		end)
    end
    local imgRight = self.rootBG:getChildByName('img_right')
    imgRight:setLocalZOrder(ZORDER2)
    imgRight:getChildByName('tips_bottom'):setString(GlobalApi:getLocalStr('TODAY_DOUBLE_DES10'))

    local imgIn = imgRight:getChildByName('img_in')
    self.awardBgLeft = imgIn:getChildByName('award_bg_left')
    self.txLeft = self.awardBgLeft:getChildByName('tx')

    self.awardBgRight = imgIn:getChildByName('award_bg_right')
    self.txRight = self.awardBgRight:getChildByName('tx')

    self.awardBgCenter = imgIn:getChildByName('award_bg_center')
    self.txCenter = self.awardBgCenter:getChildByName('tx')

    self.awardBgLeft:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:enterCopy(sender.data)
        end
    end)

    self.awardBgRight:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:enterCopy(sender.data)
        end
    end)

    self.awardBgCenter:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:enterCopy(sender.data)
        end
    end)


    self:swtichWeekDay(self.curSelectDay)
end

-- 切换到周几
function TodayDouble:swtichWeekDay(day)
    for i=1,#self.btns do
        if i == day then
            self.btns[i]:setLocalZOrder(ZORDER1)
            self.btns[i]:loadTextureNormal(defaultSel)
            self.btns[i].text:setFontSize(30)
            self.btns[i].text:setTextColor(cc.c3b(0xfe, 0xa5, 0x00))
        else
            self.btns[i]:setLocalZOrder(ZORDER3)
            self.btns[i]:loadTextureNormal(defaultNor)
            self.btns[i].text:setFontSize(22)
            self.btns[i].text:setTextColor(cc.c3b(0xff, 0xf7, 0xe4))
        end
	end

    if self.awardBgLeft:getChildByName('richLeft') then
        self.awardBgLeft:removeChildByName('richLeft')
    end

    if self.awardBgRight:getChildByName('richRight') then
        self.awardBgRight:removeChildByName('richRight')
    end

    if self.awardBgCenter:getChildByName('richCenter') then
        self.awardBgCenter:removeChildByName('richCenter')
    end

    local data = self.todayDoubleConf[day]
    local gateway1 = data.gateway1
    local gateway2 = data.gateway2

    local icon1 = data.icon1
    local icon2 = data.icon2

    local name1 = data.name1
    local name2 = data.name2

    local name3 = ""
    if data.name3 ~= '0' then
        name3 = data.name3
    end
    local name4 = ""
    if data.name4 ~= '0' then
        name4 = data.name4
    end

    local isOpen1,isNotIn1,id1,level1 = GlobalApi:getOpenInfo(gateway1)

    if gateway2 ~= '0' then
        self.awardBgLeft:setVisible(true)
        self.awardBgRight:setVisible(true)
        self.awardBgCenter:setVisible(false)

        local isOpen2,isNotIn2,id2,level2 = GlobalApi:getOpenInfo(gateway2)

        self.awardBgLeft.data = {gateway1,isOpen1,id1,level1,name1}
        self.awardBgRight.data = {gateway2,isOpen2,id2,level2,name2}

        self.awardBgLeft:getChildByName('award_img'):loadTexture('uires/icon/dailytask/'..icon1 .. '.png')
        self.awardBgRight:getChildByName('award_img'):loadTexture('uires/icon/dailytask/'..icon2 .. '.png')

        if isOpen1 then
            self.txLeft:setVisible(true)
            self.txLeft:setString(string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES12'),name1 .. name3))
        else
            self.txLeft:setVisible(false)
            self:setRichText(id1,level1,name1,'richLeft',self.awardBgLeft,self.txLeft)
        end

        if isOpen2 then
            self.txRight:setVisible(true)
            self.txRight:setString(string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES12'),name2 .. name4))
        else
            self.txRight:setVisible(false)
            self:setRichText(id2,level2,name2,'richRight',self.awardBgRight,self.txRight)
        end

    else
        self.awardBgLeft:setVisible(false)
        self.awardBgRight:setVisible(false)
        self.awardBgCenter:setVisible(true)

        self.awardBgCenter.data = {gateway1,isOpen1,id1,level1,name1}

        self.awardBgCenter:getChildByName('award_img'):loadTexture('uires/icon/dailytask/'..icon1 .. '.png')
        if isOpen1 then
            self.txCenter:setVisible(true)
            self.txCenter:setString(string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES12'),name1 .. name3))
        else
            self.txCenter:setVisible(false)
            self:setRichText(id1,level1,name1,'richCenter',self.awardBgCenter,self.txCenter)
        end
    end

end

function TodayDouble:setRichText(id,level,str,richTextName,parent,widget)
    local des
    if id then
        des = string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES13'),id)
    elseif level then
        des = string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES14'),level)
    else
        return
    end

    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(des, 22, cc.c3b(0xff, 0xf2, 0x49))
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES15'),str), 22, cc.c3b(0xfe, 0xa5, 0x00))
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(widget:getPositionX(),widget:getPositionY()))
    richText:format(true)
    parent:addChild(richText)
end

-- 进入某个副本
function TodayDouble:enterCopy(data)
    if self.curSelectDay == self.curDay then
        if data[2] then
            GlobalApi:getGotoByModule(data[1])
        else
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('TODAY_DOUBLE_DES17'),data[5]), COLOR_TYPE.RED)
        end
    else
        promptmgr:showSystenHint(GlobalApi:getLocalStr('TODAY_DOUBLE_DES16'), COLOR_TYPE.RED)
    end
end

return TodayDouble