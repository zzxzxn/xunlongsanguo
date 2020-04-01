local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")

local RoleEquipInheritUI = class("RoleEquipInheritUI", ClassRoleBaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function RoleEquipInheritUI:ctor()
    self.super.ctor(self)
    self.equipObj = nil
    self.selectedEquip = nil
    self.enoughGold = true
end

function RoleEquipInheritUI:initPanel()
    self.panel = cc.CSLoader:createNode("csb/roleequipinheritpanel.csb")
    local equipBgImg = self.panel:getChildByName("equip_bg_img")
    local infoLabel1 = equipBgImg:getChildByName("info_tx_1")
    local infoLabel2 = equipBgImg:getChildByName("info_tx_2")
    infoLabel1:setString(GlobalApi:getLocalStr("GODDESC"))
    infoLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    infoLabel2:setString(GlobalApi:getLocalStr("GODDESC2"))
    infoLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    local equipIconNode = equipBgImg:getChildByName("equip_icon_node")
    self.tab1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode:addChild(self.tab1.awardBgImg)
    self.tab1.awardImg:ignoreContentAdaptWithSize(true)
    local equipIconNode2 = equipBgImg:getChildByName("equip_icon_node2")
    self.tab2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode2:addChild(self.tab2.awardBgImg)
    self.tab2.awardImg:ignoreContentAdaptWithSize(true)
    self.refineGoldImg = equipBgImg:getChildByName("refine_gold_img")
    self.refineTx = self.refineGoldImg:getChildByName("refine_tx")
    self.refineTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.refineTx1 = self.refineGoldImg:getChildByName("refine_tx_1")
    self.refineTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.refineTx2 = self.refineGoldImg:getChildByName("refine_tx_2")
    self.refineTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.tab2.awardBgImg:setTouchEnabled(true)
    self.tab2.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.equipObj == nil then
                return
            end
            local roleobj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
            local equipSelectUI = ClassEquipSelectUI.new(roleobj, {}, 0, self.equipObj:getType(), 2, 0, function (map)
                local index = next(map)
                if index then
                    self.selectedEquip = map[index]
                else
                    self.selectedEquip = nil
                end
                RoleMgr:setDirty("RoleMainUI", true)
                return true
            end)
            equipSelectUI:showUI()
        end
    end)

    -- 传承
    --local swallowGoldImg = equipBgImg:getChildByName("swallow_gold_img")
    --self.swallowLabel = swallowGoldImg:getChildByName("swallow_tx")
    self.inheritBtn = equipBgImg:getChildByName("inherit_btn")
    local inheritLabel = self.inheritBtn:getChildByName("func_tx")
    inheritLabel:setString(GlobalApi:getLocalStr("INHERIT"))
    self.inheritBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
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
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            local roleobj = RoleData:getRoleByPos(self.equipObj:getPos())
                            roleobj:setFightForceDirty(true)
                            RoleMgr:popupTips(roleobj)
                            -- if self.selectedEquip:getPos() > 0 then
                            --     local roleobj2 = RoleData:getRoleByPos(self.selectedEquip:getPos())
                            --     roleobj2:setFightForceDirty(true)
                            --     RoleMgr:popupTips(roleobj2)
                            -- end
                            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, self.equipPos, true)
                        end
                    end)
                else
                    -- 金币不足
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
                    --self.swallowLabel:stopAllActions()
                    --self.swallowLabel:setScale(1)
                    --self.swallowLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 2), cc.ScaleTo:create(0.1, 1)))
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("NEED_SELECT_EQUIP_FIRST"), COLOR_TYPE.RED)
            end
        end
    end)
end

function RoleEquipInheritUI:update(roleObj, equipPos)
    self.equipPos = equipPos
    local equipObj = roleObj:getEquipByIndex(equipPos)
    if equipObj == nil then
        return
    end
    self.equipObj = equipObj
    if self.equipObj:getGodId() <= 0 then
        RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP_INFO, equipPos, true)
        return
    end
    self:updateUI()
end

function RoleEquipInheritUI:updateUI()
    local equipObj = self.equipObj
    local godLevel = equipObj:getGodLevel()
    if self.selectedEquip then
        self.refineGoldImg:setVisible(true)
    else
        self.refineGoldImg:setVisible(false)
    end
    --self.swallowLabel:stopAllActions()
    --self.swallowLabel:setScale(1)
    local needGold = 0
    local currGold = UserData:getUserObj():getGold()
    if self.selectedEquip then
        needGold = -self.selectedEquip:getInheritCost()
    end
    if currGold < needGold then
        self.enoughGold = false
        --self.swallowLabel:setTextColor(COLOR_TYPE.RED)
    else
        self.enoughGold = true
        --self.swallowLabel:setTextColor(COLOR_TYPE.WHITE)
    end
    ClassItemCell:updateItem(self.tab1, equipObj, 1)

    local gold = UserData:getUserObj():getGold()
    if self.selectedEquip then
        ClassItemCell:updateItem(self.tab2, self.selectedEquip, 1)
        local refineCost = -self.selectedEquip:getInheritCost()
        self.refineTx:setString(GlobalApi:toWordsNumber(-self.selectedEquip:getInheritCost()))
        if refineCost <= gold then
            self.refineTx2:setTextColor(cc.c3b(255,255,255))
        else
            self.refineTx2:setTextColor(cc.c3b(255,0,0))
        end
    else
        self.tab2.awardImg:loadTexture(DEFAULTEQUIP[3])
        self.tab2.awardBgImg:loadTexture(COLOR_ITEMFRAME.DEFAULT)
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

function RoleEquipInheritUI:onMoveOut()
    self.selectedEquip = nil
end

return RoleEquipInheritUI