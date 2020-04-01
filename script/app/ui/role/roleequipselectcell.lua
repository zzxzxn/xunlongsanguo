local RoleEquipSelectCell = class("RoleEquipSelectCell")
local ClassItemCell = require('script/app/global/itemcell')
local BASE_HEIGHT = 110
local BASE_WIDTH = 450
local ATTR_HEIGHT = 26

function RoleEquipSelectCell:ctor(rolePos, equipObj, isEquiped, index)
	self.width = BASE_WIDTH
	self.height = 0
    self.rolePos = rolePos
    self.isEquiped = isEquiped
    self.equipObj = equipObj
    self.index = index
	self:initCell(equipObj)
    self.panel:setName("equip_select_cell_" .. index)
end

function RoleEquipSelectCell:initCell(equipObj)
    local roleObj = RoleData:getRoleByPos(self.rolePos)
	local subAttrs = self.equipObj:getSubAttribute()
	local subAttrNum = self.equipObj:getSubAttrNum()
	local num = subAttrNum > 2 and subAttrNum or 2
    local godId = self.equipObj:getGodId()
    if godId > 0 then
        local godNum = godId == 3 and 2 or 1
        subAttrNum = subAttrNum + godNum
    end
	self.height = BASE_HEIGHT + subAttrNum*ATTR_HEIGHT

	--self.panel = ccui.Widget:create()
	local bgImg = ccui.ImageView:create()
    self.bgImg = bgImg
    bgImg:loadTexture("uires/ui/common/common_bg_2.png")
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width, self.height))
    --bgImg:setPositionY(-self.height/2)
    --self.panel:addChild(bgImg)
    self.panel = bgImg
    -- bg_icon
    self.node = cc.Node:create()
    self.node:setPosition(cc.p(60, self.height - 55))
    self.tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.equipObj, self.node)
    self.tab.awardBgImg:setTouchEnabled(false)
    bgImg:addChild(self.node)
    local equipLvLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    self.equipLvLabel = equipLvLabel
    equipLvLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
    equipLvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    equipLvLabel:setAnchorPoint(cc.p(0, 0.5))
    equipLvLabel:setTextColor(self.equipObj:getNameColor())
    equipLvLabel:setString("Lv." .. self.equipObj:getLevel() .. " " .. self.equipObj:getName())
    equipLvLabel:setPosition(cc.p(120, self.height - 25))
    bgImg:addChild(equipLvLabel)
    

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
    -- 装备战斗力
    local fightforceLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
    self.fightforceLabel = fightforceLabel
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    local fightforceStr = nil
    if self.index == 1 then
        local ishaveeq,canequip = roleObj:isHavebetterEquip(self.equipObj:getType())
        if ishaveeq and canequip then
            self.newImg:setVisible(true)
        end       
    end

    if self.isEquiped then
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIP_FIGHTFORCE") .. "：" .. self:getProFightForce()
    else
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIPED_FIGHTFORCE") .. "：" .. self:getProFightForce()
    end
    fightforceLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
    fightforceLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fightforceLabel:setTextColor(self.equipObj:getNameColor())
    fightforceLabel:setString(fightforceStr)
    fightforceLabel:setPosition(cc.p(120, self.height - 55))
    bgImg:addChild(fightforceLabel)

    -- 主属性
    local mainAttribute = self.equipObj:getMainAttribute()
	local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
	local attributeLabel1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
    self.attributeLabel1 = attributeLabel1
	attributeLabel1:setAnchorPoint(cc.p(0, 0.5))
    attributeLabel1:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
    attributeLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	attributeLabel1:setTextColor(COLOR_TYPE.WHITE)
	attributeLabel1:setString(mainAttributeStr)
	attributeLabel1:setPosition(cc.p(120, self.height - 81))
	bgImg:addChild(attributeLabel1)

	-- 副属性
    local subAttrIndex = 0
    self.attributeLabelArr = {}
    for i = 1, 4 do
        local attributeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
        self.attributeLabelArr[i] = attributeLabel
        attributeLabel:setAnchorPoint(cc.p(0, 0.5))
        attributeLabel:setVisible(false)
        bgImg:addChild(attributeLabel)
    end
    for k, v in pairs(subAttrs) do
        subAttrIndex = subAttrIndex + 1
        local attributeLabel = self.attributeLabelArr[subAttrIndex]
        local subAttrStr = v.name .. "    +" .. v.value
        attributeLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
        attributeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        attributeLabel:setTextColor(self.equipObj:getNameColor())
        attributeLabel:setPosition(cc.p(120, self.height - 81 - subAttrIndex*ATTR_HEIGHT))
        attributeLabel:setString(subAttrStr)
        attributeLabel:setVisible(true)
    end

    -- 神器
    local goldLabel1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
    self.goldLabel1 = goldLabel1
    goldLabel1:setAnchorPoint(cc.p(0, 0.5))
    goldLabel1:setVisible(false)
    bgImg:addChild(goldLabel1)
    local goldLabel2 = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
    self.goldLabel2 = goldLabel2
    goldLabel2:setAnchorPoint(cc.p(0, 0.5))
    goldLabel2:setVisible(false)
    bgImg:addChild(goldLabel2)
    if godId > 0 then
        subAttrIndex = subAttrIndex + 1
        local godObj = clone(self.equipObj:getGodAttr())
        goldLabel1:setVisible(true)
        goldLabel1:setTextColor(COLOR_TYPE[godObj[1].color])
        goldLabel1:enableOutline(COLOROUTLINE_TYPE[godObj[1].color], 1)
        goldLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        goldLabel1:setPosition(cc.p(120, self.height - 81 - subAttrIndex*ATTR_HEIGHT))

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
            goldLabel2:setVisible(true)
            goldLabel2:setTextColor(COLOR_TYPE[godObj[2].color])
            goldLabel2:enableOutline(COLOROUTLINE_TYPE[godObj[2].color], 1)
            goldLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            goldLabel2:setPosition(cc.p(120, self.height - 81 - subAttrIndex*ATTR_HEIGHT))
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
    -- 已装备
    ClassItemCell:setGodLight(self.tab.awardBgImg,self.equipObj:getGodId())
    local equipedImg = cc.Sprite:create("uires/ui/common/icon_yizhuangbei.png")
    self.equipedImg = equipedImg
    equipedImg:setAnchorPoint(cc.p(0.5, 0.5))
    equipedImg:setPosition(cc.p(self.width - 80, 50))
    bgImg:addChild(equipedImg)
    -- 穿戴按钮
    local putOnBtn = ccui.Button:create("uires/ui/common/common_btn_3.png", nil, nil)
    putOnBtn:setName("puton_btn")
    self.putOnBtn = putOnBtn
    local putOnBtnSize = putOnBtn:getContentSize()
    local putOnLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    putOnLabel:setTextColor(cc.c4b(255, 255, 255, 255))
    putOnLabel:enableOutline(cc.c4b(154, 91, 50, 255), 1)
    putOnLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    putOnLabel:setPosition(cc.p(putOnBtnSize.width/2, putOnBtnSize.height/2))
    putOnLabel:setString(GlobalApi:getLocalStr("EQUIP"))
    putOnBtn:setTouchEnabled(true)
    putOnBtn:setPropagateTouchEvents(false)
    putOnBtn:addChild(putOnLabel)
    putOnBtn:setPosition(cc.p(self.width - 80, 50))
    putOnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            local roleObj = RoleData:getRoleByPos(self.rolePos)
            local obj = roleObj:getEquipByIndex(self.equipObj:getType())
            if obj and obj:getGodId() ~= 0 and self.equipObj:getGodId() == 0 then
                local godLevel = obj:getGodLevel()
                local godEquipConf = GameData:getConfData("godequip")
                local godEquipObj = godEquipConf[self.equipObj:getType()][godLevel]
                local cost = -self.equipObj:getInheritCost()
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('MESSAGE_3'),cost,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        self:SendPost(self.equipObj,1,cost)
                  end,GlobalApi:getLocalStr('TAVERN_YES'),GlobalApi:getLocalStr('TAVERN_NO'),function ()
                        self:SendPost(self.equipObj,0)
                  end)                 
            else
                self:SendPost(self.equipObj,0)
            end
        end
    end)
    bgImg:addChild(putOnBtn)
    local equipLvLimitLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    self.equipLvLimitLabel = equipLvLimitLabel
    equipLvLimitLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    equipLvLimitLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    equipLvLimitLabel:setAnchorPoint(cc.p(1, 0.5))
    equipLvLimitLabel:setTextColor(COLOR_TYPE.RED)
    equipLvLimitLabel:setString(GlobalApi:getLocalStr('STR_JUNZHU') .. (self.equipObj:getLevel()-10) ..GlobalApi:getLocalStr('EQUIP_LIMIT') )
    equipLvLimitLabel:setPosition(cc.p(self.width-5, 30))
    bgImg:addChild(equipLvLimitLabel)

    if self.isEquiped then -- 如果当前已经穿了装备
        equipedImg:setVisible(true)
        putOnBtn:setVisible(false)
        self.equipLvLimitLabel:setVisible(false)
    else
        equipedImg:setVisible(false)
    	--putOnBtn:setVisible(true)
        local roleObj = RoleData:getRoleByPos(self.rolePos)
         if UserData:getUserObj():getLv() < self.equipObj:getLevel()-10 then
            self.putOnBtn:setVisible(false)
            self.equipLvLimitLabel:setVisible(true)
        else
            self.putOnBtn:setVisible(true)
            self.equipLvLimitLabel:setVisible(false)
        end
    end

end

function RoleEquipSelectCell:SendPost(equipObj,isinherit,cost)
    cost = cost or 0
    if UserData:getUserObj():getGold() < cost then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'), COLOR_TYPE.RED)
        return
    end
    local args = {
        eid = self.equipObj:getSId(),
        pos = self.rolePos,
        inherit = isinherit
    }
    MessageMgr:sendPost("wear", "hero", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            if tonumber(isinherit) > 0 then
                local roleObj =RoleData:getRoleByPos(self.rolePos)
                local obj = roleObj:getEquipByIndex(self.equipObj:getType())
                if obj == nil then
                    return
                end
                self.equipObj:inheritGod(obj)
            end
            GlobalApi:parseAwardData(jsonObj.data.awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            RoleData:putOnEquip(self.rolePos, self.equipObj)
            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP_INFO, self.equipObj:getType())
            RoleMgr:updateRoleList()
            -- RoleMgr:updateRoleMainUI()
        end
    end)
end

function RoleEquipSelectCell:update(index,rolePos, equipObj, isEquiped)
    self.rolePos = rolePos
    local roleObj = RoleData:getRoleByPos(self.rolePos)
    self.isEquiped = isEquiped
    self.equipObj = equipObj
    local subAttrs = self.equipObj:getSubAttribute()
    local subAttrNum = self.equipObj:getSubAttrNum()
    local num = subAttrNum > 2 and subAttrNum or 2
    local godId = self.equipObj:getGodId()
    if godId > 0 then
        local godNum = godId == 3 and 2 or 1
        subAttrNum = subAttrNum + godNum
    end
    self.height = BASE_HEIGHT + subAttrNum*ATTR_HEIGHT
    self.bgImg:setContentSize(cc.size(self.width, self.height))

    ClassItemCell:updateItem(self.tab, self.equipObj, 1)

    self.node:setPosition(cc.p(60, self.height - 55))
    ClassItemCell:setGodLight(self.tab.awardBgImg, self.equipObj:getGodId())
    -- 等级
    self.equipLvLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
    self.equipLvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.equipLvLabel:setTextColor(self.equipObj:getNameColor())
    self.equipLvLabel:setString("Lv. " .. self.equipObj:getLevel() .. " " .. self.equipObj:getName())
    self.equipLvLabel:setPosition(cc.p(120, self.height - 25))
    -- 装备战斗力
    local fightforceStr = nil
    if self.isEquiped then
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIP_FIGHTFORCE") .. "：" .. self:getProFightForce()
    else
        fightforceStr = GlobalApi:getLocalStr("STR_EQUIPED_FIGHTFORCE") .. "：" .. self:getProFightForce()
    end
    self.newImg:setVisible(false)
    if index == 1 then
        local ishaveeq,canequip = roleObj:isHavebetterEquip(self.equipObj:getType())
        
        if ishaveeq and canequip then
            self.newImg:setVisible(true)
        end
    end
    self.newImg:setPosition(cc.p(self.width,self.height))
    self.fightforceLabel:setString(fightforceStr)
    self.fightforceLabel:setPosition(cc.p(120, self.height - 55))
    -- 主属性
    local mainAttribute = self.equipObj:getMainAttribute()
    local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
    self.attributeLabel1:setString(mainAttributeStr)
    self.attributeLabel1:setPosition(cc.p(120, self.height - 81))

    -- 副属性
    local subAttrIndex = 0
    for k, v in pairs(subAttrs) do
        subAttrIndex = subAttrIndex + 1
        local attributeLabel = self.attributeLabelArr[subAttrIndex]
        local subAttrStr = v.name .. "    +" .. v.value
        attributeLabel:enableOutline(self.equipObj:getNameOutlineColor(), 1)
        attributeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        attributeLabel:setTextColor(self.equipObj:getNameColor())
        attributeLabel:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        attributeLabel:setString(subAttrStr)
        attributeLabel:setVisible(true)
    end
    for i = subAttrIndex+1, 4 do
        self.attributeLabelArr[i]:setVisible(false)
    end
    -- 神器
    if godId > 0 then
        subAttrIndex = subAttrIndex + 1
        local godObj = clone(self.equipObj:getGodAttr())
        self.goldLabel1:setVisible(true)
        self.goldLabel1:setTextColor(COLOR_TYPE[godObj[1].color])
        self.goldLabel1:enableOutline(COLOROUTLINE_TYPE[godObj[1].color], 1)
        self.goldLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        self.goldLabel1:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
        if godObj[1].type == 1 then
            godObj[1].value = math.floor(godObj[1].value/100)
        end
        if godObj[1].double then
            self.goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value*2 .. "%")
        else
            self.goldLabel1:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
        end
        if godObj[2] then
            subAttrIndex = subAttrIndex + 1
            self.goldLabel2:setVisible(true)
            self.goldLabel2:setTextColor(COLOR_TYPE[godObj[2].color])
            self.goldLabel2:enableOutline(COLOROUTLINE_TYPE[godObj[2].color], 1)
            self.goldLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            self.goldLabel2:setPosition(cc.p(120, self.height - 81 - subAttrIndex*26))
            if godObj[2].type == 1 then
                godObj[2].value = math.floor(godObj[2].value/100)
            end
            if godObj[2].double then
                self.goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value*2 .. "%")
            else
                self.goldLabel2:setString(godObj[2].name .. " +" .. godObj[2].value .. "%")
            end
        else
            self.goldLabel2:setVisible(false)
        end
    else
        self.goldLabel1:setVisible(false)
        self.goldLabel2:setVisible(false)
    end
    self.equipLvLimitLabel:setString(GlobalApi:getLocalStr('STR_JUNZHU') .. (self.equipObj:getLevel()-10) ..GlobalApi:getLocalStr('EQUIP_LIMIT') )
    if self.isEquiped then -- 如果当前已经穿了装备
        self.equipedImg:setVisible(true)
        self.putOnBtn:setVisible(false)
        self.equipLvLimitLabel:setVisible(false)
    else
        self.equipedImg:setVisible(false)
        --self.putOnBtn:setVisible(true)
        if UserData:getUserObj():getLv() < self.equipObj:getLevel()-10 then
            self.putOnBtn:setVisible(false)
            self.equipLvLimitLabel:setVisible(true)
        else
            self.putOnBtn:setVisible(true)
            self.equipLvLimitLabel:setVisible(false)
        end
    end
    
    

end

function RoleEquipSelectCell:getPanel()
	return self.panel
end

function RoleEquipSelectCell:getSize()
	return self.width, self.height
end

function RoleEquipSelectCell:setPosition(pos)
	self.panel:setPosition(pos)
end
function RoleEquipSelectCell:getProFightForce()
    local fightforce = 0
    local attconf =GameData:getConfData('attribute')
    local roleObj = RoleData:getRoleByPos(self.rolePos)
    local obj = roleObj:getEquipByIndex(self.equipObj:getType())
    local equiatt = {}
    if obj and not self.isEquiped then
        local att = {}  
        for i=1,#attconf do
            att[i] = 0
            equiatt[i] = 0
        end
        equiatt = clone(self.equipObj:getAllAttr())
        for i=1,self.equipObj:getMaxGemNum() do
            local gemObj = obj:getGems()[i]
            if gemObj then
                local attrId = gemObj:getAttrId()
                att[attrId] = att[attrId] + gemObj:getValue()
            end
            local gemObj1 = self.equipObj:getGems()[i]
            if gemObj1 then
                local attrId = gemObj1:getAttrId()
                att[attrId] = att[attrId] - gemObj1:getValue()
            end
        end
        local godId = self.equipObj:getGodId()
        local godId1 = obj:getGodId()
        if godId == 0 and godId1 ~= 0 then
            local godAttr = clone(obj:getGodAttr())
            for k,v in pairs(godAttr) do
                if v.double then
                    att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)*2
                else
                    att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)
                end
            end
        end
        local attemp = {}
        for i=1,#attconf do
            attemp[i] = 0
            attemp[i] = equiatt[i]+att[i]
        end
        fightforce =self.equipObj:getFightForcePre(attemp)
    else
       fightforce = self.equipObj:getFightForce()
    end
    return fightforce
end
return RoleEquipSelectCell
