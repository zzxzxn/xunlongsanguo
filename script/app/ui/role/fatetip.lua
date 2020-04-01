local FateTipUI = class("FateTipUI", BaseUI)

local bottomInt = 5
local topInt = 16
local tiaoHeight = 116


function FateTipUI:ctor(skiprole, skipfid, hid)
	self.uiIndex = GAME_UI.UI_FATETIP
	self.hid = hid
	self.skiprole = skiprole
	self.skipfid = skipfid
end

function FateTipUI:init()
	local attconf = GameData:getConfData('attribute')
	local role = RoleData:getRoleInfoById(self.hid)

	local bg = self.root:getChildByName('bgimg1')
	local bg1 = bg:getChildByName('bgimg2')
	bg1:setTouchEnabled(true)
	bg:setTouchEnabled(true)
	bg:addClickEventListener(function (  )
		RoleMgr:hideFateTip()
	end)

	local closebtn = bg1:getChildByName('close')
	closebtn:addClickEventListener(function (  )
			RoleMgr:hideFateTip()
		end)

	local bg2 = bg1:getChildByName('bgimg3')
	local role_frame = bg2:getChildByName('role_frame')
	role_frame:getChildByName('rolename')
		:setString(role:getName())
		:setTextColor(role:getNameColor())
		:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		:enableOutline(role:getNameOutlineColor(), 1)

	role_frame:getChildByName('rolebg')
		:loadTexture(role:getBgImg())

	role_frame:getChildByName('roleicon')
		:loadTexture(role:getIcon())

	local fateconf = GameData:getConfData('fate')
	local rt = xx.RichText:create()
	rt:setContentSize(cc.size(437, 167))
	rt:setAnchorPoint(cc.p(0, 0))

	local yu = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_YU'), 21, cc.c4b(163, 163, 163, 255))
	yu:setStroke(cc.c4b(0, 0, 0, 255), 1)
	yu:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

	local dun = xx.RichTextLabel:create('、', 21, cc.c4b(163, 163, 163, 255))
	dun:setStroke(cc.c4b(0, 0, 0, 255), 1)
	dun:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

	local t = RoleData:getTargetRoleAssitInfomation(self.skiprole, self.skipfid, self.hid)
	for i, v in ipairs(t) do
		local tr = v.role
		local conf = fateconf[tonumber(v.fid)]
		local rel1 = xx.RichTextLabel:create(tr:getName(), 25, tr:getNameColor())
		rel1:setStroke(tr:getNameOutlineColor(), 1)
		rel1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		rt:addElement(rel1)

		local title = '【' .. conf.name  .. '】\n'
		local rel2 = xx.RichTextLabel:create(title, 21, cc.c4b(254, 165, 0, 255))
		rel2:setStroke(COLOR_TYPE.BLACK, 1)
		rel2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		rt:addElement(rel2)

		rt:addElement(yu)

		local targetId = tr:getId()
		local attributeRoleIndex = 0
		for i = 1, 5 do
			local frid = conf['hid' .. i]
			if frid == 0 then
				break
			end
			if targetId == frid then
				attributeRoleIndex = i
			else
				local frole = RoleData:getRoleInfoById(frid)
				local frtl = xx.RichTextLabel:create(frole:getName(), 21, cc.c4b(163, 163, 163, 255))
				frtl:setStroke(COLOR_TYPE.BLACK, 1)
				frtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
				local assign = RoleData:getRoleById(frid)
				local assist = tr:isAsssist(v.fid, frid)
				if (assign ~= nil) or assist then
					frtl:setColor(cc.c4b(36, 255, 0, 255))
				end
				rt:addElement(frtl)
				rt:addElement(dun)
			end
		end
		rt:popElement()

		-- 获取这个武将在当前缘分下的属性加成显示
		local attrName1 = nil
		local attrValue1 = nil
		local attrName2 = nil
		local attrValue2 = nil

		local attid1 = conf['att' .. attributeRoleIndex .. 1]
		local attv1 = conf['value' .. attributeRoleIndex .. 1]
		if attid1  and tonumber(attid1[1]) > 0 then
			if  #attid1 > 1 then
				attrName1 = GlobalApi:getLocalStr('PROFESSION_NAME3')
			else
				attrName1 = attconf[tonumber(attid1[1])].name
			end	
			attrValue1 = tostring(attv1)
		end

		local attid2 = conf['att' .. attributeRoleIndex .. 2]
		local attv2 = conf['value' .. attributeRoleIndex .. 2]
		if attid2  and tonumber(attid2[1]) > 0 then
			if  #attid2 > 1 then
				attrName2 = GlobalApi:getLocalStr('PROFESSION_NAME3')
			else
				attrName2 = attconf[tonumber(attid2[1])].name
			end	
			attrValue2 = tostring(attv2)
		end

		local str = GlobalApi:getLocalStr('STR_GONGTONGSHANGZHENG')
		str = str .. attrName1
		str = str .. GlobalApi:getLocalStr('STR_TIGAO')
		str = str .. attrValue1 .. '%'
		if attrName2 and attrValue2 then
			str = str ..'、' .. attrName2
			str = str .. GlobalApi:getLocalStr('STR_TIGAO')
			str = str .. attrValue2 .. '%'
		end

		local rel3 = xx.RichTextLabel:create(str .. '\n', 21, cc.c4b(163, 163, 163, 255))
		rel3:setStroke(COLOR_TYPE.BLACK, 1)
		rel3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		rt:addElement(rel3)
	end
	rt:format(true)
	local rteSize = rt:getElementsSize()
	rt:setContentSize(rteSize)
	rt:setPosition(cc.p(9, 6))

	local rtExplain = xx.RichText:create()
	local str = 'FATE_ASSIST_EXPLAIN'
	rtExplain:setContentSize(cc.size(321, 50))
	rtExplain:setAnchorPoint(cc.p(0, 1))
	if rt:getElement(0) == nil then
		str = 'FATE_ASSIST_OVER'
	end
	local rtlExplain = xx.RichTextLabel:create(GlobalApi:getLocalStr(str), 21, COLOR_TYPE.WHITE)
		:setStroke(COLOR_TYPE.BLACK, 1)
		:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rtExplain:addElement(rtlExplain)
	rtExplain:setPosition(cc.p(117, -50))
	role_frame:addChild(rtExplain)

	local cardobj =BagData:getCardById(self.hid)
	local num = 0
	if cardobj ~= nil then
		num = cardobj:getNum()
	end

	local rtHad = xx.RichText:create()
	rtHad:setAnchorPoint(cc.p(1, 0.5))
	local rtl1Had = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_HAD'), 21, COLOR_TYPE.ORANGE)
		:setStroke(COLOR_TYPE.BLACK, 1)
		:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	local rtl2Had = xx.RichTextLabel:create(num, 21, COLOR_TYPE.WHITE)
		:setStroke(COLOR_TYPE.BLACK, 1)
		:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	
	local rtl3Had = xx.RichTextLabel:create(GlobalApi:getLocalStr('GE'), 21, COLOR_TYPE.ORANGE)
		:setStroke(COLOR_TYPE.BLACK, 1)
		:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rtHad:addElement(rtl1Had)
	rtHad:addElement(rtl2Had)
	rtHad:addElement(rtl3Had)
	rtHad:format(true)
	rtHad:setContentSize(rtHad:getElementsSize())
	rtHad:setPosition(cc.p(429, -30))
	role_frame:addChild(rtHad)

	-- now adapt it
	local diHeight = rteSize.height + tiaoHeight + 12
	bg2:setContentSize(cc.size(454, diHeight))
	local sumHeight = diHeight + bottomInt + topInt
	bg1:setContentSize(cc.size(467, sumHeight))
	bg2:setPosition(cc.p(232, sumHeight - topInt))
	bg2:getChildByName('tiao')
		:setPositionY(diHeight)
	role_frame:setPositionY(diHeight)
	closebtn:setPositionY(sumHeight)
	bg2:addChild(rt)

	self:adaptUI(bg, bg1)
end

-- function FateTipUI:update()
-- 	local bg = self.root:getChildByName('bgimg1')
-- 	local bg1 = bg:getChildByName('bgimg2')
-- end

return FateTipUI


