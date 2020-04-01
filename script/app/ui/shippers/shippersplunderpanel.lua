local ShippersPlunderUI = class("ShippersPlunderUI", BaseUI)

local function getColorBgUrl(id)
	local strBuff = ''
	if id == 1 then
		strBuff = 'uires/ui/shippers/shippers_green_card.png'
	elseif id == 2 then
		strBuff = 'uires/ui/shippers/shippers_blue_card.png'
	elseif id == 3 then
		strBuff = 'uires/ui/shippers/shippers_purple_card.png'
	elseif id == 4 then
		strBuff = 'uires/ui/shippers/shippers_orange_card.png'
	elseif id == 5 then
		strBuff = 'uires/ui/shippers/shippers_red_card.png'
	end
	return strBuff
end

local function getCurColorGold(lv,id)
	local awardStr = ''
	local conf = GameData:getConfData("shipperreward")
	for k, v in pairs(conf) do
		if lv == tonumber(v.level) then
			if id == 1 then
				awardStr = v.award1[1]
			elseif id == 2 then
				awardStr = v.award2[1]
			elseif id == 3 then
				awardStr = v.award3[1]
			elseif id == 4 then
				awardStr = v.award4[1]
			elseif id == 5 then
				awardStr = v.award5[1]
			end
			break
		end
	end
	
	local award = DisplayData:getDisplayObj(awardStr)
	local gold = award:getNum()
	return gold
end

function ShippersPlunderUI:ctor(key)
	self.uiIndex = GAME_UI.UI_SHIPPERSPLUNDER
	self.data = ShippersMgr:getMainUIData() 
	self.id = key
end

function ShippersPlunderUI:init()
	local plunderBgImg = self.root:getChildByName("plunder_bg_img")
    self.plunderImg = plunderBgImg:getChildByName('plunder_img')
    self:adaptUI(plunderBgImg, self.plunderImg)

	local closeBtn = self.plunderImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			ShippersMgr:hideShippersPlunder()
		end
	end)

    self:update()
end

function ShippersPlunderUI:update()
	for k, v in pairs(self.data.shippers) do
		if tonumber(k) == tonumber(self.id) then
			local mainImg = self.plunderImg:getChildByName('main_img')
			local noPlunderTx = mainImg:getChildByName('no_plunder_tx')
			noPlunderTx:setString(GlobalApi:getLocalStr('SHIPPER_CANNOT_PLUNDER')) 
			local cardBgImg = mainImg:getChildByName('card_bg_img')
			local cardImg = cardBgImg:getChildByName('card_img')
			cardImg:loadTexture(getColorBgUrl(tonumber(v.type)))

			local nameTx = cardBgImg:getChildByName('name_tx')
			local legionTx = cardBgImg:getChildByName('legion_tx')
			printall(v)
			nameTx:setString(v.name..'  Lv.'..v.level)
			legionTx:setString(GlobalApi:getLocalStr('SETTING_INFO_GUILDNAME')..(v.legion or GlobalApi:getLocalStr('E_STR_PVP_WAR_WU')))
			local timesInfoTx = cardBgImg:getChildByName('times_info_tx')
			timesInfoTx:setString(GlobalApi:getLocalStr('SHIPPER_PLUNDER_TIMES'))


			local fightBgImg = cardBgImg:getChildByName('fight_bg_img')
			local fightingLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			fightingLabel:setAnchorPoint(cc.p(0, 0.5))
			fightingLabel:setPosition(cc.p(34, 17))
			fightingLabel:setString(v.fight_force)
			fightingLabel:setScale(0.7)
			fightBgImg:addChild(fightingLabel)

			local timesTx = cardBgImg:getChildByName('times_tx')
			timesTx:setString(v.rob .. '/2')

			local goldIco = cardBgImg:getChildByName('gold_ico')
			local nameTx = cardBgImg:getChildByName('plunder_gold_tx')
			nameTx:setString(GlobalApi:getLocalStr('SHIPPER_CAN_PLUNDER'))

			local noPlunderTx = mainImg:getChildByName('no_plunder_tx')

			local plunderBtn = mainImg:getChildByName('plunder_btn')
			local infoTx = plunderBtn:getChildByName('plunder_tx')
			infoTx:setString(GlobalApi:getLocalStr('SHIPPER_PLUNDER'))
			plunderBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType ==  ccui.TouchEventType.ended then
					self:onClickPlunder()
				end
			end)

			if UserData:getUserObj():getUid() == tonumber(v.uid) then
				goldIco:setVisible(false)
				nameTx:setVisible(false)
				plunderBtn:setVisible(false)
				noPlunderTx:setVisible(true)
				noPlunderTx:setString(GlobalApi:getLocalStr('SHIPPER_DESC_3'))
			else
				if v.rob >= 2 then
					goldIco:setVisible(false)
					nameTx:setVisible(false)
					plunderBtn:setVisible(false)
					noPlunderTx:setVisible(true)
					noPlunderTx:setString(GlobalApi:getLocalStr('SHIPPER_DESC_4'))
				else
					goldIco:setVisible(true)
					nameTx:setVisible(true)
					local goldTx = cardBgImg:getChildByName('gold_tx')
					if v.extra == 1 then
						local num = getCurColorGold(tonumber(v.slevel), tonumber(v.type))* tonumber(GlobalApi:getGlobalValue('shipperExtra')) * tonumber(GlobalApi:getGlobalValue('shipperRobProportion'))
						goldTx:setString(math.floor(num))
					else
						local num = getCurColorGold(tonumber(v.slevel), tonumber(v.type))* tonumber(GlobalApi:getGlobalValue('shipperRobProportion'))
						goldTx:setString(math.floor(num))
					end
					
					plunderBtn:setVisible(true)
					noPlunderTx:setVisible(false)
				end
			end
		end
	end
end

function ShippersPlunderUI:onClickPlunder()
	local rob = GlobalApi:getGlobalValue('shipperRobCount') - self.data.rob
	if rob <= 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_DESC_5'), COLOR_TYPE.RED)
		return
	end

	local serverTime = GlobalData:getServerTime()
    local finishTime = tonumber(self.data.rob_time) + tonumber(GlobalApi:getGlobalValue('shipperRobCD')) * 60
    if serverTime >= tonumber( self.data.rob_time) and serverTime <= finishTime then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_DESC_6'), COLOR_TYPE.RED)
		return
    end

	local obj = {
        target = tonumber(self.id)
    }
    MessageMgr:sendPost("rob", "shipper", json.encode(obj), function (jsonObj)
        if jsonObj.code == 0 then
            if jsonObj.data.info then
                local customObj = {
                	target = self.id,
                    info = jsonObj.data.info,
					enemy = jsonObj.data.enemy,
					rand1 = jsonObj.data.rand1,
					rand2 = jsonObj.data.rand2,
					rand_pos = jsonObj.data.rand_pos,
					rand_attrs = jsonObj.data.rand_attrs
                }
                BattleMgr:playBattle(BATTLE_TYPE.SHIPPERS, customObj, function ()
                	ShippersMgr:setSuccessName(customObj.enemy.name)
                    MainSceneMgr:showMainCity(function ()
                    	CampaignMgr:showCampaignMain(2)
                    	ShippersMgr:showShippersMain()
                    end, nil, GAME_UI.UI_SHIPPERS)          
                end)
            end
        elseif jsonObj.code == 101 then
        	promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_DESC_8'), COLOR_TYPE.RED)
        	return
        elseif jsonObj.code == 102 then
        	promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_DESC_9'), COLOR_TYPE.RED)
        	return
        elseif jsonObj.code == 103 then
        	promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_DESC_10'), COLOR_TYPE.RED)
        	return
        end
    end)
end

return ShippersPlunderUI