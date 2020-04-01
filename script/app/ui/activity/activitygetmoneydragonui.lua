local ActivityGetMoneyDragonUI = class("ActivityGetMoneyDragonUI", BaseUI)

function ActivityGetMoneyDragonUI:ctor()
    self.uiIndex = GAME_UI.UI_GET_MONEY_DRAGON
    self.history = {}
    self.lucky_dragon = nil
    self.conf = GameData:getConfData("avluckydragon")
    self.duration = GameData:getConfData("activities")["lucky_dragon"].duration*86400
    self.running = false
    self.activitieOver = false
    self.currGetMoney = 0
    self.awards = nil

    self.vipAllCount = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())].luckyDragon
end

function ActivityGetMoneyDragonUI:init()
    local bg_img = self.root:getChildByName("bg_img")
    local alpha_img = bg_img:getChildByName("alpha_img")
    self:adaptUI(bg_img, alpha_img)

    local image = alpha_img:getChildByName("image")
    self.close_btn = image:getChildByName("close_btn")
    self.close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local desc1 = image:getChildByName('desc_1')
    desc1:setString(GlobalApi:getLocalStr("CONGRATULATE_GET_ALL_MONEY3"))
    local desc2 = image:getChildByName('desc_2')
    desc2:setString(GlobalApi:getLocalStr("CONGRATULATE_GET_ALL_MONEY4"))
    
    desc1:setVisible(false)
    desc2:setVisible(false)
    desc1:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.CallFunc:create(function ()
                desc2:setVisible(true)
                desc1:setVisible(false)
            end),
            cc.DelayTime:create(5),
            cc.CallFunc:create(function ()
                desc2:setVisible(false)
                desc1:setVisible(true)
            end),
            cc.DelayTime:create(5)
    )))

    self.rts = {}
    for i = 1, 3 do
        local rt = xx.RichText:create()
        rt:setAnchorPoint(cc.p(0, 0.5))
        local rt1 = xx.RichTextLabel:create("", 24)
        rt1:setColor(COLOR_TYPE.GREEN)
        local rt2 = xx.RichTextLabel:create(GlobalApi:getLocalStr("STR_GAIN"), 24)
        rt2:setColor(COLOR_TYPE.WHITE)
        local rt3 = xx.RichTextImage:create("uires/ui/res/res_cash.png")
        rt3:setScale(0.7)
        local rt4 = xx.RichTextLabel:create("", 24)
        rt4:setColor(COLOR_TYPE.ORANGE)
        self.rts[i] = {rt, rt1, rt2, rt3, rt4}
        rt:addElement(rt1)
        rt:addElement(rt2)
        rt:addElement(rt3)
        rt:addElement(rt4)
        rt:setAlignment("left")
        rt:setPosition(cc.p(80, 205 - i*34))
        rt:setContentSize(cc.size(400, 30))
        image:addChild(rt)
    end

    self.lastDay = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte("0"))
    self.lastDay:setAnchorPoint(cc.p(0.5, 0.5))
    self.lastDay:setPosition(cc.p(620, 504))
    self.lastDay:setScale(1.2)
    image:addChild(self.lastDay)

    local times_info_tx = image:getChildByName("times_info_tx")
    times_info_tx:setString(GlobalApi:getLocalStr("REMAIN_GET_MONEY_TIMES"))
    self.times_tx = image:getChildByName("times_tx")
    self.need_img = image:getChildByName("need_img")
    self.need_img:setVisible(false)
    self.need_tx = self.need_img:getChildByName("need_tx")
    self.have_tx = image:getChildByName("have_tx")
    self.get_tx = image:getChildByName("get_tx")
    self.time_tx = image:getChildByName("time_tx")

    self.give_btn = image:getChildByName("give_btn")
    self.give_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.activitieOver then
                promptmgr:showMessageBox(GlobalApi:getLocalStr("CURR_ACTIVITY_ALEADY_OVER"), MESSAGE_BOX_TYPE.MB_OK)
            else
                if self.lucky_dragon and self.lucky_dragon.use >= self.vipAllCount then
                    local vip = GameData:getConfData('vip')
                    local userVip = UserData:getUserObj():getVip()
                    local showVipLv,showVipCount
                    for i = userVip,GlobalApi:getMaxVip() do
                        local count = vip[tostring(i)].luckyDragon
                        if count > self.vipAllCount then
                            showVipLv = i
                            showVipCount = count
                            break
                        end
                    end
                    if showVipLv and showVipCount then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('CONGRATULATE_GET_ALL_MONEY2'),showVipLv,showVipCount - self.vipAllCount), COLOR_TYPE.RED)
                    else
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("CONGRATULATE_GET_ALL_MONEY"), MESSAGE_BOX_TYPE.MB_OK)
                    end
                else
                    if UserData:getUserObj():getCash() >= self.conf[self.lucky_dragon.use + 1].spend then
                        MessageMgr:sendPost("click_lucky_dragon", "activity", "{}",function (response)
                            if response.code == 0 then
                                UserData:getUserObj().isGetMoneyDragonPost = true
                                if response.data.history then
                                    self.history = response.data.history
                                end
                                self.lucky_dragon.use = self.lucky_dragon.use + 1
                                UserData:getUserObj().activity.lucky_dragon.use = self.lucky_dragon.use
                                if response.data.costs then
                                    GlobalApi:parseAwardData(response.data.costs)
                                end
                                if response.data.awards then
                                    self.awards = response.data.awards
                                    GlobalApi:parseAwardData(response.data.awards)
                                    local awards = DisplayData:getDisplayObjs(response.data.awards)
                                    self:startRunNumber(awards[1]:getNum())
                                end
                            end
                        end)
                    else
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                            GlobalApi:getGotoByModule("cash")
                        end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                    end
                end 
            end       
        end
    end)

    local layout = image:getChildByName("mask")
    self.numberArr = {}
    for i = 1, 5 do
        local actNode = layout:getChildByName("node_" .. i)
        actNode:setVisible(true)
        local numImg = actNode:getChildByName("number_1")
        local numImg2 = actNode:getChildByName("number_2")
        local numImg3 = actNode:getChildByName("number_3")
        self.numberArr[i] = {
            img1 = numImg,
            img2 = numImg2,
            img3 = numImg3,
            actNode = actNode,
            running = false,
            moveNum = 1,
            index = 1,
            number = 0
        }
    end

    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self:checkRunNumber()
        self:updateTime()
    end, 0)

    MessageMgr:sendPost("get_lucky_dragon", "activity", "{}",function (response)
        if response.code == 0 then
            self.history = response.data.history
            self.lucky_dragon = response.data.lucky_dragon
            self.currGetMoney = response.data.lucky_dragon.last or 0
            self:update()
            self:setActionNodePosition(self.currGetMoney)
        end
    end)
end

function ActivityGetMoneyDragonUI:setActionNodePosition(targetNumber)
    local numArr = {}
    numArr[1] = targetNumber%10
    numArr[2] = math.floor(targetNumber/10)%10
    numArr[3] = math.floor(targetNumber/100)%10
    numArr[4] = math.floor(targetNumber/1000)%10
    numArr[5] = math.floor(targetNumber/10000)%10
    for i = 1, 5 do
        self.numberArr[i].number = numArr[i]
        self.numberArr[i].actNode:setPositionY(numArr[i]*-80)
    end
end

function ActivityGetMoneyDragonUI:startRunNumber(targetNumber)
    self.currGetMoney = targetNumber
    self.running = true
    self.give_btn:setTouchEnabled(false)
    self.give_btn:setBright(false)
    self.close_btn:setTouchEnabled(false)
    self.close_btn:setBright(false)
    local numArr = {}
    numArr[1] = targetNumber%10
    numArr[2] = math.floor(targetNumber/10)%10
    numArr[3] = math.floor(targetNumber/100)%10
    numArr[4] = math.floor(targetNumber/1000)%10
    numArr[5] = math.floor(targetNumber/10000)%10
    local runningNumber = 5
    for i = 1, 5 do
        self.numberArr[i].running = true
        local changeNum = numArr[i] - self.numberArr[i].number + 10
        -- 单个数字的长度为80, EaseExponentialIn最后加速至7倍左右, 1.5秒跑800的话, 简单算7倍速跑一个数字要0.02秒
        self.numberArr[i].actNode:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.2), 
                                                               cc.EaseExponentialIn:create(cc.MoveBy:create(1.5, cc.p(0, -800))),  
                                                               cc.MoveBy:create(i*1.5 + changeNum*0.02 , cc.p(0, -5600*i-changeNum*80)), 
                                                               cc.EaseExponentialOut:create(cc.MoveBy:create(3, cc.p(0, -1600))), 
                                                               cc.CallFunc:create(function()
                                                                    self.numberArr[i].running = false
                                                                    runningNumber = runningNumber - 1
                                                                    if runningNumber <= 0 then
                                                                        self.running = false
                                                                        self.give_btn:setTouchEnabled(true)
                                                                        self.give_btn:setBright(true)
                                                                        self.close_btn:setTouchEnabled(true)
                                                                        self.close_btn:setBright(true)
                                                                        self:update()
                                                                        GlobalApi:showAwardsCommon(self.awards, nil, nil, true)
                                                                    end
                                                                end)))
        self.numberArr[i].number = numArr[i]
    end
end

function ActivityGetMoneyDragonUI:checkRunNumber()
    if self.running then
        for i = 1, 5 do
            local y = self.numberArr[i].actNode:getPositionY()
            local num = math.floor((y + 160)/-800)
            if num > self.numberArr[i].moveNum then
                self.numberArr[i].moveNum = num
                if num%3 == 0 then
                    self.numberArr[i].img1:setPositionY(800*num)
                    self.numberArr[i].img2:setPositionY(800*(num + 1))
                    self.numberArr[i].img3:setPositionY(800*(num + 2))
                elseif num%3 == 1 then
                    self.numberArr[i].img2:setPositionY(800*num)
                    self.numberArr[i].img3:setPositionY(800*(num + 1))
                    self.numberArr[i].img1:setPositionY(800*(num + 2))
                else
                    self.numberArr[i].img3:setPositionY(800*num)
                    self.numberArr[i].img1:setPositionY(800*(num + 1))
                    self.numberArr[i].img2:setPositionY(800*(num + 2))
                end
            end
        end
    end
end

function ActivityGetMoneyDragonUI:updateTime()
    if not self.activitieOver and self.lucky_dragon then
        local t = GlobalApi:convertTime(2,self.lucky_dragon.open_day) + 5*3600 + self.duration - GlobalData:getServerTime()
        if t < 0 then
            self.activitieOver = true
            self.time_tx:setString("00:00:00")
            self.lastDay:setString("0")
        else
            local d = math.floor(t/86400)
            local h = string.format("%02d", math.floor(t/3600))
            local m = string.format("%02d", math.floor(t%3600/60))
            local s = string.format("%02d", math.floor(t%3600%60%60))
            if d > 0 then
                h = h - d*24
            end
            self.time_tx:setString(h..':'..m..':'..s)
            self.lastDay:setString(tostring(d))
        end
    end
end

function ActivityGetMoneyDragonUI:update()
    if self.lucky_dragon.use >= self.vipAllCount then
        self.need_img:setVisible(false)
        self.times_tx:setString("0/" .. self.vipAllCount)
        self.need_tx:setString("")
        self.have_tx:setString(GlobalApi:toWordsNumber(UserData:getUserObj():getCash()))
        self.get_tx:setString("")
    else
        self.need_img:setVisible(true)
        self.times_tx:setString(tostring(self.vipAllCount - self.lucky_dragon.use) .. '/' .. self.vipAllCount)
        self.need_tx:setString(tostring(self.conf[self.lucky_dragon.use + 1].spend))
        self.have_tx:setString(GlobalApi:toWordsNumber(UserData:getUserObj():getCash()))
        self.get_tx:setString(tostring(self.conf[self.lucky_dragon.use + 1].lowest))
    end

    if self.conf[self.lucky_dragon.use + 1] then
        self.need_img:setVisible(true)
        self.times_tx:setString(tostring(self.vipAllCount - self.lucky_dragon.use) .. '/' .. self.vipAllCount)
        self.need_tx:setString(tostring(self.conf[self.lucky_dragon.use + 1].spend))
        self.have_tx:setString(GlobalApi:toWordsNumber(UserData:getUserObj():getCash()))
        self.get_tx:setString(tostring(self.conf[self.lucky_dragon.use + 1].lowest))
    end

    for i = 1, 3 do
        if self.history[i] then
            self.rts[i][2]:setString(self.history[i].un)
            self.rts[i][5]:setString(tostring(self.history[i].cash))
            self.rts[i][1]:setVisible(true)
            self.rts[i][1]:format(true)
        else
            self.rts[i][1]:setVisible(false)
        end
    end
end

return ActivityGetMoneyDragonUI