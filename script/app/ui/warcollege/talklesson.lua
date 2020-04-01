local TalkLesson = {}

function TalkLesson:startLesson(lessonObj, rootNode)
    local node = cc.Node:create()
    local npc = GlobalApi:createLittleLossyAniByName("guide_npc_" .. lessonObj.npc)
    local aniName = lessonObj.animation or "idle"
    npc:getAnimation():play(aniName, -1, -1)
    npc:setAnchorPoint(cc.p(0.5, 0))
    if lessonObj.npcscalex then
        npc:setScaleX(lessonObj.npcscalex)
    end
    local dialog = cc.Sprite:create("uires/ui/guide/guide_bg_dialog.png")
    local dialogSize = dialog:getContentSize()
    dialog:setVisible(false)

    local label = cc.Label:createWithTTF(GlobalApi:getLocalStr(lessonObj.text), "font/gamefont.ttf", 20)
    label:setMaxLineWidth(600)
    label:setAnchorPoint(cc.p(0.5, 1))
    label:setTextColor(COLOR_TYPE.WHITE)
    label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    -- 表情
    local emoticonSp = cc.Sprite:create("uires/ui/guide/guide_emoticon_".. lessonObj.emoticon .. ".png")
    -- 提示文字
    local label2 = cc.Label:createWithTTF(GlobalApi:getLocalStr("CLICK_ANY_POS_CONTINUE"), "font/gamefont.ttf", 22)
    label2:setTextColor(cc.c4b(255,255,255, 255))
    label2:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    node:addChild(npc)
    dialog:addChild(label)
    dialog:addChild(emoticonSp)
    dialog:addChild(label2)
    node:addChild(dialog)
    
    local winsize = cc.Director:getInstance():getWinSize()
    local act
    local startPos
    local scaleX = 1
    local function showTalk()
        self.clickFlag = false
        dialog:setVisible(true)
        dialog:setScale(0)
        dialog:runAction(cc.ScaleTo:create(0.1, scaleX, 1))
    end
    if lessonObj.direction == "down" then
        startPos = cc.p(winsize.width/2 - 200, -200)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 150)), cc.CallFunc:create(showTalk))
        scaleX = -1
        dialog:setScaleX(-1)
        label:setScaleX(-1)
        emoticonSp:setScaleX(-1)
        label2:setScaleX(-1)
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(winsize.width/2 - 70, 100))
        label:setPosition(cc.p(dialogSize.width - 300, dialogSize.height + 10))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 15, 70))
        label2:setPosition(cc.p(dialogSize.width/2 - 150, 90-winsize.height/2))
    elseif lessonObj.direction == "left" then
        startPos = cc.p(-100, winsize.height/2 - 100)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(100, 0)), cc.RotateTo:create(0.1, 30), cc.CallFunc:create(showTalk))
        scaleX = -1
        dialog:setScaleX(-1)
        label:setScaleX(-1)
        emoticonSp:setScaleX(-1)
        label2:setScaleX(-1)
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(180, winsize.height/2))
        label:setPosition(cc.p(dialogSize.width - 300, dialogSize.height + 10))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 15, 70))
        label2:setPosition(cc.p(dialogSize.width/2 - 150, 90-winsize.height/2))
    elseif lessonObj.direction == "right" then
        startPos = cc.p(winsize.width + 100, winsize.height/2 - 100)
        npc:setPosition(startPos)
        act = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(-100, 0)), cc.RotateTo:create(0.1, -45), cc.RotateTo:create(0.1, -30), cc.CallFunc:create(showTalk))
        scaleX = 1
        dialog:setAnchorPoint(cc.p(1, 0))
        dialog:setPosition(cc.p(winsize.width - 190, winsize.height/2))
        label:setPosition(cc.p(dialogSize.width + 100, dialogSize.height + 10))
        emoticonSp:setPosition(cc.p(dialogSize.width/2 - 18, 70))
        label2:setPosition(cc.p(winsize.width/2 + 150, 90-winsize.height/2))
    end
    rootNode:addChild(node)
    npc:runAction(act)
    self.dialog = dialog
    self.npc = npc
    self.clickFlag = true
    self.startPos = startPos
end

function TalkLesson:onClick()
    if not self.clickFlag then
        self.clickFlag = true
        self.dialog:setVisible(false)
        self.npc:runAction(cc.Sequence:create(cc.RotateTo:create(0.1, 0), cc.MoveTo:create(0.2, cc.p(self.startPos)), cc.CallFunc:create(function ()
            self:finish()
        end)))
    end
end

function TalkLesson:finish()
    self.dialog = nil
    self.npc = nil
    self.clickFlag = nil
    self.startPos = nil
	WarCollegeMgr:nextStep()
end

return TalkLesson