local DailyRecharge = class("daily_recharge")

local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function DailyRecharge:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.daily_recharge.day = self.msg.daily_recharge.day
    UserData:getUserObj().activity.daily_recharge.rewards = self.msg.daily_recharge.rewards
    UserData:getUserObj():getPayment().day_money = self.msg.money

    ActivityMgr:showLefSDesc2Cue()
    self:initData()
    self:initTop()
    self:initRight()
    self:initLeft()   
    self:updateMark()
end

function DailyRecharge:updateMark()
    if UserData:getUserObj():getSignByType('daily_recharge') then
		ActivityMgr:showMark("daily_recharge", true)
	else
		ActivityMgr:showMark("daily_recharge", false)
	end
end

function DailyRecharge:initData()
    self.tempData = GameData:getConfData('avdailyrecharge')
end

function DailyRecharge:initTop()
    ActivityMgr:showRightDailyRechargeRemainTime()
end

function DailyRecharge:initLeft()
    local leftBg = self.rootBG:getChildByName('leftbg')
    local des1 = leftBg:getChildByName('des1')
    des1:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP9"))
    
    local des2 = leftBg:getChildByName('des2')
    des2:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP10"))

    local rechargeBtn = leftBg:getChildByName('recharge')
    rechargeBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP11"))

    rechargeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('cash')
            ActivityMgr:hideUI()
        end
    end)

    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("ACTIVITY_SALETIP12"), 22, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

    local money = self.msg.money
	local re2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('ACTIVITY_SALETIP13'),money), 22, COLOR_TYPE.ORANGE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(152,102))
    richText:format(true)
    leftBg:addChild(richText)

end

function DailyRecharge:initRight()
    local rightBg = self.rootBG:getChildByName('rightbg')
    local sv = rightBg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = rightBg:getChildByName('cell')
    rewardCell:getChildByName('get_btn'):getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    rewardCell:setVisible(false)
    self.verSv = sv
    self.rewardCell = rewardCell

    self:updateSV()

end

function DailyRecharge:updateSV()
    local num = #self.tempData
    local size = self.verSv:getContentSize()
    local innerContainer = self.verSv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * self.rewardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        self.verSv:addChild(tempCell)

        tempCell:getChildByName('recharge_tx'):setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP14"))
        --tempCell:getChildByName('text'):setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP3"))
        tempCell:getChildByName('text'):setVisible(false)

        --
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))

        
        local re1 = xx.RichTextAtlas:create(self.tempData[i].money,"uires/ui/number/font_fightforce_4.png", 26, 38, '0')
        re1:setColor(cc.c3b(0xff, 0xef, 0x41))

	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr("ACTIVITY_SALETIP15"), 24, cc.c3b(0xff, 0xef, 0x41))
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)

        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(90,47.20))
        richText:format(true)
        tempCell:addChild(richText)


        -- 状态相关
        local stage = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        getBtn.day = self.tempData[i].money
        getBtn.progress = tempCell:getChildByName('titletx')
        getBtn.stateImage = stage
        getBtn.tempCell = tempCell
        getBtn.i = i

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                    MessageMgr:sendPost('get_daily_recharge_award','activity',json.encode({id = i}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        self.msg.daily_recharge.rewards[tostring(i)] = 1
                        UserData:getUserObj().activity.daily_recharge.rewards = self.msg.daily_recharge.rewards

                        self:refreshDay(sender)
			            self:updateMark()
		            end)
            end
        end)
        self:refreshDay(getBtn)

        -- 中间项,加入道具显示
        local centerItems = tempCell:getChildByName('center_item')
        local horSv = centerItems:getChildByName('sv')
        horSv:setScrollBarEnabled(false)
        horSv:setPropagateTouchEvents(true)

        local awardData = self.tempData[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        
        local horSvContentSize = horSv:getContentSize()

        local itemWidth = 94 * 0.8
        local horOffset = 10
        local leftPos = 40
        local awardNum = #disPlayData
        local allWidth = awardNum*itemWidth + (awardNum - 1)*horOffset + 10
        if allWidth > horSvContentSize.width then
            horSv:setInnerContainerSize(cc.size(allWidth,horSvContentSize.height))
        else
            horSv:setInnerContainerSize(horSvContentSize)
        end

        for j = 1,awardNum,1 do
            local awards = disPlayData[j]

            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, horSv)
            cell.awardBgImg:setScale(0.8)
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
            cell.awardBgImg:setPosition(cc.p(leftPos + (j-1) * (itemWidth + horOffset),50))

            cell.awardBgImg:setSwallowTouches(false)
            cell.awardBgImg:setPropagateTouchEvents(false)
            local point1
            local point2
            cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                    point1 = sender:getTouchBeganPosition()      
                end
                if eventType == ccui.TouchEventType.ended then
                    point2 = sender:getTouchEndPosition()
                    if point1 then
                        local dis = cc.pGetDistance(point1,point2)
                        if dis <= 5 then
                            GetWayMgr:showGetwayUI(awards,false)
                        end
                    end
                end

		    end)
        end

    end
    innerContainer:setPositionY(size.height - allHeight)
end

function DailyRecharge:refreshDay(btn)
    local i = btn.i
    local day = btn.day
    local progress = btn.progress
    local stateImage = btn.stateImage
    local tempCell = btn.tempCell

    tempCell:loadTexture('uires/ui/common/common_bg_6.png')

    local allDays = self.msg.money
    --print('++++++++++++++++++++' .. allDays)
    local reward = self.msg.daily_recharge.rewards -- 至少为{}

    if allDays >= day then
        if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then           
            btn:setVisible(false)
            stateImage:setVisible(true)
            stateImage:loadTexture(HASGETAWARD)
        else
            btn:setVisible(true)
            stateImage:setVisible(false)
            tempCell:loadTexture('uires/ui/common/common_bg_26.png')

        end
    else
        btn:setVisible(false)
        stateImage:loadTexture(NOTREATCH)
    end
    progress:setFontSize(20)
    progress:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES1'),allDays > day and day or allDays,day))
end

return DailyRecharge