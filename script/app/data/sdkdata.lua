--sdkdata.lua

--kTargetAndroid
--kTargetIphone
--kTargetWindows
local targetPlatform = CCApplication:getInstance():getTargetPlatform()

cc.exports.SdkData = {
	uid = "",				--用户唯一标识
	device_imei = "",		--设备imei码
	device_mac = "",		--设备mac地址码：（类似 02:00:00:00:00:00）
	device_system = "",		--设备系统版本：（类如：PC端 win10、移动端 6.0.1）
	device_name = "PC",		--设备名：PC、Nexus 5、Iphone 7
	platform = "dev",		--SDK或发行标识：（类如：dev、quick、dianhun）
	channel_id = "",		--渠道ID
	session = "",			--渠道session
	login_type = "",		--登录类型：（类如：""、游客、微信）
	serverListID = 1,		--对应data/local/serverlistplatform.dat
	channelStr = "",		--当前接入的SDK
	memo = "",				--某些特殊渠道的guid
}

function SdkData:init()
	self.javaClassName = "org/cocos2dx/lua/AppActivity"

	self.order = {}

	self:SDK_getDeviceInfo()
	self.channelStr = self:SDK_getChannelStr()
end

function SdkData:getLoginParams()
	local version = ""
	local versionFullPath = cc.FileUtils:getInstance():fullPathForFilename("manifest/version.manifest")
	if versionFullPath ~= "" then
		local content = cc.FileUtils:getInstance():getStringFromFile(versionFullPath)
		if content ~= "" then
			local fileObj = json.decode(content)
			if fileObj then
				version = fileObj.version
			end
		end
	end


	return 'uid='..self.uid.."&device_imei="..self.device_imei.."&device_mac="..self.device_mac.."&device_system="..self.device_system.."&device_name="..self.device_name.."&platform="..self.platform.."&channel_id="..self.channel_id.."&login_type="..self.login_type.."&session="..self.session.."&version="..version.."&memo="..self.memo
end

function SdkData:getSDKRequestJson()
	local params = {}
	params.device_imei = device_imei
	params.device_mac = device_mac
	params.device_system = device_system
	params.device_name = device_name
	return json.encode(params)
end

--获取当前接入的SDK
function SdkData:SDK_getChannelStr()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getChannelStr"
	    local javaParams = {}
	    local javaMethodSig = "()Ljava/lang/String;"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        print("SDK_getChannelStr result +++++++++++++", ret)
	        return ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getChannelStr", {})
		if ok then
			print("SDK_getChannelStr ++++++", ret)
			return ret
		end
	end
	return "{}"
end

function SdkData:SDK_getSplash()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getSplash"
	    local javaParams = {}
	    local javaMethodSig = "()Ljava/lang/String;"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        print("SDK_getSplash result +++++++++++++", ret)
	        return ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getSplash", {})
		if ok then
			print("SDK_getSplash ++++++", ret)
			return ret
		end
	end
	return "{}"
end

-- 添加logo信息
function SdkData:SDK_getLogoInfo()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getLogoInfo"
	    local javaParams = {}
	    local javaMethodSig = "()Ljava/lang/String;"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        print("SDK_getLogoInfo result +++++++++++++", ret)
	        return ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getLogoInfo", {})
		if ok then
			print("SDK_getLogoInfo ++++++", ret)
			return ret
		end
	end
	-- 默认返回飞剑魔斩
	return "fjmz.png"
end


-- 是否添加版号信息
function SdkData:SDK_getInfo()
	if targetPlatform == kTargetAndroid then
		local javaMethodName = "SDK_getInfo"
    	local javaParams = {}
	    local javaMethodSig = "()Z"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        return ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getInfo", {})
		if ok then
			return ret
		end
	end
	return true
end

--登陆
function SdkData:SDK_login(callback)
	local luaLoginFuncCbk = function (content)
		local params = json.decode(content)
		self.uid 	 	= params.userId or ""
		self.session 	= params.session or ""
		self.login_type = params.login_type or ""
		self.channel_id = params.channel_id or ""
		self.memo		= params.memo or ""

		callback()
	end

	local luaResetLoginCbk = function ()
		-- Game:init()
		-- Game:start()
		UIManager:backToLogin()
	end

	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_login"
	    local javaParams = {luaLoginFuncCbk, luaResetLoginCbk}
	    local javaMethodSig = "(II)V"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        print("get result +++++++++++++", ret)
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_login", {cbkFunc = luaLoginFuncCbk, resFunc = luaResetLoginCbk})
		if ok then
			print("check ++++++", ret)
		end
	end
end

--支付
function SdkData:SDK_pay(funcCbk, jsonParams)
	local params = {}
	params.orderID = jsonParams.order
	params.productCost = tostring(jsonParams.amount*100)
	-- params.pay_url = jsonParams.pay_url
	params.productId = jsonParams.id
	params.productName = jsonParams.name
	params.productDesc = jsonParams.desc

	params.roleId = tostring(GlobalData:getSelectUid())
	params.roleName = UserData:getUserObj():getName()
	params.roleLevel = tostring(UserData:getUserObj():getLv())
	params.vipLevel = tostring(UserData:getUserObj():getVip())
	params.diamondValue = tostring(UserData:getUserObj():getCash())
	params.alliance_name = tostring(UserData:getUserObj().lname)
	params.registerTime = tostring(UserData:getUserObj():getCreateTime())

	local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()
	params.serverId = tostring(serverId)
	params.serverName = tostring(serverName)

	--透传参数
	params.extras_params = {uid = tostring(UserData:getUserObj():getUid()), openid = tostring(GlobalData:getOpenId()), id = jsonParams.id}

	local content = json.encode(params)

	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_pay"
	    local javaParams = {funcCbk, tostring(content)}
	    local javaMethodSig = "(ILjava/lang/String;)V"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        print("get result +++++++++++++", ret)
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_pay", {cbkFunc=funcCbk, content=tostring(content)})
		if ok then
			print("check ++++++", ret)
		end
	end
end


function SdkData:SDK_setRoleData(type)
	local roleMsgTab = {}

	-- roleMsgTab.accountId = tostring(GlobalData:getOpenId())
	roleMsgTab.roleId = tostring(GlobalData:getSelectUid())
	roleMsgTab.roleName = UserData:getUserObj():getName()
	roleMsgTab.roleLevel = tostring(UserData:getUserObj():getLv())
	roleMsgTab.vipLevel = tostring(UserData:getUserObj():getVip())
	roleMsgTab.diamondValue = tostring(UserData:getUserObj():getCash())
	roleMsgTab.alliance_name = tostring(UserData:getUserObj().lname)
	roleMsgTab.registerTime = tostring(UserData:getUserObj():getCreateTime())

	local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()
	roleMsgTab.serverId = tostring(serverId)
	roleMsgTab.serverName = tostring(serverName)
	
	-- roleMsgTab.mapID = tostring(MapData:getCanFighttingIdByPage(1))  --新加的最高通关关卡
	local content = json.encode(roleMsgTab)

	local tag = ""
	if type == 1 then
		tag = "create"
	elseif type == 2 then
		tag = "enter"
	elseif type == 3 then
		tag = "levelup"
	elseif type == 4 then
		tag = "pay"
	elseif type == 5 then
		tag = "exit"
	end

	if targetPlatform == kTargetAndroid then
		local javaMethodName = "SDK_setRoleData"
		local javaParams = {tag, tostring(content)}
		local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
		local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
		if ok then
			print("check ++++++", ret)
		end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_setRoleData", {tag=tag, content = tostring(content)})
		if ok then
			print("check ++++++", ret)
		end    
	end
end

function SdkData:getServerListID()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getServerListID"
	    local javaParams = {}
	    local javaMethodSig = "()I"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	    	self.serverListID = ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getServerListID", {})
		if ok then
			self.serverListID = ret
		end
	end

	return self.serverListID
end

--打开连接
function SdkData:openUrl(url)
	if targetPlatform == kTargetAndroid then
		local javaMethodName = "openUrl"
    	local javaParams = {url}
	    local javaMethodSig = "(Ljava/lang/String;)V"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "openUrl", {url=url})
		if ok then
			
		end
	end
end

--退出游戏弹窗
function SdkData:SDK_exitGame()
	if targetPlatform == kTargetAndroid then
		local javaMethodName = "SDK_exitGame"
    	local javaParams = {}
	    local javaMethodSig = "()Z"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	        return ret
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_exitGame", {})
		if ok then
			return ret
		end
	end
	return false
end

--登出游戏接口
function SdkData:SDK_Logout()
	if targetPlatform == kTargetAndroid then
		local javaMethodName = "SDK_Logout"
    	local javaParams = {}
	    local javaMethodSig = "()V"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then

	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_Logout", {})
		if ok then

		end
	end

	self:trackLogout()
end


function SdkData:getRechargeConfName()
	return "recharge";
end

function SdkData:setUid(uid)
	self.uid = uid
end

function SdkData:getUid()
	return self.uid
end

function SdkData:getChannelID()
	local channelID = self.channel_id
	if channelID == "" then
		channelID = "999999"
	end
	return channelID
end

function SdkData:getSDKPlatform()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getSDKPlatform"
	    local javaParams = {}
	    local javaMethodSig = "()Ljava/lang/String;"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	    	self.platform = ret
	        print("SDKPlatform result +++++++++++++", ret)
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getSDKPlatform", {})
		if ok then
			self.platform = ret
			print("SDKPlatform ++++++", ret)
		end
	end
	return self.platform
end

function SdkData:SDK_getDeviceInfo()
	if targetPlatform == kTargetAndroid then
	    local javaMethodName = "SDK_getDeviceInfo"
	    local javaParams = {}
	    local javaMethodSig = "()Ljava/lang/String;"
	    local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
	    if ok then
	    	local params = json.decode(ret)
	    	self.device_imei = params.device_imei or ""
	    	self.device_mac = params.device_mac or ""
	    	self.device_system = params.device_system or ""
	    	self.device_name = params.device_name or ""
	    end
	elseif targetPlatform == kTargetIphone then
		local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_getDeviceInfo", {})
		if ok then
			local params = json.decode(ret)
			self.device_imei = params.device_imei or ""
	    	self.device_mac = params.device_mac or ""
	    	self.device_system = params.device_system or ""
	    	self.device_name = params.device_name or ""
		end
	end
end









----------------------------------- 数据统计 Begin -----------------------------------
function SdkData:SDK_trackEvent(eventName, params)
	if self.channelStr == "" then
		local content = json.encode(params)

		if targetPlatform == kTargetAndroid then
			local javaMethodName = "SDK_trackEvent"
			local javaParams = {eventName, tostring(content)}
			local javaMethodSig = "(Ljava/lang/String;Ljava/lang/String;)V"
			local ok, ret = LuaJavaBridge.callStaticMethod(self.javaClassName, javaMethodName, javaParams, javaMethodSig)
			if ok then
				print("check ++++++", ret)
			end
		elseif targetPlatform == kTargetIphone then
			local ok, ret = LuaObjcBridge.callStaticMethod("AppController", "SDK_trackEvent", {eventName=eventName, params = tostring(content)})
			if ok then
				print("check ++++++", ret)
			end    
		end
	end
end

--游戏登录（一级日志）
function SdkData:trackLogin()
	if self.channelStr == "" then
		local eventName = "login"
		local params = {}

		local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

		params.track_platform 	= "dianhun"					--日志发送平台
		params.log_type 	  	= "login"					--日志类型
		params.zid 				= tostring(serverId)		--游戏大区id
		params.sid 				= "1"						--游戏服务器ID
		params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
		params.user_id 			= tostring(GlobalData:getOpenId())							--玩家id
		params.role_level 		= tostring(UserData:getUserObj():getLv())		--登录时玩家角色等级

		self:SDK_trackEvent(eventName, params)
	end
end

--游戏登出（一级日志）
function SdkData:trackLogout()
	if self.channelStr == "" then
		local eventName = "logout"
		local params = {}

		if UserData:getUserObj() == nil or UserData:getUserObj():getLv() == nil then
			return
		end

		local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

		params.track_platform 	= "dianhun"					--日志发送平台
		params.log_type 	  	= "logout"					--日志类型
		params.zid 				= tostring(serverId)		--游戏大区id
		params.sid 				= "1"						--游戏服务器ID
		params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
		params.user_id 			= tostring(GlobalData:getOpenId())							--玩家id
		params.role_level 		= tostring(UserData:getUserObj():getLv())		--登录时玩家角色等级
		params.online_durt 		= tostring(GlobalData:getServerTime() - GlobalData.openTime)		--本次在线时长
		params.online_durt_tt 	= tostring(UserData:getUserObj().mark.total_online_time)		--登出时玩家角色累计游戏时长（秒）

		self:SDK_trackEvent(eventName, params)
	end
end

--创角登出（一级日志）
function SdkData:trackCreateChar()
	if self.channelStr == "" then
		local eventName = "create_char"
		local params = {}

		local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

		params.track_platform 	= "dianhun"					--日志发送平台
		params.log_type 	  	= "create_char"				--日志类型
		params.zid 				= tostring(serverId)		--游戏大区id
		params.sid 				= "1"						--游戏服务器ID
		params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
		params.user_id 			= tostring(GlobalData:getOpenId())							--玩家id
		params.roles 			= "1"						--登录时玩家角色等级

		self:SDK_trackEvent(eventName, params)
	end
end

--充值（一级日志）
function SdkData:trackPayClient()
	if self.channelStr == "" then
		local eventName = "pay_client"
		local params = {}
		local curPayConf = RechargeMgr:getCurPayConf()

		local isFirstPay = 0
		if curPayConf.isNotShow == 0 and curPayConf.duration <= 0 and UserData:getUserObj():getPayment().pay_list[curPayConf.id] == false then
			isFirstPay = 1
		end

		local free_amt = 0
		if curPayConf.duration > 0 then
			free_amt = curPayConf.amount * curPayConf.duration
		end

		local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

		params.track_platform 	= "dianhun"					--日志发送平台
		params.log_type 	  	= "pay_client"					--日志类型
		params.zid 				= tostring(serverId)		--游戏大区id
		params.sid 				= "1"						--游戏服务器ID
		params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
		params.user_id 			= tostring(GlobalData:getOpenId())							--玩家id
		params.role_level 		= tostring(UserData:getUserObj():getLv())		--登录时玩家角色等级
		params.before_gmoney	= tostring(RechargeMgr:getBeforeCash())			--操作前游戏币余额
		params.pay_gmoney		= tostring(UserData:getUserObj():getCash() - RechargeMgr:getBeforeCash())			--本次增加的游戏币
		params.pay_amount		= tostring(curPayConf.amount)			--现实货币金额 
		params.currency_type	= "CNY"						--现实货币类型
		params.currency_unit	= "10"						--兑换比例
		params.free_amt			= tostring(free_amt)			--赠送游戏主货币金额
		params.order_id 		= tostring(order.orderID)			--订单编号
		params.is_firstpay		= tostring(isFirstPay)			--是否首充
		params.item_id 			= tostring(order.id)			--充值产品

		self:SDK_trackEvent(eventName, params)
	end
end

-- --主货币变更（二级日志）
-- function SdkData:trackGmoney(mny_type, bef_gmny, aft_gmny, reason_type)
-- 	local eventName = "create_char"
-- 	local params = {}

-- 	local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

-- 	params.track_platform 	= "dianhun"					--日志发送平台
-- 	params.log_type 	  	= "gmoney"					--日志类型
-- 	params.zid 				= tostring(serverId)		--游戏大区id
-- 	params.sid 				= "1"						--游戏服务器ID
-- 	params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
-- 	params.user_id 			= tostring(GlobalData:getOpenId())			--玩家id
-- 	params.record_time 		= tostring(GlobalData:getServerTime())				--记录时间，格式如：2016-07-01 00:00:00
-- 	params.mny_type			= tostring(mny_type)								--货币类型，1：元宝，2：金币，3：体力
-- 	params.bef_gmny			= tostring(bef_gmny)								--操作前金额
-- 	params.aft_gmny			= tostring(aft_gmny)								--操作后金额
-- 	params.chge_gmny		= tostring(params.aft_gmny - params.bef_gmny)		--财产变化值，负值代表消耗，否则是收入
-- 	local chge_type = 1
-- 	if params.aft_gmny - params.bef_gmny < 0 then
-- 		chge_type = 2
-- 	end
-- 	params.chge_type		= tostring(chge_type)								--变化类型，0：纯粹在玩家间流转，1：游戏内存量增加，2：游戏内存量减少

-- 	--[[reason_type
-- 		-----游戏存量增加(chge_type=1)-----
-- 		1：通过充值直接获得（商城内点击档位进行充值购买也算入充值，关键
-- 		看是否和充值平台发生交互）
-- 		16：GM指令获得
-- 		-----游戏存量减少(chge_type=2)-----
-- 		2：商城购买道具
-- 		3：交易场出售道具消耗的佣金
-- 		17：GM指令减少
-- 		-----玩家间流传(chge_type=0)-----
-- 		4：交易场出售道具获得
-- 		5：交易场购买道具消耗
-- 		以上几种为固定枚举值，其他原因类型由游戏自定义，自定义编号务必从
-- 		100开始

-- 		自定义：
-- 		100：
-- 		101：
-- 		102：
-- 		103：
-- 	]]--
-- 	params.reason_type		= tostring(reason_type)					--变更原因

-- 	self:SDK_trackEvent(eventName, params)
-- end


--新手引导（二级日志）
--step_id：引导lua文件序号，step_index：当前引导序号，step_state：引导状态 1、进行中，step_name：引导步骤对应的name参数
function SdkData:trackGuidestep(step_id, step_index, step_state, step_name)
	if self.channelStr == "" then
		local eventName = "guidestep"
		local params = {}

		local serverId, serverName = GlobalData:getServerId(), GlobalData:getSelectSeverName()

		params.track_platform 	= "dianhun"					--日志发送平台
		params.log_type 	  	= "guidestep"					--日志类型
		params.zid 				= tostring(serverId)		--游戏大区id
		params.sid 				= "1"						--游戏服务器ID
		params.role_id 			= tostring(GlobalData:getSelectUid())		--角色id
		params.user_id 			= tostring(GlobalData:getOpenId())							--玩家id
		params.role_level 		= tostring(UserData:getUserObj():getLv())		--登录时玩家角色等级
		params.step_id			= tostring(step_id)				--引导lua文件序号
		params.step_index		= tostring(step_index)			--当前引导序号
		params.step_state		= tostring(step_state)			--引导状态 1、进行中
		params.step_name		= tostring(step_name)			--引导步骤对应的name参数

		self:SDK_trackEvent(eventName, params)
	end
end


return SdkData