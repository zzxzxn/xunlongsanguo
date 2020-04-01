local ExclusiveTipsUI = class("ExclusiveTipsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')
local MAX_PAGE = 5
function ExclusiveTipsUI:ctor(obj,pos)
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_TIPS
	self.pos = pos
	self.obj = obj
end

function ExclusiveTipsUI:init()
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
			ExclusiveMgr:hideExclusiveTipsUI()
		end
	end)

	local sv = bgImg1:getChildByName('sv')
	sv:setScrollBarEnabled(false)
	if not self.obj.showEffectDesc then
		ClassItemCell:createExclusiveInfo(sv,10,self.obj:getObj())
	else
		ClassItemCell:createExclusiveInfo(sv,10,self.obj)
	end
end

return ExclusiveTipsUI