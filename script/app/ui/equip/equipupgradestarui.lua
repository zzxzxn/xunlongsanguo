local EquipUpgradeStarUI = class("EquipUpgradeStarUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
local MAXEQUIPSTARLV = 15
-- 排序:品质>等级>战斗力>id
local function sortByQuality(arr)
    table.sort(arr, function (a, b)
        local q1 = a:getQuality()
        local q2 = b:getQuality()
        if q1 == q2 then
            local l1 = a:getLevel()
            local l2 = b:getLevel()
            if l1 == l2 then
                local f1 = a:getFightForce()
                local f2 = b:getFightForce()
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

function EquipUpgradeStarUI:ctor(equipObj)
    self.uiIndex = GAME_UI.UI_EQUIP_UPGRADE_STAR
    self.equipObj = equipObj
    self.selectedMap = {}
    self.selectedArr = {}
    self.selectIndex = 1
end

function EquipUpgradeStarUI:init()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local equipStarBgImg = self.root:getChildByName("equip_star_bg_img")
    local equipStarAlpgaImg = equipStarBgImg:getChildByName("equip_star_alpha_img")
    self:adaptUI(equipStarBgImg)
    equipStarAlpgaImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 35))

    local closeBtn = equipStarAlpgaImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local titleBgImg = equipStarAlpgaImg:getChildByName("title_img")
    local infoTx = titleBgImg:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr("TITLE_ZBSX"))

    local equipBgImg = equipStarAlpgaImg:getChildByName("equip_bg_img")
    local equipIconNode = equipBgImg:getChildByName("equip_icon_node")
    self.equipIconNode = equipIconNode
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    equipIconNode:addChild(tab.awardBgImg)
    self.tab = tab
    
    self.equipInfoLabel = equipBgImg:getChildByName("info_tx")

    self.equipArr = {}
    for i = 1, 6 do
        local equipIconNode = equipBgImg:getChildByName("equip_icon_node_" .. i)
        self.equipArr[i] = {}
        local tab2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        self.equipArr[i].tab = tab2
        self.equipArr[i].equipIconNode = equipIconNode
        equipIconNode:addChild(tab2.awardBgImg)
        tab2.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            end
            if eventType == ccui.TouchEventType.ended then
                if self.equipObj:getGodLevel() >= MAXEQUIPSTARLV then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC3'), COLOR_TYPE.RED)
                    return
                end
                local roleobj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
                local equipSelectUI = ClassEquipSelectUI.new(roleobj,self.selectedMap, 6, 0, 4, 0, function (selectedMap)
                    self.selectedMap = {}
                    self.selectedArr = {}
                    for i=1,6 do
                        ClassItemCell:setGodLight(self.equipArr[i].tab.awardBgImg, 0)
                        self.equipArr[i].tab.starImg:setVisible(false)
                    end
                    for k, v in pairs(selectedMap) do
                        self.selectedMap[k] = v
                        table.insert(self.selectedArr, v)
                    end
                    self:updateUI()
                end)
                equipSelectUI:showUI()
            end
        end)
    end

    self.godStar = {}
    for i = 1, 10 do
        local starBg = equipBgImg:getChildByName("star_bg_" .. i)
        self.godStar[i] = starBg:getChildByName("star_img")
    end

    local progressBg = equipBgImg:getChildByName("progress_bg")
    self.bar1 = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/upgrade_star_bar2.png"))
    self.bar1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.bar1:setMidpoint(cc.p(0, 0))
    self.bar1:setBarChangeRate(cc.p(1, 0))
    self.bar1:setPosition(cc.p(158, 18))
    self.bar2 = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/upgrade_star_bar2.png"))
    self.bar2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.bar2:setMidpoint(cc.p(0, 0))
    self.bar2:setBarChangeRate(cc.p(1, 0))
    self.bar2:setPosition(cc.p(158, 18))
    progressBg:addChild(self.bar1)
    progressBg:addChild(self.bar2)
    self.progressLabel = progressBg:getChildByName("progress_tx")
    self.progressLabel:setLocalZOrder(3)
    -- 自动筛选
    local selectBtn = equipStarAlpgaImg:getChildByName("select_btn")
    self.selectBtn = selectBtn
    local selectLabel = selectBtn:getChildByName("func_tx")
    selectLabel:setString(GlobalApi:getLocalStr("BTN_AUTO_FILTER"))
    selectBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.equipObj:getGodLevel() >= MAXEQUIPSTARLV then
                -- 已经满级了
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC3'), COLOR_TYPE.RED)
                return
            end

            self.selectedArr = {}
            local selectedMap = {}
            local equips = {}
            local selectEquipNum = 0
            local equipMap = BagData:getAllEquips()
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() ~= 0 and v2:getGodId() ~= 3 then
                        if self.selectedMap[v2:getSId()] then
                            selectedMap[v2:getSId()] = v2
                            table.insert(self.selectedArr, v2)
                            selectEquipNum = selectEquipNum + 1
                        else
                            table.insert(equips, v2)
                        end
                    end
                end
            end
            sortByQuality(equips)
            if #equips > 0 then
                for i = 1, 6 - selectEquipNum do
                    
                    if equips[i] then
                        selectedMap[equips[i]:getSId()] = equips[i]
                        table.insert(self.selectedArr, equips[i])
                    end
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC4'), COLOR_TYPE.RED)
            end
            self.selectedMap = selectedMap
            self:updateUI()
        end
    end)

    self.swallowBtn = equipStarAlpgaImg:getChildByName("swallow_btn")
    local swallowLabel = self.swallowBtn:getChildByName("func_tx")
    swallowLabel:setString(GlobalApi:getLocalStr("STR_SWALLOW"))
    self.swallowBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.equipObj:getGodLevel() >= MAXEQUIPSTARLV then
                -- 已经满级了
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC3'), COLOR_TYPE.RED)
                return
            end

            if self.selectIndex <= 1 then
                -- 当前没有可吞噬的
                return
            end

            local needGold = self.equipObj:getSwallowCost()
            local currGold = UserData:getUserObj():getGold()
            if currGold < needGold then
                -- 金币不足
                promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
                return
            end
            local sids = {}
            local haveAncient = false
            for k, v in pairs(self.selectedMap) do
                if v:isAncient() then
                    haveAncient = true
                end
                table.insert(sids, k)
            end
            local function sendMsg()
                local args = {
                    eid = self.equipObj:getSId(),
                    sids = sids
                }
                MessageMgr:sendPost("swallow", "equip", json.encode(args), function (jsonObj)
                    local code = jsonObj.code
                    if code == 0 then
                        local size = self.tab.awardBgImg:getContentSize()
                        local pos = self.tab.awardBgImg:convertToWorldSpace(cc.p(size.width/2, size.height/2))
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_SWALLOW_SUCC"), COLOR_TYPE.GREEN)
                        self:disableButtonClick()
                        for i,v in ipairs(self.selectedArr) do
                            local oriX, oriY = self.equipArr[i].tab.awardBgImg:getPosition()
                            local fSprite = self.equipArr[i].tab.awardBgImg:clone()
                            local eSprite = self.equipArr[i].tab.awardImg:clone()
                            local despos = self.equipArr[i].equipIconNode:convertToNodeSpace(cc.p(pos.x,pos.y))

                            fSprite:addChild(eSprite)
                            self.equipArr[i].tab.awardBgImg:loadTexture(COLOR_ITEMFRAME.DEFAULT)
                            self.equipArr[i].tab.awardImg:loadTexture(DEFAULTEQUIP[3])
                            self.equipArr[i].tab.awardBgImg:getParent():addChild(fSprite)
                            fSprite:runAction(cc.Sequence:create(
                                cc.DelayTime:create(i * 0.025),
                                cc.MoveTo:create(0.2, cc.p(despos.x, despos.y)), 
                                cc.CallFunc:create(function ()
                                    fSprite:removeFromParent()
                                    if i == #self.selectedArr then
                                        self.selectedMap = {}
                                        self.selectedArr = {}
                                        self.equipObj:updateGodAttr(jsonObj.data.god, jsonObj.data.xp)

                                        GlobalApi:parseAwardData(jsonObj.data.awards)
                                        local costs = jsonObj.data.costs
                                        if costs then
                                            GlobalApi:parseAwardData(costs)
                                        end
                                        local roleobj = RoleData:getRoleByPos(self.equipObj:getPos())
                                        roleobj:setFightForceDirty(true)
                                        self:updateUI()
                                        self:enableButtonClick()
                                    end
                                end)))
                            for i=1,6 do  
                                ClassItemCell:setGodLight(self.equipArr[i].tab.awardBgImg, 0)
                                self.equipArr[i].tab.starImg:setVisible(false)
                            end
                        end
                    end
                end)
            end
            if haveAncient then
                promptmgr:showMessageBox(GlobalApi:getLocalStr("SURE_TO_SWALLOW_ANCIENT"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    sendMsg()
                end)
            else
                sendMsg()
            end
        end
    end)
    self:updateUI()
end

function EquipUpgradeStarUI:updateUI()
    local equipObj = self.equipObj
    local godLevel = equipObj:getGodLevel()
    ClassItemCell:updateItem(self.tab, equipObj, 1)
    ClassItemCell:setGodLight(self.tab.awardBgImg, equipObj:getGodId())
    local godObj = clone(equipObj:getGodAttr())
    if godObj[1] == nil then
        return
    end
    local godStr
    if godObj[1].type == 1 then
        godObj[1].value = math.floor(godObj[1].value/100)
    end
    if godObj[1].double then
        godStr = godObj[1].name .. "+" .. godObj[1].value*2 .. "%"
    else
        godStr = godObj[1].name .. "+" .. godObj[1].value .. "%"
    end
    if godObj[2] then
        if godObj[2].type == 1 then
            godObj[2].value = math.floor(godObj[2].value/100)
        end
        if godObj[2].double then
            godStr = godStr .. "    " .. godObj[2].name .. "+" .. godObj[2].value*2 .. "%"
        else
            godStr = godStr .. "    " .. godObj[2].name .. "+" .. godObj[2].value .. "%"
        end
    end
    self.equipInfoLabel:setString(godStr)

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
    self.progressLabel:setString(equipObj:getXp() .. "/" .. equipObj:getNextXp())

    self.selectIndex = 1
    local currXp = equipObj:getXp()
    local maxXp = equipObj:getNextXp()
    local progress = currXp/maxXp*100
    progress = progress > 100 and 100 or progress
    self.bar2:setPercentage(progress)

    if #self.selectedArr > 1 then
        sortByQuality(self.selectedArr)
    end
    for k, v in ipairs(self.selectedArr) do
        ClassItemCell:updateItem(self.equipArr[self.selectIndex].tab, v, 1)
        ClassItemCell:setGodLight(self.equipArr[self.selectIndex].tab.awardBgImg, v:getGodId())
        self.selectIndex = self.selectIndex + 1
        currXp = currXp + v:getAllXp() + 1
    end

    progress = currXp/maxXp*100
    progress = progress > 100 and 100 or progress
    self.bar1:setPercentage(progress)
    self.bar1:setOpacity(255)
    self.bar1:stopAllActions()
    if self.selectIndex > 1 then
        self.bar1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(1))))
    end
    for i = self.selectIndex, 6 do
        self.equipArr[i].tab.awardBgImg:loadTexture(COLOR_ITEMFRAME.DEFAULT)
        self.equipArr[i].tab.awardImg:loadTexture(DEFAULTEQUIP[3])
    end

    if equipObj:getGodLevel() >= MAXEQUIPSTARLV then
        -- 已经满级了
        self.swallowBtn:setBright(false)
        self.selectBtn:setBright(false)
    else
        self.selectBtn:setBright(true)
        self.swallowBtn:setBright(true)
    end
end

function EquipUpgradeStarUI:disableButtonClick()
    self.swallowBtn:setTouchEnabled(false)
    self.selectBtn:setTouchEnabled(false)
    for k, v in ipairs(self.equipArr) do
        v.tab.awardBgImg:setTouchEnabled(false)
    end
end

function EquipUpgradeStarUI:enableButtonClick()
    self.swallowBtn:setTouchEnabled(true)
    self.selectBtn:setTouchEnabled(true)
    for k, v in ipairs(self.equipArr) do
        v.tab.awardBgImg:setTouchEnabled(true)
    end
end

return EquipUpgradeStarUI