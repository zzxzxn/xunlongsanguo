
local SettingChangeNameUI = class("SettingChangeNameUI", BaseUI)

function SettingChangeNameUI:ctor(ntype)
	self.uiIndex = GAME_UI.UI_SETTINGCHANGENAME
	self.ntype = ntype
end

function SettingChangeNameUI:onShow()
	--self:updatePanel()
end

function SettingChangeNameUI:updatePanel()

end

function SettingChangeNameUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

	local title_img = bg2:getChildByName('title_img')
	local titleTx = title_img:getChildByName('tx')
	titleTx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN1'))


	local panel = bg2:getChildByName('contentPanel')
	self.nameEditbox = cc.EditBox:create(cc.size(234, 58), 'uires/ui/common/bg1_alpha.png')
    self.nameEditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameEditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.nameEditbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.nameEditbox:setPlaceHolder('')
    self.nameEditbox:setPosition(130, 20)
    self.nameEditbox:setFontColor(cc.c3b(255, 255, 255))
    self.nameEditbox:setMaxLength(50)
    self.nameEditbox:setFont('font/gamefont.ttf',27)
    self.nameEditbox:setText('')
    panel:addChild(self.nameEditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 27)
    self.nameTx:setPosition(cc.p(130, 20))
    self.nameTx:setColor(cc.c3b(255, 255, 255))
    -- self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    -- self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx:setName('name_tx')
    panel:addChild(self.nameTx)
    self.nameTx:setString(UserData:getUserObj():getName())

    local maxLen = 7
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
			local isOk,str1 = GlobalApi:checkSensitiveWords(str)
			if not isOk then
				-- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
				self.nameTx:setString(str1 or oldStr or '')
			else
				self.nameTx:setString(str)
			end
			self.nameEditbox:setText('')
		end
    end)
	
	--rendom name
	local randomBtn = panel:getChildByName('randomBtn')
	randomBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			-- self.nameEditbox:setText(GlobalApi:RandomName())
			self.nameEditbox:setText('')
			print('==============',GlobalApi:RandomName())
			self.nameTx:setString(GlobalApi:RandomName())
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--ok button
	local sureBtn = panel:getChildByName('sure_btn')
	local sureTx = sureBtn:getChildByName('tx')
	sureTx:setString(GlobalApi:getLocalStr('STR_OK'))
	sureBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:SendNewName(self.nameTx:getString())
			AudioMgr.PlayAudio(11)
	    end
	end)

	local cancelBtn = panel:getChildByName('cancel_btn')
	local cancelTx = cancelBtn:getChildByName('tx')
	cancelTx:setString(GlobalApi:getLocalStr('STR_CANCEL'))
	cancelBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingChangeName()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--[[
	local closeBtn = settingImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingChangeName()
	    end
	end)
    --]]
	
	if not self.ntype then
		bg1:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				SettingMgr:hideSettingChangeName()
				AudioMgr.PlayAudio(11)
		    end
		end)
	end
	--self:updatePanel()
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
    self:guideSpecialInitHandle()
end

function SettingChangeNameUI:ActionClose(call)
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

function SettingChangeNameUI:SendNewName(name)
	print("SendNewName "..name)
	if name and name ~= '' then
		local function sendToServer(cost)
			if name ~= UserData:getUserObj():getName() then
				local args = {}
				args.name=name
				args.cash=cost
				MessageMgr:sendPost('set_name','user',json.encode(args),function (response)	
					local code = response.code
                    local costs = response.data.costs
					if costs then
					    GlobalApi:parseAwardData(costs)
					end
					if code == 0 then
						if UserData:getUserObj():getMark().rename then
							UserData:getUserObj():getMark().rename = 0
						end
						self:onChangeNameSuccess(name)
					elseif code == 101 then
						promptmgr:showMessageBox(GlobalApi:getLocalStr('SETTING_CHANGENAME_ALREADYUSE'), MESSAGE_BOX_TYPE.MB_OK)
					elseif code == 102 then
						promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER_1'), MESSAGE_BOX_TYPE.MB_OK)
					end
				end)
			end
		end
		if not UserData:getUserObj():getName() or UserData:getUserObj():getName() == "" 
			or (UserData:getUserObj():getMark().rename and UserData:getUserObj():getMark().rename == 1)
			 then
			sendToServer()
			return
		end
		if UserData:getUserObj():getName() and UserData:getUserObj():getName() == name then
			promptmgr:showMessageBox(GlobalApi:getLocalStr('SETTING_CHANGENAME_ALREADYUSE_1'), MESSAGE_BOX_TYPE.MB_OK)
			return
		end
		local cost=tonumber(GlobalApi:getGlobalValue('renameCashCost'))

        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH2'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            local hasCash = UserData:getUserObj():getCash()
            if hasCash >= cost then
                sendToServer(cost)
            else
                promptmgr:showMessageBox(
				GlobalApi:getLocalStr('STR_CASH')..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. GlobalApi:getLocalStr('STR_CASH') .. '？',
				MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				function ()
					GlobalApi:getGotoByModule('cash')
				end)
            end

        end)

		--UserData:getUserObj():cost('cash',cost,function()
			--sendToServer(cost)
		--end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))		
	else
		promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NEED_NAME'), MESSAGE_BOX_TYPE.MB_OK)
	end
end

function SettingChangeNameUI:onChangeNameSuccess(name)
	UserData:getUserObj():setName(name)
	SettingMgr:hideSettingChangeName()
end

-- 新手引导用
function SettingChangeNameUI:guideSpecialInitHandle()
end

return SettingChangeNameUI