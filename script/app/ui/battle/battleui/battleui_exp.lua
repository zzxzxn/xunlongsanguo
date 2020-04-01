local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local BattleEXPUI = class("BattleEXPUI", BaseBattleUI)

function BattleEXPUI:initExtraUI()
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
	self.customObj.baseAwardNum2 = 0
	if self.customObj.conf.baseReward[1] then
		self.customObj.baseAwardNum1 = self.customObj.conf.baseReward[1][3]
	end
	if self.customObj.conf.baseReward[2] then
		self.customObj.baseAwardNum2 = self.customObj.conf.baseReward[2][3]
	end

	local dropConf = GameData:getConfData("drop")[self.customObj.conf.drop]
	local award1 = dropConf.award1
	local award2 = dropConf.award2
	local awardObj1 = DisplayData:getDisplayObj(award1[1])
	self.customObj.dropIcon1 = awardObj1:getIcon()
	self.customObj.weight1 = dropConf.weight1

	local frame1 = extraNode:getChildByName("frame_1")
	frame1:setTexture(awardObj1:getBgImg())
	local icon = frame1:getChildByName("icon")
	icon:setTexture(awardObj1:getIcon())
	local numLabel1 = cc.LabelAtlas:_create(tostring(math.floor(self.customObj.baseAwardNum1*self.customObj.jadeSealAddition)), "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
	numLabel1:setAnchorPoint(cc.p(0, 0.5))
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
	local numLabel2 = nil
	local awardObj2
	if #award2 > 0 then
		awardObj2 = DisplayData:getDisplayObj(award2[1])
		frame2:setTexture(awardObj2:getBgImg())
		local icon2 = frame2:getChildByName("icon")
		icon2:setTexture(awardObj2:getIcon())
		self.customObj.dropIcon2 = awardObj2:getIcon()
		self.customObj.weight2 = dropConf.weight2
		self.customObj.targetPos2 = frame2:convertToWorldSpace(cc.p(icon2:getPosition()))
		numLabel1:setPosition(cc.p(-146, -192))
		numLabel2 = cc.LabelAtlas:_create(tostring(math.floor(self.customObj.baseAwardNum2*self.customObj.jadeSealAddition)), "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
		numLabel2:setAnchorPoint(cc.p(0, 0.5))
		numLabel2:setPosition(cc.p(-146, -250))
		extraNode:addChild(numLabel2)
		if addition[1] then
			local upImg2 = ccui.ImageView:create("uires/ui/common/arrow_up3.png")
			upImg2:setPosition(cc.p(90, 16))
			frame2:addChild(upImg2)

			local upTx2 = ccui.Text:create()
			upTx2:setAnchorPoint(cc.p(1, 0.5))
			upTx2:setFontName("font/gamefont.ttf")
			upTx2:setFontSize(26)
			upTx2:setTextColor(COLOR_TYPE.GREEN)
			upTx2:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
			upTx2:setString(addition[2] .. "%")
			upTx2:setPosition(cc.p(78, 16))
			frame2:addChild(upTx2)
		end
	else
		self.customObj.weight2 = 0
		numLabel1:setPosition(cc.p(-146, -220))
		frame1:setPosition(cc.p(-174, -220))
		frame2:setVisible(false)
	end
	self.customObj.targetPos1 = frame1:convertToWorldSpace(cc.p(icon:getPosition()))
	
	local infoLabel1 = extraNode:getChildByName("info_tx_1")
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_KILL") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
	infoNumLabel1:setString(tostring(self.customObj.condition))
	local infoLabel2 = extraNode:getChildByName("info_tx_2")
	infoLabel2:setString(GlobalApi:getLocalStr("STR_HIGHEST_KILL") .. "：")
	local infoNumLabel2 = extraNode:getChildByName("info_num_tx_2")
	infoNumLabel2:setString(self.customObj.highestKill)

	local topBg = self.fightPl:getChildByName("top_bg")
	local x, y = topBg:getPosition()
    topBg:setTexture("uires/ui/battle/battleui_bg_top2.png")
    local topSp = self.fightPl:getChildByName("top_sp")
    topSp:setVisible(false)
    self.playerHealth[1].healthBar:ignoreContentAdaptWithSize(true)
    self.playerHealth[1].healthBar:loadTexture("uires/ui/battle/battleui_playerhealth_3.png")
    self.playerHealth[1].healthBar:setPosition(cc.p(x, y))
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
		numLabel2 = numLabel2,
		infoNumLabel1 = infoNumLabel1,
		descImg = descImg
	}
	self.customObj.dropProb = self.customObj.conf.dropExpect
	self.customObj.dropExpect = self.customObj.conf.dropExpect/100
	self.customObj.dropNum = 0
	self.customObj.dropNum1 = 0
	self.customObj.dropNum2 = 0
	self.customObj.round = 1

	self.overTime = 120
	self.timeLabel:setString("02:00")
end

function BattleEXPUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		type = "xp",
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

function BattleEXPUI:sendMessageAfterFight(isWin)
	local roleMap = RoleData:getRoleMap()
	local heroTotalLv = 0
	for k, heroObj in pairs(roleMap) do
		heroTotalLv = heroTotalLv + heroObj:getLevel()
	end
	local args = {
		kill = self.dieNum[2],
		id = self.customObj.id,
		drop = self.customObj.dropNum,
		round = self.customObj.round,
		sig = self:generateVerifyMD5(),
		ff = self.armyData.fightforce,
		levels = heroTotalLv
	}
	MessageMgr:sendPost("fight_xp", "rescopy", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
        	local info = UserData:getUserObj():getRescopyinfo()
			info.xp.count = info.xp.count + 1
			info.xp.kill = jsonObj.data.kill or info.xp.kill
			info.xp.difficulty = jsonObj.data.difficulty or info.xp.difficulty
			info.xp.first = jsonObj.data.first or info.xp.first
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

-- 死亡统计
function BattleEXPUI:addDieNum(guid, position, soldierType)
	self.super.addDieNum(self, guid, position, soldierType)
	if guid == 2 then
		self.extraUI.infoNumLabel1:setString(tostring(self.dieNum[2] + self.customObj.condition))
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
		for i = 1, dropNum do
			local index = 1
			local res
			local randomNum2 = GlobalApi:random(0, self.customObj.weight1+self.customObj.weight2)
			if randomNum2 >= self.customObj.weight1 then
				res = self.customObj.dropIcon2
				index = 2
			else
				res = self.customObj.dropIcon1
			end
			local boxImg = ccui.ImageView:create(res)
			boxImg:setScale(0.6)
			boxImg:setPosition(position)
			self.bgImg:addChild(boxImg)
			BattleHelper:setSpecialNodeZorder(boxImg)

			local jumpPos = cc.p(math.random(40, 60), 0)
			local function moveToUI(imgIndex)
				local newpos = self.bgImg:convertToWorldSpace(cc.p(position.x+jumpPos.x, position.y))
				boxImg:setPosition(newpos)
				boxImg:retain()
				boxImg:removeFromParent(false)
				self.root:addChild(boxImg)
				boxImg:setLocalZOrder(1)
				boxImg:release()
				local targetPos
				local numLabel
				local num
				if imgIndex == 1 then
					targetPos = self.customObj.targetPos1
					numLabel = self.extraUI.numLabel1
					self.customObj.dropNum1 = self.customObj.dropNum1 + 1
					num = math.floor((self.customObj.dropNum1 + self.customObj.baseAwardNum1)*self.customObj.jadeSealAddition)
				else
					targetPos = self.customObj.targetPos2
					numLabel = self.extraUI.numLabel2
					self.customObj.dropNum2 = self.customObj.dropNum2 + 1
					num = math.floor((self.customObj.dropNum2 + self.customObj.baseAwardNum2)*self.customObj.jadeSealAddition)
				end
				local dis = cc.pGetDistance(newpos, targetPos)
				local time = dis/250
				local moveAct2 = cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveTo:create(time, targetPos)), cc.CallFunc:create(function ()
					boxImg:removeFromParent()
					numLabel:setString(tostring(num))
				end))
				boxImg:runAction(moveAct2)
			end
			local moveAct = cc.Sequence:create(cc.JumpBy:create(0.4, jumpPos, 50, 1), cc.DelayTime:create(1), cc.CallFunc:create(function ()
				moveToUI(index)
			end))
			boxImg:runAction(moveAct)
		end
	end
end

function BattleEXPUI:addKillAnimation()
end

function BattleEXPUI:battleEnd(isWin, timeoutFlag)
	if isWin then
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
		self:dispatchLegion()
	else
		self.super.battleEnd(self, true, timeoutFlag)
	end
end

function BattleEXPUI:dispatchLegion()
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
			end
		end)
	end
	self.customObj.round = self.customObj.round + 1
end

return BattleEXPUI