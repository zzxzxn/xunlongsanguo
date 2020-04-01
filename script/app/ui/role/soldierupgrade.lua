local SoldierUpgradeUI = class('SoldierUpgradeUI', BaseUI)

local function getUnlockSkill(role, target_level)
	local skillarr = role:getSoldierSkillArr()
	for i, v in ipairs(skillarr) do
		if target_level == v[1] then
			-- skill 
			return i, v
		end
	end
	return nil
end

local SOLDIER_UPGRADE_TYPE = {
	NUMBER = 1,
	SKILL = 2,
	NEWTYPE = 3,
}

local function getSoldierAttribute(role)
	local ret = {}
	local heroConf = role:getConfig('hero')
	local sid = heroConf.soldierId
	local sconf = GameData:getConfData('soldierlevel')
	local conf = sconf[sid]

	if conf ~= nil then
		for i = 2, MAXSOLDIERLV do
			local t = {}
			t.number = tonumber(conf[i].num)
			t.skillId = tonumber(conf[i].skillPos)
			t.quality = tonumber(conf[i].quality)
			if tonumber(conf[i].skillPos) > 0 then
				t.type = SOLDIER_UPGRADE_TYPE.SKILL
			elseif tonumber(conf[i - 1].num) ~= tonumber(conf[i].num) then
				t.type = SOLDIER_UPGRADE_TYPE.NUMBER
			elseif tonumber(conf[i - 1].quality) ~= tonumber(conf[i].quality) then
				t.type = SOLDIER_UPGRADE_TYPE.NEWTYPE
			end
			ret[i] = t
		end
	end
	local t = {}
	t.number = tonumber(conf[1].num)
	t.skillId = tonumber(conf[1].skillPos)
	t.quality = tonumber(conf[1].quality)
	t.type = SOLDIER_UPGRADE_TYPE.NEWTYPE
	ret[1] = t
	return ret
end

function SoldierUpgradeUI:ctor(role, fromAttr, toAttr, func)
	self.uiIndex = GAME_UI.UI_SOLDIER_UPGRADE
	-- logic data
	self.role = role
	self.fromAttr = fromAttr
	self.toAttr = toAttr
	self.func = func

	-- ui data
	self.bg_node = nil

	-- debug
	self.entry = nil
end

function SoldierUpgradeUI:init()
	local bg = self.root:getChildByName('bg')
	local bg1 = bg:getChildByName('bg1')
	self.bg_node = bg1

	self:adaptUI(bg, bg1)

    local winSize = cc.Director:getInstance():getWinSize()
    bg:getChildByName('step2_bg2'):setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    bg:getChildByName('step2_bg2'):setVisible(false)

   
	local attribute_bg = bg1:getChildByName('upgrade_bg')
		:getChildByName('attribute_bg')

	for i = 1, 4 do
		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('tx_1')
			:setString(GlobalApi:getLocalStr('STR_ATT' .. i))

		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('num_1')
			:setString(self.fromAttr[i])
	end

	for i = 1, 4 do
		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('tx_2')
			:setString(GlobalApi:getLocalStr('STR_ATT' .. i))

		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('num_2')
			:setString(self.toAttr[i])
	end

	local level = self.role:getSoldierLv() + 1
	local index, unlockSkill = getUnlockSkill(self.role, level)
	if index ~= nil and unlockSkill ~= nil then
		self:_tipSkill(index, unlockSkill)
	else
		self:_tipSoldier(level)
	end

	-- play effect
	AudioMgr.playEffect("media/effect/soldier_upgrade.mp3", false)
	bg1:getChildByName('light')
		:runAction(cc.RepeatForever:create(
			cc.RotateBy:create(0.5, 20)))

	local bg_size = bg:getContentSize()
	bg:getChildByName('press_tx')
		:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
		:setPositionX(bg_size.width / 2)
		:setLocalZOrder(9999)
		:setVisible(false)
	local tip_frame = bg1:getChildByName('tip_frame')
	tip_frame:setPositionY(tip_frame:getPositionY() + 50)
	bg1:setScale(0.1)
	bg1:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.3, 1), 
		cc.CallFunc:create(function ()
			tip_frame:runAction(cc.Sequence:create(
				cc.JumpBy:create(0.13, cc.p(0, -50), 0, 1),
				cc.JumpBy:create(0.2, cc.p(0, 0), 20, 1),
				cc.JumpBy:create(0.08, cc.p(0, 0), 5, 1),
				cc.CallFunc:create(function ()
					bg:addClickEventListener(function ()
						bg:addClickEventListener(function()end)
						self:step2()
					end)

					bg:getChildByName('press_tx')
						:setVisible(true)
						:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
						:setFontName('font/gamefont.ttf')
						:runAction(cc.RepeatForever:create(
							cc.Sequence:create(cc.FadeOut:create(1.2),
							cc.FadeIn:create(1.2))))
				end)))
		end)))
end

function SoldierUpgradeUI:_tipSkill(index, skill)
	local tip_frame = self.bg_node:getChildByName('tip_frame')
	local page = tip_frame:getChildByName('skill_page')
	tip_frame:getChildByName('soldier_page')
		:setVisible(false)
	page:setVisible(true)

	local id = skill[2]
	local conf = GameData:getConfData('soldierskill')
	if conf[id] == nil then
		print('[ERROR]: id = [' .. id .. '] not in soldierskill')
		return
	end
	-- page:getChildByName('title_tx')
	-- 	:setString(conf[id].name)
	page:getChildByName('skill_icon')
		:loadTexture('uires/icon/skill/' .. conf[id].icon)

	local rt = xx.RichText:create()
	local rtl1 = xx.RichTextLabel:create(conf[id].name, 20, COLOR_TYPE.ORANGE)
	rtl1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	local rtl2 = xx.RichTextLabel:create(
		'LV.1', 
		22, COLOR_TYPE.WHITE)
	rtl2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	rtl2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	rt:addElement(rtl1)
	rt:addElement(rtl2)
	rt:setVerticalAlignment('middle')
	rt:format(true)
	rt:setContentSize(rt:getElementsSize())
	rt:setPosition(cc.p(84, 33))

	page:addChild(rt)
end

function SoldierUpgradeUI:_tipSoldier(level)
	local tip_frame = self.bg_node:getChildByName('tip_frame')
	local page = tip_frame:getChildByName('soldier_page')
	tip_frame:getChildByName('skill_page')
		:setVisible(false)
	page:setVisible(true)

	local soldierid = self.role:getSoldierId()
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][level]
	page:getChildByName('soldier_img')
		:loadTexture('uires/ui/role/role_' ..soldlevelconf.soldierIcon)

	page:getChildByName('title_tx')
	 	:setString(soldlevelconf.name)
	local rt = xx.RichText:create()
	local rtl1 = xx.RichTextLabel:create(soldlevelconf.num, 28, COLOR_TYPE.ORANGE)
	rtl1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	rtl1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	local rtl2 = xx.RichTextLabel:create(
		GlobalApi:getLocalStr('SOLDIER_REN'), 
		22, COLOR_TYPE.WHITE)
	rtl2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	rtl2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))

	rt:addElement(rtl1)
	rt:addElement(rtl2)
	rt:setVerticalAlignment('middle')
	rt:format(true)
	rt:setContentSize(rt:getElementsSize())
	rt:setAnchorPoint(cc.p(1, 0.5))
	rt:setPosition(cc.p(156, 25))

	page:addChild(rt)
end

function SoldierUpgradeUI:step2()
	self.bg_node:setVisible(false)
	local bg = self.root:getChildByName('bg')
	local bg_size = bg:getContentSize()

	local sattr = getSoldierAttribute(self.role)
	local level = self.role:getSoldierLv() + 1

    local step2_bg2 = bg:getChildByName('step2_bg2')

    local bg2
    if sattr[level].type == SOLDIER_UPGRADE_TYPE.NUMBER then  -- 升级的背景图片单独弄一张
        step2_bg2:setVisible(true)
        step2_bg2:setTouchEnabled(false)
        
        step2_bg2:setLocalZOrder(1000)

        bg2 = ccui.Layout:create()
		    :setName('step2_bg')
		    :setContentSize(bg_size)
		    :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		    :setBackGroundColor(cc.c4b(20, 20, 20, 200))
		    :setBackGroundColorOpacity(200)
		    :setTouchEnabled(false)
	    bg:addChild(bg2)

    else
        step2_bg2:setVisible(false)
        step2_bg2:setTouchEnabled(false)

        step2_bg2:setLocalZOrder(1)

        bg2 = ccui.Layout:create()
		    :setName('step2_bg')
		    :setContentSize(bg_size)
		    :setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		    :setBackGroundColor(cc.c4b(20, 20, 20, 200))
		    :setBackGroundColorOpacity(200)
		    :setTouchEnabled(false)
	    bg:addChild(bg2)
    end

	if sattr[level].type == SOLDIER_UPGRADE_TYPE.NUMBER then
		self:step2_number(sattr)
	elseif sattr[level].type == SOLDIER_UPGRADE_TYPE.SKILL then
		self:step2_skill(sattr)
	elseif sattr[level].type == SOLDIER_UPGRADE_TYPE.NEWTYPE then
		self:step2_newtype(sattr)
	else
		RoleMgr:hideSoldierUpgrade()
		if self.func ~= nil then
			self.func()
		end
	end
end

function SoldierUpgradeUI:step2_number(a)
    local bg = self.root:getChildByName('bg')
		:getChildByName('step2_bg2')
	local bg_size = bg:getContentSize()

	local title = ccui.Text:create(GlobalApi:getLocalStr('SOLDIER_UPGRADE_STR1'),
		'font/gamefont.ttf',
		36)
	title:setTextColor(COLOR_TYPE.ORANGE)
	title:enableOutline(COLOROUTLINE_TYPE.ORANGE, 2)
	title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	title:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2 + 230))
	bg:addChild(title)

	-- play audio effect
	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
		AudioMgr.playEffect("media/effect/soldier_increased.mp3", false)
	end)))

	local horizontal_interval = 110
	local vertical_interval = 20
	local level = self.role:getSoldierLv()

	local conf = self.role:getConfig('soldierlevel')
	if conf == nil then
		print('[ERROR]: self.role:getConfig(soldierlevel) got a nil')
		return
	end
	local soldiersNode = cc.Node:create()
	soldiersNode:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2))
	for i = 1, 12 do
		local img = ccui.ImageView:create('uires/ui/role/role_' .. conf.soldierIcon)
		soldiersNode:addChild(img)
		local size = img:getContentSize()
		local pos_x = (size.width + horizontal_interval) * (1.5 - math.floor((i - 1) / 3)) / 2
		local pos_y = (1 - (i - 1) % 3) * (size.height + vertical_interval)
		img:setPosition(cc.p(pos_x, pos_y))

        -- 底座
        local imgDizuo = ccui.ImageView:create('uires/ui/role/role_dizuo.png')
		img:addChild(imgDizuo)
		imgDizuo:setPosition(cc.p(50, 0))
        imgDizuo:setVisible(true)

		-- 获取未解锁的小兵
		if i > a[level].number then    
			--ShaderMgr:setGrayForWidget(img)
            img:setOpacity(255 * 0.3)
            imgDizuo:setVisible(false)

			if i <= a[level + 1].number then
				img:setColor(cc.c3b(0, 0, 0))
				img:runAction(cc.Sequence:create(
					cc.DelayTime:create(0.2),
					cc.Spawn:create(
						cc.TintTo:create(1, cc.c3b(255, 255, 255)),
						cc.Shake:create(1, 10)),
					cc.CallFunc:create(function ()
						--ShaderMgr:restoreWidgetDefaultShader(img)
 
                        img:setOpacity(255)
                        imgDizuo:setVisible(true)

                        self:playXiaobingUpgradeEffect(img)

						self.root:getChildByName('bg')
							:addClickEventListener(function (  )
								RoleMgr:hideSoldierUpgrade()
								if self.func ~= nil then
									self.func()
								end
							end)
					end)))
			end
		end
	end
	bg:addChild(soldiersNode)
end

function SoldierUpgradeUI:step2_skill(a)
	local bg = self.root:getChildByName('bg')
		:getChildByName('step2_bg')
	local bg_size = bg:getContentSize()
	local title = ccui.Text:create(GlobalApi:getLocalStr('SOLDIER_UPGRADE_STR2'),
		'font/gamefont.ttf',
		36)
	title:setTextColor(COLOR_TYPE.ORANGE)
	title:enableOutline(COLOROUTLINE_TYPE.ORANGE, 2)
	title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	title:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2 + 200))
	bg:addChild(title)

	-- play audio effect
	AudioMgr.playEffect("media/effect/soldier_newskill.mp3", false)

	local skill_bg = self.bg_node:getChildByName('tip_frame'):clone()
	skill_bg:retain()
	local sn = cc.Node:create()


	skill_bg:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2))
		:setScale(0.1)
		:setOpacity(0)

	local light = ccui.ImageView:create('uires/ui/strength/strength_light_bg.png')
		:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2))
	bg:addChild(light)
	light:runAction(cc.RepeatForever:create(
		cc.RotateBy:create(0.5, 20)))

	bg:addChild(skill_bg)
	skill_bg:runAction(cc.Sequence:create(
		cc.Spawn:create(cc.FadeIn:create(0.5), cc.ScaleTo:create(0.5, 1.0)),
		cc.CallFunc:create(function ()
			self.root:getChildByName('bg')
				:addClickEventListener(function (  )
					skill_bg:removeFromParent()
					RoleMgr:hideSoldierUpgrade()
					if self.func ~= nil then
						self.func()
					end

				end)
		end)))
	
end

function SoldierUpgradeUI:step2_newtype(a)
	local bg = self.root:getChildByName('bg')
		:getChildByName('step2_bg')
	local bg_size = bg:getContentSize()
	local title = ccui.Text:create(GlobalApi:getLocalStr('SOLDIER_UPGRADE_STR3'),
		'font/gamefont.ttf',
		36)
	title:setTextColor(COLOR_TYPE.ORANGE)
	title:enableOutline(COLOROUTLINE_TYPE.ORANGE, 2)
	title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	title:setPosition(cc.p(bg_size.width / 2 - 60, bg_size.height / 2 + 160))
	bg:addChild(title)

	local textImg = ccui.ImageView:create('uires/ui/text/xinxingxiang.png')
	textImg:setPosition(cc.p(bg_size.width / 2 + 90, bg_size.height / 2 + 160))
	bg:addChild(textImg)

	-- play audio effect
	AudioMgr.playEffect("media/effect/soldier_newlevel.mp3", false)

	local level = self.role:getSoldierLv()
	local heroConf = self.role:getConfig('hero')
	local sid = heroConf.soldierId
	local sconf = GameData:getConfData('soldierlevel')
	local conf = sconf[sid]
	local quality = math.ceil(level/3)
	local interval = 160

	local nameBgImg = ccui.ImageView:create('uires/ui/common/common_bg_14.png')
	nameBgImg:setPosition(cc.p(bg_size.width / 2 - interval, bg_size.height / 2 + 70))
	nameBgImg:setScale9Enabled(true)
	nameBgImg:setContentSize(cc.size(129,38))
	bg:addChild(nameBgImg,9999)
	local size = nameBgImg:getContentSize()
	local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
    nameTx:setPosition(cc.p(size.width/2, size.height/2))
    nameTx:setColor(COLOR_QUALITY[quality + 1])
    nameTx:enableOutline(COLOROUTLINE_QUALITY, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setString(conf[level].name)
    nameBgImg:addChild(nameTx)

	local oriimg = ccui.ImageView:create('uires/ui/role/role_' .. conf[level].soldierIcon)
	oriimg:setPosition(cc.p(bg_size.width / 2 - interval + 20, bg_size.height / 2 - 30))
	bg:addChild(oriimg)

	local arrowsp = cc.Sprite:create()
	arrowsp:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2 - 30))
	bg:addChild(arrowsp, 9999)
	local arrowAni = self:createAnimation('arrow', 5)
	arrowsp:setVisible(true)
	arrowsp:runAction(cc.RepeatForever:create(cc.Animate:create(arrowAni)))

	local flashsp = cc.Sprite:create()
	flashsp:setPosition(cc.p(bg_size.width / 2, bg_size.height / 2 - 30))
	bg:addChild(flashsp, 9999)
	local flashAni = self:createAnimation('flash', 7)
    flashsp:setVisible(true)
    flashsp:runAction(cc.Sequence:create(
    	cc.Animate:create(flashAni), 
    	cc.Animate:create(arrowAni), 
    	cc.CallFunc:create(function()
			flashsp:removeFromParent()
			local quality1 = math.ceil((level + 1)/3)
			local nameBgImg1 = ccui.ImageView:create('uires/ui/common/common_bg_14.png')
			nameBgImg1:setScale9Enabled(true)
			nameBgImg1:setContentSize(cc.size(129,38))
			nameBgImg1:setPosition(cc.p(bg_size.width / 2 + interval, bg_size.height / 2 + 70))
			bg:addChild(nameBgImg1,9999)
			local lightImg = ccui.ImageView:create('uires/ui/common/common_light.png')
			lightImg:setPosition(cc.p(bg_size.width / 2 + interval - 1, bg_size.height / 2 + 70 - nameBgImg1:getContentSize().height/2))
			lightImg:setAnchorPoint(cc.p(0.5,1))
			bg:addChild(lightImg,9997)
			local size = nameBgImg1:getContentSize()
			local nameTx1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
		    nameTx1:setPosition(cc.p(size.width/2, size.height/2))
		    nameTx1:setColor(COLOR_QUALITY[quality1 + 1])
		    nameTx1:enableOutline(COLOROUTLINE_QUALITY, 1)
		    nameTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		    nameTx1:setAnchorPoint(cc.p(0.5,0.5))
		    nameTx1:setString(conf[level + 1].name)
		    nameBgImg1:addChild(nameTx1)
			local tarimg = ccui.ImageView:create('uires/ui/role/role_' .. conf[level + 1].soldierIcon)
			tarimg:setPosition(cc.p(bg_size.width / 2 + interval + 20, bg_size.height / 2 - 30))
			bg:addChild(tarimg)
			tarimg:setColor(cc.c3b(0, 0, 0))
			tarimg:runAction(cc.Sequence:create(
				cc.TintTo:create(0.5, cc.c3b(255, 255, 255)),
				cc.CallFunc:create(function ()
					print('new type func ..................')
					self.root:getChildByName('bg')
						:addClickEventListener(function (  )
							RoleMgr:hideSoldierUpgrade()
							if self.func ~= nil then
								self.func()
							end
						end)
				end)))
		end)))
end

function SoldierUpgradeUI:createAnimation(name, framecount)
	-- body
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
		animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
	return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
end

-- 播放小兵升级特效
function SoldierUpgradeUI:playXiaobingUpgradeEffect(img)
    local img = img
    local size1 = img:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_shengji_01')
    lvUp:setPosition(cc.p(size1.width/2,size1.height/2 + 50))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(10000)
    lvUp:setScale(1.25)
    --lvUp:setScale(1.2)
    img:addChild(lvUp)
    lvUp:getAnimation():playWithIndex(0, -1, 0)
   
    lvUp:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
		lvUp:removeFromParent()
	end)))
end
return SoldierUpgradeUI

