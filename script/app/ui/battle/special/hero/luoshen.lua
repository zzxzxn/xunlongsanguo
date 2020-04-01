local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local LuoShen = class("LuoShen", BaseClass)

-- 所有地方武将基础属性减少
function LuoShen:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
			v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
			v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
			--v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
			v.heroInfo.hit = v.heroInfo.hit + v.heroInfo.baseHit*self.value1[1]/100
			v.heroInfo.dodge = v.heroInfo.dodge + v.heroInfo.baseDodge*self.value1[1]/100
			v.heroInfo.crit = v.heroInfo.crit + v.heroInfo.baseCrit*self.value1[1]/100
			v.heroInfo.resi = v.heroInfo.resi + v.heroInfo.baseResi*self.value1[1]/100
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 死亡前对一个随机武将造成自己最大生命值的真实伤害
function LuoShen:effectWhenDie(killer)
	if self.skill2 then
		local enemyArr = self.owner.battlefield.armyArr[3-self.owner.guid]
		local randomIndex = {}
		for k, v in ipairs(enemyArr) do
			if not v:isDead() then
				if not v.heroObj:isDead() then
					table.insert(randomIndex, k)
				end
			end
		end
		if #randomIndex > 0 then
			local getHurtHero = enemyArr[BattleHelper:random(1, #randomIndex+1)].heroObj
			local hurtNum = -self.owner.maxHp*self.value2[1]/100
			getHurtHero:getEffect(self.owner, hurtNum, true, 0, 0, 1, true, 0)
		end
	end
end

return LuoShen