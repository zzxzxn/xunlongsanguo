local BaseClass = require("script/app/ui/battle/special/hero/base")

local LvMeng = class("LvMeng", BaseClass)

function LvMeng:init()
	self.addAttPercentFlag = false
end

-- 忽视目标对方护甲
function LvMeng:effectBeforeFight()
	if self.skill1 then
		self.owner.ignoreDef = self.owner.ignoreDef + self.value1[1]
	end
	if self.skill2 and #self.owner.beLockedEnemyArr == 0 then
		self.addAttPercentFlag = true
		self.owner.attPercent = self.owner.attPercent + self.value2[1]/100
	end
	if self.skill3 then
		self.owner.critCoefficient = self.value3[1]/100
	end
end

function LvMeng:effectWhenLockedBySoldier(target)
	if self.skill2 and self.addAttPercentFlag then
		self.addAttPercentFlag = false
		self.owner.attPercent = self.owner.attPercent - self.value2[1]/100
	end
end

function LvMeng:effectWhenUnlockBySoldier(target)
	if self.skill2 and not self.addAttPercentFlag and #self.owner.beLockedEnemyArr == 0 then
		self.addAttPercentFlag = true
		self.owner.attPercent = self.owner.attPercent + self.value2[1]/100
	end
end

return LvMeng