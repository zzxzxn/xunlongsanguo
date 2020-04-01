local CountryPillarUI = class("CountryPillarUI", BaseUI)

function CountryPillarUI:ctor(country, data)
    self.uiIndex = GAME_UI.UI_COUNTRY_PILLAR
    self.data = data
    self.country = country
    self.waitToClose = false
    self.schedulerEntryId = 0
end

function CountryPillarUI:init()
    local bg_alpha_img = self.root:getChildByName("bg_alpha_img")
    local middle_node = bg_alpha_img:getChildByName("middle_node")
    self:adaptUI(bg_alpha_img, middle_node)

    local layout = middle_node:getChildByName("layout")
    local bg_img = layout:getChildByName("bg_img")

    local scroll_img_1 = middle_node:getChildByName("scroll_img_1")
    local scroll_img_2 = middle_node:getChildByName("scroll_img_2")

    local close_btn = middle_node:getChildByName("close_btn")
    close_btn:setTouchEnabled(false)

    local sv = middle_node:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    local svSize = sv:getContentSize()

    local heroConf = GameData:getConfData("hero")
    local positionConf = GameData:getConfData("position")
    local totalNum = 0
    for i = 1, 3 do
        totalNum = totalNum + positionConf[i].count
    end
    local widgetW = 180
    local widgetH = 160
    for i = 1, totalNum do
        local widget = ccui.Layout:create()
        widget:setTouchEnabled(true)
        widget:addClickEventListener(function ()
            if not self.waitToClose then
                BattleMgr:showCheckInfo(self.data[i][5],'world',"country")
            end
        end)
        widget:setContentSize(cc.size(widgetW, widgetH))
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if self.data[i][6] and self.data[i][6][1] then
            promote = self.data[i][6][1]
        end
        if heroConf[tonumber(self.data[i][4])].camp == 5 then
            if self.data[i][7] and self.data[i][7] > 0 then
                weapon_illusion = self.data[i][7]
            end
            if self.data[i][8] and self.data[i][8] > 0 then
                wing_illusion = self.data[i][8]
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        local hero = GlobalApi:createLittleLossyAniByName(heroConf[tonumber(self.data[i][4])].url .. "_display", nil, changeEquipObj)
        hero:setScale(0.8)
        hero:getAnimation():play("idle", -1, -1)
        local shadow = hero:getBone(heroConf[tonumber(self.data[i][4])].url .. "_display_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
        end
        hero:setPosition(cc.p(widgetW/2, heroConf[tonumber(self.data[i][4])].uiOffsetY))
        widget:addChild(hero)

        local position_tx = ccui.Text:create()
        position_tx:setFontName("font/gamefont.ttf")
        position_tx:setFontSize(26)
        position_tx:enableOutline(COLOR_TYPE.BLACK, 1)
        position_tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        position_tx:setString(self.data[i][1])
        position_tx:setPosition(cc.p(widgetW/2, 220))
        widget:addChild(position_tx)
        if i == 1 then
            position_tx:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. self.country))
        else
            if i < 2 + positionConf[2].count then
                position_tx:setString(positionConf[2].title)
            else
                position_tx:setString(positionConf[3].title)
            end
        end
        position_tx:setTextColor(COLOR_QUALITY[positionConf[i].quality])

        local name_tx = ccui.Text:create()
        name_tx:setFontName("font/gamefont.ttf")
        name_tx:setFontSize(24)
        name_tx:enableOutline(COLOR_TYPE.BLACK, 1)
        name_tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        name_tx:setString(self.data[i][1])
        name_tx:setPosition(cc.p(widgetW/2, 180))
        widget:addChild(name_tx)

        widget:setPosition(cc.p(20 + 100 + (i-1)*200 - widgetW/2, 190))
        sv:addChild(widget)
    end
    sv:setInnerContainerSize(cc.size(totalNum*200 + 40, svSize.height))

    local needMoveX = 724
    local pox1 = scroll_img_1:getPositionX()
    local pox2 = bg_img:getPositionX()
    local pox3 = sv:getPositionX()
    local sizeW = svSize.width - needMoveX
    if sizeW < 0 then
        sizeW = 0
    end
    scroll_img_1:setPositionX(pox1 + needMoveX)
    bg_img:setPositionX(pox2 + needMoveX)
    sv:setPositionX(pox3 + needMoveX)
    sv:setContentSize(cc.size(sizeW, svSize.height))

    local stepX = 80
    local totalX = 0
    bg_alpha_img:scheduleUpdateWithPriorityLua(function (dt)
        totalX = totalX + stepX
        if totalX < needMoveX then
            scroll_img_1:setPositionX(pox1 + needMoveX - totalX)
            bg_img:setPositionX(pox2 + needMoveX - totalX)
            sv:setPositionX(pox3 + needMoveX - totalX)
            sv:setContentSize(cc.size(sizeW + totalX, svSize.height))
        else
            close_btn:setTouchEnabled(true)
            scroll_img_1:setPositionX(pox1)
            bg_img:setPositionX(pox2)
            sv:setPositionX(pox3)
            sv:setContentSize(cc.size(svSize.width, svSize.height))
            bg_alpha_img:unscheduleUpdate()
        end
    end, 0)

    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            close_btn:setTouchEnabled(false)
            self.waitToClose = true
            totalX = 0
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
            self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
                totalX = totalX + stepX
                if totalX < needMoveX then
                    scroll_img_1:setPositionX(pox1 + totalX)
                    bg_img:setPositionX(pox2 + totalX)
                    sv:setPositionX(pox3 + totalX)
                    sv:setContentSize(cc.size(svSize.width - totalX, svSize.height))
                else
                    scroll_img_1:setPositionX(pox1 + needMoveX)
                    bg_img:setPositionX(pox2 + needMoveX)
                    sv:setPositionX(pox3 + needMoveX)
                    sv:setContentSize(cc.size(sizeW, svSize.height))
                    if self.schedulerEntryId > 0 then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                        self.schedulerEntryId = 0
                    end
                    CountryMgr:hideCountryPillar()
                end
            end, 0.03, false)
        end
    end)

    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
        end
    end)
end

return CountryPillarUI