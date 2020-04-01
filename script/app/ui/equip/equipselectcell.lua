local EquipSelectCell = class("EquipSelectCell")
local ClassItemCell = require('script/app/global/itemcell')

function EquipSelectCell:ctor(roleobj,index,width, equipObj, isSelected)
    self.width = width
    self.height = 0
    self.isSelected = isSelected
    self.roleobj = roleobj
    self.index = index
    self:initCell(equipObj)
end

function EquipSelectCell:initCell(equipObj)
    local subAttrs = equipObj:getSubAttribute()
    local subAttrNum = equipObj:getSubAttrNum()
    local num = subAttrNum > 2 and subAttrNum or 2
    local godId = equipObj:getGodId()
    if godId > 0 then
        local godNum = godId == 3 and 2 or 1
        subAttrNum = subAttrNum + godNum
    end
    self.height = 110 + subAttrNum*26
    self.node = cc.Node:create()
    self.node:setPosition(cc.p(60, self.height - 55))
    local bgImg = ccui.ImageView:create()
    bgImg:loadTexture("uires/ui/common/common_bg_2.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width, self.height))

    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equipObj, self.node)
    tab.awardBgImg:setTouchEnabled(false)
    bgImg:addChild(self.node)

    -- icon
    local equipLvLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    equipLvLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    equipLvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    equipLvLabel:setAnchorPoint(cc.p(0, 0.5))
    equipLvLabel:setTextColor(equipObj:getNameColor())
    equipLvLabel:setString("Lv. " .. equipObj:getLevel() .. " " .. equipObj:getName())
    equipLvLabel:setPosition(cc.p(120, self.height - 25))
    bgImg:addChild(equipLvLabel)

    local equipLvLimitLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    self.equipLvLimitLabel = equipLvLimitLabel
    equipLvLimitLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    equipLvLimitLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    equipLvLimitLabel:setAnchorPoint(cc.p(1, 0.5))
    equipLvLimitLabel:setTextColor(COLOR_TYPE.RED)
    equipLvLimitLabel:setString(GlobalApi:getLocalStr('STR_JUNZHU') .. (equipObj:getLevel()-10) ..GlobalApi:getLocalStr('EQUIP_LIMIT') )
    equipLvLimitLabel:setPosition(cc.p(self.width-5, 70))
    bgImg:addChild(equipLvLimitLabel)
    if self.roleobj  then
        if UserData:getUserObj():getLv() + 10 >= equipObj:getLevel() then
            equipLvLimitLabel:setVisible(false)
        else
            equipLvLimitLabel:setVisible(true)
        end
    else
        equipLvLimitLabel:setVisible(false)
    end
    
    if equipObj.name then
        -- 装备的人
        local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
        nameLabel:setAnchorPoint(cc.p(1, 0.5))
        local nameStr = GlobalApi:getLocalStr("HAD_EQUIPED")..equipObj.name
        nameLabel:enableOutline(COLOROUTLINE_TYPE.RED, 1)
        nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        nameLabel:setTextColor(COLOR_TYPE.RED)
        nameLabel:setString(nameStr)
        nameLabel:setPosition(cc.p(400, 40))
        bgImg:addChild(nameLabel)
    end

    -- 装备战斗力
    local fightforceLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    local fightforceStr = GlobalApi:getLocalStr("STR_EQUIP_FIGHTFORCE") .. "：" .. equipObj:getFightForce()
    fightforceLabel:enableOutline(equipObj:getNameOutlineColor(), 1)
    fightforceLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fightforceLabel:setTextColor(equipObj:getNameColor())
    fightforceLabel:setString(fightforceStr)
    fightforceLabel:setPosition(cc.p(120, self.height - 55))
    bgImg:addChild(fightforceLabel)

    -- 主属性
    local mainAttribute = equipObj:getMainAttribute()
    local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
    local attributeLabel1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
    attributeLabel1:setAnchorPoint(cc.p(0, 0.5))
    attributeLabel1:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    attributeLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    attributeLabel1:setTextColor(COLOR_TYPE.WHITE)
    attributeLabel1:setString(mainAttributeStr)
    attributeLabel1:setPosition(cc.p(120, self.height - 81))
    bgImg:addChild(attributeLabel1)

    -- 副属性
    local subAttrIndex = 0
    for k, v in pairs(subAttrs) do
        subAttrIndex = subAttrIndex + 1
        local attributeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
        local subAttrStr = v.name .. "    +" .. v.value
        attributeLabel:setAnchorPoint(cc.p(0, 0.5))
        attributeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        attributeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        attributeLabel:setTextColor(equipObj:getNameColor())
        attributeLabel:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        attributeLabel:setString(subAttrStr)
        bgImg:addChild(attributeLabel)
    end
    ClassItemCell:setGodLight(tab.awardBgImg, equipObj:getGodId())
    -- 神器

    self.newImg = ccui.ImageView:create()
    self.newImg:loadTexture("uires/ui/common/corner_blue_1.png")
    self.newImg:setAnchorPoint(cc.p(1,1))
    self.newImg:setPosition(cc.p(self.width,self.height))
    self.newImg:setName('new_Img')
    self.newImg:setVisible(false)
    local newTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    newTx:setPosition(cc.p(44,44))
    newTx:setColor(COLOR_TYPE.WHITE)
    newTx:enableOutline(COLOR_TYPE.BLACK, 1)
    newTx:setRotation('45')
    newTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    newTx:setAnchorPoint(cc.p(0.5,0.5))
    newTx:setName('new_Tx')
    newTx:setString(GlobalApi:getLocalStr('STR_TUIJIAN'))
    self.newImg:addChild(newTx)
    bgImg:addChild(self.newImg)

    if self.roleobj and self.index == 1 then
        local ishaveeq,canequip = self.roleobj:isHavebetterEquip(equipObj:getType())
        if ishaveeq and canequip then
            self.newImg:setVisible(true)
        end       
    end

    if godId > 0 then
        local godLevel = equipObj:getGodLevel()
        subAttrIndex = subAttrIndex + 1
        local godObj = clone(equipObj:getGodAttr())
        local goldLabel1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
        goldLabel1:setAnchorPoint(cc.p(0, 0.5))
        goldLabel1:setTextColor(COLOR_TYPE[godObj[1].color])
        goldLabel1:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        goldLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        goldLabel1:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        bgImg:addChild(goldLabel1)
        if godObj[1].type == 1 then
            godObj[1].value = math.floor(godObj[1].value/100)
        end
        if godObj[1].double then
            goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value*2 .. "%")
        else
            goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
        end
        if godObj[2] then
            subAttrIndex = subAttrIndex + 1
            local goldLabel2 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
            goldLabel2:setAnchorPoint(cc.p(0, 0.5))
            goldLabel2:setTextColor(COLOR_TYPE[godObj[2].color])
            goldLabel2:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
            goldLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            goldLabel2:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
            bgImg:addChild(goldLabel2)
            if godObj[2].type == 1 then
                godObj[2].value = math.floor(godObj[2].value/100)
            end
            if godObj[2].double then
                goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value*2 .. "%")
            else
                goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value .. "%")
            end
        end
    end

    local checkBox = ccui.CheckBox:create("uires/ui/common/bg_checkbox.png", "uires/ui/common/select_checkbox.png")
    self.checkBox = checkBox
    checkBox:setPosition(cc.p(self.width - 60, 30))
    checkBox:setTouchEnabled(true)
    if self.isSelected then
        checkBox:setSelected(true)
    end
    bgImg:addChild(checkBox)
    local function selectedEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            local flag = self.callback(true)
            if not flag then
                checkBox:setSelected(false)
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self.callback(false)
        end
    end
    checkBox:addEventListener(selectedEvent)
    bgImg:setTouchEnabled(true)
    bgImg:addClickEventListener(function ()
        if checkBox:isVisible() then
            if checkBox:isSelected() then
                self.callback(false)
                checkBox:setSelected(false)
            else
                local flag = self.callback(true)
                if flag then
                    checkBox:setSelected(true)
                end
            end
        else
            self.callback(true)
        end
    end)
    self.panel = bgImg
end

function EquipSelectCell:setEquiped()
    local equipedImg = cc.Sprite:create("uires/ui/common/icon_yizhuangbei.png")
    equipedImg:setAnchorPoint(cc.p(0.5, 0.5))
    equipedImg:setPosition(cc.p(self.width - 80, 50))
    self.panel:addChild(equipedImg)
    self.panel:setTouchEnabled(false)
end

function EquipSelectCell:getPanel()
    return self.panel
end

function EquipSelectCell:getSize()
    return self.width, self.height
end

function EquipSelectCell:setPosition(pos)
    self.panel:setPosition(pos)
end

function EquipSelectCell:setSelectCallBack(callback)
    self.callback = callback
end

function EquipSelectCell:setCheckBoxVisible(vis)
    self.checkBox:setVisible(vis)
    if vis then
        self.equipLvLimitLabel:setPosition(cc.p(self.width-5, 70))
    else
        self.equipLvLimitLabel:setPosition(cc.p(self.width-5, 30))
    end
end

return EquipSelectCell