local BaseClass = require("script/app/ui/battle/special/hero/base")

local SiMaYi = class("SiMaYi", BaseClass)

-- 所有敌方武将获取怒气速度降低
function SiMaYi:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.recoverMp = v.heroInfo.recoverMp + self.value1[1]
			if v.heroInfo.recoverMp < -100 then
				v.heroInfo.recoverMp = -100
			end
		end
	end
end

function SiMaYi:effectWhenConsumeMp()
	if self.skill2 then
		return self.owner.maxMp*self.value2[1]/100
	else
		return 0
	end
end

-- 对生命值低于一半的武将多造成伤害
function SiMaYi:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill3 and hpNum < 0 and target.hp/target.maxHp < self.value3[1]/100 then
		hpNum = math.floor(hpNum*(1 + self.value3[2]/100))
	end
	return hpNum
end

return SiMaYi