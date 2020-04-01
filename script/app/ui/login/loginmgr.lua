local ClassLoginUI = require("script/app/ui/login/loginui")
cc.exports.LoginMgr = {
	uiClass = {
		loginUI = nil
	},

	isFirstLogin = false,
}

setmetatable(LoginMgr.uiClass, {__mode = "v"})

function LoginMgr:showLogin()
    -- YVSdkMgr:cpLogout()
	if self.uiClass.loginUI == nil then
		self.uiClass.loginUI = ClassLoginUI.new()
		self.uiClass.loginUI:showUI()
	end
end

function LoginMgr:hideLogin()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:hideUI()
		self.uiClass.loginUI = nil
	end
end

function LoginMgr:setLoginServerName()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:setServerName()
	end
end

function LoginMgr:showCreateName()
	local createnameUi = require('script/app/ui/login/createname').new()
	createnameUi:showUI()
end

function LoginMgr:loginUpdateChildren()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:updateChild()
	end
end

function LoginMgr:getNewServer(serverlistTab)
	local serverTab
	local nowId = 1
	local statusTab = {}
	for k,v in pairs(serverlistTab) do
		if v.status == 3 then
			table.insert(statusTab,v)
		end
		if tonumber(v.id) > nowId then
			nowId = tonumber(v.id)
			serverTab = v
		end
	end
	if #statusTab > 0 then
		serverTab = statusTab[math.random(1,#statusTab)]
	end
	return serverTab or serverlistTab[1]
end

function LoginMgr:afterGetServerList()
	local serverId = cc.UserDefault:getInstance():getIntegerForKey('serverID_1',-1)
	local serverlistTab = GlobalData:getServerTab()
	local url
	local serverName
	local serverID
	local userId
	local tab = GlobalData:getServerInfoById(serverId)
	--printall(serverlistTab)
	if not tab or serverId < 1 then
		local tab1 = self:getNewServer(serverlistTab)
		url = tab1.host
		serverName = tab1.name
		serverID = tab1.id
		userId = tab1.uid
		cc.UserDefault:getInstance():setIntegerForKey('serverID_1',serverID)
	else
		url = tab.host
		serverName = tab.name
		userId = tab.uid
		serverID = serverId
	end
	GlobalData:setSelectSeverUid(serverID)
	GlobalData:setSelectSeverName(serverName)
	GlobalData:setGateWayUrl(url)
	GlobalData:setSelectUid(userId)
	self:checkUpdate()
end

function LoginMgr:StartEnteringGame(callback)
	local getGateWayUrl = GlobalData:getGateWayUrl()
	local openKey,openId,openTime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local userId = GlobalData:getSelectUid()
	local avMd5FilePath = cc.FileUtils:getInstance():getWritablePath() .. "update_activity/activity_md5.txt"
    local avMd5 = cc.FileUtils:getInstance():getStringFromFile(avMd5FilePath)
    if avMd5 == nil or avMd5 == "" or json.decode(avMd5) == nil then
    	avMd5 = "{}"
    end
	local url = getGateWayUrl..'?avconf='.. xx.Utils:Get():urlEncode(avMd5) .. '&openkey='..openKey..'&act=login&openid='..openId..'&uid='..(userId or '')..'&opentime='..openTime
	print("===========StartEnteringGame==============>", url)

	MessageMgr:requsetGet(url, function(response)
		if response.code == 0 then
			local data = response.data
		    GlobalData:setAuthTime(data.auth_time)
		    GlobalData:setServerTime(data.auth_time)
		    GlobalData:setAuthKey(data.auth_key)
		    GlobalData:setGameServerUrl(data.game_server)
		    GlobalData:setSelectUid(data.uid)
            GlobalData:setServerId(data.serverId)
		    local timezone = data.timezone or 8
    		GlobalData:setTimeZoneOffset(timezone)
    		-- 存储每次登录的时间戳
    		-- GlobalData:StoreServerTime(data.auth_time,data.uid)
			GlobalApi:saveActivityConfig(data.avconf, 2, callback, function (status)
				if status == 0 then
					self:OnResponse(callback)
				else
					self:StartEnteringGame(callback)
				end
			end)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("GET_UID_FAILED"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:StartEnteringGame(callback)
			end)
		end
	end)
end

function LoginMgr:OnResponse(callback)
	local platform = CCApplication:getInstance():getTargetPlatform()
	local args = {
	    name = GlobalData:getOpenId(),
	    platform = SdkData:getSDKPlatform(),
	    device_info = SdkData:getSDKRequestJson()
	}

	MessageMgr:sendPost('login','user',json.encode(args),function (jsonObj)
		if jsonObj.code == 0 then
			if callback then
				callback(3)
			end
			self:OnLoginResponse(jsonObj,callback)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr('LOGIN_ERROR_MESSAGE_' .. jsonObj.code), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:OnResponse(callback)
			end)
		end
	end)
end

function LoginMgr:OnLoginResponse(resTab,callback)
	UserData:initWithData(resTab)
    UIManager:getSidebar():setActivityBtnsPosition()

    -----------------------------------socket监听事件------------------------------------
    RechargeMgr:GetLog()
    ChatNewMgr:GetLog()
    MainSceneMgr:GetLog()
    FriendsMgr:GetLog()
	SocketMgr:init(resTab.data.wssPort)
    TerritorialWarMgr:init()
	SettingMgr:init()
	------------------------------------------------------------------------------------

    --TerritorialWarMgr:registerSynMsg()
	RechargeMgr:queryRecharge()
	local loginTimes = UserData:getUserObj():getMark().logins
	if loginTimes <= 1 then   --首次登陆
		self:setFirstLogin(true)
		-- 创建角色的时候同时要上传登录
		SdkData:SDK_setRoleData(1)	
		SdkData:trackCreateChar()

		SdkData:SDK_setRoleData(2)
		SdkData:trackLogin()
	else					  --非首次登陆
		self:setFirstLogin(false)
		SdkData:SDK_setRoleData(2)

		SdkData:trackLogin()
	end
	
	if callback then
		callback(4)
	end
	-- PlayerCore::markLoginDateDigital();
	-- CPathData::GetInst()->Init();
	-- CLoginMgr::GetInst()->hideLoginPanel();
	-- CLDObjectManager* pObjectMgr = CLDObjectManager::GetInst();
	-- pObjectMgr->ClearAllObject();
	-- CUserdata::GetInst()->ReLoadClearData();
	-- InitObject();
	-- pObjectMgr->CreateLDObject(MYSELF_ID, OBJECT_TYPE_SELF);
	-- CNewsMgr::GetInst()->StartRequest();
	-- CUserdata::GetInst()->ParseJsonUserData( pJsonDic );
	-- CUserdata::GetInst()->m_dwServerTime = pJsonDic->getItemIntValue( "serverTime", 0 );
 	-- CCopySceneMgr::getInst()->saveChapterID(-1);
 	-- self:hideLogin()
end

function LoginMgr:checkUpdate()
	if self.uiClass.loginUI then
		self.uiClass.loginUI:checkUpdate()
	end
end

function LoginMgr:setFirstLogin(isFirstLogin)
	self.isFirstLogin = FirstLogin
end