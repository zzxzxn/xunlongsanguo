local OpenRankUI = class("OpenRankUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
-- 160 249 338 99 43
local RANK_TOP_STYPE = {
	'arena_top',
	'level_top',
	'ff_top',
}
local RANK_STYPE = {
	'arena_rank',
	'level_rank',
	'ff_rank',
}
local ACTIVITY_STYPE = {
	'open_rank_arena',
	'open_rank_level',
	'open_rank_ff',
}
function OpenRankUI:ctor(data)
	self.uiIndex = GAME_UI.UI_OPEN_RANK
	self.data = data
	self.maxBottomNum = 0
	self.page = 1
end

function OpenRankUI:rankListPanel()
	local size1
	local diffSize = 5
	local conf = GameData:getConfData('avrank')[self.page]
	local meImg = self.bottomSv:getChildByName('me_img')
	meImg:setLocalZOrder(999)
	meImg:setVisible(false)
	local maxNum = #conf
	local pos = {cc.p(160,52),cc.p(249,52),cc.p(338,52)}
	for i=2,maxNum do
		local bgImg = self.bottomSv:getChildByName('bg_img_'..i)
		if not bgImg then
			local node = cc.CSLoader:createNode('csb/openrankcell.csb')
			bgImg = node:getChildByName('bg_img')
			bgImg:removeFromParent(false)
			bgImg:setName('bg_img_'..i)
			self.bottomSv:addChild(bgImg)
		end
		bgImg:setVisible(true)
		size1 = bgImg:getContentSize()
		bgImg:setPosition(cc.p(17,(maxNum - i)*(size1.height + diffSize) + diffSize))
		local rankImg = bgImg:getChildByName('rank_img')
		local rankTx = bgImg:getChildByName('rank_tx')
		if i <= 3 then
			rankImg:setVisible(true)
			rankImg:loadTexture('uires/ui/report/report_rank_'..i..'.png')
			rankTx:setString('')
			if self.data[RANK_STYPE[self.page]] == i then
				meImg:setPosition(cc.p(22,(maxNum - i)*(size1.height + diffSize) + diffSize + size1.height/2))
				meImg:setVisible(true)
			end
		else
			rankImg:setVisible(false)
			local conf1 = conf[i + 1]
			if conf1 then
				rankTx:setString(conf[i].rank..'-'..(conf1.rank - 1))
				if conf[i].rank <= self.data[RANK_STYPE[self.page]] and self.data[RANK_STYPE[self.page]] <= conf1.rank - 1 then
					meImg:setPosition(cc.p(22,(maxNum - i)*(size1.height + diffSize) + diffSize + size1.height/2))
					meImg:setVisible(true)
				end
			else
				rankTx:setString((conf[i].rank - 1)..GlobalApi:getLocalStr('OPEN_RANK_DESC_5'))
				if self.data[RANK_STYPE[self.page]] > conf[i].rank - 1 then
					meImg:setPosition(cc.p(22,(maxNum - i)*(size1.height + diffSize) + diffSize + size1.height/2))
					meImg:setVisible(true)
				end
			end
		end
		for j=1,3 do
			local awardBgImg = bgImg:getChildByName('award_bg_img_'..j)
			if not awardBgImg then
				local tab = ClassItemCell:create()
				awardBgImg = tab.awardBgImg
				awardBgImg:setName('award_bg_img_'..j)
				bgImg:addChild(awardBgImg)
				awardBgImg:setScale(0.8)
				awardBgImg:setPosition(pos[j])
			end
			local awards = DisplayData:getDisplayObjs(conf[i].award)
			if awards[j] then
				awardBgImg:setVisible(true)
				ClassItemCell:updateItem(awardBgImg,awards[j],2)
				awards[j]:setLightEffect(awardBgImg)
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
						AudioMgr.PlayAudio(11)
					elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[j],false)
					end
				end)
			else
				awardBgImg:setVisible(false)
			end
		end
	end

    local size = self.bottomSv:getContentSize()
	self.bottomSv:setInnerContainerSize(cc.size(size.width,(maxNum - 1)*(size1.height + diffSize)+ diffSize))
	for i=2,self.maxBottomNum do
		local bgImg = self.bottomSv:getChildByName('bg_img_'..i)
		if bgImg then
			if i > maxNum then
				bgImg:setVisible(false)
			else
				bgImg:setVisible(true)
			end
		end
	end
	self.maxBottomNum = maxNum
end

function OpenRankUI:updateBottomPanel()
	local nameTx = self.bottomImg:getChildByName('name_tx')
	local vipImg = self.bottomImg:getChildByName('vip_img')
	local vipTx = self.bottomImg:getChildByName('vip_tx')
	local zhanBgImg = self.bottomImg:getChildByName('zhan_bg_img')
	local fightforceTx = zhanBgImg:getChildByName('fightforce_tx')
	local expBg = self.bottomImg:getChildByName('exp_bg')
	local bar = expBg:getChildByName('bar')
	local barTx = expBg:getChildByName('bar_tx')
	local lvImg = expBg:getChildByName('lv_img')
	local lvTx = lvImg:getChildByName('lv_tx')
	nameTx:setString(self.data[RANK_TOP_STYPE[self.page]].un)
	vipTx:setString(self.data[RANK_TOP_STYPE[self.page]].vip)
	local posY = nameTx:getPositionY()
	vipImg:setPosition(cc.p(nameTx:getPositionX() + nameTx:getContentSize().width/2 + 20,posY))
	vipTx:setPosition(cc.p(vipImg:getPositionX() + vipImg:getContentSize().width/2 + 10,posY))
	if self.page == 2 then
		zhanBgImg:setVisible(false)
		expBg:setVisible(true)
		local lvConf = GameData:getConfData("level")[self.data[RANK_TOP_STYPE[self.page]].level]
		local per = math.floor(self.data[RANK_TOP_STYPE[self.page]].xp/lvConf.exp*10000)/100
		bar:setPercent(per)
		barTx:setString(per..'%')
		lvTx:setString(self.data[RANK_TOP_STYPE[self.page]].level)
	else
		fightforceTx:setString(self.data[RANK_TOP_STYPE[self.page]].fight_force)
		zhanBgImg:setVisible(true)
		expBg:setVisible(false)
	end

	if self.eSpineAni then
		self.eSpineAni:removeFromParent()
	end

	local heroConf = GameData:getConfData("hero")
	local promote = nil
    local weapon_illusion = nil
    local wing_illusion = nil
    if self.data[RANK_TOP_STYPE[self.page]].promote and self.data[RANK_TOP_STYPE[self.page]].promote[1] then
        promote = self.data[RANK_TOP_STYPE[self.page]].promote[1]
    end

    if heroConf[tonumber(self.data[RANK_TOP_STYPE[self.page]].model)].camp == 5 then
        if self.data[RANK_TOP_STYPE[self.page]].weapon_illusion and self.data[RANK_TOP_STYPE[self.page]].weapon_illusion > 0 then
            weapon_illusion = self.data[RANK_TOP_STYPE[self.page]].weapon_illusion
        end
        if self.data[RANK_TOP_STYPE[self.page]].wing_illusion and self.data[RANK_TOP_STYPE[self.page]].wing_illusion > 0 then
            wing_illusion = self.data[RANK_TOP_STYPE[self.page]].wing_illusion
        end
    end
	local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
	self.eSpineAni = GlobalApi:createLittleLossyAniByRoleId(tonumber(self.data[RANK_TOP_STYPE[self.page]].model), changeEquipObj)
	self.eSpineAni:setPosition(cc.p(0,0))
	self.eSpineAni:getAnimation():play('idle', -1, 1)
	self.eSpineAni:setScale(0.8)
	local spine_node = self.bottomImg:getChildByName("spine_node")
	spine_node:addChild(self.eSpineAni)

	local conf = GameData:getConfData('avrank')
	local pos = {cc.p(89,43),cc.p(179,43),cc.p(269,43)}
	for i=1,3 do
		local awardBgImg = self.bottomImg:getChildByName('award_bg_img_'..i)
		if not awardBgImg then
			local tab = ClassItemCell:create()
			awardBgImg = tab.awardBgImg
			awardBgImg:setName('award_bg_img_'..i)
			self.bottomImg:addChild(awardBgImg)
			awardBgImg:setScale(0.8)
			awardBgImg:setPosition(pos[i])
		end
		local awards = DisplayData:getDisplayObjs(conf[self.page][1].award)
		if awards[i] then
			ClassItemCell:updateItem(awardBgImg,awards[i],2)
			awards[i]:setLightEffect(awardBgImg)
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(awards[i],false)
				end
			end)
		end
	end

	self:rankListPanel()
end

function OpenRankUI:updatePageBtn()
	for i=1,3 do
		local infoTx = self.pageBtns[i]:getChildByName('info_tx')
		if i == self.page then
			self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
			self.pageBtns[i]:setTouchEnabled(false)
			infoTx:setColor(COLOR_TYPE.PALE)
			infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
			infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		else
			self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
			self.pageBtns[i]:setTouchEnabled(true)
			infoTx:setColor(COLOR_TYPE.DARK)
			infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
			infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
		end
	end
end


function OpenRankUI:updateTopPanel()
	local descTx5 = self.topImg:getChildByName('desc_tx_5')
	local descTx7 = self.topImg:getChildByName('desc_tx_7')
	local titleTx4 = self.topImg:getChildByName('title_tx_4')
	local expBg = self.topImg:getChildByName('exp_bg')
	local bar = expBg:getChildByName('bar')
	local barTx = expBg:getChildByName('bar_tx')
	local lvImg = expBg:getChildByName('lv_img')
	local lvTx = lvImg:getChildByName('lv_tx')
	self.infoTx:setString(GlobalApi:getLocalStr('OPEN_RANK_RANK_DESC_'..self.page))

	if self.page == 3 then
		titleTx4:setVisible(true)
		descTx7:setVisible(true)
		expBg:setVisible(false)
		titleTx4:setString(GlobalApi:getLocalStr('OPEN_RANK_TITLE_DESC_2')..'：')
		descTx7:setString(self.data.fight_force)
	elseif self.page == 1 then
		titleTx4:setVisible(false)
		descTx7:setVisible(false)
		expBg:setVisible(false)
	elseif self.page == 2 then
		titleTx4:setVisible(true)
		descTx7:setVisible(false)
		expBg:setVisible(true)
		local per = math.floor(UserData:getUserObj():lvPrecent()*100)/100
		bar:setPercent(per)
		barTx:setString(per..'%')
		lvTx:setString(UserData:getUserObj():getLv())
		titleTx4:setString(GlobalApi:getLocalStr('OPEN_RANK_DESC_6')..'：')
	end

	if self.data[RANK_STYPE[self.page]] and self.data[RANK_STYPE[self.page]] ~= 0 then
		descTx5:setString(self.data[RANK_STYPE[self.page]])
	else
		descTx5:setString(GlobalApi:getLocalStr('FRIENDS_DESC_33'))
	end
	local conf = GameData:getConfData('avrank')[self.page]
	local str1 = GlobalApi:getLocalStr('OPEN_RANK_DESC_11')
	local str2 = string.format(GlobalApi:getLocalStr('OPEN_RANK_DESC_2'),conf[#conf].rank - 1)
	local str3 = GlobalApi:getLocalStr('OPEN_RANK_DESC_3')..GlobalApi:getLocalStr('OPEN_RANK_DESC_1')
	if not self.rts then
		local richText = xx.RichText:create()
		richText:setAlignment('left')
		richText:setVerticalAlignment('middle')
		richText:setContentSize(cc.size(590, 30))

		local re1 = xx.RichTextLabel:create(str1,22,cc.c3b(89,31,8))
		local re2 = xx.RichTextLabel:create(str2,22,cc.c3b(30,140,0))
		local re3 = xx.RichTextLabel:create(str3,22,cc.c3b(89,31,8))
		re1:setShadow(cc.c4b(255,255,255,255), cc.size(0,-1))
		re2:setShadow(cc.c4b(255,255,255,255), cc.size(0,-1))
		re3:setShadow(cc.c4b(255,255,255,255), cc.size(0,-1))
		re1:setStroke(COLOROUTLINE_TYPE.WHITE, 0)
		re2:setStroke(COLOROUTLINE_TYPE.WHITE, 0)
		re3:setStroke(COLOROUTLINE_TYPE.WHITE, 0)
		re1:setFont('font/gamefont.ttf')
		re2:setFont('font/gamefont.ttf')
		re3:setFont('font/gamefont.ttf')
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:setAnchorPoint(cc.p(0,1))
		richText:setPosition(cc.p(130 ,140))
		self.topImg:addChild(richText)
		self.rts = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
	else
		self.rts.re1:setString(str1)
		self.rts.re2:setString(str2)
		self.rts.re3:setString(str3)
		self.rts.richText:format(true)
	end
end

function OpenRankUI:updateTime(isEnd)
	local conf = GameData:getConfData('activities')[ACTIVITY_STYPE[self.page]]
	local openServerTime = UserData:getUserObj():getServerOpenTime()
	local nowTime = Time.getCorrectServerTime()
	local now = Time.date('*t', openServerTime)
	local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
	local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
	local beginTime = newOpenServerTime + conf.openDay*24*3600
	local diffTime = beginTime + conf.duration* 86400 - nowTime
	local descTx5 = self.topImg:getChildByName('desc_tx_5')
	local descTx6 = self.topImg:getChildByName('desc_tx_6')
    local label = descTx6:getChildByTag(9999)
    local size = descTx6:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setPosition(pos or cc.p(38,0))
    label:setAnchorPoint(cc.p(0,0.5))
    descTx6:addChild(label)
	if diffTime <= 0 then
		descTx5:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC43'))
		descTx6:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC43'))
		self.rankBtn:setVisible(false)
		if isEnd then
			MessageMgr:sendPost("get_open_rank", "activity", "{}", function (jsonObj)
				local data = jsonObj.data
				if jsonObj.code == 0 then
					self.data = data
					self:updateTopPanel()
					self:updateBottomPanel()
					local descTx5_2 = self.topImg:getChildByName('desc_tx_5')
					local descTx6_2 = self.topImg:getChildByName('desc_tx_6')
					descTx5_2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC43'))
					descTx6_2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC43'))
				end
			end)
		end
		return
	end
	self.rankBtn:setVisible(true)
	descTx6:setString('')
	local day = math.floor(diffTime/86400)
	local time = diffTime%86400
	Utils:createCDLabel(label,time,cc.c3b(30,140,0,255),COLOR_TYPE.WHITE,CDTXTYPE.FRONT,string.format(GlobalApi:getLocalStr('STR_TIME6'),day),
		cc.c3b(30,140,0,255),COLOR_TYPE.WHITE,22,function ()
			self:updateTime(true)
		end,nil,true,ENABLESHADOW_TYPE.WHITE)
	end

function OpenRankUI:updatePanel()
	self:updatePageBtn()
	self:updateTopPanel()
	self:updateBottomPanel()
	self:updateTime()
end

function OpenRankUI:init()
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
			if not self.hadGetBack then
				UserData:getUserObj():setResBackSign(0)
			end
			MainSceneMgr:hideOpenRankUI()
		end
	end)

	local topImg = bgImg1:getChildByName('top_bg_img')
	self.topImg = topImg
	local bottomImg = bgImg1:getChildByName('bottom_bg_img')
	self.bottomImg = bottomImg
	self.bottomSv = bottomImg:getChildByName('sv')
	self.bottomSv:setScrollBarEnabled(false)

	local titleTx1 = topImg:getChildByName('title_tx_1')
	local titleTx2 = topImg:getChildByName('title_tx_2')
	local titleTx3 = topImg:getChildByName('title_tx_3')
	local descTx1 = topImg:getChildByName('desc_tx_1')
	local descTx2 = topImg:getChildByName('desc_tx_2')
	local descTx3 = topImg:getChildByName('desc_tx_3')
	local descTx4 = topImg:getChildByName('desc_tx_4')
	titleTx1:setString(GlobalApi:getLocalStr('OPEN_RANK_TITLE_DESC_1')..'：')
	titleTx2:setString(GlobalApi:getLocalStr('RANKING_SELFRANK'))
	titleTx3:setString(GlobalApi:getLocalStr('REMAINDER_TIME'))

	local rankBtn = topImg:getChildByName('rank_btn')
	self.infoTx = rankBtn:getChildByName('info_tx')
	self.rankBtn = rankBtn
	rankBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local page = {2,11,1}
			RankingListMgr:showRankingListMain(page[self.page],nil,page)
		end
	end)
	self.pageBtns = {}
	for i=1,3 do
		local pageBtn = bgImg1:getChildByName('page_'..i..'_btn')
		local infoTx = pageBtn:getChildByName('info_tx')
		self.pageBtns[i] = pageBtn
		infoTx:setString(GlobalApi:getLocalStr('OPEN_RANK_BTN_DESC_'..i))
		pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self.page = i
				self:updatePanel()
			end
		end)
	end
	self:updatePanel()
end

return OpenRankUI