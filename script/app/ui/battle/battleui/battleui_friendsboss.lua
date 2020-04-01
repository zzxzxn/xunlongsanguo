local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local BattleFriendsBOSSUI = class("BattleFriendsBOSSUI", BaseBattleUI)

function BattleFriendsBOSSUI:initExtraUI()
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
		local num = math.ceil(self.customObj.hurtCount/self.customObj.radio)
		self.extraUI.numLabel1:setString(tostring(num))
		self.extraUI.infoNumLabel1:setString(GlobalApi:toWordsNumber(math.floor(self.customObj.hurtCount)))
	else
		self.customObj.hurtCount = 0
	end
end

function BattleFriendsBOSSUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		bossOwnerId = self.customObj.bossownerid
	}
	MessageMgr:sendPost("before_fight", "friend", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			self.verifyObj.pos = jsonObj.data.rand_pos or 1
			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
			self.extraUI.descImg:removeFromParent()
			self:battleStart()
		elseif code == 100 then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("FRIENDS_MSG_DESC_13"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
		elseif code == 104 then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("FRIENDS_DESC_51"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
		end
	end)
end

function BattleFriendsBOSSUI:sendMessageAfterFight(isWin)
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
	local hurtArr = {}
    local pos = {}
	for k, v in ipairs(numtab) do
		table.insert(hurtArr, v.hurt)
        table.insert(pos,v.pos)
	end
	local args = {
		bossOwnerId = self.customObj.bossownerid,
		damage = hurtArr,
        pos = pos,
		sig = self:generateVerifyMD5()
	}
	MessageMgr:sendPost("fight", "friend", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
            local lastLv = UserData:getUserObj():getLv()
			GlobalApi:parseAwardData(jsonObj.data.awards)
			local costs = jsonObj.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
            local kingLvUpData = {}
            kingLvUpData.lastLv = lastLv
            kingLvUpData.nowLv = UserData:getUserObj():getLv()
            local score = math.ceil(self.customObj.hurtCount/self.customObj.radio)
			BattleMgr:showFriendsBossResult(self.customObj.hurtCount, score, displayAwards, 3, nil, kingLvUpData)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR1"), MESSAGE_BOX_TYPE.MB_OK, function ()
				BattleMgr:exitBattleField()
			end)
		end
	end)
end

function BattleFriendsBOSSUI:addHurtCount(num, guid, soldierType)
	self.super.addHurtCount(self, num, guid, soldierType)
	if guid == 2 and soldierType == 1 then
		if self.extraUI then
			local num1 = math.ceil(self.customObj.hurtCount/self.customObj.radio)
			self.customObj.hurtCount = self.customObj.hurtCount - num
			local num2 = math.ceil(self.customObj.hurtCount/self.customObj.radio)
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

return BattleFriendsBOSSUI