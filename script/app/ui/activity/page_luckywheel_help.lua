local ActivityLimitGroupHelpUI = class("ActivityLimitGroupHelpUI", BaseUI)

function ActivityLimitGroupHelpUI:ctor()
	self.uiIndex = GAME_UI.UI_ACTIVITY_PETITIONHELP
end

function ActivityLimitGroupHelpUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))
	
	local panel = bg2:getChildByName('contentPanel')
	
	--title
	local title=ccui.Helper:seekWidgetByName(panel,"title_ex")
	title:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES18'))
	
	--info
	local info=panel:getChildByName('info')
	info:setString(string.format(GlobalApi:getLocalStr("ACTIVE_LUCKY_WHEEL_DES2"),tonumber(GlobalApi:getGlobalValue('luckyWheelTurnPond')),'\n',tonumber(GlobalApi:getGlobalValue('luckyWheelRankRequire')), '\n', '\n'))
	info:setPositionY(info:getPositionY() - 10)
	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			self:hideUI()
	    end
	end)
end

return ActivityLimitGroupHelpUI