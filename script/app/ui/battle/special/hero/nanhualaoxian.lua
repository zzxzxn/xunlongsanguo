local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local NanHuaLaoXian = class("NanHuaLaoXian", BaseClass)

-- 普攻有一定几率为己方一个武将加满怒气
function NanHuaLaoXian:effectWhenUseSkill(skillObj)
	if self.skill1 and skillObj:isBaseSkill() and BattleHelper:random(0, 100) < self.value1[1] then
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		local randomIndex = {}
		for k, v in ipairs(armyArr) do
			if not v:isDead() then
				if not v.heroObj:isDead() then
					table.insert(randomIndex, k)
				end
			end
		end
		if #randomIndex > 0 then
			local hero = armyArr[BattleHelper:random(1, #randomIndex+1)].heroObj
			hero:addMpPercentage(self.value1[2]/100)
		end
	end
end

-- 濒死时立即回复全部生命值（只可触发一次）
function NanHuaLaoXian:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.skill2 and hpNum + self.owner.hp <= 0 and hpNum < 0 and self.onlyOnce2 == nil then
		hpNum = -1
		self.onlyOnce2 = true
		self.owner:getEffect(self.owner, self.owner.maxHp, false, 0, 0, 1, true, 0)
	end
	return hpNum
end

-- 换技能，skillGroupId第二位加5
function NanHuaLaoXian:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return NanHuaLaoXian