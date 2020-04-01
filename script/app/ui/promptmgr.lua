cc.exports.promptmgr = {
	mainNode = nil,

	messageboxNode = nil,
	messageboxWidget = {},
	messageEntry = nil,

	systemhintNode = nil,
	systemhintWidget = {},

	attributeNode = nil,

	connectwaitingBg = nil,
	connectwaitingAni = nil,

	guajiNode = nil,
}

cc.exports.PROMPT_TYPE = {
	ATTRIBUTE_UPDATE = 1,
	SYSTEM_HINT = 2,
	MESSAGE_BOX = 3,
	CONNECT_WAITING = 4,
	GUAJI_INFO = 5,
}

cc.exports.MESSAGE_BOX_TYPE = {
	MB_OK = 1,
	MB_CANCEL = 2,
	MB_OK_CANCEL = 3,
}

function promptmgr:init()
	self.mainNode = cc.Node:create()
	return self.mainNode
end

-- str内容 或者富态文本
-- mbtype 类型
-- okfunc 确定按钮回调
-- oktext 确定按钮字
-- canceltext 退出按钮字
-- cancelfunc 退出按钮回调
-- noLongerShow 不再提示
function promptmgr:showMessageBox(str, mbtype, okfunc, oktext, canceltext, cancelfunc, noLongerShow)
	-- if self.mainNode == nil then
	-- 	self.mainNode = UIManager:getPrompt()
	-- end
	if noLongerShow then
		local uid = UserData:getUserObj():getUid() or 0
		local skip = cc.UserDefault:getInstance():getIntegerForKey(uid .. "_" .. noLongerShow, 0)
		if skip == 1 and okfunc then
			self.okfunc = nil
			self.cancelfunc = nil
			self.noLongerShow = nil
			okfunc()
			okfunc = nil
			return
		end
	end

	self.okfunc = okfunc
	self.cancelfunc = cancelfunc
	self.noLongerShow = noLongerShow

	if self.messageboxNode == nil then
		self.messageboxNode = cc.CSLoader:createNode('csb/messagebox.csb')

		local bgImg = self.messageboxNode:getChildByName('messagebox_bg_img')
		--bgImg:addClickEventListener(function ()
			-- hide ...only hide
			-- self:hideMessageBox()
		--end)
		local messageboxImg = bgImg:getChildByName('messagebox_img')
		local closeBtn = messageboxImg:getChildByName('close_btn')
		closeBtn:setVisible(false)
		-- closeBtn:addClickEventListener(function ()
		-- 	-- hide ...only hide
		-- 	self:hideMessageBox()
		-- end)

		local winSize = cc.Director:getInstance():getWinSize()
		bgImg:setScale9Enabled(true)
		bgImg:setContentSize(winSize)
		bgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
		messageboxImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
		self.neiBgImg = messageboxImg:getChildByName('nei_bg_img')

		local widgets = {}

		widgets.okBtn1 = self.neiBgImg:getChildByName('ok_1_btn')
		widgets.okBtn2 = self.neiBgImg:getChildByName('ok_2_btn')

		widgets.okTx1 = widgets.okBtn1:getChildByName('info_tx')
		widgets.okTx2 = widgets.okBtn2:getChildByName('info_tx')
		widgets.okTx1:setString(GlobalApi:getLocalStr("STR_OK2"))
		widgets.okTx2:setString(GlobalApi:getLocalStr("STR_OK2"))

		widgets.cancelBtn = self.neiBgImg:getChildByName('cancel_btn')
		widgets.cancelTx = widgets.cancelBtn:getChildByName('info_tx')
		widgets.cancelTx:setString(GlobalApi:getLocalStr("STR_CANCEL_1"))

		widgets.checkBoxBtn = self.neiBgImg:getChildByName('checkbox')
		local checkboxLabel = widgets.checkBoxBtn:getChildByName('label')
		checkboxLabel:setString(GlobalApi:getLocalStr("NO_LONGER_SHOW"))

		widgets.okBtn1:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if self.okfunc ~= nil then
					if self.noLongerShow and self.messageboxWidget.checkBoxBtn:isSelected() then
						local uid = UserData:getUserObj():getUid() or 0
						cc.UserDefault:getInstance():setIntegerForKey(uid .. "_" .. self.noLongerShow, 1)
					end
					local scheduler = cc.Director:getInstance():getScheduler()
					if self.messageEntry then
						scheduler:unscheduleScriptEntry(self.messageEntry)
					end
					local okfunc = self.okfunc
					self.okfunc = nil
					self.noLongerShow = nil
					self.messageEntry = scheduler:scheduleScriptFunc(function ()
							okfunc()
							scheduler:unscheduleScriptEntry(self.messageEntry)
							self.messageEntry = nil
						end, 0.01, false)
				end
				if self.cancelfunc then
					self.cancelfunc = nil
				end
				self:hideMessageBox()
			end
		end)

		widgets.okBtn2:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
	        	if self.okfunc ~= nil then
					local scheduler = cc.Director:getInstance():getScheduler()
					if self.messageEntry then
						scheduler:unscheduleScriptEntry(self.messageEntry)
					end
					local okfunc = self.okfunc
					self.okfunc = nil
					self.noLongerShow = nil
					self.messageEntry = scheduler:scheduleScriptFunc(function ()
							okfunc()
							scheduler:unscheduleScriptEntry(self.messageEntry)
							self.messageEntry = nil
						end, 0.01, false)
				end
				if self.cancelfunc then
					self.cancelfunc = nil
				end
				self:hideMessageBox()
			end
		end)

		widgets.cancelBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if self.cancelfunc ~= nil then
					local scheduler = cc.Director:getInstance():getScheduler()
					if self.messageEntry then
						scheduler:unscheduleScriptEntry(self.messageEntry)
					end
					local cancelfunc = self.cancelfunc
					self.cancelfunc = nil
					self.noLongerShow = nil
					self.messageEntry = scheduler:scheduleScriptFunc(function ()
							cancelfunc()
							scheduler:unscheduleScriptEntry(self.messageEntry)
							self.messageEntry = nil
						end, 0.01, false)
				end
				if self.okfunc then
					self.okfunc = nil
				end
				self:hideMessageBox()
			end
		end)

		self.messageboxWidget = widgets
		self.mainNode:addChild(self.messageboxNode, PROMPT_TYPE.MESSAGE_BOX)
	end

	if type(str) == 'string' then
		local msg = self.neiBgImg:getChildByTag(9999)
		if not msg then
			msg = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
			msg:setAnchorPoint(cc.p(0.5, 0.5))
			msg:setPosition(cc.p(262, 216))
			msg:setMaxLineWidth(424)
			msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			msg:setColor(COLOR_TYPE.ORANGE)
			msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
			self.neiBgImg:addChild(msg,1,9999)
		end
		msg:setString(str)
		local msg1 = self.neiBgImg:getChildByTag(9998)
		if msg1 then
			msg1:removeFromParent()
		end
	else
		local msg = self.neiBgImg:getChildByTag(9998)
		if msg then
			msg:removeFromParent()
		end
		print('=============xxxx',str)
		self.neiBgImg:addChild(str,1,9998)
		local msg1 = self.neiBgImg:getChildByTag(9999)
		if msg1 then
			msg1:setString('')
		end
	end
	
	local mb_type = mbtype
	if mb_type == nil then
		mb_type = MESSAGE_BOX_TYPE.MB_OK
	end

	if oktext then
		self.messageboxWidget.okTx1:setString(oktext)
		self.messageboxWidget.okTx2:setString(oktext)
	else
		self.messageboxWidget.okTx1:setString(GlobalApi:getLocalStr("STR_OK2"))
		self.messageboxWidget.okTx2:setString(GlobalApi:getLocalStr("STR_OK2"))
	end

	if canceltext then
		self.messageboxWidget.cancelTx:setString(canceltext)
	else
		self.messageboxWidget.cancelTx:setString(GlobalApi:getLocalStr("STR_CANCEL_1"))
	end
	
	if noLongerShow then
		self.messageboxWidget.checkBoxBtn:setVisible(true)
		self.messageboxWidget.checkBoxBtn:setSelected(false)
	else
		self.messageboxWidget.checkBoxBtn:setVisible(false)
	end

	if mb_type == MESSAGE_BOX_TYPE.MB_OK then
		self.messageboxWidget.okBtn1:setVisible(false)
		self.messageboxWidget.okBtn2:setVisible(true)
		self.messageboxWidget.cancelBtn:setVisible(false)
	elseif mb_type == MESSAGE_BOX_TYPE.MB_OK_CANCEL then
		self.messageboxWidget.okBtn1:setVisible(true)
		self.messageboxWidget.okBtn2:setVisible(false)
		self.messageboxWidget.cancelBtn:setVisible(true)
	end
	self.messageboxNode:setVisible(true)
end

function promptmgr:hideMessageBox()
	if self.messageboxNode ~= nil then
		self.messageboxNode:setVisible(false)
	end
	-- self.messageboxWidget.okBtn1:addClickEventListener(nil)
	-- self.messageboxWidget.okBtn2:addClickEventListener(nil)
	-- self.messageboxWidget.cancelBtn:addClickEventListener(nil)
end

function promptmgr:showSystenHint(str, color)
	if self.systemhintNode == nil then
		self.systemhintNode = cc.Node:create()
		-- local promptBg = ccui.ImageView:create()
		-- promptBg:loadTexture('uires/ui/common/prompt.png')
		-- promptBg:setScale9Enabled(true)
		-- promptBg:setCascadeOpacityEnabled(true)
		-- local label = cc.Label:createWithTTF('', 'font/gamefont.ttf', 20)
		-- label:setAnchorPoint(cc.p(0.5, 0.5))
		-- label:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		-- local winsize = cc.Director:getInstance():getWinSize()
		-- promptBg:setPosition(cc.p(winsize.width*0.5, winsize.height*0.5 + 100))
		-- promptBg:addChild(label)

		-- local frame = {}
		-- frame.bg = promptBg
		-- frame.label = label
		-- self.systemhintWidget = frame

		-- self.systemhintNode:addChild(promptBg)
		self.mainNode:addChild(self.systemhintNode, PROMPT_TYPE.SYSTEM_HINT)
	end

	local promptBg = ccui.ImageView:create()
	promptBg:loadTexture('uires/ui/common/prompt.png')
	local psz = promptBg:getContentSize()

	local rt = xx.RichText:create()
	local rti1 = xx.RichTextImage:create('uires/ui/common/paw.png')
	local rtl = xx.RichTextLabel:create(str, 28)
	if color == nil then
		rtl:setColor(COLOR_TYPE.WHITE)
	else
		rtl:setColor(color)
	end
	rtl:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	rtl:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
	local rti2 = xx.RichTextImage:create('uires/ui/common/paw.png')
	rti2:setScaleX(-1)
	rt:addElement(rti1)
	rt:addElement(rtl)
	rt:addElement(rti2)
	rt:setAlignment('middle')
	rt:setVerticalAlignment('middle')
	rt:format(true)
	rt:setContentSize(rt:getElementsSize())

	-- local label = cc.Label:createWithTTF(str, 'font/gamefont.ttf', 28)
	-- label:setAnchorPoint(cc.p(0.5, 0.5))
	-- label:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	-- label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	local sz = cc.Director:getInstance():getWinSize()
	promptBg:setPosition(cc.p(sz.width / 2, sz.height / 2 + 20))
	-- label:setPosition(cc.p(psz.width / 2, psz.height / 2))
	rt:setPosition(cc.p(psz.width / 2, psz.height / 2))
	-- if color == nil then
	-- 	label:setTextColor(COLOR_TYPE.WHITE)
	-- else
	-- 	label:setTextColor(color)
	-- end
	-- promptBg:addChild(label)
	promptBg:addChild(rt)
	promptBg:runAction(cc.Sequence:create(
		cc.MoveBy:create(1.5, cc.p(0, 100)), 
		cc.CallFunc:create(function (  )
			promptBg:removeFromParent()
		end)))
	self.systemhintNode:addChild(promptBg)

	self.systemhintNode:setVisible(true)
end

function promptmgr:hideSystemHint()
	if self.systemhintNode ~= nil then
		self.systemhintNode:setVisible(false)
	end
end

function promptmgr:showAttributeUpdate(arrays)
	-- if self.mainNode == nil then
	-- 	self.mainNode = UIManager:getPrompt()
	-- end

	if self.attributeNode == nil then
		self.attributeNode = cc.Node:create()
		self.mainNode:addChild(self.attributeNode, PROMPT_TYPE.ATTRIBUTE_UPDATE)
	else
		self.attributeNode:removeAllChildren()
	end

	local winSize = cc.Director:getInstance():getWinSize()
	local defaultZ = 99
	for i,v in ipairs(arrays) do
		-- local label = cc.Label:createWithTTF('', 'font/gamefont.ttf', 28)
		-- label:setString(v[1])
		-- label:setTextColor(COLOR_TYPE[v[2]])
		-- label:enableOutline(COLOROUTLINE_TYPE[v[2]], 2)

		-- self.attributeNode:addChild(label)
		self.attributeNode:addChild(v)
		v:setPosition(cc.p(winSize.width / 2, winSize.height / 2 - 100))
		v:setOpacity(50)
		v:setScale(0)
		v:setLocalZOrder(defaultZ - i)
		local action1 = cc.Spawn:create(cc.FadeTo:create(0.3, 255), cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1)))
		local action2 = cc.Sequence:create(cc.DelayTime:create(1.5), cc.FadeTo:create(0.5, 0))
		local action3 = cc.Spawn:create(cc.MoveBy:create(2, cc.p(0, 300)), action2)
		v:runAction(cc.Sequence:create(cc.DelayTime:create(i * 0.25), 
			action1, 
			cc.DelayTime:create(0.1), 
			action3,
			cc.FadeTo:create(0.1, 0),
			cc.CallFunc:create(function ()
				v:removeFromParent()
			end)))
	end

	self.attributeNode:setVisible(true)
end

function promptmgr:hideAttributeUpdate()
	if self.attributeNode ~= nil then
		self.attributeNode:setVisible(false)
	end
end

function promptmgr:showConnectWaiting()
	local winSize = cc.Director:getInstance():getWinSize()
	if self.connectwaitingBg == nil then
		self.connectwaitingBg = ccui.ImageView:create("uires/ui/common/bg_gray2.png")
		self.connectwaitingBg:setTouchEnabled(true)
		self.connectwaitingBg:setCascadeOpacityEnabled(true)
		self.connectwaitingBg:setScale9Enabled(true)
		self.connectwaitingBg:setContentSize(winSize)
		self.connectwaitingBg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
		self.mainNode:addChild(self.connectwaitingBg, PROMPT_TYPE.CONNECT_WAITING)
	end
	self.connectwaitingBg:setOpacity(0)
	self.connectwaitingBg:setVisible(true)
	self.connectwaitingBg:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function ()
		self.connectwaitingBg:setOpacity(255)
		if self.connectwaitingAni == nil then
			self.connectwaitingAni = GlobalApi:createLittleLossyAniByName("wait_connect")
			self.connectwaitingAni:setScale(0.75)
			self.connectwaitingAni:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
			self.connectwaitingBg:addChild(self.connectwaitingAni)

			local label = ccui.Text:create()
			label:setAnchorPoint(cc.p(0, 1))
	        label:setFontName("font/gamefont.ttf")
	        label:setFontSize(20)
	        label:setTextColor(COLOR_TYPE.GRAY)
	        label:setString(GlobalApi:getLocalStr("STR_CONNECTING"))
	        label:setPosition(cc.p(winSize.width*0.5 + 50, winSize.height*0.5 - 50))
			self.connectwaitingBg:addChild(label)
		end
		self.connectwaitingAni:getAnimation():playWithIndex(0, -1, 1)
	end)))
end

function promptmgr:hideConnectWaiting()
	if self.connectwaitingBg ~= nil then
		self.connectwaitingBg:stopAllActions()
		self.connectwaitingBg:setVisible(false)
		if self.connectwaitingAni ~= nil then
			self.connectwaitingAni:getAnimation():gotoAndPause(0)
		end
	end
end

-- OpenTextPromptPanel
function promptmgr:showAttributeUpdate_v2(widgets)
	local widgetCount = #widgets
	local interval = 35

	if self.guajiNode == nil then
		self.guajiNode = cc.Node:create()
		local winSize = cc.Director:getInstance():getWinSize()
		self.guajiNode:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
		self.guajiNode:setCascadeColorEnabled(false)
		self.mainNode:addChild(self.guajiNode, PROMPT_TYPE.GUAJI_INFO)
	end

	for index, w in ipairs(widgets) do
		-- local pPromptTx = cc.Label:createWithTTF(w, 'font/gamefont.ttf', 24)
		w:setAnchorPoint( cc.p(0.5,0.5) )
		w:setPosition( cc.p( 0 , - (widgetCount / 2) * interval ) )
		w:setOpacity(0)
		w:setScaleX(3)
		w:setScaleY(1)

		w:runAction(
			cc.Sequence:create(
				cc.FadeIn:create(0.1 * index), 
				cc.Spawn:create(
					cc.ScaleTo:create(0.15, 1), 
					cc.MoveBy:create(0.15, cc.p(0, interval * index))), 
				cc.DelayTime:create(1), 
				cc.FadeOut:create(0.15 * index),
				cc.CallFunc:create(function (  )
					self.guajiNode:removeAllChildren()
				end)))

		self.guajiNode:addChild(w)
	end
end

function promptmgr:hideAttributeUpdate_v2()
	if self.guajiNode ~= nil then
		self.guajiNode:setVisible(false)
	end
end

function promptmgr:clear(promtp_type)
	if promtp_type == nil then
		self.mainNode:removeAllChildren()
		self.mainNode = nil
		self.messageboxNode = nil
		self.messageboxWidget = {}
		self.systemhintNode = nil
		-- self.systemhintWidget = {}
		self.attributeNode = nil
		self.connectwaitingBg = nil
		self.connectwaitingAni = nil
		self.guajiNode = nil
		return
	end

	if promtp_type == PROMPT_TYPE.MESSAGE_BOX then
		self.messageboxNode:removeFromParent()
		self.messageboxNode = nil
		self.messageboxWidget = {}
		return
	end

	if promtp_type == PROMPT_TYPE.SYSTEM_HINT then
		self.systemhintNode:removeFromParent()
		self.systemhintNode = nil
		-- self.systemhintWidget = {}
		return
	end

	if promtp_type == PROMPT_TYPE.ATTRIBUTE_UPDATE then
		self.attributeNode:removeFromParent()
		self.attributeNode = nil
		return
	end

	if promtp_type == PROMPT_TYPE.CONNECT_WAITING then
		self.connectwaitingBg:removeFromParent()
		self.connectwaitingBg = nil
		self.connectwaitingAni = nil
		return
	end

	if promtp_type == PROMPT_TYPE.GUAJI_INFO then
		self.guajiNode:removeFromParent()
		self.guajiNode = nil
	end
end


function promptmgr:stopServerTip(url,CallFunc)
	local winSize = cc.Director:getInstance():getWinSize()
	self.stop_server = cc.CSLoader:createNode('csb/stop_server.csb')
	self.stop_server:setAnchorPoint(0.5,0.5)
	self.stop_server:setPosition(cc.p(winSize.width/2,winSize.height/2))
	self.Image_gray = self.stop_server:getChildByName("Image_gray")
	self.Image_bg = self.Image_gray:getChildByName("Image_bg")
	self.Image_content = self.Image_bg:getChildByName("Image_content")
	self.Btn_close = self.Image_bg:getChildByName("Btn_close")
	self.Btn_close:addClickEventListener(function (sender)
		self.stop_server:removeFromParent()
	end)	


	local targetPlatform = CCApplication:getInstance():getTargetPlatform()
    if targetPlatform ~= kTargetWindows then 
        local webView = ccexp.WebView:create()
        webView:addTo(self.Image_content)
        webView:setPosition(cc.p(-10, -5))
        -- webView:setScalesPageToFit(true)
        webView:setContentSize(720, 480)
        webView:setAnchorPoint(0, 0)
        webView:loadURL(url)
        -- webview:reload()
        self.wv = webView

    end 

    self.mainNode:addChild(self.stop_server)
    if CallFunc then
    	CallFunc()
    end
end

