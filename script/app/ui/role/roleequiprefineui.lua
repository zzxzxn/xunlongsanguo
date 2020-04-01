local EquipRefineUI = class("EquipRefineUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassItemCell = require('script/app/global/itemcell')

function EquipRefineUI:ctor(pos,equipPos)
	self.uiIndex = GAME_UI.UI_EQUIP_REFINE
	self.pos = pos
	self.equipPos = equipPos
	self.obj = RoleData:getRoleByPos(pos)
	self.baseXp = 0
	self.addExp = 0
	self.costNum = 0
	self.maxXp = 0
end

function EquipRefineUI:onShow()
	self:updatePanel()
end

function EquipRefineUI:runEnd(materialobj)
	if not self.isRun then
		return
	end
	self.isRun = false
	-- self.addExp = self.baseXp + self.addExp - self.maxXp
	local currBase = self.baseXp + self.addExp
	local partInfo = clone(self.obj:getPartInfoByPos(self.equipPos))
	-- local needlvup = true
	-- while needlvup do
	-- 	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	-- 	local conf = GameData:getConfData("equiprefine")[self.equipPos][partInfo.level + 1]
	-- 	local maxXp = conf.exp
	-- 	if currBase >= maxXp then
	-- 		currBase = currBase - maxXp
	-- 		partInfo.level = partInfo.level + 1
	-- 		partInfo.exp = currBase
	-- 	else
	-- 		partInfo.exp = currBase
	-- 		needlvup = false
	-- 	end
	-- end

	local level = partInfo.level
	local num = math.ceil(self.addExp / (materialobj:getUseEffect()))
	if num > materialobj:getNum() then
		num = materialobj:getNum()
	end
	local args = {
		hero_pos = self.pos,
		part_pos = self.equipPos,
		item_id = materialobj:getId(),
		item_num = num,
	}
	MessageMgr:sendPost('addPartExp', 'partintensify', json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
        	partInfo.level = data.level
        	partInfo.exp = data.exp
        	local costs = data.costs
        	if costs then
        		GlobalApi:parseAwardData(costs)
        	end
        	if data.level > level then
        		RoleMgr:showEquipRefineLvUp(self.pos,self.equipPos,level,partInfo.level,5)
        	else
        		promptmgr:showSystenHint(GlobalApi:getLocalStr('SUIT_DESC_14'), COLOR_TYPE.GREEN)
        	end
        	self.obj:setPartInfoByPos(self.equipPos,partInfo)
			self.addExp = 0
           	self.obj:setFightForceDirty(true)

            RoleMgr:updateRoleMainUIForce()
            RoleMgr:updateRoleList()
            RoleMgr:setDirty("RoleMainUI",false)
            self:updatePanel()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'), COLOR_TYPE.RED)
			self:updatePanel()
        end
        self.animation2:setVisible(false)
    end)
end

function EquipRefineUI:updateRun(materialobj,numTx,bgImg)
	if self.costNum >= materialobj:getNum() then
		if self.schedulerEntry then
			local scheduler = bgImg:getScheduler()
    		scheduler:unscheduleScriptEntry(self.schedulerEntry)
    	end
    	if self.animation2 then
    		self.animation2:setVisible(false)
    	end
    	self:runEnd(materialobj)
    	return
	end

	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	local currConf = GameData:getConfData("equiprefine")[self.equipPos][partInfo.level]
	local exp = materialobj:getUseEffect()
	local num = materialobj:getNum()
	local maxXp = self.maxXp - currConf.exp
	self.addExp = (self.addExp or 0) + exp
	self.costNum = (self.costNum or 0) + 1
	if self.costNum > num then
		self.costNum = num 
	end
	local currXp = self.baseXp + self.addExp
	-- print('==========================0',self.addExp,self.baseXp,self.maxXp)
	local percent =string.format("%.2f", (currXp - currConf.exp)/maxXp*100)
    if not self.animation2 then
    	self.animation2 = GlobalApi:createLittleLossyAniByName("tianming_soul_00")
		self.animation2:setAnchorPoint(cc.p(0.5, 0.5))
		self.animation2:getAnimation():setSpeedScale(1)
		self.animation2:getAnimation():playWithIndex(0,-1,-1)
		UIManager:addAction(self.animation2)
	end
	if tonumber(percent) < 0 then
		percent = 0
	elseif tonumber(percent) > 100 then
		percent = 10
	end
	self.animation2:setVisible(true)
	local size = self.bar:getContentSize()
	local x2 = percent * size.width / 100
	local y2 = size.height/2
	local pos2 = self.bar:convertToWorldSpace(cc.p(x2 - 23, size.height/2))
	self.animation2:setPosition(cc.p(pos2.x, pos2.y))
	self.bar:setPercent(percent)
    self.barTx:setString(GlobalApi:getLocalStr('SUIT_DESC_13')..' '..(currXp - currConf.exp)..'/'..maxXp)
    numTx:setString('x'..(num - self.costNum))

    if currXp >= self.maxXp then
    	if self.schedulerEntry then
    		local scheduler = bgImg:getScheduler()
    		scheduler:unscheduleScriptEntry(self.schedulerEntry)
    	end
    	self:runEnd(materialobj)
	end
end

function EquipRefineUI:updateRightMaxBottomPanel(b)
	local bottomImg = self.rightPl:getChildByName('bottom_img')
	for i=1,4 do
		local bgImg = bottomImg:getChildByName('award_bg_img_'..i)
		if bgImg then
			bgImg:setVisible(not b)
		end
	end
end

function EquipRefineUI:updateRightBottomPanel()
	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	local nextLevel = partInfo.level + 1
	local currConf = GameData:getConfData("equiprefine")[self.equipPos][partInfo.level]
	local conf = GameData:getConfData("equiprefine")[self.equipPos][nextLevel]
	if not conf then
		self.bar:setPercent(100)
		self.barTx:setString(GlobalApi:getLocalStr('SUIT_DESC_13')..' '..currConf.exp..'/'..currConf.exp)
		self:updateRightMaxBottomPanel(true)
		return 
	else
		self:updateRightMaxBottomPanel(false)
		self.baseXp = partInfo.exp
		self.maxXp = conf.exp
		local maxXp = self.maxXp - currConf.exp
		local percent =string.format("%.2f", (self.baseXp - currConf.exp)/maxXp*100)
		self.bar:setPercent(percent)
		self.barTx:setString(GlobalApi:getLocalStr('SUIT_DESC_13')..' '..(self.baseXp - currConf.exp)..'/'..maxXp)
	end
	local bottomImg = self.rightPl:getChildByName('bottom_img')
	for i=1,4 do
		-- local bgImg = bottomImg:getChildByName('award_bg_img_'..i)
		local awardBgImg = bottomImg:getChildByName('award_bg_img_'..i)
		-- bgImg:setVisible(true)
		if not awardBgImg then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			awardBgImg = tab.awardBgImg
			awardBgImg:setTouchEnabled(false)
			awardBgImg:setScale(0.88)
			awardBgImg:setName('award_bg_img_'..i)
			local size = awardBgImg:getContentSize()
			awardBgImg:setPosition(cc.p((i - 0.5)*(size.width*0.88 + 15) + 11,150))
			bottomImg:addChild(awardBgImg)
		end
		local materialobj = BagData:getMaterialById(self.itemdata[i].id)
		ClassItemCell:updateItem(awardBgImg, materialobj, 2)
		local limitTx = awardBgImg:getChildByName('limit_tx')
		local numTx = awardBgImg:getChildByName('lv_tx')
		limitTx:setAnchorPoint(cc.p(1,0.5))
		limitTx:setString('+'..materialobj:getUseEffect())
		numTx:setString('x'..materialobj:getNum())
		limitTx:setVisible(true)
		limitTx:setColor(COLOR_TYPE.GREEN)
		limitTx:enableOutline(COLOROUTLINE_TYPE.GREEN,1)
		limitTx:setPosition(cc.p(88,76))
		numTx:setVisible(true)
		
	    local scheduler = awardBgImg:getScheduler()
	    awardBgImg:setTouchEnabled(true)
		awardBgImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	        	AudioMgr.PlayAudio(11)
	        	if materialobj:getNum() <= 0 then
	        		promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
	        		GetWayMgr:showGetwayUI(materialobj,true)
	        		return
	        	end
            	self.costNum = 0
            	self:updateRun(materialobj,numTx,awardBgImg)
	        	if self.schedulerEntry then
	        		scheduler:unscheduleScriptEntry(self.schedulerEntry)
	        	end
	        	self.isRun = true
	        	self.schedulerEntry = scheduler:scheduleScriptFunc(function()
	        		self:updateRun(materialobj,numTx,awardBgImg)
	        	end,0.1,false)
		    elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
	        	if self.schedulerEntry then
	        		scheduler:unscheduleScriptEntry(self.schedulerEntry)
	        	end
	        	if self.animation2 then
	        		self.animation2:setVisible(false)
	        	end
	        	self:runEnd(materialobj)
	        end
	    end)
	end
end

function EquipRefineUI:updateRightMaxTopPanel()
    local rightTopPl = self.rightPl:getChildByName('top_pl')
    local rightTopMaxPl = self.rightPl:getChildByName('top_pl_max')
	rightTopMaxPl:setVisible(true)
	rightTopPl:setVisible(false)
	self.maxImg:setVisible(true)
	self.lvUpBtn:setVisible(false)
	self.descTx:setVisible(false)
	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	local level = partInfo.level
	local conf = GameData:getConfData("equiprefine")[self.equipPos][level]
	local attributeConf = GameData:getConfData("attribute")
	local awardBgImg = rightTopMaxPl:getChildByName('equip_bg_img')
	local lvTx1 = rightTopMaxPl:getChildByName('lv_tx_1')
	lvTx1:setString('Lv.'..level)
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.OTHER)
		awardBgImg = tab.awardBgImg
		awardBgImg:setName('equip_bg_img')
		tab.awardBgImg:setPosition(cc.p(75,100))
		rightTopMaxPl:addChild(tab.awardBgImg)
	end
	awardBgImg:loadTexture('uires/ui/treasure/treasure_merge_kuang.png')
	awardBgImg:ignoreContentAdaptWithSize(true)
	local awardImg = awardBgImg:getChildByName('award_img')
	awardImg:loadTexture(DEFAULTEQUIPPART[self.equipPos])
	local nameTx = awardBgImg:getChildByName('name_tx1')
	if not nameTx then
	    nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	    nameTx:setPosition(cc.p(48.5,90))
	    nameTx:setColor(COLOR_TYPE.WHITE)
	    nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
	    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	    nameTx:setAnchorPoint(cc.p(0.5,0.5))
	    nameTx:setName('name_tx1')
	    awardBgImg:addChild(nameTx)
	end
	nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..self.equipPos))

	if not self.starRtsMax then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(300, 30))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_JIHUO')..level, 24, COLOR_TYPE.YELLOW)
		local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing.png')
		local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_ATTR'), 24, COLOR_TYPE.YELLOW)
		re1:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		re3:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:setPosition(cc.p(240,92))
		rightTopMaxPl:addChild(richText)
		self.starRtsMax = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
	else
		self.starRtsMax.re1:setString(GlobalApi:getLocalStr('STRENGTH_JIHUO')..level)
		self.starRtsMax.richText:format(true)
	end

	local attrTab = {}
	for i,v in pairs(conf.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab = {name = name,desc = desc}
	end

	if not self.attrRtsMax then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(200, 24))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(attrTab.name, 24, COLOR_TYPE.RED)
		local re2 = xx.RichTextLabel:create(' +'..attrTab.desc, 24, COLOR_TYPE.YELLOW)
		re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
		re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:setPosition(cc.p(240,50))
		rightTopMaxPl:addChild(richText)
		self.attrRtsMax = {richText = richText,re1 = re1,re2 = re2}
	else
		self.attrRtsMax.re1:setString(attrTab.name)
		self.attrRtsMax.re2:setString(' +'..attrTab.desc)
		self.attrRtsMax.richText:format(true)
	end
end

function EquipRefineUI:updateRightTopPanel()
	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	local level = partInfo.level
	local conf = GameData:getConfData("equiprefine")[self.equipPos][level]
	local conf1 = GameData:getConfData("equiprefine")[self.equipPos][level + 1]
	local attributeConf = GameData:getConfData("attribute")
	if not conf1 then
		self:updateRightMaxTopPanel()
		return
	end
    local rightTopMaxPl = self.rightPl:getChildByName('top_pl_max')
	local topPl = self.rightPl:getChildByName('top_pl')
	rightTopMaxPl:setVisible(false)
	topPl:setVisible(true)
	self.maxImg:setVisible(false)
	self.lvUpBtn:setVisible(true)
	self.descTx:setVisible(true)
	local awardBgImg = topPl:getChildByName('equip_bg_img')
	local lvTx1 = topPl:getChildByName('lv_tx_1')
	local lvTx2 = topPl:getChildByName('lv_tx_2')
	lvTx1:setString('Lv.'..level)
	lvTx2:setString('Lv.'..(level + 1))
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.OTHER)
		awardBgImg = tab.awardBgImg
		awardBgImg:setName('equip_bg_img')
		tab.awardBgImg:setPosition(cc.p(75,122))
		topPl:addChild(tab.awardBgImg)
	end
	awardBgImg:loadTexture('uires/ui/treasure/treasure_merge_kuang.png')
	awardBgImg:ignoreContentAdaptWithSize(true)
	local awardImg = awardBgImg:getChildByName('award_img')
	awardImg:loadTexture(DEFAULTEQUIPPART[self.equipPos])
	-- local nameTx = awardBgImg:getChildByName('name_tx')
	-- nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..self.equipPos))
	-- nameTx:setColor(COLOR_TYPE.WHITE)
	-- nameTx:setFont('font/gamefont.ttf')
	-- nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
	-- nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	-- nameTx:setPosition(cc.p(48.5,75))

	local nameTx = awardBgImg:getChildByName('name_tx1')
	if not nameTx then
	    nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	    nameTx:setPosition(cc.p(48.5,90))
	    nameTx:setColor(COLOR_TYPE.WHITE)
	    nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
	    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	    nameTx:setAnchorPoint(cc.p(0.5,0.5))
	    nameTx:setName('name_tx1')
	    awardBgImg:addChild(nameTx)
	end
	nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..self.equipPos))

	if not self.starRts then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(300, 30))
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_JIHUO')..(level + 1), 24, COLOR_TYPE.YELLOW)
		local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing.png')
		local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_ATTR'), 24, COLOR_TYPE.YELLOW)
		re1:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		re3:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:setAnchorPoint(cc.p(0,0))
		richText:setPosition(cc.p(150,82))
		topPl:addChild(richText)
		self.starRts = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
	else
		self.starRts.re1:setString(GlobalApi:getLocalStr('STRENGTH_JIHUO')..(level + 1))
		self.starRts.richText:format(true)
	end

	local attrTab = {}
	for i,v in pairs(conf.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab[#attrTab + 1] = {name = name,desc = desc}
	end
	for i,v in pairs(conf1.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab[#attrTab + 1] = {name = name,desc = desc}
	end

	if not self.attrRts1 then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(200, 24))
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(attrTab[1].name, 24, COLOR_TYPE.RED)
		local re2 = xx.RichTextLabel:create(' +'..attrTab[1].desc, 24, COLOR_TYPE.YELLOW)
		re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
		re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:setAnchorPoint(cc.p(0,0.5))
		richText:setPosition(cc.p(35,50))
		topPl:addChild(richText)
		self.attrRts1 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.attrRts1.re1:setString(attrTab[1].name)
		self.attrRts1.re2:setString(' +'..attrTab[1].desc)
		self.attrRts1.richText:format(true)
	end

	if not self.attrRts2 then
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(200, 24))
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(attrTab[2].name, 24, COLOR_TYPE.RED)
		local re2 = xx.RichTextLabel:create(' +'..attrTab[2].desc, 24, COLOR_TYPE.YELLOW)
		local re3 = xx.RichTextImage:create('uires/ui/common/arrow1.png')
		re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
		re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:setAnchorPoint(cc.p(0,0.5))
		richText:setPosition(cc.p(240,50))
		topPl:addChild(richText)
		self.attrRts2 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.attrRts2.re1:setString(attrTab[2].name)
		self.attrRts2.re2:setString(' +'..attrTab[2].desc)
		self.attrRts2.richText:format(true)
	end
end

function EquipRefineUI:updateRightPanel()
	self:updateRightTopPanel()
	self:updateRightBottomPanel()
end

function EquipRefineUI:updateLeftPanel()
	local bgImg = self.leftPl:getChildByName('bg_img')
	local equipBgImg = bgImg:getChildByName('equip_bg_img_'..self.equipPos)
	local lightImg = bgImg:getChildByName('light_img')
	lightImg:setPosition(equipBgImg:getPosition())
	for i=1,6 do
		local partInfo = self.obj:getPartInfoByPos(i)
		local equipBgImg = bgImg:getChildByName('equip_bg_img_'..i)
		equipBgImg:setLocalZOrder(9)
		local lvTx = equipBgImg:getChildByName('lv_tx')
		lvTx:setString('Lv.'..partInfo.level)
	end
	if not self.spine then
		local url = self.obj:getUrl()
	    self.spine = GlobalApi:createLittleLossyAniByName(url..'_display', nil, self.obj:getChangeEquipState())
		self.spine:setPosition(cc.p(250,135))
		bgImg:addChild(self.spine)
	    self.spine:getAnimation():play('idle', -1, 1)
	end
end

function EquipRefineUI:updatePanel()
	self:updateLeftPanel()
	self:updateRightPanel()
end

function EquipRefineUI:upgradeOneLv()
	local partInfo = self.obj:getPartInfoByPos(self.equipPos)
	local level = partInfo.level
	local nextLevel = partInfo.level + 1
	local currConf = GameData:getConfData("equiprefine")[self.equipPos][partInfo.level]
	local conf = GameData:getConfData("equiprefine")[self.equipPos][nextLevel]

	print(self.baseXp,currConf.exp,self.baseXp - currConf.exp,conf.exp - self.baseXp)
	local needXp = conf.exp - self.baseXp
	local oldNeedXp = conf.exp - self.baseXp
	local nowXp = 0
	local materialNums = {}
	local canUpgrade = false
	for i,v in ipairs(self.itemdata) do
		local materialobj = BagData:getMaterialById(v.id)
		local exp = tonumber(materialobj:getUseEffect())
		local num = math.ceil(needXp/exp)
		if materialobj:getNum() >= num then
			materialNums[tostring(v.id)] = num
			nowXp = nowXp + num*exp
			canUpgrade = true
			break
		else
			if materialobj:getNum() > 0 then
				materialNums[tostring(v.id)] = materialobj:getNum()
				needXp = needXp - materialobj:getNum()*exp
				nowXp = nowXp + materialobj:getNum()*exp
			end
		end
	end
	local surplusExp = nowXp - oldNeedXp
	if canUpgrade then
		for i=#self.itemdata,1,-1 do
			local materialobj = BagData:getMaterialById(self.itemdata[i].id)
			if materialNums[tostring(self.itemdata[i].id)] and materialNums[tostring(self.itemdata[i].id)] > 0 then
				local exp = tonumber(materialobj:getUseEffect())
				if surplusExp >= exp then
					local num = math.floor(surplusExp/exp)
					local minNum = math.min(num,materialNums[tostring(self.itemdata[i].id)])
					surplusExp = surplusExp - num*exp
					materialNums[tostring(self.itemdata[i].id)] = materialNums[tostring(self.itemdata[i].id)] - minNum
					if materialNums[tostring(self.itemdata[i].id)] <= 0 then
						materialNums[tostring(self.itemdata[i].id)] = nil
					end
				end
			end
		end
		local awards = {}
		for k,v in pairs(materialNums) do
			awards[#awards + 1] = {'material',tonumber(k),v}
		end
		table.sort(awards,function(a,b)
			return a[2] < b[2]
		end )
		RoleMgr:showRoleOneLevelPannel(awards,GlobalApi:getLocalStr('EQUIP_REFINE_DESC_2'),function()
			local args = {
					hero_pos = self.pos,
					part_pos = self.equipPos,
					item = materialNums,
					exp = surplusExp,
				}
			MessageMgr:sendPost("addPartExp_all", "partintensify", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				local data = jsonObj.data
				if code == 0 then
					partInfo.level = data.level
					partInfo.exp = data.exp
					local costs = data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					if data.level > level then
						RoleMgr:showEquipRefineLvUp(self.pos,self.equipPos,level,partInfo.level,5)
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('SUIT_DESC_14'), COLOR_TYPE.GREEN)
					end
					self.obj:setPartInfoByPos(self.equipPos,partInfo)
					self.obj:setFightForceDirty(true)

					RoleMgr:updateRoleMainUIForce()
					RoleMgr:updateRoleList()
					RoleMgr:setDirty("RoleMainUI",false)
					self:updatePanel()
				end
			end)
		end)
	else
		local materialobj = BagData:getMaterialById(self.itemdata[1].id)
		promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
		GetWayMgr:showGetwayUI(materialobj,true)
	end
end

function EquipRefineUI:init()
	local bgImg = self.root:getChildByName("suit_bg_img")
	local suitImg = bgImg:getChildByName("suit_img")
    self:adaptUI(bgImg, suitImg)
    local winSize = cc.Director:getInstance():getWinSize()
    suitImg:setPosition(cc.p(winSize.width/2,winSize.height/2-30))
    self.leftPl = suitImg:getChildByName('left_pl')
    self.rightPl = suitImg:getChildByName('right_pl')
    local titleImg = suitImg:getChildByName('tile_img')
    local infoTx = titleImg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('TITLE_ZBJL'))
    local bottomImg = self.rightPl:getChildByName('bottom_img')
    local barImg = bottomImg:getChildByName('bar_img')
    self.descTx = bottomImg:getChildByName('desc_tx')
    self.lvUpBtn = bottomImg:getChildByName('lv_up_btn')
    local infoTx = self.lvUpBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('ROLE_LVUP_DESC1'))
    self.bar = bottomImg:getChildByName('bar')
    self.barTx = barImg:getChildByName('bar_tx')
    self.maxImg = bottomImg:getChildByName('max_img')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(6,6,5,5))
    self.descTx:setString(GlobalApi:getLocalStr('EQUIP_REFINE_DESC_1'))
	
	self.lvUpBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:upgradeOneLv()
		end
	end)
	local leftBgImg = self.leftPl:getChildByName('bg_img')
	for i=1,6 do
		local equipBgImg = leftBgImg:getChildByName('equip_bg_img_'..i)
		local nameTx = equipBgImg:getChildByName('name_tx')
		nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..i))
		equipBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
	            self.equipPos = i
	            self:updatePanel()
	        end
	    end)
	end

    local closeBtn = suitImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideEquipRefine()
        end
    end)
    local leftBtn = bgImg:getChildByName('left_btn')
    local rightBtn = bgImg:getChildByName('right_btn')
    leftBtn:setPosition(cc.p(0,winSize.height/2))
    rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)
	leftBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local maxNum = RoleData:getRoleNum()
        	while true
        	do
        		self.pos = (self.pos - 2)%maxNum + 1
        		local obj = RoleData:getRoleByPos(self.pos)
        		if obj and obj:getId() > 0 then
        			self.obj = obj
        			RoleMgr:setCurHeroChange(self.pos)
        			break
        		end
        	end
			self.baseXp = 0
			self.addExp = 0
			self.costNum = 0
			self.maxXp = 0
			if self.spine then
				self.spine:removeFromParent()
				self.spine = nil
			end
        	self:updatePanel()
        end
    end)
	rightBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local maxNum = RoleData:getRoleNum()
        	while true
        	do
        		self.pos = self.pos%maxNum + 1
        		local obj = RoleData:getRoleByPos(self.pos)
        		if obj and obj:getId() > 0 then
        			self.obj = obj
        			RoleMgr:setCurHeroChange(self.pos)
        			break
        		end
        	end
			self.baseXp = 0
			self.addExp = 0
			self.costNum = 0
			self.maxXp = 0
			if self.spine then
				self.spine:removeFromParent()
				self.spine = nil
			end
        	self:updatePanel()
        end
    end)

    self.itemdata = {}
	local itemdat = GameData:getConfData('item')
	for k,v in pairs(itemdat) do
		if tostring(v.useType) == 'partexp' then
			table.insert(self.itemdata,v)
		end
	end
	table.sort(self.itemdata, function (a, b)
			local q1 = a.quality
			local q2 = b.quality
			if q1 == q2 then
				local f1 = a.id
				local f2 = b.id
				return f1 < f2
			else
				return q1 < q2
			end
	end)
    self:updatePanel()
end

return EquipRefineUI