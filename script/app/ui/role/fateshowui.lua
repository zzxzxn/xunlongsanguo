local FateShowUI = class('FateShowUI', BaseUI)

function FateShowUI:ctor(role, fid)
	self.uiIndex = GAME_UI.UI_FATESHOW

	-- logic data
	self.role = role
	self.fid = fid

	-- view data
	self.list = nil
	self.default = nil
end

function FateShowUI:init()
	local bg = self.root:getChildByName('bg')
	local press = bg:getChildByName('press')
	press:setVisible(false)

	local bg1 = bg:getChildByName('bg1')

	self:adaptUI(bg, bg1, press)

	local conf = GameData:getConfData('fate')[tonumber(self.fid)]
	local heroconf = GameData:getConfData('hero')
	if conf == nil then
		print('[ERROR]: fate show ui args error ... can`t find the fate id ...' .. self.fid)
		return
	end
	bg1:getChildByName('title')
		:setString(conf.name)

	self.list = bg1:getChildByName('list')
	self.list:setScrollBarEnabled(false)
	if self.default == nil then
		self.default = self:_genDefaultItem()
	end
	self.list:setItemModel(self.default)

	local role_array = {}
	-- max roles is 5
	for i = 1, 5 do
		local hid = conf['hid' .. i]
		if hid ~= nil and self.role:getId() ~= hid and hid > 0 and heroconf[hid].camp ~= 5 then
			self.list:pushBackDefaultItem()

			local faterole = RoleData:getRoleInfoById(hid)
			table.insert(role_array, faterole)
		end
	end

	table.sort(role_array, function (a, b)
		local aid = a:getId()
		local bid = b:getId()

		local aassign = RoleData:getRoleById(aid)
		local aassist = self.role:isAsssist(self.fid, aid)
		local aactive = (aassign ~= nil) or aassist

		local bassign = RoleData:getRoleById(bid)
		local bassist = self.role:isAsssist(self.fid, bid)
		local bactive = (bassign ~= nil) or bassist

		local aqua = a:getQuality()
		local bqua = b:getQuality()

		if aactive == true and bactive == false then
			return true
		end
		if aactive == false and bactive == true then
			return false
		end
		if aactive == bactive then
			if aqua > bqua then
				return true
			end
			return false
		end
		return aid < bid
	end)
	-- make visible
	for i, v in ipairs(role_array) do
		local card = self.list:getItem(i - 1)

		card:getChildByName('name')
			:setLocalZOrder(99)
			:setString(v:getName())
			:setTextColor(v:getNameColor())
			:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			:enableOutline(v:getNameOutlineColor(), 1)

		local hid = v:getId()
		local assign = RoleData:getRoleById(hid)
		local assist = self.role:isAsssist(self.fid, hid)
		local active = (assign ~= nil) or assist

		card:getChildByName('active')
			:setLocalZOrder(99)
			:setVisible(active)
			:setScale(3)
			:runAction(cc.Sequence:create(
				cc.DelayTime:create(0.1),
				cc.ScaleTo:create(0.1, 1)))

		local role_ani = GlobalApi:createLittleLossyAniByRoleId(hid)
		role_ani:getAnimation():play('idle', -1, 1)
		role_ani:setPosition(cc.p(106, 60+heroconf[hid].uiOffsetY))
		role_ani:setScale(0.8)
		card:addChild(role_ani, 1)
	end

	-- could be exit
	bg:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.3), 
		cc.CallFunc:create(function ()
			bg:addClickEventListener(function ()
				RoleMgr:hideFateShow()
			end)

			press:setVisible(true)
				:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
				:runAction(
					cc.RepeatForever:create(
					cc.Sequence:create(
						cc.FadeOut:create(1.2),
						cc.FadeIn:create(1.2))))
		end)))

	-- get fate attribute
	local attconf = GameData:getConfData('attribute')
	local attrName1 = nil
	local attrValue1 = nil
	local attrName2 = nil
	local attrValue2 = nil

	local attid1 = conf.att11
	local attv1 = conf.value11
	if attid1  and tonumber(attid1[1]) > 0 then
		if  #attid1 > 1 then
			attrName1 = GlobalApi:getLocalStr('PROFESSION_NAME3')
		else
			attrName1 = attconf[tonumber(attid1[1])].name
		end
		attrValue1 = tostring(attv1)
	end

	local attid2 = conf.att12
	local attv2 = conf.value12
	if attid2  and tonumber(attid2[1]) > 0 then
		if  #attid2 > 1 then
			attrName2 = GlobalApi:getLocalStr('PROFESSION_NAME3')
		else
			attrName2 = attconf[tonumber(attid2[1])].name
		end
		attrValue2 = tostring(attv2)
	end

	local str = attrName1 .. GlobalApi:getLocalStr('STR_TIGAO')

	local rt = xx.RichText:create()
	local rtl1 = xx.RichTextLabel:create(
		GlobalApi:getLocalStr('FATE_SHOW_ACTIVE'),
		25,
		COLOR_TYPE.ORANGE)
	rtl1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rt:addElement(rtl1)

	local rtl2 = xx.RichTextLabel:create(
		str,
		25,
		COLOR_TYPE.ORANGE)
	rtl2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	rtl2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rt:addElement(rtl2)

	local rtl3 = xx.RichTextLabel:create(
		attrValue1 .. '%',
		25,
		COLOR_TYPE.GREEN)
	rtl3:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
	rtl3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rt:addElement(rtl3)

	if attrName2 ~= nil and attrValue2 ~= nil then
		local rtl4 = xx.RichTextLabel:create(
			'，' .. attrName2,
			25,
			COLOR_TYPE.ORANGE)
		rtl4:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		rtl4:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		rt:addElement(rtl4)

		local rtl5 = xx.RichTextLabel:create(
			attrValue2 .. '%',
			25,
			COLOR_TYPE.GREEN)
		rtl5:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		rtl5:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		rt:addElement(rtl5)
	end

	rt:setAlignment('middle')
	rt:setVerticalAlignment('middle')
	rt:setPosition(cc.p(457, 55))
	rt:format(true)
	rt:setContentSize(rt:getElementsSize())
	bg1:addChild(rt)
end

function FateShowUI:_genDefaultItem()
	return cc.CSLoader:createNode('csb/fatecard.csb'):getChildByName('card')
end

function FateShowUI:adaptUI(bg, bg1, press)
	local winSize = cc.Director:getInstance():getWinSize()
	bg:setContentSize(winSize)
	bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
	bg1:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
	press:setPosition(cc.p(winSize.width / 2, 60))
end

return FateShowUI
