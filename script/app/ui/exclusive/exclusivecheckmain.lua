local ExclusiveCheckMainUI = class("ExclusiveCheckMainUI", BaseUI)

function ExclusiveCheckMainUI:ctor()
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_CHECK_MAIN
    self:initData()
    
end

function ExclusiveCheckMainUI:init()
    local bgImg = self.root:getChildByName("bg_img")
	self.bgImg1 = bgImg:getChildByName('bg_img1')

    local winSize = cc.Director:getInstance():getWinSize()
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

	local closeBtn = self.root:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:hideExclusiveCheckMainUI()
		end
	end)
    closeBtn:setPosition(cc.p(winSize.width,winSize.height - 15))

    local desc = self.root:getChildByName('desc')
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
    local offset = (size.width - 3*257)/4
    local pl1 = self.root:getChildByName('tavern_1_bg')
    local pl2 = self.root:getChildByName('tavern_2_bg')
    local pl3 = self.root:getChildByName('tavern_3_bg')
    pl2:setPosition(cc.p(size.width/2,posY))
    pl1:setPosition(cc.p(size.width/2 - offset - 257,posY))
    pl3:setPosition(cc.p(size.width/2 + offset + 257,posY))

    self:update()
end

function ExclusiveCheckMainUI:update()
    self:updateNormalExclusive()
    self:updateMiddleExclusive()
    self:updateHighExclusive()
end

function ExclusiveCheckMainUI:onShow()
    self:update()
end

function ExclusiveCheckMainUI:initData()
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

function ExclusiveCheckMainUI:timeoutCallback(parent ,time)
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

function ExclusiveCheckMainUI:updateNormalExclusive()
    local pl = self.root:getChildByName('tavern_1_bg')
	local newImg = pl:getChildByName('new_img')
	newImg:setVisible(UserData:getUserObj():judgeExclusiveNormalFreeState())
	pl:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:recuit(1)
		end
	end)

    local name = pl:getChildByName('name')
    name:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_78'))

    local numIcon = pl:getChildByName('num_icon')
    numIcon:loadTexture('uires/icon/user/ncheck.png')

    local numTx = pl:getChildByName('num_tx')
	numTx:setString(self.normalTicket)
    local ownNum = UserData:getUserObj():getNcheck()
	if ownNum < self.normalTicket then
		numTx:setTextColor(cc.c3b(255,0,0))
		numTx:enableOutline(cc.c4b(65,8,8,255),2)
	else
		numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
	end

    local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')
    local day = UserData:getUserObj():getIdentity().normal_day
    if day == 0 then
		numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
		numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
    else
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.normalDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
	    if diffTime > 0 then
            self:timeoutCallback(desc3,endTime)
        else
		    numTx:setTextColor(cc.c3b(255,255,255))
		    numTx:enableOutline(cc.c4b(0,0,0,255),2)
		    numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
        end
    end

    if pl:getChildByName('rich_text') then
        pl:removeChildByName('rich_text')
    end
    local richText = xx.RichText:create()
    richText:setName('rich_text')
	richText:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_81'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(cc.c4b(0,0,0,255),1)
    re1:setShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	richText:addElement(re1)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(257/2,40))
    pl:addChild(richText)
    richText:format(true)

end

function ExclusiveCheckMainUI:updateMiddleExclusive()
    local pl = self.root:getChildByName('tavern_2_bg')
	local newImg = pl:getChildByName('new_img')
	newImg:setVisible(UserData:getUserObj():judgeExclusiveMiddleFreeState())
	pl:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:showExclusiveCheckTenMainUI(2)
		end
	end)

    local name = pl:getChildByName('name')
    name:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_79'))

    local numIcon = pl:getChildByName('num_icon')
    local numTx = pl:getChildByName('num_tx')

	local numIcon1 = pl:getChildByName('num_icon_1')
	local numIcon2 = pl:getChildByName('num_icon_2')
	numIcon:setVisible(true)
	numIcon1:setVisible(false)
	numIcon2:setVisible(false)

    local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')
    local day = UserData:getUserObj():getIdentity().medium_day
    if day == 0 then
        numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
		numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
        numIcon:loadTexture('uires/icon/user/hcheck.png')
    else
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.mediumDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
	    if diffTime > 0 then
            self:timeoutCallback(desc3,endTime)
            local ownNum = UserData:getUserObj():getHcheck()
            if ownNum < self.mediumTicket then
				numIcon:setVisible(false)
				numIcon1:setVisible(true)
				numIcon2:setVisible(true)
		        numTx:setString(self.mediumCost)
		        if UserData:getUserObj():getCash() >= self.mediumCost then
			        numTx:setTextColor(cc.c3b(255,255,255))
			        numTx:enableOutline(cc.c4b(0,0,0,255),2)
		        else
			        numTx:setTextColor(cc.c3b(255,0,0))
			        numTx:enableOutline(cc.c4b(65,8,8,255),2)
		        end
	        else
		        numTx:setTextColor(cc.c3b(255,255,255))
		        numTx:enableOutline(cc.c4b(0,0,0,255),2)
                numTx:setString(self.mediumTicket)
                numIcon:loadTexture('uires/icon/user/hcheck.png')
	        end

        else
		    numTx:setTextColor(cc.c3b(255,255,255))
		    numTx:enableOutline(cc.c4b(0,0,0,255),2)
		    numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
            numIcon:loadTexture('uires/icon/user/hcheck.png')
        end
    end

    if pl:getChildByName('rich_text') then
        pl:removeChildByName('rich_text')
    end
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
end

function ExclusiveCheckMainUI:updateHighExclusive()
    local pl = self.root:getChildByName('tavern_3_bg')
	local newImg = pl:getChildByName('new_img')
	newImg:setVisible(UserData:getUserObj():judgeExclusiveSuperFreeState())
	pl:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:showExclusiveCheckTenMainUI(3)
		end
	end)

    local name = pl:getChildByName('name')
    name:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_80'))

    local numIcon = pl:getChildByName('num_icon')

    local numTx = pl:getChildByName('num_tx')
	numTx:setString(self.superTicket)

	local numIcon1 = pl:getChildByName('num_icon_1')
	local numIcon2 = pl:getChildByName('num_icon_2')
	numIcon:setVisible(true)
	numIcon1:setVisible(false)
	numIcon2:setVisible(false)

    local ownNum = UserData:getUserObj():getHcheck()
	if ownNum < self.superTicket then
		numIcon:setVisible(false)
		numIcon1:setVisible(true)
		numIcon2:setVisible(true)
		numTx:setString(self.superCost)
		if UserData:getUserObj():getCash() >= self.superCost then
			numTx:setTextColor(cc.c3b(255,255,255))
			numTx:enableOutline(cc.c4b(0,0,0,255),2)
		else
			numTx:setTextColor(cc.c3b(255,0,0))
			numTx:enableOutline(cc.c4b(65,8,8,255),2)
		end
	else
		numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
        numIcon:loadTexture('uires/icon/user/hcheck.png')
	end

    local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')
    local day = UserData:getUserObj():getIdentity().super_day
	local isFree = false	
    if day == 0 then
		numTx:setTextColor(cc.c3b(255,255,255))
		numTx:enableOutline(cc.c4b(0,0,0,255),2)
		numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
		isFree = true
    else
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.superDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
	    if diffTime > 0 then
            self:timeoutCallback(desc3,endTime)
        else
		    numTx:setTextColor(cc.c3b(255,255,255))
		    numTx:enableOutline(cc.c4b(0,0,0,255),2)
		    numTx:setString(GlobalApi:getLocalStr('FREE_TIME'))
			isFree = true
        end
    end

	if isFree == true then
		numIcon:loadTexture('uires/icon/user/cash.png')
		numIcon:setVisible(true)
		numIcon1:setVisible(false)
		numIcon2:setVisible(false)
	end

    if pl:getChildByName('rich_text') then
        pl:removeChildByName('rich_text')
    end
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

function ExclusiveCheckMainUI:recuit(recuitType)
    if recuitType == 1 then
        local isFree = true
        local day = UserData:getUserObj():getIdentity().normal_day
        local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    	local endTime = beginTime + self.normalDay * 86400 
        local diffTime = endTime - GlobalData:getServerTime()
        if day ~= 0 and diffTime > 0 then
            isFree = false
        end

        if isFree == false and UserData:getUserObj():getNcheck() < self.normalTicket then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_95'),self.normalTicket),COLOR_TYPE.RED)
            return
        end
        
		local args = {}
		MessageMgr:sendPost("normal_identify", "exclusive", json.encode(args), function (jsonObj)
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
		            UserData:getUserObj():getIdentity().normal_day = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime() - dayLimit*86400))
                end
				ExclusiveMgr:showExclusiveAnimateUI(awards, function ()
					self:update()
				end,recuitType,1)
			end
		end)
    end
end

return ExclusiveCheckMainUI