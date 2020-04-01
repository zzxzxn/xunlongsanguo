local SkillUpgradeUI = class("SkillUpgradeUI", BaseUI)
function SkillUpgradeUI:ctor(role,func)
	self.uiIndex = GAME_UI.UI_SKILL_UPGRADE_PANEL
	self.role = role
	self.func = func
end
function SkillUpgradeUI:init()
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
	title:loadTexture('uires/ui/text/tianming_suc.png')

	self.idx = {
		[1] = 'from',
		[2] = 'to'
	}
	self.fromtable = {}
	self.totable ={}

	for i=1,2 do
		local tab = {}
		tab.bg = self.attrFrame:getChildByName('skillfrom'..tostring(i))
		tab.name = tab.bg:getChildByName('name_tx')
		local skillbg = tab.bg:getChildByName('skillbgimg')
		tab.skillimg = skillbg:getChildByName('skill_img')
		tab.skillatt1 =  tab.bg:getChildByName('attr1')
		tab.skillatt2 =  tab.bg:getChildByName('attr2')
		tab.skillatt3 =  tab.bg:getChildByName('attr3')
		tab.skillatt4 =  tab.bg:getChildByName('attr4')
		tab.arrow1 = tab.bg:getChildByName('arrow1')
		tab.arrow2 = tab.bg:getChildByName('arrow2')
		tab.arrow3 = tab.bg:getChildByName('arrow3')
		tab.arrow4 = tab.bg:getChildByName('arrow4')
		tab.lv = tab.bg:getChildByName('lv_tx')
		self.fromtable[i] = tab

		local tab1 = {}
		tab1.bg = self.attrFrame:getChildByName('skillto'..tostring(i))
		tab1.name = tab1.bg:getChildByName('name_tx')
		local skillbg = tab1.bg:getChildByName('skillbgimg')
		tab1.skillimg = skillbg:getChildByName('skill_img')
		tab1.skillatt1 =  tab1.bg:getChildByName('attr1')
		tab1.skillatt2 =  tab1.bg:getChildByName('attr2')
		tab1.skillatt3 =  tab1.bg:getChildByName('attr3')
		tab1.skillatt4 =  tab1.bg:getChildByName('attr4')
		tab1.arrow1 = tab1.bg:getChildByName('arrow1')
		tab1.arrow2 = tab1.bg:getChildByName('arrow2')
		tab1.arrow3 = tab1.bg:getChildByName('arrow3')
		tab1.arrow4 = tab1.bg:getChildByName('arrow4')
		tab1.lv = tab1.bg:getChildByName('lv_tx')
		self.totable[i] = tab1
	end
	self:initSkill()
	self.baseattfromtx = self.attrFrame:getChildByName("baseattfrom")
	self.baseatttotx = self.attrFrame:getChildByName("baseattto")
	self.attarrow = self.attrFrame:getChildByName("arrow")
	self.baseattfromtx:setVisible(false)
	self.baseatttotx:setVisible(false)
	self.attarrow:setVisible(false)
	local destinyconf = GameData:getConfData('destiny')[self.role:getDestiny().level] 
	local destinyconf1 = GameData:getConfData('destiny')[self.role:getDestiny().level+1]
	self.baseattfromtx:setString(GlobalApi:getLocalStr('SKILLUPGRADE_DESC_1')..destinyconf['atk'].."%")
	self.baseatttotx:setString(GlobalApi:getLocalStr('SKILLUPGRADE_DESC_1')..destinyconf1['atk'].."%")
	bgimg:setTouchEnabled(true)
	self.bgimg1:setVisible(true)
	self:setStage(1)
end

function SkillUpgradeUI:initSkill()
	local skilltab = self.role:getSkillIdTab()
	local skilllv = self.role:getDestiny().level
	local skillgroupconf = GameData:getConfData("skillgroup")
	self.diffnumtab = {}
	for i=1,2 do
		local skillconf = GameData:getConfData("skill")[skilltab[i]+skilllv-1]
		local skillconfto = skillconf
		if skilllv+1 <= MaxSkilLv then
			skillconfto = GameData:getConfData("skill")[skilltab[i]+skilllv]
		end
		local skillicon ='uires/icon/skill/' .. skillconf['skillIcon']
		self.fromtable[i].name:setString(skillconf.name)
		self.fromtable[i].lv:setString("Lv. "..skilllv)
		self.fromtable[i].skillimg:loadTexture(skillicon)
		self.fromtable[i].skillimg:ignoreContentAdaptWithSize(true)

		self.totable[i].name:setString(skillconf.name)
		self.totable[i].lv:setString("Lv. "..skilllv+1)
		self.totable[i].skillimg:loadTexture(skillicon)
		self.totable[i].skillimg:ignoreContentAdaptWithSize(true)

		local skilldesctab =  skillconf['skillDesc']
		local skilldesctab2 =  skillconfto['skillDesc']

		self.diffnumtab[i] = 1
		for j=2,#skilldesctab do
			if skilldesctab[j] ~= skilldesctab2[j] then
				self.fromtable[i]['skillatt'..tostring(self.diffnumtab[i])]:setString(skilldesctab[j])
				self.fromtable[i]['skillatt'..tostring(self.diffnumtab[i])]:setVisible(false)
				self.fromtable[i]['arrow'..tostring(self.diffnumtab[i])]:setVisible(false)
				self.totable[i]['skillatt'..tostring(self.diffnumtab[i])]:setString(skilldesctab2[j])
				self.totable[i]['skillatt'..tostring(self.diffnumtab[i])]:setVisible(false)
				self.diffnumtab[i] = self.diffnumtab[i] + 1 
			end
		end	
	end
end

function SkillUpgradeUI:setStage(stage)
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

		local funcTab = {}
		local index = 0
		local posytab = {414,380,348,213,189,160}
		for j=1,2 do
			for i = 1,3 do
				index = index + 1 
				if i < self.diffnumtab[j] then
					funcTab[index] = function ()
						local flashsp = cc.Sprite:create()
						flashsp:setPosition(550,250-(i-1)*30-(j-1)*200)
						self.attrFrame:addChild(flashsp, 9999)
						local flashAni = self:createAnimation('flash', 7)
					    flashsp:setVisible(true)
					    flashsp:runAction(cc.Sequence:create(cc.Animate:create(flashAni), cc.CallFunc:create(function()
								flashsp:removeFromParent()
							end)))
					    self.fromtable[j]['skillatt'..tostring(i)]:setVisible(true)
						self.fromtable[j]['arrow'..tostring(i)]:setVisible(true)
						self.totable[j]['skillatt'..tostring(i)]:setVisible(true)
					end
				else
					funcTab[index] = function ()
						cc.DelayTime:create(0.0)
					end
				end
			end
		end
		local func2 = function ()
				local flashsp = cc.Sprite:create()
				flashsp:setPosition(550,-50)
				self.attrFrame:addChild(flashsp, 9999)
				local flashAni = self:createAnimation('flash', 7)
			    flashsp:setVisible(true)
			    flashsp:runAction(cc.Sequence:create(cc.Animate:create(flashAni), cc.CallFunc:create(function()
						flashsp:removeFromParent()
					end)))
				self.baseattfromtx:setVisible(true)
				self.baseatttotx:setVisible(true)
				self.attarrow:setVisible(true)
		end
		self.attrFrame:runAction(cc.Sequence:create(cc.CallFunc:create(funcTab[1]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[2]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[3]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[4]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[5]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[6]), 
			cc.DelayTime:create(0.3), cc.CallFunc:create(func2),
			cc.DelayTime:create(0.7), cc.CallFunc:create(function()
				self:setStage(3)
			end)))
		self:setStage(3)
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
	        	RoleMgr:hideSkillUpgrade()
	        	self.func()
	        end
  	  	end)
	end
end

function SkillUpgradeUI:initVisibleFrame()
	local spineAni = GlobalApi:createLittleLossyAniByName(self.role:getUrl() .. "_display", nil, self.role:getChangeEquipState())
	if spineAni then
		local ap = spineAni:getAnchorPoint()
		local size = self.spine_frame:getContentSize()
		spineAni:setPosition(cc.p(size.width / 2, size.height / 2))
		spineAni:setLocalZOrder(999)
		spineAni:setTag(69)
		self.spine_frame:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		spineAni:setAnchorPoint(cc.p(ap.x, 0.55))
	end
end

function SkillUpgradeUI:initAttrFrame()
 	-- body
	local name = self.role:getName()
	local nameColor = self.role:getNameColor()
	local nameColorOutLine = self.role:getNameOutlineColor()

	for i,v in ipairs(self.idx) do
		local frame = self.attrFrame:getChildByName(v)
	end
 end 

 function SkillUpgradeUI:createAnimation(name, framecount)
 	-- body
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
        animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
    return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
 end

return SkillUpgradeUI