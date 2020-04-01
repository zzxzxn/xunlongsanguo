local DigMineEventUI = class("DigMineEventUI", BaseUI)

function DigMineEventUI:ctor(eventType, eventObj, callback)
    self.uiIndex = GAME_UI.UI_DIGMINE_EVENT
    self.eventType = eventType
    self.eventObj = eventObj
    self.callback = callback
end

function DigMineEventUI:init()
    local event_bg_img = self.root:getChildByName("event_bg_img")
    self.event_img = event_bg_img:getChildByName("event_img")
    self:adaptUI(event_bg_img, self.event_img)

    event_bg_img:addClickEventListener(function ()
        DigMineMgr:hideDigMineEvent()
    end)

    self:initByEventType()
end

function DigMineEventUI:initByEventType()
    if self.eventType == "monster" then
        local main_img = self.event_img:getChildByName("main_img")
        main_img:ignoreContentAdaptWithSize(true)
        main_img:loadTexture("uires/ui/digmine/event_monster.png")

        local title_tx = self.event_img:getChildByName("title_tx")
        title_tx:setString(GlobalApi:getLocalStr("DIGMINE_EVENT_NAME_1"))

        local ok_btn = self.event_img:getChildByName("ok_btn")
        ok_btn:setPositionX(680)
        local ok_tx = ok_btn:getChildByName("ok_tx")
        ok_tx:setString(GlobalApi:getLocalStr("BEGIN_FIGHTING"))
        ok_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                DigMineMgr:hideDigMineEvent()
                if self.callback then
                    self.callback()
                    self.callback = nil
                end
            end
        end)

        local cancel_btn = self.event_img:getChildByName("cancel_btn")
        cancel_btn:setPositionX(280)
        local cancel_tx = cancel_btn:getChildByName("cancel_tx")
        cancel_tx:setString(GlobalApi:getLocalStr("LATER_ON"))
        cancel_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.callback = nil
                DigMineMgr:hideDigMineEvent()
            end
        end)

        local rt = xx.RichText:create()
        rt:setAnchorPoint(cc.p(0, 0.5))
        rt:setPosition(cc.p(360, 290))
        rt:setContentSize(cc.size(540, 54))

        local descStr = '<font color="#f9e3ccff" size="26">' .. GlobalApi:getLocalStr("DIGMINE_EVENT_DESC_1") .. '</font>'
        descStr = string.format(descStr, '</font><font color="#24ff00ff" size="26">' .. GlobalApi:getLocalStr("DIGMINE_EVENT_DESC_2") .. '</font><font color="#f9e3ccff" size="26">')
        xx.Utils:Get():analyzeHTMLTag(rt, descStr)
        self.event_img:addChild(rt)
    elseif self.eventType == "box" then
        local main_img = self.event_img:getChildByName("main_img")
        main_img:ignoreContentAdaptWithSize(true)
        main_img:loadTexture("uires/ui/digmine/event_box2.png")

        local title_tx = self.event_img:getChildByName("title_tx")
        title_tx:setString(GlobalApi:getLocalStr("DIGMINE_EVENT_NAME_2"))

        local ok_btn = self.event_img:getChildByName("ok_btn")
        ok_btn:setPositionX(480)
        local ok_tx = ok_btn:getChildByName("ok_tx")
        ok_tx:setString(GlobalApi:getLocalStr("STR_OPEN"))
        ok_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                DigMineMgr:hideDigMineEvent()
                if self.callback then
                    self.callback()
                    self.callback = nil
                end
            end
        end)

        local cancel_btn = self.event_img:getChildByName("cancel_btn")
        cancel_btn:setVisible(false)

        local rt = xx.RichText:create()
        rt:setAnchorPoint(cc.p(0, 0.5))
        rt:setPosition(cc.p(360, 290))
        rt:setContentSize(cc.size(540, 54))

        local descStr = '<font color="#f9e3ccff" size="26">' .. GlobalApi:getLocalStr("DIGMINE_EVENT_DESC_3") .. '</font>'
        descStr = string.format(descStr, '</font><font color="#24ff00ff" size="26">' .. GlobalApi:getLocalStr("DIGMINE_EVENT_DESC_4") .. '</font><font color="#f9e3ccff" size="26">')
        xx.Utils:Get():analyzeHTMLTag(rt, descStr)
        self.event_img:addChild(rt)

        if self.eventObj.needCash > 0 then
            local cash_img = ccui.ImageView:create("uires/icon/user/cash.png")
            cash_img:setScale(0.6)
            cash_img:setPosition(cc.p(450, 160))
            self.event_img:addChild(cash_img)
        
            local cash_tx = ccui.Text:create()
            cash_tx:setAnchorPoint(cc.p(0, 0.5))
            cash_tx:setFontName("font/gamefont.ttf")
            cash_tx:setFontSize(24)
            cash_tx:enableOutline(COLOR_TYPE.BLACK, 1)
            cash_tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            cash_tx:setString(tostring(self.eventObj.needCash))
            cash_tx:setPosition(cc.p(480, 160))
            self.event_img:addChild(cash_tx)
        end
    elseif self.eventType == "reward" then
         local main_img = self.event_img:getChildByName("main_img")
        main_img:ignoreContentAdaptWithSize(true)
        main_img:loadTexture("uires/ui/digmine/event_box1.png")

        local title_tx = self.event_img:getChildByName("title_tx")
        title_tx:setString(GlobalApi:getLocalStr("LEGION_LEVELS_DESC8"))

        local ok_btn = self.event_img:getChildByName("ok_btn")
        ok_btn:setPositionX(480)
        local ok_tx = ok_btn:getChildByName("ok_tx")
        ok_tx:setString(GlobalApi:getLocalStr("OPEN_AND_SEE"))
        ok_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                DigMineMgr:hideDigMineEvent()
                if self.callback then
                    self.callback()
                    self.callback = nil
                end
            end
        end)

        local cancel_btn = self.event_img:getChildByName("cancel_btn")
        cancel_btn:setVisible(false)

        local rt = xx.RichText:create()
        rt:setAnchorPoint(cc.p(0, 0.5))
        rt:setPosition(cc.p(360, 290))
        rt:setContentSize(cc.size(540, 54))

        local descStr = '<font color="#f9e3ccff" size="26">' .. GlobalApi:getLocalStr("DIGMINE_EVENT_DESC_5") .. '</font>'
        xx.Utils:Get():analyzeHTMLTag(rt, descStr)
        self.event_img:addChild(rt)
    end
end

return DigMineEventUI