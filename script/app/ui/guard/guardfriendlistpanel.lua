local GuardFriendListUI = class("GuardFriendListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function GuardFriendListUI:ctor(data)
	self.uiIndex = GAME_UI.UI_GUARDFRIENDLISTUI
	self.friendtab = {}
	self.data  = data
	--printall(self.dat)
end

function GuardFriendListUI:init()
	local friendBgImg = self.root:getChildByName("friend_bg_img")
	local bgimg1 = friendBgImg:getChildByName('bg_img1')
    local friendImg = bgimg1:getChildByName('friend_img')
    self:adaptUI(friendBgImg,  bgimg1)

	local closeBtn = friendImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType ==  ccui.TouchEventType.ended then
			GuardMgr:hideGuardFriendList()
		end
	end)

	local data = GuardMgr:getAllCityData()
	local timeTx = friendImg:getChildByName('add_time_tx')

	local richText = xx.RichText:create()
    richText:setContentSize(cc.size(439, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC29'),25, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(GlobalApi:getGlobalValue('guardRepressLimitEachDay')-UserData:getUserObj():getGuard().repress,25, COLOR_TYPE.ORANGE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    --richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(0,-10))
    richText:setAlignment('middle')
    timeTx:addChild(richText,9527)

	timeTx:setString('')
	local tiltebg = friendImg:getChildByName('title_bg')
	local titletx = tiltebg:getChildByName('title_tx')
	titletx:setString(GlobalApi:getLocalStr('GUARD_DESC28'))
	--local cardBgImg = friendImg:getChildByName('card_bg_img')
	self.nofriendimg = friendImg:getChildByName('no_friend_img')
	self.sv = friendImg:getChildByName('card_sv')
	self.sv:setBounceEnabled(false)
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function GuardFriendListUI:update()
    self.memberarr = {}
    if self.data.list then
        for k,v in pairs (self.data.list) do 
            local arr = {}
            arr[1] = k
            arr[2] = v
            local fieldnum = 0
            for k,v in pairs(v.field) do
            	fieldnum = fieldnum + 1
            end
            arr[3] = fieldnum
            table.insert( self.memberarr,arr)
        end
    end

    self.num = #self.memberarr
    self:calcmess()
    for i=1,self.num do
       self:addCells(i,self.memberarr[i])
    end

    if self.num < 1 then
    	self.nofriendimg:setVisible(true)
    else
    	self.nofriendimg:setVisible(false)
    end
end

function GuardFriendListUI:calcmess()
	local maxmessnum = tonumber(GlobalApi:getGlobalValue('guardRepressLimitEachDay'))
	local seed = tonumber(UserData:getUserObj():getMark().day) + tonumber(UserData:getUserObj():getUid())
	math.randomseed(seed)
	self.havefieldtab = {}
	local data = UserData:getUserObj():getGuard().repress_list
    for i=1,self.num do 	
       if self.memberarr[i][3] > 0 then

	   		local  n = 0
	   		if UserData:getUserObj():getGuard().repress_list then
	   			n = GlobalApi:tableFind(UserData:getUserObj():getGuard().repress_list ,tonumber(self.memberarr[i][1]))
	   		end
	   		if n == 0 then
	       		table.insert(self.havefieldtab,i)
	       	end
       end
    end
	if  #self.havefieldtab < maxmessnum then
    	maxmessnum = #self.havefieldtab
    end
   
	local num = 0
	self.messtab = {}
	while (maxmessnum-num > 0) do
		local messid = GuardMgr:getMessIndex(#self.havefieldtab)
		local n = GlobalApi:tableFind(self.messtab,self.havefieldtab[messid])
		local havefind = false
		if #self.messtab > 0 then
			for i=1,#self.messtab do
				if self.havefieldtab[messid] == self.messtab[i][1] then
					havefind = true
					break
				end
			end
			if not havefind then
				local messcity = math.random(1,self.memberarr[self.havefieldtab[messid]][3])
				local arr = {}
				arr[1] = self.havefieldtab[messid]
				arr[2] = messcity
				table.insert(self.messtab,arr)
				num = num + 1
			end
		else
			local messcity = math.random(1,self.memberarr[self.havefieldtab[messid]][3])
			local arr = {}
			arr[1] = self.havefieldtab[messid]
			arr[2] = messcity
			table.insert(self.messtab,arr)
			num = num + 1
		end
	end
end

function GuardFriendListUI:addCells(index,data)

--	GuardMgr:wRand(index,data[2],field[i])
	local node = cc.CSLoader:createNode("csb/guardfriendcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.friendtab[index] = ccui.Widget:create()
    self.friendtab[index]:addChild(bgimg)

    --self.friendtab[index] = cc.CSLoader:createNode("csb/legionapplycell.csb")
    self:updateCell(index,data)
    local bgimg = self.friendtab[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height-10
    self.friendtab[index]:setPosition(cc.p(3,posy))
    self.sv:addChild(self.friendtab[index])
end

function GuardFriendListUI:updateCell(index,data)
	local messnum = 0
	
	local serverTime = tonumber(GlobalData:getServerTime())
	local guardtime = GlobalApi:getGlobalValue('guardProduceIntervalTime')

	local ismissed = 0
	local messtab ={}
	--if index == self.messtab[]
	for i=1,#self.messtab do
		if index == self.messtab[i][1] then
			data[4] = 1
			messnum = 1
			messtab[self.messtab[i][2]] = 1
			break
		end
	end

	data[5] = messtab
	--printall(data)
	local bgimg = self.friendtab[index]:getChildByName("bg_img")
	local colorimg = bgimg:getChildByName('color_img')
	if index%2== 0 then
		colorimg:setVisible(false)
	end
	local nametx = bgimg:getChildByName('name_tx')
	nametx:setString(data[2].un)
	local roleNode = bgimg:getChildByName('role_node')
	-- local frameimg = bgimg:getChildByName('frame_img')
	-- local iconimg = frameimg:getChildByName('icon_img')
	-- local roleobj = RoleData:getRoleInfoById(data[2].headpic)
	--iconimg:loadTexture(roleobj:getIcon())
    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    roleNode:addChild(iconCell.awardBgImg)

    local dataConf = GameData:getConfData('settingheadicon')
    if(dataConf[data[2].headpic] ~= nil) then
        iconCell.awardImg:loadTexture(dataConf[data[2].headpic].icon)
    end
	iconCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(data[2].headframe))
	iconCell.awardBgImg:loadTexture(COLOR_FRAME[data[2].quality])


    -- frameimg:loadTexture(COLOR_FRAME[data[2].quality])

	local lvtx = bgimg:getChildByName('lv_tx')
	lvtx:setString('Lv.'..data[2].level)

	local havenumtx = bgimg:getChildByName('have_num_tx')
	havenumtx:setString('')
	local richText = xx.RichText:create()
    richText:setContentSize(cc.size(439, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC31'),25, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(data[3],25, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(0,-3))
    --richText:setAlignment('middle')
    havenumtx:addChild(richText,9527)

	local activetx = bgimg:getChildByName('active_num_tx')
	activetx:setString('')
	local richText = xx.RichText:create()
    richText:setContentSize(cc.size(439, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC32'),25, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(messnum,25, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(0,-3))
    --richText:setAlignment('middle')
    activetx:addChild(richText,9527)

	local funcbtn = bgimg:getChildByName('func_btn')
	local funcbtntx = funcbtn:getChildByName('btn_tx')
	funcbtntx:setString(GlobalApi:getLocalStr('GUARD_DESC30'))
	funcbtn:addTouchEventListener(function (sender, eventType)
		if eventType ==  ccui.TouchEventType.ended then
			GuardMgr:setEnterdata(data)
			GuardMgr:hideGuardFriendList()
		end
	end)

    local riotImg = bgimg:getChildByName('riot_img')
    if messnum > 0 then
        riotImg:setVisible(true)
        havenumtx:setVisible(false)
        activetx:setVisible(false)
    else
        riotImg:setVisible(false)
        havenumtx:setVisible(true)
        activetx:setVisible(true)
    end

end
return GuardFriendListUI