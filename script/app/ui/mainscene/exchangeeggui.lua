local ExchangeEggUI = class("ExchangeEggUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ExchangeEggUI:ctor(data)
	self.uiIndex = GAME_UI.UI_EXCHANGEEGG
	-- self.data = data
	-- printall(self.data)
	-- print(#self.data.order)
	self:setData(data)
	self.awardsRTs = {{},{},{}}
end

function ExchangeEggUI:setData(data)
	-- self.time = 
	self.order = {}
	for k,v in pairs(data.order) do
		self.order[#self.order + 1] = {tonumber(k),v}
	end
	self.refresh = data.refresh
end

function ExchangeEggUI:updatePanel()
	local posx = {70,160,290}
	local conf = GameData:getConfData('diggingexchange')
	for i,v in ipairs(self.order) do
		local bgImg = self.exchangeImg:getChildByName('bg_'..i..'_img')
		local posY = bgImg:getPositionY()
		local costs = DisplayData:getDisplayObjs(conf[tonumber(v[1])].costs)
		local awards = DisplayData:getDisplayObjs(conf[tonumber(v[1])].awards)
		costs[3] = awards[1]
		local canBuy = true
		for j=1,3 do
			local awardBgImg = self.exchangeImg:getChildByName('award_bg_'..i..j..'_img')
			if not awardBgImg then
				local tab = ClassItemCell:create()
				awardBgImg = tab.awardBgImg
				awardBgImg:setScale(0.8)
				awardBgImg:setPosition(cc.p(posx[j],posY))
				awardBgImg:setName('award_bg_'..i..j..'_img')
				self.exchangeImg:addChild(awardBgImg)
			end
			if costs[j] then
				awardBgImg:setVisible(true)
				local awardImg = awardBgImg:getChildByName('award_img')
				local lvTx = awardBgImg:getChildByName('lv_tx')
				awardBgImg:loadTexture(costs[j]:getBgImg())
				awardImg:loadTexture(costs[j]:getIcon())
				if j == 3 then
					lvTx:setString(costs[j]:getNum())
				else
					lvTx:setString('')
					-- lvTx:setString(costs[j]:getOwnNum()..'/'..costs[j]:getNum())
		            local color,color1
		            if costs[j]:getOwnNum() < costs[j]:getNum() then
		                color = COLOR_TYPE.RED
		                color1 = COLOR_TYPE.WHITE
		                canBuy = false
		            else
		                color = COLOR_TYPE.GREEN
		                color1 = COLOR_TYPE.GREEN
		            end

		            if not self.awardsRTs[i][j] then
		                local richText = xx.RichText:create()
		                richText:setAlignment('right')
		                -- richText:setVerticalAlignment('middle')
		                richText:setContentSize(cc.size(230, 30))
		                local re1 = xx.RichTextLabel:create(GlobalApi:toWordsNumber(costs[j]:getOwnNum()),20,color)
		                local re2 = xx.RichTextLabel:create('/'..costs[j]:getNum(),20,color1)
		                re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		                re2:setStroke(COLOR_TYPE.BLACK, 1)
		                richText:addElement(re1)
		                richText:addElement(re2)
		                richText:setAnchorPoint(cc.p(1,0.5))
		                richText:setPosition(cc.p(88,15))
		                awardBgImg:addChild(richText)
		                self.awardsRTs[i][j] = {richText = richText,re2 = re2,re1 = re1}
		            else
		            	print(costs[j]:getOwnNum(),costs[j]:getNum(),'=======================')
		                self.awardsRTs[i][j].re1:setString(GlobalApi:toWordsNumber(costs[j]:getOwnNum()))
		                self.awardsRTs[i][j].re2:setString('/'..costs[j]:getNum())
		                self.awardsRTs[i][j].re1:setColor(color)
		                self.awardsRTs[i][j].re2:setColor(color1)
		                self.awardsRTs[i][j].richText:setVisible(true)
		                self.awardsRTs[i][j].richText:format(true)
		            end
				end
				awardBgImg:setTouchEnabled(true)
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
			        	GetWayMgr:showGetwayUI(costs[j],false)
				    end
				end)
			else
				awardBgImg:setVisible(false)
			end
			if v[2] == 0 then
				self.buyBtns[i]:setBright(true)
				self.buyBtns[i]:setTouchEnabled(true)
				self.infoTxs[i]:setString(GlobalApi:getLocalStr('STR_EXCHANGE_1'))
				self.infoTxs[i]:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
			else
				self.buyBtns[i]:setBright(false)
				self.buyBtns[i]:setTouchEnabled(false)
				self.infoTxs[i]:setString(GlobalApi:getLocalStr('STR_HAD_EXCHANGE'))
				self.infoTxs[i]:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
			end
		end
		self.buyBtns[i]:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if canBuy == false then
	        		promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
	        		return
	        	end
				local args = {id = v[1]}
				MessageMgr:sendPost('deal_exchange','digging',json.encode(args),function (response)
			        local code = response.code
			        local data = response.data
			        if code == 0 then
						self.order[i][2] = 1
						local awards = data.awards
						local costs = data.costs
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
						end
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						self:updatePanel()
			        end
			    end)
		    end
		end)
	end
	local szBgImg = self.exchangeImg:getChildByName('sz_bg_img')
	local numTx = szBgImg:getChildByName('num_tx')
	local maxTimes = tonumber(GlobalApi:getGlobalValue('diggingExchangeRefreshFree'))
	local gold = GlobalApi:toWordsNumber(UserData:getUserObj():getGold())

    local posX = numTx:getPositionX()
    local posY = numTx:getPositionY()

    local diggingGold = tonumber(GlobalApi:getGlobalValue('diggingExchangeRefreshGold'))

    local color
	if self.refresh > maxTimes then      
		if UserData:getUserObj():getGold() < diggingGold then
		    color = COLOR_TYPE.RED
		else
		    color = COLOR_TYPE.WHITE
		end

		--numTx:setString(gold..'/'..GlobalApi:getGlobalValue('diggingExchangeRefreshGold'))
	else
		--numTx:setString(gold..'/'..0)
		color = COLOR_TYPE.WHITE
    end

    if self.numTxTab == nil then
        local richText = xx.RichText:create()
	    richText:setAlignment('middle')
	    richText:setContentSize(cc.size(230, 30))
	    local re1 = xx.RichTextLabel:create(gold,26,color)
	    local re2 = xx.RichTextLabel:create('/'.. diggingGold,26,COLOR_TYPE.WHITE)
	    re1:setStroke(COLOR_TYPE.BLACK, 1)
	    re2:setStroke(COLOR_TYPE.BLACK, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(posX,posY))
	    szBgImg:addChild(richText)
        self.numTxTab = {richText = richText,re2 = re2,re1 = re1}

    end

    
    if self.refresh > maxTimes then
        self.numTxTab.re1:setString(gold)
	    self.numTxTab.re2:setString('/'.. diggingGold)
	    self.numTxTab.re1:setColor(color)
	    self.numTxTab.richText:setVisible(true)
	    self.numTxTab.richText:format(true)

	else
        self.numTxTab.re1:setString(gold)
	    self.numTxTab.re2:setString('/' .. 0)
	    self.numTxTab.re1:setColor(COLOR_TYPE.WHITE)
	    self.numTxTab.richText:setVisible(true)
	    self.numTxTab.richText:format(true)
	end



end

function ExchangeEggUI:init()
	local bgImg = self.root:getChildByName("exchange_bg_img")
	self.exchangeImg = bgImg:getChildByName("exchange_img")
	local closeBtn = self.exchangeImg:getChildByName("close_btn")
    self:adaptUI(bgImg, self.exchangeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.exchangeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideExchangeEgg()
	    end
	end)

	self.buyBtns = {}
	self.infoTxs = {}
	for i=1,3 do
		local buyBtn = self.exchangeImg:getChildByName('buy_'..i..'_btn')
		local infoTx = buyBtn:getChildByName('info_tx')
		self.buyBtns[i] = buyBtn
		self.infoTxs[i] = infoTx
	end
	local titleImg = self.exchangeImg:getChildByName('title_img')
	local titleTx = titleImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('EXCHANGE_EGG'))

	local refreshBtn = self.exchangeImg:getChildByName('refresh_btn')
	local infoTx = refreshBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('REFRESH_1'))
	refreshBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- local maxTimes = tonumber(GlobalApi:getGlobalValue('diggingExchangeRefreshFree'))
        	-- if self.refresh >= maxTimes then
        	-- 	promptmgr:showSystenHint(GlobalApi:getLocalStr('REFRESH_HAD_NO_TIMES'), COLOR_TYPE.RED)
        	-- 	return
        	-- end

            local diggingGold = tonumber(GlobalApi:getGlobalValue('diggingExchangeRefreshGold'))
            if UserData:getUserObj():getGold() < diggingGold then   
                promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'), COLOR_TYPE.RED)
                return
            end

			local args = {}
			MessageMgr:sendPost('refresh_exchange','digging',json.encode(args),function (response)
		        local code = response.code
		        local data = response.data
		        if code == 0 then
		        	local costs = data.costs
			        if costs then
			            GlobalApi:parseAwardData(costs)
			        end
					self:setData(data.exchange)
					self:updatePanel()
					promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
		        end
		    end)
	    end
	end)

	self:updatePanel()
end

return ExchangeEggUI