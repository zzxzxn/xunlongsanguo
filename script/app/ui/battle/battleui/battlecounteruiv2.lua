local BattleCounterV2UI = class("BattleCounterV2UI", BaseUI)

local COUNTER_COLOR_BROWN = cc.c4b(87, 38, 4, 255)

function BattleCounterV2UI:ctor()
    self.uiIndex = GAME_UI.UI_BATTLE_COUNTER_V2
end

function BattleCounterV2UI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg = self.root:getChildByName("bg_img")
    bgImg:setContentSize(winSize)
    bgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    
    local img = bgImg:getChildByName("img")
    img:setPosition(cc.p(winSize.width/2, winSize.height/2))

    local closeBtn = bgImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winSize.width, winSize.height - 50))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
end

return BattleCounterV2UI