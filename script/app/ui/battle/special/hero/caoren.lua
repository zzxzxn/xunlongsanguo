local BaseClass = require("script/app/ui/battle/special/hero/base")

local CaoRen = class("CaoRen", BaseClass)

function CaoRen:init()
	self.hurtNum = 0
	self.addAtkFlag = false
end

-- 生命值越低防御力越高
-- 单次伤害超过自身生命某一百分比时，小技能冷却
function CaoRen:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if hpNum < 0 then
		if self.skill1 then
			local addDef = -hpNum/self.owner.maxHp*self.value1[1]/100
			self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*addDef
			self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*addDef
		end
		if self.skill2 then
			self.hurtNum = self.hurtNum - hpNum
			if self.hurtNum/self.owner.maxHp >= self.value2[1]/100 then
				self.hurtNum = 0
				self.owner.baseSkill.usedTimes = self.owner.autoSkillTimes
			end
		end
	end
	return hpNum
end

-- 自身生命值高于一定比例时增加攻击力
function CaoRen:effectBeforeFight()
	if self.skill3 and not self.addAtkFlag and self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
		self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]/100
		self.addAtkFlag = true
	end
end

function CaoRen:effectWhenChangeHp()
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

return CaoRen