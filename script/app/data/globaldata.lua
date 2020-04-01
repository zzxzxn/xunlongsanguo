cc.exports.GlobalData = {
	openkey = '' ,
	openId = 0 ,
	cdkey = '' , 											--cdkey兑换url
	serverlisttab = {} , 									--服务器列表
	selectUid = 0 , 										--选择服务器角色对应的uid
	selectSeverId = 0 , 									--选择的服务器id
    serverId = 0,   										--真实的服务器id
	selectSeverName = "", 									--选择的服务器名称
	authTime = 0 , 											--上次收到服务器短消息回执时间
	differenceTime = 0, 									-- 服务器和本地时间的差值
	authKey = '' , 											--用户密钥
	isWhite = false ,										--是否是白名单
	content = '' , 											--公告内容
	gatewayurl = 'http://172.31.244.2/login2.php', 			--游戏逻辑地址
	gameServerUrl = '',
	versiondata = '0', 										--版本信息
	updateurl = "",											--动态更新服务器
	localServerSelID = 0,
	loginInfo = "", 										-- 平台登录信息
	downloadUrl = "", 										-- 需要更新的客户端地址
	timeZoneOffset = 0, 									-- 默认时区差为0
}

function GlobalData:init()
	self.openkey = ''
	self.openId = 0
	self.cdkey = ''
	self.serverlisttab = {}
	self.selectUid = 0
	self.selectSeverId = 0
    self.serverId = 0
	self.selectSeverName = ""
	self.authTime = 0
	self.authKey = ''
	self.isWhite = false
	self.content = ''
	self.bulletin = ''
	self.gatewayurl = 'http://172.31.244.2/login2.php'
	self.gameServerUrl = ''
	self.versiondata = '0'
end

function GlobalData:setOpenKeyAndOpenId( key ,id ,time)
	self.openkey = key
	self.openId = id
	self.openTime = time
end

function GlobalData:getOpenKeyAndOpenIdAndOpenTIme()
	return self.openkey ,self.openId , self.openTime
end

function GlobalData:getOpenId()
	return self.openId
end

function GlobalData:setCdkeyUrl( url )
	self.cdkey = url
end

function GlobalData:getCdKeyUrl()
	return self.cdkey
end

function GlobalData:setLocalServerSelectID(id)
	self.localServerSelID = id
end
function GlobalData:setSelectUid(uid)
	self.selectUid = uid
end

function GlobalData:getSelectUid()
	return self.selectUid
end

function GlobalData:setAuthTime( time )
	self.authTime = time
end

function GlobalData:getAnthTime( )
	return self.authTime
end

function GlobalData:setServerTime(time)
	self.differenceTime = time - os.time()
end

function GlobalData:getServerTime(delaytime)
	local time = delaytime or 0
	return os.time() + self.differenceTime - time
end

function GlobalData:setTimeZoneOffset(timeZone)
	--该值是本地真实时区
	local localTimeZone = os.difftime(os.time(), os.time(os.date("!*t", os.time())))/3600
    self.timeZoneOffset = timeZone - localTimeZone
end

function GlobalData:getTimeZoneOffset()
	return self.timeZoneOffset or 0
end

function GlobalData:setAuthKey( key )
	self.authKey = key
end

function GlobalData:getAnthKey( )
	return self.authKey
end

function GlobalData:setIswhite( iswhite )
	self.isWhite = iswhite
end

function GlobalData:getIsWhite( )
	return self.isWhite
end

function GlobalData:setSelectSeverUid( serverid )
	self.selectSeverId = serverid
end

function GlobalData:getSelectSeverUid( )
	return self.selectSeverId
end

function GlobalData:setServerId(serverId)
    self.serverId = serverId
end

function GlobalData:getServerId()
    return self.serverId
end

function GlobalData:setSelectSeverName( serverName )
	self.selectSeverName = serverName
end

function GlobalData:getSelectSeverName()
	return self.selectSeverName
end

function GlobalData:setContent( cont )
	self.content =cont
end

function GlobalData:getContent()
	return self.content
end

function GlobalData:setBulletin( bulletin )
	self.bulletin =bulletin
end

function GlobalData:getBulletin()
	return self.bulletin
end

function GlobalData:setServerTab( servertab )
	for i,v in pairs(servertab) do
		self.serverlisttab[#self.serverlisttab + 1] = v
	end
	-- self.serverlisttab = servertab
	-- for i,v in ipairs(self.serverlisttab) do
	-- 	print(i,v)
	-- end
end

function GlobalData:getServerTab()
	return self.serverlisttab
end

function GlobalData:getServerInfoById(id)
	local tab
	for i,v in ipairs(self.serverlisttab) do
		if tonumber(v.id) == id then
			tab = v
		end
	end
	return tab
end

function GlobalData:setGameServerUrl( url )
	self.gameServerUrl = url
end

function GlobalData:getGameServerUrl()
	return self.gameServerUrl
end

function GlobalData:setGateWayUrl( url )
	self.gatewayurl = url
end

function GlobalData:getGateWayUrl()
	return self.gatewayurl
end


function GlobalData:setUpdateUrl( url )
	self.updateurl = url
end


function GlobalData:getUpdateUrl()
	return self.updateurl
end

function GlobalData:setVersionData( version)
	self.versiondata = version
end

function GlobalData:getVersionData()
	return self.versiondata
end

function GlobalData:getUpdateUrlReal()
	local serverList = GameData:getConfData("local/serverlistplatform")
	return self.updateurl .. '/' .. serverList[self.localServerSelID].ResourceServerName .. '/'
end

function GlobalData:setLoginInfo(v)
	self.loginInfo = v
end

function GlobalData:getLoginInfo()
	return self.loginInfo
end

function GlobalData:setDownloadUrl(url)
	self.downloadUrl = url
end

function GlobalData:getDownloadUrl()
	return self.downloadUrl
end

function GlobalData:setOpenPay(isOpenPay)
	self.isOpenPay = isOpenPay
end

function GlobalData:getIsOpenPay()
	return self.isOpenPay
end

--设置保存阵型,0不保存,1保存
function GlobalData:setLockFormation(lock)
	if lock == 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('MAP_UI_10'), COLOR_TYPE.GREEN)
	else
		promptmgr:showSystenHint(GlobalApi:getLocalStr('MAP_UI_9'), COLOR_TYPE.RED)
	end
	local uid = UserData:getUserObj():getUid()
	cc.UserDefault:getInstance():setFloatForKey(uid .. "lockFormation", lock)
end

function GlobalData:getLockFormation()
	local uid = UserData:getUserObj():getUid()
	return cc.UserDefault:getInstance():getFloatForKey(uid .. "lockFormation")
end


-- 判断是否今日首次登陆
function GlobalData:TodayFirstLogin()	
	local curTime = GlobalData:getServerTime()
	local preTime = GlobalData:WithdrawServerTime()	
	print("preTime:"..preTime)
	print("curTime:"..curTime)
	-- 判断两个时间戳是否是同一天
	local n_short_time,n_long_time,carry,diff = os.date('*t',preTime),os.date('*t',curTime),false,{}
	-- local colMax = {60,60,24,os.date('*t',os.time{year=n_short_time.year,month=n_short_time.month+1,day=0}).day,12,0}
	n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0) -- handle dst
	-- for i,v in ipairs({'sec','min','hour','day','month','year'}) do
	-- 	diff[v] = n_long_time[v] - n_short_time[v] + (carry and -1 or 0)
	-- 	print(diff[v])
	-- 	carry = diff[v] < 0
	-- 	if carry then
	-- 		diff[v] = diff[v] + colMax[i]
	-- 	end
	-- end
	for i,v in ipairs({'day','month','year'}) do
		diff[v] = n_long_time[v] - n_short_time[v]
		-- if diff[v] < 0 then
		-- 	carry = true
		-- 	print("今日首次登陆")
		-- end
	end
	if diff['year'] < 0 then
		print("今日首次登陆")
		return true
	elseif diff['month'] < 0 then
		print("今日首次登陆")
		return true
	elseif diff['day'] < 0 then
		print("今日首次登陆")
		return true
	end
	return carry
end

-- 存储登陆时候的时间戳
function GlobalData:StoreServerTime(time,uid)
	local serverTime = GlobalData:getServerTime()
	cc.UserDefault:getInstance():setIntegerForKey(uid.."preTime",serverTime)
end

-- 读取存储的时间戳
function GlobalData:WithdrawServerTime()
	local uid = UserData:getUserObj():getUid()
	return cc.UserDefault:getInstance():getIntegerForKey(uid.."preTime")
end
