local CountryWarListUI = class("CountryWarListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CountryWarListUI:ctor(data,page)
	self.uiIndex = GAME_UI.UI_COUNTRYWAR_LIST
	self.page = page or 1
	self.pageBtns = {}
	self.data = data
    self.maxCellNum = 0
	-- self:updateData(lordCount)
end

function CountryWarListUI:updatePageBtn()
    for i=1,3 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == self.page then
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
    local color
    if self.page == 1 then
        self.pls[1]:setVisible(true)
        self.pls[2]:setVisible(false)
        color = COLOR_TYPE.GREEN
    else
        self.pls[1]:setVisible(false)
        self.pls[2]:setVisible(true)
        color = COLOR_TYPE.YELLOW
    end
    local titleBg = self.bg1:getChildByName('subtitle_bg')
    local size = titleBg:getContentSize()
    if not self.titleRTs then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(500, 30))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
        local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_1_'..self.page),22,COLOR_TYPE.PALE)
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_2_'..self.page),22,color)
        local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_3_'..self.page),22,COLOR_TYPE.PALE)
        re:setStroke(COLOROUTLINE_TYPE.PALE, 1)
        re1:setStroke(COLOROUTLINE_TYPE.PALE, 1)
        re2:setStroke(COLOROUTLINE_TYPE.PALE, 1)
        re:setFont('font/gamefont.ttf')
        re1:setFont('font/gamefont.ttf')
        re2:setFont('font/gamefont.ttf')
        richText:addElement(re)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setPosition(cc.p(size.width/2,size.height/2 - 2))
        titleBg:addChild(richText)
        self.titleRTs = {richText = richText,re = re,re1 = re1,re2 = re2}
    else
        self.titleRTs.re:setString(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_1_'..self.page))
        self.titleRTs.re1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_2_'..self.page))
        self.titleRTs.re2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_RANK_LIST_TITLE_3_'..self.page))
        self.titleRTs.re1:setColor(color)
        self.titleRTs.richText:format(true)
    end
end

function CountryWarListUI:getMyRank()
    local rank = 0
    for i,v in ipairs(self.data.campRankList) do
        if tonumber(v.country) == CountryWarMgr.camp then
            rank = v.rank
            break
        end
    end
    return rank
end

function CountryWarListUI:updateCampPanel()
    self.myCampRank = 3
    for i = 1, 3 do
	    local city = self.pls[self.page]:getChildByName("city_" .. i)
	    local bgImg = city:getChildByName("bg_img")
	    bgImg:ignoreContentAdaptWithSize(true)
	    bgImg:loadTexture("uires/ui/country/bg_1" .. self.data.campRankList[i].country ..  ".png")
	    local rankImg = city:getChildByName("rank_img")
	    rankImg:ignoreContentAdaptWithSize(true)
	    rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. self.data.campRankList[i].rank .. ".png")
	    local flag1 = city:getChildByName("flag_1")
	    flag1:ignoreContentAdaptWithSize(true)
	    flag1:loadTexture("uires/ui/countrywar/countrywar_flag_" .. self.data.campRankList[i].country ..  ".png")
	    local flag2 = city:getChildByName("flag_2")
	    flag2:ignoreContentAdaptWithSize(true)
	    flag2:loadTexture("uires/ui/country/country_flag_" .. self.data.campRankList[i].country .. "_" .. self.data.campRankList[i].country .. ".png")
	    local infoTx = city:getChildByName("info_tx")
	    infoTx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_6"))
	    local numTx = city:getChildByName("num_tx")
	    numTx:setString(tostring(self.data.campRankList[i].score.week))
        local boxBtn = city:getChildByName('box_btn')
        boxBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local rank = self:getMyRank()
                CountryWarMgr:showCountryWarAward(self.page,i,rank,self.data.weekRank,self.data.dayRank)
            end
        end)
        if self.data.campRankList[i].country == CountryWarMgr.camp then
            self.myCampRank = i
        end
	end

    local awardBtn = self.pls[self.page]:getChildByName('award_btn')
    local infotx = awardBtn:getChildByName('info_tx')
    infotx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_54"))
    awardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rank = self:getMyRank()
            CountryWarMgr:showCountryWarAward(self.page,self.myCampRank,rank,self.data.weekRank,self.data.dayRank)
        end
    end)
end

function CountryWarListUI:getServer(id)
    local tab = GlobalData:getServerTab()
    for k,v in pairs(tab) do
        if v.id == id then
            return v.name
        end
    end
    return ''
end

function CountryWarListUI:updateMyInfo()
    local myFrame = self.pls[2]:getChildByName('self_frame')
    local rankImg = myFrame:getChildByName('rank_img')
    local rankTx = myFrame:getChildByName('rank_tx')
    local posImg = myFrame:getChildByName('pos_img')
    local posTx = myFrame:getChildByName('pos_tx')
    local myRankTx = myFrame:getChildByName('my_rank_tx')
    local nameTx = myFrame:getChildByName('name_tx')
    local vipImg = myFrame:getChildByName('vip_img')
    local vipTx = vipImg:getChildByName('vip_tx')
    local fightForceTx = myFrame:getChildByName('fight_force_tx')
    local numTx = myFrame:getChildByName('num_tx')
    local responseBtn = myFrame:getChildByName('response_btn')

    local roleNode = myFrame:getChildByName('role_node')
    local awardBgImg = roleNode:getChildByName('award_bg_img')
    if not awardBgImg then
        local mainRole = RoleData:getMainRole()
        local obj = RoleData:getHeadPicObj(UserData:getUserObj().headpic)
        local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
        roleNode:addChild(headpicCell.awardBgImg)
        headpicCell.awardBgImg:loadTexture(mainRole:getBgImg())
        headpicCell.awardImg:loadTexture(obj:getIcon())
        headpicCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
        headpicCell.headframeImg:setVisible(true)
        headpicCell.lvTx:setString(UserData:getUserObj():getLv())
    end
    nameTx:setString(UserData:getUserObj():getName())
    vipTx:setString(UserData:getUserObj():getVip())
    fightForceTx:setString(RoleData:getFightForce())
    -- numTx:setString(self.data.score or 0)

    local scores = {
        [2] = self.data.score,
        [3] = self.data.weekScore,
    }
    numTx:setString(scores[self.page] or 0)

    local rank = {
        [2] = self.data.dayRank,
        [3] = self.data.weekRank,
    }
    local rank = rank[self.page]
    myRankTx:setString(GlobalApi:getLocalStr('STR_MY_RANK'))
    if rank == 0 then
        posTx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_33'))
        rankImg:setVisible(false)
        rankTx:setString('')
    elseif rank <= 3 then
        posTx:setString('')
        rankImg:setVisible(true)
        rankTx:setString('')
        rankImg:loadTexture('uires/ui/rankinglist_v3/rlistv3_rank_'..rank..'.png')
        rankImg:ignoreContentAdaptWithSize(true)
    else
        posTx:setString('')
        rankImg:setVisible(false)
        rankTx:setString(rank)
    end

    local size1 = nameTx:getContentSize()
    local x,y = nameTx:getPosition()
    local size2 = vipImg:getContentSize()
    vipImg:setPosition(cc.p(x + size1.width + 5,y))
    vipTx:setPosition(cc.p(size2.width + 2,size2.height/2))
    local infoTx = responseBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_49'))
    responseBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rank = self:getMyRank()
            if self.page == 2 then
                CountryWarMgr:showCountryWarAward(2,CountryWarMgr.camp,rank,self.data.weekRank,self.data.dayRank)
            else
                CountryWarMgr:showCountryWarAward(1,self.myCampRank,rank,self.data.weekRank,self.data.dayRank)
            end
        end
    end)
end

function CountryWarListUI:updateListPanel(data)
	local maxCell = #data
	local diffHeight = 8
	local singleSize
	for i=1,maxCell do
		local bgImg = self.sv:getChildByName('cell_bg_img_'..i)
		if not bgImg then
			local node = cc.CSLoader:createNode("csb/countrywarlistcell.csb")
			bgImg = node:getChildByName('bg_img')
			bgImg:removeFromParent(false)
			bgImg:setName('cell_bg_img_'..i)
			self.sv:addChild(bgImg)
		end
        bgImg:setVisible(true)
		singleSize = bgImg:getContentSize()
        local rankImg = bgImg:getChildByName('rank_img')
        local rankTx = bgImg:getChildByName('rank_tx')
        local nameTx = bgImg:getChildByName('name_tx')
        local numTx = bgImg:getChildByName('num_tx')
        local vipImg = bgImg:getChildByName('vip_img')
        local vipTx = bgImg:getChildByName('vip_tx')
        local fightForceTx = bgImg:getChildByName('fight_force_tx')
        local beatTx = bgImg:getChildByName('beat_tx')

        local obj = RoleData:getHeadPicObj(data[i].headpic)
        local obj1 = RoleData:getRoleInfoById(data[i].main_role)
        local roleNode = bgImg:getChildByName('role_node')
        local awardBgImg = roleNode:getChildByName('award_bg_img')
        if not awardBgImg then
            local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
            awardBgImg = headpicCell.awardBgImg
            roleNode:addChild(headpicCell.awardBgImg)
        end
        local awardImg = awardBgImg:getChildByName('award_img')
        local headframeImg = awardBgImg:getChildByName('headframeImg')
        local lvTx = awardBgImg:getChildByName('lv_tx')
        awardBgImg:loadTexture(obj1:getBgImg())
        awardImg:loadTexture(obj:getIcon())
        headframeImg:loadTexture(GlobalApi:getHeadFrame(data[i].headframe))
        headframeImg:setVisible(true)
        lvTx:setString(data[i].level)

        nameTx:setString(data[i].un)
        vipTx:setString(data[i].vip)
        if self.page == 2 then
            numTx:setString(data[i].score)
        else
            numTx:setString(data[i].weekScore)
        end
        local size1 = nameTx:getContentSize()
        local x,y = nameTx:getPosition()
        local size2 = vipImg:getContentSize()
        vipImg:setPosition(cc.p(x + size1.width + 5,y))
        vipTx:setPosition(cc.p(x + size1.width + size2.width + 10,y))
        fightForceTx:setString(data[i].fight_force)
        beatTx:setString(data[i].server..GlobalApi:getLocalStr("FU")..' '..self:getServer(data[i].server))

        if i <= 3 then
            rankImg:setVisible(true)
            rankTx:setString('')
            rankImg:loadTexture('uires/ui/rankinglist_v3/rlistv3_rank_'..i..'.png')
            rankImg:ignoreContentAdaptWithSize(true)
        else
            rankImg:setVisible(false)
            rankTx:setString(i)
        end
	end

    local size = self.sv:getContentSize()
    if singleSize then
        if maxCell*(singleSize.height + diffHeight) > size.height then
            self.sv:setInnerContainerSize(cc.size(size.width,maxCell*(singleSize.height + diffHeight) + diffHeight))
            for i=1,maxCell do
            	local bgImg = self.sv:getChildByName('cell_bg_img_'..i)
            	bgImg:setPosition(cc.p(12,(maxCell - i)*(singleSize.height + diffHeight) + diffHeight))
            end
        else
            self.sv:setInnerContainerSize(size)
            for i=1,maxCell do
            	local bgImg = self.sv:getChildByName('cell_bg_img_'..i)
            	bgImg:setPosition(cc.p(12,size.height - i*(singleSize.height + diffHeight)))
            end
        end
        local bgSv = self.sv:getChildByName('bg_sv')
        bgSv:setContentSize(self.sv:getInnerContainerSize())
    end
    if maxCell < self.maxCellNum then
        for i = maxCell + 1,self.maxCellNum do
            local bgImg = self.sv:getChildByName('cell_bg_img_'..i)
            if bgImg then
                bgImg:setVisible(false)
            end
        end
    end
    self.maxCellNum = maxCell
    self:updateMyInfo(true)
end

function CountryWarListUI:updateData()
	if self.page == 1 then
		table.sort(self.data.campRankList, function (a, b)
			if a.score.week == b.score.week then
				return a.country < b.country
			else
				return a.score.week > b.score.week
			end
		end)
		-- local maxCount = self.data.campRankList[1].score.week
		-- self.data.campRankList[1].rank = 1
		-- for i = 2, 3 do
		-- 	if maxCount <= self.data.campRankList[i].score.week then
		-- 		self.data.campRankList[i].rank = self.data.campRankList[i-1].rank
		-- 	else
		-- 		self.data.campRankList[i].rank = i
		-- 	end
		-- 	maxCount = self.data.campRankList[i].score.week
		-- end
        for i=1,3 do
            self.data.campRankList[i].rank = i
        end
		self:updateCampPanel()
	elseif self.page == 2 then
		self:updateListPanel(self.data.dayRankList)
    else
        self:updateListPanel(self.data.weekRankList)
	end
end

function CountryWarListUI:updatePanel()
	self:updateData()
	self:updatePageBtn()
end

function CountryWarListUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local grayImg = self.root:getChildByName("gray_img")
    local bg1 = grayImg:getChildByName("bg1")
    self:adaptUI(grayImg)
    bg1:setPosition(cc.p(winsize.width/2,winsize.height/2 - 5))
    self.bg1 = bg1

    local closeBtn = bg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	CountryWarMgr:hideCountryWarList()
        end
    end)

    self.pls = {}
    local bg2 = bg1:getChildByName('bg2')
	for i=1,3 do
		local pl = bg2:getChildByName('pl'..i)
		self.pls[i] = pl
        local pageBtn = bg1:getChildByName('page_'..i..'_btn')
        local infoTx = pageBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_LIST_TITLE_DESC_'..i))
        self.pageBtns[i] = pageBtn
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
	end
    self.sv = self.pls[2]:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
	self:updatePanel()
end

return CountryWarListUI