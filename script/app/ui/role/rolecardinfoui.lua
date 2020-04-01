local RoleCardInfoSv = require("script/app/ui/role/rolecardinfosv")
local RoleCardInfoUI = class("RoleCardInfoUI", BaseUI)

function RoleCardInfoUI:ctor(obj,ischip, index)
	self.uiIndex = GAME_UI.UI_ROLECARDINFO
	self.obj = RoleData:getRoleInfoById(obj:getId())
	self.cardobj = obj
	self.anim_pl = nil
	self.actionisruning = false
	self.action = ""
	self.sv = nil
	self.ischip = ischip
	self.dirty = false
	self.isshow = index or 2
end

local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

function RoleCardInfoUI:setDirty(onlychild)
	self.dirty = true
end

function RoleCardInfoUI:swapanimation(spineAni)
	-- local seed = math.random(1, 5)
	-- if self.action ~= roleanim[seed] then
	-- 	self.action = roleanim[seed]
	-- 	spineAni:getAnimation():play(roleanim[seed], -1, -1)
	-- end
end

function RoleCardInfoUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	-- bgimg:addTouchEventListener(function (sender, eventType)
	-- 	if eventType == ccui.TouchEventType.began then
	-- 		AudioMgr.PlayAudio(11)
	-- 	end
	-- 	if eventType == ccui.TouchEventType.ended then
	-- 		RoleMgr:hideRoleCardInfo()
	-- 	end
	-- end)
	local bgimg2 = bgimg:getChildByName('bg_img2')
	local bgimg1 = bgimg2:getChildByName('bg_img3')
	self:adaptUI(bgimg, bgimg2)
	local closebtn = bgimg1:getChildByName("close_btn")
	closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleCardInfo()
		end
	end)
	local roleobj = self.obj
	if roleobj == nil then
		return
	end

	local bg1 = bgimg1:getChildByName('bg_img_5')
	bg1:setLocalZOrder(99)
	local bg2 = bg1:getChildByName('role_bg')
	self.anim_pl = bg2:getChildByName('anm_pl')
	self.anim_pl:removeChildByTag(9527)
	local spineAni = GlobalApi:createLittleLossyAniByName(self.obj:getUrl() .. "_display")
	local heroconf = GameData:getConfData('hero')[self.obj:getId()]
	if spineAni then
	--  spineAni:setScale(0.6)
		local shadow = spineAni:getBone(self.obj:getUrl() .. "_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
		end
		local effectIndex = 1
		repeat
			local aniEffect = spineAni:getBone(self.obj:getUrl() .. "_effect" .. effectIndex)
			if aniEffect == nil then
				break
			end
			aniEffect:changeDisplayWithIndex(-1, true)
			aniEffect:setIgnoreMovementBoneData(true)
			effectIndex = effectIndex + 1
		until false
		spineAni:setPosition(cc.p(self.anim_pl:getContentSize().width/2,20+heroconf.uiOffsetY))
		spineAni:setLocalZOrder(999)
		spineAni:setTag(9527)
		self.anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		local beginPoint = cc.p(0,0)
		local endPoint = cc.p(0,0)
		self.anim_pl:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				beginPoint = sender:getTouchBeganPosition()
			end

			if eventType ==  ccui.TouchEventType.ended then
				endPoint= sender:getTouchEndPosition()
				local deltax = (beginPoint.x -endPoint.x)
				local deltay = math.abs(beginPoint.y -endPoint.y)
				if deltax > 25  then
					self:changePos(self.obj:getPosId(),true)
				elseif deltax <= -25 then 
					self:changePos(self.obj:getPosId(),false)
				else
					if self.actionisruning  ~= true then
						self.actionisruning = true
						self:swapanimation(spineAni)
					end
				end
			end 

		end) 

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				self.actionisruning =false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				self.actionisruning =false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end

	local namebg = bg1:getChildByName('type_img')
	local nametx = namebg:getChildByName('name_tx')
	nametx:setString(roleobj:getName())
	nametx:setTextColor(roleobj:getNameColor())
	nametx:enableOutline(roleobj:getNameOutlineColor(),2)
	local typeimg = namebg:getChildByName('type_img')
	typeimg:loadTexture('uires/ui/common/soldier_'..roleobj:getSoldierId()..'.png')
	typeimg:ignoreContentAdaptWithSize(true)
	local panel = RoleCardInfoSv.new(self.obj)
	panel:update(self.obj)
	panel:setPosition(cc.p(694,274))
	panel:getPanel():setLocalZOrder(1)
	closebtn:setLocalZOrder(2)
	bgimg1:addChild(panel:getPanel())
	self.anim_pl:setLocalZOrder(9999)
	local beassistpanel = bg1:getChildByName('beassist_panel')
	local chippanel = bg1:getChildByName('chip_panel')
	if self.ischip then 
		chippanel:setVisible(true)
		beassistpanel:setVisible(false)
		local num =self.cardobj:getOwnNum()
		local mergenum = self.cardobj:getMergeNum()
		local probgimg = chippanel:getChildByName('probg_img')
		local probar = probgimg:getChildByName('pro_bar')
		probar:setPercent((num/mergenum)*100)
		local probarxp =probar:getChildByName('bar_tx')
		probarxp:setString(num ..'/' .. mergenum)
		local funcbtn = chippanel:getChildByName('func_btn')
		local tx =funcbtn:getChildByName('func_tx')
		funcbtn:setTouchEnabled(true)
		if num >= mergenum then
			self.iscanmerge = true
			funcbtn:loadTextureNormal('uires/ui/common/common_btn_7.png')
			-- img:loadTexture('uires/ui/text/icon_hecheng.png')
			tx:setString(GlobalApi:getLocalStr("STR_MERGE"))
			tx:setTextColor(COLOR_TYPE.WHITE)
			tx:enableOutline(COLOROUTLINE_TYPE.WHITE2, 1)
			tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		else
			funcbtn:loadTextureNormal('uires/ui/common/common_btn_5.png')
			-- funcbtn:loadTexturePressed('uires/ui/common/btn_sel_1.png')
			-- img:loadTexture('uires/ui/text/btn_icon_huoqu.png')
			tx:setString(GlobalApi:getLocalStr("STR_HUOQU"))
			tx:setTextColor(COLOR_TYPE.WHITE)
			tx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
			tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		end
		funcbtn:addClickEventListener(function (sender, eventType)
			if self.iscanmerge then
				local args = {
					id = self.obj:getId(),
					num = self.cardobj:getMergeNum()
				}
				MessageMgr:sendPost("use", "bag", json.encode(args), function (jsonObj)
					print(json.encode(jsonObj))
					local code = jsonObj.code
					if code == 0 then
						local awards = jsonObj.data.awards
						GlobalApi:parseAwardData(awards)
						TavernMgr:showTavernAnimate(awards, function (  )
							local costs = jsonObj.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							if self.obj:getNum() > 0 then
								self:setType()
							else
								
							end
							RoleMgr:updateRoleList()
							self.iscanmerge = false
							funcbtn:setTouchEnabled(false)                        
							self:init()
							promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_SUCC'), COLOR_TYPE.GREEN)
						end, 4)
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_FAIL'), COLOR_TYPE.RED)
					end
				end)
			else
--                GetWayMgr:showRoleGetWay(self.cardobj)
				GetWayMgr:showGetwayUI(self.cardobj,true)
			end
		end)
	else
		chippanel:setVisible(false)
		beassistpanel:setVisible(true)
		local funcbtn = beassistpanel:getChildByName('func_btn')
		funcbtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        end
	        if eventType == ccui.TouchEventType.ended then
				local function callback()
					if self.cardobj:getOwnNum() > 0 then
						local args = {
							cid = self.cardobj:getId(),
							num = 1
						}
						MessageMgr:sendPost("resolve_card", "hero", json.encode(args), function (jsonObj)
							print(json.encode(jsonObj))
							local code = jsonObj.code
							if code == 0 then
								local awards = jsonObj.data.awards
								GlobalApi:parseAwardData(awards)
								local costs = jsonObj.data.costs
								if costs then
									GlobalApi:parseAwardData(costs)
								end
								local disaward = DisplayData:getDisplayObj(awards[1])
								local str = string.format(GlobalApi:getLocalStr('STR_RESOLVE_ONES'),self.obj:getName(),tonumber(disaward:getNum()))
								promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
								self:init()
								RoleMgr:updateRoleList()
							end
						end)
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC5'), COLOR_TYPE.RED)
					end
				end
				--分解武将
			    if self.cardobj:getQuality() >= 5 then
	                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ROLE_DESC9")), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
	                    callback()
	                end)
	            else
	                callback()
	            end
			end
		end)
		local tx = funcbtn:getChildByName('func_tx')
		tx:setString(GlobalApi:getLocalStr("STR_RESOLVE"))
		local desctx = beassistpanel:getChildByName('desc_tx')
		desctx:setString(GlobalApi:getLocalStr('STR_ZHANG'))
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(335, 30))
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("STR_RESOLVE_ONE"), 26, COLOR_TYPE.WHITE)
		re1:setStroke(COLOR_TYPE.BLACK, 1)
		-- re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re2 = xx.RichTextLabel:create(self.cardobj:getSoulNum(), 26, COLOR_TYPE.WHITE)
		re2:setStroke(COLOR_TYPE.BLACK, 1)
		-- re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re3 = xx.RichTextImage:create('uires/ui/res/res_soul.png')
		re3:setScale(0.8)
		richText:addElement(re1)
		richText:addElement(re3)
		richText:addElement(re2)

		richText:setLocalZOrder(2)
		richText:setPosition(cc.p(173, 53))
		richText:setTag(9527)
		beassistpanel:removeChildByTag(9527)
		beassistpanel:addChild(richText)

		local numtx = beassistpanel:getChildByName('num_tx')
		numtx:setString(self.cardobj:getNum())
	end
	
	if self.isshow == 1 then
		beassistpanel:setVisible(false)
	elseif self.isshow == 3 then
		beassistpanel:setVisible(false)
		chippanel:setVisible(false)
	end
end

return RoleCardInfoUI