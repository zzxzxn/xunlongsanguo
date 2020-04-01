local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local BattleTimeLimitDefenceUI = class("BattleTimeLimitDefenceUI", ClassBattleUI)

local LEGION_POS = BattleHelper.ENUM.LEGION_POS

local APPEAR_INTERVAL_1 = 10
local APPEAR_INTERVAL_2 = 10

function BattleTimeLimitDefenceUI:initExtraUI()
	local winsize = cc.Director:getInstance():getWinSize()
	local topBg = self.fightPl:getChildByName("top_bg")
	local x, y = topBg:getPosition()
	topBg:setTexture("uires/ui/battle/battleui_bg_top2.png")
	local topSp = self.fightPl:getChildByName("top_sp")
	topSp:setVisible(false)
	self.playerHealth[1].healthBar:ignoreContentAdaptWithSize(true)
	self.playerHealth[1].healthBar:loadTexture("uires/ui/battle/battleui_playerhealth_3.png")
	self.playerHealth[1].healthBar:setPosition(cc.p(x, y))
	self.playerHealth[2].healthBar:setVisible(false)

	-- 倒计时
	local countdownImg = ccui.ImageView:create("uires/ui/battle/countdown_img.png")
	local countdownSize = countdownImg:getContentSize()
	countdownImg:setPosition(cc.p(winsize.width-66, winsize.height/2))
	countdownImg:setTouchEnabled(true)
	countdownImg:addClickEventListener(function ()
		self.customObj.time = self.time + APPEAR_INTERVAL_1
		self.extraUI.countdownImg:setVisible(false)
		self.extraUI.countdownQuan:stopAllActions()
		self:dispatchLegion()
	end)
	self.battleBgPl:addChild(countdownImg)
	countdownImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.6, 1.1), cc.ScaleTo:create(0.6, 1))))
	countdownImg:setVisible(false)

	local countdownQuan = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/battle/countdown_quan.png"))
	countdownQuan:setPosition(cc.p(countdownSize.width/2, countdownSize.height/2))
	countdownQuan:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    countdownQuan:setMidpoint(cc.p(0.5, 0.5))
    countdownQuan:setPercentage(0)
    countdownImg:addChild(countdownQuan)

    local descImg = ccui.ImageView:create("uires/ui/common/name_bg21.png")
    descImg:setCascadeOpacityEnabled(true)
    descImg:setVisible(false)
   	local descImgSize = descImg:getContentSize()
    local descLabel = cc.Label:createWithTTF(GlobalApi:getLocalStr("GET_WIN_AFTER_SEVERAL_ATTACK"), "font/gamefont.ttf", 25)
    descLabel:setTextColor(COLOR_TYPE.WHITE)
    descLabel:enableOutline(cc.c4b(131, 86, 66, 255), 2)
    descLabel:setPosition(cc.p(descImgSize.width/2, descImgSize.height/2))
    descImg:addChild(descLabel)
    local remainRoundLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    remainRoundLabel:setTextColor(COLOR_TYPE.GREEN)
    remainRoundLabel:enableOutline(cc.c4b(131, 86, 66, 255), 2)
    remainRoundLabel:setPosition(cc.p(descImgSize.width/2 - 70, descImgSize.height/2))
    descImg:addChild(remainRoundLabel)
    local npc = ccui.ImageView:create("uires/ui/battle/npc_1.png")
    npc:setPosition(cc.p(descImgSize.width - 70, 36))
    descImg:addChild(npc)
    local topPlSize = self.topPl:getContentSize()
    local descImgStartPos = cc.p(topPlSize.width/2, topPlSize.height + 120)
    descImg:setPosition(descImgStartPos)
	self.topPl:addChild(descImg)

    self.extraUI = {
		countdownImg = countdownImg,
		countdownQuan = countdownQuan,
		descImg = descImg,
		descLabel = descLabel,
		remainRoundLabel = remainRoundLabel
	}

	self.customObj.round = 1
	self.customObj.time = APPEAR_INTERVAL_1 + APPEAR_INTERVAL_2
	self.customObj.dispatching = false
	self.customObj.descImgStartPos = descImgStartPos
end

function BattleTimeLimitDefenceUI:calculateStar()
	if self.dieLegionNum[1] > 3 then
		self.starNum = 1
	elseif self.dieLegionNum[1] > 1 then
		self.starNum = 2
	end
end

function BattleTimeLimitDefenceUI:sendMessageBeforeFight()
	self:battleStart()
end

function BattleTimeLimitDefenceUI:sendMessageAfterFight(isWin)
	local starNum = isWin and self.starNum or 0
	BattleMgr:showBattleResult(isWin, {}, starNum)
end

function BattleTimeLimitDefenceUI:battleEnd(isWin, timeoutFlag)
	if isWin then
		if self.customObj.round >= self.customObj.maxRound then
			self.super.battleEnd(self, isWin, timeoutFlag)
		else
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

					local winsize = cc.Director:getInstance():getWinSize()
					self.extraUI.descImg:stopAllActions()
					self.extraUI.descImg:setVisible(true)
					self.extraUI.remainRoundLabel:setString(tostring(self.customObj.maxRound - self.customObj.round))
					self.extraUI.descImg:setOpacity(255)
					self.extraUI.descImg:setPosition(self.customObj.descImgStartPos)
					self.extraUI.descImg:runAction(cc.Sequence:create(cc.MoveBy:create(0.6, cc.p(0, -240)), cc.DelayTime:create(3), cc.FadeOut:create(1), cc.CallFunc:create(function()
						self.extraUI.descImg:setVisible(false)
					end)))
				end
			end
		end
	else
		self.super.battleEnd(self, isWin, timeoutFlag)
	end
end

function BattleTimeLimitDefenceUI:updateTime()
	if (self.time - self.customObj.time) > 0 and self.customObj.round < self.customObj.maxRound then
		self.customObj.time = self.time + APPEAR_INTERVAL_1 + APPEAR_INTERVAL_2
		self.extraUI.countdownImg:setVisible(true)
		self.extraUI.countdownQuan:setPercentage(0)
		self.extraUI.countdownQuan:runAction(cc.Sequence:create(cc.ProgressTo:create(APPEAR_INTERVAL_2, 100), cc.CallFunc:create(function ()
			self.extraUI.countdownImg:setVisible(false)
			self:dispatchLegion()
    	end)))

    	local winsize = cc.Director:getInstance():getWinSize()
		self.extraUI.descImg:stopAllActions()
		self.extraUI.descImg:setVisible(true)
		self.extraUI.remainRoundLabel:setString(tostring(self.customObj.maxRound - self.customObj.round))
		self.extraUI.descImg:setOpacity(255)
		self.extraUI.descImg:setPosition(self.customObj.descImgStartPos)
		self.extraUI.descImg:runAction(cc.Sequence:create(cc.MoveBy:create(0.6, cc.p(0, -240)), cc.DelayTime:create(3), cc.FadeOut:create(1), cc.CallFunc:create(function()
			self.extraUI.descImg:setVisible(false)
		end)))
	end
	self.super.updateTime(self)
end

function BattleTimeLimitDefenceUI:dispatchLegion()
	if self.customObj.round >= self.customObj.maxRound then
		self.extraUI.countdownImg:setVisible(false)
		return
	end
	local num = 0
	local maxNum = #self.customObj.legionArr
	local newLegions = {}
	local co = coroutine.create(function ()
		for k, v in ipairs(self.customObj.legionArr) do
			local legionPos = v.info.pos
			local newLegionPos = legionPos + self.customObj.round*9
			local newV = clone(v)
			newV.info.pos = newLegionPos
			local enemyLegion = self:createLegion(2, newV, false)
			table.insert(newLegions, enemyLegion)
			enemyLegion:setPosition(cc.p(2000, LEGION_POS[2][legionPos].y))
			enemyLegion:moveToPosition(cc.p(LEGION_POS[2][legionPos].x, LEGION_POS[2][legionPos].y), function ()
				num = num + 1
				if num == maxNum then
					for k3, v3 in ipairs(newLegions) do
						self.enemyMap[v3.pos] = v3
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
	self.customObj.dispatching = true
end

function BattleTimeLimitDefenceUI:addKillAnimation()
end

return BattleTimeLimitDefenceUI