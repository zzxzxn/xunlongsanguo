local ArenaUI = class("ArenaUI", BaseUI)

local TOP_SCALE = {0.8, 0.6, 0.6}
local TOP_POS = {cc.p(109,70), cc.p(77,50), cc.p(77,50)}

function ArenaUI:ctor()
    self.uiIndex = GAME_UI.UI_ARENA
    self.ui = {}
    self.successTimes = 0
    self.challengeTimes = 0
    self.buyTimes = 0   -- 购买次数
    self.buyCount = 0   -- 购买成功后得到的次数
    self.maxRank = 0
    self.currRank = 0
    self.top3 = {}
    self.enemy = {}
    self.challengeUid = {}
end

function ArenaUI:init()
    local arenaBgImg = self.root:getChildByName("arena_bg_img")
    local arenaAlphaImg = arenaBgImg:getChildByName("arena_alpha_img")
    local arenaImg = arenaAlphaImg:getChildByName("arena_img")
    self:adaptUI(arenaBgImg, arenaAlphaImg)

    local titleImg = arenaImg:getChildByName("title_bg")
    local titleLabel = titleImg:getChildByName("title_tx")
    titleLabel:setString(GlobalApi:getLocalStr("STR_ARENA"))
    local closeBtn = arenaImg:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        ArenaMgr:hideArena()
    end)

    local displayPl = arenaImg:getChildByName("display_pl")
    local displayImg = displayPl:getChildByName("display_img")
    self:initDisplayWidget(displayImg)

    local infoImg = arenaImg:getChildByName("info_img")
    self:initInfoWidget(infoImg)
    local sprite1 = infoImg:getChildByName("sprite_1")
    local label1 = sprite1:getChildByName("text")
    label1:setString(GlobalApi:getLocalStr("STR_RANK_1"))
    local sprite2 = infoImg:getChildByName("sprite_2")
    local label2 = sprite2:getChildByName("text")
    label2:setString(GlobalApi:getLocalStr("STR_HIGH"))

    local playerImg = arenaImg:getChildByName("player_img")
    self:initPlayerWidget(playerImg)

    MessageMgr:sendPost("get", "arena", "{}", function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            self.successTimes = jsonObj.data.succ
            self.challengeTimes = jsonObj.data.count
            self.buyCount = jsonObj.data.buy_count
            self.buyTimes = jsonObj.data.buy_num
            self.top3 = jsonObj.data.top3
            self.enemy = jsonObj.data.enemy
            self.maxRank = jsonObj.data.max_rank
            self.currRank = jsonObj.data.rank
            ArenaMgr.myRank = jsonObj.data.rank
            self:update()
        end
    end)
end

function ArenaUI:initDisplayWidget(displayImg)
    self.ui["pedestalImg1"] = displayImg:getChildByName("pedestal_img_1")
    self.ui["pedestalImg2"] = displayImg:getChildByName("pedestal_img_2")
    self.ui["pedestalImg3"] = displayImg:getChildByName("pedestal_img_3")
    self.ui["displayNameLabel1"] = displayImg:getChildByName("name_tx_1")
    self.ui["displayNameLabel2"] = displayImg:getChildByName("name_tx_2")
    self.ui["displayNameLabel3"] = displayImg:getChildByName("name_tx_3")
    local rankBtn = displayImg:getChildByName("rank_btn")
    local rankLabel = rankBtn:getChildByName("text")
    rankLabel:setString(GlobalApi:getLocalStr("STR_RANK_3"))
    rankBtn:addClickEventListener(function ()
        ArenaMgr:showArenaRank(1)
    end)
    local awardBtn = displayImg:getChildByName("award_btn")
    local awardLabel = awardBtn:getChildByName("text")
    awardLabel:setString(GlobalApi:getLocalStr("STR_AWARD1"))
    awardBtn:addClickEventListener(function ()
        ArenaMgr:showArenaRank(2)
    end)
end

function ArenaUI:updateDisplayWidget()
    local heroConf = GameData:getConfData("hero")
    for k, v in pairs(self.top3) do
        local pedestalImg = self.ui["pedestalImg" .. k]
        local name = heroConf[tonumber(v.hid)].url
        name = name == "NA" and "guanyu" or name
        local animation = GlobalApi:createLittleLossyAniByName(name..'_display')
        animation:getAnimation():play("idle", -1, 1)
        animation:setScale(TOP_SCALE[tonumber(k)])
        animation:setPosition(cc.pAdd(TOP_POS[tonumber(k)], cc.p(0, heroConf[tonumber(v.hid)].uiOffsetY)))
        local shadow = animation:getBone(name .. "_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
        --animation:removeChildByName(name .. "_shadow")
        pedestalImg:addChild(animation)
        self.ui["displayNameLabel" .. k]:setString(v.name)
    end
end

function ArenaUI:initInfoWidget(infoImg)
    local challengeTimesLabel = infoImg:getChildByName("challenge_times_tx")
    local exchangeBtn = infoImg:getChildByName("exchange_btn")
    local exchangeLabel = exchangeBtn:getChildByName("text")
    exchangeLabel:setString(GlobalApi:getLocalStr("STR_EXCHANGE"))
    exchangeBtn:addClickEventListener(function ()
        -- 军功商店
        MainSceneMgr:showShop(31,{min = 31,max = 32},self.maxRank)
    end)
    local addTimesBtn = infoImg:getChildByName("add_times_btn")
    addTimesBtn:addClickEventListener(function ()
        -- 购买挑战次数
        self:buyChallengeTimes()
    end)

    local reportBtn = infoImg:getChildByName("report_btn")
    local reportLabel = reportBtn:getChildByName("text")
    reportLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT"))
    reportBtn:addClickEventListener(function ()
        -- 竞技场战报
        ArenaMgr:showArenaRank(3)
    end)

    self.ui["currRankLabel"] = infoImg:getChildByName("curr_rank_tx")
    self.ui["maxRankLabel"] = infoImg:getChildByName("max_rank_tx")
    self.ui["fightforceLabel"] = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.ui["fightforceLabel"]:setPosition(cc.p(415, 170))
    self.ui["fightforceLabel"]:setAnchorPoint(cc.p(0, 0.5))
    self.ui["fightforceLabel"]:setScale(0.8)
    infoImg:addChild(self.ui["fightforceLabel"])
    local challengeTimesLabel = infoImg:getChildByName("challenge_tx")
    challengeTimesLabel:setString(GlobalApi:getLocalStr("ARENA_CHALLENGE_TODAY"))
    self.ui["challengeTimesLabel"] = challengeTimesLabel:getChildByName("times_tx")
    --self.ui["getHonorLabel"] = infoImg:getChildByName("get_honor_tx")

    local extraChallengeLabel = infoImg:getChildByName("extra_challenge_tx")
    extraChallengeLabel:setString(GlobalApi:getLocalStr("ARENA_EXTRA_CHALLENGE_SUCCESS"))
    self.ui["extraChallengeLabel"] = extraChallengeLabel:getChildByName("times_tx")
    local extraHonorLabel1 = infoImg:getChildByName("extra_honor_tx1")
    extraHonorLabel1:setString(GlobalApi:getLocalStr("STR_EXTRA_GET"))
    self.ui["extraHonorLabel2"] = infoImg:getChildByName("extra_honor_tx2")
    self.ui["extraHonorLabel3"] = infoImg:getChildByName("extra_honor_tx3")
    self.ui["extraHonorLabel3"]:setString(GlobalApi:getLocalStr("STR_HONOR"))
    local playerHonorLabel1 = infoImg:getChildByName("player_honor_tx1")
    playerHonorLabel1:setString(GlobalApi:getLocalStr("STR_MY_HONOR") .. "：")
    self.ui["playerHonorLabel2"] = infoImg:getChildByName("player_honor_tx2")
    self.ui["playerHonorLabel3"] = infoImg:getChildByName("player_honor_tx3")
end

function ArenaUI:updateInfoWidget()
    local arenaMaxCount = GlobalApi:getGlobalValue("arenaMaxCount")
    self.ui["currRankLabel"]:setString(tostring(self.currRank))
    self.ui["maxRankLabel"]:setString(tostring(self.maxRank))
    self.ui["fightforceLabel"]:setString(RoleData:getFightForce())
    self.ui["challengeTimesLabel"]:setString(tostring(arenaMaxCount-self.challengeTimes+self.buyCount))
    local arenarewardConf = GameData:getConfData("arenareward")
    local maxConfNum = #arenarewardConf
    local index = 1
    while index < maxConfNum do
        if self.successTimes < arenarewardConf[index].count then
            break
        end
        index = index + 1
    end
    self.ui["extraChallengeLabel"]:setString(tostring(arenarewardConf[index].count-self.successTimes))
    self.ui["extraHonorLabel2"]:setString(tostring(arenarewardConf[index].award))
    local x, y = self.ui["extraHonorLabel2"]:getPosition()
    local strlength = self.ui["extraHonorLabel2"]:getContentSize().width
    self.ui["extraHonorLabel3"]:setPosition(cc.p(x + strlength + 2, y))
    self.ui["playerHonorLabel2"]:setString(tostring(UserData:getUserObj():getArena()))
    local x2, y2 = self.ui["playerHonorLabel2"]:getPosition()
    local strlength2 = self.ui["playerHonorLabel2"]:getContentSize().width
    self.ui["playerHonorLabel3"]:setPosition(cc.p(x2 + strlength2 + 5, y2))
    self.ui["playerHonorLabel3"]:setString("+" .. GlobalApi:getGlobalValue("arenaAwardCount"))
end

function ArenaUI:initPlayerWidget(playerImg)
    local refreshBtn = playerImg:getChildByName("refresh_btn")
    local refreshLabel = refreshBtn:getChildByName("text")
    refreshLabel:setString(GlobalApi:getLocalStr("REFRESH"))
    refreshBtn:addClickEventListener(function ()
        MessageMgr:sendPost("refresh", "arena", "{}", function (jsonObj)
            print(json.encode(jsonObj))
            if jsonObj.code == 0 then
                self.enemy = jsonObj.data.enemy
                self:updatePlayerWidget()
            end
        end)
    end)

    self.ui["cardImg1"] = playerImg:getChildByName("card_img_1")
    self.ui["cardImg2"] = playerImg:getChildByName("card_img_2")
    self.ui["cardImg3"] = playerImg:getChildByName("card_img_3")

    for i = 1, 3 do
        local challengeImg = self.ui["cardImg" .. i]:getChildByName("challenge_img")
        challengeImg:addClickEventListener(function ()
            local challengeTimes = tonumber(self.ui["challengeTimesLabel"]:getString())
            -- 挑战
            if challengeTimes > 0 then
                self:challengeByIndex(i)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("CHALLENGE_NOT_ENOUGH"), COLOR_TYPE.RED)
            end
        end)

        local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
        fightforceLabel:setPosition(cc.p(50, 24))
        fightforceLabel:setScale(0.7)
        fightforceLabel:setName("fightforce_tx")
        self.ui["cardImg" .. i]:addChild(fightforceLabel)
    end
end

function ArenaUI:updatePlayerWidget()
    local heroConf = GameData:getConfData("hero")
    local index = 1
    local enemyArr = {}
    for k, v in pairs(self.enemy) do
        local obj = v
        obj.uid = tonumber(k)
        table.insert(enemyArr, obj)
    end
    table.sort(enemyArr, function (a, b)
        return a.rank < b.rank
    end)
    for k, v in pairs(enemyArr) do
        local quality = heroConf[tonumber(v.headpic)].quality
        local card = self.ui["cardImg" .. index]
        local headpicBg = card:getChildByName("headpic_bg")
        local icon = headpicBg:getChildByName("icon")
        local fightforceLabel = card:getChildByName("fightforce_tx")
        local nameLabel = card:getChildByName("name_tx")
        local rankLabel = card:getChildByName("rank_tx")
        fightforceLabel:setString(tostring(v.fight_force))
        nameLabel:setString(tostring(v.name))
        rankLabel:setString(string.format(GlobalApi:getLocalStr("ARENA_RANK"), v.rank))
        if tonumber(v.headpic) == 0 then
            icon:setTexture("uires/icon/hero/caocao_icon.png")
        else
            icon:setTexture("uires/icon/hero/" .. heroConf[tonumber(v.headpic)].heroIcon)
        end
        self.challengeUid[index] = v.uid
        index = index + 1
    end
end

function ArenaUI:update()
    self:updateDisplayWidget()
    self:updateInfoWidget()
    self:updatePlayerWidget()
end

function ArenaUI:challengeByIndex(index)
    local obj = {
        enemy = self.challengeUid[index]
    }
    MessageMgr:sendPost("challenge", "arena", json.encode(obj), function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            local customObj = {
                headpic = self.enemy[tostring(self.challengeUid[index])].headpic,
                challengeUid = self.challengeUid[index],
                info = jsonObj.data.info
            }
            BattleMgr:playBattle(BATTLE_TYPE.ARENA, customObj, function ()
                MainSceneMgr:showMainCity(function()
                    ArenaMgr:showArenaV2()
                end, nil, GAME_UI.UI_ARENA)
            end)
        end
    end)
end

function ArenaUI:buyChallengeTimes()
    local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local extraTimes = vipConf[tostring(vip)].arenaExtraChallenge
    if self.buyTimes >= extraTimes then -- 购买次数超过上限
        promptmgr:showSystenHint(GlobalApi:getLocalStr('BUY_TIMES_OVER'), COLOR_TYPE.RED)
        -- promptmgr:showSystenHint(GlobalApi:getLocalStr("BUY_TIMES_OVER"), COLOR_TYPE.RED)
    else
        local buyConf = GameData:getConfData("buy")
        local cost = buyConf[self.buyTimes+1].arenaExtraChallenge
        local cash = UserData:getUserObj():getCash()
        if cash < cost then -- 元宝不足
            promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
            -- promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
        else
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ARENA_BUY_CHALLENGE"), cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                MessageMgr:sendPost("buy_count", "arena", "{}", function (jsonObj)
                    print(json.encode(jsonObj))
                    if jsonObj.code == 0 then
                        self.buyCount = jsonObj.data.buy_count
                        self.buyTimes = jsonObj.data.buy_num
                        GlobalApi:parseAwardData(jsonObj.data.awards)
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self:updateInfoWidget()
                    end
                end)
            end)
        end
    end
end

return ArenaUI