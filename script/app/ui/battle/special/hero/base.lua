local Base = class("Base")

function Base:ctor(talent)
	self.skill1 = talent.skill1
	self.skill2 = talent.skill2
	self.skill3 = talent.skill3
	self.value1 = talent.value1
	self.value2 = talent.value2
	self.value3 = talent.value3
	self:init()
end

function Base:init()
end

function Base:effectBeforeCreate(owner, army, enemy)
end

function Base:effectBeforeFight()
end

function Base:effectWhenHurtTarget(hpNum, flag, skillType, target)
	return hpNum
end

function Base:effectWhenGetHurt(hpNum, flag, skillType, target)
	return hpNum
end

function Base:effectWhenKillTarget(target)
end

function Base:effectWhenLockedByLegion(legion)
end

function Base:effectWhenCancelLockByLegion(legion)
end

function Base:effectWhenLockedBySoldier(target)
end

function Base:effectWhenUnlockBySoldier(target)
end

function Base:effectWhenLockTarget(target)
end

function Base:effectWhenCancelLock()
end

function Base:effectWhenDie(killer)
end

function Base:effectWhenUseSkill(skillObj)
end

function Base:effectWhenChangeHp()
end

function Base:effectWhenConsumeMp()
	return 0
end

function Base:effectWhenSummon(summon)
end

function Base:setOwner(owner)
	self.owner = owner
end

function Base:clone()
	local talent = {
		skill1 = self.skill1,
		skill2 = self.skill2,
		skill3 = self.skill3,
		value1 = self.value1,
		value2 = self.value2,
		value3 = self.value3
	}
	return self.new(talent)
end

return Base