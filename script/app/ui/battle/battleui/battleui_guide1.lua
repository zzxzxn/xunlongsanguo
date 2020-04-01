local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local GuideBattle1UI = class("GuideBattle1UI", ClassBattleUI)

function GuideBattle1UI:initCompleted()
    self.backBtn2:setVisible(false)
    self.battleBtn:setVisible(false)

    for i = 1, 9 do
        self.pedestalArr[i]:setTouchEnabled(false)
    end

    for i, v in ipairs(self.armyflags) do
        v:setVisible(false)
    end

    for k, v in ipairs(self.armyStars) do
        for k2, v2 in ipairs(v) do
            v2:setVisible(false)
        end
    end

    for k, v in pairs(self.playerSkillStatusArr[1]) do
        ShaderMgr:setGrayForWidget(v.border)
        v.border:setTouchEnabled(false)
    end
    
    self.fightforceNode:setVisible(false)
    self.skillListNode:setVisible(false)

    self.speedUp = 2.5
end

function GuideBattle1UI:otherSpecialHandle()
    self:beforeFight()
end

function GuideBattle1UI:battleStart()
    self.super.battleStart(self)
    self.skillPointImg:setVisible(false)
    self.autoBtn:setVisible(false)
    self.pauseBtn:setVisible(false)
    self.speedBtn:setVisible(false)
    local tipsTx = self.root:getChildByName("tips_tx")
    if tipsTx then
        tipsTx:removeFromParent()
    end
end

function GuideBattle1UI:addKillAnimation()
end

function GuideBattle1UI:sendMessageAfterFight(isWin)
    BattleMgr:showBattleResult(isWin, {}, 3)
end

return GuideBattle1UI