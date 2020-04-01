local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local MaChao = class("MaChao", BaseClass)

function MaChao:init()
	self.addAtkSpeedFlag = false
end

-- 对远程部队伤害增加
-- 攻击有几率晕眩敌人
function MaChao:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if hpNum < 0 then
		if self.skill1 and target.attackType == 2 then
			hpNum = math.floor(hpNum*(1+self.value1[2]/100))
		end
		if self.skill2 and BattleHelper:random(0, 100) < self.value2[1] then
			self.owner:createBuff(self.value2[2], target)
		end
	end
	return hpNum
end

-- 受到远程部队伤害降低
function MaChao:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.attackType == 2 then
		return math.floor(hpNum*(1+self.value1[1]/100))
	else
		return hpNum
	end
end

-- 自身生命值高于一定比例时增加攻击速度
function MaChao:effectBeforeFight()
	if self.skill3 and not self.addAtkSpeedFlag and self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
		self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value3[2]/100
		self.addAtkSpeedFlag = true
	end
end

function MaChao:effectWhenChangeHp()
	if self.skill3 then
		if self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
			if not self.addAtkSpeedFlag then
				self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value3[2]/100
				self.addAtkSpeedFlag = true
			end
		else
			if self.addAtkSpeedFlag then
				self.owner.attackSpeed = self.owner.attackSpeed - self.owner.baseAttackSpeed*self.value3[2]/100
				self.addAtkSpeedFlag = false
			end
		end
	end
end

return MaChao