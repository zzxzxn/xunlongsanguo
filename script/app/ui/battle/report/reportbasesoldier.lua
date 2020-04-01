local ClassBaseSoldier = require("script/app/ui/battle/legion/basesoldier")
local ClassReportSkill = require("script/app/ui/battle/report/reportskill")
local ClassReportBuff = require("script/app/ui/battle/report/reportbuff")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ReportBaseSoldier = class("ReportBaseSoldier", ClassBaseSoldier)

local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE
local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME

function ReportBaseSoldier:initReportAttribute()
	self.report = {}
	self.reportRoot = {
		x = 0,
		y = 0
	}
	self.report.direction = 1
	self.report.recordObj = {
		[1] = self.guid,
		[2] = self.legionObj.pos,
		[3] = self.soldierType,
		[4] = self.soldierIndex,
		[5] = {}
	}
	self.report.actionInfo = {}
	self.report.skillActionArr = {}
	self.report.waitActionArr = {}
end

function ReportBaseSoldier:initActionInfo()
	self.report.actionInfo = self.battlefield:getSoldierActionInfo(self.url)
end

function ReportBaseSoldier:createNode(position)
	self:setPosition(position)
end

function ReportBaseSoldier:createSkill(skillId, skillType)
	return ClassReportSkill.new(skillId, self, skillType)
end

function ReportBaseSoldier:talkBySoldier()
end

function ReportBaseSoldier:talkByHero()
end

function ReportBaseSoldier:showSkillShout()
end

function ReportBaseSoldier:showSkillLight()
end

function ReportBaseSoldier:setPosition(pos)
	self.reportRoot.x = pos.x
	self.reportRoot.y = pos.y
end

function ReportBaseSoldier:getPosition()
	return self.reportRoot.x, self.reportRoot.y
end

function ReportBaseSoldier:getPositionX()
	return self.reportRoot.x
end

function ReportBaseSoldier:getPositionY()
	return self.reportRoot.y
end

function ReportBaseSoldier:getDirection()
	return self.report.direction
end

function ReportBaseSoldier:setDirection(scaleX)
	self.report.direction = scaleX
end

function ReportBaseSoldier:updateZorder(posy)
end

function ReportBaseSoldier:runMoveAction(time, pos, callbackAct, dashFlag)
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.MOVE,
		[3] = pos.x,
		[4] = pos.y,
		[5] = time,
		[6] = dashFlag
	}
	self:addReport(obj)

	self.report.moveActionInfo = {
		name = actionName,
		startTime = self.battlefield.time,
		time = time,
		startPosX = self.reportRoot.x,
		startPosY = self.reportRoot.y,
		diffPosX = pos.x - self.reportRoot.x,
		diffPosY = pos.y - self.reportRoot.y,
		callback = callbackAct
	}
	if dashFlag == 1 then -- 普通移动
		if self.soldierType == 2 then
			self:playAction("walk", true)
		else
			self:playAction("run", true)
		end
	elseif dashFlag == 2 then -- 加速移动
		self:playAction("run", true)
	end
end

function ReportBaseSoldier:breakSkill()
	self.report.attackActionInfo = nil
end

function ReportBaseSoldier:playAnimation(name, loopType)
	if self.currSkill then
		if name == self.currAction and name == self.currSkill:getActionName() then
			local actionInfo = self.report.actionInfo[name]
			self.report.attackActionInfo = {
				name = name,
				startTime = self.battlefield.time,
				totalframe = actionInfo.totalframe/60
			}
		end
	end
end

function ReportBaseSoldier:recordDie(atker)
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.DEAD
	}
	if self.soldierType == 1 and atker and atker.legionObj.headpic then
		obj[3] = atker.guid
		obj[4] = atker.legionObj.pos
	end
	self:addReport(obj)
end

function ReportBaseSoldier:recordUseSkill(skillObj)
	local actionName = skillObj:getActionName()
	local actionInfo = self.report.actionInfo[actionName]
	if actionInfo then
		self.report.attackActionInfo = {
			name = actionName,
			startTime = self.battlefield.time,
			totalframe = actionInfo.totalframe/60
		}
		if actionInfo.keyframe then
			self.report.attackActionInfo.keyframe = actionInfo.keyframe/60
		end
		-- 攻击
		local obj = {
			[1] = self.battlefield.time,
			[2] = REPORT_NAME.USESKILL,
			[3] = skillObj.skillId,
			[4] = skillObj.skillType,
			[5] = self.report.direction
		}
		self:addReport(obj)
	else
		print("      @@@@@@@@@@@@@   ",actionName)
	end
end

function ReportBaseSoldier:recordBreakAttack()

end

function ReportBaseSoldier:checkAction()
	local currTime = self.battlefield.time
	if self.report.moveActionInfo then
		if currTime - self.report.moveActionInfo.startTime >= self.report.moveActionInfo.time then
			self.reportRoot.x = self.report.moveActionInfo.startPosX + self.report.moveActionInfo.diffPosX
			self.reportRoot.y = self.report.moveActionInfo.startPosY + self.report.moveActionInfo.diffPosY
			local func = self.report.moveActionInfo.callback
			self.report.moveActionInfo = nil
			func()
		else
			self.reportRoot.x = self.report.moveActionInfo.startPosX + self.report.moveActionInfo.diffPosX*(currTime - self.report.moveActionInfo.startTime)/self.report.moveActionInfo.time
			self.reportRoot.y = self.report.moveActionInfo.startPosY + self.report.moveActionInfo.diffPosY*(currTime - self.report.moveActionInfo.startTime)/self.report.moveActionInfo.time
		end
	end
	if self.report.waitForAttack then
		if currTime - self.report.waitForAttack.startTime >= self.report.waitForAttack.time then
			local func = self.report.waitForAttack.func
			self.report.waitForAttack = nil
			func()
		end
	end
	if self.report.attackActionInfo then
		if self.report.attackActionInfo.keyframe then
			if currTime - self.report.attackActionInfo.startTime >= self.report.attackActionInfo.keyframe then
				self.report.attackActionInfo.keyframe = nil
				if self.currSkill then
					if not self.currSkill:isFinished() and not self.currSkill:isCasting() then
						self.attackTimes = self.attackTimes + 1
						self.currSkill:effect()
					end
				end
			end
		end
		if self.report.attackActionInfo then
			if currTime - self.report.attackActionInfo.startTime >= self.report.attackActionInfo.totalframe then
				local name = self.report.attackActionInfo.name
				self.report.attackActionInfo = nil
				if self.liveTime and self.attackTimes >= self.liveTime then
					self:die(self)
				else
					self:movementComplete(name)
				end
			end
		end
	end
	local totalNum = #self.report.skillActionArr
	if totalNum > 0 then	
		for k = totalNum, 1, -1 do
			local action = self.report.skillActionArr[k]
			if action.remove then
				table.remove(self.report.skillActionArr, k)
			else
				local one = action.actions[action.index]
				if one.start == nil then
					one.start = true
					one.startTime =  currTime
				end
				if currTime - one.startTime >= one.waitTime then
					action.index = action.index + 1
					one.start = nil
					if action.index > #action.actions then
						if action.repeatIndex then
							action.index = action.repeatIndex
						else
							table.remove(self.report.skillActionArr, k)
						end
					end
					one.func()
				end
			end
		end
	end
	local totalNum2 = #self.report.waitActionArr
	if totalNum2 > 0 then
		for k = totalNum2, 1, -1 do
			local action = self.report.waitActionArr[k]
			if currTime - action.startTime >= action.time then
				table.remove(self.report.waitActionArr, k)
				action.func()
			end
		end
	end
end

function ReportBaseSoldier:runSkillAction(action)
	table.insert(self.report.skillActionArr, action)
end

function ReportBaseSoldier:stopSkillAction(action)
	for k, v in ipairs(self.report.skillActionArr) do
		if v == action then
			v.remove = true
		end
	end
end

function ReportBaseSoldier:stopSkillActionByTag(tag)
	for k, action in ipairs(self.report.skillActionArr) do
		if action.tag and action.tag == tag then
			action.remove = true
		end
	end
end

function ReportBaseSoldier:showHpBar()
end

function ReportBaseSoldier:setHpBarPercent(hpNum)
	if hpNum < 0 then
		self:addHurtCount(hpNum)
	end
end

function ReportBaseSoldier:showDamage(showNum, hpNum, flag)
end

function ReportBaseSoldier:setHpBarVis(vis)
end

function ReportBaseSoldier:restoreScale()
end

function ReportBaseSoldier:checkAttackCD()
	local waitTime = self.battlefield.time - self.attackFinishTime
	local attackSpeed = self.attackSpeed < self.minAttackSpeed and self.minAttackSpeed or self.attackSpeed
	if waitTime > attackSpeed then
		local flag, status = self:beforeAttack()
		if flag then
			local skill = self:getAvailableSkill()
			if skill == nil then
				self:playAction("idle", true)
			else
				self:useSkill(skill)
			end
		else
			if status == -1 then
				self:playAction("idle", true)
			else
				self.report.waitForAttack = {
					startTime = self.battlefield.time,
					time = 0.01,
					func = function ()
						self:setStatus(status)
					end
				}
				self:playAction("idle", true)
			end
		end
	else
		self.report.waitForAttack = {
			startTime = self.battlefield.time,
			time = attackSpeed - waitTime,
			func = function ()
				local flag, status = self:beforeAttack()
				if flag then
					local skill = self:getAvailableSkill()
					if skill == nil then
						self:playAction("idle", true)
					else
						self:useSkill(skill)
					end
				else
					if status == -1 then
						self:playAction("idle", true)
					else
						self:setStatus(status)
					end
				end
			end
		}
		self:playAction("idle", true)
	end
end

function ReportBaseSoldier:runAction(action)
end

function ReportBaseSoldier:stopAllActions()
	if self.report.waitForAttack then
		self.report.waitForAttack = nil
	end
	if self.report.moveActionInfo then
		self.report.moveActionInfo = nil
	end
	self.finalPosition = nil
	self.moveToOther = false
end

function ReportBaseSoldier:stopMove()
	if self.report.moveActionInfo then
		self.report.moveActionInfo = nil
	end
	self.moveToOther = false
	self.finalPosition = nil
end

function ReportBaseSoldier:playKillAnimation()
end

function ReportBaseSoldier:loseControl(buffId, moveType)
	if self.loseControlId > 0 then
		return
	end
	if moveType == 1 then -- 站原地不动
		self.rolePosOffset = cc.p(0, 0)
		self:pause()
	elseif moveType == 2 then -- 空中上下浮动
		self.rolePosOffset = cc.p(0, 90)
	elseif moveType == 3 then -- 顶飞到空中
		self.rolePosOffset = cc.p(0, 0)
	end
	self.loseControlId = buffId
	self:addLimitStatus(1, 1, 1)
end

function ReportBaseSoldier:resumeControl(buffId, moveType)
	if self.loseControlId == buffId then
		self:removeLoseControlStatus(moveType)
	end
end

function ReportBaseSoldier:removeLoseControlStatus(moveType)
	if moveType == 1 then
		self:resume()
		self.rolePosOffset = cc.p(0, 0)
		self.loseControlId = 0
		self:removeLimitStatus(1, 1, 1)
	elseif moveType == 2 then
		local act = {
			index = 1,
			actions = {
				{
					name = "callback",
					waitTime = 0.2,
					func = function ()
						self.rolePosOffset = cc.p(0, 0)
						self.loseControlId = 0
						self:removeLimitStatus(1, 1, 1)
					end
				}
			}
		}
		self:runSkillAction(act)
	elseif moveType == 3 then
		self.rolePosOffset = cc.p(0, 0)
		self.loseControlId = 0
		self:removeLimitStatus(1, 1, 1)
	end
end

function ReportBaseSoldier:setVisible(vis)
end

function ReportBaseSoldier:showEffectNode()
end

function ReportBaseSoldier:setEffectNodePosition(pos)
end

function ReportBaseSoldier:pause()
	self.pauseFlag = true
end

function ReportBaseSoldier:resume()
	self.pauseFlag = false
end

function ReportBaseSoldier:remove()
end

function ReportBaseSoldier:showSuckAnimation()
end

function ReportBaseSoldier:createBuff(sid, owner)
	ClassReportBuff.new(sid, owner, self)
end

function ReportBaseSoldier:addBuff(buff)
	table.insert(self.buffList, buff)
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.ADDBUFF,
		[3] = buff.sid,
	}
	self:addReport(obj)
end

function ReportBaseSoldier:finishRemoveBuff(sid)
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.REMOVEBUFF,
		[3] = sid,
	}
	self:addReport(obj)
end

function ReportBaseSoldier:recordDmgInReport(atker, hpNum, showNum, flag, skillType, skillOrBuffId)
	local skillId = 0
	if skillType == SKILL_TYPE.NORMAL_ATTACK or skillType == SKILL_TYPE.AUTO_SKILL or skillType == SKILL_TYPE.ANGER_SKILL then
		skillId = skillOrBuffId
	end
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.HURT,
		[3] = hpNum,
		[4] = showNum,
		[5] = flag,
		[6] = skillId
	}
	self:addReport(obj)
end

function ReportBaseSoldier:recordMp(percent)
	local obj = {
		[1] = self.battlefield.time,
		[2] = REPORT_NAME.ADDMP,
		[3] = percent
	}
	self:addReport(obj)
end

function ReportBaseSoldier:dieAfterAWhile(time)
	local action = {
		startTime = self.battlefield.time,
		time = time,
		func = function ()
			self:die(self)
		end
	}
	table.insert(self.report.waitActionArr, action)
end

function ReportBaseSoldier:showBornAnimation()
	if self.summonInfo.appearEf ~= "0" then
		local actionInfo = self.battlefield:getJsonActionInfo(self.summonInfo.appearEf)
		local action = {
			startTime = self.battlefield.time,
			time = actionInfo.totalframe/60,
			func = function ()
				self:searchTarget(false, true)
			end
		}
		table.insert(self.report.waitActionArr, action)
	else
		self:searchTarget(false, true)
	end
end

function ReportBaseSoldier:addReport(report)
	table.insert(self.report.recordObj[5], report)
end

function ReportBaseSoldier:hideSoldier()
end

function ReportBaseSoldier:playDeadSound()
end

function ReportBaseSoldier:removeAllAnimation()
end

return ReportBaseSoldier