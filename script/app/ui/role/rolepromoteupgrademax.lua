local RolePromotedUpgradeMaxUI = class("RolePromotedUpgradeMaxUI", BaseUI)

local herochangeconf = GameData:getConfData('herochange')
local MAXPROTYPE = #herochangeconf

function RolePromotedUpgradeMaxUI:ctor(obj,fromatt,toatt,func)
	self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_UPGRADEMAX_PANEL
	self.role = obj
	self.func = func
	self.fromatt = fromatt
	self.toatt = toatt
end

function RolePromotedUpgradeMaxUI:init()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local bgimg1 = self.root:getChildByName('background')
	self.bgimg1 = bgimg1
	self.bgimg1:setVisible(false)
	local bgimg = bgimg1:getChildByName('alphaBg')

	bgimg:setCascadeColorEnabled(false)
	self.bgimg = bgimg
	self:adaptUI(bgimg1, bgimg)

	local norpl = bgimg1:getChildByName('attr_bg_nor')
	norpl:setVisible(false)
	self.attrFrame = bgimg1:getChildByName('attr_bg_max')
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
	    soldierimg:setPosition(cc.p(74,217.28))
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
	local title = self.attrFrame:getChildByName('strength_suc')
	title:loadTexture('uires/ui/text/upgrade_suc.png')

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

	for i=1,4 do
		local att1 = self.attrTable[self.idx[1]][i]:getChildByName('attr1')
		att1:setString(GlobalApi:getLocalStr('STR_ATT'..i))
		local count1 = self.attrTable[self.idx[1]][i]:getChildByName('count')
		count1:setString(self.fromatt[i])
		local att2 = self.attrTable[self.idx[2]][i]:getChildByName('attr1')
		att2:setString(GlobalApi:getLocalStr('STR_ATT'..i))
		local count2 = self.attrTable[self.idx[2]][i]:getChildByName('count')
		count2:setString(self.toatt[i])
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

function RolePromotedUpgradeMaxUI:setStage(stage)
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
		self.spine_frame:runAction(cc.Sequence:create(
			cc.FadeIn:create(fadeInTime),
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

		        local spineAni = GlobalApi:createLittleLossyAniByName(self.role:getUrl().."_display", nil, self.role:getChangeEquipState())
				if spineAni then
					local ap = spineAni:getAnchorPoint()
					local size = self.spine_frame:getContentSize()
					spineAni:setPosition(cc.p(size.width / 2, size.height / 2))
					spineAni:setLocalZOrder(999)
					self.spine_frame:addChild(spineAni)
					spineAni:getAnimation():play('idle', -1, 1)
					spineAni:setAnchorPoint(cc.p(ap.x, 0.55))
				end
				local offsetY = GameData:getConfData("hero")[self.role:getId()].uiOffsetY
				spineAni:runAction(cc.Sequence:create(
					cc.Spawn:create(cc.FadeTo:create(0.2, 0), cc.ScaleTo:create(0.2, 3)),
					cc.CallFunc:create(function()
							spineAni:removeFromParent()
						end)))

				local customObj = {
		            advanced = self.role:getPromoteType() + 1
		        }
				local changeEquipObj = self.role:getChangeEquipState(customObj)
				GlobalApi:changeModelEquip(self.heroAni, self.role:getUrl() .. "_display", changeEquipObj, 2)
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
				arrowsp:setPosition(cc.p(550, 243 - i * 48))
				self.attrFrame:addChild(arrowsp, 9999)
				local arrowAni = self:createAnimation('arrow', 5)
				arrowsp:setVisible(true)
				arrowsp:runAction(cc.RepeatForever:create(cc.Animate:create(arrowAni)))

				local flashsp = cc.Sprite:create()
				flashsp:setPosition(cc.p(550, 243 - i * 48))
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
	           	RoleMgr:hideRolePromotedUpgradeMaxUI()
	        	self.func()
	        end
  	  	end)
	end
end

function RolePromotedUpgradeMaxUI:initVisibleFrame()
	self.heroAni = GlobalApi:createLittleLossyAniByName(self.role:getUrl() .. "_display", nil, self.role:getChangeEquipState())
	local ap = self.heroAni:getAnchorPoint()
	local size = self.spine_frame:getContentSize()
	self.heroAni:setPosition(cc.p(size.width / 2, size.height / 2))
	self.heroAni:setLocalZOrder(999)
	self.spine_frame:addChild(self.heroAni)
	self.heroAni:getAnimation():play('idle', -1, 1)
	self.heroAni:setAnchorPoint(cc.p(ap.x, 0.55))
end

function RolePromotedUpgradeMaxUI:initAttrFrame()
 	-- body
	local name = self.role:getName()
	local nameColor = self.role:getNameColor()
	local nameColorOutLine = self.role:getNameOutlineColor()

	for i,v in ipairs(self.idx) do
		local frame = self.attrFrame:getChildByName(v)
	end
 end 

 function RolePromotedUpgradeMaxUI:createAnimation(name, framecount)
 	-- body
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
        animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
    return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
 end

return RolePromotedUpgradeMaxUI