local AutoFusionUI = class("AutoFusionUI", BaseUI)

local COLOR_QUALITY = {
	[1] = 'WHITE',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED',
}
-- local COLOR_QUALITY = {
-- 	[1] = COLOR_TYPE.WHITE,
-- 	[2] = COLOR_TYPE.GREEN,
-- 	[3] = COLOR_TYPE.BLUE,
-- 	[4] = COLOR_TYPE.PURPLE,
-- 	[5] = COLOR_TYPE.ORANGE,
-- 	[6] = COLOR_TYPE.RED,
-- }

function AutoFusionUI:ctor()
	self.uiIndex = GAME_UI.UI_ROLE_RESOLVE
end

function AutoFusionUI:updatePanel()
	local equips = {{},{},{},{},{}}
	for i=1,6 do
		local tab = BagData:getEquipMapByType(i)
		if tab then
			for k,v in pairs(tab) do
				-- print(k,v:getQuality())
				if v:getGodId() == 0 and not v:isAncient() then
					equips[tonumber(v:getQuality())][#equips[tonumber(v:getQuality())] + 1] = tonumber(k)
				end
			end
		end
	end
	for i,v in ipairs(self.imgs) do
		v.nameTx:setString(GlobalApi:getLocalStr('COLOR_EQUIP_'..i)..' X '..#equips[i])
		v.nameTx:enableOutline(COLOROUTLINE_TYPE['ORANGE'],2)
		v.nameTx:setColor(COLOR_TYPE[COLOR_QUALITY[i]])
		if #equips[i] > 0 then
			v.funcbtn:setVisible(true)
		else
			v.funcbtn:setVisible(false)
		end
	end
end

function AutoFusionUI:createCells()
	self.imgs = {}
	for i=1,5 do
		local cellNode = cc.CSLoader:createNode("csb/autofusioncell.csb")
		local bgimg = cellNode:getChildByName("bg_img")
		bgimg:removeFromParent(false)
		local cell = ccui.Widget:create()
		cell:addChild(bgimg)
		local funcbtn = bgimg:getChildByName('func_btn')
		funcbtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	local args = {
		        	quality = i
		        }
			  	MessageMgr:sendPost('smelt_all','equip',json.encode(args),function (response)
					
					local code = response.code
					local data = response.data
					local showWidgets = {}
					if code == 0 then
						local awards = data.awards
						local update = data.update
						local smelt = UserData:getUserObj():getSmelt()
						-- UserData:getUserObj():setSmelt(smelt or 0)
						local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
						GlobalApi:parseAwardData(awards)
						-- print(update)
						-- for i,v in pairs(update) do
						-- 	print(i,v)
						-- 	local eid = v.eid
						-- 	local godId = v.god_id
						-- 	local god = v.god
						-- 	local equip = BagData:getEquipMapById(eid)
						-- 	equip:setGod(god,godId)
						-- end
						for i,v in pairs(update) do
							local eid = v.eid
							local godId = v.god_id
							local god = v.god
							local equip = BagData:getEquipMapById(eid)
							equip:setGod(god,godId)
							local quality = equip:getQuality()
							local name = GlobalApi:getLocalStr('ACCIDENT_GET')..'Lv.'..equip:getLevel()..'  '..equip:getName()
							local color = (godId>0 and COLOR_QUALITY[6]) or COLOR_QUALITY[quality]
							local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
							w:setTextColor(COLOR_TYPE[color])
							w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
							w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
							-- local tab = {name,color}
							-- showTab[#showTab + 1] = tab
							table.insert(showWidgets, w)
						end
						self:updatePanel()
						for i,v in pairs(awards) do
							local eid = v[2]
							local equip = BagData:getEquipMapById(eid)
							if equip then
								local quality = equip:getQuality()
								local name = GlobalApi:getLocalStr('ACCIDENT_GET')..'Lv.'..equip:getLevel()..'  '..equip:getName()
								local color = COLOR_QUALITY[quality]
								local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
								w:setTextColor(COLOR_TYPE[color])
								w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
								w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
								table.insert(showWidgets, w)
								-- local tab = {name,color}
								-- showTab[#showTab + 1] = tab
							end
						end
						local diffSmelt = UserData:getUserObj():getSmelt() - smelt
						-- UserData:getUserObj():setSmelt(smelt or 0)
						local name = GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..diffSmelt..GlobalApi:getLocalStr('FUSION_NUM1')
						local color = COLOR_TYPE.GREEN
						local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
						w:setTextColor(color)
						w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
						w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
						table.insert(showWidgets, w)
						-- showTab[#showTab + 1] = {GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..diffSmelt..GlobalApi:getLocalStr('FUSION_NUM1'),'GREEN'}
						local sz = self.bgimg2:getContentSize()
						local winSize = cc.Director:getInstance():getVisibleSize()
						promptmgr:showAttributeUpdate(showWidgets)
						-- promptmgr:showAttributeUpdate(winSize.width/2,winSize.height/3, showTab)
						-- GlobalApi:showpop(winSize.width/2,winSize.height/3, showTab)

						self:updatePanel()
					end
				end)
	        end
	    end)
		local functx = funcbtn:getChildByName('func_tx')
		functx:setString(GlobalApi:getLocalStr('FUSION'))
		local nameTx = bgimg:getChildByName('name_tx')

		local contentsize = bgimg:getContentSize()
		self.cellTotalHeight = self.cellTotalHeight + contentsize.height + 5*((i == 1 and 0) or 1)
		cell:setPosition(cc.p(0, contentsize.height*0.5 - self.cellTotalHeight))
		self.contentWidget:addChild(cell)
		self.imgs[i] = {nameTx = nameTx,funcbtn = funcbtn}
	end
	local posY = self.sv:getContentSize().height
	if self.cellTotalHeight > posY then
		posY = self.cellTotalHeight
	end
	self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width, posY))
	self.contentWidget:setPosition(cc.p(self.sv:getContentSize().width*0.5, posY))
end

function AutoFusionUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 =bgimg:getChildByName('bg_img_1')
	self.bgimg2 =bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg, bgimg1)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bgimg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
	local titleimg  = bgimg1:getChildByName('type_img')
	self.sv = self.bgimg2:getChildByName('info_sv')
	self.sv:setInertiaScrollEnabled(true)
	self.sv:setBounceEnabled(false)
	self.sv:setScrollBarEnabled(false)
	self.sv:setInnerContainerSize(self.sv:getContentSize())
	self.cellTotalHeight = 0
	self.contentWidget = ccui.Widget:create()
	self.sv:addChild(self.contentWidget)

    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BagMgr:hideAutoFusion()
        end
    end)

    local titleTx = bgimg1:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('FAST_FUSION_EQUIP'))

	self:createCells()
    self:updatePanel()
end

return AutoFusionUI