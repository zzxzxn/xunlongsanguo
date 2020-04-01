local ClassRankinglistCell = require("script/app/ui/rankinglist/rankinglistcell")
local ClassItemCell = require('script/app/global/itemcell')

local RankinglistV3UI = class('RankinglistV3UI', BaseUI)

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
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_zhandouli1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_zhandouli2.png',
		title_text = 'RANKING_TITLE_TX_1',
		text = 'RANKING_TITLE_V3_1',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 24,
		msg_mod = 'user',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[2] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_leitai1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_leitai2.png',
		title_text = 'RANKING_TITLE_TX_2',
		text = 'RANKING_TITLE_V3_2',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'arena',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[3] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_ta1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_ta2.png',
		title_text = 'RANKING_TITLE_TX_3',
		text = 'RANKING_TITLE_V3_3',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 24,
		msg_mod = 'tower',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[4] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_huangcheng1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_huangcheng2.png',
		text = 'RANKING_TITLE_V3_4',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'country',
		msg_act = 'rank_list',
		msg_arg = {},
		sub_title = {
			[1] = {
				title_text = 'RANKING_TITLE_TX_4',
				text = 'RANKING_SUBTITLE_1',
				button_size = cc.size(86, 37),
				text_nor_color = cc.c3b(0xff, 0xf7, 0xe4),
				text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_stroke_size = 1,
				text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_shadow_size = cc.size(0, -1),
				msg_arg = { country = 1 },
			},
			[2] = {
				title_text = 'RANKING_TITLE_TX_5',
				text = 'RANKING_SUBTITLE_2',
				button_size = cc.size(86, 37),
				text_nor_color = cc.c3b(0xff, 0xf7, 0xe4),
				text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_stroke_size = 1,
				text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_shadow_size = cc.size(0, -1),
				msg_arg = { country = 2 },
			},
			[3] = {
				title_text = 'RANKING_TITLE_TX_6',
				text = 'RANKING_SUBTITLE_3',
				button_size = cc.size(86, 37),
				text_nor_color = cc.c3b(0xff, 0xf7, 0xe4),
				text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_stroke_size = 1,
				text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_shadow_size = cc.size(0, -1),
				msg_arg = { country = 3 },
			},			
		}
	},
	[5] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_juntuan1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_juntuan2.png',
		title_text = 'RANKING_TITLE_TX_8',
		text = 'RANKING_TITLE_V3_6',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'legion',
		msg_act = 'rank_list',
		msg_arg = {},
	},
	[6] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_zhengba1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_zhengba2.png',
		text = 'RANKING_TITLE_V3_5',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'worldwar',
		msg_act = 'get_rank_list',
		msg_arg = {},
		sub_title = {
			[1] = {
				title_text = 'RANKING_TITLE_TX_7',
				text = 'RANKING_SUBTITLE_4',
				button_size = cc.size(128, 37),
				text_nor_color = cc.c3b(0xff, 0xf7, 0xe4),
				text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_stroke_size = 1,
				text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_shadow_size = cc.size(0, -1),
				msg_arg = {},
			},
			[2] = {
				title_text = 'RANKING_TITLE_TX_7',
				text = 'RANKING_SUBTITLE_5',
				button_size = cc.size(128, 37),
				text_nor_color = cc.c3b(0xff, 0xf7, 0xe4),
				text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_stroke_size = 1,
				text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
				text_nor_shadow_size = cc.size(0, -1),
				msg_arg = { last = 1 },
			},
		}
	},
	[7] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_juntuan1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_juntuan2.png',
		title_text = 'RANKING_TITLE_TX_11',
		text = 'RANKING_TITLE_V3_7',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'tavern',
		msg_act = 'get_luck_list',
		msg_arg = {},
	},
	[8] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_juntuan1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_juntuan2.png',
		title_text = 'RANKING_TITLE_TX_9',
		text = 'RANKING_TITLE_V3_8',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 24,
		msg_mod = 'legionwar',
		msg_act = 'get_world_ranklist',
		msg_arg = {},
	},
	[9] = {
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_juntuan1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_juntuan2.png',
		title_text = 'RANKING_TITLE_TX_10',
		text = 'RANKING_TITLE_V3_9',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 24,
		msg_mod = 'legionwar',
		msg_act = 'get_server_ranklist',
		msg_arg = {},
	},
    [10] = {
        --龙境排行榜
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_longjing1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_longjing2.png',
		title_text = 'RANKING_TITLE_TX_12',
		text = 'RANKING_TITLE_V3_10',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 24,
		msg_mod = 'territorywar',
		msg_act = 'get_rank',
		msg_arg = {},
	},
    [11] = {
        --等级排行榜
		bg_nor = 'uires/ui/common/title_btn_nor_2.png',
		bg_sel = 'uires/ui/common/title_btn_sel_2.png',
		icon_nor = 'uires/ui/rankinglist_v3/rlistv3_shenjiang1.png',
		icon_sel = 'uires/ui/rankinglist_v3/rlistv3_shenjiang2.png',
		title_text = 'RANKING_TITLE_TX_13',
		text = 'RANKING_TITLE_V3_11',
		text_nor_color = cc.c3b(0xcf, 0xba, 0x8d),
		text_nor_stroke = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_stroke_size = 1,
		text_nor_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_nor_shadow_size = cc.size(0, -1),
		text_sel_color = cc.c3b(0xff, 0xf7, 0xe4),
		text_sel_stroke = cc.c3b(0x23, 0x27, 0x5c),
		text_sel_stroke_size = 1,
		text_sel_shadow = cc.c3b(0x4e, 0x31, 0x11),
		text_sel_shadow_size = cc.size(0, -1),
		text_font_size = 28,
		msg_mod = 'user',
		msg_act = 'level_rank_list',
		msg_arg = {},
	},
}
-- fucking config over

local SV_SIZE = {
	{
		width = 800, 
		height = 388
	}, 
	{ 
		width = 800,
		height = 528
	}
}

function RankinglistV3UI:ctor(menutab)

	dump(menutab)
	-- base data
	self.uiIndex = GAME_UI.UI_RANKINGLIST_V3

	-- logic data
	self.page = nil
	self.subpage = nil
	self.data = {}

	-- config data
	self.menuTree = menuTree

	-- visible data
	self.list = nil
	self.defaultMenu = nil
	self.panel = {}
	self.subtitle = {}
	self.title_tx = nil
	self.cells = {}
	self.cellTotalHeight = 15
	if menutab ~= nil then
		self.menutab = menutab
	else
		self.menutab = {1,2,11,3,4,5,6,7}
	end
end

function RankinglistV3UI:init()
	local bg = self.root:getChildByName('bg')
	bg:setTouchEnabled(true)
	local bg1 = bg:getChildByName('bg1')
	self:adaptUI(bg, bg1)
	local adaptX = bg1:getPositionX()
	bg1:setPositionX(adaptX + 30)

	bg1:getChildByName('close')
		:addClickEventListener(function ()
			RankingListMgr:hideRankingListMain()
		end)

	local subtitle_bg = bg1:getChildByName('subtitle_bg')
	for i = 1, 2 do
		self.subtitle[i] = {}
		self.subtitle[i].btn = subtitle_bg:getChildByName('subtitle_' .. i)
		self.subtitle[i].tx = self.subtitle[i].btn:getChildByName('tx')
	end

	self.title_tx = bg1:getChildByName('title_bg')
		:getChildByName('title_tx')

	self.list = bg1:getChildByName('menulist')
		:setScrollBarEnabled(false)
		:setItemModel(self:getDefaultMenuItem())
	local num = 0
	for j,k in ipairs(self.menutab) do
		for i, v in ipairs(menuTree) do
			if i == k then
				self.list:pushBackDefaultItem()
				local tiao = self.list:getItem(num)
				local icon = tiao:getChildByName('icon')
				local text = tiao:getChildByName('tx')

				tiao:loadTexture(v.bg_nor)
				icon:loadTexture(v.icon_nor)
				local str = GlobalApi:getLocalStr(v.text)
				str = string.gsub(str, '|', '\r\n')
				text:setString(str)
				text:setFontSize(v.text_font_size)
				text:setTextColor(v.text_nor_color)
				text:enableOutline(v.text_nor_stroke, v.text_nor_stroke_size)
				text:enableShadow(v.text_nor_shadow, v.text_nor_shadow_size)

				tiao:setTouchEnabled(true)
				tiao:addClickEventListener(function ()
					local subpage = nil
					if menuTree[i].sub_title ~= nil then
						local country = UserData:getUserObj():getCountry()
						if country > 0 and i == 4 then
							subpage = country
						else
							subpage = 1
						end
					end
					RankingListMgr:showRankingListMain(k, subpage,self.menutab)
				end)
				num = num + 1
			end
		end
	end
	local content = bg1:getChildByName('content')
	self.self_frame = content:getChildByName('self_frame')
	self:initMyInfoCell()
	self.sv = bg1:getChildByName('sv')
	self.sv:setScrollBarEnabled(false)
	--self.svSize = self.sv:getContentSize() 
	self.svSizeIndex = 1
	self.bg_sv = self.sv:getChildByName('bg_sv')
	self.svContentWidget = ccui.Widget:create()
	self.sv:addChild(self.svContentWidget)
end

function RankinglistV3UI:getDefaultMenuItem()
	if self.defaultMenu == nil then
		self.defaultMenu = cc.CSLoader
			:createNode('csb/rl_menu_cell.csb')
			:getChildByName('menu')
	end
	return self.defaultMenu
end

function RankinglistV3UI:getData(page, subpage)
	if subpage == nil then
		-- print('---------------------------------------------------------')
		-- for k, v in pairs(self.data) do
		-- 	print(k,v)
		-- end
		-- print('---------------------------------------------------------')
		return self.data[page]
	end

	local data = self:getData(page)
	if data == nil then
		return nil
	end
	print('page . subpage ..............', page, subpage)
	return data[subpage]
end

function RankinglistV3UI:addData(data, page, subpage)
	-- if data == nil then
	-- 	print('*********************************************************')
	-- end
	if subpage == nil then
		self.data[page] = data
		return self.data[page]
	end

	if self.data[page] == nil then
		self.data[page] = {}
	end

	self.data[page][subpage] = data
	if page == 4 then
		local datas = {}
		local countryDatas = data["ranks"] or {}
		for k, v in pairs(countryDatas) do
			for k2 ,v2 in pairs(v) do
				v2.posId = tonumber(k)
				v2.country = subpage
				table.insert(datas, v2)
			end
		end
		if #datas > 0 then
			table.sort(datas, function (a, b)
				if a.posId == b.posId then
					return a.fight_force > b.fight_force
				else
					return a.posId < b.posId
				end
			end)
		end
		self.data[page][subpage]["ranks"] = datas
	end
	return self.data[page][subpage]
end

function RankinglistV3UI:changeTo(page, subpage,menutab)
	-- check args
	self.menutab = menutab or {1,2,11,3,4,5,6,7}
	if page == nil then
		print('[ERROR]: Ranking list changeTo page is nil')
		return
	end
	if page < 1 or page > #menuTree then
		print('[ERROR]: Ranking list changeTo page can not find!', page)
		return
	end
	-- set prev btn status 
	print('ranking list change to page & subpage', page, subpage)
	local index = 1
	for i,v in ipairs(self.menutab) do
		if self.page == v then
			index = i
		end
	end

	if self.page ~= nil then
		print('self.page=='..self.page)
		local tiao = self.list:getItem(index-1)
		local icon = tiao:getChildByName('icon')
		local text = tiao:getChildByName('tx')

		tiao:loadTexture(menuTree[self.page].bg_nor)
		icon:loadTexture(menuTree[self.page].icon_nor)
		text:setTextColor(menuTree[self.page].text_nor_color)
		text:enableOutline(menuTree[self.page].text_nor_stroke
			, menuTree[self.page].text_nor_stroke_size)
		text:enableShadow(menuTree[self.page].text_nor_shadow
			, menuTree[self.page].text_nor_shadow_size)
		tiao:setTouchEnabled(true)
	end

	-- set sub title btn visible
	for i = 1, 2 do
		self.subtitle[i].btn:setVisible(false)
	end

	-- set page...
	self.page = page
	self.subpage = subpage
	if self.page == nil then
		self.page = 1
	end
	local index = 1
	for i,v in ipairs(self.menutab) do
		if self.page == v then
			index = i
		end
	end
	-- set new btn status
	local tiao = self.list:getItem(index - 1)
	local icon = tiao:getChildByName('icon')
	local text = tiao:getChildByName('tx')

	tiao:loadTexture(menuTree[self.page].bg_sel)
	icon:loadTexture(menuTree[self.page].icon_sel)
	text:setTextColor(menuTree[self.page].text_sel_color)
	text:enableOutline(menuTree[self.page].text_sel_stroke
		, menuTree[self.page].text_sel_stroke_size)
	text:enableShadow(menuTree[self.page].text_sel_shadow
		, menuTree[self.page].text_sel_shadow_size)
	tiao:setTouchEnabled(false)

	-- set subtitle status
	if self.menuTree[self.page].sub_title ~= nil then
		local subpage = self.subpage or 1
		self.subpage = subpage
		local parent_page = self.menuTree[self.page]
		local subcount = #parent_page.sub_title
		if subpage <= 0 or subpage > subcount then
			print('[ERROR]: Ranking list subpage error!', subpage)
			return
		end
		local index = 1
		for i = 1, subcount do
			if i == subpage then
				-- set title ...
				local title_str = GlobalApi:getLocalStr(
					parent_page.sub_title[i].title_text)
				self.title_tx:setString(title_str)
			else
				self.subtitle[index].btn:setVisible(true)
				self.subtitle[index].btn:setContentSize(parent_page.sub_title[i].button_size)
				local substr = GlobalApi:getLocalStr(parent_page.sub_title[i].text)
				self.subtitle[index].tx:setString(substr)
				self.subtitle[index].btn:addClickEventListener(function ()
					RankingListMgr:showRankingListMain(self.page, i)
				end)
				index = index + 1
			end
		end
	else
		local title_str = GlobalApi:getLocalStr(menuTree[self.page].title_text)
		self.title_tx:setString(title_str)
	end
	-- 更新排行榜
	local datas
	local userObj = UserData:getUserObj()
	local myData = {
		headpic = userObj:getHeadpic(),
		frame = RoleData:getMainRole():getBgImg(),
		headframe = userObj:getHeadFrame(),
		level = userObj:getLv(),
		name = userObj:getName(),
		vip = userObj:getVip(),
		fight_force = userObj:getFightforce()
	}
	if page == 1 then
		datas = self.data[page]["rank_list"] or {}
		myData.rank = self.data[page].rank or 0
		myData.lastRank = self.data[page].last_rank or 0
	elseif page == 2 then
		datas = self.data[page]["rank_list"] or {}
		myData.rank = self.data[page].rank or 0
		myData.lastRank = self.data[page].last_rank or 0
	elseif page == 3 then
		datas = self.data[page]["rank_list"] or {}
		myData.rank = self.data[page].rank or 0
		myData.star = self.data[page].star or 0
	elseif page == 4 then
		datas = self.data[page][subpage]["ranks"] or {}
		myData.rank = 0
		myData.lastRank = 0
		myData.posId = self.data[page][subpage].position
	elseif page == 5 then
		datas = self.data[page]["list"] or {}
		myData.myLegion = self.data[page].self
	elseif page == 6 then
		datas = self.data[page][subpage]["rank_list"] or {}
		myData.rank = self.data[page][subpage].rank or 0
		myData.lastRank = self.data[page][subpage].last_rank or 0
		myData.sid = GlobalData:getSelectSeverUid()
		myData.score = self.data[page][subpage].score or 0
	elseif page == 7 then
		datas = self.data[page]["luck_list"] or {}
		myData.rank = self.data[page].rank or 0
		myData.luck = self.data[page].luck or 0
	elseif page == 8 then
		datas = self.data[page]["rankList"] or {}
		myData.myLegion = self.data[page].ownLegion
	elseif page == 9 then
		datas = self.data[page]["rankList"] or {}
		myData.myLegion = self.data[page].ownLegion
    elseif page == 10 then
		datas = self.data[page]["rankList"] or {}
        myData.rank = self.data[page].rank or 0
        myData.killCount = self.data[page].killCount or 0
    elseif page == 11 then
		datas = self.data[page]["rank_list"] or {}
		myData.rank = self.data[page].rank or 0
		myData.lastRank = self.data[page].last_rank or 0
	end
	self:updateMyInfo(page, myData)

	local dataNum = #datas
	for i = 1, dataNum do
		if self.cells[i] == nil then
			local cell = ClassRankinglistCell.new(page)
			self.cells[i] = cell
			self.svContentWidget:addChild(cell:getNode())
			self.cellTotalHeight = self.cellTotalHeight + 104 + 5
			cell:setPosition(cc.p(0, 52 - self.cellTotalHeight + 10))
		end
		self.cells[i]:update(page, i, datas[i])
		self.cells[i]:setVisible(true)
	end
	local cellTotalHeight = self.cellTotalHeight
	local cellNum = #self.cells
	for i = dataNum + 1, cellNum do
		self.cells[i]:setVisible(false)
		cellTotalHeight = cellTotalHeight - 109
	end
	local posY = SV_SIZE[self.svSizeIndex].height
	if cellTotalHeight > posY then
		posY = cellTotalHeight
	end
	self.sv:setContentSize(cc.size(SV_SIZE[self.svSizeIndex].width, SV_SIZE[self.svSizeIndex].height))
	self.sv:setInnerContainerSize(cc.size(SV_SIZE[self.svSizeIndex].width, posY))
	self.bg_sv:setContentSize(cc.size(SV_SIZE[self.svSizeIndex].width, posY))
	self.svContentWidget:setPosition(cc.p(SV_SIZE[self.svSizeIndex].width*0.5, posY))
	self.sv:update(10000)
	self.sv:jumpToTop()
	return
end

function RankinglistV3UI:initMyInfoCell()
	local headpicNode = self.self_frame:getChildByName("headpic_node")
	local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
	headpicNode:addChild(headpicCell.awardBgImg)
	headpicCell.awardBgImg:ignoreContentAdaptWithSize(true)
	headpicCell.awardImg:ignoreContentAdaptWithSize(true)
	-- 名次
	local rankImg = self.self_frame:getChildByName("rank_img")
	rankImg:ignoreContentAdaptWithSize(true)
	-- 名次label
	local rankLabel = cc.LabelAtlas:_create("", "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
	rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
	rankLabel:setName("rank_tx")
	rankLabel:setPosition(cc.p(62, 40))
	self.self_frame:addChild(rankLabel)
	-- 官职图片
	local posImg = self.self_frame:getChildByName("pos_img")
	posImg:ignoreContentAdaptWithSize(true)
	-- vip
	local vipImg = self.self_frame:getChildByName("vip_img")
	vipImg:ignoreContentAdaptWithSize(true)
	local vipLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	vipLabel:setName("vip_tx")
	vipLabel:setAnchorPoint(cc.p(0, 0.5))
	vipImg:addChild(vipLabel)
	vipLabel:setPosition(cc.p(50, 11.5))
	-- 战斗力
	local fightforceImg = self.self_frame:getChildByName("fightforce_img")
	fightforceImg:ignoreContentAdaptWithSize(true)
	local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforceLabel:setName("fightforce_tx")
	fightforceLabel:setScale(0.8)
	fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
	self.self_frame:addChild(fightforceLabel)

	local luck = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	luck:setAnchorPoint(cc.p(0, 0.5))
	luck:setName("luck")
	luck:setVisible(false)
	self.self_frame:addChild(luck)
	-- 国家
	local countryImg = self.self_frame:getChildByName("country_img")
	countryImg:ignoreContentAdaptWithSize(true)
	local country = UserData:getUserObj():getCountry()
	if country > 0 then
		countryImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_flag_" .. country .. ".png")
	end
	-- 对比箭头
	local diffImg = self.self_frame:getChildByName("diff_img")
	diffImg:ignoreContentAdaptWithSize(true)
end

function RankinglistV3UI:updateMyInfo(page, data)
	local rankImg = self.self_frame:getChildByName("rank_img")
	local rankLabel = self.self_frame:getChildByName("rank_tx")
	local posImg = self.self_frame:getChildByName("pos_img")
	local posLabel = self.self_frame:getChildByName("pos_tx")
	local headpicNode = self.self_frame:getChildByName("headpic_node")
	local headpicBg = headpicNode:getChildByName("award_bg_img")
	local headpic = headpicBg:getChildByName("award_img")
	local headframe = headpicBg:getChildByName("headframeImg")
	local levelLabel = headpicBg:getChildByName("lv_tx")
	local nameLabel = self.self_frame:getChildByName("name_tx")
	local vipImg = self.self_frame:getChildByName("vip_img")
	local vipLabel = vipImg:getChildByName("vip_tx")
	local vipLabel2 = vipImg:getChildByName("vip_tx2")
	local fightforceImg = self.self_frame:getChildByName("fightforce_img")
	local fightforceLabel = self.self_frame:getChildByName("fightforce_tx")
	local serverLabel = self.self_frame:getChildByName("server_tx")
	local countryImg = self.self_frame:getChildByName("country_img")
	local myRankLabel = self.self_frame:getChildByName("my_rank_tx")
	local diffImg = self.self_frame:getChildByName("diff_img")
	local lastLabel = diffImg:getChildByName("last_tx")
	local numLabel = diffImg:getChildByName("num_tx")
	local luck = self.self_frame:getChildByName("luck")
	local expBg = self.self_frame:getChildByName("exp_bg")
	local bar = expBg:getChildByName("bar")
	local barTx = expBg:getChildByName("bar_tx")
	local lvImg = expBg:getChildByName("lv_img")
	local lvTx = lvImg:getChildByName("lv_tx")
	luck:setVisible(false)
	expBg:setVisible(page == 11)
	if page == 1 or page == 2 or page == 11 then -- 战斗力
		if page == 11 then
			local per = math.floor(UserData:getUserObj():lvPrecent()*100)/100
			bar:setPercent(per)
			barTx:setString(per..'%')
			lvTx:setString(UserData:getUserObj():getLv())
		end
		self:setSelfFrameVisible(true)
		myRankLabel:setVisible(true)
		myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_RANK"))
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)
		-- 战斗力
		fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		fightforceImg:setPosition(cc.p(260, 40))
		fightforceLabel:setString(tostring(data.fight_force))
		fightforceLabel:setPosition(cc.p(cc.p(285, 40)))
		fightforceImg:setVisible(page ~= 11)
		fightforceLabel:setVisible(page ~= 11)
		-- 服务器编号
		serverLabel:setVisible(false)
		-- 官职图片
		posImg:setVisible(false)
		-- 国家图标
		countryImg:setVisible(false)
		if data.rank == 0 then -- 未上榜
			diffImg:setVisible(false)
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(true)
			posLabel:setPosition(cc.p(62, 40))
			posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
			posLabel:setTextColor(COLOR_TYPE.WHITE)
		else
			posLabel:setVisible(false)
			-- 名次
			if data.rank <= 3 then
				rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.rank .. ".png")
				rankImg:setVisible(true)
				rankLabel:setVisible(false)
			else
				rankImg:setVisible(false)
				rankLabel:setVisible(true)
				rankLabel:setString(tostring(data.rank))
			end
			if data.lastRank == 0 then
				diffImg:setVisible(false)
			else
				if data.lastRank == data.rank then
					diffImg:setVisible(false)
				elseif data.lastRank > data.rank then
					diffImg:setVisible(true)
					diffImg:loadTexture("uires/ui/common/arrow_up3.png")
					lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_YESTERDAY"))
					numLabel:setString(tostring(data.lastRank - data.rank))
				else
					diffImg:setVisible(true)
					diffImg:loadTexture("uires/ui/common/arrow_down3.png")
					lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_YESTERDAY"))
					numLabel:setString(tostring(data.rank - data.lastRank))
				end
			end
		end
	elseif page == 3 then -- 千重楼
		self:setSelfFrameVisible(true)
		myRankLabel:setVisible(true)
		myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_RANK"))
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)
		-- 战斗力
		fightforceImg:loadTexture("uires/ui/common/icon_star3.png")
		fightforceImg:setPosition(cc.p(260, 40))
		fightforceLabel:setString(tostring(data.star))
		fightforceLabel:setPosition(cc.p(cc.p(285, 40)))
		-- 服务器编号
		serverLabel:setVisible(false)
		-- 官职图片
		posImg:setVisible(false)
		-- 国家图标
		countryImg:setVisible(false)
		diffImg:setVisible(false)
		if data.rank == 0 then -- 未上榜
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(true)
			posLabel:setPosition(cc.p(62, 40))
			posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
			posLabel:setTextColor(COLOR_TYPE.WHITE)
		else
			posLabel:setVisible(false)
			-- 名次
			if data.rank <= 3 then
				rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.rank .. ".png")
				rankImg:setVisible(true)
				rankLabel:setVisible(false)
			else
				rankImg:setVisible(false)
				rankLabel:setVisible(true)
				rankLabel:setString(tostring(data.rank))
			end
		end
	elseif page == 4 then -- 皇城
		myRankLabel:setVisible(false)
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)
		-- 战斗力
		fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		fightforceImg:setPosition(cc.p(300, 40))
		fightforceLabel:setString(tostring(data.fight_force))
		fightforceLabel:setPosition(cc.p(cc.p(325, 40)))
		-- 服务器编号
		serverLabel:setVisible(false)
		-- 名次
		rankImg:setVisible(false)
		rankLabel:setVisible(false)
		diffImg:setVisible(false)
		-- 国家图标
		if UserData:getUserObj():getCountry() > 0 then
			self:setSelfFrameVisible(true)
			countryImg:setVisible(true)
			local positionConf = GameData:getConfData("position")
			posLabel:setVisible(true)
			if positionConf[data.posId].position < 3 then
				posImg:setVisible(true)
				posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_" .. positionConf[data.posId].position + 1 .. ".png")
				if data.posId == 1 then
					posLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
	            else
	            	posLabel:setString(positionConf[data.posId].title)
	            end
				posLabel:setPosition(cc.p(62, 40))
			else
				posImg:setVisible(false)
				posLabel:setString( "【" .. positionConf[data.posId].posName .. "】 \n" ..  positionConf[data.posId].title)
				posLabel:setPosition(cc.p(62, 58))
				posLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			end
			posLabel:setTextColor(COLOR_QUALITY[positionConf[data.posId].quality])
		else
			self:setSelfFrameVisible(false)
			posImg:setVisible(false)
			countryImg:setVisible(false)
			posLabel:setVisible(false)
		end
	elseif page == 5 then -- 军团
		if data.myLegion then
			self:setSelfFrameVisible(true)
			myRankLabel:setVisible(true)
			myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_LEGION"))
			-- 头像
			headpic:setVisible(false)
			local iconConf = GameData:getConfData("legionicon")
			headpicBg:loadTexture(iconConf[data.myLegion.icon].icon)
			levelLabel:setString("")
			-- 名字
			nameLabel:setString(data.myLegion.name)
			nameLabel:setTextColor(COLOR_TYPE[iconConf[data.myLegion.icon].nameColor])
			local nameSize = nameLabel:getContentSize()
			-- 等级
			vipImg:loadTexture("uires/ui/common/lv_art.png")
			vipImg:setPosition(cc.p(nameSize.width + 275, 86))
			vipLabel:setVisible(false)
			vipLabel2:setVisible(true)
			vipLabel2:setString(tostring(data.myLegion.level))
			-- 军团人数
			fightforceImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_renshu.png")
			fightforceImg:setPosition(cc.p(275, 40))
			fightforceLabel:setString(tostring(data.myLegion.count))
			fightforceLabel:setPosition(cc.p(cc.p(310, 40)))
			-- 服务器编号
			serverLabel:setVisible(false)
			-- 官职图片
			posImg:setVisible(false)
			headframe:setVisible(false)
			-- 国家图标
			countryImg:setVisible(false)
			diffImg:setVisible(false)
			if data.myLegion.rank == 0 then -- 未上榜
				rankImg:setVisible(false)
				rankLabel:setVisible(false)
				posLabel:setVisible(true)
				posLabel:setPosition(cc.p(62, 40))
				posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
				posLabel:setTextColor(COLOR_TYPE.WHITE)
			else
				posLabel:setVisible(false)
				-- 名次
				if data.myLegion.rank <= 3 then
					rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.myLegion.rank .. ".png")
					rankImg:setVisible(true)
					rankLabel:setVisible(false)
				else
					rankImg:setVisible(false)
					rankLabel:setVisible(true)
					rankLabel:setString(tostring(data.myLegion.rank))
				end
			end
		else
			self:setSelfFrameVisible(false)
			myRankLabel:setVisible(false)
			headpic:setVisible(false)
			levelLabel:setString("")
			nameLabel:setString("")
			vipLabel:setVisible(false)
			vipLabel2:setVisible(false)
			fightforceLabel:setString("")
			serverLabel:setVisible(false)
			posImg:setVisible(false)
			countryImg:setVisible(false)
			diffImg:setVisible(false)
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(false)
			headframe:setVisible(false)
		end
	elseif page == 6 then -- 群雄争霸
		self:setSelfFrameVisible(true)
		myRankLabel:setVisible(true)
		myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_RANK"))
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)
		-- 战斗力
		fightforceImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_ji.png")
		fightforceImg:setPosition(cc.p(390, 40))
		fightforceLabel:setString(tostring(data.score))
		fightforceLabel:setPosition(cc.p(cc.p(415, 40)))
		-- 服务器编号
		serverLabel:setVisible(true)
		serverLabel:setString(data.sid .. GlobalApi:getLocalStr("FU"))
		-- 官职图片
		posImg:setVisible(false)
		-- 国家图标
		countryImg:setVisible(false)
		if data.rank == 0 then -- 未上榜
			diffImg:setVisible(false)
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(true)
			posLabel:setPosition(cc.p(62, 40))
			posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
			posLabel:setTextColor(COLOR_TYPE.WHITE)
		else
			posLabel:setVisible(false)
			-- 名次
			if data.rank <= 3 then
				rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.rank .. ".png")
				rankImg:setVisible(true)
				rankLabel:setVisible(false)
			else
				rankImg:setVisible(false)
				rankLabel:setVisible(true)
				rankLabel:setString(tostring(data.rank))
			end
			if data.lastRank == 0 then
				diffImg:setVisible(false)
			else
				if data.lastRank == data.rank then
					diffImg:setVisible(false)
				elseif data.lastRank > data.rank then
					diffImg:setVisible(true)
					diffImg:loadTexture("uires/ui/common/arrow_up3.png")
					lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_ROUND"))
					numLabel:setString(tostring(data.lastRank - data.rank))
				else
					diffImg:setVisible(true)
					diffImg:loadTexture("uires/ui/common/arrow_down3.png")
					lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_ROUND"))
					numLabel:setString(tostring(data.rank - data.lastRank))
				end
			end
		end
	elseif page == 7 then -- 人品
		self:setSelfFrameVisible(true)
		myRankLabel:setVisible(true)
		myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_RANK"))
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)
		-- 战斗力
		fightforceImg:loadTexture("uires/ui/text/renping_tx.png")
		fightforceImg:setPosition(cc.p(280, 35))
		fightforceLabel:setString("")
		luck:setVisible(true)
		luck:setString(tostring(data.luck))
		luck:setPosition(cc.p(cc.p(315, 35)))
		-- 服务器编号
		serverLabel:setVisible(false)
		-- 名次
		rankImg:setVisible(false)
		rankLabel:setVisible(false)
		diffImg:setVisible(false)
		countryImg:setVisible(false)
		if data.rank == 0 then
			myRankLabel:setVisible(true)
	        posImg:setVisible(false)
	        posLabel:setVisible(true)
	        rankImg:setVisible(false)
	        rankLabel:setVisible(false)
	       	posLabel:setPosition(cc.p(62, 40))
			posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
	        --rankLabel:setString(data.rank)	
		elseif data.rank == 1 then
			myRankLabel:setVisible(false)
			posImg:setVisible(true)
			posLabel:setVisible(true)
			rankLabel:setVisible(false)
			rankImg:setVisible(false)
	        posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_1.png")
	        posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_18'))
	        posLabel:setTextColor(COLOR_TYPE.ORANGE)
	        posLabel:setPosition(cc.p(62,45))
	    elseif data.rank == 2 then
	    	myRankLabel:setVisible(false)
	    	posImg:setVisible(true)
			posLabel:setVisible(true)
			rankLabel:setVisible(false)
			rankImg:setVisible(false)
	        posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_2.png")
	        posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_19'))
	        posLabel:setTextColor(COLOR_TYPE.PURPLE)
	        posLabel:setPosition(cc.p(62,45))
	    elseif data.rank == 3 then
	    	myRankLabel:setVisible(false)
	    	posImg:setVisible(true)
			posLabel:setVisible(true)
			rankLabel:setVisible(false)
			rankImg:setVisible(false)
	        posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_3.png")
	        posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_20'))
	        posLabel:setTextColor(COLOR_TYPE.BLUE)
	        posLabel:setPosition(cc.p(62,45))
	    else
	    	myRankLabel:setVisible(true)
	        posImg:setVisible(false)
	        posLabel:setVisible(false)
	        rankImg:setVisible(false)
	        rankLabel:setVisible(true)
	        rankLabel:setString(data.rank)
	    end
	elseif page == 8 or page == 9 then -- 军团战
		if data.myLegion then
			self.self_frame:setVisible(true)
			myRankLabel:setVisible(true)
			myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_LEGION"))
			-- 头像
			headpic:setVisible(false)
			local iconConf = GameData:getConfData("legionicon")
			headpicBg:loadTexture(iconConf[data.myLegion.icon].icon)
			levelLabel:setString("")
			-- 名字
			nameLabel:setString(data.myLegion.name)
			nameLabel:setTextColor(COLOR_TYPE[iconConf[data.myLegion.icon].nameColor])
			local nameSize = nameLabel:getContentSize()
			-- -- 等级

			-- vipImg:loadTexture("uires/ui/common/lv_art.png")
			-- vipImg:setPosition(cc.p(nameSize.width + 275, 86))
			vipLabel:setVisible(false)
			vipLabel2:setVisible(false)
			-- vipLabel2:setString(tostring(data.myLegion.level))
			-- -- 军团人数
			-- fightforceImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_renshu.png")
			-- fightforceImg:setPosition(cc.p(275, 40))
			fightforceLabel:setString(tostring(data.myLegion.curScore))
			fightforceLabel:setPosition(cc.p(cc.p(290, 40)))
			-- 服务器编号
			serverLabel:setVisible(true)
			serverLabel:setString('')
			-- 官职图片
			posImg:setVisible(false)
			-- 国家图标
			countryImg:setVisible(true)
			headframe:setVisible(false)
			countryImg:loadTexture("uires/ui/legionwar/legionwar_score_icon.png")
			diffImg:setVisible(false)
			if data.myLegion.curRank == 0 then -- 未上榜
				rankImg:setVisible(false)
				rankLabel:setVisible(false)
				posLabel:setVisible(true)
				posLabel:setPosition(cc.p(62, 40))
				posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
				posLabel:setTextColor(COLOR_TYPE.WHITE)
			else
				posLabel:setVisible(false)
				-- 名次
				if data.myLegion.curRank <= 3 then
					rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.myLegion.curRank .. ".png")
					rankImg:setVisible(true)
					rankLabel:setVisible(false)
				else
					rankImg:setVisible(false)
					rankLabel:setVisible(true)
					rankLabel:setString(tostring(data.myLegion.curRank))
				end
				if data.lastRank == 0 then
					diffImg:setVisible(false)
				else
					if data.lastRank == data.curRank then
						diffImg:setVisible(false)
					elseif data.lastRank > data.curRank then
						diffImg:setVisible(true)
						diffImg:loadTexture("uires/ui/common/arrow_up3.png")
						lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_YESTERDAY"))
						numLabel:setString(tostring(data.lastRank - data.curRank))
					else
						diffImg:setVisible(true)
						diffImg:loadTexture("uires/ui/common/arrow_down3.png")
						lastLabel:setString(GlobalApi:getLocalStr("RANKING_COM_YESTERDAY"))
						numLabel:setString(tostring(data.curRank - data.lastRank))
					end
				end
			end
		else
			self:setSelfFrameVisible(false)
			myRankLabel:setVisible(false)
			headpic:setVisible(false)
			levelLabel:setString("")
			nameLabel:setString("")
			vipLabel:setVisible(false)
			vipLabel2:setVisible(false)
			fightforceLabel:setString("")
			serverLabel:setVisible(false)
			posImg:setVisible(false)
			countryImg:setVisible(false)
			diffImg:setVisible(false)
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(false)
			headframe:setVisible(false)
		end
    elseif page == 10 then
        self:setSelfFrameVisible(true)
		myRankLabel:setVisible(true)
		myRankLabel:setString(GlobalApi:getLocalStr("STR_MY_RANK"))
		-- 头像
		headpic:setVisible(true)
		headpic:loadTexture(data.headpic)
		headpicBg:loadTexture(data.frame)
	    headframe:loadTexture(data.headframe)
	    headframe:setVisible(true)
		-- 等级
		levelLabel:setString(tostring(data.level))
		-- 名字
		nameLabel:setString(data.name)
		nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = nameLabel:getContentSize()
		-- vip
		vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		vipImg:setPosition(cc.p(nameSize.width + 275, 86))
		vipLabel:setString(tostring(data.vip))
		vipLabel:setVisible(true)
		vipLabel2:setVisible(false)

		-- 击杀数
		fightforceImg:loadTexture("uires/ui/territorialwars/terwars_kill_num.png")
		fightforceImg:setPosition(cc.p(290, 40))
		fightforceLabel:setString(tostring(data.killCount))
		fightforceLabel:setPosition(cc.p(cc.p(345, 40)))
		-- 服务器编号
		serverLabel:setVisible(false)
		-- 官职图片
		posImg:setVisible(false)
		-- 国家图标
		countryImg:setVisible(false)
		diffImg:setVisible(false)
		if data.rank == 0 then -- 未上榜
			rankImg:setVisible(false)
			rankLabel:setVisible(false)
			posLabel:setVisible(true)
			posLabel:setPosition(cc.p(62, 40))
			posLabel:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
			posLabel:setTextColor(COLOR_TYPE.WHITE)
		else
			posLabel:setVisible(false)
			-- 名次
			if data.rank <= 3 then
				rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. data.rank .. ".png")
				rankImg:setVisible(true)
				rankLabel:setVisible(false)
			else
				rankImg:setVisible(false)
				rankLabel:setVisible(true)
				rankLabel:setString(tostring(data.rank))
			end
		end

	end
end

function RankinglistV3UI:setSelfFrameVisible(vis)
	if vis then
		self.svSizeIndex = 1
	else
		self.svSizeIndex = 2
	end
	self.self_frame:setVisible(vis)
end

return RankinglistV3UI