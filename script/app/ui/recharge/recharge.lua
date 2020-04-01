local RechargeUI = class("RechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local pos = {cc.p(85,270),cc.p(225,270),cc.p(365,270),cc.p(85,170),cc.p(225,170),cc.p(365,170)}
function RechargeUI:ctor(vip)
	self.uiIndex = GAME_UI.UI_RECHARGE
	self.cells = {}
    if vip then
        self.page = 2
	    self.vipPage = vip
    else
        self.page = page or 1
	    self.vipPage = UserData:getUserObj():getVip()
    end
	self.maxPage = 0
	local vipConf = GameData:getConfData('vip')
	for k,v in pairs(vipConf) do
		if tonumber(v.level) > self.maxPage then
			self.maxPage = tonumber(v.level)
		end
	end
	self.descRts = {}
end

function RechargeUI:getVip(cash)

	local vipConf = GameData:getConfData('vip')
	-- local vip = 0
	local tab
	local nextVipId = 0
	for i=0,self.maxPage do
		if vipConf[tostring(i)].cash <= cash then
			-- vip = vipConf[tostring(i)].level
			tab = vipConf[tostring(i)]
			nextVipId = i + 1
		end
	end
	local nextVipConf
	if vipConf[tostring(nextVipId)] then
		nextVipConf = vipConf[tostring(nextVipId)]
	end
	return tab,nextVipConf
end

function RechargeUI:updateRechargePanel()
	local paymentInfo = UserData:getUserObj():getPayment()

	local activeLifeCard = false
	if tonumber(paymentInfo.long_card) == 1 then
		activeLifeCard = true
	end

	local rechargeName = SdkData:getRechargeConfName()
	local tempConf = GameData:getConfData(rechargeName)
	local conf = {}
	for i,v in ipairs(tempConf) do
		if not v.isNotShow or v.isNotShow ~= 1 then
			conf[#conf + 1] = v
		end
	end
	local function getPos(size,size1,i)
		local diffSize = (size.width - size1.width*2)/3
		local wNum = (i - 1)%2
		local hNum = math.ceil(i/2)
		local posX = diffSize + wNum*(size1.width + diffSize)
		local posY = (math.ceil(#conf/2) - hNum)*(size1.height + 5)
		return cc.p(posX,posY)
	end
	if activeLifeCard then
		local index = 1
		for i=1,#conf do
			if conf[i].type == 'longCard' then
				conf[i].index = 8
			else
				conf[i].index = index
				index = index + 1
			end
		end
	end
	local size = self.cellSv:getContentSize()
	local buyBtns = {}
	local size1
	for i=1,#conf do
		if not self.cells[i] then
			local cellNode = cc.CSLoader:createNode("csb/rechargecell.csb")
			local rechargeBgImg = cellNode:getChildByName('recharge_bg_img')
			local awardImg = rechargeBgImg:getChildByName('award_img')
			local descTx = rechargeBgImg:getChildByName('desc_tx')
			local numTx = rechargeBgImg:getChildByName('num_tx')
			local buyBtn = rechargeBgImg:getChildByName('buy_btn')
			table.insert(buyBtns, buyBtn)
			local infoTx = buyBtn:getChildByName('info_tx')
			local descImg = rechargeBgImg:getChildByName('desc_img')
			size1 = rechargeBgImg:getContentSize()
			rechargeBgImg:removeFromParent(false)
			rechargeBgImg:setPosition(getPos(size,size1,conf[i].index or i))
			self.cellSv:addChild(rechargeBgImg)
			-- descTx:setString(conf[i].desc)
			descTx:setString('')
			numTx:setString(conf[i].cash)

			local rt = rechargeBgImg:getChildByName('rt')
			if rt then
				rt:removeFromParent()
			end
			local desc = conf[i].desc
			local realValue = string.split(desc, GlobalApi:getLocalStr('RECHARGE_DESC_1'))
			local tx,tx1,tx2,tx3 = '','','',''
			local pos = cc.p(300,106)
			if #realValue == 1 then
				tx = realValue[1]
				if conf[i].type == 'longCard' then
					tx3 = GlobalApi:getLocalStr('RECHARGE_DESC_3')
					if conf[i].index == 8 then
						buyBtn:setBright(false)
						buyBtn:setTouchEnabled(false)
					end
				else
					tx3 = string.format(GlobalApi:getLocalStr('RECHARGE_DESC_2'),conf[i].duration)
				end
			else
				tx = realValue[1]
				tx1 = GlobalApi:getLocalStr('RECHARGE_DESC_1')
				tx2 = realValue[2]
				pos = cc.p(300,116)
			end
			tx3 = ''
			local richText = xx.RichText:create()
    		richText:setContentSize(cc.size(400, 30))
    		richText:setPosition(pos)
			richText:setAlignment('middle')
			richText:setVerticalAlignment('bottom')
			richText:setName(rt)
			rechargeBgImg:addChild(richText)
			local re = xx.RichTextLabel:create(tx, 25, COLOR_TYPE.PALE)
			re:setStroke(COLOROUTLINE_TYPE.PALE, 1)
			local re1 = xx.RichTextLabel:create(tx1, 45, COLOR_TYPE.RED)
			re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
			local re2 = xx.RichTextLabel:create(tx2, 25, COLOR_TYPE.PALE)
			re2:setStroke(COLOROUTLINE_TYPE.PALE, 1)
			local re3 = xx.RichTextLabel:create(tx3, 18, COLOR_TYPE.ORANGE)
			re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			re:setFont('font/gamefont.ttf')
			re1:setFont('font/gamefont.ttf')
			re2:setFont('font/gamefont.ttf')
			richText:addElement(re)
			richText:addElement(re1)
			richText:addElement(re2)
			richText:addElement(re3)

			if conf[i].duration > 0 then
				descImg:setVisible(false)
			else
				if paymentInfo.pay_list[tostring(i)] then
					descImg:setVisible(false)
					richText:setVisible(false)
				else
					descImg:setVisible(true)
					richText:setVisible(true)
				end
			end
			infoTx:setString(conf[i].amount..GlobalApi:getLocalStr('ACTIVITY_SALETIP5'))
			buyBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					buyBtn:setBright(false)
					for k, v in ipairs(buyBtns) do
						v:setTouchEnabled(false)
					end
					buyBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
						buyBtn:setBright(true)
						for k, v in ipairs(buyBtns) do
							v:setTouchEnabled(true)
						end
                    end)))
					-- if SdkData:getSDKPlatform() ~= "dev" then
					-- 	local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. SdkData:getSDKPlatform())
					-- 	RechargeHelper:recharge(i, conf[i])
					-- end
					RechargeMgr:pay(conf[i])
				end
			end)
			awardImg:loadTexture('uires/ui/rech/rech_icon_'..i..'.png')
			awardImg:ignoreContentAdaptWithSize(true)
		end
	end
	self.cellSv:setInnerContainerSize(cc.size(size.width,math.ceil(#conf/2) * (size1.height + 5)))
end

function RechargeUI:updatePrivilegePanel()
	local bgImg = self.bgImg3:getChildByName('bg_img')
	local titleBgImg = self.bgImg3:getChildByName('title_bg_img')
	local titleImg = titleBgImg:getChildByName('title_img')
	local titleTx = titleImg:getChildByName('info_tx')
	local infoTx1 = self.bgImg3:getChildByName('info_1_tx')
	local infoTx2 = self.bgImg3:getChildByName('info_2_tx')
	local infoSv = self.bgImg3:getChildByName('info_sv')
	infoSv:setScrollBarEnabled(false)
	-- local num1 = titleBgImg:getChildByName('num_tx')
	local conf = GameData:getConfData('vip')[tostring(self.vipPage)]
	local descs = conf.description
	local descRT = infoSv:getChildByName('desc_rt')
	if descRT then
		descRT:removeFromParent()
	end
    descRT = xx.RichText:create()
    descRT:setContentSize(cc.size(400, 30))
    descRT:setAlignment('left')
    -- descRT:setVerticalAlignment('middle')
    descRT:setName('desc_rt')
    descRT:setAnchorPoint(cc.p(0,1))
    infoSv:addChild(descRT)
	for i=1,#descs do
		if i ~= 1 then
			local re1 = xx.RichTextLabel:create('\n',26, COLOR_TYPE.WHITE)
			re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
			descRT:addElement(re1)
		end
		local re2 = xx.RichTextImage:create('uires/ui/activity/333.png')
		descRT:addElement(re2)
		xx.Utils:Get():analyzeHTMLTag(descRT,descs[i])
	end
	descRT:format(true)
	local size = infoSv:getContentSize()
	local maxHeight = descRT:getBrushY()
	if size.height < maxHeight then
		infoSv:setInnerContainerSize(cc.size(size.width,maxHeight))
	else
		infoSv:setInnerContainerSize(cc.size(size))
	end
	local size = infoSv:getInnerContainerSize()
	descRT:setPosition(cc.p(0,descRT:getBrushY()))
	descRT:setPosition(cc.p(0,size.height))

	infoTx1:setString('VIP'..self.vipPage..GlobalApi:getLocalStr('STR_PRIVILEGE_1'))
	infoTx2:setString('VIP'..self.vipPage..GlobalApi:getLocalStr('STR_GIFTS'))
	titleTx:setString('VIP '..self.vipPage)

	local awards = DisplayData:getDisplayObjs(conf.awards)
	local size = bgImg:getContentSize()
	local hadFood = false
    local hadFoodNum = 0

	for i=1,6 do
		if awards[i] then
			local awardBgImg = bgImg:getChildByName('award_bg_'..i..'_img')
			if not awardBgImg then
				local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
				awardBgImg = tab.awardBgImg
				awardBgImg:setName('award_bg_'..i..'_img')
				bgImg:addChild(awardBgImg)
			end
			ClassItemCell:updateItem(awardBgImg, awards[i], 2)
			local posY = ((#awards > 3) and pos[i].y) or (pos[i].y - 50)
			awardBgImg:setPosition(cc.p(pos[i].x,posY))
			awardBgImg:setVisible(true)
			local numTx = awardBgImg:getChildByName('lv_tx')
			numTx:setVisible(true)
			if awards[i]:getCategory() == 'equip' then
				numTx:setString('Lv.'..awards[i]:getNum())
			else
				numTx:setString('x'..awards[i]:getNum())
			end
			if awards[i]:getId() == 'food' then
				hadFoodNum = hadFoodNum + 1
			end
			awards[i]:setLightEffect(awardBgImg)
	    	awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(awards[i],false)
		        end
		    end)
		else
			local awardBgImg = bgImg:getChildByName('award_bg_'..i..'_img')
			if awardBgImg then
				awardBgImg:setVisible(false)
			end
		end
	end

    if hadFoodNum > 0 then
        hadFood = true
    end

	local numTx = bgImg:getChildByName('num_tx')
	local infoTx = bgImg:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('FWACT_ORIPRICE')..':')
	numTx:setString(conf.cost)
	if not self.privilegeRts then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 30))
	    richText:setAlignment('left')
	    richText:setVerticalAlignment('middle')
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FWACT_CURPRICE'), 25, COLOR_TYPE.ORANGE)
	    local re2 = xx.RichTextLabel:create(conf.curPrice, 25, COLOR_TYPE.WHITE)
	    local re3 = xx.RichTextImage:create('uires/ui/res/res_cash.png')
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	    re1:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
	    richText:addElement(re3)
	    richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(225,108))
	    bgImg:addChild(richText)
	    self.privilegeRts = {richText = richText,re2 = re2,re3 = re3}
    else
    	self.privilegeRts.re2:setString(conf.curPrice)
    	self.privilegeRts.richText:format(true)
	end

	if not self.cashRts then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 30))
	    richText:setAlignment('middle')
	    richText:setVerticalAlignment('middle')
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ALL_RECHARGE_CASH'), 25, COLOR_TYPE.ORANGE)
	    local re2 = xx.RichTextImage:create('uires/ui/res/res_cash.png')
	    local re3 = xx.RichTextLabel:create(conf.cash, 25, COLOR_TYPE.WHITE)
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    re1:setFont('font/gamefont.ttf')
	    re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:addElement(re3)
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(225,38))
	    self.bgImg3:addChild(richText)
	    self.cashRts = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
    else
    	self.cashRts.re3:setString(conf.cash)
    	self.cashRts.richText:format(true)
	end

	local getBtn = bgImg:getChildByName('get_btn')
	local infoTx = getBtn:getChildByName('info_tx')
	
	local paymentInfo = UserData:getUserObj():getPayment()
	if paymentInfo.vip_rewards[tostring(self.vipPage)] then
		getBtn:setBright(false)
		getBtn:setTouchEnabled(false)
		infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
		infoTx:setString(GlobalApi:getLocalStr('HAD_BOUGHT'))
	else
		infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_BUYBTN1'))
		getBtn:setBright(true)
		getBtn:setTouchEnabled(true)
		infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
	end
	getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if hadFood then
                local food = UserData:getUserObj():getFood()
                local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                if food >= maxFood then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                    return
                end
            end
        	local vip = UserData:getUserObj():getVip()
        	if vip < self.vipPage then
        		promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_NEED_VIP_1"), COLOR_TYPE.RED)
        		return
        	end

            if UserData:getUserObj():getCash() < conf.curPrice then
                promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					    self.page = self.page%2 + 1
                        self:updatePanel()
				    end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                return
            end

			local args = {vip = self.vipPage}
			MessageMgr:sendPost('get_vip_reward','user',json.encode(args),function (response)
		        
		        local code = response.code
		        local data = response.data
		        if code == 0 then
		        	local awards = data.awards
		            if awards then
		                GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
		            end
		            local costs = data.costs
		            if costs then
		            	GlobalApi:parseAwardData(costs)
		            end
		            paymentInfo.vip_rewards[tostring(self.vipPage)] = 1
		            UserData:getUserObj():setPayment(paymentInfo)
					self:updatePanel()
		        end
		    end)
        end
    end)
end

function RechargeUI:updatePanel()
	local privilegeBtn = self.rechargeImg:getChildByName('privilege_btn')
	local infoTx = privilegeBtn:getChildByName('info_tx')
	if self.page == 1 then
		self.cellSv:setVisible(true)
		self.bgImg3:setVisible(false)
		self:updateRechargePanel()
		infoTx:setString(GlobalApi:getLocalStr('VIP_PRIVILEGE'))
		self.titleTx:setString(GlobalApi:getLocalStr('PAY'))
		self.leftBtn:setVisible(false)
		self.rightBtn:setVisible(false)
	else
		self.cellSv:setVisible(false)
		self.bgImg3:setVisible(true)
		self:updatePrivilegePanel()
		infoTx:setString(GlobalApi:getLocalStr('PAY_1'))
		self.titleTx:setString(GlobalApi:getLocalStr('VIP_PRIVILEGE'))
		self.leftBtn:setVisible(true)
		self.rightBtn:setVisible(true)
	end
	local vip_xp = UserData:getUserObj():getVipXp()
	local vipConf,nextVipConf = self:getVip(vip_xp)
	local nextLevel = 0
	local nextCash = 0
	local diffCash1 = 0
	local diffCash2 = 0
	local diffCash3 = 0
	local per = 0
	if not nextVipConf then
		per = 100
		nextLevel = vipConf.level
		nextCash = 0
		diffCash1 = 0
		diffCash2 = 0
		diffCash3 = 0
	else
		per = (vip_xp - vipConf.cash)/(nextVipConf.cash - vipConf.cash)*100
		nextLevel = nextVipConf.level
		nextCash = nextVipConf.cash
		diffCash1 = vip_xp - vipConf.cash
		diffCash2 = nextCash - vipConf.cash
		diffCash3 = nextCash - vip_xp
	end
	self.bar:setPercent(per)
	
	local vipNum1 = self.rechargeImg:getChildByName('vip_1_tx')
	vipNum1:setString(UserData:getUserObj():getVip() or 0)
	local vipNum2 = self.rechargeImg:getChildByName('vip_2_tx')
	vipNum2:setString(nextLevel)
	local numTx = self.rechargeImg:getChildByName('num_tx')
	numTx:setString(diffCash3)
	local barTx = self.bar:getChildByName('bar_tx')
	barTx:setString(diffCash1..'/'..diffCash2)
	local boxImg = self.rechargeImg:getChildByName('box_img')
	boxImg:loadTexture('uires/ui/rech/rech_box_'..self.page..'.png')
	boxImg:ignoreContentAdaptWithSize(true)
end

function RechargeUI:init()
	local rechargeBgImg = self.root:getChildByName("recharge_bg_img")
	self.rechargeImg = rechargeBgImg:getChildByName('recharge_img')
	self:adaptUI(rechargeBgImg, self.rechargeImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.rechargeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    local closebtn = self.rechargeImg:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RechargeMgr:hideRecharge()
        end
    end)

    local titleBgImg = self.rechargeImg:getChildByName('title_bg_img')
    self.titleTx = titleBgImg:getChildByName('title_tx')
    self.titleTx:setString(GlobalApi:getLocalStr('PAY'))

    self.cellSv = self.rechargeImg:getChildByName('cell_sv')
    self.cellSv:setScrollBarEnabled(false)
    
    local barBg = self.rechargeImg:getChildByName('bar_bg')
	self.bar = barBg:getChildByName('bar')

    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))


	local privilegeBtn = self.rechargeImg:getChildByName('privilege_btn')
	local infoTx = privilegeBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('VIP_PRIVILEGE'))
	privilegeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.page = self.page%2 + 1
            self:updatePanel()
        end
    end)

	self.bgImg3 = self.rechargeImg:getChildByName('bg_3_img')
	self.infoTxs = {}
	for i=1,9 do
		local infoTx = self.bgImg3:getChildByName('desc_'..i..'_tx')
		self.infoTxs[i] = infoTx
	end
	local leftBtn = rechargeBgImg:getChildByName('left_btn')
	local rightBtn = rechargeBgImg:getChildByName('right_btn')
	self.leftBtn = leftBtn
	self.rightBtn = rightBtn
    leftBtn:setPosition(cc.p(0,winSize.height/2 - 70))
    rightBtn:setPosition(cc.p(winSize.width,winSize.height/2 - 70))
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)
	leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.vipPage = (self.vipPage - 1)%(self.maxPage + 1)
            self:updatePanel()
        end
    end)
    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.vipPage = (self.vipPage + 1)%(self.maxPage + 1)
            self:updatePanel()
        end
    end)
    self:updatePanel()
end

return RechargeUI