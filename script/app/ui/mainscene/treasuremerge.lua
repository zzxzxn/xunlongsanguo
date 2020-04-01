local TreasureMergeUI = class("TreasureMergeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local defaultnor = 'uires/ui/common/title_btn_nor_1.png'
local defaultsel = 'uires/ui/common/title_btn_sel_1.png'
local dragonpieceid = 300004
local dragongemid = 300009
local maxlv = 5
function TreasureMergeUI:ctor(page)
	self.uiIndex = GAME_UI.UI_TREASURE_MERGE_PANEL
	self.page = page or 1
	self.maxLen = 0
	self.currMax = 0
	self.maxNum = 4
	self.oldMaxFrame = 0
	self.scalecoe = 0.85
	self.intervalSize = 9*self.scalecoe
	self.singleSize = cc.size(94*self.scalecoe,94*self.scalecoe)
	self.selecttab = {}
	self.selectlv = 0
	self.maxmergenum = 0
end

function TreasureMergeUI:init()
	local bgimg  = self.root:getChildByName("bg_img")
	local bgimg2  = bgimg:getChildByName("bg_img2")
	local bgimg1 = bgimg2:getChildByName("bg_img1")
	self:adaptUI(bgimg, bgimg2)

    local closeBtn = bgimg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideTreasureMerge()
		end
	end)
	self.pageBtns = {}
	self.pageBtnstx = {}
	for i = 1, 2 do
    	local pageBtn = bgimg1:getChildByName('fun_btn_'..i)
    	local infoTx = pageBtn:getChildByName('info_tx')
    	infoTx:setString(GlobalApi:getLocalStr('TREASURE_DESC_'..tostring(3+i)))
    	pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            if self.page ~= i then
	            	self.selectlv = 0
	            	self.selecttab = {}
	            	self.page = i
	            	self:updateBtnState()
	            	self:updatePanel()
	            	self:updateRightPanel()
	            end

	        end
	    end)
	    self.pageBtns[i] = pageBtn
	    self.pageBtnstx[i] = infoTx
    end

    self.swappl = bgimg1:getChildByName('swap_pl')
    local leftbg = self.swappl:getChildByName('left_bg_img')
    self.dragonSv = leftbg:getChildByName('sv')
    self.dragonSv:setScrollBarEnabled(false)
    self.dragonSv:setInertiaScrollEnabled(true)
    self.autobtn = leftbg:getChildByName('auto_btn')
    local autobtntx = self.autobtn:getChildByName('info_tx')
    autobtntx:setString(GlobalApi:getLocalStr('BTN_AUTO_FILTER'))

	self.autobtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			self:autoSelFunc()
		end
	end)

	local rightbg = self.swappl:getChildByName('right_bg_img')
	local pl = rightbg:getChildByName('pl')
	local numTx = pl:getChildByName('num_tx_2')
	local descTx1 = pl:getChildByName('desc_tx_1')
	self.descTx = pl:getChildByName('desc_tx_2')
	numTx:setString('1')
	descTx1:setString(GlobalApi:getLocalStr('DRAGON_MERGE_DESC_1'))
	self.numTx1 = pl:getChildByName('num_tx_1')
	local neibg = rightbg:getChildByName('nei_bg_1_img')
	local actionbg = neibg:getChildByName('lu_img')
	self.spine = GlobalApi:createSpineByName("fusion_lu", "spine/fusion/fusion_lu", 1)
	self.spine:setScale(0.8)
	local size = rightbg:getContentSize()
	self.spine:setPosition(cc.p(size.width/2,150))
	rightbg:addChild(self.spine,1)
	self.spine:registerSpineEventHandler(function (event)
		self.spine:setAnimation(0, 'idle01', false)
	end, sp.EventType.ANIMATION_COMPLETE)

    self.spine:registerSpineEventHandler(function (event)
        if event.animation == 'idle02' then
        	if self.showWidgets and #self.showWidgets > 0 then
        		promptmgr:showAttributeUpdate(self.showWidgets)
        		for i, v in ipairs(self.showWidgets) do
        			v:release()
        		end
        		self.showWidgets = nil
        	end
        	-- if self.tab and self.tab.x and self.tab.y and self.showTab and #self.showTab > 0 then
	        -- 	promptmgr:showAttributeUpdate(self.tab.x,self.tab.y, self.showTab)
	        -- 	self.tab, self.showTab = nil,nil
	        -- end
        end
    end, sp.EventType.ANIMATION_EVENT)
	self.spine:setAnimation(0, 'idle01', false)

	self.awardstab = {}
	for i=1,3 do
		local tab = {}
		tab.bg = rightbg:getChildByName('award_bg_'..i..'_img')
		tab.img = tab.bg:getChildByName('award_img')
		self.awardstab[i] = tab
	end
	self.swapbtn = rightbg:getChildByName('auto_btn')
	self.swapbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			self:senderSwapMsg()
		end
	end)
	local swapbtntx = self.swapbtn:getChildByName('info_tx')
	swapbtntx:setString(GlobalApi:getLocalStr('TREASURE_DESC_9'))
    self:updatePanel()
end

function TreasureMergeUI:updatePanel()
	self:updateBtnState()
	if self.page == 1 then
		self.maxmergenum = GlobalApi:getGlobalValue('dragonGemMergeNum')
		self.descTx:setString(GlobalApi:getLocalStr('DRAGON_MERGE_DESC_3'))
	elseif self.page == 2 then
		self.maxmergenum = GlobalApi:getGlobalValue('dragonGemSwapNum')
		self.descTx:setString(GlobalApi:getLocalStr('DRAGON_MERGE_DESC_2'))
	end
	self.numTx1:setString(self.maxmergenum)
	self:updateSwapPl()
end

function TreasureMergeUI:updateBtnState()
	for i=1, 2 do
    	if i == self.page then
    		self.pageBtns[i]:loadTextureNormal(defaultsel)
    		self.pageBtnstx[i]:setColor(COLOR_TYPE.PALE)
    		self.pageBtnstx[i]:enableOutline(COLOROUTLINE_TYPE.PALE,2)
    		self.pageBtnstx[i]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    	else
    		self.pageBtns[i]:loadTextureNormal(defaultnor)
    		self.pageBtnstx[i]:setColor(COLOR_TYPE.DARK)
    		self.pageBtnstx[i]:enableOutline(COLOROUTLINE_TYPE.DARK,2)
    		self.pageBtnstx[i]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    	end
    end
end

function TreasureMergeUI:updateSwapPl()
	for i=1,3 do
		if i <= tonumber(self.maxmergenum) then
			self.awardstab[i].bg:setVisible(true)
		else
			self.awardstab[i].bg:setVisible(false)
		end 
	end
	local dragongems =  BagData:getAllDragongems()
	self:updateDragonGems()
end

function TreasureMergeUI:mergeMsg(index)
	local dragonpiece =  {'material',tostring(dragonpieceid+index-1),1}
	local disobj1 = DisplayData:getDisplayObj(dragonpiece)
	if disobj1:getOwnNum() < disobj1:getMergeNum() then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_8'), COLOR_TYPE.RED)
		return
	end
	local args = {
  		type = 'dragon',
  		id = dragonpieceid+index-1,
  		num = disobj1:getMergeNum()
  	}
  	MessageMgr:sendPost('use','bag',json.encode(args),function (response)
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
            self:updatePanel()
		end
	end)
end

function TreasureMergeUI:senderSwapMsg()
	if #self.selecttab < tonumber(self.maxmergenum) then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_12'), COLOR_TYPE.RED)
		return
	end
	local tab = {}
	for i=1,#self.selecttab do
		table.insert(tab,self.selecttab[i]:getSId())
	end
	local isupgrade  = 0
	if self.maxmergenum == GlobalApi:getGlobalValue('dragonGemMergeNum')  then
		isupgrade = 1
	end
	local args = {
  		gids  = tab,
  		upgrade  = isupgrade
  	}
  	MessageMgr:sendPost('transfer_gem','treasure',json.encode(args),function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
			local awards = data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommonByText(awards)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self:gemFly()
			self.selecttab = {}
			self.selectlv = 0
            self:updatePanel()
            self:updateRightPanel()
		end
	end)
end

function TreasureMergeUI:updateDragonGems()
	local function getWH(i)
		local w,h
		local maxH = math.floor((self.maxDragongem - 1)/self.maxNum) + 1
		if maxH < 5 then
			maxH = 4.2
		end
		self.currH = maxH
		maxH = ((maxH < 5 )and 4.2) or maxH
		local h = maxH - math.floor((i - 1)/self.maxNum)
		local w = (i - 1)%self.maxNum + 1
		return w,h
	end
	local function getPos(w,h)
		local posX = w * (self.singleSize.width + self.intervalSize) - self.singleSize.width/2
		local posY = h * (self.singleSize.height + self.intervalSize) - self.singleSize.height/2 - self.intervalSize/2
		return cc.p(posX,posY)
	end
	local function sortFn(a, b)
	    local q1 = a:getQuality()
	    local q2 = b:getQuality()
	    local atttype1 = a:getAttType()
	    local atttype2 = b:getAttType()
	    if q1 == q2 then
	    	if atttype1 == atttype2 then
		        local attnum1 = a:getAttNum()
		        local attnum2 = b:getAttNum()
		        return attnum1 < attnum2
		    else
		    	return atttype1 < atttype2
		    end
	    else
	        return q1 < q2
	    end
	end

	local dragongems = BagData:getAllDragongems()
	self.showTab = {}
	for i=1,4 do
		local tab = dragongems[i]
		if tab then
            for k, v in pairs(tab) do
                table.insert(self.showTab, v)
            end
		end
	end
	table.sort( self.showTab, sortFn )
	self.maxDragongem = 0
	for i,v in pairs(self.showTab) do
		self.maxDragongem = self.maxDragongem + 1
		local awardBgImg = self.dragonSv:getChildByTag(self.maxDragongem + 100)
		local lvTx,chipImg,addImg
		if not awardBgImg then
			local gemTab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			awardBgImg = gemTab.awardBgImg
			lvTx = gemTab.lvTx
			chipImg = gemTab.chipImg
			addImg = gemTab.addImg
			self.dragonSv:addChild(awardBgImg,1,self.maxDragongem + 100)
			addImg:loadTexture('uires/ui/common/bg_gray50.png')
			addImg:setTouchEnabled(true)
			addImg:setScale9Enabled(true)
			addImg:setContentSize(cc.size(awardBgImg:getContentSize().width,awardBgImg:getContentSize().height))
			addImg:setScaleX(1)
			chipImg:loadTexture('uires/ui/common/select_checkbox1.png')
			chipImg:setScaleX(1)
		else
			awardBgImg:setVisible(true)
			lvTx = awardBgImg:getChildByName('lv_tx')
			chipImg = awardBgImg:getChildByName('chip_img')
			addImg = awardBgImg:getChildByName('add_img')
		end
		ClassItemCell:updateItem(awardBgImg, v, 2)
		awardBgImg:setScale(self.scalecoe)
		chipImg:setVisible(false)
		addImg:setVisible(false)
		lvTx:setVisible(true)
		lvTx:setString('+'..v:getAttNum().."%")

	    for i=1,#self.selecttab do
	    	if self.selecttab[i]:getSId() == v:getSId() then
	    		addImg:setVisible(true)
	    		chipImg:setVisible(true)
	    	end
	    end

		awardBgImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if self.maxmergenum == GlobalApi:getGlobalValue('dragonGemMergeNum') and v:getLevel() == maxlv then
	        		promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_11'), COLOR_TYPE.RED)
	        		return
	        	end
	        	if #self.selecttab < tonumber(self.maxmergenum) then
		        	if self.selectlv == 0 then
		        		table.insert(self.selecttab,v )
		        		self.selectlv = v:getLevel()
		        	else
		        		if self.selectlv ~= v:getLevel() then
		        			promptmgr:showMessageBox(GlobalApi:getLocalStr("TREASURE_DESC_7"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
	                            self.selecttab = {}
				        		table.insert(self.selecttab,v)
				        		self.selectlv = v:getLevel() 
				        		self:updatePanel()
	        					self:updateRightPanel()                         
	                        end,GlobalApi:getLocalStr("STR_OK2"),GlobalApi:getLocalStr("STR_CANCEL_1"))
		        		else
		        			table.insert(self.selecttab,v )
		        		end
		        	end
    				self:updatePanel()
	        		self:updateRightPanel()
		        else
		        	promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_10'), COLOR_TYPE.RED)
		       	end      		
	        end
	    end)

	   	addImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	addImg:setVisible(false)
	        	for i,vk in ipairs(self.selecttab) do
	        		if vk:getSId() ==  v:getSId() then
	        			table.remove(self.selecttab,i)
	        		end
	        	end
	        	if #self.selecttab == 0 then
	        		self.selectlv = 0
	        	end
	        	self:updateRightPanel()
	        	self:updatePanel()
	        end
	    end)
	end

	for i=1,self.maxDragongem do
		local awardBgImg = self.dragonSv:getChildByTag(i + 100)
		awardBgImg:setPosition(getPos(getWH(i)))
	end

	if self.oldH ~= self.currH then
	    local size = self.dragonSv:getContentSize()
	    if self.maxDragongem * (self.singleSize.height + self.intervalSize) > size.height then
	        self.dragonSv:setInnerContainerSize(cc.size(size.width,(math.floor((self.maxDragongem - 1)/self.maxNum) + 1) * (self.singleSize.height + self.intervalSize)))
	    else
	        self.dragonSv:setInnerContainerSize(size)
	    end
	end
 	self.oldH = self.currH

	if self.maxDragongem < self.oldMaxFrame then
		for i=self.maxDragongem + 1,self.oldMaxFrame do
			local awardBgImg = self.dragonSv:getChildByTag(i + 100)
			if awardBgImg then
				awardBgImg:setVisible(false)
			end
		end
	end
	self.oldMaxFrame = self.maxDragongem
end

function TreasureMergeUI:updateRightPanel()
	for i=1,3 do
		self.awardstab[i].img:removeChildByTag(9527)
	end
	for i=1,tonumber(self.maxmergenum) do
		if self.selecttab and self.selecttab[i] then
			local gemTab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.selecttab[i], self.awardstab[i].img)
			gemTab.lvTx:setString('+'..self.selecttab[i]:getAttNum().."%")
			gemTab.awardBgImg:setPosition(self.awardstab[i].img:getContentSize().width/2,self.awardstab[i].img:getContentSize().height/2)
			gemTab.awardBgImg:setTag(9527)
		end
	end
end

function TreasureMergeUI:autoSelFunc()
	local function ishavesel(sid)
		local ishave = false
		for i=1,#self.selecttab do
			if sid == self.selecttab[i]:getSId() then
				ishave = true
				break
			end
		end
		return ishave 
	end
	if self.selectlv == 0 then
		for i=1,maxlv do
			self.selecttab = {}
			self.selectlv = i
			for i,v in ipairs(self.showTab) do
				if v:getLevel() == self.selectlv and #self.selecttab < tonumber(self.maxmergenum) and not ishavesel(v:getSId()) then
					if self.maxmergenum == GlobalApi:getGlobalValue('dragonGemMergeNum') and v:getLevel() == maxlv then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_11'), COLOR_TYPE.RED)
						return
					end
					table.insert(self.selecttab,v)
				end
				if #self.selecttab == tonumber(self.maxmergenum) then
					self:updateRightPanel()
					self:updatePanel()
					return
				end
			end				
		end	
	else
		for i,v in ipairs(self.showTab) do
			if v:getLevel() == self.selectlv and #self.selecttab < tonumber(self.maxmergenum) and not ishavesel(v:getSId()) then
				if self.maxmergenum == GlobalApi:getGlobalValue('dragonGemMergeNum') and v:getLevel() == maxlv then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_11'), COLOR_TYPE.RED)
					return
				end
				table.insert(self.selecttab,v)
			end
			if #self.selecttab == tonumber(self.maxmergenum) then
				self:updateRightPanel()
				self:updatePanel()
				return
			end
		end				
	end
	if #self.selecttab < tonumber(self.maxmergenum) then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('TREASURE_DESC_12'), COLOR_TYPE.RED)
		self:updatePanel()
		self:updateRightPanel()
	end
end

function TreasureMergeUI:gemFly()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg2 = bgImg:getChildByName("bg_img2")
	local fusionImg = bgImg2:getChildByName("bg_img1")
	local swappl = fusionImg:getChildByName("swap_pl")
	local rightBgImg = swappl:getChildByName("right_bg_img")
	local tab = {}
	for i,v in pairs(self.selecttab) do
		tab[#tab + 1] = v
	end
	local index = 0
	local function flyEnd()
		index = index + 1
		if index >= #tab then
			self.spine:setAnimation(0, 'idle02', false)
		end
	end
    local diffPos = 
    {
	    {x = 182,y = 75},
	    {x = -182,y = 75},
	    {x = 0,y = -20},
	}
	local endPos = cc.p(249.5,273)
	for i,v in ipairs(self.awardstab) do
		local gem = tab[i]
		if gem then
			local awardImg = ccui.ImageView:create(gem:getIcon())
			local size = v.bg:getContentSize()
			-- local pos = v.awardImg:convertToWorldSpace(cc.p(size.width/2 - 25,size.height/2 - 25))
			local pos = cc.p(v.bg:getPositionX(),v.bg:getPositionY())
			awardImg:setPosition(pos)
			rightBgImg:addChild(awardImg,999)
			local bezierTo = cc.BezierTo:create(0.5, {pos,cc.p(pos.x + diffPos[i].x,pos.y + diffPos[i].y),endPos})
            AudioMgr.playEffect("media/effect/equip_fusion.mp3", false)
			awardImg:runAction(cc.ScaleTo:create(0.5,0.01))
			awardImg:runAction(cc.Sequence:create(bezierTo,cc.CallFunc:create(function()
				awardImg:removeFromParent()
				flyEnd()
            end)))
		end
	end
end

return TreasureMergeUI