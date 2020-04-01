local HumanArms = class("human_arms")

local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function HumanArms:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.human_arms = self.msg.human_arms

    self:initData()
    self:initTop()
    self:initRight()
    self:initLeft()   
    self:updateMark()
    ActivityMgr:showLefhumanArmCue()
end

function HumanArms:updateMark()
    if UserData:getUserObj():getSignByType('human_arms') then
		ActivityMgr:showMark("human_arms", true)
	else
		ActivityMgr:showMark("human_arms", false)
	end
end

function HumanArms:initData()
    self.avData = GameData:getConfData('avhuman_arms')
end

function HumanArms:initTop()
    ActivityMgr:showRightHumanArmsRemainTime()
end

function HumanArms:initLeft()
    local leftBg = self.rootBG:getChildByName('leftbg')
    local bg = leftBg:getChildByName('bg')
    --bg:setVisible(false)

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(280, 26))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_HUMAN_WING_DES1'), 26, COLOR_TYPE.WHITE)
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_HUMAN_WING_DES5'), 26,COLOR_TYPE.GREEN)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_HUMAN_WING_DES3'), 26,COLOR_TYPE.WHITE)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('top')

	richText:setAnchorPoint(cc.p(0,1))
	richText:setPosition(cc.p(15,370))
    richText:format(true)
    leftBg:addChild(richText)

end

function HumanArms:initRight()
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

function HumanArms:updateSV()
    self.verSv:removeAllChildren()
    self.tempData = {}
    local reward = self.msg.human_arms.achieve -- 至少为{}
    for i = 1,#self.avData do
        local v = clone(self.avData[i])
        local level = v.level
        v.showStatus = 1
        if reward[tostring(level)] then
            if reward[tostring(level)] == 1 then
                v.showStatus = 1
            else
                v.showStatus = 3
            end
        else
            v.showStatus = 2
        end
        table.insert(self.tempData,v)
    end

    table.sort(self.tempData,function(a, b)
        if a.showStatus == b.showStatus then
            return tonumber(a.id) < tonumber(b.id)
        else
            return a.showStatus > b.showStatus
        end
	end)

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

        --
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))

        -- 状态相关
        local stage = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        getBtn.day = self.tempData[i].level
        getBtn.stateImage = stage
        getBtn.tempCell = tempCell
        getBtn.i = i

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                    MessageMgr:sendPost('get_human_arms_award','activity',json.encode({level = self.tempData[i].level}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards1 = {}
                        if response.data.awards1 then
                            awards1 = clone(response.data.awards1)
                        end
                        local awards2 = response.data.awards2
                        for i = 1,#awards2 do
                            table.insert(awards1,awards2[i])
                        end
			            if awards1 then
				            GlobalApi:parseAwardData(awards1)
				            GlobalApi:showAwardsCommon(awards1,nil,nil,true)
			            end
                        self.msg.human_arms.achieve[tostring(self.tempData[i].level)] = 1
                        UserData:getUserObj().activity.human_arms = self.msg.human_arms

                        self:updateSV()
			            self:updateMark()
		            end)
            end
        end)

        local gotoBtn = tempCell:getChildByName('goto_btn')
        gotoBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES10'))
        getBtn.gotoBtn = gotoBtn
        gotoBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                local isOpen = GlobalApi:getOpenInfo('weapon')
                if not isOpen then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES20'), COLOR_TYPE.RED)
                    return
                end
                PeopleKingMgr:showPeopleKingMainUI(1)
                ActivityMgr:hideUI()
            end
        end)

        self:refreshDay(getBtn)

        -- 中间项,加入道具显示
        local centerItems = tempCell:getChildByName('center_item')
        local horSv = centerItems:getChildByName('sv')
        horSv:setScrollBarEnabled(false)
        horSv:setPropagateTouchEvents(true)

        local awardData2 = clone(self.tempData[i].awards1)
        local awardData = clone(self.tempData[i].awards2)

        local limitLv = self.msg.human_arms.level
        if self.tempData[i].level >= limitLv then
            for i = 1,#awardData do
                table.insert(awardData2,awardData[i])
            end
            awardData = awardData2
        end

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
        
        local desc = tempCell:getChildByName('desc')
        desc:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_HUMAN_WING_DES6'),self.tempData[i].level))

    end
    innerContainer:setPositionY(size.height - allHeight)
end

function HumanArms:refreshDay(btn)
    local i = btn.i
    local level = self.tempData[i].level
    local day = btn.day
    local stateImage = btn.stateImage
    local tempCell = btn.tempCell
    local gotoBtn = btn.gotoBtn
    gotoBtn:setVisible(false)

    tempCell:loadTexture('uires/ui/common/common_bg_6.png')
    local reward = self.msg.human_arms.achieve -- 至少为{}
    
    local peopleKingData = UserData:getUserObj():getPeopleKing()
    local curProgress = peopleKingData and peopleKingData.weapon_level or 0

    if curProgress >= level then
        if reward[tostring(level)] and reward[tostring(level)] == 1 then
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
        stateImage:setVisible(false)
        gotoBtn:setVisible(true)
    end

    local expBg = tempCell:getChildByName('exp_bg')
    local expBar = tempCell:getChildByName('exp_bar')
    local expTx = tempCell:getChildByName('exp_tx')

    -- 玩家当前的圣武等级
    local peopleKingData = UserData:getUserObj():getPeopleKing()
    local showStep = curProgress >= level and level or curProgress
    expTx:setString(showStep .. '/' .. level)
    if level <= 0 then
        expBar:setPercent(100)
    else
        expBar:setPercent(showStep/level * 100)
    end
end

return HumanArms