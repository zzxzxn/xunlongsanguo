local TerritorialWarsFuncUI = class("TerritorialWarsFunc", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local TITLE_TEXTURE_NOR = {
	'uires/ui/common/title_btn_nor_1.png',
	'uires/ui/common/title_btn_nor_1.png',
    'uires/ui/common/title_btn_nor_1.png',
	'uires/ui/common/title_btn_nor_1.png',
}
local TITLE_TEXTURE_SEL = {
	'uires/ui/common/title_btn_sel_1.png',
	'uires/ui/common/title_btn_sel_1.png',
    'uires/ui/common/title_btn_sel_1.png',
	'uires/ui/common/title_btn_sel_1.png',
}

local PUPPET_REWARD = {
    'uires/ui/activity/yilingq.png',            --已领�?
    'uires/ui/activity/weidac.png',             --未达�?
}

local resPath = 'uires/ui/territorialwars/terwars_'

function TerritorialWarsFuncUI:ctor(funId,cities)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_FUNC
    self.uiParam = {}
    self.pageBtns = {}
    self.newImgs = {}
    self.funId = funId
    self.cityState = cities
end

function TerritorialWarsFuncUI:onShow()
    self:updateNewImgs()
end

function TerritorialWarsFuncUI:updateNewImgs()
    self.newImgs[2]:setVisible(TerritorialWarMgr:getPuppetNewImg())
    self.newImgs[3]:setVisible(TerritorialWarMgr:getSecretboxNewImg())
    self.newImgs[4]:setVisible(TerritorialWarMgr:getRelicNewImg())
end

function TerritorialWarsFuncUI:init()

    self.uiParam[1] = { winName = 'transport_bg',win = nil}
    self.uiParam[2] = { winName = 'puppet_bg',win = nil}
    self.uiParam[3] = { winName = 'secretbox_bg',win = nil}
    self.uiParam[4] = { winName = 'relic_bg',win = nil}

    local bgimg = self.root:getChildByName('bg_img')
    local funimg = bgimg:getChildByName('fun_img')
    self:adaptUI(bgimg,funimg)
    self.funimg = funimg
   
    for i=1,4 do
        local win = funimg:getChildByName(self.uiParam[i].winName)
        self.uiParam[i].win = win
        local pageBtn = funimg:getChildByName('page_' .. i .. '_img')
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:chooseWin(i)
            end
        end)
        self.pageBtns[i] = pageBtn
        self.newImgs[i] = pageBtn:getChildByName('new_img')
        local infoTx = pageBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_BTNTEXT' .. i))

    end
    local closeBtn = funimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideFuncUI()
        end
    end)

    
    self:initTransport()
    self:initPuppet()
    self:initSecretbox()
    self:initRelic()
    self:chooseWin(self.funId)
    self:updateNewImgs()
end

function TerritorialWarsFuncUI:chooseWin(id)
    
    for i=1,4 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == id then
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

            self.uiParam[i].win:setVisible(true)
        else
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
            self.uiParam[i].win:setVisible(false)
        end
    end


end

--传�?
function TerritorialWarsFuncUI:initTransport()
    
    local config = GameData:getConfData("dftransmit")
    local baseConfig = GameData:getConfData("dfbasepara")

    local transportbg = self.funimg:getChildByName('transport_bg')
    for i=1,4 do
        local cityCard = transportbg:getChildByName('card_' .. i)

        local name = cityCard:getChildByName('name')
        name:setString(config[i].name)

        local icon = cityCard:getChildByName('city_bg')
        icon:loadTexture('uires/ui/territorialwars/terwars_' .. config[i].icon)
        icon:ignoreContentAdaptWithSize(true)

        local tranBtn = cityCard:getChildByName('trans_btn')
        local btnTx = tranBtn:getChildByName('info_tx')
        btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_CITYSTATE1'))
        tranBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local cellId = tonumber(baseConfig[config[i].target].value[1])
                MessageMgr:sendPost('go_back', 'territorywar', json.encode({cellId = cellId,transferId = i}), function (jsonObj)
                    local code = jsonObj.code
                    if code ~= 0 then
                        TerritorialWarMgr:handleErrorCode(code)
                        return
                    end
                    TerritorialWarMgr:setBattleEnd(nil,nil,nil)
                    TerritorialWarMgr:clearAroundCells()
                    TerritorialWarMgr:hideFuncUI()
                    TerritorialWarMgr:showMapUI()
                end)
            end
        end)

        local cityState = TerritorialWarMgr:transportCityState(tonumber(baseConfig[config[i].target].value[1]),config[i].cost)
        local stateInfo = cityCard:getChildByName('info')
        if cityState == 1 then
            cityState = (not self.cityState[tostring(i)].hasEnemy) and TerritorialWarMgr.cityState.cango or TerritorialWarMgr.cityState.exit_enemy 
        end
        stateInfo:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_CITYSTATE' .. cityState))
        stateInfo:setColor(COLOR_TYPE.RED)
        local canGo = (cityState == 1) and true or false
        tranBtn:setVisible(canGo)
        stateInfo:setVisible(not canGo)
    end

    --剩余传送次�?
    local leftTransCount = tonumber(baseConfig['transmitTimes'].value[1]) - TerritorialWarMgr:getTransferCount()
    local transInfo1 = transportbg:getChildByName('trans_info1')
    transInfo1:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF18'))
    local transNum = transportbg:getChildByName('trans_num')
    transNum:setString(tostring(leftTransCount))
    local transInfo2 = transportbg:getChildByName('trans_info2')
    transInfo2:setString(string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF19'),config[1].name))

end

--无尽傀�?
function TerritorialWarsFuncUI:initPuppet()
    
    local territoryData = UserData:getUserObj():getTerritorialWar()
    local userLevel = territoryData.level
    if userLevel == nil then
        print("territoryData.level nil in func line 179")
        userLevel = UserData:getUserObj():getLv()
    end

    local typeConfig = GameData:getConfData("dfachievementtype")
    local levels = typeConfig[TerritorialWarMgr.achieveMentType.puppet].level
    self.awardIndex = 1
    self.des = typeConfig[TerritorialWarMgr.achieveMentType.puppet].desc
    for k,v in pairs(levels) do
        if userLevel >= v then
            self.awardIndex = k
        end
    end

    self.awardConfig = GameData:getConfData("dfachievementaward")

    local puppetbg = self.funimg:getChildByName('puppet_bg')
    local leftBg = puppetbg:getChildByName('left_bg')
    local cityIcon = leftBg:getChildByName('city_bg')

    local cityname = leftBg:getChildByName('name')
    cityname:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_PUPPET1'))
    
    --累计击溃
    local killCount = TerritorialWarMgr:getKillPuppetCount()
    local info = leftBg:getChildByName('info')
    info:setString(string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_PUPPET2'),killCount))
    
    --拥有无尽傀�?
    self.ownCount = 0
    local elementConfig = GameData:getConfData("dfelement")             
    local disPlayData = DisplayData:getDisplayObjs(elementConfig[3].award) --3石塔Id,固定产出无尽傀�?
    if #disPlayData == 1 then
        local obj = BagData:getMaterialById(disPlayData[1]:getId())
        if obj then
            self.ownCount = obj:getNum()
        end
    end
    local info1 = leftBg:getChildByName('info1')
    info1:setString(string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_PUPPET3'),self.ownCount))

    --挑战
    local confirmBtn = leftBg:getChildByName('confirm_btn')
    local btnTx = confirmBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_PUPPET4'))
    confirmBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.ownCount == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT1'),COLOR_TYPE.RED)
                return
            end
            self:FightPuppet() 
        end
    end)

    self.cardSv = puppetbg:getChildByName('card_sv')
	self.cardSv:setScrollBarEnabled(false)

    self:setPuppetData()
    self:updatePuppet()
end

local function sortcmp(a, b)

    if a.state == b.state then
        return a.target < b.target
    else
        return a.state > b.state
    end
end

function TerritorialWarsFuncUI:setPuppetData()
    
    self.achieve = {}
    local dfachieveConfig = GameData:getConfData("dfachievement")[TerritorialWarMgr.achieveMentType.puppet]
    for k,v in pairs(dfachieveConfig) do
        if k ~= 'type' then
            --1-已领�?2-未达�?3-可以领取
            local getState,finishCount = TerritorialWarMgr:getAchieveAwardState(TerritorialWarMgr.achieveMentType.puppet,v.target,v.goalId)
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

function TerritorialWarsFuncUI:updatePuppet()

    self.cardSv:removeAllChildren()
	if #self.achieve > 0 then
        self.cardSv:setVisible(true)
		local size1
		for i,v in ipairs(self.achieve) do
			local cell = self.cardSv:getChildByTag(i + 100)
			local cellBg
			if not cell then
				local cellNode = cc.CSLoader:createNode('csb/puppetcell.csb')
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

			local infoTx = cellBg:getChildByName('info_text')
            infoTx:setString('')
            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(400, 280))
            richText:setAnchorPoint(cc.p(0,1))
            richText:setPosition(cc.p(0,20))
            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')
            infoTx:addChild(richText)

            local str = string.format(self.des,tostring(v.target))
            str = string.gsub(str, "|", "\n")

            xx.Utils:Get():analyzeHTMLTag(richText,str)
            richText:format(true)

            --奖励
            local awardNode = cellBg:getChildByName('reworld_node')
            local awardId = v.awardId[self.awardIndex]
            local disPlayData = DisplayData:getDisplayObjs(self.awardConfig[awardId].award)
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
                        achievementType = TerritorialWarMgr.achieveMentType.puppet,
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
                        TerritorialWarMgr:setAchieveRecord(TerritorialWarMgr.achieveMentType.puppet,v.goalId)
                        self:setPuppetData()
                        self:updatePuppet()
                    end)
                end
            end)

            local btnText = getBtn:getChildByName('info_tx')
            btnText:setString(GlobalApi:getLocalStr('STR_GET'))

			local getIcon = cellBg:getChildByName('get_icon')
            --1-已领�?2-未达�?3-可以领取
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
		if #self.achieve * size1.height > size.height then
		    self.cardSv:setInnerContainerSize(cc.size(size.width,(#self.achieve * size1.height+(#self.achieve-1)*8)))
		else
		    self.cardSv:setInnerContainerSize(size)
		end

	    local function getPos(i)
	    	local size2 = self.cardSv:getInnerContainerSize()
			return cc.p(1,size2.height - size1.height* i-8*(i-1))
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

function TerritorialWarsFuncUI:FightPuppet()
    
    local dfbase = GameData:getConfData("dfbasepara")
    local dfpuppetConfig = GameData:getConfData("dfpuppetconf")
    local lv = UserData:getUserObj():getLv()
    local baseGold = 0
    for k,v in pairs(dfpuppetConfig[lv].drop) do
        baseGold = tonumber(v[3])
    end

    MessageMgr:sendPost('challenge', 'territorywar', json.encode({}), function (jsonObj)
        local code = jsonObj.code
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end

        local customObj = {
            info = jsonObj.data.enemy,
            fomation = dfbase['puppetFormation'].value[1],
            maxRound = tonumber(dfbase['puppetMaxRound'].value[1]),
            needMonsterCount = tonumber(dfpuppetConfig[lv].posCount),
            addFactor= tonumber(dfbase['puppetAddFactor'].value[1]),
            highKillCount = TerritorialWarMgr:getKillPuppetCount(),
            totalTime = tonumber(dfbase['puppetMaxTime'].value[1]),
            baseAward = baseGold,
        }
        TerritorialWarMgr:setBattleEnd(nil,nil,nil)
        BattleMgr:playBattle(BATTLE_TYPE.TERRITORALWAR_PUPPET, customObj, function ()
            TerritorialWarMgr:showMapUI()
		end)
    end)
end

--秘匣
function TerritorialWarsFuncUI:initSecretbox()
    
    local dropId = {}
    local dropCfg = GameData:getConfData('drop')
    local secretBxBg = self.funimg:getChildByName('secretbox_bg')
    local dfBoxlootCfg = GameData:getConfData('dfboxloot')
    local dfbase = GameData:getConfData('dfbasepara')
    local cost = dfbase['advancedBoxCost'].value[1]
    local Lv = UserData:getUserObj():getLv()
    for k,v in pairs(dfBoxlootCfg) do
        if Lv >= k then
            dropId[1] = v.boxLootId
            dropId[2] = v.advancedBoxLootId
        end
    end
    local elementConfig = GameData:getConfData("dfelement")
    local disPlayData = DisplayData:getDisplayObjs(elementConfig[4].award)
    if #disPlayData ~= 2 then
        return
    end
    for i=1,2 do
        local innerBg = secretBxBg:getChildByName('inner_bg' .. i)
        local boxName = innerBg:getChildByName('con_tx')
        local itemNode = innerBg:getChildByName('main_award')
        local ownCount = 0
        
        local awards = disPlayData[i]
        boxName:setString(awards:getName())

        --拥有
        local ownNum = innerBg:getChildByName('num_tx')
        local obj = BagData:getMaterialById(awards:getId())
        if obj then
            ownCount = obj:getNum()
        end
        ownNum:setString('x '..ownCount)
     

        --显示奖励
        for j=1,4 do
            local awardNode = innerBg:getChildByName('drop_award' .. j)
            local disPlayData = DisplayData:getDisplayObjs(dropCfg[dropId[i]]['award' .. j])
            if #disPlayData == 1 then
                local awards = disPlayData[1]
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardNode)
                cell.awardBgImg:setScale(0.9)
            end
        end
        local info1 = innerBg:getChildByName('info_tx1')
        if i == 1 then
            info1:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_SECRET2'))
        else
            info1:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_SECRET6'))
            local cash = innerBg:getChildByName('cash_tx')
            cash:setString(cost)
            cash:setColor(COLOR_TYPE.GREEN)
            local ybtx = innerBg:getChildByName('yb')
            ybtx:setString(GlobalApi:getLocalStr('STR_CASH'))
        end
        local info2 = innerBg:getChildByName('info_tx2')
        info2:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_SECRET4'))

        local btn = innerBg:getChildByName('confirm_btn')
        local btnTx = btn:getChildByName('info_tx')
        btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_SECRET5'))
        btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if ownCount == 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT2'),COLOR_TYPE.RED)
                    return
                end

                local openMsgBox = false

                if i== 2 then
                    local hasCash = UserData:getUserObj():getCash()
                    if tonumber(cost) >  hasCash then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT3'),COLOR_TYPE.RED)
                        return
                    end
                    openMsgBox = true
                    cost = dfbase['advancedBoxCost'].value[1]
                else
                    cost = 0
                end

                UserData:getUserObj():cost('cash',tonumber(cost),function()
                    
                    MessageMgr:sendPost('open_box', 'territorywar', json.encode({boxType = i-1}), function (jsonObj)
                        local code = jsonObj.code
                        local data = jsonObj.data
                        if code ~= 0 then
                            TerritorialWarMgr:handleErrorCode(code)
                            return
                        end

                        if data.awards then
                            GlobalApi:parseAwardData(data.awards)
                            GlobalApi:showAwardsCommon(data.awards,2,nil,true)
                        end
                     
                        if data.costs then
		            	    GlobalApi:parseAwardData(data.costs)
		                end

                        local obj = BagData:getMaterialById(awards:getId())
                        if obj then
                            ownCount = obj:getNum()
                        end
                        ownNum:setString('x '..ownCount)
                    end)
               end,openMsgBox,string.format(GlobalApi:getLocalStr('NEED_CASH'),tonumber(cost)))
            end
        end)
    end
end

--秘境
function TerritorialWarsFuncUI:initRelic()
    
    local relicbg = self.funimg:getChildByName('relic_bg')
    self.innerSv = relicbg:getChildByName('inner_sv')
    self.innerSv:setScrollBarEnabled(false)
    self:updateRelic()
end

function TerritorialWarsFuncUI:updateRelic()
    local relicbg = self.funimg:getChildByName('relic_bg')
    local dfrelicCfg = GameData:getConfData("dfrelic")
    local bgImg = relicbg:getChildByName('bg_img')
    local tipTx = bgImg:getChildByName('tip_text')
    tipTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_RELIC5'))
    local relicList = TerritorialWarMgr:getRelicList()
    local listCount = 0
	local size1
	for i,v in pairs(relicList) do
        if not dfrelicCfg[tonumber(i)] then
            return 
        end
        listCount = listCount + 1
		local cell = self.innerSv:getChildByTag(i + 100)
		local cellBg
		if not cell then
			local cellNode = cc.CSLoader:createNode('csb/reliccell.csb')
			cellBg = cellNode:getChildByName('cell_bg')
			cellBg:removeFromParent(false)
			cell = ccui.Widget:create()
			cell:addChild(cellBg)
			self.innerSv:addChild(cell,1,i+100)
		else
			cellBg = cell:getChildByName('cell_bg')
		end
		cell:setVisible(true)
		size1 = cellBg:getContentSize()

		local nameTx = cellBg:getChildByName('name')
        nameTx:setString(dfrelicCfg[tonumber(i)].name)
           
        local numInfo = cellBg:getChildByName('num_text')
        numInfo:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_RELIC1'))

        local numTx = cellBg:getChildByName('num')
        numTx:setString(v.num)

        local totalTime = TerritorialWarMgr:getRealCount('relicExploreTime',dfrelicCfg[tonumber(i)].time*60*60)
        local barBg = cellBg:getChildByName('bar_bg')
        local bar = barBg:getChildByName('bar')
        local barTx = barBg:getChildByName('bar_tx')
        local stateTx = cellBg:getChildByName('state_tx')

        local diffTime = v.endTime - GlobalData:getServerTime()
        if v.endTime == 0  or diffTime <= 0 then
            bar:setPercent(100)
            barTx:setString(TerritorialWarMgr:getTime(totalTime))
            stateTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_RELIC3'))
        else
            local diffTime = v.endTime - GlobalData:getServerTime()
	        if diffTime > 0 then
                bar:setPercent(diffTime/totalTime*100)
                self:timeoutCallback(barBg,v.endTime,i)
            end
            stateTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_RELIC2'))
            barTx:setString('')
        end

		local exploreBtn = cellBg:getChildByName('confirm_btn')
        exploreBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:hideFuncUI()
                TerritorialWarMgr:showExplorUI(tonumber(i))
            end
        end)

        local btnText = exploreBtn:getChildByName('info_tx')
        btnText:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_RELIC4')) 

        if v.num == 0 then
            exploreBtn:setTouchEnabled(false)
            exploreBtn:setBright(false)
            btnText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        else
            exploreBtn:setTouchEnabled(true)
            exploreBtn:setBright(true)
            btnText:enableOutline(COLOROUTLINE_TYPE.WHITE1)
        end

	end

    if listCount > 0 then
        local size = self.innerSv:getContentSize()
	    if listCount * size1.height + 3 > size.height then
		    self.innerSv:setInnerContainerSize(cc.size(size.width,(listCount * size1.height+(listCount-1)*8) + 3))
	    else
		    self.innerSv:setInnerContainerSize(size)
	    end

	    local function getPos(i)
	        local size2 = self.innerSv:getInnerContainerSize()
		    return cc.p(6,size2.height - size1.height* i-8*(i-1) - 3)
	    end

        local id = 0
	    for i,v in pairs(relicList) do
            id = id +1
		    local cell = self.innerSv:getChildByTag(i + 100)
		    if cell then
			    cell:setPosition(getPos(id))
		    end
	    end
        bgImg:setVisible(false)
    elseif listCount == 0 then
        bgImg:setVisible(true)
    end
end

function TerritorialWarsFuncUI:timeoutCallback(parent ,time,relicId)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)		 
    local size = parent:getContentSize()
    node:setPosition(cc.p(size.width/2+35,size.height/2))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK,'',cc.c3b(255,255,255),cc.c4b(0,0,0,255),20,function ()
		TerritorialWarMgr:removeFinishRelic(relicId)
	end)
end

return TerritorialWarsFuncUI