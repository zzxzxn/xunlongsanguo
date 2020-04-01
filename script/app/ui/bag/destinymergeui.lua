local DestinyMergeUI = class("DestinyMergeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function DestinyMergeUI:ctor(fromid,toId)
	self.uiIndex = GAME_UI.UI_DRESSMERGE
	self.times = 1
	self.maxTimes = 0
	self.fromId = fromid
	self.toId = toId
end

function DestinyMergeUI:onShow()
	self:update()
end

function DestinyMergeUI:OnMerge()
	local currConf = GameData:getConfData("item")[self.fromId]
	local gold = nil  
	if currConf.cost[1] and tonumber(currConf.cost[1]) ~= 0 then
		gold = DisplayData:getDisplayObj(currConf.cost[1])
	end
	local mergeGold = 0
	if gold then
		mergeGold = gold:getNum()
	end
	
    local costNum = self.times*mergeGold
	UserData:getUserObj():cost('gold',costNum,function()
	 	local args = {
	  		id = self.obj:getId(),
	  		num = self.times*currConf.mergeNum
	  	}
	  	MessageMgr:sendPost('merge','bag',json.encode(args),function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				local awards = data.awards
				if awards then
					GlobalApi:parseAwardData(awards)
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
		            end
					promptmgr:showAttributeUpdate(showWidgets)
				end
				local costs = data.costs
	            if costs then
	                GlobalApi:parseAwardData(costs)
	            end
	            BagMgr:hideDestinyMerge()
			end
		end)
	end)

end

function DestinyMergeUI:update()

	local num = self.obj:getNum()
    self.maxTimes = math.floor(num/self.mergeNum)
    if self.maxTimes < 0 then
    	self.maxTimes = 0
    end

    if self.times > self.maxTimes then
    	self.times = self.maxTimes 
    end
	local currConf = GameData:getConfData("item")[self.fromId]
	local objtemp = DisplayData:getDisplayObj(currConf.mergeItem[1])
    self.timesTx:setString(self.times*objtemp:getNum())

	self.addBtn:setTouchEnabled(true)
	self.addBtn:setBright(true)
	self.lessBtn:setTouchEnabled(true)
	self.lessBtn:setBright(true)

    if self.times <= 1 then
		self.lessBtn:setTouchEnabled(false)
		self.lessBtn:setBright(false)
    end

    if self.times >= self.maxTimes then
		self.addBtn:setTouchEnabled(false)
		self.addBtn:setBright(false)
    end

    local infoTx = self.okBtn:getChildByName("info_tx")
    if self.maxTimes <= 0 then
		self.okBtn:setTouchEnabled(false)
		self.okBtn:setBright(false)
		infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
	else
		infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    end

    local currConf = GameData:getConfData("item")[self.fromId]
    self.numTx:setString(self.nextObj:getNum())
    self.currNum:setString(self.obj:getNum()..'/'..self.mergeNum)
    if self.obj:getNum() < self.mergeNum then
    	self.currNum:setColor(COLOR_TYPE.RED)
    else
    	self.currNum:setColor(COLOR_TYPE.GREEN)
    end
    self.nextNum:setString(self.times*objtemp:getNum())
	local gold = nil  
	if currConf.cost[1] and tonumber(currConf.cost[1]) ~= 0 then
		gold = DisplayData:getDisplayObj(currConf.cost[1])
	end
	local mergeGold = 0
	if gold then
		mergeGold = gold:getNum()
	end
    self.costNumTx:setString(self.times*mergeGold)
end

function DestinyMergeUI:init()
	self.bgImg = self.root:getChildByName("merge_bg_img")
	local mergeImg = self.bgImg:getChildByName("merge_img")
	self:adaptUI(self.bgImg, mergeImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	mergeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	local closeBtn = mergeImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           BagMgr:hideDestinyMerge()
        end
    end)
	local soldierImg = mergeImg:getChildByName("soldier_img")
	soldierImg:setVisible(false)
	self.lessBtn = mergeImg:getChildByName("less_btn")
	self.addBtn = mergeImg:getChildByName("add_btn")
	self.okBtn = mergeImg:getChildByName("ok_btn")
	local btnTx = self.okBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('STR_MERGE_1'))
	self.timesTx = mergeImg:getChildByName("times_tx")
	local titleTx = mergeImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('DESTINY_MERGE'))
	titleTx:setPosition(cc.p(mergeImg:getContentSize().width/2,titleTx:getPositionY()))
	titleTx:setColor(COLOR_TYPE.PALE)
	titleTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
	self.costNumTx = mergeImg:getChildByName('cost_num_tx')
    local maxBtn = mergeImg:getChildByName("max_btn")
	local btnTx = maxBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('MAX'))
	maxBtn:setVisible(true)
    local neiBgImg = mergeImg:getChildByName("nei_bg_img")
	local awardBgNode = neiBgImg:getChildByName("award_bg_node")
	local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	awardBgNode:addChild(itemcell.awardBgImg)
	local nameTx = awardBgNode:getChildByName("name_tx")
	local descTx = awardBgNode:getChildByName("desc_tx")
	descTx:setString(GlobalApi:getLocalStr('STR_GETWAY2')..'：')
	self.numTx = awardBgNode:getChildByName("num_tx")

	self.obj = BagData:getMaterialById(self.fromId)
	self.nextObj = BagData:getMaterialById(self.toId)
	itemcell.awardBgImg:loadTexture(self.nextObj:getBgImg())
	nameTx:setString(self.nextObj:getName())
	nameTx:setColor(self.nextObj:getNameColor())
	nameTx:enableOutline(self.nextObj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	itemcell.awardImg:loadTexture(self.nextObj:getIcon())
	itemcell.awardImg:ignoreContentAdaptWithSize(true)

	local currConf = GameData:getConfData("item")[self.fromId]
	local nextConf = GameData:getConfData("item")[self.toId]
    self.mergeNum = currConf.mergeNum
	local num = self.obj:getNum()
	if num < self.mergeNum then
		self.times = 0
	end

    local currTab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    currTab.awardBgImg:setPosition(cc.p(113,290))
    mergeImg:addChild(currTab.awardBgImg)
    currTab.awardBgImg:loadTexture(self.obj:getBgImg())
    currTab.awardImg:loadTexture(self.obj:getIcon())
    self.currNum = currTab.lvTx
	self.currNum:setColor(COLOR_TYPE.GREEN)
	self.currNum:enableOutline(COLOROUTLINE_TYPE.GREEN,1)
	currTab.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           GetWayMgr:showGetwayUI(self.obj,true,0,nil,1,true)
           --GetWayMgr:showGetwayUI(obj,true,equiparr[i].num,self.obj,equiparr[i].poslevel,false)
        end
    end)

    local nextTab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    nextTab.awardBgImg:setPosition(cc.p(333,290))
    mergeImg:addChild(nextTab.awardBgImg)
    nextTab.awardBgImg:loadTexture(self.nextObj:getBgImg())
    nextTab.awardImg:loadTexture(self.nextObj:getIcon())
    self.nextNum = nextTab.lvTx

  	self.editbox = cc.EditBox:create(cc.size(130, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.timesTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    mergeImg:addChild(self.editbox)
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
				self.timesTx:setString('0')
				self.times = 0
				return
			end
			local times = math.floor(num)
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

	self.okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           self:OnMerge()
        end
    end)

	maxBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
       		self.times = self.maxTimes
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

return DestinyMergeUI