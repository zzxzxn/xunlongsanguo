local BaseClass = require("script/app/ui/battle/special/hero/base")

local DiaoChan = class("DiaoChan", BaseClass)

local function isInRange(direction, x1, y1, x2, y2, rangeX1, rangeX2, rangeY1, rangeY2)
	local rx
	local ry = y2 - y1
	if direction == 1 then
		rx = x2 - x1
	else
		rx = x1 - x2
	end
	if (rangeX1 <= rx and rx <= rangeX2) and (rangeY1 <= ry and ry <= rangeY2) then
		return true
	end
	return false
end

-- 所有敌方武将防御下降
function DiaoChan:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
			v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
		end
	end
end

-- 封印击杀者所有技能
-- 周围所有单位提升攻击力
function DiaoChan:effectWhenDie(killer)
	if self.skill2 and not killer.isPlayerSkill then
		killer:forgetSkill(0)
	end
	if self.skill3 then
		local x, y = self.owner:getPosition()
		local direction = self.owner:getDirection()
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		for k, v in ipairs(armyArr) do
			if not v:isDead() then
				if not v.heroObj:isDead() then
					local x2, y2 = v.heroObj:getPosition()
					if isInRange(direction, x, y, x2, y2, self.value3[2], self.value3[3], self.value3[4], self.value3[5]) then
						self.owner:createBuff(self.value3[1], v.heroObj)
					end
				end
				for k2, soldierObj in ipairs(v.soldierObjs) do
					if not soldierObj:isDead() then
						local x2, y2 = soldierObj:getPosition()
						if isInRange(direction, x, y, x2, y2, self.value3[2], self.value3[3], self.value3[4], self.value3[5]) then
							self.owner:createBuff(self.value3[1], soldierObj)
						end
					end
				end
				for k2, summonObj in ipairs(v.summonObjs) do
					if not summonObj:isDead() then
						local x2, y2 = summonObj:getPosition()
						if isInRange(direction, x, y, x2, y2, self.value3[2], self.value3[3], self.value3[4], self.value3[5]) then
							self.owner:createBuff(self.value3[1], summonObj)
						end
					end
				end
			end
		end
	end
end

return DiaoChan