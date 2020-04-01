local BattleHelper = require("script/app/ui/battle/battlehelper")

local BattleFailureUI = class("BattleFailureUI", BaseUI)

function BattleFailureUI:ctor(notFromBattlefield, damageInfo)
    self.uiIndex = GAME_UI.UI_BATTLE_FAILURE
    self.notFromBattlefield = notFromBattlefield
    self.damageInfo = damageInfo
    self.animationOver = false
end

function BattleFailureUI:init()
    local failureBgImg = self.root:getChildByName("failure_bg_img")
    local failureNode = failureBgImg:getChildByName("failure_node")
    self:adaptUI(failureBgImg, failureNode)

    local infoLabel = failureNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))
    -- 伤害统计
    local damageBtn = failureNode:getChildByName("damage_btn")
    local damageLabel = damageBtn:getChildByName("text")
    damageLabel:setString(GlobalApi:getLocalStr("STR_STATISTICS"))
    damageBtn:addClickEventListener(function ()
        if self.notFromBattlefield then
            BattleMgr:showBattleDamageCount(false, self.damageInfo)
        else
            BattleMgr:showBattleDamageCount()
        end
    end)

    local battlefailrecommendConf = GameData:getConfData("battlefailrecommend")
    self.strengthen_btns = {}
    for i = 1, 3 do
        local strengthen_btn = failureNode:getChildByName("strengthen_img_" .. i)
        local gotoModuleName
        local gotoModuleIndex
        -- -1表示改功能未开,0是不推荐,1是一般推荐,2是特别推荐,要显示推荐字样
        local status
        local recommendIndex = 1
        for k, v in ipairs(battlefailrecommendConf[i]) do
            status, gotoModuleName, gotoModuleIndex = self:checkRecommend(v.key)
            recommendIndex = k
            if status > 0 then
                break
            end
        end
        local name_tx = strengthen_btn:getChildByName("name_tx")
        name_tx:setString(battlefailrecommendConf[i][recommendIndex].title)
        local desc_tx = strengthen_btn:getChildByName("desc_tx")
        desc_tx:setTextAreaSize(cc.size(180,150))
        desc_tx:setString(battlefailrecommendConf[i][recommendIndex].desc)
        local content_img = strengthen_btn:getChildByName("content_img")
        content_img:ignoreContentAdaptWithSize(true)
        content_img:loadTexture("uires/ui/battleresult/" .. battlefailrecommendConf[i][recommendIndex].url)
        local recommend_img = strengthen_btn:getChildByName("recommend_img")
        if status == 2 then
            recommend_img:setVisible(true)
        else
            recommend_img:setVisible(false)
        end
        strengthen_btn:setScale(0)
        strengthen_btn:addClickEventListener(function ()
            if self.animationOver then
                if status >= 0 then
                    if self.notFromBattlefield then
                        MainSceneMgr:showMainCity(function ()
                            GlobalApi:getGotoByModule(gotoModuleName)
                        end, nil, gotoModuleIndex)
                    else
                        BattleMgr:exitBattleField(gotoModuleName, gotoModuleIndex)
                    end
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_OPEN_YET'), COLOR_TYPE.RED)
                end
            end
        end)
        self.strengthen_btns[i] = strengthen_btn
    end

    local title = failureNode:getChildByName("title")
    title:setPosition(cc.p(0, 600))
    title:runAction(cc.Sequence:create(cc.EaseBounceOut:create(cc.MoveTo:create(0.6, cc.p(0, 200))), cc.CallFunc:create(function ()
        self.animationOver = true
    end)))
    title:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function ()
        for i = 1, 3 do
            self.strengthen_btns[i]:runAction(cc.ScaleTo:create(0.1, 1))
        end
    end)))

    failureBgImg:addClickEventListener(function ()
        if self.animationOver then
            BattleMgr:hideFailure()
            if not self.notFromBattlefield then
                BattleMgr:exitBattleField()
            end
        end
    end)

    local lightImg = failureNode:getChildByName("light_img")
    lightImg:setScaleY(0)
    lightImg:runAction(cc.ScaleTo:create(0.1, 1))
    local particle = cc.ParticleSystemQuad:create("particle/failure_light.plist")
    local winSize = cc.Director:getInstance():getWinSize()
    particle:setPosition(cc.p(0, winSize.height/2))
    failureNode:addChild(particle)

    --战斗失败自动取消战斗托管
    BattleMgr:setTrust(false)
end

function BattleFailureUI:checkRecommend(checkKey)
    if checkKey == "levelUp" then
        return self:checkCanLevelUp()
    elseif checkKey == "tupo" then
        return self:checkCanTupo()
    elseif checkKey == "destiny" then
        return self:checkCanDestiny()
    elseif checkKey == "soldierLvUp" then
        return self:checkCanSoldierLvUp()
    elseif checkKey == "pub" then
        return self:checkFreePub()
    elseif checkKey == "guard" then
        return self:checkCanGuard()
    elseif checkKey == "goldmine" then
        return self:checkCanGoldmine()
    elseif checkKey == "shipper" then
        return self:checkCanShipper()
    elseif checkKey == "countryJade" then
        return self:checkCanCountryJade()
    elseif checkKey == "shop" then
        return self:checkBlackmarket()
    elseif checkKey == "altar" then
        return self:checkCanAltar()
    elseif checkKey == "rescopy" then
        return self:checkCanRescopy()
    elseif checkKey == "infinite" then
        return self:checkCanInfinite()
    elseif checkKey == "vip" then
        return self:checkCanVip() 
    end
end

-- 是否有可升级的武将
function BattleFailureUI:checkCanLevelUp()
    local itemdata = {}
    local itemdat = GameData:getConfData('item')
    for k,v in pairs(itemdat) do
        if tostring(v.useType) == 'xp' then
            table.insert(itemdata,v)
        end
    end
    local rolelvconf = GameData:getConfData('level')
    local canUpLv = false
    local roleLv = UserData:getUserObj():getLv()
    local roleMap = RoleData:getRoleMap()
    for k, v in pairs(roleMap) do
        if v:getId() > 0 then
            if v:getLevel() < roleLv then
                local oldlv = v:getLevel()
                local remainXp = rolelvconf[oldlv].roleExp - v:getXp()
                for i = 1,3 do
                    local materialobj = BagData:getMaterialById(itemdata[i].id)
                    if materialobj and materialobj:getNum() >= 1 then
                        local costExp = tonumber(materialobj.conf.useEffect)
                        local needMaxNum = 1
                        if remainXp <= costExp then
                            needMaxNum = 1
                        else
                            needMaxNum = math.ceil(remainXp/costExp)
                            if needMaxNum >= materialobj:getNum() then
                                needMaxNum = materialobj:getNum()
                            end
                        end
                        remainXp = remainXp - costExp*needMaxNum
                        if remainXp <= 0 then
                            break
                        end
                    end
                end
                if remainXp <= 0 then
                    canUpLv = true
                    break
                end
            end
        end
    end
    if canUpLv then
        return 2, "heroList", GAME_UI.UI_ROLELIST
    else
        return 0, "heroList", GAME_UI.UI_ROLELIST
    end
end

-- 是否有可突破的武将
function BattleFailureUI:checkCanTupo()
    local canTupo = false
    local roleMap = RoleData:getRoleMap()
    for k, v in pairs(roleMap) do
        if v:getId() > 0 then
            if v:isTupo() then
                canTupo = true
                break
            end
        end
    end
    if canTupo then
        return 2, "heroList", GAME_UI.UI_ROLELIST
    else
        return 0, "heroList", GAME_UI.UI_ROLELIST
    end
end

-- 是否有可升级天命的武将
function BattleFailureUI:checkCanDestiny()
    local destinyConf = GameData:getConfData('destiny')
    local maxDestiny = #destinyConf
    local canDestiny = false
    local roleMap = RoleData:getRoleMap()
    for k, v in pairs(roleMap) do
        if v:getId() > 0 then
            local fate = v:getDestiny()
            if fate.level < maxDestiny then
                local destinyObj = destinyConf[fate.level]
                local needFate = destinyObj['maxEnergy'] - fate.energy
                local award = DisplayData:getDisplayObj(destinyObj['cost'][1])
                local materialobj = BagData:getMaterialById(award:getId())
                if materialobj and materialobj:getNum() >= needFate then
                    canDestiny = true
                    break
                end
            end
        end
    end
    if canDestiny then
        return 2, "heroList", GAME_UI.UI_ROLELIST
    else
        return 0, "heroList", GAME_UI.UI_ROLELIST
    end
end

-- 有可穿戴的小兵装备
function BattleFailureUI:checkCanSoldierLvUp()
    local canEquipSoldierEquip = false
    local roleMap = RoleData:getRoleMap()
    for k, v in pairs(roleMap) do
        if v:getId() > 0 then
            if v:isSoldierCanLvUp() then
                canEquipSoldierEquip = true
                break
            end
        end
    end
    if canEquipSoldierEquip then
        return 2, "heroList", GAME_UI.UI_ROLELIST
    else
        return 0, "heroList", GAME_UI.UI_ROLELIST
    end
end

-- 酒馆有免费的招募次数
function BattleFailureUI:checkFreePub()
    local isOpen = GlobalApi:getOpenInfo('pub')
    if isOpen then
        local userObj = UserData:getUserObj()
        if userObj:getSignByType('tavern_free') or userObj:getSignByType('tavern_ten') or userObj:getSignByType('tavern_limit') then
            return 2, "pub", GAME_UI.UI_TAVERN
        else
            return 0, "pub", GAME_UI.UI_TAVERN
        end
    else
        return -1, "pub", GAME_UI.UI_TAVERN
    end
end

-- 可巡逻或可收获的城池 0:不显示 1:有可巡逻或可收获的城池 2:有可巡逻的城池同时有免费时间
function BattleFailureUI:checkCanGuard()
    return UserData:getUserObj():getGuardRecommendStatus(), "patrol", GAME_UI.UI_GUARDMAP
end

function BattleFailureUI:checkCanGoldmine()
    local isOpen = GlobalApi:getOpenInfo('goldmine')
    if isOpen then
        local canGoldmine = UserData:getUserObj():getSignByType('goldmine_count')
        if canGoldmine then
            return 1, "goldmine", GAME_UI.UI_GOLDMINE
        else
            return 0, "goldmine", GAME_UI.UI_GOLDMINE
        end
    else
        return -1, "goldmine", GAME_UI.UI_GOLDMINE
    end
end

function BattleFailureUI:checkCanShipper()
    local isOpen = GlobalApi:getOpenInfo('shipper')
    if isOpen then
        local shipper = UserData:getUserObj():getShipper()
        local num1 = tonumber(GlobalApi:getGlobalValue("shipperDeliveryCount")) - shipper.delivery
        local num2 = tonumber(GlobalApi:getGlobalValue("shipperRobCount")) - shipper.rob
        if num1 > 0 then
            return 2, "shipper", GAME_UI.UI_SHIPPERS
        elseif num2 > 0 then
            return 1, "shipper", GAME_UI.UI_SHIPPERS
        else
            return 0, "shipper", GAME_UI.UI_SHIPPERS
        end
    else
        return -1, "shipper", GAME_UI.UI_SHIPPERS
    end
end

function BattleFailureUI:checkCanCountryJade()
    local isOpen = GlobalApi:getOpenInfo('countryJade')
    if isOpen then
        if UserData:getUserObj():getSignByType("countryJade") then
            return 2, "country", GAME_UI.UI_COUNTRYMAIN
        else
            return 0, "country", GAME_UI.UI_COUNTRYMAIN
        end
    else
        return -1, "country", GAME_UI.UI_COUNTRYMAIN
    end
end

function BattleFailureUI:checkBlackmarket()
    local openLevel = tonumber(GlobalApi:getGlobalValue('marketOpenLevel'))
    local isShopOpen = GlobalApi:getOpenInfo('shop')
    if UserData:getUserObj():getLv() >= openLevel and isShopOpen then
        return 2, "shop", GAME_UI.UI_SHOPMAIN
    else
        return -1, "shop", GAME_UI.UI_SHOPMAIN
    end
end

function BattleFailureUI:checkCanAltar()
    local isOpen = GlobalApi:getOpenInfo("altar")
    if isOpen then
        local altarconf = GameData:getConfData('altar')
        local altar = UserData:getUserObj():getAltar()
        for i=1,4 do
            if UserData:getUserObj():getLv() >= altarconf[i].level then
                local count = 0
                if altar[tostring(i)] then
                    count = tonumber(altar[tostring(i)])
                end
                if count < altarconf[i].free then
                    if i == 2 then
                        return 2, "altar", GAME_UI.UI_ALTARMAINUI
                    else
                        return 1, "altar", GAME_UI.UI_ALTARMAINUI
                    end
                end
            end
        end
        return 0, "altar", GAME_UI.UI_ALTARMAINUI
    else
        return -1, "altar", GAME_UI.UI_ALTARMAINUI
    end
end

function BattleFailureUI:checkCanRescopy()
    local isOpen1 = GlobalApi:getOpenInfo("boat")
    local isOpen2 = GlobalApi:getOpenInfo("goldRescopy")
    local isOpen3 = GlobalApi:getOpenInfo("rebornRescopy")
    local isOpen4 = GlobalApi:getOpenInfo("xpRescopy")
    local isOpen5 = GlobalApi:getOpenInfo("destinyRescopy")
    if isOpen1 then
        if isOpen2 or isOpen3 or isOpen4 or isOpen5 then
            if UserData:getUserObj():getSignByType('rescopy') then
                return 2, "boat", GAME_UI.UI_CAMPAIGN
            else
                return 0, "boat", GAME_UI.UI_CAMPAIGN
            end
        else
            return -1, "boat", GAME_UI.UI_CAMPAIGN
        end
    else
        return -1, "boat", GAME_UI.UI_CAMPAIGN
    end
end

function BattleFailureUI:checkCanInfinite()
    local isOpen1 = GlobalApi:getOpenInfo("boat")
    local isOpen2 = GlobalApi:getOpenInfo("infinite")
    if isOpen1 and isOpen2 then
        if UserData:getUserObj():getUnlimitedShasShowStatus() then
            return 2, "infinite", GAME_UI.UI_CAMPAIGN
        else
            return 0, "infinite", GAME_UI.UI_CAMPAIGN
        end
    else
        return -1, "infinite", GAME_UI.UI_CAMPAIGN
    end
end

function BattleFailureUI:checkCanVip()
    local canBuyVIPGift = false
    local userVip = UserData:getUserObj():getVip()
    local paymentInfo = UserData:getUserObj():getPayment()
    local judge = 1
    for i = 0, userVip do
        if paymentInfo.vip_rewards[tostring(i)] == nil then
            canBuyVIPGift = true
            break
        end
    end
    if canBuyVIPGift then
        return 2, "cash", GAME_UI.UI_RECHARGE
    else
        return 0, "cash", GAME_UI.UI_RECHARGE
    end
end

return BattleFailureUI