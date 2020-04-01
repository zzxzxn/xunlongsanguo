local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

local TongYuan = class("TongYuan", BaseClass)

function TongYuan:init()
	self.addTimes = 0
end

-- 普通攻击造成额外伤害
function TongYuan:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.skill1 and hpNum < 0 and skillType == SKILL_TYPE.NORMAL_ATTACK then
		hpNum = math.floor(hpNum*(1+self.value1[1]/100))
	end
	return hpNum
end

-- 每次攻击提升一定攻击力
-- 切换目标时清空
function TongYuan:effectWhenUseSkill(skillObj)
	if self.skill2 then
		if self.addTimes < self.value2[2] then
			self.addTimes = self.addTimes + 1
			self.owner.attPercent = self.owner.attPercent + self.value2[1]/100
		end
	end
end

function TongYuan:effectWhenLockTarget(target)
	if self.skill2 and self.addTimes > 0 then
		self.owner.attPercent = self.owner.attPercent - self.value2[1]*self.addTimes/100
		self.addTimes = 0
	end
end

-- 换技能，skillGroupId第二位加5
function TongYuan:effectBeforeCreate(owner, army, enemy)
	if self.skill3 then
		owner.heroInfo.skillGroupId = owner.heroInfo.skillGroupId + math.pow(10, string.len(tostring(owner.heroInfo.skillGroupId))-2)*5
	end
end

return TongYuan