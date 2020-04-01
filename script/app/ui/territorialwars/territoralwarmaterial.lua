local TerritorialWarsMaterialUI = class("TerritorialWarsMaterial", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')


local PUPPET_REWARD = {
    'uires/ui/activity/yilingq.png',            --已领取
    'uires/ui/activity/weidac.png',             --未达成
}

function TerritorialWarsMaterialUI:ctor()
    self.uiIndex = GAME_UI.UI_WORLD_MAP_MATERIAL
end

local resPath = 'uires/ui/territorialwars/terwars_'

function TerritorialWarsMaterialUI:init()
    
    local bgimg = self.root:getChildByName('bg_img')
    local matimg = bgimg:getChildByName('mat_img')
    self:adaptUI(bgimg,matimg)

    local closeBtn = matimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideMaterialUI()
        end
    end)

    local titleBg = matimg:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MATERIAL1'))

    local innerbg = matimg:getChildByName('inner_bg')
    self.cardSv = innerbg:getChildByName('inner_sv')
    self.cardSv:setScrollBarEnabled(false)

    self:updateData()
    self:updateSvPanel()
end

local function sortcmp(a, b)
    if a.state == b.state then
        return a.target < b.target
    else
        return a.state > b.state
    end
end

function  TerritorialWarsMaterialUI:updateData()

    self.materialtab = {}
    local territoryData = UserData:getUserObj():getTerritorialWar()
    local userLevel = territoryData.level
    if userLevel == nil then
        print("territoryData.level nil in material line 57")
        userLevel = UserData:getUserObj():getLv()
    end
    for i = 1,5 do
        local achieveType = TerritorialWarMgr.achieveMentType.heap_base+i
        local typeConfig = GameData:getConfData("dfachievementtype")
        local des = typeConfig[achieveType].desc
        local icon = typeConfig[achieveType].icon
        local levels = typeConfig[achieveType].level
        local awardIndex = 1
        for k,v in pairs(levels) do
            if userLevel >= v then
                awardIndex = k
            end
        end

        local awardConfig = GameData:getConfData("dfachievementaward")

        local dfachieveConfig = GameData:getConfData("dfachievement")[achieveType]
        local achieve = {}
        for k,v in pairs(dfachieveConfig) do
            if k ~= 'type' then
                achieve[#achieve+1] = v
            end
        end

        local function achieveSort(a, b)
            return tonumber(a.target) < tonumber(b.target)
        end

        table.sort(achieve, achieveSort)

        --1-已领取 2-未达成 3-可以领取
        local index,notgetIndex = 0,0
        for k,v in ipairs(achieve) do
            local state,finishCount = TerritorialWarMgr:getAchieveAwardState(achieveType,v.target,v.goalId)
            if state == 3 then
                notgetIndex = tonumber(k)
                break
            end
            if state == 2 then
                index = tonumber(k)
                break
            end
        end

        local realKey = 1
        if index == 0 and notgetIndex == 0 then
            realKey = #achieve
        elseif notgetIndex ~= 0 then
            realKey = notgetIndex
        elseif notgetIndex == 0 and index ~= 0 then
            realKey = index
        end
        local awardId = achieve[realKey].awardId[awardIndex]
        local award = awardConfig[awardId].award
        --1-已领取 2-未达成 3-可以领取
        local state,finishCount = TerritorialWarMgr:getAchieveAwardState(achieveType,achieve[realKey].target,achieve[realKey].goalId)
        local obj = {
            goalId = achieve[realKey].goalId,
            target = achieve[realKey].target,
            award = award,
            finishCount = finishCount,
            state = state,
            achieveType = achieveType,
            des = des,
            icon = icon
        }
        self.materialtab[#self.materialtab+1] = obj
     end

     table.sort(self.materialtab,sortcmp)
end

function TerritorialWarsMaterialUI:updateSvPanel()

     self.cardSv:removeAllChildren()
     if #self.materialtab > 0 then
        local size1
        for k,v in ipairs(self.materialtab) do
            local cell = self.cardSv:getChildByTag(k + 100)
		    local cellBg
		    if not cell then
			    local cellNode = cc.CSLoader:createNode('csb/territorialwar_achieve_cell.csb')
			    cellBg = cellNode:getChildByName('cell_bg')
			    cellBg:removeFromParent(false)
			    cell = ccui.Widget:create()
			    cell:addChild(cellBg)
			    self.cardSv:addChild(cell,1,k+100)
		    else
			    cellBg = cell:getChildByName('cell_bg')
		    end
		    cell:setVisible(true)
		    size1 = cellBg:getContentSize()
        
            local infoTx = cellBg:getChildByName('info_text')
            infoTx:setString('')
            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(400, 280))
            richText:setAnchorPoint(cc.p(0,1))
            richText:setPosition(cc.p(0,15))
            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')
            infoTx:addChild(richText)

            local icon = cellBg:getChildByName('type_icon')
            icon:loadTexture(resPath .. v.icon)

            local str = string.format(v.des,tostring(v.target))
            str = string.gsub(str, "|", "\n")

            xx.Utils:Get():analyzeHTMLTag(richText,str)
            richText:format(true)

            local isVisible = false
            local color = COLOR_TYPE.GREEN
            if v.finishCount < v.target then
                color = COLOR_TYPE.RED
                isVisible = true
            end

            local finishtext = cellBg:getChildByName('finish_text')
            local richText = xx.RichText:create()
            richText:setAlignment('middle')
            richText:setContentSize(cc.size(300, 30))
            local re = xx.RichTextLabel:create(v.finishCount,20,color)
            re:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re1 = xx.RichTextLabel:create('/' .. tostring(v.target),20,COLOR_TYPE.WHITE)
            re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            richText:addElement(re)
            richText:addElement(re1)
            richText:setAnchorPoint(cc.p(0.5,0.5))
            local fieldBgSize = finishtext:getContentSize()
            richText:setPosition(cc.p(fieldBgSize.width*0.5,fieldBgSize.height*0.5))
            finishtext:addChild(richText)
            richText:setVisible(isVisible)

            --奖励
            local awardNode = cellBg:getChildByName('award_node1')
            local disPlayData = DisplayData:getDisplayObjs(v.award)
            if #disPlayData == 1 then
                local awards = disPlayData[1]
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardNode)
            end

            local getBtn = cellBg:getChildByName('confirm_btn')
            getBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local args = {
                        achievementType = v.achieveType,
                        achievementId = v.goalId
                    }
                    MessageMgr:sendPost('get_achievement_awards', 'territorywar', json.encode(args), function (jsonObj)
                        local code = jsonObj.code
                        if code ~= 0 then
                            TerritorialWarMgr:handleErrorCode(code)
                            return
                        end

                        local awards = jsonObj.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,2,nil,true)
                        end
                        TerritorialWarMgr:setAchieveRecord(v.achieveType,v.goalId)
                        self:updateData()
                        self:updateSvPanel()
                    end)
                end
            end)

            local btnText = getBtn:getChildByName('info_tx')
            btnText:setString(GlobalApi:getLocalStr('STR_GET'))

		    local getIcon = cellBg:getChildByName('get_icon')
            if v.state < 3 then
                getIcon:loadTexture(PUPPET_REWARD[v.state])
                getBtn:setVisible(false)
                getIcon:setVisible(true)
            else
                getBtn:setVisible(true)
                getIcon:setVisible(false)
            end
        end

        local size = self.cardSv:getContentSize()
	    if #self.materialtab * size1.height > size.height then
		    self.cardSv:setInnerContainerSize(cc.size(size.width,(#self.materialtab* size1.height+(5-1)*8)))
	    else
		    self.cardSv:setInnerContainerSize(size)
	    end

	    local function getPos(i)
	        local size2 = self.cardSv:getInnerContainerSize()
		    return cc.p(3,size2.height - size1.height* i-8*(i-1))
	    end
	    for i,v in ipairs(self.materialtab) do
		    local cell = self.cardSv:getChildByTag(i + 100)
		    if cell then
			    cell:setPosition(getPos(i))
		    end
	    end

    end
end
return TerritorialWarsMaterialUI