local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ZhangHe = class("ZhangHe", BaseClass)

function ZhangHe:init()
	self.addCritFlag = false
end

-- 本方所有部队对群雄武将额外造成20%伤害
-- 没有人攻击自己时，增加暴击值
function ZhangHe:effectBeforeFight()
	if self.skill1 then
		BattleHelper:addCampCorrection(self.owner.guid, 4, self.value1[1]/100)
	end
	if self.skill2 and not self.addCritFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addCritFlag = true
		self.owner.crit = self.owner.crit + self.value2[1]
	end
	if self.skill3 then
		self.owner.critCoefficient = self.value3[1]/100
	end
end

function ZhangHe:effectWhenLockedBySoldier(target)
	if self.skill2 and self.addCritFlag then
		self.addCritFlag = false
		self.owner.crit = self.owner.crit - self.value2[1]
	end
end

function ZhangHe:effectWhenUnlockBySoldier(target)
	if self.skill2 and not self.addCritFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addCritFlag = true
		self.owner.crit = self.owner.crit + self.value2[1]
	end
end

return ZhangHe