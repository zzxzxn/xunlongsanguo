local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideShowUI = class("GuideShowUI", ClassGuideBase)

function GuideShowUI:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
end

function GuideShowUI:startGuide()
    local uiObj = require("script/app/ui/guide/guideui/" .. self.guideObj.res).new()
    uiObj:showUI()
    if self.guideObj.func then
        uiObj[self.guideObj.func](uiObj)
    else
        self:finish()
    end
end

return GuideShowUI