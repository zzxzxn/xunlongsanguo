local GuideStoryTwoUI = class("GuideStoryTwoUI", BaseUI)

function GuideStoryTwoUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDESTORY
    self.audioIds = {}
end

function GuideStoryTwoUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    self.bg_img = self.root:getChildByName("bg_img")
    self.bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))

    self.skipBtn = ccui.Button:create("uires/ui/common/btn_skip2.png")
    self.skipBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:finish()
        end
    end)
    self.skipBtn:setPosition(cc.p(winSize.width - 80, winSize.height - 60))
    self.root:addChild(self.skipBtn)
end

function GuideStoryTwoUI:start()
    self:step1()
end

function GuideStoryTwoUI:step1()
    local musicId = UIManager:playBgm(1)
    local volume = AudioMgr.musicVal*0.4
    ccexp.AudioEngine:setVolume(musicId, volume)

    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setContentSize(cc.size(772, 432))
    blackBorder:setPosition(cc.p(180, 170))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(768, 428))
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg14.png")
    bg:setPosition(cc.p(384, 214))
    layout:addChild(bg)

    local zhaoyun = GlobalApi:createLittleLossyAniByName("guide_npc_10")
    zhaoyun:setScale(0.6)
    zhaoyun:setPosition(cc.p(520, 100))
    zhaoyun:getAnimation():play("idle", -1, 1)
    bg:addChild(zhaoyun)

    local zhangfei = GlobalApi:createLittleLossyAniByName("guide_npc_5")
    zhangfei:setScale(-0.8, 0.8)
    zhangfei:setPosition(cc.p(180, 20))
    zhangfei:getAnimation():play("zhaoji", -1, 1)
    bg:addChild(zhangfei)

    local dialog1 = self:createDialog("GUIDE_TEXT_124", 1)
    dialog1:setPosition(cc.p(240, 180))
    blackBorder:addChild(dialog1)
    dialog1:setScale(0)
    dialog1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        self:playSound("GUIDE_TEXT_124")
    end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(5), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
        local dialog2 = self:createDialog("GUIDE_TEXT_125", 4)
        dialog2:setPosition(cc.p(460, 220))
        blackBorder:addChild(dialog2)
        dialog2:setScale(0)
        zhaoyun:getAnimation():play("amaze", -1, 0)
        self:playSound("GUIDE_TEXT_125")
        dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            zhaoyun:getAnimation():play("idle", -1, 1)
            bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.4), cc.CallFunc:create(function()
                local dialog3 = self:createDialog("GUIDE_TEXT_126", 4)
                dialog3:setPosition(cc.p(500, 220))
                blackBorder:addChild(dialog3)
                dialog3:setScale(0)
                self:playSound("GUIDE_TEXT_126")
                dialog3:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.DelayTime:create(1), cc.CallFunc:create(function()
                    local dialog4 = self:createDialog("GUIDE_TEXT_127", 1)
                    dialog4:setPosition(cc.p(180, 160))
                    blackBorder:addChild(dialog4)
                    dialog4:setScale(0)
                    self:playSound("GUIDE_TEXT_127")
                    dialog4:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2.5), cc.FadeOut:create(0.2), cc.DelayTime:create(1), cc.CallFunc:create(function()
                        zhangfei:pause()
                        zhaoyun:getAnimation():play("speechless", -1, 0)
                        local dialog5 = self:createDialog("GUIDE_TEXT_128", 4)
                        dialog5:setPosition(cc.p(520, 200))
                        blackBorder:addChild(dialog5)
                        dialog5:setScale(0)
                        self:playSound("GUIDE_TEXT_128")
                        dialog5:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                            zhangfei:setPosition(cc.p(180, 100))
                            zhangfei:setScale(-0.8)
                            local shadow = zhangfei:getBone("guide_npc_5_shadow")
                            if shadow then
                                shadow:changeDisplayWithIndex(-1, true)
                            end
                            local dialog7 = self:createDialog("GUIDE_TEXT_130", 1)
                            dialog7:setPosition(cc.p(180, 80))
                            blackBorder:addChild(dialog7)
                            dialog7:setScale(0)
                            self:playSound("GUIDE_TEXT_130")
                            dialog7:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
                        end), cc.DelayTime:create(2), cc.CallFunc:create(function()
                            zhaoyun:getAnimation():play("didi", -1, 1)
                            bg:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.2, 2),cc.MoveBy:create(0.2, cc.p(-100, 0))), cc.CallFunc:create(function()
                                local dialog6 = self:createDialog("GUIDE_TEXT_129", 4)
                                dialog6:setPosition(cc.p(500, 240))
                                blackBorder:addChild(dialog6)
                                dialog6:setScale(0)
                                self:playSound("GUIDE_TEXT_129")
                                dialog6:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.DelayTime:create(1), cc.CallFunc:create(function()
                                    self:finish()
                                end)))
                            end)))
                        end)))
                    end)))
                end)))
            end)))
        end)))
    end)))
end

function GuideStoryTwoUI:finish()
    self.skipBtn:setTouchEnabled(false)
    for id, v in pairs(self.audioIds) do
        AudioMgr.stopEffect(id)
    end
    self:hideUI()
    GuideMgr:finishCurrGuide()
end

function GuideStoryTwoUI:createDialog(textIndex, position)
    local guidetextConf = GameData:getConfData("local/guidetext")
    local dialog = ccui.ImageView:create("uires/ui/guide/guide_dialog_jiao2.png")
    dialog:setCascadeOpacityEnabled(true)
    dialog:setAnchorPoint(cc.p(0.5, 0))

    local dialogBG = ccui.ImageView:create("uires/ui/guide/guide_bg_dialog4.png")
    dialogBG:setCascadeOpacityEnabled(true)
    dialogBG:setScale9Enabled(true)
    dialogBG:setAnchorPoint(cc.p(0, 0))
    dialog:addChild(dialogBG)

    local jiao = ccui.ImageView:create("uires/ui/guide/guide_dialog_jiao2.png")
    jiao:setAnchorPoint(cc.p(0, 0))
    dialog:addChild(jiao)

    local dialogTx = ccui.Text:create()
    dialogTx:setAnchorPoint(cc.p(0, 1))
    dialogTx:setFontName("font/gamefont.ttf")
    dialogTx:setFontSize(20)
    dialogTx:setTextColor(COLOR_TYPE.BLACK)
    if guidetextConf[textIndex] then
        dialogTx:setString(guidetextConf[textIndex].text)
    else
        dialogTx:setString(textIndex)
    end
    local size1 = dialogTx:getContentSize()
    local width = 0
    if size1.width > 180 then
        width = 180
        dialogTx:setTextAreaSize(cc.size(180, 0))
    else
        width = size1.width
    end
    local size2 = dialogTx:getContentSize()
    dialogBG:setContentSize(cc.size(width + 20, size2.height + 20))
    if position == 1 then
        dialogBG:setPosition(cc.p(-30, 9))
    elseif position == 2 then
        dialogBG:setPosition(cc.p(-30, 9))
    elseif position == 3 then
        dialogBG:setScaleX(-1)
        dialogBG:setPosition(cc.p(50, 9))
    elseif position == 4 then
        dialogBG:setScaleX(-1)
        dialogBG:setPosition(cc.p(width + 20 -30, 9))
    end
    dialogTx:setPosition(cc.p(10, size2.height+10))
    dialogBG:addChild(dialogTx)
    return dialog
end

function GuideStoryTwoUI:playSound(index)
    local guidetextConf = GameData:getConfData("local/guidetext")
    local soundRes = guidetextConf[index].soundRes
    if soundRes ~= "0" then
        self:playEffect("media/guide/" .. soundRes)
    end
end

function GuideStoryTwoUI:playEffect(res)
    local audioId = AudioMgr.playEffect(res, false)
    if audioId ~= cc.AUDIO_INVAILD_ID then
        self.audioIds[audioId] = true
        AudioMgr.setFinishCallback(audioId, function ()
            self.audioIds[audioId] = nil
        end)
    end
end

return GuideStoryTwoUI