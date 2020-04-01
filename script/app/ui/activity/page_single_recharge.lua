local SingleRecharge = class("SingleRecharge")

local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function SingleRecharge:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
    UserData:getUserObj().activity.single_recharge.rewards = self.msg.single_recharge.rewards
    UserData:getUserObj().activity.single_recharge.money = self.msg.single_recharge.money
    
    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()

    self:updateMark()
end

function SingleRecharge:updateMark()
    if UserData:getUserObj():getSignByType('single_recharge') then
		ActivityMgr:showMark("single_recharge", true)
	else
		ActivityMgr:showMark("single_recharge", false)
	end
end

function SingleRecharge:initData()
    self.tempData = GameData:getConfData('avsinglerecharge')
end

function SingleRecharge:initTop()
    ActivityMgr:showRightSingleRechargeRemainTime()
end

function SingleRecharge:initLeft()
    local leftBg = self.rootBG:getChildByName('leftbg')
    local tipsBg = leftBg:getChildByName('tips_bg')

    local tips = tipsBg:getChildByName('tips')
    local tips2 = tipsBg:getChildByName('tips2')
    local tips3 = tipsBg:getChildByName('tips3')

    tips:setString(GlobalApi:getLocalStr('ACTIVE_SINGLE_RECHARGE_1'))
    tips2:setString(GlobalApi:getLocalStr('ACTIVE_SINGLE_RECHARGE_2'))
    tips3:setString(GlobalApi:getLocalStr('ACTIVE_SINGLE_RECHARGE_4'))
end

function SingleRecharge:initRight()
    local rightBg = self.rootBG:getChildByName('rightbg')
    local sv = rightBg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = rightBg:getChildByName('reward_cell')
    rewardCell:getChildByName('get_btn'):getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    rewardCell:getChildByName('recharge_btn'):getChildByName('info_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES2'))
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell

    self:updateSV()
end


function SingleRecharge:updateSV()
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
        tempCell:setPosition(cc.p(0.2,allHeight - offset))
        self.sv:addChild(tempCell)

        local desc = tempCell:getChildByName('desc')
        local numTx = tempCell:getChildByName('num_tx')
        local moneyTx = tempCell:getChildByName('money')

        desc:setString(GlobalApi:getLocalStr("ACTIVE_SINGLE_RECHARGE_3"))
        numTx:setString(self.tempData[i].money)
        moneyTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP5"))

        numTx:setPositionX(desc:getPositionX() + desc:getContentSize().width + 5)
        moneyTx:setPositionX(numTx:getPositionX() + numTx:getContentSize().width + 5)

        -- 状态相关
        local stage = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        local rechargeBtn = tempCell:getChildByName('recharge_btn')
        getBtn.rechargeBtn = rechargeBtn
        getBtn.day = self.tempData[i].money
        --getBtn.progress = tempCell:getChildByName('titletx')
        --getBtn.numTx = tempCell:getChildByName('num_tx')
        getBtn.stateImage = stage
        getBtn.tempCell = tempCell
        getBtn.i = i

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                    MessageMgr:sendPost('get_single_recharge_award','activity',json.encode({id = i}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        local rewardNum = self.msg.single_recharge.rewards[tostring(i)] or 0
                        self.msg.single_recharge.rewards[tostring(i)] = rewardNum + 1
                        UserData:getUserObj().activity.single_recharge.rewards = self.msg.single_recharge.rewards

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

        -- 中间项,加入道具显示
        local awardData = self.tempData[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,4 do
            local frame = tempCell:getChildByName('frame' .. j)
            local awards = disPlayData[j]
            if awards then
                frame:setVisible(true)
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
                cell.awardBgImg:setScale(84.6/94)
                cell.awardBgImg:setPosition(cc.p(40,36))
                cell.lvTx:setString('x'..awards:getNum())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            else
                frame:setVisible(false)
            end
        end
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function SingleRecharge:refreshDay(btn)
    local i = btn.i
    local day = btn.day
    --local progress = btn.progress
    local stateImage = btn.stateImage
    --local numTx = btn.numTx
    local tempCell = btn.tempCell

    tempCell:loadTexture('uires/ui/common/common_bg_6.png')

    --local allDays = self.msg.single_recharge.money
    --print('++++++++++++++++++++' .. allDays)
    --local reward = self.msg.single_recharge.rewards -- 至少为{}

    --local judge = false
   -- for k,v in pairs(allDays) do
        --if tonumber(v) == day then
           -- judge = true
           -- break
        --end
  --  end

    --[[
    btn.rechargeBtn:setVisible(false)

    if judge == true then
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
        --btn:setVisible(false)
        --stateImage:loadTexture(NOTREATCH)

        btn:setVisible(false)
        stateImage:setVisible(false)
        btn.rechargeBtn:setVisible(true)
    end
    --]]
    --progress:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES1'),allDays > day and day or allDays,day))
    --numTx:setString(day)

    local rechargeNum = self.msg.single_recharge.progress[tostring(i)] or 0
    local hasGetNum = self.msg.single_recharge.rewards[tostring(i)] or 0
    local maxGetNum = self.tempData[i].limitCount

    local infoTx = tempCell:getChildByName('info_tx')
    infoTx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_SINGLE_RECHARGE_5'),hasGetNum,maxGetNum)) 

    local got = tempCell:getChildByName('got')
    local tx = got:getChildByName('tx')
    tx:setString(GlobalApi:getLocalStr('ACTIVE_SINGLE_RECHARGE_6'))

    local gotoBtn = tempCell:getChildByName('recharge_btn')

    -- 单充红点逻辑也要对应改
    if hasGetNum >= maxGetNum then
        btn:setVisible(false)
        got:setVisible(true)
        tx:setVisible(true)
        gotoBtn:setVisible(false)
    elseif hasGetNum < rechargeNum then
        btn:setVisible(true)
        got:setVisible(false)
        tx:setVisible(false)
        gotoBtn:setVisible(false)
    else
        btn:setVisible(false)
        got:setVisible(false)
        tx:setVisible(false)
        gotoBtn:setVisible(true)
    end
end

return SingleRecharge