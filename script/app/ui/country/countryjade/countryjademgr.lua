local CountryJadeMainUI = require("script/app/ui/country/countryjade/countryjademainui")
local CountryJadeChooseCountryUI = require("script/app/ui/country/countryjade/countryjadechoosecountyui")
local CountryJadeReportUI = require("script/app/ui/country/countryjade/countryjadereportui")
local CountryJadeAwardUI = require("script/app/ui/country/countryjade/countryjadeawardui")
local CountryJadeSuccessUI = require("script/app/ui/country/countryjade/countryjadessuccesspanel")

cc.exports.CountryJadeMgr = {
	uiClass = {
		countryJadeMyOwnMainUI = nil,
        countryJadeOtherMainUI = nil,
        countryJadeChooseCountryUI = nil,
        countryJadeReportUI = nil,
        countryJadeAwardUI = nil,
        countryJadeSuccessUI = nil,
        countryJadeSuccessShowStatus = false
	}
}

cc.exports.COUNTRY_JADE_SHOW_TYPE = {
    OWN = 1,        -- 自己国家
	OTHER = 2,      -- 其他国家
}

setmetatable(CountryJadeMgr.uiClass, {__mode = "v"})

function CountryJadeMgr:showMyOwnCountryJadeMainUI()
    -- 这里要加判断条件，是否有这个功能,这里暂时随国家开启而开启
    local function callBack(serverData)
        if self.uiClass["countryJadeMyOwnMainUI"] == nil then
		    self.uiClass["countryJadeMyOwnMainUI"] = CountryJadeMainUI.new(COUNTRY_JADE_SHOW_TYPE.OWN,serverData)
		    self.uiClass["countryJadeMyOwnMainUI"]:showUI()
	    end
    end
    self:getCountryJadeFromServer(callBack)
end

function CountryJadeMgr:hideMyOwnCountryJadeMainUI()
	if self.uiClass["countryJadeMyOwnMainUI"] then
		self.uiClass["countryJadeMyOwnMainUI"]:hideUI()
		self.uiClass["countryJadeMyOwnMainUI"] = nil
	end
end

function CountryJadeMgr:showOtherCountryJadeMainUI(showType,country,offset,limit)
    local function callBack(serverData)
        if self.uiClass["countryJadeOtherMainUI"] == nil then
		    self.uiClass["countryJadeOtherMainUI"] = CountryJadeMainUI.new(showType,serverData,country)
		    self.uiClass["countryJadeOtherMainUI"]:showUI()
	    end
    end
    self:getOtherCountryJadeFromServer(country,offset or 1,limit or self:getCountryJadePageRoomCount(),callBack)
end

function CountryJadeMgr:hideOtherCountryJadeMainUI()
	if self.uiClass["countryJadeOtherMainUI"] then
		self.uiClass["countryJadeOtherMainUI"]:hideUI()
		self.uiClass["countryJadeOtherMainUI"] = nil
	end
end

function CountryJadeMgr:showCountryJadeChooseCountryUI(countryIds)
	if self.uiClass["countryJadeChooseCountryUI"] == nil then
		self.uiClass["countryJadeChooseCountryUI"] = CountryJadeChooseCountryUI.new(countryIds)
		self.uiClass["countryJadeChooseCountryUI"]:showUI()
	end
end

function CountryJadeMgr:hideCountryJadeChooseCountryUI()
	if self.uiClass["countryJadeChooseCountryUI"] then
		self.uiClass["countryJadeChooseCountryUI"]:hideUI()
		self.uiClass["countryJadeChooseCountryUI"] = nil
	end
end

function CountryJadeMgr:showCountryJadeReportUI()   
    local  function callBack(msg)
        if self.uiClass["countryJadeReportUI"] == nil then
		    self.uiClass["countryJadeReportUI"] = CountryJadeReportUI.new(msg)
		    self.uiClass["countryJadeReportUI"]:showUI()
	    end
    end
    self:getBattleReportFromServer(callBack)
end

function CountryJadeMgr:hideCountryJadeReportUI()
	if self.uiClass["countryJadeReportUI"] then
		self.uiClass["countryJadeReportUI"]:hideUI()
		self.uiClass["countryJadeReportUI"] = nil
	end
end

function CountryJadeMgr:showCountryJadeAwardUI()   
    if self.uiClass["countryJadeAwardUI"] == nil then
		self.uiClass["countryJadeAwardUI"] = CountryJadeAwardUI.new()
		self.uiClass["countryJadeAwardUI"]:showUI()
	end
end

function CountryJadeMgr:hideCountryJadeAwardUI()
	if self.uiClass["countryJadeAwardUI"] then
		self.uiClass["countryJadeAwardUI"]:hideUI()
		self.uiClass["countryJadeAwardUI"] = nil
	end
end

function CountryJadeMgr:showCountryJadeSuccessUI(status)   
    if self.uiClass["countryJadeSuccessUI"] == nil then
		self.uiClass["countryJadeSuccessUI"] = CountryJadeSuccessUI.new(status)
		self.uiClass["countryJadeSuccessUI"]:showUI()
	end
end

function CountryJadeMgr:hideCountryJadeSuccessUI()
	if self.uiClass["countryJadeSuccessUI"] then
		self.uiClass["countryJadeSuccessUI"]:hideUI()
		self.uiClass["countryJadeSuccessUI"] = nil
	end
end

----------------------------------------------------------- 通讯 ------------------------------------------------------------------
-- 获取国家玉璧数据,默认返回的是玩家所在的房间
function CountryJadeMgr:getCountryJadeFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("get_main_page", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 领取玉璧
function CountryJadeMgr:getJadeFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("get_jade", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 替换玉璧
function CountryJadeMgr:replaceJadeFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("exchange_jade", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end


-- 加入房间,roomPos   房间位置(1左2右)
function CountryJadeMgr:joinRoomFromServer(roomId,roomPos,callBack)
    local args = {roomId = roomId,roomPos = roomPos}
    MessageMgr:sendPost("join_room", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 退出房间
function CountryJadeMgr:exitRoomFromServer(roomId,callBack)
    local args = {roomId = roomId}
    MessageMgr:sendPost("exit_room", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 喊话
function CountryJadeMgr:broadcastFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("shout", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 获取国家玉璧数据:country 国家, 1/2/3 魏/蜀/吴;offset  起始房间号,limit要获取的房间数量
function CountryJadeMgr:getOtherCountryJadeFromServer(country,offset,limit,callBack)
    local args = {country = country,offset = offset,limit = limit}
    MessageMgr:sendPost("get_country_rooms", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 抢劫
function CountryJadeMgr:robOtherCountryFromServer(country,roomId,roomPos,callBack)
    local args = {country = country,roomId = roomId,roomPos = roomPos}
    MessageMgr:sendPost("rob_room", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        if code == 110 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES116'), COLOR_TYPE.RED)
            return
        end

        self:popErrorInfo(code)
    end)
end

-- 获取战报
function CountryJadeMgr:getBattleReportFromServer(callBack)
    local args = {}
    MessageMgr:sendPost("get_reports", "country_jade", json.encode(args), function (jsonObj)
	    local code = jsonObj.code
	    if code == 0 then
            if callBack then
                callBack(jsonObj.data)
            end
            return
	    end
        self:popErrorInfo(code)
    end)
end

-- 里面的描述暂时这样，弹出窗口暂时为一行
function CountryJadeMgr:popErrorInfo(code)
    if code == 101 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES101'), COLOR_TYPE.RED)
    elseif code == 102 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES102'), COLOR_TYPE.RED)
    elseif code == 103 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES103'), COLOR_TYPE.RED)
    elseif code == 104 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES104'), COLOR_TYPE.RED)
    elseif code == 105 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES105'), COLOR_TYPE.RED)
    elseif code == 106 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES106'), COLOR_TYPE.RED)
    elseif code == 107 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES107'), COLOR_TYPE.RED)
    elseif code == 108 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES108'), COLOR_TYPE.RED)
    elseif code == 109 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES109'), COLOR_TYPE.RED)
    elseif code == 110 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES110'), COLOR_TYPE.RED)
    elseif code == 111 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES111'), COLOR_TYPE.RED)
    elseif code == 112 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES112'), COLOR_TYPE.RED)
    elseif code == 113 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES113'), COLOR_TYPE.RED)
    elseif code == 114 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES114'), COLOR_TYPE.RED)
    elseif code == 115 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES115'), COLOR_TYPE.RED)
    elseif code == 117 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES117'), COLOR_TYPE.RED)
    elseif code == 118 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES118'), COLOR_TYPE.RED)
    end
end
----------------------------------------------------------- 通讯 ------------------------------------------------------------------
--[[
countryJadeRoomCount	60	合璧房间数
countryJadePageRoomCount	4	合璧每页房间数量
countryJadeNeedTime	240	合璧需要时间
countryJadeProtectTime	120	合璧保护时间
countryJadeReportCount	10	战报保存数量
countryJadeMergeCount	3	玩家合璧次数
countryJadeShoutCD	30	喊话CD
countryJadeOpenDays	1,2,3,4,5,6,7	国家玉璧开启天
countryJadeOpenTime	14	国家玉璧开启时间
countryJadeOpenKeepTime	240	国家玉璧开启持续时间（分）
countryJadeJadePrice	20	领取玉璧需要的国家币
countryJadeCloseJadeTime	120	合璧关闭前不能合璧的秒数
--]]
function CountryJadeMgr:getCountryJadeRoomCount()
    return tonumber(GlobalApi:getGlobalValue('countryJadeRoomCount'))
end

function CountryJadeMgr:getCountryJadePageRoomCount()
    return tonumber(GlobalApi:getGlobalValue('countryJadePageRoomCount'))
end

function CountryJadeMgr:getCountryJadeProtectTime()
    return tonumber(GlobalApi:getGlobalValue('countryJadeProtectTime'))
end

function CountryJadeMgr:getCountryJadeReportCount()
    return tonumber(GlobalApi:getGlobalValue('countryJadeReportCount'))
end

function CountryJadeMgr:getCountryJadeMergeCount()
    return tonumber(GlobalApi:getGlobalValue('countryJadeMergeCount'))
end

function CountryJadeMgr:getCountryJadeShoutCD()
    return tonumber(GlobalApi:getGlobalValue('countryJadeShoutCD'))
end

function CountryJadeMgr:getCountryJadeOpenDays()
    return GlobalApi:getGlobalValue('countryJadeOpenDays')
end

function CountryJadeMgr:getCountryJadeOpenTime()
    return tonumber(GlobalApi:getGlobalValue('countryJadeOpenTime'))
end

function CountryJadeMgr:getCountryJadeOpenKeepTime()
    return tonumber(GlobalApi:getGlobalValue('countryJadeOpenKeepTime'))
end

function CountryJadeMgr:getCountryJadeJadePriceCost()
    return tonumber(GlobalApi:getGlobalValue('countryJadeJadePrice'))
end

function CountryJadeMgr:getCountryJadeCloseJadeTime()
    return tonumber(GlobalApi:getGlobalValue('countryJadeCloseJadeTime'))
end

function CountryJadeMgr:getCountryJadeGetJadeFreeTimes()
    return tonumber(GlobalApi:getGlobalValue("countryJadeFreeCount"))
end

-- 暂时足够,true:足够
function CountryJadeMgr:judgetCountryJadePriceIsEnough()
    local userCountryCurrency = UserData:getUserObj():getCountryCurrency()
    if userCountryCurrency >= self:getCountryJadeJadePriceCost() then
        return true
    else
        return false
    end
end

-- 判断国家玉璧是否开启,最大的条件是随国家开启而开启
function CountryJadeMgr:judgeCountryJadeIsOpen()
    local days = self:getCountryJadeOpenDays()
    local dayTab = {}
    string.gsub(days, '[^,]+', function(w) table.insert(dayTab, w) end )

    local time = GlobalData:getServerTime() - 5*3600
    local wday = tonumber(Time.date('%w', time)) -- 这个日期是周几
    if wday == 0 then
        wday = 7
    end

    local judge = false
    for k,v in pairs(dayTab) do
        if tonumber(v) == wday then
            judge = true
            break
        end
    end
    if judge == false then
        return false
    end
    
    -- 判断时刻
    local startTime = self:getCountryJadeOpenTime()
    local keepTime = self:getCountryJadeOpenKeepTime()  -- 分钟
    local now = Time.date('*t', GlobalData:getServerTime())
    if now.hour >= startTime and now.hour <= (keepTime * 60 + startTime) then
        return true
    else
        return false
    end
end

-- 得到玉璧当天的结束时刻
function CountryJadeMgr:getCountryJadeEndTime()
    local startTime = self:getCountryJadeOpenTime()
    local keepTime = self:getCountryJadeOpenKeepTime()  -- 分钟

    local serverTime = GlobalData:getServerTime()
    local now = Time.date('*t', serverTime )
    local endHour = startTime
    local time = Time.time({year = now.year, month = now.month, day = now.day, hour = endHour, min = 0, sec = 0})
    local endTime = time + keepTime * 60
    
    return endTime
end

-- 判断玉璧 是否 合璧关闭前不能合璧的秒数时刻,true即将关闭
function CountryJadeMgr:judgeIsCountryJadeCloseJadeTime()
    local endTime = self:getCountryJadeEndTime()
    local realTime = endTime - self:getCountryJadeCloseJadeTime() * 60

    if GlobalData:getServerTime() >= realTime then
        return true
    else
        return false
    end
end

-- 掠夺保护时间：合璧即将完成不能进行合璧,true:不能掠夺；那如果被掠夺的玩家是没有合璧的呢。。。。。
function CountryJadeMgr:judgeJadeIsCompleteByRob(remainTime)
    --print('==========++++++++++++++prtected' .. remainTime or 99999)
    if remainTime and remainTime < self:getCountryJadeProtectTime() then
        return true
    else
        return false
    end
end

function CountryJadeMgr:showJadeAward(jade)
    local function confirmCallback()
        local showWidgets = {}
        local jadeConf = GameData:getConfData('countryjade')[jade]
		local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..jadeConf.desc..'x'..1, 'font/gamefont.ttf', 24)
		w:setTextColor(COLOR_QUALITY[jadeConf.type + 1])
		w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		table.insert(showWidgets, w)

		promptmgr:showAttributeUpdate(showWidgets)
    end

    local showAwardUI = require('script/app/ui/tips/showawardjadeui').new({{'user','cash',jade}},nil,nil,confirmCallback)
    showAwardUI:showUI()
end
