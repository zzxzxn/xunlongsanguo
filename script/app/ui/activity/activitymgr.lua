local ClassActivityUI = require("script/app/ui/activity/activityui")
local ClassPages = {}
ClassPages["value_package"] = require("script/app/ui/activity/page_sale")      --超值礼包
ClassPages["privilege"]  = require("script/app/ui/activity/page_privilege") --特权礼包
ClassPages["week"]       = require("script/app/ui/activity/page_week")      --每周礼包
ClassPages["levelgift"]  = require("script/app/ui/activity/page_levelgift")	--等级礼包
ClassPages["mooncard"]   = require("script/app/ui/activity/page_mooncard")	--月卡终身卡
ClassPages["petition"]   = require("script/app/ui/activity/page_petition")	--请愿东风
ClassPages["limit_buy"]   = require("script/app/ui/activity/page_limitbuy")	--每日限购
ClassPages["roulette"]   = require("script/app/ui/activity/page_roulette")	--命运之轮
ClassPages["todaydouble"]   = require("script/app/ui/activity/page_todaydouble")	    --今日双倍
ClassPages["login_goodgift"]   = require("script/app/ui/activity/page_logingoodgift")	--登陆好礼
ClassPages["limit_seckill"]   = require("script/app/ui/activity/page_limitseckill")	    --限时秒杀
ClassPages["pay_only"]   = require("script/app/ui/activity/page_payonly")	            --充值专享
ClassPages["limit_group"]   = require("script/app/ui/activity/page_limit_group")	    --限时团购
ClassPages["lucky_wheel"]   = require("script/app/ui/activity/page_luckywheel")	        --幸运轮盘
ClassPages["grow_fund"]   = require("script/app/ui/activity/page_grow_fund")	        --成长基金
ClassPages["day_vouchsafe"]   = require("script/app/ui/activity/page_day_vouchsafe")    -- 每日特惠
ClassPages["cloud_buy"]   = require("script/app/ui/activity/page_cloud_buy")    -- 每日特惠
ClassPages["sky_drop_arms"]   = require("script/app/ui/activity/page_sky_drop_arms")    -- 天降手臂
ClassPages["sky_drop_wing"]   = require("script/app/ui/activity/page_sky_drop_wing")    -- 天降翅膀

ClassPages["accumulate_recharge"]   = require("script/app/ui/activity/page_accumulate_recharge")	        --累计活动
ClassPages["daily_recharge"]        = require("script/app/ui/activity/page_daily_recharge")	                --每日充值
ClassPages["single_recharge"]        = require("script/app/ui/activity/page_single_recharge")	            --每日充值
ClassPages["expend_gift"]        = require("script/app/ui/activity/page_expend_gift")	                    --消费有礼
ClassPages["tavern_recruit"]        = require("script/app/ui/activity/page_tavern_recruit")	                --酒馆招募限时活动
ClassPages["exchange_points"]        = require("script/app/ui/activity/page_exchange_points")	            --积分兑换
ClassPages["daily_cost"]        = require("script/app/ui/activity/page_activity_daily_cost")	            --每日消耗
ClassPages["tavern_recruit_level"]        = require("script/app/ui/activity/page_tavern_recruit_level")	    --酒馆招募等级活动
ClassPages["value_package_new"] = require("script/app/ui/activity/page_sale_new")                           --超值礼包新
ClassPages["day_challenge"] = require("script/app/ui/activity/page_day_challenge")                          --每日挑战
ClassPages["promote_exchange"] = require("script/app/ui/activity/page_promote_exchange")                    --封将兑换
ClassPages["surprise_step"] = require("script/app/ui/activity/page_surprise_step")                          --步步惊喜
ClassPages["human_wing"] = require("script/app/ui/activity/page_human_wing")                                --人皇之翼
ClassPages["human_arms"] = require("script/app/ui/activity/page_human_arms")                                --人皇之武
ClassPages["surprise_turn"] = require("script/app/ui/activity/page_surprise_turn")                          --惊喜转盘
ClassPages["christmas_tree"] = require("script/app/ui/activity/page_christmas_tree")                        
ClassPages["surprise_box"] = require("script/app/ui/activity/page_surprise_box")
ClassPages["buy_hot_free"] = require("script/app/ui/activity/page_buy_hot_free")
ClassPages["invincible_gold_will"] = require("script/app/ui/activity/page_invincible_gold_will")
ClassPages["integral_carnival"] = require("script/app/ui/activity/page_integral_carnival")

ClassPages["sign"]       = require("script/app/ui/activity/page_signmainui")

ClassPages["happy_wheel"]   = require("script/app/ui/activity/page_happywheel")         --如意轮盘

cc.exports.ActivityMgr = {
    uiClass = {
        ActivityUI = nil,
       
    },
    activityDatas = nil,
    sortedDatas = {},

    --打开页面的act
    messageAct = {
        --privilege = "get_privilege_gift",
        week      = "get_week_gift",
        value_package = "get_overvalued_gift",
		levelgift = "get_level_gift",
		limit_buy  = "get_limit_buy",
		petition  = "get_petition",
		roulette  = "get_roulette",
        todaydouble  = "get_todaydouble",
        login_goodgift  = "get_login_goodgift",
        limit_seckill   = "get_limit_seckill",
        pay_only        = "get_pay_only",
        limit_group     = "get_limit_group",
        lucky_wheel     = "get_lucky_wheel",
        grow_fund       = "get_grow_fund",
        accumulate_recharge = "get_accumulate_recharge",
        daily_recharge = "get_daily_recharge",
        single_recharge = "get_single_recharge",
        expend_gift = "get_expend_gift",
        tavern_recruit = "get_tavern_recruit",
        exchange_points = "get_exchange_points",
        daily_cost = "get_daily_cost",
        tavern_recruit_level = "get_tavern_recruit_level",
        value_package_new = "get_overvalued_gift_new",
        day_challenge = "get_day_challenge",
        day_vouchsafe = 'get_day_vouchsafe',
        promote_exchange = 'get_promote_exchange',
        surprise_step = 'get_surprise_step',
        human_wing = 'get_human_wing',
        human_arms = 'get_human_arms',
        happy_wheel     = "get_happy_wheel",
        cloud_buy = "get_cloud_buy",
		surprise_turn = "get_surprise_turn",
		christmas_tree = "get_christmas_tree",
		surprise_box = "get_surprise_box",
        sky_drop_arms = 'get_sky_drop_arms',
        sky_drop_wing = 'get_sky_drop_wing',
		buy_hot_free = 'get_buy_hot_free',
		invincible_gold_will = 'get_gold_will',
		integral_carnival = 'get_integral_carnival',
    }
}


setmetatable(ActivityMgr.uiClass, {__mode = "v"})

--activityName 活动名称 在data/local/activityentry.dat中配置 
function ActivityMgr:showActivityPage(activityName)

    
    local pageData = self:loadPageData(activityName)
    if(pageData == nil) then
        print("Don't has an acitivty data named:"..activityName.." in local/activityentry")
        return
    end

    if(pageData["type"] == 0) then
        print("Selected a disabled activity")
        return
    end

    if(self.uiClass.ActivityUI == nil) then
        self.uiClass.ActivityUI = ClassActivityUI:new()
        self.uiClass.ActivityUI:showUI()
        self.uiClass.ActivityUI:showMenus(pageData["type"])
    end

    if(self.messageAct[activityName]) then
        if activityName == 'todaydouble' or activityName == 'login_goodgift' or activityName == 'limit_seckill' then
            ActivityMgr:OpenPage(activityName,pageData)
            return
        end
        MessageMgr:sendPost(self.messageAct[activityName],'activity',json.encode({}),function(jsonObj)
            print(json.encode(jsonObj))
            if(jsonObj.code ~= 0) then
                return
            end
            ActivityMgr:OpenPage(activityName,pageData,jsonObj.data)
        end)
    else
        ActivityMgr:OpenPage(activityName,pageData)
    end
	
end
function ActivityMgr:OpenPage(activityName,pageData,msg)
   if activityName == 'sign' and self.uiClass[activityName] then
      self.uiClass[activityName] = nil
   end
   if self.uiClass[activityName] == nil then
        if(ClassPages[activityName] == nil) then
            print("Don't has an acitivty class named:"..activityName)
            return
        end

        print("load activity page:"..pageData.uiFilePath)
        local pageUI = cc.CSLoader:createNode(pageData.uiFilePath)
        if(pageUI == nil) then
            print("Can not create ui by file path:"..pageData.uiFilePath)
            return
        end

        self.uiClass.ActivityUI:hideTopCue()
        print("load activity page name is:"..activityName)
        local newPage = ClassPages[activityName]:new()
        newPage.root = pageUI
        newPage:init(msg)
        self.uiClass.ActivityUI:showPage(pageUI,pageData,activityName)
        self.uiClass[activityName] = newPage
    end

end

function ActivityMgr:showMark(activityName, isShow)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showMark(activityName, isShow)
    end
end

function ActivityMgr:showLeftCue(text)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLeftCue(text)
    end
end
function ActivityMgr:showRightCue(text)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightCue(text)
    end
end
function ActivityMgr:showLeftPayOnlyCue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLeftPayOnlyCue()
    end
end
function ActivityMgr:showLefTavernRecruitCue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefTavernRecruitCue()
    end
end
function ActivityMgr:showLefSurpriseStepCue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefSurpriseStepCue()
    end
end
function ActivityMgr:showLefGoldWillTx()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefGoldWillTx()
    end
end
function ActivityMgr:getLefHappyWheelCue()
    if(self.uiClass.ActivityUI ~= nil) then
        return self.uiClass.ActivityUI:getLefHappyWheelCue()
    end
end
function ActivityMgr:getLefIntegralCarnival()
    if(self.uiClass.ActivityUI ~= nil) then
        return self.uiClass.ActivityUI:getLefIntegralCarnival()
    end
end
function ActivityMgr:getLefSurpriseTurnBgCue()
    if(self.uiClass.ActivityUI ~= nil) then
        return self.uiClass.ActivityUI:getLefSurpriseTurnBgCue()
    end
end
function ActivityMgr:getLefChristmasTreeBgCue()
    if(self.uiClass.ActivityUI ~= nil) then
        return self.uiClass.ActivityUI:getLefChristmasTreeBgCue()
    end
end
function ActivityMgr:showLefhumanArmCue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefhumanArmCue()
    end
end
function ActivityMgr:showLefHumanWingCue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefHumanWingCue()
    end
end
function ActivityMgr:showLefSDesc2Cue()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLefSDesc2Cue()
    end
end
function ActivityMgr:showLeftLimitGroupCue(num)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLeftLimitGroupCue(num)
    end
end
function ActivityMgr:showRightCueResetHour()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightCueResetHour()
    end
end
function ActivityMgr:showRightTodayDoubleRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightTodayDoubleRemainTime()
    end
end

function ActivityMgr:showRightLoginGoodGiftRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightLoginGoodGiftRemainTime()
    end
end

function ActivityMgr:showRightAccumulateRechargeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightAccumulateRechargeRemainTime()
    end
end
function ActivityMgr:showRightExpendGiftRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightExpendGiftRemainTime()
    end
end
function ActivityMgr:showRightDayChallengeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightDayChallengeRemainTime()
    end
end
function ActivityMgr:showRightSurpriseStepRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSurpriseStepRemainTime()
    end
end
function ActivityMgr:showRightHumanWingRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightHumanWingRemainTime()
    end
end
function ActivityMgr:showRightHumanArmsRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightHumanArmsRemainTime()
    end
end
function ActivityMgr:showRightLimitSeckillRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightLimitSeckillRemainTime()
    end
end
function ActivityMgr:showRightPromoteExchangeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightPromoteExchangeRemainTime()
    end
end
function ActivityMgr:showRightExchangePointsRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightExchangePointsRemainTime()
    end
end
function ActivityMgr:showRightTavernRecruitRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightTavernRecruitRemainTime()
    end
end
function ActivityMgr:showRightTavernRecruitLevelRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightTavernRecruitLevelRemainTime()
    end
end
function ActivityMgr:showRightDailyRechargeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightDailyRechargeRemainTime()
    end
end
function ActivityMgr:showRightSurpriseTurnRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSurpriseTurnRemainTime()
    end
end
function ActivityMgr:showRightChristmasTreeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightChristmasTreeRemainTime()
    end
end
function ActivityMgr:showRightSurpriseBoxRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSurpriseBoxRemainTime()
    end
end
function ActivityMgr:showRightBuyHotFreeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightBuyHotFreeRemainTime()
    end
end
function ActivityMgr:showRightInvincibleGoldWillRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightInvincibleGoldWillRemainTime()
    end
end
function ActivityMgr:showRightIntegralCarnivalRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightIntegralCarnivalRemainTime()
    end
end
function ActivityMgr:showRightDailyCostRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightDailyCostRemainTime()
    end
end
function ActivityMgr:showRightSingleRechargeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSingleRechargeRemainTime()
    end
end
function ActivityMgr:showRightLuckyWheelRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightLuckyWheelRemainTime()
    end
end
function ActivityMgr:showLuckyWheelCount(count)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showLuckyWheelCount(count)
    end
end
function ActivityMgr:showRightHappyWheelRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightHappyWheelRemainTime()
    end
end
function ActivityMgr:showHappyWheelCount(count)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showHappyWheelCount(count)
    end
end
function ActivityMgr:showRightLimitGroupRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightLimitGroupRemainTime()
    end
end

function ActivityMgr:showRightPayOnlyRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightPayOnlyRemainTime()
    end
end

function ActivityMgr:showRightCueMonthResetHour()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightCueMonthResetHour()
    end
end
function ActivityMgr:ShowPetitionTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:ShowPetitionTime()
    end
end
function ActivityMgr:ShowRemainCount(count)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:ShowRemainCount(count)
    end
end
function ActivityMgr:ShowRouletteRemainCount(count)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:ShowRouletteRemainCount(count)
    end
end
function ActivityMgr:ShowRightCueResetHourBySale(count)
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:ShowRightCueResetHourBySale(count)
    end
end
function ActivityMgr:showRightSaleNewRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSaleNewRemainTime()
    end
end
function ActivityMgr:showRightDayVouchsafeRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightDayVouchsafeRemainTime()
    end
end
function ActivityMgr:showRightSkyDropArmsRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSkyDropArmsRemainTime()
    end
end
function ActivityMgr:showRightSkyDropWingRemainTime()
    if(self.uiClass.ActivityUI ~= nil) then
        self.uiClass.ActivityUI:showRightSkyDropWingRemainTime()
    end
end
function ActivityMgr:removePepetion()
    --if(self.uiClass.ActivityUI ~= nil) then
        --self.uiClass.ActivityUI:removePepetion()
    --end
end

function ActivityMgr:onPageHide(activityName)
    if(self.uiClass[activityName] ~= nil) then
        self.uiClass[activityName] = nil
    end
end
function  ActivityMgr:hideUI()
    if self.uiClass.ActivityUI then
        self.uiClass.ActivityUI:ActionClose(call)
		self.uiClass.ActivityUI = nil
	end
    for key,uiClass in pairs(self.uiClass) do
        self.uiClass[key] = nil
    end

    
end
function ActivityMgr:loadPageData(activityName)
    if(self.activityDatas == nil) then
        self.activityDatas = GameData:getConfData("local/activityentry")
    end
    return self.activityDatas[activityName]
end
function ActivityMgr:getMenusAndCloseBtn()
    if(self.uiClass.ActivityUI ~= nil) then
        local menus,closeBtn,cue4Help = self.uiClass.ActivityUI:getMenusAndCloseBtn()
        return menus,closeBtn,cue4Help
    end
end
function ActivityMgr:getMenusAndCloseBtn2()
    if(self.uiClass.ActivityUI ~= nil) then
        local menus,closeBtn,recruitHelp,surpriseStepBuyImg = self.uiClass.ActivityUI:getMenusAndCloseBtn2()
        return menus,closeBtn,recruitHelp,surpriseStepBuyImg
    end
end
function ActivityMgr:getDatasByType(activityType)
    if(self.sortedDatas[activityType] ~= nil) then
        return self.sortedDatas[activityType]
    end

    if(self.activityDatas == nil) then
        self.activityDatas = GameData:getConfData("local/activityentry")
    end
   
    local ret = {}
    for key,activityData in pairs(self.activityDatas) do
        if(activityData["type"] == activityType) then
            table.insert(ret,activityData)
        end
    end
    table.sort(ret,function (a,b)  return a.order < b.order end)
    self.sortedDatas[activityType] = ret
    return ret
end

function ActivityMgr:showTimeLimitActivityByType(activityType)
    local activityDatas = GameData:getConfData("local/activityentry")

    local ret = {}
    for key,activityData in pairs(activityDatas) do
        if(activityData["type"] == activityType) then
            table.insert(ret,activityData)
        end
    end
    table.sort(ret,function (a,b)  return a.order < b.order end)
    
    for i = 1,#ret do
        if UserData:getUserObj():getActivityStatus(ret[i].commonConfigKey) == true then
            ActivityMgr:showActivityPage(ret[i].commonConfigKey)
            break
        end
    end
end

function ActivityMgr:showActivityByType(activityType)
	local activityDatas = GameData:getConfData("local/activityentry")

    local ret = {}
    for key,activityData in pairs(activityDatas) do
        if(activityData["type"] == activityType) then
            table.insert(ret,activityData)
        end
    end
    table.sort(ret,function (a,b)  return a.order < b.order end)
    
    for i = 1,#ret do
		local data = ret[i]
        local privilegeIsFinished = true
        if data.key == 'privilege' and UserData:getUserObj():judgePrivilegeActivityIsFinished() == true then
            privilegeIsFinished = false
        end

        local levelGiftIsFinished = true
        if data.key == 'levelgift' and UserData:getUserObj():judgeLevelGiftIsFinished() == true then
            levelGiftIsFinished = false
        end

        if(ActivityMgr:getActivityTime(data.commonConfigKey) ~= 0) and (ActivityMgr:getActivityTime(data.commonConfigKey) ~= -2) and data.key ~= 'limit_seckill' and data.key ~= 'roulette' and privilegeIsFinished and levelGiftIsFinished then
            ActivityMgr:showActivityPage(ret[i].commonConfigKey)
            break
        end
    end
end

function ActivityMgr:judgeLimitActivityIsOpen()
    local activityDatas = GameData:getConfData("local/activityentry")

    local ret = {}
    for key,activityData in pairs(activityDatas) do
        if(activityData["type"] == 3) then
            table.insert(ret,activityData)
        end
    end
    table.sort(ret,function (a,b)  return a.order < b.order end)
    
    local judge = false
    for i = 1,#ret do
        if UserData:getUserObj():getActivityStatus(ret[i].commonConfigKey) == true then
            judge = true
            break
        end
    end
    return judge
end
--------------------------
--return 0：未开启
--return -1：没配置或无限期开启
--return >0 : 剩余活动时间
---------------------------

function ActivityMgr:getActivityTime(stype)
    local conf = GameData:getConfData('activities')[stype]
    if not conf then
        return -1
    end
    local level = UserData:getUserObj():getLv()
    if level < conf.openLevel then
        return -2
    end

    -- 今日双倍特殊处理
    if stype == 'todaydouble' then
        local time = Time.getCorrectServerTime()
        local startTime = GlobalApi:convertTime(1,conf.startTime)
        local diffTime = time - startTime
        local wday = math.ceil(diffTime/(24*3600))

        local todayDoubleConf = GameData:getConfData('avtodaydouble')
        local data = todayDoubleConf[wday]
        if not data then
            return 0
        end

        local gateway1 = data.gateway1
        local gateway2 = data.gateway2

        if gateway1 == '0' and gateway2 == '0' then
            return 0
        end
    end


    local openDay = conf.openDay
    local duration = conf.duration
    local delayDays = conf.delayDays
    local openLoginDay = conf.openLoginDay

    local openServerTime = UserData:getUserObj():getServerOpenTime()
    local nowTime = Time.getCorrectServerTime()

    local a = tonumber(Time.date('%Y%m%d', openServerTime))
    local b = tonumber(Time.date('%Y%m%d', nowTime))

    if openDay ~= 0 then    -- openDay等于0表示就是开服活动
        local now = Time.date('*t', openServerTime)
        local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
        local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})

        local endTime = GlobalApi:convertTime(1,conf.endTime)
        local delayTime = conf.delayDays * 86400
        if conf.startTime and conf.startTime ~= 0 then  -- 如果有开启时间，openDay表示开服时间距离开启时间的天数
            local startTime = GlobalApi:convertTime(1,conf.startTime)
            if conf.type == 1 then
                if (nowTime - newOpenServerTime < openDay * 86400) or (newOpenServerTime > (endTime + delayTime)) then
                    return 0
                end
            else
                if startTime - newOpenServerTime < openDay * 86400 then
                    return 0
                end
            end
        else    -- openDay现在时间距离开服时间的天数
            if conf.type == 1 then
                if (nowTime - newOpenServerTime < openDay * 86400) or (newOpenServerTime > (endTime + delayTime)) then
                    return 0
                end
            else
                if nowTime - newOpenServerTime < openDay * 86400 then
                    return 0
                end
            end
        end
    end

    if conf.type == 0 then -- 开服活动
        local openServerTime = UserData:getUserObj():getServerOpenTime()
        local now = Time.date('*t', openServerTime)
        local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
        local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})

        local beginTime = Time.activityBeginningOfOneDay(newOpenServerTime) + openDay*24*3600
        if nowTime - beginTime > (conf.duration + conf.delayDays)* 86400 then
            return 0
        else
            --print(GlobalApi:toStringTime(openServerTime,'YMD',1))
            return (conf.duration + conf.delayDays)* 86400 + beginTime - nowTime 
        end
    elseif conf.type == 1 then -- 限时活动,有种特殊情况，当活动开放距离开服天数和活动开始时间都存在的话
        local startTime = GlobalApi:convertTime(1,conf.startTime)
        local endTime = GlobalApi:convertTime(1,conf.endTime)
        local delayTime = conf.delayDays * 86400
        
        -- print(conf.startTime)
        -- print(startTime)
        -- print(nowTime)
        -- print(endTime + delayTime)
        if nowTime < startTime or nowTime > (endTime + delayTime) then
            return 0
        else
            return endTime + delayTime - nowTime
        end

    elseif conf.type == 2 then -- 等级活动（七日狂欢）（七天乐）,许愿   
        local time = 0
        local stype2 = stype
        if stype == 'three_money_buy' then
            stype2 = 'money_buy2'
        end
        if UserData:getUserObj().activity[stype2] and UserData:getUserObj().activity[stype2]['open_day'] then
    		time = UserData:getUserObj().activity[stype2]['open_day']
    	end

    	local beginTime = GlobalApi:convertTime(2,time) + openDay*24*3600 + 5*3600
    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400 
    	if nowTime < beginTime or nowTime > endTime then
    		return 0,-1
        else
            return -1,endTime - nowTime
    	end
    elseif conf.type == 3 then
        local time = 0
        local stype2 = stype
        if stype == 'three_money_buy' then
            stype2 = 'money_buy2'
        end
        if UserData:getUserObj().activity[stype2] and UserData:getUserObj().activity[stype2]['time'] then
    		time = UserData:getUserObj().activity[stype2]['time']
    	end

        local createTime = UserData:getUserObj():getCreateTime()
        local now = Time.date('*t',createTime)
        local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
        local refTime = GlobalData:getServerTime() - Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
        if(now.hour < resetHour) then
            refTime = refTime + 24*3600
        end
        
        if refTime < openLoginDay*24*3600 then  -- 未开启
            return 0,-1
        else
            if refTime < openLoginDay*24*3600 + (conf.duration + conf.delayDays)*86400 then    -- 未结束
                return -1,(conf.duration + conf.delayDays)* 86400 - (refTime - openLoginDay*24*3600)
            else
                return 0,-1
            end
        end

        --[[
    	local beginTime = time
    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400
    	if nowTime < beginTime or nowTime > endTime then
    		return 0,-1
        else
            return -1,endTime - nowTime
    	end
        --]]
    elseif conf.type == 4 then
        local time = 0
        if UserData:getUserObj().activity[stype] and UserData:getUserObj().activity[stype]['time'] then
    		time = UserData:getUserObj().activity[stype]['time']
    	end
    	local beginTime = GlobalApi:convertTime(2,time) + openDay*24*3600
    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400 + 5*3600
    	if nowTime < beginTime or nowTime > endTime then
    		return 0,-1
        else
            return -1,endTime - nowTime
    	end
    else
        return 0
    end
    return -1
end

--- 延迟天数不能许愿
function ActivityMgr:judgeActivityIsPetiton()
    local conf = GameData:getConfData('activities')['petition']

    local temp,time = ActivityMgr:getActivityTime("petition")
    if time < 0 then
        return true -- 结束了
    end

    local delayDays = conf.delayDays
    if time < delayDays * 86400 then
        return true
    else
        return false
    end

end

function ActivityMgr:getActivityPetiton()
    MessageMgr:sendPost('get_petition','activity',json.encode({}),function(jsonObj)
        --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end
        UserData:getUserObj().activity.petition.day = jsonObj.data.petition.day
        UserData:getUserObj().activity.petition.got = jsonObj.data.petition.got
        UserData:getUserObj().activity.petition.fan = jsonObj.data.petition.fan
        UserData:getUserObj().activity.petition.reward = jsonObj.data.petition.reward
    end)
end

function ActivityMgr:showGetMoneyDragon()
    local ui = require("script/app/ui/activity/activitygetmoneydragonui").new()
    ui:showUI()
end

