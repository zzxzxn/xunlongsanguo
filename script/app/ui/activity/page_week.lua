local PageWeek = class("PageWeek")
local ClassItemCell = require('script/app/global/itemcell')
function PageWeek:init(msg)
    self.rootBG     = self.root:getChildByName("root")
    self.scrollView = self.rootBG:getChildByName("scrollView")
    self.scrollView:setScrollBarEnabled(false)

    self.tempItemCell = cc.CSLoader:createNode("csb/activity_itemcell.csb"):getChildByName("root")

    self:ShowItems(msg)

    ActivityMgr:showLeftCue(GlobalApi:getLocalStr("ACTIVITY_PRITIP1"))
    ActivityMgr:showRightCue(GlobalApi:getLocalStr("ACTIVITY_PRITIP2"))

    local updateDay = tonumber(Time.date('%Y%m%d',msg.update))
    UserData:getUserObj().activity.week_gift.update = msg.update

	self:updateMark()

end

function PageWeek:updateMark()
	if UserData:getUserObj():getActivityWeekShowStatus() then
		ActivityMgr:showMark("week", true)
	else
		ActivityMgr:showMark("week", false)
	end
end

function PageWeek:ShowItems(payedGift)
    local weekDatas = GameData:getConfData("avweekgift")
    local vip = UserData:getUserObj():getVip()

    self.visibleCells = {}
    for key,data in pairs(weekDatas) do
        local newCell = self.tempItemCell:clone()

        local award = DisplayData:getDisplayObj(data.award[1])
        if(award ~= nil and payedGift.week_gift[tostring(key)] ~= nil) then

            newCell.giftID = key

            local itemName = ccui.Helper:seekWidgetByName(newCell,"itemName")
            local price     = ccui.Helper:seekWidgetByName(newCell,"price")
            local oriPrice  = ccui.Helper:seekWidgetByName(price,"oriPrice")
            local curPrice  = ccui.Helper:seekWidgetByName(price,"curPrice")
            newCell.limitText = ccui.Helper:seekWidgetByName(newCell,"limitText")
            local itemContent = ccui.Helper:seekWidgetByName(newCell,"item")
            newCell.btn   = ccui.Helper:seekWidgetByName(newCell,"btn")
            newCell.btnTx = ccui.Helper:seekWidgetByName(newCell,"btnTx")
            newCell.btnTx:setString(GlobalApi:getLocalStr("BUY_1"))
           

            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, itemContent)
            itemName:setString(award:getName())
            oriPrice:setString(data.oriPrice)
            curPrice:setString(data.curPrice)
            tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
					AudioMgr.PlayAudio(11)
					GetWayMgr:showGetwayUI(award,false)
		        end
		    end)
            
            tab.awardBgImg:setPosition(cc.p(itemContent:getContentSize().width/2,itemContent:getContentSize().height/2))

            table.insert(self.visibleCells,newCell)
             newCell.maxNum  = data["vip"..vip] or 0
             newCell.curNum = payedGift.week_gift[string.format("%d",key)] or 0
             newCell.limitText:setString( newCell.curNum.."/"..newCell.maxNum)
            if(newCell.curNum >= newCell.maxNum) then
                ShaderMgr:setGrayForWidget(newCell.btn)
                newCell.btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
                newCell.btn:setTouchEnabled(false)
                newCell.payed = true
            else
                local function clickBuy(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if UserData:getUserObj():getCash() < data.curPrice then
                            --promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
                            promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					                GlobalApi:getGotoByModule('cash')
				                end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                            return
                        end
                        self:sendBuyGiftMessage(key)
                    end
                end
                newCell.btn:addTouchEventListener(clickBuy)
                newCell.payed = false
            end
        end
    end
    table.sort(self.visibleCells,(function (a,b)
        if(b.payed and a.payed) then    
            return a.giftID < b.giftID
        elseif(b.payed) then
            return true
         elseif(a.payed) then
            return false
        else
            return a.giftID < b.giftID
        end
    end))

    local numOfCell = #self.visibleCells
    local viewHeight = math.floor((numOfCell+1)/2)* 118
    if(viewHeight > self.scrollView:getContentSize().height) then
        self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,viewHeight))
    else
        viewHeight = self.scrollView:getContentSize().height
        self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width,viewHeight))
    end

    for i = 1,numOfCell do
        local cell = self.visibleCells[i]
        self.scrollView:addChild(cell)
        if(math.mod(i,2) == 1) then
            cell:setPosition(cc.p(0,viewHeight - math.floor((i-1)/2 + 1)* 118))
        else
            cell:setPosition(cc.p(455,viewHeight - math.floor((i-1)/2 + 1)* 118))
        end
    end

end
function PageWeek:sendBuyGiftMessage(giftID)
    
    MessageMgr:sendPost('buy_week_gift','activity',json.encode({id = giftID}),function(jsonObj)
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

        for i = 1,#self.visibleCells do
            local cell = self.visibleCells[i]
            if(cell.giftID == giftID) then
                cell.curNum = cell.curNum + 1
                if(cell.curNum >= cell.maxNum) then
                    ShaderMgr:setGrayForWidget(cell.btn)
                    cell.btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
                    cell.btn:setTouchEnabled(false)
                    cell.payed = true
                end
                cell.limitText:setString( cell.curNum.."/"..cell.maxNum)
            end
        end

    end)
end

return PageWeek