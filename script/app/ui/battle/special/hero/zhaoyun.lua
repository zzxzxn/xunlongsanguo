local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhaoYun = class("ZhaoYun", BaseClass)

function ZhaoYun:init()
	self.addTimes = 0
end

-- 所有近战部队攻击速度提高
function ZhaoYun:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 1 then
				v.heroInfo.attackSpeed = v.heroInfo.attackSpeed + v.heroInfo.baseAttackSpeed*self.value1[1]/100
			end
		end
	end
end

-- 提升攻击速度，切换目标时效果消失。
function ZhaoYun:effectWhenUseSkill(skillObj)
	if self.skill2 and self.addTimes < self.value2[2] then
		self.addTimes = self.addTimes + 1
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value2[1]/100
	end
end

function ZhaoYun:effectWhenLockTarget(target)
	if self.skill2 and self.addTimes > 0 then
		self.owner.attackSpeed = self.owner.attackSpeed - self.owner.baseAttackSpeed*self.value2[1]*self.addTimes/100
		self.addTimes = 0
	end
end

--暴击伤害提升
function ZhaoYun:effectBeforeFight()
	if self.skill3 then
		self.owner.critCoefficient = self.value3[1]/100
	end
end

return ZhaoYun