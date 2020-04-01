local TerritorialWarUI = class("TerritorialWar", BaseUI)

local gridRes = {
    selectRes = 'uires/ui/territorialwars/terwars_hex_select.png',
    normalRes = 'uires/ui/common/touming.png',
    mainroldRes = 'uires/ui/territorialwars/terwars_main_hero.png',
}

local stateImg = {
    occupy = 'uires/ui/territorialwars/terwars_occupy.png',   
    plunder = 'uires/ui/territorialwars/terwars_plunder.png',
}

local opacityImg = {
    open = 'uires/ui/territorialwars/terwars_kai.png',   
    close = 'uires/ui/territorialwars/terwars_guan.png',
}

local partimg = {
    red = 'uires/ui/territorialwars/terwars_hongdi.png',   
    blue = 'uires/ui/territorialwars/terwars_landi.png',
}

local asyncImg = {
    'uires/ui/territorialwars/terwars_map_bg.jpg',
    'uires/ui/territorialwars/terwars_function_btn.png',
    'uires/ui/territorialwars/terwars_material_btn.png',
    'uires/ui/territorialwars/terwars_jilu.png',
    'uires/ui/territorialwars/terwars_paihang.png',
    'uires/ui/mainscene/mainscene_hc_nor_btn.png',
    'uires/ui/territorialwars/terwars_hex_select.png',
    'uires/ui/territorialwars/terwars_hex_normal.png',
    'uires/ui/territorialwars/terwars_main_hero.png',
    'uires/ui/territorialwars/terwars_red.png',
    'uires/ui/territorialwars/terwars_green.png',
    'uires/ui/common/touming.png',
    'uires/ui/territorialwars/terwars_footprint.png',
    'uires/ui/battle/plist/battle_hero_hp_3.png',
    'uires/ui/battle/plist/battle_hero_hp_4.png',
    'uires/ui/battle/plist/battle_hero_hp_1.png',
}

local scheduler = cc.Director:getInstance():getScheduler()
function TerritorialWarUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.TERRITORIAL_WARS)
end

function TerritorialWarUI:ctor(data,callback)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_UI
    self.allBgId = {}
    TerritorialWarMgr.mapClose = false
    self.data = data

    -- 开放的cell
    self.openCells = {}

    self.clouds = {}
    self.showClouds = true
    self.isHideBtn = false
    self.isBtnActionEnd = true
    self.cellIdPairs = {}

    self.viewRange = tonumber(GameData:getConfData('dfbasepara').fogOpenRange.value[1])
    self.open = false
    self.loadFinish = false
    self.callback = callback
end

function TerritorialWarUI:isLoadFinish()
    return self.loadFinish
end

-- 建立格子id与位置的对应表
function TerritorialWarUI:initPosCellPairs()
    local fogConf = GameData:getConfData('dffogconf')

    self.horizontalDis = self.cellHeight * math.cos(self.slopRad) + 20
    self.verticalDis = self.cellHeight * math.sin(self.slopRad) - 2

    self.posCellTab = {}
    for k, v in pairs(fogConf) do
        local key = v.pos[1] .. '_' .. v.pos[2]
        self.posCellTab[key] = {}
        self.posCellTab[key].cellId = k

        local horizontalIndex,verticalIndex = v.pos[1], v.pos[2]

        local offsetX = (horizontalIndex-1)*self.horizontalDis 
        local offsetY = (horizontalIndex-1)*self.verticalDis

        local centerX = math.sin(self.slopRad)*self.cellHeight*(verticalIndex-1) +  offsetX
        local centerY = math.cos(self.slopRad)*self.cellHeight*(verticalIndex-1) +  offsetY
        
        self.posCellTab[key].pos = cc.p(centerX, centerY)

        if v.relativeId ~= 0 then
            self.cellIdPairs[v.relativeId] = k
        end
    end
end

-- 从元素格子id获取雾的格子id
function TerritorialWarUI:getFogCellIdFromElement(cellId)
    if self.cellIdPairs[cellId] then
        return self.cellIdPairs[cellId]
    end
    
    return 0
end

function TerritorialWarUI:isCellCanClick(cellId)
    -- 首先判断是否在雾的配置里有这个格子，如果没有就是可以点的
    local gridConf = GameData:getConfData('dfmapgrid')
    local cellInfo = gridConf[cellId]
    local fogCellId = self:getCellIdByPos(cellInfo.pos[1], cellInfo.pos[2])
    if fogCellId == 0 then
        return true
    end

    local fogCellId = self:getFogCellIdFromElement(cellId)
    if self.openCells[fogCellId] then
        return true
    end

    return false
end

function TerritorialWarUI:getViewListCell(x, y, range)
    local num = 0
	local cellList = {}
	for i = 1, range do
		if i ~= range then
			num = num + 1
			cellList[num] = {x+i,y}
			num = num + 1
			cellList[num] = {x-i,y}
		end

		if i == range then
			for k = -range + 1, range - i - 1 do
				num = num + 1
				cellList[num] = {x+k ,y+i}
			end
			for k = -range + i + 1, range - 1 do
				num = num + 1
				cellList[num] = {x + k, y - i}
			end
		else
			for k = -range, range - i do
				num = num + 1
				cellList[num] = {x+k ,y+i}
			end
			for k = -range + i, range do
				num = num + 1
				cellList[num] = {x+k, y-i}
			end
		end
	end

	return cellList
end

function TerritorialWarUI:runActivityBtns(callback)
    local size = self.bgImg:getContentSize()
    local size1 = self.bottomPl:getContentSize()
    local maxNum = 4
    self.isBtnActionEnd = false
    local pos1 = cc.p(size1.width + size.width +5,45)
    local pos2 = cc.p(size1.width,45)
    if not self.isHideBtn then
        self.bgImg:setPosition(pos1)
        self.bgImg:runAction(cc.Sequence:create(cc.MoveTo:create(maxNum * 0.1,pos2),cc.CallFunc:create(function()
            self.isBtnActionEnd = true
            if callback then
                callback()
            end
        end)))
    else
        self.bgImg:setPosition(pos2)
        self.bgImg:runAction(cc.Sequence:create(cc.MoveTo:create(maxNum * 0.1,pos1),cc.CallFunc:create(function()
            self.isBtnActionEnd = true
            if callback then
                callback()
            end
        end)))
    end
end
function TerritorialWarUI:enter()

    -- 脥酶赂帽虏茫碌脛脳卯赂脽Zorder
    self.gridTopZorder = 1

    -- 脝脕脛禄脰脨脨脛碌茫
    local winSize = cc.Director:getInstance():getWinSize()
    self.screenCenterPoint = cc.p(winSize.width/2, winSize.height/2)

    self.bottomPl = self.uiLayer:getChildByName('bottom_pl')
    self.bgImg = self.bottomPl:getChildByName('bg_img')
    self.newImgs = {}
    local bossBtn = self.bgImg:getChildByName('boss_btn')
    local functionBtn = self.bgImg:getChildByName('function_btn')
    self.newImgs[2] = functionBtn:getChildByName('new_img')
    local materialBtn = self.bgImg:getChildByName('material_btn')
    self.newImgs[1] = materialBtn:getChildByName('new_img')
    local reportBtn = self.bgImg:getChildByName('report_btn')
    self.newImgs[3] = reportBtn:getChildByName('new_img')
    local rankBtn = self.bgImg:getChildByName('rank_btn')
    local backCity = self.uiLayer:getChildByName('city_btn')
    local fieldBg = self.uiLayer:getChildByName('field_bg')
    local helpbtn = self.uiLayer:getChildByName('help_btn')
    local addbtn = self.uiLayer:getChildByName('add_btn')
    self.newImgs[4] = addbtn:getChildByName('new_img')
    local mapBtn = self.uiLayer:getChildByName('map_btn')
    local locationBtn = self.uiLayer:getChildByName('location_btn')
    local opacityBtn = fieldBg:getChildByName('opacity_btn')
    local raidsBtn = self.uiLayer:getChildByName('raids_btn')
    self.moveBtn = self.uiLayer:getChildByName('move_btn')
    self.moveBtn:setVisible(false)
    self.invadeImg = self.uiLayer:getChildByName('invade_img')
    local actionBg = self.moveBtn:getChildByName("action_bg")
    self.actionNum = actionBg:getChildByName("num")
    
    self.achievetab = {}
    bossBtn:loadTextures('uires/ui/territorialwars/terwars_boss.png','','')
    functionBtn:loadTextures('uires/ui/territorialwars/terwars_function_btn.png','','')
    materialBtn:loadTextures('uires/ui/territorialwars/terwars_material_btn.png','','')
    reportBtn:loadTextures('uires/ui/territorialwars/terwars_jilu.png','','')
    rankBtn:loadTextures('uires/ui/territorialwars/terwars_paihang.png','','')
    backCity:loadTextures('uires/ui/mainscene/mainscene_hc_nor_btn.png','','')
    locationBtn:loadTextures('uires/ui/territorialwars/terwars_dingwei.png','','')
    mapBtn:loadTextures('uires/ui/territorialwars/terwars_map_btn.png','','')
    addbtn:loadTextures('uires/ui/buoy/add_nor_btn.png','','')
    raidsBtn:loadTextures('uires/ui/territorialwars/terwars_saodang.png','','')
    self.footImg = "uires/ui/territorialwars/terwars_footprint.png"
    self.flagImg = "uires/ui/territorialwars/terwars_flag.png"
    for i=1,2 do
        local acheveBg = self.uiLayer:getChildByName('acheve_' .. i)
        local text =  acheveBg:getChildByName('title_tx')
        local titleTx = acheveBg:getChildByName("title_tx")
        titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_ACHIEVE' .. i))
        local proTx = acheveBg:getChildByName("pro_tx")
        proTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT44'))
        local partImg = acheveBg:getChildByName("part_img")
        local partTx = partImg:getChildByName("part_tx")
        local partRes = (i == 1) and partimg.red or partimg.blue
        partImg:loadTexture(partRes)
        local parttext = (i == 1) and GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT36') or GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT43')
        partTx:setString(parttext)
        local proNumTx = acheveBg:getChildByName("pro_num")
        self.achievetab[i] = {}
        self.achievetab[i].bg = acheveBg
        self.achievetab[i].text = proNumTx
        self.achievetab[i].achType = 100+i

        self.achievetab[i].bg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:showAchieveUI(i)
            end
        end)
    end
    
    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setContentSize(cc.size(300, 30))
    local re = xx.RichTextLabel:create('',24,COLOR_TYPE.GREEN)
    re:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF10'),24,COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    local fieldBgSize = fieldBg:getContentSize()
    richText:setPosition(cc.p(fieldBgSize.width*0.5,fieldBgSize.height*0.5))
    fieldBg:addChild(richText)
    self.legionwarName = {richText = richText,re = re,re1 = re1}

    local size = functionBtn:getContentSize()

    local size1 = addbtn:getContentSize()
    self.bottomPl:setPosition(cc.p(winSize.width-size1.width/2,0))
    fieldBg:setPosition(cc.p(1,size.height*5.4))
    
    addbtn:setPosition(cc.p(winSize.width - size1.width/2,45))
    locationBtn:setPosition(cc.p(winSize.width - size1.width/2-10,size1.height+20))
    mapBtn:setPosition(cc.p(winSize.width - size1.width/2-10,size1.height*3 - 30))
    raidsBtn:setPosition(cc.p(winSize.width - size1.width/2-10,size1.height*2))

    for i=1,2 do
        self.achievetab[i].bg:setPosition(cc.p(winSize.width - size1.width,size.height*5.4 - (i-1)*62))
    end

    self.invadeImg:setPosition(cc.p(winSize.width - size1.width/2-20,size1.height*4 - 85))
    self.moveBtn:setAnchorPoint(cc.p(0.5,0.5))
    self.moveBtn:setPosition(cc.p(winSize.width/2,size1.height+20))

    addbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if not self.isBtnActionEnd then
                return
            end
            self.isHideBtn = not self.isHideBtn
            self:updateNewImgs()
            self:runActivityBtns(function()
                if self.isHideBtn then
                    addbtn:loadTextures('uires/ui/buoy/less_nor_btn.png','','')
                else
                    addbtn:loadTextures('uires/ui/buoy/add_nor_btn.png','','')
                end
            end)
        end
    end)

    local helpSize = helpbtn:getContentSize()
    helpbtn:setPosition(cc.p(winSize.width - helpSize.width*0.5,winSize.height-helpSize.height/2 - 50))
    -- 战报
    reportBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showReportUI()
        end
    end)

    self.clickBackCity = false
    --禄脴鲁脟
    backCity:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('leave','territorywar',json.encode({}),function (response)
                local code = response.code
                if code ~= 0 then
                    TerritorialWarMgr:handleErrorCode(code)
                    return
                end 
                if self.moveFurther then
                    local function callback()
                        TerritorialWarMgr:setBattleEnd(nil,nil,nil)
                        TerritorialWarMgr:hideMapUI()
                    end
                    self.stopMove = true
                    self.clickBackCity = true
                else
                    TerritorialWarMgr:setBattleEnd(nil,nil,nil)
                    TerritorialWarMgr:hideMapUI()
                end
            end)
        end
    end)

    bossBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showBossListUI()
        end
    end)

    --排行榜
    rankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain(10,nil,{10,11})
        end
    end)
    
    --鹿娄脛脺
    functionBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showFuncUI(1)
        end
    end)

    --虏脛脕脧
    materialBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showMaterialUI()
        end
    end)
    
    --帮助
    helpbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	--HelpMgr:showHelpUI(HELP_SHOW_TYPE.TERRITORIALWAR_HELP)
            TerritorialWarMgr:showRuleBookUI()
		end
	end)

    --定位
    locationBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self:locationPos()
		end
	end)

    --扫荡
    raidsBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local needLv = tonumber(GlobalApi:getGlobalValue('sweepLevel'))
            local level = UserData:getUserObj():getLv()
            if level < needLv then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),needLv), COLOR_TYPE.RED)
                return
            end
			local conf = GameData:getConfData("dfmapgrid")
			local conf1 = GameData:getConfData("dfelement")
			local awardIds = {}
			for i,v in ipairs(conf) do
				if v.immobilizationElement ~= '' and not self.visitedRes[tostring(v.id)] then
					local tab = string.split(v.immobilizationElement,'.')
					if tab[1] == 'element' and conf1[tonumber(tab[2])].isCost == 1 then
						awardIds[tab[2]] = (awardIds[tab[2]] or 0) + 1
					end
				end
			end
			local awards = {}
			for k,v in pairs(awardIds) do
				local award = DisplayData:getDisplayObj(conf1[tonumber(k)].award[1])
				local num = award:getNum() * v
				award:setNum(num)
				awards[#awards + 1] = award
			end
			if #awards <= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORIALWAR_GET_ALL_DESC_1'), COLOR_TYPE.RED)
			else
				TerritorialWarMgr:showTerritoralwarGetAll(awards,self.notMyHome,function()
					TerritorialWarMgr:updateMapInfo()
				end)
			end
        end
    end)

    --小地图
    mapBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local cellId = (self.BossInfo and self.BossInfo._cellId) and self.BossInfo._cellId or nil
            TerritorialWarMgr:showSmallMapUI(self.openCells,self.posCellTab,self.territoryWar,self.hextab,self.curHexPos,self.otherObj,cellId)
        end
    end)

    --屏蔽按钮
    local flag = TerritorialWarMgr:getOpactityFlag()
    local img = flag and opacityImg.close or opacityImg.open
    opacityBtn:loadTextureNormal(img)
    opacityBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then 
           local flag = TerritorialWarMgr:getOpactityFlag()
           flag = not flag
           TerritorialWarMgr:setOpactityFlag(flag)
           local str = flag and GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG16') or GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG17')
           promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
           local imag = flag and opacityImg.close or opacityImg.open
           opacityBtn:loadTextureNormal(imag)
           self:setViewPlayerOpacity()
        end
    end)

    local count = math.floor(self.mapBlockHeight/winSize.height)
    local mod  = math.mod(self.mapBlockHeight,winSize.height)
    self.loactionPos = cc.p(0,-((count-1)*winSize.height+mod))

    self.currScale = tonumber(GameData:getConfData('dfbasepara').mapscale.value[1])
    self:setLimit(self.currScale)
    self.mapBlockArr = {}

    self.resType = {
        element = 1,
        creature = 2,
        mine = 3,
        boss = 4,
    }

    for i = 1, self.mapBlockCountMaxX do
        self.mapBlockArr[i] = {}
    end

    UIManager:showSidebar({1,4,6},{3,14,15},true)
    
    self.loadFinish = true
    TerritorialWarMgr:processCacheMsg(self.data)
    self:setData(self.data.territoryWar,self.data.territoryData,self.data.playerList, self.data.enemies, self.data.stele, self.data.visitedCells, false)
    
    self:updateNewImgs()
    self:setGateName()
    TerritorialWarMgr:updateAfterLoading()
    self:_onShowUIAniOver()
    if self.callback then
        self.callback()
    end
end

function TerritorialWarUI:initLoading()

    self.jsonLoaded = {}
    self.plistLoaded = {}
    local winSize = cc.Director:getInstance():getVisibleSize()
    local loadingUI,loadingPanel
    loadingUI = require ("script/app/ui/loading/loadingui").new(2)
    loadingPanel = loadingUI:getPanel()
    loadingPanel:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.root:addChild(loadingPanel, 9999)
    self.loadingUI = loadingUI

    --加载资源路径
    self:loadMapResUIR()

    local loadedImgCount = 0
    local loadedImgMaxCount = #asyncImg+#self.animationMap
    local function imageLoaded(texture)
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        self.loadingUI:setPercent(loadingPercent)
        if loadedImgCount >= #asyncImg then
            self:loadAnimationRes(loadedImgCount,loadedImgMaxCount)
        end
    end

    for i=1,#asyncImg do
        if asyncImg[i] then
            cc.Director:getInstance():getTextureCache():addImageAsync(asyncImg[i],imageLoaded)
        end
    end
      
end

--加载地图资源URL
function TerritorialWarUI:loadMapResUIR()

    self.animationMap = {}
    local dfmapcreatureCfg = GameData:getConfData("dfmapcreature")
    for i=1,#dfmapcreatureCfg do
        local combatId = dfmapcreatureCfg[i].combatId
        local fomationConfig = GameData:getConfData("formation")[combatId]
        local monsterId = fomationConfig['pos'..fomationConfig.boss]
        local monsterConfig = GameData:getConfData("monster")[monsterId]
        local name = monsterConfig.url .. "_display"
        local url = "animation_littlelossy/" .. name .. "/" .. name
        self.animationMap[#self.animationMap+1] = url
    end

    local dfmapmineConfig = GameData:getConfData("dfmapmine")
    for i=1,#dfmapmineConfig do
        local name = dfmapmineConfig[i].url
        local url = "animation_littlelossy/" .. name .. "/" .. name
        self.animationMap[#self.animationMap+1] = url
    end

    local dfelementConfig = GameData:getConfData("dfelement")
    for i=1,#dfelementConfig do
        local name = dfelementConfig[i].url
        local url = "animation_littlelossy/" .. name .. "/" .. name
        self.animationMap[#self.animationMap+1] = url
    end
end

function TerritorialWarUI:loadAnimationRes(loadedImgCount,loadedImgMaxCount)

    local totalCount = #self.animationMap 
    local countPerFrame = math.ceil(totalCount/30)
    local loadedCount = 0
    local count = 0
    local co = coroutine.create(function ()
        for k, v in pairs(self.animationMap) do
            local url = v
            if self.plistLoaded[url] == nil then
                self.plistLoaded[url] = true
                cc.SpriteFrameCache:getInstance():addSpriteFrames(url .. ".plist")
            end
            if self.jsonLoaded[url] == nil then
                self.jsonLoaded[url] = true
                count = count + 1
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(url .. ".json")
            end
            loadedCount = loadedCount + 1
            if loadedCount%countPerFrame == 0 then
                coroutine.yield()
            end
        end
    end)

    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self.loadingUI:setPercent((loadedImgCount+loadedCount)/loadedImgMaxCount*90)
        if not coroutine.resume(co) then
            self.root:unscheduleUpdate()
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                local function callback()
                    self:enter()
                    local ntype,win,cost = TerritorialWarMgr:getBattleEnd() 
                    if ntype ~= nil and ntype == 1 or ntype == 3 then
                        TerritorialWarMgr:showMsgUI(ntype,win,cost)
                    end
                end
                UIManager:removeLoadingAction()
                self.loadingUI:runToPercent(0.2, 100, function ()
                    self.loadingUI:removeFromParent()
                    self.loadingUI = nil
                    callback()
                end)
            end)))
        end
    end, 0)
end

function TerritorialWarUI:init()
    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            TerritorialWarMgr.mapClose = true
        end
    end)
    self.posArr = {}
    self.posArr[1] = {0, -1}
    self.posArr[2] = {0, 1}
    self.posArr[3] = {-1, 0}
    self.posArr[4] = {1, 0}
    self.posArr[5] = {1, -1}
    self.posArr[6] = {-1, 1}

    self.mapContainer = self.root:getChildByName('map_container')
    self.bgLayer = self.mapContainer:getChildByName('bg_layer')
    self.resLayer = self.mapContainer:getChildByName('res_layer')
    self.gridLayer = self.mapContainer:getChildByName('grid_layer')
    self.effectLayer = self.mapContainer:getChildByName('effect_layer')
    self.uiLayer = self.root:getChildByName('ui_layer')
    
    self.mapBlockWidth = 2487   -- 脪禄赂枚碌脴脥录驴茅碌脛驴铆露脠
    self.mapBlockHeight = 2315
    self.mapBlockCountMaxX = 1  -- 潞谩脧貌脳卯露脿露脿脡脵赂枚碌脴脥录驴茅
    self.mapBlockCountMaxY = 1  -- 脳脻脧貌脳卯露脿碌脴脥录驴茅脢媒脕驴
    
    self.slopAngle = 20         -- 脰卤脧脽脟茫脨卤陆脟
    self.slopRad = 3.1415926/(180/self.slopAngle)        --脰卤脧脽脨卤脗脢

    self.gidConfig = GameData:getConfData("dfmapgrid")
    self.paramConfig = GameData:getConfData("dfbasepara")

    self.hextab = {}            --碌脴脥录驴茅脳茅
    self.cellHeight = 45        -- 脡猫脰脙脕霉卤脽脨脦碌脛赂脽
    self.aroundHex = {}
    self.curHexPos = {}
    self.moving = false
    self.otherObj = {}
    self.OpacityPlayer = {}
    self.paintedHex = {}
    self.oldcellId = nil
    self.element = {}
    self.elementData = {}
    self.legionwarName = {}

    self:initHexTab()

    -- 录脟脗录脩隆脰脨
    self.lastSelectBlockIndexX = nil                --碌脴脥录驴茅脨猫脫脜禄炉脡戮鲁媒
    self.lastSelectBlockIndexY = nil
    self:initLoading()
    self:initPosCellPairs()
    self.open = true
end

-- 根据坐标位置获取格子cellID
function TerritorialWarUI:getCellIdByPos(x, y)
    local key = x .. '_' .. y
    if self.posCellTab[key] == nil then
        return 0
    end

    return self.posCellTab[key].cellId
end

function TerritorialWarUI:getCellPos(x, y)
    local key = x .. '_' .. y
    if self.posCellTab[key] == nil then
        return 0
    end

    return self.posCellTab[key].pos
end

function TerritorialWarUI:initOpenCells(curLid, visitCells)
    if visitCells == nil then
        return
    end

    if visitCells[tostring(curLid)] == nil then
        return
    end

    local gridFogConf = GameData:getConfData('dffogconf')
    local gridConf = GameData:getConfData('dfmapgrid')

    self.openCells = {}
    self:clearClouds()

    local selfLid = UserData:getUserObj():getLid()
    if curLid == selfLid then
        -- 在自己领地，默认开一片雾
        local range = GameData:getConfData('dfbasepara').openFogId.value
        local startCell = tonumber(range[1])
        local endCell = tonumber(range[2])

        for i = startCell,endCell do
            self.openCells[i] = i
        end
    end

    for k, v in pairs(visitCells[tostring(curLid)]) do
        local viewRange = self.viewRange
        local cellInfo = gridConf[tonumber(v)]
        if cellInfo and cellInfo.immobilizationElement == 'element.7' and curLid == selfLid then
            -- 瞭望塔，自己领地的瞭望塔才有用
            viewRange = tonumber(GameData:getConfData('dfbasepara').watchTowerOpenRange.value[1])
        end

        local fogCellId = self:getFogCellIdFromElement(tonumber(v))
        if fogCellId  > 0 then
            self.openCells[fogCellId] = fogCellId
            local fogCellInfo = gridFogConf[fogCellId]
            local openCellList = self:getViewListCell(fogCellInfo.pos[1], fogCellInfo.pos[2], viewRange)
            for k1, v1 in pairs(openCellList) do
                local cellId = self:getCellIdByPos(v1[1], v1[2])
                self.openCells[cellId] = cellId
            end
        else
            if cellInfo then
                local openCellList = self:getViewListCell(cellInfo.pos[1], cellInfo.pos[2], viewRange)
                for k1, v1 in pairs(openCellList) do
                    local cellId = self:getCellIdByPos(v1[1], v1[2])
                    self.openCells[cellId] = cellId
                end
            end
        end
    end
end

-- 清理掉所有地图背景
function TerritorialWarUI:clearAllMaps()
    for i = 1, 25 do
        if self.mapContainer:getChildByTag(i + 1000) then
            self.mapContainer:removeChildByTag(i + 1000)
        end
    end
end

function TerritorialWarUI:clearAllElements()
    for k, v in pairs(self.element) do
        if v._spine then 
            v._spine:removeFromParent()
        end

        if v.bg then
            v.bg:removeFromParent()
        end
        if self.resBlock:getChildByTag(k + 1000) then
            self.resBlock:removeChildByTag(k + 1000)
        end
    end

    self.element = {}
    self.elementData = {}
end

function TerritorialWarUI:setData(territoryWar, territoryData, playerList, enemies, stele, visitedCells, update)
    
    playermap:clear()
    self:clearAllMaps()
    self:clearAllElements()
    self.loadFinish = true
    self:clearAroundCells()

    self.territoryWar = territoryWar                  --脕矛碌脴脮陆碌脛陆莽脙忙脥鲁录脝脢媒戮脻拢篓ex:鲁脡戮脥拢漏
    self.territoryData = territoryData                --脕矛碌脴脮陆碌脛碌脴脥录脢媒戮脻拢篓ex拢潞赂帽脳脫脨脜脧垄拢漏
    self.playerList = playerList                      --脣霉麓娄碌脴脥录碌脛脥忙录脪脨脜脧垄
    self.enemies = enemies
    self.stele = stele                                  -- 路脙脦脢碌脛脢炉卤庐
    self.visitedCells = visitedCells
    self.curLid = tonumber(self.territoryWar.pos.lid) --脥忙录脪碌卤脟掳碌脴脥录脣霉脢么戮眉脥脜id

    self.visitedRes = self.territoryWar.visitedResList.self             --脪脩路脙脦脢碌脛脳脢脭麓脕脨卤铆拢卢掳眉脌篓脪脩脗脫露谩碌脛驴贸碌茫
    self.occupyMine =  self.territoryData.mine        -- 录潞路陆戮眉脥脜脮录脕矛碌脛驴贸

    local dfbaseparaCfg = GameData:getConfData('dfbasepara')
    self.legionNumLimit = tonumber(dfbaseparaCfg['legionNumLimit'].value[1])       --戮眉脥脜禄楼脥篓脢媒脕驴脧脼脰脝拢篓脳卯露脿3赂枚戮眉脥脜禄楼脥篓拢漏
    self.invadeLimit = tonumber(dfbaseparaCfg['invadeLimit'].value[1])             --脠毛脟脰脨猫脟贸路脙脦脢脢炉卤庐脧脼脰脝

    self.message_update = true

    local selfLid = UserData:getUserObj():getLid()
    local enemyId = 0
    if self.curLid ~= selfLid and self.enemies ~= nil then
        for k,v in ipairs(self.enemies) do
            if tonumber(v) == self.curLid then
                enemyId = k
            end
        end
    end

    if enemyId ~= 0 then
        self.visitedRes = self.territoryWar.visitedResList['enemy' .. tostring(enemyId)]
        self.notMyHome = true
    end

    -- 初始化哪些格子开启了
    self:initOpenCells(self.curLid, self.visitedCells)

    if self.legionwarName ~= nil then
        if self.curLid == selfLid  then
            self.legionwarName.re:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF11'))
            self.legionwarName.re:setColor(COLOR_TYPE.GREEN)
            self.legionwarName.richText:format(true)
        else
            self.legionwarName.re:setString(self.territoryData.legionName)
            self.legionwarName.re:setColor(COLOR_TYPE.RED)
            self.legionwarName.richText:format(true)
        end
    end


    if update == true then
        local center_pos = self:convertScreenLocationToMap(self.screenCenterPoint)
        local indexX, indexY = self:getBlockIndexByPosition(center_pos)
        local effectBlock = self.mapBlockArr[indexX][indexY].effect
        self.flagPic = nil
        self.resBlock:removeAllChildren()
        self:refreshCharacters() 
        self:refreshClouds(effectBlock)
    elseif update == false then
        local startPos = self:convertScreenLocationToMap(self.screenCenterPoint)
        self:refreshWorldMap(startPos)
    end
    
    
    self.achievementAwardGetRecord = self.territoryWar.achievementAwardGetRecord
    self:updateWeekAchieve()
    self:createBgByPos()

    --不需要切图加载
    local cells = self.territoryData.cells
    for k,v in pairs(cells) do 
        local cellId = tonumber(k)
        if v.resType == self.resType.boss then
            self:createMapBoss(v,cellId)
        elseif v.resType == self.resType.creature then
            self:createMonster(cellId, v, self.resBlock)
        elseif v.resType == self.resType.mine then
            self:createMine(cellId, v, self.resBlock)
        end
    end

end

function TerritorialWarUI:updateNewImgs()
    local visible1 = TerritorialWarMgr:getMaterialNewImg()
    local visible2 = TerritorialWarMgr:getAllFuncNewImg()
    self.newImgs[1]:setVisible(visible1)
    self.newImgs[2]:setVisible(visible2)
    self.newImgs[3]:setVisible(false)
    self.newImgs[4]:setVisible((visible1 or visible2) and self.isHideBtn)
end

function TerritorialWarUI:onShow()
    self.open = true
    self:updateNewImgs()
    UIManager:showSidebar({1,4,6},{3,14,15},true)
end

--脰脴脰脙卤脽陆莽脰碌
function TerritorialWarUI:setLimit(scale1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local point = self.mapContainer:getAnchorPoint()
    local scale = scale1
    if not scale then
        scale = self.currScale
    end

    self.mapContainer:setScale(scale)

    self.limitLW = winSize.width - self.mapBlockWidth * self.mapBlockCountMaxX * scale * (1 - point.x)
    self.limitRW = point.x
    self.limitUH = point.y
    self.limitDH = winSize.height - self.mapBlockHeight * self.mapBlockCountMaxY * scale * (1 - point.y)
end

--卤脽陆莽录矛虏芒
function TerritorialWarUI:detectEdges( point )
    if point.x > self.limitRW then
        point.x = self.limitRW
    end
    if point.x < self.limitLW then
        point.x = self.limitLW
    end
    if point.y > self.limitUH then
        point.y = self.limitUH
    end
    if point.y < self.limitDH then
        point.y = self.limitDH
    end
end

-- 脭脷脰赂露篓脦禄脰脙麓麓陆篓脪禄赂枚脳脢脭麓
function TerritorialWarUI:createMapRes(mapPos, resInfo)
    local indexX, indexY = self:getBlockIndexByPosition(mapPos)
    local blockPosX, blockPosY = self.mapBlockArr[indexX][indexY].res:getPosition()
    local resPos = cc.p(mapPos.x - blockPosX, mapPos.y - blockPosY)

    local resType = 'food.png'
    if math.random(1, 2) > 1.5 then
        resType = 'wood.png'
    end

    local newRes = ccui.ImageView:create('uires/ui/territorialwars/terwars_' .. resType)
    newRes:setAnchorPoint(cc.p(0.5, 0.5))
    newRes:setPosition(resPos)
    self.mapBlockArr[indexX][indexY].res:addChild(newRes)
end

function TerritorialWarUI:createBgByPos(pos)
    local index = 0
    for i=1,25 do
        if self.allBgId[i] then
            index = index + 1
        end
    end
    if index >= 25 then
        return
    end
    local posX,posY
    if pos then
        posX,posY = pos.x,pos.y
    else
        posX,posY = self.mapContainer:getPosition()
    end
    local anchor = self.mapContainer:getAnchorPoint()
    local leftBottomPosX,leftBottomPosY = math.abs(posX - 2560*anchor.x * self.currScale),math.abs(posY - 2560*anchor.y * self.currScale)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local points = {
        cc.p(leftBottomPosX, leftBottomPosY + winSize.height), -- 脳贸脡脧
        cc.p((leftBottomPosX + winSize.width), leftBottomPosY + winSize.height),
        cc.p(leftBottomPosX, leftBottomPosY),
        cc.p(leftBottomPosX + winSize.width, leftBottomPosY),
    }
    local function getBg(point)
        local blockSize = 512 * self.currScale
        local x = (point.x - point.x%blockSize)/blockSize + 1
        local y = (point.y - point.y%blockSize)/blockSize + 1
        return (5 - y)*5 + x
    end
    local ids = {}
    for i,v in ipairs(points) do
        local bgId = getBg(v)
        ids[i] = bgId
    end
    local newIds = {}
    local leftIds = {}
    local rightIds = {}
    for i=ids[1],ids[3],5 do
        leftIds[#leftIds + 1] = i
    end
    for i=ids[2],ids[4],5 do
        rightIds[#rightIds + 1] = i
    end
    for i,v in ipairs(leftIds) do
        for j=v,rightIds[i] do
            newIds[#newIds + 1] = j
            if j >= 1 and j <= 25 then
                local bgImg = self.mapContainer:getChildByTag(j + 1000)
                if not bgImg then
                    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/territorialwars/terwars_df_'..j..'.jpg',function(texture)
                        local function getBgPos(i)
                            local index = (5 - math.floor((i - 1)/5 + 1))*5+(i - 1)%5 + 1
                            local posX = (math.floor((index - 1)%5 + 1) - 1)*512 + 256
                            local posY = (math.ceil(index/5) - 1)*512 + 256
                            return cc.p(posX,posY)
                        end
                        if TerritorialWarMgr.mapClose == true then
                            return
                        end
                        local img = ccui.ImageView:create('uires/ui/territorialwars/terwars_df_'..j..'.jpg')
                        local pos = getBgPos(j)
                        img:setPosition(pos)
                        self.mapContainer:addChild(img,2,j+1000)
                        self:refreshRes(j)
                        self.allBgId[j] = 1
                    end)
                end
            end
        end
    end
end

-- 录脫脭脴脪禄驴茅碌脴脥录
function TerritorialWarUI:loadMapBlock(pos)
    local newMapBlock = {}
    -- 背景图
    local newBlockBg = ccui.ImageView:create('uires/ui/territorialwars/terwars_map_bg.jpg')
    newBlockBg:setAnchorPoint(cc.p(0,0))
    newBlockBg:setPosition(cc.p(pos.x,pos.y))
    newBlockBg:setTouchEnabled(true)
    newBlockBg:setScale(5)
    self.bgLayer:addChild(newBlockBg)
    self.bgLayer:setLocalZOrder(1)
    newMapBlock.bg = newBlockBg

    -- 脥酶赂帽虏茫
    local newBlockGrid = cc.DrawNode:create()
    newBlockGrid:setContentSize(newBlockBg:getContentSize())
    newBlockGrid:setAnchorPoint(cc.p(0, 0))
    newBlockGrid:setPosition(pos)
    self.gridLayer:addChild(newBlockGrid)
    newMapBlock.grid = newBlockGrid
    self.gridLayer:setLocalZOrder(3)
    self.blockgrid = newBlockGrid                           --底层格子

    -- 脳脢脭麓虏茫
    local newBlockRes = cc.Node:create()
    newBlockRes:setPosition(pos)
    self.resLayer:addChild(newBlockRes,1)
    newMapBlock.res = newBlockRes
    self.resBlock = newBlockRes                             --资源点

    self:refreshCharacters()

    self.resLayer:setLocalZOrder(4)
    -- 脤脴脨搂虏茫
    local newBlockEffect = cc.Node:create()
    newBlockEffect:setPosition(pos)
    self.effectLayer:addChild(newBlockEffect)
    newMapBlock.effect = newBlockEffect
    self.effectLayer:setLocalZOrder(6)
    self:refreshClouds(newBlockEffect)

    local mapContainerPrePos = nil
    local mapContainerPos = nil
    local mapContainerDiffPos = nil
    local cliclBeginPos = nil   -- 碌茫禄梅驴陋脢录脳酶卤锚
    newBlockBg:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            -- 脥脧露炉碌脴脥录
            mapContainerPrePos = mapContainerPos
            mapContainerPos = sender:getTouchMovePosition()
            if mapContainerPos and mapContainerPrePos then
                mapContainerDiffPos = cc.p(mapContainerPos.x - mapContainerPrePos.x, mapContainerPos.y - mapContainerPrePos.y)
                local targetPos = cc.pAdd(cc.p(self.mapContainer:getPositionX(),self.mapContainer:getPositionY()),mapContainerDiffPos)

                self:detectEdges(targetPos)
                self.mapContainer:setPosition(targetPos)
                
                local centerPos = self:convertScreenLocationToMap(self.screenCenterPoint)
                self:refreshWorldMap(centerPos)
            end
        else
            mapContainerPrePos = nil
            mapContainerPos = nil
            mapContainerDiffPos = nil

            -- 碌茫禄梅脢脗录镁
            if eventType == ccui.TouchEventType.began then
                cliclBeginPos = sender:getTouchBeganPosition()
            elseif eventType == ccui.TouchEventType.ended then
                local clickScreenPos = sender:getTouchEndPosition()
                self:createBgByPos()
                if self:distance2(cliclBeginPos.x, cliclBeginPos.y, clickScreenPos.x, clickScreenPos.y) < 1000 then
                    local clickMapPos = self.mapContainer:convertToNodeSpace(clickScreenPos)

                    local cellPos = self:GetCell(clickMapPos.x, clickMapPos.y)
                    local indexX, indexY = self:getBlockIndexByPosition(clickMapPos)
                    self:selectCell(cellPos,indexX, indexY)
                end
            end
        end
    end)

    return newMapBlock
end

-- 卤锚录脟脩隆脰脨碌脛脕霉卤脽脨脦
function TerritorialWarUI:selectCell(cellPos, indexX, indexY)

    if indexX <= 0 or indexX > self.mapBlockCountMaxX or indexY <= 0 or indexY > self.mapBlockCountMaxY or self.moveFurther or self.moving then
        return
    end

    if self.hextab[cellPos.x] == nil or self.hextab[cellPos.x][cellPos.y] == nil then
        return
    end
    
    if self.curHexPos.horIndex == cellPos.x and self.curHexPos.verIndex == cellPos.y then
        return
    end

    local cellId = self.hextab[cellPos.x][cellPos.y]._cellId
    if self:isCellCanClick(cellId) == false then
        return
    end

    self.moveFurther = false
    self.moveBtn:setVisible(false)
    
    --清空上次路径
    if self.pathMark then
        for k,v in pairs(self.pathMark) do
            if v then
                v:removeFromParent(true)
            end
        end
        self.pathMark = {}
    end
    if self.flagPic then
        self.flagPic:setVisible(false)
    end

    local emptycell = self:isEmptyCell(cellId)
    if emptycell == true and self:CheckInAround(cellId) == true then

         local conf = GameData:getConfData('dfbasepara')
         local perCost = tonumber(conf['actionCost'].value[1])

         local curPoint = UserData:getUserObj():getActionPoint()
         curPoint = curPoint or 0
         if curPoint < perCost then
            local errStr = GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_229')
            promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
            return
         end
        self:Move(cellId)
    elseif emptycell == false and self.moving == false then
        if not self:existPlayer(cellId) then

            if self:existBoss(cellId) then
                self:showBossUI(cellId)
            else
                self:showElementVisitUI(cellId)
            end
        else
            self:showEnemyUI(cellId)
        end
    end

    --self:calculatePath(cellId)

    --隆媒隆媒隆媒隆媒隆媒隆媒隆媒碌茫禄梅虏禄脧脿脕脷碌脛赂帽脳脫隆媒隆媒隆媒隆媒隆媒隆媒隆媒
    self:DrawUnitHex(cellId,gridRes.selectRes)
    self.oldcellId = cellId

    self.lastSelectBlockIndexX = indexX
    self.lastSelectBlockIndexY = indexY

    self.mapBlockArr[indexX][indexY].grid:setLocalZOrder(self.gridTopZorder)
    self.gridTopZorder = self.gridTopZorder + 1

    if not emptycell or self:CheckInAround(cellId) then
        return
    end

    local success = self:findPath(self.mapBlockArr[indexX][indexY].grid,cellId)
    if success and #self.path >0 then  

        local conf = GameData:getConfData('dfbasepara')
        local perCost = tonumber(conf['actionCost'].value[1])
        local allCost = (#self.path-1)*perCost
        self.actionNum:setString(allCost)
        local curPoint = UserData:getUserObj():getActionPoint() or 0

        --标记路径
        self:markPath()
        self.moveBtn:setVisible(true)
        local text = self.moveBtn:getChildByName("text")
        text:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO43'))    
        self.moveBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if not self.longMoving then
                    self.stopMove = false
                    text:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO44'))
                    self.longMoving = true
                    self.moveFurther = true
                    self:longMove(#self.path-1,cellId)
                else
                   self.stopMove = true
                end
            end
        end)
        
        if self.flagPic then
            self.flagPic:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if not self.longMoving then
                        self.stopMove = false
                        text:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO44'))
                        self.longMoving = true
                        self.moveFurther = true
                        self:longMove(#self.path-1,cellId)
                    end
                end
            end)
        end
    end
end

function TerritorialWarUI:findPath(gridBlock,desCellId)

    local srX,srY = self.curHexPos.horIndex,self.curHexPos.verIndex
    local destPos = self:convertToHexPos(desCellId)
    
    if self.hextab[srX] == nil or self.hextab[srX][srY] == nil then
        return false
    end
    
    local srCellId = self.hextab[srX][srY]._cellId
    print("src" ,srCellId,srX,srY)
    print("des" ,desCellId,destPos.x,destPos.y)

    local curNode,valueG,valueH,valueF
    valueG = 0
    valueH = self:calulateDis(srCellId,desCellId)
    valueF = valueH

    local closeTable = {}
    local openTable = {}
    local closeIndex = 0

    openTable[srCellId] = {cellId = srCellId,valueG = valueG,valueH = valueH, valueF = valueF,parent = nil}
    local openCount = 1
    while openCount ~= 0 do

        local minF = 1000000
        for k,v in pairs(openTable) do
            if v.valueF < minF then
                minF = v.valueF
                curNode = v
            end
        end

        closeIndex = closeIndex + 1
        closeTable[closeIndex] = curNode
        openTable[curNode.cellId] = nil
        openCount = openCount -1
        if curNode.cellId == desCellId then
            break
        end

        local pos = self:convertToHexPos(curNode.cellId)
        if not self:couldPass(pos.x,pos.y) and curNode.cellId ~= srCellId then   --有敌人和自己重合的情况，所以起始位置去掉判断
            local str = GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT41")
            promptmgr:showSystenHint(str, COLOR_TYPE.RED) 
            return false
        end

        local around = self:findAround(curNode.cellId)
        local findSuceess = false
        for i=1,#around do

            local roundId = around[i]
            if roundId == desCellId then
                closeIndex = closeIndex + 1
                closeTable[closeIndex] = {cellId = roundId,valueG = 0,valueH = 0,valueF = valueG,parent = curNode.cellId }
                findSuceess = true 
                break
            end

            local inCloseTab = false
            for k,v in pairs(closeTable) do
                if v.cellId ==  roundId then
                    inCloseTab = true
                    break
                end
            end 

            if not inCloseTab then
                --不在开启列表中
                if openTable[roundId] == nil then
                    local valueG = self:calulateDis(roundId,srCellId)
                    local valueH = self:calulateDis(roundId,desCellId)
                    local valueF = valueG + valueH
                    openTable[roundId] = {}
                    openTable[roundId] = {cellId = roundId,valueG = valueG,valueH = valueH,valueF = valueF,parent = curNode.cellId }
                    openCount = openCount + 1
                else
                    local valueG = self:calulateDis(roundId,curNode.cellId) + curNode.valueG
                    if valueG < openTable[roundId].valueG then
                        openTable[roundId].valueG = valueG
                        openTable[roundId].valueF = valueG + openTable[roundId].valueH
                        openTable[roundId].parent = curNode.cellId
                    end  
                end
            end

        end

        if findSuceess then
            break
        end

        if openCount == 0 and curNode.cellId ~= desCellId then

            local str = GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT41")
            promptmgr:showSystenHint(str, COLOR_TYPE.RED)  
            return false
        end
    end

    self.path = {}       
    self.path[1] = closeTable[#closeTable].cellId
    local index = 1
    local p = closeTable[#closeTable].parent
    for i=#closeTable-1,1,-1 do
        if p == closeTable[i].cellId then
            index = index + 1
            p = closeTable[i].parent
            self.path[index] = closeTable[i].cellId
        end
    end

    return true
end

function TerritorialWarUI:markPath()

    local function getRotation(curCellId,nextCellId)

        local curPos = self:convertToHexPos(curCellId)
        local nextPos = self:convertToHexPos(nextCellId)
        if curPos.x == nextPos.x and curPos.y<nextPos.y then
            return 10
        elseif curPos.x < nextPos.x and curPos.y==nextPos.y then
            return 60
        elseif curPos.x < nextPos.x and curPos.y > nextPos.y then
            return 110
        elseif curPos.x == nextPos.x and curPos.y > nextPos.y then
            return 180
        elseif curPos.x > nextPos.x and curPos.y==nextPos.y then
            return 230
        elseif curPos.x > nextPos.x and curPos.y < nextPos.y then
            return 300
        end
    end

    self.pathMark = {}
    for i=#self.path-1,1,-1 do

        local img = ccui.ImageView:create(self.footImg)
        local pos = self:convertToHexPos(self.path[i])
        local x,y = self.hextab[pos.x][pos.y]._centerPosX,self.hextab[pos.x][pos.y]._centerPosY
        local rotation = getRotation(self.path[i+1],self.path[i])
        local zOrder = -pos.y
        if i ~= 1 then
            img:setRotation(rotation)
            img:setPosition(cc.p(x,y))
            self.pathMark[#self.path-i] = img
            img:setLocalZOrder(zOrder+0.5)
            self.blockgrid:add(img)
        else
            local flagImage = self.resBlock:getChildByName("pathFlag")
            if not flagImage then
                flagImage = ccui.ImageView:create(self.flagImg)
                flagImage:setAnchorPoint(cc.p(0.5,0.2))  
                flagImage:setName("pathFlag")
                self.resBlock:addChild(flagImage) 
                flagImage:setTouchEnabled(true)
                self.flagPic = flagImage
            end
            flagImage:setVisible(true)
            flagImage:setPosition(cc.p(x,y))
            flagImage:setLocalZOrder(zOrder-0.5)
            local moveTip = flagImage:getChildByName("movetip")
            if not moveTip then
                moveTip = ccui.Text:create()
                moveTip:setFontName("font/gamefont.ttf")
                moveTip:enableOutline(COLOR_TYPE.BLACK, 1)
                moveTip:setFontSize(14)
                moveTip:setName("movetip")
                flagImage:addChild(moveTip)
                moveTip:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT45"))
            end
            moveTip:setPosition(cc.p(25,0))
            moveTip:stopAllActions()
            moveTip:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.FadeIn:create(1),
                cc.DelayTime:create(0.5),
                cc.FadeOut:create(1),
                cc.DelayTime:create(0.5)          
            )))
        end    
    end

end

function TerritorialWarUI:calulateDis(srCellId,destCellId)

    local destPos = self:convertToHexPos(destCellId)
    local srPos = self:convertToHexPos(srCellId)

    if self.hextab[destPos.x] == nil or self.hextab[destPos.x][destPos.y] == nil or self.hextab[srPos.x] == nil or self.hextab[srPos.x][srPos.y] ==nil then
        return
    end

    local srCenterPosX,srCenterPosY = self.hextab[srPos.x][srPos.y]._centerPosX,self.hextab[srPos.x][srPos.y]._centerPosY
    local destCenterPosX,destCenterPosY = self.hextab[destPos.x][destPos.y]._centerPosX,self.hextab[destPos.x][destPos.y]._centerPosY

    local distance = math.sqrt(self:distance2(srCenterPosX,srCenterPosY,destCenterPosX,destCenterPosY))

    return distance
end

function TerritorialWarUI:findAround(cellId)

    local round = {};
    local hexPos = self:convertToHexPos(cellId)
    for k,v in ipairs(self.posArr) do
        local posX = hexPos.x + self.posArr[k][1]
        local posY = hexPos.y + self.posArr[k][2]

        if self:couldPass(posX,posY) then
            local cellId = self.hextab[posX][posY]._cellId
            round[#round+1] = cellId
        end
    end
    return round
end

function TerritorialWarUI:couldPass(x,y)
   
   --是否有格子
   if self.hextab[x] == nil or self.hextab[x][y] == nil then
        return false
   end

   local cellId = self.hextab[x][y]._cellId

   if self.elementData[cellId] == nil and not self:existPlayer(cellId) and not self:existBoss(cellId) then
        return true
   end

   return false
end

function TerritorialWarUI:longMove(step,destCellId)

    if self.stopMove then
         self:breakMove()
         return
    end

    if self.path == nil or step<=0 or not self.longMoving then
        self.moveBtn:setVisible(false)
        self.longMoving = false
        if self.flagPic then
            self.flagPic:setVisible(false)
        end
        return
    end

    local cellId = self.path[step]
    if step == 1  then
        self.moveFurther = false
    end

    local conf = GameData:getConfData('dfbasepara')
    local perCost = conf['actionCost'].value[1]
    local allCost = step*tonumber(perCost)
    self.actionNum:setString(allCost)

    self:Move(cellId,function()

        --删除寻路路径
        local markImg = self.pathMark[#self.path-step]
        if markImg then
             self.pathMark[#self.path-step] = nil
            markImg:removeFromParent(true)
        end
        self:longMove(step-1,destCellId)
    end,destCellId)
end

-- 脟贸脠隆脕陆赂枚碌茫碌脛戮脿脌毛脝陆路陆
function TerritorialWarUI:distance2(x1, y1, x2, y2)
    return ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
end

-- 赂酶露篓脪禄赂枚脳酶卤锚拢卢路碌禄脴虏露禄帽碌脛脕霉卤脽脨脦脰脨脨脛碌茫脳酶卤锚
function TerritorialWarUI:GetCell(x, y)

    local points = {}
    local distance = 1000000
    local horizontalIndex,verticalIndex = 0,0
     for i=1,#self.gidConfig do
        local pos = self:convertToHexPos(i)
        if pos ~= nil then
            if self.hextab[pos.x][pos.y] ~= nil then
                local newDis = math.sqrt(self:distance2(x,y, self.hextab[pos.x][pos.y]._centerPosX, self.hextab[pos.x][pos.y]._centerPosY))
                if distance > newDis and self.cellHeight > newDis then
                    distance = newDis
                    horizontalIndex = pos.x
                    verticalIndex = pos.y
                end
             end
        end
    end

    points.x = horizontalIndex
    points.y = verticalIndex

    return points
end

function TerritorialWarUI:initHexTab()
    
    --录脝脣茫赂帽脳脫脨卤脧貌脣庐脝陆潞脥脢煤脰卤碌脛脝芦脪脝脰碌
    self.horizontalDis = self.cellHeight*math.cos(self.slopRad)+20                      --脨卤脧貌脕霉卤盲脨脦脳茅脭脷脣庐脝陆路陆脧貌脡脧碌脛戮脿脌毛
    self.verticalDis = self.cellHeight*math.sin(self.slopRad)-2                         --脨卤脧貌脕霉卤盲脨脦脳茅脭脷脢煤脰卤路陆脧貌脡脧碌脛戮脿脌毛

    local Dis = 1                                                                       --脨拢露脭脣庐脝陆潞脥脢煤脰卤路陆脧貌碌脛戮脿脌毛
    local horidiff = Dis*math.cos(self.slopRad)
    local vertical = Dis*math.sin(self.slopRad)
    self.horizontalDis = self.horizontalDis - horidiff
    self.verticalDis = self.verticalDis-horidiff

    for i=1,#self.gidConfig do
        local pos = self:convertToHexPos(i)
        if pos ~=nil  then
            local horizontalIndex,verticalIndex = pos.x,pos.y

            local offsetX = (horizontalIndex-1)*self.horizontalDis       --脣庐脝陆脝芦脪脝脳酶卤锚
            local offsetY = (horizontalIndex-1)*self.verticalDis         --脢煤脰卤脝芦脪脝脳酶卤锚

            local centerX = math.sin(self.slopRad)*self.cellHeight*(verticalIndex-1) +  offsetX
            local centerY = math.cos(self.slopRad)*self.cellHeight*(verticalIndex-1) +  offsetY

            if self.hextab[horizontalIndex] == nil then
                self.hextab[horizontalIndex] = {}
            end

            self.hextab[horizontalIndex][verticalIndex] = {}
            self.hextab[horizontalIndex][verticalIndex] = {_centerPosX = nil,_centerPosY = nil,pos = {},_cellId}

            self.hextab[horizontalIndex][verticalIndex]._centerPosX = centerX
            self.hextab[horizontalIndex][verticalIndex]._centerPosY = centerY
            self.hextab[horizontalIndex][verticalIndex]._cellId = i

        end

    end
end

function TerritorialWarUI:refreshRes(mapId)
    
    local i,j = (mapId-1)%5,math.floor((mapId-1)/5)
    local maxX,maxY = (i+1)*512,(5-j)*512
    local minX,minY = i*512,(5-j-1)*512
    local config = GameData:getConfData('dfmapcreature')
    --创建地图元素
    local cells = self.territoryData.cells
    for k,v in pairs(cells) do 
        local cellId = tonumber(k)
        local cellPos = self:convertToHexPos(cellId)
        local x,y = self.hextab[cellPos.x][cellPos.y]._centerPosX,self.hextab[cellPos.x][cellPos.y]._centerPosY
        if x >= minX and x <= maxX and y<= maxY and y>= minY then
            local creatureInfo = config[v.resId]
            if v.resType == self.resType.element then
                self:createElement(cellId, v, self.resBlock)
            end
        end
    end

end

function TerritorialWarUI:inVisitedRes(cellId)
   
   for k,v in pairs(self.visitedRes) do
        if cellId == tonumber(k) then
            return true
        end
   end

   return false
end

-- 是否显示共享怪
function TerritorialWarUI:isShareMonsterShow(cellId)
    local cellInfo = self.territoryData.cells[tostring(cellId)];
    if cellInfo and cellInfo.resType == self.resType.creature then
        local creatureInfo = GameData:getConfData('dfmapcreature')[cellInfo.resId]
        if creatureInfo ~= nil and creatureInfo.isShare == 1 and cellInfo.resParam == 0 then
            return false
        end
    end

    return true
end

function TerritorialWarUI:setGateName()
    
    local config = GameData:getConfData("dftransmit")
    local baseConfig = GameData:getConfData("dfbasepara")
    for i=1,3 do
        local levelCellId = tonumber(baseConfig[config[i+1].target].value[1])
        local pos = self:convertToHexPos(levelCellId)
        if pos ~= nil and self.hextab[pos.x]~= nil and self.hextab[pos.x][pos.y] ~= nil then
            
            local diffX,diffY = 0,0
            if i==1 then                    --剑门关
                diffX,diffY = -105,25
            elseif i==2 then                --嘉峪关
                diffX,diffY = -80,30
            elseif i==3 then                --虎牢关
                diffX,diffY = -160,15
            end
            local namebg = ccui.ImageView:create('uires/ui/legion/legion_building_bg.png')
            namebg:setPosition(cc.p(self.hextab[pos.x][pos.y]._centerPosX+diffX,self.hextab[pos.x][pos.y]._centerPosY+diffY))
            namebg:setScale9Enabled(true)
            local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
            nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
            nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            nameLabel:setMaxLineWidth(20)
            nameLabel:setLineSpacing(-5)
            nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
            nameLabel:setPosition(cc.p(40, 90))
            nameLabel:setString(config[i+1].name)
            namebg:setContentSize(cc.size(40, 150))
            namebg:addChild(nameLabel)
            namebg:setLocalZOrder(-pos.y)
            self.resBlock:addChild(namebg)
        end
    end

end

--创建怪物
function TerritorialWarUI:createMonster(cellId,info,block)

    if self.hextab[info.x] == nil or self.hextab[info.x][info.y] == nil or self.element[cellId] ~= nil then
        return
    end

    if self:inVisitedRes(cellId) and  self.visitedRes[tostring(cellId)].param == 0 then
        local monster = block:getChildByTag(cellId + 1000)
        if monster then
            block:removeChild(monster)
        end
        return
    end

    if self:isShareMonsterShow(cellId) == false then
        local monster = block:getChildByTag(cellId + 1000)
        if monster then
            block:removeChild(monster)
        end
        return
    end

    self.elementData[cellId] = 1

    local id = info.resId
    local dfmapcreature = GameData:getConfData("dfmapcreature")[info.resId]
    local fomationConfig = GameData:getConfData("formation")[dfmapcreature.combatId]
    local monsterId = fomationConfig['pos'..fomationConfig.boss]
    local monsterConfig = GameData:getConfData("monster")[monsterId]

    local modelAin = nil
    local bg = block:getChildByTag(cellId + 1000)
    if not bg then
        bg = ccui.ImageView:create('uires/ui/common/touming.png')
        local spineAni = GlobalApi:onlyCreateArmature(monsterConfig.url.."_display")
        local offsetX,offsetY,nameBarOffsetY = dfmapcreature.uiOffset[1]*dfmapcreature.ort,dfmapcreature.uiOffset[2],dfmapcreature.uiOffset[3]
        spineAni:setScale(0.4)
        spineAni:setAnchorPoint(cc.p(0.5, 0))
        spineAni:setPosition(cc.p(bg:getContentSize().width/2+offsetX,0+offsetY))
        spineAni:getAnimation():play('idle', -1, 1)
        spineAni:setName('mode')
        bg:addChild(spineAni)
        bg:setAnchorPoint(cc.p(0.5, 0))
        bg:setPosition(cc.p(self.hextab[info.x][info.y]._centerPosX,self.hextab[info.x][info.y]._centerPosY-10))

        --朝向
        if dfmapcreature.ort ~= 1 then
            spineAni:setScaleX(-math.abs(spineAni:getScaleX()))
        end

        --血条
        local bloodValue = info.resParam and info.resParam or 0                             --公共怪血量
        if dfmapcreature and dfmapcreature.isShare ~= 1 then
            bloodValue = (self.visitedRes[tostring(cellId)] and self.visitedRes[tostring(cellId)].param) and self.visitedRes[tostring(cellId)].param or 100
        end

        local bloodHpRes = "uires/ui/battle/plist/battle_hero_hp_1.png"
        
        local loadingBarBg = ccui.ImageView:create("uires/ui/battle/plist/battle_hero_hp_4.png")

        local loadingBar = cc.ProgressTimer:create(cc.Sprite:create(bloodHpRes))
        loadingBarBg:setAnchorPoint(cc.p(0.5, 0))
        loadingBarBg:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height+80+nameBarOffsetY))
        loadingBarBg:setScaleX(1.2)
        loadingBarBg:setScale9Enabled(true)
        bg:addChild(loadingBarBg,1)
        loadingBar:setScaleX(1.2)
        loadingBar:setAnchorPoint(cc.p(0.5, 0))
        loadingBar:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height+80+nameBarOffsetY))
        loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        loadingBar:setMidpoint(cc.p(0, 0))
        loadingBar:setBarChangeRate(cc.p(1, 0))
        loadingBar:setPercentage(bloodValue)
        loadingBar:setName("bar")
        bg:addChild(loadingBar,2)

        local lvText = ccui.Text:create()
        lvText:setAnchorPoint(cc.p(0.5, 0))
        lvText:setFontName("font/gamefont.ttf")
        lvText:enableOutline(COLOR_TYPE.BLACK, 1)
        lvText:setFontSize(12)
        lvText:setString("Lv. " .. monsterConfig.level)
        lvText:setPosition(cc.p(0,bg:getContentSize().height+85+nameBarOffsetY))
        bg:addChild(lvText)
        local zOrder = -info.y
        block:addChild(bg,zOrder,cellId + 1000)
        modelAin = spineAni
    else
        local model = bg:getChildByName('mode')
        if model ~= nil then
            modelAin = model
        end
    end
    if modelAin ~= nil then
       self.element[self.hextab[info.x][info.y]._cellId] = {_spine = nil,_info = nil,_bg = nil,_img = nil}
       self.element[self.hextab[info.x][info.y]._cellId]._spine = modelAin
       self.element[self.hextab[info.x][info.y]._cellId]._info = info
       self.element[self.hextab[info.x][info.y]._cellId]._bg = bg  
    end
end

--创建矿
function TerritorialWarUI:createMine(cellId,info,block)
    
    if self.hextab[info.x] == nil or self.hextab[info.x][info.y] == nil or self.element[cellId] ~= nil then
        return
    end

    local dfmapmineConfig = GameData:getConfData("dfmapmine")[info.resId]
    local anchorPoint = cc.p(dfmapmineConfig.offset_x, dfmapmineConfig.offset_y)

    local image = 'uires/ui/common/touming.png'
    local animationState = self:getMineState(cellId) and 'open' or 'close'
    local offisize = 20
    local addY = 30
    if self.curLid == UserData:getUserObj():getLid() then
        if animationState == 'open' then
            image = stateImg.occupy
            offisize = 0
            addY = 50
        end
    else
        if self:inVisitedRes(cellId) then
            image = stateImg.plunder
            offisize = 0
            addY = 50
        end 
    end

    self.elementData[cellId] = 1

    local rtimg,rtext,nameH,modeAin = nil
    local bg = block:getChildByTag(cellId + 1000)
    if not bg then
        bg = ccui.ImageView:create('uires/ui/common/touming.png')
        local model = GlobalApi:onlyCreateArmature(dfmapmineConfig.url)
        if model~=nil then
            model:setScale(dfmapmineConfig.scale)
            model:setAnchorPoint(anchorPoint) 
		    model:getAnimation():play(animationState, -1, 1)
            model:setPosition(cc.p(bg:getContentSize().width/2,0))
            model:setName('mode')
            bg:addChild(model)
		    bg:setPosition(cc.p(self.hextab[info.x][info.y]._centerPosX,self.hextab[info.x][info.y]._centerPosY))
        
            local namebg = ccui.ImageView:create('uires/ui/legion/legion_building_bg.png')
            namebg:setPosition(cc.p(bg:getContentSize().width/2-60,bg:getContentSize().height+35))
            namebg:setScale9Enabled(true)

            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(30, 0))
            namebg:setContentSize(richText:getContentSize().width + 8, 180)

            local height = richText:getContentSize().height/2-offisize
            local rtImg = xx.RichTextImage:create(image)
            local rtName = xx.RichTextLabel:create('' .. dfmapmineConfig.name, 20,COLOR_TYPE.WHITE)
            richText:addElement(rtImg)
            richText:addElement(rtName)
            rtImg:setScale(0.9)
            richText:setAnchorPoint(cc.p(0.5,0.5))
            richText:setPosition(cc.p(richText:getContentSize().width/2 + 4,namebg:getContentSize().height/2+addY))
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')
            richText:setName('richText')
            namebg:addChild(richText)
            namebg:setName('namebg')
            bg:addChild(namebg)
            bg:setAnchorPoint(cc.p(0.5, 0))
            local zOrder = -self.hextab[info.x][info.y]._centerPosY
            block:addChild(bg,zOrder,cellId+1000)
            rtimg = rtImg
            rtext = richText
            nameH = height
            modeAin = model
        end
    else
        local model = bg:getChildByName('mode')
        local namebg = bg:getChildByName('namebg')
        if model == nil or namebg == nil then
            return
        end
        model:getAnimation():play(animationState, -1, 1)
        local richText = namebg:getChildByName('richText')
        local height = richText:getContentSize().height/2-offisize
	    local rtImg = richText:getElement(0)
        rtImg:setImg(image)
	    local rtName =richText:getElement(1)
        rtName:setString(dfmapmineConfig.name)
        richText:setPosition(cc.p(richText:getContentSize().width/2 + 4,height + 4))
        richText:format(true)
        rtimg = rtImg
        rtext = richText
        nameH = height
        modeAin = model
    end

    if rtimg ~= nil and rtext~= nil and nameH ~= nil and modeAin ~= nil then
        self.element[self.hextab[info.x][info.y]._cellId] = {_spine = nil,_info = nil,_bg = nil,_img = nil,_rtx = richText,_height = 0,_offisize = 0}
        self.element[self.hextab[info.x][info.y]._cellId]._spine = modeAin
        self.element[self.hextab[info.x][info.y]._cellId]._info = info
        self.element[self.hextab[info.x][info.y]._cellId]._bg = bg
        self.element[self.hextab[info.x][info.y]._cellId]._rtx = rtext
        self.element[self.hextab[info.x][info.y]._cellId]._img = rtimg
        self.element[self.hextab[info.x][info.y]._cellId]._height = nameH
        self.element[self.hextab[info.x][info.y]._cellId]._offisize = offisize
    end

end

--创建元素
function TerritorialWarUI:createElement(cellId,info,block)
    
    if self.hextab[info.x] == nil or self.hextab[info.x][info.y] == nil or self.element[cellId] ~= nil then
        return
    end

    local dfelementConfig = GameData:getConfData("dfelement")[info.resId]
    if self:inVisitedRes(cellId) and dfelementConfig.isCost == 1 then
        local element = block:getChildByTag(cellId + 1000)
        if element then
            block:removeChild(element)
        end
        return
    end

    self.elementData[cellId] = 1

    local animationState = 'close'
    if info.resId == TerritorialWarMgr.resourceType.stele then
        animationState = self:getSteleState(cellId) and 'open' or 'close'
    elseif info.resId == TerritorialWarMgr.resourceType.transfer_out then
        local count = self:getSteleCount()
        animationState = (count >= self.legionNumLimit) and 'open' or 'close'
    elseif info.resId == TerritorialWarMgr.resourceType.transfer_in then 
        local count = self:getSteleCount()
        animationState = (count >= self.invadeLimit) and 'open' or 'close'
    else
        animationState = self:inVisitedRes(cellId) and 'open' or 'close'
    end

    local image = 'uires/ui/common/touming.png'
    local addY = 35
    local offisize = 20
    if animationState == 'open' then
        image = stateImg.occupy
        offisize = 0
        addY = 0
    end
    local rtimg,rtext,nameH,modeAin = nil
    local anchorPoint = cc.p(dfelementConfig.offset_x, dfelementConfig.offset_y)
    local bg = block:getChildByTag(cellId + 1000)
    if not bg then
        bg = ccui.ImageView:create('uires/ui/common/touming.png')
        --local model = GlobalApi:createLittleLossyAniByName(dfelementConfig.url)
        local model = GlobalApi:onlyCreateArmature(dfelementConfig.url)
        if model~=nil then
            model:setScale(dfelementConfig.scale)
            model:setAnchorPoint(anchorPoint)
            
            model:getAnimation():play(animationState, -1, 1)
            model:setPosition(cc.p(bg:getContentSize().width/2,0))
            model:setName('mode')
            bg:addChild(model)
		    bg:setPosition(cc.p(self.hextab[info.x][info.y]._centerPosX,self.hextab[info.x][info.y]._centerPosY-10))

            local namebg = ccui.ImageView:create('uires/ui/legion/legion_building_bg.png')
            namebg:setPosition(cc.p(bg:getContentSize().width/2-70,bg:getContentSize().height+45))
            namebg:setScale9Enabled(true)
        
            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(30, 0))
            namebg:setContentSize(richText:getContentSize().width + 8, 140)

            local height = richText:getContentSize().height/2-offisize
            local rtImg = xx.RichTextImage:create(image)
            local rtName = xx.RichTextLabel:create('' .. dfelementConfig.name, 20,COLOR_TYPE.WHITE)
            richText:addElement(rtImg)
            richText:addElement(rtName)
            rtImg:setScale(0.9)
            richText:setAnchorPoint(cc.p(0.5,0.5))
            richText:setPosition(cc.p(richText:getContentSize().width/2 + 4,namebg:getContentSize().height-addY))
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')
            richText:setName('richText')
            namebg:addChild(richText)
            if dfelementConfig.isCost == 1 then
                namebg:setVisible(false)
            else
                namebg:setVisible(true)
            end
            namebg:setName('namebg')
            bg:addChild(namebg)
            bg:setAnchorPoint(cc.p(0.5, 0))

            local zOder = -self.hextab[info.x][info.y]._centerPosY
            block:addChild(bg,zOder,cellId + 1000)
            rtimg = rtImg
            rtext = richText
            nameH = height
            modeAin = model
       end
    else
        local model = bg:getChildByName('mode')
        local namebg = bg:getChildByName('namebg')
        if model == nil or namebg == nil then
            return
        end
        model:getAnimation():play(animationState, -1, 1)
        
        local richText = namebg:getChildByName('richText')
        local height = richText:getContentSize().height/2-offisize
	    local rtImg = richText:getElement(0)
        rtImg:setImg(image)
	    local rtName =richText:getElement(1)
        rtName:setString(dfelementConfig.name)
        richText:setPosition(cc.p(richText:getContentSize().width/2 + 4,height + 4))
        richText:format(true)
        rtimg = rtImg
        rtext = richText
        nameH = height
        modeAin = model
    end 

    if rtimg ~= nil and rtext~= nil and nameH ~= nil and modeAin ~= nil then
        self.element[self.hextab[info.x][info.y]._cellId] = {_spine = nil,_info = nil,_bg = nil,_img = nil,_rtx = richText,_height = 0,_offisize = 0}
        self.element[self.hextab[info.x][info.y]._cellId]._spine = modeAin
        self.element[self.hextab[info.x][info.y]._cellId]._info = info
        self.element[self.hextab[info.x][info.y]._cellId]._bg = bg
        self.element[self.hextab[info.x][info.y]._cellId]._rtx = rtext
        self.element[self.hextab[info.x][info.y]._cellId]._img = rtimg
        self.element[self.hextab[info.x][info.y]._cellId]._height = nameH
        self.element[self.hextab[info.x][info.y]._cellId]._offisize = offisize
    end
end

--采集资源
function TerritorialWarUI:CollectElement(cellId,gone)
    
   local center_pos = self:convertScreenLocationToMap(self.screenCenterPoint)
   local indexX, indexY = self:getBlockIndexByPosition(center_pos)
   local gridBlock = self.mapBlockArr[indexX][indexY].res
   local dfelementConfig = GameData:getConfData('dfelement')
    MessageMgr:sendPost('gather','territorywar',json.encode({cellId  = cellId}),function (response)

        local code = response.code
        local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end 

        if data.awards then
            GlobalApi:parseAwardData(data.awards)
            GlobalApi:showAwardsCommon(data.awards,2,nil,true)
        end

        -- 得到采集矿的总数
        local visitedMineCount = response.data.visitedMineCount
        if visitedMineCount then
            self:updeteMineVisitCount(visitedMineCount)
        end
        local id = self.element[cellId]._info.resId
        self.visitedRes[tostring(cellId)] = {param = 0}
        if gone == 1 then
            gridBlock:removeChild(self.element[cellId]._bg)
            if id == TerritorialWarMgr.resourceType.signet then
                self.territoryWar.dragonScaleCount = self.territoryWar.dragonScaleCount + 1
                self:updateWeekAchieve()
            end
            self.element[cellId] = nil
            self.elementData[cellId] = nil
            TerritorialWarMgr:hideElementUI()
        else
            TerritorialWarMgr:hideElementVTUI()
            local str = dfelementConfig[tonumber(id)].message
            promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)  
            if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img ~= nil then
                
                self.element[cellId]._spine:getAnimation():play('open', -1, 1)
                self.element[cellId]._img:setImg(stateImg.occupy)
                self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
                self.element[cellId]._rtx:format(true)
            end

            if id == TerritorialWarMgr.resourceType.stele then
               self:setSteleInfo(cellId)
               self:updateWeekAchieve()
               self:updateTransportState()
            elseif id == TerritorialWarMgr.resourceType.relic then
               self:addRelicList(data.relicId)
               TerritorialWarMgr:showFuncUI(4)
            elseif id == TerritorialWarMgr.resourceType.stone_tower then
                TerritorialWarMgr:showFuncUI(2)
            elseif id == TerritorialWarMgr.resourceType.drogon_statue then
                TerritorialWarMgr:showFuncUI(3)
            end
        end
    end)

end

-- 赂眉脨脗虏脛脕脧露脩路脙脦脢麓脦脢媒
function TerritorialWarUI:updeteMineVisitCount(visitCount)
    self.territoryWar.visitedMineCount = visitCount
end

--占领矿
function TerritorialWarUI:OccupyMineral(cellId,name)
    
    local actName = 'occupy_mine'
    if UserData:getUserObj():getLid() ~= self.curLid then
        actName = 'rob_mine'
    end
    MessageMgr:sendPost(actName,'territorywar',json.encode({cellId  = cellId}),function (response)
        local code = response.code
        local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end 

        local cellId = tonumber(cellId)
        if not self.element[cellId]._info then
            return
        end
        local id = tonumber(self.element[cellId]._info.resId)
        local img = stateImg.occupy
        if actName == 'occupy_mine' then   
            local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT6'),name)
            promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
            self:setMineState(cellId,id,0)
        else
           if data.awards then
                GlobalApi:parseAwardData(data.awards)
                GlobalApi:showAwardsCommon(data.awards,2,nil,true)
            end
            img = stateImg.plunder

            -- 记录矿已经被掠夺过
            self.visitedRes[cellId] = {param = 100,}
            --self:setMineState(cellId,id,1)
        end

        if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img ~= nil then
            self.element[cellId]._spine:getAnimation():play('open', -1, 1)
            self.element[cellId]._img:setImg(img)
            self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
            self.element[cellId]._rtx:format(true)
        end

        TerritorialWarMgr:hideElementVTUI()
    end)
end

--路脙脦脢碌脨脠脣碌脛UI
function TerritorialWarUI:showEnemyUI(cellId)

    local isAround = self:CheckInAround(cellId)
    MessageMgr:sendPost('get_cell_player_list','territorywar',json.encode({cellId  = cellId}),function (response)
        local code = response.code
        local data = response.data
        if code ~= 0 then
            TerritorialWarMgr:handleErrorCode(code)
            return
        end 

        local count = 0
        local uid = 0
        for k,v in pairs(data.playerList) do
            if v.pos.cellId == cellId then
                count = count + 1
                uid = v.uid
            end
        end

        if count  == 0 then
            TerritorialWarMgr:handleErrorCode(300)
        elseif count  == 1 then
            TerritorialWarMgr:showPlayerUI(data.playerList[tostring(uid)],isAround)
        else
           TerritorialWarMgr:showEnemylistUI(data.playerList,isAround)
        end
    end)

end

--点开元素界面
function TerritorialWarUI:showElementVisitUI(cellId)

   if self.element[cellId] == nil then
        return
   end

   local resId = self.element[cellId]._info.resId
   local isAround = self:CheckInAround(cellId)

   local myselfLand = false
   if UserData:getUserObj():getLid() == self.curLid then
        myselfLand = true
   end
   local dfelementConfig = GameData:getConfData('dfelement')[resId]
   if self.element[cellId]._info.resType == self.resType.element then
        if self.element[cellId]._info.resId == TerritorialWarMgr.resourceType.transfer_out and myselfLand == true then    --传送门
            
            MessageMgr:sendPost('get_enemy','territorywar',json.encode({cellId  = cellId}),function (response)
                local code = response.code
                local data = response.data
                if code ~= 0 then
                    TerritorialWarMgr:handleErrorCode(code)
                    return
                end 
                local tab = {}
                tab.data = data
                --TerritorialWarMgr:showTransportUI(resId,cellId,isAround,data)
                TerritorialWarMgr:showElementVTUI(resId,cellId,isAround,tab,3)
            end)
        elseif self.element[cellId]._info.resId >= TerritorialWarMgr.resourceType.transfer_in then                        --路脟麓芦脣脥碌茫碌脛element脢掳脠隆
            local tab = {}
            tab.visited = self:inVisitedRes(cellId)
            tab.myselfLand  = myselfLand
            if tonumber(dfelementConfig.showType) == 0 then                         --可拾取道具

                if not isAround then
                    TerritorialWarMgr:showElementUI(resId,cellId,isAround,self:inVisitedRes(cellId),myselfLand)
                else
                    self:CollectElement(cellId,1)
                end
            else
                if self.element[cellId]._info.resId == TerritorialWarMgr.resourceType.transfer_in and self.curLid ~= UserData:getUserObj():getLid() then
                    return
                end
                TerritorialWarMgr:showElementVTUI(resId,cellId,isAround,tab)        --剩余不可拾取道具
            end
            
        end
   elseif self.element[cellId]._info.resType == self.resType.mine then          --打开矿产
        
        MessageMgr:sendPost('get_mine_Info','territorywar',json.encode({cellId  = cellId}),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                TerritorialWarMgr:handleErrorCode(code)
                return
            end 

            local visited = myselfLand and self:getMineState(cellId) or self:inVisitedRes(cellId)

            local tab = {}
            tab.visited = visited
            tab.hold  = data.mine.hold
            tab.robCount  = data.mine.robCount
            tab.myselfLand  = myselfLand

            --TerritorialWarMgr:showMineralUI(resId,cellId,isAround,visited,data.mine.hold,data.mine.robCount,myselfLand)
            TerritorialWarMgr:showElementVTUI(resId,cellId,isAround,tab,1)
        end)

   elseif self.element[cellId]._info.resType == self.resType.creature then      --怪

        MessageMgr:sendPost('attack_monster','territorywar',json.encode({cellId  = cellId}),function (response)
            local code = response.code
            local data = response.data
            if code ~= 0 then
                TerritorialWarMgr:handleErrorCode(code)
                return
            end 

            local tab = {}
            tab.stayingPower = data.stayingPower
            TerritorialWarMgr:showCreatureUI(resId,cellId,isAround,data.stayingPower)
        end)
        
   end
end

--更新传送点状态
function TerritorialWarUI:updateTransportState()

    local dfbaseparaCfg = GameData:getConfData('dfbasepara')
    local legionNumLimit = tonumber(dfbaseparaCfg['legionNumLimit'].value[1])       --戮眉脥脜禄楼脥篓脢媒脕驴脧脼脰脝拢篓脳卯露脿3赂枚戮眉脥脜禄楼脥篓拢漏
    local invadeLimit = tonumber(dfbaseparaCfg['invadeLimit'].value[1])             --脠毛脟脰脨猫脟贸路脙脦脢脢炉卤庐脧脼脰脝
    local config = GameData:getConfData("dfelement")

    local count = self:getSteleCount()

    local cellId,id = 0,0
    if count == legionNumLimit  then
        local cellId = tonumber(dfbaseparaCfg['initialPos'].value[1])
        id = TerritorialWarMgr.resourceType.transfer_out  
    elseif invadeLimit == count then
        local cellId = tonumber(dfbaseparaCfg['invadePos'].value[1])
        id = TerritorialWarMgr.resourceType.transfer_in  
    end
    
    if cellId ~= 0 and id ~= 0 then
        if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img then
            self.element[cellId]._spine:getAnimation():play('open', -1, 1)
            self.element[cellId]._img:setImg(stateImg.occupy)
            self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
            self.element[cellId]._rtx:format(true)
        end
        local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT5'),config[id].name)
        promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
    end
end

--脣垄脨脗脰脺鲁脡戮脥陆卤脌酶脛驴卤锚
function TerritorialWarUI:updateWeekAchieve()

    for i=1,2 do
        local dfachieveConfig = GameData:getConfData("dfachievement")[self.achievetab[i].achType]
        local achieve = {}
        for k,v in pairs(dfachieveConfig) do
            if k ~= 'type' then
                achieve[#achieve+1] = v
            end
        end

        local canGetCount,getedCount,notfishiIndex = 0,0,0
        for k,v in ipairs(achieve) do
            --state:1-已领取 2-未达成 3-可以领取
            local state,finishCount = self:getAchieveAwardState(self.achievetab[i].achType,v.target,v.goalId)
            if state == 3 then
                canGetCount = canGetCount + 1
            end
            if state == 1 then
               getedCount = getedCount + 1
            end

            if state == 2 and notfishiIndex == 0 then
                notfishiIndex = tonumber(k)
            end
        end

        if getedCount == #achieve then
            self.achievetab[i].text:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF21'))
            self.achievetab[i].text:setColor(COLOR_TYPE.YELLOW)
        elseif canGetCount > 0 then
            self.achievetab[i].text:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF20'))
            self.achievetab[i].text:setColor(COLOR_TYPE.GREEN)
        elseif getedCount ~= #achieve and  canGetCount == 0 then
            local state,finishCount = self:getAchieveAwardState(self.achievetab[i].achType,achieve[notfishiIndex].target,achieve[notfishiIndex].goalId)
            self.achievetab[i].text:setString(finishCount .. "/" .. achieve[notfishiIndex].target)
            self.achievetab[i].text:setColor(COLOR_TYPE.WHITE)
        end
    end
end

--脢脟路帽脢脟驴脮赂帽脳脫
function TerritorialWarUI:isEmptyCell(cellId)

    if self.element[cellId] == nil and not self:existPlayer(cellId) and not self:existBoss(cellId)  then
        return true
    end
   return false
end

function TerritorialWarUI:existBoss(cellId)

    if not self.BossInfo then
        return false
    end
    if not self.BossInfo._cellId then
        return false
    end
    if cellId ~= self.BossInfo._cellId then
        return false
    end
    return true
end

--是否存在敌方玩家
function TerritorialWarUI:existPlayer(cellId)

    local uid = UserData:getUserObj():getUid() or 0
    local lid = UserData:getUserObj():getLid() or 0
    for k,v in pairs(self.otherObj) do
        if uid ~= v.uid and cellId == v.cellId and v.lid ~= lid then
            return true
        end
    end

    return false
end

--获取成就领奖记录
function TerritorialWarUI:getAchieveRecord(achieveType,goalId)

    if self.achievementAwardGetRecord[tostring(achieveType)] == nil then
        return false
    end
    local exist = false
    for k,v in pairs(self.achievementAwardGetRecord[tostring(achieveType)]) do
        if tonumber(v) == tonumber(goalId) then
            exist = true
            break
        end
    end

    return exist
end

--设置成就领奖记录
function TerritorialWarUI:setAchieveRecord(achieveType,goalId)
    
    local stype = tostring(achieveType)
    local goldId = tonumber(goalId)
    if self.achievementAwardGetRecord[stype] == nil then
        self.achievementAwardGetRecord[stype] = {}
        --self.achievementAwardGetRecord[stype][#self.achievementAwardGetRecord[stype]+1] = goldId
        --self.achievementAwardGetRecord[stype][goldId] = goldId
    end
    table.insert(self.achievementAwardGetRecord[stype],goldId)
end

function TerritorialWarUI:setSteleInfo(cellId)
    
    local count = self:getSteleCount()
    self.stele[tostring(count+1)] = {}
    self.stele[tostring(count+1)].cellId = cellId
    self.stele[tostring(count+1)].lid = self.curLid
end

--得到石碑访问的数量
function TerritorialWarUI:getSteleCount()

    local count = 0
    for k, v in pairs(self.stele) do
        count = count + 1
    end
    return count
end

--录矛虏芒驴贸脦茂碌脛脮录脕矛脟茅驴枚
function TerritorialWarUI:getMineState(cellId)
    for k,v in pairs(self.occupyMine) do
        for i,mineCell in pairs(v.holdCells) do
            if mineCell == cellId then
                return true
            end
        end
    end
    return false
end

--脡猫脰脙驴贸脦茂碌脛脮录脕矛脟茅驴枚
function TerritorialWarUI:setMineState(cellId,id,robCount)
    
    for k,v in pairs(self.occupyMine) do
        if tonumber(k) == id then
            v.holdCells[#v.holdCells+1] = cellId
            if robCount ~= 0 then
                v.robCount = v.robCount + 1
            end
        end
    end

end

--录矛虏芒虏t脥没脣镁脢脟路帽驴陋脝么
function TerritorialWarUI:getWatchTower(cellId)
    
   for k,v in pairs(self.watchTower) do
       if cellId == v then
           return true
       end
   end
   return false
end

--录矛虏芒脢炉卤庐脢脟路帽路脙脦脢鹿媒(脫脙脫脷碌卤脟掳鲁隆戮掳碌脛脢炉卤庐脳麓脤卢赂眉脨脗)
function TerritorialWarUI:getSteleState(cellId)
    
    for k,v in pairs(self.stele) do
        if tonumber(v.cellId) == cellId and self.curLid == v.lid then
            return true
        end
    end
    return false
end

--1-已领取 2-未达成 3-可以领取
function TerritorialWarUI:getAchieveAwardState(achieveType,target,goalId)

    local state,totalFinish = 2,0
    if achieveType == TerritorialWarMgr.achieveMentType.puppet then
        totalFinish = self:getKillPuppetCount()
    elseif achieveType == TerritorialWarMgr.achieveMentType.stele then
        totalFinish = self:getSteleCount()
    elseif achieveType == TerritorialWarMgr.achieveMentType.drgon then
        totalFinish = self.territoryWar.dragonScaleCount
    elseif achieveType == TerritorialWarMgr.achieveMentType.endurance then
        totalFinish = self.territoryWar.consumeEnemyStayingPower 
    elseif achieveType >= TerritorialWarMgr.achieveMentType.stone_heap and achieveType <= TerritorialWarMgr.achieveMentType.tear_heap then
        totalFinish = self:getMineCountById(achieveType-200)
    end

    if totalFinish < target then
        return state,totalFinish
    end 

    local record = self:getAchieveRecord(achieveType,goalId)
    state = record and 1 or 3

    return state,totalFinish
end

--脡猫脰脙露脩脢媒脕驴
function TerritorialWarUI:setMineCountById(id)

    if self.territoryWar.visitedMineCount[id] == nil then
        self.territoryWar.visitedMineCount[id] = 1
    else
        self.territoryWar.visitedMineCount[id] = self.territoryWar.visitedMineCount[id] + 1
    end

end

--路脙脦脢驴贸露脩脢媒脕驴
function  TerritorialWarUI:getMineCountById(id)

    if self.territoryWar.visitedMineCount[id] == nil then
        return 0
    end

    return self.territoryWar.visitedMineCount[id]
end

--获取傀儡击杀总数
function TerritorialWarUI:getKillPuppetCount()
    return self.territoryWar.killPuppetTotalCount
end

--获取遗迹可探索列表
function TerritorialWarUI:getRelicList()

   return self.territoryWar.relic
end

--添加遗迹
function TerritorialWarUI:addRelicList(id)
    
    local dfrelic = GameData:getConfData('dfrelic')
    if self.territoryWar.relic[tostring(id)] == nil  then
        self.territoryWar.relic[tostring(id)] = {}
        self.territoryWar.relic[tostring(id)].num = 1
        self.territoryWar.relic[tostring(id)].exploreTime = 0
        self.territoryWar.relic[tostring(id)].endTime = 0
    else
        self.territoryWar.relic[tostring(id)].num = self.territoryWar.relic[tostring(id)].num + 1
    end

end

function TerritorialWarUI:removeFinishRelic(id)
    if self.territoryWar.relic[tostring(id)] ~= nil  then
        self.territoryWar.relic[tostring(id)] = nil
    end
end

function TerritorialWarUI:setRelicListData(id,info)
    
    for k,v in pairs(self.territoryWar.relic) do
        if tonumber(k) == id then
            v.num = info.num
            v.exploreTime = info.exploreTime
            v.endTime = info.endTime
        end
    end

end

function TerritorialWarUI:setUpdate()
    self.message_update = false
end

--麓芦脣脥麓脦脢媒
function TerritorialWarUI:getTransferCount()
    return self.territoryWar.transferCount
end

--麓芦脣脥鲁脟鲁脴碌脛脳麓脤卢
function TerritorialWarUI:transportCityState(cellId,cost)
    
    if tonumber(self.paramConfig['initialPos'].value[1]) == cellId then
        return TerritorialWarMgr.cityState.cango
    end

    local visited = false
    for k,v in pairs(self.territoryWar.visitedCity) do
        if tonumber(v) == cellId then
            visited = true
            break
        end
    end 

    if not visited then
        return TerritorialWarMgr.cityState.not_visited
    end

    local baseConfig = GameData:getConfData("dfbasepara")
    local leftCount = baseConfig['transmitTimes'].value[1] - self.territoryWar.transferCount
    if leftCount == 0 and cost ~= 0 then
        return TerritorialWarMgr.cityState.not_count
    end
    
    return TerritorialWarMgr.cityState.cango
end

function TerritorialWarUI:refreshCharacters()
    
    self.otherObj = {}
    local nCount = 1
    local lid = self.territoryWar.pos.lid
    self.fightmap = {}
    
    printall(self.playerList)
    for k,v in pairs(self.playerList) do
        if tonumber(v.pos.lid) == tonumber(lid) then
          local otheruid = tostring(v.uid)
          self.otherObj[otheruid] = {cellId = nil,roleBg = nil,lid = nil,uid = nil,name = nil,dragon = nil,fightState = nil}
          self.otherObj[otheruid].cellId = v.pos.cellId
          self.otherObj[otheruid].lid = v.lid
          self.otherObj[otheruid].uid = v.uid
          self.otherObj[otheruid].name = v.un
          self.otherObj[otheruid].dragon = v.dragon
          self.otherObj[otheruid].fightState = v.state
          
          --new 插入数据
          playermap:insert(v.pos.cellId,v)
          if v.state then
            if not self.fightmap[v.pos.cellId] then
                self.fightmap[v.pos.cellId] = 0
            else
                self.fightmap[v.pos.cellId] = self.fightmap[v.pos.cellId] + 1
            end
          end
        end
    end

    self:createMyself()
    self:showInitPlayer()

    self:enemyInvade()
    self:setViewPlayerOpacity()
end

function TerritorialWarUI:showInitPlayer()

    local map = playermap:getmap()
    if map == nil then
        return
    end
    for k,v in pairs(map) do
        if type(v) ~= "function" then 
            self:createMode(self.resBlock,v._data:top()) 
        end
    end

end


function TerritorialWarUI:createMode(gridBlock,v,notOpacity)

    if v == nil or v.obj ~= nil then
        return
    end

    local cellId = v.pos.cellId
    local hexpos = self:convertToHexPos(cellId)
    if hexpos == nil then
        return
    end

    if self.hextab[hexpos.x] == nil or self.hextab[hexpos.x][hexpos.y] == nil then
        return
    end

    local isEnemy = false
    local lid = UserData:getUserObj():getLid()
    if v.lid ~= lid then
        isEnemy = true
    end

    local id = tonumber(v.dragon)
    if id == nil or id <= 0 then
        id = 1
    end
    if id > 10 then
        id = 10
    end
    local url=GameData:getConfData("playerskill")[id].roleRes
    local name = v.un
    local fightState = v.state
    local obj = ccui.ImageView:create('uires/ui/common/touming.png')
    local weapon_illusion = v.weapon_illusion or 0
    local wing_illusion = v.wing_illusion or 0

    local changeEquipObj = GlobalApi:getChangeEquipState(nil, weapon_illusion, wing_illusion)
    local roleAni = GlobalApi:createLittleLossyAniByName(url..'_display',nil,changeEquipObj)
    roleAni:setScale(0.35)
    roleAni:setName('role')
    roleAni:getAnimation():play('idle', -1, 1)
    roleAni:setAnchorPoint(cc.p(0.5, 0))
    roleAni:setPosition(cc.p(obj:getContentSize().width/2,0))
    obj:addChild(roleAni)
    obj:setAnchorPoint(cc.p(0.5, 0))
    obj:setPosition(cc.p(self.hextab[hexpos.x][hexpos.y]._centerPosX,self.hextab[hexpos.x][hexpos.y]._centerPosY-5))
    obj:setLocalZOrder(-hexpos.y)

    --血条
    local bloodHpRes = isEnemy and "uires/ui/battle/plist/battle_hero_hp_1.png" or "uires/ui/battle/plist/battle_hero_hp_3.png"
    local bloodValue = 0
    if v.stayingPower  then
        bloodValue = (v.stayingPower > 100) and 0 or v.stayingPower
    end

    local loadingBarBg = ccui.ImageView:create("uires/ui/battle/plist/battle_hero_hp_4.png")
    local loadingBar = cc.ProgressTimer:create(cc.Sprite:create(bloodHpRes))
    loadingBarBg:setAnchorPoint(cc.p(0.5, 0))
    loadingBarBg:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height+80))
    loadingBarBg:setScaleX(1.2)
    loadingBarBg:setScale9Enabled(true)
    obj:addChild(loadingBarBg,1)
    loadingBar:setScaleX(1.2)
    loadingBar:setAnchorPoint(cc.p(0.5, 0))
    loadingBar:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height+80))
    loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    loadingBar:setMidpoint(cc.p(0, 0))
    loadingBar:setBarChangeRate(cc.p(1, 0))
    loadingBar:setPercentage(bloodValue)
    obj:addChild(loadingBar,2)
    
    --名字和骷髅图标显示
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(200, 30))
    local image = 'uires/ui/common/touming.png'
    if isEnemy == true then
        image = 'uires/ui/infinitebattle/infinitebattle_difficulty_1.png'
    end
    local rtImg = xx.RichTextImage:create(image)
    local rtName = xx.RichTextLabel:create('' .. name, 16,COLOR_TYPE.WHITE)
    richText:addElement(rtImg)
    richText:addElement(rtName)
    rtImg:setScale(0.7)
    richText:setAnchorPoint(cc.p(0.5, 0))
    richText:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height+80))
    richText:setAlignment('middle')
    richText:setCascadeOpacityEnabled(true)
    local color = isEnemy and COLOR_TYPE.RED or COLOR_TYPE.GREEN
    rtName:setColor(color)
    obj:addChild(richText)
         
    --战斗状态
    local fightSprite = GlobalApi:createSpineByName('map_fight',"spine/map_fight/map_fight",1)
    fightSprite:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height+130))
    fightSprite:setAnchorPoint(cc.p(0.5, 0))
    fightSprite:setAnimation(0,'animation',true)
    fightSprite:setScale(0.5)
    fightSprite:setName("fightSprite")

    local visible = self.fightmap[cellId] and true or false
    fightSprite:setVisible(visible)
    obj:addChild(fightSprite)

    gridBlock:addChild(obj)
    v["obj"] = obj
    v["bar"] = loadingBar
    if notOpacity then
        return
    end

    local inView = self:inPlayerView(hexpos.x,hexpos.y)
    if inView then
        obj:setCascadeOpacityEnabled(true)
        obj:setOpacity(0)
        obj:runAction(cc.FadeTo:create(0.5,50))

        loadingBar:setOpacity(0)
        loadingBar:runAction(cc.FadeTo:create(0.5,50))
        self.OpacityPlayer[#self.OpacityPlayer+1] = v.uid
    else
        obj:setCascadeOpacityEnabled(true)
        obj:setOpacity(0)
        obj:runAction(cc.FadeIn:create(1))
        loadingBar:setOpacity(0)
        loadingBar:runAction(cc.FadeIn:create(1))
    end
end


function TerritorialWarUI:enemyInvade()

   local uid = UserData:getUserObj():getUid() or 0
   local lid = UserData:getUserObj():getLid() or 0
   if self.curLid ~= lid then
     self.invadeImg:setVisible(false)
     return
   end
   
   local exitEnemy = false
   for k,v in pairs(self.otherObj) do
        if uid ~= v.uid and v.lid ~= lid then
            exitEnemy = true
            break
        end
    end

    if not exitEnemy then
      self.invadeImg:setVisible(false)
      return
   end
    self.invadeImg:setVisible(true)
   
    self.invadeImg:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.FadeIn:create(2),
            cc.DelayTime:create(1),
            cc.FadeOut:create(2),
            cc.DelayTime:create(0.5)
    ))) 
end

function TerritorialWarUI:setViewPlayerOpacity()

    for k,v in pairs(self.OpacityPlayer) do
        local data = playermap:getdata(v)
        if data ~= nil and data.obj ~= nil then
            data.obj:setCascadeOpacityEnabled(true)
            data.obj:runAction(cc.FadeIn:create(0.5))
            data.bar:runAction(cc.FadeIn:create(0.5))
            self.OpacityPlayer[k] = nil
        end
    end

    local flag = TerritorialWarMgr:getOpactityFlag()
    if not flag then
       return
    end

    --增加范围内的友方透明度
    local lid = UserData:getUserObj():getLid() or 0 
    local uid = UserData:getUserObj():getUid() or 0

    local openCellList = self:getAroundList(self.curHexPos.horIndex, self.curHexPos.verIndex, 2)
    for k1, v1 in pairs(openCellList) do
        local hexX,hexY = v1[1],v1[2]
        if self.hextab[hexX] ~= nil and self.hextab[hexX][hexY] ~= nil then
            local cellId = self.hextab[hexX][hexY]._cellId
            local topData = playermap:top(cellId)
            if topData ~= nil and topData.obj ~= nil and topData.uid ~= uid and topData.lid == lid then
                topData.obj:setCascadeOpacityEnabled(true)
                topData.obj:runAction(cc.FadeTo:create(0.5,50))
                topData.bar:runAction(cc.FadeTo:create(0.5,50))
                self.OpacityPlayer[#self.OpacityPlayer+1] = topData.uid
            end
        end
    end
end

function TerritorialWarUI:inPlayerView(x,y)

    local openCellList = self:getAroundList(self.curHexPos.horIndex, self.curHexPos.verIndex, 2)
    for k1, v1 in pairs(openCellList) do
        if x == v1[1] and y == v1[2] then
            return true
        end
    end

    return false
end

function TerritorialWarUI:getAroundList(x,y,range)
	local cellList = {}
	for i = 1, range do
        table.insert(cellList, {x+i, y})
        table.insert(cellList, {x-i, y})
        table.insert(cellList, {x, y+i})
        table.insert(cellList, {x, y-i})

		for k = -range, range - i do
            if k ~= 0 then
                table.insert(cellList, {x+k ,y+i})
            end
		end

		for k = -range + i, range do
            if k ~= 0 then
                table.insert(cellList, {x+k, y-i})
            end
		end
	end

	return cellList
end

function TerritorialWarUI:locationPos(target)

    local mapPosX, mapPosY = self:getMapContaierPos(target)
    local targetPos = cc.p(mapPosX, mapPosY)
    self.mapContainer:setPosition(targetPos)

end

function TerritorialWarUI:createMyself()

    local value = self.paramConfig.initialPos['value']
    local initCellId = tonumber(value[1])
    local sourcePos = {}
    if self.curHexPos == nil or self.curHexPos.horIndex == nil then
        sourcePos = self:convertToHexPos(initCellId)
    else
         sourcePos.x = self.curHexPos.horIndex
         sourcePos.y = self.curHexPos.verIndex
    end

    --碌脙碌陆碌卤脟掳脳酶卤锚
    local serverCellId = self.territoryWar.pos.cellId
    if serverCellId == nil then
        return
    end

    local serverPos = self:convertToHexPos(serverCellId)
    if serverPos == nil then
        return
    end

    local userName = UserData:getUserObj():getName()
    local role = RoleData:getMainRole()

    self.curHexPos.horIndex = serverPos.x
    self.curHexPos.verIndex = serverPos.y

    local mapPosX, mapPosY = self:getMapContaierPos()
    local targetPos = cc.p(mapPosX, mapPosY)
    self.mapContainer:setPosition(targetPos)

    --禄忙脰脝脰脺脦搂碌脛赂帽脳脫
    self:PaintAroundHex(serverCellId)
end

function TerritorialWarUI:createOthers(gridBlock,otherInfo,fightState)
    
    if otherInfo == nil then
        return
    end

    local pos = self:convertToHexPos(otherInfo.cellId)
    if pos == nil then
        return
    end

    local isEnenmy = false
    local lid = UserData:getUserObj():getLid()
    if otherInfo.lid ~= lid then
        isEnenmy = true
    end

    local id = tonumber(otherInfo.dragon)
    if id == nil or id <= 0 then
        id = 1
    end
    local dragonUrl=GameData:getConfData("playerskill")[id].roleRes

    self:createPlayerMode(pos.x,pos.y,gridBlock,isEnenmy,otherInfo.name,dragonUrl,otherInfo.uid,2,fightState)


end

function TerritorialWarUI:removeOthers(uid)
   
    if uid == UserData:getUserObj():getUid() then
        return
    end


    local data = playermap:delete(uid)
    if not data then
        return
    end

    self.otherObj[tostring(uid)] = nil
    self:enemyInvade()
    if data ~= nil and data.obj ~= nil then
        self.resBlock:removeChild(data.obj)
        data.obj = nil
        data.bar = nil
        local topData = playermap:top(data.pos.cellId)
        if topData ~= nil and topData.obj == nil then
            self:createMode(self.resBlock,playermap:top(topData.pos.cellId))
        end
    end

    local cellId = data.pos.cellId
    if self.fightmap[cellId] then
        self.fightmap[cellId] = self.fightmap[cellId] - 1
        if self.fightmap[cellId] <=0 then
            self.fightmap[cellId] = nil
        end
    end

end

function TerritorialWarUI:PlayerMove(destPos,sourcePos,uid,callBack,dest)

   if self.hextab[destPos.x][destPos.y] == nil or sourcePos == nil or uid == nil then
        return
   end
   local sourceCellId = self.hextab[sourcePos.x][sourcePos.y]._cellId
   local destCellId = self.hextab[destPos.x][destPos.y]._cellId
   local roleObj = nil
   local isTop = playermap:isTop(uid)
   local sourceData = nil

   if isTop then
       sourceData = playermap:pop(sourceCellId)
       roleObj = sourceData.obj
   else

       local newdata = playermap:delete(uid)
       if not newdata then
         return
       end
       self:createMode(self.resBlock,newdata)
       roleObj = newdata.obj
       sourceData = newdata
   end

   if not roleObj or not sourceData then
     return
   end


   --战斗状态检测
   local fightSprite = sourceData.obj:getChildByName('fightSprite')
   if fightSprite then
        fightSprite:setVisible(false)
    end
      
   local roleAni = roleObj:getChildByName('role')
   if sourcePos.x < destPos.x then
        roleAni:setScaleX(math.abs(roleAni:getScaleX()))
    elseif sourcePos.x > destPos.x then
        roleAni:setScaleX(-math.abs(roleAni:getScaleX()))
    else
        if sourcePos.y < destPos.y then
            roleAni:setScaleX(math.abs(roleAni:getScaleX()))
        else
            roleAni:setScaleX(-math.abs(roleAni:getScaleX()))
        end
    end

    local posX = self.hextab[destPos.x][destPos.y]._centerPosX
    local posY = self.hextab[destPos.x][destPos.y]._centerPosY

    roleAni:getAnimation():play('run', -1, 1)
    roleObj:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.5,cc.p(posX,posY)),
        cc.CallFunc:create(function()
            if not dest or (dest and dest ==  destCellId) then
                roleAni:getAnimation():play('idle', -1, 1)
            end
            roleObj:setLocalZOrder(-destPos.y)

            local uid = UserData:getUserObj():getUid()
            local destData = playermap:top(destCellId)
            if destData == nil or uid ~= destData.uid then
                if destData ~= nil and destData.obj ~= nil then
                    self.resBlock:removeChild(destData.obj)
                    destData.obj = nil
                    destData.bar = nil
                end

                local visible = self.fightmap[destCellId] and true or false
                
                fightSprite:setVisible(visible)

                sourceData.pos.cellId = destCellId  
                playermap:insert(destCellId,sourceData)  
            else

                sourceData.pos.cellId = destCellId  
                playermap:insert(destCellId,sourceData)

                self.resBlock:removeChild(sourceData.obj)
                sourceData.obj = nil
                sourceData.bar = nil
                local visible = self.fightmap[destCellId] and true or false
                if destData ~= nil and destData.obj ~= nil then
                    local fightSprite = destData.obj:getChildByName('fightSprite')
                    
                    fightSprite:setVisible(visible)
                end
            end

            local newSourceData = playermap:top(sourceCellId)
            if newSourceData ~= nil and newSourceData.obj == nil then
                self:createMode(self.resBlock,newSourceData)
            end
            
            if callBack then
                callBack()
            else
                self:setViewPlayerOpacity()
            end
        end)
    ))

end

function TerritorialWarUI:CheckInAround(cellId)
    
    for k,v in pairs(self.aroundHex) do
        if v == cellId then
            return true
        end
    end

    return false
end

function TerritorialWarUI:PaintAroundHex(cellId)
    self.aroundHex = {};
    local hexPos = self:convertToHexPos(cellId)
    for k,v in ipairs(self.posArr) do
        local posX = hexPos.x + self.posArr[k][1]
        local posY = hexPos.y + self.posArr[k][2]

        if self.hextab[posX] ~= nil and self.hextab[posX][posY] ~= nil then
            local cellId = self.hextab[posX][posY]._cellId
            self.aroundHex[k] = cellId
            self:DrawUnitHex(cellId,gridRes.mainroldRes)
        end
    end
end

--画格子
function  TerritorialWarUI:DrawUnitHex(cellId,res)
   
   local hexPos = self:convertToHexPos(cellId)
   if self.blockgrid == nil or self.hextab[hexPos.x] == nil or self.hextab[hexPos.x][hexPos.y] == nil then
    return
   end

   for k,v in pairs(self.paintedHex) do
        if not self:CheckInAround(k) then
            self.paintedHex[k]:setVisible(false)
        end
   end

   if self.paintedHex[cellId] == nil then
       local hexImg = ccui.ImageView:create(res)
       hexImg:setAnchorPoint(cc.p(0.5,0.5))
       local cellPos = cc.p(self.hextab[hexPos.x][hexPos.y]._centerPosX, self.hextab[hexPos.x][hexPos.y]._centerPosY)
       hexImg:setPosition(cellPos)
       self.paintedHex[cellId] = hexImg
       local zOder = -hexPos.y
       self.blockgrid:addChild(hexImg,zOder)
   else
       self.paintedHex[cellId]:setVisible(true)
       self.paintedHex[cellId]:loadTexture(res)
   end
   
end

-- 赂霉戮脻脝脕脛禄脰脨脨脛碌茫脣垄脨脗碌脴脥录
function TerritorialWarUI:refreshWorldMap(center_pos)
    local indexX, indexY = self:getBlockIndexByPosition(center_pos)
    local mapBlockPos = self:getBlockPosition(indexX, indexY)

    if self.mapBlockArr[indexX][indexY] == nil then
        self.mapBlockArr[indexX][indexY] = self:loadMapBlock(mapBlockPos)
    end

    for i = 1, self.mapBlockCountMaxX do
        for j = 1, self.mapBlockCountMaxY do
            if self:isPartOfBlockInScreen(i, j) then
                -- 脪陋脧脭脢戮
                if self.mapBlockArr[i][j] == nil then
                    local blockPos = self:getBlockPosition(i, j)
                    self.mapBlockArr[i][j] = self:loadMapBlock(blockPos)
                end
            else
                -- 脪陋脪脝鲁媒
                if self.mapBlockArr[i][j] ~= nil then
                    self.bgLayer:removeChild(self.mapBlockArr[i][j].bg)
                    self.gridLayer:removeChild(self.mapBlockArr[i][j].grid)
                    self.gridLayer:removeChild(self.mapBlockArr[i][j].res)
                    self.gridLayer:removeChild(self.mapBlockArr[i][j].effect)
                    self.mapBlockArr[i][j] = nil
                end
            end
        end
    end
end

-- 脜脨露脧脪禄赂枚碌脴脥录驴茅脢脟路帽脫脨虏驴路脰脭脷脝脕脛禄脛脷
function TerritorialWarUI:isPartOfBlockInScreen(indexX, indexY)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local blockPos = self:getBlockPosition(indexX, indexY)

    local leftBottom = blockPos
    local leftTop = cc.p(blockPos.x, blockPos.y + self.mapBlockHeight)
    local rightBottom = cc.p(blockPos.x + self.mapBlockWidth, blockPos.y)
    local rightTop = cc.p(blockPos.x + self.mapBlockWidth, blockPos.y + self.mapBlockHeight)

    local leftBottom_screen = self.mapContainer:convertToWorldSpace(leftBottom)
    local leftTop_screen = self.mapContainer:convertToWorldSpace(leftTop)
    local rightBottom_screen = self.mapContainer:convertToWorldSpace(rightBottom)
    local rightTop_screen = self.mapContainer:convertToWorldSpace(rightTop)

    -- 录矛虏茅4赂枚露楼碌茫脢脟路帽脭脷脝脕脛禄脛脷
    if self:isPointInScreen(leftBottom_screen) or
        self:isPointInScreen(leftTop_screen) or
        self:isPointInScreen(rightBottom_screen) or
        self:isPointInScreen(rightTop_screen) then
        return true
    end

    -- 脜脨露脧脳贸卤脽脭碌脢脟路帽脭脷脝脕脛禄脛脷
    if leftBottom_screen.y <= 0 and leftTop_screen.y >= winSize.height and leftBottom_screen.x >= 0 and leftBottom_screen.x < winSize.width then
        return true
    end 

    -- 脜脨露脧脫脪卤脽脭碌脢脟路帽脭脷脝脕脛禄脛脷
    if rightBottom_screen.y <= 0 and rightTop_screen.y >= winSize.height and rightBottom_screen.x >= 0 and rightBottom_screen.x <= winSize.width then
        return true
    end 

    -- 脜脨露脧脧脗卤脽脭碌脢脟路帽脭脷脝脕脛禄脛脷
    if leftBottom_screen.x <= 0 and rightBottom_screen.x >= winSize.width and leftBottom_screen.y >= 0 and leftBottom_screen.y <= winSize.height then
        return true
    end 

    -- 脜脨露脧脡脧卤脽脭碌脢脟路帽脭脷脝脕脛禄脛脷
    if leftTop_screen.x <= 0 and rightTop_screen.x >= winSize.width and leftTop_screen.y >= 0 and leftTop_screen.y <= winSize.height then
        return true
    end 

    -- 脣脛脤玫卤脽露录虏禄脭脷脝脕脛禄拢卢碌芦脢脟脰脨录盲虏驴路脰脭脷脝脕脛禄
    if leftTop_screen.x <= 0 and leftTop_screen.y >= winSize.height and rightBottom_screen.x >= winSize.width and rightBottom_screen.y <= 0 then
        return true
    end

    return false
end

-- 脜脨露脧脪禄赂枚脳酶卤锚脢脟路帽脭脷脝脕脛禄脰脨
function TerritorialWarUI:isPointInScreen(point)
    local winSize = cc.Director:getInstance():getVisibleSize()
    if point.x >= 0 and point.x < winSize.width and point.y >= 0 and point.y < winSize.height then
        return true
    end

    return false
end

-- 赂霉戮脻脳酶卤锚碌茫录脝脣茫鲁枚驴茅脳酶卤锚
function TerritorialWarUI:getBlockIndexByPosition(pos)
    local indexX = math.ceil(pos.x/self.mapBlockWidth)
    if pos.x % self.mapBlockWidth == 0 then
        indexX = indexX + 1
    end

    local indexY = math.ceil(pos.y/self.mapBlockHeight)
    if pos.y % self.mapBlockHeight == 0 then
        indexY = indexY + 1
    end

    return indexX, indexY
end

-- 禄帽碌脙脰赂露篓脳酶卤锚驴茅碌脛脦禄脰脙
function TerritorialWarUI:getBlockPosition(indexX, indexY)
    return cc.p((indexX - 1) * self.mapBlockWidth, (indexY - 1) * self.mapBlockHeight)
end

-- 脝脕脛禄脳酶卤锚脳陋禄炉脦陋碌脴脥录脳酶卤锚
function TerritorialWarUI:convertScreenLocationToMap(screen_pos)
    local mapPos = self.mapContainer:convertToNodeSpace(screen_pos)
    return mapPos
end

--赂帽脳脫ID脳陋禄禄脦陋赂帽脳脫脳酶卤锚
function TerritorialWarUI:convertToHexPos(Id)
    local cellId = tonumber(Id)
    if self.gidConfig[cellId] == nil then
        return
    end

    local pos = self.gidConfig[cellId]['pos']
    if #pos ~= 2 then
        return
    end
    local hexPos = {}
    hexPos.x,hexPos.y = pos[1],pos[2]
    return hexPos
end

--脪脌戮脻赂帽脳脫脳酶卤锚露篓脦禄脝脕脛禄脦禄脰脙
function TerritorialWarUI:getTargetPos(destPos,sourcePos)

    if self.hextab[destPos.x] == nil or self.hextab[sourcePos.x] == nil or self.hextab[destPos.x][destPos.y] == nil or self.hextab[sourcePos.x][sourcePos.y] == nil then
        return
    end

    local diffX = self.hextab[destPos.x][destPos.y]._centerPosX-self.hextab[sourcePos.x][sourcePos.y]._centerPosX
    local diffY = self.hextab[destPos.x][destPos.y]._centerPosY-self.hextab[sourcePos.x][sourcePos.y]._centerPosY
    self.loactionPos.x = self.loactionPos.x - diffX
    self.loactionPos.y = self.loactionPos.y - diffY
    cc.p(self.loactionPos.x,self.loactionPos.y)
    return cc.p(self.loactionPos.x,self.loactionPos.y)

end

function TerritorialWarUI:OtherPlayerPosChange(msg)
    
    if not self.open then
        return
    end
    
    if msg.set == true then
        self:setOthersPostion(msg)
        self:enemyInvade()
    elseif msg.set == false then
        self:OtherPlayerMove(msg)
    end


end

function TerritorialWarUI:setOthersPostion(msg)
    
    if not self.open then
        return
    end

    if msg.uid == UserData:getUserObj():getUid() then
        return
    end

    local uid = tostring(msg.uid)
    self.otherObj[uid].cellId = msg.cellId

    local sourceData = playermap:delete(msg.uid)
    if not sourceData then
      return
    end

    --得到位置信息和格子id
    local sourceCellId = sourceData.pos.cellId
    local destCellId = msg.cellId
    local desPos = self:convertToHexPos(msg.cellId) 
    local posX = self.hextab[desPos.x][desPos.y]._centerPosX
    local posY = self.hextab[desPos.x][desPos.y]._centerPosY

    if sourceData.obj == nil then
        self:createMode(self.resBlock,sourceData,true)
    end

    local roleObj = sourceData.obj
    if not roleObj or not sourceData then
      return
    end

    --战斗状态检测
    local fightSprite = sourceData.obj:getChildByName('fightSprite')
    if fightSprite then
        fightSprite:setVisible(false)
    end

    roleObj:setPosition(cc.p(posX,posY))

    local uid = UserData:getUserObj():getUid()
    local destData = playermap:top(destCellId)
    if destData == nil or uid ~= destData.uid then
        if destData ~= nil and destData.obj ~= nil then
            self.resBlock:removeChild(destData.obj)
            destData.obj = nil
            destData.bar = nil
        end
        local visible = self.fightmap[destCellId] and true or false
        
        fightSprite:setVisible(visible)

        sourceData.pos.cellId = destCellId  
        playermap:insert(destCellId,sourceData)  
    else
        sourceData.pos.cellId = destCellId  
        playermap:insert(destCellId,sourceData)

        self.resBlock:removeChild(sourceData.obj)
        sourceData.obj = nil
        sourceData.bar = nil
        local visible = self.fightmap[destCellId] and true or false
        if destData ~= nil and destData.obj ~= nil then
            local fightSprite = destData.obj:getChildByName('fightSprite')
            
            fightSprite:setVisible(visible)
        end
    end
    
    local newSourceData = playermap:top(sourceCellId)
    if newSourceData ~= nil and newSourceData.obj == nil then
        self:createMode(self.resBlock,newSourceData)
    end

    if not sourceData.obj then
        return
    end

    local inView = self:inPlayerView(desPos.x,desPos.y)
    if inView then
        sourceData.obj:setCascadeOpacityEnabled(true)
        sourceData.obj:setOpacity(0)
        sourceData.obj:runAction(cc.FadeTo:create(0.5,50))
        sourceData.bar:setOpacity(0)
        sourceData.bar:runAction(cc.FadeTo:create(0.5,50))
        self.OpacityPlayer[#self.OpacityPlayer+1] = msg.uid
    else
        sourceData.obj:setCascadeOpacityEnabled(true)
        sourceData.obj:setOpacity(0)
        local fadeIn = cc.FadeIn:create(1)
        sourceData.obj:runAction(fadeIn)
        sourceData.bar:setOpacity(0)
        sourceData.bar:runAction(cc.FadeIn:create(1))
    end
    
end

function TerritorialWarUI:OtherPlayerMove(msg)
    
    if not self.open then
        return
    end

    if msg.uid == UserData:getUserObj():getUid() then
        return
    end

    --从原堆栈中找到数据
    local data = playermap:getdata(msg.uid)
    if not data then
        return
    end

    local uid = tostring(msg.uid)
    self.otherObj[uid].cellId = msg.cellId

    local srCellId = data.pos.cellId
    local sourcePos = self:convertToHexPos(srCellId)
    local destCellId = msg.cellId
    local desPos = self:convertToHexPos(msg.cellId) 

    self:PlayerMove(desPos, sourcePos,msg.uid)

end

function TerritorialWarUI:otherPlayerEnter(msg)
    
    if not self.open then
        return
    end

    if msg.uid == UserData:getUserObj():getUid() then
        return
    end


    local uid = tostring(msg.uid)
    local otherInfo = {}
    otherInfo.cellId = msg.pos.cellId
    otherInfo.lid = msg.lid
    otherInfo.uid = msg.uid
    otherInfo.name = msg.un
    otherInfo.dragon = msg.dragon
    otherInfo.stayingPower = msg.stayingPower
    self.otherObj[uid] = otherInfo

    local data = playermap:getdata(msg.uid)
    if data ~= nil then
        return
    end
    playermap:insert(msg.pos.cellId,msg)
    self:createMode(self.resBlock,playermap:top(msg.pos.cellId))
    self:enemyInvade()
end

function TerritorialWarUI:playerHpChange(msg)

    local data = playermap:getdata(msg.uid)
    if not data then
        return
    end

    local hpValue = (msg.stayingPower == 0) and 100 or msg.stayingPower
    data.stayingPower = hpValue
    local hpBar = data.bar
    if hpBar then
        hpBar:setPercentage(hpValue)
    end
end

--脥卢虏陆驴贸脮录脕矛
function TerritorialWarUI:updateMine(msg)
    
    if not self.open then
        return
    end

    local lid = tostring(msg.lid)
    local cellId = tonumber(msg.cellId)

    --在自己领地才会同步
    local selfLid = UserData:getUserObj():getLid()
    if msg.lid ~= selfLid then
        return
    end

    if not self.element[cellId] or not self.element[cellId]._info then
        return
    end

    local id = tonumber(self.element[cellId]._info.resId)
    self:setMineState(cellId,id,0)
    local dfmapmineConfig = GameData:getConfData("dfmapmine")[id]
    local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT6'),dfmapmineConfig.name)
    promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)

    if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img ~= nil then
        self.element[cellId]._spine:getAnimation():play('open', -1, 1)
        self.element[cellId]._img:setImg(stateImg.occupy)
        self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
        self.element[cellId]._rtx:format(true)
    end

end

--
function TerritorialWarUI:addShareMonsterDeath(msg)

    local cellInfo = self.territoryData.cells[tostring(msg.cellId)];
    if cellInfo and cellInfo.resType == self.resType.creature then
        local creatureInfo = GameData:getConfData('dfmapcreature')[cellInfo.resId]
        if creatureInfo ~= nil and creatureInfo.isShare == 1 then
             cellInfo.resParam = 0 
        end
    end
end

--共享怪死亡
function TerritorialWarUI:updateShareMonsterDeath(msg)
   
    if not self.open then
        return
    end

   local cellId = tonumber(msg.cellId)
   if not self.element[cellId] or not self.element[cellId]._info or not self.element[cellId]._bg then
       return
   end

   local winSize = cc.Director:getInstance():getWinSize()
   self.screenCenterPoint = cc.p(winSize.width/2, winSize.height/2)

   local center_pos = self:convertScreenLocationToMap(self.screenCenterPoint)
   local indexX, indexY = self:getBlockIndexByPosition(center_pos)
   local gridBlock = self.mapBlockArr[indexX][indexY].res

   gridBlock:removeChild(self.element[cellId]._bg)
   self.element[cellId] = nil
   self.elementData[cellId] = nil

end

--同步共享怪血量
function TerritorialWarUI:monsterHpChange(msg)

   local cellId = tonumber(msg.cellId)
   if not self.element[cellId] or not self.element[cellId]._info or not self.element[cellId]._bg then
       return
   end

   local bloodValue = msg.stayingPower
   local cellInfo = self.territoryData.cells[msg.cellId];
   if cellInfo and cellInfo.resType == self.resType.creature then
        local creatureInfo = GameData:getConfData('dfmapcreature')[cellInfo.resId]
        if creatureInfo ~= nil and creatureInfo.isShare == 1  then
            cellInfo.resParam = bloodValue
        end
   end

   if self.element[cellId] and self.element[cellId]._bg then
        local bar = self.element[cellId]._bg:getChildByName("bar")
        bar:setPercentage(bloodValue)
   end

end

--同步瞭望塔状态
function TerritorialWarUI:updateWatchTowerState(msg)
    
    if not self.open then
        return
    end

    local cellId = tonumber(msg.cellId)
    if not self.element[cellId]._info then
        return
    end

    local selfLid = UserData:getUserObj():getLid()
    if self.curLid ~= selfLid then
        return
    end

    if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img ~= nil then
        self.element[cellId]._spine:getAnimation():play('open', -1, 1)
        self.element[cellId]._img:setImg(stateImg.occupy)
        self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
        self.element[cellId]._rtx:format(true)
    end
end

-- 戮眉脥脜鲁脡脭卤路脙脦脢赂帽脳脫
function TerritorialWarUI:onLegionMemberVisitCell(msg)
    
    if not self.open then
        return
    end

    local lid = tostring(msg.lid)
    local cellId = tonumber(msg.cellId)

    self:openViewCell(lid, cellId)
end

--踢玩家出局
function TerritorialWarUI:kickPlayer(msg)
    
    if not self.open then
        return
    end
    local str = (msg.idsmiss==1) and GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT9') or GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT10')
    promptmgr:showSystenHint(str)
    MainSceneMgr:showMainCity()

end

function TerritorialWarUI:onPlayerFightStateChange(msg)

    local uid = msg.uid

    --找到玩家数据
    local playerdata = playermap:getdata(uid)
    if not playerdata then
        return
    end

    playerdata.state = msg.state

    local cellId = playerdata.pos.cellId
    if msg.state then
        if not self.fightmap[cellId] then
            self.fightmap[cellId] = 0
        else
            self.fightmap[cellId] = self.fightmap[cellId] + 1
        end
    else
        if self.fightmap[cellId] then
            self.fightmap[cellId] = self.fightmap[cellId] - 1
            if self.fightmap[cellId] <=0 then
                self.fightmap[cellId] = nil
            end
        end
    end

    
    --找到该玩家所在格子栈顶元素
    local top = playermap:top(cellId)
    if not top or not top.obj then
        return
    end
    
    local fightSprite = top.obj:getChildByName('fightSprite')
    if not fightSprite then
        return
    end
    local visible = self.fightmap[cellId] and true or false
    fightSprite:setVisible(visible)
    
end

function TerritorialWarUI:openViewCell(lid, cellId)
    if self.visitedCells[lid] == nil then
        self.visitedCells[lid] = {}
    end

    local exist = false
    for k, v in ipairs(self.visitedCells[lid]) do
        if v == cellId then
            exist = true
            break
        end
    end

    if exist == false then
        table.insert(self.visitedCells[lid], cellId)

        -- 刷新云雾
        self:refreshCloudsAroundCell(cellId)
    end
end

function TerritorialWarUI:refreshCloudsAroundCell(cellId)
    local viewRange = self.viewRange
    local gridConf = GameData:getConfData('dfmapgrid')
    local cellInfo = gridConf[cellId]

    local selfLid = UserData:getUserObj():getLid()
    if cellInfo and cellInfo.immobilizationElement == 'element.7' and self.curLid == selfLid then
        viewRange = tonumber(GameData:getConfData('dfbasepara').watchTowerOpenRange.value[1])
    end

    local diffCells = {}
    local fogCellId = self:getFogCellIdFromElement(cellId)
    if fogCellId > 0 then
        local gridConf = GameData:getConfData('dffogconf')
        local cellInfo = gridConf[fogCellId]
        table.insert(diffCells, fogCellId)

        local openCellList = self:getViewListCell(cellInfo.pos[1], cellInfo.pos[2], viewRange)
        for k, v in pairs(openCellList) do
            local cellId1 = self:getCellIdByPos(v[1], v[2])

            if self.openCells[cellId1] == nil then
                self.openCells[cellId1] = cellId1
                table.insert(diffCells, cellId1)
            end
        end

        for k, v in ipairs(diffCells) do
            if self.clouds[v] and self.clouds[v] ~= 0 then
                self.clouds[v]:setVisible(false)
                self.clouds[v]:removeFromParent()
                self.clouds[v] = nil
            end
        end
    else
        local openCellList = self:getViewListCell(cellInfo.pos[1], cellInfo.pos[2], viewRange)
        for k, v in pairs(openCellList) do
            local cellId1 = self:getCellIdByPos(v[1], v[2])

            if self.openCells[cellId1] == nil then
                self.openCells[cellId1] = cellId1
                table.insert(diffCells, cellId1)
            end
        end

        for k, v in ipairs(diffCells) do
            if self.clouds[v] and self.clouds[v] ~= 0 then
                self.clouds[v]:setVisible(false)
                self.clouds[v]:removeFromParent()
                self.clouds[v] = 0
            end
        end
    end
end

--更新石碑状态
function TerritorialWarUI:updateStele(msg)

    local cellId = tonumber(msg.cellId)
    if not self.element[cellId]._info then
        return
    end

    self.stele = msg.stele
    self:updateWeekAchieve()

    local id = self.element[cellId]._info.resId
    local dfelementConfig = GameData:getConfData('dfelement')
    local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT5'),dfelementConfig[tonumber(id)].name) 
    promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)  
    if self.element[cellId] ~= nil and self.element[cellId]._spine ~= nil and self.element[cellId]._img ~= nil then
        self.element[cellId]._spine:getAnimation():play('open', -1, 1)
        self.element[cellId]._img:setImg(stateImg.occupy)
        self.element[cellId]._rtx:setPositionY(self.element[cellId]._height+self.element[cellId]._offisize)
        self.element[cellId]._rtx:format(true)
    end

    --脣垄脨脗麓芦脣脥碌茫陆脫驴脷
    self:updateTransportState()
end

function TerritorialWarUI:setLevel(cellId)
    
    local config = GameData:getConfData("dftransmit")
    local baseConfig = GameData:getConfData("dfbasepara")
    
    local count = #self.territoryWar.visitedCity
    for i=1,3 do
        local levelCellId = tonumber(baseConfig[config[i+1].target].value[1])
        if cellId == levelCellId and not self:visitedGate(levelCellId) then
           self.territoryWar.visitedCity[count+1] = cellId
           local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_HIT5'),config[i+1].name)
           promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
           TerritorialWarMgr:showFuncUI(1)
        end
    end

end

--鹿脴掳炉脢脟路帽路脙脦脢鹿媒
function TerritorialWarUI:visitedGate(cellId)

   if #self.territoryWar.visitedCity == 0 then
       return false
   end

   for k,v in ipairs(self.territoryWar.visitedCity) do
        if v == cellId then
            return true
        end
   end
   return false
end

function TerritorialWarUI:showResult(msg)
    
    GlobalApi:parseAwardData(msg.costs)

    -- 确保耐力值跟服务器保持一致
    local staying_power = msg.staying_power
    local cur_staying_power = UserData:getUserObj():getEndurance()
    if cur_staying_power ~= staying_power then
         UserData:getUserObj():setStayingPower(staying_power)
    end
    if msg.win == true then
        
        if msg.dead == true then
            TerritorialWarMgr:showMsgUI(4,msg.win,msg.costs[1][3])
            TerritorialWarMgr:updateMapInfo()
        else
            TerritorialWarMgr:showMsgUI(1,msg.win,msg.costs[1][3])
        end   
    else
        TerritorialWarMgr:setBattleEnd(1,msg.win,msg.costs[1][3])
        TerritorialWarMgr:updateMapInfo()
    end

end

function TerritorialWarUI:getMapContaierPos(cellPos)
    local heroPos = cellPos;
    if heroPos == nil then
        heroPos = {}
        heroPos.x = self.curHexPos.horIndex
        heroPos.y = self.curHexPos.verIndex
    end

    local heroMapPos = cc.p(0, 0)
    heroMapPos.x = self.hextab[heroPos.x][heroPos.y]._centerPosX
    heroMapPos.y = self.hextab[heroPos.x][heroPos.y]._centerPosY

    local winSize = cc.Director:getInstance():getVisibleSize()
    
    local mapPosX = (winSize.width/2 - heroMapPos.x * self.currScale) 
    local mapPosY = (winSize.height/2 - heroMapPos.y * self.currScale)

    if mapPosX > 0 then
        mapPosX = 0
    end

    if mapPosX < winSize.width - self.mapBlockWidth * self.currScale then
        mapPosX = winSize.width - self.mapBlockWidth * self.currScale
    end

    if mapPosY > 0 then
        mapPosY = 0
    end

    if mapPosY < winSize.height - self.mapBlockHeight * self.currScale then
        mapPosY = winSize.height - self.mapBlockHeight * self.currScale
    end

    return mapPosX, mapPosY
end

function TerritorialWarUI:clearAroundCells()
    for k,v in pairs(self.aroundHex) do
        self:DrawUnitHex(v, gridRes.normalRes)
    end
end

function TerritorialWarUI:clearClouds()
    for k, v in pairs(self.clouds) do
        if v and v ~= 0 then
            v:removeFromParent()
            self.clouds[k] = nil
        end
    end

    self.clouds = {}
end

function TerritorialWarUI:onHide()
    
    self.plistLoaded = nil
    for k, v in pairs(self.jsonLoaded) do
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(k .. ".json")
    end
    self.jsonLoaded = nil
    self.open = false
    self:clearClouds()
end

function TerritorialWarUI:breakMove(callback)

    --清空上次路径
    if self.pathMark then
        for k,v in pairs(self.pathMark) do
            if v then
                v:removeFromParent(true)
            end
        end
        self.pathMark = {}
    end
    if self.flagPic then
        self.flagPic:setVisible(false)
    end        
    self.moveBtn:setVisible(false)
    local uid = UserData:getUserObj():getUid()
    local playerdata = playermap:getdata(uid)
    if playerdata and playerdata.obj then
        local playermode = playerdata.obj:getChildByName("role")
        if playermode then
            playermode:getAnimation():play('idle', -1, 1)
        end
    end 

    if self.clickBackCity then
        TerritorialWarMgr:setBattleEnd(nil,nil,nil)
        TerritorialWarMgr:hideMapUI()
    end

    self.moveFurther,self.longMoving = false,false
end

--脟毛脟贸脪脝露炉
function TerritorialWarUI:Move(cellId,callBack,destCellId)
    
    if self.moving == true then
        return
    end

    local cellPos = self:convertToHexPos(cellId)

    --脟毛脟贸脪脝露炉
    local args = {cellId = cellId}
    MessageMgr:sendPost('move_to','territorywar',json.encode(args),function (response)
            
        local code = response.code
        local data = response.data

        if code ~= 0 then

            TerritorialWarMgr:handleErrorCode(code)
            self:breakMove()
            return
        end 
        local costs = response.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end

        local action_point = response.data.action_point
        if action_point then
            local curPoint = UserData:getUserObj():getActionPoint()
            if curPoint ~= action_point then
                local diff = action_point - curPoint
                GlobalApi:parseAwardData({{'user','action_point',diff}})
            end

            local action_point_time = response.data.action_point_time
            UserData:getUserObj():setActionPointTime(action_point_time)
            UIManager:getSidebar():resetActionPointRestore()
        end

        self:openViewCell(self.curLid, cellId)

        local sourcePos = {x = self.curHexPos.horIndex, y = self.curHexPos.verIndex}
        local uid = UserData:getUserObj():getUid()
        self.moving = true
        self:PlayerMove(cellPos,sourcePos,uid,function ()
            self.moving = false
            self:PaintAroundHex(cellId) 
            if callBack then
                callBack()
            end
        end,destCellId)
        
        local mapPosX, mapPosY = self:getMapContaierPos(cellPos)
        local targetPos = cc.p(mapPosX, mapPosY)

        self.mapContainer:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5,targetPos),
            cc.CallFunc:create(function()
                self.curHexPos.horIndex = cellPos.x
                self.curHexPos.verIndex = cellPos.y

                self:setViewPlayerOpacity()
                
                local selfLid = UserData:getUserObj():getLid()
                if self.curLid == selfLid then
                    self:setLevel(cellId)
                end
            end)
        ))

    end) 

end

-- 麓麓陆篓脭脝虏茫
function TerritorialWarUI:refreshClouds(effectBlock)
    if self.showClouds == false then
        return
    end

    local fogConf = GameData:getConfData('dffogconf')

    for k, v in pairs(fogConf) do
        local cellPos = self:getCellPos(v.pos[1], v.pos[2])
        if self:isCellCloudShow(k) then
            if self.clouds[k] == nil or self.clouds[k] == 0 then
                local cloud = ccui.ImageView:create('uires/ui/territorialwars/terwars_cloud.png')
                cloud:setPosition(cellPos)
                effectBlock:addChild(cloud)
                self.clouds[k] = cloud
            end  
        end
    end
end

-- 判断这个是否显示云
function TerritorialWarUI:isCellCloudShow(cellId)
    if self.openCells[cellId] ~= nil then
        return false
    end

    return true
end


function  TerritorialWarUI:createMapBoss(v,bossCellId)

    bossCellId = tonumber(bossCellId)
    self.BossInfo = {}
    local dfbaseparaCfg = GameData:getConfData("dfbasepara")
    local info = self:convertToHexPos(bossCellId)
    local paramIndex = tonumber(v.resParam)+1
    local level = tonumber(v.resId)
    local dfbossforceCfg = GameData:getConfData("dfbossforce")[level]
    local maxNum = #dfbossforceCfg.battleId
    paramIndex = (paramIndex > maxNum or paramIndex < 1) and 1 or paramIndex
    local fomationConfig = GameData:getConfData("formation")[dfbossforceCfg.battleId[paramIndex]]
    local monsterId = fomationConfig['pos'..fomationConfig.boss]
    local monsterConfig = GameData:getConfData("monster")[monsterId]
    local scale = monsterConfig.scale
    local offsetY = monsterConfig.uiOffsetY
    local modelAin = nil
    local nameOffsetY = 100
    local bg = self.resBlock:getChildByTag(bossCellId + 1000)
    if not bg then
        bg = ccui.ImageView:create('uires/ui/common/touming.png')
        local spineAni = GlobalApi:createLittleLossyAniByName(monsterConfig.url.."_display")
        spineAni:setScale(scale/100)
        spineAni:setAnchorPoint(cc.p(0.5, 0))
        spineAni:setPosition(cc.p(bg:getContentSize().width/2,0+offsetY))
        spineAni:getAnimation():play('idle', -1, 1)
        spineAni:setName('mode')
        bg:addChild(spineAni)
        bg:setAnchorPoint(cc.p(0.5, 0))
        bg:setPosition(cc.p(self.hextab[info.x][info.y]._centerPosX,self.hextab[info.x][info.y]._centerPosY-10))


        local bossFlagImg = ccui.ImageView:create('uires/ui/territorialwars/terwars_bosshead.png')
        bossFlagImg:setPosition(cc.p(-50,bg:getContentSize().height+nameOffsetY-10))
        bossFlagImg:setAnchorPoint(cc.p(0.5, 0))
        bossFlagImg:setScale(0.9)
        bg:addChild(bossFlagImg)

        local bossNameTx = ccui.Text:create()
        bossNameTx:setAnchorPoint(cc.p(0.5, 0))
        bossNameTx:setFontName("font/gamefont.ttf")
        bossNameTx:enableOutline(COLOR_TYPE.BLACK, 1)
        bossNameTx:setFontSize(20)
        bossNameTx:setColor(COLOR_TYPE.RED)
        bossNameTx:setString(monsterConfig.heroName)
        bossNameTx:setPosition(cc.p(bg:getContentSize().width/2,bg:getContentSize().height+nameOffsetY))
        bg:addChild(bossNameTx)
        local zOrder = -self.hextab[info.x][info.y]._centerPosY
        self.resBlock:addChild(bg,zOrder,bossCellId + 1000)
        modelAin = spineAni
    else
        local model = bg:getChildByName('mode')
        if model ~= nil then
            modelAin = model
        end
    end
    if modelAin ~= nil then
       self.BossInfo._spine = modelAin
       self.BossInfo._cellId = bossCellId
       self.BossInfo._bossforceCfg = dfbossforceCfg
       self.BossInfo._bg = bg  
       self.BossInfo._paramIndex = paramIndex
       self.BossInfo._level = self.territoryData.level or 1
    end

end

--碾压之后删除怪物
function TerritorialWarUI:deleteMonster(cellId)

   local cellId = tonumber(cellId)
   if not self.element[cellId] or not self.element[cellId]._info or not self.element[cellId]._bg then
       return
   end

   local winSize = cc.Director:getInstance():getWinSize()
   self.screenCenterPoint = cc.p(winSize.width/2, winSize.height/2)

   local center_pos = self:convertScreenLocationToMap(self.screenCenterPoint)
   local indexX, indexY = self:getBlockIndexByPosition(center_pos)
   local gridBlock = self.mapBlockArr[indexX][indexY].res

   gridBlock:removeChild(self.element[cellId]._bg)
   self.element[cellId] = nil
   self.elementData[cellId] = nil

end

function TerritorialWarUI:getDragonResCount()
    return self.territoryWar.dragonScaleCount
end

function TerritorialWarUI:bossbirth(msg)
    local bossInfo = {}
    bossInfo.resParam = msg.boss.bossIndex
    bossInfo.resId = msg.boss.bossLevel
    self:createMapBoss(bossInfo,msg.boss.bossCellId)
end

function TerritorialWarUI:showBossUI(cellId)

    local isAround = self:CheckInAround(cellId)
    TerritorialWarMgr:showBossUI(self.BossInfo._bossforceCfg,self.BossInfo._paramIndex,cellId,self.curLid,self.BossInfo._level,isAround)
end

return TerritorialWarUI