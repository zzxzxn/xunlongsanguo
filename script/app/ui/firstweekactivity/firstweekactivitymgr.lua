local ClassFirstWeekActivityUI = require("script/app/ui/firstweekactivity/firstweekactivityui")

cc.exports.FirstWeekActivityMgr = {
    uiClass = {
        FirstWeekActivityUI = nil,
    },
    daysData = nil,
    taskData = nil,
    currentDay = 1,
}

setmetatable(FirstWeekActivityMgr.uiClass, {__mode = "v"})


function FirstWeekActivityMgr:showUI()
	if self.uiClass.FirstWeekActivityUI == nil then
        self:ReadAndRebulidData()
        self:GetServerData()

        --self.uiClass.FirstWeekActivityUI = ClassFirstWeekActivityUI.new()
	    --self.uiClass.FirstWeekActivityUI:showUI()
	end
end

function FirstWeekActivityMgr:hideUI(call)
	if self.uiClass.FirstWeekActivityUI then
        self.uiClass.FirstWeekActivityUI:ActionClose(call)
		self.uiClass.FirstWeekActivityUI = nil
	end
end

--从服务器获取进度
function  FirstWeekActivityMgr:GetServerData()
     MessageMgr:sendPost('get_openseven','activity',json.encode({}),function(jsonObj)

        if(jsonObj.code ~= 0) then
            return
        end
        local data = jsonObj.data.open_seven
        local openTime = GlobalApi:convertTime(2,tostring(jsonObj.data.open_seven.open_day)) + 5*3600
        self.currentDay = math.floor((Time.getCorrectServerTime() - openTime) /86400) + 1
        print("Current Day:"..self.currentDay)
       
        UserData:getUserObj().activity.open_seven.progress = data.progress
        -- dump(data.progress)

        for key,progress in pairs(data.progress)  do
            local got = progress[2]
            local id = tonumber(key)
            if(self.taskData[id] ~= nil) then
                self.taskData[id].progress = progress[1]
                self.taskData[id].got      = progress[2] ~= 0
            end
        end
        for key,left in pairs(jsonObj.data.left)  do
            local id = tonumber(key)
            if(self.taskData[id] ~= nil) then
                self.taskData[id].left = left
            end
        end
            
        self.uiClass.FirstWeekActivityUI = ClassFirstWeekActivityUI.new()
        self.uiClass.FirstWeekActivityUI.currentDay = self.currentDay
	    self.uiClass.FirstWeekActivityUI:showUI()


        if FirstWeekActivityMgr:judgeLogic() == false then
            UserData:getUserObj().tips.open_seven = 0
        end


    end)
end

--读取配置
function FirstWeekActivityMgr:ReadAndRebulidData(args)
    if(self.daysData ~= nil) then
        return
    end

    if self:judgeNewOrOldSever() then
        self.daysData = GameData:getConfData("openseven")
        self.taskData = GameData:getConfData("opensevenreward")
    else
        self.daysData = GameData:getConfData("oldopenseven")
        self.taskData = GameData:getConfData("oldopensevenreward")
    end
end

function FirstWeekActivityMgr:judgeNewOrOldSever()
    local openServerTime = UserData:getUserObj():getServerOpenTime()
    local now = Time.date('*t', openServerTime)
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})

    local serverTimeLimit = GlobalApi:convertTime(1,'2017:8:23:5:00:00')
    if newOpenServerTime >= serverTimeLimit then
        return true
    else
        return false
    end
end

function FirstWeekActivityMgr:GetTypesOfDay(day)
    if(self.daysData ~= nil) then
        return self.daysData[day]
    end
end
function FirstWeekActivityMgr:GetTaskByID(taskID)
    
    if(self.taskData[taskID] ~= nil) then
        return self.taskData[taskID]
    end
    
    return nil
end
function FirstWeekActivityMgr:SendGetRewardMsg(taskID,halfPriceBuy)
    
    local msg = {}
    msg.id = taskID
    MessageMgr:sendPost('get_openseven_reward','activity',json.encode(msg),function(jsonObj)
        if(jsonObj.code ~= 0) then
            return
        end
        if(self.taskData[taskID] ~= nil) then
            self.taskData[taskID].got = true

            if UserData:getUserObj().activity.open_seven.progress[tostring(taskID)] then
                UserData:getUserObj().activity.open_seven.progress[tostring(taskID)][2] = 1
            end


            if(halfPriceBuy) then
                local awards = jsonObj.data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                end
                local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                self.uiClass.FirstWeekActivityUI:DisableHalfPriceBuyBtn()
            else
                local awards = jsonObj.data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                end
                local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                self.uiClass.FirstWeekActivityUI:RefreshCell(nil,taskID)
                self.uiClass.FirstWeekActivityUI:refreshSelectDayMarks()


                UserData:getUserObj().tips.open_seven = 0


            end
        else
            print("FirstWeekActivityMgr:SendGetRewardMsg: nil taskData")
        end
    end)
end

function FirstWeekActivityMgr:judgeLogic()
    self:ReadAndRebulidData()

    local dataProgress = UserData:getUserObj().activity.open_seven.progress

    if not dataProgress then
        return false
    end

    --local a = dataProgress[tostring(35)]
    local openTime = GlobalApi:convertTime(2,tostring(UserData:getUserObj().activity.open_seven.open_day)) + 5*3600
    self.currentDay = math.floor((Time.getCorrectServerTime() - openTime) /86400) + 1


    for key,progress in pairs(dataProgress)  do
        local got = progress[2]
        local id = tonumber(key)
        if(self.taskData[id] ~= nil) then
            self.taskData[id].progress = progress[1]
            self.taskData[id].got      = progress[2] ~= 0
        end
    end

    for i = 1,self.currentDay do
        
        local types = self:GetTypesOfDay(i)

        if types then
            for ti = 1,#types do
                 local typeData = types[ti]
                 for idx,id in pairs(typeData.task)  do
                     local taskData = self:GetTaskByID(tonumber(id))
                     if(taskData.progress ~= nil and taskData.progress >= taskData.target and not taskData.got) then
                        return true
                     end
                 end

            end
        end



    end


    return false


end



function  FirstWeekActivityMgr:GetNewServerData()
     MessageMgr:sendPost('get_openseven','activity',json.encode({}),function(jsonObj)
        if(jsonObj.code ~= 0) then
            return
        end
        local data = jsonObj.data.open_seven
        local openTime = GlobalApi:convertTime(2,tostring(jsonObj.data.open_seven.open_day)) + 5*3600
        self.currentDay = math.floor((Time.getCorrectServerTime() - openTime) /86400) + 1
       
        UserData:getUserObj().activity.open_seven.progress = data.progress
        

        --去刷新sidebar
        --if UIManager.sidebar then
            --UIManager.sidebar:setActivityBtnsPosition()

        --end
        


    end)
end