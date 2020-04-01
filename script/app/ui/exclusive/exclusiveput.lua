local ExclusivePutUI = class("ExclusivePutUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function ExclusivePutUI:ctor(obj,pos,callBack)
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_PUT
	self.pos = pos
	self.obj = obj
	self.callBack = callBack
end

function ExclusivePutUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self:adaptUI(bgImg, bgImg1)
	local winSize = cc.Director:getInstance():getVisibleSize()
	if self.pos then
		bgImg1:setPosition(self.pos)
	else
		bgImg1:setPosition(cc.p(winSize.width/2 - 180,winSize.height - 160))
	end

	bgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			ExclusiveMgr:hideExclusivePutUI()
		end
	end)

	local sv = bgImg1:getChildByName('sv')
	sv:setScrollBarEnabled(false)
	ClassItemCell:createExclusiveInfo(sv,10,self.obj)

	local autoBtn = bgImg1:getChildByName('auto_btn')
	autoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			if self.callBack then
				self.callBack()
			end
			ExclusiveMgr:hideExclusivePutUI()
		end
	end)
	autoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr("EXCLUSIVE_DESC_110"))

end

return ExclusivePutUI