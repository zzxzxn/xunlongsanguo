local LegionCityUpgradeUI = class("LegionCityUpgradeUI", BaseUI)

local ClassLegionBuildingUpgradeUI = require('script/app/ui/legion/legioncity/legionBuildingUpgrade')

function LegionCityUpgradeUI:ctor()
  self.uiIndex = GAME_UI.UI_LEGIONCITYUPGRADEUI
  self.curSelect = 1
end

function LegionCityUpgradeUI:onShow()
    self:refreshCityInfo(self.curSelect)
    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[self.curSelect]
    UIManager:showSidebar({1}, cityInfo.costType,true)
    self:refreshNewImgs()
end

function LegionCityUpgradeUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img_1')
    self:adaptUI(bgimg, bgimg1)

    local closebtn = bgimg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionCityUpgradeUI()
        end
    end)

    local winsize = cc.Director:getInstance():getWinSize()
    closebtn:setPositionX(winsize.width - closebtn:getContentSize().width/2)
    closebtn:setPositionY(winsize.height - closebtn:getContentSize().height/2)

    self.tabArr = {}
    local tab_pl = bgimg:getChildByName('tab_pl');
    local tabSize = tab_pl:getContentSize()
    tab_pl:setContentSize(cc.size(tabSize.width, winsize.height))
    tab_pl:setPositionY(winsize.height/2)
    tab_pl:setPositionX(0)

    local btnPosY = {80, 60, 40, 20}
    for i = 1, 4 do
        self.tabArr[i] = tab_pl:getChildByName('tab_' .. i)
        self.tabArr[i].func_tx = self.tabArr[i]:getChildByName('func_tx')
        self.tabArr[i].newImg = self.tabArr[i]:getChildByName('new_img')
        self.tabArr[i].newImg:setVisible(false)
        self.tabArr[i]:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:switchTab(i)
            end
        end)

        self.tabArr[i]:setPositionY(tabSize.height * btnPosY[i]/100)
    end

   local  helpBtn = tab_pl:getChildByName('help_btn');
   helpBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(HELP_SHOW_TYPE.LEGION_CITY_UPGRADE)
        end
   end)

    self:refreshTabText()

    local cityInfoPl = bgimg1:getChildByName('city_info_pl')
    self.cityInfoPl = cityInfoPl
    self.effectArr = {}
    for i = 1, 4 do
        self.effectArr[i] = {}
        self.effectArr[i].bg = cityInfoPl:getChildByName('effect_' .. i)
        self.effectArr[i].effect_name = self.effectArr[i].bg:getChildByName('effect_name_tx')
        self.effectArr[i].icon = self.effectArr[i].bg:getChildByName('icon_img')
        self.effectArr[i].effect_desc = self.effectArr[i].bg:getChildByName('effect_desc_tx')
        self.effectArr[i].value1 = self.effectArr[i].bg:getChildByName('value_1')
        self.effectArr[i].value2 = self.effectArr[i].bg:getChildByName('value_2')
        self.effectArr[i].state = self.effectArr[i].bg:getChildByName('state_img')
        self.effectArr[i].arrow = self.effectArr[i].bg:getChildByName('arrow_img')
    end
    self.selImg = ccui.ImageView:create("uires/ui/common/equiplight.png")
    self.selImg:setVisible(false)
    self.selImg:setScale9Enabled(true)
    self.selImg:setContentSize(cc.size(250, 350))
    cityInfoPl:addChild(self.selImg)

    self.arardArr = {}
    self.progress = {}
    for i = 1, 2 do 
        self.arardArr[i] = {}
        self.arardArr[i].bg = cityInfoPl:getChildByName('award_' .. i)
        self.arardArr[i].icon = self.arardArr[i].bg:getChildByName('icon')
        self.arardArr[i].num = self.arardArr[i].bg:getChildByName('num_tx')

        local sprite = cc.Sprite:create('uires/ui/legion/cityUpgrade/cityUpgrade_mask.png')
        self.progress[i] = cc.ProgressTimer:create(sprite)
        self.progress[i] :setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        self.progress[i] :setAnchorPoint(cc.p(0, 0))
        self.arardArr[i].bg:addChild(self.progress[i])
        self.progress[i] :setPercentage(0)
    end

    self.cityInfoArr = {}
    for i = 1, 2 do
        self.cityInfoArr[i] = {}
        self.cityInfoArr[i].bg = cityInfoPl:getChildByName('city_info_' .. i)
        self.cityInfoArr[i].icon = self.cityInfoArr[i].bg:getChildByName('city_icon_img')
        self.cityInfoArr[i].title = self.cityInfoArr[i].bg:getChildByName('title_tx')
    end

    self.cityProgressBg = cityInfoPl:getChildByName('city_progress_bg')
    self.cityProgress = self.cityProgressBg:getChildByName('city_progress')
    self.cityProgressTx = self.cityProgressBg:getChildByName('progress_tx')

    self.getAwardBtn = cityInfoPl:getChildByName('get_award_btn')
    self.getAwardBtnTx = self.getAwardBtn:getChildByName('func_tx')
    self.getAwardBtnTx:setString(GlobalApi:getLocalStr("GET_HERO"))

    self:switchTab(self.curSelect)
    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[self.curSelect]
    UIManager:showSidebar({1}, cityInfo.costType,true)

    self.buildingUpgradeAnis = {}
    self:addCustomEventListener(CUSTOM_EVENT.LEGION_BUILDING_UPGRADE, function (buildingIndex)
        local cardIndex = (buildingIndex - 1)%4 + 1
        local ani = self:getBuildingUpgradeAnimation()
        ani:setScale(1.8)
        ani:setPosition(cc.p(self.effectArr[cardIndex].bg:getPosition()))
        ani:getAnimation():playWithIndex(0, -1, 0)
        if cardIndex == 4 then
            local cityLevel = UserData:getUserObj():getLegionCityMainLevel()
            if cityLevel > 1 then
                local cityMainConf = GameData:getConfData('legioncitymain')
                local totalLevel = UserData:getUserObj():getLegionCityTotalLevel()
                local totalMaxLevel = tonumber(cityMainConf[cityLevel - 1].condition)
                if totalLevel == totalMaxLevel then
                    local ani2 = self:getBuildingUpgradeAnimation()
                    ani2:setScale(1)
                    ani2:setPosition(cc.p(self.cityInfoArr[1].bg:getPosition()))
                    ani2:getAnimation():playWithIndex(0, -1, 0)
                    if cityMainConf[cityLevel + 1] then
                        local ani3 = self:getBuildingUpgradeAnimation()
                        ani3:setScale(1)
                        ani3:setPosition(cc.p(self.cityInfoArr[2].bg:getPosition()))
                        ani3:getAnimation():playWithIndex(0, -1, 0)
                    end
                    self:bolckClick()
                    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
                        self:unbolckClick()
                        LegionMgr:showLegionCityUpgradeEffectUI(cityLevel)
                    end)))
                end
            end
        end
    end)
    self.bolckImg = ccui.ImageView:create("uires/ui/common/bg1_alpha.png")
    self.bolckImg:setLocalZOrder(999)
    self.bolckImg:setVisible(false)
    self.bolckImg:setTouchEnabled(true)
    self.bolckImg:setScale9Enabled(true)
    self.bolckImg:setContentSize(winsize)
    self.bolckImg:setPosition(cc.p(winsize.width/2, winsize.height/2))
    self.root:addChild(self.bolckImg)
    self:refreshNewImgs()
end

function LegionCityUpgradeUI:bolckClick()
    self.bolckImg:setVisible(true)
end

function LegionCityUpgradeUI:unbolckClick()
    self.bolckImg:setVisible(false)
end

function LegionCityUpgradeUI:getBuildingUpgradeAnimation()
    local ani = nil
    if #self.buildingUpgradeAnis > 0 then
        ani = table.remove(self.buildingUpgradeAnis)
        ani:setVisible(true)
    else
        ani = GlobalApi:createLittleLossyAniByName("ui_city_upgrade")
        self.cityInfoPl:addChild(ani)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:setVisible(false)
                table.insert(self.buildingUpgradeAnis, ani)
            end
        end)
    end
    return ani
end

function LegionCityUpgradeUI:refreshNewImgs()
    -- self.curSelect i 
    -- local buildId = (index - 1) * 4 + i
    -- local buildLevel = UserData:getUserObj():getLegionCityBuildingLevel(buildId)
    local cityConf = GameData:getConfData('legioncitybase')
    for i = 1, 4 do
        local isShow = false
        for j=1,4 do
            local buildId = (i - 1) * 4 + j
            local buildLevel = UserData:getUserObj():getLegionCityBuildingLevel(buildId)
            local newUI = ClassLegionBuildingUpgradeUI.new(i,j,buildId,buildLevel)
            isShow = newUI:canUpgrade() or isShow
        end
        self.tabArr[i].newImg:setVisible(isShow)
    end
end

function LegionCityUpgradeUI:refreshTabText()
    local cityConf = GameData:getConfData('legioncitybase')
    for i = 1, 4 do
        self.tabArr[i].func_tx:setString(cityConf[i].typeName)
    end
end
    
function LegionCityUpgradeUI:switchTab(index)
    for i = 1, 4 do
        if i == index then
            self.tabArr[i]:loadTextureNormal('uires/ui/common/common_btn_13.png')
            self.tabArr[i]:setTouchEnabled(false)
        else 
            self.tabArr[i]:loadTextureNormal('uires/ui/common/common_btn_9.png')
            self.tabArr[i]:setTouchEnabled(true)
        end
    end

    self.curSelect = index
    self:refreshCityInfo(self.curSelect)
end

function LegionCityUpgradeUI:refreshAwards(index)
    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[index]
    local heroConf = GameData:getConfData('hero')

    local hasAward = false

    --刷新产出
    local curTime = GlobalData:getServerTime()
    local awards = cityInfo.award
    for i = 1, 2 do
        local awardId = tonumber(awards[i][2])
        local awardNum = UserData:getUserObj():getLegionCityAwardNum(awardId)
        local heroData = heroConf[awardId];
        self.arardArr[i].bg:loadTexture(COLOR_FRAME[heroData.quality])
        self.arardArr[i].icon:loadTexture('uires/icon/hero/' .. heroData.heroIcon)
        self.arardArr[i].num:setString(awardNum)

        self.arardArr[i].bg:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local tempRole = RoleData:getRoleInfoById(awardId)
                --GetWayMgr:showGetwayUI(tempRole,true)	
                LegionMgr:showLegionSuiPianUI(tempRole,self.curSelect)
            end
        end)

        local interval,maxNum = self:getAwardInterval(index)
        if awardNum >= maxNum then
            self.progress[i]:setVisible(false)
        else
            self.progress[i]:setVisible(true)
        end

        if awardNum > 0 then
            hasAward = true
        end

        local remainTime = curTime - UserData:getUserObj():getLegionCityAwardTime(awardId)
        local initPercent = remainTime/(interval * 3600) * 100
        self.progress[i] :setPercentage(initPercent)
        self.progress[i]:runAction(cc.Sequence:create(cc.ProgressTo:create(remainTime, 0),cc.CallFunc:create(function()
            
        end)))
    end

    if hasAward then
        ShaderMgr:restoreWidgetDefaultShader(self.getAwardBtn)
        self.getAwardBtn:setTouchEnabled(true)
        self.getAwardBtnTx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
    else
        ShaderMgr:setGrayForWidget(self.getAwardBtn)
        self.getAwardBtn:setTouchEnabled(false)
        self.getAwardBtnTx:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
    end
end

function LegionCityUpgradeUI:getAwardInterval(index)
    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[index]

    local buildingId = 0
    if index == 1 then
        buildingId = 4
    elseif index == 2 then
        buildingId = 8
    elseif index == 3 then
        buildingId = 12
    elseif index == 4 then
        buildingId = 16
    end

    local buildingLevel = UserData:getUserObj():getLegionCityBuildingLevel(buildingId)
    local buildConf = GameData:getConfData('legioncityconf')
    local buildInfo = buildConf[buildingId][buildingLevel]
    if buildInfo == nil then
        return 0,0
    end
    return buildInfo.value[1],buildInfo.value[2]
end

-- 刷新城池信息
function LegionCityUpgradeUI:refreshCityInfo(index)
    local cityConf = GameData:getConfData('legioncitybase')
    local functionConf = GameData:getConfData('legioncityfunction')
    local buildingConf = GameData:getConfData('legioncityconf')
    local heroConf = GameData:getConfData('hero')
    local cityMainConf = GameData:getConfData('legioncitymain')
    local cityInfo = cityConf[index]

    --刷新产出
    self:refreshAwards(index)

    -- 刷新主城升级信息
    local cityLevel = UserData:getUserObj():getLegionCityMainLevel()
    local totalLevel = UserData:getUserObj():getLegionCityTotalLevel()
    
    local curCityData = cityMainConf[cityLevel]

    local cityNextLevel = cityLevel + 1
    local nextCityData = cityMainConf[cityNextLevel]
    if nextCityData == nil then
        nextCityData = curCityData
        cityNextLevel = cityLevel
    end

    local cityMaxLevel = #cityMainConf
    local totalMaxLevel = tonumber(GameData:getConfData('legioncitymain')[cityLevel].condition)
    self.cityProgress:setPercent(totalLevel/totalMaxLevel * 100)
    self.cityProgressTx:setString(totalLevel .. '/' .. totalMaxLevel)

    self.cityInfoArr[1].icon:loadTexture('uires/ui/citycraft/' .. curCityData.url)
    self.cityInfoArr[1].title:setString(GlobalApi:getLocalStr('STR_MAIN_CITY') .. ' Lv.' .. cityLevel)

    if cityNextLevel == cityLevel then
        -- 到顶级了
        self.cityInfoArr[2].bg:setVisible(false)
        self.cityProgressBg:setVisible(false)
        self.cityInfoArr[1].bg:setPositionX(250)
    else
        self.cityInfoArr[1].bg:setPositionX(117)
        self.cityInfoArr[2].bg:setVisible(true)
        self.cityProgressBg:setVisible(true)
        self.cityInfoArr[2].icon:loadTexture('uires/ui/citycraft/' .. nextCityData.url)
        self.cityInfoArr[2].title:setString(GlobalApi:getLocalStr('STR_MAIN_CITY') .. ' Lv.' .. cityNextLevel)
    end

    self.getAwardBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:getAwards(index)
        end
    end)

    for i = 1, 4 do
        local buildId = (index - 1) * 4 + i

        local buildLevel = UserData:getUserObj():getLegionCityBuildingLevel(buildId)
        local curBuildInfo = buildingConf[buildId][buildLevel]

        local nextBuildLevel = buildLevel + 1
        local nextBuildInfo = buildingConf[buildId][nextBuildLevel]
        if nextBuildInfo == nil then
            nextBuildInfo = curBuildInfo
            nextBuildLevel = buildLevel
        end

        local curValue = 0
        if curBuildInfo then
            curValue = curBuildInfo.value[1] 
        end

        self.effectArr[i].effect_name:setString(cityInfo['buildName' .. i] .. ' Lv.' .. buildLevel)

        local funcInfo = functionConf[cityInfo['buildFunction' .. i]]
        self.effectArr[i].effect_desc:setString(funcInfo.desc1[1])

        self.effectArr[i].icon:loadTexture('uires/ui/legion/cityUpgrade/' .. cityInfo['buildUrl' .. i] .. '.png')

        if curValue == 0 then
            self.effectArr[i].value1:setString("0")
        else
            self.effectArr[i].value1:setString(string.format(funcInfo.desc2[1], curValue) .. funcInfo.desc3)
        end

        if nextBuildLevel == buildLevel then
            self.effectArr[i].value2:setVisible(false)
            self.effectArr[i].arrow:setVisible(false)
            self.effectArr[i].value1:setPositionX(104)
        else
            self.effectArr[i].value2:setVisible(true)
            self.effectArr[i].arrow:setVisible(true)
            self.effectArr[i].value1:setPositionX(59)
            self.effectArr[i].value2:setString(string.format(funcInfo.desc2[1], nextBuildInfo.value[1]) .. funcInfo.desc3)
        end
        

        self.effectArr[i].bg:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                self.selImg:setVisible(true)
                self.selImg:setPosition(cc.p(self.effectArr[i].bg:getPosition()))
            elseif eventType == ccui.TouchEventType.ended then
                self.selImg:setVisible(false)
                if buildLevel < cityMaxLevel then
                    self:openUpgradeUI(index, i, buildId, buildLevel)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("BUILDING_ALREADY_MAX_LEVEL"), COLOR_TYPE.GREEN)
                end
            elseif eventType == ccui.TouchEventType.canceled then
                self.selImg:setVisible(false)
            end
        end)

        if buildLevel == 0 then
            self.effectArr[i].state:loadTexture('uires/ui/legion/cityUpgrade/cityUpgrade_build_normal.png')
        else
            self.effectArr[i].state:loadTexture('uires/ui/legion/cityUpgrade/cityUpgrade_upgrade_normal.png')
        end

        self.effectArr[i].state:setVisible(self:canUpgrade(buildId, buildLevel))
    end

    UIManager:showSidebar({1}, cityInfo.costType,false)
end

function LegionCityUpgradeUI:canUpgrade(buildingId, buildingLevel)
    -- 检查主城等级
    local mainCityLevel = UserData:getUserObj():getLegionCityMainLevel()

    local buildingConf = GameData:getConfData('legioncityconf')
    local nextBuildInfo = buildingConf[buildingId][buildingLevel + 1]
    if nextBuildInfo == nil then
        return false
    end

    if mainCityLevel < nextBuildInfo.condition1 then
        return false;
    end

    -- 检查建筑等级
    local needBuildings = nextBuildInfo.needBuild
    local needLevel = nextBuildInfo.needLevel
    for k, v in pairs(needBuildings) do
        local curLevel = UserData:getUserObj():getLegionCityBuildingLevel(v)
        if curLevel < needLevel then
            return false
        end
    end

    -- 检查消耗
    local costs = nextBuildInfo.cost
    for i = 1, #costs do
        local mineType = 0
        if costs[i][2] == 'mine_1' then
            mineType = 1
        elseif costs[i][2] == 'mine_2' then
            mineType = 2
        elseif costs[i][2] == 'mine_3' then
            mineType = 3
        elseif costs[i][2] == 'mine_4' then
            mineType = 4
        elseif costs[i][2] == 'mine_5' then
            mineType = 5
        end
        local has = UserData:getUserObj():getMine(mineType)
        local need = math.abs(costs[i][3])
        if has < need then
            return false
        end
    end

    return true
end

-- -- 建造
-- function LegionCityUpgradeUI:openBuildUI(cityType, cityIndex, buildId)
--     self:openUpgradeUI(cityType, cityIndex, buildId, 0)
-- end

-- -- 升级
-- function LegionCityUpgradeUI:openUpgradeUI(cityType, cityIndex, buildId, bulildLevel)
--     self:openUpgradeUI(buildId, bulildLevel)
-- end

function LegionCityUpgradeUI:openUpgradeUI(cityType, cityIndex, buildId, bulildLevel)
    local newUI = ClassLegionBuildingUpgradeUI.new(cityType, cityIndex, buildId, bulildLevel)
    newUI:showUI()
end

-- 领取奖励
function LegionCityUpgradeUI:getAwards(cityType)
    local args = {
        city_type = cityType,
    }

    MessageMgr:sendPost("get_city_awards", "legion", json.encode(args), function (jsonObj)
		print(json.encode(jsonObj))
	    local code = jsonObj.code
		if code == 0 then
            local awards = jsonObj.data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end

            UserData:getUserObj():setLegionCityInfo(jsonObj.data.city)
            self:refreshAwards(cityType)
        end
	end)		
end

return LegionCityUpgradeUI