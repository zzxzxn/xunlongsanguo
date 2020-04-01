cc.exports.TaskMgr = {
	uiClass = {
		
	},
	
}

setmetatable(TaskMgr.uiClass, {__mode = "v"})

function TaskMgr:getDailyData(repData)
	if not self.dailyTaskConf then
        self.dailyTaskConf = GameData:getConfData('dailytask')
        self.routetoConf = GameData:getConfData("routeto")
    end

	local cangetCount = 0
	local newData = {}
	for i=1,#self.dailyTaskConf do
		local baseConf = self.dailyTaskConf[i]
		if baseConf.event ~= TEMP_BLOCK_NAME then
			local status = repData.task.daily_reward[tostring(i)] or 2
			local times = repData.task.daily[tostring(i)] or 0
			if status ~= 1 and times >= (baseConf.target or 0) then 		--可领取
				status = 0
				cangetCount = cangetCount + 1
			elseif status ~= 1 and times < (baseConf.target or 0) then 	--未达成
				status = 1
			else 														--已领取
				status = 2
			end
			
			local key = baseConf.key
			local routeto = self.routetoConf[key]
			local desc,isOpen = nil,0
	    	if routeto then
	    		if routeto.value == 2 then
					desc = GlobalApi:getGotoLegionModule(routeto.key,true)
					if not desc then
						isOpen = 0
					end
				elseif routeto.value == 1 then
					desc,isOpen = GlobalApi:getGotoByModule(routeto.key,true)
					if not desc then
						isOpen = 0
					end
				end
	    	end

	    	-- 如果没有达到标准不显示
	    	if not desc then
				newData[#newData + 1] = {
					times = times,
					status = status,
					active = active,
					isOpen = isOpen,
					id = baseConf.id,
					baseConf = baseConf
				}
			end
		end
	end
	self:sortNewData(newData)

	return newData, cangetCount
end

function TaskMgr:sortNewData(data)
	local function sortFn(a,b)
		if a.status == b.status then
			if a.isOpen == b.isOpen then
				return a.baseConf.id < b.baseConf.id
			end
			return a.isOpen < b.isOpen
		end
		return a.status < b.status
	end
	table.sort(data, sortFn)
end

function TaskMgr:getDailyCellDesc(data)
	local baseConf = data.baseConf
	local desc1 = ''
	if baseConf.event == 'food' then
		local nowTime = GlobalData:getServerTime()
		local today = Time.beginningOfToday()
		local time1 = string.split(GlobalApi:getGlobalValue('dailyFoodNoon'),'-')
		-- local time3 = string.split(GlobalApi:getGlobalValue('dailyFoodNight'),'-')
		local time2 = string.split(GlobalApi:getGlobalValue('dailyFoodEvening'),'-')
		local time = {time1,time2}
		local isOut = true
		for i,v in ipairs(time) do
			if nowTime - today < v[2]*3600 then
				desc1 = string.format(GlobalApi:getLocalStr('GET_FOOD_'..i),v[1],v[2])
				isOut = false
				break
			end
		end
		if isOut then
			desc1 = string.format(GlobalApi:getLocalStr('GET_FOOD_1'),time[1][1],time[1][2])
		end
	elseif baseConf.event == 'monthCard' then
		local paymentInfo = UserData:getUserObj():getPayment()
		desc1 = string.format(baseConf.desc,paymentInfo.month_card or 0)
	else
		desc1 = baseConf.desc
	end

	local desc2 = ''
	local desc2Color = COLOR_TYPE.WHITE
	if baseConf.target then
		local x = ((data.times > baseConf.target) and baseConf.target) or data.times
		desc2 = '('..x..'/'..baseConf.target..')'
		if data.times >= baseConf.target then
			desc2Color = COLOR_TYPE.GREEN
		end
	end

	return desc1, desc2, desc2Color
end

function TaskMgr:getDailyReward(dailyDataList, callFunc)
	local getTab = {}
	for k,v in pairs(dailyDataList) do
		if v.status == 0 then
			getTab[#getTab+1] = v.id
		end
	end

	local args = {ids = getTab}
	MessageMgr:sendPost('daily_reward','task',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
        	callFunc(data, getTab)
        end
    end)
end