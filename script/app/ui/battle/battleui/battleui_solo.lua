local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleSoloUI = class("BattleSoloUI", ClassBattleUI)

-- 40秒内击败守卫为3星，60秒内击败守卫为2星
function BattleSoloUI:calculateStar()
	if self.time >= 61 then
		self.starNum = 1
	elseif self.time >= 41 then
		self.starNum = 2
	end
end

return BattleSoloUI