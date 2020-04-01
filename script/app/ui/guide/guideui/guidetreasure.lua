local ClassTreasureUI = require("script/app/ui/mainscene/treasure")

local GuideTreasureUI = class("GuideTreasureUI", ClassTreasureUI)

function GuideTreasureUI:init()
    local treasureInfo = UserData:getUserObj():getTreasure()
    local id = UserData:getUserObj():getTreasure().id or 1
    if id > self.num then
        id = self.num
    end
    self.currPos = id

    self.super.init(self)
    for k, v in pairs(self.skillImgs) do
        v:setTouchEnabled(false)
    end
    self.tameBtn:setTouchEnabled(false)
    local helpbtn = self.root:getChildByName('help_btn')
    helpbtn:setTouchEnabled(false)
end

function GuideTreasureUI:scrollToFireDragon()
    local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    hand:getAnimation():play("idle02", -1, -1)
    hand:getAnimation():gotoAndPause(0)
    hand:setRotation(180)
    self.root:addChild(hand)
    local startPos = cc.pAdd(self.pl:convertToWorldSpace(cc.p(self.imgs[self.currPos]:getPosition())), cc.p(150, 0))
    local endPos = cc.pAdd(cc.p(-350, 0), startPos)
    hand:setPosition(startPos)
    hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.8, endPos), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        hand:setPosition(startPos)
    end))))
    self.guideHand1 = hand
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:setTouchEnabled(false)
end

function GuideTreasureUI:setImgsPosition()
    self.super.setImgsPosition(self)
    if self.currPos == 2 then
        if self.guideHand1 then
            self.guideHand1:stopAllActions()
            self.guideHand1:removeFromParent()
            self.guideHand1 = nil
            GuideMgr:finishCurrGuide()
        end
    end
end

function GuideTreasureUI:guideEquipDragon()
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:setTouchEnabled(false)
    self.pl:setTouchEnabled(false)
    self.cannotMove = true
    local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    hand:getAnimation():play("idle02", -1, -1)
    hand:getAnimation():gotoAndPause(0)
    hand:setRotation(120)
    self.root:addChild(hand)
    local startPos = self.pl:convertToWorldSpace(cc.p(self.imgs[self.currPos]:getPosition()))
    local endPos = cc.pAdd(self.rightBottomImg:convertToWorldSpace(cc.p(self.skillImgs[1]:getPosition())), cc.p(-20, 0))
    hand:setPosition(startPos)
    hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(1, endPos), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        hand:setPosition(startPos)
    end))))
    self.guideHand2 = hand
end

function GuideTreasureUI:updateSkills(index)
    self.super.updateSkills(self, index)
    if self.guideHand2 then
        self.guideHand2:stopAllActions()
        self.guideHand2:removeFromParent()
        self.guideHand2 = nil
        local closeBtn = self.root:getChildByName("close_btn")
        closeBtn:setTouchEnabled(true)
        closeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:sendSkillsChange(function()
                    self:hideUI()
                end)
            end
        end)
        GuideMgr:finishCurrGuide()
    end
end

function GuideTreasureUI:updateLeftPanel()
    self.super.updateLeftPanel(self)
    self.tameBtn:setTouchEnabled(false)
end

return GuideTreasureUI