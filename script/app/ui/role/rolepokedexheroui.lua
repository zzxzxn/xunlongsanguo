local PokedexHeroUI = class("PokedexHeroUI", BaseUI)

function PokedexHeroUI:ctor(roleObj)
	self.uiIndex = GAME_UI.UI_POKEDEX_HERO
	self.roleObj = roleObj
end

function PokedexHeroUI:hideMySelf()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local bgPl = self.root:getChildByName("bg_pl")
	bgPl:stopAllActions()
	local scale = bgPl:getScaleX()
	bgPl:runAction(cc.RotateTo:create(0.5*scale, 90))
	bgPl:runAction(cc.MoveTo:create(0.5*scale,cc.p(275 + (winSize.width - 960)/2,winSize.height/2)))
	bgPl:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5*scale, 0.42),cc.CallFunc:create(function()
		RoleMgr:hidePokedexHero()
	end)))
end

function PokedexHeroUI:init()
	local bgPl = self.root:getChildByName("bg_pl")
	local bgImg = bgPl:getChildByName("bg_img")
	local kuangImg = bgPl:getChildByName("kuang_img")
	local winSize = cc.Director:getInstance():getVisibleSize()
	bgPl:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:hideMySelf()
		end
	end)
	bgImg:loadTexture(self.roleObj:getBigCardImg())
	local size = bgImg:getContentSize()
	local scaleX = winSize.width/size.height
	local scaleY = winSize.height/size.width
	if scaleX > scaleY then
		bgImg:setScale(scaleX)
	else
		bgImg:setScale(scaleY)
	end
	bgPl:setContentSize(cc.size(winSize.width,winSize.height))
	kuangImg:setContentSize(cc.size(winSize.height,winSize.width))
	-- bgPl:setPosition(cc.p(winSize.width/2,winSize.height/2))
	bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	kuangImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

	bgPl:setRotation(90)
	bgPl:setScale(0.42)
	bgPl:setPosition(cc.p(275 + (winSize.width - 960)/2,winSize.height/2))

	bgPl:runAction(cc.RotateTo:create(0.5, 0))
	bgPl:runAction(cc.ScaleTo:create(0.5, 1))
	bgPl:runAction(cc.MoveTo:create(0.5,cc.p(winSize.width/2,winSize.height/2)))
end

return PokedexHeroUI
