local PrefectureUI = class("PrefectureUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PrefectureUI:ctor(id,owner,surplus_time)
	self.uiIndex = GAME_UI.UI_PREFECTURE
    self.id = id
    self.owner = owner or {}
	self.surplus_time = surplus_time
end

function PrefectureUI:timeoutCallback(img,img1,tx,pos)
    local l = img1:getChildByTag(9999)
    if l then
        l:removeFromParent()
    end
    if self.owner.time then
		local lordMaxSeconds = tonumber(GlobalApi:getGlobalValue('lordMaxHour'))*3600
		local lordLimitSeconds = tonumber(GlobalApi:getGlobalValue('lordLimitHour'))*60
        local diffTime = self.surplus_time
		if self.surplus_time > lordLimitSeconds then
			diffTime = self.surplus_time - lordLimitSeconds
		end
		if diffTime >= lordMaxSeconds then
			diffTime = lordMaxSeconds
		end
        local label = img:getChildByTag(9999)
        local size = img:getContentSize()
        if label then
            label:removeFromParent()
        end
        label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        label:setTag(9999)
        label:setPosition(pos or cc.p(size.width/2,-100))
        label:setAnchorPoint(cc.p(0,0.5))
        img:addChild(label)
        Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,tx,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.ORANGE,25,function ()
            local args = {id = self.id}
            MessageMgr:sendPost('lord_get','battle',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    self.owner = data.owner or {}
                    -- local cityData = MapData.data[self.id]
                    -- cityData:setOwner(self.owner)
                    if data.self then
                        MapData.lordId = data.self
                    else
                        MapData.lordId = nil
                    end
                    -- local uid = UserData:getUserObj():getUid()
                    -- if data.owner and data.owner.uid == uid then
                    --     local id = self.id
                    --     MapData.lordId = id
                    -- end
					self.surplus_time = data.surplus_time
                    MapData:setLordDrop(data.self_lord_drop)
                    self:updatePanel()
                end
            end)
        end)
    else
        local label = img:getChildByTag(9999)
        if label then
            label:removeFromParent()
        end
    end
end

function PrefectureUI:updatePanel()
    local bgImg = self.root:getChildByName("prefecture_bg_img")
    local prefectureImg = bgImg:getChildByName("prefecture_img")
	local cityData = MapData.data[self.id]
    local keyArr = string.split(cityData:getName() , '.')
    -- self.cityNameTx:setString(keyArr[#keyArr])
    self.cityNameTx:setString(cityData:getName())
    if self.owner.fight_force and self.owner.level then
        self.forceLabel:setString(self.owner.fight_force)
        local lvTx = self.nameBgImg:getChildByTag(9999)
        if lvTx then
            lvTx:setString(self.owner.level)
        else
            local label = cc.LabelAtlas:_create('', "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setPosition(cc.p(0, 20))
            label:setString(self.owner.level)
            self.nameBgImg:addChild(label)
        end
    else
        self.forceLabel:setString('')
        local lvTx = self.nameBgImg:getChildByTag(9999)
        if lvTx then
            lvTx:removeFromParent()
        end
    end

    if self.owner.name then
        self.nameTx:setString(self.owner.name)
        -- self.lvTx:setString(self.owner.level)
    else
        self.nameTx:setString('')
        -- self.lvTx:setString('')
    end

    if self.owner.hid then
        local spineAni = self.prefectureImg:getChildByTag(9999)
        if spineAni then
            spineAni:removeFromParent()
        end
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
            local promote = nil
            local weapon_illusion = nil
            local wing_illusion = nil
            if self.owner.promote and self.owner.promote[1] then
                promote = self.owner.promote[1]
            end
            local heroConf = GameData:getConfData("hero")
            if heroConf[tonumber(self.owner.hid)].camp == 5 then
                if self.owner.weapon_illusion and self.owner.weapon_illusion > 0 then
                    weapon_illusion = self.owner.weapon_illusion
                end
                if self.owner.wing_illusion and self.owner.wing_illusion > 0 then
                    wing_illusion = self.owner.wing_illusion
                end
            end
            local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
            dump(changeEquipObj)
            local spineAni = GlobalApi:createLittleLossyAniByRoleId(tonumber(self.owner.hid), changeEquipObj)
            if spineAni then
                spineAni:setOpacity(0)
                spineAni:setPosition(cc.p(170,180))
                self.prefectureImg:addChild(spineAni,1,9999)
                spineAni:getAnimation():play('idle', -1, 1)
                spineAni:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
            end
        end)))
    else
        local spineAni = self.prefectureImg:getChildByTag(9999)
        if spineAni then
            spineAni:removeFromParent()
        end
    end

    
    local uid = UserData:getUserObj():getUid()
	if self.prefectureImg:getChildByName('rich_text_remain_time') then
		self.prefectureImg:removeChildByName('rich_text_remain_time')
	end
    -- if self.owner.uid and uid == self.owner.uid then
    if MapData.lordId == self.id then
        self.retreatBtn:setVisible(true)
        self.ownerBtn:setVisible(true)
        self.occupyBtn:setVisible(false)
        self.cityImg:setVisible(false)
        self.nameBgImg:setVisible(true)
        self.nameTx:setVisible(true)
        self.zhanBgImg:setVisible(true)
        self.infoTx:setVisible(false)
        self.pl1:setVisible(false)
        self.pl2:setVisible(true)
        self.cityImg:setVisible(false)
        if self.foodRt then
            self.foodRt.richText:setVisible(false)
        end
        self:timeoutCallback(self.prefectureImg,self.awardBgImg1,GlobalApi:getLocalStr('REMAINDER_TIME'),cc.p(600,130))
        -- self.timeInfoTx:setVisible(true)
        local awardsTab = cityData:getPrefecture() --cityData:getPrefecture()
        if self.id == 0 then
            awardsTab = MapData:getLordDrop()
        end
        for i=1,5 do
            local str = 'award'..i
            if awardsTab[str] and awardsTab[str][1] then
                local award = DisplayData:getDisplayObj(awardsTab[str][1])
                ClassItemCell:updateItem(self.showAward1[i], award, 1)
                self.showAward1[i].awardBgImg:setVisible(true)
                self.showAward1[i].lvTx:setVisible(true)
                award:setLightEffect(self.showAward1[i].awardBgImg)
                local stype = award:getCategory()
                if stype == 'equip' then
                    self.showAward1[i].lvTx:setString('Lv.'..award:getLevel())
                else
                    self.showAward1[i].lvTx:setString('x'..award:getNum())
                end
                if award:getExtraBg() then
                    self.showAward1[i].doubleImg:setVisible(true)
                else
                    self.showAward1[i].doubleImg:setVisible(false)
                end

                self.showAward1[i].awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        GetWayMgr:showGetwayUI(award,false)
                    end
                end)
            else
                self.showAward1[i].awardBgImg:setVisible(false)
            end
        end
    else
        self.retreatBtn:setVisible(false)
        self.ownerBtn:setVisible(false)
        self.occupyBtn:setVisible(true)

        self.pl1:setVisible(true)
        self.pl2:setVisible(false)
        self:timeoutCallback(self.awardBgImg1,self.prefectureImg,GlobalApi:getLocalStr('REMAINDER_TIME'))
        -- self.timeInfoTx:setVisible(false)
        local awardsTab = cityData:getPrefecture()
        if self.id == 0 then
            awardsTab = MapData:getLordDrop()
        end
        for i=1,5 do
            local str = 'award'..i
            if awardsTab[str] and awardsTab[str][1] then
                local award = DisplayData:getDisplayObj(awardsTab[str][1])
                ClassItemCell:updateItem(self.showAward[i], award, 1)
                self.showAward[i].awardBgImg:setVisible(true)
                self.showAward[i].lvTx:setVisible(true)
                award:setLightEffect(self.showAward[i].awardBgImg)
                local stype = award:getCategory()
                if stype == 'equip' then
                    self.showAward[i].lvTx:setString('Lv.'..award:getLevel())
                else
                    self.showAward[i].lvTx:setString('x'..award:getNum())
                end
                self.showAward[i].awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        GetWayMgr:showGetwayUI(award,false)
                    end
                end)
            else
                self.showAward[i].awardBgImg:setVisible(false)
            end
        end
        local bottomBgImg = self.pl1:getChildByName('bottom_bg_img')
        local descTx = bottomBgImg:getChildByName('desc_tx')
        descTx:ignoreContentAdaptWithSize(false)
        descTx:setTextAreaSize(cc.size(560,180))
        descTx:setString(cityData:getDesc())

        if not self.foodRt then
            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(200, 30))
            local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('NEED_FOOD_1'), 21, COLOR_TYPE.ORANGE)
            local re2 = xx.RichTextLabel:create(cityData:getFood(4), 21, COLOR_TYPE.WHITE)
            re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
            re2:setStroke(COLOR_TYPE.BLACK, 1)
            richText:addElement(re1)
            richText:addElement(re2)
            richText:setAnchorPoint(cc.p(0.5,0.5))
            richText:setPosition(cc.p(750,40))
			richText:setAlignment('middle')
			richText:setVerticalAlignment('middle')
            self.prefectureImg:addChild(richText)
            self.foodRt = {richText = richText , re1 = re1 ,re2 = re2}
        end
        self.foodRt.richText:setVisible(true)
        if self.owner.name then
            --self.foodRt.richText:setPosition(cc.p(740,65))
            self.infoTx:setVisible(true)
            self.cityImg:setVisible(false)
            self.nameBgImg:setVisible(true)
            self.nameTx:setVisible(true)
            self.zhanBgImg:setVisible(true)
        else
            --self.foodRt.richText:setPosition(cc.p(740,57))
            self.infoTx:setVisible(false)
            self.cityImg:setVisible(true)
            self.nameBgImg:setVisible(false)
            self.nameTx:setVisible(false)
            self.zhanBgImg:setVisible(false)
        end

		local richText = xx.RichText:create()
		richText:setName('rich_text_remain_time')
        richText:setContentSize(cc.size(400, 30))
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('REMAINDER_TIME_2'), 21, COLOR_TYPE.ORANGE)
		local time = self.surplus_time
		local lordLimitSeconds = tonumber(GlobalApi:getGlobalValue('lordLimitHour'))*60
		if self.surplus_time > lordLimitSeconds then
			time = lordLimitSeconds
		end
		local str = '00:00:00'
		local color = COLOR_TYPE.RED
		if time >= 60 then
			local h = string.format("%02d", math.floor(time/3600))
			local m = string.format("%02d", math.floor(time%3600/60))
			local s = string.format("%02d", math.floor(time%3600%60%60))
			str = h..':'..m ..':'..s
			color = COLOR_TYPE.GREEN
		end
        local re2 = xx.RichTextLabel:create(str, 21, color)
        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re2:setStroke(COLOR_TYPE.BLACK, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setPosition(cc.p(750,70))
		richText:setAlignment('middle')
		richText:setVerticalAlignment('middle')
        self.prefectureImg:addChild(richText)
		richText:format(true)
    end

    local function getPos(i,size)
        return cc.p((i - 0.5)*(size.width + 20) + 10,size.height/2 + 7)
    end

    local index = 0
    local maxIndex = 0
    local singleSize
    self.awardSv:removeAllChildren()
    if self.owner.got then
        for k,v in pairs(self.owner.got) do
            maxIndex = maxIndex + 1
            local award = DisplayData:getDisplayObj(v)
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, self.awardSv)
            singleSize = tab.awardBgImg:getContentSize()
            award:setLightEffect(tab.awardBgImg)
            local stype = award:getCategory()
            if stype == 'equip' then
                tab.lvTx:setString('Lv.'..award:getLevel())
            else
                tab.lvTx:setString('x'..award:getNum())
            end
            if award:getExtraBg() then
                tab.doubleImg:setVisible(true)
            else
                tab.doubleImg:setVisible(false)
            end
            tab.awardBgImg:setPosition(getPos(maxIndex,singleSize))
        end
    end
    if singleSize then
        self.awardSv:setInnerContainerSize(cc.size(singleSize.width*maxIndex,singleSize.height))
    end
end

function PrefectureUI:init()
	local bgImg = self.root:getChildByName("prefecture_bg_img")
	self.prefectureImg = bgImg:getChildByName("prefecture_img")
    self:adaptUI(bgImg, self.prefectureImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.prefectureImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

    local leftImg = self.prefectureImg:getChildByName('left_bg_img')
    local rightImg = self.prefectureImg:getChildByName('right_bg_img')
    self.infoTx = self.prefectureImg:getChildByName('info_tx')
    self.infoTx:setString(GlobalApi:getLocalStr('NOT_CONSUMED'))
	self.infoTx:setAnchorPoint(cc.p(0.5,0.5))
	self.infoTx:setPosition(cc.p(750,16))
    self.pl1 = rightImg:getChildByName("pl_1")
    self.pl2 = rightImg:getChildByName("pl_2")
    self.awardBgImg1 = self.pl1:getChildByName("award_bg_img")
    -- local titleImg = self.awardBgImg1:getChildByName("title_bg_img")
    local titleTx = self.awardBgImg1:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('ONE_MINUTE_GET'))
    self.awardBgImg2 = self.pl2:getChildByName("award_bg_1_img")
    -- local titleImg = self.awardBgImg2:getChildByName("title_bg_img")
    local titleTx = self.awardBgImg2:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('ONE_MINUTE_GET'))
    self.awardBgImg3 = self.pl2:getChildByName("award_bg_2_img")
    local titleImg = self.awardBgImg3:getChildByName("title_bg_img")
    local titleTx = titleImg:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('HAD_GET'))
    self.awardSv = self.awardBgImg3:getChildByName('award_sv')
    self.awardSv:setScrollBarEnabled(false)
    local closeBtn = self.prefectureImg:getChildByName("close_btn")
    -- self.timeBgImg = awardBgImg:getChildByName("time_bg_img")

    -- self.timeInfoTx = self.prefectureImg:getChildByName("time_info_tx")
    -- self.timeInfoTx:setString(GlobalApi:getLocalStr('REMAINDER_TIME_1'))
    local titleImg = self.prefectureImg:getChildByName("title_img")
	self.cityNameTx = titleImg:getChildByName("city_name_tx")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePrefecturePanel()
        end
    end)

   	self.numTx1 = self.prefectureImg:getChildByName("num_1_tx")
    self.numTx2 = self.prefectureImg:getChildByName("num_2_tx")

    self.showAward = {}
    local pos1 = {cc.p(67,64),cc.p(181,64),cc.p(295,64),cc.p(409,64),cc.p(523,64)}
    for i=1,5 do
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        tab.awardBgImg:setPosition(pos1[i])
        self.awardBgImg1:addChild(tab.awardBgImg)
        self.showAward[i] = tab
    end

    self.showAward1 = {}
    for i=1,5 do
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        tab.awardBgImg:setPosition(pos1[i])
        self.awardBgImg2:addChild(tab.awardBgImg)
        self.showAward1[i] = tab
    end

    self.zhanBgImg = leftImg:getChildByName("zhan_bg_img")
    local forceLabel = self.zhanBgImg:getChildByName('fightforce_tx')
    forceLabel:setString('')

    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    self.zhanBgImg:addChild(self.forceLabel)

    self.cityImg = leftImg:getChildByName("city_img")
    local cityData = MapData.data[self.id]
    self.cityImg:loadTexture(cityData:getBtnResource())
    self.cityImg:ignoreContentAdaptWithSize(true)
    local infoTx = self.cityImg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('NO_OWNER'))
    infoTx:setPosition(cc.p(self.cityImg:getContentSize().width/2,-58))

    self.nameBgImg = leftImg:getChildByName("name_bg_img")
    self.nameTx = self.nameBgImg:getChildByName('name_tx')

    self.ownerBtn = self.prefectureImg:getChildByName("owner_btn")
    infoTx = self.ownerBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('OTHER_CAMP'))
    self.retreatBtn = self.prefectureImg:getChildByName("retreat_btn")
    infoTx = self.retreatBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('STR_RETREAT'))
    self.occupyBtn = self.prefectureImg:getChildByName("occupy_btn")
    infoTx = self.occupyBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('STR_OCCUPY1'))
    self.occupyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- local diffTimes = GlobalApi:getGlobalValue('lordOccupyCount') - MapData.lord.count
            -- if diffTimes <= 0 then
            --     promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NO_TIMES'), COLOR_TYPE.RED)
            --     return
            -- end
			local limitTime = self.surplus_time
			local lordLimitSeconds = tonumber(GlobalApi:getGlobalValue('lordLimitHour'))*60
			if self.surplus_time > lordLimitSeconds then
				limitTime = self.surplus_time - lordLimitSeconds
			end
			if limitTime < 60 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('CONSUMED_DESC'), COLOR_TYPE.RED)
				return
			end

            local cityData = MapData.data[self.id]
            local needFood = cityData:getFood(4)
            local food = UserData:getUserObj():getFood()
            if needFood > food then
                promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY_FOOD"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                    GlobalApi:getGotoByModule("food")
                end)
                return
            end
            if self.owner and self.owner.uid then
                local fightForce = self.owner.fight_force
                local myFightForce = UserData:getUserObj():getFightforce()
                if myFightForce < fightForce*GlobalApi:getGlobalValue('fightForceDiffPercent')/100 then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_FIGHTFORCE'), MESSAGE_BOX_TYPE.MB_OK)
                    return
                end
            end
            local cityData = MapData.data[self.id]
            local keyArr = string.split(cityData:getName() , '.')
            local name = keyArr[#keyArr]
            local mapData = MapData.data
            local uid = UserData:getUserObj():getUid()
            -- for i,v in ipairs(mapData) do
            --     local owner = v:getOwner()
                if MapData.lordId then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('YOU_HAD_OCCUPY_ONE_CITY'),name), MESSAGE_BOX_TYPE.MB_OK)
                    return
                end
            -- end
            local cityId = MapData.lord.leave_cid
            local diffTime = MapData.lord.leave_time + GlobalApi:getGlobalValue('lordReoccupyInterval')*60 - GlobalData:getServerTime()
            if cityId == self.id and diffTime > 0 then
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('REOCCUPY_CITY'),GlobalApi:getGlobalValue('lordReoccupyInterval')*60,diffTime), MESSAGE_BOX_TYPE.MB_OK)
                return
            end
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CAN_OCCUPY_ONE_CITY'),name), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                local args = {
                    id = self.id
                }
                MessageMgr:sendPost('occupy','battle',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        if data.owner then
                            if self.owner and self.owner.uid then
                                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('CONGRATULATIONS_TO_OCCUPY_1'),name), COLOR_TYPE.GREEN)
                            else
                                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('CONGRATULATIONS_TO_OCCUPY'),name), COLOR_TYPE.GREEN)
                            end
                            local cityData = MapData.data[self.id]
                            self.owner = data.owner or {}
                            -- cityData:setOwner(data.owner)
                            local id = self.id
                            MapData.lordId = id
                            MapData.lord.count = MapData.lord.count + 1
                            UserData:getUserObj():setGuideCityTime(data.owner.time)
                            self:updatePanel()
                        elseif data.info then
                            local id = self.id
                            MapMgr:playPVPBattle(BATTLE_TYPE.LORD,id,4,data.info,function()
                                MapMgr:showMainScene(2,id,function()
                                    MapMgr:showPrefecturePanel(id)
                                end)
                            end)
                        end
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                    elseif code == 101 then
                        promptmgr:showMessageBox(GlobalApi:getLocalStr('FIGHTING'), MESSAGE_BOX_TYPE.MB_OK)
                    else
                        promptmgr:showMessageBox(GlobalApi:getLocalStr('THE_CITY_HAD_OCCUPY'), MESSAGE_BOX_TYPE.MB_OK)
                    end
                end)
            end)
        end
    end)
    self.retreatBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('LEAVE_THE_CITY'),name), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                local args = {
                    id = self.id
                }
                MessageMgr:sendPost('leave','battle',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                        end
                        -- local cityData = MapData.data[self.id]
                        -- cityData:setOwner()
                        UserData:getUserObj():setGuideCityTime(0)
                        MapData.lordId = nil
                        self.owner = data.owner or {}
                        MapData.lord.leave_cid = self.id
                        MapData.lord.leave_time = data.leave_time
						self.surplus_time = data.surplus_time
                        self:updatePanel()
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LORD_DESC_1'), COLOR_TYPE.GREEN)
                    else
                        promptmgr:showMessageBox(GlobalApi:getLocalStr('MY_CITY_HAD_OCCUPY'), MESSAGE_BOX_TYPE.MB_OK)
                    end
                end)
            end)
        end
    end)
    self.ownerBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:showViewPrefecturePanel()
        end
    end)
    self:updatePanel()
end

return PrefectureUI