local BattleCounterUI = class("BattleCounterUI", BaseUI)

function BattleCounterUI:ctor()
    self.uiIndex = GAME_UI.UI_BATTLE_COUNTER
end

function BattleCounterUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg = self.root:getChildByName("bg_img")
    bgImg:setContentSize(winSize)
    bgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    
    local img = bgImg:getChildByName("img")
    img:setPosition(cc.p(winSize.width/2, winSize.height/2))

    local closeBtn = bgImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winSize.width - 160, winSize.height - 100))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
end

return BattleCounterUI