local ArenaV2DailyUI = class('ArenaV2DailyUI', BaseUI)


function ArenaV2DailyUI:ctor()
	self.uiIndex = GAME_UI.UI_ARENA_V2_DAILY

	-- ui data
	self.default = nil
end

function ArenaV2DailyUI:init()
	local bg = self.root:getChildByName('bg')
	local bg1 = bg:getChildByName('bg1')
	self:adaptUI(bg, bg1)

	bg1:getChildByName('close')
		:addClickEventListener(function (  )
			ArenaMgr:hideArenaV2Daily()
		end)

	bg1:getChildByName('titlebg')
		:getChildByName('tx')
		:setString(GlobalApi:getLocalStr('ARENA_TITLE2'))

	local list = bg1:getChildByName('content_bg')
		:getChildByName('list')

	local descTx = bg1:getChildByName('desc_tx')
	descTx:setString('奖励每日21点通过邮箱发放')
	if self.default == nil then
		local cell = cc.CSLoader:createNode('csb/arena_v2_daily_cell.csb')
		self.default = cell:getChildByName('tiao')
	end
	list:setItemModel(self.default)
	list:setScrollBarEnabled(false)

	local dailyconf = GameData:getConfData('arenadaily')
	local levelconf = GameData:getConfData('arenalevel')

	local lastrank = 1
	for i, v in ipairs(dailyconf) do
		list:pushBackDefaultItem()

		local tiao = list:getItem(i - 1)
		local rankTx = tiao:getChildByName('rank_tx')
		local rankImg = tiao:getChildByName('rank_img')
		local rank_rt = xx.RichText:create()
		local rank_di = xx.RichTextLabel:create(
			GlobalApi:getLocalStr('ARENA_AWARDS_INFO_1'),
			25, 
			COLOR_TYPE.PALE)
		rank_di:setStroke(COLOROUTLINE_TYPE.PALE, 2)
		rank_di:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -1))

		rank_rt:addElement(rank_di)

        if i <= 3 then
            -- self.cells[i].rankTx:setString(conf[i].rank..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC3'))
            rankTx:setString('')
            rankImg:loadTexture('uires/ui/rankinglist_v3/rlistv3_rank_'..i..'.png')
        elseif i == #dailyconf then
            rankImg:setVisible(false)
            rankTx:setString((dailyconf[i - 1].rank)..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC4'))
        else
            rankImg:setVisible(false)
            local conf1 = dailyconf[i - 1]
            if dailyconf[i].rank - 1 == conf1.rank then
                rankTx:setString(dailyconf[i].rank)
            else
                rankTx:setString((conf1.rank + 1)..'-'..dailyconf[i].rank)
            end
        end

		local award_rt = xx.RichText:create()
		local dis = DisplayData:getDisplayObjs(v.award)
		for i, v in ipairs(dis) do
			local icon = xx.RichTextImage:create(v:getIcon())
			icon:setScale(0.6)
			award_rt:addElement(icon)

			local num = xx.RichTextLabel:create(
				v:getNum(),
				25,
				COLOR_TYPE.WHITE)
			num:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
			num:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
			num:setMinWidth(65)
			award_rt:addElement(num)
		end
		award_rt:setAlignment('middle')
		award_rt:setVerticalAlignment('middle')
		award_rt:format(true)
		award_rt:setContentSize(award_rt:getElementsSize())
		award_rt:setPosition(cc.p(178, 30))

		tiao:getChildByName('award_bg')
			:addChild(award_rt)
	end

	-- my rank
	local award = dailyconf[#dailyconf].award
	for i, v in ipairs(dailyconf) do
		if ArenaMgr.myRank <= v.rank then
			award = DisplayData:getDisplayObjs(v.award)
			break
		end
	end

	-- my level
	if levelconf[ArenaMgr.myLevel] == nil then
		return
	end
	local levelAward = DisplayData:getDisplayObjs(levelconf[ArenaMgr.myLevel].award)

	local my_rt = xx.RichText:create()
	local myaward = xx.RichTextLabel:create(
		GlobalApi:getLocalStr('ARENA_DAILY_MY_AWARD'),
		28,
		COLOR_TYPE.PALE)
	myaward:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	myaward:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -1))

	my_rt:addElement(myaward)

	for i, v in ipairs(award) do
		local icon = xx.RichTextImage:create(v:getIcon())
		icon:setScale(0.6)
		my_rt:addElement(icon)

		local num = xx.RichTextLabel:create(
			v:getNum(),
			25,
			COLOR_TYPE.WHITE)
		num:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		num:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		my_rt:addElement(num)

		local add = xx.RichTextLabel:create(
			' +' .. levelAward[i]:getNum(),
			25,
			COLOR_TYPE.GREEN)
		add:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		add:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		my_rt:addElement(add)
	end
	my_rt:setAlignment('middle')
	my_rt:setVerticalAlignment('middle')
	my_rt:format(true)
	my_rt:setContentSize(my_rt:getElementsSize())
	my_rt:setPosition(cc.p(350, 72))
	bg1:addChild(my_rt)
end

return ArenaV2DailyUI
