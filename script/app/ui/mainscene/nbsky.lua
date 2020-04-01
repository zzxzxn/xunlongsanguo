local NBSkyUI = class("NBSkyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function NBSkyUI:ctor()
	self.uiIndex = GAME_UI.UI_NB_SKY
end

function NBSkyUI:buy(conf,award,ntype)
	local vip = UserData:getUserObj():getVip()
	if conf.vip > vip then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_VIP_1'), COLOR_TYPE.RED)
		return
	end
	local function callback()
		local args = {
			id =  conf.id
		}
		MessageMgr:sendPost('buy_sky_limit_buy','activity',json.encode(args),function(jsonObj)
			local code = jsonObj.code
			local data = jsonObj.data
			if code == 0 then
				local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local awards = data.awards
				if awards then
					GlobalApi:parseAwardData(awards)
					GlobalApi:showAwardsCommon(awards, nil, nil, true)
				end
				local data = UserData:getUserObj():getActicityInfoByKey('sky_limit_buy')
				data.rewards[tostring(conf.id)] = 1
				UserData:getUserObj():setActicityInfoByKey('sky_limit_buy',data)
				self:updatePanel()
			end
		end)
	end
	local str = string.format(GlobalApi:getLocalStr('NB_SKY_DESC_2'),conf.cost,award:getName())
	UserData:getUserObj():cost('cash',conf.cost,callback,true,str)
end

function NBSkyUI:updatePanel()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	local conf = GameData:getConfData("avskyrestrictions")
	local ids = {}
	local data = UserData:getUserObj():getActicityInfoByKey('sky_limit_buy')
	local winSize = cc.Director:getInstance():getVisibleSize()
	local pos = {cc.p(cc.p(winSize.width/2 + 270,winSize.height/2 - 150)),cc.p(cc.p(winSize.width/2 + 57,winSize.height/2 - 150))}
	for i,v in ipairs(conf) do
		local obj = DisplayData:getDisplayObj(v.skyItem[1])
		local node = bgImg1:getChildByName('node_'..i)
		local nameTx = bgImg1:getChildByName('name_tx_'..i)
		local descTx1 = bgImg1:getChildByName('desc_tx_1'..i)
		local descTx2 = bgImg1:getChildByName('desc_tx_2'..i)
		local descTx3 = bgImg1:getChildByName('desc_tx_3'..i)
		local numTx = bgImg1:getChildByName('num_tx_'..i)
		local buyBtn = bgImg1:getChildByName('buy_btn_'..i)
		local infoTx = buyBtn:getChildByName('info_tx')
		local cashImg = buyBtn:getChildByName('cash_img')
		local param = {}
		local awardBgImg = ClassItemCell:updateAwardFrameByObj(node,obj,param)
		local surfacetimeImg = awardBgImg:getChildByName('surfacetime_Img')
		if surfacetimeImg then
			surfacetimeImg:setScale9Enabled(true)
			surfacetimeImg:setContentSize(cc.size(40,surfacetimeImg:getContentSize().height - 6))
		end
		ids[i] = obj:getId()
		nameTx:setString(obj:getName())
		descTx1:setString(GlobalApi:getLocalStr('PEOPLE_KING_TITLE_DESC_'..i))
		descTx2:setString(GlobalApi:getLocalStr('NB_SKY_DESC_1'))
		numTx:setString(v.showPower..'+')
		descTx3:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_VIPLIMIT'),v.vip))
		ClassItemCell:setGodLight(awardBgImg,3)
		awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				local conf = GameData:getConfData("skychange")[i][obj:getId()]
				PeopleKingMgr:showPeopleKingDsiplayUI(conf,pos[i])
			end
		end)
		
		if data.rewards[tostring(i)] == 1 then
			infoTx:setString(GlobalApi:getLocalStr('HAD_BOUGHT'))
			infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			cashImg:setVisible(false)
			buyBtn:setTouchEnabled(false)
			buyBtn:setBright(false)
			infoTx:setPosition(cc.p(93.5,32.5))
		else
			infoTx:setString(v.cost)
			buyBtn:setTouchEnabled(true)
			cashImg:setVisible(true)
			buyBtn:setBright(true)
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
			buyBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					self:buy(v,obj,data.rewards[tostring(i)])
				end
			end)
		end
	end

	local mainRoleAni = bgImg1:getChildByName('role')
	if not mainRoleAni then
		local size = bgImg1:getContentSize()
		local roleObj = RoleData:getMainRole()
		local customObj = {weapon_illusion = ids[1],wing_illusion = ids[2]}
		mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState(customObj))
		mainRoleAni:getAnimation():play("idle", -1, 1)
		mainRoleAni:setPosition(cc.p(250, size.height/2 - 100))
		mainRoleAni:setName('role')
		bgImg1:addChild(mainRoleAni)
	end
end

function NBSkyUI:timeoutCallback(img,time)
	local diffTime = time
	local label = img:getChildByTag(9999)
	local size = img:getContentSize()
	local winSize = cc.Director:getInstance():getVisibleSize()
	label = cc.Label:createWithTTF('', "font/gamefont.ttf", 22)
	label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	label:setTag(9999)
	label:setPosition(cc.p(winSize.width/2 + 150,winSize.height/2 - 170))
	label:setAnchorPoint(cc.p(0,0.5))
	img:addChild(label)
	Utils:createCDLabel(label,diffTime,COLOR_TYPE.YELLOW,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.FRONT, GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16')..'：',COLOR_TYPE.YELLOW,COLOROUTLINE_TYPE.YELLOW,22,function ()
		MainSceneMgr:hideNBSkyUI()
	end)
end



function NBSkyUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	local bgImg2 = bgImg:getChildByName("bg_img2")
	self:adaptUI(bgImg, bgImg1)
	
	local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
	bgImg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

	local closeBtn = bgImg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideNBSkyUI()
		end
	end)

	local yiciImg = bgImg1:getChildByName('yici_img')
	self:updatePanel()
	local conf = GameData:getConfData('activities')['sky_limit_buy']
	local data = UserData:getUserObj():getActicityInfoByKey('sky_limit_buy')
	local openDay = conf.openDay
	local duration = conf.duration
	local delayDays = conf.delayDays
	local nowTime = Time.getCorrectServerTime()
	local beginTime = GlobalApi:convertTime(2,data.open_day) + openDay*24*3600 + 5*3600
	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400 
	local diffTime = endTime - nowTime
	self:timeoutCallback(bgImg1,diffTime)
	yiciImg:setLocalZOrder(9)
end

return NBSkyUI