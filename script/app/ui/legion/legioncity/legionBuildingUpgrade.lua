local LegionBuildingUpgradeUI = class("LegionBuildingUpgradeUI", BaseUI)

function LegionBuildingUpgradeUI:ctor(cityType, cityIndex, buildingId, buildingLevel)
    self.uiIndex = GAME_UI.UI_LEGION_BUILDING_UPGRADE
    self.cityType = cityType
    self.cityIndex = cityIndex
    self.buildingId = buildingId
    self.buildingLevel = buildingLevel
end

function LegionBuildingUpgradeUI:init()
    local bg_img = self.root:getChildByName("bg_img")
    local middle_node = bg_img:getChildByName('middle_node')
    self:adaptUI(bg_img, middle_node)
    
    local close_btn = middle_node:getChildByName('close_btn')
    close_btn:addTouchEventListener(function (sender, eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local bg_img2 = middle_node:getChildByName('bg_img2')
    self.building_name_tx = bg_img2:getChildByName('building_name_tx')
    self.building_icon_img = bg_img2:getChildByName('building_icon_img')
    self.building_icon_img:ignoreContentAdaptWithSize(true)

    self.res_pl = bg_img2:getChildByName('res_pl')
    local need_tx = self.res_pl:getChildByName('need_tx')
    need_tx:setString(GlobalApi:getLocalStr("SKILL_UPGRADE_DES3"))
    self.resArr = {}
    for i = 1, 2 do
        self.resArr[i] = {}
        self.resArr[i].bg = self.res_pl:getChildByName('res_bg_' .. i)
        self.resArr[i].icon = self.res_pl:getChildByName('icon_img_' .. i)
        self.resArr[i].icon:ignoreContentAdaptWithSize(true)
        self.resArr[i].num = self.res_pl:getChildByName('num_tx_' .. i)
    end

    local bg_img1 = middle_node:getChildByName('bg_img1')
    self.upgrade_btn = bg_img1:getChildByName('upgrade_btn')
    self.upgrade_btn_tx = self.upgrade_btn:getChildByName('func_tx')
    self.upgrade_btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:upgradeBuilding(self.buildingId)
        end
    end) 

    local upgrade_info_pl = bg_img1:getChildByName('upgrade_info_pl')
    local top_tx = upgrade_info_pl:getChildByName('top_tx')
    if self.buildingLevel == 0 then
        top_tx:setString(GlobalApi:getLocalStr("BUILD_REQUIRE") .. "：")
    else
        top_tx:setString(GlobalApi:getLocalStr("UPGRADE_REQUIRE") .. "：")    
    end
    local info_tx = upgrade_info_pl:getChildByName('info_tx')
    if self.buildingLevel == 0 then
        info_tx:setString(GlobalApi:getLocalStr("BUILD_EFFECT") .. "：")
    else
        info_tx:setString(GlobalApi:getLocalStr("UPGRADE_EFFECT") .. "：")
    end

    self.reach_img_1 = upgrade_info_pl:getChildByName('reach_img_1')
    self.reach_img_1:setVisible(false)

    self.condition_tx = upgrade_info_pl:getChildByName('condition_tx')
    self.condition_tx2 = xx.RichText:create()
    self.condition_tx2:setAnchorPoint(cc.p(0, 0.5))
    self.condition_tx2:setPosition(cc.p(self.condition_tx:getPositionX(), 182))
    upgrade_info_pl:addChild(self.condition_tx2)

    self.effectArr = {}
    for i = 1, 2 do
        self.effectArr[i] = {}
        self.effectArr[i].bg = upgrade_info_pl:getChildByName('effect_' .. i)
        self.effectArr[i].desc = self.effectArr[i].bg:getChildByName('effect_desc_tx')
        self.effectArr[i].value1 = self.effectArr[i].bg:getChildByName('value_1')
        self.effectArr[i].value2 = self.effectArr[i].bg:getChildByName('value_2')
    end

    self:refreshUI()
end

function LegionBuildingUpgradeUI:refreshUI()
    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[self.cityType]

    local functionConf = GameData:getConfData('legioncityfunction')
    local buildingConf = GameData:getConfData('legioncityconf')

    UIManager:showSidebar({1}, cityInfo.costType,false)

    -- ½¨ÖþÃû³ÆºÍicon
    self.buildingName = cityInfo['buildName' .. self.cityIndex]
    self.building_name_tx:setString(cityInfo['buildName' .. self.cityIndex] .. ' Lv.' .. self.buildingLevel)
    self.building_icon_img:loadTexture('uires/ui/legion/cityUpgrade/' .. cityInfo['buildUrl' .. self.cityIndex] .. '.png')

    local curBuildInfo = buildingConf[self.buildingId][self.buildingLevel]
    local nextBuildLevel = self.buildingLevel + 1
    local nextBuildInfo = buildingConf[self.buildingId][nextBuildLevel]
    if nextBuildInfo == nil then
        nextBuildInfo = curBuildInfo
        nextBuildLevel = self.buildingLevel
    end

    local needBuilds = buildingConf[self.buildingId][nextBuildLevel].needBuild
    local needLevel = buildingConf[self.buildingId][nextBuildLevel].needLevel

    local needStr1 = GlobalApi:getLocalStr('STR_MAIN_CITY') .. string.format(GlobalApi:getLocalStr('STR_BUILD_NEED_LEVEL'), buildingConf[self.buildingId][nextBuildLevel].condition1)
    self.condition_tx:setString(needStr1)
    local curCityLevel = UserData:getUserObj():getLegionCityMainLevel()
    if curCityLevel >= buildingConf[self.buildingId][nextBuildLevel].condition1 then
        self.condition_tx:setTextColor(COLOR_TYPE.GREEN)
        self.reach_img_1:setVisible(true)
        self.reach_img_1:setPositionX(self.condition_tx:getPositionX() + self.condition_tx:getContentSize().width + 15)
    else
        self.condition_tx:setTextColor(COLOR_TYPE.WHITE)
        self.reach_img_1:setVisible(false)
    end

    self.condition_tx2:clear()
    local conditionNum = 0
    for i = 1, #needBuilds do
        local bI = needBuilds[i] - 4 * (math.floor((needBuilds[i] - 1)/4))
        local cityName = cityInfo['buildName' .. bI]
        if i ~= #needBuilds then
            cityName = cityName .. ","
        end
        local rtl = xx.RichTextLabel:create(cityName, 20)
        local curLv = UserData:getUserObj():getLegionCityBuildingLevel(needBuilds[i])
        if curLv >= needLevel then
            conditionNum = conditionNum + 1
            rtl:setColor(COLOR_TYPE.GREEN)
        end
        self.condition_tx2:addElement(rtl)
    end

    local rtl2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('STR_BUILD_NEED_LEVEL'), needLevel), 20)
    if conditionNum == #needBuilds then
        rtl2:setColor(COLOR_TYPE.GREEN)
    end
    self.condition_tx2:addElement(rtl2)

    if #needBuilds > 1 then
        local rtl3 = xx.RichTextLabel:create("（" .. conditionNum .. "/" .. #needBuilds .. "）", 20)
        if conditionNum > 0 then
            rtl3:setColor(COLOR_TYPE.GREEN)
        end
        self.condition_tx2:addElement(rtl3)
    end

    if conditionNum == #needBuilds then
        local rtl4 = xx.RichTextImage:create("uires/ui/common/select_checkbox1.png")
        rtl4:setScale(0.5)
        self.condition_tx2:addElement(rtl4)
    end
    self.condition_tx2:format(true)

    local funcInfo = functionConf[cityInfo['buildFunction' .. self.cityIndex]]
    local effectCount = #funcInfo.desc1

    for i = 1, 2 do
        if i <= effectCount then
            self.effectArr[i].bg:setVisible(true)
            self.effectArr[i].desc:setString(funcInfo.desc1[i])

            if curBuildInfo == nil then
                self.effectArr[i].value1:setString(0)
            else
                self.effectArr[i].value1:setString(string.format(funcInfo.desc2[i], curBuildInfo.value[i]) .. funcInfo.desc3)
            end
            
            self.effectArr[i].value2:setString(string.format(funcInfo.desc2[i], nextBuildInfo.value[i]) .. funcInfo.desc3)
        else
            self.effectArr[i].bg:setVisible(false)
        end
    end

    local userConf = GameData:getConfData('user')
    if nextBuildLevel == self.buildingLevel then
        self.res_pl:setVisible(false)
    else
        self.res_pl:setVisible(true)
        for i = 1, 2 do
            self.resArr[i].bg:setVisible(true)
            self.resArr[i].icon:loadTexture('uires/ui/res/res_' .. userConf[nextBuildInfo.cost[i][2]].icon)
            local mineType = self:getMineType(nextBuildInfo.cost[i][2])
            local curMineNum = UserData:getUserObj():getMine(mineType)
            if curMineNum >= math.abs(nextBuildInfo.cost[i][3]) then
                self.resArr[i].num:setTextColor(COLOR_TYPE.GREEN)
            else
                self.resArr[i].num:setTextColor(COLOR_TYPE.RED)
            end
            self.resArr[i].num:setString(math.abs(nextBuildInfo.cost[i][3]))
        end
    end

    if self.buildingLevel == 0 then
        self.upgrade_btn_tx:setString(GlobalApi:getLocalStr('STR_BUILD_1'))
    else
        self.upgrade_btn_tx:setString(GlobalApi:getLocalStr('UPGRADE2'))
    end

    if self:canUpgrade() then
        ShaderMgr:restoreWidgetDefaultShader(self.upgrade_btn)
        self.upgrade_btn:setTouchEnabled(true)
        self.upgrade_btn_tx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
    else
        ShaderMgr:setGrayForWidget(self.upgrade_btn)
        self.upgrade_btn:setTouchEnabled(false)
        self.upgrade_btn_tx:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
    end
end

function LegionBuildingUpgradeUI:getMineType(costType)
    local mine_type = 1
    if costType == 'mine_1' then
        mine_type = 1
    elseif costType == 'mine_2' then
        mine_type = 2
    elseif costType == 'mine_3' then
        mine_type = 3
    elseif costType == 'mine_4' then
        mine_type = 4
    elseif costType == 'mine_5' then
        mine_type = 5
    end

    return mine_type
end

function LegionBuildingUpgradeUI:upgradeBuilding(buildingId)
    local args = {
        building_id = buildingId,
    }
    MessageMgr:sendPost("upgrade_building", "legion", json.encode(args), function (jsonObj)
		print(json.encode(jsonObj))
	    local code = jsonObj.code
		if code == 0 then
            local costs = jsonObj.data.costs
            if costs then
				GlobalApi:parseAwardData(costs)
			end

            local cityAwards = jsonObj.data.awards
            if cityAwards then
                UserData:getUserObj():setLegionCityAwards(cityAwards)
            end

            local level = jsonObj.data.level
            UserData:getUserObj():setLegionCityBuildingLevel(buildingId, level)
            self.buildingLevel = level
            self:hideUI()

            if level == 1 then
                local str = string.format(GlobalApi:getLocalStr('LEGION_CITY_BUILD_SUCCESS'), self.buildingName)
                promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
            else
                local str = string.format(GlobalApi:getLocalStr('LEGION_CITYUPGRADE_SUCCESS'), self.buildingName)
                promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
            end
            CustomEventMgr:dispatchEvent(CUSTOM_EVENT.LEGION_BUILDING_UPGRADE, args.building_id)
        else 
            promptmgr:showSystenHint(GlobalApi:getLocalStr('UPGRADE_FAIL'), COLOR_TYPE.RED)
        end
	end)	
end

--ÅÐ¶Ï½¨ÖþÊÇ·ñÄÜÉý¼¶
function LegionBuildingUpgradeUI:canUpgrade()
    -- ¼ì²éÖ÷³ÇµÈ¼¶
    local mainCityLevel = UserData:getUserObj():getLegionCityMainLevel()

    local buildingConf = GameData:getConfData('legioncityconf')
    local nextBuildInfo = buildingConf[self.buildingId][self.buildingLevel + 1]
    if nextBuildInfo == nil then
        return false
    end

    if mainCityLevel < nextBuildInfo.condition1 then
        return false;
    end

    -- ¼ì²é½¨ÖþµÈ¼¶
    local needBuildings = nextBuildInfo.needBuild
    local needLevel = nextBuildInfo.needLevel
    for k, v in pairs(needBuildings) do
        local curLevel = UserData:getUserObj():getLegionCityBuildingLevel(v)
        if curLevel < needLevel then
            return false
        end
    end

    -- ¼ì²éÏûºÄ
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

return LegionBuildingUpgradeUI