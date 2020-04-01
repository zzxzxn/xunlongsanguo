local ExclusiveExchange = class("ExclusiveExchange", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ExclusiveExchange:ctor(showTab,exclusiveObj,roleObj)
	self.uiIndex = GAME_UI.UI_CHOOSE_EXCLUSIVE2_PANEL
	self.showTab = showTab
	self.equipExclusiveObj = exclusiveObj
	self.selectIndex = 1
	self.roleObj = roleObj
end

function ExclusiveExchange:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self:adaptUI(bgImg, bgImg1)
	local bgImg2 = bgImg1:getChildByName('bg_img2')
	self.bgImg2 = bgImg2
	local titleBg = bgImg2:getChildByName('title_bg')
	local titleTx = titleBg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_7'))
	local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:hideExclusiveExchangeUI()
		end
	end)

	local leftBg = self.bgImg2:getChildByName('left_bg')
	local centerBg = self.bgImg2:getChildByName('center_bg')
	local rightBg = self.bgImg2:getChildByName('right_bg')
	self.centerSv = centerBg:getChildByName('sv')
	self.rightSv = rightBg:getChildByName('sv')
	self.centerSv:setScrollBarEnabled(false)
	self.rightSv:setScrollBarEnabled(false)

	self:updateLeft()
	local num = #self.showTab
	if self.equipExclusiveObj then
		self:updateCenter()
		if num == 0 then
			rightBg:setVisible(false)
			self.bgImg2:setContentSize(cc.size(616,522))
			leftBg:setPositionX(158)
			centerBg:setPositionX(458.80)
			titleBg:setPositionX(308)
			closeBtn:setPositionX(782)
		else
			self:updateRight()
		end
	else
		centerBg:setVisible(false)
		self.bgImg2:setContentSize(cc.size(616,522))
		leftBg:setPositionX(158)
		rightBg:setPositionX(458.80)
		titleBg:setPositionX(308)
		closeBtn:setPositionX(782)
		self:updateRight()
	end
	self:registerBtnHandler()
end

function ExclusiveExchange:updateLeft()
	local leftBg = self.bgImg2:getChildByName('left_bg')
	local noTreasureTx = leftBg:getChildByName('no_treasure_tx')
    noTreasureTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_99'))
	local sv = leftBg:getChildByName('sv')
	if #self.showTab == 0 then
		noTreasureTx:setVisible(true)
		sv:setVisible(false)
	else
		noTreasureTx:setVisible(false)
		sv:setVisible(true)
		sv:setScrollBarEnabled(false)
		self.sv = sv
		self.cells = {}
		self:updateSv()
		self:updateSelectCells()
	end
end

function ExclusiveExchange:updateSv()
	local num = #self.showTab

	local CELLWIDHT = 94*0.86
	local CELLHEIGHT = 94*0.86

	local size = self.sv:getContentSize()
	local innerContainer = self.sv:getInnerContainer()
	local allHeight = size.height
	local cellWidthSpace = (size.width - 3*CELLWIDHT)/2
	local cellHeightSpace = 10

    
    local height = math.ceil(num/3) * CELLHEIGHT + (math.ceil(num/3) - 1)*cellHeightSpace + 16

	if height > size.height then
		innerContainer:setContentSize(cc.size(size.width,height))
		allHeight = height
	end

    local offset = 8
    for i = 1,num do
        local v = self.showTab[i]
		local awardBgImg = ClassItemCell:updateExclusive(self.sv,v,'award_bg_img_'..i,true)

		local selectImg = ccui.ImageView:create('uires/ui/common/guang1.png')
		selectImg:setName('select_img')
		selectImg:setLocalZOrder(-1)
		selectImg:setPosition(cc.p(awardBgImg:getContentSize().width/2,awardBgImg:getContentSize().height/2))
		awardBgImg:addChild(selectImg)

		awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if self.selectIndex == i then
					return
				end
				self.selectIndex = i
				self:updateSelectCells()
				self:updateRight()
			end
		end)
		
		awardBgImg:setScale(0.86)
		awardBgImg:setAnchorPoint(cc.p(0,0))
		local posX = 0
		local posY = 0
		if i%3 == 0 then
			posX = size.width - CELLWIDHT - 14
		elseif i%3 == 1 then
			posX = 14
		else
			posX = CELLWIDHT + cellWidthSpace
		end
		local curCellHeight = 0
		if i%3 == 1 then
			curCellHeight = CELLHEIGHT
		end
		local curSpace = 0
		if i == 1 or i == 2 or i == 3 then
			curSpace = 0
		elseif i%3 == 1 then
			curSpace = cellHeightSpace
		end
		offset = offset + curCellHeight + curSpace
		local posY = allHeight - offset
		awardBgImg:setPosition(cc.p(posX,posY))
		table.insert(self.cells,awardBgImg)
	end
	innerContainer:setPositionY(size.height - allHeight)
end

function ExclusiveExchange:updateSelectCells()
	for i = 1,#self.cells do
		local selectImg = self.cells[i]:getChildByName('select_img')
		if i == self.selectIndex then
			selectImg:setVisible(true)
		else
			selectImg:setVisible(false)
		end
	end
end

function ExclusiveExchange:registerBtnHandler()
	local centerBg = self.bgImg2:getChildByName('center_bg')
	local takeOffBtn = centerBg:getChildByName('take_off_btn')
	takeOffBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_15'))
	takeOffBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            local obj = self.showTab[self.selectIndex]
			local function callBack()
                local roleobj = RoleData:getRoleByPos(self.roleObj:getPosId())
                roleobj:setFightForceDirty(true)
                RoleData:getPosFightForceByPos(roleobj)
                RoleMgr:popupTips(roleobj)
				ExclusiveMgr:setDirty(true)
				ExclusiveMgr:hideExclusiveExchangeUI()
			end
			ExclusiveMgr:takeOffExclusive(self.roleObj,self.equipExclusiveObj:getId(),callBack)
		end
	end)
	local rightBg = self.bgImg2:getChildByName('right_bg')
	local putOnBtn = rightBg:getChildByName('put_on_btn')
	putOnBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_16'))
	putOnBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local obj = self.showTab[self.selectIndex]
			local function callBack()
                local roleobj = RoleData:getRoleByPos(self.roleObj:getPosId())
                roleobj:setFightForceDirty(true)
                RoleData:getPosFightForceByPos(roleobj)
                RoleMgr:popupTips(roleobj)
				ExclusiveMgr:setDirty(true)
				ExclusiveMgr:hideExclusiveExchangeUI()
			end
			ExclusiveMgr:putOnExclusive(self.roleObj,obj:getId(),callBack)
		end
	end)
end

function ExclusiveExchange:updateCenter()
	ClassItemCell:createExclusiveInfo(self.centerSv,10,self.equipExclusiveObj,nil,3)
end

function ExclusiveExchange:updateRight()
	local showType = 1
	if self.equipExclusiveObj then
		showType = 2
	end
	local obj = self.showTab[self.selectIndex]
	ClassItemCell:createExclusiveInfo(self.rightSv,10,obj,nil,showType)
end

return ExclusiveExchange