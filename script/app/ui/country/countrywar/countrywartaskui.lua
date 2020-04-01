local CountryWarTaskUI = class("CountryWarTaskUI", BaseUI)
local PERSONAL_PAGE = 2
local COUNTRY_PAGE = 1
local TITLE_TEXTURE_NOR = {
	'uires/ui/common/title_btn_nor_1.png',
	'uires/ui/common/title_btn_nor_1.png',
}
local TITLE_TEXTURE_SEL = {
	'uires/ui/common/title_btn_sel_1.png',
	'uires/ui/common/title_btn_sel_1.png',
}

local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED'
}

function CountryWarTaskUI:ctor(page,data)
	self.uiIndex = GAME_UI.UI_COUNTRYWAR_TASK
	self.page = page or 1
	self.data = data
	self.intervalSize = 2
	self.zxIntervalSize = 15
	self.maxCellNum = 0
end

function CountryWarTaskUI:getPersonalTaskGotInfo(taskId)
	local tab = self.data.selfInfo.personalTaskAwardGot
	if not tab then
		return 0
	end
	for i,v in ipairs(tab) do
		if v == taskId then
			return 1
		end
	end
	return 0
end

function CountryWarTaskUI:getCountryTaskGotInfo(taskType)
	local tab = self.data.selfInfo.countryTaskAwardGot
	if not tab then
		return 0
	end
	for i,v in pairs(tab) do
		if v == taskType then
			return 1
		end
	end
	return 0
end

function CountryWarTaskUI:getDataByType(stype,ntype)
	if stype == 'callCount' or stype == 'replyCallCount' or stype == 'fastReliveCount' 
		or stype == 'buyGoodsCount' then
		return self.data.selfInfo[stype]
	-- elseif stype == 'callCount' then
	-- elseif stype == 'replyCallCount' then
	elseif stype == 'killCount' then
		return self.data.selfInfo.taskInfo[tostring(ntype)].killCount
	elseif stype == 'conqueredCityCount' then
		return self.data.selfInfo.taskInfo[tostring(ntype)].conqueredCity
	-- elseif stype == 'fastReliveCount' then
	-- elseif stype == 'buyGoodCount' then
	end
end

function CountryWarTaskUI:getData()
	local tab = {}
	if self.page == 1 then
		local conf = GameData:getConfData('countrywartask')
		for k,v in pairs(self.data.tasks) do
			v.taskType = tonumber(k)
			local got = self:getCountryTaskGotInfo(v.taskType)
			v.got = got
			v.num = v.curVal or 0
			v.condition = conf[tonumber(k)][v.taskId].condition2
			tab[#tab + 1] = v
		end
	else
		local camp = CountryWarMgr.camp
		local conf = GameData:getConfData('countrywartaskpersonal')
		for i,v in ipairs(conf) do
			if v.countryType == 0 or v.countryType ~= camp then
				local got = self:getPersonalTaskGotInfo(i)
				v.got = got
				local num = self:getDataByType(v.event,v.countryType)
				v.canGet = ((num >= v.condition) and 1 or 0)
				v.num = ((num >= v.condition) and v.condition or num)
				tab[#tab + 1] = v
			end
		end
	end
	return tab
end

function CountryWarTaskUI:updatePersonalTask()
	local size1
	local conf = self:getData()
	table.sort( conf, function(a,b)
		local got1 = a.got
		local got2 = b.got
		if got1 == got2 then
			local canGet1 = a.canGet
			local canGet2 = b.canGet
			if canGet1 == canGet2 then
				local id1 = a.id
				local id2 = b.id
				return id1 < id2
			else
				return canGet1 > canGet2
			end
		else
			return got1 < got2
		end
	end)
	local canGet = 0
	for i,v in ipairs(conf) do
		local cell = self.sv:getChildByName('cell_'..i)
		if not cell then
			cell = cc.CSLoader:createNode('csb/countrywartaskcell.csb')
			cell:setName('cell_'..i)
			self.sv:addChild(cell)
			self.maxCellNum = i
		end
		local taskImg = cell:getChildByName('task_img')
		size1 = taskImg:getContentSize()
		local nameTx = taskImg:getChildByName('name_tx')
		local targetTx = taskImg:getChildByName('target_tx')
		nameTx:setString(v.desc)
		local num = v.num
		if num > v.condition then
			num = v.condition
		end
		targetTx:setString('('..num..'/'..v.condition..')')
		targetTx:setPosition(cc.p(nameTx:getPositionX() + nameTx:getContentSize().width,nameTx:getPositionY()))
		if v.num >= v.condition then
			targetTx:setColor(COLOR_TYPE.GREEN)
		else
			targetTx:setColor(COLOR_TYPE.WHITE)
		end
		local awards = DisplayData:getDisplayObjs(v.award)
		for j=1,3 do
			local awardBgImg = taskImg:getChildByName('award_'..j..'_img')
			local awardImg = awardBgImg:getChildByName('award_img')
			local numTx = awardBgImg:getChildByName('num_tx')
			if awards[j] then
				awardBgImg:loadTexture(awards[j]:getBgImg())
				awardBgImg:setVisible(true)
				awardImg:loadTexture(awards[j]:getIcon())
				awardImg:ignoreContentAdaptWithSize(true)
				numTx:setString('x'..awards[j]:getNum())
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[j],false)
					end
				end)
			else
				awardBgImg:setVisible(false)
			end
		end
		local taskBgImg = taskImg:getChildByName('task_bg_img')
		local awardImg = taskBgImg:getChildByName('task_img')
		awardImg:loadTexture('uires/icon/dailytask/'..v.icon)
		awardImg:ignoreContentAdaptWithSize(true)

		local gotoBtn = taskImg:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		local getBtn = taskImg:getChildByName('get_btn')
		local infoTx = getBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
		getBtn:setTouchEnabled(false)
		-- local num = self:getDataByType(v.event)
		-- if self:getCountryTaskGotInfo(v.taskId) then
		-- print('==============================',v.event,num,v.condition)
		if v.got == 1 then
			getBtn:setVisible(true)
			getBtn:setBright(false)
			infoTx:setColor(COLOR_TYPE.WHITE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
		elseif v.canGet == 1 then
			canGet = 1
			getBtn:setVisible(true)
			getBtn:setBright(true)
			getBtn:setTouchEnabled(true)
			infoTx:setColor(COLOR_TYPE.WHITE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
			getBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					CountryWarMgr:getPersonalTaskAward(v.id,function()
			            if not self.data.selfInfo.personalTaskAwardGot then
			                self.data.selfInfo.personalTaskAwardGot = {}
			            end
			            self.data.selfInfo.personalTaskAwardGot[#self.data.selfInfo.personalTaskAwardGot + 1] = v.id
						self:updatePanel()
					end)
			    end
			end)
		else
			getBtn:setVisible(false)
		end
		gotoBtn:setVisible(v.canGet ~= 1)
		gotoBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				-- GlobalApi:getGotoByModule(conf[v.id].key)
				-- self:hideMySelf(true)
				CountryWarMgr:hideCountryWarTask()
				CountryWarMgr:showCountryWarMap(nil,function()
					CountryWarMgr:setWinPosition()
				end)
		    end
		end)
	end

	local size = self.sv:getContentSize()
    if #conf * (size1.height + self.intervalSize) > size.height then
        self.sv:setInnerContainerSize(cc.size(size.width,(#conf * (size1.height + self.intervalSize))))
    else
        self.sv:setInnerContainerSize(size)
    end
    local function getPos(i)
    	local size2 = self.sv:getInnerContainerSize()
		return cc.p(0,size2.height - (size1.height + self.intervalSize) * i)
	end
	for i=1,self.maxCellNum do
		local cell = self.sv:getChildByName('cell_'..i)
		if i <= #conf then
			cell:setPosition(getPos(i))
			cell:setVisible(true)
		else
			cell:setVisible(false)
		end
	end
	UserData:getUserObj():setSignByType('personalTaskAwards',canGet)
end

function CountryWarTaskUI:updateCountryTask()
	local size1
	local data = self:getData()
	local maxNum = 0
	local conf = GameData:getConfData('countrywartask')
	table.sort( data, function(a,b)
		local got1 = a.got
		local got2 = b.got
		if got1 == got2 then
			local finish1 = a.finish
			local finish2 = b.finish
			if finish1 == finish2 then
				local type1 = a.taskType
				local type2 = b.taskType
				return type1 < type2
			else
				return finish1 > finish2
			end
		else
			return got1 < got2
		end
	end)
	local canGet = 0
	for i,v in ipairs(data) do
		local cell = self.sv:getChildByName('cell_'..i)
		if not cell then
			cell = cc.CSLoader:createNode('csb/countrywartaskcell.csb')
			cell:setName('cell_'..i)
			self.sv:addChild(cell)
			self.maxCellNum = i
		end
		local conf1 = conf[v.taskType][v.taskId]
		local taskImg = cell:getChildByName('task_img')
		size1 = taskImg:getContentSize()
		local nameTx = taskImg:getChildByName('name_tx')
		nameTx:setString(conf1.desc)
		local targetTx = taskImg:getChildByName('target_tx')
		local num = v.num
		if num > v.condition then
			num = v.condition
		end
		targetTx:setString('('..num..'/'..v.condition..')')
		targetTx:setPosition(cc.p(nameTx:getPositionX() + nameTx:getContentSize().width,nameTx:getPositionY()))
		if v.num >= v.condition then
			targetTx:setColor(COLOR_TYPE.GREEN)
		else
			targetTx:setColor(COLOR_TYPE.WHITE)
		end
		local awards = DisplayData:getDisplayObjs(conf1.award)
		for j=1,3 do
			local awardBgImg = taskImg:getChildByName('award_'..j..'_img')
			local awardImg = awardBgImg:getChildByName('award_img')
			local numTx = awardBgImg:getChildByName('num_tx')
			if awards[j] then
				awardBgImg:loadTexture(awards[j]:getBgImg())
				awardBgImg:setVisible(true)
				awardImg:loadTexture(awards[j]:getIcon())
				awardImg:ignoreContentAdaptWithSize(true)
				numTx:setString('x'..awards[j]:getNum())
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[j],false)
					end
				end)
			else
				awardBgImg:setVisible(false)
			end
		end
		local taskBgImg = taskImg:getChildByName('task_bg_img')
		local awardImg = taskBgImg:getChildByName('task_img')
		awardImg:loadTexture('uires/icon/dailytask/'..conf1.icon)
		awardImg:ignoreContentAdaptWithSize(true)

		local gotoBtn = taskImg:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		local getBtn = taskImg:getChildByName('get_btn')
		local infoTx = getBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
		getBtn:setTouchEnabled(false)
		if v.got == 1 then
			getBtn:setVisible(true)
			getBtn:setBright(false)
			infoTx:setColor(COLOR_TYPE.WHITE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
		elseif v.finish ~= 0 then
			canGet = 1
			getBtn:setVisible(true)
			getBtn:setBright(true)
			getBtn:setTouchEnabled(true)
			infoTx:setColor(COLOR_TYPE.WHITE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
			getBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					CountryWarMgr:getCountryTaskAward(v.taskType,v.taskId,function()
			            if not self.data.selfInfo.countryTaskAwardGot then
			               self.data.selfInfo.countryTaskAwardGot = {}
			            end
			            self.data.selfInfo.countryTaskAwardGot[#self.data.selfInfo.countryTaskAwardGot + 1] = v.taskType
						self:updatePanel()
					end)
			    end
			end)
		else
			getBtn:setVisible(false)
		end
		gotoBtn:setVisible(v.finish == 0)
		gotoBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				-- GlobalApi:getGotoByModule(conf[v.id].key)
				-- self:hideMySelf(true)
				CountryWarMgr:hideCountryWarTask()
				CountryWarMgr:showCountryWarMap(nil,function()
					if conf1.countryType ~= 0 then
						CountryWarMgr:setWinPosition(nil,nil,conf1.condition1)
					else
						CountryWarMgr:setWinPosition()
					end
				end)
		    end
		end)
	end

	local size = self.sv:getContentSize()
    if #data * (size1.height + self.intervalSize) > size.height then
        self.sv:setInnerContainerSize(cc.size(size.width,(#data * (size1.height + self.intervalSize))))
    else
        self.sv:setInnerContainerSize(size)
    end
    local function getPos(i)
    	local size2 = self.sv:getInnerContainerSize()
		return cc.p(0,size2.height - (size1.height + self.intervalSize) * i)
	end
	for i=1,self.maxCellNum do
		local cell = self.sv:getChildByName('cell_'..i)
		if i <= #data then
			cell:setPosition(getPos(i))
			cell:setVisible(true)
		else
			cell:setVisible(false)
		end
	end
	UserData:getUserObj():setSignByType('campTaskAwards',canGet)
end

function CountryWarTaskUI:updatePanel()
    if self.page == 1 then
    	self:updateCountryTask()
    else
    	self:updatePersonalTask()
    end
	local signs = {
		UserData:getUserObj():getSignByType('countrywarcamptask'),
		UserData:getUserObj():getSignByType('countrywarpersonaltask'),
	}
    for i=1,2 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        local newImg = self.pageBtns[i]:getChildByName('new_img')
        newImg:setVisible(signs[i])
        if i == self.page then
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
end

function CountryWarTaskUI:init()
	local bgImg = self.root:getChildByName("task_bg_img")
	local taskImg = bgImg:getChildByName("task_img")
    self:adaptUI(bgImg, taskImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    taskImg:setPosition(cc.p(winSize.width/2 + 7,winSize.height/2 - 40))

    -- local titleTx = taskImg:getChildByName('title_tx')
    -- titleTx:setString(GlobalApi:getLocalStr('TASK'))
    self.neiBgImg = taskImg:getChildByName('nei_bg_img')
    self.sv = self.neiBgImg:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    local closeBtn = taskImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			CountryWarMgr:hideCountryWarTask()
	    end
	end)

    self.pageBtns = {}
    local STR = {
	    GlobalApi:getLocalStr('COUNTRY_WAR_TITLE_DESC_1'),
		GlobalApi:getLocalStr('COUNTRY_WAR_TITLE_DESC_2'),
	}
    for i=1,2 do
    	local pageBtn = taskImg:getChildByName('page_'..i..'_img')
    	local infoTx = pageBtn:getChildByName('info_tx')
    	infoTx:setString(STR[i])
    	pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				if i == 1 and not self.data.tasks then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_63'), COLOR_TYPE.RED)
					return
				elseif i == 2 and (not self.data.selfInfo or not self.data.selfInfo.taskInfo) then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_64'), COLOR_TYPE.RED)
					return
				end
				self.page = i
				self:updatePanel()
		    end
		end)
		self.pageBtns[i] = pageBtn
    end

	self:updatePanel()
end

return CountryWarTaskUI