local ShippersReportUI = class("ShippersReportUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local function getCurColorGold(lv,id)
	local awardStr = ''
	local conf = GameData:getConfData("shipperreward")
	for k, v in pairs(conf) do
		if tonumber(lv) == tonumber(v.level) then
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

function ShippersReportUI:ctor(data)
	self.uiIndex = GAME_UI.UI_SHIPPERREPORT
	self.cellSv = nil
	self.data = data
	table.sort( self.data.report, function(a,b)
		return a.time > b.time
	end )
end

function ShippersReportUI:init()
	local reportBgImg = self.root:getChildByName("report_bg_img")
    local reportImg = reportBgImg:getChildByName('report_img')
    self:adaptUI(reportBgImg,  reportImg)

	local winSize = cc.Director:getInstance():getVisibleSize()
    reportImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
	local closeBtn = reportImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			ShippersMgr:hideShippersReport()
		end
	end)

    local noReportImg = reportImg:getChildByName('no_report_img')
    local titleBgImg = reportImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('BATTLE_LIST'))
    noReportImg:setVisible(#self.data.report <= 0)

	self.cellSv = reportImg:getChildByName('report_sv')
	-- self.cellSv:setBounceEnabled(false)
    self.cellSv:setScrollBarEnabled(false)
    self:update()
end

function ShippersReportUI:update()
	local headConf = GameData:getConfData("settingheadicon")
	local singleSize
	local size = self.cellSv:getContentSize()
	for i = 1, #self.data.report do
		local cell = cc.CSLoader:createNode("csb/shippersreportcell.csb")
		local data = self.data.report[i]
		local cardPl = cell:getChildByName('card_pl')
		singleSize = cardPl:getContentSize()
		local bgImg = cardPl:getChildByName('card_img')
		bgImg:setVisible(true)
		if i % 2 == 0 then
			bgImg:setVisible(false)
		end

		local headpicUrl
		if data.headpic == 0 then
		    headpicUrl = "uires/icon/hero/caocao_icon.png"
		else
		    headpicUrl = headConf[data.headpic].icon
		end
		local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
		local photoNode = cardPl:getChildByName('photo_node')
	    photoNode:addChild(headpicCell.awardBgImg)
	    headpicCell.awardBgImg:loadTexture(COLOR_FRAME[data.quality])
	    headpicCell.awardImg:loadTexture(headpicUrl)
	    headpicCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    headpicCell.headframeImg:setVisible(true)

		local redPointIco = cardPl:getChildByName('red_point_ico')
		local roleLvTx = redPointIco:getChildByName('role_lv_tx')
		roleLvTx:setString(data.level)

		local nameTx = cardPl:getChildByName('name_tx')
		nameTx:setString(data.un)

		local fightTx = cardPl:getChildByName('fighting_tx')
		fightTx:setString(GlobalApi:getLocalStr('FIGHT_FORCE')..'：')
		local fightingLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
		fightingLabel:setAnchorPoint(cc.p(0, 0.5))
		fightingLabel:setPosition(cc.p(72, 15))
		fightingLabel:setString(data.fight_force)
		fightingLabel:setScale(0.7)
		fightTx:addChild(fightingLabel)

		local timeTx = cardPl:getChildByName('time_tx')
		local serverTime = GlobalData:getServerTime()
		local time = serverTime - tonumber(data.time)
		local timeStr = ''
		if math.floor(time / 60) < 60 then
			timeStr = string.format(GlobalApi:getLocalStr('MINUTE_AGO'),math.floor(time / 60))
		else
			timeStr = string.format(GlobalApi:getLocalStr('HOUR_AGO'),math.floor(time / 3600))
		end 
		timeTx:setString(timeStr)

		local winIco = cardPl:getChildByName('win_ico')
		local infoTx = cardPl:getChildByName('info_tx')

		local gold = getCurColorGold(data.slevel, tonumber(data.type)) * tonumber(GlobalApi:getGlobalValue('shipperRobProportion'))
		if tonumber(data.extra) == 1 then
			gold = gold * tonumber(GlobalApi:getGlobalValue('shipperExtra'))
		end
		gold = math.floor(gold)
		if data.rob == 0 then
			if data.success == 0 then
				winIco:loadTexture('uires/ui/arena/failure.png')
				infoTx:setString(GlobalApi:getLocalStr('SHIPPER_LOSE_GOLD').. gold)
			elseif data.success == 1 then
				winIco:loadTexture('uires/ui/arena/victory.png')
				infoTx:setString(GlobalApi:getLocalStr('SHIPPER_NO_LOSE'))
			end
		elseif data.rob == 1 then
			if data.success == 0 then
				winIco:loadTexture('uires/ui/arena/failure.png')
				infoTx:setString(GlobalApi:getLocalStr('SHIPPER_NO_PLUNDER'))
			elseif data.success == 1 then
				winIco:loadTexture('uires/ui/arena/victory.png')
				infoTx:setString(GlobalApi:getLocalStr('SHIPPER_GET_GOLD').. gold)
			end
		end
		if data.replay then
			local replayBtn = ccui.Button:create("uires/ui/common/icon_replay.png")
	        replayBtn:setScale(1.2)
	        replayBtn:setPosition(cc.p(700, 40))
	        replayBtn:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
	                local args = {
	                    id = data.replay
	                }
	                MessageMgr:sendPost('get', 'replay', json.encode(args), function (jsonObj)
	                    if jsonObj.code == 0 then
	                        local customObj = {
	                            info = jsonObj.data.info,
	                            enemy = jsonObj.data.enemy,
	                            rand1 = jsonObj.data.rand1,
	                            rand2 = jsonObj.data.rand2
	                        }
	                        BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function (battleReportJson)
			                    MainSceneMgr:showMainCity(function ()
			                    	CampaignMgr:showCampaignMain(2)
			                    	ShippersMgr:showShippersMain()
			                    end, nil, GAME_UI.UI_SHIPPERS)
	                        end)
	                    end
	                end)
	            end
	        end)
	        cardPl:addChild(replayBtn)
		end
		
		if #self.data.report > 4 then
			cell:setPosition(cc.p(0, (#self.data.report - i) * singleSize.height))
		else
			cell:setPosition(cc.p(0, size.height - i * singleSize.height))
		end	
		self.cellSv:addChild(cell)
	end
	if singleSize then
		if #self.data.report > 4 then
			self.cellSv:setInnerContainerSize(cc.size(size.width, (#self.data.report) * singleSize.height))
		else
			self.cellSv:setInnerContainerSize(cc.size(size.width, size.height))
		end
	end
	self.cellSv:jumpToTop()
end

return ShippersReportUI