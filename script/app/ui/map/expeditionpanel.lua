local ExpeditionUI = class("ExpeditionUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

function ExpeditionUI:ctor(id,page,raidaward,needNum)
	self.uiIndex = GAME_UI.UI_EXPEDITION
	local data = MapData.data[id]
	local star = data:getStar(1)
	if star <= 0 then
		self.page = 1
	else
		self.page = page or MapMgr.locatePage or 1
	end
	self.id = id
	self.rt1 = nil
	self.rt2 = nil
	self.maxCellCount = 0
	self.eliteOpend = GlobalApi:getOpenInfo("elite")
	self.spineAni = {}
	self.raidaward = raidaward
	self.needNum = needNum
	self.isRaidaward = false
end

function ExpeditionUI:onShow()
	local cityData = MapData.data[self.id]
	local newStar = cityData:getStar(self.page)
	if self.page == 1 and self.id + 1 <= MapData.maxProgress and self.currStar <= 0 and newStar > 0 then
		MapData.currProgress = self.id + 1
		MapData.patrol = GlobalData:getServerTime()
	end
	self:updatePanel()
end

function ExpeditionUI:OnFighting()
	-- 创建战斗场景
	local cityData = MapData.data[self.id]
	local limit = cityData:getLimits(self.page)
	local times = cityData:getTimes(self.page)
	local currStar = cityData:getStar(self.page) 
	if times >= limit then
		-- promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NO_TIMES'), MESSAGE_BOX_TYPE.MB_OK)
		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
		return
	end
	local needFood = cityData:getFood(self.page)
	local food = UserData:getUserObj():getFood()
	if currStar <= 0 then
		needFood = 0
	end
	if needFood > food then
        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY_FOOD"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("food")
        end)
		return
	end
	local id = self.id
    if id == 0 then
        MessageMgr:sendPost("unlock_maincity", "battle", "{}", function (jsonObj)
            if jsonObj.code == 0 then
                MapData:setCurrProgress(0)
            end
        end)
    else
        local page = self.page
        MapMgr.locatePage = page
        MapMgr:playBattle(BATTLE_TYPE.NORMAL, id, page,function()
            MapMgr:showMainScene(2,id,function()
                MapMgr:showExpeditionPanel(id,page)
            end)
        end)
    end
end

function ExpeditionUI:OnRaids(times,num)
    if BagData:getEquipFull() and self.page == 1 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
        return
    end
	local cityData = MapData.data[self.id]
	local needFood = cityData:getFood(self.page)
	local food = UserData:getUserObj():getFood()
	local maxTimes = math.floor(food/needFood)
	if times > maxTimes then
		times = maxTimes
	end
	if times <= 0 then
        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY_FOOD"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("food")
        end)
		return
	end
	local args = 
	{
		type = self.page,
		id = self.id,
		time = times,
	}
	MessageMgr:sendPost('auto_fight','battle',json.encode(args),function (response)
		
		local code = response.code
		local data = response.data
		if code == 0 then
            local lastLv = UserData:getUserObj():getLv()
			cityData:addTimes(self.page,times)
			local awardsNum
			if self.raidaward then
				awardsNum = self.raidaward:getNum()
			end
			local awards = data.awards
			for k,v in pairs(awards) do
				GlobalApi:parseAwardData(v)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local id,page = self.id,self.page
			MapMgr:showRainsPanel(awards,id,page,num,self.raidaward,awardsNum,self.needNum,self.isRaidaward)
			self:updatePanel()
            local nowLv = UserData:getUserObj():getLv()
            GlobalApi:showKingLvUp(lastLv,nowLv)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MAP_ERROR'), COLOR_TYPE.RED)
		end
	end)
end

function ExpeditionUI:getSpine(url)
	-- if self.page == 1 then
		if self.spineAni[self.page] then
			self.spineAni[self.page]:setVisible(true)
		else
		    self.spineAni[self.page] = GlobalApi:createLittleLossyAniByName(url..'_display')
			self.spineAni[self.page]:setPosition(cc.p(170,200))
			self.expeditionImg:addChild(self.spineAni[self.page])
		    -- self.spineAni:setAnimation(0, 'idle', true)
		    self.spineAni[self.page]:getAnimation():play('idle', -1, 1)
		end
		if self.spineAni[self.page%2 + 1] then
	    	self.spineAni[self.page%2 + 1]:setVisible(false)
	    end
	-- elseif self.page == 2 then
	-- 	if self.spineAni1 then
	-- 		self.spineAni1:setVisible(true)
	-- 	else
	-- 	    self.spineAni1 = GlobalApi:createAniByName(url)
	-- 		self.spineAni1:setPosition(cc.p(170,200))
	-- 		self.expeditionImg:addChild(self.spineAni1)
	-- 	    self.spineAni1:getAnimation():play('idle', -1, 1)

	-- 	end
	-- 	if self.spineAni then
	--     	self.spineAni:setVisible(false)
	--     end
	-- end
end

function ExpeditionUI:updateAward()
	local cityData = MapData.data[self.id]
	local awardsTab = cityData:getDrop(self.page)
	local index = 0
	for i=1,10 do
		local str = 'award'..i
    	if awardsTab[str] and awardsTab[str][1] then
    		index = index + 1
    		local awardBgImg = self.awardSv:getChildByTag(1000 + index)
    		if not awardBgImg then
			    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			    awardBgImg = tab.awardBgImg
			    self.awardSv:addChild(awardBgImg,1,1000 + index)
			    awardBgImg:setAnchorPoint(cc.p(0,0.5))
			    awardBgImg:setPosition(cc.p((index - 1)*110 + 10,50))
			    awardBgImg:setTouchEnabled(true)
			end
	    	local award = DisplayData:getDisplayObj(awardsTab[str][1])
	    	ClassItemCell:updateItem(awardBgImg, award, 2)
	    	local stype = award:getCategory()
	    	if self.raidaward and stype == self.raidaward:getCategory() and award:getId() == self.raidaward:getId() then
	    		self.isRaidaward = true
	    	end
	    	local lvTx = awardBgImg:getChildByName('lv_tx')
	    	lvTx:setVisible(true)
	    	if stype == 'equip' then
	    		lvTx:setString('Lv.'..award:getLevel())
	    	else
	    		lvTx:setString('x'..award:getNum())
	    	end
	    	awardBgImg:setVisible(true)
	    	awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(award,false)
		        end
		    end)
	    end
	end
	if index < self.maxCellCount then
		for i=index + 1,self.maxCellCount do
			local awardBgImg = self.awardSv:getChildByTag(i + 1000)
			if awardBgImg then
				awardBgImg:removeFromParent()
			end
		end
	end
	self.maxCellCount = index

    local size = self.awardSv:getContentSize()
    if index * 110 + 10 > size.width then
        self.awardSv:setInnerContainerSize(cc.size(index* 110,size.height))
    else
        self.awardSv:setInnerContainerSize(size)
    end
end

function ExpeditionUI:updatePanel()
	local cityData = MapData.data[self.id]
	local keyArr = string.split(cityData:getName() , '.')
	-- self.cityNameTx:setString(keyArr[#keyArr])
	self.cityNameTx:setString(cityData:getName())
	
	local star = cityData:getStar(self.page)
	for i,v in ipairs(self.star) do
		v:setVisible(star>=i)
	end
    self.isRaidaward = false
    local first = 0
    if star >= 3 then
    	self.raidsBtn:setVisible(true)
		self.raidsTenBtn:setVisible(true)
		local richText = self.expeditionImg:getChildByTag(9997)
		if richText then
			richText:setVisible(false)
		end
    else
    	self.raidsBtn:setVisible(false)
		self.raidsTenBtn:setVisible(false)
    	if star <= 0 then
	    	first = 1
    	end

	    local richText = self.expeditionImg:getChildByTag(9997)
	    if not richText then
			richText = xx.RichText:create()
			richText:setAlignment('middle')
			richText:setContentSize(cc.size(300, 30))
			local tx1 = GlobalApi:getLocalStr('TOWER_AUTOFIGHT_DESC')
			local re1 = xx.RichTextLabel:create(tx1, 30, COLOR_TYPE.PALE)
			re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
			re1:setFont('font/gamefont.ttf')
			richText:addElement(re1)
			richText:setAnchorPoint(cc.p(0.5,0.5))
			richText:setPosition(cc.p(166,55))
			self.expeditionImg:addChild(richText,1,9997)
		end
		richText:setVisible(true)
    end

    local infoTx1 = self.normalBtn:getChildByName('info_tx')
    local infoTx2 = self.eliteBtn:getChildByName('info_tx')
    if self.page == 1 then
    	self.addBtn:setVisible(false)
    	self.normalBtn:setTouchEnabled(false)
    	self.normalBtn:loadTexture('uires/ui/common/title_btn_sel_3.png')
    	self.normalBtn:ignoreContentAdaptWithSize(false)
    	self.eliteBtn:setTouchEnabled(true)
    	if star > 0  and self.eliteOpend then
    		self.eliteBtn:setBright(true)
    		self.eliteBtn:loadTexture('uires/ui/common/title_btn_nor_3.png')
    		self.eliteBtn:ignoreContentAdaptWithSize(false)
    		self.quanImg:setVisible(false)
    	else
    		self.eliteBtn:setTouchEnabled(false)
    		self.eliteBtn:setBright(false)
    		self.quanImg:setVisible(true)
    	end
		infoTx1:setColor(COLOR_TYPE.PALE)
		infoTx1:enableOutline(COLOROUTLINE_TYPE.PALE,2)
		infoTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		infoTx2:setColor(COLOR_TYPE.DARK)
		infoTx2:enableOutline(COLOROUTLINE_TYPE.DARK,2)
		infoTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

		self.pl1:setVisible(true)
		self.pl2:setVisible(false)
		local equipTab = {}
		local unlockAwards = cityData:getPatrolEquip()
	    for k,v in pairs(unlockAwards) do
	    	equipTab[#equipTab + 1] = v
	    end
	    if #equipTab > 0 then
	    	self.noEquipImg:setVisible(false)
		    for i=1,2 do
		    	if equipTab[i] then
			    	local award = DisplayData:getDisplayObj(equipTab[i])
			    	ClassItemCell:updateItem(self.showAward1[i], award, 1)
			    	local obj = award:getObj()
			    	if obj then
			    		self.showAward1[i].nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..obj:getType()))
			    		self.showAward1[i].awardBgImg:setTouchEnabled(true)
			    		self.showAward1[i].awardBgImg:addTouchEventListener(function (sender, eventType)
					        if eventType == ccui.TouchEventType.began then
			                    AudioMgr.PlayAudio(11)
			                elseif eventType == ccui.TouchEventType.ended then
			                    GetWayMgr:showGetwayUI(award,false)
			                end
					    end)
			    	else
			    		self.showAward1[i].nameTx:setString('')
			    	end
			    	local stype = award:getCategory()
			    	self.showAward1[i].lvTx:setVisible(true)
			    	if stype == 'equip' then
			    		self.showAward1[i].lvTx:setString('Lv.'..award:getLevel())
			    	else
			    		self.showAward1[i].lvTx:setString('x'..award:getLevel())
			    	end
			    	self.showAward1[i].awardBgImg1:setVisible(true)
			    else
			    	self.showAward1[i].awardBgImg1:setVisible(false)
			    end
		    end
		else
			self.noEquipImg:setVisible(true)
			for i=1,2 do
				self.showAward1[i].awardBgImg1:setVisible(false)
			end
		end
	    self.titleTx:setString(GlobalApi:getLocalStr('FIGHTING_UNLOCK'))
    elseif self.page == 2 then
    	self.addBtn:setVisible(true)
    	self.eliteBtn:setTouchEnabled(false)
    	self.eliteBtn:loadTexture('uires/ui/common/title_btn_sel_3.png')
    	self.eliteBtn:ignoreContentAdaptWithSize(false)
    	self.normalBtn:setTouchEnabled(true)
    	self.normalBtn:loadTexture('uires/ui/common/title_btn_nor_3.png')
    	self.normalBtn:ignoreContentAdaptWithSize(false)
    	self.quanImg:setVisible(false)
		infoTx2:setColor(COLOR_TYPE.PALE)
		infoTx2:enableOutline(COLOROUTLINE_TYPE.PALE,2)
		infoTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		infoTx1:setColor(COLOR_TYPE.DARK)
		infoTx1:enableOutline(COLOROUTLINE_TYPE.DARK,2)
		infoTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		self.pl1:setVisible(false)
		self.pl2:setVisible(true)
		local awards = cityData:getFirst(self.page)
		-- if first == 1 then
		-- self.noEquipImg:setVisible(false)
		for i=1,4 do
			if awards[i] then
				local award = DisplayData:getDisplayObj(awards[i])
				ClassItemCell:updateItem(self.showAward2[i], award, 1)
		    	self.showAward2[i].awardBgImg:setVisible(true)
		    	local stype = award:getCategory()
		    	self.showAward2[i].lvTx:setVisible(true)
		    	if stype == 'equip' then
		    		self.showAward2[i].lvTx:setString('Lv.'..award:getLevel())
		    	else
		    		self.showAward2[i].lvTx:setString('x'..award:getNum())
		    	end
		    	self.showAward2[i].awardBgImg:addTouchEventListener(function (sender, eventType)
			        if eventType == ccui.TouchEventType.began then
	                    AudioMgr.PlayAudio(11)
	                elseif eventType == ccui.TouchEventType.ended then
	                    GetWayMgr:showGetwayUI(award,false)
	                end
			    end)
			    if first == 1 then
			    	self.showAward2[i].addImg:setVisible(false)
			    else
			    	self.showAward2[i].addImg:loadTexture('uires/ui/common/had_get.png')
					self.showAward2[i].addImg:setVisible(true)
			    end
		    else
		    	self.showAward2[i].awardBgImg:setVisible(false)
		    end
		end
		self.noEquipImg:setVisible(#awards <= 0)
		self.titleTx:setString(GlobalApi:getLocalStr('FIRST_BLOOD'))
    end

	local monsterGroup = cityData:getFormation(self.page)
	local monsterConf = GameData:getConfData("formation")[monsterGroup]

	--使用程序计算的战力,不使用配置表
	local fightforce = 0
    for i=1,9 do
        local posId = monsterConf["pos"..i]
        if posId and posId > 0 then
            fightforce = fightforce + RoleData:CalMonsterFightForce(posId)
        end
    end

	self.forceLabel:setString(fightforce)
	local monsterId = monsterConf['pos'..monsterConf.boss]
	local monsterObj = GameData:getConfData("monster")[monsterId]
    self:getSpine(monsterObj.url)

	local limit = cityData:getLimits(self.page)
	local times = cityData:getTimes(self.page)
	local tx1 = GlobalApi:getLocalStr('NEED_FOOD_1')
	local tx2 = cityData:getFood(self.page)
	local tx3 = GlobalApi:getLocalStr('FREE_TIMES_1')
	local tx4 = (limit-times)..'/'..limit
    if not self.rt1 then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(190, 30))
		local re1 = xx.RichTextLabel:create(tx1, 21, COLOR_TYPE.ORANGE)
		local re2 = xx.RichTextLabel:create(tx2, 21, COLOR_TYPE.WHITE)
		re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		re2:setStroke(COLOR_TYPE.BLACK, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:setAnchorPoint(cc.p(0,0.5))
		richText:setPosition(cc.p(460,65))
		self.expeditionImg:addChild(richText)
		self.rt1 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.rt1.re1:setString(tx1)
		self.rt1.re2:setString(tx2)
		self.rt1.richText:format(true)
    end
    local star = cityData:getStar(self.page)
    self.rt1.richText:setVisible(star > 0)
    if not self.rt2 then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(190, 30))
		local re1 = xx.RichTextLabel:create(tx3, 21, COLOR_TYPE.ORANGE)
		local re2 = xx.RichTextLabel:create(tx4, 21, COLOR_TYPE.WHITE)
		re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		re2:setStroke(COLOR_TYPE.BLACK, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:setAnchorPoint(cc.p(0,0.5))
		richText:setPosition(cc.p(460,35))
		self.expeditionImg:addChild(richText)
		self.rt2 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.rt2.re1:setString(tx3)
		self.rt2.re2:setString(tx4)
		self.rt2.richText:format(true)
    end
    self.currStar = cityData:getStar(1)

    self:updateAward()

    if self.id <= 1 then
    	self.leftBtn:setBright(false)
    	self.leftBtn:setTouchEnabled(false)
    else
    	self.leftBtn:setBright(true)
    	self.leftBtn:setTouchEnabled(true)
    end
    local fightedId = MapData:getFightedCityId()
    if self.page == 1 then
	    if self.id > fightedId or self.id >= #MapData.data or self.id >= MapData.maxProgress then
	    	self.rightBtn:setBright(false)
	    	self.rightBtn:setTouchEnabled(false)
	    else
		    local cityData1 = MapData.data[tonumber(self.id + 1)]
		    local level = UserData:getUserObj():getLv()
		    local needLevel = cityData1:getLevel()
		    if cityData1 and cityData1:getStar(1) <= 0 and level < needLevel then
		    	self.rightBtn:setBright(false)
		    	self.rightBtn:setTouchEnabled(false)
		    else
		    	self.rightBtn:setBright(true)
		    	self.rightBtn:setTouchEnabled(true)
		    end
	    end
	else
	    if self.id >= fightedId or self.id >= #MapData.data then
	    	self.rightBtn:setBright(false)
	    	self.rightBtn:setTouchEnabled(false)
	    else
	    	self.rightBtn:setBright(true)
	    	self.rightBtn:setTouchEnabled(true)
	    end
	end
	local index = self.id%5 + 2
	self.roleBgImg:loadTexture('uires/ui/guard/guard_frame_'..index..'.png')
end

function ExpeditionUI:init()
	local bgImg = self.root:getChildByName("expedition_bg_img")
	self.expeditionImg = bgImg:getChildByName("expedition_img")
    self:adaptUI(bgImg, self.expeditionImg)
	local closeBtn = self.expeditionImg:getChildByName("close_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.expeditionImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
	local titleImg = self.expeditionImg:getChildByName("title_img")
	self.cityNameTx = titleImg:getChildByName("city_name_tx")

	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideExpeditionPanel()
        end
    end)

    self.normalBtn = self.expeditionImg:getChildByName("normal_btn")
    local infoTx = self.normalBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('NORMAL'))
    self.eliteBtn = self.expeditionImg:getChildByName("elite_btn")
    infoTx = self.eliteBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('ELITE'))
    self.quanImg = self.eliteBtn:getChildByName("quan_img")
    self.fightingBtn = self.expeditionImg:getChildByName("fighting_btn")
    local infoTx = self.fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('BEGIN_FIGHTING'))
    self.normalBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self.page = 1
        	self:updatePanel()
        end
    end)
    self.eliteBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local cityData = MapData.data[self.id]
        	if cityData:getStar(1) > 0 then
	        	self.page = 2
	        	self:updatePanel()
	        else
	        	promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_FIGHT_NORMAL_FIRST'), COLOR_TYPE.RED)
	        end
        end
    end)
    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if self.page == 1 then
		        if BagData:getEquipFull() then
		            promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
		            return
		        end
		    else
		    	if self.id ~= 1 then
		    		local star = MapData.data[self.id - 1]:getStar(2)
		    		if not star or star <= 0 then
		    			promptmgr:showSystenHint(GlobalApi:getLocalStr('ELITE_DESC_1'), COLOR_TYPE.RED)
		    			return
		    		end
		    	end
		    end
            self:OnFighting()
        end
    end)

    self.raidsBtn = self.expeditionImg:getChildByName("raids_btn")
    self.raidsTenBtn = self.expeditionImg:getChildByName("raids_ten_btn")
    infoTx = self.raidsBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('RAIDS'))
	infoTx = self.raidsTenBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('RAIDS_TEN'))
    self.raidsBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local cityData = MapData.data[self.id]
			local star = cityData:getStar(self.page)
			local times = 1
			local maxTimes = cityData:getLimits(self.page) - cityData:getTimes(self.page)
			if maxTimes < times then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
				return
			end
			if star < 3 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_THREE_STAR'), COLOR_TYPE.RED)
				return
			end
        	self:OnRaids(times,1)
        end
    end)
    self.raidsTenBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local isOpen, isInConf, cityId, openLevel = GlobalApi:getOpenInfo("auto_progress_ten")
	        local autoProgressTenVip = tonumber(GlobalApi:getGlobalValue("autoProgressTenVip"))
	        local vip = UserData:getUserObj():getVip()
	        if isOpen or autoProgressTenVip <= vip then
				local cityData = MapData.data[self.id]
				local star = cityData:getStar(self.page)
				local times = 10
				local maxTimes = cityData:getLimits(self.page) - cityData:getTimes(self.page)
				if maxTimes <= 0 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
					return
				end
				if maxTimes < times then
					times = maxTimes
				end
				if star < 3 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_THREE_STAR'), COLOR_TYPE.RED)
					return
				end
	        	self:OnRaids(times,10)
	        else
	        	promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("OPEN_AFTER_LEVEL_OR_VIP"), openLevel, autoProgressTenVip), COLOR_TYPE.RED)
	        end
        end
    end)

    local leftImg = self.expeditionImg:getChildByName('left_bg_img')
    local roleBgImg = leftImg:getChildByName('role_bg_img')
    self.roleBgImg = roleBgImg
    local rightImg = self.expeditionImg:getChildByName('right_bg_img')
    local canGetBgImg = rightImg:getChildByName('can_get_bg_img')
    local titleImg = canGetBgImg:getChildByName("title_bg_img")
    local infoTx = titleImg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('MAYBE_GET'))
    local canUnlockBgImg = rightImg:getChildByName('can_unlock_bg_img')
    -- local titleImg = canUnlockBgImg:getChildByName("title_bg_img")
    self.titleTx = canUnlockBgImg:getChildByName('info_tx')
    self.titleTx:setString(GlobalApi:getLocalStr('FIGHTING_UNLOCK'))

    local talkImg = self.expeditionImg:getChildByName("talk_img")
    -- leftImg:loadTexture('uires/ui/guard/guard_frame_5.png')
    talkImg:setLocalZOrder(1000)
    local descTx = talkImg:getChildByName("desc_tx")
    descTx:setString(GlobalApi:getLocalStr('CITY_CELL_TALK_2'))
    talkImg:setOpacity(255)
    talkImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
    	cc.DelayTime:create(1), 
    	cc.FadeIn:create(0.5),
    	cc.DelayTime:create(3), 
    	cc.FadeOut:create(0.5))))
    local zhanBgImg = leftImg:getChildByName('zhan_bg_img')
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    forceLabel:setString('')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)

    self.star = {}
    for i=1,3 do
    	local str = 'star_'..i..'_img'
    	local starBgImg = self.expeditionImg:getChildByName(str)
    	local starImg = starBgImg:getChildByName('star_img')
    	self.star[i] = starImg
    end

    self.showAward = {}
    -- for i=1,5 do
    -- 	local str = 'award_bg_'..i..'_img'
    -- 	local awardBgImg = canGetBgImg:getChildByName(str)
    -- 	local awardImg = awardBgImg:getChildByName('award_img')
    -- 	local lvTx = awardBgImg:getChildByName('lv_tx')
    -- 	self.showAward[i] = {awardImg = awardImg,awardBgImg = awardBgImg,lvTx = lvTx}
    -- end
    self.awardSv = canGetBgImg:getChildByName('award_sv')
    self.awardSv:setScrollBarEnabled(false)

    self.noEquipImg = canUnlockBgImg:getChildByName('no_equip_img')
    self.showAward1 = {}
    self.pl1 = canUnlockBgImg:getChildByName('pl1')
    for i=1,2 do
    	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	local str = 'award_bg_'..i..'_img'
    	local awardBgImg1 = self.pl1:getChildByName(str)
    	local nameTx = awardBgImg1:getChildByName('name_tx')
    	tab.awardBgImg1 = awardBgImg1
    	tab.nameTx = nameTx
    	tab.awardBgImg:setPosition(cc.p(64.5,54))
    	awardBgImg1:addChild(tab.awardBgImg)
    	self.showAward1[i] = tab
    end

    self.showAward2 = {}
    self.pl2 = canUnlockBgImg:getChildByName('pl2')
    local pos = {cc.p(67,74),cc.p(181,74),cc.p(295,74),cc.p(409,74)}
    for i=1,4 do
    	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	tab.awardBgImg:setPosition(pos[i])
    	self.pl2:addChild(tab.awardBgImg)
    	self.showAward2[i] = tab
    end

    self.leftBtn = bgImg:getChildByName('left_btn')
    self.rightBtn = bgImg:getChildByName('right_btn')
    self.leftBtn:setPosition(cc.p(0,winSize.height/2))
    self.rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    local leftBtn,rightBtn = self.leftBtn,self.rightBtn
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)
    self.leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if self.id == 1 then
        		return
        	end
        	if self.spineAni[self.page] then
        		self.spineAni[self.page]:removeFromParent()
        		self.spineAni[self.page] = nil
        	end
            self.id = self.id - 1
            self:updatePanel()
        end
    end)
    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local fightedId = MapData:getFightedCityId()
        	local cityData = MapData.data[self.id + 1]
        	local pformation = cityData:getPformation1()
        	if self.id >= fightedId and MapData.cityProcess < #pformation then
        		MapMgr:hideExpeditionPanel()
        		local id = self.id
        		MapMgr:showExpeditionCellPanel(id + 1)
        		return
        	end
        	if self.id >= #MapData.data then
        		return
        	end
        	if self.spineAni[self.page] then
        		self.spineAni[self.page]:removeFromParent()
        		self.spineAni[self.page] = nil
        	end
            self.id = self.id + 1
            self:updatePanel()
        end
    end)

    self.addBtn = self.expeditionImg:getChildByName("add_btn")
    self.addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local eliteReset = MapData:getEliteReset()
        	local buyTimes = 0
        	if eliteReset and eliteReset[tostring(self.id)] then
        		buyTimes = eliteReset[tostring(self.id)]
        	end
        	local vip = UserData:getUserObj():getVip()
        	local vipConf = GameData:getConfData("vip")
        	local canResetTimes = vipConf[tostring(vip)].eliteReset
        	local cityData = MapData.data[self.id]
        	local limit = cityData:getLimits(self.page)
			local times = cityData:getTimes(self.page)
        	if times < limit then -- 次数满的，不用买
        		promptmgr:showSystenHint(GlobalApi:getLocalStr("NO_NEED_BUY_TIMES"), COLOR_TYPE.RED)
        	elseif buyTimes >= canResetTimes then -- 重置次数已满
        		if vipConf[tostring(vip+1)] == nil then -- vip已经达到最大值
        			promptmgr:showSystenHint(GlobalApi:getLocalStr("RESET_TIMES_REACH_MAX"), COLOR_TYPE.RED)
        		else
        			local i = 1
        			local flag = false
        			while vipConf[tostring(vip+i)] do
        				 if vipConf[tostring(vip+i)].eliteReset > buyTimes then
        				 	flag = true
        				 	promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("VIP_LOW_CANNOT_RESET"), vip+i), COLOR_TYPE.RED)
        				 	break
        				 end
        				 i = i + 1
        			end
        			if not flag then
        				promptmgr:showSystenHint(GlobalApi:getLocalStr("RESET_TIMES_REACH_MAX"), COLOR_TYPE.RED)
        			end
        		end
        	else
        		local cash = UserData:getUserObj():getCash()
        		local buyConf = GameData:getConfData("buy")
        		local needCash = buyConf[buyTimes+1].eliteReset
        		if cash < needCash then
        			promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
        		else
        			promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("TOWER_DESC_4"), needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
        				local args = {
        					id = self.id
        				}
        				MessageMgr:sendPost("reset_elite", "battle", json.encode(args), function (response)
							if response.code == 0 then
								MapData:addEliteReset(self.id)
								local cityData2 = MapData.data[self.id]
								cityData2:setTimes(0, self.page)
								if response.data.costs then
									GlobalApi:parseAwardData(response.data.costs)
								end
								self:updatePanel()
								promptmgr:showSystenHint(GlobalApi:getLocalStr("ACTIVITY_ROULETTE_RESET_TIPS"), COLOR_TYPE.GREEN)
							end
        				end)
					end)
        		end
        	end
        end
    end)

    self:updatePanel()
end

return ExpeditionUI