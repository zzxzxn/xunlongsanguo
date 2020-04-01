local BaseClass = require("script/app/ui/battle/special/hero/base")

local LiuBei = class("LiuBei", BaseClass)

-- 所有蜀国武将基础属性增加
-- 换技能，skillGroupId第二位加5
function LiuBei:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.camp == 2 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
				-- v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
				v.heroInfo.hit = v.heroInfo.hit + v.heroInfo.baseHit*self.value1[1]/100
				v.heroInfo.dodge = v.heroInfo.dodge + v.heroInfo.baseDodge*self.value1[1]/100
				v.heroInfo.crit = v.heroInfo.crit + v.heroInfo.baseCrit*self.value1[1]/100
				v.heroInfo.resi = v.heroInfo.resi + v.heroInfo.baseResi*self.value1[1]/100
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 目标生命小于一半时，提升治疗效果
function LiuBei:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill2 and hpNum > 0 and target.hp/target.maxHp <= self.value2[1]/100 then
		hpNum = math.floor(hpNum*(1 + self.value2[2]/100))
	end
	return hpNum
end

return LiuBei