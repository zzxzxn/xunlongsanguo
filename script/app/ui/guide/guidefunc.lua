local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideFunc = class("GuideFunc", ClassGuideBase)

function GuideFunc:ctor(guideNode, guideObj, flag)
    self.guideObj = guideObj
    self.guideNode = guideNode
    self.flag = flag
end

function GuideFunc:startGuide()
    local guideObj = self.guideObj
    if guideObj.interrupt and not self.flag then -- 这个引导是中断重登时才会有的引导
        self:finish()
    else
        if guideObj.uiindex then
            local uiObj = UIManager:getUIByIndex(guideObj.uiindex)
            if uiObj then
                local function doit()
                    if uiObj[guideObj.func] then
                        uiObj[guideObj.func](uiObj)
                    end
                end
                if UIManager:getTopNodeIndex() == guideObj.uiindex and not UIManager:getUIByIndex(guideObj.uiindex)._showAnimation then
                    doit()
                else
                    CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
                        if UIManager:getTopNodeIndex() == guideObj.uiindex then
                            CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
                            doit()
                        end
                    end)
                end
            end
        else
            if GuideMgr[guideObj.func] then
                if guideObj.arg then
                    GuideMgr[guideObj.func](GuideMgr, guideObj.arg)
                else
                    GuideMgr[guideObj.func](GuideMgr)
                end
            end
        end
    end
end

function GuideFunc:clear()
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
end

return GuideFunc