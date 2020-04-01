local BaseClass = require("script/app/ui/battle/special/hero/base")

local Guojia = class("Guojia", BaseClass)

-- 所有魏国武将属性增加
-- 换技能，skillGroupId第二位加5
function Guojia:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.camp == 1 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
				--v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
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

-- 提升所有本方武将怒气
function Guojia:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if self.skill2 and hpNum < 0 then
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		for k, v in ipairs(armyArr) do
			if not v:isDead() and not v.heroObj:isDead() then
				v.heroObj:addMpPercentage(self.value2[1]/100)
			end
		end
	end
	return hpNum
end

return Guojia