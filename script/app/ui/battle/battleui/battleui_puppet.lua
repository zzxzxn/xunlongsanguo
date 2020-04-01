local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local BattlePuppetUI = class("BattlePuppetUI", BaseBattleUI)

function BattlePuppetUI:initExtraUI()
	local winsize = cc.Director:getInstance():getWinSize()
	local extraNode = self.root:getChildByName("extra_node")
	extraNode:setPosition(cc.p(winsize.width, winsize.height))
	extraNode:setVisible(true)
	
    local frame1 = extraNode:getChildByName("frame_1")
	frame1:setPosition(cc.p(-174, -220))
	local icon = frame1:getChildByName("icon")
	icon:setTexture("uires/icon/user/gold.png")
    local numLabel1 = cc.LabelAtlas:_create(tostring(0), "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
	numLabel1:setAnchorPoint(cc.p(0, 0.5))
	numLabel1:setPosition(cc.p(-146, -220))
	extraNode:addChild(numLabel1)
    local frame2 = extraNode:getChildByName("frame_2")
	frame2:setVisible(false)

	local infoLabel1 = extraNode:getChildByName("info_tx_1")
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_KILL") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
    infoNumLabel1:setString('0')
    --[[
	local infoLabel2 = extraNode:getChildByName("info_tx_2")
	infoLabel2:setString('')
	local infoNumLabel2 = extraNode:getChildByName("info_num_tx_2")
	infoNumLabel2:setString(self.customObj.highKillCount)
    --]]
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
    local des = GlobalApi:getLocalStr('TERRITORIAL_WAL_PUPPET5')
    local descLabel = cc.Label:createWithTTF(des, "font/gamefont.ttf", 25)
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

	self.customObj.dropNum = 0
	self.customObj.round = 1

	self.overTime = self.customObj.totalTime
    local str = TerritorialWarMgr:getTime(self.overTime,true)
	self.timeLabel:setString(str)
end

function BattlePuppetUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		
	}
	MessageMgr:sendPost("challenge_before_fight", "territorywar", json.encode(args), function (jsonObj)
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

function BattlePuppetUI:sendMessageAfterFight(isWin)
	local args = {
		killCount = self.dieNum[2],
		round = self.customObj.round,
		sig = self:generateVerifyMD5()
	}
	MessageMgr:sendPost("challenge_fight", "territorywar", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
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
function BattlePuppetUI:addDieNum(guid, position, soldierType)
	self.super.addDieNum(self, guid, position, soldierType)
	if guid == 2 then
		self.extraUI.infoNumLabel1:setString(tostring(self.dieNum[2]))

        local gold = self.dieNum[2]*self.customObj.baseAward
		self.extraUI.numLabel1:stopAllActions()
		self.extraUI.numLabel1:runAction(cc.DynamicNumberTo:create("LabelAtlas", 1, gold))
	end
end

function BattlePuppetUI:addKillAnimation()

end

function BattlePuppetUI:battleEnd(isWin, timeoutFlag)
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

function BattlePuppetUI:dispatchLegion()
	local legionArr = self.customObj.legionArr
	local round = self.customObj.round
    
    local maxRound = self.customObj.maxRound
	if round > maxRound then
		round = maxRound
	end
    
	local needMonsterCount = self.customObj.needMonsterCount
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
		local factor = math.pow(self.customObj.addFactor, self.customObj.round-1)
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

return BattlePuppetUI