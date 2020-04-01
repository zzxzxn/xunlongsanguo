local LegionIconSelectUI = class("LegionIconSelectUI", BaseUI)

function LegionIconSelectUI:ctor(legionMemberData)
    self.uiIndex = GAME_UI.UI_LEGIONICONSELECTUI
    self.legionMemberData = legionMemberData
end

function LegionIconSelectUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionIconSelectUI()
    --     end
    -- end)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionIconSelectUI()
        end
    end)
    local iconConf = GameData:getConfData("legionicon")
    for i=1, #iconConf do
        local iconbg = ccui.ImageView:create(COLOR_FRAME[iconConf[i].frameQuality])
        local iconSize = iconbg:getContentSize()
        local rowIndex = math.ceil(i/5) - 1
        local colIndex = (i - 1)%5
        iconbg:setPosition(cc.p(86 + colIndex*141, 413 - rowIndex*113))
        bgimg2:addChild(iconbg)

        local iconimg = ccui.ImageView:create(iconConf[i].icon)
        iconimg:setPosition(cc.p(iconSize.width/2, iconSize.height/2))
        iconbg:addChild(iconimg)

        iconbg:setTouchEnabled(true)
        iconbg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if i ~= LegionMgr:getSelectIconID() then
                    if iconConf[i].condition == "vip_level" then
                        if self.legionMemberData then
                            local haveHighVip = false
                            for k, v in pairs(self.legionMemberData) do
                                if v.vip >= iconConf[i].value then
                                    haveHighVip = true
                                    break
                                end
                            end
                            if haveHighVip then
                                LegionMgr:setSelectIconChange(true)
                                LegionMgr:setSelectIconID(i)
                                LegionMgr:hideLegionIconSelectUI()
                            else
                                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("OPEN_WHEN_LEGION_HAVE"), "VIP" .. iconConf[i].value), COLOR_TYPE.RED)
                            end
                        else
                            if UserData:getUserObj():getVip() >= iconConf[i].value then
                                LegionMgr:setSelectIconChange(true)
                                LegionMgr:setSelectIconID(i)
                                LegionMgr:hideLegionIconSelectUI()
                            else
                                promptmgr:showSystenHint("VIP" .. iconConf[i].value .. GlobalApi:getLocalStr("SELECE_LEGION_ICON_NEED_VIP"), COLOR_TYPE.RED)
                            end
                        end
                    else
                        LegionMgr:setSelectIconChange(true)
                        LegionMgr:setSelectIconID(i)
                        LegionMgr:hideLegionIconSelectUI()
                    end
                else
                    LegionMgr:setSelectIconID(i)
                    LegionMgr:hideLegionIconSelectUI()
                end
            end
        end)        
    end
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ICON_TITLE'))
    self:adaptUI(bgimg1, bgimg2)
end

return LegionIconSelectUI