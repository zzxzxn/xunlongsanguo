local RoleCellAssist = require("script/app/ui/role/rolecellassist")
local RoleCellBeAssist = require("script/app/ui/role/rolecellbeassist")
local RoleCellChip = require("script/app/ui/role/rolecellchip")
local RoleCellPromoted = require("script/app/ui/role/rolecellpromoted")
local RoleListUI = class("RoleListUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassItemCell = require('script/app/global/itemcell')

function RoleListUI:ctor(page)
	self.uiIndex = GAME_UI.UI_ROLELIST
	self.role_sv = nil
	self.roleCellTable = {}
	self.objarr ={}
	self.heroCellTab = {}
	self.fateCellTab = {}
	self.num = MAXROlENUM
	self.fatenum = 0
	self.cellTotalHeight = 10
	self.currtype = page or 1
	self.isassist = false
	self.dirty = false
	self.selectheroindex = 1
	self.celltab = {}
    self.objfateadvancedarr = {}
end

local defaultNor = {
	[1] = 'uires/ui/bgtext/shangzhen2.png',
	[2] = 'uires/ui/bgtext/suipian2.png',
	[3] = 'uires/ui/bgtext/kapai2.png',
	[4] = 'uires/ui/bgtext/yuanfen2.png',
	[5] = 'uires/ui/bgtext/fengjiang2.png',
}

local defaultSel = {
	[1] = 'uires/ui/bgtext/shangzhen1.png',
	[2] = 'uires/ui/bgtext/suipian1.png',
	[3] = 'uires/ui/bgtext/kapai1.png',
	[4] = 'uires/ui/bgtext/yuanfen1.png',
	[5] = 'uires/ui/bgtext/fengjiang1.png',
}
local lv = GameData:getConfData('moduleopen')['promote'].level
local funcopenlevel = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
	[4] = 1,
	[5] = lv,
}

function RoleListUI:setDirty(onlychild)
	self.dirty = true
	self:update()
end

function RoleListUI:onShowUIAniOver()
	local isOpen = GlobalApi:getOpenInfo('promote')
	if isOpen then
    	GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.ROLE_LIST_PROMOTE)
    end
end

function RoleListUI:addCells(tempCellData,widgetItem)
    if self.objarr[tempCellData.index] then
        local i = tempCellData.index
        local obj = self.objarr[tempCellData.index]
        local id = obj:getId()
        if self.currtype == ROLELISTTYPE.UI_BEASSIST then
			self.celltab[i] = RoleCellBeAssist.new(self, i,self.objarr[i])
		elseif self.currtype == ROLELISTTYPE.UI_ASSIST then
			-- 上阵item
			self.celltab[i] = RoleCellAssist.new(self, i,self.objarr[i])
		elseif self.currtype == ROLELISTTYPE.UI_CHIP then
			self.celltab[i] = RoleCellChip.new(self, i,self.objarr[i])
		elseif self.currtype == ROLELISTTYPE.UI_PROMOTED then
			self.celltab[i] = RoleCellPromoted.new(self, i,self.objarr[i])
		end

        local panel = self.celltab[i]:getPanel()
		local contentsize = panel:getChildByName('bg_img'):getContentSize()
		self.celltab[i]:setType(self.isassis)

        local w = tempCellData.w
        local h = tempCellData.h

     	local posx = w * 0.5
        if i % 2 == 0 then
            posx = w + (self.viewSize.width - 2*w) + posx
        end
        widgetItem:addChild(panel)
        panel:setPosition(cc.p(posx,h*0.5))
    end
end

function RoleListUI:update()
	self:swapList(self.currtype)
end

function RoleListUI:onShow()
	if self.currtype ~= ROLELISTTYPE.UI_ASSIST then
		self:update()
	end
end

function RoleListUI:updateCell(celltype,isassist)
    if self.bgimg2:getChildByName('scrollview_sv') then
        self.bgimg2:removeChildByName('scrollview_sv')
        self.role_sv = nil
    end

    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.role_sv_temp:getPosition())
    scrollView:setContentSize(self.role_sv_temp:getContentSize())
    self.bgimg2:addChild(scrollView)
	self.role_sv = scrollView

	self.objarr = {}
	self.objfatearr = {}
	self.currtype = celltype
	self.isassist = isassist 
	self.role_sv:setVisible(true)
	self.rolefatebg:setVisible(false)

	for i=1,5 do
		if tonumber(self.currtype) == i then
			self.rolebtnarr[i]:loadTextureNormal(defaultSel[i])
		end
	end
	local num = 0
	if celltype == ROLELISTTYPE.UI_ASSIST then
		for k, v in pairs(RoleData:getRoleMap()) do
			if v:getId() < 10000 then
				self.objarr[tonumber(k)] = v
			end
		end
		self.num =MAXROlENUM
    	self.desc:setString('')
    	self.noroleimg:setVisible(false)
    	self.nopromotedimg:setVisible(false)
    	self.resvbtn:setVisible(false)
	elseif celltype == ROLELISTTYPE.UI_CHIP then
		local allfragment = BagData:getFragment()
		for k, v in pairs(allfragment) do
			if v:getId() < 10000 then
				table.insert(self.objarr, v)
			end
		end
		self.num = #self.objarr
		if self.num == 0 then
	    	self.noroleimg:loadTexture('uires/ui/text/no_rolecard.png')
	    	self.noroleimg:setVisible(true)
	    else
	    	self.noroleimg:setVisible(false)
	    end
	    self.nopromotedimg:setVisible(false)
	    self.resvbtn:setVisible(false)
	elseif celltype == ROLELISTTYPE.UI_BEASSIST  then
		local allcards = BagData:getAllCards()
		 for k, v in pairs(allcards) do
		 	if v:getId() < 10000 then
		        table.insert(self.objarr, v)
		    end
	    end
	    self.num = #self.objarr
	    if self.num == 0 then
	    	self.noroleimg:loadTexture('uires/ui/text/no_huodewujiang.png')
	    	self.noroleimg:setVisible(true)
	    else
	    	self.noroleimg:setVisible(false)
	    end
	    self.nopromotedimg:setVisible(false)
	    self.resvbtn:setVisible(true)    
	elseif celltype == ROLELISTTYPE.UI_FATE then
		self.role_sv:setVisible(false)
		self.rolefatebg:setVisible(true)
        -- table.insert(self.objfatearr,1)
		for k, v in pairs(RoleData:getRoleMap()) do
			if v:getId()>0 and v:getId() < 10000 then
                table.insert(self.objfatearr,v)
			end
		end
		self.fatenum = #self.objfatearr
    	self.desc:setString('')
    	self.noroleimg:setVisible(false)
    	self.resvbtn:setVisible(false) 
    elseif celltype == ROLELISTTYPE.UI_PROMOTED then
    	local num = 1
		for k, v in pairs(RoleData:getRoleMap()) do
			if  v:getId() < 10000 and v:getId() > 0  
				and v:isJunZhu()== false 
				and v:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit')) and v:getRealQulity() ~= 7  then
					self.objarr[num] = v
					num = num + 1
			end
		end
		self.num = #self.objarr
    	self.desc:setString('')
    	if self.num == 0 then
	    	self.nopromotedimg:setVisible(true)
	    else
	    	self.nopromotedimg:setVisible(false)
	    end
	    self.noroleimg:setVisible(false)
    	self.resvbtn:setVisible(false) 	
	end
	self:clickFate()
	self:chickPromoted()
    self:updateChipShowStatus()
	self.cellTotalHeight = 10
	if celltype ~= ROLELISTTYPE.UI_FATE and self.num > 0  then
		RoleMgr:sortByQuality(self.objarr,self.currtype)
        self.viewSize = self.role_sv:getContentSize() -- 可视区域的大小
        self:initListView()
	elseif celltype == ROLELISTTYPE.UI_FATE then
		self:initfateplleft()
	end

end

function RoleListUI:initListView()
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    if self.currtype == ROLELISTTYPE.UI_BEASSIST then
	    local tab = RoleData:getFateCards()
	    for i,v in pairs(tab) do
		    local obj = ClassRoleObj.new(tonumber(i),tonumber(v))
		    obj.isFate = true
		    self.objarr[#self.objarr + 1] = obj
	    end
	    table.sort( self.objarr, function (a,b)
	    	local id1 = a:getId()
	    	local id2 = b:getId()
	    	if id1 == id2 then
	    		return not a.isFate
	    	else
	    		return id1 > id2
	    	end
	    end )
    end

    local allNum = #self.objarr
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (math.ceil(allNum/2) - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addCells(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.role_sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,2)
    else
        self.scrollViewGeneral:resetScrollView(self.role_sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,2)
    end
    
end

function RoleListUI:initItemData(index)
    if self.objarr[index] then
        local w = 430
        local h = 140
        
        local curCellHeight = 0
        if index%2 == 1 then
            curCellHeight = h
        end

        self.allHeight = curCellHeight + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function RoleListUI:clickFate()
	local iscanadd = false
	for k, v in pairs(RoleData:getRoleMap()) do
		if v:getId()>0 and v:getId() < 10000 then
			if v:isFateCanAcitive() then		
				iscanadd = true
				break
			end
		end
	end

	local newimg = self.rolebtnarr[4]:getChildByName('new_img')
	newimg:setVisible(iscanadd)
end

function RoleListUI:chickPromoted()
	local iscanpromoted = false
	for k, v in pairs(RoleData:getRoleMap()) do
		if v:getId()>0 and v:getId() < 10000 then
			if v:isCanrPromoted() then		
				iscanpromoted = true
				break
			end
		end
	end
	local newimg = self.rolebtnarr[5]:getChildByName('new_img')
	local isOpen = GlobalApi:getOpenInfo('promote')
	if isOpen then
		newimg:setVisible(iscanpromoted or RechargeMgr.vipChanged)
	end
end

function RoleListUI:updateChipShowStatus()
	self.rolebtnarr[2]:getChildByName('new_img'):setVisible(UserData:getUserObj():getSignByType('chip'))
end

function RoleListUI:setTitleBtnPosition()
	local btnsv = self.bgimg2:getChildByName('btn_sv')
	local order = {1,4,5,2,3}
	local promteisOpen = GlobalApi:getOpenInfo('promote')
	if not promteisOpen then
		order = {1,4,2,3,5}
	end
	local isOpen = {
        true,
        true,
        true,
        true,
        true,
	}
	local maxNum = 0
	for i,v in ipairs(isOpen) do
		if v then
			maxNum = maxNum + 1
		end
	end
	local x,y = 34,71
	local diffHeight = 130
	local size = btnsv:getContentSize()
	btnsv:setInnerContainerSize(cc.size(size.width,diffHeight * maxNum + 10))
    for i,v in ipairs(order) do
    	local btn = btnsv:getChildByName('role_' .. v .. '_btn')
    	btn:setSwallowTouches(false)
    	if isOpen[v] then
    		btn:setVisible(true)
    		btn:setPosition(cc.p(x,y + (maxNum - 1)*diffHeight))
    		y = y - diffHeight
    	else
    		btn:setVisible(false)
    	end
    end
end

function RoleListUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')

    local bgimg2 = bgimg1:getChildByName('bg_img2')
    self.bgimg2 = bgimg2
    local closebtn = bgimg2:getChildByName("close_btn")
    closebtn:setLocalZOrder(10000)
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleList()
        end
    end)

	local chartBtn = self.bgimg2:getChildByName('chart_btn')
	chartBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            ChartMgr:showChartMain()
        end
    end)
	chartBtn:setLocalZOrder(10000)
	self.chartBtn = chartBtn

    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('STR_ROLELIST_TITLE'))
    self.rolebtnarr = {}
    local btnsv = bgimg2:getChildByName('btn_sv')
    btnsv:setScrollBarEnabled(false)
    for i=1,5 do
    	self.rolebtnarr[i] = btnsv:getChildByName('role_' .. i .. '_btn')
    	local newimg = self.rolebtnarr[i]:getChildByName('new_img')
    	newimg:setVisible(false)
    	self.rolebtnarr[i]:addTouchEventListener(function (sender, eventType)
			if eventType ==ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if UserData:getUserObj():getLv() < funcopenlevel[i] then
					local str = funcopenlevel[i]..GlobalApi:getLocalStr('FRIENDS_DESC_32')
					promptmgr:showSystenHint(str, COLOR_TYPE.RED)
					return
				else
					if self.curi and self.curi == i then
						return
					end
					self:swapList(i)
					if i ~= self.celltype  then
						self.celltab = {}
					end
					for j=1,5 do
						self.rolebtnarr[j]:loadTextureNormal(defaultNor[j])
					end
					self.rolebtnarr[i]:loadTextureNormal(defaultSel[i])
				end
			end
    	end)
    end
    self.desc = bgimg2:getChildByName('desc_tx')
    self.desc:setString('')
    self.rolefatebg = bgimg2:getChildByName('rolefate_pl')
    self.role_sv_temp = bgimg2:getChildByName('role_sv')
    self.noroleimg = bgimg2:getChildByName('norole_img')
    self.noroleimg:ignoreContentAdaptWithSize(true)
    self.nopromotedimg = bgimg2:getChildByName('nopromoted_img')
    local desctx = self.nopromotedimg:getChildByName('desc_tx')
    desctx:setString(GlobalApi:getLocalStr('ROLE_DESC18'))

	self.resvbtn = bgimg1:getChildByName('res_btn')
	local resvTx = self.resvbtn:getChildByName('resolve_tx')
	resvTx:setString(GlobalApi:getLocalStr('STR_RESOLVE_ALL'))
    self.resvbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
    	if eventType == ccui.TouchEventType.ended then
           RoleMgr:showRoleResolve()
        end
	end)

    self.role_sv_temp:setScrollBarEnabled(false)
    self.role_sv_temp:setInertiaScrollEnabled(true)
    self.role_sv_temp:setVisible(false)
    self:updateCell(self.currtype)
    self:adaptUI(bgimg, bgimg1)
    RoleData:calcFateCards()
    self:setTitleBtnPosition()
end

function RoleListUI:swapList(celltype )
    self.curi = celltype
	if self.curi == 1 then
		self.chartBtn:setVisible(true)
	else	
		self.chartBtn:setVisible(false)
	end

	self:updateCell(celltype)
end

function RoleListUI:initfateplleft()
	local rolelistsv = self.rolefatebg:getChildByName('roleactive_sv')
	rolelistsv:setScrollBarEnabled(false)
	rolelistsv:setInertiaScrollEnabled(true)
	rolelistsv:removeAllChildren()

	local rolelistsvcontentWidget = ccui.Widget:create()
    rolelistsv:addChild(rolelistsvcontentWidget)
    rolelistsvcontentWidget:removeAllChildren()
	for i=1,self.fatenum do
		local node = cc.CSLoader:createNode("csb/rolefate_role_cell.csb")
	    local bgimg = node:getChildByName("bg_img")
	    bgimg:removeFromParent(false)
	    self.heroCellTab[i]= ccui.Widget:create()
        self.heroCellTab[i]:setName('rolefate_role_cell' .. i)
	    self.heroCellTab[i]:addChild(bgimg)
	    self:initFateRoleCell(i, bgimg)
	    local contentsize = bgimg:getContentSize()
	    if math.ceil(self.fatenum*(contentsize.height+5)) > rolelistsv:getContentSize().height then
	        rolelistsv:setInnerContainerSize(cc.size(contentsize.width,self.fatenum*(contentsize.height+5)))
	    end
	    local posy = -i*(contentsize.height+5)+contentsize.height/2
	    self.heroCellTab[i]:setPosition(cc.p(0,posy))
	    rolelistsvcontentWidget:addChild(self.heroCellTab[i])
	    rolelistsvcontentWidget:setPosition(cc.p(rolelistsv:getContentSize().width*0.5, rolelistsv:getInnerContainerSize().height ))
	end
    for i=1,self.fatenum do
    	local tempbgimg = self.heroCellTab[i]:getChildByName("bg_img")
        -- if i == 1 then
        --     tempbgimg:loadTexture('uires/ui/fateshow/fateshow_paizi2.png')
        -- else
            tempbgimg:loadTexture('uires/ui/common/common_bg_21.png')
        -- end
    end

    local selectbgimg = self.heroCellTab[self.selectheroindex]:getChildByName("bg_img")
    -- if self.selectheroindex == 1 then
    --     selectbgimg:loadTexture('uires/ui/fateshow/fateshow_paizi.png')
    -- else
        selectbgimg:loadTexture('uires/ui/common/common_bg_26.png')
    -- end
    self:updateFatePlRight()
end

function RoleListUI:initFateRoleCell(index, bgimg)
	local roleAlphaBg = bgimg:getChildByName("role_alpha_bg")
    local roleAlphaBgSize = roleAlphaBg:getContentSize()

    local fightforcetx = bgimg:getChildByName('fightforce_tx')
    local nametx = bgimg:getChildByName('name_tx')
    local newimg = bgimg:getChildByName('new_img')
    local fightforceimg = bgimg:getChildByName('fightforce_img')
    local roleOpenTx = bgimg:getChildByName('role_open_tx')
    
    -- if index == 1 then
        -- --rolebg:setVisible(false)
        -- newimg:setVisible(false)
        -- fightforceimg:setVisible(false)
        -- fightforcetx:setVisible(false)
        -- roleOpenTx:setVisible(true)

        -- local conf = GameData:getConfData('moduleopen')['fateAdvanced']
        -- local lvLimit = conf.level
        -- local level = UserData:getUserObj():getLv()
        -- if level >= lvLimit then
        --     roleOpenTx:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES24'))
        -- else
        --     roleOpenTx:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES1'),lvLimit))
        -- end
    -- else
        roleOpenTx:setVisible(false)
	    local roleCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.objfatearr[index], roleAlphaBg)
	    roleCell.awardBgImg:setTouchEnabled(false)
	    roleCell.awardBgImg:setPosition(cc.p(roleAlphaBgSize.width/2, roleAlphaBgSize.height/2))

        --rolebg:loadTexture(self.objfatearr[index]:getBgImg())
        --roleicon:loadTexture(self.objfatearr[index]:getIcon())
        --rolelvtx:setString('Lv'..self.objfatearr[index]:getLevel())
        if self.objfatearr[index]:getTalent() > 0 then
	        nametx:setString(self.objfatearr[index]:getName()..'+'..self.objfatearr[index]:getTalent())
	    else
		    nametx:setString(self.objfatearr[index]:getName())
	    end
        nametx:setTextColor(self.objfatearr[index]:getNameColor())
    
        if self.objfatearr[index]:isFateCanAcitive() then
    	    newimg:setVisible(true)
        else
    	    newimg:setVisible(false)
        end
        local leftLabel = cc.LabelAtlas:_create(RoleData:getPosFightForceByPos(self.objfatearr[index]), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	    leftLabel:setAnchorPoint(cc.p(0,0.5))
	    leftLabel:setPosition(cc.p(0,0))
	    leftLabel:setScale(0.7)
	    fightforcetx:addChild(leftLabel)
    -- end
    bgimg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self.selectheroindex = index
            for i=1,self.fatenum do
                local tempbgimg = self.heroCellTab[i]:getChildByName("bg_img")
                -- if i == 1 then
                --     tempbgimg:loadTexture('uires/ui/fateshow/fateshow_paizi2.png')
                -- else
                    tempbgimg:loadTexture('uires/ui/common/common_bg_21.png')
                -- end
            end
            -- if self.selectheroindex == 1 then
            --     bgimg:loadTexture('uires/ui/fateshow/fateshow_paizi.png')
            -- else
                bgimg:loadTexture('uires/ui/common/common_bg_26.png')
            -- end
            self:updateFatePlRight()
        end
    end)
end

function  RoleListUI:ishaveteam(id)
	local innategropeconf = GameData:getConfData('innategroup')[id]
	local teamroleId = 0
	if innategropeconf and innategropeconf.teamheroID then
		teamroleId = innategropeconf.teamheroID
	end
	local hadFate = false
	local camp = self.objfatearr[self.selectheroindex]:getCamp()
	if self.objfatearr[self.selectheroindex]:getQuality() >= 5 and camp ~= 5 and teamroleId > 0 then
		hadFate = true
	end
	return hadFate
end
function RoleListUI:updateFatePlRight()
	local fatesv = self.rolefatebg:getChildByName('role_fate_sv')
    local roleNoFate = self.rolefatebg:getChildByName('role_no_fate')
	fatesv:setScrollBarEnabled(false)
	fatesv:setInertiaScrollEnabled(true)
	-- fatesv:removeAllChildren()
	-- local fatesvcontentWidget = ccui.Widget:create()
    --    fatesv:addChild(fatesvcontentWidget)
    --    fatesvcontentWidget:removeAllChildren()

    local roleNoConspiracy = self.rolefatebg:getChildByName('role_no_conspiracy')
    local roleConspiracySv = self.rolefatebg:getChildByName('role_conspiracy_sv')
    roleConspiracySv:setScrollBarEnabled(false)
	roleConspiracySv:setInertiaScrollEnabled(true)

    -- if self.selectheroindex == 1 then
    --     for i=1,5 do
		  --   if self.fateCellTab[i] then
    --             self.fateCellTab[i]:setVisible(false)
    --         end
    --     end
    --     roleNoFate:setVisible(false)
    --     roleNoConspiracy:setVisible(true)
    --     roleConspiracySv:setVisible(true)
    --     local conf = GameData:getConfData('moduleopen')['fateAdvanced']
    --     local lvLimit = conf.level
    --     local level = UserData:getUserObj():getLv()
    --     if level >= lvLimit then
    --         roleNoConspiracy:setVisible(false)
    --         roleConspiracySv:setVisible(true)
    --         self:updateAdvancedFateCell(roleConspiracySv)
    --     else
    --         roleNoConspiracy:setVisible(true)
    --         roleConspiracySv:setVisible(false)
    --     end
    --     local noMail = roleNoConspiracy:getChildByName('no_mail')
    --     noMail:getChildByName('info_tx'):setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES1'),lvLimit))
    -- else
        roleNoConspiracy:setVisible(false)
        roleConspiracySv:setVisible(false)

		local fateatt =	self.objfatearr[self.selectheroindex]:getFateArr()
		local num = #fateatt
		local innategropeconf = GameData:getConfData('innategroup')[self.objfatearr[self.selectheroindex]:getId()]
		--local teamroleId = innategropeconf.teamheroID
		local hadFate = self:ishaveteam(self.objfatearr[self.selectheroindex]:getId())
		if hadFate then
			num = num + 1
		end
	    self.nowNum = num
	    local contentsize
	    local currNum = 0
		for i=1,5 do
			if not self.fateCellTab[i] then
				local node = cc.CSLoader:createNode("csb/rolefate_fate_cell.csb")
			    local bgimg = node:getChildByName("bg_img")

			    local pl = bgimg:getChildByName("pl")
				local fateHeroBg = pl:getChildByName("fate_hero_bg")
				local roleAlphaBg = fateHeroBg:getChildByName("role_alpha_bg")
			    local roleAlphaBgSize = roleAlphaBg:getContentSize()
			    local roleCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
			    roleCell.awardBgImg:ignoreContentAdaptWithSize(true)
			    roleCell.awardImg:ignoreContentAdaptWithSize(true)
			    roleCell.awardBgImg:setPosition(cc.p(roleAlphaBgSize.width/2, roleAlphaBgSize.height/2))
			    roleAlphaBg:addChild(roleCell.awardBgImg)

			    for j = 1, 4 do
			    	local fateHeroBg2 = bgimg:getChildByName("fate_hero_" .. j .. "_bg")
				    local roleAlphaBg2 = fateHeroBg2:getChildByName("role_alpha_bg")
				    local roleCell2 = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
				    roleCell2.awardBgImg:ignoreContentAdaptWithSize(true)
				    roleCell2.awardImg:ignoreContentAdaptWithSize(true)
				    roleCell2.awardBgImg:setPosition(cc.p(roleAlphaBgSize.width/2, roleAlphaBgSize.height/2))
				    roleAlphaBg2:addChild(roleCell2.awardBgImg)
				end

			    bgimg:removeFromParent(false)
			    bgimg:setName('rolefate_fate_cell'..i)
			    fatesv:addChild(bgimg)
			    self.fateCellTab[i]= bgimg
			end
			contentsize = self.fateCellTab[i]:getContentSize()
		    if i == 1 then
		    	if hadFate ~= true then
		    		self.fateCellTab[i]:setVisible(false)
		    	else
		    		currNum = currNum + 1
		    		self.fateCellTab[i]:setVisible(true)
		    		self:updateFateCellS(i)
		    	end
		    else

		    	if i <= (num + 1) then
		    		currNum = currNum + 1
		    		self.fateCellTab[i]:setVisible(true)
		    		self:updateFateCell(i,currNum)
		    	else
		    		self.fateCellTab[i]:setVisible(false)
		    	end
		    end
		    local posx = fatesv:getContentSize().width/2
		    local posy = (contentsize.height + 5)*(num - currNum)+contentsize.height/2
		    self.fateCellTab[i]:setPosition(cc.p(posx,posy))
		end
	    if self.nowNum ~= self.oldNum and contentsize then
		    -- if math.ceil(num*(contentsize.height+5)) > fatesv:getContentSize().height then
		    	local height = num*(contentsize.height+5)
		        fatesv:setInnerContainerSize(cc.size(contentsize.width,height))
		    -- end
		end
		self.oldNum = self.nowNum
	    if num > 0 then
	        roleNoFate:setVisible(false)
	    else
	        roleNoFate:setVisible(true)
	    end  

    -- end
end

function RoleListUI:updateAdvancedFateCell(roleConspiracySv)
    if #self.objfateadvancedarr > 0 then
        for k = 1,#self.objfateadvancedarr do
            self:updateAdvancedFateCellItem(self.objfateadvancedarr[k].type,self.objfateadvancedarr[k])
        end
        return
    end

    local sv = roleConspiracySv

    local tempData = GameData:getConfData('fateadvancedtype')
    local num = #tempData
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local WIDHT = 546
    local HEGIHT = 196

    local height = num * HEGIHT + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = HEGIHT
    for i = 1,num do
        local node = cc.CSLoader:createNode("csb/rolefate_fate_cell_conspiracy.csb")
		local tempCell = node:getChildByName("bg_img")
		tempCell:removeFromParent(false)
        sv:addChild(tempCell)

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(WIDHT/2,allHeight - offset + HEGIHT/2))
        self:updateAdvancedFateCellItem(i,tempCell)
        tempCell.type = i
        table.insert(self.objfateadvancedarr,tempCell)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function RoleListUI:updateAdvancedFateCellItem(type,bgImg)
    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[type]
    local attributeConf = GameData:getConfData('attribute')
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')

    local leftNameTx = bgImg:getChildByName('left_name_tx')
    leftNameTx:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES2'),fateAdvancedTypeData.fateName))

    local rightNameTx = bgImg:getChildByName('right_name_tx')
    rightNameTx:setString(fateAdvancedTypeData.attEffDesc)

    local leftImg = bgImg:getChildByName('left_img')
    local frame = leftImg:getChildByName('frame')
    frame:loadTexture(COLOR_FRAME[tonumber(fateAdvancedTypeData.fateIconQuality)])
    local icon = frame:getChildByName('icon')
    icon:loadTexture('uires/icon/fate_icon/' .. fateAdvancedTypeData.fateIcon2)

    local rightImg = bgImg:getChildByName('right_img')
    local upgradeBtn = rightImg:getChildByName('upgrade_btn')
    upgradeBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES4'))
    upgradeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleLvUpOneLevelPannelUI(type)
        end
    end)

    local activeBtn = rightImg:getChildByName('active_btn')
    activeBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES5'))
    activeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleLvUpOneLevelPannelUI(type)
        end
    end)

    -- 是否激活
    local nowLv = UserData:getUserObj():getConspiracy()[tostring(type)] or 0
  
    local notActiveImg = leftImg:getChildByName('not_active_img')
    if nowLv <= 0 then
        notActiveImg:setVisible(true)
        activeBtn:setVisible(true)
        upgradeBtn:setVisible(false)
    else
        notActiveImg:setVisible(false)
        activeBtn:setVisible(false)
        upgradeBtn:setVisible(true)

        -- 左边等级
        local lvRichText = leftImg:getChildByName('reichtext_lv')
        if not lvRichText then
            local richText = xx.RichText:create()
            richText:setName('reichtext_lv')
	        richText:setContentSize(cc.size(200, 40))

	        local re1 = xx.RichTextImage:create('uires/ui/common/lv_art.png')
    
	        local re2 = xx.RichTextLabel:create(100, 22,COLOR_TYPE.WHITE)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re2:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0.5,0.5))
	        richText:setPosition(cc.p(notActiveImg:getPositionX(),notActiveImg:getPositionY() - 8))
            leftImg:addChild(richText)

            richText.re2 = re2
            lvRichText = richText
        end
        lvRichText.re2:setString(nowLv)
        lvRichText:format(true)
    end

    -- 右边属性
    local richTextAttSpecial = rightImg:getChildByName('reichtext_att_spacial')
    if not richTextAttSpecial then
        local richText = xx.RichText:create()
        richText:setName('reichtext_att_spacial')
	    richText:setContentSize(cc.size(500, 40))

	    local re1 = xx.RichTextLabel:create('', 20,COLOR_TYPE.RED)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create('', 20,COLOR_TYPE.YELLOW)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

        local re3 = xx.RichTextLabel:create('', 20,cc.c4b(163, 163, 163, 255))
	    re3:setStroke(cc.c4b(0, 0, 0, 255),1)
        re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(5,119.5))
        rightImg:addChild(richText)

        richText.re1 = re1
        richText.re2 = re2
        richText.re3 = re3
        richTextAttSpecial = richText
    end
    local fateadvancedData = fateadvancedConf[type]
    local maxLv = #fateadvancedData
    local attSpecialId = fateAdvancedTypeData.attSpecialId
    richTextAttSpecial.re1:setString(attributeConf[attSpecialId].name)
    local re3Desc = ''
    local nextLv = nowLv + 1
    if nowLv <= 0 then
        richTextAttSpecial.re2:setString(' +' .. 0 .. '%')
        if fateadvancedData[nextLv].attSpecialValue > 0 then
            re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES6'),fateadvancedData[nextLv].attSpecialValue/100) .. '%】'
        end
    else
        richTextAttSpecial.re2:setString(' +' .. fateadvancedData[nowLv].attSpecialValue/100 .. '%')
        if nowLv < maxLv then
            if fateadvancedData[nowLv].attSpecialValue ~= fateadvancedData[nextLv].attSpecialValue then
                re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES7'),nextLv,fateadvancedData[nextLv].attSpecialValue/100) .. '%】'
            end
        end
    end
    richTextAttSpecial.re3:setString(re3Desc)
    richTextAttSpecial:format(true)

    local reachMaxLvImg = rightImg:getChildByName('reach_max_lv_img')
    if nowLv >= maxLv then
        reachMaxLvImg:setVisible(true)
        upgradeBtn:setVisible(false)
        activeBtn:setVisible(false)
    else
        reachMaxLvImg:setVisible(false)
    end

    for i = 1,4 do
        local reichtextAtt = rightImg:getChildByName('reichtext_att_' .. i)
        if not reichtextAtt then
            local richText = xx.RichText:create()
            richText:setName('reichtext_att_' .. i)
	        richText:setContentSize(cc.size(500, 40))

	        local re1 = xx.RichTextLabel:create('', 18,COLOR_TYPE.WHITE)
	        re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')

	        local re2 = xx.RichTextLabel:create('', 18,COLOR_TYPE.GREEN)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re2:setFont('font/gamefont.ttf')

            local re3 = xx.RichTextLabel:create('', 18,cc.c4b(163, 163, 163, 255))
	        re3:setStroke(cc.c4b(0, 0, 0, 255),1)
            re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
            re3:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:addElement(re3)

            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0,0.5))
	        richText:setPosition(cc.p(8,112 - i * 25))
            rightImg:addChild(richText)

            richText.re1 = re1
            richText.re2 = re2
            richText.re3 = re3
            reichtextAtt = richText
        end
        local fateadvancedData = fateadvancedConf[type]
        local attSpecialId = fateAdvancedTypeData['attId' .. i]
        reichtextAtt.re1:setString(attributeConf[attSpecialId].name)
        local re3Desc = ''
        local nextLv = nowLv + 1
        if nowLv <= 0 then
            reichtextAtt.re2:setString(' +' .. 0)
            if fateadvancedData[nextLv]['attValue' .. i] > 0 then
                re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES8'),fateadvancedData[nextLv]['attValue' .. i])
            end
        else
            reichtextAtt.re2:setString(' +' .. fateadvancedData[nowLv]['attValue' .. i])
            if nowLv < maxLv then
                if fateadvancedData[nowLv]['attValue' .. i] ~= fateadvancedData[nextLv]['attValue' .. i] then
                    re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES9'),nextLv,fateadvancedData[nextLv]['attValue' .. i])
                end
            end
        end
        reichtextAtt.re3:setString(re3Desc)
        reichtextAtt:format(true)
    end
end

function RoleListUI:updateFateCellS(index)
	local bgimg = self.fateCellTab[index]
	local fatenametx = bgimg:getChildByName('fate_name_tx')
	local fateeffecttx = bgimg:getChildByName('fate_effect_tx')
	fatenametx:setVisible(false)
	fateeffecttx:setVisible(false)
	local pl = bgimg:getChildByName('pl')
	local fateheroarr = {}
	for i=1,4 do
		local bg = bgimg:getChildByName('fate_hero_'..i..'_bg')
		bg:setVisible(false)
	end

	local conf = GameData:getConfData('innategroup')[self.objfatearr[self.selectheroindex]:getId()]
	local talent = self.objfatearr[self.selectheroindex]:getTalent()
	local fatenametx1 = pl:getChildByName('fate_name_tx')
	local fateeffecttx1 = pl:getChildByName('fate_effect_tx')
	local fatenametx2 = pl:getChildByName('fate_name_tx1')
	fatenametx1:setString(GlobalApi:getLocalStr('SPECIAL_FATE'))
	fateeffecttx1:setString(GlobalApi:getLocalStr('SPECIAL_FATE_1'))
	local roleId = conf.teamheroID
	local fateHeroBg = pl:getChildByName('fate_hero_bg')
	local roleAlphaBg = fateHeroBg:getChildByName('role_alpha_bg')
	local roleBg = roleAlphaBg:getChildByName('award_bg_img')
	local alreadyBg = fateHeroBg:getChildByName('already_bg')
	local obj = RoleData:getRoleById(roleId)
	if obj then
		alreadyBg:loadTexture('uires/ui/text/yishangzhen.png')
	else
		alreadyBg:loadTexture('uires/ui/text/weishangzhen.png')
	end
	for i=1,4 do
		local conf1 = GameData:getConfData('innate')[conf['level'..conf.teamvaluegroup[i]]]
		local tx = pl:getChildByName('fate_tx_'..i)
		local str = conf['teamDes'..i]
		local strTab = string.split(str,'，')
		local str1 = conf1.name..'：'..strTab[#strTab]..' （'..string.format(GlobalApi:getLocalStr('ROLE_TUPO_ACTIVE_DESC'),('+'..conf.teamvaluegroup[i]))..'）'
		tx:setString(str1)
		if talent >= conf.teamvaluegroup[i] and obj then
			tx:setColor(COLOR_TYPE.GREEN)
			tx:enableOutline(COLOROUTLINE_TYPE.GREEN)
		else
			tx:setColor(COLOR_TYPE.GRAY)
			tx:enableOutline(COLOROUTLINE_TYPE.GRAY)
		end
	end
	local obj1 = RoleData:getRoleInfoById(roleId)
	fatenametx2:setString(obj1:getName())
	fatenametx2:setColor(obj1:getNameColor())
	fatenametx2:enableOutline(obj1:getNameOutlineColor(),1)
	ClassItemCell:updateHero(roleBg, obj1, 2)
	fateHeroBg:addClickEventListener(function ()
		GetWayMgr:showGetwayUI(obj1,true)			
	end)
end

function RoleListUI:updateFateCell(i,index)
	local bgimg = self.fateCellTab[i]
	local fatenametx = bgimg:getChildByName('fate_name_tx')
	local fateeffecttx = bgimg:getChildByName('fate_effect_tx')
	local pl = bgimg:getChildByName('pl')
	pl:setVisible(false)
	local fateheroarr = {}
	for i=1,4 do
		local arr = {}
		arr.bg = bgimg:getChildByName('fate_hero_'..i..'_bg')
		arr.bg:setVisible(false)
		local roleAlphaBg = arr.bg:getChildByName('role_alpha_bg')
		arr.roleframe = roleAlphaBg:getChildByName('award_bg_img')
		arr.roleicon = arr.roleframe:getChildByName('award_img')
		arr.newimg = arr.roleframe:getChildByName('up_img')
		arr.nametx = arr.bg:getChildByName('name_tx')
		arr.btn = arr.bg:getChildByName('btn')
		arr.btntx = arr.btn:getChildByName('tx')
		arr.alimg = arr.bg:getChildByName('already_bg')
		fateheroarr[i] = arr
	end
	self:genFateStayNight(self.objfatearr[self.selectheroindex], index, fateheroarr, fatenametx, fateeffecttx)
end

function RoleListUI:genFateStayNight(role, idx, wighetarr,fatenametx,fateeffecttx)
	local fateatt =	role:getFateArr()
	local hadfate = self:ishaveteam(self.objfatearr[self.selectheroindex]:getId())
	if hadfate then
		idx = idx - 1
	end
	-- if #fateatt <= 1 or fateatt[idx] == nil then
	-- 	return nil
	-- end

	local heroconf = GameData:getConfData('hero')
	local active = true
	for i, v in ipairs(fateatt[idx].roleStatus) do
		-- 下面的四个小人
		local tempRole = RoleData:getRoleInfoById(v.hid)
		ClassItemCell:updateHero(wighetarr[i].roleframe, tempRole, 2)
		wighetarr[i].bg:setVisible(true)
		wighetarr[i].bg:setTouchEnabled(false)
		wighetarr[i].nametx:setString(tempRole:getName())
		wighetarr[i].nametx:enableOutline(tempRole:getNameOutlineColor(), 1)
		wighetarr[i].nametx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		wighetarr[i].btn:setSwallowTouches(false)
		wighetarr[i].roleframe:setTouchEnabled(true)
		wighetarr[i].roleframe:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(tempRole,false)
            end
        end)
		ShaderMgr:restoreWidgetDefaultShader(wighetarr[i].roleframe)
		ShaderMgr:restoreWidgetDefaultShader(wighetarr[i].roleicon)
		wighetarr[i].alimg:setVisible(false)
		wighetarr[i].btn:setVisible(true)

		-- 这儿的逻辑很混乱 读代码的小兄弟 注意了。。。
		local zhenren = RoleData:getRoleById(v.hid)
		local card = BagData:getCardById(v.hid)
		if role:isAsssist(fateatt[idx].fid, v.hid) then
			wighetarr[i].btn:setVisible(true)
			wighetarr[i].btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			wighetarr[i].btntx:setString(GlobalApi:getLocalStr('FATE_TAKEOUT'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
			wighetarr[i].btn:addClickEventListener(self:takeoutFn(wighetarr, role, fateatt[idx], v))
			wighetarr[i].nametx:setVisible(false)
			wighetarr[i].newimg:setVisible(false)
		elseif zhenren == nil and card == nil then
			wighetarr[i].btn:setVisible(true)
			wighetarr[i].btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			ShaderMgr:setGrayForWidget(wighetarr[i].roleframe)
			ShaderMgr:setGrayForWidget(wighetarr[i].roleicon)
			wighetarr[i].btntx:setString(GlobalApi:getLocalStr('FATE_GET'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
			wighetarr[i].btn:setVisible(false)
			wighetarr[i].bg:setTouchEnabled(true)
			wighetarr[i].bg:addClickEventListener(function ()
				-- open the view ui
				GetWayMgr:showGetwayUI(tempRole,true)			
			end)
			wighetarr[i].newimg:setVisible(false)
			wighetarr[i].nametx:setVisible(true)
		elseif zhenren ~= nil then
			wighetarr[i].btn:setVisible(false)
			wighetarr[i].btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			wighetarr[i].btntx:setString(GlobalApi:getLocalStr('FATE_ALREADY'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
			wighetarr[i].nametx:setVisible(false)
			wighetarr[i].newimg:setVisible(false)
			wighetarr[i].alimg:setVisible(true)
		elseif zhenren == nil and card ~= nil then
			wighetarr[i].btn:setVisible(true)
			wighetarr[i].btn:loadTextureNormal('uires/ui/common/common_btn_3.png')
			wighetarr[i].btntx:setString(GlobalApi:getLocalStr('FATE_ASSIST'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE1)
			if role:isJunZhu() then
				wighetarr[i].btn:addClickEventListener(self:assistFn(wighetarr, role, fateatt[idx], v,i))
			else
				wighetarr[i].btn:addClickEventListener(self:assistFnWithMsgBox(wighetarr, role, fateatt[idx], v,i))
			end
			
			wighetarr[i].nametx:setVisible(false)
			wighetarr[i].newimg:setVisible(true)
		end
		if v.active == false then
			active = false
		end

	end
	local str = GlobalApi:getLocalStr('STR_GONGTONGSHANGZHENG')
	str = str .. fateatt[idx].effect1
	str = str .. GlobalApi:getLocalStr('STR_TIGAO')
	str = str .. fateatt[idx].effvalue1 .. '%'
	if fateatt[idx].effect2 then
		str = str ..'、' .. fateatt[idx].effect2
		str = str .. GlobalApi:getLocalStr('STR_TIGAO')
		str = str .. fateatt[idx].effvalue2 .. '%'
	end
	fateeffecttx:setString(str)
	fatenametx:setString(fateatt[idx].fname)

	local alFates = RoleData:getAlreadyFate(role)
	local n = GlobalApi:tableFind(alFates, fateatt[idx].fid) 
	
	if n == 0 then
		fatenametx:setColor(COLOR_TYPE.DARK)
		fatenametx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
		fateeffecttx:setColor(COLOR_TYPE.DARK)
		fateeffecttx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
	else
		fatenametx:setColor(COLOR_TYPE.ORANGE)
		fatenametx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		fateeffecttx:setColor(COLOR_TYPE.GREEN)
		fateeffecttx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
	end
end

function RoleListUI:takeoutFn(wighetarr, role, fateattr, onecrole,index)
	-- takeout the assist role card
	-- pos fid cid
	return function (  )
		self.bpressedbtn = true
		local args = {
			pos = role:getPosId(),
			fid = fateattr.fid,
			cid = onecrole.hid
		}
		MessageMgr:sendPost("unassist", "hero", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				local awards = jsonObj.data.awards
				if awards then
					GlobalApi:parseAwardData(awards)
				end
				role:delAssist(fateattr.fid, onecrole.hid)
				role:setFightForceDirty(true)
				RoleData:getPosFightForceByPos(role)
				--RoleMgr:updateRoleList()
				RoleMgr:popupTips(role)
				-- must be refresh main ui ... 
				--RoleMgr:updateRoleMainUI()

			    local bgimg = self.heroCellTab[self.selectheroindex]:getChildByName("bg_img")
			    local newimg = bgimg:getChildByName('new_img')
			    if self.objfatearr[self.selectheroindex]:isFateCanAcitive() then
			    	newimg:setVisible(true)
			    else
			    	newimg:setVisible(false)
			    end
				self:clickFate()
				self:update()

			end
		end)
	end
end

function RoleListUI:assistFnWithMsgBox(wighetarr, role, fateattr, onecrole,index)
	return function ()
		promptmgr:showMessageBox(GlobalApi:getLocalStr('ROLE_DESC11'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
           	self.bpressedbtn = true
			local args = {
				pos = role:getPosId(),
				fid = fateattr.fid,
				cid = onecrole.hid
			}
			MessageMgr:sendPost("assist", "hero", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					role:addAssist(fateattr.fid, onecrole.hid)
					role:setFightForceDirty(true)
					--RoleMgr:updateRoleList()
					self:clickFate()
					local bgimg = self.heroCellTab[self.selectheroindex]:getChildByName("bg_img")
				    local newimg = bgimg:getChildByName('new_img')
				    if self.objfatearr[self.selectheroindex]:isFateCanAcitive() then
				    	newimg:setVisible(true)
				    else
				    	newimg:setVisible(false)
				    end
				    RoleData:getPosFightForceByPos(role)
					RoleMgr:popupTips(role)
					-- must be refresh main ui ... 
					--RoleMgr:updateRoleMainUI()
					--RoleMgr:showFateShow(role, fateattr.fid)
					local alFates = RoleData:getAlreadyFate(role)
					local n = GlobalApi:tableFind(alFates, fateattr.fid) 
					
	                promptmgr:showSystenHint(GlobalApi:getLocalStr('FATE_ASSIST_SUCCEESS'), COLOR_TYPE.GREEN)

					if n ~= 0 then
						RoleMgr:showFateShow(role, fateattr.fid)
					end
					self:updateFatePlRight()
				end
			end)
        end,GlobalApi:getLocalStr('STR_OK2'),GlobalApi:getLocalStr('MESSAGE_NO'))
	end
end

function RoleListUI:assistFn(wighetarr, role, fateattr, onecrole,index)
	-- post assist msg
	-- pos fid cid
	return function()
		self.bpressedbtn = true
		local args = {
			pos = role:getPosId(),
			fid = fateattr.fid,
			cid = onecrole.hid
		}
		MessageMgr:sendPost("assist", "hero", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				role:addAssist(fateattr.fid, onecrole.hid)
				role:setFightForceDirty(true)
				--RoleMgr:updateRoleList()
				self:clickFate()
				local bgimg = self.heroCellTab[self.selectheroindex]:getChildByName("bg_img")
			    local newimg = bgimg:getChildByName('new_img')
			    if self.objfatearr[self.selectheroindex]:isFateCanAcitive() then
			    	newimg:setVisible(true)
			    else
			    	newimg:setVisible(false)
			    end
			    RoleData:getPosFightForceByPos(role)
				RoleMgr:popupTips(role)
				-- must be refresh main ui ... 
				--RoleMgr:updateRoleMainUI()
				--RoleMgr:showFateShow(role, fateattr.fid)
				local alFates = RoleData:getAlreadyFate(role)
				local n = GlobalApi:tableFind(alFates, fateattr.fid) 
				
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FATE_ASSIST_SUCCEESS'), COLOR_TYPE.GREEN)

				if n ~= 0 then
					RoleMgr:showFateShow(role, fateattr.fid)
				end
				self:updateFatePlRight()
			end
		end)
	end
end

return RoleListUI