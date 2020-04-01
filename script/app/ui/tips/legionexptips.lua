local LegionExpTipsUI = class("LegionExpTipsUI", BaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
function LegionExpTipsUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGIONEXPINFO
end

function LegionExpTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideLegionExpTips()
        end
    end)
	local bgimg1 = bgimg:getChildByName('bg_img_1')
	local bgimg2 = bgimg1:getChildByName('bg_img_2')
	self:adaptUI(bgimg, bgimg1)
	local desctx = bgimg2:getChildByName('desc_1')
	desctx:setString(GlobalApi:getLocalStr('LEGION_DESC5'))
	bgimg2:setPosition(cc.p(400,480))
end

return LegionExpTipsUI