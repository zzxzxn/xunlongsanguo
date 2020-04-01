local TerritorialWarsBossUI = class("TerritorialWarsBossUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local legionIconUrl = "uires/ui/legion/legion_"

function TerritorialWarsBossUI:ctor(bossforceCfg,indexParam,cellId,curLid,level,fightCount,legionIcon,legionName,isAround)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_BOSS
    self._bossforceCfg = bossforceCfg
    self._fightTimes = fightCount + 1       
    self.legionIcon = legionIcon
    self.legionName = legionName
    self.indexParam = indexParam
    self.cellId = cellId
    self.curLid = curLid
    self.bossLevel = level
    self.isAround = isAround
end

function TerritorialWarsBossUI:init()

    local scoreParam = GameData:getConfData("dfbasepara")["bossScoreAdd"].value[1]
    local maxNum = #self._bossforceCfg.battleId
    self.indexParam = (self.indexParam > maxNum or self.indexParam < 1) and 1 or self.indexParam
    local fomationConfig = GameData:getConfData("formation")[self._bossforceCfg.battleId[self.indexParam]]
    local monsterId = fomationConfig['pos'..fomationConfig.boss]
    local monsterConfig = GameData:getConfData("monster")[monsterId]
    local loopInfo = GameData:getConfData("drop")[self._bossforceCfg.lootId[self.indexParam]]
    self.loopReward ={}
    for i=1,#loopInfo.fixed do
        self.loopReward[#self.loopReward + 1] = loopInfo.fixed[i]
    end
    for i=1,10 do
        local award = loopInfo["award" .. i]
        if award[1] then
            self.loopReward[#self.loopReward + 1] = award[1]
        end
    end
    local dfbossCostCfg = GameData:getConfData("dfbosscost")
    if self._fightTimes > #dfbossCostCfg then
        self._fightTimes = #dfbossCostCfg
    end
    local fightCostCfg = dfbossCostCfg[self._fightTimes]
    local dfbaseCfg = GameData:getConfData("dfbasepara")

    local alphaBg = self.root:getChildByName("alpha_img")
    local bg = alphaBg:getChildByName("bg_img")
    self:adaptUI(alphaBg, bg)

    local neiBg = bg:getChildByName("nei_bg_img")
    self.leftImg = neiBg:getChildByName("left_bg_img")
    local nameTx = self.leftImg:getChildByName("name_tx")
    nameTx:setString(monsterConfig.heroName)

    --龙之印记积分加成
    local modeBg = self.leftImg:getChildByName("modebg_img")
    local longIcon = modeBg:getChildByName("long_icon")
    local longTx = longIcon:getChildByName("info_tx")
    local resCount = TerritorialWarMgr:getDragonResCount()
    self.addParam = scoreParam*resCount
    local addparaStr = self.addParam*100 .. "%"
    longTx:setString(addparaStr)
    local additionPos = modeBg:convertToWorldSpace(cc.p(longIcon:getPosition()))
    longIcon:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TipsMgr:showTerritorialwarBossTips(additionPos,resCount,scoreParam,"territorywarBoss")
        end
    end)
    

    --战斗力
    local zhanBgImg = self.leftImg:getChildByName('zhan_bg_img')
    local nameTx = self.leftImg:getChildByName('name_tx')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)
    self.forceLabel:setString(fomationConfig.fightforce)

    local rightPl = neiBg:getChildByName("right_pl")
    local topBg = rightPl:getChildByName("top_bg_img")
    local desc = topBg:getChildByName("desc_tx")
    desc:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT12") .. GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT36") .. "：")

    --军团图标,名字
    local legionIconImg = topBg:getChildByName("legion_icon")
    local legionNameTx = topBg:getChildByName("legion_name")
    if not self.legionName then
        legionIconImg:setVisible(false)
        legionNameTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT29"))
    else
        legionIconImg:setVisible(true)
        legionNameTx:setString(self.legionName)
        local color = (self.legionName == "军团名字最多") and COLOR_TYPE.RED or COLOR_TYPE.GREEN
        legionNameTx:setColor(color)
        legionIconImg:loadTexture(legionIconUrl .. self.legionIcon .. "_jun.png")
    end
    

    --掉落奖励
    local bottomBg = rightPl:getChildByName("bottom_bg_img")
    local headBg = bottomBg:getChildByName("title_bg_img")
    local headTx = headBg:getChildByName("info_tx")
    headTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_INFO9"))
    self.awardSv = bottomBg:getChildByName("award_sv")
    self.awardSv:setScrollBarEnabled(false)

    --挑战消耗
    local cost = math.abs(fightCostCfg.cost[1][3])
    local costTx = bottomBg:getChildByName("cost_info")
    costTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT14"))
    local cashInfo = bottomBg:getChildByName("cash_info")
    local cashdesc = cashInfo:getChildByName("cash_tx")
    cashdesc:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_MSG3"))
    local cashNum = cashInfo:getChildByName("cash_num")
    cashNum:setString(cost)
    local hasCash = UserData:getUserObj():getCash()
    local color = (hasCash >= cost) and COLOR_TYPE.GREEN or COLOR_TYPE.RED
    cashNum:setColor(color)
    local showfreeInfo = (cost == 0) and true or false
    costTx:setVisible(showfreeInfo)
    cashInfo:setVisible(not showfreeInfo)

    --是否在时间段
    local startHour,startMinute = string.match(dfbaseCfg["bossActivityTime"].value[1],"(%d+):(%d+)")
    local endHour,endMinute = string.match(dfbaseCfg["bossActivityTime"].value[2],"(%d+):(%d+)")
    local hour = os.date("%H", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
    local minute = os.date("%M", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
    local startTime,endTime,curTime = startHour*60+startMinute,endHour*60+endMinute,hour*60+minute
    local isOpenTime = (curTime >= startTime and curTime <endTime) and true or false
    if curTime < startTime or curTime > endTime or not self.isAround then
        costTx:setVisible(false)
        cashInfo:setVisible(false)
    end

    --窗口标题
    local titleImg = bg:getChildByName("title_img")
    local infotx = titleImg:getChildByName("info_tx")
    infotx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT13'))

    --按钮事件
    local hurtRankBtn = self.leftImg:getChildByName("hurtrank_btn")
    hurtRankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showDamageRankUI(self.curLid)
        end
    end)

    local belongBtn = topBg:getChildByName("belong_btn")
    belongBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showAwardBelongUI(2,self.bossLevel)
        end
    end)

    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:closeBossUI()
        end
    end)

    local fightBtn = bottomBg:getChildByName("fighting_btn")
    local btnTx = fightBtn:getChildByName("info_tx")
    local text = isOpenTime and GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT15") or GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT16")
    btnTx:setString(text)
    fightBtn:setTouchEnabled(isOpenTime)
    fightBtn:setBright(isOpenTime)
    local outlineColor = isOpenTime and COLOROUTLINE_TYPE.WHITE1 or COLOROUTLINE_TYPE.GRAY1
    btnTx:enableOutline(outlineColor,1)
    fightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callback()
                self:Fighting()
            end
            if cost == 0 then
                self:Fighting()
            else
                UserData:getUserObj():cost('cash',tonumber(cost),callback,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),tonumber(cost)))
            end
        end
    end)
    fightBtn:setVisible(self.isAround)
    self:getSpine(monsterConfig.url)
    self:updateAward()
end

function TerritorialWarsBossUI:Fighting()

     MessageMgr:sendPost('attack_boss','territorywar',json.encode({cellId  = self.cellId}),function (response)
        local code = response.code
        local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end 

        local customObj = {
            id = self._bossforceCfg.battleId[self.indexParam],
            cellId = self.cellId,
            radio = self._bossforceCfg.radio,
            addParam = self.addParam
        }
        BattleMgr:playBattle(BATTLE_TYPE.TERRITORALWAR_BOSS, customObj, function ()
            TerritorialWarMgr:showMapUI()
        end)
    end)
end

function TerritorialWarsBossUI:getSpine(url,y)
    y = y or 0
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display')
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
    spineAni:setPosition(cc.p(195,135 + y))
    self.leftImg:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function TerritorialWarsBossUI:updateAward()

    for i=1,#self.loopReward do

        local award = DisplayData:getDisplayObj(self.loopReward[i])
        local awardBgImg = self.awardSv:getChildByTag(1000 + i)
        if not awardBgImg then
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, self.awardSv)
            awardBgImg = tab.awardBgImg
            awardBgImg:setTag(1000 + i)
            awardBgImg:setAnchorPoint(cc.p(0,0.5))
            awardBgImg:setPosition(cc.p((i - 1)*110 + 10,50))
        end
        local lvTx = awardBgImg:getChildByName('lv_tx')
        awardBgImg:setTouchEnabled(true)
        local stype = award:getCategory()
        if stype == 'equip' then
            lvTx:setString('Lv.'..award:getLevel())
        else
            lvTx:setString('x'..award:getNum())
        end
        awardBgImg:setVisible(true)
        awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(award,false)
            end
        end)
        
    end

    local size = self.awardSv:getContentSize()
    if #self.loopReward * 110 + 10 > size.width then
        self.awardSv:setInnerContainerSize(cc.size(#self.loopReward* 110,size.height))
    else
        self.awardSv:setInnerContainerSize(size)
    end
end

return TerritorialWarsBossUI