local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local SunJian = class("SunJian", BaseClass)

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

-- 有一定几率使攻击者眩晕
function SunJian:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if self.skill1 and hpNum < 0 and not atker.isPlayerSkill and BattleHelper:random(0, 100) <= self.value1[1] then
		self.owner:createBuff(self.value1[2], atker)
	end
	return hpNum
end

-- 周围目标眩晕一定时间
function SunJian:effectWhenDie(killer)
	if self.skill2 then
		local x, y = self.owner:getPosition()
		local direction = self.owner:getDirection()
		local enemyArr = self.owner.battlefield.armyArr[3-self.owner.guid]
		for k, v in ipairs(enemyArr) do
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

-- 换技能，skillGroupId第二位加5
function SunJian:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return SunJian