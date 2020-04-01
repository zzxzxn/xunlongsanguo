local BaseClass = require("script/app/ui/battle/special/hero/base")

local DianWei = class("DianWei", BaseClass)

function DianWei:init()
	self.hurtNum = 0
	self.addTimes = 0
end

-- 1.自身生命值越低伤害越高
-- 2.对生命值低于一半的武将多造成伤害
function DianWei:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 then
		local coefficient = (1 - self.owner.hp/self.owner.maxHp)*self.value1[1]/100
		if coefficient < 0 then
			coefficient = 0
		end
		hpNum = math.floor(hpNum*(1 + coefficient))
	end
	if self.skill2 and hpNum < 0 and target.hp/target.maxHp < self.value2[1]/100 then
		hpNum = math.floor(hpNum*(1 + self.value2[2]/100))
	end
	return hpNum
end

-- 每损失一定血量增加吸血和攻速
function DianWei:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if self.skill3 and hpNum < 0 and self.addTimes < self.value3[4] then
		self.hurtNum = self.hurtNum - hpNum
		local addTimes = math.floor(self.hurtNum/self.owner.maxHp/self.value3[1]*100)
		if addTimes > self.addTimes then
			if addTimes > self.value3[4] then
				addTimes = self.value3[4]
			end
			self.owner.suckBloodPercent = self.owner.suckBloodPercent + self.value3[2]*(addTimes-self.addTimes)
			self.owner.attackSpeed = self.owner.attackSpeed + (self.owner.baseAttackSpeed*self.value3[3]/100)*(addTimes-self.addTimes)
			self.addTimes = addTimes
		end
	end
	return hpNum
end

return DianWei