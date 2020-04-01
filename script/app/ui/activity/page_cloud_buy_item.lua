local CloudBuyItemUI = class("CloudBuyItemUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CloudBuyItemUI:ctor(id,conf,data,data1,callback,callback1)
	self.uiIndex = GAME_UI.UI_CLOUD_BUY_ITEM
	self.page = 1
	self.data = data.ids[tostring(id)]
	self.cloudBuy = data.cloud_buy
	self.data1 = data1
	self.id = id
	self.callback = callback
	self.callback1 = callback1
	self.conf = GameData:getConfData("avcloudbuyawards")[self.data.aid]
	self.conf1 = conf
	self.needRefresh = false
end

function CloudBuyItemUI:closePanel()
	self:hideUI()
	if self.needRefresh and self.callback1 then
		self.callback1()
	end
end

function CloudBuyItemUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self:adaptUI(bgImg, bgImg1)
	self.bgImg1 = bgImg1

	local winSize = cc.Director:getInstance():getWinSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 60))

	local closeBtn = bgImg:getChildByName("close_btn")
	closeBtn:setPosition(cc.p(winSize.width,winSize.height - 50))
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:closePanel()
		end
	end)

	local titleBgImg = bgImg1:getChildByName("title_bg_img")
	local infoTx = titleBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr("ACTIVITY_CLOUD_BUY_TITLE_1"))

	self:updatePanel()
	self:updatePageBtn()
	self:updateEditBox()
end

function CloudBuyItemUI:update()
	if self.maxTimes < 0 then
		self.maxTimes = 0
	end
	
	if self.times > self.maxTimes then
		self.times = self.maxTimes 
	end
	self.timesTx:setString(self.times)

	self.addBtn:setTouchEnabled(true)
	self.addBtn:setBright(true)
	self.lessBtn:setTouchEnabled(true)
	self.lessBtn:setBright(true)

	if self.times <= 1 then
		self.lessBtn:setTouchEnabled(false)
		self.lessBtn:setBright(false)
	end

	if self.times == self.maxTimes then
		self.addBtn:setTouchEnabled(false)
		self.addBtn:setBright(false)
	end

	if self.maxTimes <= 0 then
		local infoTx = self.buyBtn:getChildByName('info_tx')
		infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
		self.buyBtn:setTouchEnabled(false)
		self.buyBtn:setBright(false)
	end
end

function CloudBuyItemUI:updateEditBox()
	local topImg = self.bgImg1:getChildByName('top_img')
	self.timesTx = topImg:getChildByName('times_tx')
	self.addBtn = topImg:getChildByName('add_btn')
	self.lessBtn = topImg:getChildByName('less_btn')
	self.editbox = cc.EditBox:create(cc.size(100, 40), 'uires/ui/common/common_num_bg4.png')
	self.editbox:setPosition(self.timesTx:getPosition())
	self.editbox:setMaxLength(10)
	self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	topImg:addChild(self.editbox)
	self.timesTx:setLocalZOrder(2)

	self.editbox:registerScriptEditBoxHandler(function(event,pSender)
		local edit = pSender
		local strFmt 
		if event == "began" then
			self.editbox:setText(self.times)
			self.timesTx:setString('')
		elseif event == "ended" then
			local num = tonumber(self.editbox:getText())
			if not num then
				self.editbox:setText('')
				self.timesTx:setString('1')
				self.times = 0
				return
			end
			local times = num
			if times > self.maxTimes then
				self.times = self.maxTimes
			elseif times < 1 then
				self.times = 0
			else
				self.times = times
			end
			self.editbox:setText('')
			self:update()
		end
	end)
	self.lessBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.times > 1 then
				self.times = self.times - 1
				self:update()
			end
		end
	end)

	self.addBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.times < self.maxTimes then
				self.times = self.times + 1
				self:update()
			end
		end
	end)
	self:update()
end

function CloudBuyItemUI:updateTime(img,diffTime,pos)
	local label = img:getChildByName('time_desc_tx')
	local size = img:getContentSize()
	if label then
		label:removeFromParent()
	end
	label = cc.Label:createWithTTF('', "font/gamefont.ttf", 38)
	label:setName('time_desc_tx')
	label:setPosition(pos)
	label:setAnchorPoint(cc.p(0.5,0.5))
	img:addChild(label)
	Utils:createCDLabel(label,diffTime,COLOR_TYPE.RED,COLOROUTLINE_TYPE.RED,CDTXTYPE.FRONT,GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_17'),
		COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,22,function ()
		self:hideUI()
		if self.callback1 then
			self.callback1()
		end
		promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_20'), COLOR_TYPE.GREEN)
	end)
end

function CloudBuyItemUI:refreshPanel()
	local args = {
		id  = self.id,
	}
	MessageMgr:sendPost("get_cloud_buy_pid",'activity',json.encode(args),function(jsonObj)
		local code = jsonObj.code
		local data = jsonObj.data
		if code == 0 then
			self.data1 = data
			self:updatePanel()
			self:updatePageBtn()
			self:updateEditBox()
		end
	end)
end

function CloudBuyItemUI:updateTopPanel()
	local remainderNum = self.conf.num - self.data.buy
	local limitNum = self.conf.buy - (self.cloudBuy.buy[tostring(self.id)] or 0)
	self.maxTimes = math.min(remainderNum,limitNum)
	self.times = 1
	local topImg = self.bgImg1:getChildByName('top_img')
	local node = topImg:getChildByName('node')
	local awardBgImg = node:getChildByName('award_bg_img')
	local obj = DisplayData:getDisplayObj(self.conf.awards[1])
	local str = {'LIMIT_DESC','ACTIVITY_CLOUD_BUY_DESC_5'}
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, obj, node)
		awardBgImg = tab.awardBgImg
		local size = awardBgImg:getContentSize()
		local signImg = ClassItemCell:updateImageView(awardBgImg,'uires/ui/common/corner_blue_'..self.conf1.type..'.png','sign_img',nil,nil,
			cc.p(size.width + 2,size.height + 2),cc.p(1,1))
		signImg:setScale(0.8)
		local infoTx = ClassItemCell:updateTTFlabel(signImg,GlobalApi:getLocalStr(str[self.conf1.type]),"font/gamefont.ttf",16,'info_tx',nil,cc.p(45,45))
		infoTx:setSkewX(45.38)
		infoTx:setSkewY(-45.38)
	else
		ClassItemCell:updateItem(awardBgImg, obj, 2)
	end
	local nameTx = awardBgImg:getChildByName('name_tx')
	nameTx:setAnchorPoint(cc.p(0, 0.5))
	nameTx:setString(obj:getName())
	nameTx:setColor(obj:getNameColor(COLOR_TYPE.ORANGE))
	nameTx:setPosition(cc.p(110,70))
	obj:setLightEffect(awardBgImg)

	local nums = {self.conf.num,self.data.buy,self.conf.num - self.data.buy}
	for i=1,3 do
		local descTx = topImg:getChildByName('desc_tx_1'..i)
		local numTx = topImg:getChildByName('num_tx_'..i)
		descTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_ITEM_DESC_'..i))
		numTx:setString(nums[i])
	end
	local descTx1 = topImg:getChildByName('desc_tx_1')
	local descTx2 = topImg:getChildByName('desc_tx_2')
	descTx1:setString(GlobalApi:getLocalStr('STR_PRICE'))
	descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_8'))
	if self.conf1.type == 1 then
		local diffTime = self.data1.lottrey_time - GlobalData:getServerTime()
		descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_18'))
		self:updateTime(topImg,diffTime,cc.p(625,175))
		descTx2:setPosition(cc.p(730,175))
	else
		descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_19'))
		descTx2:setPosition(cc.p(359,175))
	end

	local descTx3 = topImg:getChildByName('desc_tx_3')
	local str = string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_9'),self.maxTimes)
	if not descTx3 then
		descTx3 = ClassItemCell:updateTTFlabel(topImg,str,nil,22,'desc_tx_3',nil,
			cc.p(698,108),nil,nil,nil,nil,cc.p(1,0.5))
	else
		descTx3 = ClassItemCell:updateTTFlabel(topImg,str,nil,22,'desc_tx_3')
	end
	local maxLen = descTx3:getStringLength()
	local colorTab = GlobalApi:getAllCharIndex(str)
	for i=0,maxLen do
		local letter = descTx3:getLetter(i)
		if letter then
			if colorTab[i + 1] then
				letter:setColor(COLOR_TYPE.GREEN)
			else
				letter:setColor(COLOR_TYPE.WHITE)
			end
		end
	end

	local numTx = topImg:getChildByName('cash_tx')
	numTx:setString(self.conf.costs)

	local barBg = topImg:getChildByName('bar_bg')
	local bar = barBg:getChildByName('bar')
	bar:setScale9Enabled(true)
	bar:setCapInsets(cc.rect(10,15,1,1))
	bar:setContentSize(cc.size(406,46))
	local per = self.data.buy/self.conf.num*100
	bar:setPercent(per)

	self.buyBtn = topImg:getChildByName('buy_btn')
	local infoTx = self.buyBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_15'))
	self.buyBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local function callback()
				local args = {
					id =  self.id, 
					aid = self.data.aid,
					num = self.times,
				}
				MessageMgr:sendPost("do_cloud_buy",'activity',json.encode(args),function(jsonObj)
					local code = jsonObj.code
					local data = jsonObj.data
					if code == 0 then
						local costs = data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						self.needRefresh = true
						self.data.buy = data.buy
						self.data.aid = data.aid
						if data.lottery == 1 then
							self.cloudBuy.buy[tostring(self.id)] = 0
							self.conf = GameData:getConfData("avcloudbuyawards")[data.aid]
							promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_20'), COLOR_TYPE.GREEN)
							-- self:closePanel()
							self:refreshPanel()
							return
						end
						self.data1.globalLog = data.globalLog
						self.data1.log = data.log
						-- self.data.buy = self.data.buy + self.times
						self.cloudBuy.buy[tostring(self.id)] = (self.cloudBuy.buy[tostring(self.id)] or 0) + self.times
						self.times = 1
						self:updatePanel()
						self:update()
						promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN)
					elseif code == 101 then
						self.needRefresh = true
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_20'), COLOR_TYPE.RED)
						self:closePanel()
					elseif code == 102 then
						self.needRefresh = true
						self:closePanel()
					end
				end)
			end
			local costNum = tonumber(GlobalApi:getGlobalValue('cloudBuyCosts'))
			local cost = costNum*self.times
            -- promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_21'),cost),
            -- MESSAGE_BOX_TYPE.MB_OK_CANCEL,callback)
			local str = string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_21'),cost,self.times)
            UserData:getUserObj():cost('cash',cost,callback,true,str)
		end
	end)
end

function CloudBuyItemUI:updatePageBtn()
	local rightBgImg = self.bgImg1:getChildByName('bottom_right_img')
	local pageBtns = {}
	local function updateBtn()
		for i=1,2 do
			local infoTx = pageBtns[i]:getChildByName('info_tx')
			if i == self.page then
				pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
				pageBtns[i]:setTouchEnabled(false)
				infoTx:setColor(COLOR_TYPE.PALE)
				infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
				infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
			else
				pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
				pageBtns[i]:setTouchEnabled(true)
				infoTx:setColor(COLOR_TYPE.DARK)
				infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
				infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
			end
		end
	end
	for i=1,2 do
		local pageBtn = rightBgImg:getChildByName('page_btn_'..i)
		local infoTx = pageBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_ITEM_TITLE_'..i))
		pageBtns[i] = pageBtn
		pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.page = self.page % 2 + 1
				updateBtn()
				self:updateBottomRightPanel()
			end
		end)
	end
	updateBtn()
end

function CloudBuyItemUI:updateRecordCell(node,diff,index,maxWidth,data)
	local diffHeight = 8
	diff = diff + diffHeight
	local nameTx = ClassItemCell:updateTTFlabel(node,data.name,nil,20,'name_tx_'..index,nil,
		cc.p(25,-diff),nil,nil,nil,nil,cc.p(0,1))
	ClassItemCell:updateTTFlabel(node,data.sid..GlobalApi:getLocalStr('FU'),nil,20,'fu_tx_'..index,nil,
		cc.p(205,-diff),nil,nil,nil,nil,cc.p(0,1))
	local nowTime = GlobalData:getServerTime()
	local diffTime = math.floor((nowTime - data.time)/3600)
	local diffTime1 = math.ceil((nowTime - data.time + 1)/60)
	local str = ''
	if diffTime > 0 then
		str = string.format(GlobalApi:getLocalStr('HOUR_AGO'),diffTime)
	else
		str = string.format(GlobalApi:getLocalStr('MINUTE_AGO'),diffTime1)
	end
	ClassItemCell:updateTTFlabel(node,str,nil,20,'time_tx_'..index,nil,
		cc.p(295,-diff),nil,nil,nil,nil,cc.p(0,1))
	local timesTx = ClassItemCell:updateTTFlabel(node,string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_29'),data.num),nil,20,'desc_tx_'..index,nil,
		cc.p(405,-diff),nil,nil,nil,nil,cc.p(0,1))
	local size = timesTx:getContentSize()
	diff = diff + size.height + diffHeight
	local lineImg = ClassItemCell:updateImageView(node,'uires/ui/common/common_tiao_4.png','line_img_'..index,nil,nil,
		cc.p(0,-diff),cc.p(0,0.5))
	lineImg:setScale9Enabled(true)
	lineImg:setContentSize(cc.size(maxWidth,lineImg:getContentSize().height))
	-- diff = diff + diffHeight
	return diff
end

function CloudBuyItemUI:updateMyRecord(node,diff,maxWidth,data)
	local diffHeight = 8
	local diffHeight1 = 10
	diff = diff + diffHeight
	local str = string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_23'),#data)
	local descTx1 = ClassItemCell:updateTTFlabel(node,str,nil,26,'desc_tx_1',nil,
		cc.p(maxWidth/2,-diff),nil,nil,nil,nil,cc.p(0.5,1))
	diff = diff + descTx1:getContentSize().height + diffHeight
	local descTx2 = ClassItemCell:updateTTFlabel(node,GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_16'),nil,24,'desc_tx_2',nil,
		cc.p(maxWidth/2,-diff),COLOR_TYPE.ORANGE,nil,nil,nil,cc.p(0.5,1))
	diff = diff + descTx2:getContentSize().height + diffHeight
	local lineImg = ClassItemCell:updateImageView(node,'uires/ui/common/common_tiao_4.png','line_img',nil,nil,
		cc.p(0,-diff),cc.p(0,0.5))
	lineImg:setScale9Enabled(true)
	lineImg:setContentSize(cc.size(maxWidth,lineImg:getContentSize().height))
	diff = diff + diffHeight1
	local size
	local num = 0
	for i,v in ipairs(data) do
		for i1,v1 in ipairs(v) do
			num = num + 1
			if num % 2 == 1 and num ~= 1 then
				diff = diff + size.height + diffHeight1
			end
			local descTx = ClassItemCell:updateTTFlabel(node,v1,nil,24,'code_tx_'..num,nil,
				cc.p(20 + maxWidth/2*((num - 1) % 2),-diff),nil,nil,nil,nil,cc.p(0,1))
			if not size then
				size = descTx:getContentSize()
			end
		end
	end
	diff = diff + size.height

	local str = string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_23'),num)
	local descTx1 = ClassItemCell:updateTTFlabel(node,str,nil,26,'desc_tx_1')
	local maxLen = descTx1:getStringLength()
	local colorTab = GlobalApi:getAllCharIndex(str)
	for i=0,maxLen do
		local letter = descTx1:getLetter(i)
		if letter then
			if colorTab[i + 1] then
				letter:setColor(COLOR_TYPE.GREEN)
			else
				letter:setColor(COLOR_TYPE.WHITE)
			end
		end
	end
	return diff
end

function CloudBuyItemUI:updateBottomRightPanel()
	local rightBgImg = self.bgImg1:getChildByName('bottom_right_img')
	local neiBgImg = rightBgImg:getChildByName('nei_bg_img')
	local sv1 = neiBgImg:getChildByName('sv_1')
	sv1:setScrollBarEnabled(false)
	local sv2 = neiBgImg:getChildByName('sv_2')
	sv2:setScrollBarEnabled(false)
	local size = neiBgImg:getContentSize()
	if self.page == 1 then
		local num = 0
		for k,v in pairs(self.data1.globalLog) do
			num = num + 1
		end
		if self.data1.globalLog and num > 0 then
			sv1:setVisible(true)
			sv2:setVisible(false)
			local node = sv1:getChildByName('node')
			if not node then
				node = cc.Node:create()
				node:setName('node')
				sv1:addChild(node)
			end
			local diff = 0
			local size = sv1:getContentSize()
			local tab = {}
			for k,v in pairs(self.data1.globalLog) do
				tab[tonumber(k)] = v
			end
			table.sort(tab, function(a,b)
				return a.time > b.time
			end )
			for i,v in ipairs(tab) do
				diff = self:updateRecordCell(node,diff,i,size.width,v)
			end
			if size.height > diff then
				node:setPosition(cc.p(0,size.height))
				sv1:setInnerContainerSize(size)
			else
				node:setPosition(cc.p(0,diff))
				sv1:setInnerContainerSize(cc.size(size.width,diff))
			end
			ClassItemCell:updateTTFlabel(neiBgImg,'','font/gamefont.ttf',34,'desc_tx')
		else
			sv1:setVisible(false)
			sv2:setVisible(false)
			ClassItemCell:updateTTFlabel(neiBgImg,GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_27'),'font/gamefont.ttf',34,'desc_tx',nil,
				cc.p(size.width/2,size.height/2),COLOR_TYPE.PALE,COLOROUTLINE_TYPE.PALE,2)
		end
	else
		if self.data1.log and #self.data1.log > 0 then
			sv1:setVisible(false)
			sv2:setVisible(true)
			local node = sv2:getChildByName('node')
			if not node then
				node = cc.Node:create()
				node:setName('node')
				sv2:addChild(node)
			end
			local size = sv2:getContentSize()
			local diff = self:updateMyRecord(node,0,size.width,self.data1.log)
			if size.height > diff then
				node:setPosition(cc.p(0,size.height))
				sv2:setInnerContainerSize(size)
			else
				node:setPosition(cc.p(0,diff))
				sv2:setInnerContainerSize(cc.size(size.width,diff))
			end
			ClassItemCell:updateTTFlabel(neiBgImg,'','font/gamefont.ttf',34,'desc_tx')
		else
			sv1:setVisible(false)
			sv2:setVisible(false)
			local size = neiBgImg:getContentSize()
			ClassItemCell:updateTTFlabel(neiBgImg,GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_28'),'font/gamefont.ttf',34,'desc_tx',nil,
				cc.p(size.width/2,size.height/2),COLOR_TYPE.PALE,COLOROUTLINE_TYPE.PALE,2)
		end
	end
end

function CloudBuyItemUI:updateBottomLeftPanel()
	local awardsConf = GameData:getConfData("avcloudbuyawards")
	local leftBgImg = self.bgImg1:getChildByName('bottom_left_img')
	local pl = leftBgImg:getChildByName('pl')
	local descTx1 = leftBgImg:getChildByName('desc_tx_1')
	local descTx = leftBgImg:getChildByName('desc_tx')
	local descTx2 = pl:getChildByName('desc_tx_2')
	local descTx3 = pl:getChildByName('desc_tx_3')
	local fuTx = pl:getChildByName('fu_tx')
	local nameTx = pl:getChildByName('name_tx')
	local node = pl:getChildByName('node')
	local awardBgImg = node:getChildByName('award_bg_img')
	descTx1:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_22'))
	if self.data1.last_winners and self.data1.last_winners.name then
		descTx:setString('')
		pl:setVisible(true)
		local award = DisplayData:getDisplayObj(awardsConf[self.data1.last_winners.aid].awards[1])
		if not awardBgImg then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, node)
			awardBgImg = tab.awardBgImg
			awardBgImg:setScale(0.8)
		end
		nameTx:setString(self.data1.last_winners.name)
		nameTx:setColor(COLOR_TYPE.ORANGE)
		fuTx:setString(self.data1.last_winners.sid..GlobalApi:getLocalStr('FU'))
		awardBgImg:setTouchEnabled(false)

		local now = os.date('*t',self.data1.last_winners.time)
		descTx2:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_33'),now.year,now.month,now.day)
			..'\n\t\t\t\t\t'..
			string.format('%02d',now.hour)..':'..
			string.format('%02d',now.min)..':'..
			string.format('%02d',now.sec))
		local code = self.data1.last_winners.code
		local str1 = string.sub(code,1,12)
		local str2 = string.sub(code,13,string.len(code))
		descTx3:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_32')..str1..'\n\t\t\t\t\t'..str2)
	else
		pl:setVisible(false)
		descTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT29'))
	end
end

function CloudBuyItemUI:updatePanel()
	self:updateTopPanel()
	self:updateBottomLeftPanel()
	self:updateBottomRightPanel()
end

return CloudBuyItemUI