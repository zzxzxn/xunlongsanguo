local MailUI = class("MailUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function MailUI:ctor(data)
	self.uiIndex = GAME_UI.UI_EMAIL
	self.data = data
	self.oldMaxMail = 0
	self.mailsRt = {}
	self.selectId = 1
end

function MailUI:getDefaultItem()
	local awardBgImg = ClassItemCell:updateAwardFrameByObj(self.root,nil,{})
	awardBgImg:removeFromParent(false)
	return awardBgImg
end

local function sortFn(a, b)
	local readMail = UserData:getUserObj():getMail()
	local status = ((a.sys == 1) and readMail[tostring(a.id)]) or nil
	local status1 = ((b.sys == 1) and readMail[tostring(b.id)]) or nil
	if not status and not status1 then
		return a.time > b.time
	end
	if status and status1 then
		return a.time > b.time
	end	
	if not status then
		return true
	end
	return status1
end

-- function MailUI:onShow()
-- 	self:updatePanel()
-- end

function MailUI:updatePanel()
	local oldMails = UserData:getUserObj():getMails()
	local showTab = {}
	local conf = GameData:getConfData("mail")
	local conf1 = GameData:getConfData("localtext")
	for i,v in pairs(oldMails) do
		v.arrId = i
		v.isNew = false
		showTab[#showTab+1] = v
	end
	for i,v in pairs(self.data.mails) do
		v.arrId = i
		v.isNew = true
		showTab[#showTab+1] = v
	end
	table.sort( showTab, sortFn )
	for i,v in ipairs(showTab) do
		if self.selectMailId and self.selectMailId == v.id then
			self.selectId = i
		end
	end
	if #showTab > 0 then
		local size1
		for i,v in ipairs(showTab) do
			local cell = self.cardSv:getChildByTag(i + 100)
			local emailBgImg
			if not cell then
				local cellNode = cc.CSLoader:createNode('csb/emailcell.csb')
				emailBgImg = cellNode:getChildByName('email_bg_img')
				emailBgImg:removeFromParent(false)
				cell = ccui.Widget:create()
				cell:addChild(emailBgImg)
				self.cardSv:addChild(cell,1,i+100)
			else
				emailBgImg = cell:getChildByName('email_bg_img')
			end
			cell:setVisible(true)
			if i%2 == 1 then
				emailBgImg:loadTexture('uires/ui/common/common_bg_11.png')
			else
				emailBgImg:loadTexture('uires/ui/common/bg1_alpha.png')
			end
			size1 = emailBgImg:getContentSize()
			local emailNameTx = emailBgImg:getChildByName('email_name_tx')
			local emailTimeTx = emailBgImg:getChildByName('email_time_tx')
			local emailDateTx = emailBgImg:getChildByName('email_date_tx')
			local fromDescTx = emailBgImg:getChildByName('from_desc_tx')
			local fromNameTx = emailBgImg:getChildByName('from_name_tx')
			local emailImg = emailBgImg:getChildByName('email_img')
			local zhenImg = emailImg:getChildByName('zhen_img')
			local arrowImg = emailBgImg:getChildByName('arrow_img')

			local readMail = UserData:getUserObj():getMail()
			if readMail[tostring(v.id)] == 1 and v.sys == 1 then
				emailImg:loadTexture(COLOR_ITEMFRAME.GRAY)
				zhenImg:setVisible(false)
			else
				emailImg:loadTexture(COLOR_ITEMFRAME.BLUE)
				zhenImg:setVisible(true)
			end
			
			if type(v.title) ~= 'number' then
				emailNameTx:setString(v.title)
			else
				emailNameTx:setString(conf1[v.title].text)
			end

			local tx = GlobalApi:getLocalStr('SEND_MAIL_PEOPLE')
			local tx1
			if type(v.from) ~= 'number' then
				tx1 = v.from
			else
				tx1 = conf[v.from].name
			end
			fromDescTx:setString(tx)
			fromNameTx:setString(tx1)

			local date = Time.date('*t', tonumber(v.time))
			emailDateTx:setString(date.year..'-'..date.month..'-'..date.day)

			-- local diffTime = v.expire - GlobalData:getServerTime()
			-- if diffTime > 86400 then
			-- 	emailTimeTx:setString(math.floor(diffTime/86400)..GlobalApi:getLocalStr('DELETE_DAY'))
			-- else
			-- 	emailTimeTx:setString(math.floor(diffTime/3600)..GlobalApi:getLocalStr('DELETE_HOUR'))
			-- end
			emailTimeTx:setString('')
			if self.selectId == i then
				arrowImg:setVisible(true)
				if self.selectId%2 == 1 then
					arrowImg:setScaleX(-1)
				else
					arrowImg:setScaleX(1)
				end
				self:updateRightPanel(showTab[self.selectId],function()
					if v.isNew == true then
						self.data.mails[v.arrId] = nil
					end
					self:updatePanel()
				end,v.from,i)
			else
				arrowImg:setVisible(false)
			end
			GlobalApi:regiesterBtnHandler(emailBgImg,function()
				if self.selectId == i then
					return
				end
				self.selectMailId = v.id
				self:updatePanel()
				self:updateRightPanel(v,function()
					if v.isNew == true then
						self.data.mails[v.arrId] = nil
					end
					self:updatePanel()
				end,v.from,i)
			end)
		end

		if self.oldMaxMail ~= #showTab then
			local size = self.cardSv:getContentSize()
			if #showTab * size1.height > size.height then
				self.cardSv:setInnerContainerSize(cc.size(size.width,(#showTab * size1.height)))
			else
				self.cardSv:setInnerContainerSize(size)
			end
		end
		local function getPos(i)
			local size2 = self.cardSv:getInnerContainerSize()
			return cc.p(0,size2.height - size1.height* i)
		end
		for i,v in ipairs(showTab) do
			local cell = self.cardSv:getChildByTag(i + 100)
			if cell then
				cell:setPosition(getPos(i))
			end
		end
		self.noMail:setVisible(false)
		self.rightBgImg:setVisible(true)
	else
		self.rightBgImg:setVisible(false)
		self.noMail:setVisible(true)
	end
	if #showTab < self.oldMaxMail then
		for i=#showTab + 1,self.oldMaxMail do
			local mailCell = self.cardSv:getChildByTag(i + 100)
			if mailCell then
				mailCell:setVisible(false)
			end
		end
	end
	self.oldMaxMail = #showTab
end

function MailUI:updateRightPanel(mail,callback,from,index)
	if self.selectId ~= index then
		return
	end
	local topImg = self.rightBgImg:getChildByName("top_img")
	local titleTx = topImg:getChildByName("title_tx")
	local descTx1 = self.rightBgImg:getChildByName("desc_tx_1")
	local descTx2 = self.rightBgImg:getChildByName("desc_tx_2")
	local getBtn = self.rightBgImg:getChildByName("get_btn")
	local infoTx = getBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
	if #mail.awards > 0 then
		descTx1:setString(GlobalApi:getLocalStr('MAIL_DESC_1'))
		getBtn:setBright(true)
		getBtn:setTouchEnabled(true)
		descTx2:setVisible(true)
		infoTx:setColor(COLOR_TYPE.WHITE)
		infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
	else
		descTx1:setString(GlobalApi:getLocalStr('MAIL_DESC_2'))
		getBtn:setBright(false)
		getBtn:setTouchEnabled(false)
		descTx2:setVisible(false)
		infoTx:setColor(COLOR_TYPE.GRAY)
		infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
	end

	local diffTime = mail.expire - GlobalData:getServerTime()
	if diffTime > 86400 then
		descTx2:setString('（'..math.floor(diffTime/86400)..GlobalApi:getLocalStr('DELETE_DAY')..'）')
	else
		descTx2:setString('（'..math.floor(diffTime/3600)..GlobalApi:getLocalStr('DELETE_HOUR')..'）')
	end

	local conf = GameData:getConfData("mail")
	local conf1 = GameData:getConfData("localtext")
	if type(mail.title) ~= 'number' then
		titleTx:setString(mail.title)
	else
		titleTx:setString(conf1[mail.title].text)
	end

	self.awardSv:removeAllChildren()
	local size
	local content = mail.content
	local infoPl
	local nameTx
	local readMail = UserData:getUserObj():getMail()
	self.food = false

	local jadeTab = {}
	if mail.awards and #mail.awards > 0 then
		local awards = DisplayData:getDisplayObjs(mail.awards)
		if self.defaultItem == nil then
			self.defaultItem = self:getDefaultItem()
			self.awardSv:setItemModel(self.defaultItem)
			self.awardSv:setItemsMargin(-5)
		end
		if awards[1]:getObjType() == 'fragment' then
			awards[#awards + 1] = awards[1]
			table.remove(awards,1)
		end
		for i,v in ipairs(awards) do
			self.awardSv:pushBackDefaultItem()
			local item = self.awardSv:getItem(i - 1)
			item:setName('item_'..i)
			local isDouble = false
			if v:getExtraBg() then
				isDouble = true
			end
			local str = ''
			if v:getObjType() == 'equip' then
				str = 'Lv.'..GlobalApi:toWordsNumber(v:getNum())
			else
				str = 'x'..GlobalApi:toWordsNumber(v:getNum())
			end
			local param = {
				bgName = 'item_'..i,
				lvTxStr = str,
				showDoubleImg = isDouble,
				bgScale = 0.8,
			}
			local awardBgImg = ClassItemCell:updateAwardFrameByObj(self.awardSv,v,param)

			if v:getId() == 'food' then
				self.food = true
			end
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

			if type(from) == 'number' and tonumber(from) == 7 then
				local doubleImg = awardBgImg:getChildByName('double_img')
				if doubleImg then
					doubleImg:setVisible(false)
				end
				if v:getExtraBg() then
					table.insert(jadeTab,v)                    
				end
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
				MainSceneMgr:readEmail(mail,function()
					self.selectId = 1
					if callback then
						callback()
					end
				end)
			end
		end)
	else
		if mail.sys == 0 or (mail.sys == 1 and not readMail[tostring(mail.id)]) then
			MainSceneMgr:readEmail(mail,function()
				if callback then
					callback()
				end
			end)
		end
	end

	if not self.rts1 then
		self.rts1 = {reTab = {}}
		self.rts1.richText = xx.RichText:create()
		self.rts1.richText:setContentSize(cc.size(380, 30))
		self.rts1.richText:setAnchorPoint(cc.p(0,1))
		self.rightBgImg:addChild(self.rts1.richText)
	else
		for i,v in ipairs(self.rts1.reTab) do
			v:setString('')
		end
	end

	local reNum = 1
	if type(from) == 'number' and tonumber(from) == 7 and #jadeTab > 0 then
		local jadeStr = ''
		for k  = 1,#jadeTab do
			local v = jadeTab[k]
			if v:getType() == 'user' then
				if k == #jadeTab then    -- 最后1个逗号不要
					jadeStr = jadeStr .. string.format(GlobalApi:getLocalStr('MAIL_DES1'),v:getNum(),v:getName())
				else
					jadeStr = jadeStr .. string.format(GlobalApi:getLocalStr('MAIL_DES1'),v:getNum(),v:getName()) .. '，'
				end
			else
				if k == #jadeTab then    -- 最后1个逗号不要                       
					jadeStr = jadeStr .. string.format(GlobalApi:getLocalStr('MAIL_DES2'),v:getNum(),v:getName())
				else
					jadeStr = jadeStr .. string.format(GlobalApi:getLocalStr('MAIL_DES2'),v:getNum(),v:getName()) .. '，'
				end
			end
		end

		local text = conf1[tonumber(content[1])].text
		if not self.rts1.reTab[reNum] then
			local re1 = xx.RichTextLabel:create(string.format(text,jadeStr),23,COLOR_TYPE.ORANGE)
			re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			self.rts1.reTab[reNum] = re1
			self.rts1.richText:addElement(re1)
		else
			self.rts1.reTab[reNum]:setString(string.format(text,jadeStr))
			self.rts1.reTab[reNum]:setColor(COLOR_TYPE.ORANGE)
			self.rts1.reTab[reNum]:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		end
		reNum = reNum + 1
	elseif type(content) == 'string' then
		if not self.rts1.reTab[reNum] then
			local re1 = xx.RichTextLabel:create(content,23,COLOR_TYPE.ORANGE)
			re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			self.rts1.reTab[reNum] = re1
			self.rts1.richText:addElement(re1)
		else
			self.rts1.reTab[reNum]:setString(content)
			self.rts1.reTab[reNum]:setColor(COLOR_TYPE.ORANGE)
			self.rts1.reTab[reNum]:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		end
		reNum = reNum + 1
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
				-- local re1 = xx.RichTextLabel:create(tostring(v), 23,color)
				-- re1:setStroke(outlineColor, 1)
				-- reTab[#reTab + 1] = re1
				if not self.rts1.reTab[reNum] then
					local re1 = xx.RichTextLabel:create(tostring(v), 23,color)
					re1:setStroke(outlineColor, 1)
					self.rts1.reTab[reNum] = re1
					self.rts1.richText:addElement(re1)
				else
					self.rts1.reTab[reNum]:setString(tostring(v))
					self.rts1.reTab[reNum]:setColor(color)
					self.rts1.reTab[reNum]:setStroke(outlineColor, 1)
				end
				reNum = reNum + 1
			end
		else
			-- local re1 = xx.RichTextLabel:create(conf1[id].text,23, COLOR_TYPE.ORANGE)
			-- re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			-- reTab[#reTab + 1] = re1
			if not self.rts1.reTab[reNum] then
				local re1 = xx.RichTextLabel:create(conf1[id].text,23, COLOR_TYPE.ORANGE)
				re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
				self.rts1.reTab[reNum] = re1
				reNum = reNum + 1
				self.rts1.richText:addElement(re1)
			else
				self.rts1.reTab[reNum]:setString(conf1[id].text)
				self.rts1.reTab[reNum]:setColor(COLOR_TYPE.ORANGE)
				self.rts1.reTab[reNum]:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			end
		end
	end
	-- for i,v in ipairs(reTab) do
	-- 	richText:addElement(v)
	-- end
	self.rts1.richText:format(true)
	self.rts1.richText:setPosition(cc.p(15,360))

end

function MailUI:init()
	local bgImg = self.root:getChildByName("email_bg_img")
	local emailImg = bgImg:getChildByName("email_img")
	local closeBtn = emailImg:getChildByName("close_btn")
	self:adaptUI(bgImg, emailImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	emailImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideEmail()
		end
	end)

	local titleTx = emailImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('MAILBOX'))
	self.noMail = emailImg:getChildByName('no_mail')
	local infoTx = self.noMail:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('NO_MAIL'))
	self.cardSv = emailImg:getChildByName('card_sv')
	self.cardSv:setScrollBarEnabled(false)
	self.rightBgImg = emailImg:getChildByName('right_bg_img')
	self.awardSv = self.rightBgImg:getChildByName("list")
	self.awardSv:setScrollBarEnabled(false)

	self:updatePanel()
end

return MailUI