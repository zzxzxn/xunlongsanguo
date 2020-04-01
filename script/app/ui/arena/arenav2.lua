local ArenaV2UI = class('ArenaV2UI', BaseUI)

-- config begin
local c = {
	[1] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_huangcheng1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_huangcheng2.png',
		text = 'ARENA_TITLE1',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 2,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 2,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		link = nil,
	},
	[2] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/arena_v2/meiri2.png',
		icon_sel = 'uires/ui/arena_v2/meiri.png',
		text = 'ARENA_TITLE2',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 2,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 2,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		link = nil,
	},
	[3] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_bang1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_bang2.png',
		text = 'ARENA_TITLE3',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 2,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 2,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		link = nil,
	},
	[4] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_zhanbao1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_zhanbao2.png',
		new_img = 'uires/ui/common/new_img.png',
		text = 'ARENA_TITLE4',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 2,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 2,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		link = nil,
	},
}
local rtIntSize = cc.size(10, 33)
local closeIntSize = cc.size(5, -5)
local menulist_width = 285
local exp_rt_pos = cc.p(213, 19)
-- config end

function ArenaV2UI:ctor(jsonObj, battleReportJson)
	-- ui data
	self.uiIndex = GAME_UI.UI_ARENA_V2
	self.defaultItem = nil
	self.menulist = nil
	self.bg = nil
	self.refreshBtn = nil

	-- logic data
	self.data = jsonObj.data
	self.eRefresh = false
	self.first = true
	self.counter = 0
	self.enemyArray = {}

	-- late display
	self.added_exp = 0
	self.ext_award = {}
	self.entry = nil

	-- logic operat
	if battleReportJson ~= nil then
		print('----------------------------------------------------')
		print(json.encode(battleReportJson))

		-- lose
		if battleReportJson.data.diff == 0 then
			self.added_exp = GlobalApi:getGlobalValue('arenaLossXp')
		else
			self.added_exp = GlobalApi:getGlobalValue('arenaWinXp')
		end
		self.ext_award = battleReportJson.data.ext_awards
	end
	-- -- analyze enemy data
	-- for k, v in pairs(jsonObj.data.enemy) do
	-- 	local obj = v
	-- 	obj.uid = tonumber(k)
	-- 	table.insert(self.enemyArray, obj)
	-- end
	-- table.sort(self.enemyArray, function (a, b)
	-- 	return a.rank < b.rank
	-- end)
	-- self.data.enemy = nil

	ArenaMgr.myRank = jsonObj.data.rank
	ArenaMgr.myLevel = jsonObj.data.level
	-- ui-logic data ...WTF
	local nowTime = GlobalData:getServerTime()
	self.challenge_cd = jsonObj.data.challenge_cd
	self.challengeCD = (jsonObj.data.challenge_cd - nowTime)or 0
	UserData:getUserObj():setArenaCD(self.challenge_cd)
	self.select = {}
end

function ArenaV2UI:init()
	local bgNode = self.root:getChildByName('bg_node')
	local bg = bgNode:getChildByName('bg')
	-- ShaderMgr:makeBling(bg, 1)
	self.bg = bg
	-- self:adaptUI(bg, nil, true)
	local winSize = cc.Director:getInstance():getWinSize()
	bgNode:setPosition(cc.p(winSize.width/2,winSize.height/2))
	self.closeBtn = self.root:getChildByName('close')
	self.closeBtn:addClickEventListener(function()
            AudioMgr.PlayAudio(11)
			ArenaMgr:hideArenaV2()
		end)
	local bottomNode = self.root:getChildByName('bottom_node')
	self.refreshBtn = bottomNode:getChildByName('bottom')
		:getChildByName('right')
		:getChildByName('refresh')

	self.coolBtn = bottomNode:getChildByName('bottom')
		:getChildByName('right')
		:getChildByName('cool_btn')

	local tx = self.coolBtn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('TRAINING_ACC_BTN'))
	self.coolBtn:addClickEventListener(function()
            AudioMgr.PlayAudio(11)
            
            local vip = UserData:getUserObj():getVip()
            if vip < tonumber(GlobalApi:getGlobalValue('arenaColdSpeedVipLimit')) then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('ARENA_COLD_SPEED_VIP_LIMIT_DES'),tonumber(GlobalApi:getGlobalValue('arenaColdSpeedVipLimit'))), COLOR_TYPE.RED)
                return
            end

            local nowTime = GlobalData:getServerTime()
            local costs = math.ceil((self.challenge_cd - nowTime) / tonumber(GlobalApi:getGlobalValue("arenaChanllengeUnitTime"))*tonumber(GlobalApi:getGlobalValue("arenaChanllengeUnitCost")))
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ARENA_DESC_1'),costs), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
			    local args = {}
			    MessageMgr:sendPost('clear_challenge_cd','arena',json.encode(args),function (response)
			        local code = response.code
			        local data = response.data
			        if code == 0 then
			            local costs = data.costs
			            if costs then
			                GlobalApi:parseAwardData(costs)
			            end
				        local label = self.right:getChildByTag(9999)
				        if label then
				            label:removeFromParent()
				        end
						self.challengeCD = 0
						UserData:getUserObj():setArenaCD(0)
						self.fightTx:setVisible(true)
						self.fightImg:setVisible(true)
						self.coolBtn:setVisible(false)
						self.refreshBtn:setVisible(true)
			        end
			    end)
			end)
		end)

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.ARENAV)
    btn:setPosition(cc.p(310 ,winSize.height - 30))
    self.root:addChild(btn)

	-- adapt code could be...here ...
	-- get data ...
	-- MessageMgr:sendPost('get', 'arena', '{}', function (jsonObj)
	-- 	if jsonObj.code == 0 then
	-- 		self.data = jsonObj.data

	-- 		-- analyze enemy data
	-- 		for k, v in pairs(jsonObj.data.enemy) do
	-- 			local obj = v
	-- 			obj.uid = tonumber(k)
	-- 			table.insert(self.enemyArray, obj)
	-- 		end
	-- 		table.sort(self.enemyArray, function (a, b)
	-- 			return a.rank < b.rank
	-- 		end)
	-- 		self.data.enemy = nil

	-- 		ArenaMgr.myRank = jsonObj.data.rank
	-- 		self:_initLinks()
	-- 		self:onUpdate()
	-- 	end
	-- end)

	-- FUCKING brain hole, begin actions
	self:beginSettings()
	self:_initLinks()
	self:onUpdate()
end

function ArenaV2UI:_initLinks()
	c[1].link = function (  )
		MainSceneMgr:showShop(31,{min = 31,max = 32}, self.data.max_rank)
	end

	c[2].link = function (  )
		-- ArenaMgr:showArenaV2Award()
		ArenaMgr:showArenaV2Daily()
	end

	c[3].link = function (  )
		RankingListMgr:showRankingListMain(2)
	end

	c[4].link = function (  )
		ArenaMgr:showArenaV2Report()
	end
end

function ArenaV2UI:onUpdate()
	if self.data == nil then
		return
	end
	local bg = self.bg
	bg:setTouchEnabled(true)

	-- configs
	local awardsConf = GameData:getConfData('arenadaily')
	local levelConf = GameData:getConfData('arenalevel')

	-- adapt ui common data
	local winSize = cc.Director:getInstance():getWinSize()
	local bgSize = bg:getContentSize()
	local horizontalInterval = (bgSize.width - winSize.width) / 2
	local verticalInterval = (bgSize.height - winSize.height) / 2

	-- adapt close button
	self.closeBtn:setAnchorPoint(cc.p(1, 1))
	self.closeBtn:setPosition(cc.p(winSize.width - closeIntSize.width,
			winSize.height - closeIntSize.height - 20))

	-- adapt left ui
	local leftNode = self.root:getChildByName('left_node')
	local left = leftNode:getChildByName('left')
		-- :setPosition(cc.p(0, winSize.height / 2))
		:setLocalZOrder(999)
	leftNode:setPosition(cc.p(0,winSize.height))
	local leftSize = left:getContentSize()

	local rank_bg = left:getChildByName('rank_bg')
	local rank_bg_size = rank_bg:getContentSize()
	local rank_bg_y = (leftSize.height - winSize.height - rank_bg_size.height) / 2 + winSize.height

	-- rank_bg:setPositionY(rank_bg_y)
	rank_bg:getChildByName('best')
		:setString(self.data.max_rank)

	rank_bg:getChildByName('tx1')
		:setString(GlobalApi:getLocalStr('STR_HISTORY_HIGHEST'))

	rank_bg:getChildByName('tx')
		:setString(GlobalApi:getLocalStr('CURRENT_RANK'))

	rank_bg:getChildByName('rank')
		:setString(self.data.rank)

	-- awards  control ..
	local awardIndx = #awardsConf
	for i, v in ipairs(awardsConf) do
		if self.data.rank <= v.rank then
			awardIndx = i
			break
		end
	end

	local level = UserData:getUserObj():getArenaLv()
	if levelConf[level] == nil then
		print('[ERROR]: arena level config can`t find target level .. ' .. level)
		return
	end
	local awardsArr = DisplayData:getDisplayObjs(awardsConf[awardIndx].award)
	local exawardsArr = DisplayData:getDisplayObjs(levelConf[level].award)
	if #awardsArr ~= #exawardsArr then
		print('[ERROR]: count between arenadaily.dat and arenalevel')
		return
	end

	for i, v in ipairs(awardsArr) do
		if v:getType() ~= exawardsArr[i]:getType() then
			print('[ERROR]: awards are not match between arenadaily.dat and arenalevel')
			return
		end
	end
	local award_bg = left:getChildByName('award_bg')
	local award_bg_size = award_bg:getContentSize()
	local award_bg_y = rank_bg_y - rank_bg_size.height / 2 - award_bg_size.height / 2
	-- award_bg:setPositionY(award_bg_y)
	award_bg:getChildByName('title')
		:setString(GlobalApi:getLocalStr('STR_SETTLEMENT_AWARD'))

	local award_rt = xx.RichText:create()
	award_rt:setRowSpacing(-12)

	for i, v in ipairs(awardsArr) do
		local award_rti = xx.RichTextImage:create(v:getIcon())
		award_rti:setScale(0.6)
		local award_rtl = xx.RichTextLabel:create(
			' ' .. v:getNum(),
			21,
			COLOR_TYPE.WHITE)
		award_rtl:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		award_rtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		award_rtl:setMinWidth(48)

		local award_rtl1 = xx.RichTextLabel:create(
			'+' .. exawardsArr[i]:getNum() .. '\n',
			21,
			COLOR_TYPE.GREEN)
		award_rtl1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		award_rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		award_rt:addElement(award_rti)
		award_rt:addElement(award_rtl)
		award_rt:addElement(award_rtl1)
	end

	-- award_rt:setAlignment('middle')
	award_rt:setVerticalAlignment('middle')
	award_rt:format(true)
	award_rt:setContentSize(award_rt:getElementsSize())
	award_rt:setPosition(cc.p(112, 70))
	award_bg:addChild(award_rt)
	-- award_bg:getChildByName('tx1')
	-- 	:setString(cashNum)

	-- award_bg:getChildByName('tx2')
	-- 	:setString(goldNum)

	-- other ui link
	self.menulist = left:getChildByName('list')
	self.menulist:setTouchEnabled(false)
	-- self.menulist:setItemsMargin(0)
	local top_y = award_bg_y - award_bg_size.height / 2
	local bottom_y = (leftSize.height - winSize.height) / 2
	-- self.menulist:setPositionY(bottom_y)
	-- self.menulist:setContentSize(cc.size(menulist_width, top_y - bottom_y))
	-- local template = self:getDefaultItemTemplate()
	-- self.menulist:setBounceEnabled(true)
	-- self.menulist:setItemModel(template)
	self.menulist:setScrollBarEnabled(false)
	for i, v in ipairs(c) do
		-- self.menulist:pushBackDefaultItem()

		local tiao = self.menulist:getChildByName('tiao_'..i)
		local text = tiao:getChildByName('text')
		local icon = tiao:getChildByName('icon')
		local newImg = tiao:getChildByName('new_img')

		self:_initSingleMenu(tiao, icon, text, newImg, v , i)

		tiao:setTouchEnabled(true)
		tiao:addClickEventListener(function ()
            AudioMgr.PlayAudio(11)
			tiao:loadTexture(v.bg_sel)
			icon:loadTexture(v.icon_sel)
			text:setString(GlobalApi:getLocalStr(v.text))
				:setTextColor(v.text_sel_color)
				:enableOutline(v.text_sel_stroke, v.text_sel_stroke_size)
				:enableShadow(v.text_sel_shadow, v.text_sel_shadow_size)
				:setTouchEnabled(false)
			table.insert(self.select, i)

			return v.link and v.link()
		end)
	end

	-- adapt bottom ui
	local bottomNode = self.root:getChildByName('bottom_node')
	local bottom = bottomNode:getChildByName('bottom')
	bottomNode:setPosition(cc.p(winSize.width/2, 0))
	local bottom_size = bottom:getContentSize()
	local ctPosX = leftSize.width + 
		(bottom_size.width - winSize.width) / 2 + 
		rtIntSize.width
	local right = bottom:getChildByName('right')
	-- right:setPositionX(winSize.width + (bottom_size.width - winSize.width) / 2)
	right:setPositionX(ctPosX + 670)

	-- challenge count
	local left = bottom:getChildByName('left')
	left:setPosition(cc.p(ctPosX, 0))
	-- local rt = xx.RichText:create()
	-- rt:setName('rich_text')

	-- rt:setAnchorPoint(cc.p(0, 0))
	-- rt:setPosition(cc.p(ctPosX, rtIntSize.height))
	-- bottom:addChild(rt)
	local xp1 = UserData:getUserObj():getArenaXp()
	local xp2 = UserData:getUserObj():getOldArenaXp()
	local level = UserData:getUserObj():getArenaLv()
	local oldLv = UserData:getUserObj():getOldArenaLv()
	local oldXp = 0
	self:updateChallengeCount(true)
	local xp = xp1 - xp2
	if xp1 ~= xp2 or oldLv ~= level then
		local lv = level
		if xp2 > xp1 or oldLv ~= level then
			lv = lv - 1
			oldXp = levelConf[lv].xp + xp1 - xp2
		else
			oldXp = xp1 - xp2
		end
		ArenaMgr:showArenaAward(1,'x'..oldXp,function()
			self:updateChallengeCount()
		end)
	end

	-- self.refreshBtn = right:getChildByName('refresh')
	local btn_tx = self.refreshBtn:getChildByName('tx')
	if self.first == false then
		btn_tx:setString(GlobalApi:getLocalStr('ARENA_CHANGE_ONCE'))
	end
	self.refreshBtn:addClickEventListener(function()
        AudioMgr.PlayAudio(11)
		self:refreshCallback(btn_tx)()
	end)
		
	self.right = right
	self.fightTx = right:getChildByName('fight_tx')
	self.fightImg = right:getChildByName('fight_img')
	self.fightTx:setString(UserData:getUserObj():getFightforce())
	if self.challengeCD > 0 then
		self.fightTx:setVisible(false)
		self.fightImg:setVisible(false)
		self.coolBtn:setVisible(true)
		self.refreshBtn:setVisible(false)
		self:timeoutCallback()
	else
		self.fightTx:setVisible(true)
		self.fightImg:setVisible(true)
		self.coolBtn:setVisible(false)
		self.refreshBtn:setVisible(true)
	end
end

function ArenaV2UI:timeoutCallback()
    if self.challengeCD then
        local label = self.right:getChildByTag(9999)
        local posX,posY = self.coolBtn:getPositionX(),self.coolBtn:getPositionY()
        if label then
            label:removeFromParent()
        end
        label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        label:setTag(9999)
        label:setPosition(cc.p(posX - 60,posY + 55))
        label:setAnchorPoint(cc.p(0.5,0.5))
        self.right:addChild(label)
        label:setVisible(true)
        Utils:createCDLabel(label,self.challengeCD,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,tx,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.ORANGE,25,function ()
			label:removeFromParent()
			self.challengeCD = 0
			self.fightTx:setVisible(true)
			self.fightImg:setVisible(true)
			self.coolBtn:setVisible(false)
			self.refreshBtn:setVisible(true)
        end)
    end
end

function ArenaV2UI:onShow()
	-- restore the menu selector
	while true do
		local i = table.remove(self.select)
		if i == nil then
			break
		end

		local tiao = self.menulist:getChildByName('tiao_'..i)
		local text = tiao:getChildByName('text')
		local icon = tiao:getChildByName('icon')
		local newImg = tiao:getChildByName('new_img')

		self:_initSingleMenu(tiao, icon, text , newImg , c[i] , i)

		tiao:setTouchEnabled(true)
	end

	-- self:updateChallengeCount()
end

function ArenaV2UI:getDefaultItemTemplate()
	if self.defaultItem ~= nil then
		return self.defaultItem
	end

	local cell = cc.CSLoader:createNode('csb/rankinglistmenucell.csb')
	local template = cell:getChildByName('tiao')
	self.defaultItem = template
	return self.defaultItem
end

function ArenaV2UI:_initSingleMenu(tiao, icon, text, newImg, data , i)
	tiao:loadTexture(data.bg_nor)
	icon:loadTexture(data.icon_nor)
	text:setString(GlobalApi:getLocalStr(data.text))
	text:setTextColor(data.text_nor_color)
	text:enableOutline(data.text_nor_stroke, data.text_nor_stroke_size)
	text:enableShadow(data.text_nor_shadow, data.text_nor_shadow_size)

	local signs = {
		ArenaMgr:getArenaShopSign(),
		false,
		false,
		UserData:getUserObj():getSignByType('arena_report'),
	}
	newImg:setVisible(signs[i])
end

function ArenaV2UI:beginSettings()
	for i = 1, 3 do
		local enemy = self.bg:getChildByName('target_' .. i)
		enemy:getChildByName('role')
			:setVisible(false)
		enemy:getChildByName('enemy_left')
			:setVisible(true)
			:loadTexture('uires/ui/arena_v2/flag_waitting.png')
	end
	self.refreshBtn:getChildByName('tx')
		:setString(GlobalApi:getLocalStr('ARENA_START_GET'))
end

function ArenaV2UI:refreshCallback(tx)
	return function ()
		self.refreshBtn:setEnabled(false)
		self.refreshBtn:getChildByName('tx')
			:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
			:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		-- send message
		MessageMgr:sendPost("refresh", "arena", "{}", function (jsonObj)
			print(json.encode(jsonObj))
			if jsonObj.code == 0 then
				self.enemyArray = {}

				-- analyze enemy data
				for k, v in pairs(jsonObj.data.enemy) do
					local obj = v
					obj.uid = tonumber(k)
					table.insert(self.enemyArray, obj)
				end
				table.sort(self.enemyArray, function (a, b)
					return a.rank < b.rank
				end)

				self.eRefresh = true
			end
		end)

		-- waiting time
		local wt = 0
		-- refresh ui
		tx:setString(GlobalApi:getLocalStr('ARENA_GETTING'))
		if self.first == false then
			-- rols go out
			self:sortTargets(false)
			AudioMgr.playEffect("media/effect/arena_role_exit.mp3", false)
			wt = 0.1
			for i = 1, 3 do
				local enemy = self.bg:getChildByName('target_' .. i)
				local role_ani = enemy:getChildByName('role_ani')
				role_ani:getAnimation():play('run', 1, -1)
				role_ani:runAction(cc.Sequence:create(
						cc.JumpBy:create(0.3, cc.p(200, -50), 30, 1), 
						cc.CallFunc:create(function (  )
							-- role:setVisible(false)
							local roleNode = enemy:getChildByName('role')
							roleNode:setVisible(false)
							roleNode:getChildByName('rank_bg')
								:removeAllChildren()
							roleNode:getChildByName('name_bg')
								:removeAllChildren()
						end), 
						cc.MoveBy:create(1, cc.p(600, 0)), 
						cc.CallFunc:create(function ()
							role_ani:removeFromParent()
							if i == 1 then
								self:sortTargets(true)
							end
						end)))
			end
		else
			-- play first flag effect
			-- wt = 0.5
			for i = 1, 3 do
				self.bg:getChildByName('target_' .. i)
					:getChildByName('enemy_left')
					-- :runAction(cc.FadeOut:create(0.5))
					:setVisible(false)
			end
		end

		-- play 'searching' flag effect
		self.bg:runAction(cc.Sequence:create(
			cc.DelayTime:create(wt), 
			cc.CallFunc:create(function ()
				if self.first == true then
					for i = 1, 3 do
						local getting = GlobalApi:createSpineByName('ui_arena_getting', "spine/ui_arena_getting/ui_arena_getting", 1)
						-- getting:setLocalZOrder(9)
						getting:setName('flag_ani')
						self.bg:getChildByName('target_' .. i)
							:addChild(getting)
						getting:setAnimation(0, 'idle', true)
					end
					self:flagAnimation(1, self:enemyAnimation())
				else
					for i = 1, 3 do
						local getting = GlobalApi:createSpineByName('ui_arena_getting', "spine/ui_arena_getting/ui_arena_getting", 1)
						-- getting:setLocalZOrder(9)
						getting:setName('flag_ani')
						self.bg:getChildByName('target_' .. i)
							:addChild(getting)
						getting:setAnimation(0, 'idle1', false)
						getting:registerSpineEventHandler(function ()
							getting:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
							getting:setAnimation(0, 'idle', true)
						end, sp.EventType.ANIMATION_COMPLETE)

						-- special ...function execute ...
						if i == 1 then
							self:flagAnimation(1, self:enemyAnimation())
						end
					end
				end
				-- set attribute first -> false
				self.first = false
			end)))
	end
end

function ArenaV2UI:flagAnimation(index, fn)
	if index > 3 then
		return
	end

	local ani = self.bg:getChildByName('target_' .. index)
		:getChildByName('flag_ani')
	ani:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.05),
		cc.CallFunc:create(function (  )
			if self.eRefresh == false then
				self:flagAnimation(index, fn)
				return
			end

			ani:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.6), 
				cc.CallFunc:create(function ()
					self:flagAnimation(index + 1, fn)
					return fn and fn(index)
				end)))
		end)))
end

function ArenaV2UI:enemyAnimation()
	return function (index)
		if self.enemyArray == nil or self.enemyArray[index] == nil then
			return
		end
		local hid = tonumber(self.enemyArray[index].model)
		local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if self.enemyArray[index].promote and self.enemyArray[index].promote[1] then
			promote = self.enemyArray[index].promote[1]
		end
		local heroConf = GameData:getConfData("hero")
        if heroConf[hid].camp == 5 then
            if self.enemyArray[index].weapon_illusion and self.enemyArray[index].weapon_illusion > 0 then
                weapon_illusion = self.enemyArray[index].weapon_illusion
            end
            if self.enemyArray[index].wing_illusion and self.enemyArray[index].wing_illusion > 0 then
                wing_illusion = self.enemyArray[index].wing_illusion
            end
        end
		local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
		local roleAni = GlobalApi:createLittleLossyAniByRoleId(hid, changeEquipObj)
		-- roleAni:setLocalZOrder(99)
		roleAni:setName('role_ani')
		roleAni:setPosition(cc.p(-600, -50))
		local enemy = self.bg:getChildByName('target_' .. index)
		enemy:addChild(roleAni, -1)
		roleAni:getAnimation():play('run', -1, 1)
		roleAni:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.4, cc.p(400, 0)), 
			cc.CallFunc:create(function ()
				enemy:getChildByName('flag_ani')
					:removeFromParent()
				AudioMgr.playEffect("media/effect/arena_role_enter.mp3", false)
			end), 
			cc.JumpBy:create(0.3, cc.p(200, 50), 50, 1), 
			cc.CallFunc:create(function ()
				roleAni:getAnimation():play('idle', -1, 1)

				-- setting role ...
				enemy:getChildByName('enemy_left')
					-- :setOpacity(100)
					:setVisible(false)

				local role_ui = enemy:getChildByName('role')
					:setVisible(true)

				role_ui:getChildByName('touch_layout')
					:addClickEventListener(function ()
            			AudioMgr.PlayAudio(11)
						local arenaMaxCount = GlobalApi:getGlobalValue('arenaMaxCount')
						local challengeCount = arenaMaxCount - self.data.count + self.data.buy_count
						if challengeCount <= 0 then
							promptmgr:showSystenHint(GlobalApi:getLocalStr('CHALLENGE_NOT_ENOUGH'), COLOR_TYPE.RED)
							return
						end
						local obj = {
							enemy = self.enemyArray[index].uid
						}
						MessageMgr:sendPost('challenge', 'arena', json.encode(obj), function (jsonObj)
							-- print('****************************************************')
							-- print(json.encode(jsonObj))
							-- print('****************************************************')
							if jsonObj.code == 0 then
								local customObj = {
									headpic = self.enemyArray[index].headpic,
									challengeUid = self.enemyArray[index].uid,
									info = jsonObj.data.info,
									enemy = jsonObj.data.enemy,
									rand1 = jsonObj.data.rand1,
									rand2 = jsonObj.data.rand2,
									rand_pos = jsonObj.data.rand_pos,
									rand_attrs = jsonObj.data.rand_attrs,
									maxRank = self.data.max_rank
								}
								if customObj.challengeUid <= 1000000 then -- 机器人
									customObj.quality = 4
								else
									customObj.quality = self.enemyArray[index].quality
								end
								BattleMgr:playBattle(BATTLE_TYPE.ARENA, customObj, function (battleReportJson)
									MainSceneMgr:showMainCity(function()
										ArenaMgr:showArenaV2(battleReportJson)
									end, nil, GAME_UI.UI_ARENA_V2)
								end)
							end
						end)
					end)

				local name_bg = role_ui:getChildByName('name_bg')
				local name_bg_size = name_bg:getContentSize()

				local nameRt = xx.RichText:create()
				local levelRtl = xx.RichTextLabel:create(
					self.enemyArray[index].level, 28, COLOR_TYPE.WHITE)
				levelRtl:setStroke(COLOR_TYPE.BLACK, 1)
				levelRtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
				levelRtl:setMinWidth(40)

				local nameRtl = xx.RichTextLabel:create(
					self.enemyArray[index].name, 28, COLOR_TYPE.WHITE)
				nameRtl:setStroke(COLOR_TYPE.BLACK, 1)
				nameRtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

				nameRt:addElement(levelRtl)
				nameRt:addElement(nameRtl)
				nameRt:format(true)
				nameRt:setContentSize(nameRt:getElementsSize())
				nameRt:setPosition(cc.p(name_bg_size.width / 2, name_bg_size.height / 2))
				name_bg:addChild(nameRt)

				local rank_bg = role_ui:getChildByName('rank_bg')
				local rank_bg_size = rank_bg:getContentSize()
				local rankRt = xx.RichText:create()

				local diRtl = xx.RichTextLabel:create(
					GlobalApi:getLocalStr('ARENA_DI'), 28, COLOR_TYPE.PALE)
				diRtl:setStroke(COLOR_TYPE.BLACK, 1)
				diRtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

				local rankRtl = xx.RichTextLabel:create(
					self.enemyArray[index].rank, 28, COLOR_TYPE.WHITE)
				rankRtl:setStroke(COLOR_TYPE.BLACK, 1)
				rankRtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

				local mingRtl = xx.RichTextLabel:create(
					GlobalApi:getLocalStr('ARENA_MING') .. '\n', 28, COLOR_TYPE.PALE)
				mingRtl:setStroke(COLOR_TYPE.BLACK, 1)
				mingRtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

				local fightRti = xx.RichTextImage:create(
					'uires/ui/common/fightbg.png')
				fightRti:setScale(0.8)

				local fightRta = xx.RichTextAtlas:create(
					tostring(self.enemyArray[index].fight_force), 
					'uires/ui/number/font_fightforce_3.png', 
					26, 
					38, 
					0)
				fightRta:setScale(0.7)

				rankRt:addElement(diRtl)
				rankRt:addElement(rankRtl)
				rankRt:addElement(mingRtl)
				rankRt:addElement(fightRti)
				rankRt:addElement(fightRta)
				rankRt:setAlignment('middle')
				rankRt:setVerticalAlignment('middle')
				rankRt:setRowSpacing(6)
				rankRt:format(true)
				rankRt:setContentSize(rankRt:getElementsSize())
				rankRt:setPosition(cc.p(rank_bg_size.width / 2, rank_bg_size.height / 2))
				rank_bg:addChild(rankRt)

				-- change refresh button text
				if self.enemyArray[index + 1] == nil then
					self.refreshBtn:setEnabled(true)
					self.refreshBtn:getChildByName('tx')
						:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
						:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				end
				self.refreshBtn:getChildByName('tx')
					:setString(GlobalApi:getLocalStr('ARENA_CHANGE_ONCE'))
			end)))
	end
end

function ArenaV2UI:buyChallengeCount()
	return function (  )
		local vip = UserData:getUserObj():getVip()
		local vipConf = GameData:getConfData("vip")
		local extraTimes = vipConf[tostring(vip)].arenaExtraChallenge
		if self.data.buy_num >= extraTimes then -- 购买次数超过上限
			promptmgr:showSystenHint(GlobalApi:getLocalStr('BUY_TIMES_OVER'), COLOR_TYPE.RED)
			-- promptmgr:showSystenHint(GlobalApi:getLocalStr("BUY_TIMES_OVER"), COLOR_TYPE.RED)
		else
			local buyConf = GameData:getConfData("buy")
			local cost = buyConf[self.data.buy_num + 1].arenaExtraChallenge
			local cash = UserData:getUserObj():getCash()
			if cash < cost then -- 元宝不足
				promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
				-- promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
			else
				promptmgr:showMessageBox(
					string.format(GlobalApi:getLocalStr("ARENA_BUY_CHALLENGE"), cost)..'\n'..string.format(GlobalApi:getLocalStr("ARENA_BUY_CHALLENGE_TIMES"),extraTimes - self.data.buy_num),
					MESSAGE_BOX_TYPE.MB_OK_CANCEL,
					function ()
						MessageMgr:sendPost("buy_count", "arena", "{}", function (jsonObj)
						print(json.encode(jsonObj))
						if jsonObj.code == 0 then
							self.data.buy_count = jsonObj.data.buy_count
							self.data.buy_num = jsonObj.data.buy_num
							GlobalApi:parseAwardData(jsonObj.data.awards)
							local costs = jsonObj.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							self:updateChallengeCount()
						end
					end)
				end)
			end
		end
	end
end

function ArenaV2UI:updateChallengeCount(ntype)
	-- print('0000000000000000000000000000000000000000000000')
	local levelConf = GameData:getConfData('arenalevel')
	local level = UserData:getUserObj():getArenaLv()
	if levelConf[level + 1] == nil then
		print('[ERROR]: Can`t find the target level in arenalevel.dat .. ' ..
			level + 1)
		-- return
	end
	local bottomNode = self.root:getChildByName('bottom_node')
	local left = bottomNode:getChildByName('bottom')
		:getChildByName('left')

	local rt1 = left:getChildByName('rt1')
	if rt1 then
		rt1:removeFromParent()
	end
	if levelConf[level + 1] then
		rt1 = xx.RichText:create()
		rt1:setName('rt1')
		rt1:setAnchorPoint(cc.p(0, 0.5))
		rt1:setPosition(cc.p(10, 24))
		left:addChild(rt1)

		local rtl1 = xx.RichTextLabel:create(
			GlobalApi:getLocalStr('ARENA_UPLEVEL_TEXT'),
			25,
			COLOR_TYPE.WHITE)
		rtl1:setFont('font/gamefont.ttf')
		rtl1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		local rtl1_1 = xx.RichTextLabel:create(
			levelConf[level + 1].arena,
			25,
			COLOR_TYPE.GREEN)
		rtl1_1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		rtl1_1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		local rti2 = xx.RichTextImage:create('uires/icon/user/arena.png')
		rti2:setScale(0.6)

		local rtl3 = xx.RichTextLabel:create(
			GlobalApi:getLocalStr('ARENA_UPLEVEL_TEXT1'),
			25,
			COLOR_TYPE.WHITE)
		rtl3:setFont('font/gamefont.ttf')
		rtl3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		rt1:setVerticalAlignment('middle')
		rt1:addElement(rtl1)
		rt1:addElement(rtl1_1)
		rt1:addElement(rti2)
		rt1:addElement(rtl3)
		rt1:format(true)
		rt1:setContentSize(rt1:getElementsSize())
	end

	local rt2 = left:getChildByName('rt2')
	if rt2 then
		rt2:removeFromParent()
	end
	rt2 = xx.RichText:create()
	rt2:setAnchorPoint(cc.p(0.5, 0.5))
	rt2:setName('rt2')
	rt2:setPosition(cc.p(210, 102))
	left:addChild(rt2)

	local arenaMaxCount = GlobalApi:getGlobalValue('arenaMaxCount')
	local challengeCount = arenaMaxCount - self.data.count + self.data.buy_count
	local rtl11 = xx.RichTextLabel:create(
		GlobalApi:getLocalStr('ARENA_CHALLENGE_COUNT'),
		25,
		COLOR_TYPE.YELLOW)
	rtl11:setFont('font/gamefont.ttf')
	rtl11:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	rtl11:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	local rtl11_1 = xx.RichTextLabel:create(
		challengeCount,
		25,
		COLOR_TYPE.GREEN)
	rtl11_1:setMinWidth(30)
	rtl11_1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
	rtl11_1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	local rti12 = xx.RichTextImage:create('uires/ui/common/icon_add2.png')
	rti12:setScale(0.8)
	rti12:setTouchEnabled(true)
	rti12:registClickEvent(self:buyChallengeCount())

	rt2:setVerticalAlignment('middle')
	rt2:addElement(rtl11)
	rt2:addElement(rtl11_1)
	rt2:addElement(rti12)
	rt2:format(true)
	rt2:setContentSize(cc.size(300, 40))

	local bar_bg = left:getChildByName('progress_bg')
	local bar = bar_bg:getChildByName('bar')
	local arenaExpTx = GlobalApi:getLocalStr('ARENA_EXP_TX')
	local bar_tx = bar_bg:getChildByName('bar_tx')
		:setVisible(false)
	-- self.rt3 = bar_bg:getChildByName('rt3')
	local rt3,level_rtl1,level_rtl2,level_rtl3
	if not self.rt3 then
		self.rt3 = xx.RichText:create()
		self.rt3:setAnchorPoint(cc.p(0.5, 0.5))
		self.rt3:setContentSize(cc.size(420, 31))
		self.rt3:setAlignment('middle')
		self.rt3:setVerticalAlignment('middle')
		self.rt3:setName('rt3')
		self.rt3:setPosition(exp_rt_pos)
		bar_bg:addChild(self.rt3)
		self.level_rtl1 = xx.RichTextLabel:create(
			GlobalApi:getLocalStr('ARENA_LEVEL_TX'),
			21,
			COLOR_TYPE.WHITE)
		self.level_rtl1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		self.level_rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		self.level_rtl2 = xx.RichTextLabel:create()
		self.level_rtl2:setColor(COLOR_TYPE.ORANGE)
		self.level_rtl2:setFontSize(21)
		self.level_rtl2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		self.level_rtl2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		self.level_rtl3 = xx.RichTextLabel:create()
		self.level_rtl3:setColor(COLOR_TYPE.WHITE)
		self.level_rtl3:setFontSize(21)
		self.level_rtl3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		self.level_rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		self.rt3:addElement(self.level_rtl1)
		self.rt3:addElement(self.level_rtl2)
		self.rt3:addElement(self.level_rtl3)
	end
	rt3 = self.rt3
	level_rtl1 = self.level_rtl1
	level_rtl2 = self.level_rtl2
	level_rtl3 = self.level_rtl3

	local addition_img = bar_bg:getChildByName("addition_img")
    addition_img:setTouchEnabled(true)
    addition_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local additionPos = bar_bg:convertToWorldSpace(cc.p(addition_img:getPosition()))
            TipsMgr:showJadeSealAdditionTips(additionPos, "arena")
        end
    end)
    local addition_tx = addition_img:getChildByName("addition_tx")
    local addition = UserData:getUserObj():getJadeSealAddition("arena")
    addition_tx:setString(addition[2] .. "%")
    if not addition[1] then
        ShaderMgr:setGrayForWidget(addition_img)
        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end

	local xp1 = UserData:getUserObj():getArenaXp()
	local xp2 = UserData:getUserObj():getOldArenaXp()
	local oldLv = UserData:getUserObj():getOldArenaLv()
	if ntype then
		if levelConf[oldLv] then
			if xp2 > levelConf[oldLv].xp then
				xp2 = levelConf[oldLv].xp
			end
			level_rtl2:setString(tostring(oldLv))
			local tstr = string.format(
				arenaExpTx,
				xp2,
				levelConf[oldLv].xp)
			level_rtl3:setString(tstr)
			bar:setPercent(xp2 / levelConf[oldLv].xp * 100)
		else
			level_rtl2:setString(tostring(level))
			local tstr = string.format(
				arenaExpTx,
				levelConf[oldLv].xp,
				levelConf[oldLv].xp)
			level_rtl3:setString(tstr)
			bar:setPercent(100)
		end
		return
	end
	UserData:getUserObj():setOldArenaLv(level)
	UserData:getUserObj():setOldArenaXp(xp1)
	local xp = xp1 - xp2
	if xp1 == xp2 and oldLv == level then
		level_rtl2:setString(tostring(level))
		local tstr = string.format(
			arenaExpTx,
			xp1,
			levelConf[level].xp)
		level_rtl3:setString(tstr)
		bar:setPercent(xp1 / levelConf[level].xp * 100)
	else
		-- get added level
		local prev_level = #levelConf
		if oldLv ~= level then
			prev_level = oldLv
		else
			prev_level = level
		end

		local prev_xp = xp2
		print('level ....... ' .. level)
		print('prev_level ....... ' .. prev_level)
		print('xp ....... ' .. xp)
		print('prev_xp ...... ' .. prev_xp)

		level_rtl2:setString(tostring(prev_level))
		local tstr = string.format(
			arenaExpTx,
			prev_xp,
			levelConf[prev_level].xp)
		level_rtl3:setString(tstr)
		bar:setPercent(prev_xp / levelConf[prev_level].xp * 100)

		local per = xp1 / levelConf[level].xp * 100
		if per > 100 then
			per = 100
		end
		require('script/app/utils/scheduleActions'):runExpBar(
			bar,
			-- 0.2,
			0.5,
			level - prev_level + 1,
			per,
			function (e)
				if e.status == SAS.START then
					rt3:setScale(1.2)
					self.closeBtn:setTouchEnabled(fasle)
				elseif e.status == SAS.FRAME then
					prev_xp = math.floor(e.percent * levelConf[prev_level].xp / 100)
					if prev_xp > levelConf[prev_level].xp then
						prev_xp = levelConf[prev_level].xp
					end
					local tstr = string.format(
						arenaExpTx,
						prev_xp,
						levelConf[prev_level].xp)
					level_rtl3:setString(tstr)
					rt3:markDirty()
				elseif e.status == SAS.SINGLE_END then
					if self.ext_award then
						local awards = DisplayData:getDisplayObjs(self.ext_award)
						ArenaMgr:showArenaAward(2,'x'..awards[1]:getNum(),function()
							GlobalApi:parseAwardData(self.ext_award)
							self:updateChallengeCount()
						end)
					end
					prev_level = level - e.count + 1
					level_rtl2:setString(tostring(prev_level))
					prev_xp = math.floor(e.percent * levelConf[prev_level].xp / 100)
					if prev_xp > levelConf[prev_level].xp then
						prev_xp = levelConf[prev_level].xp
					end
					local tstr = string.format(
						arenaExpTx, 
						prev_xp, 
						levelConf[prev_level].xp)
					level_rtl3:setString(tstr)
					rt3:markDirty()
				elseif e.status == SAS.END then
					self.closeBtn:setTouchEnabled(true)
					level_rtl2:setString(tostring(level))
					if xp1 > levelConf[level].xp then
						xp1 = levelConf[level].xp
					end
					local tstr = string.format(
						arenaExpTx,
						xp1,
						levelConf[level].xp)
					level_rtl3:setString(tstr)
					-- rt3:setScale(1)
					rt3:runAction(cc.ScaleTo:create(0.5,1))
					rt3:markDirty()
				end
			end)
	end
end

function ArenaV2UI:onHide()
	for i = 1, 4 do
		c[i].link = nil
	end
end

function ArenaV2UI:waitting(w)
	w:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function (  )
			if self.eRefresh == false then
				self:waitting(w)
				return
			end
		end)))
end

function ArenaV2UI:sortTargets(b)
	local baseZ = 100
	for i = 1, 3 do
		if b == true then
			self.bg:getChildByName('target_' .. i)
				:setLocalZOrder(baseZ + i)
		else
			self.bg:getChildByName('target_' .. i)
				:setLocalZOrder(baseZ - i)
		end
	end
end

function ArenaV2UI:cleanupLateDispalyData()
	self.added_exp = 0
	self.ext_award = {}
end

return ArenaV2UI
