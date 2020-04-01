local ResGetBackUI = class("ResGetBackUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ResGetBackUI:ctor(data)
	self.uiIndex = GAME_UI.UI_RES_GET_BACK
	self.maxTopNum = 0
	self.maxBottomNum = 0
	self.oldData = clone(data)
	self:getData(data,true)
end

function ResGetBackUI:getData(data,isClearn)
	self.data = {}
	self.topData = {}
	self.hadGetBack = false
	local conf = GameData:getConfData("resback")
	local index = 0
	for k,v in pairs(data) do
		index = index + 1
		local tab = {}
		local num = 0
		local maxNum = 0
		for k1,v1 in pairs(v) do
			maxNum = maxNum + 1
			if not v1.isget then
				self.hadGetBack = true
				v1.isget = 0
			elseif v1.isget == 1 then
				num = num  + 1
			elseif v1.isget == 0 then
				self.hadGetBack = true
			end
			tab[#tab + 1] = {date = k1,data = v1}
		end
		table.sort( tab,function(a,b)
			if a.data.isget == b.data.isget then
				return tonumber(a.date) < tonumber(b.date)
			end
			return a.data.isget < b.data.isget
		end )
		self.data[k] = tab
		self.data[k].num = num
		self.data[k].maxNum = maxNum
		self.data[k].index = index
		if self.data[k].maxNum <= 0 or (self.data[k].num >= self.data[k].maxNum and isClearn) then
			self.data[k] = nil
		else
			self.topData[#self.topData + 1] = conf[k]
			self.topData[#self.topData].data = self.data[k]
		end
	end
	if not self.hadGetBack then
		UserData:getUserObj():setResBackSign(0)
	else
		table.sort(self.topData,function (a,b)
			if a.data.num == b.data.num then
				return a.data.index < b.data.index
			end
			return a.data.num < b.data.num
		end )
	end
end

function ResGetBackUI:updateTopPanel()
	local maxNum = 0
	local size1
	local diffSize = 5
	local selecetImg = self.topSv:getChildByName('select_img')
	selecetImg:setLocalZOrder(3)
	for i,v in pairs(self.topData) do
		if self.data[v.type] then
			maxNum = maxNum + 1
			local currIndex = maxNum
			local bgImg = self.topSv:getChildByName('bg_img_'..currIndex)
			if not bgImg then
				local node = cc.CSLoader:createNode('csb/resgetbackcell1.csb')
				bgImg = node:getChildByName('bg_img')
				bgImg:removeFromParent(false)
				bgImg:setName('bg_img_'..currIndex)
				self.topSv:addChild(bgImg)
			end
			bgImg:setVisible(true)
			size1 = bgImg:getContentSize()
			bgImg:setPosition(cc.p((maxNum - 1)*(size1.width + diffSize),2))
			local nameBgImg = bgImg:getChildByName('name_bg_img')
			local nameTx = nameBgImg:getChildByName('name_tx')
			local resImg = bgImg:getChildByName('res_img')
			local hideImg = bgImg:getChildByName('hide_img')
			local txImg = hideImg:getChildByName('tx_img')
			local descTx = txImg:getChildByName('desc_tx')
			descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_7'))
			hideImg:setVisible(v.data.num >= v.data.maxNum)
			hideImg:setLocalZOrder(10)
			resImg:loadTexture(v.url)
			nameTx:setString(v.desc)
			if not self.selectIndex or v.type == self.selectIndex then
				self.selectIndex = v.type
				selecetImg:setPosition(cc.p(cc.p((currIndex - 1)*(size1.width + diffSize) + size1.width/2,2 + size1.height/2)))
			end
			bgImg:setTouchEnabled(true)
			bgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					if v.type ~= self.selectIndex then
						self.selectIndex = v.type
						selecetImg:setPosition(cc.p(cc.p((currIndex - 1)*(size1.width + diffSize) + size1.width/2,2 + size1.height/2)))
						self:updateBottomPanel()
					end
				end
			end)
		end
	end

    local size = self.topSv:getContentSize()
    if maxNum > 3 then
        self.topSv:setInnerContainerSize(cc.size(maxNum*(size1.width + diffSize) - diffSize,size.height))
    else
        self.topSv:setInnerContainerSize(size)
    end
	for i=1,self.maxTopNum do
		local bgImg = self.topSv:getChildByName('bg_img_'..i)
		if i > maxNum then
			bgImg:setVisible(false)
		else
			bgImg:setVisible(true)
		end
	end
	self.maxTopNum = maxNum
end

function ResGetBackUI:updateBottomPanel()
	local size1
	local diffSize = 5
	local data = self.data[self.selectIndex]
	local conf = GameData:getConfData("resback")[self.selectIndex]
	for i,v in ipairs(data) do 
		local bgImg = self.bottomSv:getChildByName('bg_img_'..i)
		if not bgImg then
			local node = cc.CSLoader:createNode('csb/resgetbackcell2.csb')
			bgImg = node:getChildByName('bg_img')
			bgImg:removeFromParent(false)
			bgImg:setName('bg_img_'..i)
			self.bottomSv:addChild(bgImg)
		end
		bgImg:setVisible(true)
		size1 = bgImg:getContentSize()
		bgImg:setPosition(cc.p((i - 1)*(size1.width + diffSize),2))
		local nameTx = bgImg:getChildByName('name_tx')
		local hideImg = bgImg:getChildByName('hide_img')
		local txImg = hideImg:getChildByName('tx_img')
		local descTx = txImg:getChildByName('desc_tx')
		descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_7'))
		hideImg:setLocalZOrder(10)
        local m = tonumber(string.sub(v.date , 5, 6))
        local d = tonumber(string.sub(v.date , 7, 8))
		nameTx:setString(string.format(GlobalApi:getLocalStr('RES_GET_BACK_DATE'),m,d))
		local getBackBtn = bgImg:getChildByName('get_back_btn')
		getBackBtn:setVisible(v.data.isget == 0)
		local infoTx = getBackBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_2'))
		hideImg:setVisible(v.data.isget ~= 0)
		local isCash = true
		if conf.backType == 0 then
			isCash = false
		end
	    getBackBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				MainSceneMgr:showResGetBackCellUI(self.selectIndex,v,function()
					self.oldData[self.selectIndex][v.date].isget = 1
					self:getData(self.oldData)
					self:updatePanel()
				end,nil,isCash)
	        end
	    end)

		local awards = DisplayData:getDisplayObjs(v.data.awards)
		local size = bgImg:getContentSize()
		local pos = {cc.p(size.width/2 - 45,115),cc.p(size.width/2 + 45,115),cc.p(size.width/2,115)}
		for i=1,2 do
			local awardBgImg = bgImg:getChildByName('award_bg_img_'..i)
			if awards[i] then
				if not awardBgImg then
					local tab = ClassItemCell:create()
					awardBgImg = tab.awardBgImg
					awardBgImg:setName('award_bg_img_'..i)
					bgImg:addChild(awardBgImg)
				end
				if #awards > 1 then
					awardBgImg:setPosition(pos[i])
				else
					awardBgImg:setPosition(pos[3])
				end
				awardBgImg:setVisible(true)
				awardBgImg:setScale(0.8)
				ClassItemCell:updateItem(awardBgImg, awards[i], 0)
		    	awardBgImg:addTouchEventListener(function (sender, eventType)
			        if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[i],false)
			        end
			    end)
			else
				if awardBgImg then
					awardBgImg:setVisible(false)
				end
			end
		end
	end

    local size = self.bottomSv:getContentSize()
    if #data > 3 then
        self.bottomSv:setInnerContainerSize(cc.size(#data*(size1.width + diffSize) - diffSize,size.height))
    else
        self.bottomSv:setInnerContainerSize(size)
    end
	for i=1,self.maxBottomNum do
		local bgImg = self.bottomSv:getChildByName('bg_img_'..i)
		if i > #data then
			bgImg:setVisible(false)
		else
			bgImg:setVisible(true)
		end
	end
	self.maxBottomNum = #data
end

function ResGetBackUI:updatePanel()
	self:updateTopPanel()
	self:updateBottomPanel()
end

function ResGetBackUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			if not self.hadGetBack then
				UserData:getUserObj():setResBackSign(0)
			end
			MainSceneMgr:hideResGetBackUI()
	    end
	end)

	local titleBg = bgImg1:getChildByName('title_bg')
	local titleTx = titleBg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_3'))
	local descTx = bgImg1:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_4'))
	local topImg = bgImg1:getChildByName('top_bg_img')
	local bottomImg = bgImg1:getChildByName('bottom_bg_img')
    self.topSv = topImg:getChildByName('cell_sv')
    self.topSv:setScrollBarEnabled(false)
	self.bottomSv = bottomImg:getChildByName('cell_sv')
    self.bottomSv:setScrollBarEnabled(false)
    local getBackBtn = bgImg1:getChildByName('get_back_btn')
	local infoTx = getBackBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_5'))
    getBackBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local data = self.data[self.selectIndex]
			local conf = GameData:getConfData("resback")[self.selectIndex]
			local newData = self:getRepeatAwards(data)
			if newData.data.remainnum <= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('RES_GET_BACK_DESC_1'), COLOR_TYPE.RED)
				return
			end
			local isCash = true
			if conf.backType == 0 then
				isCash = false
			end
			MainSceneMgr:showResGetBackCellUI(self.selectIndex,newData,function()
				for k,v in pairs(self.oldData[self.selectIndex]) do
					self.oldData[self.selectIndex][k].isget = 1
				end
				self:getData(self.oldData)
				self.selectIndex = nil
				self:updatePanel()
			end,true,isCash)
	    end
	end)

    local getBackAllBtn = bgImg1:getChildByName('get_back_all_btn')
	local infoTx = getBackAllBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_9'))
    getBackAllBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local remainnum = 0
        	for k,v in pairs(self.data) do
				local conf = GameData:getConfData("resback")[self.selectIndex]
				local newData = self:getRepeatAwards(v)
				remainnum = remainnum + newData.data.remainnum
        	end
			if remainnum <= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('RES_GET_BACK_DESC_1'), COLOR_TYPE.RED)
				return
			end
			MainSceneMgr:showResGetBackAllUI(self.oldData,function()
				for k,v in pairs(self.oldData) do
					for k1,v1 in pairs(v) do
						self.oldData[k][k1].isget = 1
					end
				end
				self:getData(self.oldData)
				self.selectIndex = nil
				self:updatePanel()
			end)
	    end
	end)

	self:updatePanel()
end

function ResGetBackUI:getRepeatAwards(data)
    local itemTab = {}
    local gemTab = {}
    local materialTab = {}
    local dressTab = {}
    local otherTab = {}
    local itemTab1 = {}
    local gemTab1 = {}
    local materialTab1 = {}
    local dressTab1 = {}
    local otherTab1 = {}
    local remainnum = 0
    local conf = GameData:getConfData("resback")[self.selectIndex]
    local ratio = 1
	for i,v in ipairs(data) do
		if v.data.isget == 0 then
			for j=1,2 do
				if v.data.awards[j] then
			        if v.data.awards[j][1] == 'user' then
			            itemTab[v.data.awards[j][2]] = (itemTab[v.data.awards[j][2]] or 0) + v.data.awards[j][3]
			            itemTab1[v.data.awards[j][2]] = (itemTab1[v.data.awards[j][2]] or 0) + math.floor(v.data.awards[j][3]*conf.freeRadio)
			        elseif v.data.awards[j][1] == 'gem' then
			            gemTab[v.data.awards[j][2]] = (gemTab[v.data.awards[j][2]] or 0) + v.data.awards[j][3]
			            gemTab1[v.data.awards[j][2]] = (gemTab1[v.data.awards[j][2]] or 0) + math.floor(v.data.awards[j][3]*conf.freeRadio)
			        elseif v.data.awards[j][1] == 'material' then
			            materialTab[v.data.awards[j][2]] = (materialTab[v.data.awards[j][2]] or 0) + v.data.awards[j][3]
			            materialTab1[v.data.awards[j][2]] = (materialTab1[v.data.awards[j][2]] or 0) + math.floor(v.data.awards[j][3]*conf.freeRadio)
			        elseif v.data.awards[j][1] == 'dress' then
			            dressTab[v.data.awards[j][2]] = (dressTab[v.data.awards[j][2]] or 0) + v.data.awards[j][3]
			            dressTab1[v.data.awards[j][2]] = (dressTab1[v.data.awards[j][2]] or 0) + math.floor(v.data.awards[j][3]*conf.freeRadio)
			        else
			            otherTab[#otherTab + 1] = v.data.awards[j]
			            v.data.awards[j][3] = math.floor(v.data.awards[j][3]*conf.freeRadio)
			            otherTab1[#otherTab1 + 1] = v.data.awards[j]
			        end
				end
			end
			remainnum = remainnum + v.data.remainnum
		end
	end
    for i,v in pairs(itemTab) do
        otherTab[#otherTab + 1] = {'user',i,tonumber(v)}
    end
    for i,v in pairs(gemTab) do
        otherTab[#otherTab + 1] = {'gem',i,tonumber(v)}
    end
    for i,v in pairs(materialTab) do
        otherTab[#otherTab + 1] = {'material',i,tonumber(v)}
    end
    for i,v in pairs(dressTab) do
        otherTab[#otherTab + 1] = {'dress',i,tonumber(v)}
    end
    for i,v in pairs(itemTab1) do
        otherTab1[#otherTab1 + 1] = {'user',i,tonumber(v)}
    end
    for i,v in pairs(gemTab1) do
        otherTab1[#otherTab1 + 1] = {'gem',i,tonumber(v)}
    end
    for i,v in pairs(materialTab1) do
        otherTab1[#otherTab1 + 1] = {'material',i,tonumber(v)}
    end
    for i,v in pairs(dressTab1) do
        otherTab1[#otherTab1 + 1] = {'dress',i,tonumber(v)}
    end
    local tab = {date = data.date,data = {awards = otherTab,awards1 = otherTab1,remainnum = remainnum}}
    return tab
end

return ResGetBackUI