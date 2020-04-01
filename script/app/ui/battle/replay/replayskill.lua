local EffectMgr = require("script/app/ui/battle/effect/effectmanager")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local ReplaySkill = class("ReplaySkill")

local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

function ReplaySkill:ctor(skillId, owner, skillType)
	self.skillId = skillId
	self.owner = owner
	self.castingAnimations = {}
	self.skillType = skillType
	self.guid = owner.guid
	self.casting = false
	self.baseInfo = GameData:getConfData("skill")[skillId]
end

function ReplaySkill:getActionName()
	return self.baseInfo.action
end

function ReplaySkill:useSkill()
	if #self.castingAnimations > 0 then
		self.castingAnimations = {}
	end
	if self.baseInfo.type == 2 then -- 引导技能
		self.casting = true
	else
		self.casting = false
	end
	if self.baseInfo.soundEffect ~= "0" then
		BattleHelper:playSound(self.baseInfo.soundEffect, false)
	end
end

function ReplaySkill:finished()
	self.casting = false
	if #self.castingAnimations > 0 then
		self.castingAnimations = {}
	end
end

function ReplaySkill:isCasting()
	return self.casting
end

function ReplaySkill:isNeedShout()
	return self.skillType == SKILL_TYPE.ANGER_SKILL
end

function ReplaySkill:breaked()
	if self.casting then
		for k, v in ipairs(self.castingAnimations) do
			v:setStop(self, true)
		end
		self:finished()
	end
end

function ReplaySkill:playSkillAnimation(skillAnimationId, direction, pos)
	local skillAni = EffectMgr:playEffects(skillAnimationId, self, direction, pos)
	if self.casting then
		table.insert(self.castingAnimations, skillAni)
	end
end

return ReplaySkill