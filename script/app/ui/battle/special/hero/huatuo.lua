local BaseClass = require("script/app/ui/battle/special/hero/base")

local HuaTuo = class("HuaTuo", BaseClass)

-- 所有本方武将受到的伤害下降
-- 全体友军近战部队防御提高
function HuaTuo:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			v.heroInfo.defPercent = v.heroInfo.defPercent + self.value1[1]
		end
	end
	if self.skill3 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 1 then
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value3[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value3[1]/100
			end
		end
	end
end

-- 本方生命值比例最低的武将满血
function HuaTuo:effectWhenDie(killer)
	if self.skill2 then
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		local heroObj
		local minRatio = 100
		for k, v in ipairs(armyArr) do
			if not v:isDead() and not v.heroObj:isDead() then
				local ratio = v.heroObj.hp/v.heroObj.maxHp
				if ratio < minRatio then
					minRatio = ratio
					heroObj = v.heroObj
				end
			end
		end
		if heroObj then
			local needHp = heroObj.maxHp - heroObj.hp
			heroObj:getEffect(self.owner, needHp, false, 0, 0, 1, true, 0)
		end
	end
end

return HuaTuo