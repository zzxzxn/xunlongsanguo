local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local PangTong = class("PangTong", BaseClass)

-- 所有远程部队攻击提高
-- 换技能，skillGroupId第二位加5
function PangTong:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 2 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 濒死时立即回复全部生命值，并随机封印一个技能（只可触发一次）
function PangTong:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.skill2 and hpNum + self.owner.hp <= 0 and hpNum < 0 and self.onlyOnce2 == nil then
		hpNum = -1
		self.onlyOnce2 = true
		self.owner:getEffect(self.owner, self.owner.maxHp, false, 0, 0, 1, true, 0)
		self.owner:forgetSkill(BattleHelper:random(2, 4))
	end
	return hpNum
end

return PangTong