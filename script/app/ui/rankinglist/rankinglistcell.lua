local RankingListCellUI = class("RankingListCellUI")
local ClassItemCell = require('script/app/global/itemcell')

function RankingListCellUI:ctor(page)
    self.page = page

	local bg = ccui.ImageView:create("uires/ui/common/common_bg_24.png")
	bg:setCapInsets(cc.rect(120, 33, 33, 32))
	bg:setScale9Enabled(true)
	bg:setContentSize(cc.size(776, 104))
	-- 名次图片
	local rankImg = ccui.ImageView:create()
	rankImg:ignoreContentAdaptWithSize(true)
	rankImg:setPosition(cc.p(53, 52))
	bg:addChild(rankImg)
	self.rankImg = rankImg
	-- 名次label
	self.rankLabel = cc.LabelAtlas:_create("", "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
	self.rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.rankLabel:setPosition(cc.p(53, 52))
	bg:addChild(self.rankLabel)
	-- 官职图片
	local posImg = ccui.ImageView:create()
	posImg:ignoreContentAdaptWithSize(true)
	posImg:setPosition(cc.p(53, 72))
	bg:addChild(posImg)
	self.posImg = posImg
	-- 官职名字
	local posLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 26)
	posLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	posLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	bg:addChild(posLabel)
	posLabel:setPosition(cc.p(53, 36))
	self.posLabel = posLabel
	-- 头像
	local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
	headpicCell.awardBgImg:ignoreContentAdaptWithSize(true)
	headpicCell.awardBgImg:setPosition(cc.p(162, 52))
	bg:addChild(headpicCell.awardBgImg)
	self.headpicBg = headpicCell.awardBgImg

	headpicCell.awardImg:ignoreContentAdaptWithSize(true)
	self.headpic = headpicCell.awardImg
	self.headframe = headpicCell.headframeImg

	self.levelLabel = headpicCell.lvTx
	-- 名字
	local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setTextColor(COLOR_TYPE.WHITE)
	nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	nameLabel:setPosition(cc.p(225, 75))
	bg:addChild(nameLabel)
	self.nameLabel = nameLabel
	-- vip等级
	local vipImg = ccui.ImageView:create()
	vipImg:ignoreContentAdaptWithSize(true)
	bg:addChild(vipImg)
	self.vipImg = vipImg
	local vipLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	vipLabel:setAnchorPoint(cc.p(0, 0.5))
	vipImg:addChild(vipLabel)
	vipLabel:setPosition(cc.p(50, 11.5))
	self.vipLabel = vipLabel
	local vipLabel2 = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
	vipLabel2:setAnchorPoint(cc.p(0, 0.5))
	vipLabel2:setTextColor(COLOR_TYPE.WHITE)
	vipLabel2:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	vipLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	vipImg:addChild(vipLabel2)
	vipLabel2:setPosition(cc.p(35, 11.5))
	self.vipLabel2 = vipLabel2
	-- 战斗力
	local fightforceImg = ccui.ImageView:create()
	fightforceImg:ignoreContentAdaptWithSize(true)
	bg:addChild(fightforceImg)
	self.fightforceImg = fightforceImg
	local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforceLabel:setScale(0.8)
	fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
	bg:addChild(fightforceLabel)
	self.fightforceLabel = fightforceLabel

	local luck = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	luck:setAnchorPoint(cc.p(0, 0.5))
	bg:addChild(luck)
	self.luck = luck
	self.luck:setVisible(false)
	-- 服务器编号
	local serverLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	serverLabel:setAnchorPoint(cc.p(0, 0.5))
	serverLabel:setTextColor(COLOR_TYPE.WHITE)
	serverLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	serverLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	serverLabel:setPosition(cc.p(225, 35))
	bg:addChild(serverLabel)
	self.serverLabel = serverLabel
	-- 国家图标
	local countryImg = ccui.ImageView:create()
	bg:addChild(countryImg)
	countryImg:setPosition(cc.p(240, 35))
	self.countryImg = countryImg
	-- 查看按钮
	local viewbtn = ccui.Button:create("uires/ui/common/common_btn_8.png")
	local viewLabel = cc.Label:createWithTTF(GlobalApi:getLocalStr("STR_GOTO_VIEW"), "font/gamefont.ttf", 30)
	viewLabel:setTextColor(COLOR_TYPE.WHITE)
	viewLabel:enableOutline(COLOROUTLINE_TYPE.WHITE2, 2)
	viewLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	viewLabel:setPosition(cc.p(95, 42))
	viewbtn:addChild(viewLabel)
	viewbtn:setPosition(cc.p(660, 50))
	viewbtn:addClickEventListener(function ()
		AudioMgr.PlayAudio(11)
		if self.uid > 0 then
			--BattleMgr:showCheckInfo(self.uid, isWorld, isArena)
            if self.page and self.page == 4 then
                BattleMgr:showCheckInfo(self.uid,'world','country')
            elseif self.page and self.page == 6 then
            	BattleMgr:showCheckInfo(self.uid,'universe')
            else
                BattleMgr:showCheckInfo(self.uid,'world','arena')
            end
			
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('TO_BE_EXPECTED'), COLOR_TYPE.GREEN)
		end
	end)

	bg:addChild(viewbtn)
	self.viewbtn = viewbtn

	local curRankImg = ccui.ImageView:create("uires/ui/legionwar/legionwar_rank1.png")
	curRankImg:setPosition(cc.p(650,50))
	bg:addChild(curRankImg)
	self.curRankImg = curRankImg

	local rank2Label = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	rank2Label:setAnchorPoint(cc.p(0.5, 0.5))
	rank2Label:setTextColor(COLOR_TYPE.WHITE)
	rank2Label:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	rank2Label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	rank2Label:setPosition(cc.p(650, 25))
	bg:addChild(rank2Label)
	self.rank2Label = rank2Label

	local serverLabel2 = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	serverLabel2:setAnchorPoint(cc.p(0, 0.5))
	serverLabel2:setTextColor(COLOR_TYPE.WHITE)
	serverLabel2:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	serverLabel2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	serverLabel2:setPosition(cc.p(400, 75))
	bg:addChild(serverLabel2)
	self.serverLabel2 = serverLabel2

	local expBg = ccui.ImageView:create('uires/ui/common/exp_barbg.png')
	expBg:setPosition(cc.p(250,35))
	expBg:setScale(0.75)
	expBg:setAnchorPoint(cc.p(0,0.5))
	bg:addChild(expBg)
	self.expBg = expBg

    local bar = ccui.LoadingBar:create("uires/ui/common/exp_bar.png")
    bar:setAnchorPoint(cc.p(0.5, 0.5))
    expBg:addChild(bar)
    bar:setPosition(cc.p(123,19.5))
    bar:setPercent(0)
    self.bar = bar

	local lvImg = ccui.ImageView:create('uires/ui/common/little_bg.png')
	lvImg:setPosition(cc.p(-8, 19.5))
	expBg:addChild(lvImg)

	local barTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	barTx:setAnchorPoint(cc.p(0.5, 0.5))
	barTx:setTextColor(COLOR_TYPE.WHITE)
	barTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	barTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	barTx:setPosition(cc.p(123, 20.5))
	expBg:addChild(barTx)
	self.barTx = barTx

	local lvTx = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	lvTx:setScale(0.65)
	lvTx:setAnchorPoint(cc.p(0.5, 0.5))
	lvTx:setPosition(cc.p(25.5, 26))
	lvImg:addChild(lvTx)
	self.lvTx = lvTx

	self.bg = bg
end

-- main_role 主角id
-- vip
function RankingListCellUI:update(page, index, data)
    self.page = page
	self.luck:setVisible(false)
	self.expBg:setVisible(page == 11)
	self.fightforceImg:setVisible(page ~= 11)
	self.fightforceLabel:setVisible(page ~= 11)
	if page == 1 then -- 战斗力
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		self.fightforceImg:setPosition(cc.p(240, 35))
		self.fightforceLabel:setString(tostring(data.fight_force))
		self.fightforceLabel:setPosition(cc.p(cc.p(265, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 2 then -- 擂台
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		self.fightforceImg:setPosition(cc.p(240, 35))
		self.fightforceLabel:setString(tostring(data.fight_force))
		self.fightforceLabel:setPosition(cc.p(cc.p(265, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 3 then -- 千重楼
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/common/icon_star3.png")
		self.fightforceImg:setPosition(cc.p(245, 35))
		self.fightforceLabel:setString(tostring(data.star))
		self.fightforceLabel:setPosition(cc.p(cc.p(270, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 4 then -- 皇城
		-- 官职
		local positionConf = GameData:getConfData("position")
		self.posLabel:setVisible(true)
		if positionConf[data.posId].position < 3 then
			self.posImg:setVisible(true)
			self.posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_" .. positionConf[data.posId].position + 1 .. ".png")
			if data.posId == 1 then
				self.posLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. data.country))
            else
            	self.posLabel:setString(positionConf[data.posId].title)
            end
			
			self.posLabel:setPosition(cc.p(53, 36))
		else
			self.posImg:setVisible(false)
			self.posLabel:setString( "【" .. positionConf[data.posId].posName .. "】 \n" ..  positionConf[data.posId].title)
			self.posLabel:setPosition(cc.p(53, 52))
			self.posLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
		end
		self.posLabel:setTextColor(COLOR_QUALITY[positionConf[data.posId].quality])
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		self.fightforceImg:setPosition(cc.p(280, 35))
		self.fightforceLabel:setString(tostring(data.fight_force))
		self.fightforceLabel:setPosition(cc.p(cc.p(305, 35)))
		-- 国家图标
		self.countryImg:setVisible(true)
		self.countryImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_flag_" .. data.country .. ".png")
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 名次
		self.rankImg:setVisible(false)
		self.rankLabel:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 5 then -- 军团
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(false)
		local iconConf = GameData:getConfData("legionicon")
		self.headpicBg:loadTexture(iconConf[data.icon].icon)
		self.levelLabel:setString("")
		-- 名字
		self.nameLabel:setString(data.name)
		self.nameLabel:setTextColor(COLOR_TYPE[iconConf[data.icon].nameColor])
		local nameSize = self.nameLabel:getContentSize()
		-- 等级
		self.vipImg:loadTexture("uires/ui/common/lv_art.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		self.vipLabel:setVisible(false)
		self.vipLabel2:setVisible(true)
		self.vipLabel2:setString(tostring(data.level))
		-- 军团人数
		self.fightforceImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_renshu.png")
		self.fightforceImg:setPosition(cc.p(255, 35))
		self.fightforceLabel:setString(tostring(data.count))
		self.fightforceLabel:setPosition(cc.p(cc.p(290, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(false)
		self.headframe:setVisible(false)
		self.uid = 0
	elseif page == 6 then -- 群雄争霸
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.name)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_ji.png")
		self.fightforceImg:setPosition(cc.p(380, 35))
		self.fightforceLabel:setString(tostring(data.score))
		self.fightforceLabel:setPosition(cc.p(cc.p(405, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(true)
		self.serverLabel:setString(data.sid .. GlobalApi:getLocalStr("FU"))
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
	 	self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 7 then -- 人品
		-- 官职
		local positionConf = GameData:getConfData("position")
		self.posLabel:setVisible(true)
		self.posImg:setVisible(true)
		self.rankLabel:setVisible(false)
		if index == 1 then
	        self.posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_1.png")
	        self.posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_18'))
	        self.posLabel:setTextColor(COLOR_TYPE.ORANGE)
	    elseif index == 2 then
	        self.posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_2.png")
	        self.posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_19'))
	        self.posLabel:setTextColor(COLOR_TYPE.PURPLE)
	    elseif index == 3 then
	        self.posImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_3.png")
	        self.posLabel:setString(GlobalApi:getLocalStr('TRVEN_DESC_20'))
	        self.posLabel:setTextColor(COLOR_TYPE.BLUE)
	    else
	        self.posImg:setVisible(false)
	        self.posLabel:setVisible(false)
	        self.rankLabel:setVisible(true)
	        self.rankLabel:setString(index)
	    end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)

		self.headpic:loadTexture(obj:getIcon())
		-- 等级
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			self.headpicBg:loadTexture(COLOR_FRAME[data.quality])
		end
		self.levelLabel:setString(tostring(data.level))
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/text/renping_tx.png")
		self.fightforceImg:setPosition(cc.p(260, 35))
		self.fightforceLabel:setString("")
		self.luck:setVisible(true)
		self.luck:setString(tostring(data.luck))
		self.luck:setPosition(cc.p(cc.p(295, 35)))
		-- 国家图标
		self.countryImg:setVisible(false)
		--self.countryImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_flag_" .. data.country .. ".png")
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 名次
		self.rankImg:setVisible(false)
		--self.rankLabel:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 8 or page == 9 then -- 军团战
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(false)
		local iconConf = GameData:getConfData("legionicon")
		self.headpicBg:loadTexture(iconConf[data.icon].icon)
		self.levelLabel:setString("")
		-- 名字
		self.nameLabel:setString(data.name)
		self.nameLabel:setTextColor(COLOR_TYPE[iconConf[data.icon].nameColor])
		local nameSize = self.nameLabel:getContentSize()
		-- 等级
		-- self.vipImg:loadTexture("uires/ui/common/lv_art.png")
		-- self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		-- self.vipLabel:setVisible(false)
		-- self.vipLabel2:setVisible(true)
		-- self.vipLabel2:setString(tostring(data.level))
		-- 军团人数
		self.fightforceImg:loadTexture("uires/ui/legionwar/legionwar_score_icon.png")
		self.fightforceImg:setPosition(cc.p(255, 35))
		self.fightforceLabel:setString(tostring(data.score))
		self.fightforceLabel:setPosition(cc.p(cc.p(290, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		--self.serverLabel:setString(data.curScore)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.countryImg:loadTexture("uires/ui/legionwar/legionwar_score_icon.png")
		self.viewbtn:setVisible(false)
		self.headframe:setVisible(false)
		local rankid = LegionMgr:calcRank(data.score)
		local rankconf = GameData:getConfData('legionwarrank')
		self.curRankImg:setVisible(true)
		-- print("uires/ui/legionwar/legionwar_rank".. tostring(rankconf[rankid].icon) ..".png")

		self.curRankImg:loadTexture("uires/ui/legionwar/legionwar_".. tostring(rankconf[rankid].icon))
		self.rank2Label:setVisible(true)
		self.rank2Label:setString(rankconf[rankid].name)
		if page == 8 then
			self.serverLabel2:setString(data.sid..GlobalApi:getLocalStr('FU'))
		else
			self.serverLabel2:setString('')
		end
		self.uid = 0
    elseif page == 10 then -- 领地战龙境
        
        -- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())

		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)

		-- 击杀数
		self.fightforceImg:loadTexture("uires/ui/territorialwars/terwars_kill_num.png")
		self.fightforceImg:setPosition(cc.p(290, 35))
		self.fightforceLabel:setString(tostring(data.killCount))
		self.fightforceLabel:setPosition(cc.p(cc.p(345, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid
	elseif page == 11 then -- 等级
		-- 名次
		if index <= 3 then
			self.rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. index .. ".png")
			self.rankImg:setVisible(true)
			self.rankLabel:setVisible(false)
		else
			self.rankImg:setVisible(false)
			self.rankLabel:setVisible(true)
			self.rankLabel:setString(tostring(index))
		end
		-- 头像
		self.headpic:setVisible(true)
		local obj = RoleData:getHeadPicObj(data.headpic)
		self.headpic:loadTexture(obj:getIcon())
		if data.uid <= 1000000 then -- 机器人
			self.headpicBg:loadTexture(COLOR_FRAME[4])
		else
			local quality = GameData:getConfData("hero")[data.main_role].quality
			self.headpicBg:loadTexture(COLOR_FRAME[quality])
		end
	    self.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	    self.headframe:setVisible(true)
		-- 等级
		self.levelLabel:setString(tostring(data.level))
		-- 名字
		self.nameLabel:setString(data.un)
		self.nameLabel:setTextColor(COLOR_TYPE.WHITE)
		local nameSize = self.nameLabel:getContentSize()
		-- vip
		self.vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
		self.vipImg:setPosition(cc.p(nameSize.width + 255, 75))
		local vip = data.vip or 1
		self.vipLabel:setString(tostring(vip))
		self.vipLabel:setVisible(true)
		self.vipLabel2:setVisible(false)
		-- 战斗力
		self.fightforceImg:loadTexture("uires/ui/common/fightbg.png")
		self.fightforceImg:setPosition(cc.p(240, 35))
		self.fightforceLabel:setString(tostring(data.fight_force))
		self.fightforceLabel:setPosition(cc.p(cc.p(265, 35)))
		-- 服务器编号
		self.serverLabel:setVisible(false)
		-- 官职图片
		self.posImg:setVisible(false)
		-- 官职名字
		self.posLabel:setVisible(false)
		-- 国家图标
		self.countryImg:setVisible(false)
		self.curRankImg:setVisible(false)
		self.rank2Label:setVisible(false)
		self.serverLabel2:setVisible(false)
		self.viewbtn:setVisible(true)
		self.uid = data.uid

		local lvConf = GameData:getConfData("level")[data.level]
		local per = math.floor(data.xp/lvConf.exp*10000)/100
		self.bar:setPercent(per)
		self.barTx:setString(per..'%')
		self.lvTx:setString(data.level)
	end
end

function RankingListCellUI:setPosition(pos)
	self.bg:setPosition(pos)
end

function RankingListCellUI:getNode()
	return self.bg
end

function RankingListCellUI:setVisible(vis)
	self.bg:setVisible(vis)
end

return RankingListCellUI