
local SettingExchangeUI = class("SettingExchangeUI", BaseUI)

function SettingExchangeUI:ctor(obj,callback)
	self.uiIndex = GAME_UI.UI_SETTINGEXCHANGE
	self.callback = callback
end

function SettingExchangeUI:onShow()
	self:updatePanel()
end

function SettingExchangeUI:updatePanel()

end

function SettingExchangeUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

	local panel = bg2:getChildByName('contentPanel')
	
	--title
	local infoTx = panel:getChildByName("tips")
	infoTx:setString(GlobalApi:getLocalStr("SETTING_EXCHANGE_TITLE"))
	
	--exchange editbox
	self.nameEditbox = cc.EditBox:create(cc.size(430, 42), 'uires/ui/common/common_bg_10.png')	
	self.nameEditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameEditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.nameEditbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.nameEditbox:setPlaceHolder('')
    self.nameEditbox:setPosition(224, 98)
    self.nameEditbox:setFontColor(cc.c3b(255, 255, 255))
    --self.nameEditbox:setMaxLength(7)
    self.nameEditbox:setFont('font/gamefont.ttf',26)
    self.nameEditbox:setText("")
    panel:addChild(self.nameEditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
    self.nameTx:setPosition(cc.p(20, 98))
    self.nameTx:setColor(COLOR_TYPE.WHITE)
    self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0,0.5))
    self.nameTx:setName('name_tx')
    panel:addChild(self.nameTx)
    -- self.nameTx:setString(UserData:getUserObj():getName())

    local maxLen = 32
    local oldStr = UserData:getUserObj():getName()
    self.nameEditbox:registerScriptEditBoxHandler(function(event,pSender)
		if event == "began" then
			self.nameEditbox:setText(self.nameTx:getString())
			oldStr = UserData:getUserObj():getName()
			self.nameTx:setString('')
		elseif event == "ended" then
			local str = self.nameEditbox:getText()
			local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
			-- local isOk = GlobalApi:checkSensitiveWords(str)
			-- if not isOk then
			-- 	promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
			-- 	self.nameTx:setString(oldStr)
			-- else
				self.nameTx:setString(str)
			-- end
			self.nameEditbox:setText('')
		end
    end)
	
	--ok button
	local sureBtn = panel:getChildByName('sure_btn')
	local sureTx = sureBtn:getChildByName('tx')
	sureTx:setString(GlobalApi:getLocalStr('STR_OK'))
	sureBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:SendExchangeStr(self.nameTx:getString())
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--cancel button
	local cancelBtn = panel:getChildByName('cancel_btn')
	local cancelTx = cancelBtn:getChildByName('tx')
	cancelTx:setString(GlobalApi:getLocalStr('STR_CANCEL'))
	cancelBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingExchange()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--close button
	--[[
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingExchange()
	    end
	end)
	--]]
	bg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingExchange()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	self:updatePanel()
	
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
end

function SettingExchangeUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bg2")
     panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
     panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
end

function SettingExchangeUI:SendExchangeStr(str)
	print("SendExchangeStr "..str)
	
	if str and str ~= '' then
		local args = {}
		args.key=str
		MessageMgr:sendPost('exchange_cdkey','user',json.encode(args),function (response)
							
							local code = response.code
							if code == 0 then
			    				SettingMgr:hideSettingExchange()
								local awards = response.data.awards
								if awards then
									GlobalApi:parseAwardData(awards)
									GlobalApi:showAwardsCommon(awards,nil,nil,true)
								end
							elseif code == 101 then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('SETTING_EXCHANGE_VALID_1'), COLOR_TYPE.RED)
							elseif code == 102 then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('SETTING_EXCHANGE_ALREADY_USE'), COLOR_TYPE.RED)
                            elseif code == 103 then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('SETTING_EXCHANGE_ALREADY_USE2'), COLOR_TYPE.RED)
							else
								promptmgr:showSystenHint(GlobalApi:getLocalStr('SETTING_EXCHANGE_VALID_1'), COLOR_TYPE.RED)
							end
						end)
	else
		promptmgr:showSystenHint(GlobalApi:getLocalStr('SETTING_EXCHANGE_VALID_2'), COLOR_TYPE.RED)
	end
	
end

return SettingExchangeUI