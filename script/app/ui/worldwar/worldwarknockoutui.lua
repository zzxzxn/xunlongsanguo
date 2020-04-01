local WorldWarKnockoutUI = class("WorldWarKnockoutUI", BaseUI)
local MAX_PEOPLE = 16
local NORMAL = 0
local SPECIAL = 1
function WorldWarKnockoutUI:ctor(top32,records,replays,result)
    self.uiIndex = GAME_UI.UI_WORLDWARKNOCKOUTUI
    self.nameTxs = {}               -- 名字label
    self.bLineImgs = {}             -- 蓝线
    self.sBtns = {}                 -- 支持按钮
    self.rImgs = {}                 -- 放大镜
    self.page = 1                   -- 32强当前页数
    self.maxPage = 2                -- 最大页数
    self.style = NORMAL             -- 正常为支持32，32进16 特殊为其他阶段
    self.records = records or {}
    self.top32 = top32 or {}
    self.replays = replays or {}
    self.result = result or {}
end

function WorldWarKnockoutUI:updateName()
    local nameTx = self.namePl:getChildByName('name_tx')
    local serverTx = self.namePl:getChildByName('server_tx')
    local myuid = UserData:getUserObj():getUid()
    local records = self.records
    local infoTx = self.normalBtn:getChildByName('info_tx')
    if self.style == NORMAL then
        infoTx:setString('8'..GlobalApi:getLocalStr('KNOCK_QIANG'))
        for i=1,MAX_PEOPLE do
            local data = self.top32[i + (self.page - 1)*MAX_PEOPLE]
            if myuid == data.uid then
                self.nameTxs[i]:setColor(COLOR_TYPE.GREEN)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            elseif WorldWarMgr:getRise(i + (self.page - 1)*MAX_PEOPLE,records) == false then
                self.nameTxs[i]:setColor(COLOR_TYPE.GRAY)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
            else
                self.nameTxs[i]:setColor(COLOR_TYPE.WHITE)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            end
            self.nameTxs[i]:setString(data.name)
        end
        -- self.rImgs[15]:setPosition(cc.p(480,320))
        nameTx:setString('')
        serverTx:setString('')
    else
        infoTx:setString('16'..GlobalApi:getLocalStr('KNOCK_QIANG'))
        for i=1,MAX_PEOPLE do
            local playerIndex = self.records[i] + 1
            local data = self.top32[playerIndex]
            if myuid == data.uid then
                self.nameTxs[i]:setColor(COLOR_TYPE.GREEN)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            elseif WorldWarMgr:getRise(playerIndex,records) == false then
                self.nameTxs[i]:setColor(COLOR_TYPE.GRAY)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
            else
                self.nameTxs[i]:setColor(COLOR_TYPE.WHITE)
                self.nameTxs[i]:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            end
            self.nameTxs[i]:setString(data.name)
        end
        if self.records[31] and self.records[31] > -1 then
            local player = self.top32[self.records[31] + 1]
            nameTx:setString(player.name)
            serverTx:setString(string.format(GlobalApi:getLocalStr('FU_1'),player.sid))
            -- self.rImgs[15]:setPosition(cc.p(480,235))
            self.barBg:setVisible(false)
        else
            nameTx:setString('')
            serverTx:setString('')
            -- self.rImgs[15]:setPosition(cc.p(480,320))
        end
    end
end

function WorldWarKnockoutUI:updatePageBtn()
    if self.style == NORMAL then
        self.leftBtn:setVisible(true)
        self.rightBtn:setVisible(true)
        if self.page <= 1 then
            self.leftBtn:setTouchEnabled(false)
            self.leftBtn:setBright(false)
            self.page = 1
        else
            self.leftBtn:setTouchEnabled(true)
            self.leftBtn:setBright(true)
        end

        if self.page >= self.maxPage then
            self.page = self.maxPage
            self.rightBtn:setTouchEnabled(false)
            self.rightBtn:setBright(false)
        else
            self.rightBtn:setTouchEnabled(true)
            self.rightBtn:setBright(true)
        end
    else
        self.leftBtn:setVisible(false)
        self.rightBtn:setVisible(false)
    end
end

function WorldWarKnockoutUI:getPage(index)
    local records = self.records
    if index == 31 then
        return 3
    else
        if index <= 8 or (index >= 17 and index <= 20) or index == 25 or index == 26 or index == 29 then
            return 1
        else
            return 2
        end
    end
end

function WorldWarKnockoutUI:getRecordsId(index)
    local id = 0
    if self.style == NORMAL then
        if index <= 8 then
            id = (self.page - 1) * 8 + index
        elseif index <= 12 then
            id = (self.page - 1) * 4 + index + 8
        elseif index <= 14 then
            id = (self.page - 1) * 2 + index + 8 + 4
        else
            id = (self.page - 1) * 1 + index + 8 + 4 + 2
        end
    else
        id = index + 16
    end
    return id
end

function WorldWarKnockoutUI:updateBlinePanel()
    local records = self.records
    for i,v in ipairs(self.bLineImgs) do
        v:setVisible(false)
    end
    if self.style == NORMAL then
        for i,v in pairs(self.bLineImgs1) do
            v:setVisible(#records > 16)
        end
        for i,v in ipairs(self.dLineImg) do
            v:setVisible(i > 9)
        end
        for i,v in ipairs(records) do
            local index
            if v ~= -1 then
                local id = v + 1
                local page = self:getPage(i)
                if self.page == page then
                    index = id - (page - 1) * 16
                    if i <= 16 then
                    elseif i <= 24 then
                        index = math.floor((index - 1)/2) + 1 + 16
                    elseif i <= 28 then
                        index = math.floor((index - 1)/4) + 1 + 24
                    elseif i <= 30 then
                        index = math.floor((index -  1)/8) + 1 + 28
                    else
                        index = math.floor((index - 1)/16) + 1 + 30
                    end
                    self.bLineImgs[index]:setVisible(i <= 16 and true)
                    if i <= 16 then
                        local index1 = (i - 1)%8 + 1
                        -- print(index1,math.ceil(index1 + 31))
                        self.bLineImgs1[math.ceil(index1 + 31)]:setVisible(true)
                    end
                end
            end
        end
    else
        for i=17,#records do
            local index,index1,index2
            local currIndex
            if records[i] ~= -1 then
                if i <= 24 then
                    index = i - 16
                    index1 = index * 2 - 1
                    index2 = index * 2
                elseif i <= 28 then
                    index = i - 24
                    index1 = index * 2 - 1 + 16
                    index2 = index * 2 + 16
                elseif i <= 30 then
                    index = i - 28
                    index1 = index * 2 - 1 + 24
                    index2 = index * 2 + 24
                elseif i <= 31 then
                    index = i - 30
                    index1 = index * 2 - 1 + 28
                    index2 = index * 2 + 28
                end
                currIndex = ((records[i] == records[index1]) and index1) or index2
                self.bLineImgs[currIndex]:setVisible(true)
            end
        end
        if records[31] and records[31] ~= -1 then
            self.bLineImgs[31]:setVisible(true)
        end
        for i,v in ipairs(self.dLineImg) do
            v:setVisible(i <= 9)
        end
        for i,v in pairs(self.bLineImgs1) do
            v:setVisible(false)
        end
    end
end

function WorldWarKnockoutUI:updateSbtnRimg()
    local records = self.records
    local sBtnInfo,progressNum = WorldWarMgr:getProgressInfo(self.style,WorldWarMgr.progress)
    local support = nil
    if WorldWarMgr.supportData then
        support = WorldWarMgr.supportData[tostring(progressNum)]
    end
    for i,v in ipairs(self.sBtns) do
        local isV = true
        if self.style == NORMAL then
            isV = i <= 8
        end
        if i >= sBtnInfo.min and i <= sBtnInfo.max then
            local recordId = self:getRecordsId(i)
            local idA,idB = WorldWarMgr:getPlayerId(recordId,self.records)
            local playerA,playerB = self.top32[idA],self.top32[idB]
            -- v:setVisible(true)
            local infoTx = v:getChildByName('info_tx')
            if not support then
                infoTx:setString(GlobalApi:getLocalStr('SUPPORT'))
                v:setTouchEnabled(true)
            elseif (support[1] ~= playerA.uid) and (support[1] ~= playerB.uid) then
                -- v:setVisible(false)
                isV = false
            else
                infoTx:setString(GlobalApi:getLocalStr('SUPPORT_1'))
                v:setTouchEnabled(false)
            end
        else
            -- v:setVisible(false)
            isV = false
        end
        v:setVisible(isV)
    end
    for i,v in ipairs(self.rImgs) do
        local index = self:getRecordsId(i)
        local isV = true
        if self.style == NORMAL then
            isV = i <= 8
        end
        if records[index] then
            v:setVisible(true)
            if records[index] == -1 then
                v:loadTextureNormal('uires/ui/worldwar/worldwar_fangda_1.png')
                local animation = v:getChildByName('ui_zhandou_a')
                local size = v:getContentSize()
                if not animation then
                    animation = GlobalApi:createLittleLossyAniByName("ui_zhandou")
                    animation:getAnimation():playWithIndex(0, -1, 1)
                    v:addChild(animation)
                    animation:setPosition(cc.p(size.width/2 + 2,size.height/2 + 3))
                    animation:setName('ui_zhandou_a')
                else
                    animation:setVisible(true)
                end
            else
                v:loadTextureNormal('uires/ui/worldwar/worldwar_fangda.png')
                local animation = v:getChildByName('ui_zhandou_a')
                if animation then
                    animation:setVisible(false)
                end
            end
        else
            v:setVisible(false)
            isV = false
        end
        v:setVisible(isV)
    end
    -- print('======================',WorldWarMgr.progress)
    -- printall(WorldWarMgr.supportData)
end

function WorldWarKnockoutUI:getNextProgress(progress)
    if progress == 16 then
        return 8
    elseif progress == 8 then
        return 4
    elseif progress == 4 then
        return 2
    elseif progress == 2 then
        return 1
    end
end

function WorldWarKnockoutUI:getNowProgress()
    -- print('getNowProgress === ',WorldWarMgr.progress)
    if WorldWarMgr.progress == 'sup_16' or WorldWarMgr.progress == 'sup_8' or WorldWarMgr.progress == 'sup_4'
        or WorldWarMgr.progress == 'sup_2' or WorldWarMgr.progress == 'sup_1' then
        local progressArr = string.split(WorldWarMgr.progress , '_')
        local bt = Time.beginningOfWeek()
        local dt = WorldWarMgr:getScheduleByProgress(tonumber(progressArr[2]))
        local startTime = bt + (tonumber(dt.startWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
        local nowTime = GlobalData:getServerTime()
        -- print('======================111111',(nowTime - bt)/3600/24)
        local time = startTime - nowTime
        -- if time <= 0 then
        --     time = 1
        -- end
        return 0,startTime - nowTime
    elseif WorldWarMgr.progress ~= 'rank' and WorldWarMgr.progress ~= 'over' and WorldWarMgr.progress ~= 'close' then
        local bt = Time.beginningOfWeek()
        local dt = WorldWarMgr:getScheduleByProgress(tonumber(WorldWarMgr.progress))
        local startTime = bt + (tonumber(dt.startWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
        local endTime = bt + (tonumber(dt.endWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600 + tonumber(dt.interval) * 2 *60
        local nowTime = GlobalData:getServerTime()
        -- print('=======================xxxxxxxxxxxxxxxxxxx2',nowTime > startTime)
        if nowTime > startTime and nowTime < endTime then
            local diffTime = endTime - nowTime
            local per = (diffTime - diffTime % (tonumber(dt.interval) * 60))/ (tonumber(dt.interval) * 60)
            local time = (diffTime - 1) % (tonumber(dt.interval) * 60)
            -- if time <= 0 then
            --     time = 1
            -- end
            -- if per == 0 then
            --     time = 0
            -- end
            -- print('=======================1',2 - per)
            return 2 - per, time
        elseif nowTime > endTime then
            local progress = self:getNextProgress(WorldWarMgr.progress)
            if progress then
                local bt = Time.beginningOfWeek()
                local dt = WorldWarMgr:getScheduleByProgress(progress)
                local startTime = bt + (tonumber(dt.startWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
                local endTime = bt + (tonumber(dt.endWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600 + tonumber(dt.interval) * 2 *60
                nowTime = GlobalData:getServerTime()
                local time = startTime - nowTime
                if time <= 0 then
                    time = 1
                end
                return 0,nil
            end
            -- print('=======================xxxxxxxxxxxxxxxxxxx1')
            return 0,nil
        end
    end
    return 0,nil
end

function WorldWarKnockoutUI:updateTimeInfo()
    local myuid = UserData:getUserObj():getUid()
    local me = WorldWarMgr:getPlayerById(myuid,self.top32) or {index = 0}
    local index = me.index
    local time = nil
    local per = nil
    local timeStr = ''
    local records = self.records
    -- self.fightIndex = -1
    self.emBtn:setVisible(false)
    local nowIndex = 0
    if index > 0 then
        local temIndex1 = (index - 1 - (index - 1)%2)/2 + 1
        local temIndex2 = 16 + (index - 1 - (index - 1)%4)/4 + 1
        local temIndex3 = 24 + (index - 1 - (index - 1)%8)/8 + 1
        local temIndex4 = 28 + (index - 1 - (index - 1)%16)/16 + 1
        local temIndex5 = 31
        per,time = self:getNowProgress()
        -- if per == 0 then
        --     per = 2 
        -- end
        self.nowProcess = per
        if #records == 16 then
            nowIndex = temIndex1
            if records[temIndex1] + 1 == 0 then   
                -- self.emBtn:setVisible(true)
                -- self.fightIndex = 0
            elseif records[temIndex1] + 1 == index then
                -- time = (5 - (per or 13)*5/13) * 5 * 60 + time
                -- time = (5 - per) * 5 * 60 + time
                -- if per == 5 then
                    -- self.emBtn:setVisible(true)
                    -- self.fightIndex = 0
                -- end
            end
        elseif #records == 24 then
            nowIndex = temIndex2
            if records[temIndex1] + 1 == index then
                if records[temIndex2] + 1 == 0 then
                    -- self.emBtn:setVisible(true)
                    -- self.fightIndex = 0
                elseif records[temIndex2] + 1 == index then
                    -- time = (5 - per) * 5 * 60 + time
                    -- if per == 2 then
                        -- self.emBtn:setVisible(true)
                        -- self.fightIndex = 0
                    -- end
                end
            end
        elseif #records == 28 then
            nowIndex = temIndex3
            if records[temIndex2] + 1 == index then
                if records[temIndex3] + 1 == 0 then
                    -- self.emBtn:setVisible(true)
                    -- self.fightIndex = 0
                elseif records[temIndex3] + 1 == index then
                    local per1 = per
                    -- if (per or 13)*5/13 == 5 then
                    --     per1 = 13
                    -- end
                    -- time = (5 -per) * 5 * 60 + time
                    -- if per == 2 then
                        -- self.emBtn:setVisible(true)
                        -- self.fightIndex = 0
                    -- end
                end
            end
        elseif #records == 30 then
            nowIndex = temIndex4
            if records[temIndex3] + 1 == index then
                if records[temIndex4] + 1 == 0 then
                    -- self.emBtn:setVisible(true)
                elseif records[temIndex4] + 1 == index then
                    -- time = (5 - per) * 5 * 60 + time
                    -- if per == 2 then
                        -- self.emBtn:setVisible(true)
                    -- end
                end
            end
        elseif #records == 31 and records[31] == -1 then
            nowIndex = temIndex5
            if records[temIndex4] + 1 == index then
                if records[temIndex5] + 1 == 0 then
                    -- self.emBtn:setVisible(true)
                end
            end
        end
    else
        per,time = self:getNowProgress()
    end
    -- print('=======================xxxxxxxxxxxxxxxxxxx',self.nowProcess,nowIndex,self.result[nowIndex])
    local infoTx = self.emBtn:getChildByName('info_tx')
    if self.nowProcess == 1 then
        infoTx:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC28'))
        self.emBtn:setTouchEnabled(true)
        self.emBtn:setBright(true)
    elseif self.nowProcess == 2 then
        printall(self.result)
        infoTx:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC29'))
        -- infoTx:setColor(COLOR_TYPE.WHITE)
        -- print('==============================',nowIndex,not self.result[nowIndex])
        if nowIndex ~= 0 then
            if not self.result[nowIndex] or self.result[nowIndex] == -1 then
                self.emBtn:setTouchEnabled(true)
                self.emBtn:setBright(true)
                infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
            else
                local isReady = self.result[nowIndex]%10
                local uid = UserData:getUserObj():getUid()
                local meIndex = WorldWarMgr:getIndexByUid(uid)
                -- print('===============xxxx',meIndex)
                local parity = meIndex%2
                -- print('=====================11',nowIndex,meIndex,parity,isReady)
                if (parity == 1 and (isReady == 1 or isReady == 2 or isReady == 5 or isReady == 6)) or
                   (parity == 0 and (isReady == 3 or isReady == 4 or isReady == 5 or isReady == 6)) then
                    self.emBtn:setTouchEnabled(false)
                    self.emBtn:setBright(false)
                    infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1)
                else
                    self.emBtn:setTouchEnabled(true)
                    self.emBtn:setBright(true)
                    infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
                end
            end
        else
            self.emBtn:setTouchEnabled(false)
            self.emBtn:setBright(false)
            infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1)
        end
    else
        self.emBtn:setVisible(false)
    end
    return per,time,timeStr
end

function WorldWarKnockoutUI:timeoutCallback(tx,time,isHide)
    local label = self.namePl:getChildByTag(9999)
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 22)
    label:setPosition(cc.p(540,95))
    label:setAnchorPoint(cc.p(0,0.5))
    label:setVisible(isHide)
    self.namePl:addChild(label,1,9999)
    Utils:createCDLabel(label,time,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,tx,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.ORANGE,22,function ()
        -- print('----------------------1',#self.replays)
        -- printall(self.replays)
        WorldWarMgr:getRecords(function(records,replays)
            -- printall(self.replays)
            self.records = records
            self.replays = replays
            -- print('----------------------2',#self.replays)
            self:updatePanel()
        end)
    end)
end

function WorldWarKnockoutUI:getPerOfTImebar()
    local per = self:getNowProgress()
    -- print('=================================3',per)
    if per == 0 then
        return 0
    elseif per == 1 then
        return 50
    elseif per == 2 then
        return 100
    else
        return 100
    end
end

function WorldWarKnockoutUI:updateTime()
    -- _,time = self:getNowProgress(13)
    local per,time,timeStr = self:updateTimeInfo()
    local timeStr = GlobalApi:getLocalStr('E_STR_PVP_WAR_TIME_DESC2')
    time = tonumber(time) or 0
    -- print('==================',per)
    if time <= 0 then 
        local label = self.namePl:getChildByTag(9999)
        if label then
            label:removeFromParent()
        end
    elseif per == 2 then
        self:timeoutCallback(timeStr,time + 5,true)
    else
        self:timeoutCallback(timeStr,time + 5,true)
    end
    local per = self:getPerOfTImebar()
    -- print('==========================2',per)
    self.bar:setPercent(per)
    self.bar:setVisible(true)
end

function WorldWarKnockoutUI:updateInfo()
    local _,time = self:getNowProgress()
    local nowTime = GlobalData:getServerTime()
    local beginDay = Time.beginningOfToday()
    local tStr = ''
    -- print('==================================time',time)
    if not time then
        self.timeTx:setString('')
        self.infoTx:setString('')
        return
    end
    -- print('==================================time1',time)
    if (time + nowTime - beginDay) > 86400 then
        tStr = GlobalApi:getLocalStr('TOMORROW')
    end
    local turn = ''
    local team = ''
    local desc = ''
    local desc1 = ''
    local conf
    if self.style == NORMAL and WorldWarMgr.progress ~= 'sup_2' 
        and WorldWarMgr.progress ~= 'sup_1' 
        and WorldWarMgr.progress ~= '2' 
        and WorldWarMgr.progress ~= '1' then
        team = (((self.page == 1) and 'A') or 'B')..GlobalApi:getLocalStr('WORLD_WAR_DESC_6')
    else
        team = ''
    end
    local keyArr = string.split(WorldWarMgr.progress , '_')
    turn = tonumber(keyArr[#keyArr])
    -- print('=======================================0',turn)
    if not turn then
        self.infoTx:setString('')
    elseif turn == 1 then
        desc = GlobalApi:getLocalStr('WORLD_WAR_DESC_5')
    elseif turn == 2 then
        desc = GlobalApi:getLocalStr('WORLD_WAR_DESC_4')
    else
        desc = string.format(GlobalApi:getLocalStr('WORLD_WAR_DESC_2'),turn)
    end
    if #keyArr == 1 then
        self.infoTx:setString('（'..desc..team..'）')
        self.timeTx:setString(desc..GlobalApi:getLocalStr('WORLD_WAR_DESC_3'))
    elseif #keyArr == 2 then
        conf = WorldWarMgr:getScheduleByProgress(turn)
        local keyArr = string.split(conf.startHour , '.')
        local m = (keyArr[2] or 0)/10*60
        local str = keyArr[1]..':'..string.format("%02d",m)
        self.infoTx:setString('（'..desc..team..'）')
        self.timeTx:setString(tStr..string.format(GlobalApi:getLocalStr('WORLD_WAR_DESC_1'),str)..desc)
    else
        self.timeTx:setString('')
        self.infoTx:setString('')
    end
    
    -- print('===================xxxxxx1111111',turn)
    if turn then
        local conf = WorldWarMgr:getScheduleByProgress(turn)
        local keyArr = string.split(conf.startHour , '.')
        for i,v in ipairs(self.timeTxs) do
            local m = (keyArr[2] or 0)/10*60 + conf.interval * (i - 1)
            if m >= 60 then
                v:setString((keyArr[1] + 1)..':'..string.format("%02d",(m - 60)))
            else
                v:setString(keyArr[1]..':'..string.format("%02d",m))
            end
        end
    end
end

function WorldWarKnockoutUI:onShow()
    -- print('onShowonShowonShowonShow ======================------')
    self:updatePanel()
end

function WorldWarKnockoutUI:updatePanel()
    self:updateName()
    self:updatePageBtn()
    -- print('======================records')
    -- printall(self.records)
    -- print('======================22222')
    self:updateBlinePanel()
    self:updateSbtnRimg()
    if WorldWarMgr.progress == 'sup_16' or WorldWarMgr.progress == '16' then
        self.normalBtn:setVisible(false)
    else
        self.normalBtn:setVisible(true)
    end
    self:updateTime()
    self:updateInfo()
    if self.style == NORMAL then
        -- if WorldWarMgr.progress ~= 'sup_1' and WorldWarMgr.progress ~= '1' and WorldWarMgr.progress ~= 'rank' and WorldWarMgr.progress ~= 'close' 
        --     and #self.records < 30 then
        --     self.firstImg:setVisible(true)
        -- else
            self.firstImg:setVisible(false)
            self.firstImg1:setVisible(true)
        -- end
    else
        self.firstImg:setVisible(true)
        self.firstImg1:setVisible(false)
        -- if #self.records == 31 and self.records[31] ~= -1 then
        --     local player = self.top32[self.records[31] + 1]
        --     local roleObj = RoleData:getRoleInfoById(tonumber(player.headpic))
        --     -- self.firstImg:loadTexture(roleObj:getBigPic())
        --     self.firstImg:loadTexture('uires/ui/worldwar/worldwar_first1.png')
        --     self.firstImg:ignoreContentAdaptWithSize(true)
        -- else
        --     self.firstImg:loadTexture('uires/ui/worldwar/worldwar_first.png')
        --     self.firstImg:ignoreContentAdaptWithSize(true)
        -- end
    end
end

function WorldWarKnockoutUI:init()
    local worldwarImg = self.root:getChildByName("worldwar_img")
    local closeBtn = self.root:getChildByName("close_btn")
    self.namePl = self.root:getChildByName("name_pl")
    local dLinePl = self.root:getChildByName("d_line_pl")
    local bLinePl = self.root:getChildByName("b_line_pl")
    local sPl = self.root:getChildByName("s_pl")
    
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showWorldMainWar()
            WorldWarMgr:hideKnockout()
        end
    end)

    self.firstImg = sPl:getChildByName('first_img')
    self.firstImg1 = sPl:getChildByName('first_1_img')
    local size = self.firstImg:getContentSize()
    local selectAni = GlobalApi:createLittleLossyAniByName("ui_worldwar_light")
    selectAni:getAnimation():playWithIndex(0, -1, 1)
    selectAni:setName('ui_worldwar_light')
    selectAni:setPosition(cc.p(size.width/2,size.height/2 + 32))
    selectAni:setScale(2)
    selectAni:getAnimation():setSpeedScale(0.5)
    self.firstImg:addChild(selectAni)

    for i=1,31 do
        local lineImg = bLinePl:getChildByName('line_'..i..'_img')
        self.bLineImgs[i] = lineImg
    end
    self.bLineImgs1 = {}
    for i=32,39 do
        local lineImg = bLinePl:getChildByName('line_'..i..'_img')
        self.bLineImgs1[i] = lineImg
    end
    self.dLineImg = {}
    for i=8,24 do
        local lineImg = dLinePl:getChildByName('line_'..i..'_img')
        self.dLineImg[i - 7] = lineImg
    end

    for i=1,MAX_PEOPLE do
        local nameImg = self.namePl:getChildByName('name_'..i..'_img')
        local nameTx = nameImg:getChildByName('name_tx')
        self.nameTxs[i] = nameTx
        nameImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.style == NORMAL then
                    local id = i + (self.page - 1)*MAX_PEOPLE
                    local top32 = self.top32
                    BattleMgr:showCheckInfo(top32[id].uid,'universe')
                else
                    local id = self.records[i] + 1
                    local top32 = self.top32
                    printall(top32[id])
                    BattleMgr:showCheckInfo(top32[id].uid,'universe')
                end
            end
        end)
    end
    for i=1,15 do
        local sBtn = sPl:getChildByName('s_'..i..'_btn')
        local rImg = sPl:getChildByName('r_'..i..'_btn')
        local infoTx = sBtn:getChildByName('info_tx')
        self.sBtns[i] = sBtn
        self.rImgs[i] = rImg
        sBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local top32 = self.top32
                local records = self.records
                local replays = self.replays
                WorldWarMgr:showSupport(self:getRecordsId(i),top32,records,replays)
            end
        end)
        rImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local top32 = self.top32
                local records = self.records
                local replays = self.replays
                local recordsId = self:getRecordsId(i)
                -- print('=============================0000022222',recordsId)
                if replays[recordsId] and records[recordsId] >= 0 then
                    WorldWarMgr:showReplay(recordsId,top32,records,replays)
                end
            end
        end)
    end

    self.infoTx = self.namePl:getChildByName("info_tx")
    self.timeTx = self.namePl:getChildByName("time_tx")

    self.barBg = self.namePl:getChildByName("bar_bg")
    self.bar = self.barBg:getChildByName("bar")
    self.barBg:setVisible((WorldWarMgr.progress ~= 'rank' and WorldWarMgr.progress ~= 'close'))
    self.timeTxs = {}
    for i=1,3 do
        local timeTx = self.barBg:getChildByName('time_'..i..'_tx')
        self.timeTxs[i] = timeTx
    end

    local mySupportBtn = self.namePl:getChildByName("my_support_btn")
    mySupportBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_103'))
    local myReplayBtn = self.namePl:getChildByName("my_replay_btn")
    myReplayBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_105'))
    local priceBtn = self.namePl:getChildByName("price_btn")
    priceBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_104'))
    self.emBtn = self.namePl:getChildByName("em_btn")
    self.emBtn:setVisible(false)
    self.emBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_101'))
    self.normalBtn = self.namePl:getChildByName("normal_btn")
    self.leftBtn = self.root:getChildByName("left_btn")
    self.rightBtn = self.root:getChildByName("right_btn")
    self.emBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.nowProcess == 1 then
                local uid = UserData:getUserObj():getUid()
                local top32 = self.top32
                local data = WorldWarMgr:getPlayerById(uid,top32)
                WorldWarMgr:embattle(function()
                    BattleMgr:hideEmbattleUI()
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("EMBATTLE_SUCC"), COLOR_TYPE.GREEN)
                end)
            elseif self.nowProcess == 2 then
                self.emBtn:setTouchEnabled(false)
                self.emBtn:setBright(false)
                local infoTx = self.emBtn:getChildByName('info_tx')
                infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1)
                WorldWarMgr:prepareFight(self.root,function(succ)
                    self.emBtn:setTouchEnabled(true)
                    self.emBtn:setBright(true)
                    infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
                    if succ == 0 then
                        self:updatePanel()
                    end
                end)
            end
        end
    end)
    self.leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.page = (self.page - 2)%2 + 1
            self:updatePanel()
        end
    end)

    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.page = self.page%2 + 1
            self:updatePanel()
        end
    end)
    self.normalBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.style = ((self.style == NORMAL) and SPECIAL) or NORMAL
            self:updatePanel()
        end
    end)
    mySupportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local top32 = self.top32
            local records = self.records
            local replays = self.replays
            WorldWarMgr:showMySupport(top32,records,replays)
        end
    end)
    priceBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showPriceRank()
        end
    end)
    myReplayBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local top32 = self.top32
            local records = self.records
            local replays = self.replays
            WorldWarMgr:showMyReplay(top32,records,replays)
        end
    end)

    local winSize = cc.Director:getInstance():getVisibleSize()
    worldwarImg:setPosition(cc.p(winSize.width/2,0))
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    self.namePl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    dLinePl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    bLinePl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    sPl:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.leftBtn:setPosition(cc.p(0,winSize.height/2))
    self.rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    -- self.normalBtn:setPosition(cc.p(0,winSize.height))

    -- btn:setPosition(cc.p(winSize.width/2,winSize.height))
    -- mySupportBtn:setPosition(cc.p(winSize.width/2,50))
    -- priceBtn:setPosition(cc.p(winSize.width/2 - 200,50))
    -- myReplayBtn:setPosition(cc.p(winSize.width/2 + 200,50))
    if WorldWarMgr.progress == 'sup_16' or WorldWarMgr.progress == '16' then
        self.style = NORMAL
        self.normalBtn:getChildByName('info_tx'):setString('8'..GlobalApi:getLocalStr('KNOCK_QIANG'))
    else
        self.style = SPECIAL
        self.normalBtn:getChildByName('info_tx'):setString('16'..GlobalApi:getLocalStr('KNOCK_QIANG'))
    end
    self:updatePanel()
end

return WorldWarKnockoutUI