local BaseClass = require("script/app/ui/battle/special/hero/base")

local TaiShiCi = class("TaiShiCi", BaseClass)

function TaiShiCi:init()
	self.getHurtTimes = 0
	self.lockedNum = 0
end

-- 每有一个远程部队锁定自己时，自己部队防御提高10%
function TaiShiCi:effectWhenLockedByLegion(legion)
	if self.skill1 and legion.legionType == 2 then
		self.lockedNum = self.lockedNum + 1
		if self.lockedNum <= self.value1[2] then
			local legion = self.owner.legionObj
			if not legion.heroObj:isDead() then
				legion.heroObj.phyDef = legion.heroObj.phyDef + legion.heroObj.basePhyDef*self.value1[1]/100
				legion.heroObj.magDef = legion.heroObj.magDef + legion.heroObj.baseMagDef*self.value1[1]/100
			end
			for k, soldierObj in ipairs(legion.soldierObjs) do
				if not soldierObj:isDead() then
					soldierObj.phyDef = soldierObj.phyDef + soldierObj.basePhyDef*self.value1[1]/100
					soldierObj.magDef = soldierObj.magDef + soldierObj.baseMagDef*self.value1[1]/100
				end
			end
			for k, summonObj in ipairs(legion.summonObjs) do
				if not summonObj:isDead() then
					summonObj.phyDef = summonObj.phyDef + summonObj.basePhyDef*self.value1[1]/100
					summonObj.magDef = summonObj.magDef + summonObj.baseMagDef*self.value1[1]/100
				end
			end
		end 
	end
end

function TaiShiCi:effectWhenCancelLockByLegion(legion)
	if self.skill1 and legion.legionType == 2 then
		self.lockedNum = self.lockedNum - 1
		if self.lockedNum < self.value1[2] then
			local legion = self.owner.legionObj
			if not legion.heroObj:isDead() then
				legion.heroObj.phyDef = legion.heroObj.phyDef - legion.heroObj.basePhyDef*self.value1[1]/100
				legion.heroObj.magDef = legion.heroObj.magDef - legion.heroObj.baseMagDef*self.value1[1]/100
			end
			for k, soldierObj in ipairs(legion.soldierObjs) do
				if not soldierObj:isDead() then
					soldierObj.phyDef = soldierObj.phyDef - soldierObj.basePhyDef*self.value1[1]/100
					soldierObj.magDef = soldierObj.magDef - soldierObj.baseMagDef*self.value1[1]/100
				end
			end
			for k, summonObj in ipairs(legion.summonObjs) do
				if not summonObj:isDead() then
					summonObj.phyDef = summonObj.phyDef - summonObj.basePhyDef*self.value1[1]/100
					summonObj.magDef = summonObj.magDef - summonObj.baseMagDef*self.value1[1]/100
				end
			end
		end 
	end
end

-- 每被攻击X次免疫一次伤害
function TaiShiCi:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.skill2 and hpNum < 0 then
		self.getHurtTimes = self.getHurtTimes + 1
		if self.getHurtTimes >= self.value2[1] then
			self.getHurtTimes = 0
			self.owner.invincibleOnce = true
		end
	end
	return hpNum
end

-- 暴击时增加自身怒气
function TaiShiCi:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill3 and flag == 3 and hpNum < 0 then
		self.owner:addMpPercentage(self.value3[1]/100)
	end
	return hpNum
end

return TaiShiCi