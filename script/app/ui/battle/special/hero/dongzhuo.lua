local BaseClass = require("script/app/ui/battle/special/hero/base")

local DongZhuo = class("DongZhuo", BaseClass)

function DongZhuo:init()
	self.addDefFlag = false
end

-- 所有近战部队防御提高
function DongZhuo:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 1 then
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
			end
		end
	end
end

-- 本方军团多于敌方时，防御力提升30%
function DongZhuo:effectBeforeFight()
	if self.skill2 then
		local legionCount = self.owner.battlefield.legionCount
		if legionCount[self.owner.guid] > legionCount[3-self.owner.guid] then
			self.addDefFlag = true
			self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*self.value2[1]/100
			self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*self.value2[1]/100
		end
		self.owner.battlefield:addHandleWhenLegionDie(self.owner, function (guid)
			local legionCount = self.owner.battlefield.legionCount
			if legionCount[self.owner.guid] > legionCount[3-self.owner.guid] then
				if not self.addDefFlag then
					self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*self.value2[1]/100
					self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*self.value2[1]/100
					self.addDefFlag = true
				end
			else
				if self.addDefFlag then
					self.owner.phyDef = self.owner.phyDef - self.owner.basePhyDef*self.value2[1]/100
					self.owner.magDef = self.owner.magDef - self.owner.baseMagDef*self.value2[1]/100
					self.addDefFlag = false
				end
			end
		end)
	end
end

function DongZhuo:effectWhenDie(killer)
	if self.skill2 then
		self.owner.battlefield:removeHandleWhenLegionDie(self.owner)
	end
end

-- 对被控制的目标额外造成伤害
function DongZhuo:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill3 and hpNum < 0 then
		if target.limitMove > 0 or target.limitAtt > 0 or target.limitSkill > 0 then
			hpNum = math.floor(hpNum*(1+self.value3[1]/100))
		end
	end
	return hpNum
end

return DongZhuo