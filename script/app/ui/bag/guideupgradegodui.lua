local GuideUpgradeGodUI = class("GuideUpgradeGodUI", BaseUI)

function GuideUpgradeGodUI:ctor(ntype)
    self.uiIndex = GAME_UI.UI_GUIDE_UPGRADE_GOD
    self.ntype = ntype
end

function GuideUpgradeGodUI:init()
    local guideImg = self.root:getChildByName("guide_img")
    self.pl1 = guideImg:getChildByName("pl_1")
    self.pl2 = guideImg:getChildByName("pl_2")
    self:adaptUI(guideImg, self.pl1)
    self:adaptUI(guideImg, self.pl2)
    self:showPl(self.ntype)
end

function GuideUpgradeGodUI:showPl(ntype)
    if ntype == 1 then
        self.pl1:setVisible(true)
        self.pl2:setVisible(false)
    else
        self.pl1:setVisible(false)
        self.pl2:setVisible(true)
    end
end

return GuideUpgradeGodUI