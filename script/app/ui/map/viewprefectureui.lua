local ViewPrefectureUI = class("ViewPrefectureUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ViewPrefectureUI:ctor(owners)
	self.uiIndex = GAME_UI.UI_VIEWPREFECTURE
    self.page = 1
    self.timeSort = 0
    self.forceSort = 0
    self.idSort = 1
    self.checked = true
    self.owners = owners or {}
    self:getOwners()
end

function ViewPrefectureUI:timeoutCallback(img,time)
    if time then
		local lordMaxSeconds = tonumber(GlobalApi:getGlobalValue('lordMaxHour'))*3600
        local diffTime = time
		if diffTime >= lordMaxSeconds then
			diffTime = lordMaxSeconds
		end
        local label = img:getChildByTag(9999)
        local size = img:getContentSize()
        if label then
            label:removeFromParent()
        end
        label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        label:setTag(9999)
        label:setPosition(cc.p(size.width - 135,size.height/2))
        label:setAnchorPoint(cc.p(0,0.5))
        img:addChild(label)
        Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,CDTXTYPE.FRONT, nil,nil,nil,25,function ()
            local args = {}
            MessageMgr:sendPost('get','battle',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    self.owners = data.lord or {}
                    self:getOwners()
                    self:updatePanel()
                end
            end)
        end)
    end
end

function ViewPrefectureUI:updatePanel()
    local tab
    if self.checked == true then
        tab = self.tab1
        self.maxPage = math.ceil(#self.tab1/5)
    else
        tab = self.tab
        self.maxPage = math.ceil(#MapData.data/5)
    end
    if self.page > self.maxPage then
        self.page = self.maxPage
    end
    for i=1,5 do
        local owner = tab[(self.page - 1)*5 + i]
        if owner then
            local cityData = MapData.data[owner.id]
            local keyArr = string.split(cityData:getName() , '.')
            -- if cityData then
                self.imgs[i].cityNameTx:setString(keyArr[#keyArr])
            -- else
            --     self.imgs[i].cityNameTx:setString('')
            -- end
            local awardsTab = cityData:getPrefecture()
            if i == 1 and self.page == 1 then
                awardsTab = MapData:getLordDrop()
            end
            for j,v in ipairs(self.imgs[i].awards) do
                if awardsTab['award'..j] and awardsTab['award'..j][1] then
                    local award = DisplayData:getDisplayObj(awardsTab['award'..j][1])
                    ClassItemCell:updateItem(v, award, 1)
                    v.awardBgImg:setVisible(true)
                    v.lvTx:setVisible(false)
                    award:setLightEffect(v.awardBgImg)
                else
                    v.awardBgImg:setVisible(false)
                end
            end
            self.imgs[i].funcTx:setString(GlobalApi:getLocalStr('GOTO_1'))
            self.imgs[i].funcBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    MapMgr:hideUIAllPanel()
                    MapMgr:setWinPosition(owner.id,2,function()
                        MapMgr:showPrefecturePanel(owner.id)
                    end)
                end
            end)
            if owner.name then
                local uid = UserData:getUserObj():getUid()
                if owner.uid == uid then
                    self.imgs[i].ownerNameTx:setColor(COLOR_TYPE.RED)
                else
                    self.imgs[i].ownerNameTx:setColor(COLOR_TYPE.WHITE)
                end
                self.imgs[i].ownerNameTx:setString(owner.name)
                if owner.country and owner.country > 0 then
                    self.imgs[i].countryImg:setVisible(true)
                    self.imgs[i].countryImg:setPositionX(self.imgs[i].ownerNameTx:getPositionX() + self.imgs[i].ownerNameTx:getContentSize().width/2 + 20)
                    self.imgs[i].countryImg:loadTexture("uires/ui/country/country_flag_" .. owner.country .. ".png")
                else
                    self.imgs[i].countryImg:setVisible(false)
                end
                self.imgs[i].funcBtn:setVisible(true)
            else
                self.imgs[i].ownerNameTx:setString('')
                self.imgs[i].countryImg:setVisible(false)
            end
            self.imgs[i].fightforceTx:setString(owner.fight_force or '')

            if owner.time and owner.time ~= 0 then
                self:timeoutCallback(self.imgs[i].cellImg,owner.time)
            else
                local label = self.imgs[i].cellImg:getChildByTag(9999)
                if label then
                    label:removeFromParent()
                end
            end
            local star = MapData.data[MapData.currProgress]:getStar(1)
            local progress = MapData.currProgress - 1
            if star > 0 then
                progress = MapData.currProgress
            end
            self.imgs[i].funcBtn:setVisible(owner.id <= progress)
        else
            self.imgs[i].cityNameTx:setString('')
            self.imgs[i].ownerNameTx:setString('')
            self.imgs[i].countryImg:setVisible(false)
            self.imgs[i].fightforceTx:setString('')
            local label = self.imgs[i].cellImg:getChildByTag(9999)
            if label then
                label:removeFromParent()
            end
            self.imgs[i].funcBtn:setVisible(false)
            for i,v in ipairs(self.imgs[i].awards) do
                v.awardBgImg:setVisible(false)
            end
        end
    end
    -- for i,v in ipairs(self.imgs[i].awards) do
    --     v.awardBgImg:setVisible(true)
    -- end
    if self.page <= 1 then
        self.leftBtn:setTouchEnabled(false)
        self.leftBtn:setBright(false)
    else
        self.leftBtn:setTouchEnabled(true)
        self.leftBtn:setBright(true)
    end

    if self.page >= self.maxPage then
        self.rightBtn:setTouchEnabled(false)
        self.rightBtn:setBright(false)
    else
        self.rightBtn:setTouchEnabled(true)
        self.rightBtn:setBright(true)
    end
    self.pageTx:setString(self.page..'/'..self.maxPage)
    self.checkedImg:setVisible(self.checked)
end

function ViewPrefectureUI:getOwners()
    self.tab = {}
    self.tab1 = {}
    for i,v in pairs(MapData.data) do
        if i ~= 0 then
            self.tab[#self.tab + 1] = self.owners[tostring(i)] or {}
            self.tab[#self.tab].id = tonumber(i)
            if not self.tab[#self.tab].time then
                self.tab[#self.tab].time = 0
            end
        end
    end
    local star = MapData.data[MapData.currProgress]:getStar(1)
    local progress = MapData.currProgress - 1
    if star > 0 then
        progress = MapData.currProgress
    end
    for i=0,progress do
        self.tab1[#self.tab1 + 1] = self.owners[tostring(i)] or {}
        self.tab1[#self.tab1].id = tonumber(i)
        if not self.tab1[#self.tab1].time then
            self.tab1[#self.tab1].time = 0
        end
    end
end

function ViewPrefectureUI:init()
	local bgImg = self.root:getChildByName("owner_bg_img")
	local ownerImg = bgImg:getChildByName("owner_img")
    local closeBtn = ownerImg:getChildByName("close_btn")
    self:adaptUI(bgImg, ownerImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    ownerImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

    local awardBtn = ownerImg:getChildByName("award_btn")
    local awardTx = awardBtn:getChildByName("text")
    awardTx:setString(GlobalApi:getLocalStr("LORD_COUNTRY_AWARD"))
    awardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryMgr:showLordCountrySalary()
        end
    end)

    local titleImg = ownerImg:getChildByName("title_img")
    local titleTx = titleImg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr('ALL_OWNER'))
    local cityNameTx = ownerImg:getChildByName("city_name_tx")
    cityNameTx:setString(GlobalApi:getLocalStr('CITY'))
    cityNameTx:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function sortFn(a, b)
                return a.id < b.id
            end
            local function sortFn1(a, b)
                return a.id > b.id
            end
            if self.idSort == 0 or self.idSort == 2 then
                self.idSort = 1
                table.sort(self.tab,sortFn)
                table.sort(self.tab1,sortFn)
            elseif self.idSort == 1 then
                self.idSort = 2
                table.sort(self.tab,sortFn1)
                table.sort(self.tab1,sortFn1)
            end
            self.timeSort = 0
            self.forceSort = 0
            self:updatePanel()
        end
    end)
    local ownerNameTx = ownerImg:getChildByName("owner_name_tx")
    ownerNameTx:setString(GlobalApi:getLocalStr('OWNER'))
    local produceTx = ownerImg:getChildByName("produce_tx")
    produceTx:setString(GlobalApi:getLocalStr('PRODUCE'))
    local fightForceTx = ownerImg:getChildByName("fight_force_tx")
    fightForceTx:setString(GlobalApi:getLocalStr('FIGHT_FORCE'))
    fightForceTx:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function sortFn(a, b)
                local force = a.fight_force or 0
                local force1 = b.fight_force or 0
                if force == force1 then
                    return a.id < b.id
                end
                return force > force1
            end
            local function sortFn1(a, b)
                local force = a.fight_force or 0
                local force1 = b.fight_force or 0
                if force == force1 then
                    return a.id < b.id
                end
                return force < force1
            end
            if self.forceSort == 0 or self.forceSort == 2 then
                self.forceSort = 1
                table.sort(self.tab,sortFn)
                table.sort(self.tab1,sortFn)
            elseif self.forceSort == 1 then
                self.forceSort = 2
                table.sort(self.tab,sortFn1)
                table.sort(self.tab1,sortFn1)
            end
            self.timeSort = 0
            self.idSort = 0
            self:updatePanel()
        end
    end)
    local timeTx = ownerImg:getChildByName("time_tx")
    timeTx:setString(GlobalApi:getLocalStr('REMAINDER_TIME1'))
    timeTx:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function sortFn(a, b)
                if a.time == b.time then
                    return a.id < b.id
                end
                return a.time < b.time
            end
            local function sortFn1(a, b)
                if a.time == b.time then
                    return a.id < b.id
                end
                return a.time > b.time
            end
            if self.timeSort == 0 or self.timeSort == 2 then
                self.timeSort = 1
                table.sort(self.tab,sortFn)
                table.sort(self.tab1,sortFn)
            elseif self.timeSort == 1 then
                self.timeSort = 2
                table.sort(self.tab,sortFn1)
                table.sort(self.tab1,sortFn1)
            end
            self.idSort = 0
            self.forceSort = 0
            self:updatePanel()
        end
    end)

    bgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideViewPrefecturePanel()
        end
    end)
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideViewPrefecturePanel()
        end
    end)

    self.imgs = {}
    for i=1,5 do
        local cellImg = ownerImg:getChildByName('cell_'..i..'_img')
        local ownerNameTx = cellImg:getChildByName('owner_name_tx')
        local cityNameTx = cellImg:getChildByName('city_name_tx')
        local countryImg = cellImg:getChildByName('country_img')
        countryImg:ignoreContentAdaptWithSize(true)
        countryImg:setScale(0.2)
        local fightforceTx = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        fightforceTx:setAnchorPoint(cc.p(0.5, 0.5))
        fightforceTx:setPosition(cc.p(488, 28))
        fightforceTx:setScale(0.7)
        cellImg:addChild(fightforceTx)
        local funcBtn = cellImg:getChildByName('func_btn')
        local funcTx = funcBtn:getChildByName('func_tx')
        funcBtn:setSwallowTouches(true)
        local awards = {}
        local pos = {cc.p(131,30),cc.p(181,30)}
        for i=1,2 do
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            tab.awardBgImg:setPosition(pos[i])
            tab.awardBgImg:setScale(0.5)
            cellImg:addChild(tab.awardBgImg)
            awards[i] = tab
        end

        self.imgs[i] = {
            cellImg = cellImg,
            ownerNameTx = ownerNameTx,
            cityNameTx = cityNameTx,
            countryImg = countryImg,
            funcBtn = funcBtn,
            funcTx = funcTx,
            awards = awards,
            fightforceTx = fightforceTx
        }
    end
    
    self.leftBtn = ownerImg:getChildByName("left_btn")
    self.rightBtn = ownerImg:getChildByName("right_btn")
    self.pageTx = ownerImg:getChildByName("page_tx")
    self.leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.page > 0 then
                self.page = self.page - 1
            else
                return
            end
            self:updatePanel()
        end
    end)
    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.page < math.ceil(#MapData.data/5) then
                self.page = self.page + 1
            else
                return
            end
            self:updatePanel()
        end
    end)

    self.pageTx:setLocalZOrder(1)
    self.maxPage = math.ceil(#MapData.data/5)
    self.editbox = cc.EditBox:create(cc.size(164, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.pageTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editbox:setLocalZOrder(0)
    ownerImg:addChild(self.editbox)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
        local edit = pSender
        local strFmt 
        if event == "began" then
            self.editbox:setText(self.page)
            self.pageTx:setString('')
        elseif event == "ended" then
            local page = tonumber(self.editbox:getText()) or 1
            if page > self.maxPage then
                self.page = self.maxPage
            elseif page < 1 then
                self.page = 1
            else
                self.page = page
            end
            self.editbox:setText('')
            self:updatePanel()
        end
    end)

    local checkBoxBtn = ownerImg:getChildByName("chechbox_btn")
    local infoTx = checkBoxBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('CAN_SEE_CITY'))
    self.checkedImg = checkBoxBtn:getChildByName("checked_img")
    checkBoxBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.checked = self.checked ~= true
            self:updatePanel()
        end
    end)
    self:updatePanel()
end

return ViewPrefectureUI