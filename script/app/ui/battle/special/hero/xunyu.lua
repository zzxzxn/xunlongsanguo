local BaseClass = require("script/app/ui/battle/special/hero/base")

local XunYu = class("XunYu", BaseClass)

function XunYu:init()
	self.addTimes = 0
	self.lastLockEnemy = nil
end

-- 所有本方武将获取怒气速度增加
function XunYu:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			v.heroInfo.recoverMp = v.heroInfo.recoverMp + self.value1[1]
			if v.heroInfo.recoverMp < -100 then
				v.heroInfo.recoverMp = -100
			end
		end
	end
end

-- 每次攻击降低对方护甲，切换目标时清除
function XunYu:effectWhenUseSkill(skillObj)
	if self.skill2 and self.owner.lockEnemy and self.addTimes < self.value2[2] then
		if self.lastLockEnemy == nil then
			self.lastLockEnemy = self.owner.lockEnemy
		end
		self.addTimes = self.addTimes + 1
		self.owner.lockEnemy.phyDef = self.owner.lockEnemy.phyDef + self.owner.lockEnemy.basePhyDef*self.value2[1]/100
		self.owner.lockEnemy.magDef = self.owner.lockEnemy.magDef + self.owner.lockEnemy.baseMagDef*self.value2[1]/100
	end
end

function XunYu:effectWhenCancelLock()
	if self.skill2 and self.addTimes > 0 and self.lastLockEnemy then
		self.lastLockEnemy.phyDef = self.lastLockEnemy.phyDef - self.lastLockEnemy.basePhyDef*self.value2[1]/100*self.addTimes
		self.lastLockEnemy.magDef = self.lastLockEnemy.magDef - self.lastLockEnemy.baseMagDef*self.value2[1]/100*self.addTimes
		self.lastLockEnemy = nil
		self.addTimes = 0
	end
end

function XunYu:effectWhenConsumeMp()
	if self.skill3 then
		return self.owner.maxMp*self.value3[1]/100
	else
		return 0
	end
end

return XunYu