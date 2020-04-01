local RaidsUI = class("RaidsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RaidsUI:ctor(awards,id,page,times,raidaward,oldNum,needNum,showGet)
	self.uiIndex = GAME_UI.UI_RAIDSUI
	self.awards = awards
	self.isEnd = false
	self.id = id
	self.page = page
	self.oldNum = 0
	self.raidsTimes = times
	self.raidaward = raidaward
	self.oldItemNum = oldNum
	self.getNum = 0
	self.needNum = needNum or 0
	self.showGet = showGet
end

function RaidsUI:getPos(i,size)
	-- if self.maxAward == 1 then
		local size1 = self.awardSv:getInnerContainerSize()
	-- 	return cc.p(0,size1.height - size.height)
	-- else
	-- 	return cc.p(0,(self.currMax - i)*size.height)
	-- end
	return cc.p(0,size1.height - i*size.height)
end

function RaidsUI:OnRaids(times)
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
			local awards = data.awards
			for k,v in pairs(awards) do
				GlobalApi:parseAwardData(v)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            for i,v in ipairs(awards) do
            	self.awards[#self.awards + 1] = v
            end
			-- self.awardSv:removeAllChildren()
			self.maxAward = #self.awards
			if self.actionEnd then
				self:update()
			end
            local nowLv = UserData:getUserObj():getLv()
            GlobalApi:showKingLvUp(lastLv,nowLv)
		end
	end)
end

function RaidsUI:updateGetItem()
	self.getNum = self.getNum + 1
	local needNum = self.needNum
	if self.raidaward:getObjType() == 'fragment' then
		needNum = self.raidaward:getMergeNum()
	end
	local nameTx = self.pl:getChildByName('name_tx')
	nameTx:setString(self.raidaward:getName())
	local numTx = self.pl:getChildByName('num_tx')
	numTx:setString((self.oldItemNum + self.getNum)..'/'..needNum)
	if self.rts then
		self.rts.re2:setString(self.getNum)
		self.rts.richText:format(true)
	end
end

function RaidsUI:updateAward(node,index,maxIndex)
	local awards = self.awards[index]
	local pl = node:getChildByName('award_pl')
	-- local award = self.awards[i]
	local otherAwards = {}
	local userAwards = {}
	local awardInfo = DisplayData:getDisplayObjs(awards)
	for k, v in pairs(awardInfo) do
        if v:getType() == "user" then
            local name = v:getId()
            if userAwards[name] then
                userAwards[name] = userAwards[name] + v:getNum()
            else
                userAwards[name] = v:getNum()
            end
        else
            otherAwards[#otherAwards + 1] = v
        end
    end
    local pos = cc.p(84,64)
	for i=1,5 do
		local str = 'award_bg_'..i..'_img'
		local awardBgImg = pl:getChildByName(str)
		if not awardBgImg then
		    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
		    awardBgImg = tab.awardBgImg
		    awardBgImg:setTouchEnabled(true)
		    awardBgImg:setPosition(cc.p(pos.x + 110 * i,pos.y))
		    awardBgImg:setName(str)
		    pl:addChild(awardBgImg)
		end
		if otherAwards[i] then
			awardBgImg:setVisible(true)
			ClassItemCell:updateItem(awardBgImg, otherAwards[i], 2)
			local numTx = awardBgImg:getChildByName('lv_tx')
			local doubleImg = awardBgImg:getChildByName('double_img')
			numTx:setVisible(true)
            if otherAwards[i]:getObjType() == 'equip' then
                numTx:setString('Lv.'..otherAwards[i]:getLevel())
            else
                numTx:setString('x'..otherAwards[i]:getNum())
            end
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(otherAwards[i],false)
                end
            end)
            ClassItemCell:setGodLight(awardBgImg)
            if otherAwards[i]:getExtraBg() then
                doubleImg:setVisible(true)
            else
                doubleImg:setVisible(false)
            end
            if self.raidaward and self.raidaward:getId() == otherAwards[i]:getId() and self.currMax == index then
            	self:updateGetItem()
            end
		else
			awardBgImg:setVisible(false)
		end
	end
	local nameTx = pl:getChildByName('name_tx')
	local expTx = pl:getChildByName('exp_tx')
	local goldTx = pl:getChildByName('gold_tx')
	nameTx:setString(string.format(GlobalApi:getLocalStr('STR_THE_FIGHTING'),index))
	expTx:setString(userAwards['xp'] or 0)
	goldTx:setString(userAwards['gold']or 0)
end

function RaidsUI:update()
	self.currMax = self.currMax + 1
	local node = cc.CSLoader:createNode("csb/raidscell.csb")
	local pl = node:getChildByName('award_pl')
    pl:removeFromParent(false)
    local widget = ccui.Widget:create()
    widget:addChild(pl)
	local size = pl:getContentSize()
	self.awardSv:addChild(widget)
	self.cells[#self.cells + 1] = widget
	
	self.awardSv:setInnerContainerSize(cc.size(self.awardSv:getContentSize().width,self.currMax*size.height))
	for i,v in ipairs(self.cells) do
		self:updateAward(v,i,self.currMax)
		v:setPosition(self:getPos(i,size))
	end
	self.awardSv:jumpToBottom()
	if self.currMax >= self.maxAward then
		self.actionEnd = true
		-- self.lightImg:setVisible(true)
		-- self.raidsOverImg:setVisible(true)
		-- self.lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))

		local userAwards = {}
		local materialAwards = {}
		local equipAwards = {}
		for i=self.oldNum + 1,#self.awards do
			for j,k in ipairs(self.awards[i]) do
		        if k[1] == "user" then
		            userAwards[k[2]] = (userAwards[k[2]] or 0) + k[3]
		        elseif k[1] == "material" then
		            materialAwards[k[2]] = (materialAwards[k[2]] or 0) + k[3]
		        else
		            equipAwards[#equipAwards + 1] = k
		        end
			end
		end
		local awards = {}
		for k,v in pairs(userAwards) do
			local tab = {'user',k,v}
			awards[#awards + 1] = tab
		end
		for k,v in pairs(materialAwards) do
			local tab = {'material',tonumber(k),v}
			awards[#awards + 1] = tab
		end
		for k,v in pairs(equipAwards) do
			awards[#awards + 1] = v
		end
		local showWidgets = {}
		for i,v in ipairs(awards) do
			local awardTab = DisplayData:getDisplayObj(v)
			local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..awardTab:getName()..'x'..awardTab:getNum(), 'font/gamefont.ttf', 24)
			w:setTextColor(awardTab:getNameColor())
			w:enableOutline(awardTab:getNameOutlineColor(),1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		promptmgr:showAttributeUpdate(showWidgets)
		self.oldNum = #self.awards
	else
		self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
			self:update()
	    end)))
	end
end

function RaidsUI:init()
	local raidsBgImg = self.root:getChildByName("raids_bg_img")
	local raidsImg = raidsBgImg:getChildByName("raids_nei_bg_img")
    self:adaptUI(raidsBgImg, raidsImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    raidsImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = raidsImg:getChildByName('close_btn')
    local infoTx = closeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    local raidsBtn = raidsImg:getChildByName('raids_btn')
    local infoTx = raidsBtn:getChildByName('info_tx')
    if self.raidsTimes == 1 then
    	infoTx:setString(GlobalApi:getLocalStr('RAIDS_AGAIN_1'))
    elseif self.raidsTimes == 5 then
    	infoTx:setString(GlobalApi:getLocalStr('RAIDS_AGAIN_3'))
    else
    	infoTx:setString(GlobalApi:getLocalStr('RAIDS_AGAIN_2'))
    end
    self.pl = raidsImg:getChildByName("item_pl")
    if self.raidaward and self.showGet then
    	self.pl:setVisible(true)
	    local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(400, 28))
	    richText:setAlignment('middle')
	    richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create('本次扫荡共获得', 21,COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		local re2 = xx.RichTextLabel:create('0', 21,COLOR_TYPE.GREEN)
		re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		local re3 = xx.RichTextLabel:create('个', 21,COLOR_TYPE.ORANGE)
		re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:setPosition(cc.p(105,90))
		self.pl:addChild(richText)
		self.rts = {richText = richText,re2 = re2}
		local nameTx = self.pl:getChildByName('name_tx')
		local numTx = self.pl:getChildByName('num_tx')
		nameTx:setString(self.raidaward:getName())
		local needNum = self.needNum
		if self.raidaward:getObjType() == 'fragment' then
			needNum = self.raidaward:getMergeNum()
		end
		numTx:setString(self.oldItemNum..'/'..needNum)
		nameTx:setColor(self.raidaward:getNameColor())
		numTx:setColor(self.raidaward:getNameColor())
		nameTx:enableOutline(self.raidaward:getNameOutlineColor(),1)
		numTx:enableOutline(self.raidaward:getNameOutlineColor(),1)

	    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.raidaward, self.pl)
	    tab.awardBgImg:setScale(0.7)
	    tab.awardBgImg:setPosition(cc.p(40,27))
	    tab.awardBgImg:setTouchEnabled(false)
		tab.lvTx:setVisible(false)
        ClassItemCell:setGodLight(tab.awardBgImg)
    else
    	self.pl:setVisible(false)
    end
    local nameTx = raidsImg:getChildByName('city_name_tx')
    nameTx:setString(GlobalApi:getLocalStr('RAIDS_RESULT'))
    self.cells = {}
    self.maxAward = #self.awards
	self.currMax = 0
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           MapMgr:hideRainsPanel()
        end
    end)
	raidsBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local cityData = MapData.data[self.id]
			local star = cityData:getStar(self.page)
			local times = self.raidsTimes
			local maxTimes = cityData:getLimits(self.page) - cityData:getTimes(self.page)
			if maxTimes <= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
				return
			end
			if maxTimes < times then
				times = maxTimes
			end
			if self.page ~= 3 and star < 3 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_THREE_STAR'), COLOR_TYPE.RED)
				return
			end
        	self:OnRaids(times)
        end
    end)
    -- if #self.awards ~= 1 then
    -- 	raidsBtn:setVisible(false)
    -- 	closeBtn:setPosition(cc.p(363,54))
    -- end

	self.awardSv = raidsImg:getChildByName('award_sv')
	self.awardSv:setScrollBarEnabled(false)
	self.awardSv:setAnchorPoint(cc.p(0, 1))
	-- self.lightImg = raidsImg:getChildByName('light_img')
	-- self.raidsOverImg = raidsImg:getChildByName('raids_over_img')
	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
		self:update()
    end)))
end

return RaidsUI