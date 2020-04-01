local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

local ZhuGeLiang = class("ZhuGeLiang", BaseClass)

-- 对被控制的目标额外造成伤害
-- 大招多造成伤害
function ZhuGeLiang:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 then
		if target.limitMove > 0 or target.limitAtt > 0 or target.limitSkill > 0 then
			hpNum = math.floor(hpNum*(1+self.value1[1]/100))
		end
	end
	return hpNum
end

-- 切换目标时，伤害提高
function ZhuGeLiang:effectWhenLockTarget(target)
	if self.skill2 then
		self.owner:createBuff(self.value2[1], self.owner)
	end
end

-- 换技能，skillGroupId第二位加5
function ZhuGeLiang:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return ZhuGeLiang