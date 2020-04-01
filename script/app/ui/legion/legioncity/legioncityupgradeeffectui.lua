local LegionCityUpgradeEffectUI = class("LegionCityUpgradeEffectUI", BaseUI)

function LegionCityUpgradeEffectUI:ctor(cityLevel)
  self.uiIndex = GAME_UI.UI_LEGION_CITY_UPGRAGE_EFFECT
  self.cityLevel = cityLevel
end

function LegionCityUpgradeEffectUI:init()
	local winSize = cc.Director:getInstance():getWinSize()
	local bg = self.root:getChildByName('bg')
	self:adaptUI(bg)

	local info_tx = bg:getChildByName('info_tx')
	info_tx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
	info_tx:setPosition(cc.p(winSize.width/2, 40))
	info_tx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    self:showEffect(bg, winSize)
    AudioMgr.playEffect("media/effect/soldier_newlevel.mp3", false)
end

function LegionCityUpgradeEffectUI:showEffect(bg, winSize)
	local titleImg = ccui.ImageView:create("uires/ui/text/tx_gxzcsj.png")
	titleImg:setPosition(cc.p(winSize.width / 2, winSize.height / 2 + 160))
	bg:addChild(titleImg)

	local level = 3
	local quality = math.ceil(level/3)
	local interval = 160

	local nameBgImg = ccui.ImageView:create('uires/ui/common/common_bg_14.png')
	nameBgImg:setPosition(cc.p(winSize.width / 2 - interval, winSize.height / 2 + 70))
	nameBgImg:setScale9Enabled(true)
	nameBgImg:setContentSize(cc.size(129,38))
	bg:addChild(nameBgImg,9999)
	local size = nameBgImg:getContentSize()
	local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
    nameTx:setPosition(cc.p(size.width/2, size.height/2))
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setString("Lv." .. self.cityLevel-1)
    nameBgImg:addChild(nameTx)

    local cityMainConf = GameData:getConfData('legioncitymain')
	local oriimg = ccui.ImageView:create('uires/ui/citycraft/' .. cityMainConf[self.cityLevel-1].url)
	local oriSize = oriimg:getContentSize()
	oriimg:setScale(140/oriSize.height)
	oriimg:setPosition(cc.p(winSize.width / 2 - interval, winSize.height / 2 - 30))
	bg:addChild(oriimg)

	local arrowsp = cc.Sprite:create()
	arrowsp:setPosition(cc.p(winSize.width / 2, winSize.height / 2 - 30))
	bg:addChild(arrowsp, 9999)
	local arrowAni = self:createAnimation('arrow', 5)
	arrowsp:setVisible(true)
	arrowsp:runAction(cc.RepeatForever:create(cc.Animate:create(arrowAni)))

	local flashsp = cc.Sprite:create()
	flashsp:setPosition(cc.p(winSize.width / 2, winSize.height / 2 - 30))
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
			nameBgImg1:setPosition(cc.p(winSize.width / 2 + interval, winSize.height / 2 + 70))
			bg:addChild(nameBgImg1,9999)
			local lightImg = ccui.ImageView:create('uires/ui/common/common_light.png')
			lightImg:setPosition(cc.p(winSize.width / 2 + interval - 1, winSize.height / 2 + 70 - nameBgImg1:getContentSize().height/2))
			lightImg:setAnchorPoint(cc.p(0.5,1))
			bg:addChild(lightImg,9997)
			local size = nameBgImg1:getContentSize()
			local nameTx1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
		    nameTx1:setPosition(cc.p(size.width/2, size.height/2))
		    nameTx1:setColor(COLOR_TYPE.GREEN)
		    nameTx1:enableOutline(COLOR_TYPE.BLACK, 1)
		    nameTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		    nameTx1:setAnchorPoint(cc.p(0.5,0.5))
		    nameTx1:setString("Lv." .. self.cityLevel)
		    nameBgImg1:addChild(nameTx1)
			local tarimg = ccui.ImageView:create('uires/ui/citycraft/' .. cityMainConf[self.cityLevel].url)
			local tarSize = tarimg:getContentSize()
			tarimg:setScale(140/tarSize.height)
			tarimg:setPosition(cc.p(winSize.width / 2 + interval, winSize.height / 2 - 30))
			bg:addChild(tarimg)
			tarimg:setColor(cc.c3b(0, 0, 0))
			tarimg:runAction(cc.Sequence:create(
				cc.TintTo:create(0.5, cc.c3b(255, 255, 255)),
				cc.CallFunc:create(function ()
					self.root:getChildByName('bg')
						:addClickEventListener(function (  )
							LegionMgr:hideLegionCityUpgradeEffectUI()
						end)
				end)))
		end)))
end

function LegionCityUpgradeEffectUI:createAnimation(name, framecount)
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
		animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
	return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
end

return LegionCityUpgradeEffectUI