local fate = {
	spread = false,
	bpressedbtn = false
}

local fullRect = cc.size(453, 250)
local collapseRect = cc.size(453, 250 - 150)

function fate.new()
	local ret = {}
	ret.spred = false
	ret.bpressedbtn = false
	setmetatable(ret, {__index = fate})
	return ret
end

function fate:genFateStayNight(role, idx, update,richTextWidth,showStatus)
	local fateatt =	role:getFateArr()
	if #fateatt <= 0 or fateatt[idx] == nil then
		return nil
	end

	local heroconf = GameData:getConfData('hero')

	local panel = cc.CSLoader:createNode("csb/rolefatecell.csb")
	panel:setName('panel' .. idx)
	panel:setPosition(cc.p(0, -150))
	local layout = ccui.Layout:create()
	layout:setName('layout')
	layout:setTouchEnabled(true)
	layout:setSwallowTouches(false)
	layout:addChild(panel)

	local newicon = ccui.ImageView:create('uires/ui/common/new_img.png')
		:setAnchorPoint(cc.p(1, 1))
		:setPosition(cc.p(94, 94))
		:setVisible(false)
	panel:getChildByName('role_frame')

	panel:getChildByName('role_icon')
		:loadTexture('uires/ui/role/role_'..idx..'_img.png')
		:addChild(newicon, 99)

	panel:getChildByName('collapse')
		:setVisible(false)

	local rt = xx.RichText:create()
	rt:setName('rt')
	rt:setAnchorPoint(cc.p(0, 1))
    local realRichTextWidth = richTextWidth or 320
	rt:setContentSize(cc.size(realRichTextWidth, 94))
	rt:setPosition(cc.p(113, 245))

	local title_font_size = 23
	local title = '【' .. fateatt[idx].fname  .. '】\n'
	local re1 = xx.RichTextLabel:create(
		title, 
		title_font_size, 
		cc.c4b(254, 165, 0, 255))
	re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	rt:addElement(re1)

	local discription_font_size = 18

	local re2 = xx.RichTextLabel:create(
		GlobalApi:getLocalStr('STR_YU'), 
		discription_font_size, 
		cc.c4b(36, 255, 0, 255))
	re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	rt:addElement(re2)

	local reDun = xx.RichTextLabel:create(
		'、', 
		discription_font_size, 
		cc.c4b(36, 255, 0, 255))
	reDun:setStroke(cc.c4b(0, 0, 0, 255), 1)
	reDun:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	-- reDun:retain()

	for i = 1, 4 do
		panel:getChildByName('role' .. i)
			:setVisible(false)
	end

	local active = true
	for i, v in ipairs(fateatt[idx].roleStatus) do
		local ref = xx.RichTextLabel:create(
			heroconf[v.hid].heroName, 
			discription_font_size, 
			cc.c4b(36, 255, 0, 255))
		ref:setStroke(cc.c4b(0, 0, 0, 255), 1)
		ref:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		-- 下面的四个小人
		local tempRole = RoleData:getRoleInfoById(v.hid)

		local rolebg = panel:getChildByName('role' .. i)
		rolebg:setVisible(true)
		rolebg:setTouchEnabled(true)
		rolebg:setSwallowTouches(false)
		rolebg:loadTexture(tempRole:getBigIcon())

		if panel:getPositionY() >= 0 then
			rolebg:setVisible(true)
			-- rolebg:setTouchEnabled(true)
		else
			rolebg:setVisible(false)
			-- rolebg:setTouchEnabled(false)
		end

		local roleName = rolebg:getChildByName('name')
			:setString(tempRole:getName())
			:setTextColor(tempRole:getNameColor())
			:enableOutline(tempRole:getNameOutlineColor(), 1)
			:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

		local btn = rolebg:getChildByName('btn')
		btn:setSwallowTouches(false)
		local tx = btn:getChildByName('tx')
		local already_bg = rolebg:getChildByName('already_bg')
		local already_tx = rolebg:getChildByName('already_tx')

		-- 这儿的逻辑很混乱 读代码的小兄弟 注意了。。。
		local zhenren = RoleData:getRoleById(v.hid)
		local card = BagData:getCardById(v.hid)
		if role:isAsssist(fateatt[idx].fid, v.hid) then
			btn:setVisible(true)
			already_bg:setVisible(false)
			already_tx:setVisible(false)

			btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			tx:setString(GlobalApi:getLocalStr('FATE_TAKEOUT'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
		elseif zhenren == nil and card == nil then
			btn:setVisible(true)
			already_bg:setVisible(false)
			already_tx:setVisible(false)

			btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			ShaderMgr:setGrayForWidget(rolebg)
			tx:setString(GlobalApi:getLocalStr('FATE_GET'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
			btn:addClickEventListener(function ()
				-- open the view ui
				GetWayMgr:showGetwayUI(tempRole, true)
			end)
		elseif zhenren ~= nil then
			btn:setVisible(false)
			already_bg:setVisible(true)
			already_tx:setVisible(true)
			already_tx:setString(GlobalApi:getLocalStr('FATE_ALREADY'))
				:setColor(COLOR_TYPE.PALE)
				:enableOutline(COLOROUTLINE_TYPE.PALE)
				:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

			btn:loadTextureNormal('uires/ui/common/common_btn_6.png')
			tx:setString(GlobalApi:getLocalStr('FATE_ALREADY'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE2)
			btn:setEnabled(false)
		elseif zhenren == nil and card ~= nil then
			btn:setVisible(true)
			already_bg:setVisible(false)
			already_tx:setVisible(false)

			--newicon:setVisible(true)
			btn:loadTextureNormal('uires/ui/common/common_btn_3.png')
			tx:setString(GlobalApi:getLocalStr('FATE_ASSIST'))
				:enableOutline(COLOROUTLINE_TYPE.WHITE1)
		end
		if v.active == false then
			active = false
			ref:setColor(cc.c4b(163, 163, 163, 255))
		end
		rt:addElement(ref)
		rt:addElement(reDun)
		-- reDun:release()

        -- by cl add
        if showStatus then
            ref:setColor(cc.c4b(163, 163, 163, 255))
        end
	end
	rt:popElement()

	local str = GlobalApi:getLocalStr('STR_GONGTONGSHANGZHENG')
	str = str .. fateatt[idx].effect1
	str = str .. GlobalApi:getLocalStr('STR_TIGAO')
	str = str .. fateatt[idx].effvalue1 .. '%'
	if fateatt[idx].effect2 then
		str = str ..'、' .. fateatt[idx].effect2
		str = str .. GlobalApi:getLocalStr('STR_TIGAO')
		str = str .. fateatt[idx].effvalue2 .. '%'
	end

	local re3 = xx.RichTextLabel:create(str, discription_font_size, cc.c4b(36, 255, 0, 255))
	re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	rt:addElement(re3)

	if active == false then
		re1:setColor(cc.c4b(163, 163, 163, 255))
		re2:setColor(cc.c4b(163, 163, 163, 255))
		re3:setColor(cc.c4b(163, 163, 163, 255))
		reDun:setColor(cc.c4b(163, 163, 163, 255))
	end
	panel:addChild(rt)

	self:setRolesVisible(layout, panel, fateatt[idx].roleStatus)

    -- by cl add
    if showStatus then
        re1:setColor(cc.c4b(163, 163, 163, 255))
		re2:setColor(cc.c4b(163, 163, 163, 255))
		re3:setColor(cc.c4b(163, 163, 163, 255))
		reDun:setColor(cc.c4b(163, 163, 163, 255))
    end

	return layout
end

function fate:setRolesVisible(layout, panel, array)
	if self.spread == false then
		layout:setContentSize(collapseRect)
		panel:setPosition(cc.p(0, -150))
		for i, v in ipairs(array) do
			panel:getChildByName('role' .. i)
				:setVisible(false)
		end
	else
		layout:setContentSize(fullRect)
		panel:setPosition(cc.p(0, 0))
		for i, v in ipairs(array) do
			panel:getChildByName('role' .. i)
				:setVisible(true)
		end
	end
end

function fate:getRoleNameElement(rt, index)
	local i = 2 + (index - 1) * 2
	return rt:getElement(i)
end

return fate
