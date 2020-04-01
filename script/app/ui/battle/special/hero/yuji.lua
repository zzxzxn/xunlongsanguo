local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local YuJi = class("YuJi", BaseClass)

-- 所有敌方武将生命下降
-- 换技能，skillGroupId第二位加5
function YuJi:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		owner.heroInfo.preDamageCount = owner.heroInfo.preDamageCount or 0
		local hurtCount = 0
		for k, v in ipairs(enemy) do
			hurtCount = owner.heroInfo.baseHp*self.value1[1]/100
			owner.heroInfo.preDamageCount = owner.heroInfo.preDamageCount + hurtCount
			v.heroInfo.preHurtCount = v.heroInfo.preHurtCount or 0
			v.heroInfo.preHurtCount = v.heroInfo.preHurtCount + hurtCount
			v.heroInfo.hp = v.heroInfo.hp + hurtCount
			if v.heroInfo.hp < 1 then
				v.heroInfo.hp = 1
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 于吉击杀的单位会对周围造成AOE伤害
function YuJi:effectBeforeFight()
	if self.skill2 then
		self.aoeSkill = self.owner:createSkill(self.value2[1], BattleHelper.ENUM.SKILL_TYPE.SPECIAL)
	end
end

function YuJi:effectWhenKillTarget(target)
	if self.skill2 then
		self.aoeSkill:useSkill(cc.p(target:getPosition()))
		self.aoeSkill:effect()
	end
end

return YuJi