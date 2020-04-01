local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
local ClassItemCell = require('script/app/global/itemcell')
local FusionUI = class("FusionUI", BaseUI)
local COLOR_QUALITY = {
    [1] = 'WHITE',
    [2] = 'GREEN',
    [3] = 'BLUE',
    [4] = 'PURPLE',
    [5] = 'ORANGE',
    [6] = 'RED',
}

local EQUIP_BG_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED',
}
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

function FusionUI:ctor(obj,data,callback)
	self.uiIndex = GAME_UI.UI_FUSION
	if obj then
		self.selectedMap = {[obj:getSId()] = obj}
	else
		self.selectedMap = {}
	end
	self.awards = {}
	self.selectedArr = {}
	self.callback = callback
	self:setData(data)
end

function FusionUI:onShow()
	-- self.selectedMap = {}
	self:updatePanel()
end

function FusionUI:resetSelectMap()
	self.selectedMap = {}
	self:updatePanel()
end

function FusionUI:setData(data)
	self.refresh = data.refresh
	self.smelt = data.smelt
	self.smeltCost = data.smelt_cost
	self.itemId = tonumber(data.item) or 0
	self.itemNum = tonumber(data.item_num) or 0
	if tonumber(data.item) == 0 then
		self.godId = tonumber(data.god_id)
		self:getEquipGodAttr(tonumber(data.equip),data.subattr)
	end
end

function FusionUI:getEquipGodAttr(id,subattr)
	local attributeConf = GameData:getConfData("attribute")
	local equipConf = GameData:getConfData("equip")[id]
	self.conf = equipConf
	-- 神器属性
	self.godAttr = {}
	if self.godId > 0 then
		local godEquipConf = GameData:getConfData("godequip")
		local godEquipObj = godEquipConf[equipConf.type][1]
		if self.godId == 3 then -- 两个神器属性
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att1"]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value1"]
			self.godAttr[1]["double"] = false
			self.godAttr[2] = {}
			local attrId2 = godEquipObj["att2"]
			self.godAttr[2]["id"] = attrId2
			self.godAttr[2]["name"] = attributeConf[attrId2].name
			self.godAttr[2]["value"] = godEquipObj["value2"]
			self.godAttr[2]["double"] = false
			-- self.allAttr[attrId1] = self.allAttr[attrId1] + godEquipObj["value1"]
			-- self.allAttr[attrId2] = self.allAttr[attrId2] + godEquipObj["value2"]
		else
			self.godAttr[1] = {}
			local attrId1 = godEquipObj["att" .. self.godId]
			self.godAttr[1]["id"] = attrId1
			self.godAttr[1]["name"] = attributeConf[attrId1].name
			self.godAttr[1]["value"] = godEquipObj["value" .. self.godId]
			self.godAttr[1]["double"] = false
			-- self.allAttr[attrId1] = self.allAttr[attrId1] + godEquipObj["value" .. self.godId]
		end
	end
	-- 装备主属性
	local mainAttribute = {}
	mainAttribute.name = attributeConf[equipConf.attributeType].name
	mainAttribute.value = equipConf.attributeValue
	mainAttribute.id = equipConf.attributeType
	self.mainAttribute = mainAttribute

	self.subAttr = {}
	self.subAttrNum = 0
	for k, v in pairs(subattr) do
		local attribute = {}
		attribute.name = attributeConf[tonumber(k)].name
		attribute.value = v
		self.subAttr[tonumber(k)] = attribute
		-- self.allAttr[tonumber(k)] = self.allAttr[tonumber(k)] + v
		self.subAttrNum = self.subAttrNum + 1
	end

	self.maxGem = equipConf.quality - 1
end

function FusionUI:updateRightPanel()
	if self.itemId == 0 then
		self.pl1:setVisible(true)
		self.pl2:setVisible(false)
		self.nameTx:setString('Lv.'..self.conf.level..'  '..self.conf.name)
		local quality = tonumber(self.conf.quality)
		if self.godId > 0 then
			quality = 6
		end
		self.nameTx:setColor(COLOR_TYPE[COLOR_QUALITY[quality]])
		self.nameTx:enableOutline(COLOROUTLINE_TYPE[COLOR_QUALITY[quality]],1)
		self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		if self.godId == 1 or self.godId == 2 then
			self.godAttTx1:setString(self.godAttr[1].name..'    +'..self.godAttr[1].value..'%')
			self.starImg:setVisible(true)
			self.starLv:setString('1')
		elseif self.godId == 3 then
			self.godAttTx1:setString(self.godAttr[1].name..'    +'..self.godAttr[1].value..'%')
			self.starImg:setVisible(true)
			self.starLv:setString('1')
		else
			self.godAttTx1:setString('')
			self.starImg:setVisible(false)
			self.starLv:setString('')
		end
		ClassItemCell:setGodLight(self.awardBgImg,self.godId)
		self.awardImg:loadTexture("uires/icon/equip/" .. self.conf.icon)
		self.awardImg:ignoreContentAdaptWithSize(true)
		self.awardBgImg:loadTexture(COLOR_ITEMFRAME[COLOR_QUALITY[self.conf.quality]])

		self.attTx:setString(self.mainAttribute.name .. ':  +'..self.mainAttribute.value)

		for i=1,4 do
			local gemImg = self.pl1:getChildByName('gem_'..i..'_img')
			gemImg:setVisible(self.maxGem >= i)
		end

		local attrTxs = {}
		for i=1,4 do
			local label = self.pl1:getChildByName('att_'..i..'_tx')
			attrTxs[i] = label
			label:setVisible(false)
		end
	    local subAttrNum = 1
	    local attrTab = {}
	    attrTab[self.mainAttribute.id] = {}
		attrTab[self.mainAttribute.id] = self.mainAttribute.value
	    for k, v in pairs(self.subAttr) do
	        local label = attrTxs[subAttrNum]
	        local subAttrStr = v.name .. "    +" .. v.value
	        label:setString(subAttrStr)
	        label:setColor(COLOR_TYPE[COLOR_QUALITY[quality]])
	        label:enableOutline(COLOROUTLINE_TYPE[COLOR_QUALITY[quality]],1)
	        label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	        label:setVisible(true)
	        subAttrNum = subAttrNum + 1
	        if attrTab[tonumber(k)] then
	       		attrTab[tonumber(k)] = attrTab[tonumber(k)] + tonumber(v.value)
	       	else
	       		attrTab[tonumber(k)] = tonumber(v.value)
	       	end
	    end

	    local isUp = self:getIsUp(attrTab,self.conf)
	    self.upImg:setVisible(isUp)
	    self.forceTx:setString(GlobalApi:getLocalStr('STR_TOTAL_FIGHTFORCE')..': '..GlobalApi:getFightForcePre(attrTab))
	    self.forceTx:setColor(COLOR_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]])
	    self.forceTx:enableOutline(COLOROUTLINE_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]],1)
	    self.numTx:setString('')
	else
		self.pl1:setVisible(false)
		self.pl2:setVisible(true)
		self.upImg:setVisible(false)
		local award = DisplayData:getDisplayObj({'material',self.itemId,1})
		self.awardImg:loadTexture(award:getIcon())
		self.awardImg:ignoreContentAdaptWithSize(true)
		self.awardBgImg:loadTexture(award:getBgImg())
		self.nameTx:setString(award:getName())
		self.nameTx:setColor(award:getNameColor())
		self.nameTx:enableOutline(award:getNameOutlineColor(),1)
		local numTx = self.pl2:getChildByName("num_tx")
		local descTx1 = self.pl2:getChildByName("desc_1_tx")
		local descTx2 = self.pl2:getChildByName("desc_2_tx")
		numTx:setString(GlobalApi:getLocalStr('TAVERN_NOW_OWN')..'：'..award:getOwnNum())
		descTx1:setString(GlobalApi:getLocalStr('FUSION_DESC_1'))
		descTx2:setString(award:getDesc())
		self.numTx:setString('x'..self.itemNum)
		ClassItemCell:setGodLight(self.awardBgImg)
		self.starImg:setVisible(false)
		self.starLv:setString('')
	end
	local smelt = UserData:getUserObj():getSmelt()
	self.numTx1:setString(self.smeltCost)
	self.numTx2:setString(smelt)
	local vip = UserData:getUserObj():getVip()
	local conf = GameData:getConfData("vip")
	local times = conf[tostring(vip)].smeltRefresh
	self.infoTx3:setString(string.format(GlobalApi:getLocalStr('REFRESH_TIMES'),times - self.refresh))
	if self.smeltCost > smelt then
		self.numTx1:setColor(COLOR_TYPE['RED'])
		self.numTx1:enableOutline(COLOROUTLINE_TYPE['RED'],1)
		self.numTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		self.numTx2:setColor(COLOR_TYPE['RED'])
		self.numTx2:enableOutline(COLOROUTLINE_TYPE['RED'],1)
		self.numTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	else
		self.numTx1:setColor(COLOR_TYPE['GREEN'])
		self.numTx1:enableOutline(COLOROUTLINE_TYPE['GREEN'],1)
		self.numTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		self.numTx2:setColor(COLOR_TYPE['GREEN'])
		self.numTx2:enableOutline(COLOROUTLINE_TYPE['GREEN'],1)
		self.numTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	end
end

function FusionUI:getIsUp(attr,conf)
    local isUp = false
    for i=1,RoleData:getRoleNum() do
    	local roleObj = RoleData:getRoleByPos(i)
    	if roleObj and tonumber(roleObj:getId()) > 0 then
    		local eauiped = roleObj:getEquipByIndex(tonumber(conf.type))
    		if eauiped then
				local up = GlobalApi:getProFightForce(attr,eauiped,tonumber(conf.quality) - 1)
				local diffLevel = tonumber(conf.level) - UserData:getUserObj():getLv()
				isUp = up and (diffLevel <= 10)
				if isUp then
	                break
	            end
    		else
    			isUp = true
    			break
    		end
    	end
    end
    return isUp
end

function FusionUI:equipFly()
	local bgImg = self.root:getChildByName("fusion_bg_img")
	local fusionImg = bgImg:getChildByName("fusion_img")
	local leftBgImg = fusionImg:getChildByName("left_bg_img")
	local tab = {}
	for i,v in pairs(self.selectedMap) do
		tab[#tab + 1] = v
	end
	local index = 0
	local function flyEnd()
		index = index + 1
		if index >= #tab then
			self.spine:setAnimation(0, 'idle02', false)
		end
	end
    local diffPos = 
    {
	    {x = 130,y = -15},
	    {x = -130,y = -15},
	    {x = 50,y = 80},
	    {x = -50,y = 80},
	    {x = 65,y = 150},
	    {x = -65,y = 150},
	}
	local endPos = cc.p(249.5,273)
	for i,v in ipairs(self.awards) do
		local equip = tab[i]
		if equip then
			local awardImg = ccui.ImageView:create(equip:getIcon())
			local size = v.awardImg:getContentSize()
			-- local pos = v.awardImg:convertToWorldSpace(cc.p(size.width/2 - 25,size.height/2 - 25))
			local pos = cc.p(v.awardBg:getPositionX(),v.awardBg:getPositionY())
			awardImg:setPosition(pos)
			leftBgImg:addChild(awardImg,999)
			local bezierTo = cc.BezierTo:create(0.5, {pos,cc.p(pos.x + diffPos[i].x,pos.y + diffPos[i].y),endPos})
            AudioMgr.playEffect("media/effect/equip_fusion.mp3", false)
			awardImg:runAction(cc.ScaleTo:create(0.5,0.01))
			awardImg:runAction(cc.Sequence:create(bezierTo,cc.CallFunc:create(function()
				awardImg:removeFromParent()
				flyEnd()
            end)))
		end
	end
end

function FusionUI:updateLeftPanel()
	local tab = {}
	for i,v in pairs(self.selectedMap) do
		tab[#tab + 1] = v
	end
	for i,v in ipairs(self.awards) do
		local equip = tab[i]
		if equip then
			v.awardImg:loadTexture(equip:getIcon())
			v.awardBg:loadTexture(equip:getBgImg())
			v.awardImg:ignoreContentAdaptWithSize(true)
		else
			-- v.awardImg:loadTexture(DEFAULTEQUIP[i])
			v.awardImg:loadTexture('uires/ui/common/default_xuanzhe.png')
			v.awardBg:loadTexture('uires/ui/common/frame_default2.png')
			v.awardImg:ignoreContentAdaptWithSize(true)
		end
	end
end

function FusionUI:updatePanel()
	self:updateLeftPanel()
	self:updateRightPanel()
end

function FusionUI:init()
	local bgImg = self.root:getChildByName("fusion_bg_img")
	local fusionImg = bgImg:getChildByName("fusion_img")
	self:adaptUI(bgImg, fusionImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	fusionImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

	local leftBgImg = fusionImg:getChildByName("left_bg_img")
	local closeBtn = fusionImg:getChildByName("close_btn")
	local autoBtn = leftBgImg:getChildByName("auto_btn")
	local infoTx = autoBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('BTN_AUTO_FILTER'))
	local fusionBtn = leftBgImg:getChildByName("fusion_btn")
	infoTx = fusionBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('FUSION'))
	local fastBtn = leftBgImg:getChildByName("fast_btn")
	fastBtn:setLocalZOrder(3)
	local addition_img = leftBgImg:getChildByName("addition_img")
    addition_img:setTouchEnabled(true)
    local additionPos = leftBgImg:convertToWorldSpace(cc.p(addition_img:getPosition()))
    addition_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TipsMgr:showJadeSealAdditionTips(additionPos, "smelt")
        end
    end)
    addition_img:setLocalZOrder(4)
    local addition_tx = addition_img:getChildByName("addition_tx")
    local addition = UserData:getUserObj():getJadeSealAddition("smelt")
    addition_tx:setString(addition[2] .. "%")
    if not addition[1] then
        ShaderMgr:setGrayForWidget(addition_img)
        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end

	self.spine = GlobalApi:createSpineByName("fusion_lu", "spine/fusion/fusion_lu", 1)
	self.spine:setScale(0.8)
	local size = leftBgImg:getContentSize()
	self.spine:setPosition(cc.p(size.width/2,150))
	leftBgImg:addChild(self.spine,1)
	self.spine:registerSpineEventHandler(function (event)
		self.spine:setAnimation(0, 'idle01', false)
	end, sp.EventType.ANIMATION_COMPLETE)

    self.spine:registerSpineEventHandler(function (event)
        if event.animation == 'idle02' then
        	if self.showWidgets and #self.showWidgets > 0 then
        		promptmgr:showAttributeUpdate(self.showWidgets)
        		for i, v in ipairs(self.showWidgets) do
        			v:release()
        		end
        		self.showWidgets = nil
        	end
        	-- if self.tab and self.tab.x and self.tab.y and self.showTab and #self.showTab > 0 then
	        -- 	promptmgr:showAttributeUpdate(self.tab.x,self.tab.y, self.showTab)
	        -- 	self.tab, self.showTab = nil,nil
	        -- end
        end
    end, sp.EventType.ANIMATION_EVENT)
	self.spine:setAnimation(0, 'idle01', false)
	
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.FUSION)
    --btn:setScale(0.7)
    btn:setPosition(cc.p(35, 487))
    fusionImg:addChild(btn)

	local titleBgImg = fusionImg:getChildByName("title_img")
	local infoTx = titleBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr("BLACKSMITH"))
	
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			BagMgr:hideFusion()
	    end
	end)

	autoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local tab = {}
			for i,v in pairs(self.selectedMap) do
				tab[#tab + 1] = v
			end
			if #tab >= 6 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_FUSION_EQUIP'), COLOR_TYPE.RED)
				-- promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_FUSION_EQUIP'), COLOR_TYPE.RED)
				return
			end
			self.selectedArr = {}
			local selectedMap = {}
			local equips = {}
			local selectEquipNum = 0
			local equipMap = BagData:getAllEquips()
			for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() == 0 and not v2:isAncient() then
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
            	promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_CAN_USED_EQUIP'), COLOR_TYPE.RED)
            	-- promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_CAN_USED_EQUIP'), COLOR_TYPE.RED)
            	return
            end
            self.selectedMap = selectedMap
            self:updatePanel()
	    end
	end)

	fusionBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local eids = {}
			for i,v in pairs(self.selectedMap) do
				eids[#eids + 1] = i
			end
			if #eids <= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_EQUIP_FOR_FUSION'), COLOR_TYPE.RED)
				-- promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_EQUIP_FOR_FUSION'), COLOR_TYPE.RED)
				return
			end
			local args = {
				eids = eids
			}
		  	MessageMgr:sendPost('smelt','equip',json.encode(args),function (response)
				
				local code = response.code
				local data = response.data
				self.showWidgets = {}
				if code == 0 then
					local awards = data.awards
					local update = data.update
					local smelt = UserData:getUserObj():getSmelt()
					GlobalApi:parseAwardData(awards)
					local isUp = false
					for i,v in ipairs(awards) do
						if v[1] == 'equip' then
							local conf = GameData:getConfData("equip")[v[3].id]
							isUp = self:getIsUp(v[3].subattr,conf)
							if isUp == true then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('GET_EQUIP'), COLOR_TYPE.WHITE)
								break
							end
						end
					end
					for i,v in pairs(update) do
						local equip = BagData:getEquipMapById(v.eid)
						if equip then
							local conf = GameData:getConfData("equip")[equip:getId()]
							isUp = self:getIsUp(equip,conf)
							if isUp == true then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('GET_EQUIP'), COLOR_TYPE.WHITE)
								break
							end
						end
					end
					local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
					
					for i,v in pairs(update) do
						local eid = v.eid
						local godId = v.god_id
						local god = v.god
						local equip = BagData:getEquipMapById(eid)
						equip:setGod(god,godId)
						local quality = equip:getQuality()
						local name = GlobalApi:getLocalStr('ACCIDENT_GET')..'Lv.'..equip:getLevel()..'  '..equip:getName()
						local color = (godId>0 and COLOR_QUALITY[6]) or COLOR_QUALITY[quality]
						local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
						w:setTextColor(COLOR_TYPE[color])
						w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
						w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
						w:retain()
						table.insert(self.showWidgets, w)
					end
					for i,v in pairs(awards) do
						local eid = v[2]
						local equip = BagData:getEquipMapById(eid)
						if equip then
							local quality = equip:getQuality()
							local name = GlobalApi:getLocalStr('ACCIDENT_GET')..'Lv.'..equip:getLevel()..'  '..equip:getName()
							local color = COLOR_QUALITY[quality]
							local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
							w:setTextColor(COLOR_TYPE[color])
							w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
							w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
							w:retain()
							table.insert(self.showWidgets, w)
						elseif v[1] == 'gem' then
							local award = DisplayData:getDisplayObj(v)
							local quality = award:getQuality()
							local name = GlobalApi:getLocalStr('ACCIDENT_GET')..award:getName()
							local color = COLOR_QUALITY[quality]
							local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
							w:setTextColor(COLOR_TYPE[color])
							w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
							w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
							w:retain()
							table.insert(self.showWidgets, w)
						end
					end
					local diffSmelt = UserData:getUserObj():getSmelt() - smelt
					if diffSmelt > 0 then
						local name = GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..diffSmelt..GlobalApi:getLocalStr('FUSION_NUM1')
						local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
						w:setTextColor(COLOR_TYPE.GREEN)
						w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
						w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
						w:retain()
						table.insert(self.showWidgets, w)
					end
					self:equipFly()
					self.selectedMap = {}
					self:updatePanel()
					if self.callback then
						self.callback()
					end
				end
			end)
	    end
	end)

	fastBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local vip = UserData:getUserObj():getVip()
        	local needVip = tonumber(GlobalApi:getGlobalValue('autoFunsionNeedVip'))
        	local isOpen,_,_,level = GlobalApi:getOpenInfo('autofunsion')
        	if vip < needVip and not isOpen then
        		promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('OPEN_AFTER_LEVEL_OR_VIP'),level,needVip), COLOR_TYPE.RED)
        		return
        	end
			-- GlobalApi:getGotoByModule('autofunsion')
			BagMgr:showAutoFusion()
	    end
	end)
	
	for i=1,6 do
		local awardBg = leftBgImg:getChildByName('award_bg_'..i..'_img')
		local awardImg = awardBg:getChildByName('award_img')
		self.awards[i] = {awardBg = awardBg,awardImg = awardImg}
		awardBg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            local equipSelectUI = ClassEquipSelectUI.new(nil,self.selectedMap, 6, 0, 3, 0, function (map)
	                self.selectedMap = map or {}
	                self:updatePanel()
	            end,1)
	            equipSelectUI:showUI()
		    end
		end)
	end

	local rightBgImg = fusionImg:getChildByName("right_bg_img")
	local pl1 = rightBgImg:getChildByName("pl1")
	self.pl1 = pl1
	self.pl2 = rightBgImg:getChildByName("pl2")
	self.rightBgImg = rightBgImg
	self.nameTx = rightBgImg:getChildByName("name_tx")
	self.forceTx = pl1:getChildByName("force_tx")
	self.attTx = pl1:getChildByName("att_tx")
	self.godAttTx1 = pl1:getChildByName("god_att_1_tx")
	local node  = rightBgImg:getChildByName("award_node")
	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	self.awardBgImg = tab.awardBgImg
	node:addChild(self.awardBgImg)
	self.awardImg = tab.awardImg
	self.starImg = tab.starImg
	self.starLv = tab.starLv
	self.numTx = tab.lvTx
	self.upImg = tab.upImg
	self.numTx1 = rightBgImg:getChildByName("num_1_tx")
	self.numTx2 = rightBgImg:getChildByName("num_2_tx")
	
	local infoTx = rightBgImg:getChildByName("info_1_tx")
	infoTx:setString(GlobalApi:getLocalStr('NEED_FUSION'))
	infoTx = rightBgImg:getChildByName("info_2_tx")
	infoTx:setString(GlobalApi:getLocalStr('HAD_FUSION'))
	self.infoTx3 = rightBgImg:getChildByName("info_3_tx")
	local refreshBtn = rightBgImg:getChildByName("refresh_btn")
	infoTx = refreshBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('REFRESH_1'))
	local forgeBtn = rightBgImg:getChildByName("forge_btn")
	infoTx = forgeBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('FORGE_1'))
	refreshBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
    		local cost = tonumber(GlobalApi:getGlobalValue('makeFreshCashCost'))
			local args
			local tx
			local b
			local conf = GameData:getConfData("vip")
			local vip = UserData:getUserObj():getVip()
			local times = conf[tostring(vip)].smeltRefresh
			if times - self.refresh <= 0 then
				args = {cash = GlobalApi:getGlobalValue('makeFreshCashCost')}
				tx = string.format(GlobalApi:getLocalStr('NEED_CASH'),GlobalApi:getGlobalValue('makeFreshCashCost'))
				b = 1
			else
				args = {}
				tx = nil
				b = nil
			end
			local function callback()
				MessageMgr:sendPost('make_refresh','equip',json.encode(args),function (response)
					local code = response.code
					local data = response.data
					if code == 0 then
						local awards = data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
						end
						local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
						self:setData(data.make)
						UserData:getUserObj():initMake(data.make)
						self:updatePanel()
						promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
					end
				end)
			end
			if b then
    			UserData:getUserObj():cost('cash',cost,callback,b,tx)
    		else
    			callback()
    		end
	    end
	end)

	forgeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.awardBgImg:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2, 1.3),
                cc.ScaleTo:create(0.2, 1)
                ))

		    if BagData:getEquipFull() then
		        promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
		        return
		    end
			local smelt = UserData:getUserObj():getSmelt()
			if self.smeltCost > smelt then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('HAD_NOT_ENOUGH_FUSION'), COLOR_TYPE.RED)
				-- promptmgr:showSystenHint(GlobalApi:getLocalStr('HAD_NOT_ENOUGH_FUSION'), COLOR_TYPE.RED)
				return
			end
			local args = {

			}
			MessageMgr:sendPost('make','equip',json.encode(args),function (response)
				
				local code = response.code
				local data = response.data
				if code == 0 then
					-- local smelt = tonumber(data.make.smelt)
					-- UserData:getUserObj():setSmelt(smelt or 0)
					local awards = data.awards
					local equips
					if awards then
						GlobalApi:parseAwardData(awards)
						equips = DisplayData:getDisplayObjs(awards)
					end
					local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
					self:setData(data.make)
					UserData:getUserObj():initMake(data.make)
					self:updateRightPanel()
					if equips[1]:getType() == 'equip' then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..' Lv.'..equips[1]:getLevel()..' '..equips[1]:getName(), equips[1]:getNameColor())
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..equips[1]:getName(), equips[1]:getNameColor())
					end
					-- promptmgr:showSystenHint(GlobalApi:getLocalStr('FORCE_SUCCESS'), COLOR_TYPE.GREEN)
				end
			end)
	    end
	end)

	self:updatePanel()
end

return FusionUI