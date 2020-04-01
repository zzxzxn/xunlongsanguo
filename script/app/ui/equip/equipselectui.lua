local ClassEquipSelectCell = require("script/app/ui/equip/equipselectcell")

local EquipSelectUI = class("EquipSelectUI", BaseUI)

local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

local function sortByQuality(arr, ruleType,lv)
    if ruleType == 2 then
        table.sort(arr, function (a, b)
            local lv1 = a:canEquip(lv)
            local lv2 = b:canEquip(lv)
            if lv1 == lv2 then
                local q1 = a:getFightForce()
                local q2 = b:getFightForce()
                if q1 == q2 then
                    local f1 = a:getQuality()
                    local f2 = b:getQuality()
                    if f1 == f2 then
                        local id1 = a:getId()
                        local id2 = b:getId()
                        return id1 > id2
                    else
                        return f1 > f2
                    end
                else
                    return q1 > q2
                end
            else
                return lv1 < lv2
            end
        end)
    else
        table.sort(arr, function (a, b)
            local q1 = a:getFightForce()
            local q2 = b:getFightForce()
            if q1 == q2 then
                local l1 = a:getLevel()
                local l2 = b:getLevel()
                if l1 == l2 then
                    local f1 = a:getQuality()
                    local f2 = b:getQuality()
                    if f1 == f2 then
                        local id1 = a:getId()
                        local id2 = b:getId()
                        return id1 > id2
                    else
                        return f1 < f2
                    end
                else
                    return l1 < l2
                end
            else
                return q1 < q2
            end
        end)
    end
end

-- selectEquipArr: 已经选择了的装备
-- maxNum：可以选择的最大数量 0表示单选
-- equipType: 1-6 对应6个部位，0表示选择全部的装备
-- ruleType：筛选规则 0：全部显示 1：只显示所有神器，2：只显示所有非神器 3:不显示远古装备,不显示神器 4：所有神器不包括双属性神器 
-- lvLimit：等级要求
-- callback：回调
function EquipSelectUI:ctor(roleobj,selectEquipArr, maxNum, equipType, ruleType, lvLimit, callback, sortType)
    self.uiIndex = GAME_UI.UI_EQUIPSELECT
    self.callback = callback
    self.selectEquipArr = selectEquipArr
    self.maxNum = maxNum
    self.equipType = equipType
    self.ruleType = ruleType
    self.sortType = sortType
    self.roleobj = roleobj
    self.lvLimit = lvLimit == 0 and 100000000 or lvLimit
end

function EquipSelectUI:init()
    local selectEquipArr = {}
    self.selectEquipArr2 = selectEquipArr
    local selectEquipNum = 0
    local equipSelectBgImg = self.root:getChildByName("equip_select_bg_img")
    local equipSelectImg = equipSelectBgImg:getChildByName("equip_select_img")
    self.panel = equipSelectImg
    self:adaptUI(equipSelectBgImg, equipSelectImg)
    local bgimg1 = equipSelectImg:getChildByName('bg_img1')
    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('EQUIPLIST'))
    local closeBtn = equipSelectImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.maxNum > 0 then -- 非单选
                if self.callback then
                    self.callback(selectEquipArr)
                end
            end
            self:hideUI()
        end
    end)
    equipSelectBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.maxNum > 0 then -- 非单选
                if self.callback then
                    self.callback(selectEquipArr)
                end
            end
            self:hideUI()
        end
    end)
    local listview = bgimg1:getChildByName("equip_sv")  -- 其实是scrollview，这里难得改名字了
    listview:setScrollBarEnabled(false)
    self.listview = listview
    local svSize = listview:getContentSize()
    self.posY = self.listview:getPositionY()

    self.svSize = svSize -- 最原始的大小

    self.noequipimg = bgimg1:getChildByName('noequipimg')
    local equips = {}
    local equips2 = {}
    local equips3 = {}
    local equipNum = 0
    local equipNum2 = 0
    local equipNum3 = 0
    if self.equipType == 0 then -- 选择全部装备
        local equipMap = BagData:getAllEquips()
        if self.ruleType == 1 then
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() ~= 0 and v2:getLevel() <= self.lvLimit then
                        if self.selectEquipArr[v2:getSId()] then
                            selectEquipArr[v2:getSId()] = v2
                            selectEquipNum = selectEquipNum + 1
                            table.insert(equips2, v2)
                            equipNum2 = equipNum2 + 1
                        else
                            table.insert(equips3, v2)
                            equipNum3 = equipNum3 + 1
                        end
                        equipNum = equipNum + 1
                    end
                end
            end
        elseif self.ruleType == 2 then
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() == 0  then
                        if self.selectEquipArr[v2:getSId()] then
                            selectEquipArr[v2:getSId()] = v2
                            selectEquipNum = selectEquipNum + 1
                            table.insert(equips2, v2)
                            equipNum2 = equipNum2 + 1
                        else
                            table.insert(equips3, v2)
                            equipNum3 = equipNum3 + 1
                        end
                        equipNum = equipNum + 1
                    end
                end
            end
        elseif self.ruleType == 3 then
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() == 0 and not v2:isAncient() then
                        if self.selectEquipArr[v2:getSId()] then
                            selectEquipArr[v2:getSId()] = v2
                            selectEquipNum = selectEquipNum + 1
                            table.insert(equips2, v2)
                            equipNum2 = equipNum2 + 1
                        else
                            table.insert(equips3, v2)
                            equipNum3 = equipNum3 + 1
                        end
                        equipNum = equipNum + 1
                    end
                end
            end
        elseif self.ruleType == 4 then
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() ~= 0 and v2:getGodId() ~= 3 and v2:getLevel() <= self.lvLimit then
                        if self.selectEquipArr[v2:getSId()] then
                            selectEquipArr[v2:getSId()] = v2
                            selectEquipNum = selectEquipNum + 1
                            table.insert(equips2, v2)
                            equipNum2 = equipNum2 + 1
                        else
                            table.insert(equips3, v2)
                            equipNum3 = equipNum3 + 1
                        end
                        equipNum = equipNum + 1
                    end
                end
            end
        elseif self.ruleType == 0 then
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getLevel() <= self.lvLimit then
                        if self.selectEquipArr[v2:getSId()] then
                            selectEquipArr[v2:getSId()] = v2
                            selectEquipNum = selectEquipNum + 1
                            table.insert(equips2, v2)
                            equipNum2 = equipNum2 + 1
                        else
                            table.insert(equips3, v2)
                            equipNum3 = equipNum3 + 1
                        end
                        equipNum = equipNum + 1
                    end
                end
            end
        end
    else -- 选择某一种装备
        local equipMap = BagData:getEquipMapByType(self.equipType)
        if self.ruleType == 1 then
            for k, v in pairs(equipMap) do
                if v:getGodId() ~= 0 and v:getLevel() <= self.lvLimit then
                    if self.selectEquipArr[v:getSId()] then
                        selectEquipArr[v:getSId()] = v
                        selectEquipNum = selectEquipNum + 1
                        table.insert(equips2, v)
                        equipNum2 = equipNum2 + 1
                    else
                        table.insert(equips3, v)
                        equipNum3 = equipNum3 + 1
                    end
                    equipNum = equipNum + 1
                end
            end
        elseif self.ruleType == 2 then
            local maxNum = RoleData:getRoleNum()
            for i=1,maxNum do
                local obj = RoleData:getRoleByPos(i)
                if self.roleobj then
                    local pos = self.roleobj:getPosId()
                    if i ~= pos and obj and obj ~= 0 then
                        local equip = obj:getEquipByIndex(self.equipType)
                        if equip and equip:getGodId() == 0 then
                            equip.name = obj:getName()
                            table.insert(equips3, equip)
                            equipNum3 = equipNum3 + 1
                            equipNum = equipNum + 1
                        end
                    end
                else
                    if obj and obj ~= 0 then
                        local equip = obj:getEquipByIndex(self.equipType)
                        if equip and equip:getGodId() == 0 then
                            equip.name = obj:getName()
                            table.insert(equips3, equip)
                            equipNum3 = equipNum3 + 1
                            equipNum = equipNum + 1
                        end
                    end
                end
            end

            for k, v in pairs(equipMap) do
                if v:getGodId() == 0  then
                    if self.selectEquipArr[v:getSId()] then
                        selectEquipArr[v:getSId()] = v
                        selectEquipNum = selectEquipNum + 1
                        table.insert(equips2, v)
                        equipNum2 = equipNum2 + 1
                    else
                        table.insert(equips3, v)
                        equipNum3 = equipNum3 + 1
                    end
                    equipNum = equipNum + 1
                end
            end
         elseif self.ruleType == 3 then
            for k, v in pairs(equipMap) do
                if v:getGodId() == 0 and not v:isAncient() then
                    if self.selectEquipArr[v:getSId()] then
                        selectEquipArr[v:getSId()] = v
                        selectEquipNum = selectEquipNum + 1
                        table.insert(equips2, v)
                        equipNum2 = equipNum2 + 1
                    else
                        table.insert(equips3, v)
                        equipNum3 = equipNum3 + 1
                    end
                    equipNum = equipNum + 1
                end
            end
        elseif self.ruleType == 4 then
            for k, v in pairs(equipMap) do
                if v:getGodId() ~= 0 and v:getGodId() ~= 3 and v:getLevel() <= self.lvLimit then
                    if self.selectEquipArr[v:getSId()] then
                        selectEquipArr[v:getSId()] = v
                        selectEquipNum = selectEquipNum + 1
                        table.insert(equips2, v)
                        equipNum2 = equipNum2 + 1
                    else
                        table.insert(equips3, v)
                        equipNum3 = equipNum3 + 1
                    end
                    equipNum = equipNum + 1
                end
            end
        elseif self.ruleType == 0 then
            for k, v in pairs(equipMap) do
                if v:getLevel() <= self.lvLimit then
                    if self.selectEquipArr[v:getSId()] then
                        selectEquipArr[v:getSId()] = v
                        selectEquipNum = selectEquipNum + 1
                        table.insert(equips2, v)
                        equipNum2 = equipNum2 + 1
                    else
                        table.insert(equips3, v)
                        equipNum3 = equipNum3 + 1
                    end
                    equipNum = equipNum + 1
                end
            end
        end

    end
    local offsetH = 0
    if self.maxNum <= 0 then -- 单选
        --print('4444444444444444444444444444')
        local equipIndex = next(self.selectEquipArr)
        if equipIndex then -- 已经装备了一件装备
            local equipObj = self.selectEquipArr[equipIndex]
            local equipedCell = ClassEquipSelectCell.new(self.roleobj,0,svSize.width, equipObj, false)
            equipedCell:setCheckBoxVisible(false)
            equipedCell:setEquiped()
            local panel = equipedCell:getPanel()
            local w, h = equipedCell:getSize()
            panel:setPosition(cc.p(self.listview:getPositionX() + svSize.width/2,svSize.height - h*0.5 + self.posY))
            bgimg1:addChild(panel)
            offsetH = h + 4
        end
    end
    local lv = UserData:getUserObj():getLv() + 10
    -- if self.roleobj then
    --     lv = self.roleobj:getLevel()
    -- end

    self.listview:setContentSize(cc.size(svSize.width,svSize.height - offsetH))
    self.listview:setPositionY(self.posY)

    self.viewSize = self.listview:getContentSize() -- 可视区域的大小

    self.equips = equips
    if equipNum > 0 then
        if equipNum2 > 0 then
            sortByQuality(equips2, self.sortType or self.ruleType,lv)
        end
        if equipNum3 > 0 then
            sortByQuality(equips3, self.sortType or self.ruleType,lv)
        end
        for i = 1, equipNum2 do
            table.insert(equips, equips2[i])
        end
        for i = 1, equipNum3 do
            table.insert(equips, equips3[i])
        end
        self:initListView()
        self.noequipimg:setVisible(false)
    else
        self.noequipimg:setVisible(true)
    end

    self.selectEquipNum = selectEquipNum
end

function EquipSelectUI:initListView()
    --print('====allNum=====' .. #self.equips)
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.equips
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    ScrollViewGeneral.new(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)

end


function EquipSelectUI:initItemData(index)
    if self.equips[index] then
        local equips = self.equips
        local equipObj = equips[index]

        local subAttrNum = equipObj:getSubAttrNum()
        local godId = equipObj:getGodId()
        if godId > 0 then
            local godNum = godId == 3 and 2 or 1
            subAttrNum = subAttrNum + godNum
        end
        local w = self.viewSize.width
        local h = 110 + subAttrNum*26
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function EquipSelectUI:addItem(tempCellData,widgetItem)
    if self.equips[tempCellData.index] then
        local equips = self.equips
        local index = tempCellData.index

        local sid = equips[index]:getSId()
        local selectedFlag = false
        if self.selectEquipArr2[sid] then
            selectedFlag = true
        end

        local cell = ClassEquipSelectCell.new(self.roleobj,index,self.viewSize.width, equips[index], selectedFlag)

        if self.maxNum <= 0 then
            cell:setCheckBoxVisible(false)
            cell:setSelectCallBack(function (selected)
                self.selectEquipArr2[sid] = equips[index]
                    if self.callback then
                    local flag = self.callback(self.selectEquipArr2)
                    if flag then
                        self:hideUI()
                    end
                else
                    self:hideUI()
                end
            end)
        else
            cell:setSelectCallBack(function (selected)
                if self.selectEquipNum >= self.maxNum and selected then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("EQUIP_SELECT_INFO_1"), self.maxNum), COLOR_TYPE.RED)
                    return false
                end
                if selected then
                    self.selectEquipArr2[sid] = equips[index]
                    self.selectEquipNum = self.selectEquipNum + 1
                else
                    if self.selectEquipArr2[sid] then
                        self.selectEquipArr2[sid] = nil
                        self.selectEquipNum = self.selectEquipNum - 1
                    end
                end
                return true
            end)
        end

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell:getPanel())
        cell:getPanel():setPosition(cc.p(w*0.5,h*0.5))
    end
end

return EquipSelectUI