local GuideStoryOneUI = class("GuideStoryOneUI", BaseUI)

function GuideStoryOneUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDESTORY
    self.audioIds = {}
end

function GuideStoryOneUI:init()
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

function GuideStoryOneUI:start()
    self:step1()
end

function GuideStoryOneUI:step1()
    local musicId = UIManager:playBgm(1)
    local volume = AudioMgr.musicVal*0.4
    ccexp.AudioEngine:setVolume(musicId, volume)
    local function _step3()
        local bgImgSize = self.bg_img:getContentSize()
        local blackBorder3 = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder3:setAnchorPoint(cc.p(0, 0))
        blackBorder3:setScale9Enabled(true)
        blackBorder3:setContentSize(cc.size(179, 189))
        blackBorder3:setPosition(cc.p(800, bgImgSize.height + 190))
        self.bg_img:addChild(blackBorder3)

        local layout3 = ccui.Layout:create()
        layout3:setBackGroundImage("uires/ui/guide/story/story_bg3.png")
        layout3:setContentSize(cc.size(175, 185))
        layout3:setPosition(cc.p(2, 2))
        layout3:setClippingEnabled(true)
        blackBorder3:addChild(layout3)

        local liubei3 = GlobalApi:createLittleLossyAniByName("story_3")
        liubei3:setPosition(cc.p(62, -62))
        liubei3:getAnimation():playWithIndex(0, -1, 1)
        layout3:addChild(liubei3)

        blackBorder3:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(800, 180)), cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            local dialog4 = self:createDialog("GUIDE_TEXT_108", 4)
            dialog4:setPosition(cc.p(60, 100))
            blackBorder3:addChild(dialog4)
            dialog4:setScale(0)
            self:playSound("GUIDE_TEXT_108")
            dialog4:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.DelayTime:create(1), cc.CallFunc:create(function()
                self:unscheduleUpdate()
                self.bg_img:removeAllChildren()
                self:step2()
            end)))
        end)))
    end

    local function _step2()
        local blackBorder2 = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder2:setAnchorPoint(cc.p(0, 0))
        blackBorder2:setScale9Enabled(true)
        blackBorder2:setContentSize(cc.size(174, 195))
        blackBorder2:setPosition(cc.p(-200, 340))
        self.bg_img:addChild(blackBorder2)

        local layout2 = ccui.Layout:create()
        layout2:setBackGroundImage("uires/ui/guide/story/story_bg2.png")
        layout2:setContentSize(cc.size(170, 191))
        layout2:setPosition(cc.p(2, 2))
        layout2:setClippingEnabled(true)
        blackBorder2:addChild(layout2)

        local zhangfei2 = GlobalApi:createLittleLossyAniByName("guide_npc_5")
        zhangfei2:setScale(-0.4, 0.4)
        zhangfei2:setPosition(cc.p(50, 10))
        zhangfei2:getAnimation():play("idle", -1, 1)
        layout2:addChild(zhangfei2)

        blackBorder2:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(660, 340)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local dialog3 = self:createDialog("GUIDE_TEXT_107", 2)
            dialog3:setPosition(cc.p(100, 100))
            blackBorder2:addChild(dialog3)
            dialog3:setScale(0)
            self:playSound("GUIDE_TEXT_107")
            dialog3:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                zhangfei2:pause()
                _step3()
            end)))
        end)))
    end

    local function _step1()
        local textImg = ccui.ImageView:create("uires/ui/guide/story/story_text1.png")
        textImg:setPosition(cc.p(160, 400))
        self.bg_img:addChild(textImg)

        local asideText = ccui.Text:create()
        asideText:setAnchorPoint(cc.p(0, 1))
        asideText:setFontName("font/gamefont.ttf")
        asideText:setFontSize(28)
        asideText:setTextColor(COLOR_TYPE.BLACK)
        asideText:setPosition(cc.p(260, 600))
        self.bg_img:addChild(asideText)
        
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(424, 381))
        blackBorder:setPosition(cc.p(218, 163))
        self.bg_img:addChild(blackBorder)

        local layout1 = ccui.Layout:create()
        layout1:setContentSize(cc.size(420, 377))
        layout1:setPosition(cc.p(2, 2))
        layout1:setClippingEnabled(true)
        blackBorder:addChild(layout1)

        local bgNode = cc.Node:create()
        local bgMoveFlag = true
        local bgArr = {}
        local bg11 = ccui.ImageView:create("uires/ui/guide/story/story_bg1.png")
        local bg12 = ccui.ImageView:create("uires/ui/guide/story/story_bg1.png")
        local bg13 = ccui.ImageView:create("uires/ui/guide/story/story_bg1.png")
        bg11:setAnchorPoint(cc.p(0, 0))
        bg12:setAnchorPoint(cc.p(0, 0))
        bg13:setAnchorPoint(cc.p(0, 0))
        local bgSize = bg11:getContentSize()
        bg12:setPosition(cc.p(-bgSize.width, 0))
        bg13:setPosition(cc.p(-bgSize.width*2, 0))
        bgNode:addChild(bg11)
        bgNode:addChild(bg12)
        bgNode:addChild(bg13)
        layout1:addChild(bgNode)
        bgNode:runAction(cc.RepeatForever:create(cc.MoveBy:create(2, cc.p(100, 0))))
        bgArr[1] = bg11
        bgArr[2] = bg12
        bgArr[3] = bg13


        local liubei1 = GlobalApi:createLittleLossyAniByName("story_1")
        liubei1:setPosition(cc.p(50, 70))
        liubei1:getAnimation():playWithIndex(0, -1, 1)
        layout1:addChild(liubei1)

        local guanyu1 = GlobalApi:createSpineByName("guide_guanyu", "spine/guide_guanyu/guide_guanyu", 1)
        guanyu1:setScaleX(-1)
        guanyu1:setPosition(cc.p(240, 70))
        guanyu1:setAnimation(0, "run2", true)
        layout1:addChild(guanyu1)

        local zhangfei1 = GlobalApi:createSpineByName("guide_zhangfei", "spine/guide_zhangfei/guide_zhangfei", 1)
        zhangfei1:setScaleX(-1)
        zhangfei1:setPosition(cc.p(360, 70))
        zhangfei1:setAnimation(0, "run3", true)
        layout1:addChild(zhangfei1)

        local dialog1 = self:createDialog("GUIDE_TEXT_105", 4)
        dialog1:setPosition(cc.p(60, 260))
        blackBorder:addChild(dialog1)
        dialog1:setScale(0)
        dialog1:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            self:playSound("GUIDE_TEXT_105")
        end), cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            local dialog2 = self:createDialog("GUIDE_TEXT_106", 3)
            dialog2:setPosition(cc.p(350, 180))
            blackBorder:addChild(dialog2)
            dialog2:setScale(0)
            dialog2:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
                self:playSound("GUIDE_TEXT_106")
            end), cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                bgMoveFlag = false
                bgNode:stopAllActions()
                liubei1:pause()
                guanyu1:pause()
                zhangfei1:pause()
                _step2()
            end)))
        end)))

        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_104"].text)
        local currIndex = 0
        local titleIndex = 0
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        if guidetextConf["GUIDE_TEXT_104"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_104"].soundRes)
        end
        self:scheduleUpdate(function (dt)
            if bgMoveFlag then
                local x = bgNode:getPositionX()
                local index = math.floor(x/bgSize.width)
                if index > currIndex then
                    currIndex = index
                    if index%3 == 0 then
                        bgArr[1]:setPositionX(-bgSize.width*index)
                        bgArr[2]:setPositionX(-bgSize.width*(index+1))
                        bgArr[3]:setPositionX(-bgSize.width*(index+2))
                    elseif index%3 == 1 then
                        bgArr[2]:setPositionX(-bgSize.width*index)
                        bgArr[3]:setPositionX(-bgSize.width*(index+1))
                        bgArr[1]:setPositionX(-bgSize.width*(index+2))
                    else
                        bgArr[3]:setPositionX(-bgSize.width*index)
                        bgArr[1]:setPositionX(-bgSize.width*(index+1))
                        bgArr[2]:setPositionX(-bgSize.width*(index+2))
                    end
                end
            end

            if titleIndex < titleMaxIndex then
                titleDt = titleDt + dt
                if titleDt > 0.3 then
                    titleDt = 0
                    titleIndex = titleIndex + 1
                    asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                end
            end
        end)
    end
    _step1()
end

function GuideStoryOneUI:step2()
    local function _step3()
        local guidetextConf = GameData:getConfData("local/guidetext")
        local bgImgSize = self.bg_img:getContentSize()
        local image = ccui.ImageView:create("uires/ui/guide/story/story_bg6.png")
        local size = image:getContentSize()
        image:setAnchorPoint(cc.p(0, 0))
        image:setPosition(cc.p(700, bgImgSize.height + size.height))
        self.bg_img:addChild(image)

        local text1 = ccui.Text:create()
        text1:setAnchorPoint(cc.p(0, 1))
        text1:setFontName("font/gamefont.ttf")
        text1:setFontSize(24)
        text1:setTextAreaSize(cc.size(size.width - 20, 0))
        text1:enableOutline(COLOR_TYPE.BLACK, 2)
        text1:setString(guidetextConf["GUIDE_TEXT_121"].text)
        if guidetextConf["GUIDE_TEXT_121"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_121"].soundRes)
        end
        text1:setPosition(cc.p(10, size.height - 10))
        image:addChild(text1)

        local text2 = ccui.Text:create()
        text2:setFontName("font/gamefont.ttf")
        text2:setFontSize(38)
        text2:setTextAreaSize(cc.size(size.width, 0))
        text2:enableOutline(COLOR_TYPE.BLACK, 2)
        text2:setString(GlobalApi:getLocalStr("OFFICIAL_WEBSITE"))
        text2:setPosition(cc.p(238, 80))
        image:addChild(text2)

        image:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(700, 180)), cc.DelayTime:create(6), cc.CallFunc:create(function()
            self:unscheduleUpdate()
            self.bg_img:removeAllChildren()
            self:step3()
        end)))
    end

    local function _step2()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(355, 261))
        blackBorder:setPosition(cc.p(-200, 340))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg5.png")
        layout:setContentSize(cc.size(351, 257))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local story5 = GlobalApi:createLittleLossyAniByName("story_5")
        story5:setPosition(cc.p(180, 10))
        story5:getAnimation():playWithIndex(0, -1, 1)
        layout:addChild(story5)
        self:playEffect("media/guide/guide_story_beat.mp3")
        blackBorder:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(560, 340)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local dialog1 = self:createDialog("GUIDE_TEXT_110", 1)
            dialog1:setPosition(cc.p(340, 160))
            blackBorder:addChild(dialog1)
            dialog1:setScale(0)
            self:playSound("GUIDE_TEXT_110")
            dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                local dialog2 = self:createDialog("GUIDE_TEXT_111", 4)
                dialog2:setPosition(cc.p(120, 80))
                blackBorder:addChild(dialog2)
                dialog2:setScale(0)
                self:playSound("GUIDE_TEXT_111")
                dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(1), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                    story5:pause()
                    _step3()
                end)))
            end)))
        end)))
    end

    local function _step1()
        local winSize = cc.Director:getInstance():getWinSize()
        local guidetextConf = GameData:getConfData("local/guidetext")
        local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_109"].text)
        local titleIndex = 2
        local titleMaxIndex = #titleStrTable
        local titleDt = 0
        local asideText = ccui.Text:create()
        asideText:setAnchorPoint(cc.p(0, 1))
        asideText:setFontName("font/gamefont.ttf")
        asideText:setFontSize(36)
        asideText:setTextColor(COLOR_TYPE.BLACK)
        asideText:setPosition(cc.p(260, 590))
        self.bg_img:addChild(asideText)

        local whiteImg = ccui.ImageView:create("uires/ui/common/bg_white1.png")
        whiteImg:setCascadeOpacityEnabled(true)
        whiteImg:setScale9Enabled(true)
        whiteImg:setContentSize(winSize)
        whiteImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
        self.root:addChild(whiteImg)
        local kacha = ccui.ImageView:create("uires/ui/guide/story/story_kacha.png")
        kacha:setPosition(cc.p(520, 400))
        whiteImg:addChild(kacha)
        whiteImg:setVisible(false)
        whiteImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            whiteImg:setVisible(true)
            self:playEffect("media/guide/guide_story_photo.mp3")
            local bg1 = ccui.ImageView:create("uires/ui/guide/story/story_bg4.png")
            bg1:setPosition(cc.p(400, 360))
            self.bg_img:addChild(bg1)
            asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
        end), cc.DelayTime:create(0.2), cc.FadeOut:create(2), cc.CallFunc:create(function()
            self:playSound("GUIDE_TEXT_109")
            local bird = ccui.ImageView:create("uires/ui/guide/story/story_bird.png")
            bird:setPosition(cc.p(280 + asideText:getContentSize().width, 570))
            bird:setOpacity(0)
            self.bg_img:addChild(bird)
            bird:runAction(cc.Sequence:create(cc.FadeIn:create(0.2), cc.CallFunc:create(function()
                self:playEffect("media/guide/guide_story_crow.mp3")
            end), cc.MoveBy:create(2.5, cc.p(300, 0)), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                _step2()
            end)))
            self:scheduleUpdate(function (dt)
                if titleIndex < titleMaxIndex then
                    titleDt = titleDt + dt
                    if titleDt > 0.3 then
                        titleDt = 0
                        titleIndex = titleIndex + 1
                        asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                    end
                end
            end)
        end)))
    end
    _step1()
end

function GuideStoryOneUI:step3()
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local image = ccui.ImageView:create("uires/ui/guide/story/story_bg8.png")
        local size = image:getContentSize()
        image:setAnchorPoint(cc.p(0, 0))
        image:setPosition(cc.p(640, bgImgSize.height + size.height))
        self.bg_img:addChild(image)

        image:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(640, 180)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local asideText = ccui.Text:create()
            asideText:setAnchorPoint(cc.p(0, 1))
            asideText:setFontName("font/gamefont.ttf")
            asideText:setFontSize(26)
            asideText:enableOutline(COLOR_TYPE.BLACK, 1)
            asideText:setPosition(cc.p(90, 270))
            image:addChild(asideText)
            local guidetextConf = GameData:getConfData("local/guidetext")
            local titleStrTable = GlobalApi:splitStringToTable(guidetextConf["GUIDE_TEXT_122"].text)
            local currIndex = 0
            local titleIndex = 0
            local titleMaxIndex = #titleStrTable
            local titleDt = 0
            if guidetextConf["GUIDE_TEXT_122"].soundRes ~= "0" then
                self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_122"].soundRes)
            end
            self:playEffect("media/guide/guide_story_horse.mp3")
            self:scheduleUpdate(function (dt)
                if titleIndex < titleMaxIndex then
                    titleDt = titleDt + dt
                    if titleDt > 0.3 then
                        titleDt = 0
                        titleIndex = titleIndex + 1
                        asideText:setString(table.concat(titleStrTable, "", 1, titleIndex))
                    end
                end
            end)
            local dialog = self:createDialog("GUIDE_TEXT_114", 1)
            dialog:setPosition(cc.p(30, 80))
            image:addChild(dialog)
            dialog:setScale(0)
            dialog:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                self:playSound("GUIDE_TEXT_114")
            end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                self:unscheduleUpdate()
                self.bg_img:removeAllChildren()
                self:step4()
            end)))
        end)))
    end
    local function _step1()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(385, 282))
        blackBorder:setPosition(cc.p(200, 320))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg7.png")
        layout:setContentSize(cc.size(381, 278))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local story6 = GlobalApi:createLittleLossyAniByName("story_6")
        story6:setPosition(cc.p(184, 0))
        story6:getAnimation():playWithIndex(0, -1, 1)
        layout:addChild(story6)

        blackBorder:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local dialog1 = self:createDialog("GUIDE_TEXT_112", 4)
            self:playSound("GUIDE_TEXT_112")
            dialog1:setPosition(cc.p(40, 120))
            blackBorder:addChild(dialog1)
            dialog1:setScale(0)
            dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                local dialog2 = self:createDialog("GUIDE_TEXT_113", 1)
                self:playSound("GUIDE_TEXT_113")
                dialog2:setPosition(cc.p(350, 120))
                blackBorder:addChild(dialog2)
                dialog2:setScale(0)
                dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                    local dialog3 = self:createDialog(" ......  ", 1)
                    dialog3:setPosition(cc.p(210, 120))
                    blackBorder:addChild(dialog3)
                    dialog3:setScale(0)
                    dialog3:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                        story6:pause()
                        _step2()
                    end)))
                end)))
            end)))
        end)))
    end
    _step1()
end

function GuideStoryOneUI:step4()
    local musicId = UIManager:playBgm(3)
    local volume = AudioMgr.musicVal*0.4
    ccexp.AudioEngine:setVolume(musicId, volume)
    local function _step2()
        local bgImgSize = self.bg_img:getContentSize()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(576, 375))
        blackBorder:setPosition(cc.p(440, bgImgSize.height + 375))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg10.png")
        layout:setContentSize(cc.size(572, 371))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local zhuizhu = GlobalApi:createSpineByName("guide_zhuizhu", "spine/guide_zhuizhu/guide_zhuizhu", 1)
        zhuizhu:setScaleX(-1)
        zhuizhu:setPosition(cc.p(320, 50))
        zhuizhu:setAnimation(0, "run", true)
        layout:addChild(zhuizhu)

        blackBorder:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(440, 160)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local dialog1 = self:createDialog("GUIDE_TEXT_117", 4)
            dialog1:setPosition(cc.p(170, 160))
            blackBorder:addChild(dialog1)
            dialog1:setScale(0)
            self:playSound("GUIDE_TEXT_117")
            dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                local dialog2 = self:createDialog("GUIDE_TEXT_118", 4)
                dialog2:setPosition(cc.p(70, 160))
                blackBorder:addChild(dialog2)
                dialog2:setScale(0)
                self:playSound("GUIDE_TEXT_118")
                dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                    self.bg_img:removeAllChildren()
                    self:step5()
                end)))
            end)))
        end)))
    end
    local function _step1()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(538, 365))
        blackBorder:setPosition(cc.p(130, 230))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg9.png")
        layout:setContentSize(cc.size(534, 361))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local story9 = GlobalApi:createLittleLossyAniByName("story_9")
        story9:setPosition(cc.p(267, 0))
        story9:getAnimation():playWithIndex(0, -1, 1)
        layout:addChild(story9)

        local xiaolong = GlobalApi:createAniByName("boss_xiaolong")
        xiaolong:setPosition(cc.p(100, 50))
        xiaolong:getAnimation():play("idle", -1, 1)
        layout:addChild(xiaolong)

        blackBorder:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local dialog1 = self:createDialog("GUIDE_TEXT_115", 1)
            dialog1:setPosition(cc.p(110, 270))
            blackBorder:addChild(dialog1)
            dialog1:setScale(0)
            self:playSound("GUIDE_TEXT_115")
            dialog1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                local dialog2 = self:createDialog("GUIDE_TEXT_116", 4)
                dialog2:setPosition(cc.p(350, 160))
                blackBorder:addChild(dialog2)
                dialog2:setScale(0)
                self:playSound("GUIDE_TEXT_116")
                dialog2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, -1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                    story9:pause()
                    xiaolong:pause()
                    _step2()
                end)))
            end)))
        end)))
    end
    _step1()
end

function GuideStoryOneUI:step5()
    local function _step3()
        local bgImgSize = self.bg_img:getContentSize()
        local blackBorder3 = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder3:setAnchorPoint(cc.p(0, 0))
        blackBorder3:setScale9Enabled(true)
        blackBorder3:setContentSize(cc.size(312, 244))
        blackBorder3:setPosition(cc.p(640, bgImgSize.height + 190))
        self.bg_img:addChild(blackBorder3)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg13.png")
        layout:setContentSize(cc.size(308, 240))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder3:addChild(layout)

        local story13 = GlobalApi:createLittleLossyAniByName("story_13")
        story13:setPosition(cc.p(128, 0))
        story13:getAnimation():play("idle", -1, 1)
        layout:addChild(story13)
        
        blackBorder3:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(640, 200)), cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            local dialog = self:createDialog("GUIDE_TEXT_120", 1)
            dialog:setPosition(cc.p(200, 120))
            blackBorder3:addChild(dialog)
            dialog:setScale(0)
            self:playSound("GUIDE_TEXT_120")
            dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1, 1), cc.DelayTime:create(3), cc.FadeOut:create(0.2), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                local finishImg = ccui.ImageView:create("uires/ui/guide/guide_finish.png")
                finishImg:setPosition(cc.p(960, 220))
                finishImg:setScale(5)
                finishImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1), cc.DelayTime:create(1), cc.CallFunc:create(function()
                    self:finish()    
                end)))
                self.bg_img:addChild(finishImg)
            end)))
        end)))
    end
    local function _step2()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(264, 162))
        blackBorder:setPosition(cc.p(-200, 425))
        self.bg_img:addChild(blackBorder)

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg12.png")
        layout:setContentSize(cc.size(260, 158))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        blackBorder:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(470, 425)), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            local story12 = GlobalApi:createLittleLossyAniByName("story_12")
            story12:setPosition(cc.p(130, 0))
            layout:addChild(story12)
            self:playEffect("media/guide/guide_story_skill.mp3")
            story12:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
                if movementType == 1 then
                    blackBorder:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function()
                        _step3()
                    end)))
                end
            end)
            story12:getAnimation():playWithIndex(0, -1, 0)
        end)))
    end
    local function _step1()
        local blackBorder = ccui.ImageView:create("uires/ui/common/border_black.png")
        blackBorder:setAnchorPoint(cc.p(0, 0))
        blackBorder:setScale9Enabled(true)
        blackBorder:setContentSize(cc.size(286, 399))
        blackBorder:setPosition(cc.p(150, 190))
        self.bg_img:addChild(blackBorder)
        self:playEffect("media/guide/guide_story_appear.mp3")

        local layout = ccui.Layout:create()
        layout:setBackGroundImage("uires/ui/guide/story/story_bg11.png")
        layout:setContentSize(cc.size(282, 395))
        layout:setPosition(cc.p(2, 2))
        layout:setClippingEnabled(true)
        blackBorder:addChild(layout)

        local dialog = cc.Sprite:create("uires/ui/battle/bg_talk_6.png")
        dialog:setCascadeOpacityEnabled(true)
        local dialogSize = dialog:getContentSize()
        local guidetextConf = GameData:getConfData("local/guidetext")
        local dialogTx = ccui.Text:create()
        dialogTx:setFontName("font/gamefont.ttf")
        dialogTx:setPosition(cc.p(dialogSize.width/2, dialogSize.height/2 + 4))
        dialogTx:setFontSize(22)
        dialogTx:setTextColor(COLOR_TYPE.WHITE)
        dialogTx:enableOutline(cc.c4b(218, 79, 32, 255), 2)
        dialogTx:setString(guidetextConf["GUIDE_TEXT_119"].text)
        if guidetextConf["GUIDE_TEXT_119"].soundRes ~= "0" then
            self:playEffect("media/guide/" .. guidetextConf["GUIDE_TEXT_119"].soundRes)
        end
        dialog:addChild(dialogTx)
        dialog:setPosition(cc.p(160, 320))
        blackBorder:addChild(dialog)
        dialog:setScale(0)

        blackBorder:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            dialog:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(2), cc.FadeOut:create(0.5), cc.CallFunc:create(function ()
                _step2()
            end)))
        end)))
    end
    _step1()
end

function GuideStoryOneUI:finish()
    self.skipBtn:setTouchEnabled(false)
    for id, v in pairs(self.audioIds) do
        AudioMgr.stopEffect(id)
    end
    self:hideUI()
    GuideMgr:finishCurrGuide()
end

function GuideStoryOneUI:createDialog(textIndex, position)
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
                
function GuideStoryOneUI:scheduleUpdate(func)
    self.bg_img:scheduleUpdateWithPriorityLua(function (dt)
        func(dt)
    end, 0)
end

function GuideStoryOneUI:unscheduleUpdate()
    self.bg_img:unscheduleUpdate()
end

function GuideStoryOneUI:playSound(index)
    local guidetextConf = GameData:getConfData("local/guidetext")
    local soundRes = guidetextConf[index].soundRes
    if soundRes ~= "0" then
        self:playEffect("media/guide/" .. soundRes)
    end
end

function GuideStoryOneUI:playEffect(res)
    local audioId = AudioMgr.playEffect(res, false)
    if audioId ~= cc.AUDIO_INVAILD_ID then
        self.audioIds[audioId] = true
        AudioMgr.setFinishCallback(audioId, function ()
            self.audioIds[audioId] = nil
        end)
    end
end

return GuideStoryOneUI