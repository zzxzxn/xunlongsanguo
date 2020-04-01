local RoleSelectListOutSideUI = class("RoleSelectListOutSideUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleSelectListOutSideUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_ROLESELECTLISTOUTSIDE
	self.dirty = false
end

function RoleSelectListOutSideUI:setDirty(onlychild)
	self.dirty = true
end
function RoleSelectListOutSideUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	bgimg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleSelectListOutSide()
        end
    end)
    local bgalpha = bgimg:getChildByName('bg_alpha')
	local bgimg1 =bgalpha:getChildByName('bg_img1')
	local titlebg =bgimg1:getChildByName('title_bg')
	local titletx =titlebg:getChildByName('title_tx')
	titletx:setString(GlobalApi:getLocalStr('ROLESEL'))
	self.noroleimg = bgimg1:getChildByName('norole_img')
	self.listview = bgimg1:getChildByName('role_listview')
    local node = cc.CSLoader:createNode("csb/roleselectcell.csb")
    local cellbgimg = node:getChildByName("bg_img")
    local iconImg = cellbgimg:getChildByName("icon_img")
    local iconImgSize = iconImg:getContentSize()
    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    iconCell.awardBgImg:setTouchEnabled(false)
    iconCell.awardBgImg:setPosition(cc.p(iconImgSize.width/2, iconImgSize.height/2))
    iconImg:addChild(iconCell.awardBgImg)
    self.listview:setItemModel(cellbgimg)
    self.listview:setScrollBarEnabled(false)
	self:adaptUI(bgimg, bgalpha)
	self.rolecards = {}
	self.cardsNum = 0


    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleSelectListOutSide()
        end
    end)
    self:update()
end

function RoleSelectListOutSideUI:update()
	self.rolecards = {}
	local assistmap = RoleData:getRoleAssistMap()
	local allcards = BagData:getAllCards()
	for k, v in pairs(allcards) do
		 if assistmap[v:getId()] == nil and v:getId() < 10000  then
		 	table.insert(self.rolecards, v)
		 end
	end
	self.cardsNum = #self.rolecards
	if self.cardsNum > 0 then
		RoleMgr:sortByQuality(self.rolecards,ROLELISTTYPE.UI_BEASSIST)
		self:initListView()
		self.noroleimg:setVisible(false)
	else
		self.noroleimg:setVisible(true)
	end
end


function RoleSelectListOutSideUI:loadBy1FPS(amount, view, callback)
    local index = 0
    local function update()
        if index < amount then
            callback(index)
        else
            view:unscheduleUpdate()
        end
        index = index + 1
    end
    view:scheduleUpdateWithPriorityLua(update, 0)

end

function RoleSelectListOutSideUI:initListView()
    if table.getn(self.listview:getItems()) == 0 then
        local function callback(index)
            self:initListItem(index)
        end
        self:loadBy1FPS(#self.rolecards, self.root, callback)
    end
end

function RoleSelectListOutSideUI:initListItem(index)
    self.listview:pushBackDefaultItem()
    self:setListItem(index)
    local item = self.listview:getItem(index)
end

function RoleSelectListOutSideUI:setListItem( index)
    local item = self.listview:getItem(index)
    local data = self.rolecards[index+1] 
    item:setVisible(true)
    item:setName("roleselectcell_" .. index+1)
    self:updatecell(item,self.rolecards[index+1],index+1)

end

function RoleSelectListOutSideUI:updatecell( parent,obj,pos )
	self.nor_pl = parent:getChildByName('nor_pl')
	local iconbg = parent:getChildByName('icon_img')
	local iconbigbg = iconbg:getChildByName('award_bg_img')
	local numTx = iconbigbg:getChildByName('lv_tx')
	ClassItemCell:updateItem(iconbigbg, obj, 2)
	numTx:setVisible(false)

	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')
	self.lv = namebg:getChildByName('lv_tx')
	self.funcbtn = self.nor_pl:getChildByName('func_btn')
    self.funcbtn:setPropagateTouchEvents(false)
    local tx =self.funcbtn:getChildByName('btn_tx')
	tx:setString(GlobalApi:getLocalStr('STR_ASSIST'))
	if obj:getId() ~= 0 then
		self.name:setString(obj:getName())
		self.name:setTextColor(obj:getNameColor())
		--self.name:enableOutline(obj:getNameOutlineColor(),2)
		self.soldiertypeimg:loadTexture('uires/ui/common/soldier_'..obj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
	end
	self.lv:setString("")
	self.funcbtn:addClickEventListener(function (sender, eventType)
		local function exchange()
			local args = {
				pos = RoleMgr:getSelectRolePos(),
	            hid = obj:getId()
			}
			MessageMgr:sendPost("exchange", "hero", json.encode(args), function (jsonObj)
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
					RoleData:exchangeRole(RoleMgr:getSelectRolePos(),obj:getId(),false)

					RoleMgr:setCurHeroChange(true)
					RoleMgr:updateRoleList()
					RoleMgr:setDirty("RoleListUI",false)	                

					local obj = RoleData:getRoleByPos(pos)
					if obj then
						obj:setFightForceDirty(true)
					end
					RoleData:getFightForce()
					RoleMgr:hideRoleSelectListOutSide()
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

return RoleSelectListOutSideUI