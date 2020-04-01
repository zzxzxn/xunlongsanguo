local ClassItemCell = require('script/app/global/itemcell')
local InfiniteBattleBossLevelUpUI = class("InfiniteBattleBossLevelUpUI", BaseUI)

function InfiniteBattleBossLevelUpUI:ctor(canUpgrade, callback)
	self.uiIndex = GAME_UI.UI_INFINITE_BATTLE_BOSS_LEVEL_UP
    self.canUpgrade = canUpgrade
    self.callback = callback
end

function InfiniteBattleBossLevelUpUI:init()
    local infiniteData = UserData:getUserObj():getInfinite()
    local boss_bg_img = self.root:getChildByName("boss_bg_img")
    local boss_img = boss_bg_img:getChildByName("boss_img")
    self:adaptUI(boss_bg_img, boss_img)

    local closeBtn = boss_img:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            InfiniteBattleMgr:hideInfiniteBattleBossLevelUp()
        end
    end)

    local nei_bg_img = boss_img:getChildByName("nei_bg_img")
    local title_tx = nei_bg_img:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("CHALLENGE_UPGRADE"))

    local info_tx_1 = nei_bg_img:getChildByName("info_tx_1")
    info_tx_1:setString(GlobalApi:getLocalStr("INFINITE_INFO_1") .. "：")
    local info_tx_2 = nei_bg_img:getChildByName("info_tx_2")
    info_tx_2:setString(GlobalApi:getLocalStr("INFINITE_INFO_2") .. "：")

    local num_tx_1 = nei_bg_img:getChildByName("num_tx_1")
    num_tx_1:setString("x " .. infiniteData.boss_level)
    local num_tx_2 = nei_bg_img:getChildByName("num_tx_2")
    num_tx_2:setString("x " .. (infiniteData.boss_level + 1))

    local award_sv = nei_bg_img:getChildByName("award_sv")
    award_sv:setScrollBarEnabled(false)
    local svSize = award_sv:getContentSize()
    local bossConf = GameData:getConfData("itboss")
    if bossConf[infiniteData.boss_level + 1] then
        local award = bossConf[infiniteData.boss_level + 1].award
        local awardObjs = DisplayData:getDisplayObjs(award)
        local awardNum = #awardObjs
        for i, v in ipairs(awardObjs) do
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, award_sv)
            tab.awardBgImg:setAnchorPoint(cc.p(0,0.5))
            tab.awardBgImg:setPosition(cc.p((i - 1)*110 + 10, 50))
            v:setLightEffect(tab.awardBgImg)
            local stype = v:getCategory()
            if stype == 'equip' then
                tab.lvTx:setString('Lv.'..v:getLevel())
            else
                tab.lvTx:setString('x'..v:getNum())
            end
        end
        if awardNum * 110 + 10 > svSize.width then
            award_sv:setInnerContainerSize(cc.size(awardNum*110, svSize.height))
        else
            award_sv:setInnerContainerSize(svSize)
        end
    end

    local ok_btn = nei_bg_img:getChildByName("ok_btn")
    local ob_tx = ok_btn:getChildByName("info_tx")
    if self.canUpgrade then
        ob_tx:setString(GlobalApi:getLocalStr("STR_UPGRADE_1"))
    else
        ob_tx:setString(GlobalApi:getLocalStr("STR_UNDERSTAND"))
    end
    ok_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            InfiniteBattleMgr:hideInfiniteBattleBossLevelUp()
            if self.callback then
                self.callback()
            end
        end
    end)
end

return InfiniteBattleBossLevelUpUI