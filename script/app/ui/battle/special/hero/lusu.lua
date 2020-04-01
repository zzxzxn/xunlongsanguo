local BaseClass = require("script/app/ui/battle/special/hero/base")

local LuSu = class("LuSu", BaseClass)

-- 能量点回复速度增加（君主技能的能量点）
-- 每只召唤物死亡时为己方增加10点能量点
-- 每只召唤物死亡会使鲁肃攻击和攻速提升
function LuSu:effectBeforeFight()
	if self.skill1 then
		self.owner.battlefield:addPointPerSecond(self.owner.guid, self.value1[1]) 
	end
	if self.skill2 or self.skill3 then
		self.owner.battlefield:addHandleWhenSoldierDie(self.owner, function (guid, soldierType)
			if soldierType == 3 then
				if self.skill2 and guid == self.owner.guid then
					self.owner.battlefield:addPoint(self.owner.guid, self.value2[1])
				end
				if self.skill3 then
					self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[1]/100
					self.owner.attackSpeed = self.owner.attackSpeed + self.owner.baseAttackSpeed*self.value3[2]/100
				end
			end
		end)
	end
end

function LuSu:effectWhenDie(killer)
	if self.skill2 or self.skill3 then
		self.owner.battlefield:removeHandleWhenSoldierDie(self.owner)
	end
end

return LuSu