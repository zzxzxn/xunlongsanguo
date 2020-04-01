local UseUI = class("UseUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function UseUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_USE
	self.obj = obj[1]
	self.maxTimes = 0
	self.ntype = obj[2] or 3
	self.mergeNum = ((self.obj:getMergeNum() == 0) and 1) or self.obj:getMergeNum()
	self.times = 1
end

function UseUI:OnUse(act)
    local act = act or 'use'
 	local args = {
  		type = 'material',
  		id = self.obj:getId(),
  		num = self.times * self.mergeNum
  	}
  	MessageMgr:sendPost(act,'bag',json.encode(args),function (response)
		
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
			local useEffect = self.obj:getUseEffect()
            if useEffect then
            	local tab = string.split(useEffect,':')
            	if tab and tab[1] == 'arena' then
            		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('BAG_GET_DESC_1'),self.times * self.mergeNum), COLOR_TYPE.GREEN)
            	end
            end
			BagMgr:hideUse()
		end
	end)
end

function UseUI:update()
	-- self.maxTimes = self.obj:getNum()
	local num = self.obj:getNum()
	self.maxTimes = math.floor(num/self.mergeNum)
	if self.maxTimes > 99 then
		self.maxTimes = 99
	end
    if self.maxTimes < 0 then
    	self.maxTimes = 0
    end
    if self.times > self.maxTimes then
    	self.times = self.maxTimes 
    end
    if self.times == 0 and num > self.mergeNum then
    	self.times = 1
    end
    self.timesTx:setString(self.times * self.mergeNum)

    if self.times <= 1 then
		self.lessBtn:setTouchEnabled(false)
		self.lessBtn:setBright(false)
	else
		self.lessBtn:setTouchEnabled(true)
		self.lessBtn:setBright(true)
    end

    if self.times >= self.maxTimes then
		self.addBtn:setTouchEnabled(false)
		self.addBtn:setBright(false)
	else
		self.addBtn:setTouchEnabled(true)
		self.addBtn:setBright(true)
    end

	
    if self.maxTimes == 0 or self.times == 0 then
		self.okBtn:setTouchEnabled(false)
		self.okBtn:setBright(false)
		local btnTx = self.okBtn:getChildByName("info_tx")
		btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end

    self.numTx:setString(string.format(GlobalApi:getLocalStr('HAD_NUM'),num))
end

function UseUI:init()
	self.bgImg = self.root:getChildByName("sell_bg_img")
	local sellImg = self.bgImg:getChildByName("sell_img")
	self:adaptUI(self.bgImg, sellImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	sellImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	self.lessBtn = sellImg:getChildByName("less_btn")
	self.addBtn = sellImg:getChildByName("add_btn")
	self.okBtn = sellImg:getChildByName("ok_btn")
	local btnTx = self.okBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('USE'))
	self.timesTx = sellImg:getChildByName("times_tx")
    local titleTx = sellImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('USE'))
	local maxBtn = sellImg:getChildByName("max_btn")
	local btnTx = maxBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('MAX'))

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

	local closeBtn = sellImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           BagMgr:hideUse()
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

  	self.editbox = cc.EditBox:create(cc.size(120, 40), 'uires/ui/common/name_bg9.png')
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
			local num = tonumber(self.editbox:getText())
			if not num then
				self.editbox:setText('')
				self.timesTx:setString('0')
				self.times = 0
				return
			end
			local times = math.floor(num/self.mergeNum)
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
        	if self.obj:getId() == 200079 then 	--粮草包上限处理
        		local food = UserData:getUserObj():getFood()

        		local useEffect = self.obj:getUseEffect()
			    local tab = string.split(useEffect,':')
			    local tab2 = string.split(tab[1],'.')
			    local dropId = tab2[2]
			    local dropData = GameData:getConfData("drop")
				local dropConf = dropData[tonumber(dropId)]
				local fixDisPlayData = DisplayData:getDisplayObjs(dropConf.fixed)
        		local getFood = self.times * fixDisPlayData[1]:getNum()

				local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
				if food + getFood >= maxFood then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
					return
				end
        	end

           	local cost = self.obj:getCost()
			if cost and cost:getId() == 'cash' then
                UserData:getUserObj():cost('cash',cost:getNum() * self.times,function()
                   self:OnUse('use_day_box')
                end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost:getNum() * self.times))
			else
				self:OnUse()
			end
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

return UseUI