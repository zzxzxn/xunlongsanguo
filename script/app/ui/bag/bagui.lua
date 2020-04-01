local BagUI = class("BagUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradenewui")
local ClassItemCell = require('script/app/global/itemcell')

local ITEM_PAGE = 1
local GEM_PAGE = 2
local EQUIP_PAGE = 3
local EXCLUSIVE_PAGE = 4
local PAGE_BTN_STYPE = {'item','gem','equip','exclusive'}
function BagUI:ctor(id)
	self.uiIndex = GAME_UI.UI_BAG
	self.page = id or ITEM_PAGE
	self.frames = {}
	self.oldMaxFrame = 0
	self.itemAttrRichText = {}
	self.maxNum = 4
	self.runOnShow = true
	self.oldH = 0
	self.currH = 0
end

function BagUI:onShow()
	-- self.currObj = nil
	if self.runOnShow then
		self:updatePanel()
	end
	self.runOnShow = true
end

local function sortFn(a, b)
	local q1 = a:getQuality()
	local q2 = b:getQuality()
	local godId1 = (a.getGodId and a:getGodId()) or 0
	local godId2 = (b.getGodId and b:getGodId()) or 0
	local level1 = (a.getGodLevel and a:getGodLevel()) or 0
	local level2 = (b.getGodLevel and b:getGodLevel()) or 0
	if godId1 == 2 then
		godId1 = 1
	end
	if godId2 == 2 then
		godId2 = 1
	end
	if godId1 == godId2 then
		if q1 == q2 then
			if level1 == level2 then
				local l1 = a:getLevel()
				local l2 = b:getLevel()
				if l1 == l2 then
					local id1 = a:getId()
					local id2 = b:getId()
					return id1 < id2
				else
					return l1 > l2
				end
			else
				return level1 > level2
			end
		else
			return q1 > q2
		end
	else
		return godId1 > godId2
	end
end

function BagUI:updateEquip()
	local equipTab = {}
	for i=1,6 do
		local tab = BagData:getEquipMapByType(i)
		for k, v in pairs(tab) do
			table.insert(equipTab, v)
		end
	end
	if #equipTab > 2 then
		table.sort(equipTab,sortFn )
	end
	for j,v in pairs(equipTab) do
		self.currMax = self.currMax + 1
		local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..self.currMax)
		local param = {
			bgName = 'award_bg_img_'..self.currMax,
		}
		awardBgImg = ClassItemCell:updateAwardFrameByObj(self.cardSv,v,param)
		if not self.currObj then
			self.currObj = {v,EQUIP_PAGE,awardBgImg}
		end
		awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.currObj = {v,EQUIP_PAGE,awardBgImg}
				self:updateLeftPanel(v,EQUIP_PAGE)
			end
		end)
	end
end

function BagUI:updateExclusive()
	local exclusiveTab = BagData:getAllExclusive()
	local showTab = {}
	for i=1,4 do
		local tab = exclusiveTab[i]
		if tab then
			for k, v in pairs(tab) do
				table.insert(showTab, v)
			end
		end
	end
	table.sort( showTab, sortFn )
	for k,v in pairs(showTab) do
		self.currMax = self.currMax + 1
		local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..self.currMax)
		local param = {
			bgName = 'award_bg_img_'..self.currMax,
		}
		awardBgImg = ClassItemCell:updateAwardFrameByObj(self.cardSv,v,param)
		if not self.currObj or self.currObj[1]:getId() == v:getId() then
			self.currObj = {v,EXCLUSIVE_PAGE,awardBgImg}
		end
		awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.currObj = {v,EXCLUSIVE_PAGE,awardBgImg}
				self:updateLeftPanel(v,EXCLUSIVE_PAGE)
			end
		end)
	end
end

function BagUI:updateGem()
	local gemTab = BagData:getAllGems()
	local showTab = {}
	for i=1,4 do
		local tab = gemTab[i]
		if tab then
			for k, v in pairs(tab) do
				table.insert(showTab, v)
			end
		end
	end
	table.sort( showTab, sortFn )
	for k,v in pairs(showTab) do
		self.currMax = self.currMax + 1
		local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..self.currMax)
		local param = {
			bgName = 'award_bg_img_'..self.currMax,
		}
		awardBgImg = ClassItemCell:updateAwardFrameByObj(self.cardSv,v,param)
		if not self.currObj or self.currObj[1]:getId() == v:getId() then
			self.currObj = {v,GEM_PAGE,awardBgImg}
		end
		awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.currObj = {v,GEM_PAGE,awardBgImg}
				self:updateLeftPanel(v,GEM_PAGE)
			end
		end)
	end
end

local function sortFn1(a, b)
	local q1 = a:getQuality()
	local q2 = b:getQuality()
	local u1 = a:getUseable()
	local u2 = b:getUseable()
	-- local n1 = a:getNew()
	-- local n2 = b:getNew()
	local s1 = a:getObjType()
	local s2 = b:getObjType()
	if u1 == u2 then
		if s1 == s2 then
			if q1 == q2 then
				local id1 = a:getId()
				local id2 = b:getId()
				return id1 > id2
			else
				return q1 > q2
			end
		else
			if s1 == 'dress' then
				return false
			elseif s1 == 'dragon' then
				return false
			elseif s1 == 'limitmat' then
				return false
			else
				return true

			end
		end
	else
		return u1 > u2
	end
end

function BagUI:updateItem()
	local tab = BagData:getAllMaterial()
	local tab1 = BagData:getAllDresses()
	local tab2 = BagData:getAllDragongems()
	local tab3 = BagData:getAllLimitMat()
	local showTab = {}
	if tab then
		for k, v in pairs(tab) do
			table.insert(showTab, v)
		end
	end
	if tab1 then
		for k, v in pairs(tab1) do
			table.insert(showTab, v)
		end
	end
	if tab2 then
		for i=1,4 do
			if tab2[i] then
				for k,v in pairs(tab2[i]) do
					table.insert(showTab, v)
				end
			end
		end
	end
	if tab3 then
		for k, v in pairs(tab3) do
			table.insert(showTab, v)
		end
	end
	table.sort( showTab, sortFn1 )
	for k,v in pairs(showTab) do
		local showable = v:getShowable()
		if showable == 1 then
			self.currMax = self.currMax + 1
			local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..self.currMax)
			local param = {
				bgName = 'award_bg_img_'..self.currMax,
			}
			awardBgImg = ClassItemCell:updateAwardFrameByObj(self.cardSv,v,param)
			v:setNew(false)
			if not self.currObj or self.currObj[1]:getId() == v:getId() then
				self.currObj = {v,ITEM_PAGE,awardBgImg}
			end
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					self.currObj = {v,ITEM_PAGE,awardBgImg}
					self:updateLeftPanel(v,ITEM_PAGE)
				end
			end)
		end
	end
end

function BagUI:getPos(w,h)
	local posX = w * (self.singleSize.width + self.intervalSize) - self.singleSize.width/2
	local posY = h * (self.singleSize.height + self.intervalSize) - self.singleSize.height/2 - self.intervalSize
	return cc.p(posX,posY)
end

function BagUI:getWH(i)
	local w,h
	local maxH = math.floor((self.currMax - 1)/self.maxNum) + 1
	if maxH < 4 then
		maxH = 3.4
	end
	self.currH = maxH
	if self.page == EQUIP_PAGE then
		maxH = ((maxH < 4 )and 3.375) or maxH
	else
		maxH = ((maxH < 5 )and 4.215) or maxH
	end
	local h = maxH - math.floor((i - 1)/self.maxNum)
	local w = (i - 1)%self.maxNum + 1
	return w,h
end

-- function BagUI:setEquipPosition()
-- 	for i=1,self.maxEquip do
-- 		local awardBgImg = self.cardSv:getChildByTag(i + 100)
-- 		awardBgImg:setPosition(self:getPos(self:getWH(i)))
-- 	end
-- end

-- function BagUI:setGemPosition()
-- 	for i= self.maxEquip + 1,self.maxEquip + self.maxGem do
-- 		local awardBgImg = self.cardSv:getChildByTag(i + 100)
-- 		awardBgImg:setPosition(self:getPos(self:getWH(i)))
-- 	end
-- end

-- function BagUI:setItemPosition()
-- 	for i=self.maxEquip + self.maxGem + 1,self.currMax do
-- 		local awardBgImg = self.cardSv:getChildByTag(i + 100)
-- 		awardBgImg:setPosition(self:getPos(self:getWH(i)))
-- 	end
-- end

function BagUI:setAwardPosition()
	for i=1,self.currMax do
		local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..i)
		awardBgImg:setPosition(self:getPos(self:getWH(i)))
	end
end

function BagUI:updateLeftItemPanel(obj,ntype)
	self.rightBgImg:setVisible(true)
	self.rightBgImg1:setVisible(false)
	local nameTx = self.goodsBgImg:getChildByName("name_tx")
	local btnTx = self.mergeBtn:getChildByName("info_tx")
	local posX,posY = self.goodsBgImg:getPosition()
	local param = {
		showLvTx = false,
		bgPos = cc.p(posX,posY),
	}
	self.awardBgImg = ClassItemCell:updateAwardFrameByObj(self.rightBgImg,obj,param)
	
	if obj:getCategory() == "limitmat" then
		self.timebg:setVisible(true)
		local time = 0
		if tonumber(obj:getTimeType()) == 1 then
			time = obj:getTime()
		elseif tonumber(obj:getTimeType()) == 2 then
			time = obj:getTime() - GlobalData:getServerTime()
		end
		if tonumber(time) > 0 then
			self.timetx:removeAllChildren()
			if tonumber(obj:getTimeType()) == 1 then
				local str1 = GlobalApi:getLocalStr('LIMIT_TIME_DESC')
				local str2 = GlobalApi:toStringTime(time,"YMD",1)
				local str3 = GlobalApi:toStringTime(time,"H",1)
				self.timetx:setString(str1..str2..str3)
				self.cdlabel:setTime(time-GlobalData:getServerTime())
				self.cdlabel:setVisible(false)
			elseif tonumber(obj:getTimeType()) == 2 then
				self.timetx:setString('')
				local str1 = GlobalApi:toStringTime(time,"D",2)       	           	
				local  day = math.floor(time/86400)
				if day > 0 then
					self.cdlabel:setString(GlobalApi:getLocalStr('REMAINDER_TIME')..str1)
				else
					self.cdlabel:setString(GlobalApi:getLocalStr('REMAINDER_TIME'))
				end
				local time1 = time-day*86400
				self.cdlabel:setTime(time1)
				self.cdlabel:setVisible(true)
			end
		else
			self.timetx:removeAllChildren()
			self.timetx:setString('')
			self.timebg:setVisible(false)
		end
	else
		self.timebg:setVisible(false)
	end
	self.autoMergeBtn:setVisible(false)
	self.sellBtn:setVisible(true)
	local numTx = self.sellBtn:getChildByName("num_tx")
	local infoTx = self.sellBtn:getChildByName('info_tx')
	local goldImg = self.sellBtn:getChildByName('gold_icon')
	if obj:getSellable() == 1 then
		numTx:setString(obj:getSell())
		infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE2,1)
		self.sellBtn:setBright(true)
		self.sellBtn:setTouchEnabled(true)
		goldImg:setVisible(true)
	else
		numTx:setString('')
		infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
		self.sellBtn:setBright(false)
		self.sellBtn:setTouchEnabled(false)
		goldImg:setVisible(false)
	end
	if obj:getCategory() == 'dress' or obj:getUseable() == 2 then
		btnTx:setString(GlobalApi:getLocalStr('STR_MERGE_1'))
	else
		btnTx:setString(GlobalApi:getLocalStr('USE'))
	end
	self.mergeBtn:setVisible(true)

	local num = obj:getNum()
	local mergeNum = ((obj.getMergeNum and obj:getMergeNum() == 0) and 1) or obj:getMergeNum()
	if obj:getUseable() == 1 and (num / mergeNum) >= 1 then
		self.mergeBtn:setBright(true)
		self.mergeBtn:setTouchEnabled(true)
		self.mergeBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				-- 神器碎片需要关卡开启
				if obj:getCategory() == 'dress' then
					local id = obj:getId()
					BagMgr:showDressMerge(id,true)
				else
					if obj:getId() == 200079 then
						local food = UserData:getUserObj():getFood()
						local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
						if food >= maxFood then
							promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
							return
						end
					end
					local userType = obj:getUseType()
					if userType == 'herobox' then
						if obj:getId() == 200131 or obj:getId() == 200132 or obj:getId() == 200133 or obj:getId() == 200134 then
							BagMgr:showJadeSealAwardNewUI(obj)
						else
							local userEffect = tonumber(obj:getUseEffect())
							BagMgr:showHeroBox(userEffect,obj:getId(),obj:getNum())
						end
					elseif userType == 'trialbox' then
						BagMgr:showOpenBox(obj)
					else
						local moduleOpen = obj:getModule()
						if moduleOpen and moduleOpen ~= '' then
							local desc,isOpen = GlobalApi:getGotoByModule(moduleOpen,true)
							if desc then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
								return
							end
						end
						self:useItemByTarget(obj,num,mergeNum)
					end
				end
			end
		end)
		btnTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
		btnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	elseif obj:getUseable() == 2 and (num / mergeNum) >= 1 then
		self.mergeBtn:setBright(true)
		self.mergeBtn:setTouchEnabled(true)
		local function showstatus()
			local level = UserData:getUserObj():getLv()
			local str = string.format(GlobalApi:getLocalStr('MERGE_DESTINY_LIMIT_DESC'),obj:getMergeLvLimit())
			if level >= obj:getMergeLvLimit() then
				BagMgr:showDestinyMerge(obj:getId(),true)
			else	
				promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			end
		end
		self.mergeBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if obj:getId() == 300001 then
					promptmgr:showMessageBox(GlobalApi:getLocalStr("MERGE_DESTINY_DESC"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()	
						showstatus()
					end)
				else
					showstatus()
				end
			end
		end)
	else
		self.mergeBtn:setBright(false)
		self.mergeBtn:setTouchEnabled(false)
		btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
		btnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	end
	self.infoPl1:setVisible(false)
	self.infoPl2:setVisible(true)
	nameTx:setString(obj:getName())
	nameTx:setColor(obj:getNameColor())
	nameTx:enableOutline(obj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	for i=1,4 do
		local bgImg = self.goodsBgImg:getChildByName('gem_bg_'..i..'_img')
		bgImg:setVisible(false)
	end

	local maxHeight = 0
	local diffHeight = 28
	local size = self.infoPl2:getContentSize()
	local function getPos(i)
		return cc.p(0,size.height - diffHeight*(i-1))
	end
	local tx1 = self.infoPl2:getChildByName('info_1_tx')
	tx1:ignoreContentAdaptWithSize(false)
	tx1:setTextAreaSize(cc.size(300,150))
	local tx2 = self.infoPl2:getChildByName('info_2_tx')
	
	if obj:getCategory() == 'dragon' then
		local size = self.infoPl2:getContentSize()
		local function getPos(i)
			return cc.p(0,size.height - diffHeight*i)
		end
		tx1:setString(obj:getAttName() .. ' +'..obj:getAttNum()..'%')
		tx1:setColor(obj:getNameColor())
		tx1:enableOutline(obj:getNameOutlineColor(),1)
		tx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		tx1:setPosition(getPos(0))

		tx2:setString(obj:getDesc())
		tx2:setColor(COLOR_TYPE.WHITE)
		tx2:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
		tx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		tx2:setPosition(getPos(1))
	else
		tx2:setString('')
		tx1:setString(obj:getDesc())
		tx1:setPosition(getPos(1))
		tx1:setColor(obj:getNameColor())
		tx1:enableOutline(obj:getNameOutlineColor(),1)
		tx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		for i=1,2 do
			local richText = self.infoPl2:getChildByTag(i+9999)
			if richText then
				richText:setVisible(false)
			end
		end
	end

	self.checkBtn:setVisible(false)
	if obj:judgeHasDrop(obj) then
		self.checkBtn:setVisible(true)
		self.sellBtn:setVisible(false)
		self.autoMergeBtn:setVisible(false)
	end
	self.checkBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			GetWayMgr:showGetwayUI(obj,false)
		end
	end)
end

function BagUI:useItem(mergeNum,obj,act)
	local act = act or 'use'
	local args = {
		type = 'material',
		id = obj:getId(),
		num = mergeNum
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
			local useEffect = obj:getUseEffect()
			if useEffect then
				local tab = string.split(useEffect,':')
				if tab and tab[1] == 'arena' then
					promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('BAG_GET_DESC_1'),1), COLOR_TYPE.GREEN)
				end

				if tonumber(obj:getId()) == 500001 then
					--print('===+++++++++' .. useEffect)                    
					SdkData:openUrl(useEffect)
				end

			end
			-- self.currObj = nil
			self:updatePanel()
		end
	end)
end

function BagUI:useItemByTarget(obj, num, mergeNum)
	if (num / mergeNum) >= 1 and (num / mergeNum) < 2 then
		local cost = obj:getCost()
		if cost and cost:getId() == 'cash' then
			UserData:getUserObj():cost('cash',cost:getNum(),function()
			   self:useItem(mergeNum, obj, 'use_day_box')
			end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost:getNum()))
		else
			self:useItem(mergeNum, obj)
		end
	elseif (num / mergeNum) >= 2 then	
		BagMgr:showUse(self.currObj)
	end
end
function BagUI:updateLeftGemPanel(obj,ntype)
	self.rightBgImg:setVisible(true)
	self.rightBgImg1:setVisible(false)
	local nameTx = self.goodsBgImg:getChildByName("name_tx")
	local btnTx = self.mergeBtn:getChildByName("info_tx")
	local posX,posY = self.goodsBgImg:getPosition()
	local param = {
		showLvTx = false,
		bgPos = cc.p(posX,posY),
	}
	self.awardBgImg = ClassItemCell:updateAwardFrameByObj(self.rightBgImg,obj,param)
	self.timebg:setVisible(false)
	self.sellBtn:setVisible(true)
	self.sellBtn:setTouchEnabled(true)
	self.sellBtn:setBright(true)
	local numTx = self.sellBtn:getChildByName("num_tx")
	numTx:setString(obj:getSell())
	local goldImg = self.sellBtn:getChildByName('gold_icon')
	goldImg:setVisible(true)

	self.mergeBtn:setBright(true)
	self.mergeBtn:setTouchEnabled(true)
	self.mergeBtn:setVisible(true)
	self.checkBtn:setVisible(false)
	btnTx:setColor(COLOR_TYPE['WHITE'])
	btnTx:enableOutline(cc.c3b(165,70,6),1)
	btnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	btnTx:setString(GlobalApi:getLocalStr('STR_MERGE_1'))
	self.mergeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local gemUpgradeUI = ClassGemUpgradeUI.new(obj:getId(),0, nil, function ()
				self:updatePanel()
			end)
			local desc,isOpen = GlobalApi:getGotoByModule('gem_merge',true)
			if desc then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
				return
			end
			gemUpgradeUI:showUI()
		end
	end)
	self.infoPl1:setVisible(false)
	self.infoPl2:setVisible(true)
	nameTx:setString(obj:getName())
	nameTx:setColor(obj:getNameColor())
	nameTx:enableOutline(obj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	for i=1,4 do
		local bgImg = self.goodsBgImg:getChildByName('gem_bg_'..i..'_img')
		bgImg:setVisible(false)
	end

	local maxHeight = 0
	local diffHeight = 28
	local size = self.infoPl2:getContentSize()
	local function getPos(i)
		return cc.p(0,size.height - diffHeight*i)
	end
	local tx1 = self.infoPl2:getChildByName('info_1_tx')
	tx1:setString(obj:getAttrName() .. ' +'..obj:getValue())
	tx1:setColor(obj:getNameColor())
	tx1:enableOutline(obj:getNameOutlineColor(),1)
	tx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	tx1:setPosition(getPos(0))

	local tx2 = self.infoPl2:getChildByName('info_2_tx')
	tx2:setString(obj:getDesc())
	tx2:setColor(COLOR_TYPE.WHITE)
	tx2:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
	tx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	tx2:setPosition(getPos(1))

	for i=1,2 do
		local richText = self.infoPl2:getChildByTag(i+9999)
		if richText then
			richText:setVisible(false)
		end
	end

	local lv = obj:getId()%10
	self.sellBtn:setVisible(true)
	self.autoMergeBtn:setVisible(false)
	self.autoMergeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			BagMgr:showGemMerge(obj)
		end
	end)
end

function BagUI:updateLeftEquipPanel(obj,ntype)
	self.rightBgImg:setVisible(true)
	self.rightBgImg1:setVisible(false)
	local nameTx = self.goodsBgImg:getChildByName("name_tx")
	local btnTx = self.mergeBtn:getChildByName("info_tx")
	local posX,posY = self.goodsBgImg:getPosition()
	self.timebg:setVisible(false)
	local param = {
		showLvTx = false,
		bgPos = cc.p(posX,posY),
	}
	self.awardBgImg = ClassItemCell:updateAwardFrameByObj(self.rightBgImg,obj,param)
	local isCanEquipGem = obj:getEmptyGemNum()
	self.sellBtn:setVisible(true)
	self.sellBtn:setTouchEnabled(true)
	self.sellBtn:setBright(true)
	local numTx = self.sellBtn:getChildByName("num_tx")
	numTx:setString(obj:getSellPrice())
	local goldImg = self.sellBtn:getChildByName('gold_icon')
	goldImg:setVisible(true)
	
	self.autoMergeBtn:setVisible(false)
	self.mergeBtn:setVisible(true)
	self.mergeBtn:setBright(true)
	self.mergeBtn:setTouchEnabled(true)
	self.checkBtn:setVisible(false)
	btnTx:setColor(COLOR_TYPE['WHITE'])
	btnTx:enableOutline(COLOROUTLINE_TYPE['WHITE1'],1)
	btnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	if obj:getGodId() == 0 then
		if obj:isAncient() then
			btnTx:setString(GlobalApi:getLocalStr('DISMANTLING'))
			self.mergeBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					local awards = obj:getDismantlingAward()
					if awards and awards[1] then
						local equipDismantlingUI = require("script/app/ui/equip/equipdismantlingui").new(obj)
						equipDismantlingUI:showUI()
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('DISMANTLING_DESC_1'), COLOR_TYPE.RED)
					end
				end
			end)
		else
			btnTx:setString(GlobalApi:getLocalStr('FUSION'))
			self.mergeBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					-- print('熔炼')
					local isOpen,_,cityId,level = GlobalApi:getOpenInfo('blacksmith')
					if isOpen then
						BagMgr:showFusion(obj,function()
							self.currObj = nil
						end)
					else
						if cityId then
							local cityData = MapData.data[cityId]
							promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..
								cityData:getName()..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
							return
						end
						if level then
							promptmgr:showSystenHint(level..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'), COLOR_TYPE.RED)
							return
						end
					end
				end
			end)
		end
	else
		btnTx:setString(GlobalApi:getLocalStr('INHERIT_1'))
		self.mergeBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				local equipInheritUI = require("script/app/ui/equip/equipinheritui").new(obj)
				equipInheritUI:showUI()
				-- BagMgr:showFusion(obj,function()
				-- 	self.currObj = nil
				-- end)
			end
		end)
	end
	self.infoPl1:setVisible(true)
	self.infoPl2:setVisible(false)

	local maxHeight = 0
	local diffHeight = 28
	local godId = obj:getGodId()
	local size = self.attrSv:getContentSize()
	local function getPos(diffSize)
		return cc.p(0,maxHeight - diffSize)
	end
	local att = obj:getMainAttribute()
	local txs = {}
	local tx1 = self.attrSv:getChildByName('info_1_tx')
	tx1:setString(GlobalApi:getLocalStr('STR_TOTAL_FIGHTFORCE')..': '..obj:getFightForce())
	tx1:setColor(COLOR_TYPE.ORANGE)
	tx1:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	tx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	tx1:setVisible(true)
	txs[#txs + 1] = {tx1,diffHeight}
	maxHeight = maxHeight + diffHeight

	local tx2 = self.attrSv:getChildByName('info_2_tx')
	tx2:setString(att.name .. ' +'..att.value)
	tx2:setColor(COLOR_TYPE.WHITE)
	tx2:enableOutline(COLOR_TYPE.BLACK,1)
	tx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	tx2:setVisible(true)
	txs[#txs + 1] = {tx2,diffHeight}
	maxHeight = maxHeight + diffHeight

	local subAttrs = obj:getSubAttribute()
	local attrNum = 0
	for k, v in pairs(subAttrs) do
		attrNum = attrNum + 1
		local tx = self.attrSv:getChildByName('info_'..(attrNum + 2)..'_tx')
		tx:setVisible(true)
		tx:setString(v.name .. " +" .. v.value)
		tx:setTextColor(obj:getNameColor())
		tx:enableOutline(obj:getNameOutlineColor(),1)
		tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		txs[#txs + 1] = {tx,diffHeight}
		maxHeight = maxHeight + diffHeight
	end

	for i=1,4 do
		local tx = self.attrSv:getChildByName('info_'..(i + 2)..'_tx')
		tx:setVisible(attrNum >= i)
	end

	if godId > 0 then
		local starPl = self.attrSv:getChildByName('star_pl')
		starPl:setVisible(true)
		local level = obj:getGodLevel()
		for i=1,10 do
			local starBgImg = starPl:getChildByName('star_bg_'..i..'_img')
			local starImg = starBgImg:getChildByName('star_img')
			starImg:setVisible(level >= i)
		end
		-- node:setPosition(getPos(diffHeight + 3))
		txs[#txs + 1] = {starPl,diffHeight}
		maxHeight = maxHeight + diffHeight
		local godAttr = clone(obj:getGodAttr())
		if godId == 1 or godId == 2 then
			local tx = self.attrSv:getChildByName('info_7_tx')
			if godAttr[1].type == 1 then
				godAttr[1].value = math.floor(godAttr[1].value/100)
			end
			tx:setString(godAttr[1].name..' +'..godAttr[1].value.."%")
			tx:setAnchorPoint(cc.p(0,0))
			tx:setColor(COLOR_TYPE[godAttr[1].color])
			tx:enableOutline(COLOROUTLINE_TYPE[godAttr[1].color],1)
			tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			tx:setVisible(true)
			txs[#txs + 1] = {tx,diffHeight + 6}
			maxHeight = maxHeight + diffHeight + 6
			tx = self.attrSv:getChildByName('info_8_tx')
			tx:setVisible(false)
		elseif godId == 3 then
			local tx = self.attrSv:getChildByName('info_7_tx')
			if godAttr[1].type == 1 then
				godAttr[1].value = math.floor(godAttr[1].value/100)
			end
			tx:setString(godAttr[1].name..' +'..godAttr[1].value.."%")
			tx:setAnchorPoint(cc.p(0,0))
			tx:setColor(COLOR_TYPE[godAttr[1].color])
			tx:enableOutline(COLOROUTLINE_TYPE[godAttr[1].color],1)
			tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			tx:setVisible(true)
			txs[#txs + 1] = {tx,diffHeight + 3}
			maxHeight = maxHeight + diffHeight + 3

			tx = self.attrSv:getChildByName('info_8_tx')
			if godAttr[2].type == 1 then
				godAttr[2].value = math.floor(godAttr[2].value/100)
			end
			tx:setString(godAttr[2].name..' +'..godAttr[2].value.."%")
			tx:setAnchorPoint(cc.p(0,0))
			tx:setColor(COLOR_TYPE[godAttr[2].color])
			tx:enableOutline(COLOROUTLINE_TYPE[godAttr[2].color],1)
			tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			tx:setVisible(true)
			txs[#txs + 1] = {tx,diffHeight}
			maxHeight = maxHeight + diffHeight
		end
	else
		local tx = self.attrSv:getChildByName('info_7_tx')
		tx:setVisible(false)
		tx = self.attrSv:getChildByName('info_8_tx')
		tx:setVisible(false)
		local starPl = self.attrSv:getChildByName('star_pl')
		starPl:setVisible(false)
	end

	local gems = obj:getGems()
	local gemTab = {}
	for k,v in pairs(gems) do
		gemTab[#gemTab + 1] = v
	end
	local index = 1
	for i=1,4 do
		local gemBgImg = self.attrSv:getChildByName('gem_bg_'..i..'_img')
		if gemTab[i] then
			gemBgImg:setVisible(true)
			txs[#txs + 1] = {gemBgImg,47}
			maxHeight = maxHeight + 47
			local aImg = gemBgImg:getChildByName("gem_img")
			local nameTx1 = gemBgImg:getChildByName("name_tx")
			local lvTx = gemBgImg:getChildByName("lv_tx")
			aImg:loadTexture(gemTab[i]:getIcon())
			gemBgImg:loadTexture(gemTab[i]:getBgImg())
			lvTx:setString('Lv'..gemTab[i]:getLevel())
			local name = gemTab[i]:getName()
			local attrName = gemTab[i]:getAttrName()
			local attValue = gemTab[i]:getValue()
			nameTx1:setString(name .. '     '..attrName .. " +" .. attValue)
			nameTx1:setColor(gemTab[i]:getNameColor())
			nameTx1:enableOutline(gemTab[i]:getNameOutlineColor(),2)
			nameTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			gemTab[i]:setLightEffect(gemBgImg)
		else
			GlobalApi:setLightEffect(gemBgImg,0)
			gemBgImg:setVisible(false)
		end
	end
	if size.height < maxHeight then
		self.attrSv:setInnerContainerSize(cc.size(size.width,maxHeight))
	else
		maxHeight = size.height
		self.attrSv:setInnerContainerSize(cc.size(size.width,size.height))
	end
	local currHeight = 0
	for i,v in ipairs(txs) do
		currHeight = currHeight + v[2]
		v[1]:setPosition(getPos(currHeight))
	end
	nameTx:setString('Lv.'..obj:getLevel()..'  '..obj:getName())
	nameTx:setColor(obj:getNameColor())
	nameTx:enableOutline(obj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	for i=1,4 do
		local bgImg = self.goodsBgImg:getChildByName('gem_bg_'..i..'_img')
		local isOpen = GlobalApi:getOpenInfo('gem')
		local aImg = bgImg:getChildByName("award_img")
		local addImg = bgImg:getChildByName("add_img")
		local lvTx = bgImg:getChildByName("lv_tx")
		local maxNum = obj:getMaxGemNum()
		if isOpen then
			if maxNum >= i then
				local gems = obj:getGems()
				bgImg:setVisible(true)
				if gems and gems[i] then
					lvTx:setVisible(true)
					aImg:loadTexture(gems[i]:getIcon())
					bgImg:loadTexture(gems[i]:getBgImg())
					addImg:setVisible(false)
					lvTx:setString('Lv'..gems[i]:getLevel())
					gems[i]:setLightEffect(bgImg)
				else
					-- aImg:loadTexture('uires/ui/common/frame_bg_gem.png')
					bgImg:loadTexture('uires/ui/common/frame_bg_gem.png')
					addImg:setVisible(isCanEquipGem == true)
					lvTx:setVisible(false)
					if isCanEquipGem == true then
						aImg:loadTexture('uires/ui/common/frame_default2.png')
					else
						aImg:loadTexture('uires/ui/common/frame_bg_gem.png')
					end
					GlobalApi:setLightEffect(bgImg,0)
				end
				aImg:ignoreContentAdaptWithSize(true)
				bgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
						AudioMgr.PlayAudio(11)
					elseif eventType == ccui.TouchEventType.ended then
						if not gems[i] and isCanEquipGem == true then -- 已经有宝石了
							local gemSelectUI = ClassGemSelectUI.new(i, obj, function ()
								self:updateLeftEquipPanel(obj,ntype)
							end)
							gemSelectUI:showUI()
							self.runOnShow = false
						elseif not gems[i] then
							promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_HAD_NO_EQUIPED_GEM'), COLOR_TYPE.RED)
							-- promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_HAD_NO_EQUIPED_GEM'), COLOR_TYPE.RED)
						else
							local gemUpgradeUI = ClassGemUpgradeUI.new(gems[i]:getId(),i, obj, function ()
								-- self:updatePanel()
								self:updateLeftEquipPanel(obj,ntype)
							end)
							local desc,isOpen = GlobalApi:getGotoByModule('gem_merge',true)
							if desc then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')
									..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
								return
							end
							gemUpgradeUI:showUI()
							self.runOnShow = false
						end
					end
				end)
			else
				bgImg:setVisible(false)
			end
		else
			bgImg:loadTexture('uires/ui/common/frame_default2.png')
			aImg:loadTexture('uires/ui/common/frame_default2.png')
			addImg:setVisible(true)
			addImg:loadTexture("uires/ui/common/lock_3.png")
			addImg:ignoreContentAdaptWithSize(true)
			addImg:setScale(1.5)
		end
	end
end

function BagUI:updateLeftExclusivePanel(obj,ntype)
	self.rightBgImg:setVisible(false)
	self.rightBgImg1:setVisible(true)
	ClassItemCell:createExclusiveInfo(self.infoSv,23,obj)
end

function BagUI:updateLeftPanel(obj,ntype)
	local isCanEquipGem = false
	if ntype == ITEM_PAGE then
		self:updateLeftItemPanel(obj,ntype)
	elseif ntype == GEM_PAGE then
		self:updateLeftGemPanel(obj,ntype)
	elseif ntype == EQUIP_PAGE then
		self:updateLeftEquipPanel(obj,ntype)
	else
		self:updateLeftExclusivePanel(obj,ntype)
	end
	self.light:setVisible(true)
	self.light:setPosition(self.currObj[3]:getPosition())
end

function BagUI:updatePanel()
	if self.currObj then
		if not self.currObj[1] or self.currObj[1]:getObjType() == 'equip' or self.currObj[1]:getNum() <= 0 then
			self.currObj = nil
		end
	end
	self.currMax = 0
	self:updateBtn()
	self.timebg:setVisible(false)
	-- self.currObj = nil
	print("page is:"..self.page)
	if self.page == ITEM_PAGE then
		self:updateItem()
		self.cardSv:setContentSize(cc.size(440,450))
	elseif self.page == GEM_PAGE then
		self:updateGem()
		self.cardSv:setContentSize(cc.size(440,450))
	elseif self.page == EQUIP_PAGE then
		self:updateEquip()
		self.cardSv:setContentSize(cc.size(440,360))
	elseif self.page == EXCLUSIVE_PAGE then
		self:updateExclusive()
		self.cardSv:setContentSize(cc.size(440,450))
	end

	self:setAwardPosition()
	if self.page == EQUIP_PAGE then
		-- self:setEquipPosition()
		local tx = GlobalApi:getLocalStr('MAX_BAG_EQUIP')
		local valume = UserData:getUserObj():getEquipValume()
		local tx2 = '/'..valume
		if not self.equipRt then
			local richText = xx.RichText:create()
			richText:setContentSize(cc.size(230, 30))
			richText:setAlignment('right')
			local re1
			local re = xx.RichTextLabel:create(tx,21,COLOR_TYPE.ORANGE)
			re:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			if self.currMax >= valume then
				re1 = xx.RichTextLabel:create(self.currMax,21,COLOR_TYPE.RED)
				re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
			else
				re1 = xx.RichTextLabel:create(self.currMax,21,COLOR_TYPE.WHITE)
				re1:setStroke(COLOR_TYPE.BLACK, 1)
			end
			local re2 = xx.RichTextLabel:create(tx2,21,COLOR_TYPE.WHITE)
			re2:setStroke(COLOR_TYPE.BLACK, 1)
			richText:addElement(re)
			richText:addElement(re1)
			richText:addElement(re2)
			richText:setAnchorPoint(cc.p(1,0.5))
			richText:setPosition(cc.p(440,40))
			self.leftBgImg:addChild(richText)
			self.equipRt = {richText = richText,re = re,re1 = re1,re2 = re2}
		else
			self.equipRt.richText:setVisible(true)
			self.equipRt.re:setString(tx)
			self.equipRt.re2:setString(tx2)
			if self.currMax >= valume then
				self.equipRt.re1:setString(self.currMax)
				self.equipRt.re1:setColor(COLOR_TYPE.RED)
				self.equipRt.re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
			else
				self.equipRt.re1:setString(self.currMax)
				self.equipRt.re1:setColor(COLOR_TYPE.WHITE)
				self.equipRt.re1:setStroke(COLOR_TYPE.BLACK, 1)
			end
			self.equipRt.richText:format(true)
		end
	else
		if self.equipRt then
			self.equipRt.richText:setVisible(false)
		end
	end

	if self.oldH ~= self.currH then
		local size = self.cardSv:getContentSize()
		if self.currMax * (self.singleSize.width + self.intervalSize) > size.width then
			self.cardSv:setInnerContainerSize(cc.size(size.width,(math.floor((self.currMax - 1)/self.maxNum) + 1) * (self.singleSize.height + self.intervalSize)))
		else
			self.cardSv:setInnerContainerSize(size)
		end
	elseif self.page == EQUIP_PAGE and (self.currH or 0) < 4 then
		local size = self.cardSv:getContentSize()
		self.cardSv:setInnerContainerSize(size)
	elseif self.page ~= EQUIP_PAGE and (self.currH or 0) <= 4 then
		local size = self.cardSv:getContentSize()
		self.cardSv:setInnerContainerSize(size)
	end
	self.oldH = self.currH

	if self.currMax < self.oldMaxFrame then
		for i=self.currMax + 1,self.oldMaxFrame do
			local awardBgImg = self.cardSv:getChildByName('award_bg_img_'..i)
			if awardBgImg then
				-- awardBgImg:removeFromParent()
				awardBgImg:setVisible(false)
			end
		end
	end
	self.oldMaxFrame = self.currMax

	if self.currObj then
		self:updateLeftPanel(self.currObj[1],self.currObj[2])
	else
		self.light:setVisible(false)
	end
	-- print(self.currMax)
	if self.currMax <= 0 then
		self.noEquipImg:setVisible(true)
		self.mergeBtn:setVisible(false)
		self.infoPl1:setVisible(false)
		self.infoPl2:setVisible(false)

		self.sellBtn:setVisible(false)
		self.checkBtn:setVisible(false)
		self.rightBgImg1:setVisible(false)
		self.rightBgImg:setVisible(true)
		self.goodsBgImg:setVisible(false)
		if self.awardBgImg then
			self.awardBgImg:setVisible(false)
		end
	else
		self.noEquipImg:setVisible(false)
		self.goodsBgImg:setVisible(true)
		if self.awardBgImg then
			self.awardBgImg:setVisible(true)
		end
	end
	-- self.cardSv:jumpToTop()
	-- self.cardSv:scrollToTop(0.01, false)
	self.extendBtn:setVisible(self.page == EQUIP_PAGE)
end

function BagUI:registerBtnHandler()
	self.btns = {}
	local pageBtnList = self.bagImg:getChildByName("page_btn_list")
	pageBtnList:setScrollBarEnabled(false)
	for i,v in ipairs(PAGE_BTN_STYPE) do
		local btn = pageBtnList:getChildByName(v.."_btn")
		self.btns[i] = btn
		btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.currH = 0
				self.page = i
				self.currObj = nil
				self:updatePanel()
			end
		end)
	end
	self.extendBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local maxBag = tonumber(GlobalApi:getGlobalValue('maxEquipValume'))
			local valume = UserData:getUserObj():getEquipValume()
			if valume >= maxBag then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX'), COLOR_TYPE.RED)
				return
			end
			local cost = tonumber(GlobalApi:getGlobalValue('extendCashCost'))
			local richText = xx.RichText:create()
			richText:setContentSize(cc.size(416, 40))
			local tx = string.format(GlobalApi:getLocalStr("EXTEND_BAG_NEED"), cost)
			local re = xx.RichTextLabel:create(tx, 25, COLOR_TYPE.ORANGE)
			re:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			richText:addElement(re)
			richText:setPosition(cc.p(262,216))
			richText:setAnchorPoint(cc.p(0.5,0.5))

			local function callback()
				local args = {}
				MessageMgr:sendPost('extend','bag',json.encode(args),function (response)
					
					local code = response.code
					local data = response.data
					if code == 0 then
						local awards = data.awards
						GlobalApi:parseAwardData(awards)
						local costs = data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						UserData:getUserObj():setEquipValume(data.equip_valume)
						self:updatePanel()
						promptmgr:showSystenHint(GlobalApi:getLocalStr('EXTEND_BAG_SUCC'), COLOR_TYPE.GREEN)
					end
				end)
			end
			UserData:getUserObj():cost('cash',cost,callback,1,richText)
		end
	end)
	self.sellBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.currObj[2] then
				if self.currObj[2] == ITEM_PAGE or self.currObj[2] == GEM_PAGE then
					BagMgr:showSell(self.currObj)
				elseif self.currObj[2] == EQUIP_PAGE then
					local args = {
						type = 'equip',
						id = self.currObj[1]:getSId(),
						num = 1
					}
					local function sell()
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
								end
								-- local showTab = {}
								-- for i,v in ipairs(showAward) do
								-- 	showTab[#showTab + 1] = {GlobalApi:getLocalStr("CONGRATULATION_TO_GET")..v:getName()..'x'..v:getNum(),'GREEN'}
								-- end
								self.currObj = nil
								-- local winSize = cc.Director:getInstance():getVisibleSize()
								-- local sz = self.bagImg:getContentSize()
								-- local x, y = self.bagImg:convertToWorldSpace(cc.p(sz.width / 2, sz.height / 2))
								promptmgr:showAttributeUpdate(showWidgets)
								-- promptmgr:showAttributeUpdate(winSize.width/2,winSize.height/2, showTab)
								self:updatePanel()
							end
						end)
					end
					local godId = self.currObj[1]:getGodId()
					local quality = self.currObj[1]:getQuality()
					if godId > 0 then
						promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("SELL_GOD_EQUIP"), cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
							sell()
						end)
					elseif quality >= 5 then
						promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("SELL_ORANGE_EQUIP"), cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
							sell()
						end)
					else
						sell()
					end
				end
			end
		end
	end)
end

function BagUI:updateBtn()
	local nor = {
		['item'] = 'uires/ui/bgtext/tx_nor_dj.png',
		['gem'] = 'uires/ui/bgtext/tx_nor_bs.png',
		['equip'] = 'uires/ui/bgtext/tx_nor_zb.png',
		['exclusive'] = 'uires/ui/bgtext/txt_nor_exclusive.png',
	}
	local sel = {
		['item'] = 'uires/ui/bgtext/tx_sel_dj.png',
		['gem'] = 'uires/ui/bgtext/tx_sel_bs.png',
		['equip'] = 'uires/ui/bgtext/tx_sel_zb.png',
		['exclusive'] = 'uires/ui/bgtext/txt_sel_exclusive.png',
	}
	for i,v in ipairs(self.btns) do
		if self.page == i then
			v:loadTexture(sel[PAGE_BTN_STYPE[i]])
			v:setTouchEnabled(false)
		else
			v:setTouchEnabled(true)
			v:loadTexture(nor[PAGE_BTN_STYPE[i]])
		end
	end
	local newimg = self.btns[ITEM_PAGE]:getChildByName('new_img')
	if self.page == ITEM_PAGE then
		newimg:setVisible(false)
	else
		local isShow = UserData:getUserObj():getSignByType('bag_item')
		newimg:setVisible(isShow)
	end
end

function BagUI:init()
	self.intervalSize = 12.8
	self.singleSize = cc.size(94,94)
	local bgImg = self.root:getChildByName("bag_bg_img")
	self.bagImg = bgImg:getChildByName("bag_img")
	self:adaptUI(bgImg, self.bagImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.bagImg:setPosition(cc.p(winSize.width/2 + 25,winSize.height/2 - 45))

	local closeBtn = self.bagImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			BagMgr:hideBag()
		end
	end)
	local titleBgImg = self.bagImg:getChildByName("title_bg_img")
	local infoTx = titleBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr("BAG"))

	local rightBgImg = self.bagImg:getChildByName("right_bg_img")
	self.rightBgImg = rightBgImg
	local rightBgImg1 = self.bagImg:getChildByName("right_bg_img_1")
	self.rightBgImg1 = rightBgImg1
	local equipBtn = rightBgImg1:getChildByName('equip_btn')
	local infoTx = equipBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_14'))
	equipBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			GlobalApi:getGotoByModule('exclusive')
		end
	end)
	self.infoSv = self.rightBgImg1:getChildByName('info_sv')
	self.infoSv:setScrollBarEnabled(false)
	self.infoPl1 = rightBgImg:getChildByName("info_1_pl")
	self.infoPl2 = rightBgImg:getChildByName("info_2_pl")
	self.timebg = rightBgImg:getChildByName("time_bg")
	self.timetx = self.timebg:getChildByName('time_tx')
	self.cdlabel = Utils:createCDLabel(self.timetx,0,
		COLOR_TYPE.ORANGE,COLOR_TYPE.BLACK,
		CDTXTYPE.FRONT,
		GlobalApi:getLocalStr('REMAINDER_TIME'),
		COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.BLACK,20,function ()	
			self.timetx:removeAllChildren()
			if self.currObj and self.currObj[1]:getObjType() == 'limitmat'  then
				self.currObj = nil
				self:updatePanel()
			end
		end,3)
	self.goodsBgImg = rightBgImg:getChildByName("goods_bg_img")
	self.noEquipImg = rightBgImg:getChildByName("no_equip_img")
	self.attrSv = self.infoPl1:getChildByName('attr_sv')
	self.attrSv:setScrollBarEnabled(false)
	self.autoMergeBtn = rightBgImg:getChildByName("auto_merge_btn")
	self.autoMergeBtn:setVisible(false)
	local infoTx = self.autoMergeBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr("AUTO_UPGRADE"))
	self.sellBtn = rightBgImg:getChildByName("sell_btn")
	local infoTx = self.sellBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr("SELL_1"))
	self.mergeBtn = rightBgImg:getChildByName("merge_btn")
	self.rightBgImg = rightBgImg

	self.checkBtn = rightBgImg:getChildByName("check_btn")
	self.checkBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr("SELL_2"))

	local leftBgImg = self.bagImg:getChildByName("left_bg_img")
	self.extendBtn = leftBgImg:getChildByName("extend_btn")
	local infoTx = self.extendBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr("EXTEND_BAG"))
	self.cardSv = leftBgImg:getChildByName("card_sv")
	self.cardSv:setInertiaScrollEnabled(true)
	self.cardSv:setScrollBarEnabled(false)
	self.light = ccui.ImageView:create()
	self.light:setTouchEnabled(false)
	self.light:loadTexture('uires/ui/common/guang1.png')
	self.light:setAnchorPoint(0.5,0.5)
	self.cardSv:addChild(self.light)
	self.leftBgImg = leftBgImg

	self.currObj = nil
	self:registerBtnHandler()
	self:updatePanel()
end

return BagUI