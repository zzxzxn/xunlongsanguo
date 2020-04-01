local TerritorialWarsExplorUI = class("TerritorialWarsExplor", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function TerritorialWarsExplorUI:ctor(relicId)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_EXPLOR
    self.relicId = relicId
    self.relicInfo = {}
    local relicList = TerritorialWarMgr:getRelicList()
    for i,v in pairs(relicList) do
        if tonumber(i) == relicId then
            self.relicInfo = v
        end
    end

end

function TerritorialWarsExplorUI:init()
    
    local dfrelicCfg = GameData:getConfData("dfrelic")
    
    local outlineBg = self.root:getChildByName('alpha_img')
    local bgImg = outlineBg:getChildByName('bg_img')
    self:adaptUI(outlineBg,bgImg)
    local closeBtn = bgImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideExplorUI()
        end
    end)
    self.bg = bgImg
    self.topBgImg = bgImg:getChildByName('top_bg_img')
    self.bottomBgImg = bgImg:getChildByName('bottom_bg_img')
    local titleText = self.topBgImg:getChildByName('title_tx')
    titleText:setString(dfrelicCfg[self.relicId].name)

    --加速消耗
    local dfbaseparaCfg = GameData:getConfData("dfbasepara")
    local cost = tonumber(dfbaseparaCfg['relicAccelerateCost'].value[1])

    cost = TerritorialWarMgr:getRealCount('relicAccelerateCost',cost)

    local cashTx = self.bottomBgImg:getChildByName('cash_num')
    cashTx:setString(cost)
    local hasCash = UserData:getUserObj():getCash()
    if hasCash >= cost then
        cashTx:setColor(COLOR_TYPE.GREEN)
    else
        cashTx:setColor(COLOR_TYPE.RED)
    end

    --元宝显示
    self.cashBg = self.bottomBgImg:getChildByName('cash_bg_img')
    self.cashIcon = self.bottomBgImg:getChildByName('cash_icon')
    self.cashTx = cashTx

    --加速按钮
    local time = tonumber(dfbaseparaCfg['relicAccelerateTime'].value[1])
    local speedBtn = self.bottomBgImg:getChildByName('speed_up')
    local btnTex = speedBtn:getChildByName('info_tx')
    btnTex:setString(string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR3'),time))
    speedBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if cost >  hasCash then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT4'),COLOR_TYPE.RED)
                return
            end
            UserData:getUserObj():cost('cash',cost,function()
                
                MessageMgr:sendPost('speed_explore', 'territorywar', json.encode({relicId = self.relicId}), function (jsonObj)
                    local code = jsonObj.code
                    if code == 0 then   
                        --表示完成了
                        if jsonObj.data.relicInfo == nil then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT7'),COLOR_TYPE.GREEN)
                            self.explorFinishBtn:setVisible(true)
                            self.zhuizhu:setAnimation(0, "run", false)
                            self.barTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR9'))
                            self.barBg:removeAllChildren()
                            TerritorialWarMgr:removeFinishRelic(self.relicId)
                        else
                            TerritorialWarMgr:setRelicListData(self.relicId,jsonObj.data.relicInfo)
                            self.relicInfo.exploreTime = jsonObj.data.relicInfo.exploreTime
                            self.relicInfo.endTime = jsonObj.data.relicInfo.endTime
                            self.relicInfo.num = jsonObj.data.relicInfo.num
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT8'),COLOR_TYPE.GREEN)
                            self:updatePanel()
                        end
                        local costs = jsonObj.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
                    else
                        TerritorialWarMgr:handleErrorCode(code)
                    end
                end)
            end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
        end
    end)

    --完成探索
    self.explorFinishBtn = self.bottomBgImg:getChildByName('explor_finish')
    local btnTx = self.explorFinishBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR8'))
    self.explorFinishBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideExplorUI()
        end
    end)

    --探索按钮
    self.explorBtn = self.bottomBgImg:getChildByName('explor_btn')
    local btnTx = self.explorBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR4'))
    self.explorBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            MessageMgr:sendPost('start_explore', 'territorywar', json.encode({relicId = self.relicId}), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    TerritorialWarMgr:setRelicListData(self.relicId,jsonObj.data.relicInfo)
                    self.relicInfo.exploreTime = jsonObj.data.relicInfo.exploreTime
                    self.relicInfo.endTime = jsonObj.data.relicInfo.endTime
                    self.relicInfo.num = jsonObj.data.relicInfo.num
                    self:updatePanel()
                else
                    local vipLv = UserData:getUserObj():getVip()
                    if vipLv < GlobalApi:getMaxVip() then
                        TerritorialWarMgr:handleErrorCode(code)
                    else
                        local errStr = GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_239')
                        promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
                    end
                end
            end)
        end
    end)

    local infoTx = self.topBgImg:getChildByName('info_text')
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR5'))

    local neiBg = self.topBgImg:getChildByName('nei_bg_img')
    for i=1,2 do
        local titleTx = neiBg:getChildByName('title_' .. i)
        titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR' .. i))
    end

    --基础奖励
    local disPlayData = DisplayData:getDisplayObjs(dfrelicCfg[self.relicId].baseAward)
    if #disPlayData == 3 then
        for i=1,3 do 
            local awardNode = neiBg:getChildByName('award_node' .. i)
            local awards = disPlayData[i]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardNode)
            local num = TerritorialWarMgr:getRealCount('relicBaseAward',awards:getNum())
            cell.lvTx:setString('x'..num)
            cell.awardBgImg:setScale(0.9)
        end
    end
    

    --龙
    local id = dfrelicCfg[self.relicId].correlationId
    local treasureCfg = GameData:getConfData("treasure")[id]
    local url = treasureCfg[#treasureCfg].url
    local dragonLevel = 1
    local dragon = RoleData:getDragonById(dfrelicCfg[self.relicId].correlationId)
    if dragon then
        dragonLevel = dragon:getLevel()
    end

    local spine = GlobalApi:createLittleLossyAniByName(url)
    spine:getAnimation():play('idle', -1, 1)
    spine:setPosition(cc.p(165,50))
    spine:setScale(0.8)
    self.topBgImg:addChild(spine)

    self.zhuizhu = GlobalApi:createSpineByName("guide_zhuizhu", "spine/guide_zhuizhu/guide_zhuizhu", 1)
    self.zhuizhu:setPosition(cc.p(300, 50))
    self.bg:addChild(self.zhuizhu)
    self.zhuizhu:setScale(0.8)

    --额外奖励
    self.innerSv = neiBg:getChildByName('inner_sv')
    self.innerSv:setScrollBarEnabled(false)
    self:updateSvPanel()
    --时间
    self:updatePanel()
end

--时间条
function TerritorialWarsExplorUI:updatePanel()
    
    local dfrelicCfg = GameData:getConfData("dfrelic")
    local exploreTime = self.relicInfo.exploreTime

    local totalTime = TerritorialWarMgr:getRealCount('relicExploreTime',dfrelicCfg[self.relicId].time*60*60)
    self.barBg = self.bottomBgImg:getChildByName('bar_bg')
    local bar = self.barBg:getChildByName('bar')
    self.barTx = self.barBg:getChildByName('bar_tx')
    local endTime = self.relicInfo.endTime
    bar:setScale9Enabled(true)
    bar:setCapInsets(cc.rect(10,15,1,1))
    self.explorFinishBtn:setVisible(false)

    local diffTime = endTime - GlobalData:getServerTime()
    if endTime == 0 or diffTime <0 then
        bar:setPercent(100)
        self.barTx:setString(TerritorialWarMgr:getTime(totalTime))
        self.explorBtn:setVisible(true)
        self.cashBg:setVisible(false)
        self.cashIcon:setVisible(false)
        self.cashTx:setVisible(false)
    else
        self.cashBg:setVisible(true)
        self.cashIcon:setVisible(true)
        self.cashTx:setVisible(true)
        if diffTime > 0 then
           bar:setPercent(diffTime/totalTime*100)
           self:timeoutCallback(self.barBg,endTime)
           self.zhuizhu:setAnimation(0, "run", true)
        else
            self.explorFinishBtn:setVisible(true)
        end
        self.explorBtn:setVisible(false)
        self.barTx:setString('')
    end

end

function TerritorialWarsExplorUI:timeoutCallback(parent ,time)

	local diffTime = time - GlobalData:getServerTime()
	if diffTime <= 0 then       
        return
	end
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0.5,0.5))
    local size = parent:getSize()
    node:setPosition(cc.p(size.width/2+35,size.height/2))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK,'',cc.c3b(255,255,255),cc.c4b(0,0,0,255),20,function ()
        promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT7'),COLOR_TYPE.GREEN)
        self.explorFinishBtn:setVisible(true)
        self.zhuizhu:setAnimation(0, "run", false)
		parent:removeAllChildren()  
        TerritorialWarMgr:removeFinishRelic(self.relicId)
	end)
end

function TerritorialWarsExplorUI:updateSvPanel()
    
    local dfrelicCfg = GameData:getConfData("dfrelic")
    local size1
    local maxNum = 5
    local diffSize = 10
    for i=1,maxNum do
        local cell = self.innerSv:getChildByTag(i + 100)
		local cellBg
		if not cell then
			local cellNode = cc.CSLoader:createNode('csb/explorcell.csb')
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

        local awardNode = cellBg:getChildByName('awardNode')
        local disPlayData = DisplayData:getDisplayObjs(dfrelicCfg[self.relicId]['advancedAward' .. i])
        if #disPlayData == 1 then
            local awards = disPlayData[1]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardNode)
            cell.awardBgImg:setSwallowTouches(false)
            cell.awardBgImg:setScale(0.8)
        end

        local infoTx = cellBg:getChildByName('info_text')
        local dragon = RoleData:getDragonById(dfrelicCfg[self.relicId].correlationId)
        if dragon then
            if  dragon:getLevel() >= i then
                infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR6'))
                infoTx:setColor(COLOR_TYPE.WHITE)
            else
                infoTx:setString(string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_EXPLOR7'),i,dfrelicCfg[self.relicId].dName))
                infoTx:setColor(COLOR_TYPE.RED)
            end
        end
    end

    local size = self.innerSv:getContentSize()
	if maxNum * size1.width > size.width then
		-- self.innerSv:setInnerContainerSize(cc.size(size.width,(5 * size1.height+(5-1)*8)))
        self.innerSv:setInnerContainerSize(cc.size((maxNum * size1.width+(maxNum-1)*diffSize),size.height))
	else
		self.innerSv:setInnerContainerSize(size)
	end

	local function getPos(i)
	    local size2 = self.innerSv:getInnerContainerSize()
		--return cc.p(size2.width - size1.width* i-diffSize*(i-1),0)
        return cc.p(size1.width* (i-1)+diffSize*i,0)
	end

	for i = 1,5 do
		local cell = self.innerSv:getChildByTag(i + 100)
		if cell then
			cell:setPosition(getPos(i))
		end
	end
end

return TerritorialWarsExplorUI