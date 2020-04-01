cc.exports.MessageMgr = {
	fuckServerForceToAddThisMsg = "",
	messageSequence = 0
}

local COMPRESS_TYPE = "deflate"
if CCApplication:getInstance():getTargetPlatform() == kTargetWindows then
	COMPRESS_TYPE = ""
end

function MessageMgr:decodeURI(s)
	s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end

function MessageMgr:encodeURI(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end


local function getServerUrl()
	local serverList = GameData:getConfData("local/serverlistplatform")
	local url = serverList[SdkData:getServerListID()].ServerUrl
	return url
end

local function formatGetServerListUrl()
	local serverList = GameData:getConfData("local/serverlistplatform")
	local url = getServerUrl().."?"..SdkData:getLoginParams()
	print("========ServerUrl==========>",url)
	return url
end

function MessageMgr:requsetGet(url, callback, ignoreResp)
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)

	print("======HttpRequest GET======")
	print(url)

	xhr:registerScriptHandler(function()

		print("======getResponse======")
		print(xhr.response)

		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			if self:parseJsonBeforeResponse(jsonObj) then
				callback(jsonObj)
			end
		else
            if ignoreResp == nil then
			    promptmgr:showMessageBox(GlobalApi:getLocalStr("NETWORL_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				    self:requsetGet(url, callback)
			    end)
            end
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)
	xhr:send()
end

function MessageMgr:getServerList(callback)
	local url = formatGetServerListUrl()
	self:requsetGet(url, function(jsonObj)
		if jsonObj.code == 0 then
			self:afterGetServerList(jsonObj, callback)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("GET_SERVER_LIST_FAILED"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self:getServerList(callback)
			end)
		end
	end)
end

function MessageMgr:afterGetServerList(jsonObj, callback)
	-- if next(jsonObj['server_list']) == nil then
	-- 	promptmgr:stopServerTip(jsonObj.desc,nil)
	-- 	return 
	-- end
	GlobalData:init()
	GlobalData:setCdkeyUrl(jsonObj['cdkey'])
	GlobalData:setOpenKeyAndOpenId(jsonObj['openkey'],jsonObj['openid'],jsonObj['opentime'])
	GlobalData:setIswhite(jsonObj['white'])
	GlobalData:setServerTab(jsonObj['server_list'])
	GlobalData:setVersionData(jsonObj['version'])
	GlobalData:setUpdateUrl(jsonObj['update_url'])
	-- --测试
	-- GlobalData:setUpdateUrl("http://10.10.200.203:9060/update/xlsgTest")
	
	GlobalData:setContent(jsonObj['bulletin'])
	GlobalData:setBulletin(jsonObj['bulletin'])
	GlobalData:setLocalServerSelectID(SdkData:getServerListID())
	GlobalData:setDownloadUrl(jsonObj['download'])

	GlobalData:setOpenPay(jsonObj['isOpenPay'])
	if callback then
		callback()
	end
end

function MessageMgr:getActivityConf(confArr, callback)
	local confJson = json.encode(confArr) or "{}"
	local url = GlobalData:getGateWayUrl() .. "?act=avconf&avconf=" .. xx.Utils:Get():urlEncode(confJson)
	local xhr = cc.XMLHttpRequest:new()
	xhr:open("GET", url)

	print("======HttpRequest GET======")
	print(url)
	
	xhr:registerScriptHandler(function()

		print("======getResponse======")
		print(xhr.response)

		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			callback(xhr.response)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("NETWORL_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
			    self:getActivityConf(confArr, callback)
		    end)
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)
	xhr:send()
end

function MessageMgr:sendPost( act, mod, argsJson, response )
	local otherStr
	if GuideMgr:isRunning() and GuideMgr.saveWithMsg then
		local guidestep = GuideMgr:getSaveStep()
		otherStr = "&guide=" .. guidestep
	end
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Encoding", COMPRESS_TYPE)
	xhr:open("POST", GlobalData:getGameServerUrl())
	xhr:registerScriptHandler(function()

		print("======getResponse======>  act："..act.."   mod："..mod)
		print(xhr.response)

		if xhr.response then
			self.fuckServerForceToAddThisMsg = self.fuckServerForceToAddThisMsg .. "\nresponse = " .. xhr.response
		end
		promptmgr:hideConnectWaiting()
		print("xhr.readyState is:"..xhr.readyState..",".."xhr.status:"..xhr.status)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			if self:parseJsonBeforeResponse(jsonObj) then
                if jsonObj.data.tips and UserData and UserData:getUserObj() then
                    UserData:getUserObj():setTipsInfo(jsonObj.data.tips)
                end
				response(jsonObj)
				if GuideMgr:isRunning() and jsonObj.code == 0 then
					if GuideMgr.saveWithMsg and otherStr then
						GuideMgr:completeSave()
					end
					CustomEventMgr:dispatchEvent(CUSTOM_EVENT.MSG_RESPONSE)
				end
			end
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("NETWORL_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
				self.messageSequence = self.messageSequence - 1
				self:sendPost(act, mod, argsJson, response)
			end)
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)

	local uid = GlobalData:getSelectUid()
	local openkey,openid,opentime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local authkey = GlobalData:getAnthKey()
	local authtime = GlobalData:getAnthTime()
	local currTime = GlobalData:getServerTime()
	local sigT = self:getSigTime(currTime, self.messageSequence)
	local v = 	'uid=' .. uid .. 
				'&openid=' .. openid .. 
				'&act=' .. act .. 
				'&mod=' .. mod .. 
				'&auth_key=' .. authkey .. 
				'&args=' .. argsJson .. 
				'&auth_time=' .. authtime ..
				'&seq=' .. self.messageSequence .. 
				'&stime=' .. currTime ..
				'&sig=' .. sigT
	if otherStr then
		v = v .. otherStr
	end

	print("======HttpRequest POST======>  act："..act.."   mod："..mod.."  seq:"..self.messageSequence)
	print(GlobalData:getGameServerUrl().."?"..v)

	self.fuckServerForceToAddThisMsg = "request = " .. v
	self.messageSequence = self.messageSequence + 1
	xhr:send(v)
	promptmgr:showConnectWaiting()
end

function MessageMgr:sendPostByRecharge( act, mod, argsJson, response )
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Encoding", COMPRESS_TYPE)
	xhr:open("POST", GlobalData:getGameServerUrl())
	xhr:registerScriptHandler(function()

		print("======getResponse======>  act："..act.."   mod："..mod)
		print(xhr.response)

		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			local jsonObj = json.decode(xhr.response)
			response(jsonObj)
		end
		xhr:unregisterScriptHandler()
		ScriptHandlerMgr:getInstance():removeObjectAllHandlers(xhr)
	end)

	local uid = GlobalData:getSelectUid()
	local openkey,openid,opentime = GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	local authkey = GlobalData:getAnthKey()
	local authtime = GlobalData:getAnthTime()
	local currTime = GlobalData:getServerTime()
	local sigT = self:getSigTime(currTime, 0)
	local v = 	'uid=' .. uid .. 
				'&openid=' .. openid .. 
				'&act=' .. act .. 
				'&mod=' .. mod .. 
				'&auth_key=' .. authkey .. 
				'&args=' .. argsJson .. 
				'&auth_time=' .. authtime ..
				'&seq=0' .. 
				'&stime=' .. currTime ..
				'&sig=' .. sigT

	print("======HttpRequest POST======>  act："..act.."   mod："..mod)
	print(GlobalData:getGameServerUrl().."?"..v)

	xhr:send(v)
end

function MessageMgr:parseJsonBeforeResponse(jsonObj)
	if jsonObj.serverTime then
		GlobalData:setServerTime(jsonObj.serverTime)
	end
	return self:parseCode(jsonObj)

end

function MessageMgr:parseCode(jsonObj)
	GlobalApi:setStopServer(jsonObj)
	local code = jsonObj.code
	local function restart()
		UIManager:backToLogin()
		SdkData:trackLogout()
	end
	if code == 2 or code == 5 then   --服务器重启，请重新登陆
		promptmgr:showMessageBox(GlobalApi:getLocalStr("SERVER_RESTART"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 3 then  --您的账号异地登陆，请重新登陆
		promptmgr:showMessageBox(GlobalApi:getLocalStr("REPEAT_LOGIN"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 4 then   --长时间未操作，请重新登陆
		promptmgr:showMessageBox(GlobalApi:getLocalStr("NI_BEI_TI_LE"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 6 then  --服务器忙，请重新登陆
		promptmgr:showMessageBox(GlobalApi:getLocalStr("SERVER_BUSY"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 8 then   --登录超时，请重新登录
		promptmgr:showMessageBox(GlobalApi:getLocalStr("LOGIN_OVER_TIME"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 9 then   --客户端数据异常，请重新登录
		promptmgr:showMessageBox(GlobalApi:getLocalStr("KICK_BECAUSE_CHEAT_2"), MESSAGE_BOX_TYPE.MB_OK,restart)
		return false
	elseif code == 10 then  --停服公告
		-- promptmgr:stopServerTip(jsonObj.desc,restart)
		-- return false
	end
	return true
end

function MessageMgr:getSigTime(t, seq)
	local tStr = tostring(t)
	local f = tonumber(string.sub(tStr, 1, 5))
	local s = tonumber(string.sub(tStr, 6, 10))
	return xx.Utils:Get():generateMD5((s*f + t)%s + seq)
end

return MessageMgr