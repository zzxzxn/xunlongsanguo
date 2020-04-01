local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local BattleGoldUI = class("BattleGoldUI", BaseBattleUI)

function BattleGoldUI:initExtraUI()
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
	if #self.customObj.conf.baseReward > 0 then
		self.customObj.baseAwardNum = self.customObj.conf.baseReward[1][3]
	else
		self.customObj.baseAwardNum = 0
	end

	local frame1 = extraNode:getChildByName("frame_1")
	frame1:setPosition(cc.p(-174, -220))
	local icon = frame1:getChildByName("icon")
	icon:setTexture("uires/icon/user/gold.png")
	local numLabel1 = cc.LabelAtlas:_create(tostring(math.floor(self.customObj.baseAwardNum*self.customObj.jadeSealAddition)), "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
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
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_DAMAGE") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
	infoNumLabel1:setString(tostring(self.customObj.conf.condition))
	local infoLabel2 = extraNode:getChildByName("info_tx_2")
	infoLabel2:setString(GlobalApi:getLocalStr("STR_HISTORY_HIGHEST") .. "：")
	local infoNumLabel2 = extraNode:getChildByName("info_num_tx_2")
	infoNumLabel2:setString(tostring(self.customObj.highestDmg))

	local topBg = self.fightPl:getChildByName("top_bg")
    topBg:setTexture("uires/ui/battle/battleui_bg_top2.png")
    local x, y = topBg:getPosition()
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
		infoNumLabel1 = infoNumLabel1,
		descImg = descImg
	}

	self.overTime = 120
	self.timeLabel:setString("02:00")

	if self.customObj.hurtCount and self.customObj.hurtCount > 0 then
		local gold = math.floor(self.customObj.jadeSealAddition*(self.customObj.hurtCount*self.customObj.conf.goldFactor/10000 + self.customObj.baseAwardNum))
		self.extraUI.numLabel1:setString(gold)
		self.extraUI.infoNumLabel1:setString(tostring(math.floor(self.customObj.hurtCount) +  self.customObj.condition))
	else
		self.customObj.hurtCount = 0
	end
end

function BattleGoldUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		type = "gold",
		id = self.customObj.id
	}
	MessageMgr:sendPost("before_fight", "rescopy", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
        	self.verifyObj.pos = jsonObj.data.rand_pos or 1
			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
        	self.extraUI.descImg:removeFromParent()
        	self:battleStart()
        else
        	promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
        end
	end)
end

function BattleGoldUI:sendMessageAfterFight(isWin)
	local starNum = isWin and self.starNum or 0
	local roleMap = RoleData:getRoleMap()
	local heroTotalLv = 0
	for k, heroObj in pairs(roleMap) do
		heroTotalLv = heroTotalLv + heroObj:getLevel()
	end
	local args = {
		id = self.customObj.id,
		damage = math.floor(self.customObj.hurtCount),
		star = starNum,
		sig = self:generateVerifyMD5(),
		ff = self.armyData.fightforce,
		levels = heroTotalLv
	}
	MessageMgr:sendPost("fight_gold", "rescopy", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			local info = UserData:getUserObj():getRescopyinfo()
			info.gold.count = info.gold.count + 1
			info.gold.damage = jsonObj.data.damage or info.gold.damage
			info.gold.difficulty = jsonObj.data.difficulty or info.gold.difficulty
			info.gold.first = jsonObj.data.first or info.gold.first
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

function BattleGoldUI:addHurtCount(num, guid, soldierType)
	self.super.addHurtCount(self, num, guid, soldierType)
	if guid == 2 and soldierType == 1 then
		if self.extraUI then
			self.customObj.hurtCount = self.customObj.hurtCount - num
			local gold = math.floor(self.customObj.jadeSealAddition*(self.customObj.hurtCount*self.customObj.conf.goldFactor/10000 + self.customObj.baseAwardNum))
			self.extraUI.numLabel1:stopAllActions()
			self.extraUI.numLabel1:runAction(cc.DynamicNumberTo:create("LabelAtlas", 1, gold))
			self.extraUI.infoNumLabel1:setString(tostring(math.floor(self.customObj.hurtCount) +  self.customObj.condition))
		else
			self.customObj.hurtCount = self.customObj.hurtCount or 0
			self.customObj.hurtCount = self.customObj.hurtCount - num
		end
	end
end

function BattleGoldUI:addKillAnimation()
end

function BattleGoldUI:battleEnd(isWin, timeoutFlag)
    self.super.battleEnd(self, true, timeoutFlag)
end

return BattleGoldUI