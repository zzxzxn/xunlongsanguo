local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassRoleEquipSelectCell = require("script/app/ui/role/roleequipselectcell")

local RoleEquipSelectUI = class("RoleEquipSelectUI", ClassRoleBaseUI)

local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

-- 排序:品质>战斗力>id
local function sortByQuality(lv,arr)
	table.sort(arr, function (a, b)
		local lv1 = a:canEquip(lv)
		local lv2 = b:canEquip(lv)
		if lv1 == lv2 then
			local q1 = a:getFightForce()
			local q2 = b:getFightForce()
			if q1 == q2 then
				local f1 = a:getQuality()
				local f2 = b:getQuality()
				if f1 == f2 then
					local id1 = a:getId()
					local id2 = b:getId()
					return id1 > id2
				else
					return f1 > f2
				end
			else
				return q1 > q2
			end
		else
			return lv1 < lv2
		end
	end)
end

function RoleEquipSelectUI:onMoveOut()

end

function RoleEquipSelectUI:ctor()
	self.super.ctor(self)
	self.equipPos = 0
	self.roleObj = nil
    self.equipNum = 0
    self.equips = {}

end

function RoleEquipSelectUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roleequipselectpanel.csb")
	self.panel:setName("role_equip_select_panel")
	self.equipSelect =self.panel:getChildByName("equip_select") 
	self.equipBgImg = self.equipSelect:getChildByName("equip_select_bg_img")
	self.listviewTemp = self.equipSelect:getChildByName("equip_select_sv")
	self.listviewTemp:setScrollBarEnabled(false)
    self.listviewTemp:setVisible(false)
	self.desc = self.equipSelect:getChildByName('desc_tx')
	self.noequipimg = self.equipSelect:getChildByName('noequipimg')
	self.desc:setString('')
    self.posY = self.listviewTemp:getPositionY()
    self.svSize = self.listviewTemp:getContentSize()
end

function RoleEquipSelectUI:update(roleObj, equipPos)
    if self.equipSelect:getChildByName('scrollview_sv') then
        self.equipSelect:removeChildByName('scrollview_sv')
        self.listview = nil
    end

    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.listviewTemp:getPosition())
    self.equipSelect:addChild(scrollView)
	self.listview = scrollView


	self.equipPos = equipPos
	self.roleObj = roleObj
    self.equips = {}

    local equipMap = BagData:getEquipMapByType(self.equipPos)
	for k, v in pairs(equipMap) do
		table.insert(self.equips, v)
	end

    self.equipNum = #self.equips
    print('+++++++++++++++++++' .. self.equipNum)

    local equipBgImgSize = self.equipBgImg:getContentSize()
	local currEquip = self.roleObj:getEquipByIndex(self.equipPos)
    if self.equipSelect:getChildByName('panel_equiped_cell') then
        self.equipSelect:removeChildByName('panel_equiped_cell')
    end
    local offsetH = 0
	if currEquip then -- 如果这格有装备
        local equipedCell = ClassRoleEquipSelectCell.new(self.roleObj:getPosId(), currEquip, true, 0)
	    local panel = equipedCell:getPanel()
        local w, h = equipedCell:getSize()
        panel:setPosition(cc.p(self.listview:getPositionX() + self.svSize.width/2,self.svSize.height - h*0.5))
        panel:setName('panel_equiped_cell')
        self.equipSelect:addChild(panel)
        offsetH = h + 4
    end

    self.listview:setContentSize(cc.size(self.svSize.width,self.svSize.height - offsetH))


    self.viewSize = self.listview:getContentSize() -- 可视区域的大小

	if self.equipNum > 0 then
		sortByQuality(UserData:getUserObj():getLv()+10,self.equips)
		self:initListView()
		self.noequipimg:setVisible(false)
	else
		self.noequipimg:setVisible(true)
	end

end

function RoleEquipSelectUI:initListView()
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.equips
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)
    else
        self.scrollViewGeneral:resetScrollView(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)
    end
    
end

function RoleEquipSelectUI:initItemData(index)
    if self.equips[index] then
        local equips = self.equips
        local equipObj = equips[index]

        local subAttrNum = equipObj:getSubAttrNum()
        local godId = equipObj:getGodId()
        if godId > 0 then
            local godNum = godId == 3 and 2 or 1
            subAttrNum = subAttrNum + godNum
        end
        local w = self.viewSize.width
        local h = 110 + subAttrNum*26
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function RoleEquipSelectUI:addItem(tempCellData,widgetItem)
    if self.equips[tempCellData.index] then
        local equips = self.equips
        local index = tempCellData.index

        local cell = ClassRoleEquipSelectCell.new(self.roleObj:getPosId(), self.equips[index], false, index)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell:getPanel())
        cell:getPanel():setPosition(cc.p(w*0.5,h*0.5))
    end
end

return RoleEquipSelectUI