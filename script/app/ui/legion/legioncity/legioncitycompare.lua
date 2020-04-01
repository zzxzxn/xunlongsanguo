local LegionCityCompareUI = class("LegionCityCompareUI", BaseUI)

function LegionCityCompareUI:ctor(data, memberdata)
    self.uiIndex = GAME_UI.UI_LEGION_CITY_COMPARE
    self.data = data
    self.memberdata = memberdata
    self.legioncompareconf = GameData:getConfData('legioncompareconf')
end

function LegionCityCompareUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)

    local closebtn = bgimg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local heroInfoPl = bgimg1:getChildByName('hero_info_pl')

    self.heroInfoArr = {}
    for i = 1, 2 do
        self.heroInfoArr[i] = {}
        self.heroInfoArr[i].bg = heroInfoPl:getChildByName('hero_info_' .. i)
        self.heroInfoArr[i].iconBg = self.heroInfoArr[i].bg:getChildByName('icon_bg_img')
        self.heroInfoArr[i].iconImg = self.heroInfoArr[i].iconBg:getChildByName('icon_img')
        self.heroInfoArr[i].frameImg = self.heroInfoArr[i].iconBg:getChildByName('frame_img')
        self.heroInfoArr[i].heroNameTx = self.heroInfoArr[i].bg:getChildByName('hero_name_tx')
        self.heroInfoArr[i].fightForceBg = self.heroInfoArr[i].bg:getChildByName('fight_force_bg')
        self.heroInfoArr[i].fightForceTx = self.heroInfoArr[i].fightForceBg:getChildByName('fight_force_tx')
    end

    self.compareCellTab = {}
    local comparePl = bgimg1:getChildByName('compare_pl')
    self.compareSv = comparePl:getChildByName('compare_sv')

    self:refreshUI()
end

function LegionCityCompareUI:refreshUI()
    local obj = RoleData:getHeadPicObj(UserData:getUserObj().headpic)
    local obj1 = RoleData:getMainRole()
    self.heroInfoArr[1].heroNameTx:setString(UserData:getUserObj():getName())
    self.heroInfoArr[1].fightForceTx:setString(UserData:getUserObj():getFightforce())
    self.heroInfoArr[1].iconImg:loadTexture(obj:getIcon())
    self.heroInfoArr[1].frameImg:loadTexture(obj1:getBgImg())

    self.heroInfoArr[2].heroNameTx:setString(self.memberdata[2].un)
    self.heroInfoArr[2].fightForceTx:setString(self.memberdata[2].fight_force)

    local headId= self.data.targetHeadpic or 1
	local path = GameData:getConfData('settingheadicon')[headId].icon
    self.heroInfoArr[2].iconImg:loadTexture(path);

    self.compareSv:setScrollBarEnabled(false)
	self.compareSv:setInertiaScrollEnabled(true)
	self.compareSv:removeAllChildren()

    local contentWidget = ccui.Widget:create()
    self.compareSv:addChild(contentWidget)
    contentWidget:removeAllChildren()
    
    for i = 1, #self.legioncompareconf do
        local node = cc.CSLoader:createNode("csb/legion_city_compare_cell.csb")
	    local bgimg = node:getChildByName("bg_img")
	    bgimg:removeFromParent(false)

        self.compareCellTab[i]= ccui.Widget:create()
	    self.compareCellTab[i]:setName('compare_cell'..i)
	    self.compareCellTab[i]:addChild(bgimg)
        self.compareCellTab[i].bg = bgimg

	    self:updateCompareCell(i)

	    local contentsize = bgimg:getContentSize()
	    if math.ceil(i*(contentsize.height+5)) > self.compareSv:getContentSize().height then
	        self.compareSv:setInnerContainerSize(cc.size(contentsize.width,i*(contentsize.height+5)))
	    end

	    local posx = 0
	    local posy = -i*(contentsize.height+5)+contentsize.height/2
	    self.compareCellTab[i]:setPosition(cc.p(posx,posy))
	    contentWidget:addChild(self.compareCellTab[i])
	    contentWidget:setPosition(cc.p(self.compareSv:getContentSize().width*0.5, self.compareSv:getInnerContainerSize().height ))
    end
end

function LegionCityCompareUI:getBuildingTotalLevel(buildings)
    local total = 0 
    for k, v in pairs(buildings) do
        total = total + v.level
    end
    return total
end

function LegionCityCompareUI:getMainCityLevel(buildings)
    local level = 1
    local legionCityMainConf = GameData:getConfData('legioncitymain')
    local totalLevel = self:getBuildingTotalLevel(buildings)
    for k,v in ipairs(legionCityMainConf) do
        if totalLevel >= tonumber(v.condition) then
            level = k + 1
        end
    end

    return level
end

function LegionCityCompareUI:getValueByIndex(index)
    local value1 = 0
    local value2 = 0
    if index == 1 then
        -- 主城等级
        value1 = self:getMainCityLevel(self.data.territoryWar.buildings)
        value2 = self:getMainCityLevel(self.data.targetTerritoryWar.buildings)
    elseif index == 2 then
        -- 建筑等级
        value1 = self:getBuildingTotalLevel(self.data.territoryWar.buildings)
        value2 = self:getBuildingTotalLevel(self.data.targetTerritoryWar.buildings)
    elseif index == 3 then
        -- 累计击杀
        value1 = self.data.territoryWar.killCount
        value2 = self.data.targetTerritoryWar.killCount
    elseif index == 4 then
        -- 累计掠夺
        value1 = self.data.territoryWar.robCount
        value2 = self.data.targetTerritoryWar.robCount
    elseif index == 5 then
        -- 累计探索
        value1 = self.data.territoryWar.exploreCount
        value2 = self.data.targetTerritoryWar.exploreCount
    end

    return value1, value2
end

function LegionCityCompareUI:updateCompareCell(index)
    local cell = self.compareCellTab[index].bg
    local progressBg = cell:getChildByName('progress_bg')
    local progress1 = progressBg:getChildByName('progress_1')
    progress1:setScale9Enabled(true)
    progress1:setCapInsets(cc.rect(10,15,1,1))

    local progress2 = progressBg:getChildByName('progress_2')
    progress2:setScale9Enabled(true)
    progress2:setCapInsets(cc.rect(10,15,1,1))

    local titleTx = cell:getChildByName('title_tx')
    titleTx:setString(self.legioncompareconf[index].name)
    local effect = progressBg:getChildByName('effect_img')
    --effect:setVisible(false)

    local value_1 = progressBg:getChildByName('value_1')
    local value_2 = progressBg:getChildByName('value_2')
    local value1, value2 = self:getValueByIndex(index)
    local total = value1 + value2
    local percent1 = 50
    local percent2 = 50
    if total > 0 then
        percent1 = value1/total * 100
        percent2 = value2/total * 100
    end

    value_1:setString(value1)
    value_2:setString(value2)

    progress1:setPercent(percent1)
    progress2:setPercent(percent2)

    local effectPosX = 6 + 762 * percent1/100
    effect:setPositionX(effectPosX)
    if percent1 == 0 or percent2 == 0 then
        effect:setVisible(false)
    else
        effect:setVisible(true)
    end
end

return LegionCityCompareUI