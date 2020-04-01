local ClassBattleSkill = require("script/app/ui/battle/skill/battleskill")
local ClassReportSkill = require("script/app/ui/battle/report/reportskill")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local PlayerSkillObj = class("PlayerSkillObj")

function PlayerSkillObj:ctor(battlefield, guid, index, info, playerLv, skillLevel)
	self.battlefield = battlefield
	self.guid = guid
	self.index = index
	self.info = info
	self.level = skillLevel
	self.legionType = 0
	self.soldierType = 1
	self.damageCount = {0,0}
	self.atk = (playerLv*26 + 856)
	self.critCoefficient = BattleHelper.CONST.CRIT_DAMAGE_COEFFICIENT
	self.attPercent = 0
	self.pvpAttPercent = 0
	if battlefield.isReport then
		self.baseSkill = ClassReportSkill.new(info.skillId + skillLevel*2, self, 4)
	else
		self.baseSkill = ClassBattleSkill.new(info.skillId + skillLevel*2, self, 4)
	end
	self.legionObj = {}
	self.isPlayerSkill = true
end

function PlayerSkillObj:getEffect(atker, hpNum, showNum, flag, skillType, damageCoefficient, addAnger, skillOrBuffId)
end

function PlayerSkillObj:addMp(mpNum)
end

function PlayerSkillObj:isDead()
	return false
end

function PlayerSkillObj:addMpPercentage(p)
end

function PlayerSkillObj:addDamageCount(num, guid, damageCoefficient)
	local dmgNum = num
	if dmgNum > 0 then -- 加血统计
		self.damageCount[1] = self.damageCount[1] + dmgNum
	else -- 伤害统计
		dmgNum = dmgNum/damageCoefficient
		self.damageCount[2] = self.damageCount[2] - dmgNum
	end
	self.battlefield:addDamageCount(num, guid, 1)
end

function PlayerSkillObj:addHurtCount(num)
end

function PlayerSkillObj:runSkillAction(act)
	self.battlefield:runSkillAction(act)
end

function PlayerSkillObj:stopSkillAction(act)
	self.battlefield:stopSkillAction(act)
end

function PlayerSkillObj:effectWhenHurtTarget(hpNum, flag, skillType, target)
	return hpNum
end

function PlayerSkillObj:effectWhenGetHurt(hpNum, flag, skillType, target)
	return hpNum
end

function PlayerSkillObj:effectWhenKillTarget(target)
end

function PlayerSkillObj:effectWhenLockedByLegion(legion)
end

function PlayerSkillObj:forgetSkill(index)
end

function PlayerSkillObj:addReport(report)
	self.battlefield:addReport(report)
end

return PlayerSkillObj