local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local SunCe = class("SunCe", BaseClass)

function SunCe:init()
	self.lockedNum = 0
end

-- 每有一个近战部队锁定自己时，自己部队防御提高10%
function SunCe:effectWhenLockedByLegion(legion)
	if self.skill1 and legion.legionType ~= 2 then
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

function SunCe:effectWhenCancelLockByLegion(legion)
	if self.skill1 and legion.legionType ~= 2 then
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

-- 自己部队免疫一切控制技能
function SunCe:effectBeforeFight()
	if self.skill2 then
		local legion = self.owner.legionObj
		if not legion.heroObj:isDead() then
			legion.heroObj.ignoreControl = legion.heroObj.ignoreControl + 1
		end
		for k, soldierObj in ipairs(legion.soldierObjs) do
			if not soldierObj:isDead() then
				soldierObj.ignoreControl = soldierObj.ignoreControl + 1
			end
		end
		for k, summonObj in ipairs(legion.summonObjs) do
			if not summonObj:isDead() then
				summonObj.ignoreControl = summonObj.ignoreControl + 1
			end
		end
	end
end

-- 攻击有几率晕眩敌人
function SunCe:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill3 and hpNum < 0 and BattleHelper:random(0, 100) < self.value3[2] then
		self.owner:createBuff(self.value3[1], target)
	end
	return hpNum
end

return SunCe