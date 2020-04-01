local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideClick = class("GuideClick", ClassGuideBase)

function GuideClick:ctor(guideNode, guideObj, saveWithClick)
    self.guideObj = guideObj
    self.guideNode = guideNode
    self.flag = true
    self.saveWithClick = saveWithClick
end

function GuideClick:startGuide()
    local guideObj = self.guideObj
    self.uiShowFlag = false
    self.swallowBeforeShow = guideObj.swallowbeforeshow
    local function doit()
        self.uiShowFlag = true
        local parentNode
        local uiObj
        if guideObj.specialui and guideObj.specialui == "sidebar" then
            uiObj = UIManager:getSidebar()
            parentNode = uiObj:getNode()
        else
            uiObj = UIManager:getUIByIndex(guideObj.uiindex)
            parentNode = uiObj.root
        end
        local widget
        local index = 1
        local maxNum = #guideObj.widgetindex
        while index <= maxNum do
            local name = guideObj.widgetindex[index]
            local isActivity = guideObj.isActivity
            if isActivity then
                local activityName = guideObj.activityname
                name =  GuideMgr:getActivityBtnName(activityName)
                if not name then
                    GuideMgr:saveAndFinish()
                    return
                end
            end
            if type(name) == "number" then
               widget = xx.Utils:Get():seekNodeByTag(parentNode, name)
            else
               widget = xx.Utils:Get():seekNodeByName(parentNode, name)
            end
            parentNode = widget
            index = index + 1
        end
        if widget == nil then
            GuideMgr:saveAndFinish()
            return
        end
        self.clickWidget = widget
        self.clickWidget:setTouchEnabled(true)
        local widgetSize = widget:getContentSize()
        local touchScale = self.guideObj.touchScale or 1
        local touchOffsetW = widgetSize.width*(1 - touchScale)/2
        local touchOffsetH = widgetSize.height*(1 - touchScale)/2
        self.touchRect = cc.rect(touchOffsetW+1, touchOffsetH+1, widgetSize.width-touchOffsetW*2-2, widgetSize.height-touchOffsetH*2-2)
        local _propagateTouchEvents = widget:isPropagateTouchEvents()
        widget:setPropagateTouchEvents(false)

        local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
        self.hand = hand
        hand:getAnimation():play("idle01", -1, 1)
        hand:setRotation(guideObj.rotation)
        if guideObj.hideHand then
            hand:setVisible(false)
        end
        local widgetScreenPos = widget:getParent():convertToWorldSpace(cc.p(widget:getPosition()))
        if guideObj.addtowidget then
            hand:setPosition(cc.pAdd(cc.p(widgetSize.width/2, widgetSize.height/2), guideObj.pos))
            hand:setLocalZOrder(100000)
            widget:addChild(hand)
        else
            hand:setPosition(cc.pAdd(widgetScreenPos, guideObj.pos))
            hand:setLocalZOrder(2)
            self.guideNode:addChild(hand)
        end
        local widget2 = ccui.Widget:create()
        self.widget2 = widget2
        widget2:registerScriptHandler(function (event)
            if event == "exit" then
                widget2:unregisterScriptHandler()
                self.clickWidget = nil
                self.widget2 = nil
            end
        end)

        widget2:setAnchorPoint(cc.p(0, 0))
        widget2:setContentSize(widgetSize)
        widget2:setTouchEnabled(true)
        widget2:setSwallowTouches(false)
        widget2:setPropagateTouchEvents(false)
        --防止滑动手指消失却没有触发引导
        widget2:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                if self.saveWithClick then
                    GuideMgr.saveWithMsg = true
                end
            elseif eventType == ccui.TouchEventType.canceled then
                if self.saveWithClick then
                    GuideMgr.saveWithMsg = false
                end
            elseif eventType == ccui.TouchEventType.ended then
                if guideObj.finish == "msg" then
                    CustomEventMgr:addEventListener(CUSTOM_EVENT.MSG_RESPONSE, self, function ()
                        self:clickOver()
                        CustomEventMgr:removeEventListener(CUSTOM_EVENT.MSG_RESPONSE, self)
                        self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                            self:finish()
                        end)))
                    end)
                elseif guideObj.finish == "normal" then
                    self:clickOver()
                    self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                        self:finish()
                    end)))
                else
                    self:clickOver()
                end
            elseif eventType == ccui.TouchEventType.moved then
            end
        end)
        
        -- 是否高亮
        if guideObj.hightlight then
            local winsize = cc.Director:getInstance():getWinSize()
            local pos = widget:getParent():convertToWorldSpace(cc.p(widget:getPosition()))
            local clone = widget:clone()
            clone:setSwallowTouches(false)
            clone:setPosition(pos)
            clone:addClickEventListener(function ()
            end)
            clone:addTouchEventListener(function (sender, eventType)
            end)
            local bg = ccui.ImageView:create("uires/ui/common/bg1_gray44.png")
            bg:setScale9Enabled(true)
            bg:setContentSize(winsize)
            bg:setPosition(winsize.width / 2, winsize.height / 2)
            self.guideNode:addChild(bg)
            self.guideNode:addChild(clone)
            self.cloneWidgetBg = bg
            self.cloneWidget = clone
        end
        -- 显示提示
        if guideObj.showtips then
            -- local guidetextConf = GameData:getConfData("local/guidetext")[guideObj.tipstext]
            -- local dialogNode = cc.Node:create()
            -- self.dialogNode = dialogNode
            -- local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_2.png")
            -- local npc = ccui.ImageView:create("uires/ui/yindao/yindao_5.png")
            -- local npcSize = npc:getContentSize()
            -- local pos = cc.p(0,0)
            -- npc:setPosition(pos)
            -- local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont.ttf", 21)
            -- label:setAlignment(0)
            -- label:setVerticalAlignment(1)
            -- label:setMaxLineWidth(230)
            -- label:setTextColor(COLOR_TYPE.WHITE)
            -- label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            -- local labelSize = label:getContentSize()
            -- dialog:setScale9Enabled(true)
            -- dialog:setContentSize(labelSize.width + 30, labelSize.height + 30)
            -- dialog:setPosition(cc.p(pos.x + npcSize.width/2 - 20, pos.y + npcSize.width/2 - dialog:getContentSize().height/2 + 10))
            -- label:setPosition(dialog:getPosition())


            local guidetextConf = GameData:getConfData("local/guidetext")[guideObj.tipstext]
            local dialogNode = cc.Node:create()
            self.dialogNode = dialogNode
            local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_8.png")
            local npc = GlobalApi:createLittleLossyAniByName("guide_npc_2")
            local npcSize = npc:getContentSize()
            local pos = cc.p(0,0)
            npc:getAnimation():play("idle", -1, -1)
            local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont.ttf", 21)
            label:setAlignment(0)
            label:setVerticalAlignment(1)
            label:setMaxLineWidth(230)
            label:setTextColor(COLOR_TYPE.WHITE)
            label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            label:setAnchorPoint(cc.p(0.5, 1))
            local labelSize = label:getContentSize()
            dialog:setScale9Enabled(true)

            dialog:setPosition(cc.p(pos.x + npcSize.width/2 - 20, pos.y + npcSize.width/2 - dialog:getContentSize().height/2 + 10))
            npc:setPosition(cc.pAdd(pos, cc.p(290, 34)))
            label:setPosition(cc.p(dialog:getPositionX() - 70, dialog:getPositionY() + 45))

            --默认人在右边
            if guideObj.direction == "left" then
                npc:setScaleX(-1)
                dialog:setScaleX(-1)
                dialog:setPosition(cc.p(pos.x + npcSize.width/2 - 20, pos.y + npcSize.width/2 - dialog:getContentSize().height/2 + 10))
                npc:setPosition(cc.pAdd(pos, cc.p(-40, 34)))
                label:setPosition(cc.p(dialog:getPositionX() + 40, dialog:getPositionY() + 45))
            end

            -- npc:setPosition(pos)
            -- label:setPosition(dialog:getPosition())


            dialogNode:setPosition(cc.pAdd(widgetScreenPos, guideObj.tipspos))
            dialogNode:addChild(dialog)
            dialogNode:addChild(label)
            dialogNode:addChild(npc)
            AudioMgr.playEffect("media/guide/" .. guidetextConf.soundRes, false)

            local winSize = cc.Director:getInstance():getVisibleSize()
            local node = cc.ClippingNode:create()
            node:setPosition(cc.p(0, 0))
            node:setAlphaThreshold(0.05)
            node:setInverted(true)
            local stencil = cc.Sprite:create('uires/ui/yindao/yindao_bg_black1.png')
            stencil:setPosition(hand:getPosition())
            node:setStencil(stencil)
            local img = ccui.ImageView:create('uires/ui/common/bg1_gray44.png')
            img:setContentSize(winSize)
            img:setScale9Enabled(true)
            img:setPosition(cc.p(winSize.width/2, winSize.height/2))
            node:addChild(img,999)
            node:setName("clipNode")
            self.guideNode:addChild(node, 999)

            self.guideNode:addChild(dialogNode,1000)
        end
        widget:addChild(widget2)
        if guideObj.func and uiObj and uiObj[guideObj.func] then
            uiObj[guideObj.func](uiObj)
        end
    end

    local doit2 = function()
        if guideObj.delay then
            self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(guideObj.delay), cc.CallFunc:create(function()
                doit()
            end)))
        else
            doit()
        end
    end

    if guideObj.specialui then
        doit2()
    else
        if UIManager:getTopNodeIndex() == guideObj.uiindex and not UIManager:getUIByIndex(guideObj.uiindex)._showAnimation then
            doit2()
        else
            CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
                if UIManager:getTopNodeIndex() == guideObj.uiindex then
                    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
                    doit2()
                end
            end)
        end
    end
end

function GuideClick:clickOver()
    if self.guideNode:getChildByName("clipNode") then
        self.guideNode:getChildByName("clipNode"):removeFromParent()
    end
    if self.clickWidget then
        self.clickWidget:setPropagateTouchEvents(_propagateTouchEvents)
        self.clickWidget = nil
    end
    if self.widget2 then
        self.widget2:removeFromParent()
    end
    self.hand:removeFromParent()
    if self.guideObj.hightlight then
        self.cloneWidgetBg:removeFromParent()
        self.cloneWidget:removeFromParent()
    end
    if self.guideObj.showtips then
        self.dialogNode:removeFromParent()
    end
end

function GuideClick:clear()
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
    CustomEventMgr:removeEventListener(CUSTOM_EVENT.MSG_RESPONSE, self)
end

function GuideClick:canSwallow(sender)
    self.flag = true
    if self.swallowBeforeShow and not self.uiShowFlag then -- 打开界面前可以随便点
        self.flag = false
    else
        if self.clickWidget and self.clickWidget:isVisible() and self.clickWidget:isTouchEnabled() and not UIManager:isBlockTouch() then
            local pos = sender:getTouchBeganPosition()
            local posx, posy = self.clickWidget:getPosition()
            local wpos = self.clickWidget:convertToNodeSpace(pos)
            if cc.rectContainsPoint(self.touchRect, wpos) then
                self.flag = false
            end
        end
    end
    return self.flag
end

function GuideClick:onClickScreen()
    if self.flag then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("GUIDE_INFO_1"), COLOR_TYPE.GREEN)
    end
end

return GuideClick