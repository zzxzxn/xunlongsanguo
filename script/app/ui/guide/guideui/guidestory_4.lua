local GuideStoryFourUI = class("GuideStoryFourUI", BaseUI)

function GuideStoryFourUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDESTORY
    self.audioIds = {}
end

function GuideStoryFourUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    self.bg_img = self.root:getChildByName("bg_img")
    self.bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))

    self.skipBtn = ccui.Button:create("uires/ui/common/btn_skip2.png")
    self.skipBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:unscheduleUpdate()
            self:finish()
        end
    end)
    self.skipBtn:setPosition(cc.p(winSize.width - 80, winSize.height - 60))
    self.root:addChild(self.skipBtn)
end

function GuideStoryFourUI:start()
    self:step1()
end

function GuideStoryFourUI:step1()
    local musicId = UIManager:playBgm(1)
    local volume = AudioMgr.musicVal*0.4
    ccexp.AudioEngine:setVolume(musicId, volume)

    local asideText1 = ccui.Text:create()
    asideText1:setAnchorPoint(cc.p(0.5, 1))
    asideText1:setFontName("font/gamefont.ttf")
    asideText1:setFontSize(24)
    asideText1:setTextAreaSize(cc.size(20, 0))
    asideText1:setTextColor(COLOR_TYPE.BLACK)
    asideText1:setPosition(cc.p(230, 600))
    self.bg_img:addChild(asideText1)

    local asideText2 = ccui.Text:create()
    asideText2:setAnchorPoint(cc.p(0.5, 1))
    asideText2:setFontName("font/gamefont.ttf")
    asideText2:setFontSize(24)
    asideText2:setTextAreaSize(cc.size(20, 0))
    asideText2:setTextColor(COLOR_TYPE.BLACK)
    asideText2:setPosition(cc.p(200, 600))
    self.bg_img:addChild(asideText2)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg21.png")
    local size = bg:getContentSize()
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
    blackBorder:setPosition(cc.p(320, 165))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setContentSize(size)
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    bg:setPosition(cc.p(size.width/2, size.height/2))
    layout:addChild(bg)

    local story_14 = GlobalApi:createLittleLossyAniByName("story_14")
    story_14:setPosition(cc.p(290, -20))
    story_14:getAnimation():playWithIndex(0, -1, 0)
    layout:addChild(story_14)
    story_14:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ()
        local dialog = self:createDialog("GUIDE_TEXT_152", 1)
        dialog:setPosition(cc.p(420, 300))
        blackBorder:addChild(dialog)
        dialog:setScale(0)
        self:playSound("GUIDE_TEXT_152")
        dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
    end)))

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_151"].text)
    local currIndex = 0
    local titleIndex1 = 0
    local titleMaxIndex2 = 7
    local titleMaxIndex1 = #titleStrTable - titleMaxIndex2
    local titleIndex2 = titleMaxIndex1
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_151"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_151"].soundRes)
    end
    self:scheduleUpdate(function (dt)
        titleDt = titleDt + dt
        if titleDt > 0.3 then
            titleDt = 0
            if titleIndex1 < titleMaxIndex1 then
                titleIndex1 = titleIndex1 + 1
                asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex1))
            elseif titleIndex2 < #titleStrTable then
                titleIndex2 = titleIndex2 + 1
                asideText2:setString(table.concat(titleStrTable, "", titleMaxIndex1 + 1, titleIndex2))
            else
                self:unscheduleUpdate()
                self.bg_img:removeAllChildren()
                self:step2()
            end
        end
    end)
end

function GuideStoryFourUI:step2()
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(504, 404))
        blackBorder:setPosition(cc.p(480, bgImgSize.height + 180))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(500, 400))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg21.png")
        bg:setScale(2)
        bg:setPosition(cc.p(250, 0))
        layout:addChild(bg)

        local npc_14 = GlobalApi:createLittleLossyAniByName("guide_npc_14")
        npc_14:setScale(1.2)
        npc_14:setPosition(cc.p(300, -40))
        npc_14:getAnimation():play("idle_2", -1, 1)
        layout:addChild(npc_14)

        blackBorder:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(480, 180)), cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            local asideText1 = ccui.Text:create()
            asideText1:setAnchorPoint(cc.p(0, 0.5))
            asideText1:setFontName("font/gamefont.ttf")
            asideText1:setFontSize(24)
            asideText1:setTextColor(COLOR_TYPE.BLACK)
            asideText1:setPosition(cc.p(520, 560))
            self.bg_img:addChild(asideText1)

            local guidetextConf = GameData:getConfData("local/guidetext")
            local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_154"].text)
            local currIndex = 0
            local titleIndex = 0
            local titleMaxIndex = #titleStrTable
            local titleDt = 0
            if guidetextConf["GUIDE_TEXT_154"].soundRes ~= "0" then
                self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_154"].soundRes)
            end
            self:scheduleUpdate(function (dt)
                titleDt = titleDt + dt
                if titleDt > 0.2 then
                    titleDt = 0
                    if titleIndex < titleMaxIndex then
                        titleIndex = titleIndex + 1
                        asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex))
                    else
                        self:unscheduleUpdate()
                        local dialog = self:createDialog("GUIDE_TEXT_155", 3)
                        dialog:setPosition(cc.p(80, 120))
                        blackBorder:addChild(dialog)
                        dialog:setScale(0)
                        self:playSound("GUIDE_TEXT_155")
                        dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                            self.bg_img:removeAllChildren()
                            self:step3()
                        end)))
                    end
                end
            end)
        end)))
    end
    local function _step1()
        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg22.png")
        local size = bg:getContentSize()
        
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
        blackBorder:setPosition(cc.p(140, 240))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        bg:setPosition(cc.p(size.width/2, size.height/2))
        layout:addChild(bg)

        local dialog = self:createDialog("GUIDE_TEXT_153", 1)
        dialog:setPosition(cc.p(220, 140))
        blackBorder:addChild(dialog)
        dialog:setScale(0)
        self:playSound("GUIDE_TEXT_153")
        dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            _step2()
        end)))
    end
    _step1()
end

function GuideStoryFourUI:step3()
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg24.png")
        local size = bg:getContentSize()
        
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
        blackBorder:setPosition(cc.p(460, bgImgSize.height + 160))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        bg:setPosition(cc.p(size.width/2, size.height/2))
        layout:addChild(bg)

        local story_13 = GlobalApi:createLittleLossyAniByName("story_13")
        story_13:setScale(-1.2, 1.2)
        story_13:setPosition(cc.p(346, 32))
        story_13:getAnimation():play("idle_4", -1, 1)
        layout:addChild(story_13)

        local asideText1 = ccui.Text:create()
        asideText1:setAnchorPoint(cc.p(0, 0.5))
        asideText1:setFontName("font/gamefont.ttf")
        asideText1:setFontSize(24)
        asideText1:setTextColor(COLOR_TYPE.BLACK)
        asideText1:setPosition(cc.p(560, 560))
        self.bg_img:addChild(asideText1)

        blackBorder:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(460, 180)), cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            local guidetextConf = GameData:getConfData("local/guidetext")
            local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_157"].text)
            local currIndex = 0
            local titleIndex = 0
            local titleMaxIndex = #titleStrTable
            local titleDt = 0
            if guidetextConf["GUIDE_TEXT_157"].soundRes ~= "0" then
                self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_157"].soundRes)
            end
            self:scheduleUpdate(function (dt)
                titleDt = titleDt + dt
                if titleDt > 0.3 then
                    titleDt = 0
                    if titleIndex < titleMaxIndex then
                        titleIndex = titleIndex + 1
                        asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex))
                    else
                        self:unscheduleUpdate()
                        self.bg_img:removeAllChildren()
                        self:step4()
                    end
                end
            end)
        end)))
    end
    local function _step1()
        local asideText1 = ccui.Text:create()
        asideText1:setAnchorPoint(cc.p(0, 0.5))
        asideText1:setFontName("font/gamefont.ttf")
        asideText1:setFontSize(24)
        asideText1:setTextColor(COLOR_TYPE.BLACK)
        asideText1:setPosition(cc.p(160, 580))
        self.bg_img:addChild(asideText1)

        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg23.png")
        local size = bg:getContentSize()
        
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
        blackBorder:setPosition(cc.p(140, 160))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setContentSize(size)
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        bg:setPosition(cc.p(size.width/2, size.height/2))
        layout:addChild(bg)

        local npc_14 = GlobalApi:createLittleLossyAniByName("guide_npc_14")
        npc_14:setScale(-0.9, 0.9)
        npc_14:setPosition(cc.p(200, 10))
        npc_14:getAnimation():play("idle_1", -1, 1)
        layout:addChild(npc_14)

        local story_star = GlobalApi:createLittleLossyAniByName("story_star")
        story_star:setPosition(cc.p(200, 120))
        story_star:getAnimation():playWithIndex(0, -1, 1)
        layout:addChild(story_star)

        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_156"].text)
        local currIndex = 0
        local titleIndex = 0
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        if guidetextConf["GUIDE_TEXT_156"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_156"].soundRes)
        end
        self:scheduleUpdate(function (dt)
            titleDt = titleDt + dt
            if titleDt > 0.3 then
                titleDt = 0
                if titleIndex < titleMaxIndex then
                    titleIndex = titleIndex + 1
                    asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex))
                else
                    self:unscheduleUpdate()
                    npc_14:pause()
                    story_star:pause()
                    _step2()
                end
            end
        end)
    end
    _step1()
end

function GuideStoryFourUI:step4()
    local asideText1 = ccui.Text:create()
    asideText1:setAnchorPoint(cc.p(0.5, 1))
    asideText1:setFontName("font/gamefont.ttf")
    asideText1:setFontSize(24)
    asideText1:setTextAreaSize(cc.size(20, 0))
    asideText1:setTextColor(COLOR_TYPE.BLACK)
    asideText1:setPosition(cc.p(900, 560))
    self.bg_img:addChild(asideText1)

    local asideText2 = ccui.Text:create()
    asideText2:setAnchorPoint(cc.p(0.5, 1))
    asideText2:setFontName("font/gamefont.ttf")
    asideText2:setFontSize(24)
    asideText2:setTextAreaSize(cc.size(20, 0))
    asideText2:setTextColor(COLOR_TYPE.BLACK)
    asideText2:setPosition(cc.p(870, 560))
    self.bg_img:addChild(asideText2)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg25.png")
    local size = bg:getContentSize()
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
    blackBorder:setPosition(cc.p(200, 180))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setContentSize(size)
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    bg:setPosition(cc.p(size.width/2, size.height/2))
    layout:addChild(bg)

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_158"].text)
    local currIndex = 0
    local titleIndex1 = 0
    local titleMaxIndex2 = 6
    local titleMaxIndex1 = #titleStrTable - titleMaxIndex2
    local titleIndex2 = titleMaxIndex1
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_158"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_158"].soundRes)
    end
    self:scheduleUpdate(function (dt)
        titleDt = titleDt + dt
        if titleDt > 0.3 then
            titleDt = 0
            if titleIndex1 < titleMaxIndex1 then
                titleIndex1 = titleIndex1 + 1
                asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex1))
            elseif titleIndex2 < #titleStrTable then
                titleIndex2 = titleIndex2 + 1
                asideText2:setString(table.concat(titleStrTable, "", titleMaxIndex1 + 1, titleIndex2))
            else
                self:unscheduleUpdate()
                self.bg_img:removeAllChildren()
                self:step5()
            end
        end
    end)
end

function GuideStoryFourUI:step5()
    local asideText1 = ccui.Text:create()
    asideText1:setAnchorPoint(cc.p(0.5, 1))
    asideText1:setFontName("font/gamefont.ttf")
    asideText1:setFontSize(24)
    asideText1:setTextAreaSize(cc.size(20, 0))
    asideText1:setTextColor(COLOR_TYPE.BLACK)
    asideText1:setPosition(cc.p(220, 560))
    self.bg_img:addChild(asideText1)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg26.png")
    local size = bg:getContentSize()
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
    blackBorder:setPosition(cc.p(280, 180))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setContentSize(size)
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    bg:setPosition(cc.p(size.width/2, size.height/2))
    layout:addChild(bg)

    local npc_14 = GlobalApi:createLittleLossyAniByName("guide_npc_14")
    npc_14:setPosition(cc.p(50, -120))
    npc_14:getAnimation():play("idle_3", -1, 1)
    layout:addChild(npc_14)

    local story_13 = GlobalApi:createLittleLossyAniByName("story_13")
    story_13:setScale(-1.1, 1.1)
    story_13:setPosition(cc.p(450, 136))
    story_13:getAnimation():play("idle_4", -1, 1)
    layout:addChild(story_13)

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_159"].text)
    local currIndex = 0
    local titleIndex = 0
    local titleMaxIndex = #titleStrTable
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_159"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_159"].soundRes)
    end
    self:scheduleUpdate(function (dt)
        titleDt = titleDt + dt
        if titleDt > 0.3 then
            titleDt = 0
            if titleIndex < titleMaxIndex then
                titleIndex = titleIndex + 1
                asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex))
            else
                self:unscheduleUpdate()
                local dialog = self:createDialog("GUIDE_TEXT_160", 2)
                dialog:setPosition(cc.p(120, 180))
                blackBorder:addChild(dialog)
                dialog:setScale(0)
                self:playSound("GUIDE_TEXT_160")
                dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                    local dialog2 = self:createDialog("GUIDE_TEXT_161", 4)
                    dialog2:setPosition(cc.p(340, 280))
                    blackBorder:addChild(dialog2)
                    dialog2:setScale(0)
                    self:playSound("GUIDE_TEXT_161")
                    dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.DelayTime:create(1), cc.CallFunc:create(function()
                        self:finish()
                    end)))
                end)))
            end
        end
    end)
end

function GuideStoryFourUI:finish()
    self.skipBtn:setTouchEnabled(false)
    for id, v in pairs(self.audioIds) do
        AudioMgr.stopEffect(id)
    end
    self:hideUI()
    GuideMgr:finishCurrGuide()
end

function GuideStoryFourUI:createDialog(textIndex, position)
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
                
function GuideStoryFourUI:scheduleUpdate(func)
    self.bg_img:scheduleUpdateWithPriorityLua(function (dt)
        func(dt)
    end, 0)
end

function GuideStoryFourUI:unscheduleUpdate()
    self.bg_img:unscheduleUpdate()
end

function GuideStoryFourUI:playSound(index)
    local guidetextConf = GameData:getConfData("local/guidetext")
    local soundRes = guidetextConf[index].soundRes
    if soundRes ~= "0" then
        self:playEffect("media/guide/" .. soundRes)
    end
end

function GuideStoryFourUI:playEffect(res)
    local audioId = AudioMgr.playEffect(res, false)
    if audioId ~= cc.AUDIO_INVAILD_ID then
        self.audioIds[audioId] = true
        AudioMgr.setFinishCallback(audioId, function ()
            self.audioIds[audioId] = nil
        end)
    end
end

return GuideStoryFourUI