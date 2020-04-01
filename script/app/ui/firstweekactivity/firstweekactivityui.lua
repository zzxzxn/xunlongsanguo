local FirstWeekActivityUI = class("FirstWeekActivityUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function FirstWeekActivityUI:ctor()
    self.uiIndex = GAME_UI.UI_FIRSTWEEKACTIVITY
    self.numOfDays = 7
    self.numOfMaxTypes = 5
    self.numOfselectDayType = 0
    self.selectDayTypes = nil
    self.currentTypeTasks = nil

    self.currentDay  = -1  --当前是第几天
    self.selectDay   = -1  --正在浏览第几天
    self.currentType = -1

    self.daysBtns = {}
    self.daysStrings = {}
    self.daysMarks = {}

    self.typeBtns = {}
    self.typeStrings = {}
    self.typeMarks = {}

    self.taskCells = {}

    self.typesActionTime = 0.5
    self.tasksActionTime = 0.5
    self.showingTaskPage = true

end

function FirstWeekActivityUI:init()

    

    local root    =  self.root:getChildByName("root")
    local rootBG  =  ccui.Helper:seekWidgetByName(root,"bg")
    self.rootBG   =  rootBG
    self:adaptUI(root, rootBG)

    --天数切换
    self.daysContainer = ccui.Helper:seekWidgetByName(rootBG,"daysTabs")
    local openSevenTab
    if FirstWeekActivityMgr:judgeNewOrOldSever() then
        openSevenTab = GameData:getConfData('openseventab')
    else
        openSevenTab = GameData:getConfData('oldopenseventab')
    end
    
    for i = 1,self.numOfDays do
        local dayType1 = ccui.Helper:seekWidgetByName(self.daysContainer,"day"..i)
        local dayType2 = ccui.Helper:seekWidgetByName(self.daysContainer,"day" .. i .."_1")
        local picture = openSevenTab[i].picture
        if picture and picture ~= '0' then
            self.daysBtns[i] = dayType2
            dayType2:getChildByName('img'):loadTexture("uires/ui/firstweekactivity/" .. picture)
            dayType1:setVisible(false)
        else
            self.daysBtns[i] = dayType1
            dayType2:setVisible(false)
        end

        self.daysStrings[i] = ccui.Helper:seekWidgetByName(self.daysBtns[i],"dayString")
        self.daysMarks[i] = ccui.Helper:seekWidgetByName(self.daysBtns[i],"mark")
        self.daysMarks[i]:setVisible(false)
        self.daysStrings[i]:setString(string.format(GlobalApi:getLocalStr('FWACT_DAY'),i))
    end

    --类型切换
    self.typeContainer =  ccui.Helper:seekWidgetByName(rootBG,"typeTabs")
    self.svLeft = self.typeContainer:getChildByName('sv_left')
    self.svLeft:setScrollBarEnabled(false)
    for i = 1,self.numOfMaxTypes do
        self.typeBtns[i]        = ccui.Helper:seekWidgetByName(self.svLeft,"type"..i)
        self.typeBtns[i]:setVisible(false)
        self.typeBtns[i].oriPos = cc.p(self.typeBtns[i]:getPosition())
        self.typeStrings[i]     = ccui.Helper:seekWidgetByName(self.typeBtns[i],"typeString")
        self.typeMarks[i]       = ccui.Helper:seekWidgetByName(self.typeBtns[i],"mark")
        self.typeMarks[i]:setVisible(false)
        self.typeBtns[i]:setLocalZOrder(5-i)
       
    end
   -- self.selectFrame = ccui.Helper:seekWidgetByName(self.typeContainer,"selectFrame")

    --妹子
    self.role = ccui.Helper:seekWidgetByName(rootBG,"role")

    --奖励页面
    self.pageContainer = ccui.Helper:seekWidgetByName(rootBG,"pageContainer")
    self.rewardsPage   = ccui.Helper:seekWidgetByName( self.pageContainer,"rewardsPage")
    self.rewardsList   = ccui.Helper:seekWidgetByName(self.rewardsPage,"rewardsList")
    self.rewardsList:setScrollBarEnabled(false)
    self.rewardsPage:setVisible(false)

    self.tempRewardsCell = ccui.Helper:seekWidgetByName(self.rewardsPage,"rewardCell")
    self.tempRewardsCell:getChildByName('desc'):setString(GlobalApi:getLocalStr('ACTIVITY_LEVELGIFT_TITLE1'))
    self.tempRewardsCell:getChildByName('getButton'):getChildByName('text'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    self.tempRewardsCell:setVisible(false)

    --半价抢购页面
    self.halfPricePage = ccui.Helper:seekWidgetByName( self.pageContainer,"halfPricePage")
    self.halfPricePage:setVisible(false)


    local priceBG = ccui.Helper:seekWidgetByName( self.halfPricePage,"priceBG")
    self.halfPrice_oriPrice    = ccui.Helper:seekWidgetByName( priceBG,"oriPrice")
    self.halfPrice_curPrice    = ccui.Helper:seekWidgetByName( priceBG,"curPrice")
    self.halfPrice_oriPriceNum = ccui.Helper:seekWidgetByName( priceBG,"oriPriceNum")
    self.halfPrice_curPriceNum = ccui.Helper:seekWidgetByName( priceBG,"curPriceNum")

    self.halfPrice_buyBtn   = ccui.Helper:seekWidgetByName( self.halfPricePage,"buyBtn")
    self.halfPrice_buyText  = ccui.Helper:seekWidgetByName( self.halfPrice_buyBtn,"text")
    self.halfPrice_limitText= ccui.Helper:seekWidgetByName( self.halfPricePage,"limitText")

    self.halfPrice_itemName = ccui.Helper:seekWidgetByName( self.halfPricePage,"itemName")
    self.halfPrice_itemBG   = ccui.Helper:seekWidgetByName( self.halfPricePage,"itemBG")
    self.halfPrice_itemIcon = ccui.Helper:seekWidgetByName( self.halfPrice_itemBG,"itemIcon")

    --关闭按钮
    self.closeBtn = ccui.Helper:seekWidgetByName(rootBG,"closeButton")

    self:registerTouchEvents()

    if(self.currentDay > 7) then
        self:ChangeToDay(7,false)
    else
        self:ChangeToDay(self.currentDay,false)
    end
    self:refreshAllMarks()

    --rootBG:setScale(0.05)
    --rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 1)))

    local actionTime = 0.35
    self.typeContainer:setPositionX(self.typeContainer:getPositionX() + 300)
    self.typeContainer:runAction(cc.MoveBy:create(actionTime,cc.p(-300,0)))

    self.pageContainer:setPositionX(self.pageContainer:getPositionX() + 300)
    self.pageContainer:runAction(cc.MoveBy:create(actionTime,cc.p(-300,0)))

--    self.role:setPositionX(self.role:getPositionX() - 300)
--    self.role:runAction(cc.MoveBy:create(actionTime,cc.p(300,0)))

    self.rootBG:setOpacity(0.3)
    rootBG:runAction(cc.FadeIn:create(actionTime))

    --self.titleBG:runAction(cc.RepeatForever:create(cc.RotateBy:create(4,360)))

    

end
function FirstWeekActivityUI:ActionClose(call)
    self:hideUI()
    --[[self.rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
     self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
        --]]
end

function FirstWeekActivityUI:playEffect(img)
    if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end
     

    local parent = img:getParent()
    local img = img
    local posX = img:getPositionX()
    local posY = img:getPositionY()

    --[[
    local size1 = img:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_tongyonguangshu_01')
    lvUp:setPosition(cc.p(posX ,posY + 50))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img:setLocalZOrder(101)
    --lvUp:setScale(1.2)
    parent:addChild(lvUp)
    lvUp:getAnimation():playWithIndex(0, -1, 1)
    --]]

    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(posX ,posY))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))

    lvUp:setLocalZOrder(100)
    img:setLocalZOrder(101)
    --lvUp:setScale(0.6)
    parent:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)


    self.lvUp = lvUp
end


function FirstWeekActivityUI:registerTouchEvents()
     for i = 1,self.numOfDays do
        local function clickTable(sender, eventType)      
            if(self.selectDay == i) then
                 return
            end
            self:playEffect(sender)

            if(not self.runningTypesAction) then
--                self.runningTypesAction = true
                --self.selectFrame:setVisible(false)
                
--                self:DoTypesOutAction(self.typesActionTime)
--                self:DoTasksOutAction(self.typesActionTime)
--                self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(self.typesActionTime+ 0.1),cc.CallFunc:create(function ()
--                        self:ChangeToDay(i,true)           

--                end)))
                self:ChangeToDay(i,true)      
                self:refreshSelectDayMarks()    
            end
        end
        self.daysBtns[i]:addTouchEventListener(clickTable)
    end

    for i = 1,self.numOfMaxTypes do
        local function clickTable(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if(self.currentType == i) then
                     return
                end
               
--                if(not self.runningTasksAction) then
--                    self:SetTypesStringColor(i)
--                    self.runningTasksAction = true
--                    self:DoTasksOutAction(self.tasksActionTime)
--                    self.selectFrame:setPosition(self.typeBtns[i].oriPos)
--                    self.selectFrame:setScale(1.1)
--                    self.selectFrame:runAction(cc.ScaleTo:create(0.1, 1))
--                    self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(self.tasksActionTime ),cc.CallFunc:create(function ()
--                            self:ChangeToType(i,true)
--                            self.runningTasksAction = false
--                    end)))
--                end
--                  self.selectFrame:setPosition(self.typeBtns[i].oriPos)
--                  self.selectFrame:setScale(1.1)
--                  self.selectFrame:runAction(cc.ScaleTo:create(0.1, 1))
                  self:ChangeToType(i,true)
            end
        end
        self.typeBtns[i]:addTouchEventListener(clickTable)
    end

    local function clickClose(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                print("close")
                FirstWeekActivityMgr:hideUI()
            end
        end
    self.closeBtn:addTouchEventListener(clickClose)
    
end
function FirstWeekActivityUI:refreshAllMarks()
    
    print("refreshAllMarks")
    for i = 1,self.numOfDays do
       local types = FirstWeekActivityMgr:GetTypesOfDay(i)
       local showDayMakrs = false
       
       for ti = 1,#types do
             local showTypeMakrs = false
             local typeData = types[ti]
             for idx,id in pairs(typeData.task)  do
                 local taskData = FirstWeekActivityMgr:GetTaskByID(tonumber(id))
--                 print("day:"..i.." type:"..ti.."data:"..idx.."progress:")
--                 print(taskData.got)
--                  print(taskData.progress)
--                     print(taskData.target)
                 if(taskData.progress ~= nil and taskData.progress >= taskData.target and not taskData.got) then
                    showTypeMakrs = true
                    showDayMakrs = true
                    break
                 end
             end
             if(showTypeMakrs) then
                if(self.currentDay >= i and self.selectDay == i) then
                    self.typeMarks[ti]:setVisible(true)
                else
                    break
                end
             end
       end
       if(showDayMakrs and self.currentDay >= i ) then
            self.daysMarks[i]:setVisible(true)
       end
    end
    


end
function FirstWeekActivityUI:refreshSelectDayMarks()
       
        for i = 1,self.numOfMaxTypes do
            self.typeMarks[i]:setVisible(false)
        end
        self.daysMarks[self.selectDay]:setVisible(false)

       local types = FirstWeekActivityMgr:GetTypesOfDay(self.selectDay)
       local showDayMakrs  = false
       local showTypeMakrs = false
       for ti = 1,#types do
             local showTypeMakrs = false
             local typeData = types[ti]
             for idx,id in pairs(typeData.task)  do
                 local taskData = FirstWeekActivityMgr:GetTaskByID(tonumber(id))
                 if(taskData.progress ~= nil and taskData.progress >= taskData.target and not taskData.got) then
                    showTypeMakrs = true
                    showDayMakrs = true;
                    break
                 end
             end
             if(showTypeMakrs and self.currentDay >= self.selectDay) then
                self.typeMarks[ti]:setVisible(true)
             end
       end

       if(self.currentDay >= self.selectDay) then
            self.daysMarks[self.selectDay]:setVisible(showDayMakrs)
       end

end
function FirstWeekActivityUI:createNewTaskCell()
    local newCell = self.tempRewardsCell:clone()

    newCell.sv = ccui.Helper:seekWidgetByName(newCell,"sv")
    newCell.sv:setScrollBarEnabled(false)
    newCell.sv:setPropagateTouchEvents(true)
    newCell.contentSize = newCell.sv:getInnerContainerSize()
    newCell.itemContainer = ccui.Helper:seekWidgetByName(newCell,"items")
    newCell.getButton     = ccui.Helper:seekWidgetByName(newCell,"getButton")
    newCell.rechargeBtn   = ccui.Helper:seekWidgetByName(newCell,"recharge_btn")
    newCell.btnText       = ccui.Helper:seekWidgetByName(newCell.getButton,"text")
    newCell.stateImage    = ccui.Helper:seekWidgetByName(newCell,"stateImage") 
    newCell.desc          = ccui.Helper:seekWidgetByName(newCell,"desc")
    newCell.progress      = ccui.Helper:seekWidgetByName(newCell,"progress")
    newCell.items         = {}
    newCell.rechargeBtn:getChildByName('text'):enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    newCell.rechargeBtn:getChildByName('text'):setString(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES3'))
    newCell:setVisible(true)

    return newCell

end
function FirstWeekActivityUI:createNewItem()
     local newItem = self.tempItem:clone()
     newItem.icon    =  ccui.Helper:seekWidgetByName(newItem,"itemIcon")
     newItem.itemNum =  ccui.Helper:seekWidgetByName(newItem,"itemNum")

     newItem:setVisible(true)
     return newItem
end

function FirstWeekActivityUI:SetTypesStringColor(currentType)
     for i = 1,self.numOfMaxTypes do
        if(i == currentType) then
            self.typeStrings[i]:setTextColor(COLOR_TYPE.ORANGE)
            self.typeStrings[i]:enableOutline(COLOROUTLINE_TYPE.PALE,2)
        else
            self.typeStrings[i]:setTextColor(COLOR_TYPE.PALE)
            self.typeStrings[i]:enableOutline(COLOROUTLINE_TYPE.DARK,2)
        end

    end
end

function FirstWeekActivityUI:SetDaysStringColor(lastDay,newDay)
   
    if(lastDay ~= -1) then
        if(self.selectDay == self.numOfDays) then
            self.daysBtns[lastDay]:loadTextureNormal("uires/ui/firstweekactivity/daanniu.png")
        else
            self.daysBtns[lastDay]:loadTextureNormal("uires/ui/firstweekactivity/btn_top1.png")
            --self.daysStrings[lastDay]:enableOutline(COLOROUTLINE_TYPE.WHITE2,1)
            --self.daysBtns[lastDay]:setContentSize(cc.size(107,52))
        end
         
    end

    if(newDay == self.numOfDays) then
        self.daysBtns[newDay]:loadTextureNormal("uires/ui/firstweekactivity/daanniu2.png")
    else
        self.daysBtns[newDay]:loadTextureNormal("uires/ui/firstweekactivity/btn_top2.png")
        --self.daysStrings[newDay]:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        --self.daysBtns[newDay]:setContentSize(cc.size(107,52))
    end

    self:playEffect(self.daysBtns[newDay])

end


function FirstWeekActivityUI:ChangeToDay(day,doAction)
    if(self.selectDay == day) then
        return
    end
    
    self:SetDaysStringColor(self.selectDay,day)
    self.selectDay = day
    self.currentType = -1

    for i = 1,self.numOfDays do
        if(i == day) then
            self.daysStrings[i]:setTextColor(cc.c3b(107, 20, 133))
            --self.channelBtns[i]:loadTextureNormal('uires/ui/chat/chat_btn_light.png')
            --self.channelTexts[i]:setTextColor(COLOR_TYPE.PALE)
        else
            self.daysStrings[i]:setTextColor(cc.c3b(255, 255, 255))
            --self.channelBtns[i]:loadTextureNormal('uires/ui/chat/chat_btn_dark.png')
            --self.channelTexts[i]:setTextColor(COLOR_TYPE.DARK)
        end
    end

    self.selectDayTypes = FirstWeekActivityMgr:GetTypesOfDay(day)

    if( self.selectDayTypes == nil) then
        print("can not found types of day:"..day)
        return
    end

    self.numOfselectDayType = math.min(self.numOfMaxTypes,#self.selectDayTypes)
    for i = 1,self.numOfselectDayType do
        self.typeBtns[i]:setVisible(true)
        self.typeStrings[i]:setString(self.selectDayTypes[i].title)
    end

    for i = self.numOfselectDayType + 1,self.numOfMaxTypes do
        self.typeBtns[i]:setVisible(false)
    end

     if(doAction) then
        self:DoTypesInAction(self.typesActionTime)
     end


    self:ChangeToType(1,doAction)
end
function FirstWeekActivityUI:ChangeToType(typeIndex,doAction)
    if(typeIndex == self.currentType ) then
        return
    end

    self.currentType = typeIndex

    self:SetTypesStringColor(typeIndex)
    

    local typeData = self.selectDayTypes[typeIndex]

    local firstTasak = FirstWeekActivityMgr:GetTaskByID(tonumber(typeData.task[1]))
    if(firstTasak == nil) then
        return
    end

      
    if(firstTasak["type"] == "sale") then
        self:ShowHalfPricePage(firstTasak,typeData.task[1])

        if(self.showingTaskPage) then
            local actionTime = 0.3
            self.rewardsPage:stopAllActions()
            self.halfPricePage:stopAllActions()
            self.halfPricePage:setPositionX(self.halfPricePage:getContentSize().width)
            self.halfPricePage:runAction(cc.MoveBy:create(actionTime,cc.p(-self.halfPricePage:getContentSize().width,0)))
            self.rewardsPage:runAction(cc.MoveBy:create(actionTime,cc.p(-self.rewardsPage:getContentSize().width,0)))
            self.rewardsPage:runAction(cc.Sequence:create(cc.DelayTime:create(actionTime),cc.CallFunc:create(function ()
                    self.rewardsPage:setVisible(false)
            end)))
        else
            self.rewardsPage:setVisible(false)
        end
         self.showingTaskPage = false
    else
        self:ShowTasksPage(typeData.task)
        if(not self.showingTaskPage) then
            self.rewardsPage:stopAllActions()
            self.halfPricePage:stopAllActions()
            local actionTime = 0.3
            self.rewardsPage:setPositionX(-self.rewardsPage:getContentSize().width)
            self.rewardsPage:runAction(cc.MoveBy:create(actionTime,cc.p(self.rewardsPage:getContentSize().width,0)))
            self.halfPricePage:runAction(cc.MoveBy:create(actionTime,cc.p(self.halfPricePage:getContentSize().width,0)))
            self.halfPricePage:runAction(cc.Sequence:create(cc.DelayTime:create(actionTime),cc.CallFunc:create(function ()
                    self.halfPricePage:setPositionX(0)
                    self.halfPricePage:setVisible(false)
            end)))
        else
            self.halfPricePage:setVisible(false)
            if(doAction) then
                self:DoTasksInAction(self.tasksActionTime)
            end
        end

        self.showingTaskPage = true
    end

end
function FirstWeekActivityUI:SetCellState(cell,state)
    
    cell.state = state

    cell.rechargeBtn:setVisible(false)
    cell.rechargeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('cash')
            FirstWeekActivityMgr:hideUI()
        end
    end)

    if(state == "inProgress") then
        cell.getButton:setVisible(false)

        if cell.taskType == 'pay' or cell.taskType == 'payOnce' then
            cell.stateImage:setVisible(false)
            cell.rechargeBtn:setVisible(true)
        else
            cell.stateImage:setVisible(true)
            cell.stateImage:loadTexture("uires/ui/activity/weidacheng.png")
            cell.getButton:setContentSize(cc.size(132,65))
        end

        --cell.getButton:loadTextureNormal("uires/ui/common/noshadow_btn_7.png")
        --cell.getButton:setContentSize(cc.size(104,50))

        --cell.btnText:setString(GlobalApi:getLocalStr("GOTO_1"))
        --cell.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE2,1)

--        cell.getButton:addTouchEventListener(function(sender, eventType)
--            if eventType == ccui.TouchEventType.ended then
--                  local function goto()
--                     local tab = GlobalApi:getGotoInfo(cell.taskType)
--                     if(tab ~= nil) then
--                        tab.callback()
--                     end
--                   end
--                  FirstWeekActivityMgr:hideUI(goto)
--            end
--        end)
    elseif(state == "finish") then
        cell.getButton:setVisible(true)
        cell.stateImage:setVisible(false)

        cell.getButton:loadTextureNormal("uires/ui/common/noshadow_btn_5.png")

        cell.btnText:setString(GlobalApi:getLocalStr("FWACT_GET"))
        cell.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        cell.getButton:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local taskData = FirstWeekActivityMgr:GetTaskByID(cell.id)
                local awards = DisplayData:getDisplayObjs(taskData.award)
                local hadFood = false
                for i = 1,#awards do
                    if awards[i]:getId() == 'food' then
				        hadFood = true
                        break
			        end
                end

                if hadFood == true then
                    local food = UserData:getUserObj():getFood()
                    local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                    if food >= maxFood then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                        return
                    end
                end

                FirstWeekActivityMgr:SendGetRewardMsg(cell.id)
            end
        end)
    elseif(state == "untimely") then
        cell.getButton:setVisible(false)
        cell.stateImage:setVisible(false)
    elseif(state == "got") then
        cell.getButton:setVisible(false)
        cell.stateImage:setVisible(true)
        cell.stateImage:loadTexture("uires/ui/activity/yilingqu.png")
    else
        cell.getButton:setVisible(false)
        cell.stateImage:setVisible(true)
        cell.stateImage:loadTexture("uires/ui/activity/yiguoqi.png")
        
    end

end
function FirstWeekActivityUI:RefreshCell(curCell,id)
        
        if(curCell == nil) then
            for i = 1,#self.taskCells do
                if(self.taskCells[i].id == id) then
                    curCell = self.taskCells[i]
                    break
                end
            end
            self:refreshAllMarks()
        end

        if(curCell == nil) then
            return
        end

        local taskData = FirstWeekActivityMgr:GetTaskByID(tonumber(id))
        curCell.data = taskData
        curCell.id = id
        curCell.taskType = taskData["type"]
        curCell.desc:setString(taskData.desc)
        local exRt = tonumber(GlobalApi:getGlobalValue('exchangeRate'))
        --充值类型的完成进度显示成target/
        if(taskData.progress ~= nil) then
            

            if(taskData.progress >= taskData.target) then
                if curCell.taskType == "pay" then
                    curCell.progress:setString(string.format("%d/%d",taskData.target/exRt,taskData.target/exRt))
                else
                    curCell.progress:setString(string.format("%d/%d",taskData.target,taskData.target))
                end
                 
                 --curCell.progress:setTextColor(COLOR_TYPE.GREEN)
                if(taskData.got) then
                    self:SetCellState(curCell,"got")
                else
                    if(self.currentDay >= self.selectDay) then
                        self:SetCellState(curCell,"finish")
                    else
                        self:SetCellState(curCell,"untimely")
                    end
                end
            else
                if curCell.taskType == "pay" then
                    curCell.progress:setString(string.format("%d/%d",taskData.progress/exRt,taskData.target/exRt))
                else
                    curCell.progress:setString(string.format("%d/%d",taskData.progress,taskData.target))
                end
                 
                 --curCell.progress:setTextColor(COLOR_TYPE.ORANGE)
                if(self.currentDay <= 7) then
                    self:SetCellState(curCell,"inProgress")
                else
                    self:SetCellState(curCell,"")
                end
            end
        else
             if(self.currentDay <= 7) then
                self:SetCellState(curCell,"inProgress")
             else
                self:SetCellState(curCell,"")
             end
            --curCell.progress:setString(string.format("%d/%d",0,taskData.target))
            if curCell.taskType == "pay" then
                curCell.progress:setString(string.format("%d/%d",0,taskData.target/exRt))
            else
                curCell.progress:setString(string.format("%d/%d",0,taskData.target))
            end
            --curCell.progress:setTextColor(COLOR_TYPE.ORANGE)
        end

        --curCell.progress:setPositionX( curCell.desc:getPositionX() + curCell.desc:getContentSize().width)

        local itemWidth = 100
        local rewards = DisplayData:getDisplayObjs(taskData.award)

        local allNum = #rewards
        local allWidth = allNum*itemWidth + (allNum - 1)*8
        if allWidth > curCell.contentSize.width then
            curCell.sv:setInnerContainerSize(cc.size(allWidth,curCell.contentSize.height))
        else
            curCell.sv:setInnerContainerSize(curCell.contentSize)
        end

        for i = 1,#rewards do
            if curCell.items[i] then
                curCell.items[i].awardBgImg:removeAllChildren()
                curCell.items[i].awardBgImg:removeFromParent()
                curCell.items[i] = nil
            end

            if allNum > 4 then
                if(curCell.items[i] == nil) then
                    curCell.items[i] = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, rewards[i], curCell.sv)
                    curCell.items[i].awardBgImg:setPosition(cc.p(50 + (i-1) * (itemWidth + 8),55))
                else
                    curCell.items[i].awardBgImg:setVisible(true)
                end
                curCell.sv:setVisible(true)
                curCell.itemContainer:setVisible(false)
            else
                if(curCell.items[i] == nil) then
                    curCell.items[i] = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, rewards[i], curCell.itemContainer)
                    curCell.items[i].awardBgImg:setPosition(cc.p(50 + (i-1) * (itemWidth + 8),50))
                else
                    curCell.items[i].awardBgImg:setVisible(true)
                end
                curCell.sv:setVisible(false)
                curCell.itemContainer:setVisible(true)
            end

            local curItem = curCell.items[i]
            curItem.awardBgImg:loadTexture(rewards[i]:getBgImg())
            curItem.chipImg:setVisible(true)
            curItem.chipImg:loadTexture(rewards[i]:getChip())
            curItem.awardImg:loadTexture(rewards[i]:getIcon())
            local godId = rewards[i]:getGodId()
            rewards[i]:setLightEffect(curItem.awardBgImg)

            if rewards[i]:getObjType() == 'equip' then
                curItem.lvTx:setString('Lv.'..rewards[i]:getLevel())
            end

            curItem.awardBgImg:setSwallowTouches(false)
            curItem.awardBgImg:setPropagateTouchEvents(false)
            local point1
            local point2
            curItem.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                    point1 = sender:getTouchBeganPosition()      
                end
                if eventType == ccui.TouchEventType.ended then
                    point2 = sender:getTouchEndPosition()
                    if point1 then
                        local dis = cc.pGetDistance(point1,point2)
                        if dis <= 5 then
                            GetWayMgr:showGetwayUI(rewards[i],false)
                        end
                    end
                end

		    end)
        end

        for i = #rewards + 1,#curCell.items do
            if(curCell.items[i] ~= nil) then
                curCell.items[i].awardBgImg:setVisible(false)
            end
        end

        curCell:stopAllActions()

end

function FirstWeekActivityUI:ShowTasksPage(taskIDs)

    self.rewardsPage:setVisible(true)

    if(taskIDs == nil) then
        return
    end

    -- 排序，已经领取的放到最下面
    local temp = {}
    local temp1 = {}
    local temp2 = {}

    for idx,id in pairs(taskIDs)  do
        local taskData = FirstWeekActivityMgr:GetTaskByID(tonumber(id))
        if taskData.got then
            temp2[#temp2 + 1] = id
        else
            temp1[#temp1 + 1] = id
        end
    end

    if #temp2 > 0 then
        for i = 1,#temp2,1 do
            table.insert(temp1,temp2[i])
        end
        temp = temp1
    else
        temp = temp1
    end

    --table.sort(temp,function(a,b) return a.priority < b.priority end)
    




    for idx,id in pairs(temp)  do
        if(self.taskCells[idx]== nil) then
            self.taskCells[idx] = self:createNewTaskCell()
            self.rewardsList:addChild(self.taskCells[idx])
            self.taskCells[idx].oriWidth =  self.taskCells[idx]:getContentSize().width
        end
        self:RefreshCell(self.taskCells[idx],tonumber(id))

    end

    for i = #self.taskCells,#temp + 1,-1 do
        self.rewardsList:removeChild(self.taskCells[i]);
        table.remove(self.taskCells,i)
    end
    self.rewardsList:forceDoLayout()

    self.rewardsList:jumpToTop();
    
end
function FirstWeekActivityUI:ShowHalfPricePage(taskData,id)
    self.halfPricePage:setVisible(true)

    --self.halfPrice_oriPriceNum = ccui.Helper:seekWidgetByName( priceBG,"oriPriceNum")
    --self.halfPrice_curPriceNum = ccui.Helper:seekWidgetByName( priceBG,"curPriceNum")
    self.halfPrice_oriPriceNum:setString(taskData.ori_sell)
    self.halfPrice_curPriceNum:setString(taskData.sell)
    self.halfPrice_oriPrice:setString(GlobalApi:getLocalStr("FWACT_ORIPRICE"))
    self.halfPrice_curPrice:setString(GlobalApi:getLocalStr("FWACT_CURPRICE"))

    local reward = DisplayData:getDisplayObj(taskData.award[1])
    if(self.halfPrice_itemCell == nil) then
        self.halfPrice_itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, reward, self.halfPrice_itemBG)
        self.halfPrice_itemCell.awardBgImg:setPosition(cc.p(self.halfPrice_itemCell.awardBgImg:getContentSize().width /2,
        self.halfPrice_itemCell.awardBgImg:getContentSize().height/2))
    else
        ClassItemCell:updateItem(self.halfPrice_itemCell, reward, 1)
    end
    self.halfPrice_itemName:setString(reward:getName())
    reward:setLightEffect(self.halfPrice_itemCell.awardBgImg)

    self.halfPrice_itemCell.awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			GetWayMgr:showGetwayUI(reward,false)
		end
	end)

    local left =taskData.left or 0

    local num = taskData.target - left
    if(num <0) then
        num = 0 
    end
    self.halfPrice_limitText:setString(string.format(GlobalApi:getLocalStr("FWACT_LIMIT"),taskData.target,num))
    if(taskData.got) then
        --self.halfPrice_buyBtn 
        --已购买
        self.halfPrice_buyText:setString(GlobalApi:getLocalStr("PURCHASED"))
        self.halfPrice_buyText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.halfPrice_buyText:enableShadow(COLOROUTLINE_TYPE.GRAY1, cc.size(0, -1), 0)
        self.halfPrice_buyBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(self.halfPrice_buyBtn)

    else
        if(self.selectDay > self.currentDay) then
            self.halfPrice_buyText:setString(GlobalApi:getLocalStr("BUY"))
            ShaderMgr:setGrayForWidget(self.halfPrice_buyBtn)
            self.halfPrice_buyText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
            self.halfPrice_buyText:enableShadow(COLOROUTLINE_TYPE.GRAY1, cc.size(0, -1), 0)
            self.halfPrice_buyBtn:setTouchEnabled(false)
        else
            if(num > 0) then
                --有货
                self.halfPrice_buyText:setString(GlobalApi:getLocalStr("BUY"))
                ShaderMgr:restoreWidgetDefaultShader(self.halfPrice_buyBtn)
                self.halfPrice_buyText:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
                self.halfPrice_buyText:enableShadow(COLOROUTLINE_TYPE.WHITE1, cc.size(0, -1), 0)
                self.halfPrice_buyBtn:setTouchEnabled(true)
                self.halfPrice_buyBtn:addTouchEventListener(function(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if UserData:getUserObj():getCash() < taskData.sell then
	                        promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				                    GlobalApi:getGotoByModule('cash')
			                    end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))

                            return
	                    end
                        FirstWeekActivityMgr:SendGetRewardMsg(tonumber(id),true)
                    end
                end)    
            
            else
                --售罄
                self.halfPrice_buyText:setString(GlobalApi:getLocalStr("SOLDOUT"))
                ShaderMgr:setGrayForWidget(self.halfPrice_buyBtn)
                self.halfPrice_buyText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
                self.halfPrice_buyText:enableShadow(COLOROUTLINE_TYPE.GRAY1, cc.size(0, -1), 0)
                self.halfPrice_buyBtn:setTouchEnabled(false)
            end

        end

    end
end
function FirstWeekActivityUI:DisableHalfPriceBuyBtn()
        self.halfPrice_buyText:setString(GlobalApi:getLocalStr("PURCHASED"))
        self.halfPrice_buyBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(self.halfPrice_buyBtn)
        self.halfPrice_buyText:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.halfPrice_buyText:enableShadow(COLOROUTLINE_TYPE.GRAY1, cc.size(0, -1), 0)
end
function  FirstWeekActivityUI:DoTasksOutAction(time)
  
     --self.rewardsList:forceDoLayout()

     self.rewardsPage:unscheduleUpdate()
  
    local elTime = 0
    local function scheduleUpdate(dt)
        elTime = elTime + dt
        local t = 1-elTime/time

        if(t <= 0) then
             t = 0
             self.rewardsPage:unscheduleUpdate()
        end

        for i = 1,#self.taskCells do

            local curCell = self.taskCells[i]
        
            curCell:setContentSize(cc.size(curCell.oriWidth* t,curCell:getContentSize().height))
        end
    end

    self.rewardsPage:scheduleUpdateWithPriorityLua(scheduleUpdate, 0)

end
function  FirstWeekActivityUI:DoTasksInAction(time)
  
     --self.rewardsList:forceDoLayout()

     self.rewardsPage:unscheduleUpdate()
  
    local elTime = 0
    local function scheduleUpdate(dt)
        elTime = elTime + dt
        local t = elTime/time

        if(t >=1) then
             t = 1
             self.rewardsPage:unscheduleUpdate()
             self.runningTasksAction = false
        end

        for i = 1,#self.taskCells do

            local curCell = self.taskCells[i]

            curCell:setContentSize(cc.size(curCell.oriWidth * t,curCell:getContentSize().height))
        end
    end

    self.rewardsPage:scheduleUpdateWithPriorityLua(scheduleUpdate, 0)
end

function  FirstWeekActivityUI:DoTypesInAction(time)
    
    if(self.numOfselectDayType <= 0) then
        return
    end

    local stepTime = time/self.numOfselectDayType
    
    for i = 1,self.numOfMaxTypes do
        self.typeBtns[i]:setVisible(false)
    end

    local function DropSingleBtn(idx)
         if(idx > self.numOfselectDayType) then
--            self.selectFrame:setVisible(true)
--            self.selectFrame:setPosition(self.typeBtns[1].oriPos)
            self.runningTypesAction = false
            return
         end
         local curBtn = self.typeBtns[idx]
         curBtn:setVisible(true)
         curBtn:setPositionY(curBtn:getPositionY() + 75)
         curBtn:runAction(cc.EaseIn:create(cc.MoveTo:create(stepTime,curBtn.oriPos),0.5))
         --curBtn:runAction(cc.MoveTo:create(stepTime,curBtn.oriPos))
         curBtn:runAction(cc.Sequence:create(cc.DelayTime:create(stepTime),cc.CallFunc:create(function ()
            return DropSingleBtn(idx + 1)
         end)))
    end

    DropSingleBtn(1)
end
function  FirstWeekActivityUI:DoTypesOutAction(time)
    
    if(self.numOfselectDayType <= 0) then
        return
    end

    local stepTime = time/self.numOfselectDayType

    local allTime = 0
    local function DropSingleBtn(idx)
         if(idx < 1) then
            return
         end

         local curBtn = self.typeBtns[idx]
         --curBtn:setPositionY(curBtn:getPositionY() + 75)
         -- curBtn:runAction(cc.EaseOut:create(cc.MoveBy:create(stepTime,cc.p(0,75)),0.5))
         curBtn:runAction(cc.MoveBy:create(stepTime,cc.p(0,75)))
         curBtn:runAction(cc.Sequence:create(cc.DelayTime:create(stepTime),cc.CallFunc:create(function ()
            curBtn:setVisible(false)
            curBtn:setPositionY(curBtn.oriPos.y)
            allTime = allTime + stepTime
            return DropSingleBtn(idx - 1)

         end)))

    end

    DropSingleBtn(self.numOfselectDayType)
end


return FirstWeekActivityUI
