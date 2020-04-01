-- require "script/app/data/globaldata"
local CreateNameUI = class("CreateNameUI", BaseUI)

--如果有SDK,用SDK的登陆界面代替此界面
function CreateNameUI:ctor()
	self.uiIndex = GAME_UI.UI_CREATENAME
end

function CreateNameUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local Layout_EditBox_0 = self.root:getChildByName("Layout_EditBox_0")
    Layout_EditBox_0:setPositionX(winSize.width/2)
    local Layout_EditBox = self.root:getChildByName("Layout_EditBox")
    Layout_EditBox:setPositionX(winSize.width/2)
    local Btn_Start = self.root:getChildByName("Btn_Start")
    Btn_Start:setPositionX(winSize.width/2)

    local Text_Start = Btn_Start:getChildByName("Text_Start")

    local editbox = cc.EditBox:create(cc.size(320, 32), 'uires/ui/common/common_bg.png')
    editbox:setAnchorPoint(cc.p(0, 0.5))
    editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox:setFontName("font/gamefont.ttf");
    editbox:setFontSize(24);
    editbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    editbox:setPosition(20, 26)
    editbox:setFontColor(cc.c3b(255, 255, 255))
    editbox:setMaxLength(30)
    Layout_EditBox:addChild(editbox)

    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
    nameTx:setPosition(cc.p(20, 26))
    nameTx:setAnchorPoint(cc.p(0, 0.5))
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setName('name_tx')
    Layout_EditBox:addChild(nameTx)
    nameTx:setString(cc.UserDefault:getInstance():getStringForKey('uid',''))
    if nameTx:getString() == '' then
        editbox:setPlaceHolder(GlobalApi:getLocalStr('STR_INPUT_NAME'))
    end

    local doLogin = function()
        MessageMgr:getServerList(function()
            self:hideUI()
            LoginMgr:afterGetServerList()
        end)
    end

    local sdkLogin = function()
        SdkData:SDK_login(function()
            cc.UserDefault:getInstance():setStringForKey('uid', SdkData:getUid())
            doLogin()
        end)
    end

	Btn_Start:addClickEventListener(function (sender)
        if SdkData:getSDKPlatform() == "dev" then
            local name = nameTx:getString()
            if name and name ~= '' then
                cc.UserDefault:getInstance():setStringForKey('uid', name)
                SdkData:setUid(name)
                doLogin()
            else
                promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NEED_NAME'), MESSAGE_BOX_TYPE.MB_OK)
        	end
        else
            sdkLogin()
        end
	end)

    editbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            editbox:setText(nameTx:getString())
            editbox:setPlaceHolder('')
            nameTx:setString('')
        elseif event == "ended" then
            local str = editbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,30*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            nameTx:setString(str)
            editbox:setText('')
            if str == '' then
                editbox:setPlaceHolder(GlobalApi:getLocalStr('STR_INPUT_NAME'))
            else
                editbox:setPlaceHolder('')
            end
        end
    end)


    if SdkData:getSDKPlatform() == "dev" then
        Text_Start:setString(GlobalApi:getLocalStr('STR_LOGIN_START'))
    else
        -- Btn_Start:setVisible(false)
        Text_Start:setString(GlobalApi:getLocalStr('STR_LOGIN_LOGIN'))
        Layout_EditBox:setVisible(false)
        Layout_EditBox_0:setVisible(false)
        editbox:setVisible(false)

        sdkLogin()
    end
end

return CreateNameUI