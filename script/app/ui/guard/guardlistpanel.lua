local GuardListUI = class("GuardListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end


function GuardListUI:ctor()
	self.uiIndex = GAME_UI.UI_GUARDLIST
    self.roletab = {}
end

function GuardListUI:init()
	local selectBgImg = self.root:getChildByName("select_bg_img")
	local selectImg = selectBgImg:getChildByName("select_img")
	self:adaptUI(selectBgImg, selectImg)

    local closeBtn = selectImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
           GuardMgr:hideGuardList()
        end
    end)
    self.roleSv = selectImg:getChildByName("sv")
    self.roleSv:setScrollBarEnabled(false)
    local titlebg = selectImg:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_ROLELIST_TITLE'))

    self.noroleimg = selectImg:getChildByName('norole_img')
    self:update()
end

function GuardListUI:update()
	local roleId = {}
    local cardId = {}
    local listId = {}
    local roleTab = RoleData:getRoleMap()
    for k, v in pairs(roleTab) do
    	if tonumber(v:getId()) ~= 0 and not v:isJunZhu() and tonumber(v:getId()) < 10000 and v.quality > 3 and v.quality < 7 then
    		table.insert(roleId, tonumber(v:getId()))
    	end 
    end
    self.num = 0
    if #roleId > 0 then
        local cardTab = BagData:getAllCards()
        for k, v in pairs(cardTab) do
            if tonumber(v:getId()) ~= 0 and not v:isJunZhu() and tonumber(v:getId()) < 10000 and v.quality > 3 and v.quality < 7 then
                table.insert(cardId, tonumber(v:getId()))
            end
        end

       	listId = roleId
    	for k, v in pairs (cardId) do
    	 	if not tablefind(v, roleId) and k < 10000 then
                table.insert(listId, v)
    	 	end
     	end

        self.num = #listId
     	table.sort(listId, function (rid1, rid2)
     		local rObj1 = RoleData:getRoleInfoById(rid1)
     		local rObj2 = RoleData:getRoleInfoById(rid1)
    		local quality1 = rObj1:getQuality() 
    		local quality2 = rObj2:getQuality() 
    		if quality1 < quality2 then
    			return true
    		elseif quality1 == quality2 then
    			local piece1 = BagData:getFragmentById(rid1)
    			local piece2 = BagData:getFragmentById(rid2)
                local num1 = 0
                local num2 = 0
                if  piece1 then
                    num1 = piece1:getNum()
                end
                if piece2 then
                    num2 = piece2:getNum()
                end

    			if num1 > num2 then
    				return true
    			elseif num1 == num2 then
    				if rid1 < rid2 then
    					return false
    				else
    					return true
    				end
    			elseif num1 < num2 then
    				return false
    			end
    		elseif quality1 > quality2 then
    			return false
    		end
    		return true
    	end)
     end
    self.pushRoleId = {}
    local data = GuardMgr:getAllCityData()
    for k, v in pairs(data.guard.field) do
        table.insert(self.pushRoleId, v.hid)
    end

 	local index = 1
    for k, v in pairs(listId) do
        self:addCells(index,v)
        index = index+1
    end 
    if self.num < 1 then
        self.noroleimg:setVisible(true)
    else
        self.noroleimg:setVisible(false)
    end
   	self.roleSv:jumpToTop()
end

function GuardListUI:addCells(index,data)
    local node = cc.CSLoader:createNode("csb/guardlistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.roletab[index] = ccui.Widget:create()
    self.roletab[index]:addChild(bgimg)
    self:initCell(index,data)
    local bgimg = self.roletab[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if math.ceil(self.num/2)*(contentsize.height+10) > self.roleSv:getContentSize().height then
        self.roleSv:setInnerContainerSize(cc.size(self.roleSv:getContentSize().width,math.ceil(self.num/2)*(contentsize.height+5)+20))
    end
    local posx = -1*(index%2)*(contentsize.width+4) + contentsize.width+6
    local posy = self.roleSv:getInnerContainerSize().height-math.ceil(index/2)*(5 + contentsize.height)-10 
    self.roletab[index]:setPosition(cc.p(posx,posy))
    self.roleSv:addChild(self.roletab[index])
end

function GuardListUI:initCell(index,data)
    local cell = self.roletab[index]
    local bgimg = cell:getChildByName('bg_img')
    local rObj = RoleData:getRoleInfoById(tonumber(data))
    local namebg = bgimg:getChildByName('namebg_img')
    local nameTx = namebg:getChildByName('name_tx')
    local lvtx = namebg:getChildByName('lv_tx')
    nameTx:setString(rObj:getName())
    nameTx:setColor(rObj:getNameColor())
    --lvtx:setString(rObj:getLevel())
    local iconBgNode = bgimg:getChildByName('icon_bg_node')
    local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, rObj, iconBgNode)

    local numTx = bgimg:getChildByName('num_tx')
    local num = 0
    local piece = BagData:getFragmentById(tonumber(data)) 
    if piece then
        num = piece:getNum()
    end
    numTx:setString(GlobalApi:getLocalStr('GUARD_DESC26')..num)
    -- local lvtx  = namebg:getChildByName('lv_tx')
    -- lvtx:setString(rObj:getLevel())
    local paichuBtn = bgimg:getChildByName('func_btn')
    local paichuBtntx = paichuBtn:getChildByName('btn_tx')
    paichuBtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_BTN_TX3'))
    paichuBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
            GuardMgr:setSelectRoleId(tonumber(data))
            GuardMgr:hideGuardList()
            GuardMgr:updateGuardMain(3)
        end
    end)
    local haveselectIco = bgimg:getChildByName('gou_img')
    if tablefind(tonumber(data), self.pushRoleId) then
        paichuBtn:setVisible(false)
        haveselectIco:setVisible(true)
    else
        paichuBtn:setVisible(true)
        haveselectIco:setVisible(false)
    end
    local soldiertypeimg = namebg:getChildByName('soldiertype_img')
    soldiertypeimg:loadTexture('uires/ui/common/soldier_'..rObj:getSoldierId()..'.png')
end
return GuardListUI