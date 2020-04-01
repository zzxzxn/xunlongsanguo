local RechargeWaittingUI = class("RechargeWaittingUI", BaseUI)

function RechargeWaittingUI:ctor()
    self.uiIndex = GAME_UI.UI_RECHARGE_WAITING
end

function RechargeWaittingUI:init()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    local winSize = cc.Director:getInstance():getWinSize()

    local spine = GlobalApi:createSpineByName("guide_zhuizhu", "spine/guide_zhuizhu/guide_zhuizhu", 1)
    spine:setPosition(cc.p(winSize.width/2, winSize.height/2 - 80))
    bg_img:addChild(spine)
    spine:setAnimation(0, "run", true)
end

return RechargeWaittingUI