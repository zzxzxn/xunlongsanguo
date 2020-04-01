local ForgeUI = class("ForgeUI", BaseUI)
local COLOR_QUALITY = {
	[1] = 'WHITE',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
}

local EQUIP_BG_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
}

function ForgeUI:ctor(data)
	self.uiIndex = GAME_UI.UI_FORGE
	self:setData(data)
end

function ForgeUI:setData(data)
	self.refresh = data.refresh
	self.smelt = data.smelt
	self.smeltCost = data.smelt_cost
	self.godId = tonumber(data.god_id)
	self:getEquipGodAttr(tonumber(data.equip),data.subattr)
end

function ForgeUI:getEquipGodAttr(id,subattr)
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

function ForgeUI:updatePanel()
	self.nameTx:setString('Lv.'..self.conf.level..'  '..self.conf.name)
	self.nameTx:setColor(COLOR_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]])
	self.nameTx:enableOutline(COLOROUTLINE_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]],1)
	self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	if self.godId == 1 or self.godId == 2 then
		self.godAttTx1:setString(self.godAttr[1].name..'    +'..self.godAttr[1].value..'%')
		self.starImg:setVisible(true)
	elseif self.godId == 3 then
		self.godAttTx1:setString(self.godAttr[1].name..'    +'..self.godAttr[1].value..'%')
		self.starImg:setVisible(true)
	else
		self.godAttTx1:setString('')
		self.starImg:setVisible(false)
	end
	self.awardImg:loadTexture("uires/icon/equip/" .. self.conf.icon)
	self.awardImg:ignoreContentAdaptWithSize(true)
	self.awardBgImg:loadTexture(COLOR_ITEMFRAME[COLOR_QUALITY[self.conf.quality]])

	self.numTx1:setString(self.smeltCost)
	self.numTx2:setString(self.smelt)
	self.infoTx3:setString(string.format(GlobalApi:getLocalStr('REFRESH_TIMES'),self.refresh))
	if self.smeltCost > self.smelt then
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

	self.attTx:setString(self.mainAttribute.name .. ':  +'..self.mainAttribute.value)

	for i=1,4 do
		local gemImg = self.awardBgImg:getChildByName('gem_'..i..'_img')
		gemImg:setVisible(self.maxGem >= i)
	end

	local attrTxs = {}
	for i=1,4 do
		local label = self.neiBgImg:getChildByName('att_'..i..'_tx')
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
        label:setColor(COLOR_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]])
        label:enableOutline(COLOROUTLINE_TYPE[COLOR_QUALITY[tonumber(self.conf.quality)]],1)
        label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        label:setVisible(true)
        subAttrNum = subAttrNum + 1
        if attrTab[tonumber(k)] then
       		attrTab[tonumber(k)] = attrTab[tonumber(k)] + tonumber(v.value)
       	else
       		attrTab[tonumber(k)] = tonumber(v.value)
       	end
    end
    local isUp = false
    for i=1,RoleData:getRoleNum() do
    	local roleObj = RoleData:getRoleByPos(i)
    	if roleObj and roleObj:getId() > 0 then
    		local eauiped = roleObj:getEquipByIndex(tonumber(self.conf.type))
    		if eauiped then
				local up = GlobalApi:getProFightForce(attrTab,eauiped,tonumber(self.conf.quality) - 1)
				local diffLevel = tonumber(self.conf.level) - roleObj:getLevel()
				isUp = up and (diffLevel <= 10)
    		else
    			isUp = true
    		end
    	end
    end
    self.upImg:setVisible(isUp)
    self.forceTx:setString(GlobalApi:getLocalStr('STR_TOTAL_FIGHTFORCE')..': '..GlobalApi:getFightForcePre(attrTab))
end
function ForgeUI:init()
	local bgImg = self.root:getChildByName("forge_bg_img")
	local forgeImg = bgImg:getChildByName("forge_img")
	local closeBtn = forgeImg:getChildByName("close_btn")
    self:adaptUI(bgImg, forgeImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	forgeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    bgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			BagMgr:hideForge()
	    end
	end)
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			BagMgr:hideForge()
	    end
	end)

	local titleBgImg = forgeImg:getChildByName("title_img")
	local infoTx = titleBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr("FORGE_EQUIP"))

	local neiBgImg = forgeImg:getChildByName("bg_img")
	self.neiBgImg = neiBgImg
	self.nameTx = neiBgImg:getChildByName("name_tx")
	self.forceTx = neiBgImg:getChildByName("force_tx")
	self.attTx = neiBgImg:getChildByName("att_tx")
	self.godAttTx1 = neiBgImg:getChildByName("god_att_1_tx")
	-- self.godAttTx2 = neiBgImg:getChildByName("god_att_2_tx")
	self.awardBgImg = neiBgImg:getChildByName("award_bg_img")
	self.awardImg = self.awardBgImg:getChildByName("award_img")
	self.starImg = self.awardBgImg:getChildByName("star_img")
	self.upImg = self.awardBgImg:getChildByName("up_img")
	self.numTx1 = neiBgImg:getChildByName("num_1_tx")
	self.numTx2 = neiBgImg:getChildByName("num_2_tx")
	
	local infoTx = neiBgImg:getChildByName("info_1_tx")
	infoTx:setString(GlobalApi:getLocalStr('NEED_FUSION'))
	infoTx = neiBgImg:getChildByName("info_2_tx")
	infoTx:setString(GlobalApi:getLocalStr('HAD_FUSION'))
	self.infoTx3 = neiBgImg:getChildByName("info_3_tx")
	local refreshBtn = neiBgImg:getChildByName("refresh_btn")
	infoTx = refreshBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('REFRESH_1'))
	local forgeBtn = neiBgImg:getChildByName("forge_btn")
	infoTx = forgeBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('FORGE_1'))
	refreshBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			local function func(args)
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
						self:updatePanel()
						promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
						-- promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
					end
				end)
			end
			local args
			if self.refresh <= 0 then
				args = {cash = GlobalApi:getGlobalValue('makeFreshCashCost')}
				promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),GlobalApi:getGlobalValue('makeFreshCashCost')), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
	                func(args)
	            end)
			else
				args = {}
				func(args)
			end
	    end
	end)

	forgeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.smeltCost > self.smelt then
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
					local smelt = tonumber(data.make.smelt)
					UserData:getUserObj():setSmelt(smelt or 0)
					local awards = data.awards
					if awards then
						GlobalApi:parseAwardData(awards)
					end
					local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
					self:setData(data.make)
					self:updatePanel()
					promptmgr:showSystenHint(GlobalApi:getLocalStr('FORCE_SUCCESS'), COLOR_TYPE.GREEN)
					-- promptmgr:showSystenHint(GlobalApi:getLocalStr('FORCE_SUCCESS'), COLOR_TYPE.GREEN)
				end
			end)
	    end
	end)

	self:updatePanel()
end

return ForgeUI