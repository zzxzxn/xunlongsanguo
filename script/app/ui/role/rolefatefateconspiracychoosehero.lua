local ClassEquipSelectCell = require("script/app/ui/equip/equipselectcell")
local RoleFateFateConspiracyChooseHeroUI = class("RoleFateFateConspiracyChooseHeroUI", BaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end

function RoleFateFateConspiracyChooseHeroUI:ctor(type,heroIds,pos,callBack)
    self.uiIndex = GAME_UI.UI_ROLE_FATE_FATE_CONSPIRACY_CHOOSE_HERO
    self.type = type
    self.heroIds = heroIds
    self.pos = pos
    self.callBack = callBack
end

function RoleFateFateConspiracyChooseHeroUI:init()
    local equipSelectBgImg = self.root:getChildByName("equip_select_bg_img")
    local equipSelectImg = equipSelectBgImg:getChildByName("equip_select_img")
    self:adaptUI(equipSelectBgImg, equipSelectImg)
    local bgimg1 = equipSelectImg:getChildByName('bg_img1')
    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES11'))
    local closeBtn = equipSelectImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleFateFateConspiracyChooseHerolPannel()
        end
    end)
    equipSelectBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleFateFateConspiracyChooseHerolPannel()
        end
    end)

    local noDescTx = bgimg1:getChildByName('no_desc_tx')
    noDescTx:setVisible(false)

    local img = equipSelectImg:getChildByName('img')
    img:setVisible(false)
    self.img = img

    local listview = bgimg1:getChildByName("equip_sv")
    listview:setScrollBarEnabled(false)
    self.sv = listview
    self.viewSize = self.sv:getContentSize()

    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[self.type]
    local fateHeroId = fateAdvancedTypeData.fateHeroId

    local attributeConf = GameData:getConfData('attribute')
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')

    self.showData = {}
    local allcards = BagData:getAllCards()
    for k, v in pairs(allcards) do
		if v:getId() < 10000 and tablefind(v:getId(),fateHeroId) then        
            local obj = BagData:getCardById(v:getId())
            local num = obj:getNum()
            for i = 1,4 do
                if self.heroIds[i] == v:getId() then
                    num = num - 1
                end
            end
            if self.heroIds[self.pos] == v:getId() then
                num = num + 1
            end
            if num > 0 then
		        table.insert(self.showData,v:getId())
            end
		end
	end
    local noDescTx = bgimg1:getChildByName("no_desc_tx")
    local noDescTx2 = bgimg1:getChildByName("no_desc_tx_2")
    if #self.showData > 0 then
        noDescTx:setVisible(false)
        noDescTx2:setVisible(false)
	    self:initListView()
    else
        noDescTx:setVisible(true)
        noDescTx2:setVisible(true)
        noDescTx:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES15'))
        noDescTx2:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES16'))
    end
end

function RoleFateFateConspiracyChooseHeroUI:initListView()
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.showData
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace

    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil)
    else
        self.scrollViewGeneral:resetScrollView(self.sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil)
    end
end

function RoleFateFateConspiracyChooseHeroUI:initItemData(index)
    if self.showData[index] then
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

function RoleFateFateConspiracyChooseHeroUI:addItem(tempCellData,widgetItem)
    if self.showData[tempCellData.index] then
        local index = tempCellData.index

        local item = self.img:clone()
        item:setVisible(true)
        self:updatecell(index,item)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(item)
        item:setPosition(cc.p(w*0.5,h*0.5))
    end
end

function RoleFateFateConspiracyChooseHeroUI:updatecell(i,parent)
    local obj = BagData:getCardById(self.showData[i])

    local nor_pl = parent:getChildByName('nor_pl')
	local iconbg = parent:getChildByName('icon_img')

	
	local iconbigbg = iconbg:getChildByName('icon_bg_img')
	local icon = iconbigbg:getChildByName('icon_img')

    --xyh
    local typeImg = iconbigbg:getChildByName('type_img')
    local campType = obj:getCamp()
    typeImg:loadTexture('uires/ui/common/camp_'..campType..'.png')
	
	local namebg = nor_pl:getChildByName('namebg_img')
	local name = namebg:getChildByName('name_tx')
	local soldiertypeimg = namebg:getChildByName('soldiertype_img')
	local lv = namebg:getChildByName('lv_tx')
	local funcbtn = nor_pl:getChildByName('func_btn')
    funcbtn:setPropagateTouchEvents(false)
    local tx = funcbtn:getChildByName('btn_tx')
	tx:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES14'))
	icon:loadTexture(obj:getIcon())
	iconbigbg:loadTexture(obj:getBgImg())
	local fataImg = nor_pl:getChildByName('fate_img')
    fataImg:setVisible(false)
	if obj:getId() ~= 0 then
		name:setString(obj:getName())
		name:setTextColor(obj:getNameColor())
		soldiertypeimg:loadTexture(obj:getProfessionTypeImg())
		soldiertypeimg:loadTexture('uires/ui/common/soldier_'..obj:getSoldierId()..'.png')
		soldiertypeimg:ignoreContentAdaptWithSize(true)
	end
	lv:setString("")
	parent:setTouchEnabled(true)
	parent:setSwallowTouches(false)
    parent:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
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
	funcbtn:addClickEventListener(function (sender, eventType)
        self.heroIds[self.pos] = self.showData[i]
        self.callBack(self.heroIds)
        RoleMgr:hideRoleFateFateConspiracyChooseHerolPannel()
	end)

    local ownDesc = nor_pl:getChildByName('own_desc')
    ownDesc:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES13'))

    local num = obj:getNum()
    for j = 1,4 do
        if self.heroIds[j] == obj:getId() then
            num = num - 1
        end
    end
    if self.heroIds[self.pos] == obj:getId() then
        num = num + 1
    end

    local ownNum = nor_pl:getChildByName('own_num')
    ownNum:setString(num)
end

return RoleFateFateConspiracyChooseHeroUI