local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleSelectListUI = class("RoleSelectListUI", ClassRoleBaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function RoleSelectListUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roleselectlistpanel.csb")
	local bgimg =self.panel:getChildByName('bg_img')
	local bgimg1 =bgimg:getChildByName('bg_img1')
    self.bgimg1 = bgimg1
	self.desctx = bgimg1:getChildByName('desc_tx')
	self.rolecards = {}
	self.cardsNum = 0
	self.noroleimg = bgimg1:getChildByName('norole_img')
    self.listviewTemp = bgimg1:getChildByName('role_listview')
    self.listviewTemp:setScrollBarEnabled(false)
    self.listviewTemp:setVisible(false)
    self.updateStatus = false
end

function RoleSelectListUI:onMoveOut()

end

function RoleSelectListUI:update(obj)
    if self.updateStatus == true then
        self.updateStatus = false
        return
    end
    if self.bgimg1:getChildByName('scrollview_sv') then
        self.bgimg1:removeChildByName('scrollview_sv')
        self.listview = nil
    end

    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.listviewTemp:getPosition())
    scrollView:setContentSize(self.listviewTemp:getContentSize())
    self.bgimg1:addChild(scrollView)
	self.listview = scrollView

    self.viewSize = self.listview:getContentSize() -- 可视区域的大小

	self.rolecards = {}
	local assistmap = RoleData:getRoleAssistMap()
	local allcards = BagData:getAllCards()
	for k, v in pairs(allcards) do
		 if assistmap[k] == nil  and v:getId() < 10000 then
		 	table.insert(self.rolecards, v)
		 end
	end
	local tab = RoleData:getFateCards()
	for i,v in pairs(tab) do
		local obj1 = BagData:getCardById(tonumber(i))
		if (not obj1 or obj1:getNum() <= 0) and assistmap[tonumber(i)] == nil then
		    local obj = ClassRoleObj.new(tonumber(i),tonumber(v))
		    obj.isFate = true
		    self.rolecards[#self.rolecards + 1] = obj
		end
	end
	table.sort( self.rolecards, function (a,b)
		local id1 = a:getId()
		local id2 = b:getId()
		if id1 == id2 then
			return not a.isFate
		else
			return id1 > id2
		end
	end )
	self.cardsNum = #self.rolecards
	self.desctx:setString('')
	if self.cardsNum > 0 then
		RoleMgr:sortByQuality(self.rolecards,ROLELISTTYPE.UI_BEASSIST)
		self:initListView()
		self.noroleimg:setVisible(false)
	else
		self.noroleimg:setVisible(true)
	end
end
function RoleSelectListUI:initListView()
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.rolecards
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    ScrollViewGeneral.new(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)

end

function RoleSelectListUI:initItemData(index)
    if self.rolecards[index] then
        local w = 430
        local h = 140
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function RoleSelectListUI:addItem(tempCellData,widgetItem)
    if self.rolecards[tempCellData.index] then
        local index = tempCellData.index
        local item = cc.CSLoader:createNode("csb/roleselectcell.csb")
        local cellbgimg = item:getChildByName("bg_img")
	    local iconImg = cellbgimg:getChildByName("icon_img")
	    local iconImgSize = iconImg:getContentSize()
	    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	    iconCell.awardBgImg:setTouchEnabled(false)
	    iconCell.awardBgImg:setPosition(cc.p(iconImgSize.width/2, iconImgSize.height/2))
	    iconImg:addChild(iconCell.awardBgImg)
        local data = self.rolecards[index] 
        item:setName("roleselectcell_" .. index)
        self:updatecell(item:getChildByName("bg_img"),data,index)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(item)
        item:setPosition(cc.p(w*0.5,h*0.5))
    end
end

function RoleSelectListUI:updatecell( parent,obj,pos )
   
	self.nor_pl = parent:getChildByName('nor_pl')
	local iconbg = parent:getChildByName('icon_img')

	local iconbigbg = iconbg:getChildByName('award_bg_img')
	local icon = iconbigbg:getChildByName('award_img')
	local numTx = iconbigbg:getChildByName('lv_tx')
	local objtemp  = RoleData:getRoleInfoById(obj:getId())
	ClassItemCell:updateItem(iconbigbg, objtemp, 2)
	numTx:setVisible(false)
	
	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')
	self.lv = namebg:getChildByName('lv_tx')
	self.funcbtn = self.nor_pl:getChildByName('func_btn')
    self.funcbtn:setPropagateTouchEvents(false)
    local tx =self.funcbtn:getChildByName('btn_tx')
	tx:setString(GlobalApi:getLocalStr('CHANGE_ROLE'))
	local fataImg = self.nor_pl:getChildByName('fate_img')
	if obj.isFate then
		self.funcbtn:setVisible(false)
		ShaderMgr:setGrayForWidget(icon)
		ShaderMgr:setGrayForWidget(iconbigbg)
		fataImg:setVisible(true)
	else
		self.funcbtn:setVisible(true)
		ShaderMgr:restoreWidgetDefaultShader(icon)
		ShaderMgr:restoreWidgetDefaultShader(iconbigbg)
		fataImg:setVisible(false)
	end
	if obj:getId() ~= 0 then
		self.name:setString(objtemp:getName())
		self.name:setTextColor(objtemp:getNameColor())
		self.soldiertypeimg:loadTexture(obj:getProfessionTypeImg())
		self.soldiertypeimg:loadTexture('uires/ui/common/soldier_'..obj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
	end
	self.lv:setString("")
	parent:setTouchEnabled(true)
	parent:setSwallowTouches(false)
    parent:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
	        if obj.isFate then
	         	local point1 = sender:getTouchBeganPosition()
	            local point2 = sender:getTouchEndPosition()
	            if point1 then
	                local dis =cc.pGetDistance(point1,point2)
	                if dis <= 10 then
	                    promptmgr:showSystenHint(GlobalApi:getLocalStr('HAD_FATE'), COLOR_TYPE.RED)
	                end
	            end
	        end
	    end
    end)
	self.funcbtn:addClickEventListener(function (sender, eventType)
		local oldobj = clone(RoleData:getRoleByPos(RoleMgr:getSelectRolePos()))
		local function exchange()
			local args = {
				pos = RoleMgr:getSelectRolePos(),
	            hid = obj:getId()
			}

			MessageMgr:sendPost("exchange", "hero", json.encode(args), function (jsonObj)
				print(json.encode(jsonObj))
				local code = jsonObj.code
				if code == 0 then
					local awards = jsonObj.data.awards
					GlobalApi:parseAwardData(awards)
					local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end

                    if awards then
	                    for k,v in pairs (awards) do
	                    	if v[1] == 'dress' then
	                    		local obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
	                    		obj:cleanSoldierDress()
	                    		break
		                    end
	                    end
	                end
	                local orirole = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
	                if orirole ~= nil then
	                	orirole:cleanupAssist()
	                end

					RoleData:exchangeRole(RoleMgr:getSelectRolePos(),obj:getId(),false)
					RoleMgr:setCurHeroChange(true)
					RoleMgr:updateRoleList()
					RoleMgr:setDirty("RoleListUI",false)
                    self.updateStatus = true
	                RoleMgr:updateRoleMainUI()
					self.rolecards[pos] = oldobj
	                self:updatecell(parent,oldobj,pos)
	           	elseif code == 101 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_8'), COLOR_TYPE.RED)
				end
			end)
		end
		local role = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		if role and role.hid ~= 0 then
			RoleMgr:showRoleExchange(exchange)
		else
			exchange()
		end
	end)
end
return RoleSelectListUI