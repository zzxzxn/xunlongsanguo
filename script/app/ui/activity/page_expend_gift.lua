local ExpendGift = class("expend_gift")
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function ExpendGift:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.expend_gift.rewards = self.msg.expend_gift.rewards
    UserData:getUserObj().activity.expend_gift.paid = self.msg.expend_gift.paid

    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()

    self:updateMark()
end

function ExpendGift:initData()
    self.tempData = GameData:getConfData('avexpendgift')

end

function ExpendGift:updateMark()
    if UserData:getUserObj():getSignByType('expend_gift') then
		ActivityMgr:showMark("expend_gift", true)
	else
		ActivityMgr:showMark("expend_gift", false)
	end
end

function ExpendGift:initTop()
    ActivityMgr:showRightExpendGiftRemainTime()
end

function ExpendGift:initLeft()
    local tipsBg = self.rootBG:getChildByName('tips_bg')
    local tips = tipsBg:getChildByName('tips')
    local tips2 = tipsBg:getChildByName('tips2')
    
    tips:setFontSize(24)
    tips2:setFontSize(24)
    tips:setString(GlobalApi:getLocalStr('ACTIVE_EXPEND_GIFT_DES1'))
    tips2:setString(GlobalApi:getLocalStr('ACTIVE_EXPEND_GIFT_DES2'))
end

function ExpendGift:initRight()
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

function ExpendGift:updateSV()
    local num = #self.tempData
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

        local paid = self.tempData[i].paid
        tempCell:getChildByName('desc'):setString(string.format(GlobalApi:getLocalStr('ACTIVE_EXPEND_GIFT_DES3'),paid))
        
        local awardData = self.tempData[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,4 do
            local frame = tempCell:getChildByName('frame' .. j)
            local awards = disPlayData[j]
            if awards then
                frame:setVisible(true)
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
                cell.awardBgImg:setPosition(cc.p(47,45))
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
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
        getBtn.i = i

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_expend_gift_award','activity',json.encode({id = i}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        self.msg.expend_gift.rewards[tostring(i)] = 1
                        UserData:getUserObj().activity.expend_gift.rewards = self.msg.expend_gift.rewards

                        self:refreshDay(sender)
			            self:updateMark()
		            end)

            end
        end)
        self:refreshDay(getBtn)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function ExpendGift:refreshDay(btn)
    local i = btn.i
    local day = btn.day
    local progress = btn.progress
    local stateImage = btn.stateImage

    local allDays = self.msg.expend_gift.paid
    --print('++++++++++++++++++++' .. allDays)
    local reward = self.msg.expend_gift.rewards -- ÖÁÉÙÎª{}
    if allDays >= day then
        if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then           
            btn:setVisible(false)
            stateImage:setVisible(true)
            stateImage:loadTexture(HASGETAWARD)
        else
            btn:setVisible(true)
            stateImage:setVisible(false)
        end
    else
        btn:setVisible(false)
        stateImage:loadTexture(NOTREATCH)
    end

    progress:setString(string.format(GlobalApi:getLocalStr('LOGIN_GOOD_GIFT4'),allDays > day and day or allDays,day))
end

return ExpendGift