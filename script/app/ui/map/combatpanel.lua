local CombatUI = class("CombatUI", BaseUI)
local roleanim ={
	'attack',
	'run',
	'skill1',
	'skill2',
	'shengli'
}
function CombatUI:ctor(id,raidaward)
	self.uiIndex = GAME_UI.UI_COMBAT
	self.id = id
	self.page = 3
	if raidaward then
		local fragment = BagData:getFragmentById(raidaward:getId())
		if not fragment then
			fragment = DisplayData:getDisplayObj({'fragment',raidaward:getId(),0})
		end
		self.raidaward = fragment
	else
		self.raidaward = raidaward
	end
	self.isRaidaward = false
end

function CombatUI:clear()
	self.id = nil
	self.page = nil
	self.numTx1 = nil
	self.numTx2 = nil
	self.forceLabel = nil
	self.cityNameTx = nil
	self.showAward = nil
	self.showAward1 = nil
    self.fightingBtn = nil
    self.neiBgImg = nil
end

function CombatUI:OnFighting()
	local cityData = cc.exports.MapData.data[self.id]
	local star = cityData:getStar(1)
	if star <= 0 then
	    -- promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_FIGHT_NORMAL_FIRST'), MESSAGE_BOX_TYPE.OK)
	    promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_FIGHT_NORMAL_FIRST'), COLOR_TYPE.RED)
		return
	end
	local limit = cityData:getLimits(self.page)
	local times = cityData:getTimes(self.page)
	if times >= limit then
		-- promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NO_TIMES'), MESSAGE_BOX_TYPE.OK)
		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
		return
	end
	local needFood = cityData:getFood(self.page)
	local food = UserData:getUserObj():getFood()
	if needFood > food then
        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY_FOOD"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("food")
        end)
		return
	end
	local id = self.id
	local page = self.page
    MapMgr:playBattle(BATTLE_TYPE.NORMAL, id, page,function()
	    MapMgr:showMainScene(2,id,function()
            MapMgr:showCombatPanel(id)
        end)
    end)
end

function CombatUI:updatePanel()
	local cityData = MapData.data[self.id]
	local keyArr = string.split(cityData:getName() , '.')
	-- self.cityNameTx:setString(keyArr[#keyArr])
	self.cityNameTx:setString(cityData:getName())
	self.isRaidaward = false
    local awardsTab = cityData:getDrop(3)
    -- for i=1,2 do
    	local pl = self.canGetBgImg:getChildByName('pl1')
    	local size = pl:getContentSize()
    	local str = 'award1'
	    local award = DisplayData:getDisplayObj(awardsTab[str][1])
    	local id = award:getId()
	    local roleObj = RoleData:getRoleInfoById(tonumber(id))
    	if not self.spineAnis then
    		self.spineAnis = GlobalApi:createLittleLossyAniByRoleId(id)
		    self.spineAnis:setPosition(cc.p(size.width/2,20))
		    self.spineAnis:getAnimation():play('idle', -1, 1)
		    pl:addChild(self.spineAnis)
		    local num = 0
	        local obj = BagData:getFragmentById(award:getId())
	        if obj then
	            num = obj:getNum()
	        end
	        local award1 = DisplayData:getDisplayObj({'fragment',award:getId(),num})
			pl:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
		            GetWayMgr:showGetwayUI(award1,true)
		        end
		    end)
		    if not self.nameRTs then
			    local richText = xx.RichText:create()
			    richText:setContentSize(cc.size(200, 30))
			    richText:setAlignment('middle')
				local re1 = xx.RichTextLabel:create(roleObj:getName(), 26, COLOR_TYPE.ORANGE)
				local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('DIAN_CHIP'), 26, COLOR_TYPE.WHITE)
				re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
				re2:setStroke(COLOR_TYPE.BLACK, 1)
				richText:addElement(re1)
				richText:addElement(re2)
				richText:setAnchorPoint(cc.p(0.5,0.5))
				richText:setPosition(cc.p(pl:getPositionX(),40))
				richText:setName('name_tx')
				self.canGetBgImg:addChild(richText)
				self.nameRTs = {richText = richText,re1 = re1,re2 = re2}
			else
				self.nameRTs.re1:setString(roleObj:getName())
				self.nameRTs.richText:format(true)
			end
    	end
    -- end
	if self.raidaward and award:getId() == self.raidaward:getId() then
		self.isRaidaward = true
	end
    local descTx = self.canGetBgImg:getChildByName('desc_tx')
    local name = roleObj:getName()
    descTx:setString(string.format(cityData:getDesc1(),name,name,award:getMergeNum(),name,name))

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
		richText:setPosition(cc.p(460,69))
		self.combatImg:addChild(richText)
		self.rt1 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.rt1.re1:setString(tx1)
		self.rt1.re2:setString(tx2)
		self.rt1.richText:format(true)
    end
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
		richText:setPosition(cc.p(460,39))
		self.combatImg:addChild(richText)
		self.rt2 = {richText = richText,re1 = re1,re2 = re2}
	else
		self.rt2.re1:setString(tx3)
		self.rt2.re2:setString(tx4)
		self.rt2.richText:format(true)
    end

	self:getSpine()

	local id = MapData:getCanFighttingIdByPage(self.page)
    if self.id <= 1 then
    	self.leftBtn:setBright(false)
    	self.leftBtn:setTouchEnabled(false)
    else
    	self.leftBtn:setBright(true)
    	self.leftBtn:setTouchEnabled(true)
    end
    if self.id >= id then
    	self.rightBtn:setBright(false)
    	self.rightBtn:setTouchEnabled(false)
    else
    	self.rightBtn:setBright(true)
    	self.rightBtn:setTouchEnabled(true)
    end

    local cityData = MapData.data[self.id]
    local star = cityData:getStar(self.page)
    local richText = self.combatImg:getChildByName('open_raids')
    if star > 0 then
	    self.raidsBtn:setVisible(true)
		self.raidsTenBtn:setVisible(true)
		if richText then
			richText:setVisible(false)
		end
	else
	    self.raidsBtn:setVisible(false)
		self.raidsTenBtn:setVisible(false)
		if richText then
			richText:setVisible(true)
		else
			richText = xx.RichText:create()
			richText:setContentSize(cc.size(220, 30))
			local tx1 = GlobalApi:getLocalStr('OPEN_RAIDS')
			local re1 = xx.RichTextLabel:create(tx1, 30, COLOR_TYPE.PALE)
			re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
			re1:setFont('font/gamefont.ttf')
			richText:addElement(re1)
			richText:setAnchorPoint(cc.p(0.5,0.5))
			richText:setPosition(cc.p(166,55))
			richText:setName('open_raids')
			self.combatImg:addChild(richText)
		    self.raidsBtn:setVisible(false)
			self.raidsTenBtn:setVisible(false)
		end
	end
end

function CombatUI:getSpine()
	local cityData = MapData.data[self.id]
	self.cityImg:loadTexture(cityData:getBtnResource())
	self.cityImg:ignoreContentAdaptWithSize(true)
	local monsterGroup = cityData:getFormation(self.page)
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
	if monsterConf then
		self.forceLabel:setString(monsterConf.fightforce)
	end
end

function CombatUI:OnRaids(times,num)
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
			MapMgr:showRainsPanel(awards,id,page,num,self.raidaward,awardsNum,0,self.isRaidaward)
			self:updatePanel()
            local nowLv = UserData:getUserObj():getLv()
            GlobalApi:showKingLvUp(lastLv,nowLv)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MAP_ERROR'), COLOR_TYPE.RED)
		end
	end)
end

function CombatUI:onShow()
	self:updatePanel()
end

function CombatUI:init()
	local bgImg = self.root:getChildByName("combat_bg_img")
	self.combatImg = bgImg:getChildByName("combat_img")
    self:adaptUI(bgImg, self.combatImg)
	local closeBtn = self.combatImg:getChildByName("close_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.combatImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	local titleImg = self.combatImg:getChildByName("title_img")
	self.cityNameTx = titleImg:getChildByName("city_name_tx")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideCombatPanel()
        end
    end)

    local addBtn = self.combatImg:getChildByName("add_btn")
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local combatReset = MapData:getCombatReset()
        	local buyTimes = 0
        	if combatReset and combatReset[tostring(self.id)] then
        		buyTimes = combatReset[tostring(self.id)]
        	end
        	local vip = UserData:getUserObj():getVip()
        	local vipConf = GameData:getConfData("vip")
        	local canResetTimes = vipConf[tostring(vip)].combatReset
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
        				 if vipConf[tostring(vip+i)].combatReset > buyTimes then
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
        		local needCash = buyConf[buyTimes+1].combatReset
        		if cash < needCash then
        			promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
        		else
        			promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("TOWER_DESC_4"), needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
        				local args = {
        					id = self.id
        				}
        				MessageMgr:sendPost('reset_combat', 'battle', json.encode(args), function (response)
							if response.code == 0 then
								MapData:addCombatReset(self.id)
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

    self.fightingBtn = self.combatImg:getChildByName("fighting_btn")
    local infoTx = self.fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('COMBAT'))
    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:OnFighting()
        end
    end)

    local leftImg = self.combatImg:getChildByName('left_bg_img')
    local roleBgImg = leftImg:getChildByName('role_bg_img')
    self.cityImg = roleBgImg:getChildByName('city_img')
    local rightImg = self.combatImg:getChildByName('right_bg_img')
    self.canGetBgImg = rightImg:getChildByName('can_get_bg_img')
    local titleImg = self.canGetBgImg:getChildByName("title_bg_img")
    local titleTx = titleImg:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('MAYBE_GET'))
    local zhanBgImg = leftImg:getChildByName('zhan_bg_img')
    -- local nameBgImg = leftImg:getChildByName('name_bg_img')
    -- self.nameTx = nameBgImg:getChildByName("name_tx")
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    forceLabel:setString('')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)
	
	self.raidsBtn = self.combatImg:getChildByName("raids_btn")
    self.raidsTenBtn = self.combatImg:getChildByName("raids_ten_btn")
    infoTx = self.raidsBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('RAIDS'))
	infoTx = self.raidsTenBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('RAIDS_FIVE'))
    self.raidsBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local cityData = MapData.data[self.id]
			local star = cityData:getStar(self.page)
			local times = 1
			local maxTimes = cityData:getLimits(self.page) -  cityData:getTimes(self.page)
			if maxTimes < times then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
				return
			end
			if star <= 0 then
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
	        if isOpen or vip >= autoProgressTenVip then
	        	local cityData = MapData.data[self.id]
				local star = cityData:getStar(self.page)
				local times = 5
				local maxTimes = cityData:getLimits(self.page) -  cityData:getTimes(self.page)
				if maxTimes <= 0 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
					return
				end
				if maxTimes < times then
					times = maxTimes
				end
				if star <= 0 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_THREE_STAR'), COLOR_TYPE.RED)
					return
				end
	        	self:OnRaids(times,5)
	        else
	        	promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("OPEN_AFTER_LEVEL_OR_VIP"), openLevel, autoProgressTenVip), COLOR_TYPE.RED)
	        end
        end
    end)
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
        	if self.spineAnis then
        		self.spineAnis:removeFromParent()
        		self.spineAnis = nil
        	end
            self.id = self.id - 1
            self:updatePanel()
        end
    end)
    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local id = MapData:getCanFighttingIdByPage(self.page)
        	if self.id >= id then
        		return
        	end
        	if self.spineAnis then
        		self.spineAnis:removeFromParent()
        		self.spineAnis = nil
        	end
            self.id = self.id + 1
            self:updatePanel()
        end
    end)
    self.showAward = {}
    self:updatePanel()
end

return CombatUI