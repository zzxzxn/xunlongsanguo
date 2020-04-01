local BaseClass = require("script/app/ui/battle/special/hero/base")

local JiangWei = class("JiangWei", BaseClass)

function JiangWei:init()
	self.addAtkFlag = false
end

-- 每次被攻击时会额外反弹伤害
function JiangWei:effectBeforeFight()
	if self.skill1 then
		self.owner.reboundDmg = self.owner.reboundDmg + self.value1[1]/100
	end
	if self.skill3 and not self.addAtkFlag and self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
		self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]/100
		self.addAtkFlag = true
	end
end

-- 反弹时会将伤害会转化为自身生命值
function JiangWei:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill2 and flag == 4 and hpNum < 0 then
		self.owner:getEffect(self.owner, -hpNum, false, 0, 0, 1, true, 0)
	end
	return hpNum
end

-- 自身生命值高于一定比例时增加攻击力
function JiangWei:effectWhenChangeHp()
	if self.skill3 then
		if self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
			if not self.addAtkFlag then
				self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]/100
				self.addAtkFlag = true
			end
		else
			if self.addAtkFlag then
				self.owner.atk = self.owner.atk - self.owner.baseAtk*self.value3[2]/100
				self.addAtkFlag = false
			end
		end
	end
end

return JiangWei