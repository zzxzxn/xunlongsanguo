local AccumulateRecharge = class("accumulate_recharge")
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function AccumulateRecharge:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.accumulate_recharge.rewards = self.msg.accumulate_recharge.rewards
    UserData:getUserObj().activity.accumulate_recharge.paid = self.msg.accumulate_recharge.paid

    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()

    self:updateMark()
end

function AccumulateRecharge:initData()
    self.tempData = GameData:getConfData('avaccumulaterecharge')

end


function AccumulateRecharge:updateMark()
    if UserData:getUserObj():getSignByType('accumulate_recharge') then
		ActivityMgr:showMark("accumulate_recharge", true)
	else
		ActivityMgr:showMark("accumulate_recharge", false)
	end
end

function AccumulateRecharge:initTop()
    ActivityMgr:showRightAccumulateRechargeRemainTime()
end

function AccumulateRecharge:initLeft()
    local tipsBg = self.rootBG:getChildByName('tips_bg')
    local tips = tipsBg:getChildByName('tips')
    local tips2 = tipsBg:getChildByName('tips2')
    
    tips:setString(GlobalApi:getLocalStr('ACCUMULATE_RECHARGE_1'))
    tips2:setString(GlobalApi:getLocalStr('ACCUMULATE_RECHARGE_2'))
end

function AccumulateRecharge:initRight()
    local rightImg = self.rootBG:getChildByName('right_img')
    local sv = rightImg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = sv:getChildByName('reward_cell')
    rewardCell:getChildByName('get_btn'):getChildByName('text'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    rewardCell:getChildByName('recharge_btn'):getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES2'))
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell

    self:updateSV()
end

function AccumulateRecharge:updateSV()
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

        local needRechargeGoldNumber = self.tempData[i].needRechargeGoldNumber
        tempCell:getChildByName('desc'):setString(string.format(GlobalApi:getLocalStr('ACCUMULATE_RECHARGE_3'),needRechargeGoldNumber))
        
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
        local rechargeBtn = tempCell:getChildByName('recharge_btn')
        getBtn.rechargeBtn = rechargeBtn
        getBtn.day = needRechargeGoldNumber
        getBtn.progress = progress
        getBtn.stateImage = stateImage
        getBtn.i = i

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_accumulate_recharge_award','activity',json.encode({id = i}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        self.msg.accumulate_recharge.rewards[tostring(i)] = 1
                        UserData:getUserObj().activity.accumulate_recharge.rewards = self.msg.accumulate_recharge.rewards

                        UserData:getUserObj().tips.accumulate_recharge = 0

                        self:refreshDay(sender)
			            self:updateMark()
		            end)

            end
        end)

        rechargeBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                GlobalApi:getGotoByModule('cash')
                ActivityMgr:hideUI()
            end
        end)

        self:refreshDay(getBtn)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function AccumulateRecharge:refreshDay(btn)
    local i = btn.i
    local day = btn.day
    local progress = btn.progress
    local stateImage = btn.stateImage

    btn.rechargeBtn:setVisible(false)

    local allDays = self.msg.accumulate_recharge.paid
    --print('++++++++++++++++++++' .. allDays)
    local reward = self.msg.accumulate_recharge.rewards -- ÖÁÉÙÎª{}
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
        --btn:setVisible(false)
        --stateImage:loadTexture(NOTREATCH)

        btn:setVisible(false)
        stateImage:setVisible(false)
        btn.rechargeBtn:setVisible(true)
    end

    progress:setString(string.format(GlobalApi:getLocalStr('LOGIN_GOOD_GIFT4'),allDays > day and day or allDays,day))
end

return AccumulateRecharge