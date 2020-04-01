local BaseClass = require("script/app/ui/battle/special/hero/base")

local WeiYan = class("WeiYan", BaseClass)

function WeiYan:init()
	self.hurtNum = 0
	self.addTimes = 0
end

-- 敌方武将死亡则自身回复10%生命值
function WeiYan:effectWhenKillTarget(target)
	if self.skill1 and target.soldierType == 1 then
		local hpNum = math.floor(self.owner.baseHp*self.value1[1]/100)
		self.owner:getEffect(self.owner, hpNum, false, 0, 0, 1, true, 0)
	end
end

-- 如果暴击则回复自身等量生命值
function WeiYan:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill2 and hpNum < 0 and flag == 3 then
		self.owner:getEffect(self.owner, -hpNum, false, 0, 0, 1, true, 0)
	end
	return hpNum
end

-- 每损失一定生命提升攻击力
function WeiYan:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if self.skill3 and hpNum < 0 and self.addTimes < self.value3[3] then
		self.hurtNum = self.hurtNum - hpNum
		local addTimes = math.floor(self.hurtNum/self.owner.maxHp/self.value3[1]*100)
		if addTimes > self.addTimes then
			if addTimes > self.value3[3] then
				addTimes = self.value3[3]
			end
			self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]*(addTimes-self.addTimes)/100
			self.addTimes = addTimes
		end
	end
	return hpNum
end

return WeiYan