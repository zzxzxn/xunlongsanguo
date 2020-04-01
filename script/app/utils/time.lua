cc.exports.Time = {}

function Time.beginningOfOneDay(t)
    local now = os.date('*t', tonumber(t) + GlobalData:getTimeZoneOffset()*3600)
    local beginDay = os.time{year = now.year, month = now.month, day = now.day, hour = 0}
    return beginDay - GlobalData:getTimeZoneOffset()*3600
end

function Time.activityBeginningOfOneDay(t)
    local now = os.date('*t', tonumber(t) + GlobalData:getTimeZoneOffset()*3600)
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local beginDay = os.time{year = now.year, month = now.month, day = now.day, hour = resetHour}
    return beginDay - GlobalData:getTimeZoneOffset()*3600
end

function Time.beginningOfToday()
    local now = os.date('*t', GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)
    local beginDay = os.time{year = now.year, month = now.month, day = now.day, hour = 0}
    return beginDay - GlobalData:getTimeZoneOffset()*3600
end

function Time.beginningOfWeek(difftime)
    local now = os.date('*t', GlobalData:getServerTime(difftime) + GlobalData:getTimeZoneOffset()*3600)
    local toMonday = now.wday - 2
    -- 表格配置中星期天是一周的最后一天，为7，lua中为一周的开始，wday为1
    -- wday: [1-7] => [Sunday - Saturday]
    if now.wday == 1 then
        toMonday = toMonday + 7
    end

    local beginWeekDay = os.time{year = now.year, month = now.month, day = now.day - toMonday, hour = 0}
    return beginWeekDay - GlobalData:getTimeZoneOffset()*3600
end

function Time.getStr(time)
    local h = math.floor(time/3600)
    local m = math.floor((time%3600)/60)
    return h..GlobalApi:getLocalStr('STR_HOUR')..m..GlobalApi:getLocalStr('STR_MINUTE')
end

--本月
function Time.getCurMonth()
	return os.date("%m", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
end
--本日
function Time.getCurDay()
	return os.date("%d", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
end

--服务器时间推后了5个小时
function Time.getDayToModifiedServerDay()
	local day = os.date('%Y%m%d',GlobalData:getServerTime(GlobalApi:getGlobalValue('resetHour')*3600) + GlobalData:getTimeZoneOffset()*3600)
	return day
end

--当月剩余时间
function Time.getDayHaveInThisMonth()
    local month = Time.getCurMonth()
    local montharr = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local year = os.date("%Y", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then
        montharr[2] = 29
    end
    local day = Time.getCurDay()
    --print('have...'..montharr[month]-day)
    return montharr[month]-day
end

function Time.date(s, t)
    return os.date(s, t + GlobalData:getTimeZoneOffset()*3600)
end

function Time.time(t)
    return os.time{year = t.year, month = t.month, day = t.day, hour = t.hour, min = t.min, sec = t.sec}
end

-- 由于活动activities发的日期，服务器时间也特殊纠正一下
function Time.getCorrectServerTime()
    return GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600
end
