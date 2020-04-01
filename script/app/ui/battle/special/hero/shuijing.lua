local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ShuiJing = class("ShuiJing", BaseClass)

function ShuiJing:init()
	self.attackTimes = 0
	self.summonTimes = 0
end

-- 每攻击一定次数随机召唤一个召唤物
function ShuiJing:effectWhenUseSkill(skillObj)
	if self.skill1 and self.summonTimes < self.value1[2] then
		self.attackTimes = self.attackTimes + 1
		if self.attackTimes >= self.value1[1] then
			self.attackTimes = 0
			self.summonTimes = self.summonTimes + 1
			local summonId = self.value1[BattleHelper:random(3, 6)] + 10*self.owner.skillLevel
			local posx, posy = self.owner:getPosition()
			local dir = self.owner:getDirection()
			local bornPos = cc.p(posx + 60*dir, posy)
			self.owner.legionObj:addSummonObj(self.owner, summonId, bornPos)
		end
	end
end

-- 死亡时为血量最低的友方武将加个buff
function ShuiJing:effectWhenDie(killer)
	if self.skill2 then
		local target = nil
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		for k, v in ipairs(armyArr) do
			if not v:isDead() then
				if not v.heroObj:isDead() then
					if target == nil or v.heroObj.hp < target.hp then
						target = v.heroObj
					end
				end
			end
		end
		if target then
			self.owner:createBuff(self.value2[1], target)
		end
	end
end

-- 换技能，skillGroupId第二位加5
function ShuiJing:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return ShuiJing