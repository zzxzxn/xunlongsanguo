local LoginGoodGift = class("LoginGoodGift")
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidacheng.png'
local HASGETAWARD = 'uires/ui/activity/yilingqu.png'

function LoginGoodGift:init(msg)
    self.rootBG = self.root:getChildByName("root")
	self.cells = {}

    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()

    self:updateMark()
	
end

function LoginGoodGift:initData()
    self.tempData = GameData:getConfData('avlogingift')

end


function LoginGoodGift:updateMark()
    if UserData:getUserObj():getSignByType('login_goodgift') then
		ActivityMgr:showMark("login_goodgift", true)
	else
		ActivityMgr:showMark("login_goodgift", false)
	end
end

function LoginGoodGift:initTop()
    ActivityMgr:showRightLoginGoodGiftRemainTime()
end

function LoginGoodGift:initLeft()
    local tipsBg = self.rootBG:getChildByName('tips_bg')
    local tips = tipsBg:getChildByName('tips')
    local tips2 = tipsBg:getChildByName('tips2')
    
    tips:setString(GlobalApi:getLocalStr('LOGIN_GOOD_GIFT1'))
    tips2:setString(GlobalApi:getLocalStr('LOGIN_GOOD_GIFT2'))
end

function LoginGoodGift:initRight()
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

function LoginGoodGift:updateSV()
	for i = 1,#self.cells,1 do
		self.cells[i]:removeFromParent()
	end
	self.cells = {}

	local reward = UserData:getUserObj().activity.login_goodgift.reward
	local confData = {}
    for i = 1,#self.tempData do
        local v = clone(self.tempData[i])
        local curStep = UserData:getUserObj().activity.login_goodgift.login
        local needStep = tonumber(v.day)
        v.showStatus = 2
        if curStep >= needStep then    -- 进度达成
            if reward[tostring(needStep)] and tonumber(reward[tostring(needStep)]) == 1 then
                v.showStatus = 1            
            else
                v.showStatus = 3
            end
        end
        table.insert(confData,v)
    end

    table.sort(confData,function(a, b)
        if a.showStatus == b.showStatus then
            return tonumber(a.day) < tonumber(b.day)
        else
            return a.showStatus > b.showStatus
        end
	end)


    local num = #confData
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
		table.insert(self.cells,tempCell)
        
        tempCell:getChildByName('desc'):setString(string.format(GlobalApi:getLocalStr('LOGIN_GOOD_GIFT3'),confData[i].day))
        
        local awardData = confData[i].award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,4 do
            local frame = tempCell:getChildByName('frame' .. j)
            local awards = disPlayData[j]
            if awards then
                frame:setVisible(true)
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
                cell.awardBgImg:setPosition(cc.p(47,45))
                cell.lvTx:setString('x'..awards:getNum())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            else
                frame:setVisible(false)
            end
        end

        -- 状态
        local getBtn = tempCell:getChildByName('get_btn')
        local progress = tempCell:getChildByName('progress')
        local stateImage = tempCell:getChildByName('state_image')
        getBtn.day = tonumber(confData[i].day)
        getBtn.progress = progress
        getBtn.stateImage = stateImage

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_login_goodgift','activity',json.encode({day = sender.day}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        UserData:getUserObj().activity.login_goodgift.reward[tostring(sender.day)] = 1
                        --self:refreshDay(sender)
			            self:updateMark()

						self:updateSV()

		            end)

            end
        end)
        self:refreshDay(getBtn)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function LoginGoodGift:refreshDay(btn)
    local day = btn.day
    local progress = btn.progress
    local stateImage = btn.stateImage

    local allDays = UserData:getUserObj().activity.login_goodgift.login
    --print('++++++++++++++++++++' .. allDays)
    local reward = UserData:getUserObj().activity.login_goodgift.reward -- 至少为{}
    if allDays >= day then
        if reward[tostring(day)] and tonumber(reward[tostring(day)]) == 1 then           
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

return LoginGoodGift