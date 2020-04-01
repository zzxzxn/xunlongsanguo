local TerritorialWarsAchieveUI = class("TerritorialWarsAchieve", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local TITLE_TEXTURE_NOR = {
	'uires/ui/common/title_btn_nor_3.png',
	'uires/ui/common/title_btn_nor_3.png',
    'uires/ui/common/title_btn_nor_1.png',
}

local TITLE_TEXTURE_SEL = {
	'uires/ui/common/title_btn_sel_3.png',
	'uires/ui/common/title_btn_sel_3.png',
    'uires/ui/common/title_btn_sel_1.png',
}

local PUPPET_REWARD = {
    'uires/ui/activity/yilingq.png',            --已领取
    'uires/ui/activity/weidac.png',             --未达成
}

local resPath = 'uires/ui/territorialwars/terwars_'

local MAX_LEN = 2
local ACHIEVE_BASE_TYPE = 100

function TerritorialWarsAchieveUI:ctor(id)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_ACHIEVE
    self.pageBtns = {}
    self.id = id
    self.richText = {}
    self.richTextProgress = {}
    self.cellReward = {}
    self.maxCell = 0
end

function TerritorialWarsAchieveUI:init()
    
    local bgimg = self.root:getChildByName('bg_img')
    local achimg = bgimg:getChildByName('ach_img')
    self:adaptUI(bgimg,achimg)

     local closeBtn = achimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideAchieveUI()
        end
    end)

    for i=1,MAX_LEN do
        local pageBtn = achimg:getChildByName('page_' .. i .. '_img')
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:chooseAchieve(i)
            end
        end)
        self.pageBtns[i] = pageBtn
        local btnTx = pageBtn:getChildByName('info_tx')
        btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_ACHIEVE' .. i))
    end

    local innerbg = achimg:getChildByName('inner_bg')
    self.cardSv = innerbg:getChildByName('inner_sv')
    self.cardSv:setScrollBarEnabled(false)

    self:chooseAchieve(self.id)
end

function TerritorialWarsAchieveUI:chooseAchieve(id)
    
    for i=1,MAX_LEN do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == id then
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end

    self.achieveType = ACHIEVE_BASE_TYPE + id
    
    local territoryData = UserData:getUserObj():getTerritorialWar()
    local userLevel = territoryData.level
    if userLevel == nil then
        print("territoryData.level nil in TerritorialWarsAchieve line 91")
        userLevel = UserData:getUserObj():getLv()
    end
    local typeConfig = GameData:getConfData("dfachievementtype")
    local levels = typeConfig[self.achieveType].level
    self.awardIndex = 1
    self.des = typeConfig[self.achieveType].desc
    self.icon = typeConfig[self.achieveType].icon
    for k,v in pairs(levels) do
        if userLevel >= v then
            self.awardIndex = k
        end
    end

    self.awardConfig = GameData:getConfData("dfachievementaward")

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

function TerritorialWarsAchieveUI:updateData()
    self.achieve = {}
    local dfachieveConfig = GameData:getConfData("dfachievement")[self.achieveType]
    for k,v in pairs(dfachieveConfig) do
        if k ~= 'type' then
            --1-已领取 2-未达成 3-可以领取
            local getState,finishCount = TerritorialWarMgr:getAchieveAwardState(self.achieveType,v.target,v.goalId)
            local obj = {
                goalId = v.goalId,
                target = v.target,
                awardId = v.awardId,
                finishCount = finishCount,
                state = getState,
            }
            self.achieve[#self.achieve+1] = obj
        end
    end
    table.sort(self.achieve,sortcmp)
end

function TerritorialWarsAchieveUI:updateSvPanel()

    if self.maxCell < #self.achieve then
        self.maxCell = #self.achieve
    end

    for i = #self.achieve+1,self.maxCell do
        local cell = self.cardSv:getChildByTag(i + 100)
        if cell then
            cell:setVisible(false)
        end
    end

    if #self.achieve > 0 then
        self.cardSv:setVisible(true)
		local size1
		for i,v in ipairs(self.achieve) do
			local cell = self.cardSv:getChildByTag(i + 100)
			local cellBg
			if not cell then
				local cellNode = cc.CSLoader:createNode('csb/territorialwar_achieve_cell.csb')
				cellBg = cellNode:getChildByName('cell_bg')
				cellBg:removeFromParent(false)
				cell = ccui.Widget:create()
				cell:addChild(cellBg)
				self.cardSv:addChild(cell,1,i+100)
			else
				cellBg = cell:getChildByName('cell_bg')
			end
			cell:setVisible(true)
			size1 = cellBg:getContentSize()

            --icon
            local icon = cellBg:getChildByName('type_icon')
            icon:loadTexture(resPath .. self.icon)

            --描述信息
			local infoTx = cellBg:getChildByName('info_text')
            infoTx:setString('')
            if not self.richText[i] then
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(400, 280))
                richText:setAnchorPoint(cc.p(0,1))
                richText:setPosition(cc.p(0,15))
                richText:setAlignment('left')
                richText:setVerticalAlignment('middle')
                infoTx:addChild(richText)
                self.richText[i] = richText
            else
                self.richText[i]:clear()
            end
            local str = string.format(self.des,tostring(v.target))
            str = string.gsub(str, "|", "\n")
            xx.Utils:Get():analyzeHTMLTag(self.richText[i],str)
            self.richText[i]:format(true)

            local color = COLOR_TYPE.GREEN
            if v.finishCount < v.target then
                color = COLOR_TYPE.RED
            end

            --进度显示
            local finishtext = cellBg:getChildByName('finish_text')
            if not self.richTextProgress[i] then
                self.richTextProgress[i] = {}
                local richText = xx.RichText:create()
                richText:setAlignment('middle')
                richText:setContentSize(cc.size(300, 30))
                local re = xx.RichTextLabel:create(v.finishCount,20,color)
                re:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                self.richTextProgress[i].finshTx = re

                local re1 = xx.RichTextLabel:create('/' .. tostring(v.target),20,COLOR_TYPE.WHITE)
                re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                self.richTextProgress[i].targetTx = re1

                richText:addElement(re)
                richText:addElement(re1)
                richText:setAnchorPoint(cc.p(0.5,0.5))
                local fieldBgSize = finishtext:getContentSize()
                richText:setPosition(cc.p(fieldBgSize.width*0.5,fieldBgSize.height*0.5))
                finishtext:addChild(richText)
                self.richTextProgress[i].richText = richText
            else
                self.richTextProgress[i].finshTx:setString(v.finishCount)
                self.richTextProgress[i].finshTx:setColor(color)
                self.richTextProgress[i].targetTx:setString('/' .. v.target)
                self.richTextProgress[i].richText:format(true)
            end

            --奖励
            
            local awardId = v.awardId[self.awardIndex]
            local disPlayData = DisplayData:getDisplayObjs(self.awardConfig[awardId].award)
            for k = 1,2 do
                local awardNode = cellBg:getChildByName('award_node'..k)
                awardNode:setScale(0.8)
                local awards = disPlayData[k]
                if not awards then
                    awardNode:setVisible(false)
                else
                    awardNode:setVisible(true)
                    if not self.cellReward[i] or not self.cellReward[i][k] then
                        self.cellReward[i] = {}
                        local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardNode)
                        self.cellReward[i][k] = itemCell
                    else
                        ClassItemCell:updateItem(self.cellReward[i][k],awards,1)
                    end
                end
            end

			local getBtn = cellBg:getChildByName('confirm_btn')
            getBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local args = {
                        achievementType = self.achieveType,
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
                        TerritorialWarMgr:setAchieveRecord(self.achieveType,v.goalId)
                        self:updateData()
                        self:updateSvPanel()
                        TerritorialWarMgr:updateWeekAchieve()
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
               finishtext:setVisible(true)
            else
               getBtn:setVisible(true)
               getIcon:setVisible(false)
               finishtext:setVisible(false)
            end
		end

        local size = self.cardSv:getContentSize()
		if #self.achieve * size1.height > size.height then
		    self.cardSv:setInnerContainerSize(cc.size(size.width,(#self.achieve * size1.height+(#self.achieve-1)*8)))
		else
		    self.cardSv:setInnerContainerSize(size)
		end

	    local function getPos(i)
	    	local size2 = self.cardSv:getInnerContainerSize()
			return cc.p(3,size2.height - size1.height* i-8*(i-1))
		end
		for i,v in ipairs(self.achieve) do
			local cell = self.cardSv:getChildByTag(i + 100)
			if cell then
				cell:setPosition(getPos(i))
			end
		end
	else
		self.cardSv:setVisible(false)
	end
    
end

return TerritorialWarsAchieveUI