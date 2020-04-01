local ShippersSelectUI = class("ShippersSelectUI", BaseUI)

local function getCurColorText(id)
	local strBuff = ''
	local conf = GameData:getConfData('shipper')
	for k, v in pairs(conf) do
		if tonumber(v.shipper) == id then
			strBuff = v.desc
		end
	end
	return strBuff
end

local function getCurColor(id)
	local strBuff = ''
	if id == 1 then
		strBuff = COLOR_TYPE.GREEN
	elseif id == 2 then
		strBuff = COLOR_TYPE.BLUE
	elseif id == 3 then
		strBuff = COLOR_TYPE.PURPLE
	elseif id == 4 then
		strBuff = COLOR_TYPE.YELLOW
	elseif id == 5 then
		strBuff = COLOR_TYPE.RED
	end
	return strBuff
end

local function getCurColorGold(id)
	local awardStr = ''
	local playerLv = UserData:getUserObj():getLv()
	local conf = GameData:getConfData("shipperreward")
	for k, v in pairs(conf) do
		if math.floor(playerLv / 10) == tonumber(v.level) / 10 then
			if id == 1 then
				awardStr = v.award1[1]
			elseif id == 2 then
				awardStr = v.award2[1]
			elseif id == 3 then
				awardStr = v.award3[1]
			elseif id == 4 then
				awardStr = v.award4[1]
			elseif id == 5 then
				awardStr = v.award5[1]
			end
			break
		end
	end
	local award = DisplayData:getDisplayObj(awardStr)
	local gold = award:getNum()
	return gold
end

function ShippersSelectUI:ctor()
	self.uiIndex = GAME_UI.UI_SHIPPERSSELECT
	self.data = ShippersMgr:getMainUIData()
	self.target = 0
	self.start = self.data.type	
end

function ShippersSelectUI:init()
	local selectBgImg = self.root:getChildByName("select_bg_img")
	self.selectImg = selectBgImg:getChildByName("select_img")
    self:adaptUI(selectBgImg, self.selectImg)

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.selectImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
	local closeBtn = self.selectImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			ShippersMgr:hideShippersSelect()
		end
	end)

	-- for i=1,3 do
	-- 	local infoTx1 = self.selectImg:getChildByName('info_'..i..'_tx')
	-- 	infoTx1:setString(GlobalApi:getLocalStr('SHIPPER_INFO_'..i))
	-- end
	local neiBgImg = self.selectImg:getChildByName('nei_bg_img')
	local infoTx = neiBgImg:getChildByName('info_3_tx')
	infoTx:setString(GlobalApi:getLocalStr('SHIPPER_INFO_4'))
	local refreshBtn = self.selectImg:getChildByName('refresh_btn')
	refreshBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			self:onClickRefresh()
		end
	end)

	local startBtn = self.selectImg:getChildByName('start_btn')
	startBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			self:onClickStar()
		end
	end)
	
	self.pos = {}
	for i=1,5 do
		local cardIco = self.selectImg:getChildByName('card_'..i..'_ico')
		local cs = cardIco:getContentSize()
		self.pos[i] = cc.p(cardIco:getPositionX() + 2, cardIco:getPositionY() + 4)
	end
	local titleBgImg = self.selectImg:getChildByName('title_bg_img')
	local titleTx = titleBgImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('SHIPPER_SELECT'))

	local midImg = self.selectImg:getChildByName('mid_img')
	local exchangeBtn = midImg:getChildByName('exchange_btn')
	local richText = xx.RichText:create()
	richText:setContentSize(cc.size(475, 30))
	richText:setAlignment('middle')
	richText:setVerticalAlignment('middle')
    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_INFO_1'),21,COLOR_TYPE.WHITE)
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_INFO_2'),21,COLOR_TYPE.GREEN)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_INFO_3'),21,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_INFO_5')..',',21,COLOR_TYPE.RED)
    re:setFont('font/gamefont.ttf')
    re2:setFont('font/gamefont.ttf')
    re3:setFont('font/gamefont.ttf')
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.RED, 1)
    richText:addElement(re)
    richText:addElement(re3)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(270,100))
    midImg:addChild(richText)

    local addition_img = self.selectImg:getChildByName("addition_img")
    addition_img:setTouchEnabled(true)
    local additionPos = self.selectImg:convertToWorldSpace(cc.p(addition_img:getPosition()))
    addition_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TipsMgr:showJadeSealAdditionTips(additionPos, "shipper")
        end
    end)
    local addition_tx = addition_img:getChildByName("addition_tx")

    local addition = UserData:getUserObj():getJadeSealAddition("shipper")
    addition_tx:setString(addition[2] .. "%")
    if not addition[1] then
        ShaderMgr:setGrayForWidget(addition_img)
        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end

    exchangeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.data.exchangenum >= tonumber(GlobalApi:getGlobalValue('shipperExchangeLimit')) then
            	ShippersMgr:showShippersExchange(function(data)
		        	self.data.free = data.shipper.free
		        	self.data.exchangenum = data.shipper.exchangenum
		        	self.target = data.shipper.type
		        	self.data.type = data.shipper.type
		        	self.start = self.target
		        	self:update()
            	end)
            else
            	promptmgr:showSystenHint(GlobalApi:getGlobalValue('shipperExchangeLimit')..GlobalApi:getLocalStr('SHIPPER_INFO_7'), COLOR_TYPE.RED)
            end
        end
    end)

    self:update()
end

function ShippersSelectUI:setDescImg(i)
    local midImg = self.selectImg:getChildByName('mid_img')
	local bgImg = midImg:getChildByName('bg_img')
	local barBgImg = midImg:getChildByName('bar_bg_img')
	local bar = barBgImg:getChildByName('bar')
	local barTx = barBgImg:getChildByName('bar_tx')
	local descTx = barBgImg:getChildByName('desc_tx')
	local descImg = bgImg:getChildByName('desc_img')
	descTx:setString(string.format(GlobalApi:getLocalStr('SHIPPER_INFO_10'),GlobalApi:getGlobalValue('perShipperCashAdd')))
	descImg:loadTexture('uires/ui/shippers/shippers_'..i..'bei.png')
	barTx:setString(GlobalApi:getLocalStr('SHIPPER_INFO_6')..'：'..self.data.exchangenum..'/'..GlobalApi:getGlobalValue('shipperExchangeLimit'))
	bar:setPercent(self.data.exchangenum/tonumber(GlobalApi:getGlobalValue('shipperExchangeLimit'))*100)

	local spine = midImg:getChildByName('spine')
	if spine then
		spine:removeFromParent()
	end
	local spineName = 'biaoche'..i
	spine = GlobalApi:createAniByName(spineName)
	spine:setName('spine')
	spine:setPosition(cc.p(270,150))
	midImg:addChild(spine)
end

function ShippersSelectUI:update()
	local lightIco = self.selectImg:getChildByName('light_ico')
	if not lightIco then
		-- lightIco:setPosition(self.pos[self.start])
		lightIco = GlobalApi:createLittleLossyAniByName('shipper_select')
		lightIco:setScale(1.1)
		lightIco:getAnimation():playWithIndex(0, -1, 1)
        lightIco:setName('light_ico')
        --lightIco:setScale(1.1)
		self.selectImg:addChild(lightIco)
	end
	lightIco:setPosition(self.pos[self.start])
	self:setDescImg(self.start)

	local cashTx = self.selectImg:getChildByName('cash_num_tx')
	local cashIco = self.selectImg:getChildByName('cash_ico')
    cashTx:setString('x'..GlobalApi:getGlobalValue('shipperRefreshCash'))

    local playerLv = UserData:getUserObj():getLv()
    local neiBgImg = self.selectImg:getChildByName('nei_bg_img')
    local titleBgImg = neiBgImg:getChildByName('title_bg_img')
    local curColorTx = titleBgImg:getChildByName('cur_color_tx')
    curColorTx:setString(getCurColorText(self.start))
    curColorTx:setColor(getCurColor(self.start))

    local goldTx = self.selectImg:getChildByName('gold_num_tx')
    local gold = getCurColorGold(tonumber(self.start))
    local timeStr1 = GlobalApi:getGlobalValue('shipperNoon')
	local timeStr2 = GlobalApi:getGlobalValue('shipperNight')
	local serverTime = GlobalData:getServerTime()
	local hour = Time.date("%H", serverTime)
	local minute = Time.date("%M", serverTime)
	local time = hour + minute / 60
    local time1 = string.split(timeStr1, '-' )
    local time2 = string.split(timeStr2, '-' )
   	if (time >= tonumber(time1[1]) and time <= tonumber(time1[2])) or (time >= tonumber(time2[1]) and time <= tonumber(time2[2])) then
   		gold = gold * tonumber(GlobalApi:getGlobalValue('shipperExtra'))
   	end
    goldTx:setString(math.floor(gold))

    local startBtn = self.selectImg:getChildByName('start_btn')
    local startTx = startBtn:getChildByName('start_tx')
    startTx:setString(GlobalApi:getLocalStr('SHIPPER_START'))
    startTx:enableOutline(cc.c4b(165,70,6,255),1)
    startTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))

    local cashPl = self.selectImg:getChildByName('cash_pl')
    local cashNumTx = cashPl:getChildByName('cash_num_tx')
    cashNumTx:setString(UserData:getUserObj():getCash()..'）')
    -- cashNumTx:setString('x'..GlobalApi:getGlobalValue('shipperRefreshCash'))
    local infoTx = cashPl:getChildByName('info_tx')
    infoTx:setString('（'..GlobalApi:getLocalStr('SHIPPER_REMAINDER'))

    local refreshBtn = self.selectImg:getChildByName('refresh_btn')
    local refreshTx = refreshBtn:getChildByName('refresh_tx')
    refreshTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    local redPointIco = refreshBtn:getChildByName('red_point_ico')

 
    if self.data.free == 0 then
    	refreshTx:setString(GlobalApi:getLocalStr('REFRESH_CASH'))
    	redPointIco:setVisible(false)
		cashTx:setVisible(true)
		cashIco:setVisible(true)
		cashPl:setVisible(true)
    else
    	refreshTx:setString(GlobalApi:getLocalStr('REFRESH_FREE'))
    	redPointIco:setVisible(true)
		cashTx:setVisible(false)
		cashIco:setVisible(false)
		cashPl:setVisible(false)
    end

    if self.data.type == 5 then
    	refreshBtn:setBright(false)
    	refreshBtn:setTouchEnabled(false)
    	refreshTx:enableOutline(cc.c4b(59,59,59,255),1)
    else
    	refreshBtn:setBright(true)
    	refreshBtn:setTouchEnabled(true)
    	refreshTx:enableOutline(cc.c4b(165,70,6,255),1)
    end
    
end

function ShippersSelectUI:onClickRefresh()
	if self.data.free == 0 then
		local curCash = UserData:getUserObj():getCash()
		local needCash = tonumber(GlobalApi:getGlobalValue('shipperRefreshCash'))
		if curCash < needCash then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
			return
		end
	end
	self:lockBtn()
	local args = {}
	local use_cash = 0
	if self.data.free == 0 then
		args ={use_cash = 1}
	else
		args ={use_cash = 0}
	end
	
	MessageMgr:sendPost("refresh", "shipper", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
        	local data = jsonObj.data
        	self.data.free = data.shipper.free
        	self.data.exchangenum = data.shipper.exchangenum
            if data.costs then
                GlobalApi:parseAwardData(data.costs)
        	end
        	self.target = data.type
        	self:lightEffect(3, self.start ,self.target)
        end
    end)
end

function ShippersSelectUI:onClickStar()
	local nowTime = Time.getCorrectServerTime() - Time.beginningOfToday()
	local noon = GlobalApi:getGlobalValue('shipperNoon')
	local night = GlobalApi:getGlobalValue('shipperNight')
	local keyArr1 = string.split(noon , '-')
	local keyArr2 = string.split(night , '-')
	local function callback()
		MessageMgr:sendPost("delivery", "shipper", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	            UserData:getUserObj():updateShipper("delivery", jsonObj.data.delivery)
	        	ShippersMgr:addMyData(jsonObj.data)
	            --self.data.delivery = self.data.delivery + 1
	            self.data.delivery = jsonObj.data.delivery
	        	self.data.type = 1
	        	self.data.free = 1
	            ShippersMgr:updateShippersMain()
	            ShippersMgr:hideShippersSelect()
	        end
	    end)
	end
	if (nowTime > 3600 *tonumber(keyArr1[1]) and nowTime < 3600 * tonumber(keyArr1[2])) or (nowTime > 3600 *tonumber(keyArr2[1]) and nowTime < 3600 * tonumber(keyArr2[2])) then
		callback()
	else
		promptmgr:showMessageBox(GlobalApi:getLocalStr('SHIPPER_DESC_7'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
			callback()
		end)
	end
end

function ShippersSelectUI:lockBtn()
	local closeBtn = self.selectImg:getChildByName('close_btn')
	closeBtn:setTouchEnabled(false)
	local refreshBtn = self.selectImg:getChildByName('refresh_btn')
	refreshBtn:setTouchEnabled(false)
	local startBtn = self.selectImg:getChildByName('start_btn')
	startBtn:setTouchEnabled(false)
end

function ShippersSelectUI:unLockBtn()
	local closeBtn = self.selectImg:getChildByName('close_btn')
	closeBtn:setTouchEnabled(true)
	local refreshBtn = self.selectImg:getChildByName('refresh_btn')
	refreshBtn:setTouchEnabled(true)
	local startBtn = self.selectImg:getChildByName('start_btn')
	startBtn:setTouchEnabled(true)
end

function ShippersSelectUI:lightEffect(round, start, target)
	local lightIco = self.selectImg:getChildByName('light_ico')
	local bitAction = {}
	local allAction = {}
	for r = 1, round do
		local index = 1
		for i = start, 5 do
			local move = cc.CallFunc:create(function ()
		    	lightIco:setPosition(self.pos[i])
		    	self:setDescImg(i)
		    	if r == round and i == target then
		    		self.data.type = target
		    		self.start = target
		    		lightIco:stopAllActions()
		    		self:unLockBtn()
		    		self:update()	
		    	end
		    end)
		    local time = cc.DelayTime:create(0.1)
			if r == round then
				time = cc.DelayTime:create(0.2)
			end
		    bitAction[index] = cc.Sequence:create(move, time)
		    index = index + 1	
		end
		allAction[r] = cc.Sequence:create(bitAction)	
	end
	lightIco:runAction(cc.Sequence:create(allAction))
end

-- 递归方法实现动画
-- function ShippersSelectUI:runAction(i)
-- 	local tab = {}
-- 	for i=1,a do
-- 		tab[#tab + 1] = 0.1
-- 	end
-- 	tab[#tab] = 0.2
-- 	self.lightIco:stopAllActions()
-- 	local fn = cc.CallFunc:create(function ()
-- 	    	self.lightIco:setPosition(cc.p(100 + (i - 1) * 172, 305))
-- 	    	self.count = self.count + 1
-- 	    	if self.count > 10 and i == 3 then
-- 	    		self.lightIco:stopAllActions()
-- 	    	end
-- 	    end)

-- 	local time = cc.DelayTime:create(tab[math.floor(self.count/5) + 1])
-- 	self.lightIco:runAction(cc.Sequence:create(fn, time,cc.CallFunc:create(function()
-- 		local index = i%5 + 1
-- 		self:runAction(index)
-- 	end)))
-- end

return ShippersSelectUI