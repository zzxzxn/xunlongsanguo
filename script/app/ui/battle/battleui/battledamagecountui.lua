local BattleDamageCountUI = class("BattleDamageCountUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj = require('script/app/obj/roleobj')

local CELL_WIDTH = 260
local CELL_HEIGHT = 70

local function createCell(index, obj, left, maxDmg)
    local bgImg = ccui.ImageView:create("uires/ui/common/bg1_alpha.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(CELL_WIDTH, CELL_HEIGHT))

    -- 头像
    local headpicBg
    if obj.isMonster then
        headpicBg = ccui.ImageView:create(COLOR_FRAME[obj.quality])
        headpicBg:setScale(0.7)
        local headpicIcon = ccui.ImageView:create(obj.headpic)
        headpicIcon:setPosition(cc.p(47, 47))
        headpicBg:addChild(headpicIcon)
        bgImg:addChild(headpicBg)
    else
        local heroObj = ClassRoleObj.new(obj.hid, 0)
        heroObj:setPromoted(obj.promote)
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, heroObj, bgImg)
        cell.awardBgImg:setScale(0.7)
        cell.awardBgImg:setTouchEnabled(false)
        headpicBg = cell.awardBgImg
    end
    -- 伤害数字
    local dmgLabel = cc.Label:createWithTTF(tostring(math.floor(obj.dmg)), "font/gamefont.ttf", 24)
    dmgLabel:setTextColor(cc.c4b(255,247,229, 255))
    bgImg:addChild(dmgLabel)

    -- 进度条
    local bgBar = ccui.ImageView:create("uires/ui/battleresult/br_bar_bg.png")
    local barSize = bgBar:getContentSize()
    bgImg:addChild(bgBar)
    local loadingBar = ccui.LoadingBar:create("uires/ui/battleresult/bar_" .. left .. ".png", obj.dmg/maxDmg*100)
    loadingBar:setPosition(cc.p(barSize.width/2, barSize.height/2))
    bgBar:addChild(loadingBar)

    if left == 1 then
        headpicBg:setPosition(cc.p(40, 35))
        dmgLabel:setPosition(cc.p(208, 50))
        bgBar:setPosition(cc.p(208, 20))
    else
        loadingBar:setDirection(ccui.LoadingBarDirection.RIGHT)
        headpicBg:setPosition(cc.p(CELL_WIDTH - 40, 35))
        dmgLabel:setPosition(cc.p(CELL_WIDTH - 208, 50))
        bgBar:setPosition(cc.p(CELL_WIDTH - 208, 20))
    end
    
    return bgImg
end

function BattleDamageCountUI:ctor(damageInfo, isReport)
    self.uiIndex = GAME_UI.UI_BATTLEDAMAGECOUNT
    self.damageInfo = damageInfo
    self.isReport = isReport
end

function BattleDamageCountUI:init()
    local countBgImg = self.root:getChildByName("count_bg_img")
    local countNode = countBgImg:getChildByName("count_node")
    self:adaptUI(countBgImg, countNode)
    countBgImg:addClickEventListener(function ()
        self:hideUI()
    end)
    local leftLabel = countNode:getChildByName("left_tx")
    local rightLabel = countNode:getChildByName("right_tx")
    if self.isReport then
        leftLabel:setString(self.damageInfo.atkName)
        rightLabel:setString(self.damageInfo.defName)
    else
        leftLabel:setString(GlobalApi:getLocalStr("STR_MY_SIDE"))
        rightLabel:setString(GlobalApi:getLocalStr("STR_ENEMY_SIDE"))
    end
    local infoLabel = countNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local sv = countNode:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    local svSize = sv:getContentSize()
    local contentWidget = ccui.Widget:create()
    sv:addChild(contentWidget)

    local cellMaxHeight = 10
    local maxDmg = self.damageInfo.damageArr[1].dmg
    local cellTotalHeight1 = 5
    local cellTotalHeight2 = 5
    local index1 = 1
    local index2 = 1
    for k, v in ipairs(self.damageInfo.damageArr) do
        if v.guid == 1 then
            if index1 <= 10 then
                cellTotalHeight1 = cellTotalHeight1 + CELL_HEIGHT + 5
            end
            local cell = createCell(k, v, 1, maxDmg)
            cell:setPosition(cc.p(-svSize.width/2 + CELL_WIDTH/2 + 10, CELL_HEIGHT*0.5 - cellTotalHeight1 + 10))
            contentWidget:addChild(cell)
            index1 = index1 + 1
        else
            if index2 <= 10 then
                cellTotalHeight2 = cellTotalHeight2 + CELL_HEIGHT + 5    
            end
            local cell = createCell(k, v, 2, maxDmg)
            cell:setPosition(cc.p(svSize.width/2 - CELL_WIDTH/2 - 10, CELL_HEIGHT*0.5 - cellTotalHeight2 + 10))
            contentWidget:addChild(cell)
            index2 = index2 + 1
        end
    end
    cellMaxHeight = cellMaxHeight < cellTotalHeight1 and cellTotalHeight1 or cellMaxHeight
    cellMaxHeight = cellMaxHeight < cellTotalHeight2 and cellTotalHeight2 or cellMaxHeight
    local posY = svSize.height
    if cellMaxHeight > posY then
        posY = cellMaxHeight
    end
    sv:setInnerContainerSize(cc.size(svSize.width, posY))
    contentWidget:setPosition(cc.p(svSize.width*0.5, posY))
end

return BattleDamageCountUI