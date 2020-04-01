local RoleResolveUI = class("RoleResolveUI", BaseUI)

local ROLE_COLOR = {
	[1] = 'WHITE',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED',
	[7] = 'GOLD',
}

function RoleResolveUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_ROLE_RESOLVE
	self.dirty = false
end

function RoleResolveUI:setDirty(onlychild)
	self.dirty = true
end
function RoleResolveUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	-- bgimg:addTouchEventListener(function (sender, eventType)
 --        if eventType == ccui.TouchEventType.ended then
 --            RoleMgr:hideRoleResolve()
 --        end
 --    end)
	local bgimg1 =bgimg:getChildByName('bg_img_1')
	local bgimg2 =bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg, bgimg1)
	local titleTx = bgimg1:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('ROLE_RESOLVE'))

	self.sv = bgimg2:getChildByName('info_sv')
	self.sv:setInertiaScrollEnabled(true)
	self.sv:setBounceEnabled(false)
	self.sv:setScrollBarEnabled(false)
	self.sv:setInnerContainerSize(self.sv:getContentSize())
	self.rolecards = {}
	self.cardsNum = 0
	self.roleCellNum = 0
	self.cellTotalHeight = 10
	self.contentWidget = ccui.Widget:create()
	self.sv:addChild(self.contentWidget)
	local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            self:addCells()
        end
    end

    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleResolve()
        end
    end)

    self.sv:addEventListener(scrollViewEvent)
    self:update()
end

function RoleResolveUI:update()
	self.rolecards = {}
	local assistmap = RoleData:getRoleAssistMap()
	local allcards = BagData:getAllCards()
	local tempallcards = {}
	for k,v in pairs(allcards) do
		if tonumber(k) < 10000 then
			table.insert(tempallcards,v)
		end
	end
	local cardsarr = {}
	for i=1,7 do
		local temp = {}
		temp.num = 0
		temp.soul = 0
		cardsarr[i] = temp
	end
	for k,v in pairs(tempallcards) do
		local qualiy = tonumber(v:getQuality())
		local soulnum = tonumber(v:getSoulNum())
		cardsarr[qualiy].num  = cardsarr[qualiy].num + v:getNum()
		cardsarr[qualiy].soul  = cardsarr[qualiy].soul + soulnum*v:getNum()
	end
	self.rolecards = cardsarr
	--printall(self.rolecards)
	self.cardsNum = #self.rolecards
	self.contentWidget:removeAllChildren()
	self.cellTotalHeight = 0
	self.roleCellNum = 0
	if self.cardsNum > 0 then
		self.sv:setContentSize(self.sv:getContentSize())
		self:addCells()
	end
	self.sv:scrollToTop(0.01, false)
end

function RoleResolveUI:addCells()
   	if self.roleCellNum < self.cardsNum then -- 每次创建7个
		local currNum = self.roleCellNum
		self.roleCellNum = self.roleCellNum + 7
		self.roleCellNum = self.roleCellNum > self.cardsNum and self.cardsNum or self.roleCellNum
		for i = currNum+3, self.roleCellNum do
			local cellNode = cc.CSLoader:createNode("csb/roleresolvecell.csb")
			local bgimg = cellNode:getChildByName("bg_img")
			bgimg:removeFromParent(false)
			local cell = ccui.Widget:create()
			cell:addChild(bgimg)
			local funcbtn = bgimg:getChildByName('func_btn')
			funcbtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				end
		        if eventType == ccui.TouchEventType.ended then
	                if i >= 5 then
	                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ROLE_DESC9")), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
	                        self:sendMsg(i)
	                    end)
	                else
	                    self:sendMsg(i)
	                end
		        end
		    end)
			if self.rolecards[i].num <= 0  then
				funcbtn:setVisible(false)
			else
				funcbtn:setVisible(true)
			end
			local functx = funcbtn:getChildByName('func_tx')
			functx:setString(GlobalApi:getLocalStr('STR_RESOLVE'))
			local nametx1 = bgimg:getChildByName('name_tx')
			nametx1:setString(GlobalApi:getLocalStr('COLOR_' ..i) .. GlobalApi:getLocalStr('CRAD') .. 'X' .. self.rolecards[i].num)
			nametx1:setTextColor(COLOR_TYPE[ROLE_COLOR[i]])
			nametx1:enableOutline(COLOROUTLINE_TYPE[ROLE_COLOR[i]],1)
			nametx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

			local richText = xx.RichText:create()
	        richText:ignoreContentAdaptWithSize(false)
	        richText:setContentSize(cc.size(335, 30))
	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("GLOBALGET"),23,COLOR_TYPE['ORANGE'])
	        local re2 = xx.RichTextLabel:create(' ' .. 'X'..self.rolecards[i].soul,23,COLOR_TYPE.WHITE)
	        local re3 = xx.RichTextImage:create('uires/ui/common/soul.png')
	        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	        re2:setStroke(COLOR_TYPE.BLACK, 1)
	        richText:addElement(re1)
	        richText:addElement(re3)
	        richText:addElement(re2)

	        richText:setLocalZOrder(2)
	        richText:setAnchorPoint(cc.p(0,0.5))
	        richText:setPosition(cc.p(28 ,30))
	        richText:setTag(9527)
	        bgimg:removeChildByTag(9527)
	        bgimg:addChild(richText)

			local contentsize = bgimg:getContentSize()
			self.cellTotalHeight = self.cellTotalHeight + contentsize.height + 5
			cell:setPosition(cc.p(0, contentsize.height*0.5 - self.cellTotalHeight + 5))
			self.contentWidget:addChild(cell)
		end
		local posY = self.sv:getContentSize().height
		self.cellTotalHeight = self.cellTotalHeight - 5
		if self.cellTotalHeight > posY then
			posY = self.cellTotalHeight
		end
		self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width, posY))
		self.contentWidget:setPosition(cc.p(self.sv:getContentSize().width*0.5, posY))
	end
end
function RoleResolveUI:sendMsg(qualiy)
    if self.rolecards[qualiy].num > 0 then
       	local args = {
			quality = qualiy
		}
		MessageMgr:sendPost("resolve_all", "hero", json.encode(args), function (jsonObj)
			print(json.encode(jsonObj))
			local code = jsonObj.code
			if code == 0 then
				local awards = jsonObj.data.awards
				GlobalApi:parseAwardData(awards)
				local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
				RoleMgr:updateRoleList()
				RoleMgr:hideRoleResolve()
				RoleMgr:setDirty()
				local str = string.format(GlobalApi:getLocalStr('STR_HAVESOUL'),self.rolecards[qualiy].num,GlobalApi:getLocalStr('COLOR_' ..qualiy),self.rolecards[qualiy].soul)
				promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
			end
		end)
	else
	--	print('xxxx')
	end
end
return RoleResolveUI