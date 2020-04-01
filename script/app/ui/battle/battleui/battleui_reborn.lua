local BattleHelper = require("script/app/ui/battle/battlehelper")
local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS

local ADD_ATK_DURATION = 10 -- 每10秒加一次攻击

local BattlerRebornUI = class("BattlerRebornUI", BaseBattleUI)

function BattlerRebornUI:initExtraUI()
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

	local frame1 = extraNode:getChildByName("frame_1")
	frame1:setPosition(cc.p(-174, -220))
	frame1:setTexture(awardObj1:getBgImg())
	local icon = frame1:getChildByName("icon")
	icon:setTexture(awardObj1:getIcon())

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
	infoLabel1:setString(GlobalApi:getLocalStr("STR_CURR_TIME") .. "：")
	local infoNumLabel1 = extraNode:getChildByName("info_num_tx_1")
	infoNumLabel1:setString(tostring(self.customObj.condition))
	local infoLabel2 = extraNode:getChildByName("info_tx_2")
	infoLabel2:setString(GlobalApi:getLocalStr("STR_HISTORY_HIGHEST") .. "：")
	local infoNumLabel2 = extraNode:getChildByName("info_num_tx_2")
	infoNumLabel2:setString(self.customObj.highestTime)

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
		infoNumLabel1 = infoNumLabel1,
		descImg = descImg
	}

	self.customObj.dropProb = self.customObj.conf.dropExpect
	self.customObj.dropExpect = self.customObj.conf.dropExpect/100
	self.customObj.dropNum = 0
	self.customObj.time = self.customObj.conf.dropTimeDuration
	self.customObj.addTimes = 0
	self.customObj.addAtkTimes = 0

	self.overTime = 120
	self.timeLabel:setString("02:00")
end

function BattlerRebornUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		formation[v.legionInfo.rolePos] = k
	end
	-- 保存阵型
	UserData:getUserObj():setFormation(formation)
	local args = {
		type = "reborn",
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

function BattlerRebornUI:sendMessageAfterFight(isWin)
	local roleMap = RoleData:getRoleMap()
	local heroTotalLv = 0
	for k, heroObj in pairs(roleMap) do
		heroTotalLv = heroTotalLv + heroObj:getLevel()
	end
	local args = {
		time = math.floor(self.time),
		id = self.customObj.id,
		drop = self.customObj.dropNum,
		sig = self:generateVerifyMD5(),
		ff = self.armyData.fightforce,
		levels = heroTotalLv
	}
	MessageMgr:sendPost("fight_reborn", "rescopy", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
        	local info = UserData:getUserObj():getRescopyinfo()
			info.reborn.count = info.reborn.count + 1
			info.reborn.time = jsonObj.data.time or info.reborn.time
			info.reborn.difficulty = jsonObj.data.difficulty or info.reborn.difficulty
			info.reborn.first = jsonObj.data.first or info.reborn.first
        	local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
        	BattleMgr:showBattleResult(true, displayAwards, 3, nil,nil,false,nil,true)
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

function BattlerRebornUI:updateTime()
	self.super.updateTime(self)
	self.extraUI.infoNumLabel1:setString(tostring(math.floor(self.time) + self.customObj.condition))
	local addTimes = math.floor(self.time/self.customObj.time)
	if addTimes > self.customObj.addTimes then
		local dropNum = 0
		for i = self.customObj.addTimes + 1, addTimes do
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
		end
		self.customObj.addTimes = addTimes
		self.extraUI.numLabel1:setString(tostring(math.floor((self.customObj.dropNum + self.customObj.baseAwardNum1)*self.customObj.jadeSealAddition)))
	end
	local addAtkTimes = math.floor(self.time/ADD_ATK_DURATION)
	if addAtkTimes > self.customObj.addAtkTimes then
		for k, v in pairs(self.enemyMap) do
			if not v.heroObj:isDead() then
				v.heroObj.atk = v.heroObj.atk + self.customObj.conf.addFactor
			end
			for k2, soldierObj in pairs(v.soldierObjs) do
				if not soldierObj:isDead() then
					soldierObj.atk = soldierObj.atk + self.customObj.conf.addFactor
				end
			end
			for k2, summonObj in pairs(v.summonObjs) do
				if not summonObj:isDead() then
					summonObj.atk = summonObj.atk + self.customObj.conf.addFactor
				end
			end
		end
		self.customObj.addAtkTimes = addAtkTimes
	end
end

function BattlerRebornUI:addKillAnimation()

end

function BattlerRebornUI:battleEnd(isWin, timeoutFlag)
    self.super.battleEnd(self, true, timeoutFlag)
end

return BattlerRebornUI