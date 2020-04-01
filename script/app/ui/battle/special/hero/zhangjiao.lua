local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhangJiao = class("ZhangJiao", BaseClass)

-- 对生命值小于指定百分比的小兵秒杀
function ZhangJiao:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and target.soldierType == 2 and target.hp/target.maxHp < self.value1[1]/100 then
		return -target.hp
	else
		return hpNum
	end
end

-- 召唤物攻击增加
function ZhangJiao:effectWhenSummon(summon)
	if self.skill2 then
		summon.atk = summon.atk + summon.baseAtk*self.value2[1]/100
	end
end

-- 换技能，skillGroupId第二位加5
function ZhangJiao:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return ZhangJiao