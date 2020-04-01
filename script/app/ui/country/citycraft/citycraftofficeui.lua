local CityCraftOfficeUI = class("CityCraftOfficeUI", BaseUI)

function CityCraftOfficeUI:ctor(myPosition, index)
    self.uiIndex = GAME_UI.UI_CITYCRAFTOFFICE
    self.index = index
    self.myPosition = myPosition
    self.conf = GameData:getConfData("position")
    self.list = nil
    self.canChallenge = true
end

function CityCraftOfficeUI:init()
    local officBgImg = self.root:getChildByName("offic_bg_img")
    local officeAlphaImg = officBgImg:getChildByName("office_alpha_img")
    self:adaptUI(officBgImg, officeAlphaImg)

    local officeImg = officeAlphaImg:getChildByName("office_img")
    local closeBtn = officeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CityCraftMgr:hideCityCraftOffice()
        end
    end)

    local titleBg = officeImg:getChildByName("title_bg")
    local titleLabel = titleBg:getChildByName("title_tx")
    if self.index == 1 then
        titleLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_1" .. UserData:getUserObj():getCountry()))
    else
        titleLabel:setString(GlobalApi:getLocalStr("STR_OFFICE_" .. self.conf[self.index].position))
    end

    local infoImg = officeImg:getChildByName("info_img")
    local yuxiImg = infoImg:getChildByName("yuxi_img")
    yuxiImg:setTexture("uires/ui/jadeseal/jadeseal_" .. 10 - self.conf[self.index].position .. ".png")
    yuxiImg:setScale(1.2)

    local officeLabel = infoImg:getChildByName("office_tx")
    officeLabel:ignoreContentAdaptWithSize(false)
    officeLabel:setTextAreaSize(cc.size(20,120))
    if self.index == 1 then
        officeLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
    else
        officeLabel:setString(self.conf[self.index].title)
    end
    officeLabel:setTextColor(COLOR_QUALITY[self.conf[self.index].quality])

    local privilegeBtn = infoImg:getChildByName("privilege_btn")
    privilegeBtn:setVisible(false)
    -- local privilegeLabel = privilegeBtn:getChildByName("text")
    -- privilegeLabel:setString(GlobalApi:getLocalStr("STR_PRIVILEGE"))
    -- privilegeBtn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --     end
    -- end)

    local salaryLabel = infoImg:getChildByName("salary_tx")
    salaryLabel:setString(GlobalApi:getLocalStr("STR_OFFICE_SALARY") .. "：")

    local salaryNumLabel = infoImg:getChildByName("salary_num_tx")
    salaryNumLabel:setString(self.conf[self.index].salary .. "/" .. GlobalApi:getLocalStr("STR_HOUR"))
    
    local awardLabel = infoImg:getChildByName("award_tx")
    awardLabel:setString(GlobalApi:getLocalStr("STR_SETTLEMENT_AWARD") .. "：")

    local awards = DisplayData:getDisplayObjs(self.conf[self.index].reward)
    for i = 1, 3 do
        local awardBg = infoImg:getChildByName("award_bg_" .. i)
        if awards[i] then
            local awardIcon = awardBg:getChildByName("award_icon")
            local awardLabel = awardBg:getChildByName("award_tx")
            awardIcon:setScale(0.7)
            awardIcon:setTexture(awards[i]:getIcon())
            awardLabel:setString(tostring(awards[i]:getNum()))
        else
            awardBg:setVisible(false)
        end
    end

    local displayImg = officeImg:getChildByName("display_img")
    self.displaySize = displayImg:getContentSize()
    self.pedestals = {}
    local maxNum = self.conf[self.index].count
    for i = 1, 4 do
        local pedestalImg = displayImg:getChildByName("pedestal_img_" .. i)
        if i > maxNum then
            pedestalImg:setVisible(false)
        end
        local nameBg = pedestalImg:getChildByName("name_bg")
        nameBg:setLocalZOrder(2)
        local lvLabel = pedestalImg:getChildByName("lv_tx")
        local fightforceIcon = pedestalImg:getChildByName("fightforce_icon")
        local x, y = fightforceIcon:getPosition()
        local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
        fightforceLabel:setScale(0.7)
        fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))
        fightforceLabel:setPosition(cc.p(x, y))
        fightforceLabel:setLocalZOrder(3)
        pedestalImg:addChild(fightforceLabel)
        local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
        nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        nameLabel:setLineSpacing(-5)
        nameLabel:setAnchorPoint(cc.p(0.5, 1))
        nameLabel:setPosition(cc.p(-14, 175))
        nameLabel:setLocalZOrder(3)
        pedestalImg:addChild(nameLabel)
        self.pedestals[i] = {
            img = pedestalImg,
            name = nameLabel,
            lv = lvLabel,
            icon = fightforceIcon,
            fightforce = fightforceLabel
        }
        pedestalImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.canChallenge then
                    CityCraftMgr:showCityCraftPlayerInfo(self.conf[self.index].posName, self.list[i])
                else
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("CAN_CHALLENGE_AFTER_POSITION"), self.conf[self.index].needPosName), COLOR_TYPE.RED)
                end
            end
        end)
    end

    local posx, posy = self.pedestals[1].img:getPosition()
    if maxNum == 1 then -- 只有1个人
        self.pedestals[1].img:setPosition(cc.p(self.displaySize.width/2, posy))
    elseif maxNum == 3 then -- 有3个人
        self.pedestals[1].img:setPosition(cc.p(self.displaySize.width/4, posy))
        self.pedestals[2].img:setPosition(cc.p(self.displaySize.width/2, posy))
        self.pedestals[3].img:setPosition(cc.p(self.displaySize.width/4*3, posy))
    end

    local function getRoles()
        local obj = {
            position = self.index
        }
        MessageMgr:sendPost("get_position","country", json.encode(obj), function (response)
            
            if response.code == 0 then
                self.list = {}
                for k, v in pairs(response.data.list) do
                    local oneobj = v
                    oneobj.uid = tonumber(k)
                    table.insert(self.list, oneobj)
                end
                self:updateDisplay()
            end
        end)
    end

    local changeBtn = displayImg:getChildByName("change_btn")
    if self.conf[self.myPosition].position - self.conf[self.index].position > 1 then -- 目标官职比我大2级以上
        self.canChallenge = false
        changeBtn:setVisible(false)
        local infoLabel = displayImg:getChildByName("info_tx")
        infoLabel:setString(string.format(GlobalApi:getLocalStr("CAN_CHALLENGE_AFTER_POSITION"), self.conf[self.index].needPosName))
    else
        self.canChallenge = true
        local changeLabel = changeBtn:getChildByName("text")
        changeLabel:setString(GlobalApi:getLocalStr("STR_CHANGE_BATCH"))
        changeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                getRoles()
            end
        end)
        if maxNum < 4 then
            changeBtn:setVisible(false)
        end
    end
    getRoles()
end

function CityCraftOfficeUI:updateDisplay()
    local index = 1
    for k, v in ipairs(self.list) do
        self.pedestals[index].img:setVisible(true)
        self.pedestals[index].img:removeChildByName("hero")
        local conf = GameData:getConfData("hero")[v.model]
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if v.promote and v.promote[1] then
            promote = v.promote[1]
        end
        if conf.camp == 5 then
            if v.weapon_illusion and v.weapon_illusion > 0 then
                weapon_illusion = v.weapon_illusion
            end
            if v.wing_illusion and v.wing_illusion > 0 then
                wing_illusion = v.wing_illusion
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        local hero = GlobalApi:createLittleLossyAniByName(conf.url .. "_display", nil, changeEquipObj)
        hero:setScale(0.7)
        hero:getAnimation():play("idle", -1, -1)
        hero:setName("hero")
        hero:setPosition(cc.p(78.5, 50 + conf.uiOffsetY*0.7))
        self.pedestals[index].img:addChild(hero)
        local shadow = hero:getBone(conf.url .. "_display_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
        local flag = GlobalApi:isContainEnglish(tostring(v.un))
        if flag then
            self.pedestals[index].name:setAnchorPoint(cc.p(0, 0.5))
            self.pedestals[index].name:setRotation(90)
            self.pedestals[index].name:setMaxLineWidth(0)
        else
            self.pedestals[index].name:setAnchorPoint(cc.p(0.5, 1))
            self.pedestals[index].name:setRotation(0)
            self.pedestals[index].name:setMaxLineWidth(20)
        end
        self.pedestals[index].name:setString(v.un)
        self.pedestals[index].name:setTextColor(COLOR_QUALITY[v.quality])
        self.pedestals[index].lv:setString(tostring(v.level))
        self.pedestals[index].fightforce:setString(tostring(v.fight_force))
        local size = self.pedestals[index].fightforce:getContentSize()
        local x, y = self.pedestals[index].fightforce:getPosition()
        self.pedestals[index].icon:setPosition(cc.p(x - size.width/2, y))
        index = index + 1
    end
end

return CityCraftOfficeUI