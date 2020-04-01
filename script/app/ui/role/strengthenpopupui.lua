local StrengthenPopupUI = class("StrengthenPopupUI", BaseUI)
function StrengthenPopupUI:ctor(role, type, fromAttr, toAttr, func, obj, targetlv)
	self.uiIndex = GAME_UI.UI_STRENGHENPOPUPUI
	self.role = role
	self.dragonObj = obj
	self.fromAttr = fromAttr
	self.toAttr = toAttr
	self.func = func
	self.type = type
	self.targetlv = targetlv or 1
end

function StrengthenPopupUI:init()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local bgimg1 = self.root:getChildByName('background')
	self.bgimg1 = bgimg1
	self.bgimg1:setVisible(false)
	local bgimg = bgimg1:getChildByName('alphaBg')

	bgimg:setCascadeColorEnabled(false)
	self.bgimg = bgimg
	self:adaptUI(bgimg1, bgimg)
	self.attrFrame = bgimg1:getChildByName('attr_bg')
	self.attrFrame:setCascadeOpacityEnabled(false)
	self.attrFrame:setOpacity(0)
	self.attrFrame:setPosition(cc.p(winSize.width/2,winSize.height/2))

	self.pressText = self.attrFrame:getChildByName('press')
	self.pressText:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
	self.spine_frame = bgimg:getChildByName('spine')
	self.spine_frame:setLocalZOrder(8999)

	if self.role then
		local quality = self.role:getQuality()
		self.bgImg = ccui.ImageView:create(COLOR_CARDBG[quality - 1])
		local strLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
	    strLabel:setTextColor(COLOR_TYPE.OFFWHITE)
	    strLabel:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	    strLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
	    strLabel:setString(GlobalApi:getLocalStr("JADESEAL_DESC5"))
	    strLabel:setPosition(cc.p(72.16, 34.92))
	    local soldierimg = ccui.ImageView:create('uires/ui/common/'..'soldier_'..self.role:getSoldierId()..'.png')
	    soldierimg:setPosition(cc.p(125.50, 196.50))
	    soldierimg:setScale(0.8)
	    local spine_frame_size = self.spine_frame:getContentSize()
	    self.bgImg:setPosition(cc.p(spine_frame_size.width/2,spine_frame_size.height/2))
	    self.bgImg:addChild(strLabel)
	    self.bgImg:addChild(soldierimg)
	    self.spine_frame:addChild(self.bgImg,-1)
	    self.bgImg:setVisible(false)
		self.spine_frameX, self.spine_frameY = self.spine_frame:getPosition()
		self.spine_frameX = self.spine_frameX + spine_frame_size.width / 2
		self.spine_frameY = self.spine_frameY + spine_frame_size.height / 2
	end
    self.flagPl = bgimg:getChildByName('flag_pl')
    self.layout = bgimg:getChildByName('pl')
    
    self.layout:setLocalZOrder(9)
    self.flagPl:setVisible(false)
    self.layout:setVisible(false)

	local title = self.attrFrame:getChildByName('strength_suc')
	if self.type == 'upgrade_talent' then
		title:loadTexture('uires/ui/text/strength_suc.png')
	elseif self.type == 'upgrade_destiny' then
		title:loadTexture('uires/ui/text/tianming_suc.png')
	elseif self.type == 'upgrade_soldier' then
		title:loadTexture('uires/ui/text/jinjie_suc.png')
	elseif self.type == 'upgrade_junzhu' then
		title:loadTexture('uires/ui/text/pztx_suc.png')
		self.bgImg:setVisible(true)
	elseif self.type == 'upgrade_risestar' or self.type == 'upgrade_dragon' then
		title:loadTexture('uires/ui/text/jinjie_suc.png')
		self.ani = GlobalApi:createSpineByName("wujiangshengpin", "spine/wujiangshengpin/wujiangshengpin", 1)
		self.ani:setScale(2)
		self.ani:setPosition(cc.p(winSize.width/2, winSize.height/2))
		self.bgimg:addChild(self.ani)
		self.ani:setVisible(false)
	-- elseif self.type == 'upgrade_dragon' then
	-- 	title:loadTexture('uires/ui/text/pztx_suc.png')
	-- 	self.bgImg:setVisible(true)
	elseif self.type == 'upgrade_peopleking_weapon' or self.type == 'upgrade_peopleking_wing' then
		title:loadTexture('uires/ui/text/jinjie_suc.png')
	end

	self.idx = {
		[1] = 'from',
		[2] = 'to'
	}
	self.attrTable = {}
	self.flagImgs = {}
	for k,v in ipairs(self.idx) do
		self.attrTable[v] = {}
		local frame = self.attrFrame:getChildByName(v)
		for i = 1, 4 do
			self.attrTable[v][i] = frame:getChildByName('att' .. i .. 'bg')
		end
		self.flagImgs[v] = frame:getChildByName('flag_img')
	end

	bgimg:setTouchEnabled(true)

	-- start
	if self.type == 'upgrade_risestar' or self.type == 'upgrade_dragon' then
		self:playVideo()
	else
		self.bgimg1:setVisible(true)
		self:setStage(1)
	end
end

function StrengthenPopupUI:playVideo()
    local targetPlatform = CCApplication:getInstance():getTargetPlatform()
	if targetPlatform == kTargetAndroid or targetPlatform == kTargetIphone or targetPlatform == kTargetIpad then
	    local winSize = cc.Director:getInstance():getVisibleSize()
	    local videoPlayer = ccexp.VideoPlayer:create()
	    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
	    videoPlayer:setContentSize(cc.size(winSize.width,winSize.height))
	    self.root:addChild(videoPlayer)
	        
	    videoPlayer:setPosition(cc.p(winSize.width / 2,winSize.height / 2))
	    local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename("rise_star.mp4")
	    videoPlayer:setFileName(videoFullPath)
	    videoPlayer:play()
	    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.23),cc.CallFunc:create(function()
	    	AudioMgr.playEffect("media/effect/rise_star.mp3", false)
	    end)))
	    self.bgimg1:setVisible(true)

	    local function onVideoCompleted()
	    	self:removeCustomEventListener(CUSTOM_EVENT.ENTER_BACKGROUND)
	    	self:removeCustomEventListener(CUSTOM_EVENT.ENTER_FOREGROUND)
			videoPlayer:setVisible(false)
			self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
				videoPlayer:removeFromParent()
			end)))
			self:playAction()
	    end

	    videoPlayer:addEventListener(function (sener, eventType)
	    	if eventType == ccexp.VideoPlayerEvent.COMPLETED then
				onVideoCompleted()
			end
	    end)
		self:addCustomEventListener(CUSTOM_EVENT.ENTER_BACKGROUND, function ()
			videoPlayer:stop()
		end)
		self:addCustomEventListener(CUSTOM_EVENT.ENTER_FOREGROUND, function ()
			onVideoCompleted()
		end)
	else
	    self.bgimg1:setVisible(true)
	    self:playAction()
	end
end
function StrengthenPopupUI:playAction()
	if self.type == 'upgrade_risestar' then
		self:playUpgradeStarAction()
	elseif self.type == 'upgrade_dragon' then
		self:playDragonAction()
	end
end

function StrengthenPopupUI:initDragonFrame()
	local spineAni = GlobalApi:createLittleLossyAniByName(self.dragonObj:getUrl(), nil, self.dragonObj:getChangeEquipState())
	if spineAni then
		local ap = spineAni:getAnchorPoint()
		local size = self.spine_frame:getContentSize()
		spineAni:setPosition(cc.p(size.width/2, size.height/3))
		spineAni:setLocalZOrder(999)
		spineAni:setTag(69)
		self.spine_frame:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
	end
	return spineAni
end

function StrengthenPopupUI:playDragonAction()
	local winSize = self.bgimg:getContentSize()
	local spineAni = self:initDragonFrame()
	self.ani:setVisible(true)
	self.ani:setPosition(cc.p(winSize.width/2, winSize.height/2))
	self.ani:setAnimation(0, 'animation', false)

	
	self.spine_frame:setVisible(true)
	self.attrFrame:setVisible(false)
	local spine_frame_size = self.spine_frame:getContentSize()
	self.spine_frame:setAnchorPoint(cc.p(0.5, 0.5))
	self.spine_frame:setPosition(cc.p((winSize.width) / 2, (winSize.height) / 2))
	self.spine_frame:setLocalZOrder(1)
	self.attrFrame:setLocalZOrder(1)

	local delayTime = 0.6
	local shake1 = 0.2
	local shake1delay = 0.2
	local fadeInTime = 0.3
	self.layout:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime + 0.3),cc.CallFunc:create(function()
		self.layout:setVisible(true)
        self.layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.3)))
        self.layout:runAction(cc.ScaleTo:create(0.28,1.3))
	end)))

	self.spine_frame:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
		local customObj = {
            advanced = self.dragonObj:getLevel() + 1
        }
		local changeEquipObj = self.dragonObj:getChangeEquipState(customObj)
		GlobalApi:changeModelEquip(spineAni,self.dragonObj:getUrl(),changeEquipObj,2)
		self.bgimg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
	        if eventType == ccui.TouchEventType.ended then
	        	RoleMgr:hideStengthenPopupUI()
	        	if self.func then
	        		self.func()
	        		self.func = nil
	        	end
	        end
  	  	end)
	end),cc.DelayTime:create(fadeInTime + 2),cc.CallFunc:create(function()
    	RoleMgr:hideStengthenPopupUI()
    	if self.func then
    		self.func()
    		self.func = nil
    	end
	end)
	))
end

function StrengthenPopupUI:playUpgradeStarAction()
	self.flagPl:setVisible(true)
	local winSize = self.bgimg:getContentSize()
	self.ani:setVisible(true)
	self.ani:setAnimation(0, 'animation', false)

	self:initVisibleFrame()
	self.spine_frame:setVisible(true)
	self.attrFrame:setVisible(false)
	local spine_frame_size = self.spine_frame:getContentSize()
	self.spine_frame:setAnchorPoint(cc.p(0.5, 0.5))
	self.spine_frame:setPosition(cc.p((winSize.width) / 2, (winSize.height) / 2))
	self.spine_frame:setLocalZOrder(1)
	self.attrFrame:setLocalZOrder(1)
	self.spine_frame:setOpacity(0)
	self.flagPl:setLocalZOrder(2)
	self.flagPl:setPosition(cc.p(winSize.width/2, winSize.height/2 + 150))
	self.layout:setPosition(cc.p(winSize.width/2,winSize.height/2))

	local flagImg = self.flagPl:getChildByName('flag_img')
	local flagOldImg = self.flagPl:getChildByName('flag_old_img')
	local nameTx = self.flagPl:getChildByName('name_tx')
	local starImg1 = self.flagPl:getChildByName('star_img_1')
	local starImg2 = self.flagPl:getChildByName('star_img_2')
	local starImg3 = self.flagPl:getChildByName('star_img_3')
	local quality = self.role:getHeroQuality()
	local starImgs = {starImg1,starImg2,starImg3}
	local conf = GameData:getConfData('heroquality')[quality + self.targetlv]
	local conf1 = GameData:getConfData('heroquality')[quality]
	local delayTime = 0.6
	local shake1 = 0.2
	local shake1delay = 0.2
	local fadeInTime = 0.3
	nameTx:setString(self.role:getName())
	nameTx:setColor(self.role:getNameColor())
	nameTx:enableOutline(self.role:getNameOutlineColor(),1)
	for i=1,3 do
		if i < conf.star then
			starImgs[i]:setVisible(true)
			starImgs[i]:setScale(0.8)
			starImgs[i]:setOpacity(255)
		elseif i == conf.star then
			starImgs[i]:setVisible(true)
			starImgs[i]:setScale(10)
			starImgs[i]:setOpacity(0)
			starImgs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime + 0.1),cc.ScaleTo:create(0.3,0.8)))
			starImgs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime + 0.1),cc.FadeIn:create(0.5)))
		else
			starImgs[i]:setVisible(false)
		end
	end
	flagImg:loadTexture('uires/ui/role/role_flag_'..conf.quality..'.png')
	if conf.quality ~= conf1.quality then
		flagOldImg:loadTexture('uires/ui/role/role_flag_'..conf1.quality..'.png')
		flagImg:setScale(10)
		flagImg:setOpacity(0)
		flagImg:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime),cc.ScaleTo:create(0.3,0.8)))
		flagImg:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime),cc.FadeIn:create(0.5),cc.CallFunc:create(function()
			flagOldImg:setVisible(false)
		end)))
	else
		flagOldImg:setVisible(false)
	end
	self.layout:runAction(cc.Sequence:create(cc.DelayTime:create(fadeInTime + 0.3),cc.CallFunc:create(function()
		self.layout:setVisible(true)
        self.layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.3)))
        self.layout:runAction(cc.ScaleTo:create(0.28,1.3))
	end)))
	if self.type == 'upgrade_junzhu' then
		delayTime = delayTime + shake1 + shake1delay * 2
	end
	self.flagPl:runAction(cc.Sequence:create(
		cc.DelayTime:create(delayTime + fadeInTime + 0.5),
		cc.MoveTo:create(0.5, cc.p(self.spine_frameX, self.spine_frameY + 150))))
	self.flagPl:runAction(cc.Sequence:create(
		cc.DelayTime:create(delayTime + fadeInTime + 0.5),
		cc.FadeOut:create(0.5)))

	self.spine_frame:runAction(cc.Sequence:create(
		cc.FadeIn:create(fadeInTime),
		cc.CallFunc:create(function ()
			if self.type == 'upgrade_junzhu' then
				self.spine_frame:runAction(cc.Sequence:create(
					GlobalApi:rotateShake(shake1, 2, 10, shake1delay),
					cc.CallFunc:create(function (  )
						local bgimg_size = self.bgImg:getContentSize()
						local mask = ccui.ImageView:create('uires/ui/tavern/tavern_mask_white.png')
						mask:setAnchorPoint(cc.p(0, 0))
						self.bgImg:addChild(mask)
						mask:runAction(cc.Sequence:create(cc.FadeOut:create(0.4), 
							cc.CallFunc:create(function ()
									mask:removeFromParent()
								end)))
						local quality = self.role:getQuality()
						self.bgImg:loadTexture(COLOR_CARDBG[quality])
					end)))
			end
		end),
		cc.DelayTime:create(delayTime),
		cc.CallFunc:create(function()
			AudioMgr.playEffect("media/effect/role_upgrade.mp3", false)
		end),
		cc.DelayTime:create(0.5),
		cc.MoveTo:create(0.5, cc.p(self.spine_frameX, self.spine_frameY)),
		cc.CallFunc:create(function ()
				self:setStage(2)
			end)))
end

function StrengthenPopupUI:setStage(stage)
	if stage == 1 then
		self:initVisibleFrame()
		self.spine_frame:setVisible(true)
		self.attrFrame:setVisible(false)
		local winSize = self.bgimg:getContentSize()
		local spine_frame_size = self.spine_frame:getContentSize()
		self.spine_frame:setAnchorPoint(cc.p(0.5, 0.5))
		self.spine_frame:setPosition(cc.p((winSize.width) / 2, (winSize.height) / 2))
		self.spine_frame:setOpacity(0)
		local delayTime = 0.6
		local shake1 = 0.2
		local shake1delay = 0.2
		local fadeInTime = 0.3
		if self.type == 'upgrade_junzhu' then
			delayTime = delayTime + shake1 + shake1delay * 2
		end
		-- play actoin 1
		self.spine_frame:runAction(cc.Sequence:create(
			cc.FadeIn:create(fadeInTime),
			cc.CallFunc:create(function ()
				if self.type == 'upgrade_junzhu' then
					self.spine_frame:runAction(cc.Sequence:create(
						GlobalApi:rotateShake(shake1, 2, 10, shake1delay),
						cc.CallFunc:create(function (  )
							local bgimg_size = self.bgImg:getContentSize()
							local mask = ccui.ImageView:create('uires/ui/tavern/tavern_mask_white.png')
							mask:setAnchorPoint(cc.p(0, 0))
							self.bgImg:addChild(mask)
							mask:runAction(cc.Sequence:create(cc.FadeOut:create(0.4), 
								cc.CallFunc:create(function ()
										mask:removeFromParent()
									end)))
							local quality = self.role:getQuality()
							self.bgImg:loadTexture(COLOR_CARDBG[quality])
						end)))
				end
			end),
			cc.DelayTime:create(delayTime),
			cc.CallFunc:create(function()
						local selectAni = GlobalApi:createLittleLossyAniByName("ui_tupo")
						selectAni:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
							if movementType == 1 then
								selectAni:removeFromParent()
							end
						end)
						AudioMgr.playEffect("media/effect/role_upgrade.mp3", false)
					    selectAni:getAnimation():play("Animation1", -1, 0)
					    local size = self.spine_frame:getContentSize()
					    selectAni:setPosition(cc.p(size.width / 2, size.height / 2))
					    selectAni:setScale(2.5)
				        self.spine_frame:addChild(selectAni,100000,10000)

				        local customObj = {}
					    if self.type == "upgrade_peopleking_weapon" then
					    	local peopleKingData = UserData:getUserObj():getPeopleKing()
					    	local surfaceId = self:getSurfaceId()
							surfaceId = surfaceId or peopleKingData.weapon_illusion
							customObj.weapon_illusion = tonumber(surfaceId)
					    elseif self.type == "upgrade_peopleking_wing" then
					    	local surfaceId = self:getSurfaceId()
					    	local peopleKingData = UserData:getUserObj():getPeopleKing()
							surfaceId = surfaceId or peopleKingData.wing_illusion
					        customObj.wing_illusion = tonumber(surfaceId)
					    end

				        local spineAni = GlobalApi:createLittleLossyAniByName(self.role:getUrl().."_display", nil, self.role:getChangeEquipState(customObj))--GlobalApi:createAniByName(self.role:getUrl())
						if spineAni then
							local ap = spineAni:getAnchorPoint()
							local size = self.spine_frame:getContentSize()
							spineAni:setPosition(cc.p(size.width / 2, size.height / 2))
							spineAni:setLocalZOrder(999)
							self.spine_frame:addChild(spineAni)
							spineAni:getAnimation():play('idle', -1, 1)
							spineAni:setAnchorPoint(cc.p(ap.x, 0.55))
							if self.type == 'upgrade_junzhu' then
								spineAni:setScale(0.7)
								spineAni:setPosition(cc.p(size.width / 2, size.height / 2+30))
							end
						end

						if self.type == 'upgrade_junzhu' then
							local sp = self.role:getCardIcon()
							self.bgImgtemp = ccui.ImageView:create(sp)
							local strLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
						    strLabel:setTextColor(COLOR_TYPE.OFFWHITE)
						    strLabel:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
						    strLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
						    strLabel:setString(GlobalApi:getLocalStr("JADESEAL_DESC5"))
						    strLabel:setPosition(cc.p(72.16, 34.92))
						    local soldierimg = ccui.ImageView:create('uires/ui/common/'..'soldier_'..self.role:getSoldierId()..'.png')
    						soldierimg:setPosition(cc.p(74,217.28))
    						self.bgImgtemp:addChild(soldierimg)
						    self.bgImgtemp:setPosition(cc.p(self.spine_frame:getContentSize().width/2,self.spine_frame:getContentSize().height/2))
						    self.bgImgtemp:addChild(strLabel)
						    self.spine_frame:addChild(self.bgImgtemp,997)
						   	self.bgImgtemp:runAction(cc.Sequence:create(
							-- cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3), cc.MoveBy:create(0.2, cc.p(0, -100 + offsetY * 3))),
							cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3)),
							--cc.Spawn:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(0.5, 3)),
							--cc.Spawn:create(cc.FadeIn:create(0.3), cc.ScaleTo:create(0.3, 1), cc.MoveBy:create(0.3, cc.p(0, 50))),
							--cc.DelayTime:create(10),
							cc.CallFunc:create(function()
									-- local sp = cc.Sprite:create('uires/ui/strength/strength_fazhen1.png')
									-- self.spine_frame:addChild(sp)
									-- sp:setGlobalZOrder(99999)
									-- sp:setCameraMask(2)
									self.bgImgtemp:removeFromParent()
								end)))
						end

						-- local nb = 100
						-- local cloneFrame = self:cloneVisibleFrame()
						-- cloneFrame:setVisible(true)
						-- self.visibleFrame:getParent():addChild(cloneFrame)
						local offsetY = GameData:getConfData("hero")[self.role:getId()].uiOffsetY
						spineAni:runAction(cc.Sequence:create(
							-- cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3), cc.MoveBy:create(0.2, cc.p(0, -100 + offsetY * 3))),
							cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3)),
							--cc.Spawn:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(0.5, 3)),
							--cc.Spawn:create(cc.FadeIn:create(0.3), cc.ScaleTo:create(0.3, 1), cc.MoveBy:create(0.3, cc.p(0, 50))),
							--cc.DelayTime:create(10),
							cc.CallFunc:create(function()
									-- local sp = cc.Sprite:create('uires/ui/strength/strength_fazhen1.png')
									-- self.spine_frame:addChild(sp)
									-- sp:setGlobalZOrder(99999)
									-- sp:setCameraMask(2)
									spineAni:removeFromParent()
								end)))
				local offsetY = GameData:getConfData("hero")[self.role:getId()].uiOffsetY
				spineAni:runAction(cc.Sequence:create(
					cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3)),
					cc.CallFunc:create(function()
							spineAni:removeFromParent()
						end)))

			end),
			cc.DelayTime:create(0.5),
			cc.MoveTo:create(0.5, cc.p(self.spine_frameX, self.spine_frameY)),
			cc.CallFunc:create(function ()
					self:setStage(2)
				end)))

	elseif stage == 2 then
		self.spine_frame:setScale(1)
		self.spine_frame:setOpacity(255)

		self:initAttrFrame()
		self.attrFrame:setVisible(true)
		self.pressText:setVisible(false)

		for k,v in ipairs(self.idx) do
			for i = 1, 4 do
				self.attrTable[v][i]:setVisible(false)
			end
		end

		local funcTab = {}
		for i = 1, 4 do
			funcTab[i] = function (  )
				local arrowsp = cc.Sprite:create()
				arrowsp:setPosition(cc.p(550, 221 - i * 48))
				self.attrFrame:addChild(arrowsp, 9999)
				local arrowAni = self:createAnimation('arrow', 5)
				arrowsp:setVisible(true)
				arrowsp:runAction(cc.RepeatForever:create(cc.Animate:create(arrowAni)))

				local flashsp = cc.Sprite:create()
				flashsp:setPosition(cc.p(550, 221 - i * 48))
				self.attrFrame:addChild(flashsp, 9999)
				local flashAni = self:createAnimation('flash', 7)
			    flashsp:setVisible(true)
			    flashsp:runAction(cc.Sequence:create(cc.Animate:create(flashAni), cc.Animate:create(arrowAni), cc.CallFunc:create(function()
						flashsp:removeFromParent()
					end)))

				for k,v in ipairs(self.idx) do
					self.attrTable[v][i]:setVisible(true)
				end
			end
		end

		self.attrFrame:runAction(cc.Sequence:create(cc.CallFunc:create(funcTab[1]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[2]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[3]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[4]), 
			cc.DelayTime:create(0.7), cc.CallFunc:create(function()
				self:setStage(3)
			end)))

	elseif stage == 3 then
		local delayTime = 0
		if self.type == 'upgrade_talent' then
			delayTime = 0.6
			local richText = self:getDescRichText()
			self.attrFrame:addChild(richText)
            richText:setOpacity(0)
            richText:runAction(cc.FadeIn:create(0.5))
        elseif self.type == "upgrade_peopleking_weapon" or self.type == "upgrade_peopleking_wing" then

        	delayTime = 0.6
			local text = self:getPeopleKingDesc()
			self.attrFrame:addChild(text)
            text:setOpacity(0)
            text:runAction(cc.FadeIn:create(0.5))
		end
		self.root:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function()
			self.pressText:setVisible(true)
			self.pressText:runAction(
				cc.RepeatForever:create(
					cc.Sequence:create(
						cc.FadeOut:create(1.2),
						cc.FadeIn:create(1.2))))
		end)))

		self.bgimg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
	        if eventType == ccui.TouchEventType.ended then
	        	RoleMgr:hideStengthenPopupUI()
	        	if self.func then
	        		self.func()
	        		self.func = nil
	        	end
	        end
  	  	end)
	end
end

function StrengthenPopupUI:getPeopleKingDesc()

	local tx = ccui.Text:create()
	tx:setFontName("font/gamefont.ttf")
    tx:setFontSize(28)
    tx:setColor(COLOR_TYPE.GREEN)
    tx:setAnchorPoint(cc.p(0, 1))
    tx:setPosition(cc.p(315, 15))

	local surfaceName,name,typeId = '','',1
	if self.type == "upgrade_peopleking_weapon" then
		name = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1")
		typeId = 1
	elseif self.type == "upgrade_peopleking_wing" then
		name = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")
		typeId = 2
	end
	local cfg = GameData:getConfData("skychange")[typeId]
	local surfaceId = self:getSurfaceId()
    local str = GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_15")
    if not surfaceId then
    	tx:setString('')
    else
    	local surfaceName = cfg[surfaceId].name
    	local txStr = string.format(str,name,surfaceName)
    	tx:setString(txStr)
    end
    return tx
end

function StrengthenPopupUI:getSurfaceId()

	local typeId,lv = 1,1
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	if self.type == "upgrade_peopleking_weapon" then
		lv = peopleKingData.weapon_level or 1
		typeId = 1
	elseif self.type == "upgrade_peopleking_wing" then
		lv = peopleKingData.wing_level or 1
		typeId = 2
	end
	local surfaceId
	local skychangeConf = GameData:getConfData("skychange")[typeId]
	for i=1,#skychangeConf do
		if skychangeConf[i].condition == "level" and lv == skychangeConf[i].value then
			surfaceId = i
			break
		end
	end
	return surfaceId
end

function StrengthenPopupUI:getDescRichText()
	if self.targetlv > 1 then
		local richText = xx.RichText:create()
		richText:setAlignment('left')
	    richText:setVerticalAlignment('top')
	    richText:setContentSize(cc.size(500, 75))
	    local tx1 = string.format(GlobalApi:getLocalStr('STR_AUTO_TUPO_DESC'),self.role:getTalent() + self.targetlv)
	    local re1 = xx.RichTextLabel:create(tx1, 25, COLOR_TYPE.GREEN)
		re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re2 = xx.RichTextLabel:create('   '..GlobalApi:getLocalStr("AREADY_ACTIVE"),26,COLOR_TYPE.YELLOW)
	    re2:setFont('font/gamefont.ttf')
	    re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	    
		richText:addElement(re1)
		richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0,1))
	    richText:setPosition(cc.p(350,0))
	    return richText
	else
		local value = self.role:getTalent() + self.targetlv
		local innateGroupId = self.role:getInnateGroup()
		local groupconf = GameData:getConfData('innategroup')[innateGroupId]
		local specialtab = groupconf['highlight']
		local teamtab = groupconf['teamvaluegroup']
		local innateid = groupconf[tostring('level' .. value)]
		local effect =groupconf[tostring('value' .. value)]
		local innateconf = GameData:getConfData('innate')[innateid]
		local teamheroID = groupconf['teamheroID']
	    local richText = xx.RichText:create()
	    richText:setAlignment('left')
	    richText:setVerticalAlignment('top')
	    richText:setContentSize(cc.size(500, 75))

		local tx1 = ''
		local tx2 = ''
		local tx3 = ''
		local tx4 = ''
		local teamnum = 0
		local re1 = xx.RichTextLabel:create(tx1, 25, COLOR_TYPE.GREEN)
		re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re3 = xx.RichTextLabel:create(tx3, 25, COLOR_TYPE.ORANGE)
		re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re5 = xx.RichTextLabel:create(tx4, 25, COLOR_TYPE.GREEN)
		re5:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
		re5:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re6 = xx.RichTextImage:create('uires/ui/common/arrow5.png')
		re6:setScale(0.6)
		local s = GlobalApi:tableFind(teamtab,value)
		if s ~= 0 then
			for i,v in ipairs(teamtab) do
				if value >= v then
					teamnum = teamnum + 1
				end
			end
			tx4 =  groupconf[tostring('teamDes'..teamnum)]
			re5:setString(tx4)
		end
		if innateid < 1000 then
			tx1 = innateconf['desc'] .. effect .. '%'
			if innateconf['type'] ~= 2 then
				tx1 = innateconf['desc'] .. effect
			end
			tx3 =  '【' .. innateconf['name'] ..'】 '
		else
	        tx1 = groupconf[tostring('specialDes'..innateid%1000)]
			tx3 =  '【' .. groupconf[tostring('specialName'..innateid%1000)] ..'】 '
		end
		local n  = GlobalApi:tableFind(specialtab,value)
		re3:setColor(COLOR_TYPE.ORANGE)
		re1:setString(tx1)
		re3:setString(tx3)
		richText:addElement(re3)
		if n == 0 then
			re1:setColor(COLOR_TYPE.GREEN)
			re5:setColor(COLOR_TYPE.GREEN)
		else
			re1:setColor(COLOR_TYPE.RED)
			re5:setColor(COLOR_TYPE.RED)
			local re4 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
			re4:setScale(0.8)
			richText:addElement(re4)
		end
		richText:addElement(re1)
		if s ~= 0 then
			richText:addElement(re6)
			richText:addElement(re5)
			local obj = RoleData:getRoleById(teamheroID) 
			if not obj then
				re5:setColor(COLOR_TYPE.GRAY)
			end
		end
	    local re7 = xx.RichTextLabel:create('   '..GlobalApi:getLocalStr("AREADY_ACTIVE"),26,COLOR_TYPE.YELLOW)
	    re7:setFont('font/gamefont.ttf')
	    re7:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	    richText:addElement(re7)
	    richText:setAnchorPoint(cc.p(0,1))
	    richText:setPosition(cc.p(315,0))
	    return richText
	end

end

function StrengthenPopupUI:initVisibleFrame()
	-- local name = self.role:getName()
	-- local nameColor = self.role:getNameColor()
	-- local nameColorOutLine = self.role:getNameOutlineColor()

	-- local name_pai = self.visibleFrame:getChildByName('name_tiao'):getChildByName('name')
	-- name_pai:enableOutline(nameColorOutLine, 2)
	-- name_pai:setString(name)
	-- name_pai:setTextColor(nameColor)
	local customObj = {}
    if self.type == "upgrade_peopleking_weapon" then
    	local peopleKingData = UserData:getUserObj():getPeopleKing()
    	local surfaceId = self:getSurfaceId()
		surfaceId = surfaceId or peopleKingData.weapon_illusion
		customObj.weapon_illusion = tonumber(surfaceId)
    elseif self.type == "upgrade_peopleking_wing" then
    	local surfaceId = self:getSurfaceId()
    	local peopleKingData = UserData:getUserObj():getPeopleKing()
		surfaceId = surfaceId or peopleKingData.wing_illusion
        customObj.wing_illusion = tonumber(surfaceId)
    end
	local spineAni = GlobalApi:createLittleLossyAniByName(self.role:getUrl() .. "_display", nil, self.role:getChangeEquipState(customObj))
	if spineAni then
		local ap = spineAni:getAnchorPoint()
		local size = self.spine_frame:getContentSize()
		spineAni:setPosition(cc.p(size.width / 2, size.height / 2))
		spineAni:setLocalZOrder(999)
		spineAni:setTag(69)
		self.spine_frame:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		spineAni:setAnchorPoint(cc.p(ap.x, 0.55))
		if self.type == 'upgrade_junzhu' then
			spineAni:setScale(0.7)
			spineAni:setPosition(cc.p(size.width / 2, size.height / 2+30))
		end
	end
end

function StrengthenPopupUI:initAttrFrame()
	local name = self.role:getName()
	local nameColor = self.role:getNameColor()
	local nameColorOutLine = self.role:getNameOutlineColor()

	for i,v in ipairs(self.idx) do
		local frame = self.attrFrame:getChildByName(v)
		local frame_name = frame:getChildByName('name')
		frame_name:enableOutline(nameColorOutLine, 2)
		frame_name:setString(name)
		frame_name:setTextColor(nameColor)

		local frame_level = frame:getChildByName('strength_count')

		local richText = xx.RichText:create()
		local y = 236
		if self.type == 'upgrade_talent' then
			if self.idx[i] == 'from' then
				local value = self.role:getTalent()
				frame_level:setString('+' .. value)
			elseif self.idx[i] == 'to' then
				local value = self.role:getTalent() + self.targetlv
				frame_level:setString('+' .. value)
			end
		elseif self.type == 'upgrade_risestar' then
			local quality = self.role:getHeroQuality()
			if self.idx[i] == 'from' then
				quality = self.role:getHeroQuality()
			elseif self.idx[i] == 'to' then
				quality = self.role:getHeroQuality() + self.targetlv
			end

			local conf = GameData:getConfData('heroquality')[quality]
			local re1 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
			local re2 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
			local re3 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
			re1:setScale(0.8)
			re2:setScale(0.8)
			re3:setScale(0.8)
			if conf.star == 1 then
				richText:addElement(re1)
			elseif conf.star == 2 then
				richText:addElement(re1)
				richText:addElement(re2)
			elseif conf.star == 3 then
				richText:addElement(re1)
				richText:addElement(re2)
				richText:addElement(re3)
			end
			self.flagImgs[v]:loadTexture('uires/ui/role/role_flag_'..conf.quality..'.png')
			self.flagImgs[v]:setVisible(true)
			frame_level:setString('')
		elseif self.type == 'upgrade_destiny' then
			local value = self.role:getDestiny().level + i - 1
			frame_name:setString('')
			frame_level:setString('')
			local re1 = xx.RichTextImage:create('uires/ui/common/frame_red.png')
			richText:addElement(re1)
		elseif self.type == 'upgrade_soldier' then
			-- 携带小兵3个    携带小兵4个
			y = 256
			local value = self.role:getSoldierLv() + i - 1
			frame_name:setString('')
			frame_level:setString('')
			local re1 = xx.RichTextLabel:create(
				GlobalApi:getLocalStr('STRENGTH_SOLDIER') .. 
				value .. 
				GlobalApi:getLocalStr('STRENGTH_GE'), 
				28, COLOR_TYPE.YELLOW)
			re1:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
			re1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

			richText:addElement(re1)
		elseif self.type == 'upgrade_junzhu' then
			local value = self.role:getQuality() + i - 1
			frame_name:setString('')
			frame_level:setString('')
			y = 256
			local re1 = xx.RichTextLabel:create(
				GlobalApi:getLocalStr('COLOR_'..value-1) ..
				GlobalApi:getLocalStr('QUALITY_DESC'),
				28,
				COLOR_TYPE.WHITE)
			re1:setStroke(COLOROUTLINE_QUALITYFORJADESEAL[value-1], 1)
			re1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
			richText:addElement(re1)
		elseif self.type == 'upgrade_peopleking_weapon' then

			local peopleKingData = UserData:getUserObj():getPeopleKing()
			local curLv = peopleKingData.weapon_level or 0		--升阶之后
			local preLv = curLv - 1 < 0 and 0 or curLv - 1

			local lv = preLv+i-1
			frame_name:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1") .. lv .. GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_2"))
			frame_name:setTextColor(COLOR_TYPE.RED)
			frame_level:setString('')

		elseif self.type == 'upgrade_peopleking_wing' then
			
			local peopleKingData = UserData:getUserObj():getPeopleKing()
			local curLv = peopleKingData.wing_level or 0
			local preLv = curLv - 1 < 0 and 0 or curLv - 1
			local lv = preLv+i-1
			frame_name:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2") .. lv .. GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_2"))
			frame_name:setTextColor(COLOR_TYPE.RED)
			frame_level:setString('')
		end

		richText:format(true)
		richText:setContentSize(richText:getElementsSize())
		if self.type == 'upgrade_risestar' then
			richText:setPosition(cc.p(62 ,236))
			richText:setAnchorPoint(cc.p(0,0.5))
			frame_name:setPosition(cc.p(89,265))
			frame_level:setPosition(cc.p(136,265))
		else
			richText:setPosition(cc.p(100 ,236))
		end
		frame:addChild(richText)

	    for i=1,4 do
	    	local frame_attrXbg = frame:getChildByName('att' .. i .. 'bg')
	    	frame_attrXbg:getChildByName('attr1'):setString(GlobalApi:getLocalStr('STR_ATT' .. i))
	    	frame_attrXbg:getChildByName('count'):setString('+' .. self[v .. 'Attr'][i])
	    end
	end
 end 

 function StrengthenPopupUI:createAnimation(name, framecount)
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
        animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
    return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
 end

return StrengthenPopupUI