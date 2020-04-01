local CountryMainUI = class("CountryMainUI", BaseUI)

function CountryMainUI:ctor(data)
    self.uiIndex = GAME_UI.UI_COUNTRYMAIN
    self.myPosition = data.position or 32
    self.list = data.list
    self.lordNum = data.lord
    self.cityNum = data.city
    self.conf = GameData:getConfData("position")
    self.cells = {}
end

function CountryMainUI:init()
    local country = UserData:getUserObj():getCountry()
    local winSize = cc.Director:getInstance():getWinSize()
    local bg_img = self.root:getChildByName("bg_img")
    bg_img:setPosition(cc.p(winSize.width/2, winSize.height/2))

    local back_btn = self.root:getChildByName("back_btn")
    back_btn:setPosition(cc.p(winSize.width - 50, winSize.height - 60))
    back_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryMgr:hideCountryMain()
        end
    end)

    self:initMiddle(winSize, country)
    self:initDown(winSize, country)
    self:initPlayerInfo(winSize)
    self:update()
end

function CountryMainUI:onShow()
    self:updateNewSign()
end

function CountryMainUI:initMiddle(winSize, country)
    local middle_node = self.root:getChildByName("middle_node")
    middle_node:setPosition(cc.p(winSize.width/2, winSize.height/2))

    local txt_title = middle_node:getChildByName("txt_title")
    txt_title:setString(GlobalApi:getLocalStr("COUNTRY_TITLE"))

    self.king_bg_img = middle_node:getChildByName("king_bg_img")
    local bg_light_img = self.king_bg_img:getChildByName("bg_light_img")
    bg_light_img:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, 360)))

    local king_widget = self.king_bg_img:getChildByName("king_widget")
    king_widget:addClickEventListener(function ()
        BattleMgr:showCheckInfo(self.list[1][5],'world', "country")
    end)

    local position_img = self.king_bg_img:getChildByName("position_img")
    position_img:ignoreContentAdaptWithSize(true)
    print("country is :"..country)
    position_img:loadTexture("uires/ui/country/position_" .. country .. ".png")

    self.king_name_tx = self.king_bg_img:getChildByName("king_name_tx")

    local fight_img = self.king_bg_img:getChildByName("fight_img")
    local posx, posy = fight_img:getPosition()
    self.fightForce_tx = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte("0"))
    self.fightForce_tx:setAnchorPoint(cc.p(0, 0.5))
    self.fightForce_tx:setScale(0.6)
    self.fightForce_tx:setPosition(cc.p(posx + 30, posy))
    self.king_bg_img:addChild(self.fightForce_tx)

    local award_img = self.king_bg_img:getChildByName("award_img")
    award_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryMgr:showCountryOfficeAwards()
        end
    end)

    local title_tx_1 = self.king_bg_img:getChildByName("title_tx_1")
    local title_tx_2 = self.king_bg_img:getChildByName("title_tx_2")
    title_tx_1:setString(GlobalApi:getLocalStr("NUMBER_OF_LORD"))
    title_tx_2:setString(GlobalApi:getLocalStr("NUMBER_OF_CITIES"))
    self.num_tx_1 = self.king_bg_img:getChildByName("num_tx_1")
    self.num_tx_2 = self.king_bg_img:getChildByName("num_tx_2")

    self.country_bg_img = middle_node:getChildByName("country_bg_img")
    self.country_bg_img:setVisible(false)
    local sv = self.country_bg_img:getChildByName("sv")
    local svSize = sv:getContentSize()
    sv:setScrollBarEnabled(false)
    local cellTotalHeight = #self.list*50
    for k, v in ipairs(self.list) do
        local cell = self:createCountryCell(k, v)
        sv:addChild(cell)
        cell:setPosition(cc.p(svSize.width/2, cellTotalHeight - (k-1)*50 - 25))
    end
    sv:setInnerContainerSize(cc.size(svSize.width, cellTotalHeight))

    local back_btn = self.country_bg_img:getChildByName("back_btn")
    back_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.country_bg_img:setVisible(false)
            self.king_bg_img:setVisible(true)
            self.light_img:setVisible(false)
        end
    end)

    local country_title_tx_1 = self.country_bg_img:getChildByName("title_tx_1")
    local country_title_tx_2 = self.country_bg_img:getChildByName("title_tx_2")
    local country_title_tx_3 = self.country_bg_img:getChildByName("title_tx_3")
    local country_title_tx_4 = self.country_bg_img:getChildByName("title_tx_4")
    local country_title_tx_5 = self.country_bg_img:getChildByName("title_tx_5")
    local country_title_tx_6 = self.country_bg_img:getChildByName("title_tx_6")
    country_title_tx_1:setString(GlobalApi:getLocalStr("NUMBER_OF_LORD"))
    country_title_tx_2:setString(GlobalApi:getLocalStr("NUMBER_OF_CITIES"))
    country_title_tx_3:setString(GlobalApi:getLocalStr("STR_OFFICE"))
    country_title_tx_4:setString(GlobalApi:getLocalStr("STR_NAME"))
    country_title_tx_5:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES2"))
    country_title_tx_6:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES3"))

    self.country_num_tx_1 = self.country_bg_img:getChildByName("num_tx_1")
    self.country_num_tx_2 = self.country_bg_img:getChildByName("num_tx_2")
end

function CountryMainUI:initDown(winSize, country)
    local down_img = self.root:getChildByName("down_img")
    down_img:setPosition(cc.p(winSize.width/2, 0))

    local startX = (1400 - winSize.width)/2 + 80

    self.light_img = down_img:getChildByName("light_img")
    self.light_img:ignoreContentAdaptWithSize(true)
    self.light_img:loadTexture("uires/ui/country/country_flag_" .. country .. "_" .. country .. ".png")
    self.light_img:setVisible(false)
    -- self.light_img:setPositionX(startX)
    local flag_img = down_img:getChildByName("flag_img")
    flag_img:ignoreContentAdaptWithSize(true)
    flag_img:loadTexture("uires/ui/country/country_flag_" .. country .. ".png")
    -- flag_img:setPositionX(startX)
    flag_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.light_img:setVisible(true)
            self.country_bg_img:setVisible(true)
            self.king_bg_img:setVisible(false)
        end
    end)

    local text_img = down_img:getChildByName("text_img")
    -- text_img:setPositionX(startX)

    --屏蔽势力详情
    flag_img:setVisible(false)
    text_img:setVisible(false)

    local btn_1 = down_img:getChildByName("btn_1")
    self.new_img_1 = btn_1:getChildByName("new_img")
    btn_1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:showCountryWarMain()
        end
    end)

    local btn_2 = down_img:getChildByName("btn_2")
    self.new_img_2 = btn_2:getChildByName("new_img")
    btn_2:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule("countryJade")
        end
    end)

    local btn_3 = down_img:getChildByName("btn_3")
    self.new_img_3 = btn_3:getChildByName("new_img")
    btn_3:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CityCraftMgr:showCityCraft()
        end
    end)

    local btn_4 = down_img:getChildByName("btn_4")
    btn_4:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryMgr:showCountryPillar(country, self.list)
        end
    end)
end

function CountryMainUI:initPlayerInfo(winSize)
    local player_info_node = self.root:getChildByName("player_info_node")
    player_info_node:setPosition(cc.p(0, winSize.height - 10))

    self.player_lv_tx = cc.LabelAtlas:_create("", "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
    self.player_lv_tx:setAnchorPoint(cc.p(0.5,0.5))
    self.player_lv_tx:setPosition(cc.p(23, -20))
    player_info_node:addChild(self.player_lv_tx)

    self.player_vip_img = player_info_node:getChildByName("vip_img")
    self.player_name_tx = player_info_node:getChildByName("name_tx")
    self.player_role_img = self.player_vip_img:getChildByName("role_img")

    self.player_progress = cc.ProgressTimer:create(cc.Sprite:create('uires/ui/buoy/buoy_bar.png'))
    self.player_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.player_progress:setPosition(cc.p(67,56.6))
    self.player_progress:setAnchorPoint(cc.p(0,0.5))
    self.player_progress:setMidpoint(cc.p(0,1))
    self.player_progress:setBarChangeRate(cc.p(1,0))
    self.player_vip_img:addChild(self.player_progress)

    self.player_vip_tx = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_2.png", 16, 20, string.byte('0'))
    self.player_vip_tx:setAnchorPoint(cc.p(0, 0.5))
    self.player_vip_tx:setPosition(cc.p(100,68))
    self.player_vip_img:addChild(self.player_vip_tx)

    local info_bg_img = self.root:getChildByName("middle_node"):getChildByName("info_bg_img")
    -- info_bg_img:setPosition(cc.p(0, winSize.height - 140))
    self.office_tx = info_bg_img:getChildByName("office_tx")
    self.salary_tx = info_bg_img:getChildByName("salary_tx")
    self.office_img = info_bg_img:getChildByName("office_img")
    self.office_img:ignoreContentAdaptWithSize(true)

    local mymsg_tx = info_bg_img:getChildByName("mymsg_tx")
    mymsg_tx:setString(GlobalApi:getLocalStr("COUNTRY_MY_MSG"))

    --屏蔽左上角玩家信息
    player_info_node:setVisible(false)
end

function CountryMainUI:update()
    self:updateInfo()
    self:updateMiddle()
    self:updateNewSign()
end

function CountryMainUI:updateInfo()
    if self.myPosition == 1 then
        self.office_tx:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    else
        self.office_tx:setString(self.conf[self.myPosition].title .. "(" .. self.conf[self.myPosition].posName .. ")")
    end
    self.office_tx:setTextColor(COLOR_QUALITY[self.conf[self.myPosition].quality])
    self.salary_tx:setString(self.conf[self.myPosition].salary .. "/" .. GlobalApi:getLocalStr("STR_HOUR"))
    self.office_img:loadTexture("uires/ui/jadeseal/jadeseal_" .. 10 - self.conf[self.myPosition].position .. ".png")

    self.player_name_tx:setString(UserData:getUserObj():getName())
    self.player_lv_tx:setString(UserData:getUserObj():getLv())
    self.player_progress:setPercentage(UserData:getUserObj():lvPrecent())
    
    local fightForce_tx = self.player_vip_img:getChildByName("fight_force_tx")
    if fightForce_tx then
        fightForce_tx:removeFromParent()
    end
    local myFightForce = UserData:getUserObj():getFightforce()
    if myFightForce < 1000000 then
        fightForce_tx = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_2.png", 16, 20, string.byte('0'))
    elseif myFightForce >= 1000000 and myFightForce < 10000000 then
        fightForce_tx = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_5.png", 16, 20, string.byte('0'))
    elseif myFightForce > 10000000 then
        fightForce_tx = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_5.png", 16, 20, string.byte('0'))
    end
    
    local size = self.player_vip_img:getContentSize()
    fightForce_tx:setAnchorPoint(cc.p(0,0.5))
    fightForce_tx:setPosition(cc.p(100,42))
    self.player_vip_img:addChild(fightForce_tx)
    fightForce_tx:setName("fight_force_tx")
    UserData:getUserObj():runFightforce(fightForce_tx, "CountryMainUI")
    
    self.player_role_img:loadTexture(UserData:getUserObj():getHeadpic())
    
    self.player_vip_tx:setString(UserData:getUserObj():getVip())
end

function CountryMainUI:updateMiddle()
    self.king_name_tx:setString(self.list[1][1])
    self.fightForce_tx:setString(tostring(self.list[1][3]))

    local conf = GameData:getConfData("hero")[tonumber(self.list[1][4])]
    if self.kingAni == nil then
        self.kingUrl = conf.url
        local posx, posy = 416, 90
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if self.list[1][6] and self.list[1][6][1] then
            promote = self.list[1][6][1]
        end
        if conf.camp == 5 then
            if self.list[1][7] and self.list[1][7] > 0 then
                weapon_illusion = self.list[1][7]
            end
            if self.list[1][8] and self.list[1][8] > 0 then
                wing_illusion = self.list[1][8]
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        self.kingAni = GlobalApi:createLittleLossyAniByName(conf.url .. "_display", nil, changeEquipObj)
        self.kingAni:getAnimation():play("idle", -1, -1)
        self.kingAni:setPosition(cc.p(posx, posy + conf.uiOffsetY + 20))
        self.king_bg_img:addChild(self.kingAni)
        local shadow = self.kingAni:getBone(conf.url .. "_display_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
    elseif self.kingUrl ~= conf.url then
        self.kingUrl = conf.url
        self.kingAni:removeFromParent()
        local posx, posy = 416, 90
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if self.list[1][6] and self.list[1][6][1] then
            promote = self.list[1][6][1]
        end
        if conf.camp == 5 then
            if self.list[1][7] and self.list[1][7] > 0 then
                weapon_illusion = self.list[1][7]
            end
            if self.list[1][8] and self.list[1][8] > 0 then
                wing_illusion = self.list[1][8]
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        self.kingAni = GlobalApi:createLittleLossyAniByName(conf.url .. "_display", nil, changeEquipObj)
        self.kingAni:getAnimation():play("idle", -1, -1)
        self.kingAni:setPosition(cc.p(posx, posy + conf.uiOffsetY + 20))
        self.king_bg_img:addChild(self.kingAni)
        local shadow = self.kingAni:getBone(conf.url .. "_display_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
    end
    self.num_tx_1:setString(tostring(self.lordNum))
    self.country_num_tx_1:setString(tostring(self.lordNum))
    self.num_tx_2:setString(tostring(self.cityNum))
    self.country_num_tx_2:setString(tostring(self.cityNum))
end

function CountryMainUI:createCountryCell(rank, data)
    local widget = ccui.Widget:create()
    widget:setContentSize(680, 40)

    local textColor = COLOR_TYPE.WHITE

    local position_tx = ccui.Text:create()
    position_tx:setFontName("font/gamefont.ttf")
    position_tx:setFontSize(22)
    position_tx:setString(data[1])
    position_tx:setAnchorPoint(cc.p(0, 0.5))
    position_tx:setPosition(cc.p(60, 20))
    widget:addChild(position_tx)
    if rank == 1 then
        textColor = COLOR_TYPE.YELLOW
        local kingImg = ccui.ImageView:create("uires/ui/common/maozi.png")
        kingImg:setScale(0.8)
        kingImg:setRotation(-30)
        kingImg:setPosition(cc.p(38, 30))
        widget:addChild(kingImg)
        position_tx:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    else
        if data[5] == UserData:getUserObj():getUid() then
            textColor = COLOR_TYPE.GREEN
            local isMe = ccui.ImageView:create("uires/ui/common/me.png")
            isMe:setPosition(cc.p(40, 24))
            widget:addChild(isMe)
        end
        position_tx:setString(self.conf[rank].title)
    end
    position_tx:setTextColor(textColor)

    local name_tx = ccui.Text:create()
    name_tx:setFontName("font/gamefont.ttf")
    name_tx:setFontSize(22)
    name_tx:setString(data[1])
    name_tx:setAnchorPoint(cc.p(0, 0.5))
    name_tx:setPosition(cc.p(220, 20))
    name_tx:setTextColor(textColor)
    widget:addChild(name_tx)

    local level_tx = ccui.Text:create()
    level_tx:setFontName("font/gamefont.ttf")
    level_tx:setFontSize(22)
    level_tx:setString(tostring(data[2]))
    level_tx:setAnchorPoint(cc.p(1, 0.5))
    level_tx:setPosition(cc.p(450, 20))
    level_tx:setTextColor(textColor)
    widget:addChild(level_tx)

    local fightforce_tx = ccui.Text:create()
    fightforce_tx:setFontName("font/gamefont.ttf")
    fightforce_tx:setFontSize(22)
    fightforce_tx:setString(tostring(data[3]))
    fightforce_tx:setAnchorPoint(cc.p(0, 0.5))
    fightforce_tx:setPosition(cc.p(540, 20))
    fightforce_tx:setTextColor(textColor)
    widget:addChild(fightforce_tx)

    return widget
end

function CountryMainUI:updateNewSign()
    self.new_img_1:setVisible(UserData:getUserObj():getSignByType("countrywar"))
    self.new_img_2:setVisible(UserData:getUserObj():getSignByType("countryJade"))
    self.new_img_3:setVisible(UserData:getUserObj():getSignByType("country_city"))
end

return CountryMainUI