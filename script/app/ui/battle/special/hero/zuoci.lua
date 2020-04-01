local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ZuoCi = class("ZuoCi", BaseClass)

-- 有一定几率把目标变为蛋
function ZuoCi:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and BattleHelper:random(0, 100) <= self.value1[1] then
		self.owner:createBuff(self.value1[2], target)
	end
	return hpNum
end

-- 每有一个武将死亡时，提升属性
function ZuoCi:effectBeforeFight()
	if self.skill2 then
		self.owner.battlefield:addHandleWhenSoldierDie(self.owner, function (guid, soldierType)
			if soldierType == 1 and guid ~= self.owner.guid then
				local percent = self.value2[1]/100
				self.owner.atk = self.owner.atk + self.owner.baseAtk*percent
				self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*percent
				self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*percent
				self.owner.hit = self.owner.hit + self.owner.baseHit*percent
				self.owner.dodge = self.owner.dodge + self.owner.baseDodge*percent
				self.owner.crit = self.owner.crit + self.owner.baseCrit*percent
				self.owner.resi = self.owner.resi + self.owner.baseResi*percent
				--self.owner.hp = self.owner.hp + self.owner.baseHp*percent
			end
		end)
	end
end

function ZuoCi:effectWhenDie(killer)
	if self.skill2 then
		self.owner.battlefield:removeHandleWhenSoldierDie(self.owner)
	end
end

-- 换技能，skillGroupId第二位加5
function ZuoCi:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return ZuoCi