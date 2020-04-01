local MilitaryUI = class("MilitaryUI", BaseUI)

local SHOP_TYPE = {
	GODSHOP = 1,
	EQUIPSHOP = 2,
	ARENASHOP = 3,
	TOWERSHOP = 4,
	BLACKSHOP = 5,
	BATTLESHOP = 6,
	HONORSHOP = 7,
	LEGIONSHOP = 8,
	SECRETSHOP = 9,
	SERVERSHOP = 14,			--服战商店
	SALARYSHOP = 15,			--俸禄商店
}
function MilitaryUI:ctor(page)
	self.uiIndex = GAME_UI.UI_MILITARYUI
	self.page = page or 1
	self.pageBtns = {}
	self.content = {}
	self.lockRTs1 = {}
	self.page1Tip = {}
	self.lockRTs2 = {}
	self.lockRTs3 = {}
	self.lockRTs4 = {}
	self.pageCount = 4
	self.chooseId = -1
	self.chooseType = -1
	self.clickType = 1
end

function MilitaryUI:onShow()
	self:updatePanel()
end

function MilitaryUI:getPageData4()
	local tab = {}
	local tab1 = {}
	local tab2 = {}
	local conf = GameData:getConfData("local/dailyplay")
	for i=1,#conf do

		local isOpen = false
		if conf[i].key == "legionWarMinJoinLevel" or conf[i].key == "legionDfOpenLevel" then
			local desc = GlobalApi:getGotoLegionModule(conf[i].key,true)
			if not desc then
				isOpen = true
			end
		else
			isOpen = GlobalApi:getOpenInfo(conf[i].key)
	    end
	    
	    local showType,str1,str2,cdtime =  UserData:getUserObj():getDailyText(conf[i].event)
	    if not isOpen then
		    tab1[#tab1 + 1] = conf[i]
		else
			if showType == 1 then
			    tab[#tab + 1] = conf[i]
		    else
			    tab2[#tab2 + 1] = conf[i]
			end
	    end
	end

	for i,v in ipairs(tab2) do
		tab[#tab + 1] = v
	end
	for i,v in ipairs(tab1) do
		tab[#tab + 1] = v
	end
	return tab
end

function MilitaryUI:getPageData4StateInfo(bgImg,id,key)

	local showType,str1,str2,cdtime,color =  UserData:getUserObj():getDailyText(key)
	local color1,color2 = COLOR_TYPE.GREEN,COLOR_TYPE.YELLOW
	if showType == 3 and str2 == '' then
		if str1 ~= GlobalApi:getLocalStr("MILITARY_DESC_25") then
			color1 = COLOR_TYPE.RED
		end
	end
	if color then
		color2 = color
	end
	if not self.page1Tip[id] then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(450, 30))
		richText:setAlignment('middle')
		richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(str1,22,color1)
		local re2 = xx.RichTextLabel:create(str2,22,color2)
		richText:addElement(re1)
		richText:addElement(re2)
		re1:setStroke(COLOR_TYPE.BLACK, 1)
		re2:setStroke(COLOR_TYPE.BLACK, 1)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:setPosition(cc.p(190,36))
		richText:setAlignment('middle')
		richText:format(true)
		bgImg:addChild(richText)
		self.page1Tip[id] = {richText = richText,re1 = re1,re2 = re2,cdtime = cdtime}
	else
		self.page1Tip[id].re1:setString(str1)
		self.page1Tip[id].re2:setString(str2)
		self.page1Tip[id].richText:format(true)
		self.page1Tip[id].richText:setVisible(true)
	end
	return showType
end


function MilitaryUI:updatePagePanel4(page)
	self.neiBgImg:loadTexture('uires/ui/common/common_bg_12.png')
	local conf = GameData:getConfData("local/dailyplay")
	local list = self.content[self.page]
	local data = self:getPageData4()
	if self.defaultItem1 == nil then
		local node = cc.CSLoader:createNode('csb/militarycell4.csb')
		local bgImg = node:getChildByName('bg_img')
		bgImg:removeFromParent(false)
		self.defaultItem1 = bgImg
		list:setItemModel(self.defaultItem1)
		list:setItemsMargin(4)
	end
	
	local len = math.ceil(#data/2)
	for i=1,len do
		local item = list:getItem(i - 1)
		if not item then
			list:pushBackDefaultItem()
			item = list:getItem(i - 1)
		end

		for j=1,2 do
			local id = (i-1)*2+j
			local bgImg = item:getChildByName('item_bg' .. j)
			local confData = data[id]
			if not confData then
				bgImg:setVisible(false)
				return
			end
			local chooseImg = bgImg:getChildByName("choose_img")
			chooseImg:setVisible(self.chooseType == id)
			
			local nameTx = bgImg:getChildByName("name_tx")
			nameTx:setString(confData.name)
			local getwayTx = bgImg:getChildByName("getway_tx")
			getwayTx:setString(GlobalApi:getLocalStr("MILITARY_DESC_3"))
			local numBg = bgImg:getChildByName("num_bg")

			local newImg = bgImg:getChildByName("new_img")
			newImg:setVisible(false)
			local key = confData.key
			local desc,isOpen = GlobalApi:getGotoByModule(key,true)
			if key == "legionWarMinJoinLevel" or key == "legionDfOpenLevel" then
				desc = GlobalApi:getGotoLegionModule(key,true)
				isOpen = 3
		    end

			local goto = (not desc) and true or false
			if not desc then
				local showtype = self:getPageData4StateInfo(bgImg,id,confData.event)
				if confData.event == "hook" then
					newImg:setVisible(false)
				else
					newImg:setVisible(showtype == 1)
				end
			else
				if not self.lockRTs1[id] then
					local richText = xx.RichText:create()
					richText:setContentSize(cc.size(450, 30))
					richText:setAlignment('middle')
	  				richText:setVerticalAlignment('middle')
	  				local tx1,tx2
					if isOpen == 1 then
						tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
						tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
					elseif isOpen == 2 then
						tx1 = ''
						tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
					elseif isOpen == 3 then
						tx1 = ''
						tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
					end
					local re2 = xx.RichTextLabel:create(desc,22,COLOR_TYPE.RED)
					local re1 = xx.RichTextLabel:create(tx1,22,COLOR_TYPE.WHITE)
					local re3 = xx.RichTextLabel:create(tx2,22,COLOR_TYPE.WHITE)
					re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
					re2:setStroke(COLOROUTLINE_TYPE.RED, 1)
					re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
					richText:addElement(re1)
					richText:addElement(re2)
					richText:addElement(re3)
					richText:setAnchorPoint(cc.p(1,0.5))
					richText:setPosition(cc.p(getwayTx:getPositionX()+70,getwayTx:getPositionY()))
					richText:setAlignment('right')
					richText:format(true)
					bgImg:addChild(richText)
					self.lockRTs1[id] = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
				else
					self.lockRTs1[id].richText:setVisible(true)
				end
			end

			numBg:setVisible(goto)
			getwayTx:setVisible(goto)
			bgImg:setTouchEnabled(goto)

			bgImg:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
	            	self.chooseType = id
	            	chooseImg:setVisible(false)
	            	if key == "legionWarMinJoinLevel" or key == "legionDfOpenLevel" then 
	            		GlobalApi:getGotoLegionModule(key)
	            	else
	            		GlobalApi:getGotoByModule(key)
	            	end
		        end
	        end)
		end
	end

end

function MilitaryUI:gotoSpecial(key)

	if 'territoryboss' == key then
        local step = UserData:getUserObj():getMark().step or {}
        if step[tostring(GUIDE_ONCE.TERRITORIAL_WARS)] then
			TerritorialWarMgr:shoWarBossListUI()
			
		else
			TerritorialWarMgr:showMapUI()
		end
	elseif 'tavern_free' == key then

    end
end

function MilitaryUI:getPageData3()
	local tab = {}
	local tab1 = {}
	local tab2 = {}
	local conf = GameData:getConfData("local/strength")
	for i=1,#conf do
		local isOpen = GlobalApi:getOpenInfo(conf[i].key)
		local per = UserData:getUserObj():getStrengthPercent(conf[i])
		if not isOpen then
			print("notopen" .. conf[i].name)
			tab1[#tab1 + 1] = {conf = conf[i],per = per}
		elseif per < 100 then
			tab[#tab + 1] = {conf = conf[i],per = per}
		else
			tab2[#tab2 + 1] = {conf = conf[i],per = per}
		end
	end
	table.sort( tab, function(a,b)
		return a.per < b.per
	end )
	for i,v in ipairs(tab2) do
		tab[#tab + 1] = v
	end
	for i,v in ipairs(tab1) do
		tab[#tab + 1] = v
	end
	return tab
end

function MilitaryUI:updatePagePanel3(page)
	self.neiBgImg:loadTexture('uires/ui/common/common_bg_12.png')
	local list = self.content[self.page]
	local data = self:getPageData3()
	if self.defaultItem3 == nil then
		local node = cc.CSLoader:createNode('csb/militarycell3.csb')
		local bgImg = node:getChildByName('bg_img')
		bgImg:removeFromParent(false)
		self.defaultItem3 = bgImg
		list:setItemModel(self.defaultItem3)
		list:setItemsMargin(4)
	end
	for i=1,#data do
		local conf = data[i].conf
		local item = list:getItem(i - 1)
		if not item then
			list:pushBackDefaultItem()
			item = list:getItem(i - 1)
		end
		local bgImg = item:getChildByName('bg_img')
		local descTx = item:getChildByName('desc_tx')
		local nameTx = item:getChildByName('name_tx')
		local awardBgImg = item:getChildByName('award_bg_img')
		local awardImg = awardBgImg:getChildByName('award_img')
		local barBg = item:getChildByName('bar_bg')
		local bar = barBg:getChildByName('bar')
		local tx = barBg:getChildByName('tx')
		local gotoBtn = item:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		descTx:setString(GlobalApi:getLocalStr('MILITARY_DESC_1'))

		gotoBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then

            	GlobalApi:getGotoByModule(conf.key,nil,conf.args)
            end
        end)
		nameTx:setString(conf.name)
		awardImg:loadTexture('uires/icon/dailytask/'..conf.icon)

		local desc,isOpen = GlobalApi:getGotoByModule(conf.key,true)
		if not desc then
			local per = data[i].per
			if per > 100 then
				per = 100
			end
			bar:setPercent(per)
			tx:setString(math.floor(per)..'%')
			gotoBtn:setVisible(true)
			barBg:setVisible(true)
			descTx:setVisible(true)
			if self.lockRTs2[i] then
				self.lockRTs2[i].richText:setVisible(false)
			end
		else
			gotoBtn:setVisible(false)
			barBg:setVisible(false)
			descTx:setVisible(false)
			if not self.lockRTs2[i] then
				local richText = xx.RichText:create()
				richText:setContentSize(cc.size(450, 30))
				richText:setAlignment('middle')
  				richText:setVerticalAlignment('middle')
  				local tx1,tx2
				if isOpen == 1 then
					tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
					tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
				else
					tx1 = ''
					tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
				end
				local re2 = xx.RichTextLabel:create(desc,22,COLOR_TYPE.RED)
				local re1 = xx.RichTextLabel:create(tx1,22,COLOR_TYPE.WHITE)
				local re3 = xx.RichTextLabel:create(tx2,22,COLOR_TYPE.WHITE)
				re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
				re2:setStroke(COLOROUTLINE_TYPE.RED, 1)
				re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
				richText:addElement(re1)
				richText:addElement(re2)
				richText:addElement(re3)
				richText:setAnchorPoint(cc.p(0.5,0.5))
				richText:setPosition(cc.p(650,47))
				item:addChild(richText)
				self.lockRTs2[i] = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
			else
				self.lockRTs2[i].richText:setVisible(true)
			end
		end
	end
end

function MilitaryUI:updatePagePanel1(page)
	self.neiBgImg:loadTexture('uires/ui/common/common_bg_1.png')
	local conf = GameData:getConfData("local/resget")
	local content = self.content[self.page]
	local list = content:getChildByName("list_title")
	list:setScrollBarEnabled(false)
	list:setItemsMargin(4)
	self.getwaylist = content:getChildByName("list_content")
	self.getwaylist:setScrollBarEnabled(false)
	self.getwaylist:setItemsMargin(4)
	self.numBg = content:getChildByName("num_bg")
	self.numTx = self.numBg:getChildByName("num_tx")
	self.numTx1 = self.numBg:getChildByName("num_tx1")
	self.recIcon = self.numBg:getChildByName("icon_img")
	self.descTx = {}
	for i=1,3 do
		local descTx = content:getChildByName("desc_tx"..i)
		self.descTx[i] = descTx
	end

	self.maxLen = 0
	if self.defaultItem2 == nil then
		local node = cc.CSLoader:createNode('csb/militarycell1.csb')
		local bgImg = node:getChildByName('bg_img')
		bgImg:removeFromParent(false)
		self.defaultItem2 = bgImg
		list:setItemModel(self.defaultItem2)
	end
	self.maxLine = #conf
	self.chooseInfo = {}
	for id=1,self.maxLine do
		local item = list:getItem(id - 1)
		if not item then
			list:pushBackDefaultItem()
			item = list:getItem(id - 1)
		end
		local neibg = item:getChildByName('nei_bg_img')
		local namebg = item:getChildByName('name_bg_img')
		local chooseImg = item:getChildByName('choose_img')

		self.chooseInfo[id] = {}
		self.chooseInfo[id].chooseImg = chooseImg
		self.chooseInfo[id].neibg = neibg
		self.chooseInfo[id].namebg = namebg

		local tab = {}
		if tonumber(conf[id].type1) then
			tab = {conf[id].type,tonumber(conf[id].type1),1}
		else
			tab = {conf[id].type,conf[id].type1,1}
		end
		if conf[id].type == 'equip' then
			tab = {conf[id].type,conf[id].type1,0,1}
		end
		local award = DisplayData:getDisplayObj(tab)
		local frameImg = item:getChildByName('frame_img')
		local awardImg = item:getChildByName('award_img')
		local nameTx = item:getChildByName('name_tx')
		self.chooseInfo[id].nameTx = nameTx

		frameImg:loadTexture(award:getBgImg())
		awardImg:loadTexture(award:getIcon())
		nameTx:setString(conf[id].name)
		item:setTouchEnabled(true)
		item:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	self.clickType = id
            	self:militaryGetWay(id)
            end
        end)
	end

	self:militaryGetWay(self.clickType)
end

function MilitaryUI:militaryGetWay(id)

	for i=1,self.maxLine do
		self.chooseInfo[i].chooseImg:setVisible(id == i)
		self.chooseInfo[i].namebg:setVisible(id == i)
		local neibgRes = (id == i) and "uires/ui/common/common_bg_25.png" or "uires/ui/common/common_bg_3.png"
		self.chooseInfo[i].neibg:loadTexture(neibgRes)
		local color = (id == i) and cc.c4b(255,165,0,255) or COLOR_TYPE.WHITE
		self.chooseInfo[i].nameTx:setColor(color)
		local fontSize = (id == i) and 30 or 28
		self.chooseInfo[i].nameTx:setFontSize(fontSize)
	end

	local conf = GameData:getConfData("local/resget")[id]
	local getway = conf.getway
	local star = conf.star

	if self.militarycellBg == nil then
		local node = cc.CSLoader:createNode('csb/militarygetwaycell.csb')
		local bgImg = node:getChildByName('bg_img')
		bgImg:removeFromParent(false)
		self.militarycellBg = bgImg
		self.getwaylist:setItemModel(self.militarycellBg)
	end
	local tab1 = {}
	local tab2 = {}
	local tab = {}
	for i=1,#getway do
		local getwayConf = GameData:getConfData("local/resgetway")[getway[i]]
		local isOpen = GlobalApi:getOpenInfo(getwayConf.goto)
		if not isOpen then
			tab1[#tab1 + 1] = {conf = getwayConf,star = star[i]}
		else
			tab2[#tab2 + 1] = {conf = getwayConf,star = star[i]}
		end
	end
	for i,v in ipairs(tab2) do
		tab[#tab + 1] = v
	end
	for i,v in ipairs(tab1) do
		tab[#tab + 1] = v
	end


	local len = #tab
	if self.maxLen < len then
		self.maxLen = len
	end

	for i=self.maxLen,len+1,-1 do
		local item = self.getwaylist:getItem(i - 1)
		if item then
			self.getwaylist:removeItem(i-1)
		end
	end

	for i=1,len do
		local item = self.getwaylist:getItem(i - 1)
		if not item then
			self.getwaylist:pushBackDefaultItem()
			item = self.getwaylist:getItem(i - 1)
		end
		if item:getChildByName('rich_text') then
			item:removeChildByName('rich_text')
		end
		local getwayConf = tab[i].conf
		local awardImg = item:getChildByName('award_img')
		local nameTx = item:getChildByName('name_tx')
		local gotoBtn = item:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		awardImg:loadTexture('uires/icon/dailytask/'..getwayConf.icon)
		nameTx:setString(getwayConf.name)
		for j=1,5 do
			local starBgImg = item:getChildByName('star_bg_'..j..'_img')
			local starImg = starBgImg:getChildByName('star_img')
			starImg:setVisible(j <= tab[i].star)
		end

		gotoBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	if getwayConf.goto == "legionBuild" or getwayConf.goto == "legionCopyOpenLevel" 
            	   or getwayConf.goto == "leigionWishOpenLevel" or getwayConf.goto == "legionWarMinJoinLevel"  then
	            	self:gotoLegionWay(getwayConf.goto)
		        else
		        	if getwayConf.args2[1] then
	            		local minPage,maxPage = getwayConf.args2[1],getwayConf.args2[2] or getwayConf.args2[1]
			            MainSceneMgr:showShop(getwayConf.args,{min = minPage,max = maxPage})
	            	else
		            	if getwayConf.args == 0 then
		            		GlobalApi:getGotoByModule(getwayConf.goto,nil,nil)
		            	else
		            		GlobalApi:getGotoByModule(getwayConf.goto,nil,getwayConf.args)
		            	end
		            end
		        end
            end
        end)	

        local desc,isOpen = GlobalApi:getGotoByModule(getwayConf.goto,true)
        if isOpen == 2 then
        	desc = desc .. GlobalApi:getLocalStr('MILITARY_DESC_21')
     	end
        if getwayConf.goto == "legionBuild" or getwayConf.goto == "legionCopyOpenLevel" 
           or getwayConf.goto == "leigionWishOpenLevel" or getwayConf.goto == "legionWarMinJoinLevel"  then
           	desc = GlobalApi:getGotoLegionModule(getwayConf.goto,true)
           	isOpen = 2
       	end	
     	
		if not desc then
			gotoBtn:setVisible(true)
		else
			gotoBtn:setVisible(false)
			local richText = xx.RichText:create()
			richText:setName('rich_text')
			richText:setContentSize(cc.size(450, 30))
			richText:setAlignment('middle')
  			richText:setVerticalAlignment('middle')
  			local tx = (isOpen == 1) and GlobalApi:getLocalStr('FUNCTION_DESC_1') or GlobalApi:getLocalStr('FUNCTION_DESC_2')
			local re1 = xx.RichTextLabel:create(desc,20,COLOR_TYPE.RED)
			local re2 = xx.RichTextLabel:create(tx,20,COLOR_TYPE.WHITE)
			if isOpen == 1 then
				re1,re2 = re2,re1
			end
			re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
			re2:setStroke(COLOROUTLINE_TYPE.RED, 1)
			richText:addElement(re1)
			richText:addElement(re2)
			richText:setAnchorPoint(cc.p(0.5,0.5))
			richText:setPosition(cc.p(423.43,45))
			item:addChild(richText)
		end
	end

	local tab
	if tonumber(conf.type1) then
		tab = {conf.type,tonumber(conf.type1),1}
	else
		tab = {conf.type,conf.type1,1}
	end

	self.numBg:setVisible(conf.quantity == 1)
	if conf.quantity == 1 then
		local award = DisplayData:getDisplayObj(tab)
		self.numTx:setString(GlobalApi:getLocalStr("TAVERN_LIMIT_GET_DES5")..'        ：')
		self.numTx1:setString(award:getOwnNum())
		self.recIcon:loadTexture(award:getIcon())
	end

	self.descTx[1]:setString(GlobalApi:getLocalStr("MILITARY_DESC_2"))
	self.descTx[2]:setString(conf.name)
	self.descTx[3]:setString(GlobalApi:getLocalStr("MILITARY_DESC_22"))
	local descTx1PosX = self.descTx[1]:getPositionX()
	local size1 = self.descTx[1]:getContentSize()
	local size2 = self.descTx[2]:getContentSize()
	self.descTx[2]:setPositionX(descTx1PosX+size1.width)
	self.descTx[3]:setPositionX(descTx1PosX+size1.width+size2.width)

end

function MilitaryUI:gotoLegionWay(key)
	
	if not key then
		return
	end

	local functions = {
        ['legionBuild'] = function()
			LegionMgr:showMainUI(function() LegionMgr:showLegionDonateUI() end)
        end,
        ['legionCopyOpenLevel'] = function()
        	LegionMgr:showLegionLevelsMainUI()
		end,
        ['legionWarMinJoinLevel'] = function()
        	LegionMgr:showLegionWarMainUI()
        end,
        ['leigionWishOpenLevel'] = function()
            LegionWishMgr:showLegionWishGiveMainPanelUI()
        end,
    }
    if functions[key] then
    	functions[key]()
    end
end

function MilitaryUI:updatePagePanel2(page)

	self.neiBgImg:loadTexture('uires/ui/common/common_bg_1.png')
	local list = self.content[self.page]
	list:setItemsMargin(8)
	local conf = GameData:getConfData("entershop")
	if self.defaultItem4 == nil then
		local node = cc.CSLoader:createNode('csb/militarycell2.csb')
		local bgImg = node:getChildByName('bg_img')
		bgImg:removeFromParent(false)
		self.defaultItem4 = bgImg
		list:setItemModel(self.defaultItem4)
	end
	local len = math.ceil(#conf/2)
	for i=1,len do
		local item = list:getItem(i - 1)
		if not item then
			list:pushBackDefaultItem()
			item = list:getItem(i - 1)
		end

		for j=1,2 do
			local id = (i-1)*2+j
			local bgImg = item:getChildByName('item_bg'..j)
			if not conf[id] then
				bgImg:setVisible(false)
				return
			end
			local chooseImg = bgImg:getChildByName('choose_img')
			chooseImg:setVisible(self.chooseId == id)
			local nameTx = bgImg:getChildByName("name_tx")
			nameTx:setString(conf[id].name)

			local descTx = bgImg:getChildByName("desc_tx")
			descTx:setString(conf[id].desc)

			local getwayTx = bgImg:getChildByName("getway_tx")
			getwayTx:setString(GlobalApi:getLocalStr("MILITARY_DESC_3"))
			local key = conf[id].key
			local desc,isOpen = GlobalApi:getGotoByModule(key,true)
			if key == "legion" then
				if not desc then
					local lid = UserData:getUserObj().lid
				    if not lid or lid == 0 then
						desc = GlobalApi:getLocalStr('LEGION_JION')
				    	isOpen = 3
				    end
				end
		    end

		    local goto = (not desc) and true or false
			if not desc then
				getwayTx:setVisible(true)
			else
				getwayTx:setVisible(false)
				if not self.lockRTs4[id] then
					local richText = xx.RichText:create()
					richText:setContentSize(cc.size(450, 30))
					richText:setAlignment('middle')
	  				richText:setVerticalAlignment('middle')
	  				local tx1,tx2
					if isOpen == 1 then
						tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
						tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
					elseif isOpen == 2 then
						tx1 = ''
						tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
					elseif isOpen == 3 then
						tx1 = ''
						tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
					end
					local re2 = xx.RichTextLabel:create(desc,22,COLOR_TYPE.RED)
					local re1 = xx.RichTextLabel:create(tx1,22,COLOR_TYPE.WHITE)
					local re3 = xx.RichTextLabel:create(tx2,22,COLOR_TYPE.WHITE)
					re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
					re2:setStroke(COLOROUTLINE_TYPE.RED, 1)
					re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
					richText:addElement(re1)
					richText:addElement(re2)
					richText:addElement(re3)
					richText:setAnchorPoint(cc.p(1,0.5))
					richText:setPosition(cc.p(getwayTx:getPositionX()+70,getwayTx:getPositionY()))
					richText:setAlignment('right')
					richText:format(true)
					bgImg:addChild(richText)
					self.lockRTs4[id] = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
				else
					self.lockRTs4[id].richText:setVisible(true)
				end
			end

			local res,own = self:getShopInfo(conf[id].type)
			if not res or not own then
				return
			end
			local numbg = bgImg:getChildByName("num_bg")
			local icon = numbg:getChildByName("icon")
			icon:loadTexture(res)
			local numtx = numbg:getChildByName("num_tx")
			numtx:setString(own)

			bgImg:setTouchEnabled(goto)
			bgImg:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
	            	self.chooseId = id
	            	chooseImg:setVisible(true)
	            	local minPage,maxPage = conf[id].pagetab[1],conf[id].pagetab[2] or conf[id].pagetab[1]
		            MainSceneMgr:showShop(conf[id].page,{min = minPage,max = maxPage})
		        end
	        end)
		end
	end
end

function MilitaryUI:getShopInfo(shoptype)

	local res,own
	if shoptype == SHOP_TYPE.GODSHOP then
		own = UserData:getUserObj():getSoul()
		res = 'uires/ui/res/res_soul.png'
	elseif shoptype == SHOP_TYPE.EQUIPSHOP then
		own = UserData:getUserObj():getCash()
		res = 'uires/ui/res/res_cash.png'
	elseif shoptype == SHOP_TYPE.ARENASHOP then
		res = 'uires/ui/res/res_arena.png'
		own = UserData:getUserObj():getArena()
	elseif shoptype == SHOP_TYPE.TOWERSHOP then
		res = 'uires/ui/res/res_tower.png'
		own = UserData:getUserObj():getTower()
	elseif shoptype == SHOP_TYPE.BLACKSHOP then
		own = UserData:getUserObj():getCash()
		res = 'uires/ui/res/res_cash.png'
	elseif shoptype == SHOP_TYPE.BATTLESHOP then
		res = 'uires/ui/res/res_legionwar.png'
		own = UserData:getUserObj():getLegionwar()
	elseif shoptype == SHOP_TYPE.HONORSHOP then
		res = 'uires/ui/res/res_token.png'
		own = UserData:getUserObj():getToken()
	elseif shoptype == SHOP_TYPE.LEGIONSHOP then
		res = 'uires/ui/res/res_legion.png'
		own = UserData:getUserObj():getLegion()
	elseif shoptype == SHOP_TYPE.SECRETSHOP then
		res = 'uires/ui/res/res_trial_coin.png'
		own = UserData:getUserObj():getTrialCoin()
	elseif shoptype == SHOP_TYPE.SERVERSHOP then
		res = 'uires/ui/res/res_countrywar.png'
		own = UserData:getUserObj():getCountryWar()
	elseif shoptype == SHOP_TYPE.SALARYSHOP then
		res = 'uires/ui/res/res_salary.png'
		own = UserData:getUserObj():getSalary()		
	end
	return res,own
end

function MilitaryUI:updatePanel()
    for i=1,self.pageCount do
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
    self['updatePagePanel'..self.page](self,self.page)
end

function MilitaryUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    -- bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
    

    local closeBtn = bgImg1:getChildByName("close_btn")
    local infoTx = closeBtn:getChildByName('info_tx')
    -- infoTx:setString(GlobalApi:getLocalStr('STR_CLOSE'))
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideMilitary()
	    end
	end)

	self.neiBgImg = bgImg1:getChildByName('nei_bg_img')
	local pageList = bgImg1:getChildByName('page_list')
	pageList:setScrollBarEnabled(false)
	pageList:setItemsMargin(4)
	for i=1,self.pageCount do
		local pageBtn = pageList:getItem(i - 1)
		local infoTx = pageBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('MILITARY_BTN_DESC_'..i))
		local newImg = pageBtn:getChildByName('new_img')
		if newImg then
			local sign = UserData:getUserObj():getMilitarySign()
			newImg:setVisible(sign)
		end

		self.pageBtns[i] = pageBtn
		pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	self.content[self.page]:setVisible(false)
                self.page = i
                self.content[self.page]:setVisible(true)
                self:updatePanel()
            end
        end)
	end
	
	for i=1,self.pageCount do
		local listV = bgImg1:getChildByName('list_'..i)
		if i ~= 1 then
			listV:setScrollBarEnabled(false)
		end
		listV:setVisible(i == self.page)
		self.content[i] = listV
	end

	cc.UserDefault:getInstance():setIntegerForKey(UserData:getUserObj():getUid()..'military_sign',GlobalData:getServerTime())

	self:updatePanel()
	self.root:registerScriptHandler(function (event)
        if event == "exit" then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
        end
    end)

    self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
		if self.page == 4 then
			self:updatePagePanel4()
		end
    end, 1, false)

end

return MilitaryUI