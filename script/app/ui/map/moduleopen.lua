local ModuleOpenUI = class("ModuleOpenUI", BaseUI)
	
function ModuleOpenUI:ctor(id)
    self.uiIndex = GAME_UI.UI_MODULEOPENUI
    self.id = id
end

function ModuleOpenUI:init()
    local moduleBgImg = self.root:getChildByName("module_bg_img")
    local confIndex = MapData:getFightedCityId()
    local cityData = MapData.data[self.id]
    local moduleOpenId = cityData.conf.moduleOpenId
    local conf = GameData:getConfData("moduleopen")[moduleOpenId]
    local winSize = cc.Director:getInstance():getWinSize()
    moduleBgImg:setContentSize(winSize)
    moduleBgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    local topNode = moduleBgImg:getChildByName("top_node")
    local titleImg = topNode:getChildByName("title_img")
    local middleNode = moduleBgImg:getChildByName("middle_node")
    local contentImg = middleNode:getChildByName("content_img")
    contentImg:loadTexture("uires/ui/moduleopen/moduleopen_" .. conf.contentRes)
    contentImg:ignoreContentAdaptWithSize(true)
    contentImg:setTouchEnabled(true)
    titleImg:setVisible(false)
    -- titleImg:loadTexture("uires/ui/moduleopen/moduleopen_" .. conf.titleRes)
    -- titleImg:ignoreContentAdaptWithSize(true)
    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(500, 40))
    local rt = xx.RichTextImage:create("uires/ui/moduleopen/moduleopen_" .. conf.titleRes)
    local rt1 = xx.RichTextImage:create('uires/ui/moduleopen/moduleopen_dian.png')
    local rt2 = xx.RichTextImage:create('uires/ui/moduleopen/moduleopen_open.png')
    richText:addElement(rt)
    richText:addElement(rt1)
    richText:addElement(rt2)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(titleImg:getPosition()))
    topNode:addChild(richText)


    local lightImg = middleNode:getChildByName("light_img")
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))

    local bottomNode = moduleBgImg:getChildByName("bottom_node")
    local gotoBtn = bottomNode:getChildByName("goto_btn")
    local returnBtn = bottomNode:getChildByName("return_btn")
    local returnLabel = returnBtn:getChildByName("text")
    returnLabel:setString(GlobalApi:getLocalStr("STR_RETURN_1"))
    local gotoLabel = gotoBtn:getChildByName("text")
    gotoLabel:setString(GlobalApi:getLocalStr("GOTO"))
    local infoTx = bottomNode:getChildByName('info_tx')
    infoTx:setString(conf.text)
    -- contentImg:addClickEventListener(function ()
    --     titleImg:setVisible(false)
    --     lightImg:setVisible(false)
    --     gotoBtn:setVisible(false)
    --     contentImg:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.8, 0), cc.MoveTo:create(0.8, cc.p(0, 0))), cc.CallFunc:create(function()
    --         MapMgr:hideModuleopenPanel()
    --         MainSceneMgr:showMainCity(function()
    --             MainSceneMgr:setWinPosition(conf.module, true)
    --         end)
    --     end)))
    -- end)
    returnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideModuleopenPanel()
        end
    end)
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideModuleopenPanel()
            MainSceneMgr:showMainCity(function()
                MainSceneMgr:setWinPosition(conf.goto, true)
                if cityData.conf.guideIndex > 0 then
                    GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
                end
            end,conf.goto)
        end
    end)
    topNode:setPosition(cc.p(winSize.width/2, winSize.height))
    middleNode:setPosition(cc.p(winSize.width/2, winSize.height/2))
    bottomNode:setPosition(cc.p(winSize.width/2, 0))

    if cityData.conf.guideIndex > 0 then
        local guideFinger = GlobalApi:createLittleLossyAniByName("guide_finger")
        guideFinger:getAnimation():play("idle01", -1, 1)
        guideFinger:setName('guide_finger')
        guideFinger:setPosition(gotoBtn:getPosition())
        bottomNode:addChild(guideFinger)
        returnBtn:setTouchEnabled(false)
    end
end

return ModuleOpenUI