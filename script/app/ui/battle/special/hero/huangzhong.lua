local BaseClass = require("script/app/ui/battle/special/hero/base")

local HuangZhong = class("HuangZhong", BaseClass)

function HuangZhong:init()
	self.addTimes = 0
end

-- 所有远程部队攻击速度提高
-- 换技能，skillGroupId第二位加5
function HuangZhong:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 2 then
				v.heroInfo.attackSpeed = v.heroInfo.attackSpeed + v.heroInfo.baseAttackSpeed*self.value1[1]/100
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 提升攻击力，切换目标时清除。
function HuangZhong:effectWhenUseSkill(skillObj)
	if self.skill2 and self.addTimes < self.value2[2] then
		self.addTimes = self.addTimes + 1
		self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value2[1]/100
	end
end

function HuangZhong:effectWhenLockTarget(target)
	if self.skill2 and self.addTimes > 0 then
		self.owner.atk = self.owner.atk - self.owner.baseAtk*self.value2[1]*self.addTimes/100
		self.addTimes = 0
	end
end

return HuangZhong