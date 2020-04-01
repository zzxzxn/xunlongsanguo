local GuideFirstUI = class("GuideFirstUI", BaseUI)

function GuideFirstUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDEFIRST
end

function GuideFirstUI:init()
    local guidefirstBgImg = self.root:getChildByName("guidefirst_bg_img")
    local guidefirstImg = guidefirstBgImg:getChildByName("guidefirst_img")
    self:adaptUI(guidefirstBgImg, guidefirstImg)
    UIManager:getSidebar():setFrameBtnsVisible(false)
    -- UIManager:getSidebar():setRightLowerVisible(false)
end

function GuideFirstUI:showShip()
    GuideMgr:finishCurrGuide()
end

function GuideFirstUI:goNextScene()
    UIManager:runLoadingAction(true, function ()
        GuideMgr:finishCurrGuide()
    end)
end

function GuideFirstUI:showDragonEgg()
    local winsize = cc.Director:getInstance():getWinSize()
    -- ani:registerSpineEventHandler(function (event)
    --     if event.animation == "idle01" then
    --         -- 粒子
    --         local particle = cc.ParticleSystemQuad:create("particle/guide_egg_point.plist")
    --         particle:setPosition(cc.p(winsize.width/2, winsize.height/2))
    --         particle:setName("guide_egg_point")
    --         self.root:addChild(particle)
    --         local guidesecondBgImg = self.root:getChildByName("guidefirst_bg_img")
    --         local eggBtn = guidesecondBgImg:getChildByName("egg_btn")
    --         eggBtn:setTouchEnabled(true)
    --         eggBtn:setContentSize(winsize)
    --         ani:setAnimation(0, "idle02", true)
    --         GuideMgr:finishCurrGuide()
    --     end
    -- end, sp.EventType.ANIMATION_COMPLETE)
    -- ani:setAnimation(0, "idle01", false)

    -- 粒子
    local particle = cc.ParticleSystemQuad:create("particle/guide_egg_point.plist")
    particle:setPosition(cc.p(winsize.width/2, winsize.height/2))
    particle:setName("guide_egg_point")
    self.root:addChild(particle)
    local guidesecondBgImg = self.root:getChildByName("guidefirst_bg_img")
    local eggBtn = guidesecondBgImg:getChildByName("egg_btn")
    eggBtn:setTouchEnabled(true)
    eggBtn:setContentSize(winsize)
    GuideMgr:finishCurrGuide()

    -- UIManager:getSidebar():setRightLowerVisible(false)
end

function GuideFirstUI:showGuideTreasure()
    local particle = self.root:getChildByName("guide_egg_point")
    if particle then
        particle:removeFromParent()
    end
    local guideTreasureUI = require("script/app/ui/guide/guideui/guidetreasure").new()
    guideTreasureUI:showUI()
    GuideMgr:finishCurrGuide()
end

function GuideFirstUI:hideRightLower()
    -- UIManager:getSidebar():setRightLowerVisible(false)
    GuideMgr:finishCurrGuide()
end

return GuideFirstUI