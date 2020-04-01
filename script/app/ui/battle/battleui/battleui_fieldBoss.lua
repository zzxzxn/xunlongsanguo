local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local BattleFieldBOSSUI = class("BattleFieldBOSSUI", BaseBattleUI)

function BattleFieldBOSSUI:initExtraUI()
	local winsize = cc.Director:getInstance():getWinSize()
	local extraNode = self.root:getChildByName("extra_node")
	extraNode:setPosition(cc.p(winsize.width, winsize.height))
	extraNode:setVisible(true)

	local frame1 = extraNode:getChildByName("frame_1")
	local frame2 = extraNode:getChildByName("frame_2")
	frame1:setVisible(false)
	frame2:setVisible(false)

	local titleTx = ccui.Text:create()
	titleTx:setFontName("font/gamefont.ttf")
    titleTx:setFontSize(28)
    titleTx:setAnchorPoint(cc.p(0, 0.5))
    titleTx:setTextColor(COLOR_TYPE.YELLOW)
    titleTx:enableOutline(cc.c4b(138, 62, 16, 255), 1)
    titleTx:setString(GlobalApi:getLocalStr("SCORE"))
    titleTx:setPosition(cc.p(-194, -192))
    extraNode:addChild(titleTx)

    local numLabel1 = cc.LabelAtlas:_create("0", "uires/ui/number/font_rescopy.png", 22, 25, string.byte('0'))
	numLabel1:setAnchorPoint(cc.p(1, 0.5))
	numLabel1:setPosition(cc.p(-36, -236))
	extraNode:addChild(numLabel1)

	local infoLabel1 = extraNode:getChildByName("info_tx_1")
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_DAMAGE") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
	infoNumLabel1:setString("0")

    local descImg = ccui.ImageView:create("uires/ui/common/name_bg21.png")
    descImg:setLocalZOrder(-1)
   	local descImgSize = descImg:getContentSize()
    local descLabel = cc.Label:createWithTTF(GlobalApi:getLocalStr("FRIENDS_BOSS_INFO_1"), "font/gamefont.ttf", 25)
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
	if self.customObj.hurtCount and self.customObj.hurtCount > 0 then
		local num = self.customObj.hurtCount/self.customObj.radio
		num = math.floor(num*(1+self.customObj.addParam))
		self.extraUI.numLabel1:setString(tostring(num))
		self.extraUI.infoNumLabel1:setString(GlobalApi:toWordsNumber(math.floor(self.customObj.hurtCount)))
	else
		self.customObj.hurtCount = 0
	end
end

function BattleFieldBOSSUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		cellId = self.customObj.cellId
	}
	MessageMgr:sendPost("before_fight_boss", "territorywar", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			self.verifyObj.pos = jsonObj.data.rand_pos or 1
			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
			self.extraUI.descImg:removeFromParent()
			self:battleStart()
		else
			local errorStr = (code == 210) and GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT42") or GlobalApi:getLocalStr("STR_BATTLE_ERROR")
			promptmgr:showMessageBox(errorStr, MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
		end
	end)
end

function BattleFieldBOSSUI:sendMessageAfterFight(isWin)
	local numtab = {}
	for k, v in pairs(self.enemyMap) do
		local obj = {
			pos = v.pos,
			hurt = v.heroObj:getHurtCount()
		}
		table.insert(numtab, obj)
	end
	table.sort(numtab, function (a, b)
		return a.pos < b.pos
	end)
	
	local damage = 0
	for k, v in ipairs(numtab) do
		damage = damage + v.hurt
	end
	
	local roleMap = RoleData:getRoleMap()
	local heroTotalLv = 0
	for k, heroObj in pairs(roleMap) do
		heroTotalLv = heroTotalLv + heroObj:getLevel()
	end
	local args = {
		cellId = self.customObj.cellId,
		damage = damage,
		sig = self:generateVerifyMD5(),
		ff = self.armyData.fightforce,
		levels = heroTotalLv
	}
	MessageMgr:sendPost("fight_boss", "territorywar", json.encode(args), function (jsonObj)
		local code = jsonObj.code
        if code == 0 then

			GlobalApi:parseAwardData(jsonObj.data.awards)
			local costs = jsonObj.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
			local score = damage/self.customObj.radio
            score = math.floor(score*(1+self.customObj.addParam))
			BattleMgr:showFriendsBossResult(damage, score, displayAwards, 3)

        else
			 promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
        end
	end)
end

function BattleFieldBOSSUI:addHurtCount(num, guid, soldierType)
	self.super.addHurtCount(self, num, guid, soldierType)
	if guid == 2 and soldierType == 1 then
		if self.extraUI then
			local num1 = self.customObj.hurtCount/self.customObj.radio
			num1 = math.floor(num1*(1+self.customObj.addParam))
			self.customObj.hurtCount = self.customObj.hurtCount - num
			local num2 = self.customObj.hurtCount/self.customObj.radio
			num2 = math.floor(num2*(1+self.customObj.addParam))
			self.extraUI.numLabel1:stopAllActions()
			self.extraUI.numLabel1:setString(tostring(num1))
			self.extraUI.numLabel1:runAction(cc.DynamicNumberTo:create("LabelAtlas", 1, num2))
			self.extraUI.infoNumLabel1:setString(GlobalApi:toWordsNumber(math.floor(self.customObj.hurtCount)))
		else
			self.customObj.hurtCount = self.customObj.hurtCount or 0
			self.customObj.hurtCount = self.customObj.hurtCount - num
		end
	end
end

return BattleFieldBOSSUI