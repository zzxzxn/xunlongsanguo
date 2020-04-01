local EquipDismantlingUI = class("EquipDismantlingUI", BaseUI)
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
local ClassItemCell = require('script/app/global/itemcell')

function EquipDismantlingUI:ctor(equipObj)
    self.uiIndex = GAME_UI.UI_EQUIP_DISMANTLING
    self.equipObj = equipObj
end

function EquipDismantlingUI:init()
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
    infoTx:setString(GlobalApi:getLocalStr("TITLE_ZBCJ"))
    
    local equipBgImg = equipInheritAlphaImg:getChildByName("equip_bg_img")
    local infoLabel1 = equipBgImg:getChildByName("info_tx_1")
    local infoLabel2 = equipBgImg:getChildByName("info_tx_2")
    infoLabel1:setString(GlobalApi:getLocalStr("DISMANTLING_DESC"))


    local equipIconNode = equipBgImg:getChildByName("equip_icon_node")
    local equipCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode:addChild(equipCell.awardBgImg)
    self.equipCell = equipCell
    self.nameTx1 = equipIconNode:getChildByName("name_tx")

    local equipIconNode2 = equipBgImg:getChildByName("equip_icon_node2")
    local equipCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode2:addChild(equipCell2.awardBgImg)
    self.equipCell2 = equipCell2
    self.nameTx2 = equipIconNode2:getChildByName("name_tx")
    
    self.refineGoldImg = equipBgImg:getChildByName("refine_gold_img")
    self.refineTx2 = self.refineGoldImg:getChildByName("refine_tx")
    local refineTx = self.refineGoldImg:getChildByName("refine_tx_2")
    refineTx:setString(GlobalApi:getLocalStr("ATLAR_DESC2"))

    -- 传承
    self.inheritBtn = equipBgImg:getChildByName("inherit_btn")
    local inheritLabel = self.inheritBtn:getChildByName("func_tx")
    inheritLabel:setString(GlobalApi:getLocalStr("TITLE_ZBCJ"))
    self.inheritBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.enoughGold then
                local args = {
                    sid = self.equipObj:getSId(),
                }
                MessageMgr:sendPost("dismantling", "equip", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        -- promptmgr:showSystenHint(GlobalApi:getLocalStr("INHERIT_SUCCESS"), COLOR_TYPE.GREEN)
                        -- self.selectedEquip:inheritGod(self.equipObj)
                        GlobalApi:parseAwardData(jsonObj.data.awards)
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        GlobalApi:showAwardsCommon(jsonObj.data.awards,nil,nil,true)
                        self:hideUI()
                    end
                end)
            else
                -- 金币不足
                promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
            end
        end
    end)
    self:updateUI()
end

function EquipDismantlingUI:onShow()
    self:updateUI()
end

function EquipDismantlingUI:updateUI()
    local equipObj = self.equipObj
    local godLevel = equipObj:getGodLevel()
    local needGold = equipObj:getDismantlingCost()
    local currGold = UserData:getUserObj():getGold()
    if currGold < needGold then
        self.enoughGold = false
    else
        self.enoughGold = true
    end
    ClassItemCell:updateItem(self.equipCell, equipObj, 1)
    self.nameTx1:setString('Lv. '..equipObj:getLevel()..' '..equipObj:getName())

    local awards = equipObj:getDismantlingAward()
    local award = DisplayData:getDisplayObj(awards[1])
    ClassItemCell:updateItem(self.equipCell2, award, 1)
    local equipId = award:getUseEffect()
    local newEquipObj = DisplayData:getDisplayObj({'equip',equipId,0,1})
    self.nameTx2:setString('Lv. '..newEquipObj:getLevel()..' '..award:getName())
    if self.enoughGold then
        self.refineTx2:setTextColor(cc.c3b(255,255,255))
    else
        self.refineTx2:setTextColor(cc.c3b(255,0,0))
    end
    self.refineTx2:setString(needGold)
end

return EquipDismantlingUI