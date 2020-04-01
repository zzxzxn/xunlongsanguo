require "script/app/data/globaldata"
local LoginUI = class("LoginUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
	
local NoticeUI = require("script/app/ui/notice/notice")

local OPEN_UPDATE = false

function LoginUI:ctor()
	self.uiIndex = GAME_UI.UI_LOGIN
end

function LoginUI:updateSelectQu()
	local selectBgImg = self.selectQuBgImg:getChildByName("select_bg_img")
	local diff = 15
	local sizeHeight = 60
	local maxNum = 0
	local min = 1 + (self.page - 1)*10
	for i=min + 9,min,-1 do
		if self.tab[i] then
			maxNum = maxNum + 1
		end
	end
	local maxHeight = math.ceil(maxNum/2)
	if maxHeight < 4 then
		maxHeight = 3.5
	end
	local size = self.cardSv:getContentSize()
	local num = 0
	for i=min + 9,min,-1 do
		local serverBgImg = self.cardSv:getChildByName('server_'..(i - min + 1)..'_img')
		if not self.tab[i] then
			if serverBgImg then
				serverBgImg:setVisible(false)
			end
		else
			num = num + 1
			if not serverBgImg then
				local cellNode = cc.CSLoader:createNode("csb/logincell.csb")
				serverBgImg = cellNode:getChildByName('server_bg_img')
				local roleBgNode = serverBgImg:getChildByName("role_bg_node")
				local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
				roleBgNode:addChild(headCell.awardBgImg)
		        serverBgImg:removeFromParent(false)
		        serverBgImg:setName('server_'..(i - min + 1)..'_img')
				self.cardSv:addChild(serverBgImg)
			end
			serverBgImg:setVisible(true)
			local size1 = serverBgImg:getContentSize()
			local d = (size.width - size1.width*2)/3
			local x = num%2
			local y = math.floor((num - 1)/2)
			serverBgImg:setPosition(cc.p((x==1 and d) or (d*2 + size1.width),(maxHeight - y - 1)*(sizeHeight + diff) + 10))
			local bgImg = serverBgImg:getChildByName('bg_img')
			local neiBgimg = serverBgImg:getChildByName('bg_img')
			local roleBgNode = serverBgImg:getChildByName('role_bg_node')
			local roleBgImg = roleBgNode:getChildByName('award_bg_img')
			local nameTx = serverBgImg:getChildByName('name_tx')
			local fireImg = serverBgImg:getChildByName('fire_img')
			local roleImg = roleBgImg:getChildByName('award_img')
			local lvTx = roleBgImg:getChildByName('lv_tx')
			local serverTx = serverBgImg:getChildByName('server_tx')
			local data = RoleData:getHeadPicObj(self.tab[i].headpic)
			if self.tab[i].status == 0 then
				fireImg:setVisible(true)
				roleBgImg:setVisible(false)
				serverBgImg:setTouchEnabled(false)
				ShaderMgr:setGrayForWidget(fireImg)
				ShaderMgr:setGrayForWidget(bgImg)
				ShaderMgr:setGrayForWidget(neiBgimg)
				nameTx:setColor(COLOR_TYPE.GRAY)
				serverTx:setColor(COLOR_TYPE.GRAY)
				fireImg:loadTexture('loginpanel/weihu.png')
			else
				nameTx:setColor(COLOR_TYPE.WHITE)
				serverTx:setColor(COLOR_TYPE.ORANGE)
				serverBgImg:setTouchEnabled(true)
				ShaderMgr:restoreWidgetDefaultShader(bgImg)
				ShaderMgr:restoreWidgetDefaultShader(neiBgimg)
				ShaderMgr:restoreWidgetDefaultShader(fireImg)
				roleBgImg:loadTexture(data:getBgImg())
				roleImg:loadTexture(data:getIcon())
				roleImg:ignoreContentAdaptWithSize(true)
			    -- headframeImg:loadTexture(GlobalApi:getHeadFrame(self.tab[i].headframe))
				GlobalApi:regiesterBtnHandler(serverBgImg,function()
					-- self.serverName:setString('S'..self.tab[i].id..' '..self.tab[i].name)
					GlobalData:setGateWayUrl(self.tab[i].host)
					GlobalData:setSelectSeverUid(self.tab[i].id)
					GlobalData:setSelectSeverName(self.tab[i].name)
					GlobalData:setSelectUid(self.tab[i].uid)
					cc.UserDefault:getInstance():setIntegerForKey('serverID_1',self.tab[i].id)
					self:setServerName()
					self.selectQuBgImg:setVisible(false)
				end)
				if self.tab[i].uid then
					roleBgImg:setVisible(true)
					lvTx:setString(self.tab[i].level)
					fireImg:setVisible(false)
				else
					fireImg:setVisible(true)
					roleBgImg:setVisible(false)
				end
				if self.tab[i].status == 3 then
					fireImg:loadTexture('loginpanel/tuijian.png')
				elseif self.tab[i].status == 2 then
					fireImg:loadTexture('loginpanel/new.png')
				elseif self.tab[i].status == 1 then
					fireImg:loadTexture('loginpanel/fire.png')
				end
			end
			nameTx:setString(self.tab[i].name)
			serverTx:setString(string.format('%03d',self.tab[i].id)..GlobalApi:getLocalStr('STR_AREA'))
		end
	end
    if maxNum > 6 then
        self.cardSv:setInnerContainerSize(cc.size(size.width,maxHeight * (sizeHeight + diff) + 10))
    else
        self.cardSv:setInnerContainerSize(size)
    end
end

function LoginUI:updateList()
	for i=1,self.maxPage do
		local item = self.list:getItem(i - 1)
		if not item then
			self.list:pushBackDefaultItem()
			item = self.list:getItem(i - 1)
		end
	end
	for i=1,self.maxPage do
		local item = self.list:getItem(self.maxPage - i)
		if self.page == i then
			item:setBrightStyle(ccui.BrightStyle.highlight)
			item:setTouchEnabled(false)
		else
			item:setBrightStyle(ccui.BrightStyle.normal)
			item:setTouchEnabled(true)
		end
		local infoTx = item:getChildByName('info_tx')
		infoTx:setString(((i - 1)*10 + 1)..'-'..(i*10)..GlobalApi:getLocalStr('STR_AREA'))
		item:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	self.page = i
				self:updateList()
				self:updateSelectQu()
	        end
		end)
	end
end

function LoginUI:createSelectQu()
	local tab = GlobalData:getServerTab()
	self.tab = {}
	for i,v in ipairs(tab) do
		self.tab[i] = v
	end
	table.sort(self.tab,function(a, b)
		return b.id > a.id
	end)
	self.page = math.ceil(#self.tab/10)
	self.maxPage = math.ceil(#self.tab/10)
	local selectBgImg = self.selectQuBgImg:getChildByName("select_bg_img")
	local infoTx = selectBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('LOGIN_INFO_TX'))
	self.cardSv = selectBgImg:getChildByName('server_sv')
	self.cardSv:setScrollBarEnabled(false)
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.selectQuBgImg:setScale9Enabled(true)
	self.selectQuBgImg:setContentSize(winSize)
	self.selectQuBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	self.selectQuBgImg:setVisible(true)
	selectBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

	self.list = selectBgImg:getChildByName('list')
	local cell = cc.CSLoader:createNode('csb/loginservercell.csb')
	local serverBtn = cell:getChildByName('server_btn')
	serverBtn:removeFromParent(false)
	self.list:setItemModel(serverBtn)

    local tab = {}
    for i,v in ipairs(self.tab) do
    	if v.uid then
    		tab[#tab + 1] = v
    	end
    end
    table.sort(tab,function(a,b)
    	return a.index < b.index
    end )
	for i=1,3 do
		local roleBgNode = selectBgImg:getChildByName('role_bg_'..i..'_node')
		local roleBgImg = roleBgNode:getChildByName("award_bg_img")
		local headframeImg = roleBgNode:getChildByName('headframeImg')
		if not roleBgImg then
			local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
			roleBgNode:addChild(headCell.awardBgImg)
			roleBgImg = headCell.awardBgImg
			headframeImg = cell.headframeImg
		end
		local roleImg = roleBgImg:getChildByName('award_img')
		local lvTx = roleBgNode:getChildByName('lv_tx')
		local nameTx = roleBgNode:getChildByName('name_tx')
		local serverIdTx = roleBgNode:getChildByName('server_id_tx')
		if tab[i] then
			local data = RoleData:getHeadPicObj(tab.headpic)
			roleBgImg:loadTexture(data:getBgImg())
			roleImg:loadTexture(data:getIcon())
			roleImg:ignoreContentAdaptWithSize(true)
		    -- headframeImg:loadTexture(GlobalApi:getHeadFrame(tab.headframe))
			lvTx:setString("lv."..tab[i].level)
			serverIdTx:setString(string.format('%03d',tab[i].id)..GlobalApi:getLocalStr('STR_AREA'))
			nameTx:setString(((not tab[i].un) and GlobalApi:getLocalStr('NO_NAME')) or tab[i].un)
			roleBgNode:setVisible(true)
		else
			roleBgNode:setVisible(false)
		end
		if tab[i] and tab[i].status ~= 0 then
			roleBgImg:setTouchEnabled(true)
			roleBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GlobalData:setGateWayUrl(tab[i].host)
					GlobalData:setSelectSeverUid(tab[i].id)
					GlobalData:setSelectSeverName(tab[i].name)
					GlobalData:setSelectUid(tab[i].uid)
					cc.UserDefault:getInstance():setIntegerForKey('serverID_1',tab[i].id)
					self.selectQuBgImg:setVisible(false)
					self:setServerName()
		        end
			end)
		else
			roleBgImg:setTouchEnabled(false)
		end
	end

	self:updateList()
	self:updateSelectQu()
end

function LoginUI:setServerName()
	local serverInfo = GlobalData:getServerInfoById(GlobalData:getSelectSeverUid())
	self.serverName:setString('S'..serverInfo.id..' '..serverInfo.name)

	local enter = self.root:getChildByName("enter_game_btn")
	if serverInfo.status == 0 then
		self.fireImg:loadTexture('loginpanel/weihu.png')
		ShaderMgr:setGrayForWidget(enter)
		enter:setTouchEnabled(false)
	elseif serverInfo.status == 1 then
		self.fireImg:loadTexture('loginpanel/fire.png')
		enter:getChildByName('info_tx')
		:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
		:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
		ShaderMgr:restoreWidgetDefaultShader(enter)
		enter:setTouchEnabled(true)
	elseif serverInfo.status == 2 then
		self.fireImg:loadTexture('loginpanel/new.png')
		enter:getChildByName('info_tx')
		:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
		:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
		ShaderMgr:restoreWidgetDefaultShader(enter)
		enter:setTouchEnabled(true)
	elseif serverInfo.status == 3 then
		self.fireImg:loadTexture('loginpanel/tuijian.png')
		enter:getChildByName('info_tx')
		:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
		:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
		ShaderMgr:restoreWidgetDefaultShader(enter)
		enter:setTouchEnabled(true)
	end
end

function LoginUI:onShow()
	-- self:updateChild()
end

function LoginUI:updateChild(isHide)
	self.root:stopAllActions()
	local selectServerImg = self.root:getChildByName("select_server_img")
	self.serverName = selectServerImg:getChildByName("server_tx")
	local enterGameBtn = self.root:getChildByName("enter_game_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	local size = enterGameBtn:getContentSize()
	local versionTx = self.root:getChildByName("version_tx")
	versionTx:setString('')
	-- enterGameBtn:setOpacity(0)
	-- selectServerImg:setOpacity(0)
	-- versionTx:setOpacity(0)
	-- self.noticeBtn:setOpacity(0)
	-- self.logoutBg:setOpacity(0)
	enterGameBtn:setPosition(winSize.width/2, 104)
	selectServerImg:setPosition(winSize.width/2,185)
	versionTx:setPosition(cc.p(winSize.width - 10,0))
    if not isHide then
		self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
			cc.CallFunc:create(function()
				versionTx:runAction(cc.FadeIn:create(0.5))
				enterGameBtn:setVisible(true)
				enterGameBtn:runAction(cc.FadeIn:create(0.5))
				selectServerImg:runAction(cc.FadeIn:create(0.5))
				selectServerImg:setVisible(true)
				self.noticeBtn:runAction(cc.FadeIn:create(0.5))
				self.logoutBg:runAction(cc.FadeIn:create(0.5))
				self.noticeBtn:setTouchEnabled(true)
			end)
	    ))
    end
end

function LoginUI:initLoading()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local loadingBarBg = cc.Sprite:create("uires/ui/common/common_bar_bg_1.png")
    local size = loadingBarBg:getContentSize()
    local loadingBar = ccui.LoadingBar:create("uires/ui/common/common_bar_1.png")
    -- local loadingBar = ccui.LoadingBar:create(cc.Sprite:create("uires/ui/common/common_bar_1.png"))
    local barSize = loadingBar:getContentSize()
    -- loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- loadingBar:setMidpoint(cc.p(0, 0))
    -- loadingBar:setBarChangeRate(cc.p(1, 0))
    loadingBarBg:addChild(loadingBar)
    loadingBar:setPosition(cc.p(size.width/2, size.height/2))
    loadingBar:setPercent(0)

    local numTx = ccui.Text:create()
    numTx:setFontName('font/gamefont.ttf')
    numTx:setFontSize(20)
    numTx:setColor(COLOR_TYPE.WHITE)
    numTx:enableOutline(COLOR_TYPE.BLACK, 1)
    numTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    numTx:setAnchorPoint(cc.p(1,0.5))
    numTx:setPosition(cc.p(size.width/2 + 5, size.height/2))
    loadingBarBg:addChild(numTx)
    numTx:setString(0)

    local numTx1 = ccui.Text:create()
    numTx1:setFontName('font/gamefont.ttf')
    numTx1:setFontSize(20)
    numTx1:setColor(COLOR_TYPE.WHITE)
    numTx1:enableOutline(COLOR_TYPE.BLACK, 1)
    numTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    numTx1:setAnchorPoint(cc.p(0,0.5))
    numTx1:setPosition(cc.p(size.width/2 + 5, size.height/2))
    numTx1:setString('%')
    loadingBarBg:addChild(numTx1)

    local numTx2 = ccui.Text:create()
    numTx2:setFontName('font/gamefont.ttf')
    numTx2:setFontSize(20)
    numTx2:setColor(COLOR_TYPE.ORANGE)
    numTx2:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
    numTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    numTx2:setAnchorPoint(cc.p(0.5,0.5))
    numTx2:setPosition(cc.p(size.width/2 + 5, size.height/2 + 30))
    loadingBarBg:addChild(numTx2)
    numTx2:setString(GlobalApi:getLocalStr('LOGIN_DESC'))

	loadingBarBg:setPosition(winSize.width/2,85)
	self.root:addChild(loadingBarBg)

    local nowImgCount = 0
    local loadedImgMaxCount = 41
    local perDiff = 3
    local function enterGame()
		numTx:setString(100)
		loadingBar:setPercent(100)
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
            local flag = false
            LoginMgr:hideLogin()
            UIManager:getSidebar():setFrameBtnsVisible(true)
            if not GuideMgr:isRunning() then
            	local guideStep = UserData:getUserObj():getMark().guide
                flag = GuideMgr:startFirstGuide(guideStep)
            end
            if not flag then
            	local fighted = MapData:getFightedCityId()
            	local cityData = MapData.data[fighted]
            	local isFirst = cityData:getBfirst()
            	if isFirst then
                	MapMgr:showMainScene(2)
            	else
			 		MainSceneMgr:showMainCityFromLogin()
			 	 	local confIndex = MapData:getFightedCityId()
					if confIndex > 0 then
    					local guideIndex = MapData.data[confIndex].conf.guideIndex
    					if guideIndex > 0 then
    						local guideStep = UserData:getUserObj():getMark().guide
                  			GuideMgr:startCityOpenGuide(guideIndex, guideStep)
                  		end
                  	end
                    LoginPopWindowMgr:showPopWindow()
				end
            end
        end)))
    end
    local function runBar()
    	local loadingPercent = math.floor((nowImgCount/loadedImgMaxCount)*100)
    	local maxPer = math.floor(((loadedImgMaxCount - 2)/loadedImgMaxCount)*100)
    	local percent = math.floor(loadingBar:getPercent())
    	local diff = loadingPercent - percent
    	if diff >= perDiff then
    		numTx:setString(percent + perDiff)
    		loadingBar:setPercent(percent + perDiff)
    	elseif diff > 0 then
    		numTx:setString(percent + diff)
    		loadingBar:setPercent(percent + diff)
    	elseif loadingPercent >= maxPer then
    		numTx:setString(maxPer)
    		loadingBar:setPercent(maxPer)
    		if enterGame then
    			enterGame()
    		end
    		self.runBarEnd = true
    		return
    	elseif loadingPercent == percent then
    		self.runBarEnd = true
    		return
    	end
    	self.runBarEnd = false
    	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(runBar)))
    end
    self.runBarEnd = true
    local function imageLoaded(_,num)
    	nowImgCount = nowImgCount + (num or 1)
    	if self.runBarEnd then
    		runBar()
    	end
    end

    local conf = GameData:getConfData("local/building")
    loadedImgMaxCount = loadedImgMaxCount + table.getn(conf)
    
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_building_bg.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/new_point.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/guard/guard_lock.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/fight_nor_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/fight_sel_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_cash.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_food.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_gold.png',imageLoaded)

    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_arena.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_boat.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_blacksmith.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_pub.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_mail.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_tower.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_goldmine.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_altar.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_statue.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_stable.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_shop.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_worldwar.png', imageLoaded)

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
    	LoginUI:preloadConf(imageLoaded)
	end)))

	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function ()
    	for k,v in ipairs(conf) do
	    	local url = "animation/" .. v.url .. "/" .. v.url
		    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(url  .. ".png", url .. ".plist", url .. ".json", imageLoaded)
		end
	end)))
    

    LoginMgr:StartEnteringGame(function(num)
    	imageLoaded(nil,num)
    end)
end

function LoginUI:init()
	local winSize = cc.Director:getInstance():getVisibleSize()
	-- local spine = GlobalApi:createSpineByName("login", "spine_lossless/login/login", 2)
	-- spine:setAnimation(0, "idle01", true)
 --    spine:registerSpineEventHandler(function (event)
 --        if math.random(100) > 50 then
 --            spine:setAnimation(0, "idle", true)
 --        else
 --            spine:setAnimation(0, "idle01", true)
 --        end
 --    end, sp.EventType.ANIMATION_COMPLETE)
	-- spine:setLocalZOrder(-1)
	-- spine:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	-- if 1142/770 > winSize.width/winSize.height then
	-- 	spine:setScale(winSize.height/770.01)
	-- else
	-- 	spine:setScale(winSize.width/1142.01)
	-- end
	-- self.root:addChild(spine)

	local imgBG = cc.Sprite:create("loginpanel/loginBG.png")
	imgBG:setLocalZOrder(-1)
	imgBG:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	local size = imgBG:getContentSize()

	local platform = CCApplication:getInstance():getTargetPlatform()
	-- 添加logo信息
	local logoRes = ""
	if platform == kTargetAndroid or platform == kTargetIphone then
		logoRes = SdkData:SDK_getLogoInfo()
	else
		logoRes = "fjmz.png"
	end

	local logoImg = cc.Sprite:create('uires/logo/'..logoRes)
	logoImg:setScale(0.9)
	logoImg:setLocalZOrder(1)
	logoImg:setPosition(cc.p(winSize.width/6, winSize.height/6*4))

	if size.width < winSize.width then
		-- imgBG:setScaleY(winSize.width/size.width)
		imgBG:setScale(winSize.width/size.width)
		logoImg:setScale(0.9*winSize.width/size.width)
	end

	self.root:addChild(imgBG)
	self.root:addChild(logoImg)

	self.selectQuBgImg = self.root:getChildByName("select_qu_bg_img")
	local selectServerImg = self.root:getChildByName("select_server_img")
	self.serverName = selectServerImg:getChildByName("server_tx")
	self.fireImg = selectServerImg:getChildByName("fire_img")
	local changeTx = selectServerImg:getChildByName("change_server_tx")
	changeTx:setString(GlobalApi:getLocalStr('SELECT_SERVER'))
	local descTx = self.root:getChildByName("desc_tx")
	descTx:setVisible(false)

	local descTx1 = ccui.Text:create()
	descTx1:setString(GlobalApi:getLocalStr("LOGIN_DESC_2"))
	descTx1:setFontName('font/gamefont.ttf')
	descTx1:setFontSize(16)
	descTx1:setColor(COLOR_TYPE.WHITE)
	descTx1:enableOutline(COLOR_TYPE.BLACK, 1)
	descTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	descTx1:setPosition(cc.p(winSize.width/2, 35))
	self.root:addChild(descTx1)

	local descTx2 = ccui.Text:create()
	descTx2:setString(GlobalApi:getLocalStr("LOGIN_DESC_3"))
	descTx2:setFontName('font/gamefont.ttf')
	descTx2:setFontSize(16)
	descTx2:setColor(COLOR_TYPE.WHITE)
	descTx2:enableOutline(COLOR_TYPE.BLACK, 1)
	descTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	descTx2:setPosition(cc.p(winSize.width/2, 55))
	self.root:addChild(descTx2)

	local descTx3 = ccui.Text:create()
	descTx3:setString(GlobalApi:getLocalStr("LOGIN_DESC_4"))
	descTx3:setFontName('font/gamefont.ttf')
	descTx3:setFontSize(16)
	descTx3:setColor(COLOR_TYPE.WHITE)
	descTx3:enableOutline(COLOR_TYPE.BLACK, 1)
	descTx3:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	descTx3:setPosition(cc.p(winSize.width/2, 15))
	self.root:addChild(descTx3)

	local enterGameBtn = self.root:getChildByName("enter_game_btn")
	local infoTx = enterGameBtn:getChildByName('info_tx')
	infoTx:setVisible(false)
	infoTx:setString(GlobalApi:getLocalStr('ENTER_THE_GAME'))
		:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	ShaderMgr:setGrayForWidget(enterGameBtn)
	enterGameBtn:setTouchEnabled(false)
	enterGameBtn:setVisible(false)
	enterGameBtn:setOpacity(0)
	selectServerImg:setOpacity(0)
	selectServerImg:setVisible(false)
	self.selectQuBgImg:setVisible(false)
	self.page = 1

	local size = enterGameBtn:getContentSize()
	enterGameBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if tonumber(GlobalApi:getStopServer().maintain) == 1 then 
				promptmgr:stopServerTip(GlobalApi:getStopServer().maintain_url,nil)
			else
				selectServerImg:setVisible(false)
				enterGameBtn:setVisible(false)
				self.noticeBtn:setTouchEnabled(false)
				self.noticeBtn:setVisible(false)
				self.noticeBtn:setTouchEnabled(false)
				self:initLoading()
			end
		end
	end)

	self.selectQuBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self.selectQuBgImg:setVisible(false)
		end
	end)

	selectServerImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
			self:createSelectQu()
        end
	end)

    if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
    	local function onKeyboardPressed(keyCode,event)
	        if tonumber(keyCode) == 140 then
	        	SocketMgr:close()
	            GlobalData:init()
	            
	            LoginMgr:showLogin()
				LoginMgr:showCreateName()
	        end
	    end
	    local listener = cc.EventListenerKeyboard:create()
	    listener:registerScriptHandler(onKeyboardPressed,cc.Handler.EVENT_KEYBOARD_PRESSED)
	    local eventDispatcher1 = self.root:getEventDispatcher()
	    eventDispatcher1:addEventListenerWithSceneGraphPriority(listener, self.root)
	end

    self.noticeBtn = self.root:getChildByName("notice_btn")
	self.noticeBtn:setOpacity(0)
	self.noticeBtn:setTouchEnabled(false)
    self.noticeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
            local noticeUI = NoticeUI.new()
            -- noticeUI:showUI(UI_SHOW_TYPE.SCALEIN)
            noticeUI:showUI()
	    end
	end)
    self.noticeBtn:setAnchorPoint(cc.p(1,1))
    self.noticeBtn:setPosition(cc.p(winSize.width - 10,winSize.height - 10))

    self.logoutBg = self.root:getChildByName("logout_bg")
    self.logoutBtn = self.logoutBg:getChildByName("logout_btn")
    self.logoutBtn:setTouchEnabled(true)
	self.logoutBg:setVisible(false)
	-- self.logoutBg:setVisible(true)
	self.logoutBg:setOpacity(0)
    self.logoutBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
	    	promptmgr:showMessageBox(GlobalApi:getLocalStr("WHETHER_LOGOUT_ACCOUNT"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
	            SocketMgr:close()
	            GlobalData:init()
	            enterGameBtn:setOpacity(0)
	            enterGameBtn:setVisible(false)
				selectServerImg:setOpacity(0)
				selectServerImg:setVisible(false)
				self.noticeBtn:setOpacity(0)
				self.noticeBtn:setTouchEnabled(false)
				self.logoutBg:setOpacity(0)
				if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
					LoginMgr:showLogin()
					LoginMgr:showCreateName()
				else
					LoginMgr:showLogin()
				end
			end)
	    end
	end)
    self.logoutBg:setAnchorPoint(cc.p(1,1))
    self.logoutBg:setPosition(cc.p(winSize.width - 10,winSize.height - 100))
end

function LoginUI:requestForceJson(checkHotUpdate)
	local url = GlobalData:getDownloadUrl()

	MessageMgr:requsetGet(url, function(jsonObj)
		local channelID = SdkData:getChannelID()
		-- channelID = "10001"
		local data = jsonObj[channelID]
		if data and data["isOpenUpdate"] == true then
			self:downloadNewClient(data["url"])
		else
			checkHotUpdate()
		end
	end)
end

function LoginUI:downloadNewClient(url)
	local quitNode = cc.CSLoader:createNode("csb/quitgame.csb")
	local bgImg = quitNode:getChildByName('messagebox_bg_img')
	local messageboxImg = bgImg:getChildByName('messagebox_img')
	local closeBtn = messageboxImg:getChildByName('close_btn')
	closeBtn:setVisible(false)
	local winSize = cc.Director:getInstance():getWinSize()
	bgImg:setScale9Enabled(true)
	bgImg:setContentSize(winSize)
	bgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	messageboxImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	local neiBgImg = messageboxImg:getChildByName('nei_bg_img')
	local okBtn1 = neiBgImg:getChildByName('ok_1_btn')
	local okTx = okBtn1:getChildByName('info_tx')
	okTx:setString(GlobalApi:getLocalStr("STR_OK"))
	okBtn1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local url = GlobalData:getDownloadUrl()
			SdkData:openUrl(url)
        end
	end)



	local cancelBtn = neiBgImg:getChildByName('cancel_btn')
	cancelBtn:addTouchEventListener(function()
		--当强更时点击取消按钮，直接退出游戏
		cc.Director:getInstance():endToLua()
	end)
	local cancelTx = cancelBtn:getChildByName("info_tx")
	cancelTx:setString(GlobalApi:getLocalStr("STR_CANCEL"))

	

	local okBtn2 = neiBgImg:getChildByName('ok_2_btn')
	okBtn2:setVisible(false)

	local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("RELOAD_NEW_CLIENT"), "font/gamefont.ttf", 25)
	msg:setAnchorPoint(cc.p(0.5, 0.5))
	msg:setPosition(cc.p(262, 250))
	msg:setMaxLineWidth(424)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	neiBgImg:addChild(msg)


	local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("UPDATE_TEXT"), "font/gamefont.ttf", 25)
	msg:setAnchorPoint(cc.p(0.5, 0.5))
	msg:setPosition(cc.p(262, 180))
	msg:setMaxLineWidth(424)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
	neiBgImg:addChild(msg)
	self.root:addChild(quitNode)
end

function LoginUI:checkUpdate()
	local function skipUpdate()
		self:onUpdateFinish()
	end
	local winSize = cc.Director:getInstance():getVisibleSize()
	local version = GlobalData:getVersionData()
	local versionLabel = ccui.Text:create()
	versionLabel:setAnchorPoint(cc.p(1, 0.5))
	versionLabel:setString(GlobalApi:getLocalStr("STR_VERSION_CODE") .. ": " .. version)
	versionLabel:setFontName('font/gamefont.ttf')
	versionLabel:setFontSize(20)
	versionLabel:setColor(COLOR_TYPE.WHITE)
	versionLabel:enableOutline(COLOR_TYPE.BLACK, 1)
	versionLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	versionLabel:setPosition(cc.p(winSize.width-20, 60))
	self.root:addChild(versionLabel)

	local isClientVersionEqualServerVersion = false

	--服务器端下发的版本号
	local versionArr = string.split(version, ".")

	--检测是否需要 小版本 - 热更新
	local checkHotUpdate = function()
		local openUpdate = false
		if openUpdate or CCApplication:getInstance():getTargetPlatform() ~= kTargetWindows then
				self:addCustomEventListener(CUSTOM_EVENT.UPDATE_NO_NEED,function()
					self:onUpdateFinish()
					local noticeUI = NoticeUI.new()
		            -- noticeUI:showUI(UI_SHOW_TYPE.SCALEIN)
		            noticeUI:showUI()
			    end)
			    self:addCustomEventListener(CUSTOM_EVENT.UPDATE_FINISH, function()
			    	self:restartGame()
			    end)
				self:createAME()
		else
			skipUpdate()
			-- 加个提醒,以免开发时修改了发包时忘改回来了
			promptmgr:showMessageBox("动态更新没开！", MESSAGE_BOX_TYPE.OK)
		end
	end


	-- 检查是否需要 大版本 - 强更新
	if CCApplication:getInstance():getTargetPlatform() ~= kTargetWindows then
		local versionFullPath = cc.FileUtils:getInstance():fullPathForFilename("manifest/version.manifest")
		if versionFullPath ~= "" then
			local content = cc.FileUtils:getInstance():getStringFromFile(versionFullPath)
			if content ~= "" then
				local fileObj = json.decode(content)
				if fileObj then
					if version == fileObj.version then
						isClientVersionEqualServerVersion = true
					end

					--客户端端本地读取的版本号
					local localVersionArr = string.split(fileObj.version, ".")


					if tonumber(versionArr[1]) > tonumber(localVersionArr[1]) then
						self:requestForceJson(checkHotUpdate)
						-- self:downloadNewClient()
						return
					elseif tonumber(versionArr[1]) < tonumber(localVersionArr[1]) then
						skipUpdate()
						return
					else
						if tonumber(versionArr[2]) > tonumber(localVersionArr[2]) then
							self:requestForceJson(checkHotUpdate)
							-- self:downloadNewClient()
							return
						elseif tonumber(versionArr[2]) < tonumber(localVersionArr[2]) then
							skipUpdate()
							return
						end
					end
				end
			end
		end
	end

	checkHotUpdate()
end

function LoginUI:createAME()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local loadingBarBg = cc.Sprite:create("uires/ui/common/common_bar_bg_1.png")
	local size = loadingBarBg:getContentSize()
	local loadingBar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/common_bar_1.png"))
	local barSize = loadingBar:getContentSize()
	loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	loadingBar:setMidpoint(cc.p(0, 0))
	loadingBar:setBarChangeRate(cc.p(1, 0))
	loadingBar:setPercentage(0)
	loadingBar:setPosition(cc.p(size.width/2, size.height/2))
	loadingBarBg:addChild(loadingBar)
	loadingBarBg:setVisible(false)

	local numTx1 = ccui.Text:create()
	numTx1:setString("0%")
	numTx1:setFontName('font/gamefont.ttf')
	numTx1:setFontSize(20)
	numTx1:setColor(COLOR_TYPE.WHITE)
	numTx1:enableOutline(COLOR_TYPE.BLACK, 1)
	numTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	numTx1:setPosition(cc.p(size.width/2, size.height/2))
	loadingBarBg:addChild(numTx1)

	local numTx2 = ccui.Text:create()
	numTx2:setAnchorPoint(cc.p(1, 0.5))
	numTx2:setFontName('font/gamefont.ttf')
	numTx2:setFontSize(20)
	numTx2:setColor(COLOR_TYPE.WHITE)
	numTx2:enableOutline(COLOR_TYPE.BLACK, 1)
	numTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	numTx2:setPosition(cc.p(size.width, size.height/2))
	loadingBarBg:addChild(numTx2)

	loadingBarBg:setPosition(winSize.width/2,85)
	self.root:addChild(loadingBarBg)

	--本地出包配置版本号
	local manifest = "resource/manifest/version.manifest"
	local savepath = cc.FileUtils:getInstance():getWritablePath() .. "update"
	local am = cc.AssetsManagerEx:create(manifest, savepath)
	am:retain()
	local url = GlobalData:getUpdateUrlReal()
	am:setServerPath(url)
	local serverVersion = GlobalData:getVersionData()
	am:setServerVersion(serverVersion)
	local listener
	local errorCount = 0
	local showDownloadSize = 0
	local function updateDownloadedSize()
		if showDownloadSize == 1 then
			local downloadedSize = am:getTotalDownloadedSize()
			local totalSize = am:getNeedDownloadedSize()
			if totalSize > 0 and downloadedSize > 0 then
				if downloadedSize > totalSize then
					downloadedSize = totalSize
				end
				if totalSize > 1024*1024 then -- mb
					totalSize = string.format("%.1fM", (totalSize/1024/1024))
					downloadedSize = string.format("%.1fM", (downloadedSize/1024/1024))
				elseif totalSize > 1024 then -- kb
					totalSize = string.format("%.1fK", (totalSize/1024))
					downloadedSize = string.format("%.1fK", (downloadedSize/1024))
				else
					totalSize = totalSize .. "B"
					downloadedSize = downloadedSize .. "B"
				end
				numTx2:setString(downloadedSize .. "/" .. totalSize)
			end
		elseif showDownloadSize == 2 then
			local needMoveFilesTotalNum = am:getNeedMoveFilesTotalNum()
			if needMoveFilesTotalNum > 0 then
				local currMoveFilesNum = am:getCurrMoveFilesNum()
				loadingBar:setPercentage(100*currMoveFilesNum/needMoveFilesTotalNum)
			end
		end
	end
	
	local function onUpdateEvent(event)
		local eventCode = event:getEventCode()
		if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
			loadingBarBg:unscheduleUpdate()
			loadingBarBg:getEventDispatcher():removeEventListener(listener)
			ScriptHandlerMgr:getInstance():removeObjectAllHandlers(listener)
			am:release()
			promptmgr:showMessageBox(GlobalApi:getLocalStr("ERROR_NO_LOCAL_MANIFEST"), MESSAGE_BOX_TYPE.OK, function ()
				SdkData:SDK_exitGame()
			end)
		elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
			local assetId = event:getAssetId()
			if assetId ~= cc.AssetsManagerExStatic.VERSION_ID and assetId ~= cc.AssetsManagerExStatic.MANIFEST_ID then
				local downloadPercent = am:getSuccessDownloadFilesNum()*100/am:getTotalFilesNum()
				loadingBar:setPercentage(downloadPercent)
				local num = string.format("%d", downloadPercent)
				numTx1:setString(num.."%")
			end
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("ERROR_GET_DOWNLOAD_FILELIST"), MESSAGE_BOX_TYPE.OK, function ()
				am:update()
			end)
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("ERROR_PARSE_MANIFEST"), MESSAGE_BOX_TYPE.OK, function ()
				am:update()
			end)
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
			loadingBarBg:unscheduleUpdate()
			loadingBarBg:getEventDispatcher():removeEventListener(listener)
			ScriptHandlerMgr:getInstance():removeObjectAllHandlers(listener)
			am:release()
			loadingBarBg:removeFromParent()
			CustomEventMgr:dispatchEvent(CUSTOM_EVENT.UPDATE_NO_NEED)
            -- if Third:Get():needPostUpdatedGameLogBySDK() then
            -- 	Third:Get():postUpdatedGameLogBySDK(GlobalData:getVersionData())
            -- end
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
			updateDownloadedSize()
			loadingBarBg:unscheduleUpdate()
			loadingBarBg:getEventDispatcher():removeEventListener(listener)
			ScriptHandlerMgr:getInstance():removeObjectAllHandlers(listener)
			am:release()
			loadingBar:setPercentage(100)
			numTx1:setString("100%")
			loadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
				CustomEventMgr:dispatchEvent(CUSTOM_EVENT.UPDATE_FINISH)
			end)))
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
			if errorCount == 0 then
				promptmgr:showMessageBox(GlobalApi:getLocalStr("ERROR_MOVE_SCRIPT_FILES"), MESSAGE_BOX_TYPE.OK, function ()
					am:downloadFailedAssets()
				end)
			else
				loadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
					am:downloadFailedAssets()
				end)))
			end
			errorCount = 0
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
			errorCount = errorCount + 1
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.REMOVE_FAILED_FILE_FAILED then
			loadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
				am:downloadFailedAssets()
			end)))
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
			-- if Third:Get():needPostUpdatingGameLogBySDK() then
   --          	Third:Get():postUpdatingGameLogBySDK(GlobalData:getVersionData())
   --          end
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.MOVE_SCRIPT_FILES then
        	showDownloadSize = 2
        	loadingBarBg:setVisible(true)
        	loadingBar:setPercentage(0)
			numTx1:setString(GlobalApi:getLocalStr("MOVING_SCRIPT_FILES") .. "...")
			numTx2:setString("")
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.MOVE_SCRIPT_FILES_FAILED then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("ERROR_MOVE_SCRIPT_FILES"), MESSAGE_BOX_TYPE.OK, function ()
        		am:update()
			end)
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.REMOVE_OLD_FILES_FAILED then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("REMOVE_OLD_FILES_FAILED"), MESSAGE_BOX_TYPE.OK, function ()
				am:recheckOldVersion()
			end)
		elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_WAITING then
			local totalSize = am:getNeedDownloadedSize()
			if totalSize > 1024*1024 then -- mb
				totalSize = string.format("%.1fM", (totalSize/1024/1024))
			elseif totalSize > 1024 then -- kb
				totalSize = string.format("%.1fK", (totalSize/1024))
			else
				totalSize = totalSize .. "B"
			end
			promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("NEED_UPDATE_SIZE"), totalSize), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
				showDownloadSize = 1
				loadingBarBg:setVisible(true)
				am:startDownload()
			end, nil, nil, function ()
				SdkData:SDK_exitGame()
			end)
		end
	end
	listener = cc.EventListenerAssetsManagerEx:create(am, onUpdateEvent)
	loadingBarBg:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, loadingBarBg)
	am:update()

	loadingBarBg:scheduleUpdateWithPriorityLua(function (dt)
		updateDownloadedSize()
	end, 0)
end

function LoginUI:removeScriptSearchPath()
	local pathStr = package.path
	local pathArr = string.split(pathStr, ";")
	local findIndex
	local chunk
	for i = #pathArr, 1, -1 do
		chunk = string.gsub(pathArr[i], "[\\/]*", "")
		findIndex = string.find(chunk, "update_scriptresource")
		if findIndex then
			table.remove(pathArr, i)
			break
		end
	end
	if findIndex then
		package.path = table.concat(pathArr, ";")
	end
end

function LoginUI:onUpdateFinish()
	self:removeScriptSearchPath()
	AudioMgr.PlayAudio(1)
	UIManager:playBgm(1)
	self:setServerName()
	self:updateChild()
end

function LoginUI:restartGame()
	CustomEventMgr:dispatchEvent(CUSTOM_EVENT.RESTART_GAME)
	self:removeScriptSearchPath()
	cc.Director:getInstance():purgeCachedData()
	local file = "script/app/game"
	if package.loaded[file] then
		package.loaded[file] = nil
		require(file)
	end
	Game:purgeAll()
	Game:restartGame()
end

-- 预先加载几个特别大的配置文件
function LoginUI:preloadConf(imageLoaded)
	GameData:getConfData("skill")
	imageLoaded()
	GameData:getConfData("monster")
	imageLoaded()
end

return LoginUI