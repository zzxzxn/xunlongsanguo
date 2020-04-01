local ArenaAwardsCell = class("ArenaAwardsCell")

function ArenaAwardsCell:ctor(lastObj, obj, index)
    self.width = 824
    self.height = 80
    self.index = index
    self:initCell(lastObj, obj)
end

function ArenaAwardsCell:initCell(lastObj, obj)
    local bgImg = ccui.ImageView:create()
    if self.index%2 == 0 then
        bgImg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bgImg:loadTexture("uires/ui/common/common_bg_10.png")
    end
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width, self.height))

    -- 排名
    local strLength = 0
    local rankLabel1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    rankLabel1:setAnchorPoint(cc.p(0, 0.5))
    rankLabel1:setTextColor(COLOR_TYPE.OFFWHITE)
    rankLabel1:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
    rankLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    rankLabel1:setString(GlobalApi:getLocalStr("ARENA_AWARDS_INFO_1"))
    rankLabel1:setPosition(cc.p(10, 40))
    bgImg:addChild(rankLabel1)
    strLength = rankLabel1:getContentSize().width
    if self.index == obj.rank then
        local rankLabel2 = cc.Label:createWithTTF(tostring(obj.rank), "font/gamefont.ttf", 25)
        rankLabel2:setAnchorPoint(cc.p(0, 0.5))
        rankLabel2:setTextColor(COLOR_TYPE.ORANGE)
        rankLabel2:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
        rankLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        rankLabel2:setPosition(cc.p(10 + strLength + 2, 40))
        bgImg:addChild(rankLabel2)
        strLength = strLength + rankLabel2:getContentSize().width

        local rankLabel3 = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
        rankLabel3:setAnchorPoint(cc.p(0, 0.5))
        rankLabel3:setTextColor(COLOR_TYPE.OFFWHITE)
        rankLabel3:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
        rankLabel3:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        rankLabel3:setString(GlobalApi:getLocalStr("ARENA_AWARDS_INFO_3"))
        rankLabel3:setPosition(cc.p(10 + strLength + 4, 40))
        bgImg:addChild(rankLabel3)
    else
        local rankLabel2 = cc.Label:createWithTTF(tostring(lastObj.rank+1), "font/gamefont.ttf", 25)
        rankLabel2:setAnchorPoint(cc.p(0, 0.5))
        rankLabel2:setTextColor(COLOR_TYPE.ORANGE)
        rankLabel2:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
        rankLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        rankLabel2:setPosition(cc.p(10 + strLength + 2, 40))
        bgImg:addChild(rankLabel2)
        strLength = strLength + rankLabel2:getContentSize().width

        local rankLabel3 = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
        rankLabel3:setAnchorPoint(cc.p(0, 0.5))
        rankLabel3:setTextColor(COLOR_TYPE.OFFWHITE)
        rankLabel3:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
        rankLabel3:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        rankLabel3:setString(GlobalApi:getLocalStr("ARENA_AWARDS_INFO_2"))
        rankLabel3:setPosition(cc.p(10 + strLength + 4, 40))
        bgImg:addChild(rankLabel3)
        strLength = strLength + rankLabel3:getContentSize().width

        local rankLabel4 = cc.Label:createWithTTF(tostring(obj.rank), "font/gamefont.ttf", 25)
        rankLabel4:setAnchorPoint(cc.p(0, 0.5))
        rankLabel4:setTextColor(COLOR_TYPE.ORANGE)
        rankLabel4:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
        rankLabel4:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        rankLabel4:setPosition(cc.p(10 + strLength + 6, 40))
        bgImg:addChild(rankLabel4)
        strLength = strLength + rankLabel4:getContentSize().width

        local rankLabel5 = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
        rankLabel5:setAnchorPoint(cc.p(0, 0.5))
        rankLabel5:setTextColor(COLOR_TYPE.OFFWHITE)
        rankLabel5:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
        rankLabel5:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        rankLabel5:setString(GlobalApi:getLocalStr("ARENA_AWARDS_INFO_3"))
        rankLabel5:setPosition(cc.p(10 + strLength + 8, 40))
        bgImg:addChild(rankLabel5)
    end
    local arr = DisplayData:getDisplayObjs(obj.award)
    -- 元宝
    if arr[1] then
        local cashImg = cc.Sprite:create(arr[1]:getIcon())
        cashImg:setScale(0.7)
        cashImg:setPosition(cc.p(420, 40))
        bgImg:addChild(cashImg)
        --local cashLabel = cc.LabelAtlas:_create(tostring(arr[1]:getNum()), "uires/ui/number/font_sz.png", 17, 23, string.byte('0'))
        local cashLabel = cc.Label:createWithTTF(GlobalApi:toWordsNumber(arr[1]:getNum()), "font/gamefont.ttf", 25)
        cashLabel:setAnchorPoint(cc.p(0, 0.5))
        cashLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        cashLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        cashLabel:setPosition(cc.p(450, 40))
        bgImg:addChild(cashLabel)
    end

    -- 金币
    if arr[2] then
        local goldImg = cc.Sprite:create(arr[2]:getIcon())
        goldImg:setScale(0.7)
        goldImg:setPosition(cc.p(530, 40))
        bgImg:addChild(goldImg)
        --local goldLabel = cc.LabelAtlas:_create(GlobalApi:toWordsNumber(arr[2]:getNum()), "uires/ui/number/font_sz.png", 17, 23, string.byte('0'))
        local goldLabel = cc.Label:createWithTTF(GlobalApi:toWordsNumber(arr[2]:getNum()), "font/gamefont.ttf", 25)
        goldLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        goldLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        goldLabel:setAnchorPoint(cc.p(0, 0.5))
        goldLabel:setPosition(cc.p(550, 40))
        bgImg:addChild(goldLabel)
    end

    -- 将魂
    if arr[3] then
        local soulImg = cc.Sprite:create(arr[3]:getIcon())
        soulImg:setScale(0.7)
        soulImg:setPosition(cc.p(670, 40))
        bgImg:addChild(soulImg)
        --local soulLabel = cc.LabelAtlas:_create(tostring(arr[3]:getNum()), "uires/ui/number/font_sz.png", 17, 23, string.byte('0'))
        local soulLabel = cc.Label:createWithTTF(tostring(arr[3]:getNum()), "font/gamefont.ttf", 25)
        soulLabel:setAnchorPoint(cc.p(0, 0.5))
        soulLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        soulLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        soulLabel:setPosition(cc.p(700, 40))
        bgImg:addChild(soulLabel)
    end

    -- 朕
    if self.index == obj.rank then
        if ArenaMgr.myRank == obj.rank then
            local isMeImg = cc.Sprite:create("uires/ui/common/icon_bg_green.png")
            isMeImg:setPosition(cc.p(770, 40))
            bgImg:addChild(isMeImg)
            local isMeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
            isMeLabel:setAnchorPoint(cc.p(0.5, 0.5))
            isMeLabel:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
            isMeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            isMeLabel:setString(GlobalApi:getLocalStr("STR_ME_KING"))
            isMeLabel:setPosition(cc.p(23, 23))
            isMeImg:addChild(isMeLabel)
        end
    else
        if ArenaMgr.myRank <= obj.rank and ArenaMgr.myRank >= lastObj.rank + 1 then
            local isMeImg = cc.Sprite:create("uires/ui/common/icon_bg_green.png")
            isMeImg:setPosition(cc.p(770, 40))
            bgImg:addChild(isMeImg)
            local isMeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
            isMeLabel:setAnchorPoint(cc.p(0.5, 0.5))
            isMeLabel:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
            isMeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            isMeLabel:setString(GlobalApi:getLocalStr("STR_ME_KING"))
            isMeLabel:setPosition(cc.p(23, 23))
            isMeImg:addChild(isMeLabel)
        end
    end
    self.panel = bgImg
end

function ArenaAwardsCell:getPanel()
    return self.panel
end

function ArenaAwardsCell:getSize()
    return self.width, self.height
end

function ArenaAwardsCell:setPosition(pos)
    self.panel:setPosition(pos)
end

return ArenaAwardsCell