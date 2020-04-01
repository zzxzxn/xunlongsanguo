local GuideBase = class("GuideBase")

function GuideBase:ctor()
end

function GuideBase:startGuide()
end

function GuideBase:onClickScreen()
end

function GuideBase:canSwallow(sender)
    return true
end

function GuideBase:clear()
end

function GuideBase:finish()
    self:clear()
    GuideMgr:nextStep()
end

return GuideBase