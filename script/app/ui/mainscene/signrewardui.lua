local SignRewardUI = class("SignRewardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SignRewardUI:ctor()
	self.uiIndex = GAME_UI.UI_SIGNREWARDUI
    self.signrewardconf = GameData:getConfData('signreward')
	self.signdata = UserData:getUserObj():getSign()
    self.rewardtab = {}
end
function SignRewardUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 = bgimg:getChildByName("bg_img1")
    self:adaptUI(bgimg, bgimg1)
	local bgimg2 = bgimg1:getChildByName('bg_img2')
    local winsize = cc.Director:getInstance():getWinSize()
    --local closebtn = bgimg2:getChildByName('close_btn')
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideSignReward()
        end
    end)
    local bgimg4 = bgimg2:getChildByName('bg_img4')
    local title = bgimg4:getChildByName('cont_title_tx')
    local desc  = bgimg4:getChildByName('cont_desc_tx')
    title:setString('')
    desc:setString('')

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC2'), 28, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(self.signdata.continuous, 28, COLOR_TYPE.ORANGE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC3'), 28, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setPosition(cc.p(0,0))
    richText:setAlignment('middle')
    title:removeAllChildren()
    title:addChild(richText)
    richText:setVisible(true)


    local richText2 = xx.RichText:create()
    richText2:setContentSize(cc.size(300, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC4'), 23, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(self.signdata.continuous, 23, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC5'), 23, COLOR_TYPE.ORANGE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText2:addElement(re1)
    richText2:addElement(re2)
    richText2:addElement(re3)
    richText2:setAlignment('middle')
    richText2:setPosition(cc.p(0,-3))
    --richText:setAnchorPoint(cc.p(0,0.5))
    desc:removeAllChildren()
    desc:addChild(richText2)
    richText2:setVisible(true)
    self.sv = bgimg4:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function SignRewardUI:update()
    self.num = #self.signrewardconf
    for i=1, self.num do
        self:addCells(i,self.signrewardconf[i])
    end
    self.sv:scrollToTop(0.01, false)
end

function SignRewardUI:createCell()
    local bgImg = ccui.ImageView:create("uires/ui/common/bg1_alpha.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(340, 110))
    bgImg:setAnchorPoint(cc.p(0, 0))

    local itemCell1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    itemCell1.awardBgImg:setName("award_bg_img1")
    itemCell1.awardBgImg:setPosition(cc.p(190, 55))
    bgImg:addChild(itemCell1.awardBgImg)

    local itemCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    itemCell2.awardBgImg:setName("award_bg_img2")
    itemCell2.awardBgImg:setPosition(cc.p(290, 55))
    bgImg:addChild(itemCell2.awardBgImg)

    return bgImg
end

function SignRewardUI:addCells(index,data)
    self.rewardtab[index] = self:createCell()
    self:updateCell(index,data)
    local contentsize = self.rewardtab[index]:getContentSize()
    if self.num*(contentsize.height) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height)))
    end
    local posy = self.sv:getInnerContainerSize().height-(contentsize.height)*(index-1)- contentsize.height 
    self.rewardtab[index]:setPosition(cc.p(0,posy))
    self.sv:addChild(self.rewardtab[index])
end

function SignRewardUI:updateCell(index,data)
    local bg = self.rewardtab[index]
    local richText2 = xx.RichText:create()
    richText2:setContentSize(cc.size(150, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC10'), 25, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(index, 25, COLOR_TYPE.ORANGE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC5'), 25, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText2:addElement(re1)
    richText2:addElement(re2)
    richText2:addElement(re3)
    richText2:setAlignment('middle')
    richText2:setPosition(cc.p(75, 55))
    
    bg:addChild(richText2)

    local displayarr = DisplayData:getDisplayObjs(data['awards'])
    
    for i=1,2 do
        local itembg = bg:getChildByName('award_bg_img' .. i)
        ClassItemCell:updateItem(itembg, displayarr[i], 2)
        itembg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(displayarr[i],false)
            end
        end)
    end

end

return SignRewardUI
