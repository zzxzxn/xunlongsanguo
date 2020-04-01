local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

local ZhuGong = class("ZhuGong", BaseClass)

-- 怒气值越多伤害值越高
-- 大招将多造成伤害
function ZhuGong:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 then
		hpNum = math.floor(hpNum*(1 + self.owner.mp/self.owner.maxMp*self.value1[1]/100))
	end
	if self.skill3 and hpNum < 0 and skillType == SKILL_TYPE.ANGER_SKILL then
		hpNum = math.floor(hpNum*(1+self.value3[1]/100))
	end
	return hpNum
end

-- 切换目标时，增加怒气
function ZhuGong:effectWhenLockTarget(target)
	if self.skill2 then
		self.owner:addMpPercentage(self.value2[1]/100)
	end
end

return ZhuGong