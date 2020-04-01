local BaseClass = require("script/app/ui/battle/special/hero/base")

local DaQiao = class("DaQiao", BaseClass)

function DaQiao:init()
	self.attackTimes = 0
	self.addDmgFlag = false
end

-- 对近战部队额外造成伤害
-- 每3次攻击附加3%生命的真实伤害
function DaQiao:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.attackType == 1 then
		hpNum = math.floor(hpNum*(1+self.value1[1]/100))
	end
	if self.skill2 and hpNum < 0 and self.addDmgFlag then
		hpNum = hpNum - math.floor(target.baseHp*self.value2[2]/100)
	end
	return hpNum
end

function DaQiao:effectWhenUseSkill(skillObj)
	if self.skill2 then
		self.attackTimes = self.attackTimes + 1
		if self.attackTimes >= self.value2[1] then
			self.attackTimes = 0
			self.addDmgFlag = true
		else
			self.addDmgFlag = false
		end
	end
end

function DaQiao:effectWhenDie(killer)
	if self.skill2 then
		self.attackTimes = 0
		self.addDmgFlag = false
	end
end

-- 换技能，skillGroupId第二位加5
function DaQiao:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return DaQiao