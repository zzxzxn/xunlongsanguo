local SellUI = class("SellUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SellUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_SELL
	self.obj = obj[1]
	self.times = 1
	self.maxTimes = 0
	self.ntype = obj[2] or 1
end

function SellUI:OnSell()
 	local args = {
  		type = self.stype,
  		id = self.obj:getId(),
  		num = self.times
  	}
  	MessageMgr:sendPost('sell','bag',json.encode(args),function (response)
		
		local code = response.code
		local data = response.data
		if code == 0 then
			local awards = data.awards
			GlobalApi:parseAwardData(awards)
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local showAward = DisplayData:getDisplayObjs(awards)
            local showWidgets = {}
            for i,v in ipairs(showAward) do
				local name = GlobalApi:getLocalStr("CONGRATULATION_TO_GET")..v:getName()..'x'..v:getNum()
				local color = COLOR_TYPE.GREEN
				local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
				w:setTextColor(color)
				w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
				w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				table.insert(showWidgets, w)
            	-- showTab[#showTab + 1] = {GlobalApi:getLocalStr("CONGRATULATION_TO_GET")..v:getName()..'x'..v:getNum(),'GREEN'}
            end
			self.currObj = nil
			-- local winSize = cc.Director:getInstance():getVisibleSize()
			-- local sz = self.bgImg:getContentSize()
			-- local x, y = self.bgImg:convertToWorldSpace(cc.p(sz.width / 2, sz.height / 2))
			promptmgr:showAttributeUpdate(showWidgets)
			-- promptmgr:showAttributeUpdate(winSize.width/2,winSize.height/2, showTab)
			BagMgr:hideSell()
		end
	end)
end

function SellUI:update()

	self.maxTimes = self.obj:getNum()
    
    if self.maxTimes < 0 then
    	self.maxTimes = 0
    end

    
    if self.times > self.maxTimes then
    	self.times = self.maxTimes 
    end
    self.timesTx:setString(self.times)
    self.moreNumTx:setString(self.obj:getSell() * self.times)
    self.richText:format(true)

	self.addBtn:setTouchEnabled(true)
	self.addBtn:setBright(true)
	self.lessBtn:setTouchEnabled(true)
	self.lessBtn:setBright(true)

    if self.times == 1 then
		self.lessBtn:setTouchEnabled(false)
		self.lessBtn:setBright(false)
    end

    if self.times == self.maxTimes then
		self.addBtn:setTouchEnabled(false)
		self.addBtn:setBright(false)
    end

    if self.maxTimes == 0 then
		self.okBtn:setTouchEnabled(false)
		self.okBtn:setBright(false)
    end

    self.numTx:setString(string.format(GlobalApi:getLocalStr('HAD_NUM'),self.maxTimes))
end

function SellUI:init()
	self.bgImg = self.root:getChildByName("sell_bg_img")
	local sellImg = self.bgImg:getChildByName("sell_img")
	self:adaptUI(self.bgImg, sellImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	sellImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	self.lessBtn = sellImg:getChildByName("less_btn")
	self.addBtn = sellImg:getChildByName("add_btn")
	self.okBtn = sellImg:getChildByName("ok_btn")
	local btnTx = self.okBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('SELL'))
	self.timesTx = sellImg:getChildByName("times_tx")
	local titleTx = sellImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('SELL_1'))
    
    local infoTx = sellImg:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('ENTER_THE_NUM'))
    local neiBgImg = sellImg:getChildByName("nei_bg_img")


	local awardBgNode = neiBgImg:getChildByName("award_bg_node")
	local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, awardBgNode)
	itemcell.awardBgImg:setTouchEnabled(false)
	itemcell.lvTx:setVisible(false)
	local nameTx = awardBgNode:getChildByName("name_tx")
	self.numTx = awardBgNode:getChildByName("num_tx")
	nameTx:setString(self.obj:getName())
	nameTx:setColor(self.obj:getNameColor())
	nameTx:enableOutline(self.obj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	if self.ntype == 1 then
		if self.obj:getCategory() == 'dress' then
			self.stype = 'dress'
		else
			self.stype = 'material'
		end
	else
		self.stype = 'gem'
	end

	local closeBtn = sellImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           BagMgr:hideSell()
        end
    end)

  	self.editbox = cc.EditBox:create(cc.size(160, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.timesTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    sellImg:addChild(self.editbox)
    self.timesTx:setLocalZOrder(2)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
    	local edit = pSender
		local strFmt 
		if event == "began" then
			self.editbox:setText(self.times)
			self.timesTx:setString('')
		elseif event == "ended" then
			local times = tonumber(self.editbox:getText()) or 1
			if times > self.maxTimes then
				self.times = self.maxTimes
			elseif times < 1 then
				self.times = 1
			else
				self.times = times
			end
			self.editbox:setText('')
			self:update()
		end
    end)

	self.okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           self:OnSell()
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

	local richText = xx.RichText:create()
	richText:setAlignment('left')
	richText:setVerticalAlignment('middle')
	local richText1 = xx.RichText:create()
	richText1:setAlignment('left')
	richText1:setVerticalAlignment('middle')
	richText:setContentSize(cc.size(250, 30))
	richText1:setContentSize(cc.size(250, 30))
	local tx1 = GlobalApi:getLocalStr('UNIT_PRICE')
	local tx3 = GlobalApi:getLocalStr('GET')

	local re1 = xx.RichTextLabel:create(tx1,25,COLOR_TYPE.ORANGE)
	local re2 = xx.RichTextImage:create('uires/ui/res/res_gold.png')
	local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.ORANGE)
	local re4 = xx.RichTextLabel:create(self.obj:getSell(),25,COLOR_TYPE.WHITE)
	local re5 = xx.RichTextLabel:create(self.obj:getSell(),25,COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re4:setStroke(COLOR_TYPE.BLACK, 1)
	re5:setStroke(COLOR_TYPE.BLACK, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re4)
	richText1:addElement(re3)
	richText1:addElement(re2)
	richText1:addElement(re5)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText1:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(130,130))
	richText1:setPosition(cc.p(130,170))
	sellImg:addChild(richText)
	sellImg:addChild(richText1)

	self.moreNumTx = re5
	self.richText = richText1
    self:update()
end

return SellUI