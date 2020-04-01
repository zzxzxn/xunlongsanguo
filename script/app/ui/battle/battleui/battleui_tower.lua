local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleTowerUI = class("BattleTowerUI", ClassBattleUI)

function BattleTowerUI:calculateStar()
	local conf = GameData:getConfData('towertype')[self.customObj.levelType]
    if self.customObj.levelType == 1 then -- 按战斗时间计算星星
    	if self.time >= conf.condLevel2 + 1 then
    		self.starNum = 1
    	elseif self.time >= conf.condLevel3 + 1 then
    		self.starNum = 2
    	end
    else -- 按死亡人数计算星星
    	if self.dieLegionNum[1] > conf.condLevel2 then
    		self.starNum = 1
    	elseif self.dieLegionNum[1] > conf.condLevel3 then
    		self.starNum = 2
    	end
    end
end

return BattleTowerUI