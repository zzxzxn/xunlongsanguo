local ClassBattleSkill = require("script/app/ui/battle/skill/battleskill")
local ClassReportBuff = require("script/app/ui/battle/report/reportbuff")
local BulletMgr = require("script/app/ui/battle/report/reportbulletmanager")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ReportSkill = class("ReportSkill", ClassBattleSkill)

local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME

function ReportSkill:playSound(soundEffectRes, isLoop)
end

function ReportSkill:playAttEffect(obj, baseInfo)
end

function ReportSkill:multiEffect(baseInfo, effectFinal)
	local effectAct
	if baseInfo.effectTimes == 1 then
		if baseInfo.effectDelay <= 0 then
			effectFinal()
		else
			if self.casting then
				effectAct = {
					index = 1,
					actions = {
						{
							name = "callback",
							waitTime = baseInfo.effectDelay/1000,
							func = function ()
								effectFinal()
								self.effectActs[effectAct] = nil
							end
						}
					}
				}
			else
				effectAct = {
					index = 1,
					actions = {
						{
							name = "callback",
							waitTime = baseInfo.effectDelay/1000,
							func = effectFinal
						}
					}
				}
			end
		end
	elseif baseInfo.effectTimes > 1 then
		local effectActions = {}
		for i = 1, baseInfo.effectTimes do
			if i == 1 then
				local obj = {
					name = "callback",
					waitTime = baseInfo.effectDelay/1000,
					func = effectFinal
				}
				table.insert(effectActions, obj)
			else
				local obj = {
					name = "callback",
					waitTime = baseInfo.effectInterval/1000,
					func = effectFinal
				}
				table.insert(effectActions, obj)
			end
		end
		if self.casting then
			local obj = {
				name = "callback",
				waitTime = 0,
				func = function ()
					self.effectActs[effectAct] = nil
					self:finished()
				end
			}
			table.insert(effectActions, obj)
		end
		effectAct = {
			index = 1,
			actions = effectActions
		}
	end
	if effectAct then
		self.owner:runSkillAction(effectAct)
		if self.casting then
			self.effectActs[effectAct] = 1
		end
	end
end

function ReportSkill:recordFinishCastingSkill()
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.FINISHCASTINGSKILL,
		[3] = self.skillId,
		[4] = self.skillType
	}
	if self.owner.lockEnemy then
		local x1 = self.owner:getPositionX()
		local x2 = self.owner.lockEnemy:getPositionX()
		if x1 < x2 then
			obj[5] = 1
		else
			obj[5] = -1
		end
	end
	self.owner:addReport(obj)
end

function ReportSkill:playSkillAnimation(skillAnimationId, direction, pos)
end

function ReportSkill:sendBullet(bulletId, startPos, direction, posOrTargets, effectFun, positionFlag)
	local targets
	if positionFlag == 1 then
		targets = posOrTargets
	elseif positionFlag == 2 then
		targets = {
			[1] = posOrTargets.guid,
			[2] = posOrTargets.legionObj.pos,
			[3] = posOrTargets.soldierType,
			[4] = posOrTargets.soldierIndex
		}
	elseif positionFlag == 3 then
		targets = {}
		for k, v in ipairs(posOrTargets) do
			local obj = {
				[1] = v.guid,
				[2] = v.legionObj.pos,
				[3] = v.soldierType,
				[4] = v.soldierIndex
			}
			targets[k] = obj
		end
	end
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.SENDBULLET,
		[3] = self.guid,
		[4] = self.skillId,
		[5] = self.skillType,
		[6] = startPos.x,
		[7] = startPos.y,
		[8] = positionFlag,
		[9] = direction,
		[10] = targets
	}
	self.owner:addReport(obj)
	if bulletId == 0 then
		effectFun(posOrTargets)
	else
		BulletMgr:sendBullet(self, bulletId, startPos, direction, posOrTargets, effectFun, positionFlag)
	end
end

function ReportSkill:sendMultiBullet(baseInfo, startPos, direction, effectFun)
	if baseInfo.rangeType > 1 and baseInfo.focusType > 2 then
		if self:selectPointCenter(baseInfo.focusType) then
			self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
		end
	else
		self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
	end
	if baseInfo.bulletNum > 1 then
		local bulletActions = {}
		for i = 2, baseInfo.bulletNum do
			local obj = {
				name = "callback",
				waitTime = baseInfo.bulletInterval/1000,
				func = function ()
					if baseInfo.rangeType > 1 and baseInfo.focusType > 2 then
						if self:selectPointCenter(baseInfo.focusType) then
							self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
						end
					else
						self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
					end
				end
			}
			table.insert(bulletActions, obj)
		end
		local bulletAct
		if self.casting then
			local obj = {
				name = "callback",
				waitTime = 0,
				func = function ()
					self.bulletAtcs[bulletAct] = nil
				end
			}
			table.insert(bulletActions, obj)
			bulletAct = {
				index = 1,
				actions = bulletActions
			}
			self.bulletAtcs[bulletAct] = 1
		else
			bulletAct = {
				index = 1,
				actions = bulletActions
			}
		end
		self.owner:runSkillAction(bulletAct)
	end
end

function ReportSkill:sendMultiBulletByMelee(baseInfo, startPos, direction, func)
	func()
	if baseInfo.bulletNum > 1 then
		local bulletActions = {}
		for i = 2, baseInfo.bulletNum do
			local obj = {
				name = "callback",
				waitTime = baseInfo.bulletInterval/1000,
				func = func
			}
			table.insert(bulletActions, obj)
		end
		local bulletAct
		if self.casting then
			local obj = {
				name = "callback",
				waitTime = 0,
				func = function ()
					self.bulletAtcs[bulletAct] = nil
				end
			}
			table.insert(bulletActions, obj)
			bulletAct = {
				index = 1,
				actions = bulletActions
			}
			self.bulletAtcs[bulletAct] = 1
		else
			bulletAct = {
				index = 1,
				actions = bulletActions
			}
		end
		self.owner:runSkillAction(bulletAct)
	end
end

function ReportSkill:createBuff(sid, owner, sender)
	ClassReportBuff.new(sid, owner, sender)
end

function ReportSkill:breakCastingSkill()
	self.breakFlag = true
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.BREAKCASTINGSKILL,
		[3] = self.skillId,
		[4] = self.skillType
	}
	self.owner:addReport(obj)
end

function ReportSkill:recordSkip()
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.SKIPSKILL,
		[3] = self.skillId,
		[4] = self.skillType
	}
	self.owner:addReport(obj)
end

return ReportSkill
				