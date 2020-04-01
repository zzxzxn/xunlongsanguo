local BaseClass = require("script/app/ui/battle/special/hero/base")

local JiaXu = class("JiaXu", BaseClass)

function JiaXu:init()
	self.addAttackSpeedFlag = false
end

-- 对近战部队伤害增加
function JiaXu:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.attackType == 1 then
		return math.floor(hpNum*(1+self.value1[2]/100))
	else
		return hpNum
	end
end

-- 受到近战部队伤害降低
function JiaXu:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.attackType == 1 then
		return math.floor(hpNum*(1+self.value1[1]/100))
	else
		return hpNum
	end
end

-- 没有人攻击自己时，攻击速度提升
function JiaXu:effectBeforeFight()
	if self.skill2 and not self.addAttackSpeedFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addAttackSpeedFlag = true
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value2[1]/100
	end
end

function JiaXu:effectWhenLockedBySoldier(target)
	if self.skill2 and self.addAttackSpeedFlag then
		self.addAttackSpeedFlag = false
		self.owner.attackSpeed = self.owner.attackSpeed - self.owner.baseAttackSpeed*self.value2[1]/100
	end
end

function JiaXu:effectWhenUnlockBySoldier(target)
	if self.skill2 and not self.addAttackSpeedFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addAttackSpeedFlag = true
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value2[1]/100
	end
end

-- 换技能，skillGroupId第二位加5
function JiaXu:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return JiaXu