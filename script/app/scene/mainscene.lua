local MainScene = class('MainScene')

-- 构造函数
function MainScene:ctor()
	self.scene = cc.Scene:create()
	self.mainNode = cc.Node:create()
	self.scene:addChild(self.mainNode, 1)

	if cc.Application:getInstance():getTargetPlatform() == kTargetAndroid then
		local listener = cc.EventListenerKeyboard:create()
		listener:registerScriptHandler(function (keyCode, event)
			if keyCode == cc.KeyCode.KEY_BACK then
				self:showOrHideQuitGame()
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		self.mainNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.mainNode)
	end

	local serverList = GameData:getConfData("local/serverlistplatform")
	local url = serverList[SdkData:getServerListID()].DeviceActiveUrl.."?"..SdkData:getLoginParams()
	print("========DeviceActiveUrl==========>",url)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	xhr:registerScriptHandler(function()
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)
	xhr:send()

	self.scene:onNodeEvent("enter", function ()
		self:onEnter()
	end)

	-- self.scene:onNodeEvent("exit", function ()
	-- 	SdkData:trackLogout()
	-- end)
end

function MainScene:enter()
	cc.Director:getInstance():replaceScene(self.scene)
end

function MainScene:onEnter()    
	-- 临时修复0.3.0.0版本动态更新bug,下次大版本可以删除
	if Game.loadScriptAgain then 
		Game:loadScriptAgain()
	end
	UIManager:init(self.scene, self.mainNode)

	LoginMgr:showLogin()
	LoginMgr:showCreateName()
end

function MainScene:createQuitGameUI()
	
end

function MainScene:showOrHideQuitGame()
	if SdkData:SDK_exitGame() == true then
		return
	end

	if self.quitNode == nil then
		self.quitNode = cc.CSLoader:createNode("csb/quitgame.csb")
		local bgImg = self.quitNode:getChildByName('messagebox_bg_img')
		local messageboxImg = bgImg:getChildByName('messagebox_img')
		local closeBtn = messageboxImg:getChildByName('close_btn')
		closeBtn:setVisible(false)
		local winSize = cc.Director:getInstance():getWinSize()
		bgImg:setScale9Enabled(true)
		bgImg:setContentSize(winSize)
		bgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
		messageboxImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
		local neiBgImg = messageboxImg:getChildByName('nei_bg_img')
		local okBtn1 = neiBgImg:getChildByName('ok_1_btn')
		local okBtn2 = neiBgImg:getChildByName('ok_2_btn')
		okBtn2:setVisible(false)
		local cancelBtn = neiBgImg:getChildByName('cancel_btn')
		local okTx1 = okBtn1:getChildByName('info_tx')
		okTx1:setString(GlobalApi:getLocalStr("STR_OK2"))
		local cancelTx = cancelBtn:getChildByName('info_tx')
		cancelTx:setString(GlobalApi:getLocalStr("STR_CANCEL_1"))
		okBtn1:addClickEventListener(function ()
			cc.Director:getInstance():endToLua()
		end)
		cancelBtn:addClickEventListener(function ()
			self.quitNode:removeFromParent()
			self.quitNode = nil
		end)
		local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("STR_QUIT_GAME"), "font/gamefont.ttf", 25)
		msg:setAnchorPoint(cc.p(0.5, 0.5))
		msg:setPosition(cc.p(262, 216))
		msg:setMaxLineWidth(424)
		msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		msg:setColor(COLOR_TYPE.ORANGE)
		msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
		msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
		neiBgImg:addChild(msg)
		self.scene:addChild(self.quitNode)
		self.quitNode:setLocalZOrder(999)
	end
end

return MainScene