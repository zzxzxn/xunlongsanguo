-- local RescpSceneCell =  require("script/app/ui/rankinglist/")

local RankingListUI = class("RankingListUI", BaseUI)

-- fucking config begin
-- dark
-- color: cfba8d
-- stroke: 4e3111, 2
-- shadow: 4e3111, (0, -1)
-- light
-- color: fff7e4
-- stroke: 23275c, 2
-- shadow: 4e3111, (0, -1)
local menuTree = {
	[1] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_zhandouli1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_zhandouli2.png',
		text = 'RANKING_TITLE_1',
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
		msg_mod = 'user',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[2] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_leitai1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_leitai2.png',
		text = 'RANKING_TITLE_2',
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
		msg_mod = 'arena',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[3] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_ta1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_ta2.png',
		text = 'RANKING_TITLE_3',
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
		msg_mod = 'tower',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[4] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_huangcheng1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_huangcheng2.png',
		text = 'RANKING_TITLE_4',
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
		msg_mod = 'country',
		msg_act = 'rank_list',
		msg_arg = {},
		sub_title = {
			[1] = {
				bg_nor = 'uires/ui/rankinglist/rlist_tiao4.png',
				bg_sel = 'uires/ui/rankinglist/rlist_ban.png',
				text = 'RANKING_SUBTITLE_1',
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
				msg_arg = { country = 1 },
			},
			[2] = {
				bg_nor = 'uires/ui/rankinglist/rlist_tiao4.png',
				bg_sel = 'uires/ui/rankinglist/rlist_ban.png',
				text = 'RANKING_SUBTITLE_2',
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
				msg_arg = { country = 2 },
			},
			[3] = {
				bg_nor = 'uires/ui/rankinglist/rlist_tiao4.png',
				bg_sel = 'uires/ui/rankinglist/rlist_ban.png',
				text = 'RANKING_SUBTITLE_3',
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
				msg_arg = { country = 3 },
			},			
		}
	},
	[5] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_zhengba1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_zhengba2.png',
		text = 'RANKING_TITLE_5',
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
		msg_mod = 'worldwar',
		msg_act = 'get_rank_list',
		msg_arg = {},
		sub_title = {
			[1] = {
				bg_nor = 'uires/ui/rankinglist/rlist_tiao4.png',
				bg_sel = 'uires/ui/rankinglist/rlist_ban.png',
				text = 'RANKING_SUBTITLE_4',
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
				msg_arg = {},
			},
			[2] = {
				bg_nor = 'uires/ui/rankinglist/rlist_tiao4.png',
				bg_sel = 'uires/ui/rankinglist/rlist_ban.png',
				text = 'RANKING_SUBTITLE_5',
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
				msg_arg = { last = 1 },
			},
		}
	},
	[6] = {
		bg_nor = 'uires/ui/rankinglist/rlist_huangtiao.png',
		bg_sel = 'uires/ui/rankinglist/rlist_zitiao.png',
		icon_nor = 'uires/ui/rankinglist/rlist_juntuan1.png',
		icon_sel = 'uires/ui/rankinglist/rlist_juntuan2.png',
		text = 'RANKING_TITLE_6',
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
		msg_mod = 'legion',
		msg_act = 'rank_list',
		msg_arg = {},
	},
}
-- fucking config over

function RankingListUI:ctor(page)
	self.uiIndex = GAME_UI.UI_RANKINGLISTUI
	self.select = nil
	self.subselect = nil
	self.menulist = nil
	self.userbg = nil
	self.page = page or 1

	self.rankinglist = {}
	-- self.fightforce_panel = nil
	-- self.fightforce_data = nil
	-- self.arena_panel = nil
	-- self.arena_data = nil
	-- self.tower_panel = nil
	-- self.tower_data = nil
	-- self.capital_panel = nil
	-- self.capital_data = nil
	-- self.worldwar_panel = nil
	-- self.worldwar_data = nil
	-- self.legion_panel = nil
	-- self.legion_data = nil
end

function RankingListUI:init()
	local bg = self.root:getChildByName('bgimg')
	bg:setTouchEnabled(true)
	local top = bg:getChildByName('topimg')
	local close = top:getChildByName('close')
	close:addClickEventListener(function ()
		RankingListMgr:hideRankingListMain()
	end)

	local bottom = bg:getChildByName('bottomimg')

	local menubg = bg:getChildByName('menubg')
	self.menulist = menubg:getChildByName('menulist')

	self.userbg = bg:getChildByName('userbg')

	-- adapt shit ui begin
	local winSize = cc.Director:getInstance():getWinSize()
	bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

	local bgSize = bg:getContentSize()

	local topSize = top:getContentSize()
	top:setPosition(cc.p(bgSize.width / 2, (bgSize.height + winSize.height - topSize.height) / 2))

	local closeSize = close:getContentSize()
	close:setPositionX((topSize.width + winSize.width - closeSize.width) / 2)

	local bottomSize = bottom:getContentSize()
	bottom:setPosition(cc.p(bgSize.width / 2, (bgSize.height - winSize.height + bottomSize.height) / 2))

	local menubgSize = menubg:getContentSize()
	local menuSize = self.menulist:getContentSize()
	local userSize = self.userbg:getContentSize()
	local intervalWidth = (winSize.width - menuSize.width - userSize.width) / 3
	local edgeWidth = (bgSize.width - winSize.width) / 2

	menubg:setPosition(cc.p(intervalWidth + edgeWidth + menuSize.width / 2, 
		(bgSize.height - winSize.height + menubgSize.height) / 2))
	self.menulist:setContentSize(cc.size(272, winSize.height - bottomSize.height - topSize.height))
	self.menulist:setPosition(cc.p(-24, bottomSize.height))

	self.userbg:setPosition(cc.p(edgeWidth + 2 * intervalWidth + menuSize.width + userSize.width / 2, 
		 bottomSize.height + (bgSize.height - winSize.height + userSize.height) / 2 + 6))
	self.userbg:setContentSize(cc.size(679, winSize.height - bottomSize.height - topSize.height - 12))
	-- adapt end without user list ...

	self:initMenu()
end

function RankingListUI:initMenu()
	local cell = cc.CSLoader:createNode('csb/rankinglistmenucell.csb')
	local template = cell:getChildByName('tiao')
	self.menulist:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.menulist:setItemModel(template)
	for i,v in ipairs(menuTree) do
		self.menulist:pushBackDefaultItem()

		local tiao = self.menulist:getItem(i - 1)
		local text = tiao:getChildByName('text')
		local icon = tiao:getChildByName('icon')

		tiao:loadTexture(v.bg_nor)
		icon:loadTexture(v.icon_nor)
		text:setString(GlobalApi:getLocalStr(v.text))
		text:setTextColor(v.text_nor_color)
		text:enableOutline(v.text_nor_stroke, v.text_nor_stroke_size)
		text:enableShadow(v.text_nor_shadow, v.text_nor_shadow_size)

		tiao:setTouchEnabled(true)
		tiao:addClickEventListener(function ()
			self:onClickMenu(i)
		end)
	end

	self:onClickMenu(self.page)
end

function RankingListUI:onClickMenu(idx)
	-- special FUCKING OPRATION...
	if 4 == idx and 0 == UserData:getUserObj():getCountry() then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('RANKING_NOCOUNTRY_TIP'), COLOR_TYPE.RED)
		return
	end
	-- some subtitle in this title ...WTF
	if self.select ~= nil then
		if menuTree[self.select].sub_title ~= nil then
			for i,v in ipairs(menuTree[self.select].sub_title) do
				self.menulist:removeItem(self.select)
			end
		end

		-- origin item
		local tiaoOri = self.menulist:getItem(self.select - 1)
		local textOri = tiaoOri:getChildByName('text')
		local iconOri = tiaoOri:getChildByName('icon')
		local vOri = menuTree[self.select]

		tiaoOri:loadTexture(vOri.bg_nor)
		iconOri:loadTexture(vOri.icon_nor)
		textOri:setString(GlobalApi:getLocalStr(vOri.text))
		textOri:setTextColor(vOri.text_nor_color)
		textOri:enableOutline(vOri.text_nor_stroke, vOri.text_nor_stroke_size)
		textOri:enableShadow(vOri.text_nor_shadow, vOri.text_nor_shadow_size)
		tiaoOri:setTouchEnabled(true)

		-- hide rightpage
		if self.rankinglist[self.select].panel ~= nil then
			self.rankinglist[self.select].panel:setVisible(false)
		elseif self.rankinglist[self.select][self.subselect] ~= nil and
			self.rankinglist[self.select][self.subselect].panel ~= nil then
			self.rankinglist[self.select][self.subselect].panel:setVisible(false)
		end

		-- select other main card ... reset subselect ...
		if self.select ~= idx then
			self.subselect = 1
		end
	end

	-- target item
	local tiaoTar = self.menulist:getItem(idx - 1)
	local textTar = tiaoTar:getChildByName('text')
	local iconTar = tiaoTar:getChildByName('icon')
	local vTar = menuTree[idx]

	tiaoTar:loadTexture(vTar.bg_sel)
	iconTar:loadTexture(vTar.icon_sel)
	textTar:setString(GlobalApi:getLocalStr(vTar.text))
	textTar:setTextColor(vTar.text_sel_color)
	textTar:enableOutline(vTar.text_sel_stroke, vTar.text_sel_stroke_size)
	textTar:enableShadow(vTar.text_sel_shadow, vTar.text_sel_shadow_size)
	tiaoTar:setTouchEnabled(false)

	self.select = idx

	if menuTree[idx].sub_title ~= nil then
		local subcell = cc.CSLoader:createNode('csb/rankinglistsubmenucell.csb')
		local subtemplate = subcell:getChildByName('subtitle')
		for i,v in ipairs(menuTree[idx].sub_title) do
			local subtitle = subtemplate:clone()
			local subtext = subtitle:getChildByName('text')
			subtitle:loadTexture(v.bg_nor)
			subtext:setString(GlobalApi:getLocalStr(v.text))
			subtext:setTextColor(v.text_nor_color)
			subtext:enableOutline(v.text_nor_stroke, v.text_nor_stroke_size)
			subtext:enableShadow(v.text_nor_shadow, v.text_nor_shadow_size)
			subtitle:setTouchEnabled(true)
			subtitle:addClickEventListener(function ()
				self:onClickSubmenu(idx, i)
			end)

			self.menulist:insertCustomItem(subtitle, idx + i - 1)
		end

		self:onClickSubmenu(idx, 1)
	else
		-- send msg ...
		if self.rankinglist[idx] ~= nil and
			self.rankinglist[idx].panel ~= nil and
			self.rankinglist[idx].data ~= nil then
			self:updateContentPage()
		else
			self:postMessage(idx)
		end
	end
end

function RankingListUI:onClickSubmenu(pidx, idx)
	if self.subselect ~= nil then
		-- origin item
		local tiaoOri = self.menulist:getItem(pidx + self.subselect - 1)
		local textOri = tiaoOri:getChildByName('text')
		local vOri = menuTree[pidx].sub_title[self.subselect]

		tiaoOri:loadTexture(vOri.bg_nor)
		textOri:setString(GlobalApi:getLocalStr(vOri.text))
		textOri:setTextColor(vOri.text_nor_color)
		textOri:enableOutline(vOri.text_nor_stroke, vOri.text_nor_stroke_size)
		textOri:enableShadow(vOri.text_nor_shadow, vOri.text_nor_shadow_size)
		tiaoOri:setTouchEnabled(true)

		-- hide rightpage
		if self.rankinglist[pidx] ~= nil and
			self.rankinglist[pidx][self.subselect] ~= nil and
			self.rankinglist[pidx][self.subselect].panel ~= nil and
			self.rankinglist[pidx][self.subselect].data ~= nil then
			self.rankinglist[pidx][self.subselect].panel:setVisible(false)
		end
	end

	-- target item
	local tiaoTar = self.menulist:getItem(pidx + idx - 1)
	local textTar = tiaoTar:getChildByName('text')
	local vTar = menuTree[pidx].sub_title[idx]

	tiaoTar:loadTexture(vTar.bg_sel)
	textTar:setString(GlobalApi:getLocalStr(vTar.text))
	textTar:setTextColor(vTar.text_sel_color)
	textTar:enableOutline(vTar.text_sel_stroke, vTar.text_sel_stroke_size)
	textTar:enableShadow(vTar.text_sel_shadow, vTar.text_sel_shadow_size)
	tiaoTar:setTouchEnabled(false)

	self.subselect = idx

	if self.rankinglist[pidx] ~= nil and
		self.rankinglist[pidx][tonumber(idx)] ~= nil and
		self.rankinglist[pidx][tonumber(idx)].panel ~= nil and
		self.rankinglist[pidx][tonumber(idx)].data ~= nil then
		self:updateContentPage()
	else
		self:postMessage(pidx, idx)
	end
end

function RankingListUI:postMessage(idx, subtitle)
	local args = menuTree[idx].msg_arg
	if menuTree[idx].sub_title ~= nil then
		args = menuTree[idx].sub_title[subtitle].msg_arg
	end
	MessageMgr:sendPost(menuTree[idx].msg_act, menuTree[idx].msg_mod,json.encode(args),function (jsonObj)
		if 0 ~= jsonObj.code then
			return
		end

		print('*********************************************************')
		print(json.encode(jsonObj))
		if self.rankinglist[idx] == nil then
			self.rankinglist[idx] = {}
		end
		if menuTree[idx].sub_title ~= nil then
			self.rankinglist[idx][subtitle] = {}
			self.rankinglist[idx][subtitle].panel = nil
			self.rankinglist[idx][subtitle].data = jsonObj.data
		else
			self.rankinglist[idx].panel = nil
			self.rankinglist[idx].data = jsonObj.data			
		end
		self:updateContentPage()
	end)
end

function RankingListUI:updateContentPage()
	local idx = self.select
	local subidx = self.subselect
	if self.rankinglist[idx] == nil then
		return
	end

	if self.rankinglist[idx].panel ~= nil then
		self.rankinglist[idx].panel:setVisible(true)
		return
	end

	if self.rankinglist[idx][subidx] ~= nil and
		self.rankinglist[idx][subidx].panel ~= nil and
		self.rankinglist[idx][subidx].data ~= nil then
		-- special fuck opration...
		if 5 == idx and self.rankinglist[idx][1].data.count == 1 then
			local t = self.menulist:getItem(self.select + 1)
			t:setTouchEnabled(false)
			t:getChildByName('text')
				:setTextColor(cc.c4b(192, 192, 192, 255))
			ShaderMgr:setGrayForWidget(t)
			-- ShaderMgr:setGrayForWidget(t1)
		end
		-- special end
		self.rankinglist[idx][subidx].panel:setVisible(true)
		return
	end

	if self.rankinglist[idx].panel == nil then
		if 1 == idx then
			self:makeFightForcePage()
		elseif 2 == idx then
			self:makeArenaPage()
		elseif 3 == idx then
			self:makeTowerPage()
		elseif 4 == idx then
			self:makeCityPage()
		elseif 5 == idx then
			self:makeWorldWarPage()
		elseif 6 == idx then
			self:makeLegionPage()
		end
	end
end

function RankingListUI:makeFightForcePage()
	-- rlff = ranking list fight force
	local panel = cc.CSLoader:createNode('csb/rlffpanel.csb')
	self.rankinglist[1].panel = panel
	self.userbg:addChild(panel)

	-- fucking adapt
	local userbgSize = self.userbg:getContentSize()
	local head = panel:getChildByName('head')
	local userlist = panel:getChildByName('list')

	head:setPosition(cc.p(11.5, userbgSize.height - head:getContentSize().height - 6))
	userlist:setPosition(cc.p(11.5, 12))
	userlist:setContentSize(cc.size(656, userbgSize.height - head:getContentSize().height - 18))
	userlist:setClippingEnabled(true)

	-- setting panel
	local data = self.rankinglist[1].data
	head:getChildByName('myrank'):setString(data.rank)
	local fightforce_icon = head:getChildByName('fightforce_icon')
	local fightforce_tx = cc.LabelAtlas:_create(RoleData:getFightForce(), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforce_tx:setAnchorPoint(cc.p(0, 0.5))
	fightforce_tx:setPosition(cc.p(fightforce_icon:getContentSize().width + 4, fightforce_icon:getContentSize().height / 2))
	fightforce_icon:addChild(fightforce_tx)
	local frame = head:getChildByName('frame')
	frame:getChildByName('name'):setString(UserData:getUserObj():getName())
	frame:getChildByName('lv_tx'):setString(UserData:getUserObj():getLv())

	local rt = xx.RichText:create()
	rt:setContentSize(cc.size(80, 64))
	local rtl1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('RANKING_COM_YESTERDAY') .. '\n', 25)
	local rti2 = xx.RichTextImage:create('uires/ui/common/arrow_up.png')
	local rtl3 = xx.RichTextLabel:create(math.abs(data.rank - data.last_rank))
	if data.last_rank >= data.rank then
		rtl1:setColor(cc.c4b(36, 255, 0, 255))
		rtl1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		rtl3:setColor(cc.c4b(36, 255, 0, 255))
		rtl3:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	else
		rtl1:setColor(cc.c4b(255, 30, 0, 255))
		rtl1:setStroke(COLOROUTLINE_TYPE.RED, 1)
		rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

		rti2:setImg('uires/ui/common/arrow_down.png')

		rtl3:setColor(cc.c4b(255, 30, 0, 255))
		rtl3:setStroke(COLOROUTLINE_TYPE.RED, 1)
		rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	end
	rt:addElement(rtl1)
	rt:addElement(rti2)
	rt:addElement(rtl3)
	rt:setAlignment('middle')
	rt:setPosition(cc.p(168, 44))
	head:addChild(rt)

	-- add list 
	local cell = cc.CSLoader:createNode('csb/rlffcell.csb')
	local template = cell:getChildByName('bgimg')
	userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
	userlist:setItemModel(template)
	for i, v in ipairs(data.rank_list) do
		-- print(i,v)
		userlist:pushBackDefaultItem()

		local tiao = userlist:getItem(i - 1)
		local cap_img = tiao:getChildByName('cup_img')
		if i <= 3 then
			cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
		else
			cap_img:setVisible(false)
			local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
			cap_tx:setPosition(cc.p(60, 44))
			cap_tx:setScale(1.2)
			tiao:addChild(cap_tx)
		end

		local user = tiao:getChildByName('frame')
		local username = user:getChildByName('name')
		username:setString(v.un)
		username:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		username:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local userlevel = user:getChildByName('lv_tx')
		userlevel:setString(v.level)
		userlevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		userlevel:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local ffi = tiao:getChildByName('fightforce_icon')
		local fight_force = cc.LabelAtlas:_create(v.fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
		fight_force:setAnchorPoint(cc.p(0, 0.5))
		ffi:setScale(0.7)
		fight_force:setPosition(cc.p(ffi:getContentSize().width + 4, ffi:getContentSize().height / 2))
		ffi:addChild(fight_force)

		if math.mod(i, 2) ~= 1 then
			tiao:setCascadeOpacityEnabled(false)
			tiao:setOpacity(0)
		end

		tiao:getChildByName('info'):addClickEventListener(function (  )
			BattleMgr:showCheckInfo(v.uid,'world','arena')
		end)
	end
end

function RankingListUI:makeArenaPage()
	-- rlff = ranking list fight force
	local panel = cc.CSLoader:createNode('csb/rlapanel.csb')
	self.rankinglist[2].panel = panel
	self.userbg:addChild(panel)

	-- fucking adapt
	local userbgSize = self.userbg:getContentSize()
	local head = panel:getChildByName('head')
	local userlist = panel:getChildByName('list')

	head:setPosition(cc.p(11.5, userbgSize.height - head:getContentSize().height - 6))
	userlist:setPosition(cc.p(11.5, 12))
	userlist:setContentSize(cc.size(656, userbgSize.height - head:getContentSize().height - 18))
	userlist:setClippingEnabled(true)

	-- setting panel
	local data = self.rankinglist[2].data
	if data.rank == nil then
		local t = ccui.Text:create(GlobalApi:getLocalStr('RANKING_NOFIND'), "font/gamefont.ttf", 30)
		t:setPosition(60, 44)
		t:setTextColor(cc.c4b(36, 255, 0, 255))
		t:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
		t:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		head:addChild(t)
		head:getChildByName('myrank'):setVisible(false)
	else
		head:getChildByName('myrank'):setString(data.rank)

		local rt = xx.RichText:create()
		rt:setContentSize(cc.size(100, 64))
		local rtl1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('RANKING_COM_YESTERDAY') .. '\n', 25)
		local rti2 = xx.RichTextImage:create('uires/ui/common/arrow_up.png')
		local rtl3 = xx.RichTextLabel:create(math.abs(data.rank - data.last_rank))
		if data.last_rank >= data.rank then
			rtl1:setColor(cc.c4b(36, 255, 0, 255))
			rtl1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
			rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

			rtl3:setColor(cc.c4b(36, 255, 0, 255))
			rtl3:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
			rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		else
			rtl1:setColor(cc.c4b(255, 30, 0, 255))
			rtl1:setStroke(COLOROUTLINE_TYPE.RED, 1)
			rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

			rti2:setImg('uires/ui/common/arrow_down.png')

			rtl3:setColor(cc.c4b(255, 30, 0, 255))
			rtl3:setStroke(COLOROUTLINE_TYPE.RED, 1)
			rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		end

		if data.last_rank == 0 then
			rtl1:setString(GlobalApi:getLocalStr('RANKING_LIST_UNRANK'))
			rt:addElement(rtl1)
		else
			rt:addElement(rtl1)
			rt:addElement(rti2)
			rt:addElement(rtl3)
		end
		rt:setAlignment('middle')
		rt:setPosition(cc.p(168, 44))
		head:addChild(rt)
	end

	local frame = head:getChildByName('frame')
	frame:getChildByName('name'):setString(UserData:getUserObj():getName())
	frame:getChildByName('lv_tx'):setString(UserData:getUserObj():getLv())

	local fightforce_icon = head:getChildByName('fightforce_icon')
	local fightforce_tx = cc.LabelAtlas:_create(RoleData:getFightForce(), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforce_tx:setAnchorPoint(cc.p(0, 0.5))
	fightforce_tx:setPosition(cc.p(fightforce_icon:getContentSize().width + 4, fightforce_icon:getContentSize().height / 2))
	fightforce_icon:addChild(fightforce_tx)

	-- add list 
	local cell = cc.CSLoader:createNode('csb/rlacell.csb')
	local template = cell:getChildByName('bgimg')
	userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
	userlist:setItemModel(template)
	for i, v in ipairs(data.rank_list) do
		-- print(i,v)
		userlist:pushBackDefaultItem()

		local tiao = userlist:getItem(i - 1)
		local cap_img = tiao:getChildByName('cup_img')
		if i <= 3 then
			cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
		else
			cap_img:setVisible(false)
			local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
			cap_tx:setPosition(cc.p(60, 44))
			cap_tx:setScale(1.2)
			tiao:addChild(cap_tx)
		end

		local user = tiao:getChildByName('frame')
		local username = user:getChildByName('name')
		username:setString(v.un)
		username:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		username:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local userlevel = user:getChildByName('lv_tx')
		userlevel:setString(v.level)
		userlevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		userlevel:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local ffi = tiao:getChildByName('fightforce_icon')
		local fight_force = cc.LabelAtlas:_create(v.fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
		fight_force:setAnchorPoint(cc.p(0, 0.5))
		ffi:setScale(0.7)
		fight_force:setPosition(cc.p(ffi:getContentSize().width + 4, ffi:getContentSize().height / 2))
		ffi:addChild(fight_force)

		if math.mod(i, 2) ~= 1 then
			tiao:setCascadeOpacityEnabled(false)
			tiao:setOpacity(0)
		end

		tiao:getChildByName('info'):addClickEventListener(function (  )
			BattleMgr:showCheckInfo(v.uid,'world','arena')
		end)
	end
end

function RankingListUI:makeTowerPage()
	-- rlff = ranking list fight force
	local panel = cc.CSLoader:createNode('csb/rltpanel.csb')
	self.rankinglist[3].panel = panel
	self.userbg:addChild(panel)

	-- fucking adapt
	local userbgSize = self.userbg:getContentSize()
	local head = panel:getChildByName('head')
	local userlist = panel:getChildByName('list')

	head:setPosition(cc.p(11.5, userbgSize.height - head:getContentSize().height - 6))
	userlist:setPosition(cc.p(11.5, 12))
	userlist:setContentSize(cc.size(656, userbgSize.height - head:getContentSize().height - 18))
	userlist:setClippingEnabled(true)

	-- setting panel
	local data = self.rankinglist[3].data
	if 0 == data.rank then
		head:getChildByName('myrank'):setVisible(false)
		cc.Label:createWithTTF(GlobalApi:getLocalStr('RANKING_NO_INLIST'), "font/gamefont.ttf", 28)
			:setTextColor(COLOR_TYPE.GREEN)
			:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
			:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
			:setPosition(cc.p(65, 44))
			:addTo(head)
	else
		head:getChildByName('myrank'):setString(data.rank)
	end
	head:getChildByName('star_tx'):setString(data.star)
	local frame = head:getChildByName('frame')
	frame:getChildByName('name'):setString(UserData:getUserObj():getName())
	frame:getChildByName('lv_tx'):setString(UserData:getUserObj():getLv())

	-- add list 
	local cell = cc.CSLoader:createNode('csb/rltcell.csb')
	local template = cell:getChildByName('bgimg')
	userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
	userlist:setItemModel(template)
	for i, v in ipairs(data.rank_list) do
		-- print(i,v)
		userlist:pushBackDefaultItem()

		local tiao = userlist:getItem(i - 1)
		local cap_img = tiao:getChildByName('cup_img')
		if i <= 3 then
			cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
		else
			cap_img:setVisible(false)
			local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
			cap_tx:setPosition(cc.p(60, 44))
			cap_tx:setScale(1.2)
			tiao:addChild(cap_tx)
		end

		local user = tiao:getChildByName('frame')
		local username = user:getChildByName('name')
		username:setString(v.un)
		username:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		username:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local userlevel = user:getChildByName('lv_tx')
		userlevel:setString(v.level)
		userlevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		userlevel:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local star_tx = tiao:getChildByName('star_tx')
		star_tx:setString(v.star)
		star_tx:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		star_tx:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		if math.mod(i, 2) ~= 1 then
			tiao:setCascadeOpacityEnabled(false)
			tiao:setOpacity(0)
		end

		tiao:getChildByName('info'):addClickEventListener(function (  )
			BattleMgr:showCheckInfo(v.uid,'world','arena')
		end)
	end
end

function RankingListUI:makeCityPage()
	-- rlff = ranking list fight force
	local panel = cc.CSLoader:createNode('csb/rlcpanel.csb')
	self.rankinglist[4][tonumber(self.subselect)].panel = panel
	self.userbg:addChild(panel)

	-- fucking adapt
	local userbgSize = self.userbg:getContentSize()
	local head = panel:getChildByName('head')
	local userlist = panel:getChildByName('list')

	head:setPosition(cc.p(11.5, userbgSize.height - head:getContentSize().height - 6))
	userlist:setPosition(cc.p(11.5, 12))
	userlist:setContentSize(cc.size(656, userbgSize.height - head:getContentSize().height - 18))
	userlist:setClippingEnabled(true)

	-- setting panel
	local data = self.rankinglist[4][self.subselect].data
	local frame = head:getChildByName('frame')
	frame:getChildByName('name'):setString(UserData:getUserObj():getName())
	frame:getChildByName('lv_tx'):setString(UserData:getUserObj():getLv())

	local fightforce_icon = head:getChildByName('fightforce_icon')
	local fightforce_tx = cc.LabelAtlas:_create(RoleData:getFightForce(), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforce_tx:setAnchorPoint(cc.p(0, 0.5))
	fightforce_tx:setPosition(cc.p(fightforce_icon:getContentSize().width + 4, fightforce_icon:getContentSize().height / 2))
	fightforce_icon:addChild(fightforce_tx)

	local rt = xx.RichText:create()
	local conf = GameData:getConfData("position")
	local wang = string.split(conf[1].title, '/')
	local country = UserData:getUserObj():getCountry()
	if country == 0 then
		frame:getChildByName('country'):setVisible(false)
		data.position = nil
	elseif data.position == nil then
		data.position = 32
	end

	if 1 == country then
		frame:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_wei.png')
	elseif 2 == country then
		frame:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_shu.png')
	elseif 3 == country then
		frame:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_wu.png')
	end

	if data.position == nil then
		local rtl = xx.RichTextLabel:create(GlobalApi:getLocalStr('RANKING_NOCOUNTRY'), 25, COLOR_TYPE.GREEN)
		rtl:setStroke(cc.c4b(0,0,0,255), 2)
		rtl:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
		rt:addElement(rtl)
	else
		if 1 == data.position then
			local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_1.png')
			local tx = xx.RichTextLabel:create('\n' .. GlobalApi:getLocalStr('COUNTRY_KING_' .. self.subselect), 25, COLOR_QUALITY[2])
			tx:setStroke(cc.c4b(0,0,0,255), 2)
			tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
			rt:addElement(img)
			rt:addElement(tx)
		elseif 2 == data.position then
			local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_2.png')
			local tx = xx.RichTextLabel:create('\n' .. conf[2].title, 25, COLOR_QUALITY[3])
			tx:setStroke(cc.c4b(0,0,0,255), 2)
			tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
			rt:addElement(img)
			rt:addElement(tx)
		elseif 3 == data.position then
			local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_3.png')
			local tx = xx.RichTextLabel:create('\n' .. conf[3].title, 25, COLOR_QUALITY[3])
			tx:setStroke(cc.c4b(0,0,0,255), 2)
			tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
			rt:addElement(img)
			rt:addElement(tx)
		else
			local str = '【' .. conf[data.position].posName .. '】\n' .. conf[data.position].title
			local tx = xx.RichTextLabel:create(str, 25)
			tx:setColor(COLOR_QUALITY[tonumber(conf[data.position].quality)])
			tx:setStroke(cc.c4b(0,0,0,255), 2)
			tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
			rt:addElement(tx)
		end
	end
	rt:setAlignment('middle')
	rt:format(true)
	local rtSize = rt:getElementsSize()
	rt:setContentSize(rtSize)
	rt:setPosition(cc.p(74, 44))
	rt:format(true)
	head:addChild(rt)

	-- add list 
	local cell = cc.CSLoader:createNode('csb/rlccell.csb')
	local template = cell:getChildByName('bgimg')
	userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
	userlist:setItemModel(template)
	local sum = 0
	local k = 1
	while data.ranks[tostring(k)] ~= nil do
		local rankTable = data.ranks[tostring(k)]
		for i, v in ipairs(rankTable) do
			userlist:pushBackDefaultItem()

			local tiao = userlist:getItem(sum + i - 1)

			local rt = xx.RichText:create()
			if 1 == k then
				local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_1.png')
				local tx = xx.RichTextLabel:create('\n' .. GlobalApi:getLocalStr('COUNTRY_KING_' .. self.subselect), 25, COLOR_QUALITY[2])
				tx:setStroke(cc.c4b(0,0,0,255), 2)
				tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt:addElement(img)
				rt:addElement(tx)
			elseif 2 == k then
				local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_2.png')
				local tx = xx.RichTextLabel:create('\n' .. conf[2].title, 25, COLOR_QUALITY[3])
				tx:setStroke(cc.c4b(0,0,0,255), 2)
				tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt:addElement(img)
				rt:addElement(tx)
			elseif 3 == k then
				local img = xx.RichTextImage:create('uires/ui/rankinglist/rlist_crown_3.png')
				local tx = xx.RichTextLabel:create('\n' .. conf[3].title, 25, COLOR_QUALITY[3])
				tx:setStroke(cc.c4b(0,0,0,255), 2)
				tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt:addElement(img)
				rt:addElement(tx)
			else
				local str = '【' .. conf[k].posName .. '】\n' .. conf[k].title
				local tx = xx.RichTextLabel:create(str, 25)
				tx:setColor(COLOR_QUALITY[tonumber(conf[k].quality)])
				tx:setStroke(cc.c4b(0,0,0,255), 2)
				tx:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt:addElement(tx)
			end
			rt:setAlignment('middle')
			rt:format(true)
			local rtSize = rt:getElementsSize()
			rt:setContentSize(rtSize)
			rt:setPosition(cc.p(74, 44))
			rt:format(true)
			tiao:addChild(rt)

			local user = tiao:getChildByName('frame')
			if 1 == self.subselect then
				user:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_wei.png')
			elseif 2 == self.subselect then
				user:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_shu.png')
			elseif 3 == self.subselect then
				user:getChildByName('country'):loadTexture('uires/ui/rankinglist/rlist_wu.png')
			end
			local username = user:getChildByName('name')
			username:setString(v.un)
			username:enableOutline(cc.c4b(0, 0, 0, 255), 1)
			username:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
			local userlevel = user:getChildByName('lv_tx')
			userlevel:setString(v.level)
			userlevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
			userlevel:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
			local ffi = tiao:getChildByName('fightforce_icon')
			local fight_force = cc.LabelAtlas:_create(v.fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			fight_force:setAnchorPoint(cc.p(0, 0.5))
			ffi:setScale(0.7)
			fight_force:setPosition(cc.p(ffi:getContentSize().width + 4, ffi:getContentSize().height / 2))
			ffi:addChild(fight_force)

			if math.mod(sum + i, 2) ~= 1 then
				tiao:setCascadeOpacityEnabled(false)
				tiao:setOpacity(0)
			end

			tiao:getChildByName('info'):addClickEventListener(function (  )
				BattleMgr:showCheckInfo(v.uid,'world','country')
			end)
		end
		k = k + 1
		sum = sum + #rankTable
	end
end

function RankingListUI:makeWorldWarPage()
	if self.rankinglist[5][self.subselect].data.count == 1 then
		local t = self.menulist:getItem(self.select + 1)
		t:setTouchEnabled(false)
		t:getChildByName('text')
			:setTextColor(cc.c4b(192, 192, 192, 255))
		ShaderMgr:setGrayForWidget(t)
	end
	-- rlff = ranking list fight force
	local panel = cc.CSLoader:createNode('csb/rlwwpanel.csb')
	self.rankinglist[5][self.subselect].panel = panel
	self.userbg:addChild(panel)

	if self.subselect == 1 then
		-- fucking adapt
		local userbgSize = self.userbg:getContentSize()
		local head = panel:getChildByName('head')
		local userlist = panel:getChildByName('list')

		head:setPosition(cc.p(11.5, userbgSize.height - head:getContentSize().height - 6))
		userlist:setPosition(cc.p(11.5, 12))
		userlist:setContentSize(cc.size(656, userbgSize.height - head:getContentSize().height - 18))
		userlist:setClippingEnabled(true)

		-- setting panel
		local data = self.rankinglist[5][self.subselect].data
		if data.rank == nil then
			head:getChildByName('cup_img'):setVisible(false)
		elseif data.rank > 0 and data.rank <= 3 then
			head:getChildByName('cup_img'):loadTexture('uires/ui/arena/cup_' .. data.rank .. '.png')
		else
			head:getChildByName('cup_img'):setVisible(false)
			local rt1 = xx.RichText:create()
			rt1:setContentSize(cc.size(124, 88))
			if 0 == data.rank then
				local rtl1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('RANKING_NO_INLIST'), 25, COLOR_TYPE.GREEN)
				rtl1:setStroke(cc.c4b(0,0,0,255), 2)
				rtl1:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt1:addElement(rtl1)
			else
				local rtl1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('RANKING_SELFRANK'), 25, COLOR_TYPE.ORANGE)
				rtl1:setStroke(cc.c4b(0,0,0,255), 2)
				rtl1:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				local rtl2 = xx.RichTextLabel:create('\n' .. tostring(data.rank), 25, COLOR_TYPE.WHITE)
				rtl2:setStroke(cc.c4b(0,0,0,255), 2)
				rtl2:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))
				rt1:addElement(rtl1)
				rt1:addElement(rtl2)
			end
			rt1:setAlignment('middle')
			rt1:format(true)
			local rtSize = rt1:getElementsSize()
			rt1:setContentSize(rtSize)
			rt1:setPosition(cc.p(74, 44))
			rt1:format(true)
			head:addChild(rt1)
		end

		local frame = head:getChildByName('frame')
		frame:getChildByName('name'):setString(UserData:getUserObj():getName())
		frame:getChildByName('lv_tx'):setString(GlobalData:getSelectSeverUid() .. GlobalApi:getLocalStr('FU'))
		head:getChildByName('score'):setString(data.score)

		-- add list 
		local cell = cc.CSLoader:createNode('csb/rlwwcell.csb')
		local template = cell:getChildByName('bgimg')
		userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
		userlist:setItemModel(template)
		for i, v in ipairs(data.rank_list) do
			-- print(i,v)
			userlist:pushBackDefaultItem()

			local tiao = userlist:getItem(i - 1)
			local cap_img = tiao:getChildByName('cup_img')
			if i <= 3 then
				cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
			else
				cap_img:setVisible(false)
				local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
				cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
				cap_tx:setPosition(cc.p(60, 44))
				cap_tx:setScale(1.2)
				tiao:addChild(cap_tx)
			end

			local user = tiao:getChildByName('frame')
			user:getChildByName('name')
				:setString(v.name)
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			user:getChildByName('lv_tx')
				:setString(v.sid .. GlobalApi:getLocalStr('FU'))
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			tiao:getChildByName('score'):setString(v.score)
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			if math.mod(i, 2) ~= 1 then
				tiao:setCascadeOpacityEnabled(false)
				tiao:setOpacity(0)
			end

			tiao:getChildByName('info'):addClickEventListener(function (  )
				BattleMgr:showCheckInfo(v.uid,'universe')
			end)
		end
	elseif self.subselect == 2 then
		local userbgSize = self.userbg:getContentSize()
		panel:getChildByName('head')
			:setVisible(false)
		local userlist = panel:getChildByName('list')

		userlist:setPosition(cc.p(11.5, 12))
		userlist:setContentSize(cc.size(656, userbgSize.height - 18))
		userlist:setClippingEnabled(true)

		-- add list 
		local data = self.rankinglist[5][self.subselect].data
		local cell = cc.CSLoader:createNode('csb/rlwwcell.csb')
		local template = cell:getChildByName('bgimg')
		userlist:setGravity(ccui.ListViewGravity.centerHorizontal)
		userlist:setItemModel(template)

		local dayConf = GameData:getConfData('worldwarglory')
		for i, v in ipairs(data.rank_list) do
			-- print(i,v)
			userlist:pushBackDefaultItem()

			local tiao = userlist:getItem(i - 1)
			local cap_img = tiao:getChildByName('cup_img')
			if i <= 3 then
				cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
			else
				cap_img:setVisible(false)
				local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
				cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
				cap_tx:setPosition(cc.p(60, 44))
				cap_tx:setScale(1.2)
				tiao:addChild(cap_tx)
			end

			tiao:getChildByName('fightforce_icon')
				:setVisible(false)

			local user = tiao:getChildByName('frame')
			user:getChildByName('name')
				:setString(v.name)
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			user:getChildByName('lv_tx')
				:setString(v.sid .. GlobalApi:getLocalStr('FU'))
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			local str = ''
			for m, n in ipairs(dayConf) do
				if i >= n.rank then
					if dayConf[m + 1] == nil or
						i < dayConf[m + 1].rank then
						str = n.glory
						break
					end
				end
			end

			tiao:getChildByName('score'):setString(str)
				:enableOutline(cc.c4b(0, 0, 0, 255), 1)
				:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

			if math.mod(i, 2) ~= 1 then
				tiao:setCascadeOpacityEnabled(false)
				tiao:setOpacity(0)
			end

			tiao:getChildByName('info'):addClickEventListener(function (  )
				BattleMgr:showCheckInfo(v.uid, 'universe')
			end)
		end
	end
end

function RankingListUI:makeLegionPage()
	local panel_list = ccui.ListView:create()
	self.rankinglist[6].panel = panel_list
	self.userbg:addChild(panel_list)

	local userbgSize = self.userbg:getContentSize()
	panel_list:setContentSize(cc.size(656, userbgSize.height - 18))
	panel_list:setPosition(cc.p(11.5, 12))
	panel_list:setClippingEnabled(true)

	local data = self.rankinglist[6].data

	-- add list 
	local cell = cc.CSLoader:createNode('csb/rllcell.csb')
	local template = cell:getChildByName('bgimg')
	panel_list:setGravity(ccui.ListViewGravity.centerHorizontal)
	panel_list:setItemModel(template)
	for i, v in ipairs(data.list) do
		panel_list:pushBackDefaultItem()

		local tiao = panel_list:getItem(i - 1)

		local cap_img = tiao:getChildByName('cup_img')
		if i <= 3 then
			cap_img:loadTexture('uires/ui/arena/cup_' .. i .. '.png')
		else
			cap_img:setVisible(false)
			local cap_tx = cc.LabelAtlas:_create(i, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
			cap_tx:setAnchorPoint(cc.p(0.5, 0.5))
			cap_tx:setPosition(cc.p(60, 44))
			cap_tx:setScale(1.2)
			tiao:addChild(cap_tx)
		end

		local user = tiao:getChildByName('frame')
		local username = user:getChildByName('name')
		username:setString(v.name)
		username:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		username:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local userlevel = user:getChildByName('lv_tx')
		userlevel:setString(v.level)
		userlevel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		userlevel:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		if math.mod(i, 2) ~= 1 then
			tiao:setCascadeOpacityEnabled(false)
			tiao:setOpacity(0)
		end

		tiao:getChildByName('info'):addClickEventListener(function (  )
			print('click info ... waiting ui...WTF')
		end)
	end
end

return RankingListUI


