local ClassMainScene = require('script/app/scene/mainscene')

local LogoScene = class('LogoScene')

-- 构造函数
function LogoScene:ctor()
	self.scene = cc.Scene:create()
	local winSize = cc.Director:getInstance():getWinSize()
	self.layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
	self.scene:addChild(self.layer)

	local platform = CCApplication:getInstance():getTargetPlatform()

	local splashRes = ""
	if platform == kTargetAndroid or platform == kTargetIphone then
		splashRes = SdkData:SDK_getSplash()
	else
		splashRes = "logo.png"
	end
	
	local widget = ccui.Widget:create()
	widget:setOpacity(0)
	widget:setCascadeOpacityEnabled(true)
	widget:setPosition(cc.p(winSize.width * 0.5, winSize.height * 0.5))
	self.layer:addChild(widget)

	local imgBG = cc.Sprite:create("uires/logo/health.png")
	imgBG:setAnchorPoint(cc.p(0.5,0.5))
	imgBG:setLocalZOrder(-1)
	imgBG:setPosition(cc.p(0, 0))
	local size = imgBG:getContentSize()
	-- imgBG:setScaleY(winSize.height/size.height)
	-- imgBG:setScaleX(winSize.width/size.width)

	-- logo图标捉妖封神录
	local logoRes = ""
	if platform == kTargetAndroid or platform == kTargetIphone then
		logoRes = SdkData:SDK_getLogoInfo()
	else
		logoRes = "fjmz.png"
	end

	local title = cc.Sprite:create('uires/logo/'..logoRes)
	title:setAnchorPoint(cc.p(0.5,0.5))
	title:setLocalZOrder(2)
	title:setPosition(cc.p(0,0))

	-- 版权信息
	local info = cc.Sprite:create("uires/logo/info.png")
	info:setAnchorPoint(cc.p(0.5,0))
	info:setLocalZOrder(1)
	info:setPosition(cc.p(0,-winSize.height * 0.5))

	-- 十六字社会主义核心价值观
	local slogan = cc.Sprite:create("uires/logo/slogan.png")
	slogan:setAnchorPoint(cc.p(0.5,0))
	slogan:setLocalZOrder(1)
	slogan:setPosition(cc.p(0,-winSize.height * 0.5 + info:getContentSize().height))

	widget:addChild(imgBG)
	widget:addChild(title)
	widget:addChild(info)
	widget:addChild(slogan)

	-- 通过接口判断是否添加版号信息
	if platform == kTargetAndroid or platform == kTargetIphone then
		info:setVisible(SdkData:SDK_getInfo())
	else
		info:setVisible(true)
	end

	widget:runAction(cc.Sequence:create( cc.DelayTime:create(0.1),
										cc.FadeIn:create(0.5),
										cc.DelayTime:create(1.0),
										cc.FadeOut:create(0.5),
										cc.DelayTime:create(0.1),
										cc.CallFunc:create(function ()
											print("       splashRes   !!!!!!!!!!!!   ",splashRes)
											if splashRes == "" then
												self:exit()
											else
												local res = 'uires/logo/'..splashRes
												local logo = cc.Sprite:create(res)
												logo:setPosition(cc.p(winSize.width * 0.5, winSize.height * 0.5))
												logo:setOpacity(0)
												self.layer:addChild(logo)
												local delayAct = cc.DelayTime:create(0.3)
												local fadeinAct = cc.FadeIn:create(0.5)
												local delayAct2 = cc.DelayTime:create(1.0)
												local fadeoutAct = cc.FadeOut:create(0.5)
												local delayAct3 = cc.DelayTime:create(0.1)
												local sequence = cc.Sequence:create(delayAct, fadeinAct, delayAct2, fadeoutAct, delayAct3, cc.CallFunc:create(self.exit))
												logo:runAction(sequence)
											end
										end)))
end

function LogoScene:enter()
	--cc.Director:getInstance():runWithScene(self.scene)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.scene)
    else
        cc.Director:getInstance():runWithScene(self.scene)
    end
end

function LogoScene:exit()
	local mainScene = ClassMainScene.new()
	mainScene:enter()
end

return LogoScene