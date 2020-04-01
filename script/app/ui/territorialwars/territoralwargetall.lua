local TerritorialwarGetAllUI = class("TerritorialwarGetAllUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TerritorialwarGetAllUI:ctor(awards,notHome,callback)
	self.uiIndex = GAME_UI.UI_TERRITORIALWAR_GET_ALL
	self.awards = awards
	self.notHome = notHome
	self.callback = callback
end

function TerritorialwarGetAllUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self:adaptUI(bgImg, bgImg1)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

	local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			TerritorialWarMgr:hideTerritoralwarGetAll()
		end
	end)

	local descTx = bgImg1:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr('TERRITORIALWAR_GET_ALL_DESC_2'))
	local scale = 0.74
	local diff = 14
	local function getPos(size,size1,i)
		local h = math.floor((i - 1)/4)
		local w = (i - 1)%4 + 1
		local posY = -(size1.height + diff)*(h + 0.5)*scale
		local posX = (size1.width + diff)*(w - 0.5)*scale + 2.5
		return cc.p(posX,posY)
	end

	local rates = {tonumber(GlobalApi:getGlobalValue('freeSweepDiscount')),1}
	local cost = {tonumber(GlobalApi:getGlobalValue('friendlyFreeSweep')),tonumber(GlobalApi:getGlobalValue('friendlyPaySweep'))}
	if self.notHome then
		cost = {tonumber(GlobalApi:getGlobalValue('enemyFreeSweep')),tonumber(GlobalApi:getGlobalValue('enemyPaySweep'))}
	end
	for i=1,2 do
		local neiBgImg = bgImg1:getChildByName('nei_bg_img_'..i)
		local titleImg = bgImg1:getChildByName('title_bg_img_'..i)
		local descTx = neiBgImg:getChildByName('desc_tx')
		local cardSv = neiBgImg:getChildByName('card_sv')
		cardSv:setScrollBarEnabled(false)
		local size = cardSv:getContentSize()
		local node = cc.Node:create()
		node:setPosition(cc.p(0,size.height))
		cardSv:addChild(node)
		local titleTx = titleImg:getChildByName('info_tx')
		titleTx:setString(GlobalApi:getLocalStr('TERRITORIALWAR_GET_ALL_TITLE_'..i))
		-- if descTx then
		-- 	descTx:setString(GlobalApi:getLocalStr('TERRITORIALWAR_GET_ALL_DESC'))
		-- 	descTx:setVisible(#self.awards <= 0)
		-- end
		descTx:setString(GlobalApi:getLocalStr('TERRITORIALWAR_GET_ALL_DESC_3'))
		for j,v in ipairs(self.awards) do
			local awardBgImg = neiBgImg:getChildByName('award_bg_img_'..j)
			if not awardBgImg then
				local tab = ClassItemCell:create()
				awardBgImg = tab.awardBgImg
				awardBgImg:setName('award_bg_img_'..j)
				local size1 = awardBgImg:getContentSize()
				awardBgImg:setPosition(getPos(size,size1,j))
				node:addChild(awardBgImg)
			end
			awardBgImg:setVisible(true)
			awardBgImg:setScale(scale)
			local lvTx = awardBgImg:getChildByName('lv_tx')
			ClassItemCell:updateItem(awardBgImg, v, 0)
			lvTx:setString('x'..math.floor(v:getNum() * rates[i]))
			if math.floor(v:getNum() * rates[i]) <= 0 then
				awardBgImg:setVisible(false)
			end
			awardBgImg:setSwallowTouches(false)
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(v,false)
				end
			end)
		end
		local buyBtn = neiBgImg:getChildByName('buy_btn')
		local cashImg = buyBtn:getChildByName('cash_img')
		local infoTx = buyBtn:getChildByName('info_tx')
		infoTx:setString(cost[i])
		buyBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self:getAllBack(i,cost[i])
			end
		end)
	end
end

function TerritorialwarGetAllUI:getAllBack(index,cost)
	local function sendMsg()
		local args = {}
		args.self = self.notHome ~= true and 1 or 0
		if index ~= 1 then
			args.cash = cost
		end
		MessageMgr:sendPost("gather_all", "territorywar", json.encode(args), function (jsonObj)
			local data = jsonObj.data
			if jsonObj.code == 0 then
				local awards = data.awards
				if awards then
					GlobalApi:showAwardsCommon(awards)
				end
				local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				if self.callback then
					self.callback()
					TerritorialWarMgr:hideTerritoralwarGetAll()
				end
			end
		end)
	end
	if index == 1 then
		local action = UserData:getUserObj():getActionPoint()
		if action < cost then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_229'), COLOR_TYPE.RED)
			TerritorialWarMgr:showMsgUI(2)
		else
			sendMsg()
		end
	else
		UserData:getUserObj():cost('cash',cost,sendMsg,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
	end
end

return TerritorialwarGetAllUI