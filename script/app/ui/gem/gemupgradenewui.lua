local GemUpgradeNewUI = class("GemUpgradeNewUI", BaseUI)
local ClassGemObj = require('script/app/obj/gemobj')
local ClassItemCell = require('script/app/global/itemcell')

function GemUpgradeNewUI:ctor(gid,slotIndex, equipObj, callback)
    self.uiIndex = GAME_UI.UI_GEMUPGRADE_NEW
	self.equipObj = equipObj or nil
    self.callback = callback or nil
    self.slotIndex = slotIndex or 0
    if gid > 0 then
        self.gid = gid
    else
        local equipGems = self.equipObj:getGems()
        local gem = equipGems[self.slotIndex]
        self.gid = gem:getId()
    end
	self.isOneMergeState = false
	self.cells = {}
end

function GemUpgradeNewUI:init()
    local gemSelectBgImg = self.root:getChildByName("bg_img")
    local gemSelectImg = gemSelectBgImg:getChildByName("bg_alpha")
    self:adaptUI(gemSelectBgImg, gemSelectImg)
	self.bgImg1 = gemSelectImg:getChildByName("bg_img1")

	self:initLeft()
	self:initRight()
	self:initPos()
end

function GemUpgradeNewUI:initPos()
	local bgLeft = self.bgImg1:getChildByName('bg_left')
	local bgRight = self.bgImg1:getChildByName('bg_right')
	bgLeft:setVisible(false)
	bgRight:setPositionX(464)
	bgLeft:setPositionX(675)
end

function GemUpgradeNewUI:scrllLogic()
	self.actionState = true
	local bgLeft = self.bgImg1:getChildByName('bg_left')
	local bgRight = self.bgImg1:getChildByName('bg_right')
	bgLeft:setVisible(false)
	local posY = bgRight:getPositionY()
    local action1 = cc.DelayTime:create(0.01)
	local action2 = cc.MoveTo:create(0.3, cc.p(675,posY))
    local action3 = cc.CallFunc:create(function ()
		bgLeft:setVisible(true)
		local act1 = cc.DelayTime:create(0.01)
		local act2 = cc.MoveTo:create(0.3, cc.p(214,posY))
		local act3 =  cc.CallFunc:create(function ()
			self.actionState = false
		end)
		bgLeft:runAction(cc.Sequence:create(act1,act2,act3))
    end)
    bgRight:runAction(cc.Sequence:create(action1,action2,action3))
end

function GemUpgradeNewUI:initLeft()
	local bgLeft = self.bgImg1:getChildByName('bg_left')
	local titleBg  = bgLeft:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES2'))
	
	local des1 = bgLeft:getChildByName('des1')
	des1:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES3'))
	local des2 = bgLeft:getChildByName('des2')
	des2:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES4'))

	local checkBox = bgLeft:getChildByName('checkbox')
	local selectImg = checkBox:getChildByName('select_img')
	checkBox:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self.isOneMergeState = not self.isOneMergeState
			selectImg:setVisible(self.isOneMergeState)
			self:updateCellsState()
		end
	end)
	selectImg:setVisible(self.isOneMergeState)

	local sv = bgLeft:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local cell = bgLeft:getChildByName('item')
    cell:setVisible(false)
    self.sv = sv
    self.cell = cell
    self:updateSV()
	self:updateCellsState()
end

function GemUpgradeNewUI:updateSV()
	self.sv:removeAllChildren()
	self.cells = {}

	local allGmes = self:getAllGems()
	local num = #allGmes
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5
    local height = num * self.cell:getContentSize().height + (num - 1)*cellSpace
    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end
    local offset = 0
    local tempHeight = self.cell:getContentSize().height
    for i = 1,num do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(2,allHeight - offset))
		tempCell.gemObj = BagData:getGemObjById(allGmes[i])
        self.sv:addChild(tempCell)
		self:updateItem(tempCell)
		table.insert(self.cells,tempCell)
	end
    innerContainer:setPositionY(size.height - allHeight)
end

function GemUpgradeNewUI:updateItem(widget)
	local icon = widget:getChildByName('icon')
	local nameTx = widget:getChildByName('name_tx')
	local costDescTx = widget:getChildByName('cost_desc_tx')
	local costTx = widget:getChildByName('cost_tx')
	local makeBtn = widget:getChildByName('make_btn')
	local makeBtnTx = makeBtn:getChildByName('tx')
	local goldBg = widget:getChildByName('gold_bg')
	local goldTx = goldBg:getChildByName('gold_tx')

	widget.costTx = costTx
	widget.makeBtnTx = makeBtnTx
	widget.goldTx = goldTx
	widget.makeBtn = makeBtn

	if icon:getChildByName('award_bg_img') then
		icon:removeChildByName('award_bg_img')
	end
	local gemObj = BagData:getGemObjById(widget.gemObj:getId())
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,gemObj,icon)
	cell.awardBgImg:setPosition(cc.p(94/2,94/2))
	cell.awardBgImg:loadTexture(gemObj:getBgImg())
	cell.chipImg:setVisible(false)
	cell.lvTx:setVisible(false)
	cell.awardImg:loadTexture(gemObj:getIcon())
	gemObj:setLightEffect(cell.awardBgImg)

	nameTx:setString(gemObj:getName())
    nameTx:setColor(gemObj:getNameColor())
    nameTx:enableOutline(gemObj:getNameOutlineColor(),1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

	costDescTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES10'))
end

function GemUpgradeNewUI:updateCellsState()
	for i = 1,#self.cells do
		local costTx = self.cells[i].costTx
		local makeBtnTx = self.cells[i].makeBtnTx
		local goldTx = self.cells[i].goldTx
		local gemObj = BagData:getGemObjById(self.cells[i].gemObj:getId())
		local makeBtn = self.cells[i].makeBtn

		local ownNum = gemObj:getNum()
		local costOneNum = gemObj:getCostNum()

		local costAward = DisplayData:getDisplayObj(gemObj:getCosts())
		local costOneGold = costAward:getNum()
		local maxCount = 1
		if self.isOneMergeState == true then
			maxCount = math.floor(ownNum/costOneNum)
		end
		if maxCount == 0 then
			maxCount = 1
		end
		local costNum = costOneNum*maxCount
		local costGold = costOneGold*maxCount

		goldTx:setString(costGold)
		costTx:setString(ownNum .. '/' .. costNum)
		if ownNum >= costNum then
			costTx:setColor(COLOR_TYPE.GREEN)
		else
			costTx:setColor(COLOR_TYPE.RED)
		end

		if UserData:getUserObj():getGold() < costGold then
			goldTx:setColor(COLOR_TYPE.RED)
		else
			goldTx:setColor(COLOR_TYPE.WHITE)
		end

		if self.isOneMergeState == true then
			makeBtnTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES4'))
		else	
			makeBtnTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES11'))
		end

		makeBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
			if eventType == ccui.TouchEventType.ended then
				if gemObj:getLevel() >= 12 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES15'), COLOR_TYPE.RED)
					return
				end

				if ownNum < costNum then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES12'), COLOR_TYPE.RED)
					return
				end

				if UserData:getUserObj():getGold() < costGold then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES13'), COLOR_TYPE.RED)
					return
				end

				local eid = 0
				self:lvUpPost(gemObj:getId(),eid,maxCount)
			end
		end)

	end
end

function GemUpgradeNewUI:initRight()
	local bgRight = self.bgImg1:getChildByName('bg_right')
    local closeBtn = bgRight:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            self:hideUI()
		end
    end)

	local eid = 0
	if self.equipObj then
		eid = self.equipObj:getSId()
	end

    local titleBg  = bgRight:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES1'))

	local bg = bgRight:getChildByName('bg')
	local bgTop = bgRight:getChildByName('bg_top')
	local curGemObj = BagData:getGemObjById(self.gid)
	if curGemObj:getLevel() >= 12 then
		bgTop:setVisible(true)
		bg:setVisible(false)

		local scrollBgImg = bgTop:getChildByName('scroll_bg_img')
		local gemBg = scrollBgImg:getChildByName('gem_bg')
		local nameTx = scrollBgImg:getChildByName('name_tx')
		local descTx = scrollBgImg:getChildByName('desc_tx')

		local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,curGemObj,gemBg)
		cell.awardBgImg:setPosition(cc.p(94/2,94/2))
		cell.awardBgImg:loadTexture(curGemObj:getBgImg())
		cell.chipImg:setVisible(false)
		cell.lvTx:setVisible(false)
		cell.awardImg:loadTexture(curGemObj:getIcon())
		curGemObj:setLightEffect(cell.awardBgImg)

		nameTx:setString(curGemObj:getName())
		nameTx:setColor(curGemObj:getNameColor())
		nameTx:enableOutline(curGemObj:getNameOutlineColor(),1)
		nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

		descTx:setString(curGemObj:getAttrName() .. '+' .. curGemObj:getValue())
		return
	end
	bgTop:setVisible(false)
	bg:setVisible(true)
	local upgradeGemObj = ClassGemObj.new(curGemObj:getGetGemId(), 1)
	for i = 1,2 do
		local frame = bg:getChildByName('frame' .. i)
		local icon = frame:getChildByName('icon')
		local img = frame:getChildByName('img')
		local des = img:getChildByName('des')
		local nameTx = frame:getChildByName('name_tx')
		local attTx = frame:getChildByName('att_tx')

		local gemObj = curGemObj
		local titleDes = GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES5')
		if i == 2 then
			gemObj = upgradeGemObj
			titleDes = GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES6')
		end
		des:setString(titleDes)
		if icon:getChildByName('award_bg_img') then
			icon:removeChildByName('award_bg_img')
		end
		local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,gemObj,icon)
		cell.awardBgImg:setPosition(cc.p(94/2,94/2))
		cell.awardBgImg:loadTexture(gemObj:getBgImg())
		cell.chipImg:setVisible(false)
		cell.awardImg:loadTexture(gemObj:getIcon())
		gemObj:setLightEffect(cell.awardBgImg)

		nameTx:setString(gemObj:getName())
        nameTx:setColor(gemObj:getNameColor())
        nameTx:enableOutline(gemObj:getNameOutlineColor(),1)
        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		attTx:setString(gemObj:getAttrName() .. '+' .. gemObj:getValue())
		if i == 1 then
			local num = gemObj:getNum()
			if eid > 0 then
				num = num + 1
			end
			cell.lvTx:setString('x'..num)

			if num < gemObj:getCostNum() then
				cell.lvTx:setColor(COLOR_TYPE.RED)
			else
				cell.lvTx:setColor(COLOR_TYPE.WHITE)
			end
		end
	end

	local arrow = bg:getChildByName('arrow')
	local descTx = arrow:getChildByName('tx')
	descTx:setString(string.format(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES8'),curGemObj:getCostNum(),1))

	local ownNum = curGemObj:getNum()
	if eid > 0 then
		ownNum = ownNum + 1
	end
	local costAward = DisplayData:getDisplayObj(curGemObj:getCosts())
	local costGold = costAward:getNum()
	local costNum = curGemObj:getCostNum()

	local autoBtn = bg:getChildByName('auto_btn')
	local autoBtnTx = autoBtn:getChildByName('tx')
	autoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            if ownNum < costNum then
				if self.actionState == true then
					return
				end
				local bgLeft = self.bgImg1:getChildByName('bg_left')
				if bgLeft:isVisible() == false and curGemObj:getLevel() > 1 then
					self:scrllLogic()
				else
					promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES12'), COLOR_TYPE.RED)
				end
				return
			end

			if UserData:getUserObj():getGold() < costGold then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES13'), COLOR_TYPE.RED)
				return
			end

			local eid = 0
			if self.equipObj then
				eid = self.equipObj:getSId()
			end
			self:lvUpPost(self.gid,eid,1,true)
		end
    end)

	local desNumTx = bg:getChildByName('desnum_tx')
	desNumTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES14'))
	local goldBg = bg:getChildByName('gold_bg')
	local goldTx = goldBg:getChildByName('gold_tx') 
	goldTx:setString(costGold)
	autoBtnTx:setContentSize(cc.size(300,50))
	if ownNum < costNum then
		desNumTx:setVisible(true)
		goldBg:setVisible(false)
		autoBtnTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES16'))
	else
		desNumTx:setVisible(false)
		goldBg:setVisible(true)
		if UserData:getUserObj():getGold() < costGold then
			goldTx:setColor(COLOR_TYPE.RED)
		else
			goldTx:setColor(COLOR_TYPE.WHITE)
		end
		autoBtnTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES9'))
	end

	local centerImg = bg:getChildByName('center_img')
	local txtImg = centerImg:getChildByName('txt_img')
	local txtImgTx = txtImg:getChildByName('tx')
	txtImgTx:setString(GlobalApi:getLocalStr('GEMUPGRADE_NEW_DES7'))
end

function GemUpgradeNewUI:getAllGems()
	local gemConfData = GameData:getConfData('gem')
	local gems = {}
	local curLevel = gemConfData[self.gid].level
	local curType = gemConfData[self.gid].type
	for k,v in pairs(gemConfData) do
		if v.level < curLevel and v.type == curType then
			table.insert(gems,tonumber(k))
		end
	end

	table.sort(gems,function(a, b)
		local obj1 = gemConfData[a]
		local obj2 = gemConfData[b]

		if obj1.level ~= obj2.level then
			return obj1.level > obj2.level
		else
			return obj1.id < obj2.id
		end
	end)

	return gems
end

function GemUpgradeNewUI:lvUpPost(gid,eid,num,isRight)
    local args = {
        gid = gid,
        num = num,
        eid = eid
    }
    MessageMgr:sendPost("upgrade_gem", "equip", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            local awards = jsonObj.data.awards
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end

			if isRight == true then
				self.gid = jsonObj.data.update_id
			end
			if eid > 0 then
				local gemObj = ClassGemObj.new(self.gid, 1)
				if self.equipObj then
					self.equipObj:upgradeGem(self.slotIndex,gemObj)
				end
				local str = string.format(GlobalApi:getLocalStr('LVUP_SUCC'),gemObj:getName()..'X'..'1')
                promptmgr:showSystenHint(str,COLOR_TYPE.GREEN)
			else
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end
			if isRight == true then
				self:updateSV()
			end
			self:updateCellsState()
			self:initRight()
			if self.callback then
				self.callback()
			end
        end
    end)
end

return GemUpgradeNewUI