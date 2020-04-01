local BaseClass = require("script/app/ui/battle/special/hero/base")

local XiaHouYuan = class("XiaHouYuan", BaseClass)

function XiaHouYuan:init()
	self.addAttackSpeedFlag = false
end

-- 攻击射程增加，暴击率提升
function XiaHouYuan:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		owner.heroInfo.attackRange = owner.heroInfo.attackRange + self.value1[1]
		owner.heroInfo.crit = owner.heroInfo.crit + self.value1[2]*100
	end
end

-- 暴击时，加个buff
function XiaHouYuan:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill2 and hpNum < 0 and flag == 3 then
		self.owner:createBuff(self.value2[1], self.owner)
	end
	return hpNum
end

-- 没有人攻击自己时，攻击速度提升
function XiaHouYuan:effectBeforeFight()
	if self.skill3 and not self.addAttackSpeedFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addAttackSpeedFlag = true
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value3[1]/100
	end
end

function XiaHouYuan:effectWhenLockedBySoldier(target)
	if self.skill3 and self.addAttackSpeedFlag then
		self.addAttackSpeedFlag = false
		self.owner.attackSpeed = self.owner.attackSpeed - self.owner.baseAttackSpeed*self.value3[1]/100
	end
end

function XiaHouYuan:effectWhenUnlockBySoldier(target)
	if self.skill3 and not self.addAttackSpeedFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addAttackSpeedFlag = true
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value3[1]/100
	end
end

return XiaHouYuan