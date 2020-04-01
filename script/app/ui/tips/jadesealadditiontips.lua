local JadeSealAdditionTips = class("JadeSealAdditionTips", BaseUI)

function JadeSealAdditionTips:ctor(position, key)
    self.uiIndex = GAME_UI.UI_TIPS_JADE_SEAL_ADDITION
    self.tipsPosition = position
    self.key = key
end

function JadeSealAdditionTips:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    bg_img:addClickEventListener(function ()
        TipsMgr:hideJadeSealAdditionTips()
    end)
    
    local bg_tips = self.root:getChildByName("bg_tips")
    local addX = 0
    local addY = 0
    if winSize.width - self.tipsPosition.x < 330 then
        addX = -160
    else
        addX = 160
    end
    if self.tipsPosition.y > winSize.height/2 then
        addY = -60
    else
        addY = 60
    end
    bg_tips:setPosition(cc.pAdd(self.tipsPosition, cc.p(addX, addY)))

    local jadesealconf = GameData:getConfData("jadeseal")
    local unlock
    local jadeIndex = 0
    for k, v in ipairs(jadesealconf) do
        unlock = string.split(v.unlock, ".")
        if unlock[1] == self.key then
            jadeIndex = k
            break
        end
    end

    local icon_img = bg_tips:getChildByName("icon_img")
    icon_img:ignoreContentAdaptWithSize(true)
    icon_img:loadTexture("uires/ui/jadeseal/jadeseal_" .. jadesealconf[jadeIndex].jadesealicon)

    local desc_1 = bg_tips:getChildByName("desc_1")
    desc_1:setString(GlobalApi:getLocalStr("COLLECT_STAGE"))

    local posx = desc_1:getPositionX() + desc_1:getContentSize().width
    local desc_2 = bg_tips:getChildByName("desc_2")
    desc_2:setString(tostring(jadesealconf[jadeIndex].star))
    desc_2:setPositionX(posx)

    posx = posx + desc_2:getContentSize().width
    local star_img = bg_tips:getChildByName("star_img")
    star_img:setPositionX(posx)

    posx = posx + star_img:getContentSize().width
    local desc_3 = bg_tips:getChildByName("desc_3")
    desc_3:setString(GlobalApi:getLocalStr("GUARD_DESC19"))
    desc_3:setPositionX(posx)

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(190, 33))
    richText:setAnchorPoint(cc.p(0, 0.5))
    bg_tips:addChild(richText)
    richText:setPosition(cc.p(72, 30))
    xx.Utils:Get():analyzeHTMLTag(richText, jadesealconf[jadeIndex].desc)
end

return JadeSealAdditionTips