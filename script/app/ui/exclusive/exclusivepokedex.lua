local ExclusivePokedexUI = class("ExclusivePokedexUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')
local MAX_PAGE = 5
function ExclusivePokedexUI:ctor(page)
    self.uiIndex = GAME_UI.UI_EXCLUSIVE_POKEDEX
    self.page = page or 1
    self.showType = true
    self.currMax = 0
    self.maxItem = 0
end

function ExclusivePokedexUI:onShow()
	if self.currMax ~= self.maxItem then
		self.obj = nil
	end
	self:updatePnael()
end

function ExclusivePokedexUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg1:setPosition(cc.p(winSize.width/2 + 20,winSize.height/2 - 30))

    local titleBg = bgImg1:getChildByName('title_bg_img')
    local titleTx = titleBg:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_9'))
    local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:hideExclusivePokedexUI()
		end
	end)

	self.pageBtns = {}
	local list = bgImg1:getChildByName('page_btn_list')
	list:setScrollBarEnabled(false)
	for i=1,MAX_PAGE do
		local btn = list:getChildByName('page_btn_'..i)
		local infoTx = btn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_TYPE_'..(i - 1)))
		self.pageBtns[i] = btn
		btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.obj = nil
				self.page = i
				self:updatePnael()
			end
		end)
	end

	local leftBgImg = bgImg1:getChildByName('left_bg_img')
	local rightBgImg = bgImg1:getChildByName('right_bg_img')
	self.leftSv = leftBgImg:getChildByName('card_sv')
	self.leftSv:setScrollBarEnabled(false)
	self.node = cc.Node:create()
	self.leftSv:addChild(self.node)
	self.node:setName('node')
	self.rightSv = rightBgImg:getChildByName('info_sv')
	self.rightSv:setScrollBarEnabled(false)
	local getBtn = rightBgImg:getChildByName('get_btn')
	local infoTx = getBtn:getChildByName('info_tx')
	local checkBtn = leftBgImg:getChildByName('check_btn')
	local checkImg = checkBtn:getChildByName('check_img')
	checkImg:setVisible(false)
	local descTx = leftBgImg:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_13'))
	infoTx:setString(GlobalApi:getLocalStr('STR_GETWAY'))
	getBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.obj then
				GetWayMgr:showGetwayUI(self.obj,true)
			end
		end
	end)
	checkBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.hadNum > 0 then
				self.obj = nil
				checkImg:setVisible(not checkImg:isVisible())
				self.showType = not self.showType
				self:updatePnael()
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_104'), COLOR_TYPE.RED)
			end
		end
	end)
	self.checkImg = checkImg

   	self.light = ccui.ImageView:create()
    self.light:setTouchEnabled(false)
    self.light:loadTexture('uires/ui/common/guang1.png')
    self.light:setAnchorPoint(0.5,0.5)
    self.node:addChild(self.light)
	self:updatePnael()
end

function ExclusivePokedexUI:updatePageBtn()
	for i=1,MAX_PAGE do
		local infoTx = self.pageBtns[i]:getChildByName('info_tx')
		if i == self.page then
			self.pageBtns[i]:loadTexture('uires/ui/common/title_btn_sel_2.png')
			self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
			self.pageBtns[i]:setTouchEnabled(false)
			infoTx:setColor(COLOR_TYPE.PALE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
			infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		else
			self.pageBtns[i]:loadTexture('uires/ui/common/title_btn_nor_2.png')
			self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
			self.pageBtns[i]:setTouchEnabled(true)
			infoTx:setColor(COLOR_TYPE.DARK)
			infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
			infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		end
	end
end

function ExclusivePokedexUI:updatePnael()
	self:updateLeftPnael()
	self:updateRightPnael()
	self:updatePageBtn()
end

function ExclusivePokedexUI:getData(ntype)
	local exclusiveTab = BagData:getAllExclusive()
	local conf = GameData:getConfData("exclusive")
	local showTab = {}
	if ntype == 0 then
		for k,v in pairs(conf) do
			table.insert(showTab, v)
		end
	else
		for k,v in pairs(conf) do
			local ntype1 = math.floor(v.id/100)
			if ntype1 == ntype then
				table.insert(showTab, v)
			end
		end
	end
	table.sort( showTab, function(a,b)
		return a.id < b.id
	end )
	return showTab
end

function ExclusivePokedexUI:updateLight()
	local awardBgImg = self.node:getChildByName('award_bg_img_'..self.index)
	self.light:setPosition(awardBgImg:getPosition())
end

function ExclusivePokedexUI:updateLeftPnael()
	local exclusiveTab = BagData:getAllExclusive()
	local conf = self:getData(self.page - 1)
	local size1
	local num = 0
	self.hadNum = 0
	for k,v in pairs(conf) do
		local obj
		local ntype = math.floor(v.id/100)
		if exclusiveTab[ntype][v.id] then
			obj = exclusiveTab[ntype][v.id]
		else
			if self.showType then
				obj = ClassExclusiveObj.new(tonumber(v.id), 0)
			end
		end
		if obj and obj:getNum() > 0 then
			self.hadNum = self.hadNum + 1
		end
	end
	
	if self.hadNum <= 0 then
		self.checkImg:setVisible(false)
		self.showType = true
	end

	for k,v in pairs(conf) do
		local obj
		local ntype = math.floor(v.id/100)
		if exclusiveTab[ntype][v.id] then
			obj = exclusiveTab[ntype][v.id]
		else
			if self.showType then
				obj = ClassExclusiveObj.new(tonumber(v.id), 0)
			end
		end
		if obj then
			num = num + 1
			local index = num
			local param = {
				bgName = 'award_bg_img_'..num,
				showLvTx = false,
			}
			local awardBgImg = ClassItemCell:updateAwardFrameByObj(self.node,obj,param)
			awardBgImg:setSwallowTouches(false)
			awardBgImg:setVisible(true)
			local awardImg = awardBgImg:getChildByName('award_img')
			if obj:getNum() > 0 then
				ShaderMgr:restoreWidgetDefaultShader(awardBgImg)
				ShaderMgr:restoreWidgetDefaultShader(awardImg)
			else
				ShaderMgr:setGrayForWidget(awardBgImg)
				ShaderMgr:setGrayForWidget(awardImg)
			end
			local r = math.ceil(num/MAX_PAGE)
			local c = (num - 1)%MAX_PAGE + 1
			size1 = awardBgImg:getContentSize()
			awardBgImg:setPosition(cc.p((c - 0.5)*(size1.width + 11) + 5.5,-(r - 0.5)*(size1.height + 11) - 5.5))
			if not self.obj then
				self.obj = obj
				self.index = index
			end
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					self.obj = obj
					self.index = index
					self:updateLight()
					self:updateRightPnael()
				end
			end)
		end
	end
	self.currMax = num
	if self.currMax ~= self.maxItem then
		if size1 then
			local maxC = math.ceil(self.currMax/MAX_PAGE)
			local size = self.leftSv:getContentSize()
			if size.height > maxC*(size1.height + 11) + 11 then
				self.node:setPosition(cc.p(0,size.height))
				self.leftSv:setInnerContainerSize(size)
			else
				self.node:setPosition(cc.p(0,maxC*(size1.height + 11) + 11))
				self.leftSv:setInnerContainerSize(cc.size(size.width,maxC*(size1.height + 11) + 11))
			end
		end
	end

	for i= self.currMax + 1,self.maxItem do
		local awardBgImg = self.node:getChildByName('award_bg_img_'..i)
		if awardBgImg then
			awardBgImg:setVisible(false)
		end
	end

	self:updateLight()
	self.maxItem = num
end

function ExclusivePokedexUI:updateRightPnael()
	ClassItemCell:createExclusiveInfo(self.rightSv,10,self.obj)
end

return ExclusivePokedexUI