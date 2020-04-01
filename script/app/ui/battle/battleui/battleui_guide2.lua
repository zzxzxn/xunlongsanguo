local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local GuideBattle2UI = class("GuideBattle2UI", ClassBattleUI)

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local TIMESCALE = 1000000

function GuideBattle2UI:initCompleted()
    self.backBtn2:setVisible(false)
    self.fightforceNode:setVisible(false)
    self.counterBtn:setVisible(false)
    self.battleBtn:setVisible(false)

    self.playerSkillPoints = {20, 20}
    self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
    for i = 1, 9 do
        self.pedestalArr[i]:setTouchEnabled(false)
    end

    for i, v in ipairs(self.armyflags) do
        v:setVisible(false)
    end

    for k, v in ipairs(self.armyStars) do
        for k2, v2 in ipairs(v) do
            v2:setVisible(false)
        end
    end

    self.playerSkillStatusArr[1][1].border:setTouchEnabled(false)

    self.speedUp = 2.5
end

function GuideBattle2UI:otherSpecialHandle()
    -- local dialog = cc.Sprite:create("uires/ui/battle/bg_talk_3.png")
    -- local dialogSize = dialog:getContentSize()
    -- local label = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
    -- label:setMaxLineWidth(110)
    -- label:setPosition(cc.p(dialogSize.width/2 - 4, dialogSize.height/2 + 10))
    -- label:setTextColor(COLOR_TYPE.WHITE)
    -- dialog:addChild(label)
    -- self.bgImg:addChild(dialog)
    -- BattleHelper:setSpecialNodeZorder(dialog)

    -- local monsterConf = GameData:getConfData("formation")[50002]
    -- local guidetextConf = GameData:getConfData("local/guidetext")
    -- local talks = {
    --     {1, cc.pAdd(cc.p(0, 110), LEGION_POS[1][2]), "GUIDE_TEXT_30"},
    --     {2, cc.pAdd(cc.p(0, 110), LEGION_POS[2][1]), "GUIDE_TEXT_31"},
    --     {0, monsterConf.pos5},
    --     {1, cc.pAdd(cc.p(0, 110), LEGION_POS[1][1]), "GUIDE_TEXT_32"},
    --     {1, cc.pAdd(cc.p(0, 110), LEGION_POS[1][3]), "GUIDE_TEXT_33"}
    -- }
    -- local talkIndex = 1
    -- local totalIndex = #talks
    -- local function showTalk()
    --     if talkIndex <= totalIndex then
    --         if talks[talkIndex][1] == 0 then -- 显示boss介绍界面
    --             -- local winSize = cc.Director:getInstance():getWinSize()
    --             -- local ani = GlobalApi:createLittleLossyAniByName("guide_introduce")
    --             -- ani:getAnimation():playWithIndex(0, -1, -1)
    --             -- ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
    --             --     if movementType == 1 then
    --             --         ani:removeFromParent()
    --             self.root:runAction(cc.Sequence:create(
    --                 cc.DelayTime:create(0.2),
    --                 cc.CallFunc:create(function ()
    --                     if self.armyMap[1] then
    --                         self.armyMap[1]:setVisible(true)
    --                     end
    --                     if self.armyMap[3] then
    --                         self.armyMap[3]:setVisible(true)
    --                     end
    --                     showTalk()
    --                 end)
    --             ))
    --             --     end
    --             -- end)
    --             -- ani:setPosition(cc.p(winSize.width/2, winSize.height/2))
    --             -- self.root:addChild(ani)
    --         else
    --             local guidetextObj = guidetextConf[talks[talkIndex][3]]
    --             if talks[talkIndex][1] == 1 then
    --                 dialog:setTexture("uires/ui/battle/bg_talk_3.png")
    --                 label:enableOutline(cc.c4b(63, 132, 178, 255), 2)
    --             else
    --                 dialog:setTexture("uires/ui/battle/bg_talk_4.png")
    --                 label:enableOutline(cc.c4b(218, 79, 32, 255), 2)
    --             end
    --             dialog:setPosition(talks[talkIndex][2])
    --             label:setString(guidetextObj.text)
    --             dialog:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
    --                 if guidetextObj.soundRes ~= "0" then
    --                     BattleHelper:playSound("media/guide/" .. guidetextObj.soundRes, false)
    --                 end
    --             end), cc.ScaleTo:create(0.2, 1), cc.DelayTime:create(1), cc.CallFunc:create(function ()
    --                 dialog:setScale(0)
    --                 showTalk()
    --             end)))
    --         end
    --         talkIndex = talkIndex + 1
    --     else
    --         dialog:removeFromParent()
    --         local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    --         self.guideHand = hand
    --         hand:getAnimation():play("idle01", -1, 1)
    --         local btnSize = self.battleBtn:getContentSize()
    --         hand:setPosition(cc.p(btnSize.width/2, btnSize.height/2))
    --         self.battleBtn:addChild(hand)
    --         self.battleBtn:setVisible(true)
    --     end
    -- end
    -- dialog:setScale(0)
    -- showTalk()

    local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    self.guideHand = hand
    hand:getAnimation():play("idle01", -1, 1)
    local btnSize = self.battleBtn:getContentSize()
    hand:setPosition(cc.p(btnSize.width/2, btnSize.height/2))
    self.battleBtn:addChild(hand)
    self.battleBtn:setVisible(true)
end

function GuideBattle2UI:beforeFight()
    self.super.beforeFight(self)
    self.guideHand:removeFromParent()
    self.guideHand = nil
    for k, v in pairs(self.playerSkillStatusArr[1]) do
        ShaderMgr:setGrayForSprite(v.dragon)
        v.disable = true
    end
end

function GuideBattle2UI:battleStart()
    self.super.battleStart(self)
    self.pauseBtn:setVisible(false)
    self.autoBtn:setVisible(false)
    self.speedBtn:setVisible(false)
    local tipsTx = self.root:getChildByName("tips_tx")
    if tipsTx then
        tipsTx:removeFromParent()
    end
end

function GuideBattle2UI:updatePlayerSkill(guid)
    self.super.updatePlayerSkill(self, guid)
    if self.guideStart then
        return
    end
    if not self.playerSkillStatusArr[1][1].disable and self.playerSkillStatusArr[1][1].time == 0 then
        self.guideStart = true
        self:pauseFight()

        local winSize = cc.Director:getInstance():getWinSize()
        -- local guideMaskImg = ccui.ImageView:create("uires/ui/common/bg_gray2.png")
        -- guideMaskImg:setOpacity(150)
        -- guideMaskImg:setTouchEnabled(true)
        -- guideMaskImg:setScale9Enabled(true)
        -- guideMaskImg:setContentSize(winSize)
        -- guideMaskImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
        -- self.root:addChild(guideMaskImg)
        self.skillListNode:setLocalZOrder(1)
        -- self.guideMaskImg = guideMaskImg

        -- local guidetextConf = GameData:getConfData("local/guidetext")
        -- local dialogNode = cc.Node:create()
        -- local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_2.png")
        -- local npc = ccui.ImageView:create("uires/ui/yindao/yindao_5.png")
        -- npc:setName("npc")
        -- local label = cc.Label:createWithTTF(guidetextConf["GUIDE_TIPS_43"].text, "font/gamefont.ttf", 21)
        -- label:setAlignment(0)
        -- label:setVerticalAlignment(1)
        -- label:setMaxLineWidth(230)
        -- label:setName("text")
        -- label:setTextColor(COLOR_TYPE.WHITE)
        -- label:setPosition(cc.p(150,140))
        -- label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        -- local labelSize = label:getContentSize()
        -- dialog:setScale9Enabled(true)
        -- dialog:setContentSize(labelSize.width + 20, labelSize.height + 30)
        -- dialog:setPosition(label:getPosition())

        -- local guidetextConf = GameData:getConfData("local/guidetext")
        -- local dialogNode = cc.Node:create()
        -- local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_2.png")
        -- local npc = ccui.ImageView:create("uires/ui/yindao/yindao_5.png")
        -- npc:setName("npc")
        -- local label = cc.Label:createWithTTF(guidetextConf["GUIDE_TIPS_43"].text, "font/gamefont.ttf", 21)
        -- label:setAlignment(0)
        -- label:setVerticalAlignment(1)
        -- label:setMaxLineWidth(230)
        -- label:setName("text")
        -- label:setTextColor(COLOR_TYPE.WHITE)
        -- label:setPosition(cc.p(150,140))
        -- label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        -- local labelSize = label:getContentSize()
        -- dialog:setScale9Enabled(true)
        -- dialog:setContentSize(labelSize.width + 20, labelSize.height + 30)
        -- dialog:setPosition(label:getPosition())

        local guidetextConf = GameData:getConfData("local/guidetext")
        local dialogNode = cc.Node:create()
        self.dialogNode = dialogNode
        local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_8.png")
        local npc = GlobalApi:createLittleLossyAniByName("guide_npc_2")
        local npcSize = npc:getContentSize()
        local pos = cc.p(0,0)
        npc:getAnimation():play("idle", -1, -1)
        local label = cc.Label:createWithTTF(guidetextConf["GUIDE_TIPS_43"].text, "font/gamefont.ttf", 21)
        label:setAlignment(0)
        label:setVerticalAlignment(1)
        label:setMaxLineWidth(230)
        label:setTextColor(COLOR_TYPE.WHITE)
        label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        label:setName("text")
        local labelSize = label:getContentSize()
        dialog:setScale9Enabled(true)

        npc:setScaleX(-1)
        dialog:setScaleX(-1)
        dialog:setPosition(cc.p(pos.x + npcSize.width/2 - 20, pos.y + npcSize.width/2 - dialog:getContentSize().height/2 + 10))
        npc:setPosition(cc.pAdd(pos, cc.p(-40, 34)))
        label:setPosition(cc.p(dialog:getPositionX() + 40, dialog:getPositionY() + 10))


        dialogNode:addChild(dialog)
        dialogNode:addChild(label)
        dialogNode:addChild(npc)
        dialogNode:setPosition(cc.p(-420, -10))
        if guidetextConf["GUIDE_TIPS_43"].soundRes ~= "0" then
            AudioMgr.playEffect("media/guide/" .. guidetextConf["GUIDE_TIPS_43"].soundRes, false)
        end
        self.playerSkillStatusArr[1][1].border:addChild(dialogNode)
        dialogNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.5/TIMESCALE), cc.CallFunc:create(function ()
            label:setString(guidetextConf["GUIDE_TIPS_44"].text)
            if guidetextConf["GUIDE_TIPS_44"].soundRes ~= "0" then
                AudioMgr.playEffect("media/guide/" .. guidetextConf["GUIDE_TIPS_44"].soundRes, false)
            end
        end), cc.DelayTime:create(1.5/TIMESCALE), cc.CallFunc:create(function ()
            label:setString(guidetextConf["GUIDE_TIPS_38"].text)
            if guidetextConf["GUIDE_TIPS_38"].soundRes ~= "0" then
                AudioMgr.playEffect("media/guide/" .. guidetextConf["GUIDE_TIPS_38"].soundRes, false)
            end

            local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
            hand:getAnimation():play("idle02", -1, -1)
            hand:getAnimation():gotoAndPause(0)
            hand:setRotation(90)
            self.playerSkillStatusArr[1][1].border:addChild(hand)
            local size = self.playerSkillStatusArr[1][1].border:getContentSize()
            local handStartPos = cc.p(size.width/2, size.height/2)
            local handEndPos = cc.p(size.width/2, size.height/2 + 300)
            hand:setPosition(handStartPos)
            hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5/TIMESCALE, handEndPos), cc.DelayTime:create(0.5/TIMESCALE), cc.CallFunc:create(function ()
                hand:setPosition(handStartPos)
            end))))
            self.guideHand = hand
            self.playerSkillStatusArr[1][1].border:setTouchEnabled(true)

            local widget2 = ccui.Widget:create()
            widget2:setAnchorPoint(cc.p(0, 0))
            widget2:setContentSize(size)
            widget2:setTouchEnabled(true)
            local touchBegin = false
            local startPos
            local currDragon
            local dragonRangeImg = {
                [1] = ccui.ImageView:create("uires/ui/battle/playerskill_range_circle.png"),
                [2] = ccui.ImageView:create("uires/ui/battle/playerskill_range_rect.png")
            }
            self.battleBgPl:addChild(dragonRangeImg[1])
            self.battleBgPl:addChild(dragonRangeImg[2])
            dragonRangeImg[1]:setVisible(false)
            dragonRangeImg[2]:setVisible(false)
            local skillBorder = self.skillListNode:getChildByName("skill_border_1")
            local skillBorderPosY = skillBorder:getPositionY()
            widget2:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    touchBegin = true
                    startPos = sender:getTouchBeganPosition()
                    if not self.dragonArr[1].dragon then
                        if self.playerSkillArr[1][1].info.res == "0" then
                            self.dragonArr[1].dragon = BattleHelper:createAniByName(self.playerSkillArr[1][1].info.res2)
                        else
                            local changeEquipObj = GlobalApi:getChangeEquipState(self.playerSkillArr[1][1].level)
                            self.dragonArr[1].dragon = BattleHelper:createLittleLossyAniByName(self.playerSkillArr[1][1].info.res, nil, changeEquipObj)
                        end
                        self.dragonArr[1].dragon:setOpacity(100)
                        self.dragonArr[1].dragon:getAnimation():play("attack", -1, -1)
                        self.dragonArr[1].dragon:getAnimation():gotoAndPause(self.playerSkillArr[1][1].info.pauseFrame)
                        self.dragonArr[1].dragon:setVisible(false)
                        self.dragonArr[1].visible = false
                        self.dragonArr[1].rangeImg = dragonRangeImg[self.playerSkillArr[1][1].info.rangeType]
                        self.dragonArr[1].offsetX = self.playerSkillArr[1][1].info.offsetX
                        self.dragonArr[1].offsetY = self.playerSkillArr[1][1].info.offsetY
                        self.battleBgPl:addChild(self.dragonArr[1].dragon)
                    end
                    currDragon = self.dragonArr[1]
                    currDragon.rangeImg:setScaleX(self.playerSkillArr[1][1].info.rangeScaleX/100)
                    currDragon.rangeImg:setScaleY(self.playerSkillArr[1][1].info.rangeScaleY/100)
                    currDragon.effectByClick = true
                elseif eventType == ccui.TouchEventType.moved then
                    if touchBegin then
                        local currPos = sender:getTouchMovePosition()
                        local disPos = cc.pSub(currPos, startPos)
                        if currDragon.visible then
                            if currPos.y <= skillBorderPosY + 100 then
                                currDragon.dragon:setVisible(false)
                                currDragon.rangeImg:setVisible(false)
                                currDragon.visible = false
                            else
                                currDragon.dragon:setPosition(cc.p(currPos.x + currDragon.offsetX, currPos.y - 55))
                                currDragon.rangeImg:setPosition(cc.p(currPos))
                            end
                        else
                            if currPos.y >= skillBorderPosY + 100 then
                                currDragon.effectByClick = false
                                currDragon.dragon:setVisible(true)
                                currDragon.rangeImg:setVisible(true)
                                currDragon.visible = true
                                currDragon.dragon:setPosition(cc.p(currPos.x + currDragon.offsetX, currPos.y - 55))
                                currDragon.rangeImg:setPosition(cc.p(currPos))
                            end
                        end
                    end
                elseif eventType == ccui.TouchEventType.ended then
                    if touchBegin then
                        if currDragon.visible then
                            currDragon.dragon:setVisible(false)
                            currDragon.rangeImg:setVisible(false)
                            currDragon.visible = false
                        end
                        touchBegin = false
                    end
                elseif eventType == ccui.TouchEventType.canceled then
                    if touchBegin then
                        if currDragon.visible then
                            currDragon.dragon:setVisible(false)
                            currDragon.rangeImg:setVisible(false)
                            currDragon.visible = false
                            if self.playerSkillPoints[1] >= self.playerSkillStatusArr[1][1].needPoint then
                                if self.playerSkillStatusArr[1][1].time == 0 then
                                    self.removeGuideNodeFlag = true
                                    self:continueFight()
                                    local endPos = sender:getTouchEndPosition()
                                    self:usePlayerSkill(1, 1, endPos)
                                    widget2:removeFromParent()
                                end
                            end
                        end
                        touchBegin = false
                    end
                end
            end)
            self.playerSkillStatusArr[1][1].border:addChild(widget2)
        end)))
        self.guideDialogNode = dialogNode
    end
end

function GuideBattle2UI:resumeByPlayerSkill()
    self.super.resumeByPlayerSkill(self)
    if self.removeGuideNodeFlag and self.guideDialogNode then
        self.removeGuideNodeFlag = false
        local npc = self.guideDialogNode:getChildByName("npc")
        local label = self.guideDialogNode:getChildByName("text")
        local guidetextConf = GameData:getConfData("local/guidetext")
        label:setString(guidetextConf["GUIDE_TIPS_45"].text)
        if guidetextConf["GUIDE_TIPS_45"].soundRes ~= "0" then
            AudioMgr.playEffect("media/guide/" .. guidetextConf["GUIDE_TIPS_45"].soundRes, false)
        end
        self.guideDialogNode:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ()
            self.guideDialogNode:removeFromParent()
            self.guideDialogNode = nil
        end)))
    end
end

function GuideBattle2UI:usePlayerSkill(guid, index, pos)
    if self.guideHand then
        self.guideHand:removeFromParent()
        self.guideHand = nil
    end
    -- if self.guideMaskImg then
    --     self.guideMaskImg:removeFromParent()
    --     self.guideMaskImg = nil
    -- end
    self.super.usePlayerSkill(self, guid, index, pos)
end

function GuideBattle2UI:addKillAnimation()
end

function GuideBattle2UI:sendMessageAfterFight(isWin)
    local conf = GameData:getConfData("specialreward")["guide_award1"]
    local id = DisplayData:getDisplayObj(conf.reward[1]):getId()
    if BagData:getMaterialById(id) then
        BattleMgr:showBattleResult(isWin, {}, 3)
    else
        local obj = {
            request = "guide_award1"
        }
        MessageMgr:sendPost("mark_guide", "user", json.encode(obj),function (jsonObj)
            if jsonObj.code == 0 and jsonObj.data.awards then
                GlobalApi:parseAwardData(jsonObj.data.awards)
                local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                BattleMgr:showBattleResult(isWin, displayAwards, 3)
            else
                promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"))
            end
        end)
    end
end

return GuideBattle2UI