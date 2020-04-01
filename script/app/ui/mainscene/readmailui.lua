local ReadMailUI = class("ReadMailUI", BaseUI)

function ReadMailUI:ctor(mail,callback)
	self.uiIndex = GAME_UI.UI_READEMAIL
	self.mail = mail
	self.hadEquip = false
	self.idx = 0
	self.defaultItem = nil
	self.callback = callback
end

function ReadMailUI:getDefaultItem()
	local awardBgImg = ccui.ImageView:create()
	awardBgImg:setName('awardBgImg')
	awardBgImg:setTouchEnabled(true)
	awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
	local size = awardBgImg:getContentSize()

	ccui.ImageView:create()
    	:setPosition(cc.p(size.width/2,size.height/2))
    	:loadTexture('uires/icon/user/gold.png')
    	:setName('award_img')
    	:addTo(awardBgImg)

    ccui.ImageView:create()
    	:setPosition(cc.p(size.width/2,size.height/2))
    	:loadTexture('uires/ui/common/chip_red.png')
    	:setName('chip_img')
    	:setScaleX(-1)
    	:addTo(awardBgImg)

    ccui.Text:create()
    	:setPosition(cc.p(88,15))
    	:setTextColor(COLOR_TYPE.WHITE)
    	:setFontName('font/gamefont.ttf')
    	:setFontSize(20)
    	:enableOutline(COLOR_TYPE.BLACK, 1)
    	:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    	:setAnchorPoint(cc.p(1,0.5))
    	:setName('lv_tx')
    	:addTo(awardBgImg)


    local doubleImg = ccui.ImageView:create('uires/ui/common/shuangbei.png')
    doubleImg:setPosition(cc.p(75,75))
    doubleImg:setName('double_img')
    doubleImg:setVisible(false)
    awardBgImg:addChild(doubleImg)

    return awardBgImg
end

function ReadMailUI:updatePanel()
	local bgImg = self.root:getChildByName("email_bg_img")
	local emailImg = bgImg:getChildByName("email_img")
	local titleTx = emailImg:getChildByName('title_tx')
	local pl1 = emailImg:getChildByName('pl_1')
	local pl2 = emailImg:getChildByName('pl_2')
	local getBtn = pl1:getChildByName('get_btn')
	local infoTx = getBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_GET'))
	local rightBtn = pl1:getChildByName('right_btn')
	local leftBtn = pl1:getChildByName('left_btn')

	local conf = GameData:getConfData("mail")
	local conf1 = GameData:getConfData("localtext")

	if type(self.mail.title) ~= 'number' then
		titleTx:setString(self.mail.title)
	else
		titleTx:setString(conf1[self.mail.title].text)
	end

	local richText = xx.RichText:create()
	richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(420, 30))
	richText:setAnchorPoint(cc.p(0,1))
	local size
	local content = self.mail.content
	local currImg
	local sv
	local infoPl
	local nameTx
	local readMail = UserData:getUserObj():getMail()
	if self.mail.awards and #self.mail.awards > 0 then
		pl1:setVisible(true)
		pl2:setVisible(false)
		currImg = pl1:getChildByName('top_bg_img')
		sv = currImg:getChildByName('info_sv')
		nameTx = pl1:getChildByName('name_tx')
		-- self.awardSv = pl1:getChildByName('award_sv')
		-- self.awardSv:setScrollBarEnabled(false)
		size = currImg:getContentSize()

		local awards = DisplayData:getDisplayObjs(self.mail.awards)
		if self.defaultItem == nil then
			self.defaultItem = self:getDefaultItem()
			self.awardSv:setItemModel(self.defaultItem)
			self.awardSv:setItemsMargin(20)
		end
		if awards[1]:getObjType() == 'fragment' then
			awards[#awards + 1] = awards[1]
			table.remove(awards,1)
		end
		for i,v in ipairs(awards) do
			self.awardSv:pushBackDefaultItem()
			local item = self.awardSv:getItem(i - 1)
			item:loadTexture(v:getBgImg())

			local lvTx = item:getChildByName('lv_tx')
			if v:getObjType() == 'equip' then
				lvTx:setString('Lv.'..GlobalApi:toWordsNumber(v:getNum()))
			else
				lvTx:setString('x'..GlobalApi:toWordsNumber(v:getNum()))
			end

			if v:getId() == 'food' then
				self.food = true
			end
			item:getChildByName('award_img')
				:loadTexture(v:getIcon())

			print(v:getChip())
			local chip = item:getChildByName('chip_img')
			chip:loadTexture(v:getChip())
			chip:setVisible(v:getObjType() == 'fragment')
			chip:ignoreContentAdaptWithSize(true)

			v:setLightEffect(item)

		    item:addTouchEventListener(function (sender, eventType)
		       	if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(v, false)
		        end
		    end)
		    if self.hadEquip == false and v:getType() == 'equip' then
		    	self.hadEquip = true
		    end

            local doubleImg = item:getChildByName('double_img')
            if v:getExtraBg() then
                doubleImg:setVisible(true)
            else
                doubleImg:setVisible(false)
            end

		end
		self.awardSv:jumpToLeft()

		getBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				if self.hadEquip == true then
					if BagData:getEquipFull() then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
						return
					end
				end
				if self.food then
					local food = UserData:getUserObj():getFood()
					local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
					if food >= maxFood then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
						return
					end
				end
				local mail = self.mail
				MainSceneMgr:readEmail(mail,function()
					if self.callback then
						self.callback()
					end
					MainSceneMgr:hideReadEmail()
				end)
		    end
		end)
		rightBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self.idx = self.idx + 1
	            if self.idx > #awards - 1 then
	            	self.idx = #awards
	            end
	            self.awardSv:scrollToItem(self.idx, cc.p(0, 0), cc.p(0, 0), 0.1)
	        end
	    end)
	    leftBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				self.idx = self.idx - 1
	            if self.idx < 0 then
	            	self.idx = 0
	            end
	            self.awardSv:scrollToItem(self.idx, cc.p(0, 0), cc.p(0, 0), 0.1)
	        end
	    end)
	else
		pl1:setVisible(false)
		pl2:setVisible(true)
		currImg = pl2:getChildByName('nei_bg_img')
		sv = currImg:getChildByName('info_sv')
		nameTx = currImg:getChildByName('name_tx')
		size = currImg:getContentSize()
		if self.mail.sys == 0 or (self.mail.sys == 1 and not readMail[tostring(self.mail.id)]) then
			local mail = self.mail
			MainSceneMgr:readEmail(mail)
		end
	end
	sv:setScrollBarEnabled(false)
	if type(self.mail.from) ~= 'number' then
		nameTx:setString(self.mail.from)
	else
		nameTx:setString(conf[self.mail.from].name)
	end

	local reTab = {}
	if type(content) == 'string' then
	    local re1 = xx.RichTextLabel:create(content,23,COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    reTab[#reTab + 1] = re1
	else
		local id = tonumber(content[1])
		if #content ~= 1 then
			local valueTab = string.split(conf1[id].text, '%s')
			local tab = {}
			for i=1,#content - 1 do
				tab[#tab + 1] = valueTab[i]
				tab[#tab + 1] = content[i + 1]
			end
			tab[#tab + 1] = valueTab[#valueTab]

			for i,v in ipairs(tab) do
				local color
				local outlineColor
				local outline
				if type(v) == 'number' then
					color = COLOR_TYPE.WHITE
					outlineColor = COLOR_TYPE.BLACK
					outline = 1
				else
					color = COLOR_TYPE.ORANGE
					outlineColor = COLOROUTLINE_TYPE.ORANGE
					outline = 1
				end
				local re1 = xx.RichTextLabel:create(tostring(v), 23,color)
				re1:setStroke(outlineColor, 1)
				reTab[#reTab + 1] = re1
			end
		else
			local re1 = xx.RichTextLabel:create(conf1[id].text,23, COLOR_TYPE.ORANGE)
			re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			reTab[#reTab + 1] = re1
		end
	end
	for i,v in ipairs(reTab) do
		richText:addElement(v)
	end
	richText:format(true)

	local svSize = sv:getContentSize()
	local height = richText:getBrushY()
	if height > svSize.height then
		sv:setInnerContainerSize(cc.size(svSize.width,height))
		richText:setPosition(cc.p(4 ,height))
	else
		sv:setInnerContainerSize(cc.size(svSize.width,svSize.height))
		richText:setPosition(cc.p(4 ,svSize.height))
	end
	sv:addChild(richText)
end

function ReadMailUI:init()
	self.intervalSize = 5
	local bgImg = self.root:getChildByName("email_bg_img")
	local emailImg = bgImg:getChildByName("email_img")
	local pl1 = emailImg:getChildByName('pl_1')
	local pl2 = emailImg:getChildByName('pl_2')
    self:adaptUI(bgImg, emailImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    emailImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
    
    local closeBtn = pl1:getChildByName("close_btn")
    local cloudImg = pl1:getChildByName("cloud_img")
    local infoTx = cloudImg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_ENCLOSURE'))
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideReadEmail()
	    end
	end)

	local neiBgImg = pl2:getChildByName("nei_bg_img")
    local closeBtn = neiBgImg:getChildByName("close_btn")
    local infoTx = closeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_CLOSE'))
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideReadEmail()
	    end
	end)

	self.awardSv = pl1:getChildByName('list')
	self.awardSv:setScrollBarEnabled(false)
	self:updatePanel()
end

return ReadMailUI