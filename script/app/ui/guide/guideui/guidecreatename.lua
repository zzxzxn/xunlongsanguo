--guidecreatename.lua
local GuideCreateNameUI = class("GuideCreateNameUI", BaseUI)

function GuideCreateNameUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDECREATENAME
end

function GuideCreateNameUI:init()
	local winSize = cc.Director:getInstance():getWinSize()
	
    local Img_bg = self.root:getChildByName("Img_bg")
    local node_anim = Img_bg:getChildByName("node_anim")
    Img_bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

    local img_di = self.root:getChildByName("img_di")
    img_di:setContentSize(winSize)

    local npc = GlobalApi:createLittleLossyAniByName("nan_display")
    npc:setPosition(cc.p(0,0))
    npc:getAnimation():play("idle", -1, -1)
    local bone1 = npc:getBone("nan_display_l_chibang")
    local bone2 = npc:getBone("nan_display_r_chibang")
    bone1:setOpacity(0)
    bone2:setOpacity(0)
    node_anim:addChild(npc)

    local conf = GameData:getConfData("local/guidetext")
    local str = GlobalApi:createFaceString(conf["GUIDE_TEXT_1070"].text..conf["GUIDE_TEXT_1071"].text, 50, 0, 20, nil, true, cc.size(300, 100))
    str:setPosition(cc.p(180,130))
    Img_bg:addChild(str)

    self.nameEditbox = cc.EditBox:create(cc.size(234, 58), 'uires/ui/common/bg1_alpha.png')
    self.nameEditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameEditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.nameEditbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.nameEditbox:setPlaceHolder('')
    self.nameEditbox:setPosition(680, 110)
    self.nameEditbox:setFontColor(cc.c3b(0, 0, 0))
    self.nameEditbox:setMaxLength(50)
    self.nameEditbox:setFont('font/gamefont.ttf',27)
    self.nameEditbox:setText('')
    Img_bg:addChild(self.nameEditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 27)
    self.nameTx:setPosition(cc.p(680, 110))
    self.nameTx:setColor(cc.c3b(40, 40, 40))
    -- self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    -- self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx:setName('name_tx')
    Img_bg:addChild(self.nameTx)
    self.nameTx:setString(GlobalApi:getLocalStr('STR_NEED_NAME'))

    local maxLen = 7
    local oldStr = UserData:getUserObj():getName()
    self.nameEditbox:registerScriptEditBoxHandler(function(event,pSender)
		if event == "began" then
			self.nameEditbox:setText("")
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

    --随机名字
    local randomBtn = Img_bg:getChildByName('btn_ran')
	randomBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self.nameEditbox:setText('')
			self.nameTx:setString(GlobalApi:RandomName())
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--确定
	local sureBtn = Img_bg:getChildByName('btn_ok')
	local sureTx = sureBtn:getChildByName('tx')
	sureTx:setString(GlobalApi:getLocalStr('STR_OK'))
	sureTx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
	sureBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:SendNewName(self.nameTx:getString())
			AudioMgr.PlayAudio(11)
	    end
	end)
end

function GuideCreateNameUI:SendNewName(name)
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
	else
		promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NEED_NAME'), MESSAGE_BOX_TYPE.MB_OK)
	end
end

function GuideCreateNameUI:onChangeNameSuccess(name)
	UserData:getUserObj():setName(name)

	-- SDK创建角色的时候同时要上传登录
	-- SdkData:SDK_setRoleData(1)	
	-- SdkData:trackCreateChar()

	-- SdkData:SDK_setRoleData(2)
	-- SdkData:trackLogin()

	self:hideUI()

	GuideMgr:finishCurrGuide()
end

return GuideCreateNameUI