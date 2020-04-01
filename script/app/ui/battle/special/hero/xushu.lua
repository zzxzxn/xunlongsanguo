local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local XuShu = class("XuShu", BaseClass)

-- 本方所有部队对魏国武将额外造成伤害
function XuShu:effectBeforeFight()
	if self.skill1 then
		BattleHelper:addCampCorrection(self.owner.guid, 1, self.value1[1]/100)
	end
end

function XuShu:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill2 and hpNum < 0 then
		self.owner:createBuff(self.value2[1], target)
	end
	return hpNum
end

-- 换技能，skillGroupId第二位加5
function XuShu:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return XuShu