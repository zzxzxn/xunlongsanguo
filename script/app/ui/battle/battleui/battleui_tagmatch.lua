local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local BattleTagMatchUI = class("BattleTagMatchUI", ClassBattleUI)

local LEGION_POS = BattleHelper.ENUM.LEGION_POS

function BattleTagMatchUI:initCompleted()
	local topBg = self.fightPl:getChildByName("top_bg")
	local x, y = topBg:getPosition()
	topBg:setTexture("uires/ui/battle/battleui_bg_top2.png")
	local topSp = self.fightPl:getChildByName("top_sp")
	topSp:setVisible(false)
	self.playerHealth[1].healthBar:ignoreContentAdaptWithSize(true)
	self.playerHealth[1].healthBar:loadTexture("uires/ui/battle/battleui_playerhealth_3.png")
	self.playerHealth[1].healthBar:setPosition(cc.p(x, y))
	self.playerHealth[2].healthBar:setVisible(false)
	self.customObj.round = 1
end

-- 40秒内击败守卫为3星，60秒内击败守卫为2星
function BattleTagMatchUI:calculateStar()
	if self.time >= 111 then
		self.starNum = 1
	elseif self.time >= 101 then
		self.starNum = 2
	end
end

function BattleTagMatchUI:sendMessageBeforeFight()
	self:battleStart()
end

function BattleTagMatchUI:sendMessageAfterFight(isWin)
	local starNum = isWin and self.starNum or 0
	BattleMgr:showBattleResult(isWin, {}, starNum)
end

function BattleTagMatchUI:battleEnd(isWin, timeoutFlag)
	if isWin then
		if self.customObj.round >= #self.customObj.legionArr then
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
			self:dispatchLegion()
		end
	else
		self.super.battleEnd(self, isWin, timeoutFlag)
	end
end

function BattleTagMatchUI:dispatchLegion()
	self.customObj.round = self.customObj.round + 1
	local nextLegionData = self.customObj.legionArr[self.customObj.round]
	local legionPos = nextLegionData.info.pos
	local enemyLegion = self:createLegion(2, nextLegionData, false)
	enemyLegion:setPosition(cc.p(2000, LEGION_POS[2][legionPos].y))
	enemyLegion:wait()
	enemyLegion:moveToPosition(cc.p(LEGION_POS[2][legionPos].x, LEGION_POS[2][legionPos].y), function ()
		local insertIndex = 0
		for k, v in ipairs(self.armyArr[2]) do
			if enemyLegion.pos < v.pos then
				insertIndex = k
				table.insert(self.armyArr[2], k, enemyLegion)
			end
		end
		if insertIndex <= 0 then
			table.insert(self.armyArr[2], enemyLegion)
		end
		self.legionCount[2] = self.legionCount[2] + 1
		enemyLegion:prepare()

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
	end)
end

function BattleTagMatchUI:addKillAnimation()
end

return BattleTagMatchUI