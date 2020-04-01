local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemObj = require('script/app/obj/gemobj')
local RoleEquipInfoUI = class("RoleEquipInfoUI", ClassRoleBaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local MAXEQUIPSTARLV = 15

function RoleEquipInfoUI:ctor()
	self.super.ctor(self)
	self.equipPos = -1
	self.roleObj = nil
    self.equipObj = nil
    self.lockNum = 0
    self.maxAttr = 0

    self.topTxHeight = 30 + 30
    self.centerTxHeight = 30
    self.bottomTxHeight = 30

    self.centerNotAttHeight = 40
    self.bottomNotAttHeight = 0

end

function RoleEquipInfoUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roleequipinfopanel.csb")
	self.equipBgImg = self.panel:getChildByName("equip_bg_img")
    self.godequipSv = self.equipBgImg:getChildByName("godequip_sv")
    self.godequipSv:setScrollBarEnabled(false)
    --self.svSize = self.godequipSv:getContentSize()
    self.svSize = self.godequipSv:getInnerContainerSize()
    self.contentWidget = self.godequipSv:getChildByName("content_widget")
    self.equipIconNode = self.contentWidget:getChildByName("equip_icon_node")
    self.tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    self.equipIconNode:addChild(self.tab.awardBgImg)

	self.equipLvLabel = self.contentWidget:getChildByName("equip_lv_tx")
	self.fightforceLabel = self.contentWidget:getChildByName("fightforce_tx")
    self.fightforceStrengthenLabel = self.contentWidget:getChildByName("fightforce_strengthen")
    self.fightforceStrengthenLabel:setString(GlobalApi:getLocalStr('STR_YU2'))

    self.fightforceStrengthenLvLabel = self.contentWidget:getChildByName("fightforce_strengthen_lv")
    self.fightforceStrengthenLvLabel:setString('Lv.' .. 0)

    self.fightforceStrengthenBtn = self.contentWidget:getChildByName("equip_strengthen_btn")
    self.fightforceStrengthenBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('STR_YU3'))
    self.fightforceStrengthenBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local isOpen,_,cityId,level = GlobalApi:getOpenInfo("legionTrial")
            if not isOpen then
                if cityId then
                    local cityData = MapData.data[cityId]
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..
                        cityData:getName()..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
                    return
                end
                if level then
                    promptmgr:showSystenHint(level..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'), COLOR_TYPE.RED)
                    return
                end
            end
            RoleMgr:showEquipRefine(self.roleObj:getPosId(),self.equipPos)
        end
    end)

	-- 主属性
	self.attributeLabel1 = self.contentWidget:getChildByName("attribute_tx_1")
	-- 副属性
	self.attributeLabel2 = self.contentWidget:getChildByName("attribute_tx_2")
	self.attributeLabel3 = self.contentWidget:getChildByName("attribute_tx_3")
	self.attributeLabel4 = self.contentWidget:getChildByName("attribute_tx_4")
	self.attributeLabel5 = self.contentWidget:getChildByName("attribute_tx_5")
    -- 锁
    self.lockImg1 = self.contentWidget:getChildByName("lock_img_1")
    self.lockImg2 = self.contentWidget:getChildByName("lock_img_2")
    self.lockImg3 = self.contentWidget:getChildByName("lock_img_3")
    self.lockImg4 = self.contentWidget:getChildByName("lock_img_4")
    for i=1,4 do
        self['lockImg'..i]:setOpacity(127.5)
    end

    -- 添加的属性说明描述
    self.topTx = self.contentWidget:getChildByName("top_tx")
    self.topTx:setString(GlobalApi:getLocalStr('STR_ROLELIST_DES_1'))

    self.centerTx = self.contentWidget:getChildByName("center_tx")
    self.centerTx:setString(GlobalApi:getLocalStr('STR_ROLELIST_DES_2'))
    self.centerNotAtt = self.contentWidget:getChildByName("center_not_att")
    self.centerNotAtt:setString(GlobalApi:getLocalStr('STR_ROLELIST_DES_4'))
    self.lineCenter1 = self.contentWidget:getChildByName("line_center_1")
    self.lineCenter2 = self.contentWidget:getChildByName("line_center_2")

    self.bottomTx = self.contentWidget:getChildByName("bottom_tx")
    self.bottomTx:setString(GlobalApi:getLocalStr('STR_ROLELIST_DES_3'))
    self.bottomNotAtt = self.contentWidget:getChildByName("bottom_not_att")
    self.bottomNotAtt:setString(GlobalApi:getLocalStr('STR_ROLELIST_DES_4'))
    self.lineBottom1 = self.contentWidget:getChildByName("line_bottom_1")
    self.lineBottom2 = self.contentWidget:getChildByName("line_bottom_2")

    local pl = self.contentWidget:getChildByName("pl")
    pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_EQUIP_DESC_1'), COLOR_TYPE.RED)
        end
    end)
    --最大值
    self.maxattlabel = {}
    for i = 1, 4 do
        local maxlabel = self.contentWidget:getChildByName("max_tx_"..i)
        self.maxattlabel[i] = maxlabel
    end
    self.gemArr = {}
	-- 宝石
	for i = 1, 4 do
        local gemTable = {}
        local gemBg = self.contentWidget:getChildByName("gem_bg_1_" .. i)
        local gemIcon = gemBg:getChildByName("gem_icon")
        local gemLvLabel = gemBg:getChildByName("gem_lv_tx")
        local upImg = gemBg:getChildByName("up_img")
        gemTable["gemBg"] = gemBg
        gemTable["gemIcon"] = gemIcon
        gemTable["gemLvLabel"] = gemLvLabel
        gemTable["upImg"] = upImg
        self.gemArr[i] = gemTable
		gemBg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local isOpen = GlobalApi:getOpenInfo('gem')
                if not isOpen then
                    return false
                end
        		local equipObj = self.roleObj:getEquipByIndex(self.equipPos)
				if equipObj then
                    local gems = equipObj:getGems()
                    if gems[i] then -- 已经有宝石了
                        RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_GEM, self.equipPos,true)
                    else
                        local gemSelectUI = ClassGemSelectUI.new(i, equipObj, function ()
                            self.roleObj:setFightForceDirty(true)
                            RoleMgr:updateRoleMainUI()
                            RoleMgr:updateRoleList()
                        end)
                        gemSelectUI:showUI()
                    end
				end
	        end
	    end)
	end
	-- 神器属性
	self.godEquipBg = self.contentWidget:getChildByName("godequip_bg")
    self.upgradeBtn = self.godEquipBg:getChildByName("upgrade_btn")
    local upgradeLabel = self.upgradeBtn:getChildByName("func_tx")
    upgradeLabel:setString(GlobalApi:getLocalStr('STR_UPGRADE_STAR'))
    self.starNode = self.godEquipBg:getChildByName("star_node")

    self.line1 = self.godEquipBg:getChildByName("line_1")
    -- 升星
    self.upgradeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            local desc,isOpen = GlobalApi:getGotoByModule('godupgrade',true)
            if desc then
                local tx1,tx2
                if isOpen == 1 then
                    tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
                    tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
                else
                    tx1 = ''
                    tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
                end
                promptmgr:showSystenHint(tx1..desc..tx2, COLOR_TYPE.RED)
                return
            end
            RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_UPGRADE_STAR, self.equipPos)
            RoleMgr:swapChildName(ROLEPANELTYPE.UI_UPGRADE_STAR)
        end
    end)

    self.godNode = self.godEquipBg:getChildByName("god_node")
    self.godInfoTxArr = {}
    for i = 1, 10 do
        local godEquipInfoTx = self.godNode:getChildByName("godequip_info_tx_" .. i)
        self.godInfoTxArr[i] = godEquipInfoTx
    end

    self.godStar = {}
    for i = 1, 10 do
        local starBg = self.starNode:getChildByName("star_bg_" .. i)
        local starImg = starBg:getChildByName("star_img")
        self.godStar[i] = starImg
    end
    self.gemNode = self.godEquipBg:getChildByName("gem_node")
    self.gemInfoArr = {}
    for i = 1, 4 do
        local gemInfo = {}
        gemInfo.bg = self.gemNode:getChildByName("gem_bg_" .. i)
        gemInfo.tx = self.gemNode:getChildByName("gem_tx_" .. i)
        self.gemInfoArr[i] = gemInfo
    end

	local changeBtn = self.equipBgImg:getChildByName("change_btn")
    local changeBtntx = changeBtn:getChildByName('func_tx')
    local equipGemBtn = self.contentWidget:getChildByName("equip_gem_btn")
    local equipGemBtnTx = equipGemBtn:getChildByName('func_tx')
    equipGemBtnTx:setString(GlobalApi:getLocalStr('AUTO_FILL'))
    self.info = changeBtn:getChildByName('info_img')
    self.info:setVisible(false)
    changeBtntx:setString(GlobalApi:getLocalStr('EXCHANGE'))
	self.inheritBtn = self.equipBgImg:getChildByName("inherit_btn")
    self.inheritBtntx = self.inheritBtn:getChildByName('func_tx')
    self.inheritBtntx:setString(GlobalApi:getLocalStr('INHERIT'))
	local dischargeBtn = self.equipBgImg:getChildByName("discharge_btn")
    local dischargeBtntx = dischargeBtn:getChildByName('func_tx')
    dischargeBtntx:setString(GlobalApi:getLocalStr('DISCHRGE'))
	-- 更换
	changeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
        	RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, self.equipPos)
        end
    end)
    -- 更换
    equipGemBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, self.equipPos)
            local isOpen = GlobalApi:getOpenInfo('gem')
            if not isOpen then
                local level = GameData:getConfData('moduleopen')['gem'].level
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('ROLE_EQUIP_DESC_2'),level), COLOR_TYPE.RED)
                return false
            end
            local equipObj = self.roleObj:getEquipByIndex(self.equipPos)
            local gems = equipObj:getMaxGem()
            local gemMaxGemNum = equipObj:getMaxGemNum()
            local num = 0
            for k,v in pairs(gems) do
                num = num + 1
            end
            if num > 0 then
                printall(gems)
                local tab = {}
                for k,v in pairs(gems) do
                    if v.slot <= gemMaxGemNum then
                        tab[tostring(v.slot)] = v.gid
                    end
                end
                local args = {
                    eid = equipObj:getSId(),
                    gids = tab
                }
                MessageMgr:sendPost("fill_all_gem", "equip", json.encode(args), function (jsonObj)
                    --print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        for k,v in pairs(tab) do
                            local slot = tonumber(k)
                            local newGemObj = ClassGemObj.new(v, 1)
                            equipObj:fillGem(slot, newGemObj)
                        end
                        local awards = jsonObj.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                        end
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self.roleObj:setFightForceDirty(true)
                        RoleMgr:updateRoleMainUIForce()
                        RoleMgr:updateRoleList()
                        -- 
                    end
                end)
            else
                local gemTab = BagData:getAllGems()
                local judge = false
                for i=1,4 do
                    if judge == true then
                        break
                    end
		            local tab = gemTab[i]
		            if tab then
			            for k,v in pairs(tab) do
				            if v:getNum() > 0 then
					            judge = true
                                break
				            end
			            end
		            end
	            end
                if judge == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("ROLE_DESC8"), COLOR_TYPE.RED)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("ROLE_DESC10"), COLOR_TYPE.RED)
                end

            end
        end
    end)
	-- 传承
    self.inheritBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.equipObj:getGodId() > 0 then
                RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_INHERIT, self.equipPos)
                RoleMgr:swapChildName(ROLEPANELTYPE.UI_INHERIT)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("EQUIP_NOTHAVE_GOD"), COLOR_TYPE.RED)
            end
        end
    end) 
    -- 卸下
    dischargeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
        	local isFull = BagData:isItemFull(ITEM_TYPE.EQUIP)
            if isFull then
                print("bag is fucking full")
                promptmgr:showSystenHint(GlobalApi:getLocalStr("BAG_REACHED_MAX_AND_FUSION"), COLOR_TYPE.RED)
                return
            end
        	local rolePos = self.roleObj:getPosId()
       		local args = {
    			type = self.equipPos,
                pos = rolePos
    		}
            MessageMgr:sendPost("take_off", "hero", json.encode(args), function (jsonObj)
				print(json.encode(jsonObj))
				local code = jsonObj.code
				if code == 0 then
                    local awards = jsonObj.data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                    end
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    RoleData:takeOffEquip(rolePos, self.equipPos)
                    RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, self.equipPos)
                    RoleMgr:updateRoleList()
				end
			end)
        end
    end) 

    -- 洗练
    -- self.refineGoldImg = self.contentWidget:getChildByName("refine_gold_img")
    self.autoRefineBtn = self.contentWidget:getChildByName("auto_refine_btn")
    self.autoRefineTx = self.autoRefineBtn:getChildByName('func_tx')
    self.autoRefineTx:setString(GlobalApi:getLocalStr('REFINE_1'))
    self.refineBtn = self.contentWidget:getChildByName("refine_btn")  
    self.refineTx = self.refineBtn:getChildByName("refine_tx")
    self.refineTx1 = self.refineBtn:getChildByName("refine_tx_1")
    self.refineTx2 = self.refineBtn:getChildByName("refine_tx_2")
    self.funcTx = self.refineBtn:getChildByName("func_tx")
    local descTx = self.refineBtn:getChildByName("desc_tx")
    self.refineGoldImg = self.refineBtn:getChildByName("refine_gold_img")
    -- local refineBtn = self.refineGoldImg:getChildByName("refine_btn")
    self.funcTx:setString(GlobalApi:getLocalStr('REFINE'))
    local conf = GameData:getConfData('moduleopen')['refine']
    -- local cityData = MapData.data[conf.cityId]
    -- descTx:setString(GlobalApi:getLocalStr('FUNCTION_DESC_1')..cityData:getName()..GlobalApi:getLocalStr('FUNCTION_DESC_2'))
    local desc,desc1 = GlobalApi:getGotoByModule('refine',true)
    local tx1,tx2
    if desc1 == 1 then
        tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
        tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
    else
        tx1 = ''
        tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
    end
    local isOpen = GlobalApi:getOpenInfo('refine')
    if not isOpen then
        descTx:setVisible(true)
        descTx:setString(tx1..desc..tx2)
        self.refineBtn:setBright(false)
        self.autoRefineBtn:setBright(false)
        self.funcTx:setColor(COLOR_TYPE.GRAY)
        self.funcTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.autoRefineTx:setColor(COLOR_TYPE.GRAY)
        self.autoRefineTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.refineBtn:setTouchEnabled(false)
        self.autoRefineBtn:setTouchEnabled(false)
        self.refineTx:setVisible(false)
        self.refineTx1:setVisible(false)
        self.refineTx2:setVisible(false)
        self.refineGoldImg:setVisible(false)
    else
        self.refineBtn:setBright(true)
        self.autoRefineBtn:setBright(true)
        descTx:setVisible(false)
        self.funcTx:setColor(COLOR_TYPE.WHITE)
        self.funcTx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
        self.autoRefineTx:setColor(COLOR_TYPE.WHITE)
        self.autoRefineTx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
        self.refineBtn:setTouchEnabled(true)
        self.autoRefineBtn:setTouchEnabled(true)
        self.refineTx:setVisible(true)
        self.refineTx1:setVisible(true)
        self.refineTx2:setVisible(true)
        self.refineGoldImg:setVisible(true)
    end
    self.refineBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local refineCost = self.equipObj:getRefineCost(self.lockNum)
            local currGold = UserData:getUserObj():getGold()
            if currGold < refineCost then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
                return
            end
            if self.lockNum >= self.maxAttr then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("GEM_DESC_1"), COLOR_TYPE.RED)
                return
            end
            local equipObj = self.equipObj
            local roleObj = self.roleObj
            local args = {
                lock_num = self.lockNum,
                eid = equipObj:getSId()
            }
            MessageMgr:sendPost("refine", "equip", json.encode(args), function (jsonObj)
                print(json.encode(jsonObj))
                local code = jsonObj.code
                if code == 0 then
                    GlobalApi:parseAwardData(jsonObj.data.awards)   
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end 
                    equipObj:updateSubAttr(jsonObj.data.subattr)
                    RoleMgr:setIsShowAttUpdate(false)
                    roleObj:setFightForceDirty(true)
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("REFINE_SUCC"), COLOR_TYPE.GREEN)
                    RoleMgr:updateRoleMainUI()
                    RoleMgr:updateRoleList()
                    RoleMgr:setIsShowAttUpdate(true)
                end
            end)
        end
    end)
    self.autoRefineBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local vip = UserData:getUserObj():getVip()
            local needVip = tonumber(GlobalApi:getGlobalValue('autoRefineNeedVip'))
            local isOpen,_,_,level = GlobalApi:getOpenInfo('auto_refine')
            if vip < needVip and not isOpen then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('OPEN_AFTER_LEVEL_OR_VIP'),level,needVip), COLOR_TYPE.RED)
                return
            end
            local maxNum = tonumber(GlobalApi:getGlobalValue('autoRefineMaxNum'))
            UserData:getUserObj():cost('gold',maxNum * self.currCost,function()
                local args = {
                    lock_num = self.lockNum,
                    eid = self.equipObj:getSId(),
                    num = maxNum
                }
                MessageMgr:sendPost("refine", "equip", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        GlobalApi:parseAwardData(jsonObj.data.awards)   
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end 
                        local costNum = math.abs(costs[1][3])
                        local conut = costNum/self.currCost
                        self.equipObj:updateSubAttr(jsonObj.data.subattr)
                        RoleMgr:setIsShowAttUpdate(false)
                        self.roleObj:setFightForceDirty(true)
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("REFINE_DESC_2"),conut,costNum), COLOR_TYPE.GREEN)
                        RoleMgr:updateRoleMainUI()
                        RoleMgr:updateRoleList()
                        RoleMgr:setIsShowAttUpdate(true)
                    end
                end)
            end,true,string.format(GlobalApi:getLocalStr('REFINE_DESC_1'),maxNum,maxNum * self.currCost))
        end
    end)
end

function RoleEquipInfoUI:update(roleObj, equipPos)
	self.equipPos = equipPos
	local equipObj = roleObj:getEquipByIndex(equipPos)
	if equipObj == nil then
		return
	end
	self.roleObj = roleObj
    self.equipObj = equipObj
	self:updateUI()
end

function RoleEquipInfoUI:updateUI()
    local equipObj = self.equipObj
    local quality = equipObj:getQuality()
    local partInfo = self.roleObj:getPartInfoByPos(self.equipPos)
	local level = partInfo.level
    self.fightforceStrengthenLvLabel:setString('Lv.' .. level)
    ClassItemCell:updateItem(self.tab, equipObj, 1)
    ClassItemCell:setGodLight(self.tab.awardBgImg, equipObj:getGodId())
	self.equipLvLabel:setString("Lv." .. equipObj:getLevel() .. " " .. equipObj:getName())
    self.equipLvLabel:setTextColor(equipObj:getNameColor())
    self.equipLvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.equipLvLabel:enableOutline(equipObj:getNameOutlineColor(),1)
	local fightforceStr = GlobalApi:getLocalStr("STR_EQUIP_FIGHTFORCE") .. ":  " .. equipObj:getFightForce()
	self.fightforceLabel:setString(fightforceStr)
    self.fightforceLabel:setTextColor(equipObj:getNameColor())
    self.fightforceLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.fightforceLabel:enableOutline(equipObj:getNameOutlineColor(),1)

	local mainAttribute = equipObj:getMainAttribute()
	local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
	self.attributeLabel1:setString(mainAttributeStr)
    self.attributeLabel1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

	local subAttrs = equipObj:getSubAttribute()
    local subAttrNum = 1
    self.lockNum = 0
    local attr = {}
    local attvalue = {}
    local percentage = {}
    local equipConf = GameData:getConfData("equip")[self.equipObj:getId()]
    attvalue[5] = equipConf.baseHit
    percentage[5] = equipConf.hitPercentage
    attvalue[6] =equipConf.baseDodge
    percentage[6] = equipConf.dodgePercentage
    attvalue[7] =equipConf.baseCrit
    percentage[7] = equipConf.critPercentage
    attvalue[8] =equipConf.baseResi
    percentage[8] = equipConf.resiPercentage
    for k, v in pairs(subAttrs) do
        local attributeLabel = self["attributeLabel" .. subAttrNum+1]
        local subAttrStr = v.name .. " +" .. v.value
        attr[subAttrNum] = v.value
        attributeLabel:setString(subAttrStr)
        
        attributeLabel:setTextColor(equipObj:getNameColor())
        attributeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        attributeLabel:enableOutline(equipObj:getNameOutlineColor(),1)
        attributeLabel:setVisible(true)
        

        local str = attvalue[tonumber(k)]
        local str1 =percentage[tonumber(k)]
        if v.value >= GlobalApi:roundOff((tonumber(str)*(100+tonumber(str1))/100),1) then
            self['lockImg'..subAttrNum]:setOpacity(255)
            self.lockNum = self.lockNum + 1
            self.maxattlabel[subAttrNum]:setColor(COLOR_TYPE.RED)
            self.maxattlabel[subAttrNum]:enableOutline(COLOROUTLINE_TYPE.RED)
            self.maxattlabel[subAttrNum]:setString("（"..GlobalApi:getLocalStr("STR_MAN").."）")
        else
            self['lockImg'..subAttrNum]:setOpacity(127.5)
            self.maxattlabel[subAttrNum]:setColor(COLOR_TYPE.GREEN)
            self.maxattlabel[subAttrNum]:enableOutline(COLOROUTLINE_TYPE.GREEN)
            self.maxattlabel[subAttrNum]:setString("（"..GlobalApi:roundOff((tonumber(str)*(100+tonumber(str1))/100),1).."）")
        end
        subAttrNum = subAttrNum + 1
    end

    self.maxAttr = subAttrNum - 1
    for i = subAttrNum, 4 do
        local attributeLabel = self["attributeLabel" .. i+1]
        self.maxattlabel[i]:setString('')
        attributeLabel:setVisible(false)
        self['lockImg'..i]:setOpacity(0)
    end

	local gemNum = equipObj:getMaxGemNum()
	local gems = equipObj:getGems()
    local currGemNum = 0
    local extraHeight = 0
    local isCanEquipGem = equipObj:getEmptyGemNum()
	for i = 1, 4 do -- 最多只有4个宝石
        local gemTable = self.gemArr[i]
		if i > gemNum then
			gemTable["gemBg"]:setVisible(false)
		else
            local isOpen = GlobalApi:getOpenInfo('gem')
            if isOpen then
    			local gem = gems[i]
    			if gem then
                    currGemNum = currGemNum + 1
                    gemTable["gemIcon"]:setVisible(true)
    				gemTable["gemIcon"]:loadTexture(gem:getIcon())
                    gemTable["gemIcon"]:ignoreContentAdaptWithSize(true)
    				gemTable["gemLvLabel"]:setString("Lv" .. gem:getLevel())
    				gemTable["gemLvLabel"]:setVisible(true)
                    local gemInfoBg = self.gemInfoArr[currGemNum].bg
                    local gemInfoTx = self.gemInfoArr[currGemNum].tx
                    gemInfoBg:setVisible(true)
                    gemInfoTx:setVisible(true)
                    gemInfoBg:loadTexture(gem:getBgImg())
                    local gemInfoIcon = gemInfoBg:getChildByName("gem_icon")
                    gemTable["gemBg"]:loadTexture(gem:getBgImg())
                    gemInfoIcon:setTexture(gem:getIcon())
                    local gemLvLabel = gemInfoBg:getChildByName("gem_lv_tx")
                    gemLvLabel:setString("Lv" .. gem:getLevel())
                    gemInfoTx:setTextColor(gem:getNameColor())
                    gemInfoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    gemInfoTx:enableOutline(gem:getNameOutlineColor(), 1)
                    gemInfoTx:setString(gem:getName() .. "  " .. gem:getAttrName() .. " +" .. gem:getValue())
                    extraHeight = extraHeight + 55
                    gemTable["upImg"]:setVisible(equipObj:getGemUp(i))
                    gem:setLightEffect(gemTable["gemBg"])
    			else
                    gemTable["gemBg"]:loadTexture('uires/ui/common/frame_bg_gem.png')
                    gemTable["gemIcon"]:setVisible(isCanEquipGem == true)
    				gemTable["gemIcon"]:loadTexture("uires/ui/common/add_01.png")
                    gemTable["gemIcon"]:ignoreContentAdaptWithSize(true)
    				gemTable["gemLvLabel"]:setVisible(false)
                    gemTable["upImg"]:setVisible(false)
                    GlobalApi:setLightEffect(gemTable["gemBg"],0)
                    if isCanEquipGem == true then
                        gemTable["gemBg"]:loadTexture('uires/ui/common/frame_default2.png')
                    else
                        gemTable["gemBg"]:loadTexture('uires/ui/common/frame_bg_gem.png')
                    end
    			end
            else
                gemTable["gemBg"]:loadTexture('uires/ui/common/frame_default2.png')
                gemTable["upImg"]:setVisible(false)
                gemTable["gemIcon"]:setVisible(true)
                gemTable["gemIcon"]:loadTexture("uires/ui/common/lock_3.png")
                gemTable["gemIcon"]:ignoreContentAdaptWithSize(true)
                gemTable["gemIcon"]:setScale(1.5)
            end
            gemTable["gemBg"]:setVisible(true)
		end
	end
    for i = currGemNum+1, 4 do
        self.gemInfoArr[i].bg:setVisible(false)
        self.gemInfoArr[i].tx:setVisible(false)
    end

    self.centerNotAtt:setVisible(true)
    self.bottomNotAtt:setVisible(true)

    local diff = 50
	local godLevel = equipObj:getGodLevel()
    if godLevel == 0 then
        self.line1:setVisible(false)
    else
        self.line1:setVisible(true)
    end

	if currGemNum == 0 and godLevel == 0   then
        self.bottomNotAtt:setPositionY(self.centerNotAtt:getPositionY() - diff)
        self.lineBottom1:setPositionY(self.lineCenter1:getPositionY() - diff)
        self.lineBottom2:setPositionY(self.lineCenter2:getPositionY() - diff)
        self.bottomTx:setPositionY(self.lineCenter2:getPositionY() - diff)

		self.godEquipBg:setVisible(false)
        self.godequipSv:setInnerContainerSize(cc.size(self.svSize.width, self.svSize.height))
        self.contentWidget:setPosition(cc.p(0, 0))
        self.inheritBtn:setBright(false)
        self.inheritBtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        self.godequipSv:scrollToTop(0.01, false)
	else
        local gemOffset = 0

        if godLevel ~= 0 and currGemNum ~= 0 then   -- 有神器，有宝石
            self.centerNotAtt:setVisible(false)
            self.bottomNotAtt:setVisible(false)
            extraHeight = extraHeight + self.centerTxHeight + self.bottomTxHeight
            gemOffset = self.bottomTxHeight

        elseif godLevel ~= 0 and currGemNum == 0 then -- 有神器，无宝石
            self.centerNotAtt:setVisible(false)
            self.bottomNotAtt:setVisible(true)
            extraHeight = extraHeight + self.centerTxHeight + self.bottomTxHeight + self.bottomNotAttHeight
  
        elseif godLevel == 0 and currGemNum ~= 0 then -- 无神器，有宝石
            self.centerNotAtt:setVisible(true)
            self.bottomNotAtt:setVisible(false)
            extraHeight = extraHeight + self.centerTxHeight + self.bottomTxHeight
            gemOffset = self.bottomTxHeight
        end

        local godOffset = self.centerNotAtt:getPositionY() - diff + 25

        if godLevel == 0 then
            self.upgradeBtn:setVisible(false)
            self.starNode:setVisible(false)
            self.godNode:setVisible(false)
            self.gemNode:setPosition(cc.p(0, 130 - gemOffset))
            self.godEquipBg:setVisible(false)
            extraHeight = extraHeight + 20
            self.inheritBtn:setBright(false)
            self.inheritBtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        else
            self.inheritBtn:setBright(true)
            self.inheritBtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
			for i = 1,10 do
				self.godStar[i]:setTexture('uires/ui/common/icon_xingxing.png')
			end
			if godLevel <= 10 then
				for i = 1, 10 do
					if i > godLevel then
						self.godStar[i]:setVisible(false)
					else
						self.godStar[i]:setVisible(true)
					end
				end
			else
				for i = 1,10 do
					self.godStar[i]:setVisible(true)
				end
				for i = 1,godLevel - 10 do
					self.godStar[i]:setTexture('uires/ui/common/icon_xingxing1.png')
				end
			end
            local godObj = clone(equipObj:getGodAttr())
            if godObj[1].type == 1 then
                godObj[1].value = math.floor(godObj[1].value/100)
            end
            self.godInfoTxArr[1]:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
            self.godInfoTxArr[1]:setTextColor(COLOR_TYPE[godObj[1].color])
            self.godInfoTxArr[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            self.godInfoTxArr[1]:enableOutline(COLOROUTLINE_TYPE[godObj[1].color], 1)
            if godObj[2] then -- 是双属性神器
                if godObj[2].type == 1 then
                    godObj[2].value = math.floor(godObj[2].value/100)
                end
                self.godInfoTxArr[2]:setString(godObj[2].name .. " +" .. godObj[2].value .. "%")
                self.godInfoTxArr[2]:setTextColor(COLOR_TYPE[godObj[2].color])
                self.godInfoTxArr[2]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                self.godInfoTxArr[2]:enableOutline(COLOROUTLINE_TYPE[godObj[2].color], 1)
                -- self.godInfoTxArr[4]:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
                -- self.godInfoTxArr[3]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_TALENT"), godLevel))
                -- self.godInfoTxArr[6]:setString(godObj[2].name .. " +" .. godObj[2].value .. "%")
                -- self.godInfoTxArr[5]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_TALENT"), godLevel))
                if godObj[1].double then -- 如果已激活
                    self.godInfoTxArr[4]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[4]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[4]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                    self.godInfoTxArr[3]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[3]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[3]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                else
                    self.godInfoTxArr[4]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[4]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[4]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                    self.godInfoTxArr[3]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[3]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[3]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                end
                if godObj[2].double then
                    self.godInfoTxArr[6]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[6]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[6]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                    self.godInfoTxArr[5]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[5]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[5]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                else
                    self.godInfoTxArr[6]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[6]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[6]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                    self.godInfoTxArr[5]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[5]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[5]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                end
                local godEquipConf = GameData:getConfData("godequip")
                if godObj[1].double or godObj[2].double then
                    local partLv = self.roleObj:getPartInfoByPos(tostring(self.equipPos)).level
                    local value = partLv
                    if godLevel < partLv then
                        value = godLevel
                    end
                    local godEquipObj = godEquipConf[self.equipPos][value]
                    self.godInfoTxArr[4]:setString(godObj[1].name .. " +" .. godEquipObj['value1'] .. "%")
                    self.godInfoTxArr[3]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_1"), value))
                    self.godInfoTxArr[6]:setString(godObj[2].name .. " +" .. godEquipObj['value2'] .. "%")
                    self.godInfoTxArr[5]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_1"), value))
                    if value < 15 and partLv < godLevel then
                        local godEquipObj1 = godEquipConf[self.equipPos][value+1]
                        self.godInfoTxArr[8]:setString(godObj[1].name .. " +" .. godEquipObj1['value1'] .. "%")
                        self.godInfoTxArr[7]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), value+1))
                        self.godInfoTxArr[10]:setString(godObj[2].name .. " +" .. godEquipObj1['value2'] .. "%")
                        self.godInfoTxArr[9]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), value+1))
                        self.godInfoTxArr[8]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[8]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[8]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                        self.godInfoTxArr[7]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[7]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[7]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1) 
                        self.godInfoTxArr[10]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[10]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[10]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                        self.godInfoTxArr[9]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[9]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[9]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1) 
                        self.gemNode:setPosition(cc.p(0, -160 - gemOffset))
                        extraHeight = extraHeight + 280
                        godOffset = godOffset - 280
                    else
                        self.gemNode:setPosition(cc.p(0, -40 - gemOffset))
                        extraHeight = extraHeight + 180
                        godOffset = godOffset - 180     
                        self.godInfoTxArr[8]:setString('')
                        self.godInfoTxArr[7]:setString('')
                        self.godInfoTxArr[10]:setString('')
                        self.godInfoTxArr[9]:setString('')                 
                    end
                else
                    local godEquipObj = godEquipConf[self.equipPos][1]
                    self.godInfoTxArr[4]:setString(godObj[1].name .. " +" .. godEquipObj['value1'] .. "%")
                    self.godInfoTxArr[3]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), 1))
                    self.godInfoTxArr[6]:setString(godObj[2].name .. " +" .. godEquipObj['value2'] .. "%")
                    self.godInfoTxArr[5]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), 1))

                    self.godInfoTxArr[8]:setString('')
                    self.godInfoTxArr[7]:setString('')
                    self.godInfoTxArr[10]:setString('')
                    self.godInfoTxArr[9]:setString('')
                    self.gemNode:setPosition(cc.p(0, -40 - gemOffset))
                    extraHeight = extraHeight + 180
                    godOffset = godOffset - 180
                end
                self.godInfoTxArr[3]:setVisible(true)
                self.godInfoTxArr[6]:setVisible(true)
                self.godInfoTxArr[5]:setVisible(true)

            else
                self.godInfoTxArr[8]:setString('')
                self.godInfoTxArr[7]:setString('')
                self.godInfoTxArr[10]:setString('')
                self.godInfoTxArr[9]:setString('')
                -- self.godInfoTxArr[2]:setString(godObj[1].name .. " +" .. godObj[1].value .. "%")
                -- self.godInfoTxArr[4]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_TALENT"), godLevel))
                local godEquipConf = GameData:getConfData("godequip")
                if godObj[1].double then -- 如果已激活
                    self.godInfoTxArr[2]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[2]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[2]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                    self.godInfoTxArr[4]:setTextColor(COLOR_TYPE.GREEN)
                    self.godInfoTxArr[4]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[4]:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
                else
                    self.godInfoTxArr[2]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[2]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[2]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                    self.godInfoTxArr[4]:setTextColor(COLOR_TYPE.GRAY)
                    self.godInfoTxArr[4]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    self.godInfoTxArr[4]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                end
                if godObj[1].double then
                    local partLv = self.roleObj:getPartInfoByPos(tostring(self.equipPos)).level
                    local value = partLv
                    if godLevel < partLv then
                        value = godLevel
                    end
                    local godEquipObj = godEquipConf[self.equipPos][value]
                    self.godInfoTxArr[2]:setString(godObj[1].name .. " +" .. godEquipObj['value1'] .. "%")
                    self.godInfoTxArr[4]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_1"), value))
                    if value < 15 and partLv < godLevel then
                        local godEquipObj1 = godEquipConf[self.equipPos][value+1]
                        self.godInfoTxArr[6]:setString(godObj[1].name .. " +" .. godEquipObj1['value1'] .. "%")
                        self.godInfoTxArr[5]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), value+1))
                        self.godInfoTxArr[6]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[6]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[6]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
                        self.godInfoTxArr[5]:setTextColor(COLOR_TYPE.GRAY)
                        self.godInfoTxArr[5]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                        self.godInfoTxArr[5]:enableOutline(COLOROUTLINE_TYPE.GRAY, 1) 
                        self.gemNode:setPosition(cc.p(0, 35 - 90 - gemOffset))
                        extraHeight = extraHeight + 180
                        godOffset = godOffset - 180
                    else
                        self.gemNode:setPosition(cc.p(0, 35 - gemOffset))
                        extraHeight = extraHeight + 105
                        godOffset = godOffset - 105
                        self.godInfoTxArr[6]:setString('')
                        self.godInfoTxArr[5]:setString('')
                    end
                else
                    local godEquipObj = godEquipConf[self.equipPos][1]
                    self.godInfoTxArr[2]:setString(godObj[1].name .. " +" .. godEquipObj['value1'] .. "%")
                    self.godInfoTxArr[4]:setString(string.format(GlobalApi:getLocalStr("STR_ACTIVATE_GOD_REFINE_2"), 1))
                    self.godInfoTxArr[6]:setString('')
                    self.godInfoTxArr[5]:setString('')
                    self.gemNode:setPosition(cc.p(0, 35 - gemOffset))
                    extraHeight = extraHeight + 105
                    godOffset = godOffset - 105
                end
                self.godInfoTxArr[3]:setString('')

            end
            self.upgradeBtn:setVisible(true)
            self.starNode:setVisible(true)
            self.godNode:setVisible(true)
        end

        if godLevel == 0 and currGemNum ~= 0 then -- 无神器，有宝石
            godOffset = godOffset - 10
        end
        self.bottomTx:setPositionY(godOffset)
        self.lineBottom1:setPositionY(godOffset)
        self.lineBottom2:setPositionY(godOffset)
        self.bottomNotAtt:setPositionY(godOffset - 25)

        if godLevel >= MAXEQUIPSTARLV then
            self.upgradeBtn:setVisible(false)
        end

        self.godEquipBg:setVisible(true)
        extraHeight = extraHeight - 140
        extraHeight = extraHeight < 0 and 0 or extraHeight
        self.godequipSv:setInnerContainerSize(cc.size(self.svSize.width, self.svSize.height + extraHeight + self.topTxHeight))
        self.contentWidget:setPosition(cc.p(0, extraHeight + self.topTxHeight))
        self.godequipSv:scrollToTop(0.01, false)
	end
    local gold = UserData:getUserObj():getGold()
    local refineCost = self.equipObj:getRefineCost(self.lockNum)
    self.currCost = refineCost
    local isOpen = GlobalApi:getOpenInfo('refine')
    if isOpen then
        if refineCost <= gold then
            self.refineTx2:setTextColor(cc.c3b(255,255,255))
        else
            self.refineTx2:setTextColor(cc.c3b(255,0,0))
        end
        GlobalApi:runNum(self.refineTx2,'Text','roleequipinfoui',self.oldNum,gold)
        self.oldNum = gold

        if quality > 1 then
            self.refineBtn:setVisible(true)
            self.autoRefineBtn:setVisible(true)
            self.refineTx:setString(tostring(equipObj:getRefineCost(self.lockNum)))
            local posX = self.refineTx:getPositionX()
            local size = self.refineTx:getContentSize()
            local offsetX = size.width+20
            self.refineGoldImg:setPositionX(posX-offsetX)
        else
            self.refineBtn:setVisible(false)
            self.autoRefineBtn:setVisible(false)
        end
    end
    local ishaveeq,canequip = self.roleObj:isHavebetterEquip(self.equipPos) 
    if ishaveeq then
        if canequip then
            self.info:setVisible(true)
        else
            self.info:setVisible(false)
        end
    else
        self.info:setVisible(false)
    end

    if self.lockNum >= self.maxAttr then
        self.refineBtn:setVisible(false)
        self.autoRefineBtn:setVisible(false)
    else
        self.refineBtn:setVisible(true)
        self.autoRefineBtn:setVisible(true)
    end
end

return RoleEquipInfoUI