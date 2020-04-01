local CommonTipsUI = class("CommonTipsUI", BaseUI)

function CommonTipsUI:ctor(des1,des2,des3,pos)
	self.uiIndex = GAME_UI.UI_COMMON_TIPS
    self.des1 = des1
    self.des2 = des2
    self.des3 = des3
    self.pos = pos
end

function CommonTipsUI:init()
    local bgimg = self.root:getChildByName("bg_img_1")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideCommonTips()
        end
    end)
    local bgimg2 = bgimg:getChildByName("bg_img_2")
    local tx1 = bgimg2:getChildByName('tx1')
    local tx2 = bgimg2:getChildByName('tx2')
    local tx3 = bgimg2:getChildByName('tx3')
    self:adaptUI(bgimg,bgimg2)

    tx1:setString(self.des1)
    tx2:setString(self.des2)
    tx3:setString(self.des3)

    bgimg2:setPosition(self.pos)
    -- 这里只考虑上面的超出边界，以后会添加是否超出边界逻辑
    local bgImgSize = bgimg:getContentSize()
    local bgImgSize2 = bgimg2:getContentSize()
    local posY = bgimg2:getPositionY()
    if posY + bgImgSize2.height > bgImgSize.height then
        bgimg2:setPositionY(bgImgSize.height - bgImgSize2.height)
    end

end

return CommonTipsUI