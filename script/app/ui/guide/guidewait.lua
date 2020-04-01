local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideWait = class("GuideWait", ClassGuideBase)

function GuideWait:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
end

function GuideWait:startGuide()
	if self.guideObj.uiindex then
		if UIManager:getTopNodeIndex() == self.guideObj.uiindex and not UIManager:getUIByIndex(self.guideObj.uiindex)._showAnimation then
            self:finish()
        else
            CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
                if UIManager:getTopNodeIndex() == self.guideObj.uiindex then
                    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
                    self:finish()
                end
            end)
        end
	else
	    self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(self.guideObj.time), cc.CallFunc:create(function ()
	        self:finish()
	    end)))
   	end
end

function GuideWait:clear()
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
end

return GuideWait