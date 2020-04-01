local BaseClass = require("script/app/ui/battle/special/hero/base")

local GuanYu = class("GuanYu", BaseClass)

-- 击杀武将将对方怒气值转换为自身怒气值
-- 每击杀一名武将回复自身最大生命的10%
function GuanYu:effectWhenKillTarget(target)
	if self.skill1 and target.soldierType == 1 then
		self.owner:addMp(target.mp)
	end
	if self.skill3 and target.soldierType == 1 then
		self.owner:getEffect(self.owner, math.floor(self.owner.maxHp*self.value3[1]/100), true, 0, 0, 1, true, 0)
	end
end

function GuanYu:effectWhenDie(killer)
	if self.skill2 and not killer.isPlayerSkill then
		self.owner:createBuff(self.value2[1], killer)
	end
end

return GuanYu