local BaseClass = require("script/app/ui/battle/special/hero/base")

local HuaXiong = class("HuaXiong", BaseClass)

-- 对远程部队额外造成伤害
-- 对被控制的目标额外造成伤害
function HuaXiong:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.attackType == 2 then
		hpNum = math.floor(hpNum*(1+self.value1[1]/100))
	end
	if self.skill3 and hpNum < 0 then
		if target.limitMove > 0 or target.limitAtt > 0 or target.limitSkill > 0 then
			hpNum = math.floor(hpNum*(1+self.value3[1]/100))
		end
	end
	return hpNum
end

function HuaXiong:effectWhenDie(killer)
	if self.skill2 and not killer.isPlayerSkill then
		self.owner:createBuff(self.value2[1], killer)
	end
end

return HuaXiong