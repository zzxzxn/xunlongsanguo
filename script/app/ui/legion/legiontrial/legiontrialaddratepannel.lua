local LegionTrialAddRatePannelUI = class("LegionTrialAddRatePannelUI", BaseUI)

function LegionTrialAddRatePannelUI:ctor()
    self.uiIndex = GAME_UI.UI_LEGION_TRIAL_ADD_RATE_PANNEL

end

function LegionTrialAddRatePannelUI:init()
	local bg_img = self.root:getChildByName("bg_img")
    local alpha_img = bg_img:getChildByName("alpha_img")
    self:adaptUI(bg_img, alpha_img)

    local main_img = alpha_img:getChildByName("main_img")
    
    local close_btn = main_img:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAddRatePannelUI()
        end
    end)

    local title_bg = main_img:getChildByName('title_bg')
    local title_tx = title_bg:getChildByName('title_tx')
    title_tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC24'))

    self.legionTrialCoinIncreaSetype = GameData:getConfData('legiontrialcoinincreasetype')

    --
    local sv = main_img:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = main_img:getChildByName('cell')
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell

    self:updateSV()

end

function LegionTrialAddRatePannelUI:updateSV()
    local num = #self.legionTrialCoinIncreaSetype
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * self.rewardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local data = self.legionTrialCoinIncreaSetype[i]

        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        self.sv:addChild(tempCell)

        local leftImg = tempCell:getChildByName('left_img')
        leftImg:loadTexture('uires/icon/legiontrial/' .. data.icon)

        local des1 = tempCell:getChildByName('des1')
        des1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC28'))

        local awardIncrease = data.awardIncrease
        local value = string.format("%.1f", awardIncrease)
        local add_num = tempCell:getChildByName('add_num')
        add_num:setString('+' .. value)
        
        local des = data.desc
        local des2 = tempCell:getChildByName('des2')
        des2:setString(des)

        if i == 4 then
            des2:setVisible(true)
        else
            des2:setVisible(false)

            local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(500, 38))

	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC26'), 28, cc.c4b(255, 247, 229, 255))
	        re1:setStroke(cc.c4b(78, 49, 17, 255),2)
            re1:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')
    
	        local re2 = xx.RichTextLabel:create(des, 28,COLOR_TYPE.ORANGE)
	        re2:setStroke(cc.c4b(78, 49, 17, 255),2)
            re2:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
            re2:setFont('font/gamefont.ttf')

	        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC27'), 28, cc.c4b(255, 247, 229, 255))
	        re3:setStroke(cc.c4b(78, 49, 17, 255),2)
            re3:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
            re3:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:addElement(re3)

            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0,0.5))
	        richText:setPosition(cc.p(des2:getPositionX(),des2:getPositionY()))
            richText:format(true)
            tempCell:addChild(richText)

        end

    end
    innerContainer:setPositionY(size.height - allHeight)
end

return LegionTrialAddRatePannelUI