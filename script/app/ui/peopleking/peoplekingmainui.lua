local PeopleKingMainUI = class("PeopleKingMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local MAXDELTA = 0.05
local M_IDS = {
    [1] = 300,
    [2] = 301,
}

local function getTime(t)
    local h = string.format("%02d", math.floor(t/3600))
    local m = string.format("%02d", math.floor(t%3600/60))
    local s = string.format("%02d", math.floor(t%3600%60%60))
    return h..':'..m..':'..s
end

function PeopleKingMainUI:ctor(page)
    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_MAIN
    self.page = page or 1
    self.peopleKingData = UserData:getUserObj():getPeopleKing()
    self.isSchedule = true
    self.advancedBegin = false
    self.advancedOver = true
    self.energy = 0
    self.useNum = 0
    self.timeDelta = 0
    self.advancedPage = self.page
    self.advancedIndex = 1
    self.showEnergyClearTime = false
    self.countDownTime = 0
    self.activateNewWeapon = false
    self.activateNewWing = false
    self.reminderWeapon = UserData:getUserObj():getReminder("peopleking_weapon")
    self.reminderWing = UserData:getUserObj():getReminder("peopleking_wing")

    local skyweapConf = GameData:getConfData("skyweap")
    self.weaponMaxLv = 0
    for k, v in pairs(skyweapConf) do
        if self.weaponMaxLv < k then
            self.weaponMaxLv = k
        end
    end
    local skywingConf = GameData:getConfData("skywing")
    self.wingMaxLv = 0
    for k, v in pairs(skywingConf) do
        if self.wingMaxLv < k then
            self.wingMaxLv = k
        end
    end
end

function PeopleKingMainUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bg_img = self.root:getChildByName("bg_img")
    local bg_img2 = bg_img:getChildByName("bg_img2")
    self:adaptUI(bg_img, bg_img2)

    local bg_img3 = bg_img2:getChildByName("bg_img3")

    local close_btn = bg_img3:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingMainUI()
        end
    end)

    local title_img = bg_img3:getChildByName("title_img")
    local title_tx = title_img:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_1"))

    self.weapon_btn = bg_img3:getChildByName("weapon_btn")
    self.weapon_tx = self.weapon_btn:getChildByName("weapon_tx")
    self.weapon_tx:setTextAreaSize(cc.size(30, 130))
    self.weaponNewImg = self.weapon_btn:getChildByName('new_img')
    self.weapon_tx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_3"))
    self.weapon_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:changePage(1)
        end
    end)
    self.wing_btn = bg_img3:getChildByName("wing_btn")
    self.wing_tx = self.wing_btn:getChildByName("wing_tx")
    self.wing_tx:setTextAreaSize(cc.size(30, 130))
    self.wing_tx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_4"))
    self.wingNewImg = self.wing_btn:getChildByName('new_img')
    self.wing_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:changePage(2)
        end
    end)

    self.btnNewImgs = {self.weaponNewImg,self.wingNewImg}
    self:initLeft(bg_img3)
    self:initRight(bg_img3)
    self:changePage(self.page)

    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self:scheduleUpdate(dt)
    end, 0)
end

function PeopleKingMainUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.PEOPLE_KING)
end

function PeopleKingMainUI:onShow()
    self:update()
end

function PeopleKingMainUI:onHide()
    self.isSchedule = false
    self.root:unscheduleUpdate()
    self.root:unregisterScriptHandler()
end

function PeopleKingMainUI:onCover()
    if self.advancedBegin then
        self:update()
    end
    self.advanced_bar_ani:setVisible(false)
    self.advancedBegin = false
end

function PeopleKingMainUI:changePage(page)
    local openName
    if page == 1 then
        openName = "weapon"
    elseif page == 2 then
        openName = "wing"
    end
    local isOpen,isNotIn, id, level = GlobalApi:getOpenInfo(openName)
    if not isOpen and not isNotIn then
        local str
        if level then
            str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
        elseif cityData then
            str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
        else
            str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
        end
        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
        return
    end
    self.advanced_bar_ani:setVisible(false)
    self.advancedBegin = false
    if page == 1 then
        self.weapon_btn:setTouchEnabled(false)
        self.wing_btn:setTouchEnabled(true)
        self.weapon_btn:setBrightStyle(ccui.BrightStyle.highlight)
        self.wing_btn:setBrightStyle(ccui.BrightStyle.normal)
        self.weapon_tx:setTextColor(COLOR_TYPE.PALE)
        self.wing_tx:setTextColor(COLOR_TYPE.DARK)
    elseif page == 2 then
        self.weapon_btn:setTouchEnabled(true)
        self.wing_btn:setTouchEnabled(false)
        self.weapon_btn:setBrightStyle(ccui.BrightStyle.normal)
        self.wing_btn:setBrightStyle(ccui.BrightStyle.highlight)
        self.weapon_tx:setTextColor(COLOR_TYPE.DARK)
        self.wing_tx:setTextColor(COLOR_TYPE.PALE)
    end
    self.page = page
    self:update()
end

function PeopleKingMainUI:update()
    self:updateLeft()
    self:updateRight()
	for i=1,2 do
		self.btnNewImgs[i]:setVisible(UserData:getUserObj():getPeopleKingBtn(i))
	end
end

function PeopleKingMainUI:initLeft(bg_img3)
    local left_img = bg_img3:getChildByName("left_img")
    local help_btn = left_img:getChildByName("help_btn")
    help_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(HELP_SHOW_TYPE.PEOPLEKING)
        end
    end)

    self.advanced_lv_tx = left_img:getChildByName("advanced_lv_tx")
    self.advanced_name_tx = left_img:getChildByName("advanced_name_tx")

    local awake_btn = left_img:getChildByName("awake_btn")
    self.awake_new = awake_btn:getChildByName("new_img")
    local awake_tx = awake_btn:getChildByName("awake_tx")
    awake_tx:setString(GlobalApi:getLocalStr("STR_AWAKE"))
    awake_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:showPeopleKingAwakeWeaponUI(self.page)
        end
    end)

    local change_btn = left_img:getChildByName("change_btn")
    self.mark = change_btn:getChildByName("new_img")
    local change_tx = change_btn:getChildByName("change_tx")
    change_tx:setString(GlobalApi:getLocalStr("STR_CHANGE_LOOK"))
    change_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function updateAfterEquip()
                self:update()
            end
            PeopleKingMgr:showPeopleKingChangeLookUI(self.page,updateAfterEquip)
        end
    end)

    local suit_btn = left_img:getChildByName("suit_btn")
    self.advanced_tx = suit_btn:getChildByName("advanced_tx")
    suit_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:showPeopleKingSuitBuffUI()
        end
    end)
    
    local roleObj = RoleData:getMainRole()
    self.mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState())
    self.mainRoleAni:getAnimation():play("idle", -1, 1)
    self.mainRoleAni:setPosition(cc.p(220, 160))

    left_img:addChild(self.mainRoleAni)

    self.skillCell = {}
    for i = 1, 4 do
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.OTHER)
        cell.awardBgImg:setName('award_bg_img_'..i)
        self.skillCell[i] = cell
        cell.awardBgImg:setPosition(cc.p(61 + 106*(i-1), 56))
        local clockImg = ccui.ImageView:create("uires/ui/common/lock_3.png")
        local size = cell.awardBgImg:getContentSize()
        clockImg:setPosition(cc.p(size.width/2,size.height/2))
        cell.awardBgImg:addChild(clockImg)
        cell.clockImg = clockImg

        local arrowImg = ccui.ImageView:create("uires/ui/common/arrow_up2.png")
        arrowImg:setPosition(cc.p(size.width-15,size.height-20))
        cell.awardBgImg:addChild(arrowImg)
        cell.arrowImg = arrowImg
        left_img:addChild(cell.awardBgImg)

        local function updateAfterSkillUp()
            self:update()
        end

        cell.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then

                PeopleKingMgr:showPeopleKingSkillUpUI(self.page,updateAfterSkillUp)
            end
        end)
    end
end

function PeopleKingMainUI:initRight(bg_img3)
    local right_img = bg_img3:getChildByName("right_img")
    self.right_width = right_img:getContentSize().width
    local right_title_tx_1 = right_img:getChildByName("right_title_tx_1")
    right_title_tx_1:setString(GlobalApi:getLocalStr("FIGHT_FORCE"))

    self.atk_img = right_img:getChildByName("atk_img")
    self.fightforce_tx = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte("0"))
    self.fightforce_tx:setScale(0.72)
    self.fightforce_tx:setAnchorPoint(cc.p(0, 0.5))
    self.fightforce_tx:setPositionY(self.atk_img:getPositionY())
    right_img:addChild(self.fightforce_tx)

    local right_title_tx_2 = right_img:getChildByName("right_title_tx_2")
    right_title_tx_2:setString(GlobalApi:getLocalStr("ALL_ADD_ATTRIBUTE"))

    self.right_title_tx_3 = right_img:getChildByName("right_title_tx_3")

    local attrConf = GameData:getConfData("attribute")
    self.attr_node_1 = right_img:getChildByName("attr_node_1")
    for i = 1, 4 do
        local attr_name = self.attr_node_1:getChildByName("attr_name_" .. i)
        attr_name:setString(attrConf[i].name)
    end
    self.attr_node_2 = right_img:getChildByName("attr_node_2")
    for i = 1, 4 do
        local attr_name = self.attr_node_2:getChildByName("attr_name_" .. i)
        attr_name:setString(attrConf[i].name)
    end
    self.attr_img = right_img:getChildByName("attr_img")
    self.advanced_max_img = right_img:getChildByName("advanced_max_img")
    self.advanced_node = right_img:getChildByName("advanced_node")
    local advanced_bar_bg = self.advanced_node:getChildByName("advanced_bar_bg")
    self.advanced_bar_width = advanced_bar_bg:getContentSize().width
    self.advanced_bar = advanced_bar_bg:getChildByName("advanced_bar")
    self.advanced_bar:setScale9Enabled(true)
    self.advanced_bar:setCapInsets(cc.rect(14,14,4,4))
    self.advanced_bar_tx = advanced_bar_bg:getChildByName("advanced_bar_tx")
    self.advanced_bar_tx:setLocalZOrder(3)
    self.advanced_bar_ani = GlobalApi:createLittleLossyAniByName("tianming_soul_00")
    self.advanced_bar_ani:setVisible(false)
    self.advanced_bar_ani:setScale(2, 2.4)
    self.advanced_bar_ani:getAnimation():playWithIndex(0, -1, 1)
    self.advanced_bar_ani:setPosition(cc.p(0, advanced_bar_bg:getContentSize().height/2))
    advanced_bar_bg:addChild(self.advanced_bar_ani)
    self.advanced_desc_1 = self.advanced_node:getChildByName("advanced_desc_1")
    self.advanced_desc_1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_12"))
    self.advanced_count_down = self.advanced_node:getChildByName("advanced_count_down")
    self.advanced_desc_2 = self.advanced_node:getChildByName("advanced_desc_2")
    self.advanced_desc_3 = self.advanced_node:getChildByName("advanced_desc_3")
    self.advanced_desc_3:setString("，" .. GlobalApi:getLocalStr("PEOPLE_KING_DESC_13"))
    self.advanced_desc_3_width = self.advanced_desc_3:getContentSize().width
    self.advanced_item_node_1 = self.advanced_node:getChildByName("advanced_item_node_1")
    self.newImg1 = self.advanced_item_node_1:getChildByName('new_img')
    self.newImg1:setLocalZOrder(2)
    self.advanced_item_node_2 = self.advanced_node:getChildByName("advanced_item_node_2")
    self.newImg2 = self.advanced_item_node_2:getChildByName('new_img')
    self.newImg2:setLocalZOrder(2)
    self.itemCell1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    self.itemCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    self.advanced_item_node_1:addChild(self.itemCell1.awardBgImg)
    self.advanced_item_node_2:addChild(self.itemCell2.awardBgImg)
    self.itemCell1.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:touchAdvancedItemBegan(1)
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self:touchAdvancedItemOver(1)
        end
    end)
    self.itemCell2.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:touchAdvancedItemBegan(2)
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            self:touchAdvancedItemOver(2)
        end
    end)
end

function PeopleKingMainUI:updateLeft()
    local skyskillConf = GameData:getConfData("skyskill")
    if self.page == 1 then
        local skyweapConf = GameData:getConfData("skyweap")[self.peopleKingData.weapon_level]
        if self.peopleKingData.weapon_level == 0 then
            self.advanced_lv_tx:setVisible(false)
            self.advanced_name_tx:setAnchorPoint(cc.p(0.5, 0.5))
            self.advanced_name_tx:setPosition(cc.p(220, 446))
        else
            self.advanced_lv_tx:setVisible(true)
            self.advanced_lv_tx:setString(GlobalApi:getLocalStr("SOLDIER" .. self.peopleKingData.weapon_level))
            self.advanced_name_tx:setAnchorPoint(cc.p(0, 0.5))
            self.advanced_name_tx:setPosition(cc.p(186, 446))
        end
        self.advanced_name_tx:setString(skyweapConf.name)
    elseif self.page == 2 then
        local skywingConf = GameData:getConfData("skywing")[self.peopleKingData.wing_level]
        if self.peopleKingData.wing_level == 0 then
            self.advanced_lv_tx:setVisible(false)
            self.advanced_name_tx:setAnchorPoint(cc.p(0.5, 0.5))
            self.advanced_name_tx:setPosition(cc.p(220, 446))
        else
            self.advanced_lv_tx:setVisible(true)
            self.advanced_lv_tx:setString(GlobalApi:getLocalStr("SOLDIER" .. self.peopleKingData.wing_level))
            self.advanced_name_tx:setAnchorPoint(cc.p(0, 0.5))
            self.advanced_name_tx:setPosition(cc.p(186, 446))
        end
        self.advanced_name_tx:setString(skywingConf.name)
    end

    local suitLv = self.peopleKingData.weapon_level
    if suitLv > self.peopleKingData.wing_level then
        suitLv = self.peopleKingData.wing_level
    end
    self.advanced_tx:setString("LV." .. suitLv)

    local roleObj = RoleData:getMainRole()
    GlobalApi:changeModelEquip(self.mainRoleAni, roleObj:getUrl() .. "_display", roleObj:getChangeEquipState(), 2)

    local skills = self.page == 1 and self.peopleKingData.weapon_skills or self.peopleKingData.wing_skills
    for i = 1, 4 do
        if skyskillConf[self.page][i] then
            self.skillCell[i].awardBgImg:loadTexture(COLOR_FRAME[5])
            self.skillCell[i].awardImg:loadTexture("uires/icon/skill/" .. skyskillConf[self.page][i].icon)
            local skillLv = skills[tostring(i)]
            if skillLv then
                if skillLv > 0 then
                    self.skillCell[i].lvTx:setVisible(true)
                    self.skillCell[i].lvTx:setString("Lv." .. skillLv)
                    ShaderMgr:restoreWidgetDefaultShader(self.skillCell[i].awardBgImg)
                    ShaderMgr:restoreWidgetDefaultShader(self.skillCell[i].awardImg)
                    self.skillCell[i].clockImg:setVisible(false)

                    --检测技能是否可升级
                    local couldUp = self:skillCouldUp(i,skillLv)
                    self.skillCell[i].arrowImg:setVisible(couldUp)
                else
                    self.skillCell[i].lvTx:setVisible(false)
                    ShaderMgr:setGrayForWidget(self.skillCell[i].awardBgImg)
                    ShaderMgr:setGrayForWidget(self.skillCell[i].awardImg)
                    self.skillCell[i].clockImg:setVisible(true)
                    self.skillCell[i].arrowImg:setVisible(false)
                end
            end
        end
    end
    self.mark:setVisible(UserData:getUserObj():getPeopleKingReddot(self.page))
    -- self.awake_new:setVisible(self:checkStone())
	self.awake_new:setVisible(UserData:getUserObj():getPeopleKingAwake(self.page))
	self.newImg1:setVisible(UserData:getUserObj():getPeopleKingAward1(self.page))
	self.newImg2:setVisible(UserData:getUserObj():getPeopleKingAward2(self.page))
end

function PeopleKingMainUI:updateRight()
    local skybloodawakenConf = GameData:getConfData("skybloodawaken")
    local skygasawakenConf = GameData:getConfData("skygasawaken")
    local skychangeConf = GameData:getConfData("skychange")
    local skyskillConf = GameData:getConfData("skyskill")
    local skyskillupConf = GameData:getConfData("skyskillup")
    local attributeConf = GameData:getConfData("attribute")
    local skillAttrs = {}
    local fightForce = 0
    if self.page == 1 then
        if self.peopleKingData.weapon_level <= 0 then
            self.right_title_tx_3:setString(GlobalApi:getLocalStr("PEOPLE_KING_ACTIVATE_WEAPON"))
        else
            self.right_title_tx_3:setString(GlobalApi:getLocalStr("PEOPLE_KING_ADVANCE_WEAPON"))
        end
        local skyweapConf = GameData:getConfData("skyweap")[self.peopleKingData.weapon_level]
        local attr = RoleData:getPeopleKingWeaponAttr()
        local attr_atk_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.ATK)
        local attr_atk_num = attr[ATTRIBUTE_INDEX.ATK] or 0
        attr_atk_tx:setString(tostring(attr_atk_num))

        local attr_hp_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.HP)
        local attr_hp_num = attr[ATTRIBUTE_INDEX.HP] or 0
        attr_hp_tx:setString(tostring(attr_hp_num))

        local attr_def_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.PHYDEF)
        local attr_def_num = attr[ATTRIBUTE_INDEX.PHYDEF] or 0
        attr_def_tx:setString(tostring(attr_def_num))

        local attr_mdef_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.MAGDEF)
        local attr_mdef_num = attr[ATTRIBUTE_INDEX.MAGDEF] or 0
        attr_mdef_tx:setString(tostring(attr_mdef_num))

        local fightForce = attr_atk_num*attributeConf[ATTRIBUTE_INDEX.ATK].factor + 
                           attr_hp_num*attributeConf[ATTRIBUTE_INDEX.HP].factor +
                           attr_def_num*attributeConf[ATTRIBUTE_INDEX.PHYDEF].factor +
                           attr_mdef_num*attributeConf[ATTRIBUTE_INDEX.MAGDEF].factor

        -- 下一阶属性加成
        if self.peopleKingData.weapon_level < self.weaponMaxLv then
            self.attr_node_1:setPosition(cc.p(87, 300))
            self.attr_img:setVisible(true)
            self.attr_node_2:setVisible(true)
            local attr2 = RoleData:getPeopleKingNextWeaponAttr()
            local attr_atk_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.ATK)
            local up_img_1 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.ATK)
            local attr_atk_num2 = attr2[ATTRIBUTE_INDEX.ATK] or 0
            attr_atk_tx2:setString(tostring(attr_atk_num2))
            if attr_atk_num2 <= attr_atk_num then
                attr_atk_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_1:setVisible(false)
            else
                up_img_1:setVisible(true)
                attr_atk_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_1:setPositionX(attr_atk_tx2:getPositionX() + attr_atk_tx2:getContentSize().width + 15)
            end

            local attr_hp_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.HP)
            local up_img_2 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.HP)
            local attr_hp_num2 = attr2[ATTRIBUTE_INDEX.HP] or 0
            attr_hp_tx2:setString(tostring(attr_hp_num2))
            if attr_hp_num2 <= attr_hp_num then
                attr_hp_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_2:setVisible(false)
            else
                up_img_2:setVisible(true)
                attr_hp_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_2:setPositionX(attr_hp_tx2:getPositionX() + attr_hp_tx2:getContentSize().width + 15)
            end

            local attr_def_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.PHYDEF)
            local up_img_3 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.PHYDEF)
            local attr_def_num2 = attr2[ATTRIBUTE_INDEX.PHYDEF] or 0
            attr_def_tx2:setString(tostring(attr_def_num2))
            if attr_def_num2 <= attr_def_num then
                attr_def_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_3:setVisible(false)
            else
                up_img_3:setVisible(true)
                attr_def_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_3:setPositionX(attr_def_tx2:getPositionX() + attr_def_tx2:getContentSize().width + 15)
            end

            local attr_mdef_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.MAGDEF)
            local up_img_4 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.MAGDEF)
            local attr_mdef_num2 = attr2[ATTRIBUTE_INDEX.MAGDEF] or 0
            attr_mdef_tx2:setString(tostring(attr_mdef_num2))
            if attr_mdef_num2 <= attr_mdef_num then
                attr_mdef_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_4:setVisible(false)
            else
                up_img_4:setVisible(true)
                attr_mdef_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_4:setPositionX(attr_mdef_tx2:getPositionX() + attr_mdef_tx2:getContentSize().width + 15)
            end
        else -- 满阶了
            self.attr_node_1:setPosition(cc.p(187, 300))
            self.attr_img:setVisible(false)
            self.attr_node_2:setVisible(false)
        end
        local roleMap = RoleData:getRoleMap()
        local roleCount = 0
        for k,v in pairs(roleMap) do
            if v and v:getId() > 0 then
                roleCount = roleCount + 1
            end
        end
        fightForce = math.floor(fightForce)*roleCount
        self.fightforce_tx:setString(tostring(fightForce))
        local posX = self.right_width/2 - (self.fightforce_tx:getContentSize().width*self.fightforce_tx:getScale() - 40)/2
        self.fightforce_tx:setPositionX(posX)
        self.atk_img:setPositionX(posX - 20)
        -- 进阶相关
        if self.peopleKingData.weapon_level ~= self.weaponMaxLv then
            if self.peopleKingData.weapon_energy_clean_time > 0 then
                self.showEnergyClearTime = true
                self.advanced_count_down:setVisible(true)
                self.advanced_desc_1:setAnchorPoint(cc.p(1, 0.5))
                self.advanced_desc_1:setPositionX(self.right_width/2 - 3)
                self.advanced_desc_1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_12"))
            else
                self.showEnergyClearTime = false
                self.advanced_count_down:setVisible(false)
                self.advanced_desc_1:setAnchorPoint(cc.p(0.5, 0.5))
                self.advanced_desc_1:setPositionX(self.right_width/2)
                self.advanced_desc_1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_16"))
            end
            local award1 = DisplayData:getDisplayObj(skyweapConf.cost1[1])
            ClassItemCell:updateItem(self.itemCell1, award1, 1)
            local materialobj1 = BagData:getBagobjByObj(award1)
            if materialobj1 then
                if materialobj1:getOwnNum() > 0 then
                    self.itemCell1.lvTx:setTextColor(COLOR_TYPE.WHITE)
                else
                    self.itemCell1.lvTx:setTextColor(COLOR_TYPE.RED)
                end
                self.itemCell1.lvTx:setString("x" .. materialobj1:getOwnNum())
            else
                self.itemCell1.lvTx:setTextColor(COLOR_TYPE.RED)
                self.itemCell1.lvTx:setString("x0")
            end
            if skyweapConf.cost2[1] then
                local award2 = DisplayData:getDisplayObj(skyweapConf.cost2[1])
                ClassItemCell:updateItem(self.itemCell2, award2, 1)
                local materialobj2 = BagData:getBagobjByObj(award2)
                if materialobj2 then
                    if materialobj2:getOwnNum() > 0 then
                        self.itemCell2.lvTx:setTextColor(COLOR_TYPE.WHITE)
                    else
                        self.itemCell2.lvTx:setTextColor(COLOR_TYPE.RED)
                    end
                    self.itemCell2.lvTx:setString("x" .. materialobj2:getOwnNum())
                else
                    self.itemCell2.lvTx:setTextColor(COLOR_TYPE.RED)
                    self.itemCell2.lvTx:setString("x0")
                end
                self.advanced_item_node_1:setPositionX(self.right_width/2 - 70)
                self.advanced_item_node_2:setPositionX(self.right_width/2 + 70)
                self.advanced_item_node_2:setVisible(true)
            else
                self.advanced_item_node_1:setPositionX(self.right_width/2)
                self.advanced_item_node_2:setVisible(false)
            end
            self:updateBar(self.peopleKingData.weapon_energy, skyweapConf.maxEnergy)
            self.advanced_desc_2:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_14"), award1:getNum(), skyweapConf.getEnergy))
            local advanced_desc_2_width = self.advanced_desc_2:getContentSize().width
            local advanced_desc_posx = self.right_width/2 - (self.advanced_desc_3_width - advanced_desc_2_width)/2
            self.advanced_desc_2:setPositionX(advanced_desc_posx)
            self.advanced_desc_3:setPositionX(advanced_desc_posx)
            self.advanced_max_img:setVisible(false)
            self.advanced_node:setVisible(true)
        else
            self.advanced_max_img:setVisible(true)
            self.advanced_node:setVisible(false)
        end
    elseif self.page == 2 then
        if self.peopleKingData.wing_level <= 0 then
            self.right_title_tx_3:setString(GlobalApi:getLocalStr("PEOPLE_KING_ACTIVATE_WING"))
        else
            self.right_title_tx_3:setString(GlobalApi:getLocalStr("PEOPLE_KING_ADVANCE_WING"))
        end
        local skywingConf = GameData:getConfData("skywing")[self.peopleKingData.wing_level]
        local attr = RoleData:getPeopleKingWingAttr()
        local attr_atk_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.ATK)
        local attr_atk_num = attr[ATTRIBUTE_INDEX.ATK] or 0
        attr_atk_tx:setString(tostring(attr_atk_num))

        local attr_hp_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.HP)
        local attr_hp_num = attr[ATTRIBUTE_INDEX.HP] or 0
        attr_hp_tx:setString(tostring(attr_hp_num))

        local attr_def_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.PHYDEF)
        local attr_def_num = attr[ATTRIBUTE_INDEX.PHYDEF] or 0
        attr_def_tx:setString(tostring(attr_def_num))

        local attr_mdef_tx = self.attr_node_1:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.MAGDEF)
        local attr_mdef_num = attr[ATTRIBUTE_INDEX.MAGDEF] or 0
        attr_mdef_tx:setString(tostring(attr_mdef_num))

        local fightForce = attr_atk_num*attributeConf[ATTRIBUTE_INDEX.ATK].factor + 
                           attr_hp_num*attributeConf[ATTRIBUTE_INDEX.HP].factor +
                           attr_def_num*attributeConf[ATTRIBUTE_INDEX.PHYDEF].factor +
                           attr_mdef_num*attributeConf[ATTRIBUTE_INDEX.MAGDEF].factor
        -- 下一阶属性加成
        if self.peopleKingData.wing_level < self.wingMaxLv then
            self.attr_node_1:setPosition(cc.p(87, 300))
            self.attr_img:setVisible(true)
            self.attr_node_2:setVisible(true)
            
            local attr2 = RoleData:getPeopleKingNextWingAttr()
            local attr_atk_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.ATK)
            local up_img_1 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.ATK)
            local attr_atk_num2 = attr2[ATTRIBUTE_INDEX.ATK] or 0
            attr_atk_tx2:setString(tostring(attr_atk_num2))
            if attr_atk_num2 <= attr_atk_num then
                attr_atk_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_1:setVisible(false)
            else
                up_img_1:setVisible(true)
                attr_atk_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_1:setPositionX(attr_atk_tx2:getPositionX() + attr_atk_tx2:getContentSize().width + 15)
            end

            local attr_hp_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.HP)
            local up_img_2 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.HP)
            local attr_hp_num2 = attr2[ATTRIBUTE_INDEX.HP] or 0
            attr_hp_tx2:setString(tostring(attr_hp_num2))
            if attr_hp_num2 <= attr_hp_num then
                attr_hp_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_2:setVisible(false)
            else
                up_img_2:setVisible(true)
                attr_hp_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_2:setPositionX(attr_hp_tx2:getPositionX() + attr_hp_tx2:getContentSize().width + 15)
            end

            local attr_def_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.PHYDEF)
            local up_img_3 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.PHYDEF)
            local attr_def_num2 = attr2[ATTRIBUTE_INDEX.PHYDEF] or 0
            attr_def_tx2:setString(tostring(attr_def_num2))
            if attr_def_num2 <= attr_def_num then
                attr_def_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_3:setVisible(false)
            else
                up_img_3:setVisible(true)
                attr_def_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_3:setPositionX(attr_def_tx2:getPositionX() + attr_def_tx2:getContentSize().width + 15)
            end

            local attr_mdef_tx2 = self.attr_node_2:getChildByName("attr_num_" .. ATTRIBUTE_INDEX.MAGDEF)
            local up_img_4 = self.attr_node_2:getChildByName("up_img_" .. ATTRIBUTE_INDEX.MAGDEF)
            local attr_mdef_num2 = attr2[ATTRIBUTE_INDEX.MAGDEF] or 0
            attr_mdef_tx2:setString(tostring(attr_mdef_num2))
            if attr_mdef_num2 <= attr_mdef_num then
                attr_mdef_tx2:setTextColor(COLOR_TYPE.WHITE)
                up_img_4:setVisible(false)
            else
                up_img_4:setVisible(true)
                attr_mdef_tx2:setTextColor(COLOR_TYPE.GREEN)
                up_img_4:setPositionX(attr_mdef_tx2:getPositionX() + attr_mdef_tx2:getContentSize().width + 15)
            end
        else -- 满阶了
            self.attr_node_1:setPosition(cc.p(187, 300))
            self.attr_img:setVisible(false)
            self.attr_node_2:setVisible(false)
        end
        local roleMap = RoleData:getRoleMap()
        local roleCount = 0
        for k,v in pairs(roleMap) do
            if v and v:getId() > 0 then
                roleCount = roleCount + 1
            end
        end
        fightForce = math.floor(fightForce)*roleCount
        self.fightforce_tx:setString(tostring(fightForce))
        local posX = self.right_width/2 - (self.fightforce_tx:getContentSize().width*self.fightforce_tx:getScale() - 40)/2
        self.fightforce_tx:setPositionX(posX)
        self.atk_img:setPositionX(posX - 20)
        -- 进阶相关
        if self.peopleKingData.wing_level ~= self.wingMaxLv then
            if self.peopleKingData.wing_energy_clean_time > 0 then
                self.showEnergyClearTime = true
                self.advanced_count_down:setVisible(true)
                self.advanced_desc_1:setAnchorPoint(cc.p(1, 0.5))
                self.advanced_desc_1:setPositionX(self.right_width/2 - 3)
                self.advanced_desc_1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_12"))
            else
                self.showEnergyClearTime = false
                self.advanced_count_down:setVisible(false)
                self.advanced_desc_1:setAnchorPoint(cc.p(0.5, 0.5))
                self.advanced_desc_1:setPositionX(self.right_width/2)
                self.advanced_desc_1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_16"))
            end
            local award1 = DisplayData:getDisplayObj(skywingConf.cost1[1])
            ClassItemCell:updateItem(self.itemCell1, award1, 1)
            local materialobj1 = BagData:getBagobjByObj(award1)
            if materialobj1 then
                if materialobj1:getOwnNum() > 0 then
                    self.itemCell1.lvTx:setTextColor(COLOR_TYPE.WHITE)
                else
                    self.itemCell1.lvTx:setTextColor(COLOR_TYPE.RED)
                end
                self.itemCell1.lvTx:setString("x" .. materialobj1:getOwnNum())
            else
                self.itemCell1.lvTx:setTextColor(COLOR_TYPE.RED)
                self.itemCell1.lvTx:setString("x0")
            end
            if skywingConf.cost2[1] then
                local award2 = DisplayData:getDisplayObj(skywingConf.cost2[1])
                ClassItemCell:updateItem(self.itemCell2, award2, 1)
                local materialobj2 = BagData:getBagobjByObj(award2)
                if materialobj2 then
                    if materialobj2:getOwnNum() > 0 then
                        self.itemCell2.lvTx:setTextColor(COLOR_TYPE.WHITE)
                    else
                        self.itemCell2.lvTx:setTextColor(COLOR_TYPE.RED)
                    end
                    self.itemCell2.lvTx:setString("x" .. materialobj2:getOwnNum())
                else
                    self.itemCell2.lvTx:setTextColor(COLOR_TYPE.RED)
                    self.itemCell2.lvTx:setString("x0")
                end
                self.advanced_item_node_1:setPositionX(self.right_width/2 - 70)
                self.advanced_item_node_2:setPositionX(self.right_width/2 + 70)
                self.advanced_item_node_2:setVisible(true)
            else
                self.advanced_item_node_1:setPositionX(self.right_width/2)
                self.advanced_item_node_2:setVisible(false)
            end
            self:updateBar(self.peopleKingData.wing_energy, skywingConf.maxEnergy)
            self.advanced_desc_2:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_14"), award1:getNum(), skywingConf.getEnergy))
            local advanced_desc_2_width = self.advanced_desc_2:getContentSize().width
            local advanced_desc_posx = self.right_width/2 - (self.advanced_desc_3_width - advanced_desc_2_width)/2
            self.advanced_desc_2:setPositionX(advanced_desc_posx)
            self.advanced_desc_3:setPositionX(advanced_desc_posx)
            self.advanced_max_img:setVisible(false)
            self.advanced_node:setVisible(true)
        else
            self.advanced_max_img:setVisible(true)
            self.advanced_node:setVisible(false)
        end
    end
end

function PeopleKingMainUI:touchAdvancedItemBegan(index)
    if self.advancedBegin then
        return
    end
    self.advancedPage = self.page
    self.advancedBegin = true
    local conf
    if self.advancedPage == 1 then
        conf = GameData:getConfData("skyweap")[self.peopleKingData.weapon_level]
    elseif self.advancedPage == 2 then
        conf = GameData:getConfData("skywing")[self.peopleKingData.wing_level]
    end
    local award = DisplayData:getDisplayObj(conf["cost" .. index][1])
    local materialobj = BagData:getBagobjByObj(award)
    if materialobj == nil then
        self.advancedBegin = false
        promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
        GetWayMgr:showGetwayUI(award, true)
        return
    else
        local costnum = award:getNum()
        local havenum = materialobj:getOwnNum()
        if costnum > havenum then
            self.advancedBegin = false
            promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
            GetWayMgr:showGetwayUI(award, true)
        else
            if self.advancedPage == 1 and not self.reminderWeapon then
                if materialobj:getCategory() ~= "limitmat" and conf["cost" .. 3-index][1] then
                    local otherAward = DisplayData:getDisplayObj(conf["cost" .. 3-index][1])
                    local otherMaterialobj = BagData:getBagobjByObj(otherAward)
                    if otherMaterialobj and otherAward:getNum() <= otherMaterialobj:getOwnNum() then
                        self.advancedBegin = false
                        UserData:getUserObj():markReminder("peopleking_weapon")
                        self.reminderWeapon = true
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("PEOPLE_KING_DESC_18"), MESSAGE_BOX_TYPE.MB_OK)
                        return
                    end
                end
            elseif self.advancedPage == 2 and not self.reminderWing then
                if materialobj:getCategory() ~= "limitmat" and conf["cost" .. 3-index][1] then
                    local otherAward = DisplayData:getDisplayObj(conf["cost" .. 3-index][1])
                    local otherMaterialobj = BagData:getBagobjByObj(otherAward)
                    if otherMaterialobj and otherAward:getNum() <= otherMaterialobj:getOwnNum() then
                        self.advancedBegin = false
                        UserData:getUserObj():markReminder("peopleking_wing")
                        self.reminderWing = true
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("PEOPLE_KING_DESC_18"), MESSAGE_BOX_TYPE.MB_OK)
                        return
                    end
                end
            end
            self.advancedIndex = index
            self.timeDelta = 0
            if self.advancedPage == 1 then
                self.energy = self.peopleKingData.weapon_energy
            elseif self.advancedPage == 2 then
                self.energy = self.peopleKingData.wing_energy
            end
        end
    end
end

function PeopleKingMainUI:touchAdvancedItemOver(index)
    if not self.advancedBegin then
        return
    end
    if index ~= self.advancedIndex then
        return
    end
    if self.useNum > 0 then
        self:lvUpPost()
    end
    self.advanced_bar_ani:setVisible(false)
    self.advancedBegin = false
end

function PeopleKingMainUI:lvUpPost()
    self.advanced_bar_ani:setVisible(false)
    self.advancedBegin = false
    local act = ""
    local advancedPage = self.advancedPage
    if advancedPage == 1 then
        act = "upgrade_sky_weapon"
    elseif advancedPage == 2 then
        act = "upgrade_sky_wing"
    end
    local args = {
        num = self.useNum,
        type = self.advancedIndex
    }
    MessageMgr:sendPost(act, "hero", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            GlobalApi:parseAwardData(jsonObj.data.awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            if advancedPage == 1 then
                if self.peopleKingData.weapon_level < jsonObj.data.weapon_level then
                    local currAttr = RoleData:getPeopleKingWeaponAttr()
                    local nextAttr = RoleData:getPeopleKingNextWeaponAttr()
                    local showCurrAttr = {}
                    local showNextAttr = {}
                    showCurrAttr[1] = currAttr[1] or 0
                    showCurrAttr[2] = currAttr[4] or 0
                    showCurrAttr[3] = currAttr[2] or 0
                    showCurrAttr[4] = currAttr[3] or 0
                    showNextAttr[1] = nextAttr[1] or 0
                    showNextAttr[2] = nextAttr[4] or 0
                    showNextAttr[3] = nextAttr[2] or 0
                    showNextAttr[4] = nextAttr[3] or 0
                    local oldfightforce = RoleData:getFightForce()
                    self:updateWeaponData(jsonObj.data, true)
                    RoleMgr:showStengthenPopupUI(RoleData:getMainRole(), 'upgrade_peopleking_weapon', showCurrAttr, showNextAttr, function ()
                        RoleData:setAllFightForceDirty()
                        local newfightforce = RoleData:getFightForce()
                        local extraWidgets = self:checkPeopleKingSuit(advancedPage)
                        GlobalApi:popupTips(currAttr, nextAttr, oldfightforce, newfightforce, extraWidgets)
                    end)
                else
                    self:updateWeaponData(jsonObj.data, false)
                end
            elseif advancedPage == 2 then
                if self.peopleKingData.wing_level < jsonObj.data.wing_level then
                    local currAttr = RoleData:getPeopleKingWingAttr()
                    local nextAttr = RoleData:getPeopleKingNextWingAttr()
                    local showCurrAttr = {}
                    local showNextAttr = {}
                    showCurrAttr[1] = currAttr[1] or 0
                    showCurrAttr[2] = currAttr[4] or 0
                    showCurrAttr[3] = currAttr[2] or 0
                    showCurrAttr[4] = currAttr[3] or 0
                    showNextAttr[1] = nextAttr[1] or 0
                    showNextAttr[2] = nextAttr[4] or 0
                    showNextAttr[3] = nextAttr[2] or 0
                    showNextAttr[4] = nextAttr[3] or 0
                    local oldfightforce = RoleData:getFightForce()
                    self:updateWingData(jsonObj.data, true)
                    RoleMgr:showStengthenPopupUI(RoleData:getMainRole(), 'upgrade_peopleking_wing', showCurrAttr, showNextAttr, function ()
                        RoleData:setAllFightForceDirty()
                        local newfightforce = RoleData:getFightForce()
                        local extraWidgets = self:checkPeopleKingSuit(advancedPage)
                        GlobalApi:popupTips(currAttr, nextAttr, oldfightforce, newfightforce, extraWidgets)
                    end)
                else
                    self:updateWingData(jsonObj.data, false)
                end
            end
        elseif code == 101 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("LIMIT_MAT_OUT_OF_TIME"), COLOR_TYPE.RED)
        else
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'), COLOR_TYPE.RED)
        end
        self:update()
        self.useNum = 0
        self.energy = 0
        self.tiemdelta = 0
    end)
end

function PeopleKingMainUI:updateWeaponData(data, lvUp)
    self.peopleKingData.weapon_level = data.weapon_level
    self.peopleKingData.weapon_energy = data.weapon_energy
    self.peopleKingData.weapon_energy_target = data.weapon_energy_target
    self.peopleKingData.weapon_energy_clean_time = data.weapon_energy_clean_time
    
    if lvUp then
        --升阶成功解锁
        local skyskillConf = GameData:getConfData("skyskill")
        for i = 1, 4 do
            if skyskillConf[1][i] and skyskillConf[1][i].unlock <= data.weapon_level then
                local skillId = tostring(i)
                if self.peopleKingData.weapon_skills[skillId] == nil or self.peopleKingData.weapon_skills[skillId] <= 0 then
                    self.peopleKingData.weapon_skills[skillId] = 1
                end
            end
        end

        local skychangeConf = GameData:getConfData("skychange")
        for k, v in ipairs(skychangeConf[1]) do
            if v.condition == "level" and v.value == self.peopleKingData.weapon_level then
                self.peopleKingData.weapon_collect = self.peopleKingData.weapon_collect + 1
                self.activateNewWeapon = true
                break
            end
        end

        -- 红点数据
        local skychangeConf = GameData:getConfData("skychange")[1]
        for i=1,#skychangeConf do
            if skychangeConf[i].condition == "level" and data.weapon_level == skychangeConf[i].value then
                local id = skychangeConf[i].id
                local key = UserData:getUserObj():getUid() .. 'changelook_sign_1_' .. id
                cc.UserDefault:getInstance():setBoolForKey(key, true)
                local ownWeapon = self.peopleKingData.ownWeapon
                ownWeapon[#ownWeapon+1] = tonumber(id)
                UserData:getUserObj():getPeopleKing().ownWeapon = ownWeapon
                break
            end
        end    
    end
end

function PeopleKingMainUI:updateWingData(data, lvUp)
    self.peopleKingData.wing_level = data.wing_level
    self.peopleKingData.wing_energy = data.wing_energy
    self.peopleKingData.wing_energy_target = data.wing_energy_target
    self.peopleKingData.wing_energy_clean_time = data.wing_energy_clean_time

    if lvUp then
        --升阶成功解锁
        local skyskillConf = GameData:getConfData("skyskill")
        for i = 1, 4 do
            if skyskillConf[2][i] and skyskillConf[2][i].unlock <= data.wing_level then
                local skillId = tostring(i)
                if self.peopleKingData.wing_skills[skillId] == nil or self.peopleKingData.wing_skills[skillId] <= 0 then
                    self.peopleKingData.wing_skills[skillId] = 1
                end
            end
        end

        local skychangeConf = GameData:getConfData("skychange")
        for k, v in ipairs(skychangeConf[2]) do
            if v.condition == "level" and v.value == self.peopleKingData.wing_level then
                self.peopleKingData.wing_collect = self.peopleKingData.wing_collect + 1
                self.activateNewWing = true
                break
            end
        end

        -- 红点数据
        local skychangeConf = GameData:getConfData("skychange")[2]
        for i=1,#skychangeConf do
            if skychangeConf[i].condition == "level" and data.wing_level == skychangeConf[i].value then
                local id = skychangeConf[i].id
                local key = UserData:getUserObj():getUid() .. 'changelook_sign_2_' .. id
                cc.UserDefault:getInstance():setBoolForKey(key, true)

                local ownWing = self.peopleKingData.ownWing
                ownWing[#ownWing+1] = tonumber(id)
                UserData:getUserObj():getPeopleKing().ownWing = ownWing
                break
            end
        end
    end
end

function PeopleKingMainUI:scheduleUpdate(dt)
    if self.isSchedule then
        self.timeDelta = self.timeDelta + dt
        if self.advancedBegin and self.timeDelta > MAXDELTA then
            self:calEnergy()
            self.timeDelta = 0
        end
        if self.showEnergyClearTime then
            self:updateEnergyCleanTime()
        end
    end
end

function PeopleKingMainUI:calEnergy()
    local conf
    local needEnergy = 0
    if self.advancedPage == 1 then
        conf = GameData:getConfData("skyweap")[self.peopleKingData.weapon_level]
        needEnergy = self.peopleKingData.weapon_energy_target
    elseif self.advancedPage == 2 then
        conf = GameData:getConfData("skywing")[self.peopleKingData.wing_level]
        needEnergy = self.peopleKingData.wing_energy_target
    end
    local award = DisplayData:getDisplayObj(conf["cost" .. self.advancedIndex][1])
    local materialobj = BagData:getBagobjByObj(award)
    if materialobj == nil then
        self.advanced_bar_ani:setVisible(false)
        self.advancedBegin = false
        promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
        return
    end
    if conf.clean == 1 and self.energy <= 0 then
        local showTipsKey = UserData:getUserObj():getUid() .. "_peopleking_" .. self.advancedPage
        local showTips = cc.UserDefault:getInstance():getIntegerForKey(showTipsKey, 0)
        if showTips <= 0 then
            self.advanced_bar_ani:setVisible(false)
            cc.UserDefault:getInstance():setIntegerForKey(showTipsKey, 1)
            self.advancedBegin = false
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_17"), conf.cleanTime), MESSAGE_BOX_TYPE.MB_OK)
            return
        end
    end
    local costnum = award:getNum()
    local nownum = materialobj:getOwnNum() - self.useNum*costnum
    if costnum <= nownum then
        if self.energy < conf.energyMin then
            self.useNum = self.useNum + 1
            self.energy = self.energy + conf.getEnergy
            self.advanced_bar_ani:setVisible(true)
            self.advanced_bar_ani:setPositionX(self.energy*self.advanced_bar_width/conf.maxEnergy - 50)
            self["itemCell" .. self.advancedIndex].lvTx:setString("x" .. nownum)
            self:updateBar(self.energy, conf.maxEnergy)
            promptmgr:showSystenHint(GlobalApi:getLocalStr("PEOPLE_KING_ENERGY") .. GlobalApi:getLocalStr("STR_ADD") .. conf.getEnergy, COLOR_TYPE.GREEN)
            return
        end
        if self.energy >= conf.energyMax then
			self:updateBar(self.energy, conf.maxEnergy)
            self:lvUpPost()
            return
        end
        if self.energy >= needEnergy then
            self:updateBar(self.energy, conf.maxEnergy)
            self:lvUpPost()
            return
        else
            self.useNum = self.useNum + 1
            self.energy = self.energy + conf.getEnergy
            if self.energy >= conf.maxEnergy then
                self:updateBar(self.energy, conf.maxEnergy)
                self:lvUpPost()
                return
            end
            self.advanced_bar_ani:setVisible(true)
            self.advanced_bar_ani:setPositionX(self.energy*self.advanced_bar_width/conf.maxEnergy - 50)
            self["itemCell" .. self.advancedIndex].lvTx:setString("x" .. nownum)
            self:updateBar(self.energy, conf.maxEnergy)
            promptmgr:showSystenHint(GlobalApi:getLocalStr("PEOPLE_KING_ENERGY") .. GlobalApi:getLocalStr("STR_ADD") .. conf.getEnergy, COLOR_TYPE.GREEN)
        end
    else
        if self.useNum > 0 then
            self:lvUpPost()
        end
    end
    self:updateBar(self.energy, conf.maxEnergy)
end

function PeopleKingMainUI:updateBar(currEnergy, maxEnergy)
    self.advanced_bar:setPercent(currEnergy*100/maxEnergy)
    self.advanced_bar_tx:setString(GlobalApi:getLocalStr("PEOPLE_KING_ENERGY") .. " " .. currEnergy .. "/" .. maxEnergy)
end

function PeopleKingMainUI:updateEnergyCleanTime()
    if self.page == 1 then
        local time = self.peopleKingData.weapon_energy_clean_time - GlobalData:getServerTime()
        if time > 0 then
            if self.countDownTime ~= time then
                self.countDownTime = time
                self.advanced_count_down:setString(getTime(time))
            end
        else
            self.countDownTime = 0
            self.showEnergyClearTime = false
            self.advanced_count_down:setString("00:00:00")
            self.peopleKingData.weapon_energy_clean_time = 0
            self.peopleKingData.weapon_energy = 0
            self:update()
        end
    elseif self.page == 2 then
        local time = self.peopleKingData.wing_energy_clean_time - GlobalData:getServerTime()
        if time > 0 then
            if self.countDownTime ~= time then
                self.countDownTime = time
                self.advanced_count_down:setString(getTime(time))
            end
        else
            self.countDownTime = 0
            self.showEnergyClearTime = false
            self.advanced_count_down:setString("00:00:00")
            self.peopleKingData.wing_energy_clean_time = 0
            self.peopleKingData.wing_energy = 0
            self:update()
        end
    end
end

function PeopleKingMainUI:skillCouldUp(id,curLv)
    local skillConf = GameData:getConfData("skyskill")[self.page]
    local skillupConf = GameData:getConfData("skyskillup")
    local JieShu = self.page == 1 and self.peopleKingData.weapon_level or self.peopleKingData.wing_level
    if not skillConf[id] then
        return false
    end
    local skillId = self.page*100+id
    if not skillupConf[skillId] then
        return false
    end
    local maxLvOfStage = skillConf[id].levelLimit*JieShu
    if curLv >= maxLvOfStage then
         return false
    else
        local costnum = skillupConf[skillId][curLv].cost[1][3] or 0
        local ownbooks = UserData:getUserObj():getSkybook()
        if ownbooks < -costnum then
            return false
        end
    end
    return true
end

function PeopleKingMainUI:checkStone()
    for i,v in ipairs(M_IDS) do
        local material = BagData:getMaterialById(v)
        if material and material:getOwnNum() > 0 then
            local conf
            local useNum = 0
            if i == 1 then
                if self.page == 1 then
                    useNum = self.peopleKingData.weapon_gas
                    conf = GameData:getConfData("skygasawaken")[self.page][self.peopleKingData.weapon_level]
                elseif self.page == 2 then
                    useNum = self.peopleKingData.wing_gas
                    conf = GameData:getConfData("skygasawaken")[self.page][self.peopleKingData.wing_level]
                end
            elseif i == 2 then
                if self.page == 1 then
                    useNum = self.peopleKingData.weapon_blood
                    conf = GameData:getConfData("skybloodawaken")[self.page][self.peopleKingData.weapon_level]
                elseif self.page == 2 then
                    useNum = self.peopleKingData.wing_blood
                    conf = GameData:getConfData("skybloodawaken")[self.page][self.peopleKingData.wing_level]
                end
            end
            if conf.num > 0 and useNum < conf.num then 
                return true
            end
        end
    end
    return false
end

function PeopleKingMainUI:checkPeopleKingSuit(page)
    local skyBuffLv = self.peopleKingData.weapon_level
    if skyBuffLv > self.peopleKingData.wing_level then
        skyBuffLv = self.peopleKingData.wing_level
    end
    local lstSkyBuffLv = self.peopleKingData.weapon_level
    local collect
    local activateNew = false
    if page == 1 then
        collect = self.peopleKingData.weapon_collect
        activateNew = self.activateNewWeapon
        self.activateNewWeapon = false
        lstSkyBuffLv = lstSkyBuffLv - 1
        if lstSkyBuffLv > self.peopleKingData.wing_level then
            lstSkyBuffLv = self.peopleKingData.wing_level
        end
    elseif page == 2 then
        collect = self.peopleKingData.wing_collect
        activateNew = self.activateNewWing
        self.activateNewWing = false
        if lstSkyBuffLv > self.peopleKingData.wing_level - 1 then
            lstSkyBuffLv = self.peopleKingData.wing_level - 1
        end
    end
    local extraWidgets
    local attr
    local activateWidget
    if activateNew and collect > 0 then
        local collectLv = 0
        local skycollectConf = GameData:getConfData("skycollect")
        for k, v in ipairs(skycollectConf[page]) do
            if collect == v.goalValue then
                collectLv = k
            elseif collect < v.goalValue then
                break
            end
        end
        if collectLv > 0 then
            attr = attr or {}
            if skycollectConf[page][collectLv] then
                local attId = skycollectConf[page][collectLv].att1
                attr[attId] = attr[attId] or 0
                if skycollectConf[page][collectLv-1] then
                    attr[attId] = attr[attId] + skycollectConf[page][collectLv].value1 - skycollectConf[page][collectLv-1].value1
                else
                    attr[attId] = attr[attId] + skycollectConf[page][collectLv].value1
                end
                activateWidget = activateWidget or {}
                local str = page == 1 and GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_5") or GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_6")
                local name = GlobalApi:getLocalStr("FATE_SPECIAL_DES5") .. "  " .. str .. "Lv." .. collectLv
                table.insert(activateWidget, self:createPopWidget(COLOR_TYPE.YELLOW, name))
            end 
        end
    end
    if skyBuffLv > 0 and skyBuffLv ~= lstSkyBuffLv then
        attr = attr or {}
        local skybuffConf = GameData:getConfData("skybuff")
        if skybuffConf[skyBuffLv] then
            if skybuffConf[skyBuffLv-1] then
                for k, v in ipairs(skybuffConf[skyBuffLv].att) do
                    attr[v] = attr[v] or 0
                    attr[v] = attr[v] + skybuffConf[skyBuffLv].value[k] - skybuffConf[skyBuffLv-1].value[k]
                end
            else
                for k, v in ipairs(skybuffConf[skyBuffLv].att) do
                    attr[v] = attr[v] or 0
                    attr[v] = attr[v] + skybuffConf[skyBuffLv].value[k]
                end
            end
        end
        activateWidget = activateWidget or {}
        local name = GlobalApi:getLocalStr("FATE_SPECIAL_DES5") .. "  " .. GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_5") .. "Lv." .. skyBuffLv
        table.insert(activateWidget, self:createPopWidget(COLOR_TYPE.YELLOW, name))
    end
    if activateWidget and #activateWidget > 0 then
        extraWidgets = extraWidgets or {}
        if attr then
            local attconf = GameData:getConfData("attribute")
            for k, v in pairs(attr) do
                local name = GlobalApi:getLocalStr("TREASURE_DESC_13") .. "  " .. attconf[k].name .. " + " .. v
                if attconf[k].desc ~= "0" then
                    name = name .. attconf[k].desc
                end
                table.insert(extraWidgets, self:createPopWidget(COLOR_TYPE.YELLOW, name))
            end
        end
        for k, v in ipairs(activateWidget) do
            table.insert(extraWidgets, v)
        end
    end
    return extraWidgets
end

function PeopleKingMainUI:createPopWidget(color, name)
    local w = cc.Label:createWithTTF(name, "font/gamefont.ttf", 24)
    w:setTextColor(color)
    w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    return w
end

return PeopleKingMainUI