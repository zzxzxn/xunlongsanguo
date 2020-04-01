local BaseClass = require("script/app/ui/battle/special/hero/base")

local GanNing = class("GanNing", BaseClass)

-- 所有近战部队攻击提高
-- 换技能，skillGroupId第二位加5
function GanNing:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.attackType == 1 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
			end
		end
	end
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

-- 每只召唤物死亡会使甘宁攻击提升，攻速提升
function GanNing:effectBeforeFight()
	if self.skill2 then
		self.owner.battlefield:addHandleWhenSoldierDie(self.owner, function (guid, soldierType)
			if soldierType == 3 then
				self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value2[1]/100
				self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value2[2]/100
			end
		end)
	end
end

function GanNing:effectWhenDie(killer)
	if self.skill2 then
		self.owner.battlefield:removeHandleWhenSoldierDie(self.owner)
	end
end

return GanNing