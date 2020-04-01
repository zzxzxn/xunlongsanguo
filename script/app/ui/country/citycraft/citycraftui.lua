local CityCraftUI = class("CityCraftUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local posImgs = {
    "worldwar_feats_5_2.png",
    "worldwar_feats_5_1.png",
    "worldwar_feats_4_3.png",
    "worldwar_feats_4_2.png",
    "worldwar_feats_4_1.png",
    "worldwar_feats_3_3.png",
    "worldwar_feats_3_2.png",
    "worldwar_feats_3_1.png",
    "worldwar_feats_2_3.png",
    "worldwar_feats_2_2.png"
}

function CityCraftUI:ctor(flag)
    self.uiIndex = GAME_UI.UI_CITYCRAFT
    self.myPosition = 32
    self.challenge = 0
    self.buy = 0
    self.moveFlag = false
    self.actFlag = false
    self.showOffice = flag
    self.conf = GameData:getConfData("position")
end

function CityCraftUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local citycraftAlphaImg = self.root:getChildByName("citycraft_alpha_img")

    self:adaptUI(citycraftAlphaImg)
    local closeBtn = citycraftAlphaImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winsize.width, winsize.height))
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        CityCraftMgr:hideCityCraft()
        --更新皇城按钮mark
        if CountryMgr then
            CountryMgr:updateCountry()
        end
    end)

    local mapNode = citycraftAlphaImg:getChildByName("map_node")
    mapNode:setPosition(cc.p(winsize.width / 2, winsize.height / 2))
    self.mapNode = mapNode
    local map1 = mapNode:getChildByName("map_1")
    local map2 = mapNode:getChildByName("map_2")
    -- local size1 = map1:getContentSize()
    -- local size2 = map2:getContentSize()
    -- local limitLW = winsize.width - size1.width - size2.width
    -- local limitRW = 0
    -- local limitLH = winsize.height - size1.height
    -- local limitRH = 0
    -- local preMovePos = nil
    -- local movePos = nil
    -- local bgImgDiffPos = nil
    -- local bgImgPosX = 0
    -- local bgImgPosY = 0
    -- local beganPos = nil
    -- citycraftAlphaImg:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.moved then
    --         if self.actFlag then
    --             self.mapNode:stopAllActions()
    --             self.actFlag = false
    --             bgImgPosX, bgImgPosY = self.mapNode:getPosition()
    --         end
    --         preMovePos = movePos
    --         movePos = sender:getTouchMovePosition()
    --         if preMovePos then
    --             bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
    --             local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY + bgImgDiffPos.y)
    --             if targetPos.x > limitRW then
    --                 targetPos.x = limitRW
    --             end
    --             if targetPos.x < limitLW then
    --                 targetPos.x = limitLW
    --             end
    --             if targetPos.y < limitLH then
    --                 targetPos.y = limitLH
    --             end
    --             if targetPos.y > limitRH then
    --                 targetPos.y = limitRH
    --             end
    --             bgImgPosX = targetPos.x
    --             bgImgPosY = targetPos.y
    --             mapNode:setPosition(targetPos)
    --         end
    --         if not self.moveFlag then
    --             local dis = cc.pGetDistance(beganPos, movePos)
    --             if dis > 10 then
    --                 self.moveFlag = true
    --             end
    --         end
    --     elseif eventType == ccui.TouchEventType.began then
    --         preMovePos = nil
    --         movePos = nil
    --         beganPos = sender:getTouchBeganPosition()
    --     elseif eventType == ccui.TouchEventType.ended then
    --         self.moveFlag = false
    --     elseif eventType == ccui.TouchEventType.canceled then
    --         self.moveFlag = false
    --     end
    -- end)

    self.sv = mapNode:getChildByName("sv")

    self.sv:addTouchEventListener(function(sender, evenType)
        if evenType == ccui.TouchEventType.began then
            self:hideCityItem()
        end
    end)

    self.isShowPanelItem = false
    self.panelItem = mapNode:getChildByName("panelItem")
    self.panelItem:setVisible(false)

    self.panelBlack = self.sv:getChildByName("panelBlack")
    self.panelBlack:setVisible(false)

    local btBack = self.panelItem:getChildByName("btBack")
    btBack:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        self:hideCityItem()
    end)

    local cityDatas = {}
    for k,v in pairs(self.conf) do
        local idx = v.position + 1
        if cityDatas[idx] == nil then
            cityDatas[idx] = {}
        end
        local len = #cityDatas[idx]
        cityDatas[idx][len + 1] = v
    end


    self.cityButtons = {}
    for i = 1, 10 do
        local city = self.sv:getChildByName("city_" .. (i-1))
        self.cityButtons[i] = city

        local labelTitle = city:getChildByName("labelTitle")
        city.cityDatas = cityDatas[i]
        labelTitle:setString(GlobalApi:getVerticalText(city.cityDatas[1].posName))

        city:addClickEventListener(function ()
            AudioMgr.PlayAudio(11)
            self:showCityItem(city.cityDatas)
        end)
    end

    -- local cities = {}
    -- self.cityShake = false
    -- for i = 1, 32 do
    --     local city = mapNode:getChildByName("city_" .. i)
    --     local sprite = mapNode:getChildByName("sprite_" .. i)
    --     sprite:setLocalZOrder(2)
    --     local nameBg = mapNode:getChildByName("name_bg_" .. i)
    --     nameBg:setLocalZOrder(3)
    --     local posLabel = nameBg:getChildByName("pos_tx")
    --     local titleLabel = nameBg:getChildByName("title_tx")
    --     posLabel:setString(self.conf[i].posName)
    --     if i == 1 then
    --         titleLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    --     else
    --         titleLabel:setString(self.conf[i].title)
    --     end
    --     titleLabel:setAnchorPoint(cc.p(0,0.5))
    --     titleLabel:setPositionX(50)
    --     cities[i] = city
    --     city:setSwallowTouches(false)
    --     city:addClickEventListener(function ()
    --         if self.moveFlag or self.cityShake then
    --             return
    --         end
    --         AudioMgr.PlayAudio(11)
    --         self.cityShake = true
    --         sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.9), cc.EaseElasticOut:create(cc.ScaleTo:create(0.8, 1)), cc.CallFunc:create(function()
    --            CityCraftMgr:showCityCraftOffice(self.myPosition, i)
    --            self.cityShake = false
    --         end)))
    --     end)
    -- end

    local arrowImg = self.sv:getChildByName("arrow_img")
    arrowImg:setLocalZOrder(40)
    arrowImg:setScale(0.8)

    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headCell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
    headCell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    headCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
    headCell.awardBgImg:setPosition(cc.p(20, 80))
    arrowImg:addChild(headCell.awardBgImg)

    local infoNode = mapNode:getChildByName("info_node")
    local reportBtn = mapNode:getChildByName("report_btn")
    -- 添加战报按钮提醒mark
    if not self.mark then
        local mark = ccui.ImageView:create('uires/ui/common/new_img.png')
        reportBtn:addChild(mark)
        mark:setPosition(cc.p(88, 88))

        self.mark = mark
    end
    self.mark:setVisible(UserData:getUserObj():getSignByType('country_fight_report'))
    reportBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        MessageMgr:sendPost("get_report","country", "{}", function (response)
            if response.code == 0 then
                CityCraftMgr:showCityCraftReport(response.data.reports)
                UserData:getUserObj().tips.country_report = nil
                self.mark:setVisible(UserData:getUserObj():getSignByType('country_fight_report'))
            end
        end)
    end)

    local rankBtn = mapNode:getChildByName("rank_btn")
    rankBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        RankingListMgr:showRankingListMain(4,1)
    end)
    local shopBtn = mapNode:getChildByName("shop_btn")
    shopBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        local positionConf = GameData:getConfData('position')[self.myPosition]
        MainSceneMgr:showShop(71,{min = 71,max = 72},positionConf.position)
    end)

    local salaryTime = GlobalApi:getGlobalValue("countrySalaryTime")
    local tab = string.split(salaryTime, '-')

    local panelMsg = infoNode:getChildByName("panelMsg")
    local labelRewardTip = panelMsg:getChildByName("labelRewardTip")
    labelRewardTip:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT17")..GlobalApi:getGlobalValue("countryBalanceTime")..':00'..GlobalApi:getLocalStr("STR_OFFICE_DESC_3"))

    self.imgIcon = panelMsg:getChildByName("imgIcon")
    self.labelPosName = panelMsg:getChildByName("labelPosName")
    self.labelTitle = panelMsg:getChildByName("labelTitle")

    local labelLuluTimeTitle = panelMsg:getChildByName("labelLuluTimeTitle")
    labelLuluTimeTitle:setString(GlobalApi:getLocalStr("STR_OFFICE_DESC_1")..":")
    local labelLuluTime = panelMsg:getChildByName("labelLuluTime")
    labelLuluTime:setString(tab[1]..':00-'..tab[2]..':00')
    local labelLuluGetTitle = panelMsg:getChildByName("labelLuluGetTitle")
    labelLuluGetTitle:setString(GlobalApi:getLocalStr("STR_OFFICE_GOT")..":")
    self.labelLuluGet = panelMsg:getChildByName("labelLuluGet")
    self.labelLastTimes = panelMsg:getChildByName("labelLastTimes")
    local labelTodayGetTitle = panelMsg:getChildByName("labelTodayGetTitle")
    labelTodayGetTitle:setString(GlobalApi:getLocalStr("STR_OFFICE_TODAY_GOT")..":")
    self.labelTodayGet = panelMsg:getChildByName("labelTodayGet")

    local spLuluIcon_1 = panelMsg:getChildByName("spLuluIcon_1")
    spLuluIcon_1:setPositionX(labelTodayGetTitle:getPositionX() + labelTodayGetTitle:getContentSize().width)
    self.labelTodayGet:setPositionX(spLuluIcon_1:getPositionX() + spLuluIcon_1:getContentSize().width)

    local maxChallengeTimes = GlobalApi:getGlobalValue("countryChallengeLimit")
    local addBtn = panelMsg:getChildByName("btAdd")
    self.addBtn = addBtn
    addBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        if self.cityShake then
            return
        end
        if self.buy == self.challenge then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("CHALLENGE_TIMES_FULL"), COLOR_TYPE.RED)
        else
            local vip = UserData:getUserObj():getVip()
            local maxBuy = GameData:getConfData("vip")[tostring(vip)].citycraftChallenge
            if self.buy >= maxBuy then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("TIMES_OVER_NEED_UPGRADE_VIP"), COLOR_TYPE.RED)
            else
                local buyConf = GameData:getConfData("buy")
                local needCash = 0
                if buyConf[self.buy + 1] then
                    needCash = buyConf[self.buy + 1].countryChallenge
                else
                    needCash = buyConf[#buyConf].countryChallenge
                end
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), needCash, maxBuy - self.buy), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    local currCash = UserData:getUserObj():getCash()
                    if currCash < needCash then -- 元宝不足
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
                    else
                        MessageMgr:sendPost("buy", "country", "{}", function (response)
                            if response.code == 0 then
                                self.buy = self.buy + 1
                                CityCraftMgr.challengeTimes = maxChallengeTimes + self.buy - self.challenge
                                GlobalApi:parseAwardData(response.data.costs)
                                self:updateInfo()
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN)
                            end
                        end)
                    end
                end)
            end
        end
    end)

    MessageMgr:sendPost("get_city","country", "{}", function (response)
        if response.code == 0 then
            self.myPosition = response.data.position
            local cityData = self.conf[self.myPosition]

            self.buy = response.data.buy
            self.challenge = response.data.challenge
            self.salary = response.data.salary
            UserData:getUserObj():setCountryCount(response.data.challenge)
            CityCraftMgr.challengeTimes = maxChallengeTimes + self.buy - self.challenge

            local offsetY = 120
            if cityData.position == 9 or cityData.position == 6 then
                offsetY = 80
            end

            local curCityButton = self.cityButtons[cityData.position + 1]
            local posx, posy = curCityButton:getPosition()
            arrowImg:setVisible(true)
            arrowImg:setPosition(cc.p(posx, posy + offsetY))
            arrowImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.MoveBy:create(0.5, cc.p(0, -10)))))
            self:updateInfo()
            if self.showOffice then
                CityCraftMgr:showCityCraftOffice(self.myPosition, self.myPosition)
            end
            GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.CITYCRAFT)

            local innerPosY = -posy + 250
            if innerPosY < -1600 + 768 then
                innerPosY = -1600 + 768
            elseif innerPosY > 0 then
                innerPosY = 0
            end
            self.sv:getInnerContainer():runAction(cc.MoveTo:create(0.5, cc.p(0, innerPosY)))
        end
    end)

    self.sv:getInnerContainer():setPositionY(0)

    local sprite1 = self.mapNode:getChildByName('sprite_1')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.CITY_CRAFT)
    -- btn:setScale(0.7)
    btn:setPosition(cc.p(sprite1:getContentSize().width ,sprite1:getContentSize().height / 2))
    sprite1:addChild(btn)
end

function CityCraftUI:updateInfo()
    self.labelTitle:setTextColor(COLOR_QUALITY[self.conf[self.myPosition].quality])
    self.labelTitle:setString(self.conf[self.myPosition].title)
    if self.myPosition == 1 then
        self.labelPosName:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    else
        self.labelPosName:setString(self.conf[self.myPosition].posName)
    end
    self.imgIcon:loadTexture("uires/ui/worldwar/" .. posImgs[self.conf[self.myPosition].position + 1])
    self.labelLuluGet:setString(self.conf[self.myPosition].salary .. "/" .. GlobalApi:getLocalStr("STR_HOUR"))
    self.labelTodayGet:setString(GlobalApi:toWordsNumber(self.salary))
    local maxChallengeTimes = GlobalApi:getGlobalValue("countryChallengeLimit")
    self.labelLastTimes:setString(GlobalApi:getLocalStr("STR_OFFICE_FREE_TIMES").." " .. CityCraftMgr.challengeTimes .. "/" .. maxChallengeTimes)

    self.addBtn:setPositionX(self.labelLastTimes:getPositionX() + self.labelLastTimes:getContentSize().width + self.addBtn:getContentSize().width / 2 + 4)
end

function CityCraftUI:showCityItem(cityDatas)
    if self.isShowPanelItem then
        self:hideCityItem()
        return
    end

    local labelTitle = self.panelItem:getChildByName("labelTitle")
    labelTitle:setString(cityDatas[1].posName)

    for i = 1, 4 do
        local btItem = self.panelItem:getChildByName("btItem_"..(i-1))
        if i > #cityDatas then
            btItem:setVisible(false)
        else
            btItem:setVisible(true)
            local labelName = btItem:getChildByName("labelName")
            labelName:setString(cityDatas[i].title)

            btItem:addClickEventListener(function ()
                AudioMgr.PlayAudio(11)
                CityCraftMgr:showCityCraftOffice(self.myPosition, cityDatas[i].id)
            end)
        end
    end


    self.panelItem:stopAllActions()
    self.panelBlack:stopAllActions()

    self.isShowPanelItem = true
    self.panelItem:setVisible(true)
    self.panelBlack:setVisible(true)

    self.panelBlack:runAction(cc.Sequence:create(cc.FadeIn:create(0.2), cc.CallFunc:create(function()
        
    end)))

    self.panelItem:setScale(0)
    self.panelItem:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 1.0)), cc.CallFunc:create(function()
        
    end)))
end

function CityCraftUI:hideCityItem()
    if self.isShowPanelItem then
        self.panelItem:stopAllActions()
        self.panelBlack:stopAllActions()

        self.panelBlack:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            self.panelBlack:setVisible(false)
        end)))

        self.panelItem:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.2, 0)), cc.CallFunc:create(function()
            self.panelItem:setVisible(false)
        end)))

        self.isShowPanelItem = false
    end
end

return CityCraftUI
