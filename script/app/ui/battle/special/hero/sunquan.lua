local BaseClass = require("script/app/ui/battle/special/hero/base")

local SunQuan = class("SunQuan", BaseClass)

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

-- 所有吴国武将基础属性增加
-- 换技能，skillGroupId第二位加5
function SunQuan:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.camp == 3 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
				-- v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
				v.heroInfo.hit = v.heroInfo.hit + v.heroInfo.baseHit*self.value1[1]/100
				v.heroInfo.dodge = v.heroInfo.dodge + v.heroInfo.baseDodge*self.value1[1]/100
				v.heroInfo.crit = v.heroInfo.crit + v.heroInfo.baseCrit*self.value1[1]/100
				v.heroInfo.resi = v.heroInfo.resi + v.heroInfo.baseResi*self.value1[1]/100
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 周围一定范围的友方单位无敌
function SunQuan:effectWhenDie(killer)
	if self.skill2 then
		local x, y = self.owner:getPosition()
		local direction = self.owner:getDirection()
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		for k, v in ipairs(armyArr) do
			if not v:isDead() then
				if not v.heroObj:isDead() then
					local x2, y2 = v.heroObj:getPosition()
					if isInRange(direction, x, y, x2, y2, self.value2[2], self.value2[3], self.value2[4], self.value2[5]) then
						self.owner:createBuff(self.value2[1], v.heroObj)
					end
				end
				for k2, soldierObj in ipairs(v.soldierObjs) do
					if not soldierObj:isDead() then
						local x2, y2 = soldierObj:getPosition()
						if isInRange(direction, x, y, x2, y2, self.value2[2], self.value2[3], self.value2[4], self.value2[5]) then
							self.owner:createBuff(self.value2[1], soldierObj)
						end
					end
				end
				for k2, summonObj in ipairs(v.summonObjs) do
					if not summonObj:isDead() then
						local x2, y2 = summonObj:getPosition()
						if isInRange(direction, x, y, x2, y2, self.value2[2], self.value2[3], self.value2[4], self.value2[5]) then
							self.owner:createBuff(self.value2[1], summonObj)
						end
					end
				end
			end
		end
	end
end

return SunQuan