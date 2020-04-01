local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhangFei = class("ZhangFei", BaseClass)

function ZhangFei:init()
	self.addTimes = 0
end

-- 所有敌方部队攻击速度下降
function ZhangFei:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.attackSpeed = v.heroInfo.attackSpeed + v.heroInfo.baseAttackSpeed*self.value1[1]/100
		end
	end
end

-- 提升防御力，切换目标时清除。
function ZhangFei:effectWhenUseSkill(skillObj)
	if self.skill2 then
		if self.addTimes < self.value2[2] then
			self.addTimes = self.addTimes + 1
			self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*self.value2[1]/100
			self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*self.value2[1]/100
		end
	end
end

function ZhangFei:effectWhenLockTarget(target)
	if self.skill2 and self.addTimes > 0 then
		self.owner.phyDef = self.owner.phyDef - self.owner.basePhyDef*self.value2[1]*self.addTimes/100
		self.owner.magDef = self.owner.magDef - self.owner.baseMagDef*self.value2[1]*self.addTimes/100
		self.addTimes = 0
	end
end

-- 对攻击被减速的敌人额外造成100%伤害
function ZhangFei:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill3 and hpNum < 0 then
		if target.attackSpeed > target.baseAttackSpeed then
			hpNum = hpNum*2
		end
	end
	return hpNum
end

return ZhangFei