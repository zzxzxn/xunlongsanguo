local DragonHelpUI = class("DragonHelpUI", BaseUI)
function DragonHelpUI:ctor()
	self.uiIndex = GAME_UI.UI_DRAGONHELP
end

function DragonHelpUI:init()
	local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GoldmineMgr:hideDragonHelp()
        end
    end)
    local bgImg = worldwarImg:getChildByName('bg_img')
    for i=1,4 do
        local titleTx = bgImg:getChildByName('title_'..i..'_tx')
        titleTx:setString(GlobalApi:getLocalStr("DRAGON_HELP_DES"..i))
    end
end

return DragonHelpUI