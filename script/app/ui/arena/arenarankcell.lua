local ArenaRankCell = class("ArenaRankCell")

function ArenaRankCell:ctor(heroObj, index)
    self.width = 824
    self.height = 80
    self.index = index
    self:initCell(heroObj)
end

function ArenaRankCell:initCell(heroObj)
    local bgImg = ccui.ImageView:create()
    if self.index%2 == 0 then
        bgImg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bgImg:loadTexture("uires/ui/common/common_bg_10.png")
    end
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width, self.height))

    -- 排名
    local rankLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 40)
    rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rankLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    rankLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    rankLabel:setString(tostring(self.index))
    rankLabel:setPosition(cc.p(60, 40))
    bgImg:addChild(rankLabel)
    if self.index == 1 then
        local cup = cc.Sprite:create("uires/ui/arena/cup_1.png")
        cup:setPosition(cc.p(60, 40))
        bgImg:addChild(cup)
        rankLabel:setVisible(false)
    elseif self.index == 2 then
        local cup = cc.Sprite:create("uires/ui/arena/cup_2.png")
        cup:setPosition(cc.p(60, 40))
        bgImg:addChild(cup)
        rankLabel:setVisible(false)
    elseif self.index == 3 then
        local cup = cc.Sprite:create("uires/ui/arena/cup_3.png")
        cup:setPosition(cc.p(60, 40))
        bgImg:addChild(cup)
        rankLabel:setVisible(false)
    end
    -- 头像
    local heroConf = GameData:getConfData("hero")
    local headpicUrl = "uires/icon/hero/" .. heroConf[tonumber(heroObj.headpic)].heroIcon
    local headpicBg = cc.Sprite:create("uires/ui/common/frame_blue.png")
    local headpicIcon = cc.Sprite:create(headpicUrl)
    headpicIcon:setPosition(cc.p(47, 47))
    headpicBg:addChild(headpicIcon)
    bgImg:addChild(headpicBg)
    headpicBg:setScale(0.7)
    headpicBg:setPosition(cc.p(175, 40))

    -- 姓名
    local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameLabel:setString(heroObj.name)
    nameLabel:setPosition(cc.p(215, 58))
    bgImg:addChild(nameLabel)

    -- 等级图标
    local lvSp = cc.Sprite:create("uires/ui/common/lv_art.png")
    lvSp:setPosition(cc.p(232, 25))
    bgImg:addChild(lvSp)
    -- 等级
    local lvLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    lvLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    lvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lvLabel:setString(tostring(heroObj.level))
    lvLabel:setPosition(cc.p(248, 25))
    bgImg:addChild(lvLabel)

    -- 战斗力
    local fightImg = cc.Sprite:create("uires/ui/common/fightbg.png")
    fightImg:setPosition(cc.p(430, 40))
    bgImg:addChild(fightImg)
    local fightforceLabel = cc.LabelAtlas:_create(tostring(heroObj.fight_force), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    --local fightforceLabel = cc.Label:createWithTTF(tostring(heroObj.fight_force), "font/numberfont.ttf", 36)
    fightforceLabel:setScale(0.7)
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    fightforceLabel:setPosition(cc.p(452, 40))
    --fightforceLabel:setTextColor(COLOR_TYPE.OFFWHITE)
    --fightforceLabel:enableOutline(COLOROUTLINE_TYPE.OFFWHITE, 1)
    --fightforceLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.FIGHTFORCE))
    bgImg:addChild(fightforceLabel)

    -- 查看按钮
    local lookBtn = ccui.Button:create("uires/ui/common/common_btn_5.png")
    lookBtn:setPosition(cc.p(700, 40))
    bgImg:addChild(lookBtn)
    local lookLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
    lookLabel:setAnchorPoint(cc.p(0.5, 0.5))
    lookLabel:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
    lookLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    lookLabel:setString(GlobalApi:getLocalStr("STR_LOOK_OVER"))
    lookLabel:setPosition(cc.p(67, 37))
    lookBtn:addChild(lookLabel)
    lookBtn:addClickEventListener(function ()
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('TO_BE_EXPECTED'), COLOR_TYPE.GREEN)
		BattleMgr:showCheckInfo(heroObj.uid,'world','arena')
    end)

    self.panel = bgImg
end

function ArenaRankCell:getPanel()
    return self.panel
end

function ArenaRankCell:getSize()
    return self.width, self.height
end

function ArenaRankCell:setPosition(pos)
    self.panel:setPosition(pos)
end

return ArenaRankCell