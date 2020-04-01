local EquipInheritUI = class("EquipInheritUI", BaseUI)
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
local ClassItemCell = require('script/app/global/itemcell')

function EquipInheritUI:ctor(equipObj)
    self.uiIndex = GAME_UI.UI_EQUIPONHERIT
    self.equipObj = equipObj
end

function EquipInheritUI:init()
    local equipInheritBgImg = self.root:getChildByName("equip_inherit_bg_img")
    local equipInheritAlphaImg = equipInheritBgImg:getChildByName("equip_inherit_alpha_img")
    self:adaptUI(equipInheritBgImg, equipInheritAlphaImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    equipInheritAlphaImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    -- local equipInheritImg = equipInheritAlphaImg:getChildByName("equip_inherit_img")
    local closeBtn = equipInheritAlphaImg:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        self:hideUI()
    end)

    local titleBgImg = equipInheritAlphaImg:getChildByName("title_img")
    local infoTx = titleBgImg:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr("TITLE_ZBCC"))
    
    local equipBgImg = equipInheritAlphaImg:getChildByName("equip_bg_img")
    local infoLabel1 = equipBgImg:getChildByName("info_tx_1")
    local infoLabel2 = equipBgImg:getChildByName("info_tx_2")
    infoLabel1:setString(GlobalApi:getLocalStr("GODDESC"))
    infoLabel2:setString(GlobalApi:getLocalStr("GODDESC2"))

    local equipIconNode = equipBgImg:getChildByName("equip_icon_node")
    local equipCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode:addChild(equipCell.awardBgImg)
    self.equipCell = equipCell

    local equipIconNode2 = equipBgImg:getChildByName("equip_icon_node2")
    local equipCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode2:addChild(equipCell2.awardBgImg)
    self.equipCell2 = equipCell2

    self.refineGoldImg = equipBgImg:getChildByName("refine_gold_img")
    self.refineTx = self.refineGoldImg:getChildByName("refine_tx")
    self.refineTx1 = self.refineGoldImg:getChildByName("refine_tx_1")
    self.refineTx2 = self.refineGoldImg:getChildByName("refine_tx_2")
    self.equipCell2.awardBgImg:setTouchEnabled(true)
    self.equipCell2.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.equipObj == nil then
                return
            end
            local equipSelectUI = ClassEquipSelectUI.new(nil, {}, 0, self.equipObj:getType(), 2, 0, function (map)
                local index = next(map)
                if index then
                    self.selectedEquip = map[index]
                else
                    self.selectedEquip = nil
                end
                return true
            end)
            equipSelectUI:showUI()
        end
    end)

    -- 传承
    self.inheritBtn = equipBgImg:getChildByName("inherit_btn")
    local inheritLabel = self.inheritBtn:getChildByName("func_tx")
    inheritLabel:setString(GlobalApi:getLocalStr("INHERIT"))
    self.inheritBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.selectedEquip then
                if self.enoughGold then
                    local args = {
                        from = self.equipObj:getSId(),
                        to = self.selectedEquip:getSId()
                    }
                    MessageMgr:sendPost("inherit", "equip", json.encode(args), function (jsonObj)
                        print(json.encode(jsonObj))
                        local code = jsonObj.code
                        if code == 0 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr("INHERIT_SUCCESS"), COLOR_TYPE.GREEN)
                            self.selectedEquip:inheritGod(self.equipObj)
                            GlobalApi:parseAwardData(jsonObj.data.awards)
                            local pos = self.selectedEquip:getPos()
                            if pos > 0 then
                                local partLv = RoleData:getRoleByPos(pos):getPartInfoByPos(tostring(self.selectedEquip:getType())).level
                                self.selectedEquip:activateGodByPart(partLv)
                            end
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            if self.selectedEquip:getPos() > 0 then
                                local roleobj = RoleData:getRoleByPos(self.selectedEquip:getPos())
                                roleobj:setFightForceDirty(true)
                                RoleMgr:popupTips(roleobj)
                            end
                            self:hideUI()
                        end
                    end)
                else
                    -- 金币不足
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("NEED_SELECT_EQUIP_FIRST"), COLOR_TYPE.RED)
            end
        end
    end)
    self:updateUI()
end

function EquipInheritUI:onShow()
    self:updateUI()
end

function EquipInheritUI:updateUI()
    local equipObj = self.equipObj
    local godLevel = equipObj:getGodLevel()
    if self.selectedEquip then
        self.refineGoldImg:setVisible(true)
    else
        self.refineGoldImg:setVisible(false)
    end
    local needGold = 0
    local currGold = UserData:getUserObj():getGold()
    if self.selectedEquip then
        needGold = -self.selectedEquip:getInheritCost()
    end
    if currGold < needGold then
        self.enoughGold = false
    else
        self.enoughGold = true
    end

    ClassItemCell:updateItem(self.equipCell, equipObj, 1)

    local gold = UserData:getUserObj():getGold()
    if self.selectedEquip then
        self.equipCell2.awardImg:setVisible(true)
        ClassItemCell:updateItem(self.equipCell2, self.selectedEquip, 1)
        local refineCost = -self.selectedEquip:getInheritCost()
        self.refineTx:setString(GlobalApi:toWordsNumber(-self.selectedEquip:getInheritCost()))
        if refineCost <= gold then
            self.refineTx2:setTextColor(cc.c3b(255,255,255))
        else
            self.refineTx2:setTextColor(cc.c3b(255,0,0))
        end
    else
        self.equipCell2.awardBgImg:loadTexture(COLOR_FRAME[1])
        self.equipCell2.awardImg:setVisible(false)
    end

    local oPosX, oPosY = self.refineTx:getPosition()
    local refineTxSize = self.refineTx:getContentSize()
    local refineTxSize1 = self.refineTx1:getContentSize()
    
    local nPosX = oPosX+refineTxSize.width
    self.refineTx1:setPositionX(nPosX)

    nPosX = nPosX + refineTxSize1.width
    self.refineTx2:setPositionX(nPosX)    

    GlobalApi:runNum(self.refineTx2,'Text','roleequipinfoui',self.oldNum,gold)
    self.oldNum = gold
end

return EquipInheritUI