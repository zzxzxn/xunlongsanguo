local GuideStoryThreeUI = class("GuideStoryThreeUI", BaseUI)

function GuideStoryThreeUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDESTORY
    self.audioIds = {}
end

function GuideStoryThreeUI:init()
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

function GuideStoryThreeUI:start()
    self:step1()
end

function GuideStoryThreeUI:step1()
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
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setContentSize(cc.size(668, 412))
    blackBorder:setPosition(cc.p(280, 180))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(664, 408))
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg15.png")
    bg:setPosition(cc.p(332, 204))
    layout:addChild(bg)

    local npc6 = GlobalApi:createLittleLossyAniByName("guide_npc_6")
    npc6:setScaleX(-1)
    npc6:setPosition(cc.p(300, 30))
    npc6:getAnimation():play("idle_2", -1, 1)
    layout:addChild(npc6)

    local npc2 = GlobalApi:createLittleLossyAniByName("guide_npc_2")
    npc2:setScale(0.8)
    npc2:setPosition(cc.p(560, 30))
    npc2:getAnimation():play("idle_4", -1, 1)
    layout:addChild(npc2)

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_131"].text)
    local currIndex = 0
    local titleIndex1 = 0
    local titleMaxIndex2 = 7
    local titleMaxIndex1 = #titleStrTable - titleMaxIndex2
    local titleIndex2 = titleMaxIndex1
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_131"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_131"].soundRes)
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

function GuideStoryThreeUI:step2()
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg17.png")
        local size = bg:getContentSize()
        bg:setPosition(cc.p(800, bgImgSize.height + size.height))
        self.bg_img:addChild(bg)

        local npc6 = GlobalApi:createLittleLossyAniByName("guide_npc_6")
        npc6:setScale(0.7)
        npc6:setPosition(cc.p(300, 90))
        npc6:getAnimation():play("idle", -1, 1)
        local shadow = npc6:getBone("guide_npc_6_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
        bg:addChild(npc6)

        local npc13 = GlobalApi:createLittleLossyAniByName("guide_npc_13")
        npc13:setScale(0.9)
        npc13:setPosition(cc.p(160, 90))
        npc13:getAnimation():play("idle", -1, 1)
        bg:addChild(npc13)

        bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(800, 340)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local asideText = ccui.Text:create()
            asideText:setAnchorPoint(cc.p(0, 1))
            asideText:setTextAreaSize(cc.size(340, 0))
            asideText:setFontName("font/gamefont.ttf")
            asideText:setFontSize(24)
            asideText:setTextColor(COLOR_TYPE.BLACK)
            asideText:setPosition(cc.p(660, 580))
            self.bg_img:addChild(asideText)

            local dialog1 = self:createDialog("GUIDE_TEXT_136", 4)
            dialog1:setPosition(cc.p(240, 240))
            bg:addChild(dialog1)
            dialog1:setScale(0)
            dialog1:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                self:playSound("GUIDE_TEXT_136")
            end),cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))

            local dialog2 = self:createDialog("GUIDE_TEXT_137", 1)
            dialog2:setPosition(cc.p(200, 240))
            bg:addChild(dialog2)
            dialog2:setScale(0)
            dialog2:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
                self:playSound("GUIDE_TEXT_137")
            end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))

            local guidetextConf = GameData:getConfData("local/guidetext")
            local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_135"].text)
            local currIndex = 0
            local titleIndex = 0
            local titleMaxIndex = #titleStrTable
            local titleDt = 0
            if guidetextConf["GUIDE_TEXT_135"].soundRes ~= "0" then
                self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_135"].soundRes)
            end
            self:scheduleUpdate(function (dt)
                titleDt = titleDt + dt
                if titleDt > 0.2 then
                    titleDt = 0
                    if titleIndex < titleMaxIndex then
                        titleIndex = titleIndex + 1
                        asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                    else
                        self:unscheduleUpdate()
                        self.bg_img:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                            self.bg_img:removeAllChildren()
                            self:step3()
                        end)))
                    end
                end
            end)
        end)))
    end
    local function _step1()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(463, 397))
        blackBorder:setPosition(cc.p(180, 200))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(459, 393))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg16.png")
        bg:setPosition(cc.p(229.5, 196.5))
        layout:addChild(bg)

        local npc12 = GlobalApi:createLittleLossyAniByName("guide_npc_12")
        npc12:setPosition(cc.p(120, 60))
        npc12:getAnimation():play("idle", -1, 1)
        layout:addChild(npc12)

        local nvde = GlobalApi:createSpineByName("guide_liubei", "spine/guide_liubei/guide_liubei", 1)
        nvde:setTimeScale(0.7)
        nvde:setPosition(cc.p(220, 70))
        nvde:setAnimation(0, "diaozou2", false)
        layout:addChild(nvde)
        blackBorder:runAction(cc.Sequence:create(cc.DelayTime:create(2.8), cc.CallFunc:create(function()
            local dialog1 = self:createDialog("GUIDE_TEXT_133", 4)
            dialog1:setPosition(cc.p(420, 260))
            blackBorder:addChild(dialog1)
            dialog1:setScale(0)
            self:playSound("GUIDE_TEXT_133")
            dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
        end), cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            local dialog2 = self:createDialog("GUIDE_TEXT_134", 1)
            dialog2:setPosition(cc.p(160, 160))
            blackBorder:addChild(dialog2)
            dialog2:setScale(0)
            self:playSound("GUIDE_TEXT_134")
            dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
        end)))

        local asideText1 = ccui.Text:create()
        asideText1:setAnchorPoint(cc.p(0, 0.5))
        asideText1:setFontName("font/gamefont.ttf")
        asideText1:setFontSize(24)
        asideText1:setTextColor(COLOR_TYPE.BLACK)
        asideText1:setPosition(cc.p(180, 175))
        self.bg_img:addChild(asideText1)

        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_132"].text)
        local currIndex = 0
        local titleIndex = 0
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        if guidetextConf["GUIDE_TEXT_132"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_132"].soundRes)
        end
        self:scheduleUpdate(function (dt)
            titleDt = titleDt + dt
            if titleDt > 0.2 then
                titleDt = 0
                if titleIndex < titleMaxIndex then
                    titleIndex = titleIndex + 1
                    asideText1:setString(table.concat(titleStrTable, "", 1, titleIndex))
                else
                    npc12:pause()
                    self:unscheduleUpdate()
                    _step2()
                end
            end
        end)
    end
    _step1()
end

function GuideStoryThreeUI:step3()
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setPosition(cc.p(600, 250))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg19.png")
        local size = bg:getContentSize()
        layout:setContentSize(size)
        blackBorder:setContentSize(cc.size(size.width + 4, size.height + 4))
        
        bg:setPosition(cc.p(size.width/2, size.height/2))
        layout:addChild(bg)

        local light = ccui.ImageView:create("uires/ui/strength/strength_light_bg.png")
        light:setScale(2)
        light:setPosition(cc.p(size.width/2, size.height/2 - 80))
        layout:addChild(light)
        light:runAction(cc.RepeatForever:create(cc.RotateBy:create(5, 360)))

        local bg_red = ccui.ImageView:create("uires/ui/guide/story/story_bg19_red.png")
        bg_red:setAnchorPoint(cc.p(0.5, 0))
        bg_red:setPosition(cc.p(size.width/2, 0))
        layout:addChild(bg_red)

        local npc11 = GlobalApi:createLittleLossyAniByName("guide_npc_11")
        npc11:getAnimation():play("idle", 0, 1)
        npc11:setPosition(cc.p(170, 30))
        layout:addChild(npc11)

        local asideText = ccui.Text:create()
        asideText:setAnchorPoint(cc.p(0, 1))
        asideText:setTextAreaSize(cc.size(360, 0))
        asideText:setFontName("font/gamefont.ttf")
        asideText:setFontSize(24)
        asideText:setTextColor(COLOR_TYPE.BLACK)
        asideText:setPosition(cc.p(604, 240))
        self.bg_img:addChild(asideText)

        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_139"].text)
        local currIndex = 0
        local titleIndex = 0
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        if guidetextConf["GUIDE_TEXT_139"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_139"].soundRes)
        end
        self:scheduleUpdate(function (dt)
            titleDt = titleDt + dt
            if titleDt > 0.3 then
                titleDt = 0
                if titleIndex < titleMaxIndex then
                    titleIndex = titleIndex + 1
                    asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                else
                    self:unscheduleUpdate()
                    self.bg_img:removeAllChildren()
                    self:step4()
                end
            end
        end)
    end
    local function _step1()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(333, 302))
        blackBorder:setPosition(cc.p(200, 200))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg18.png")
        local size = bg:getContentSize()
        layout:setContentSize(size)
        bg:setPosition(cc.p(size.width/2, size.height/2))
        layout:addChild(bg)

        local asideText = ccui.Text:create()
        asideText:setAnchorPoint(cc.p(0, 1))
        asideText:setFontName("font/gamefont.ttf")
        asideText:setFontSize(24)
        asideText:setTextColor(COLOR_TYPE.BLACK)
        asideText:setPosition(cc.p(200, 570))
        self.bg_img:addChild(asideText)
        
        self:playEffect("media/guide/guide_story_cry.mp3")

        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_138"].text)
        local currIndex = 0
        local titleIndex = 0
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        if guidetextConf["GUIDE_TEXT_138"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_138"].soundRes)
        end
        self:scheduleUpdate(function (dt)
            titleDt = titleDt + dt
            if titleDt > 0.2 then
                titleDt = 0
                if titleIndex < titleMaxIndex then
                    titleIndex = titleIndex + 1
                    asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                else
                    self:unscheduleUpdate()
                    _step2()
                end
            end
        end)
    end
    _step1()
end

function GuideStoryThreeUI:step4()
    local asideText1 = ccui.Text:create()
    asideText1:setAnchorPoint(cc.p(0.5, 1))
    asideText1:setFontName("font/gamefont.ttf")
    asideText1:setFontSize(24)
    asideText1:setTextAreaSize(cc.size(20, 0))
    asideText1:setTextColor(COLOR_TYPE.BLACK)
    asideText1:setPosition(cc.p(230, 580))
    self.bg_img:addChild(asideText1)

    local asideText2 = ccui.Text:create()
    asideText2:setAnchorPoint(cc.p(0.5, 1))
    asideText2:setFontName("font/gamefont.ttf")
    asideText2:setFontSize(24)
    asideText2:setTextAreaSize(cc.size(20, 0))
    asideText2:setTextColor(COLOR_TYPE.BLACK)
    asideText2:setPosition(cc.p(200, 580))
    self.bg_img:addChild(asideText2)
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setPosition(cc.p(280, 185))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg20.png")
    local size = bg:getContentSize()
    blackBorder:setContentSize(cc.size(size.width + 4 , size.height + 4))
    layout:setContentSize(size)
    bg:setPosition(cc.p(size.width/2, size.height/2))
    layout:addChild(bg)

    local guanyu = ccui.ImageView:create("uires/ui/guide/story/story_guanyu.png")
    guanyu:setPosition(cc.p(330, 210))
    layout:addChild(guanyu)

    local shanzi = ccui.ImageView:create("uires/ui/guide/story/story_shanzi.png")
    shanzi:setPosition(cc.p(245, 75))
    layout:addChild(shanzi)

    local zhugeliang = ccui.ImageView:create("uires/ui/guide/story/story_zhugeliang.png")
    zhugeliang:setPosition(cc.p(105, 100))
    layout:addChild(zhugeliang)

    local zhangfei = ccui.ImageView:create("uires/ui/guide/story/story_zhangfei.png")
    zhangfei:setPosition(cc.p(570, 230))
    layout:addChild(zhangfei)

    local liubei = ccui.ImageView:create("uires/ui/guide/story/story_liubei.png")
    liubei:setPosition(cc.p(430, 150))
    layout:addChild(liubei)

    local story13 = GlobalApi:createLittleLossyAniByName("story_13")
    story13:setScale(-1.2, 1.2)
    story13:setPosition(cc.p(460, 55))
    story13:getAnimation():play("idle_2", -1, 1)
    layout:addChild(story13)

    local dialog1 = self:createDialog("GUIDE_TEXT_141", 4)
    dialog1:setPosition(cc.p(350, 200))
    layout:addChild(dialog1)
    dialog1:setScale(0)
    
    dialog1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        self:playSound("GUIDE_TEXT_141")
    end), cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
        shanzi:runAction(cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, -500)), cc.RotateBy:create(0.2, 135)))
        local dialog2 = self:createDialog("GUIDE_TEXT_142", 1)
        dialog2:setPosition(cc.p(210, 180))
        layout:addChild(dialog2)
        dialog2:setScale(0)
        dialog2:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            self:playSound("GUIDE_TEXT_142")
        end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
    end)))

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_140"].text)
    local currIndex = 0
    local titleIndex1 = 0
    local titleMaxIndex2 = 4
    local titleMaxIndex1 = #titleStrTable - titleMaxIndex2
    local titleIndex2 = titleMaxIndex1
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_140"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_140"].soundRes)
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

function GuideStoryThreeUI:step5()
    local asideText1 = ccui.Text:create()
    asideText1:setAnchorPoint(cc.p(0.5, 1))
    asideText1:setFontName("font/gamefont.ttf")
    asideText1:setFontSize(24)
    asideText1:setTextAreaSize(cc.size(20, 0))
    asideText1:setTextColor(COLOR_TYPE.BLACK)
    asideText1:setPosition(cc.p(230, 580))
    self.bg_img:addChild(asideText1)

    local asideText2 = ccui.Text:create()
    asideText2:setAnchorPoint(cc.p(0.5, 1))
    asideText2:setFontName("font/gamefont.ttf")
    asideText2:setFontSize(24)
    asideText2:setTextAreaSize(cc.size(20, 0))
    asideText2:setTextColor(COLOR_TYPE.BLACK)
    asideText2:setPosition(cc.p(200, 580))
    self.bg_img:addChild(asideText2)
    
    local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
    blackBorder:setAnchorPoint(cc.p(0, 0))
    blackBorder:setScale9Enabled(true)
    blackBorder:setPosition(cc.p(280, 185))
    self.bg_img:addChild(blackBorder)

    local layout = ccui.Layout:create()
    layout:setPosition(cc.p(2, 2))
    layout:setClippingEnabled(true)
    blackBorder:addChild(layout)

    local bg = ccui.ImageView:create("uires/ui/guide/story/story_bg20.png")
    local size = bg:getContentSize()
    blackBorder:setContentSize(cc.size(size.width + 4 , size.height + 4))
    layout:setContentSize(size)
    bg:setPosition(cc.p(size.width/2, size.height/2))
    layout:addChild(bg)

    local zhuzi = ccui.ImageView:create("uires/ui/guide/story/story_zhuzi.png")
    zhuzi:setAnchorPoint(cc.p(0, 0))
    layout:addChild(zhuzi)

    local npc11 = GlobalApi:createLittleLossyAniByName("guide_npc_11")
    npc11:setScale(0.8)
    npc11:getAnimation():play("idle_2", 0, 1)
    npc11:setPosition(cc.p(300, 10))
    layout:addChild(npc11)

    local liubei = ccui.ImageView:create("uires/ui/guide/story/story_liubei.png")
    liubei:setScale(0.9)
    liubei:setPosition(cc.p(420, 100))
    layout:addChild(liubei)

    local story13 = GlobalApi:createLittleLossyAniByName("story_13")
    story13:setScale(-1.1, 1.1)
    story13:setPosition(cc.p(445, 15))
    story13:getAnimation():play("idle_3", -1, 1)
    layout:addChild(story13)

    local dialog1 = self:createDialog("GUIDE_TEXT_144", 4)
    dialog1:setPosition(cc.p(350, 160))
    layout:addChild(dialog1)
    dialog1:setScale(0)
    
    dialog1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        self:playSound("GUIDE_TEXT_144")
    end), cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
        local dialog2 = self:createDialog("GUIDE_TEXT_145", 1)
        dialog2:setPosition(cc.p(350, 160))
        layout:addChild(dialog2)
        dialog2:setScale(0)
        dialog2:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            self:playSound("GUIDE_TEXT_145")
        end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2)))
    end)))

    local guidetextConf = GameData:getConfData("local/guidetext")
    local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_143"].text)
    local currIndex = 0
    local titleIndex1 = 0
    local titleMaxIndex2 = 7
    local titleMaxIndex1 = #titleStrTable - titleMaxIndex2
    local titleIndex2 = titleMaxIndex1
    local titleDt = 0
    if guidetextConf["GUIDE_TEXT_143"].soundRes ~= "0" then
        self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_143"].soundRes)
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
                self.bg_img:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                    self:finish()
                end)))
            end
        end
    end)
end

function GuideStoryThreeUI:finish()
    self.skipBtn:setTouchEnabled(false)
    for id, v in pairs(self.audioIds) do
        AudioMgr.stopEffect(id)
    end
    self:hideUI()
    GuideMgr:finishCurrGuide()
end

function GuideStoryThreeUI:createDialog(textIndex, position)
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
                
function GuideStoryThreeUI:scheduleUpdate(func)
    self.bg_img:scheduleUpdateWithPriorityLua(function (dt)
        func(dt)
    end, 0)
end

function GuideStoryThreeUI:unscheduleUpdate()
    self.bg_img:unscheduleUpdate()
end

function GuideStoryThreeUI:playSound(index)
    local guidetextConf = GameData:getConfData("local/guidetext")
    local soundRes = guidetextConf[index].soundRes
    if soundRes ~= "0" then
        self:playEffect("media/guide/" .. soundRes)
    end
end

function GuideStoryThreeUI:playEffect(res)
    local audioId = AudioMgr.playEffect(res, false)
    if audioId ~= cc.AUDIO_INVAILD_ID then
        self.audioIds[audioId] = true
        AudioMgr.setFinishCallback(audioId, function ()
            self.audioIds[audioId] = nil
        end)
    end
end

return GuideStoryThreeUI