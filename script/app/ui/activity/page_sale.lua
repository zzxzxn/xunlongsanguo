local PageSale = class("PageSale")
local ClassItemCell = require('script/app/global/itemcell')
function PageSale:init(msg)
    self.rootBG     = self.root:getChildByName("root")

    self.rightBG = ccui.Helper:seekWidgetByName(self.rootBG,"rightbg")

    local bottom = ccui.Helper:seekWidgetByName(self.rightBG,"bottom")
    local rechargedTx = ccui.Helper:seekWidgetByName(bottom,"rechargedTx")
    self.rechargedNum = ccui.Helper:seekWidgetByName(bottom,"rechargedNum")
    self.rechargeBtn   = ccui.Helper:seekWidgetByName(bottom,"rechargeBtn")
    local rechargeBtnTx = ccui.Helper:seekWidgetByName(self.rechargeBtn,"btnTx")
    local rewardTx = ccui.Helper:seekWidgetByName(bottom,"rewardTx")

    --rewardTx:setVisible(false)
    --ccui.Helper:seekWidgetByName(bottom,"mail"):setVisible(false)


    rechargedTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP1"))
    rewardTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP6"))
    rechargeBtnTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP7"))

    --self:setupCells(msg)
    self:addCells(msg)

    local conf = GameData:getConfData('activities')['value_package']
    local nowTime = Time.getCorrectServerTime()
    local endTime = GlobalApi:convertTime(1,conf.endTime)
    local delayTime = conf.delayDays * 86400
    local refTime = endTime + delayTime - nowTime
    ActivityMgr:ShowRightCueResetHourBySale()
    ActivityMgr:showLefSDesc2Cue()
    self:registerTouchEvents()

    -- 点击一下这个分页叹号就消失
    UserData:getUserObj().activity.overvalued_gift.day = msg.overvalued_gift.day

    self:updateMark()

end

function PageSale:updateMark()
    if UserData:getUserObj():getActivitySaleShowStatus() then
        ActivityMgr:showMark("value_package", true)
    else
        ActivityMgr:showMark("value_package", false)
    end

end

function PageSale:addCells(giftState)
    local cell1 = ccui.Helper:seekWidgetByName(self.rightBG,"cell1")
    local cell2 = ccui.Helper:seekWidgetByName(self.rightBG,"cell2")
    cell1:setVisible(false)
    cell2:setVisible(false)

    local time = Time.getCorrectServerTime()
    local conf = GameData:getConfData('activities')['value_package']
    local startTime = GlobalApi:convertTime(1,conf.startTime)

    local diffTime = time - startTime
    local day = math.ceil(diffTime/(24*3600))
    print('=========++++++++++++' .. day)

    local saleDatas = GameData:getConfData("avovervaluedgift")
    local temp = saleDatas[day]
    if not temp then
        return
    end

    local sortTemp = {}
    for k,v in ipairs(temp) do
        if type(v) == 'table' then
            table.insert(sortTemp,v)
        end
    end
    self.cells = {}

    local sv = self.rightBG:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    local num = #sortTemp
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * cell1:getContentSize().height + (num - 1)*cellSpace
    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cell1:getContentSize().height

    for i = 1,num do
        local cell = cell1:clone()
        cell:setVisible(true)
        local size = cell:getContentSize()
        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        cell:setPosition(cc.p(5,allHeight - offset))
        sv:addChild(cell)

        local data = sortTemp[i]
        local rechargeTx = ccui.Helper:seekWidgetByName(cell,"rechargeTx")
        local text = ccui.Helper:seekWidgetByName(cell,"text")
        local money = ccui.Helper:seekWidgetByName(cell,"money")
        local numTx = ccui.Helper:seekWidgetByName(cell,"numTx")
        local itemContent = ccui.Helper:seekWidgetByName(cell,"items")

        cell.btn   = ccui.Helper:seekWidgetByName(cell,"getBtn")
        cell.btnTx = ccui.Helper:seekWidgetByName(cell.btn,"btnTx")
        cell.gotIcon = ccui.Helper:seekWidgetByName(cell,"got")
        cell.giftID = i
        cell.btnTx:setString(GlobalApi:getLocalStr("STR_GET_1"))
        rechargeTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP4"))
        numTx:setString(data.money)
        money:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP5"))
        text:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP3"))

        self.cells[i] = cell
        local awards = DisplayData:getDisplayObjs(data.award)
        if(awards ~= nil) then
            for k,v in pairs(awards) do
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, itemContent)
                tab.awardBgImg:setPosition(cc.p((k-1) * (tab.awardBgImg:getContentSize().width + 8) +  tab.awardBgImg:getContentSize().width/2,
                                             itemContent:getContentSize().height/2))
                tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		            if eventType == ccui.TouchEventType.ended then
					    AudioMgr.PlayAudio(11)
					    GetWayMgr:showGetwayUI(v,false)
		            end
		        end)
                tab.awardBgImg:loadTexture(v:getBgImg())
                tab.chipImg:setVisible(true)
                tab.chipImg:loadTexture(v:getChip())
                tab.lvTx:setString('x'..v:getNum())
                tab.awardImg:loadTexture(v:getIcon())
                local godId = v:getGodId()
                v:setLightEffect(tab.awardBgImg)
            end
        end
        if(giftState.money >= data.money) then
            if(giftState.overvalued_gift[string.format("%d",i)] == nil) then
                local function clickGet(sender, eventType)
                   if eventType == ccui.TouchEventType.ended then
                        AudioMgr.PlayAudio(11)
                        self:sendGetGiftMessage(i)
                   end
                end
                --cell.btn:addTouchEventListener(clickGet)
                --cell.gotIcon:setVisible(false)
                cell.btn:setVisible(false)  -- 现在统一只有未领取和已领取状态
                cell.gotIcon:loadTexture("uires/ui/activity/yihuode.png") 
            else
                --cell.gotIcon:loadTexture()
               cell.btn:setVisible(false)
               cell.gotIcon:loadTexture("uires/ui/activity/yihuode.png") 
            end
        else
            cell.btn:setVisible(false)
            cell.gotIcon:loadTexture("uires/ui/activity/weidacheng.png") 
        end
    end
    innerContainer:setPositionY(size.height - allHeight)
    self.rechargedNum:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_SALETIP2"),giftState.money))
end

function PageSale:setupCells(giftState)
    local time = Time.getCorrectServerTime()
    local conf = GameData:getConfData('activities')['value_package']
    local startTime = GlobalApi:convertTime(1,conf.startTime)

    local diffTime = time - startTime
    local day = math.ceil(diffTime/(24*3600))
    print('=========++++++++++++' .. day)

    local saleDatas = GameData:getConfData("avovervaluedgift")
    local temp = saleDatas[day]
    if not temp then
        return
    end
    self.cells = {}
    for i = 1,2 do
        local data = temp[i]
        local cell = ccui.Helper:seekWidgetByName(self.rightBG,"cell"..i)
        local rechargeTx = ccui.Helper:seekWidgetByName(cell,"rechargeTx")
        local text = ccui.Helper:seekWidgetByName(cell,"text")
        local money = ccui.Helper:seekWidgetByName(cell,"money")
        local numTx = ccui.Helper:seekWidgetByName(cell,"numTx")
        local itemContent = ccui.Helper:seekWidgetByName(cell,"items")

        cell.btn   = ccui.Helper:seekWidgetByName(cell,"getBtn")
        cell.btnTx = ccui.Helper:seekWidgetByName(cell.btn,"btnTx")
        cell.gotIcon = ccui.Helper:seekWidgetByName(cell,"got")
        cell.giftID = i
        cell.btnTx:setString(GlobalApi:getLocalStr("STR_GET_1"))
        rechargeTx:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP4"))
        numTx:setString(data.money)
        money:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP5"))
        text:setString(GlobalApi:getLocalStr("ACTIVITY_SALETIP3"))


        self.cells[i] = cell
        local awards = DisplayData:getDisplayObjs(data.award)
        if(awards ~= nil) then
            for k,v in pairs(awards) do
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, itemContent)
                tab.awardBgImg:setPosition(cc.p((k-1) * (tab.awardBgImg:getContentSize().width + 8) +  tab.awardBgImg:getContentSize().width/2,
                                             itemContent:getContentSize().height/2))
                tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		            if eventType == ccui.TouchEventType.ended then
					    AudioMgr.PlayAudio(11)
					    GetWayMgr:showGetwayUI(v,false)
		            end
		        end)
            end
        end
        if(giftState.money >= data.money) then
            if(giftState.overvalued_gift[string.format("%d",i)] == nil) then
                local function clickGet(sender, eventType)
                   if eventType == ccui.TouchEventType.ended then
                        AudioMgr.PlayAudio(11)
                        self:sendGetGiftMessage(i)
                   end
                end
                --cell.btn:addTouchEventListener(clickGet)
                --cell.gotIcon:setVisible(false)
                cell.btn:setVisible(false)  -- 现在统一只有未领取和已领取状态
                cell.gotIcon:loadTexture("uires/ui/activity/yihuode.png") 
            else
                --cell.gotIcon:loadTexture()
               cell.btn:setVisible(false)
               cell.gotIcon:loadTexture("uires/ui/activity/yihuode.png") 
            end
        else
            cell.btn:setVisible(false)
            cell.gotIcon:loadTexture("uires/ui/activity/weidacheng.png") 
        end
    end
    self.rechargedNum:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_SALETIP2"),giftState.money))
end
function PageSale:registerTouchEvents()
    local function clickRecharge(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
            --ActivityMgr:hideUI()
            RechargeMgr:showRecharge()
       end
    end
    self.rechargeBtn:addTouchEventListener(clickRecharge)
end
function PageSale:sendGetGiftMessage(giftID)
    
    MessageMgr:sendPost('get_overvalued_gift_awards','activity',json.encode({id = giftID}),function(jsonObj)
        print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        local awards = jsonObj.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
            GlobalApi:showAwardsCommon(awards,nil,nil,true)
        end
        local costs = jsonObj.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end

        for i = 1,#self.cells do
            local cell = self.cells[i]
            if(cell.giftID == giftID) then
                cell.btn:setVisible(false)
                cell.gotIcon:setVisible(true)
                cell.gotIcon:loadTexture("uires/ui/activity/yihuode.png") 
            end
        end

    end)
end
return PageSale