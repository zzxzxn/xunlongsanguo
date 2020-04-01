local ClassPopWindowMainUI = require('script/app/ui/loginpopwindow/popwindowmain')

cc.exports.LoginPopWindowMgr = {
	uiClass = {
        popWindow_open_seven = nil,
        popWindow_first_pay = nil,
        popWindow_daily_recharge = nil,
        popWindow_single_recharge = nil,
        popWindow_exchange_points = nil,
        popWindow_todaydouble = nil,
        popWindow_tavern_recruit = nil,
        popWindow_lucky_dragon = nil,
        popWindow_tavern_recruit_level = nil,
	}
}

-- 弹窗类型
cc.exports.POP_WINDOW_TYPE = {
    VERSION_TYPE = 1,                       -- 游戏版本更新内容弹窗
    OFFLINE_ACTIVITIES_TYPE = 2,            -- 游戏线下活动内容弹窗
    ACTIVITIES_IN_GAME_TYPE = 3,            -- 游戏内开启活动弹窗
    FUNCTION_TYPE = 4,                      -- 游戏内功能型弹窗
}

setmetatable(LoginPopWindowMgr.uiClass, {__mode = "v"})

function LoginPopWindowMgr:showPopWindow()
    if GuideMgr:isRunning() == true then
        return
    end

    local loginPopWindowLevelLimit = tonumber(GlobalApi:getGlobalValue('loginPopWindowLevelLimit'))
    if UserData:getUserObj():getLv() < loginPopWindowLevelLimit then
        return
    end

    local loginPopWindowConf = GameData:getConfData("loginpopwindow")
    local showPopWindow = {}
    for i = 1,#loginPopWindowConf do
        if loginPopWindowConf[i].isShow == 1 then
            if loginPopWindowConf[i].key == 'default' and LoginPopWindowMgr:getTodayVisible() == false then
            else
                table.insert(showPopWindow,loginPopWindowConf[i])
            end
        end
    end

    -- 小的优先级先弹出来
    table.sort(showPopWindow,function(a, b)
		return b.popPriority > a.popPriority
	end)

    -- 目前就2种
    local showPop = {}
    for i = 1,#showPopWindow do
        local popPriority = showPopWindow[i].popPriority
        if showPop[popPriority] == nil then
            showPop[popPriority] = {}
        end
        table.insert(showPop[popPriority],showPopWindow[i])
    end

    -- 在子窗口中大在前
    for i = 1,#showPop do
        table.sort(showPop[i],function(a, b)
		    return b.popSubPriority > a.popSubPriority
	    end)
    end

    for i = 1,#showPop do
        local data = showPop[i]
        if data[1].key == 'default' then
            self:showDefault(data)
        elseif data[1].key == 'hook' then
            self:showHook(data)
        end
    end
end

function LoginPopWindowMgr:showDefault(data)
    -- 判断是否开启
    local showTab = {}
    for i = 1,#data do
        local isNeedTimeControl = data[i].isNeedTimeControl
        local activityKey = data[i].activityKey

        if isNeedTimeControl == 1 then
            if activityKey ~= '0' then
                if activityKey == 'first_pay' then
                    if UserData:getUserObj():getActivityStatus(activityKey) == true and UserData:getUserObj():judgeFirstPayIsOpen() == true then
                        table.insert(showTab,data[i])
                    end
                else
                    if UserData:getUserObj():getActivityStatus(activityKey) == true then
                        table.insert(showTab,data[i])
                    end
                end
            else
                local nowTime = Time.getCorrectServerTime()
                local startTime = GlobalApi:convertTime(1,data[i].startTime)
                local endTime = GlobalApi:convertTime(1,data[i].endTime)
                if nowTime < startTime or nowTime > endTime then
                else
                    table.insert(showTab,data[i])
                end

            end
        else
            table.insert(showTab,data[i])
        end
    end

    -- 弹窗界面传入showTab,这里只有1个
    if #showTab > 0 then
        if showTab[1].defaultKey == 'open_seven' then
            self:showPopWindowOpenSevenUI(showTab)
        elseif showTab[1].defaultKey == 'first_pay' and UserData:getUserObj():getActivityInfo().first_pay.rechargeId == 0 then
            self:showPopWindowFirstPayUI(showTab)
        elseif showTab[1].defaultKey == 'daily_recharge' then
            self:showPopWindowDailyRechargeUI(showTab)
        elseif showTab[1].defaultKey == 'single_recharge' then
            self:showPopWindowSingleRechargeUI(showTab)
        elseif showTab[1].defaultKey == 'exchange_points' then
            self:showPopWindowExchangePointsUI(showTab)
        elseif showTab[1].defaultKey == 'todaydouble' then
            self:showPopWindowTodayDoubleUI(showTab)
        elseif showTab[1].defaultKey == 'tavern_recruit' then
            self:showPopWindowTavernRecruitUI(showTab)
        elseif showTab[1].defaultKey == 'lucky_dragon' then
            self:showPopWindowLuckyDragonUI(showTab)
        elseif showTab[1].defaultKey == 'tavern_recruit_level' then
            self:showPopWindowTavernRecruitLevelUI(showTab)
        end
    end
end

function LoginPopWindowMgr:getTodayVisible()
    local updateDay = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
    local userDefault = tonumber(cc.UserDefault:getInstance():getStringForKey(UserData:getUserObj():getUid() .. 'popwindowtodaydata',''))
    if userDefault == updateDay then
        return false
    else
        return true
    end
end

function LoginPopWindowMgr:setTodayVisible(value)
    cc.UserDefault:getInstance():setStringForKey(UserData:getUserObj():getUid() .. 'popwindowtodaydata',value)
end

function LoginPopWindowMgr:showPopWindowOpenSevenUI(data)
    if self.uiClass["popWindow_open_seven"] == nil then
		self.uiClass["popWindow_open_seven"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_open_seven"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowOpenSevenUI()
	if self.uiClass["popWindow_open_seven"] then
		self.uiClass["popWindow_open_seven"]:hideUI()
		self.uiClass["popWindow_open_seven"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowFirstPayUI(data)
    if self.uiClass["popWindow_first_pay"] == nil then
		self.uiClass["popWindow_first_pay"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_first_pay"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowFirstPayUI()
	if self.uiClass["popWindow_first_pay"] then
		self.uiClass["popWindow_first_pay"]:hideUI()
		self.uiClass["popWindow_first_pay"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowDailyRechargeUI(data)
    if self.uiClass["popWindow_daily_recharge"] == nil then
		self.uiClass["popWindow_daily_recharge"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_daily_recharge"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowDailyRechargeUI()
	if self.uiClass["popWindow_daily_recharge"] then
		self.uiClass["popWindow_daily_recharge"]:hideUI()
		self.uiClass["popWindow_daily_recharge"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowSingleRechargeUI(data)
    if self.uiClass["popWindow_single_recharge"] == nil then
		self.uiClass["popWindow_single_recharge"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_single_recharge"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowSingleRechargeUI()
	if self.uiClass["popWindow_single_recharge"] then
		self.uiClass["popWindow_single_recharge"]:hideUI()
		self.uiClass["popWindow_single_recharge"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowExchangePointsUI(data)
    if self.uiClass["popWindow_exchange_points"] == nil then
		self.uiClass["popWindow_exchange_points"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_exchange_points"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowExchangePointsUI()
	if self.uiClass["popWindow_exchange_points"] then
		self.uiClass["popWindow_exchange_points"]:hideUI()
		self.uiClass["popWindow_exchange_points"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowTodayDoubleUI(data)
    if self.uiClass["popWindow_todaydouble"] == nil then
		self.uiClass["popWindow_todaydouble"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_todaydouble"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowTodayDoubleUI()
	if self.uiClass["popWindow_todaydouble"] then
		self.uiClass["popWindow_todaydouble"]:hideUI()
		self.uiClass["popWindow_todaydouble"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowTavernRecruitUI(data)
    if self.uiClass["popWindow_tavern_recruit"] == nil then
		self.uiClass["popWindow_tavern_recruit"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_tavern_recruit"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowTavernRecruitUI()
	if self.uiClass["popWindow_tavern_recruit"] then
		self.uiClass["popWindow_tavern_recruit"]:hideUI()
		self.uiClass["popWindow_tavern_recruit"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowLuckyDragonUI(data)
    if self.uiClass["popWindow_lucky_dragon"] == nil then
		self.uiClass["popWindow_lucky_dragon"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_lucky_dragon"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowLuckyDragonUI()
	if self.uiClass["popWindow_lucky_dragon"] then
		self.uiClass["popWindow_lucky_dragon"]:hideUI()
		self.uiClass["popWindow_lucky_dragon"] = nil
	end
end

function LoginPopWindowMgr:showPopWindowTavernRecruitLevelUI(data)
    if self.uiClass["popWindow_tavern_recruit_level"] == nil then
		self.uiClass["popWindow_tavern_recruit_level"] = ClassPopWindowMainUI.new(data)
		self.uiClass["popWindow_tavern_recruit_level"]:showUI()
	end
end

function LoginPopWindowMgr:hidePopWindowTavernRecruitLevelUI()
	if self.uiClass["popWindow_tavern_recruit_level"] then
		self.uiClass["popWindow_tavern_recruit_level"]:hideUI()
		self.uiClass["popWindow_tavern_recruit_level"] = nil
	end
end

function LoginPopWindowMgr:showHook(itemData)
    local isOpen = GlobalApi:getOpenInfo("hook")
	if isOpen then
		if BagData:getEquipFull() then
			return
		end
		local diffTime = GlobalData:getServerTime() - MapData.patrol
		if diffTime > tonumber(GlobalApi:getGlobalValue('patrolInterval')) * 60 * 6 then
			local args = {}
			MessageMgr:sendPost('patrol_get_award','battle',json.encode(args),function (response)
				local code = response.code
				local data = response.data
				if code == 0 then
	                local lastLv = UserData:getUserObj():getLv()

					local awards = data.awards
					local gold_xp = data.gold_xp
					if #awards > 0 then
						MapMgr:showPatrolAwardsPanel(awards)
					end
					GlobalApi:parseAwardData(awards)
					GlobalApi:parseAwardData(gold_xp)
					local costs = data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					MapData.patrol = data.patrol or MapData.patrol

	                local nowLv = UserData:getUserObj():getLv()
	                GlobalApi:showKingLvUp(lastLv,nowLv)
				end
			end)
		end
	end
end
