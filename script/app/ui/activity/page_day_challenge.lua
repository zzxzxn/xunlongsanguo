local DayChallenge = class("day_challenge")
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function DayChallenge:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.day_challenge.rewards = self.msg.day_challenge.rewards
    UserData:getUserObj().activity.day_challenge.progress = self.msg.day_challenge.progress

    UserData:getUserObj().tips.day_challenge = 0

    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()

    self:updateMark()
end

function DayChallenge:initData()
    self.tempData = GameData:getConfData('avdaychallenge')

    local conf = GameData:getConfData('activities')['day_challenge']
    local openDay = conf.openDay
    local duration = conf.duration
    local delayDays = conf.delayDays
    local openLoginDay = conf.openLoginDay

    local createTime = UserData:getUserObj():getCreateTime()
    local now = Time.date('*t',createTime)
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local refTime = GlobalData:getServerTime() - Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
    if(now.hour < resetHour) then
        refTime = refTime + 24*3600
    end

    local diffTime = refTime - openLoginDay*24*3600
    self.day = math.ceil(diffTime/(24*3600))
    print('=========++++++++++++' .. self.day)
end

function DayChallenge:updateMark()
    if UserData:getUserObj():getSignByType('day_challenge') then
		ActivityMgr:showMark("day_challenge", true)
	else
		ActivityMgr:showMark("day_challenge", false)
	end
end

function DayChallenge:initTop()
    ActivityMgr:showRightDayChallengeRemainTime()
end

function DayChallenge:initLeft()
    local leftBg = self.rootBG:getChildByName('left_bg')
    local img2 = leftBg:getChildByName('img2')
    local des1 = img2:getChildByName('des1')
    local des2 = img2:getChildByName('des2')
    des1:setString(GlobalApi:getLocalStr('ACTIVE_DAY_CHALLENGE_1'))
    des2:setString(GlobalApi:getLocalStr('ACTIVE_DAY_CHALLENGE_2'))

    local _,time = ActivityMgr:getActivityTime("day_challenge")
    local node = cc.Node:create()
    node:setPosition(180,20)
    leftBg:addChild(node)
    Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.BLACK,CDTXTYPE.FRONT,GlobalApi:getLocalStr('ACTIVE_DAY_CHALLENGE_4'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.BLACK,20)

end

function DayChallenge:initRight()
    local rightImg = self.rootBG:getChildByName('right_img')
    local sv = rightImg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = sv:getChildByName('reward_cell')
    rewardCell:getChildByName('get_btn'):getChildByName('text'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell

    self:updateSV()
end

function DayChallenge:updateSV()
    local temp = self.tempData[self.day]
    if not temp then
        return
    end
    local tempData = {}
    for k,v in pairs(temp) do
        if type(v) == "table" then
            table.insert(tempData,v)
        end
    end
    table.sort(tempData,function(a, b)
		return b.id > a.id
	end)

    local num = #tempData
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
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
        self.sv:addChild(tempCell)

        local paid = tempData[i].target

        local awardData = tempData[i].award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,4 do
            local frame = tempCell:getChildByName('frame' .. j)
            local awards = disPlayData[j]
            if awards then
                frame:setVisible(true)

                local cell = ClassItemCell:create(nil,awards,frame)
                cell.awardBgImg:setPosition(cc.p(47,45))
                cell.awardBgImg:loadTexture(awards:getBgImg())
                cell.chipImg:setVisible(true)
                cell.chipImg:loadTexture(awards:getChip())
                cell.lvTx:setString('x'..awards:getNum())
                cell.awardImg:loadTexture(awards:getIcon())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)

                --cell.awardBgImg:setTouchEnabled(false)

            else
                frame:setVisible(false)
            end

        end

        -- ×´Ì¬
        local getBtn = tempCell:getChildByName('get_btn')
        local progress = tempCell:getChildByName('progress')
        local stateImage = tempCell:getChildByName('state_image')
        getBtn.day = paid
        getBtn.progress = progress
        getBtn.stateImage = stateImage
        getBtn.id = tempData[i].id
        getBtn.key = tempData[i].key
        getBtn.tempCell = tempCell
        getBtn.desc = tempCell:getChildByName('desc')
        --getBtn.desc:setString(tempData[i].desc)

        local richText = xx.RichText:create()
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
	    richText:setContentSize(cc.size(5000, 40))
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(getBtn.desc:getPositionX(),getBtn.desc:getPositionY() + 4))
	    tempCell:addChild(richText)

        local re1 = xx.RichTextLabel:create('\n',26, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,tempData[i].desc)
        richText:format(true)

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_day_challenge_award','activity',json.encode({id = tempData[i].id}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        self.msg.day_challenge.rewards[tostring(tempData[i].id)] = 1
                        UserData:getUserObj().activity.day_challenge.rewards = self.msg.day_challenge.rewards

                        self:refreshDay(sender)
			            self:updateMark()
		            end)

            end
        end)
        self:refreshDay(getBtn)
    end
    innerContainer:setPositionY(size.height - allHeight)    
end

function DayChallenge:refreshDay(btn)
    local id = btn.id
    local key = btn.key
    local day = btn.day -- target
    local progress = btn.progress
    local stateImage = btn.stateImage
    local tempCell = btn.tempCell

    tempCell:loadTexture('uires/ui/common/common_bg_6.png')

    local allDays = self.msg.day_challenge.progress[key] or 0
    print('++++++++++++++++++++' .. allDays)
    local reward = self.msg.day_challenge.rewards -- ÖÁÉÙÎª{}
    if allDays >= day then
        if reward[tostring(id)] and tonumber(reward[tostring(id)]) == 1 then           
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

    progress:setString(string.format(GlobalApi:getLocalStr('ACTIVE_DAY_CHALLENGE_3'),allDays > day and day or allDays,day))
end

return DayChallenge