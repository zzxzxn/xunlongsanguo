local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassItemObj = require('script/app/obj/itemobj')

local RoleRiseStarUI = class("RoleRiseStarUI", ClassRoleBaseUI)
local MAXDELTA = 0.2 -- 10sËõÐ¡Ò»±¶£¬×îµÍ0.05s
local FIRSTDELT = 1.0
local INTERVEAL = 10.0

local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
}


function RoleRiseStarUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/rolerisestar.csb")
	self.panel:setName("role_risestar_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	-- local bgimg1 = bgimg:getChildByName('bg_1_img')
	self.cell1 = bgimg:getChildByName('itembg_1_img')
	self.cell2 = bgimg:getChildByName('itembg_2_img')
	self.cell3 = bgimg:getChildByName('itembg_3_img')
	self.riseBtn = bgimg:getChildByName('rise_btn')
	-- 升品按钮小红点
	self.newimg	= self.riseBtn:getChildByName('new_img')
	self.infoTx = self.riseBtn:getChildByName('info_tx')
	local diImg = bgimg:getChildByName('di_img')
	self.diImg = diImg
	self.numTx = diImg:getChildByName('num_tx')
	self.itemBgImg = bgimg:getChildByName('res_img')
	self.maxImg = bgimg:getChildByName('max_img')

	self.cell1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if self.obj:getCamp() == 5 then
        		local award = DisplayData:getDisplayObj({'user','xp',1000})
        		GetWayMgr:showGetwayUI(award,true)
        		return
        	end
        	RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_LVUP)
        end
    end)

    self.cell2:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	-- local isOpen = GlobalApi:getOpenInfo('elite')
        	local desc,code = GlobalApi:getGotoByModule('elite',true)
        	if not desc then
        		RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_SOLDIER)
        	else
        		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),desc), COLOR_TYPE.RED)
        	end
        end
    end)

    self.cell3:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	-- local isOpen = GlobalApi:getOpenInfo('reborn')
        	local desc,code = GlobalApi:getGotoByModule('reborn',true)
        	if not desc then
        		RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_TUPO)
        	else
        		-- promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_RISE_STAR_5'), COLOR_TYPE.RED)
        		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),desc), COLOR_TYPE.RED)
        	end
        end
    end)

    diImg:setTouchEnabled(true)
    diImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
        	local award = DisplayData:getDisplayObj({'material',itemId,1000})
    		GetWayMgr:showGetwayUI(award,true)
        end
    end)
end

function RoleRiseStarUI:update(obj)
	self.obj = obj
	local isRise = false
	local quality = obj:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]
	local barBg1 = self.cell1:getChildByName('bar_bg')
	local bar1 = barBg1:getChildByName('bar')
	local tx1 = bar1:getChildByName('tx')
	local arrowImg1 = self.cell1:getChildByName('arrow_img')
	local currTx1 = self.cell1:getChildByName('curr_tx')
	local numTx1 = self.cell1:getChildByName('num_tx')
	local level = obj:getLevel()
	currTx1:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_1')..level)
	bar1:setPercent(level / conf.conditionHeroLevel*100)
	currTx1:stopAllActions()
	currTx1:setScale(1)
	local isNotEnough1 = false
	if level >= conf.conditionHeroLevel then
		numTx1:setVisible(true)
		arrowImg1:setVisible(false)
		numTx1:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_4'))
		numTx1:setColor(COLOR_TYPE.GREEN)
		currTx1:setColor(COLOR_TYPE.GREEN)
		tx1:setString(conf.conditionHeroLevel..'/'..conf.conditionHeroLevel)
		isNotEnough1 = true
	else
		arrowImg1:setVisible(true)
		numTx1:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_1')..conf.conditionHeroLevel)
		tx1:setString(level..'/'..conf.conditionHeroLevel)
		numTx1:setColor(COLOR_TYPE.WHITE)
		currTx1:setColor(COLOR_TYPE.RED)
		-- currTx1:runAction(cc.ScaleBy:create(0.3,2))
	end
	isRise = level >= conf.conditionHeroLevel

	local desc,isOpen = GlobalApi:getGotoByModule('elite',true)
	local barBg2 = self.cell2:getChildByName('bar_bg')
	local bar2 = barBg2:getChildByName('bar')
	local tx2 = bar2:getChildByName('tx')
	local currTx2 = self.cell2:getChildByName('curr_tx')
	local numTx2 = self.cell2:getChildByName('num_tx')
	local descTx2 = self.cell2:getChildByName('desc_tx')
	local arrowImg2 = self.cell2:getChildByName('arrow_img')
	currTx2:stopAllActions()
	currTx2:setScale(1)
	local isNotEnough2 = false
	local soldier = obj:getSoldier()
	if conf.conditionHeroSoldier <= 0 then
		isRise = isRise and true
		self.cell2:setVisible(false)
	else
		self.cell2:setVisible(true)
		-- if not desc then
			numTx2:setVisible(true)
			barBg2:setVisible(true)
			currTx2:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_2')..soldier.level)
			bar2:setPercent(soldier.level / conf.conditionHeroSoldier*100)
			if soldier.level >= conf.conditionHeroSoldier then
				arrowImg2:setVisible(false)
				numTx2:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_4'))
				numTx2:setColor(COLOR_TYPE.GREEN)
				currTx2:setColor(COLOR_TYPE.GREEN)
				tx2:setString(conf.conditionHeroSoldier..'/'..conf.conditionHeroSoldier)
				isNotEnough2 = true
			else
				arrowImg2:setVisible(true)
				numTx2:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_2')..conf.conditionHeroSoldier)
				currTx2:setColor(COLOR_TYPE.RED)
				tx2:setString(soldier.level..'/'..conf.conditionHeroSoldier)
				numTx2:setColor(COLOR_TYPE.WHITE)

			end
			descTx2:setVisible(false)
			isRise = isRise and (soldier.level >= conf.conditionHeroSoldier)
		-- else
		-- 	currTx2:setVisible(false)
		-- 	barBg2:setVisible(false)
		-- 	arrowImg2:setVisible(false)
		-- 	numTx2:setVisible(false)
		-- 	descTx2:setVisible(true)
		-- 	descTx2:setString(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'))
		-- 	isRise = false
		-- end
	end

	local num = RoleMgr:clacUpgradeStarMaxNum(obj) 
	local autoisOpen,isNotIn,id,level = GlobalApi:getOpenInfo('autoupgrade')
	if num > 1 and autoisOpen then
		self.infoTx:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_8'))
	else
		self.infoTx:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_6'))
	end
	local desc,isOpen = GlobalApi:getGotoByModule('reborn',true)
	local barBg3 = self.cell3:getChildByName('bar_bg')
	local bar3 = barBg3:getChildByName('bar')
	local tx3 = bar3:getChildByName('tx')
	local currTx3 = self.cell3:getChildByName('curr_tx')
	local numTx3 = self.cell3:getChildByName('num_tx')
	local arrowImg3 = self.cell3:getChildByName('arrow_img')
	local descTx3 = self.cell3:getChildByName('desc_tx')
	currTx3:stopAllActions()
	currTx3:setScale(1)
	local isNotEnough3 = false
	if conf.conditionHeroTalent <= 0 then
		isRise = isRise and true
		self.cell3:setVisible(false)
	else
		self.cell3:setVisible(true)
		-- if not desc then
			numTx3:setVisible(true)
			barBg3:setVisible(true)
			descTx3:setVisible(false)
			local level = obj:getTalent()
			currTx3:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_3')..level)
			bar3:setPercent(level / conf.conditionHeroTalent*100)
			tx3:setString(level..'/'..conf.conditionHeroTalent)
			if level >= conf.conditionHeroTalent then
				arrowImg3:setVisible(false)
				numTx3:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_4'))
				numTx3:setColor(COLOR_TYPE.GREEN)
				currTx3:setColor(COLOR_TYPE.GREEN)
				tx3:setString(conf.conditionHeroTalent..'/'..conf.conditionHeroTalent)
				isNotEnough3 = true
			else
				arrowImg3:setVisible(true)
				numTx3:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_3')..conf.conditionHeroTalent)
				tx3:setString(level..'/'..conf.conditionHeroTalent)
				numTx3:setColor(COLOR_TYPE.WHITE)
				currTx3:setColor(COLOR_TYPE.RED)
			end
			isRise = isRise and (level >= conf.conditionHeroTalent)
		-- else
		-- 	currTx3:setVisible(false)
		-- 	barBg3:setVisible(false)
		-- 	arrowImg3:setVisible(false)
		-- 	numTx3:setVisible(false)
		-- 	descTx3:setVisible(true)
		-- 	descTx3:setString(GlobalApi:getLocalStr('FUNCTION_DESC_1')..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'))
		-- 	isRise = false
		-- end
	end

	local itemEnough = false
	local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
	local itemobj = BagData:getMaterialById(itemId)
	if not itemobj then
		itemobj = ClassItemObj.new(tonumber(itemId),0)
	end
	self.numTx:setString(GlobalApi:toWordsNumber(itemobj:getNum())..'/'..GlobalApi:toWordsNumber(conf.itemNum))
	self.itemBgImg:loadTexture(itemobj:getIcon())
	if itemobj:getNum() >= conf.itemNum then
		itemEnough = true
		self.numTx:setColor(COLOR_TYPE.WHITE)
	else
		self.numTx:setColor(COLOR_TYPE.RED)
	end
	if conf.itemNum <= 0 then
		self.riseBtn:setPosition(cc.p(225,51))
		self.itemBgImg:setVisible(false)
		self.diImg:setVisible(false)
	else
		self.riseBtn:setPosition(cc.p(338,51))
		self.itemBgImg:setVisible(true)
		self.diImg:setVisible(true)
	end

    local baseatt = RoleData:getPosAttByPos(obj)
    local curattarr = {}
    curattarr[1] = math.floor(baseatt[1])
    curattarr[2] = math.floor(baseatt[4])
    curattarr[3] = math.floor(baseatt[2])
    curattarr[4] = math.floor(baseatt[3])
    local conf11 = GameData:getConfData('heroqualityattr')[quality + 1]
    local conf2 = GameData:getConfData('heroqualityattr')[quality][obj:getProfessionType()]
    local nextattarr = {0,0,0,0}


    -- self.nextattarr = {}
    -- local objtemp = clone(self.obj)
    -- objtemp:setTalent(self.obj:getTalent()+1)
    -- local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    -- self.nextattarr[1] = math.floor(atttemp[1])
    -- self.nextattarr[2] = math.floor(atttemp[4])
    -- self.nextattarr[3] = math.floor(atttemp[2])
    -- self.nextattarr[4] = math.floor(atttemp[3])

    -- local addarr = {}
    -- addarr[1] = math.floor(self.nextattarr[1] -self.curattarr[1])
    -- addarr[2] = math.floor(self.nextattarr[2] -self.curattarr[2])
    -- addarr[3] = math.floor(self.nextattarr[3] -self.curattarr[3])
    -- addarr[4] = math.floor(self.nextattarr[4] -self.curattarr[4])

    if conf11 then 
    	local objtemp = clone(obj)
    	objtemp:setHeroQuality(quality + 1)
    	local atttemp = RoleData:CalPosAttByPos(objtemp,true)
	    nextattarr[1] = math.floor(atttemp[1])
	    nextattarr[2] = math.floor(atttemp[4])
	    nextattarr[3] = math.floor(atttemp[2])
	    nextattarr[4] = math.floor(atttemp[3])
    	-- local conf1 = conf11[obj:getProfessionType()]
	    -- nextattarr[1] = math.floor(baseatt[1]) + conf1.attack - conf2.attack
	    -- nextattarr[2] = math.floor(baseatt[4]) + conf1.hp - conf2.hp
	    -- nextattarr[3] = math.floor(baseatt[2]) + conf1.defence - conf2.defence
	    -- nextattarr[4] = math.floor(baseatt[3]) + conf1.mdefence - conf2.mdefence
	    self.maxImg:setVisible(false)
	    self.riseBtn:setVisible(true)
	    currTx1:setAnchorPoint(cc.p(0,0.5))
	    currTx2:setAnchorPoint(cc.p(0,0.5))
	    currTx3:setAnchorPoint(cc.p(0,0.5))
	    currTx1:setPosition(cc.p(127,26))
	    currTx2:setPosition(cc.p(127,26))
	    currTx3:setPosition(cc.p(127,26))
	else
	    self.cell1:setVisible(true)
	    self.cell2:setVisible(true)
	    self.cell3:setVisible(true)
	    self.maxImg:setVisible(true)
	    self.riseBtn:setVisible(false)

	    local lconf = GameData:getConfData('heroquality')[quality - 1]
		barBg1:setVisible(true)
		bar1:setPercent(100)
		currTx1:setAnchorPoint(cc.p(0.5,0.5))
		currTx1:stopAllActions()
		currTx1:setScale(1)
		currTx1:setPosition(cc.p(218,26))
		currTx1:setColor(COLOR_TYPE.GREEN)
		currTx1:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_1')..obj:getLevel())
		tx1:setString(lconf.conditionHeroLevel..'/'..lconf.conditionHeroLevel)
		arrowImg1:setVisible(false)
		numTx1:setVisible(false)

		barBg2:setVisible(true)
		bar2:setPercent(100)
		currTx2:setAnchorPoint(cc.p(0.5,0.5))
		currTx2:stopAllActions()
		currTx2:setScale(1)
		currTx2:setPosition(cc.p(218,26))
		currTx2:setColor(COLOR_TYPE.GREEN)
		currTx2:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_2')..soldier.level)
		tx2:setString(lconf.conditionHeroSoldier..'/'..lconf.conditionHeroSoldier)
		arrowImg2:setVisible(false)
		descTx2:setVisible(false)
		numTx2:setVisible(false)

		barBg3:setVisible(true)
		bar3:setPercent(100)
		currTx3:setAnchorPoint(cc.p(0.5,0.5))
		currTx3:stopAllActions()
		currTx3:setScale(1)
		currTx3:setPosition(cc.p(218,26))
		currTx3:setColor(COLOR_TYPE.GREEN)
		currTx3:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_3')..obj:getTalent())
		tx3:setString(lconf.conditionHeroTalent..'/'..lconf.conditionHeroTalent)
		arrowImg3:setVisible(false)
		descTx3:setVisible(false)
		numTx3:setVisible(false)
	end

	-- isRise = self.obj:isCanRiseQuality()
	-- 判断小红点是否可以显示
	self.newimg:setVisible(isRise)

	self.riseBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
                self.riseBtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.5)
            end
        elseif eventType == ccui.TouchEventType.moved then
            if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
                self.riseBtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
                self.riseBtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
                self.riseBtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        	if not isRise then
        		if not isNotEnough1 then
        			currTx1:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.3,2),cc.ScaleTo:create(0.3,1)))
        		end
        		if not isNotEnough2 then
        			currTx2:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.3,2),cc.ScaleTo:create(0.3,1)))
        		end
        		if not isNotEnough3 then
        			currTx3:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.3,2),cc.ScaleTo:create(0.3,1)))
        		end
        		self.panel:runAction(cc.Sequence:create(cc.DelayTime:create(1.1),cc.CallFunc:create(function()
        			promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_RISE_STAR_5'), COLOR_TYPE.RED)
        		end)))
        		return
        	end
        	if not itemEnough then
        		promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_RISE_STAR_7'), COLOR_TYPE.RED)
        		local award = DisplayData:getDisplayObj({'material',itemId,1000})
        		GetWayMgr:showGetwayUI(award,true)
        		return
        	end
        	if num > 1 and autoisOpen then
        		RoleMgr:showRoleAutoUpgradeStar(obj)
        	else
        		RoleMgr:sendUpgradeStarMsg(obj,1,curattarr,nextattarr,function()
        			self:update()
        		end)
        	end


        end
    end)

    local judge = true
    if not isRise then
        judge = false
    end
    if not itemEnough then
        judge = false
    end
    if judge then
        if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
            self.riseBtn:removeChildByName('ui_yijianzhuangbei')
        end
        local size = self.riseBtn:getContentSize()
        local effect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
        effect:setScaleX(1.4)
        effect:setName('ui_yijianzhuangbei')
        effect:setPosition(cc.p(size.width/2 ,size.height/2))
        effect:setAnchorPoint(cc.p(0.5,0.5))
        effect:getAnimation():playWithIndex(0, -1, 1)
        self.riseBtn:addChild(effect)
	else
        if self.riseBtn:getChildByName('ui_yijianzhuangbei') then
            self.riseBtn:removeChildByName('ui_yijianzhuangbei')
        end
	end
end


return RoleRiseStarUI