local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideModuleOpen = class("ModuleOpenUI", ClassGuideBase)
	
function GuideModuleOpen:ctor(guideNode, guideObj)
    self.guideNode = guideNode
    self.guideObj = guideObj
end

function GuideModuleOpen:startGuide()
    local confIndex = MapData:getFightedCityId()
    local conf = GameData:getConfData("moduleopen")[self.guideObj.modulekey]
    if conf then
        local winSize = cc.Director:getInstance():getWinSize()
        local ui = cc.CSLoader:createNode("csb/moduleopen.csb")
        self.guideNode:addChild(ui)

        local moduleBgImg = ui:getChildByName("module_bg_img")
        moduleBgImg:setContentSize(winSize)
        moduleBgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))

        local topNode = moduleBgImg:getChildByName("top_node")
        local titleImg = topNode:getChildByName("title_img")
        local middleNode = moduleBgImg:getChildByName("middle_node")
        local contentImg = middleNode:getChildByName("content_img")
        contentImg:loadTexture("uires/ui/moduleopen/moduleopen_" .. conf.contentRes)
        contentImg:ignoreContentAdaptWithSize(true)
        contentImg:setTouchEnabled(true)

        local lightImg = middleNode:getChildByName("light_img")
        lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))

        local bottomNode = moduleBgImg:getChildByName("bottom_node")
        local gotoBtn = bottomNode:getChildByName("goto_btn")
        local gotoLabel = gotoBtn:getChildByName("text")
        gotoLabel:setString(GlobalApi:getLocalStr("GOTO"))
        contentImg:addClickEventListener(function ()
            titleImg:setVisible(false)
            lightImg:setVisible(false)
            gotoBtn:setVisible(false)
            contentImg:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.8, 0), cc.MoveTo:create(0.8, cc.p(0, 0))), cc.CallFunc:create(function()
                ui:removeFromParent()
                self:finish()
            end)))
        end)
        gotoBtn:addClickEventListener(function ()
            titleImg:setVisible(false)
            lightImg:setVisible(false)
            gotoBtn:setVisible(false)
            contentImg:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.8, 0), cc.MoveTo:create(0.8, cc.p(0, 0))), cc.CallFunc:create(function()
                ui:removeFromParent()
                self:finish()
            end)))
        end)
        topNode:setPosition(cc.p(winSize.width/2, winSize.height))
        middleNode:setPosition(cc.p(winSize.width/2, winSize.height/2))
        bottomNode:setPosition(cc.p(winSize.width/2, 0))
    else
        self:finish()
    end
end

function GuideModuleOpen:canSwallow()
    return false
end

return GuideModuleOpen