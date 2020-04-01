local WorldWarHelpUI = class("WorldWarHelpUI", BaseUI)
function WorldWarHelpUI:ctor()
	self.uiIndex = GAME_UI.UI_WORLDWARHELP
end

function WorldWarHelpUI:init()
	local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideHelp()
        end
    end)
    local bgImg = worldwarImg:getChildByName('bg_img')
    for i=1,4 do
        local titleTx = bgImg:getChildByName('title_'..i..'_tx')
        local infoTx = bgImg:getChildByName('info_'..i..'_tx')
        titleTx:setString(GlobalApi:getLocalStr("WORLD_WAR_HELP_TITLE"..i))
        infoTx:setString(GlobalApi:getLocalStr("WORLD_WAR_HELP_DESC"..i))
    end
end

return WorldWarHelpUI