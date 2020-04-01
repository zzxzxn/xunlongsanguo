local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local APPEAR_INTERVAL_1 = 10
local APPEAR_INTERVAL_2 = 10
local MAX_DESTINY_NUM = tonumber(GlobalApi:getGlobalValue('destinyNum'))

local BattlerDestinyUI = class("BattlerDestinyUI", BaseBattleUI)

local function getTime(t)
    local m = string.format("%02d", math.floor(t%3600/60))
    local s = string.format("%02d", math.floor(t%3600%60%60))
    return m..':'..s
end

function BattlerDestinyUI:initExtraUI()
	self.disNum = 1
	local winsize = cc.Director:getInstance():getWinSize()
	local extraNode = self.root:getChildByName("extra_node")
	extraNode:setPosition(cc.p(winsize.width, winsize.height))
	extraNode:setVisible(true)

	self.customObj.jadeSealAddition = 1
    local addition = UserData:getUserObj():getJadeSealAddition("rescopy")
    if addition[1] then
        self.customObj.jadeSealAddition = 1 + addition[2]/100
    end

	self.customObj.condition = self.customObj.conf.condition
	self.customObj.baseAwardNum1 = 0
	if self.customObj.conf.baseReward[1] then
		self.customObj.baseAwardNum1 = self.customObj.conf.baseReward[1][3]
	end

	local dropConf = GameData:getConfData("drop")[self.customObj.conf.drop]
	local award1 = dropConf.award1
	local awardObj1 = DisplayData:getDisplayObj(award1[1])
	self.customObj.dropIcon = awardObj1:getIcon()

	local frame1 = extraNode:getChildByName("frame_1")
	frame1:setPosition(cc.p(-174, -220))
	frame1:setTexture(awardObj1:getBgImg())
	local icon = frame1:getChildByName("icon")
	icon:setTexture(self.customObj.dropIcon)
	local numLabel1 = cc.LabelAtlas:_create(tostring(math.floor(self.customObj.baseAwardNum1*self.customObj.jadeSealAddition)), "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
	numLabel1:setAnchorPoint(cc.p(0, 0.5))
	numLabel1:setPosition(cc.p(-146, -220))
	extraNode:addChild(numLabel1)
	if addition[1] then
		local upImg = ccui.ImageView:create("uires/ui/common/arrow_up3.png")
		upImg:setPosition(cc.p(90, 16))
		frame1:addChild(upImg)

		local upTx = ccui.Text:create()
		upTx:setAnchorPoint(cc.p(1, 0.5))
		upTx:setFontName("font/gamefont.ttf")
		upTx:setFontSize(26)
		upTx:setTextColor(COLOR_TYPE.GREEN)
		upTx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		upTx:setString(addition[2] .. "%")
		upTx:setPosition(cc.p(78, 16))
		frame1:addChild(upTx)
	end

	local frame2 = extraNode:getChildByName("frame_2")
	frame2:setVisible(false)

	local infoLabel1 = extraNode:getChildByName("info_tx_1")
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_ROUND") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
	infoNumLabel1:setString(tostring(self.customObj.condition + 1))
	local infoLabel2 = extraNode:getChildByName("info_tx_2")
	infoLabel2:setString(GlobalApi:getLocalStr("STR_HISTORY_HIGHEST") .. "：")
	local infoNumLabel2 = extraNode:getChildByName("info_num_tx_2")
	infoNumLabel2:setString(self.customObj.highestRound)
	-- 倒计时
	local countdownImg = ccui.ImageView:create("uires/ui/battle/countdown_img.png")
	local countdownSize = countdownImg:getContentSize()
	countdownImg:setPosition(cc.p(-66, -400))
	countdownImg:setTouchEnabled(true)
	countdownImg:addClickEventListener(function ()
		if self.disNum < MAX_DESTINY_NUM then
			self.customObj.time = self.time + APPEAR_INTERVAL_1
			self.extraUI.countdownImg:setVisible(false)
			self.extraUI.countdownQuan:stopAllActions()
			self:dispatchLegion()
		end
	end)
	extraNode:addChild(countdownImg)
	countdownImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.6, 1.1), cc.ScaleTo:create(0.6, 1))))
	countdownImg:setVisible(false)

	local countdownQuan = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/battle/countdown_quan.png"))
	countdownQuan:setPosition(cc.p(countdownSize.width/2, countdownSize.height/2))
	countdownQuan:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    countdownQuan:setMidpoint(cc.p(0.5, 0.5))
    countdownQuan:setPercentage(0)
    countdownImg:addChild(countdownQuan)

    local topBg = self.fightPl:getChildByName("top_bg")
    local x, y = topBg:getPosition()
    topBg:setTexture("uires/ui/battle/battleui_bg_top2.png")
    local topSp = self.fightPl:getChildByName("top_sp")
    topSp:setVisible(false)
    --topSp:setTexture("uires/ui/battle/battleui_kedu.png")
    self.playerHealth[1].healthBar:ignoreContentAdaptWithSize(true)
    self.playerHealth[1].healthBar:loadTexture("uires/ui/battle/battleui_playerhealth_3.png")
    self.playerHealth[1].healthBar:setPosition(cc.p(x - 1.5, y + 0.2))
    self.playerHealth[2].healthBar:setVisible(false)

    local descImg = ccui.ImageView:create("uires/ui/common/name_bg21.png")
    descImg:setLocalZOrder(-1)
   	local descImgSize = descImg:getContentSize()
    local descLabel = cc.Label:createWithTTF(self.customObj.desc, "font/gamefont.ttf", 25)
    descLabel:setTextColor(COLOR_TYPE.WHITE)
    descLabel:enableOutline(cc.c4b(131, 86, 66, 255), 2)
    descLabel:setPosition(cc.p(descImgSize.width/2, descImgSize.height/2))
    descImg:addChild(descLabel)
    descImg:setPosition(cc.p(480, 40))
    local npc = ccui.ImageView:create("uires/ui/battle/npc_1.png")
    npc:setPosition(cc.p(descImgSize.width - 70, 36))
    descImg:addChild(npc)
	self.topPl:addChild(descImg)

	self.extraUI = {
		numLabel1 = numLabel1,
		infoNumLabel1 = infoNumLabel1,
		countdownImg = countdownImg,
		countdownQuan = countdownQuan,
		descImg = descImg
	}
	self.timeLabel:setString("")
	self.customObj.dropProb = self.customObj.conf.dropExpect
	self.customObj.dropExpect = self.customObj.conf.dropExpect/100
	self.customObj.dropNum = 0
	self.customObj.targetPos1 = frame1:convertToWorldSpace(cc.p(icon:getPosition()))
	self.customObj.round = 1
	self.customObj.cash = 0
	self.customObj.dispatching = false
	self.customObj.time = APPEAR_INTERVAL_1 + APPEAR_INTERVAL_2
	self.customObj.dropCashPos = {}
end

function BattlerDestinyUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		type = "destiny",
		id = self.customObj.id
	}
	MessageMgr:sendPost("before_fight", "rescopy", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
			self.verifyObj.pos = jsonObj.data.rand_pos or 1
			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
        	GlobalApi:setRandomSeed(jsonObj.data.rand)
       		self.extraUI.descImg:removeFromParent()
        	self:battleStart()
        else
        	promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
        end
	end)
end

function BattlerDestinyUI:sendMessageAfterFight(isWin)
	local roleMap = RoleData:getRoleMap()
	local heroTotalLv = 0
	for k, heroObj in pairs(roleMap) do
		heroTotalLv = heroTotalLv + heroObj:getLevel()
	end
	local args = {
		round = self.customObj.round - 1,
		id = self.customObj.id,
		drop = self.customObj.dropNum,
		cash = self.customObj.cash,
		sig = self:generateVerifyMD5(),
		ff = self.armyData.fightforce,
		levels = heroTotalLv
	}
	MessageMgr:sendPost("fight_destiny", "rescopy", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
        	local info = UserData:getUserObj():getRescopyinfo()
        	info.destiny.count = info.destiny.count + 1
			info.destiny.round = jsonObj.data.round or info.destiny.round
			info.destiny.difficulty = jsonObj.data.difficulty or info.destiny.difficulty
			info.destiny.first = jsonObj.data.first or info.destiny.first
        	local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
        	BattleMgr:showBattleResult(true, displayAwards, 3)
        	GlobalApi:parseAwardData(jsonObj.data.awards)
        	local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
        else
        	promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
        end
	end)
end

function BattlerDestinyUI:battleEnd(isWin, timeoutFlag)
	if isWin and self.disNum < MAX_DESTINY_NUM then
		self.waitFlag = true
		self.changeTargetLegions = nil
		for k, v in ipairs(self.playerSkillStatusArr[1]) do
			v.border:setTouchEnabled(false)
		end
		for k, v in pairs(self.dragonArr) do
			if v.dragon then
				v.dragon:setVisible(false)
				v.rangeImg:setVisible(false)
				v.visible = false
			end
		end
		for k, v in ipairs(self.armyArr[1]) do
			if not v:isDead() then
				v:stop()
				v:wait()
				v:moveToPosition(LEGION_POS[1][k])
			end
		end
		if not self.customObj.dispatching then
			if not self.extraUI.countdownImg:isVisible() then
				self.customObj.time = self.time + APPEAR_INTERVAL_1 + APPEAR_INTERVAL_2
				self.extraUI.countdownImg:setVisible(true)
				self.extraUI.countdownQuan:setPercentage(0)
				self.extraUI.countdownQuan:runAction(cc.Sequence:create(cc.ProgressTo:create(APPEAR_INTERVAL_2, 100), cc.CallFunc:create(function ()
					self.extraUI.countdownImg:setVisible(false)
					self:dispatchLegion()
		    	end)))
			end
		end
	else
		self.super.battleEnd(self, true, timeoutFlag)
	end
end

function BattlerDestinyUI:updateTime()
	if (self.time - self.customObj.time) > 0 and self.disNum < MAX_DESTINY_NUM then
		self.customObj.time = self.time + APPEAR_INTERVAL_1 + APPEAR_INTERVAL_2
		self.extraUI.countdownImg:setVisible(true)
		self.extraUI.countdownQuan:setPercentage(0)
		self.extraUI.countdownQuan:runAction(cc.Sequence:create(cc.ProgressTo:create(APPEAR_INTERVAL_2, 100), cc.CallFunc:create(function ()
			self.extraUI.countdownImg:setVisible(false)
			self:dispatchLegion()
    	end)))
	end
end

function BattlerDestinyUI:addKillAnimation()
end

function BattlerDestinyUI:dispatchLegion()
	if self.disNum >= MAX_DESTINY_NUM then
		self.extraUI.countdownImg:setVisible(false)
		return
	end
	local legionArr = self.customObj.legionArr
	local round = self.customObj.round
	if round > #self.customObj.roundConf then
		round = #self.customObj.roundConf
	end
	local needMonsterCount = self.customObj.roundConf[round].posCount
	local maxMonsterCount = #legionArr
	if needMonsterCount > maxMonsterCount then
		needMonsterCount = maxMonsterCount
	end
	local num = 0
	local maxNum = needMonsterCount
	local arr = {}
	for i = 1, maxMonsterCount do
		table.insert(arr, i)
	end
	local newLegionArr = {}
	while needMonsterCount > 0 do
		local legion = legionArr[table.remove(arr, math.random(1, maxMonsterCount))]
		table.insert(newLegionArr, legion)
		needMonsterCount = needMonsterCount - 1
		maxMonsterCount = maxMonsterCount - 1
	end
	local newLegions = {}
	local co = coroutine.create(function ()
		for k, v in pairs(newLegionArr) do
			local legionPos = v.info.pos
			local newLegionPos = legionPos + self.customObj.round*9
			local newV = clone(v)
			newV.info.pos = newLegionPos
			local factor = math.pow(1+self.customObj.conf.addFactor/100, self.customObj.round)
			newV.heroInfo.atk = v.heroInfo.atk*factor
			newV.heroInfo.phyDef = v.heroInfo.phyDef*factor
			newV.heroInfo.magDef = v.heroInfo.magDef*factor
			newV.heroInfo.hp = v.heroInfo.hp*factor
			newV.heroInfo.hit = v.heroInfo.hit*factor
			newV.heroInfo.dodge = v.heroInfo.dodge*factor
			newV.heroInfo.crit = v.heroInfo.crit*factor
			newV.heroInfo.resi = v.heroInfo.resi*factor
			local enemyLegion = self:createLegion(2, newV, false)
			newLegions[newLegionPos] = enemyLegion
			enemyLegion:setPosition(cc.p(2000, LEGION_POS[2][legionPos].y))
			enemyLegion:moveToPosition(cc.p(LEGION_POS[2][legionPos].x, LEGION_POS[2][legionPos].y), function ()
				num = num + 1
				if num == maxNum then
					for k3, v3 in pairs(newLegions) do
						self.enemyMap[k3] = v3
						table.insert(self.armyArr[2], v3)
						self.legionCount[2] = self.legionCount[2] + 1
						v3:prepare()
					end
					table.sort(self.armyArr[2], function (a, b)
						return a.pos < b.pos
					end)
					if self.waitFlag then
						for k, v in ipairs(self.playerSkillStatusArr[1]) do
							v.border:setTouchEnabled(true)
						end
						for k3, v3 in ipairs(self.armyArr[1]) do
							v3:checkError()
						end
						self.waitFlag = false
					end
					self.customObj.dispatching = false
					self.disNum = self.disNum + 1
				end
			end)
			coroutine.yield()
		end
	end)

	local time = 0
	self.extraUI.countdownImg:scheduleUpdateWithPriorityLua(function (dt)
		time = time + dt
		if time > 0.1 then
			time = 0
			if not coroutine.resume(co) then
				self.extraUI.countdownImg:unscheduleUpdate()
			end
		end
	end, 0)

	self.customObj.round = self.customObj.round + 1
	self.extraUI.infoNumLabel1:setString(tostring(self.customObj.round + self.customObj.condition))
	self.customObj.dispatching = true

	self:updateNum()
end

function BattlerDestinyUI:updateNum()
	local dropNum = 0
	local randomNum = GlobalApi:random(0, 100)
	local dropExpect = math.floor(self.customObj.dropExpect)
	if dropExpect > self.customObj.dropNum then
		dropNum = dropNum + dropExpect - self.customObj.dropNum
		self.customObj.dropNum = dropExpect
	end
	if self.customObj.dropExpect - self.customObj.dropNum > randomNum/100 then
		dropNum = dropNum + 1
		self.customObj.dropNum = self.customObj.dropNum + 1
	end
	self.customObj.dropExpect = self.customObj.dropExpect + self.customObj.dropProb/100
	local label = self.extraUI.numLabel1
	local old = tonumber(label:getString())
	local new = math.floor((self.customObj.dropNum + self.customObj.baseAwardNum1)*self.customObj.jadeSealAddition)
	GlobalApi:runNum(label,'LabelAtlas','BattlerDestinyUI',old,new)
end

return BattlerDestinyUI