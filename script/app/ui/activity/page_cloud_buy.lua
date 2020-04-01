local CloudBuy = class("CloudBuy")
local ClassItemCell = require('script/app/global/itemcell')
local CloudBuyExchageAwardUI = require("script/app/ui/activity/page_cloud_buy_exchage_award")
local CloudBuyItemUI = require("script/app/ui/activity/page_cloud_buy_item")
local CloudBuyNoticeUI = require("script/app/ui/activity/page_cloud_buy_notice")

function CloudBuy:init(msg)
	self.rootBG = self.root:getChildByName("root")

	-- printall(msg)
	self.data = msg
	-- UserData:getUserObj().activity.day_vouchsafe = self.msg
	-- local nowTime = GlobalData:getServerTime()
	-- local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
	-- local time = os.date('*t',nowTime - resetHour *3600)
	-- local now =tonumber(time.year..string.format('%02d',time.month)..string.format('%02d',time.day))
	-- self.now = now
	-- local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
	-- if self.msg.rewards and #self.msg.rewards >= 1 then
	-- 	self.nowDay = #self.msg.rewards
	-- 	if now > tonumber(self.msg.day_pay) or (now == tonumber(self.msg.day_pay) and self.msg.day_money < num) then
	-- 		self.nowDay = self.nowDay + 1
	-- 	end
	-- else
	-- 	self.nowDay = 1
	-- end
	-- local conf = GameData:getConfData('avdayvouchsafe')
	-- self.nowPage = self.nowDay
	-- if self.nowPage > #conf then
	-- 	self.nowPage = #conf
	-- end
	-- if self.nowDay > #conf then
	-- 	self.nowDay = #conf
	-- end
	-- ActivityMgr:showRightDayVouchsafeRemainTime()
	-- self:updatePanel()
	-- self:updateMark()
	-- cc.UserDefault:getInstance():setIntegerForKey(UserData:getUserObj():getUid()..'day_vouchsafe',GlobalData:getServerTime())
	self:regiesterBtnHandler()
	self:updatePanel()
	ActivityMgr:showLefTavernRecruitCue()
end

function CloudBuy:updateCount(count)
	self.data.cloud_buy.score = count
	self:updatePanel()
end

function CloudBuy:refreshPanel()
	MessageMgr:sendPost("get_cloud_buy",'activity',json.encode({}),function(jsonObj)
		local code = jsonObj.code
		if code == 0 then
			self.data = jsonObj.data
			self:updatePanel()
			if self.refresh then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
				self.refresh = false
			end
		end
	end)
end

function CloudBuy:regiesterBtnHandler()
	local leftBgImg = self.rootBG:getChildByName('left_bg_img')
	local myBtn = leftBgImg:getChildByName('my_btn')
	local infoTx = myBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_6'))
	local scoreShopBtn = leftBgImg:getChildByName('score_shop_btn')
	local infoTx = scoreShopBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_7'))
	local refreshBtn = leftBgImg:getChildByName('refresh_btn')
	local infoTx = refreshBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_10'))
	local noticeBtn = leftBgImg:getChildByName('notice_btn')
	local infoTx = noticeBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_11'))
	scoreShopBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local cloudBuyExchageAwardUI = CloudBuyExchageAwardUI.new(self.data.cloud_buy.score,self)
			cloudBuyExchageAwardUI:showUI()
		end
	end)
	myBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.data.my_buy and #self.data.my_buy > 0 then
				local cloudBuyNoticeUI = CloudBuyNoticeUI.new(self.data.my_buy,1)
				cloudBuyNoticeUI:showUI()
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_25'), COLOR_TYPE.RED)
			end
		end
	end)
	refreshBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self.refresh = true
			self:refreshPanel()
		end
	end)
	noticeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.data.award_user and #self.data.award_user > 0 then
				local cloudBuyNoticeUI = CloudBuyNoticeUI.new(self.data.award_user,2)
				cloudBuyNoticeUI:showUI()
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_26'), COLOR_TYPE.RED)
			end
		end
	end)
end

function CloudBuy:updateMark()

end

function CloudBuy:onShow()
	self:updatePanel()
end

function CloudBuy:updateLeftPanel()
	local leftBgImg = self.rootBG:getChildByName('left_bg_img')
	local node = leftBgImg:getChildByName('node')
	local awardBgImg = node:getChildByName('award_bg_img')
	local mainObj = RoleData:getMainRole()
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
		tab.awardBgImg:loadTexture(mainObj:getBgImg())
		tab.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
		tab.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
		node:addChild(tab.awardBgImg)
		awardBgImg = tab.awardBgImg
	end
	local nameTx = awardBgImg:getChildByName('name_tx')
	nameTx:setAnchorPoint(cc.p(0, 0.5))
	nameTx:setPosition(cc.p(-15,-22))
	nameTx:setString(UserData:getUserObj():getName())
	nameTx:setColor(mainObj:getNameColor())
	nameTx:setFontSize(20)
	awardBgImg:setTouchEnabled(false)

	for i=1,3 do
		local descTx = leftBgImg:getChildByName('desc_tx_'..i)
		descTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_'..i))
	end
	local level = 1
	local conf = GameData:getConfData('avcloudbuylevel')
	for i,v in ipairs(conf) do
		if self.data.cloud_buy.all_buy > v.num then
			level = v.id
		end
	end
	local str = string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_24'),conf[level].name,conf[level].prob*100)
	str = string.gsub(str,'=','%%')
	local numTx1 = leftBgImg:getChildByName('num_tx_1')
	if not numTx1 then
		numTx1 = ClassItemCell:updateTTFlabel(leftBgImg,str,nil,20,'num_tx_1',nil,cc.p(122,215),
			nil,nil,nil,nil,cc.p(0,0.5))
	end
	local colorTab = GlobalApi:getAllCharIndex(str,{string.byte('('),string.byte(')')})
	local maxLen = numTx1:getStringLength()
	for i=0,maxLen do
		local letter = numTx1:getLetter(i)
		if letter then
			if colorTab[i + 1] then
				letter:setColor(COLOR_TYPE.GREEN)
			else
				letter:setColor(COLOR_TYPE.WHITE)
			end
		end
	end

	local numTx = leftBgImg:getChildByName('num_tx')
	numTx:setString(self.data.cloud_buy.score)
end

function CloudBuy:updateRightPanel()
	local rightSv = self.rootBG:getChildByName('right_sv')
	rightSv:setScrollBarEnabled(false)
	local node = rightSv:getChildByName('node')
	if not node then
		node = cc.Node:create()
		node:setName('node')
		rightSv:addChild(node)
	end
	local size = rightSv:getContentSize()
	local conf = GameData:getConfData("avcloudbuy")
	local awardsConf = GameData:getConfData("avcloudbuyawards")
	local size1
	local str = {'LIMIT_DESC','ACTIVITY_CLOUD_BUY_DESC_5'}
	local i = 0
	for id,v in ipairs(conf) do
		if self.data.ids[tostring(id)] then
			i = i + 1
			local bgImg = node:getChildByName('bg_img_'..i)
			if not bgImg then
				local root = cc.CSLoader:createNode('csb/activity_cloud_buy_cell.csb')
				bgImg = root:getChildByName('bg_img')
				bgImg:removeFromParent(false)
				bgImg:setName('bg_img_'..i)
				node:addChild(bgImg)
				local size = bgImg:getContentSize()
				local r = (i + 1)%2
				local v = math.floor((i - 1)/2)
				bgImg:setPosition(cc.p((size.width + 8)*r + 8,-v*(size.height + 6)))

				local descTx1 = bgImg:getChildByName('desc_tx_1')
				local descTx2 = bgImg:getChildByName('desc_tx_2')
				descTx1:setString(GlobalApi:getLocalStr('STR_PRICE'))
				descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_4'))
			end
			bgImg:setVisible(true)
			size1 = bgImg:getContentSize()
			local data = self.data.ids[tostring(id)]
			local award = DisplayData:getDisplayObj(awardsConf[data.aid].awards[1])

			local barBg = bgImg:getChildByName('bar_bg')
			local bar = barBg:getChildByName('bar')
			bar:setScale9Enabled(true)
			bar:setCapInsets(cc.rect(10,15,1,1))
			bar:setContentSize(cc.size(202,46))
			local per = data.buy/awardsConf[data.aid].num*100
			bar:setPercent(per)

			local node1 = bgImg:getChildByName('node')
			local awardBgImg = node1:getChildByName('award_bg_img')
			if not awardBgImg then
				local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, node1)
				awardBgImg = tab.awardBgImg
				awardBgImg:setScale(0.8)
				-- awardBgImg:setSwallowTouches(false)
				awardBgImg:setTouchEnabled(false)
				tab.nameTx:setAnchorPoint(cc.p(0,0.5))
				tab.nameTx:setPosition(cc.p(107,65))
				tab.nameTx:setString(award:getName())
				tab.nameTx:setScale(1.25)
				tab.nameTx:setColor(award:getNameColor())
			else
				local nameTx = awardBgImg:getChildByName('name_tx')
				nameTx:setPosition(cc.p(107,65))
				nameTx:setString(award:getName())
				nameTx:setColor(award:getNameColor())
				ClassItemCell:updateItem(awardBgImg, award)
			end
			award:setLightEffect(awardBgImg)

			local numTx = bgImg:getChildByName('cash_tx')
			numTx:setString(awardsConf[data.aid].costs)

			local signImg = bgImg:getChildByName('sign_img')
			local descTx = signImg:getChildByName('desc_tx')
			signImg:loadTexture('uires/ui/common/corner_blue_'..v.type..'.png')
			descTx:setString(GlobalApi:getLocalStr(str[v.type]))
			bgImg:setTouchEnabled(true)
			bgImg:setSwallowTouches(false)
			local point1
			local point2
			local beginTime = 0
			local endTime = 0
			bgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					beginTime = socket.gettime()
					AudioMgr.PlayAudio(11)
					point1 = sender:getTouchBeganPosition()
				elseif eventType == ccui.TouchEventType.ended then
					endTime = socket.gettime()
					point2 = sender:getTouchEndPosition()
					if point1 then
						local dis =cc.pGetDistance(point1,point2)
						if dis <= 5 then
							local args = {
								id  = v.id,
							}
							MessageMgr:sendPost("get_cloud_buy_pid",'activity',json.encode(args),function(jsonObj)
								local code = jsonObj.code
								local data1 = jsonObj.data
								if code == 0 then
									local cloudBuyItemUI = CloudBuyItemUI.new(v.id,v,self.data,data1,function(data)
										self.data.ids[tostring(v.id)] = data
									end,function()
										self:refreshPanel()
									end)
									cloudBuyItemUI:showUI()
								elseif code == 102 then
									self:refreshPanel()
								end
							end)
						end
					end
				end
			end)
		end
	end
	for j=i + 1,#conf do
		local bgImg = node:getChildByName('bg_img_'..j)
		if bgImg then
			bgImg:setVisible(false)
		end
	end
	if size1 then
		local maxHeight = math.ceil(#conf/2) * (size1.height + 6) - 6
		if size.height > maxHeight then
			node:setPosition(cc.p(0,size.height))
			rightSv:setInnerContainerSize(size)
		else
			node:setPosition(cc.p(0,maxHeight))
			rightSv:setInnerContainerSize(cc.size(size.width,maxHeight))
		end
	end
end

function CloudBuy:updatePanel()
	self:updateLeftPanel()
	self:updateRightPanel()
end

return CloudBuy