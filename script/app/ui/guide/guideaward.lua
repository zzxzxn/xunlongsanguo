local ClassGuideBase = require("script/app/ui/guide/guidebase")
local ClassItemCell = require('script/app/global/itemcell')
local GuideAward = class("GuideAward", ClassGuideBase)

function GuideAward:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
    self.clickFlag = false
end

function GuideAward:startGuide()
    local winSize = cc.Director:getInstance():getWinSize()
    local guideObj = self.guideObj
    self.bgImg = ccui.ImageView:create("uires/ui/common/bg_gray2.png")
    self.bgImg:setScale9Enabled(true)
    self.bgImg:setContentSize(winSize)
    self.bgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    
    local itemObj = DisplayData:getDisplayObj(self.guideObj.item)
    local infoLabel = cc.Label:createWithTTF(GlobalApi:getLocalStr(self.guideObj.text), "font/gamefont.ttf", 28)
    infoLabel:setTextColor(itemObj:getNameColor())
    infoLabel:enableOutline(itemObj:getNameOutlineColor(), 1)
    infoLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    infoLabel:setPosition(winSize.width/2, winSize.height/2 + 100)
    self.bgImg:addChild(infoLabel)
    infoLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1)))

    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, itemObj, self.bgImg)
    tab.awardBgImg:setPosition(winSize.width/2, winSize.height/2)
    tab.awardBgImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1))))

    local nameLabel = cc.Label:createWithTTF(itemObj:getName(), "font/gamefont.ttf", 23)
    nameLabel:setTextColor(itemObj:getNameColor())
    nameLabel:enableOutline(itemObj:getNameOutlineColor(), 1)
    nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameLabel:setPosition(winSize.width/2, winSize.height/2 - 70)
    self.bgImg:addChild(nameLabel)

    local closeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
    closeLabel:setTextColor(COLOR_TYPE.WHITE)
    closeLabel:enableOutline(COLOR_TYPE.BLACK, 1)
    closeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    closeLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    closeLabel:setPosition(winSize.width/2, 80)
    self.bgImg:addChild(closeLabel)
    closeLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    self.guideNode:addChild(self.bgImg)
    self.nameLabel = nameLabel
    self.infoLabel = infoLabel
    self.closeLabel = closeLabel
    self.itemCell = tab
end

function GuideAward:onClickScreen()
    if not self.clickFlag then
        self.clickFlag = true
        self.nameLabel:setVisible(false)
        self.infoLabel:setVisible(false)
        self.closeLabel:setVisible(false)
        local sidebar = UIManager:getSidebar()
        sidebar:setFrameBtnsVisible(true)
        local bagBtn = xx.Utils:Get():seekNodeByName(sidebar:getNode(), "bag_btn")
        local pos = bagBtn:getParent():convertToWorldSpace(cc.p(bagBtn:getPosition()))
        self.itemCell.awardBgImg:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseExponentialOut:create(cc.MoveTo:create(1, pos)), cc.ScaleTo:create(1, 0)), cc.CallFunc:create(function ()
            self.bgImg:removeFromParent()
            self:finish()
        end)))
    end
end

return GuideAward