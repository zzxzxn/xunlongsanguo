local ArenaHighestRankUI = class("ArenaHighestRankUI", BaseUI)

function ArenaHighestRankUI:ctor(highestRank, diffRank, displayAwards)
    self.uiIndex = GAME_UI.UI_ARENA_HIGHESTRANK
    self.highestRank = highestRank
    self.diffRank = diffRank
    self.displayAwards = displayAwards
end

function ArenaHighestRankUI:init()
    local highestBgImg = self.root:getChildByName("highest_bg_img")
    local highestAlphaImg = highestBgImg:getChildByName("highest_alpha_img")
    self:adaptUI(highestBgImg, highestAlphaImg)

    local middleNode = highestAlphaImg:getChildByName("middle_node")
    local closeBtn = middleNode:getChildByName("ok_btn")
    local btnLabel = closeBtn:getChildByName("text")
    btnLabel:setString(GlobalApi:getLocalStr("STR_KNOW_BY_KING"))
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        ArenaMgr:hideArenaHighestRank()
    end)

    local img_di = middleNode:getChildByName("img_di")
    local tx_1 = img_di:getChildByName("tx_1")
    tx_1:setString(GlobalApi:getLocalStr("STR_HIGHTEST_RANK"))
    local tx_2 = img_di:getChildByName("tx_2")
    tx_2:setString(GlobalApi:getLocalStr("RANK_TITLE_1") .. "：")
    local tx_3 = img_di:getChildByName("tx_3")
    tx_3:setString(GlobalApi:getLocalStr("STR_MAY_GET_AWARDS"))
    local tx_4 = img_di:getChildByName("tx_4")
    for k, v in pairs(self.displayAwards) do
        if v:getId() == "cash" then
            tx_4:setString(tostring(v:getNum()))
            break
        end
    end

    local currHighestLabel = cc.LabelAtlas:_create(tostring(self.highestRank + self.diffRank), "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
    currHighestLabel:setScale(0.8)
    currHighestLabel:setAnchorPoint(cc.p(0, 0.5))
    currHighestLabel:setPosition(cc.p(160, 118))
    img_di:addChild(currHighestLabel)

    local currRankLabel = cc.LabelAtlas:_create(tostring(self.highestRank), "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
    currRankLabel:setScale(0.8)
    currRankLabel:setAnchorPoint(cc.p(0, 0.5))
    currRankLabel:setPosition(cc.p(120, 78))
    img_di:addChild(currRankLabel)

    local richText = xx.RichText:create()
    img_di:addChild(richText)
    richText:setContentSize(cc.size(400, 28))
    richText:setPosition(cc.p(120 + currRankLabel:getContentSize().width*0.8, 78))
    richText:setAlignment("left")
    local re1 = xx.RichTextLabel:create("(  ", 20, COLOR_TYPE.WHITE)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextImage:create('uires/ui/common/arrow_up2.png')
    local re3 = xx.RichTextLabel:create(self.diffRank .. " )", 20, COLOR_TYPE.WHITE)
    re3:setFont('font/gamefont.ttf')
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:format(true)
    richText:setAnchorPoint(cc.p(0, 0.5))
    richText:setContentSize(richText:getElementsSize())
end

return ArenaHighestRankUI