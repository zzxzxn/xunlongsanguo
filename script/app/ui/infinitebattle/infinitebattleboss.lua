local ClassItemCell = require('script/app/global/itemcell')
local InfiniteBattleBossUI = class("InfiniteBattleBossUI", BaseUI)

function InfiniteBattleBossUI:ctor(chapterId, showAni)
	self.uiIndex = GAME_UI.UI_INFINITE_BATTLE_BOSS
    self.infiniteData = UserData:getUserObj():getInfinite()
    self.chapterId = chapterId
    self.showAni = showAni
end

function InfiniteBattleBossUI:init()
    local boss_bg_img = self.root:getChildByName("boss_bg_img")
    local boss_img = boss_bg_img:getChildByName("boss_img")
    self:adaptUI(boss_bg_img, boss_img)
    local closeBtn = boss_img:getChildByName("close_btn")
    local titleImg = boss_img:getChildByName("title_img")
    local text = titleImg:getChildByName("text")
    text:setString(GlobalApi:getLocalStr("CHALLENGE_1"))

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            InfiniteBattleMgr:hideInfiniteBattleBoss()
        end
    end)

    local nei_bg_img = boss_img:getChildByName("nei_bg_img")
    self.left_bg_img = nei_bg_img:getChildByName("left_bg_img")
    local help_btn = self.left_bg_img:getChildByName("help_btn")
    help_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(HELP_SHOW_TYPE.INFINITE_BATTLE_BOSS)
        end
    end)
    self.right_pl = nei_bg_img:getChildByName("right_pl")

    self:initLeft()
    self:initRight()
end

function InfiniteBattleBossUI:initLeft()
    local bossConf = GameData:getConfData("itboss")
    local monsterGroup = bossConf[self.infiniteData.boss_level].fightId
    local monsterConf = GameData:getConfData("formation")[monsterGroup]

    local zhan_bg_img = self.left_bg_img:getChildByName("zhan_bg_img")
    local fightforceLabel = cc.LabelAtlas:_create(tostring(monsterConf.fightforce), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    fightforceLabel:setPosition(cc.p(130, 22))
    fightforceLabel:setScale(0.7)
    zhan_bg_img:addChild(fightforceLabel)

    local monsterId = monsterConf['pos'..monsterConf.boss]
    local monsterObj = GameData:getConfData("monster")[monsterId]
    local spineAni = GlobalApi:createLittleLossyAniByName(monsterObj.url .. "_display")
    local shadow = spineAni:getBone(monsterObj.url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
    spineAni:setPosition(cc.p(195, 135 + monsterObj.uiOffsetY))
    self.left_bg_img:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function InfiniteBattleBossUI:initRight()
    local top_bg_img = self.right_pl:getChildByName("top_bg_img")
    local difficulty_tx = top_bg_img:getChildByName("difficulty_tx")
    difficulty_tx:setString(GlobalApi:getLocalStr("STR_DIFFICULTY") .. "：")
    local info_tx = top_bg_img:getChildByName("info_tx")
    info_tx:setString(GlobalApi:getLocalStr("INFINITE_BATTLE_INFO_1"))

    if self.showAni then
        for i = 1, 6 do
            local difficulty = top_bg_img:getChildByName("difficulty_" .. i)
            difficulty:ignoreContentAdaptWithSize(true)
            if self.infiniteData.boss_level > i then
                difficulty:loadTexture("uires/ui/infinitebattle/infinitebattle_difficulty_1.png")
            else
                difficulty:loadTexture("uires/ui/infinitebattle/infinitebattle_difficulty_2.png")
            end
        end
        local lastStar = self.infiniteData.boss_level
        local lastDifficulty = top_bg_img:getChildByName("difficulty_" .. lastStar)
        if lastDifficulty then
            local worldPos = top_bg_img:convertToWorldSpace(cc.p(lastDifficulty:getPosition()))
            local pos = self.root:convertToNodeSpace(worldPos)
            local difficulty2 = ccui.ImageView:create("uires/ui/infinitebattle/infinitebattle_difficulty_1.png")
            difficulty2:setPosition(cc.p(pos.x, pos.y + 100))
            self.root:addChild(difficulty2)

            difficulty2:setScale(5)
            difficulty2:runAction(cc.Spawn:create(cc.MoveTo:create(0.2, pos), cc.ScaleTo:create(0.2, 1)))
        end
    else
        for i = 1, 6 do
            local difficulty = top_bg_img:getChildByName("difficulty_" .. i)
            difficulty:ignoreContentAdaptWithSize(true)
            if self.infiniteData.boss_level >= i then
                difficulty:loadTexture("uires/ui/infinitebattle/infinitebattle_difficulty_1.png")
            else
                difficulty:loadTexture("uires/ui/infinitebattle/infinitebattle_difficulty_2.png")
            end
        end
    end

    local bottom_bg_img = self.right_pl:getChildByName("bottom_bg_img")
    local title_bg_img = bottom_bg_img:getChildByName("title_bg_img")
    local info_tx2 = title_bg_img:getChildByName("info_tx")
    info_tx2:setString(GlobalApi:getLocalStr("LEGION_LEVELS_DESC3"))

    local gold_bg_img = bottom_bg_img:getChildByName("gold_bg_img")
    local desc_tx = gold_bg_img:getChildByName("desc_tx")
    desc_tx:setString(GlobalApi:getLocalStr("STR_CONSUME"))
    local desc_tx_0 = gold_bg_img:getChildByName("desc_tx_0")
    desc_tx_0:setString("x 1")

    local award_sv = bottom_bg_img:getChildByName("award_sv")
    award_sv:setScrollBarEnabled(false)
    local svSize = award_sv:getContentSize()
    local bossConf = GameData:getConfData("itboss")
    local award = bossConf[self.infiniteData.boss_level].award
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
    local fighting_btn = bottom_bg_img:getChildByName("fighting_btn")
    local btn_tx = fighting_btn:getChildByName("info_tx")
    local boss_sweep = self.infiniteData.boss_sweep or 0
    if boss_sweep == 1 then -- 扫荡
        btn_tx:setString(GlobalApi:getLocalStr("RAIDS2"))
        fighting_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local num = UserData:getUserObj():getShas()
                if num > 0 then
                    MessageMgr:sendPost("sweep_boss", "unlimited", "{}", function (jsonObj)
                        if jsonObj.code == 0 then
                            GlobalApi:parseAwardData(jsonObj.data.awards)
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            GlobalApi:showAwardsCommon(jsonObj.data.awards, nil, nil, true)
                        end
                    end)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("SHAS_NOT_ENOUGH"), COLOR_TYPE.RED)
                end
            end
        end)
    else
        btn_tx:setString(GlobalApi:getLocalStr("GUARD_DESC4"))
        fighting_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local num = UserData:getUserObj():getShas()
                local chapterId = self.chapterId
                if num > 0 then
                    local obj = {
                        bossId = bossConf[self.infiniteData.boss_level].fightId
                    }
                    BattleMgr:playBattle(BATTLE_TYPE.INFINITE_BATTLE_BOSS, obj, function()
                        MainSceneMgr:showMainCity(function()
                            CampaignMgr:showCampaignMain(4, chapterId)
                            InfiniteBattleMgr:showInfiniteBattleMain(chapterId, 2)
                        end)
                    end, nil, GAME_UI.UI_INFINITE_BATTLE_BOSS)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("SHAS_NOT_ENOUGH"), COLOR_TYPE.RED)
                end
            end
        end)
    end
end

return InfiniteBattleBossUI