local ExclusiveCheckTenMainUI = class("ExclusiveCheckTenMainUI", BaseUI)

function ExclusiveCheckTenMainUI:ctor(type)
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_CHECK_TEN_MAIN
    self:initData()
    self.type = type or 2
end

function ExclusiveCheckTenMainUI:init()
    local bgImg = self.root:getChildByName("bg_img")
	self.bgImg1 = bgImg:getChildByName('bg_img1')

    local winSize = cc.Director:getInstance():getWinSize()
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

	local closeBtn = self.root:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:hideExclusiveCheckTenMainUI()
		end
	end)
    closeBtn:setPosition(cc.p(winSize.width + 5,winSize.height - 20))

    local desc = self.root:getChildByName('desc')
    desc:setVisible(false)
    desc:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_77'))
    desc:setPosition(cc.p(winSize.width/2,60))

    local pokeGuang = self.root:getChildByName('poke_guang')
    pokeGuang:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.5, 360)))
    local pokeBtn = self.root:getChildByName('poke_btn')
    local pokeBtnTx = pokeBtn:getChildByName('func_tx')
    pokeBtnTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_1'))
    pokeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            ExclusiveMgr:showExclusivePokedexUI()
		end
	end)
    pokeGuang:setPosition(cc.p(winSize.width - 60,50))
    pokeBtn:setPosition(cc.p(winSize.width - 60,55))

    local size = winSize
	local posY = size.height/2 + 20
    local offset = (size.width - 2*257)/3
    local pl2 = self.root:getChildByName('tavern_2_bg')
    local pl3 = self.root:getChildByName('tavern_3_bg')
    pl2:setPosition(cc.p(offset + 257/2,posY))
    pl3:setPosition(cc.p(size.width - offset - 257/2,posY))
	
    self:update()
end

function ExclusiveCheckTenMainUI:update()
    self:updateOneExclusive()
    self:updateTenExclusive()
    self:updateVipCount()
end

function ExclusiveCheckTenMainUI:onShow()
    self:update()
end

function ExclusiveCheckTenMainUI:initData()
    self.normalDay = tonumber(GlobalApi:getGlobalValue('normalDay'))
    self.mediumDay = tonumber(GlobalApi:getGlobalValue('mediumDay'))
    self.superDay = tonumber(GlobalApi:getGlobalValue('superDay'))
    self.mediumCost = tonumber(GlobalApi:getGlobalValue('mediumCost'))
    self.superCost = tonumber(GlobalApi:getGlobalValue('superCost'))
    self.mediumTicket = tonumber(GlobalApi:getGlobalValue('mediumTicket'))
    self.superTicket = tonumber(GlobalApi:getGlobalValue('superTicket'))
    self.normalTicket = tonumber(GlobalApi:getGlobalValue('normalTicket'))
    self.mediumDiscount = tonumber(GlobalApi:getGlobalValue('mediumDiscount'))
    self.superDiscount = tonumber(GlobalApi:getGlobalValue('superDiscount'))
end

function ExclusiveCheckTenMainUI:updateVipCount()
    if self.root:getChildByName('rich_text') then
        self.root:removeChildByName('rich_text')
    end

    local vip = UserData:getUserObj():getVip()
    local vipData = GameData:getConfData('vip')[tostring(vip)]
    local allNums = vipData.mediumTimes
    local desc = GlobalApi:getLocalStr('EXCLUSIVE_DESC_79')
    local hasUseCount = UserData:getUserObj():getIdentity().medium
    if self.type == 3 then
        allNums = vipData.superTimes
        desc = GlobalApi:getLocalStr('EXCLUSIVE_DESC_80')
        hasUseCount = UserData:getUserObj():getIdentity().super
    end

    local richText = xx.RichText:create()
    richText:setName('rich_text')
	richText:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_87') .. desc, 22, COLOR_TYPE.WHITE)
	re1:setStroke(cc.c4b(0,0,0,255),1)
    re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    local showCount = allNums - hasUseCount
    if showCount <= 0 then
        showCount = 0
    end
    local re2 = xx.RichTextLabel:create(showCount, 28, COLOR_TYPE.GREEN)
	re2:setStroke(cc.c4b(0,0,0,255),1)
    re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_84'), 28, COLOR_TYPE.WHITE)
	re3:setStroke(cc.c4b(0,0,0,255),1)
    re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
	richText:setPosition(cc.p(winSize.width/2,60))
    self.root:addChild(richText)
    richText:format(true)

end

function ExclusiveCheckTenMainUI:timeoutCallback(parent ,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
    if parent:getChildByTag(9527) then
	    parent:removeChildByTag(9527)
    end
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK, GlobalApi:getLocalStr('TRVEN_DESC_1'),cc.c3b(255,255,255),cc.c4b(0,0,0,255),22,function ()
		if diffTime <= 0 then
			parent:removeAllChildren()
		else
			self:timeoutCallback(parent ,time)
		end
	end)
end

function ExclusiveCheckTenMainUI:updateOneExclusive()
    local pl = self.root:getChildByName('tavern_2_bg')
	local newImg = pl:getChildByName('new_img')
    newImg:setLocalZOrder(9999)
    if self.type == 2 then
        newImg:setVisible(UserData:getUserObj():judgeExclusiveMiddleFreeState())
    else
    	newImg:setVisible(UserData:getUserObj():judgeExclusiveSuperFreeState())
    end
	pl:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:recuitTen(2,1)
		end
	end)

    local name = pl:getChildByName('name')
    name:setString('')
    local text1 = GlobalApi:getLocalStr('EXCLUSIVE_DESC_79')
    local trvernIcon = pl:getChildByName('trvern_icon')
    pl:loadTexture('uires/ui/exclusive/exclusive_22.png')
    trvernIcon:loadTexture('uires/ui/exclusive/exclusive_tubiao2.png')
    local color = cc.c4b(58,205,248,255)
    if self.type == 3 then
        text1 = GlobalApi:getLocalStr('EXCLUSIVE_DESC_80')
        pl:loadTexture('uires/ui/exclusive/exclusive_33.png')
        trvernIcon:loadTexture('uires/ui/exclusive/exclusive_tubiao3.png')
        color = cc.c4b(246,255,0,255)
    end
    if pl:getChildByName('rich_text2') then
        pl:removeChildByName('rich_text2')
    end
    local richText2 = xx.RichText:create()
    richText2:setName('rich_text2')
	richText2:setContentSize(cc.size(600, 43))
	local re1 = xx.RichTextLabel:create(text1, 22, color)
	re1:setStroke(cc.c4b(0,0,0,255),2)
    re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	richText2:addElement(re1)
    richText2:setAlignment('middle')
    richText2:setVerticalAlignment('middle')
	richText2:setAnchorPoint(cc.p(0.5,0.5))
	richText2:setPosition(cc.p(name:getPositionX(),name:getPositionY()))
    pl:addChild(richText2)
    richText2:format(true)

    local numIcon = pl:getChildByName('num_icon')
    local numTx = pl:getChildByName('num_tx')

    local costCash = self.mediumCost
    local costTicket = self.mediumTicket
    local day = UserData:getUserObj():getIdentity().medium_day
    local hasUseNum = UserData:getUserObj():getIdentity().medium
    local iconUrl = 'uires/icon/user/hcheck.png'
    local dayAfter = self.mediumDay
    if self.type == 3 then
        costCash = self.superCost
        costTicket = self.superTicket
        day = UserData:getUserObj():getIdentity().super_day
        hasUseNum = UserData:getUserObj():getIdentity().super
        dayAfter = self.superDay
    end

    local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')
    if day == 0 then
        numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
		numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
        numIcon:loadTexture(iconUrl)
    else
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + dayAfter * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
	    if diffTime > 0 then
            self:timeoutCallback(desc3,endTime)
            local ownNum = UserData:getUserObj():getHcheck()
            if ownNum < costTicket then
                numIcon:loadTexture('uires/icon/user/cash.png')
		        numTx:setString(costCash)
		        if UserData:getUserObj():getCash() >= costCash then
			        numTx:setTextColor(cc.c3b(255,255,255))
			        numTx:enableOutline(cc.c4b(0,0,0,255),2)
		        else
			        numTx:setTextColor(cc.c3b(255,0,0))
			        numTx:enableOutline(cc.c4b(65,8,8,255),2)
		        end
	        else
		        numTx:setTextColor(cc.c3b(255,255,255))
		        numTx:enableOutline(cc.c4b(0,0,0,255),2)
                numTx:setString(costTicket)
                numIcon:loadTexture(iconUrl)
	        end

        else
		    numTx:setTextColor(cc.c3b(255,255,255))
		    numTx:enableOutline(cc.c4b(0,0,0,255),2)
		    numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
            numIcon:loadTexture(iconUrl)
        end
    end

    if pl:getChildByName('rich_text') then
        pl:removeChildByName('rich_text')
    end
    if self.type == 2 then
        local richText = xx.RichText:create()
        richText:setName('rich_text')
	    richText:setContentSize(cc.size(600, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_82'), 22, COLOR_TYPE.WHITE)
	    re1:setStroke(cc.c4b(0,0,0,255),1)
        re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
        local re2 = xx.RichTextLabel:create('1-6', 22, COLOR_TYPE.YELLOW)
	    re2:setStroke(cc.c4b(0,0,0,255),1)
        re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_83'), 22, COLOR_TYPE.WHITE)
	    re3:setStroke(cc.c4b(0,0,0,255),1)
        re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(257/2,40))
        pl:addChild(richText)
        richText:format(true)
    else
        local richText = xx.RichText:create()
        richText:setName('rich_text')
	    richText:setContentSize(cc.size(600, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_82'), 22, COLOR_TYPE.WHITE)
	    re1:setStroke(cc.c4b(0,0,0,255),1)
        re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
        local re2 = xx.RichTextLabel:create('3-6', 22, COLOR_TYPE.YELLOW)
	    re2:setStroke(cc.c4b(0,0,0,255),1)
        re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_83'), 22, COLOR_TYPE.WHITE)
	    re3:setStroke(cc.c4b(0,0,0,255),1)
        re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(257/2,40))
        pl:addChild(richText)
        richText:format(true)
    end
end

function ExclusiveCheckTenMainUI:updateTenExclusive()
    local pl = self.root:getChildByName('tavern_3_bg')
	local newImg = pl:getChildByName('new_img')
    newImg:setLocalZOrder(9999)
	newImg:setVisible(false)
	pl:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:recuitTen(2,5)
		end
	end)
    
    local name = pl:getChildByName('name')
    name:setString('')
    local text1 = GlobalApi:getLocalStr('EXCLUSIVE_DESC_79')
    local trvernIcon = pl:getChildByName('trvern_icon')
    pl:loadTexture('uires/ui/exclusive/exclusive_22.png')
    trvernIcon:loadTexture('uires/ui/exclusive/exclusive_tubiao2.png')
    local color = cc.c4b(58,205,248,255)
    if self.type == 3 then
        text1 = GlobalApi:getLocalStr('EXCLUSIVE_DESC_80')
        pl:loadTexture('uires/ui/exclusive/exclusive_33.png')
        trvernIcon:loadTexture('uires/ui/exclusive/exclusive_tubiao3.png')
        color = cc.c4b(246,255,0,255)
    end
    if pl:getChildByName('rich_text2') then
        pl:removeChildByName('rich_text2')
    end
    local richText2 = xx.RichText:create()
    richText2:setName('rich_text2')
	richText2:setContentSize(cc.size(600, 43))
	local re1 = xx.RichTextLabel:create(text1, 22, color)
	re1:setStroke(cc.c4b(0,0,0,255),2)
    re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	richText2:addElement(re1)
    richText2:setAlignment('middle')
    richText2:setVerticalAlignment('middle')
	richText2:setAnchorPoint(cc.p(0.5,0.5))
	richText2:setPosition(cc.p(name:getPositionX(),name:getPositionY()))
    pl:addChild(richText2)
    richText2:format(true)

    local numIcon = pl:getChildByName('num_icon')
    local numTx = pl:getChildByName('num_tx')

    local costCash = self.mediumCost*5*self.mediumDiscount/10
    local costTicket = self.mediumTicket*5*self.mediumDiscount/10
    local hasUseNum = UserData:getUserObj():getIdentity().medium
    local iconUrl = 'uires/icon/user/hcheck.png'
    if self.type == 3 then
        costCash = self.superCost*5*self.superDiscount/10
        costTicket = self.superTicket*5*self.superDiscount/10
        hasUseNum = UserData:getUserObj():getIdentity().super
    end
    local ownNum = UserData:getUserObj():getHcheck()
	if ownNum < costTicket then
        numIcon:loadTexture('uires/icon/user/cash.png')
		numTx:setString(costCash)
		if UserData:getUserObj():getCash() >= costCash then
			numTx:setTextColor(cc.c3b(255,255,255))
			numTx:enableOutline(cc.c4b(0,0,0,255),2)
		else
			numTx:setTextColor(cc.c3b(255,0,0))
			numTx:enableOutline(cc.c4b(65,8,8,255),2)
		end
	else
		numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
        numIcon:loadTexture(iconUrl)
        numTx:setString(costTicket)
	end

    local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')

    if pl:getChildByName('rich_text') then
        pl:removeChildByName('rich_text')
    end
    if self.type == 2 then
        local richText = xx.RichText:create()
        richText:setName('rich_text')
	    richText:setContentSize(cc.size(600, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_82'), 22, COLOR_TYPE.WHITE)
	    re1:setStroke(cc.c4b(0,0,0,255),1)
        re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
        local re2 = xx.RichTextLabel:create('1-6', 22, COLOR_TYPE.YELLOW)
	    re2:setStroke(cc.c4b(0,0,0,255),1)
        re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_83'), 22, COLOR_TYPE.WHITE)
	    re3:setStroke(cc.c4b(0,0,0,255),1)
        re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(257/2,40))
        pl:addChild(richText)
        richText:format(true)
    else
        local richText = xx.RichText:create()
        richText:setName('rich_text')
	    richText:setContentSize(cc.size(600, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_82'), 22, COLOR_TYPE.WHITE)
	    re1:setStroke(cc.c4b(0,0,0,255),1)
        re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
        local re2 = xx.RichTextLabel:create('3-6', 22, COLOR_TYPE.YELLOW)
	    re2:setStroke(cc.c4b(0,0,0,255),1)
        re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_83'), 22, COLOR_TYPE.WHITE)
	    re3:setStroke(cc.c4b(0,0,0,255),1)
        re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(257/2,40))
        pl:addChild(richText)
        richText:format(true)
    end

    local richText3 = xx.RichText:create()
    richText3:setName('rich_text')
	richText3:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_102'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(cc.c4b(0,0,0,255),1)
    re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create(5, 22, COLOR_TYPE.GREEN)
	re2:setStroke(cc.c4b(0,0,0,255),1)
    re2:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_84'), 22, COLOR_TYPE.WHITE)
	re3:setStroke(cc.c4b(0,0,0,255),1)
    re3:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')
	richText3:addElement(re1)
    richText3:addElement(re2)
    richText3:addElement(re3)
    richText3:setAlignment('middle')
    richText3:setVerticalAlignment('middle')
	richText3:setAnchorPoint(cc.p(0.5,0.5))
	richText3:setPosition(cc.p(257/2,140))
    pl:addChild(richText3)
    richText3:format(true)
end

function ExclusiveCheckTenMainUI:recuitTen(recuitType,drawNum)
    local vip = UserData:getUserObj():getVip()
    local vipData = GameData:getConfData('vip')[tostring(vip)]
    if self.type == 2 then
        local isFree = true
        local day = UserData:getUserObj():getIdentity().medium_day
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.mediumDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
        if day ~= 0 and diffTime > 0 then
            isFree = false
        end

        if drawNum == 5 then
            isFree = false
        end

        local function callBack()
            local args = {
                time = drawNum
		    }

		    MessageMgr:sendPost("medium_identify", "exclusive", json.encode(args), function (jsonObj)
			    print(json.encode(jsonObj))
			    local code = jsonObj.code
			    if code == 0 then
				    local awards = jsonObj.data.awards
				    GlobalApi:parseAwardData(awards)
				    local costs = jsonObj.data.costs
				    if costs then
					    GlobalApi:parseAwardData(costs)
				    end

                    if isFree == true then
                        local now = os.date('*t',tonumber(GlobalData:getServerTime()))
                        local dayLimit = 0
                        if now.hour < 5 then
                            dayLimit = 1
                        end
		                UserData:getUserObj():getIdentity().medium_day = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime() - dayLimit*86400))
                    else
                        UserData:getUserObj():getIdentity().medium = UserData:getUserObj():getIdentity().medium + drawNum
                    end
				    ExclusiveMgr:showExclusiveAnimateUI(awards, function ()
					    self:update()
				    end,recuitType,drawNum)
			    end
		    end)
        end
            
        if isFree == false then
            local hasUseNum = UserData:getUserObj():getIdentity().medium
            if vipData.mediumTimes - hasUseNum < drawNum then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_98'),COLOR_TYPE.RED)
                return
            end

            local costCash = self.mediumCost
            local costTicket = self.mediumTicket
            if drawNum == 5 then
                costCash = self.mediumCost*5*self.mediumDiscount/10
                costTicket = self.mediumTicket*5*self.mediumDiscount/10
            end
            if UserData:getUserObj():getHcheck() < costTicket then
                local hasCash = UserData:getUserObj():getCash()
                if costCash > hasCash then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                else
                    local desc = string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_97'),costCash)
                    if drawNum == 5 then
                        desc = string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_96'),costCash)
                    end
                    promptmgr:showMessageBox(desc,
                        MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            callBack()
                        end)
                end
            else
                callBack()
            end
        else
            callBack()
        end
    else    
        local isFree = true
        local day = UserData:getUserObj():getIdentity().super_day
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.superDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
        if day ~= 0 and diffTime > 0 then
            isFree = false
        end

        if drawNum == 5 then
            isFree = false
        end

        local function callBack()
            local args = {
                time = drawNum
		    }

		    MessageMgr:sendPost("super_identify", "exclusive", json.encode(args), function (jsonObj)
			    print(json.encode(jsonObj))
			    local code = jsonObj.code
			    if code == 0 then
				    local awards = jsonObj.data.awards
				    GlobalApi:parseAwardData(awards)
				    local costs = jsonObj.data.costs
				    if costs then
					    GlobalApi:parseAwardData(costs)
				    end

                    if isFree == true then
                        local now = os.date('*t',tonumber(GlobalData:getServerTime()))
                        local dayLimit = 0
                        if now.hour < 5 then
                            dayLimit = 1
                        end
		                UserData:getUserObj():getIdentity().super_day = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime() - dayLimit*86400))
                    else
                        UserData:getUserObj():getIdentity().super = UserData:getUserObj():getIdentity().super + drawNum
                    end
				    ExclusiveMgr:showExclusiveAnimateUI(awards, function ()
					    self:update()
				    end,recuitType,drawNum)
			    end
		    end)
        end
            
        if isFree == false then
            local hasUseNum = UserData:getUserObj():getIdentity().super
            if vipData.superTimes - hasUseNum < drawNum then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_98'),COLOR_TYPE.RED)
                return
            end

            local costCash = self.superCost
            local costTicket = self.superTicket
            if drawNum == 5 then
                costCash = self.superCost*5*self.superDiscount/10
                costTicket = self.superTicket*5*self.superDiscount/10
            end
            if UserData:getUserObj():getHcheck() < costTicket then
                local hasCash = UserData:getUserObj():getCash()
                if costCash > hasCash then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                else
                    local desc = string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_97'),costCash)
                    if drawNum == 5 then
                        desc = string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_96'),costCash)
                    end
                    promptmgr:showMessageBox(desc,
                        MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            callBack()
                        end)
                end
            else
                callBack()
            end
        else
            callBack()
        end
    end

end

return ExclusiveCheckTenMainUI