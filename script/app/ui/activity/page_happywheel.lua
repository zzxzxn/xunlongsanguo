local HappyWheel = class("HappyWheel")
local ClassItemCell = require('script/app/global/itemcell')
local ClassSellTips = require('script/app/ui/tips/selltips')
local ActivityHappyWheelLogUI = require("script/app/ui/activity/page_happywheellog")

--local ActivityLuckyWheelRankUI = require("script/app/ui/activity/page_luckywheel_rank")
local maxAwards = 8
function HappyWheel:init(msg)
    self.rootBG = self.root:getChildByName("root")
    self.msg = msg
    
    self.conf = GameData:getConfData('avhappywheel')
    self.costconf = GameData:getConfData('avhappywheelcosts')
    self.cell= self.root:getChildByName('select_cell')
    self.cell:setVisible(false)
    
    if self.msg.happy_wheel.id and #self.msg.happy_wheel.id > 0 then
        self.selecttab = self.msg.happy_wheel.id
    else
        self.selecttab = {}
    end
    self.selectstate = 0
    local  bg  = self.rootBG:getChildByName('bg')
    self.selectimg = bg:getChildByName('select_img')
    self.selectimg:setVisible(false)
    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()
    self:refreshOwnNum()
    self:update()
    --self:updateMark()

end

function HappyWheel:updateMark()
    if UserData:getUserObj():getSignByType('happy_wheel') then
		ActivityMgr:showMark("happy_wheel", true)
	else
		ActivityMgr:showMark("happy_wheel", false)
	end
end

function HappyWheel:initData()
    self.luckyWheelConf = GameData:getConfData('avluckywheel')
    self.luckyWheelScoreConf = GameData:getConfData('avluckywheelscore')
    self.cells = {}
end

function HappyWheel:initTop()
    ActivityMgr:showRightHappyWheelRemainTime()
    self.topHappyWheel = ActivityMgr:getLefHappyWheelCue()
    self.topHappyWheel:setVisible(true)

    self.humanWheelHelp = self.topHappyWheel:getChildByName('human_wheel_help')
    self.happyWheelLogBtn = self.topHappyWheel:getChildByName('happy_wheel_log_btn')
    self.addBtn = self.topHappyWheel:getChildByName('add_btn')
    self.ownNum = self.topHappyWheel:getChildByName('own_num')

    self.humanWheelHelp:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(38)
        end
    end)

    self.happyWheelLogBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('get_happy_wheel_log','activity',json.encode({num = num,id = 350005}),
	            function(response)
		            if(response.code ~= 0) then
			            return
		            end

                    local activityLuckyWheelRankUI = ActivityHappyWheelLogUI.new(response.data)
			        activityLuckyWheelRankUI:showUI()
                    
	            end)
        end
    end)

    self.addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            local awardData = {{'material',350005,1}}
            local disPlayData = DisplayData:getDisplayObjs(awardData)
            local awards = disPlayData[1]
            local tab = {}
            tab.icon = 'uires/ui/res/res_cash.png'
            tab.num = UserData:getUserObj():getCash()   -- 拥有的元宝数
            tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
            tab.id = 'cash'
            tab.costNum = tonumber(GlobalApi:getGlobalValue('happyTokenCosts'))     -- 单价
            tab.confId = nil
            tab.sellNum = 1     -- 这个暂时好像没用
            --[[if tab.num < tab.costNum then
			    promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				        GlobalApi:getGotoByModule('cash')
			        end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                return
            end
            --]]
            self:showTips(awards,tab,nil,function(callback,num,cash)
                if callback then
                    callback()
                end
                if num == 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES12'), COLOR_TYPE.RED)
                else
                    self:buyProp(num,cash)
                end
            end,nil,math.floor(tab.num/tab.costNum),'show_at_surprise_step')


        end
    end)

    self.happyWheelLogBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_10'))
end

function HappyWheel:showTips(award,tab,status,callback,sidebarList,num,showType)
    local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num,showType)
    sellTipsUI:showUI()
end

function HappyWheel:buyProp(num,cost)
    local num = num or 1
    local function sendToServer()
        self:sendToServer(num)
	end
	UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
end

function HappyWheel:sendToServer(num)
    MessageMgr:sendPost('buy_happy_token','activity',json.encode({num = num,id = 350005}),
	    function(response)
		    if(response.code ~= 0) then
			    return
		    end

            local awards = response.data.awards
		    if awards then
			    GlobalApi:parseAwardData(awards)
			    GlobalApi:showAwardsCommon(awards,nil,nil,true)
		    end

		    local costs = response.data.costs
		    if costs then
			    GlobalApi:parseAwardData(costs)
		    end
            self:refreshOwnNum()
	    end)
end

function HappyWheel:refreshOwnNum()
    local ownNowNum = 0
    if BagData:getMaterialById(350005) then
        ownNowNum = BagData:getMaterialById(350005):getNum()
    end
    self.ownNum:setString(ownNowNum)
end

function HappyWheel:initLeft()
    local bg = self.rootBG:getChildByName('bg')

    self.leftsv = bg:getChildByName('sv')
    self.leftsv:setScrollBarEnabled(false)
    self.leftsv:setInertiaScrollEnabled(true)
    self.leftsv:removeAllChildren()
    self.cells = {}
    local svwidth = 330
    local svheight = 200
    local cellheight = {}
    local innerContainer = self.leftsv:getInnerContainer()
    local size = self.leftsv:getContentSize()
    local num = self:calcNumOfType()
    for i = 1,num do
        cellheight[i] = 0
    end
    local selectImg = ccui.ImageView:create('uires/ui/common/bg_black1.png')
    selectImg:setName('selectImg')
    selectImg:setVisible(true)
    selectImg:setScale(1.2)
    for i = num,1,-1 do
            local tempCell = self.cell:clone()
            tempCell:setVisible(true)
            local namebg = tempCell:getChildByName('name_bg')
            local nametx = tempCell:getChildByName('name_tx')
            local pl = tempCell:getChildByName('head_pl')
            local arr =self:getArrByType(i)
            local plheight = 85*(math.ceil(#arr/4))
            pl:setContentSize(cc.size(svwidth,plheight))
            svheight = 40+plheight
            cellheight[i] = svheight
            tempCell:setContentSize(cc.size(svwidth,svheight))
            pl:setPosition(cc.p(0,plheight))
            namebg:setPosition(cc.p(165,svheight))
            nametx:setPosition(cc.p(165,svheight-5))
            
            if i == 1 then
                nametx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.RED)) 
                nametx:enableOutline(cc.c4b(255,30,0, 255),1)
                nametx:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_5'))
            elseif i == 2 then
                nametx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.YELLOW)) 
                nametx:enableOutline(cc.c4b(254,165,0, 255),1)
                nametx:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_6'))
            end
            for j = 1, #arr do
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
                cell.id = arr[j].id
                table.insert(self.cells,cell)
                local displayobj = DisplayData:getDisplayObj(arr[j].award[1])
                cell.awardBgImg:loadTexture(displayobj:getBgImg())
                cell.awardBgImg:setScale(0.7)
                
                cell.awardImg:loadTexture(displayobj:getIcon())
                cell.lvTx:setString("x"..displayobj:getNum())
                cell.awardBgImg:setTouchEnabled(true)

                if i == 1 then
                    GlobalApi:setLightEffect(cell.awardBgImg,1)
                    
                    local specialName = ccui.Text:create()
                    specialName:setRotation(30)
                    specialName:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_16'))
                    specialName:setFontName("font/gamefont.ttf")
                    specialName:setFontSize(24)
                    specialName:setPosition(cc.p(80,82))
                    specialName:setTextColor(COLOR_TYPE.YELLOW)
                    specialName:enableOutline(COLOR_TYPE.RED, 2)
                    cell.awardBgImg:addChild(specialName)
                end

                local grayimg = ccui.ImageView:create('uires/ui/common/bg_gray50.png')
                grayimg:setPosition(cc.p(94/2,94/2))
                grayimg:setScale(2.3)
                cell.awardBgImg:addChild(grayimg)
                cell.grayimg = grayimg

                local checkboximg = ccui.ImageView:create('uires/ui/common/select_checkbox.png')
                checkboximg:setPosition(cc.p(94/2,94/2))
                cell.awardBgImg:addChild(checkboximg)
                cell.checkboximg = checkboximg

                cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        if self.selectstate == 0 then
                            GetWayMgr:showGetwayUI(displayobj,false)
                        elseif self.selectstate == 1 then
                            if cell.judge == true then
                                for k,v in pairs(self.selecttab) do
                                    if tonumber(v) == tonumber(arr[j].id) then
                                        self.selecttab[tonumber(k)] = nil
                                        self:update()
                                        return
                                    end
                                end
                                
                            else
                                local allNum = 0
                                local curSelectBestNum = 0
                                local curSelectSecondNum = 0
                                for k,v in pairs(self.selecttab) do
                                    if v then
                                        allNum = allNum + 1
                                        for ii = 1,#self.conf do
                                            if tonumber(self.conf[ii].id) == tonumber(v) then
                                                if self.conf[ii].type == 1 then
                                                    curSelectBestNum = curSelectBestNum + 1
                                                else
                                                    curSelectSecondNum = curSelectSecondNum + 1
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                                if allNum >= maxAwards then
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_12'), COLOR_TYPE.RED)
                                    return
                                end

                                if i == 1 then
                                    if curSelectBestNum >= tonumber(GlobalApi:getGlobalValue('happyWheelGreatestNum')) then
                                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_13'),tonumber(GlobalApi:getGlobalValue('happyWheelGreatestNum'))), COLOR_TYPE.RED)
                                        return
                                    end
                                else
                                    if curSelectSecondNum >= tonumber(GlobalApi:getGlobalValue('happyWheelHighestNum')) then
                                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_14'),tonumber(GlobalApi:getGlobalValue('happyWheelHighestNum'))), COLOR_TYPE.RED)
                                        return
                                    end
                                end

                                for m = 1,maxAwards do
                                    if self.selecttab[m] == nil then
                                        self.selecttab[m] = arr[j].id
                                        self:update()
                                        break
                                    end
                                end
                                
                            end
                            
                        end
                    end
                end)
                local x = 50+80*((j-1)%4)
                local y = plheight-40-75*(math.ceil(j/4)-1)
                cell.awardBgImg:setPosition(cc.p(x,y))
                
                if arr[j].id == self.selectframeid then
                    local size = cell.awardBgImg:getContentSize()
                    selectImg:setPosition(cc.p(size.width/2,size.height/2))
                    cell.awardBgImg:addChild(selectImg)
                end 
                pl:addChild(cell.awardBgImg)
            end
            
            local heighttemp = 0 
            for s = 1, num do
                heighttemp = heighttemp + cellheight[s]
            end
            local tcellheight = 0
            for n = i,num do
                if n == num then
                    break
                else
                   tcellheight = tcellheight + cellheight[n+1]
                end
            end  
            if heighttemp > size.height then
                innerContainer:setContentSize(cc.size(svwidth,heighttemp))
            end
            tempCell:setPosition(cc.p(0,tcellheight))

            self.leftsv:addChild(tempCell)
        end

    self.leftsv:scrollToTop(0.01, false)
end

function HappyWheel:update()
    if self.selectstate == 0 then
        self.selectimg:setVisible(false)
        self.title:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_7'))
    elseif self.selectstate == 1 then
        self.selectimg:setVisible(true)
        self.title:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_8'))
    end
    self:updateCells()
    self:initRight()
end
function HappyWheel:calcNumOfType()
    local num = 0
    local typetab = {}
    for k, v in pairs(self.conf) do
        local n  = GlobalApi:tableFind(typetab,v.type)
        if n == 0 then
            table.insert(typetab,v.type)
        end
    end
    return #typetab
end

function HappyWheel:getArrByType(value)
    local num = 0
    local typearr = {}
    for k, v in pairs(self.conf) do
        if v.type == value then
            table.insert(typearr,v)
        end
    end
    table.sort(typearr,function(a,b)
        return a.id < b.id
    end)
    return typearr
end

function HappyWheel:initRight()
    local bg = self.rootBG:getChildByName('bg')

    local wheel = bg:getChildByName('wheel')
    local arrow = wheel:getChildByName('arrow')
    self.arrow = arrow
    local img = wheel:getChildByName('img')
    self.img = img
    img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectstate == 0 then
                self.selectstate = 1
                self:update()
            elseif self.selectstate == 1 then
                if #self.selecttab < 1 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_20'),COLOR_TYPE.RED)
                    return
                end
                self.selectstate = 0
                self:SelectItemMsg()
            end
        end
    end)
    self.title = img:getChildByName('title')
    for i = 1,maxAwards do
        local frame = wheel:getChildByName('icon_' .. i)
        if frame:getChildByName('award_bg_img') then
            frame:removeChildByName('award_bg_img')
        end
        frame:getChildByName('no_award_tx'):setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_11'))
        if self.selecttab[i] then
            local data = self.conf[tonumber(self.selecttab[i])]
            
            local awardData = data.award
            local disPlayData = DisplayData:getDisplayObjs(awardData)
        
            local awards = disPlayData[1]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
            cell.awardBgImg:setScale(0.6)
            cell.awardBgImg:setPosition(cc.p(35,35))
            cell.lvTx:setString('x'..awards:getNum())
            
            if data.type == 1 then
                GlobalApi:setLightEffect(cell.awardBgImg,1)
                
                local specialName = ccui.Text:create()
                specialName:setRotation(30)
                specialName:setString(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_16'))
                specialName:setFontName("font/gamefont.ttf")
                specialName:setFontSize(24)
                specialName:setPosition(cc.p(80,82))
                specialName:setTextColor(COLOR_TYPE.YELLOW)
                specialName:enableOutline(COLOR_TYPE.RED, 2)
                cell.awardBgImg:addChild(specialName)
            else
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            end
        end
    end
    local tab = {}
    for k,v in pairs(self.costconf) do
        table.insert(tab,v)
    end
    table.sort(tab,function(a,b)
        return a.id < b.id
    end)
    self.wheelbtntab = {}
    for i=1,3 do
        self.wheelbtntab[i] = bg:getChildByName('wheel_btn_'..i)
        local btntx = self.wheelbtntab[i]:getChildByName('btn_tx')
        btntx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_9'),tab[i].id))
        local costbg = bg:getChildByName('cost_'..i)
        local costnumtx = costbg:getChildByName('cost_num')
        local displayobj = DisplayData:getDisplayObj(tab[i].costs[1])
        costnumtx:setString(displayobj:getNum())
        local costimg = costbg:getChildByName('cost_img')
        costimg:loadTexture(displayobj:getIcon())
        self.wheelbtntab[i]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)        
            elseif eventType == ccui.TouchEventType.ended then
                self:scrollToServer(tab[i].id)
            end
        end)
    end
end

function HappyWheel:costPropCost()
    return 1
end

function HappyWheel:scrollToServer(count)
    if self.selectstate == 1 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_15'), COLOR_TYPE.RED)
        return
    end
    local allNum = 0
    for k,v in pairs(self.selecttab) do
        if v then
            allNum = allNum + 1
        end
    end

    if allNum < maxAwards then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_2'), COLOR_TYPE.RED)
        return
    end
    self:disableBtn()
    local function callBack()  
        MessageMgr:sendPost('turn_happy_wheel','activity',json.encode({time = count}),
	    function(response)
		    if(response.code ~= 0) then
                self:openBtn()
			    return
		    end
            self:disableBtn()
            self:scrollStart(response.data)
	    end)
    end
    print('count'..count)
    local cost = self.costconf[count].costs
    local displayobj = DisplayData:getDisplayObj(cost[1])
    local hasCash = UserData:getUserObj():getCash()
    if displayobj and displayobj:getOwnNum() < displayobj:getNum() then
        local stepItemCostNum = tonumber(GlobalApi:getGlobalValue('happyTokenCosts'))
        local buyNum = displayobj:getNum() - displayobj:getOwnNum()
        local cost = stepItemCostNum * buyNum
        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_19'),cost,buyNum,displayobj:getName()), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            local hasCash = UserData:getUserObj():getCash()
            if hasCash >= cost then
                self:sendToServer(buyNum)
            else
                promptmgr:showMessageBox(
				GlobalApi:getLocalStr('STR_CASH')..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. GlobalApi:getLocalStr('STR_CASH') .. '？',
				MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				function ()
					GlobalApi:getGotoByModule('cash')
				end)
            end
        end)
        self:openBtn()
        return
    else
        callBack()
    end
    
end

-- 转动开始
function HappyWheel:scrollStart(data)
    local id = 1
    for k,v in pairs(self.selecttab) do
        if tonumber(v) == data.ids[1] then
            id = tonumber(k)
            break
        end
    end
    --print('+++++++++++++++++++++' .. id)
    local awards = data.awards
    local costs = data.costs

    if not id or id <= 0 then
        if awards then
			GlobalApi:parseAwardData(awards)
		end
        if costs then
            GlobalApi:parseAwardData(costs)
        end
        self:openBtn()
        return
    end
    local endDeg = (id - 1) * 45 + GlobalApi:random(3, 42)
    local vec = cc.pForAngle(math.rad(90 - endDeg))
	local offset = 20
    local offset1 = 20

    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(0.66, 360)),cc.RotateBy:create(0.4,360),cc.EaseSineOut:create(cc.RotateBy:create(1, endDeg + 360 * 2)))
    --local act2 = cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(vec.x*offset, vec.y*offset)), cc.MoveBy:create(0.5,cc.p(vec.x*-offset1, vec.y*-offset1)))
    local act2 = cc.DelayTime:create(0.75)
    local act3 = cc.CallFunc:create(
	    function ()
			GlobalApi:showAwardsCommon(awards,true,nil,false)

            if awards then
			    GlobalApi:parseAwardData(awards)
		    end
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self:openBtn()

            self.arrow:setRotation(0)
            self:refreshOwnNum()

            --for i = 1,#self.cells do
                --self:updateCell(i)
            --end
            --
            --ActivityMgr:showLuckyWheelCount(self.msg.happy_wheel.score)
            --
            --local pond = self.msg.pond
            --if pond > 10000 then
                --pond = math.floor(pond/10000) .. GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES12')
            --end
            --self.cashRichText.re2:setString(pond)
            --self.cashRichText:format(true)

	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

function HappyWheel:updateCells()
    for i = 1,#self.cells do
        local cell = self.cells[i]
        local id = cell.id
        local grayimg = cell.grayimg
        local checkboximg = cell.checkboximg
        local judge = false
        for k,v in pairs(self.selecttab) do
            if tonumber(v) == tonumber(id) then
                judge = true
                break
            end
        end
        cell.judge = judge
        if judge == true then
            grayimg:setVisible(true)
            checkboximg:setVisible(true)
        else
            grayimg:setVisible(false)
            checkboximg:setVisible(false)
        end
    end
end

function HappyWheel:disableBtn()
    self.happyWheelLogBtn:setTouchEnabled(false)
    self.addBtn:setTouchEnabled(false)
    self.img:setTouchEnabled(false)
    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)
        end
    end
    for i = 1,3 do
        self.wheelbtntab[i]:setTouchEnabled(false)
    end
    local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(false)
        end
    end
end

function HappyWheel:openBtn()
    self.happyWheelLogBtn:setTouchEnabled(true)
    self.addBtn:setTouchEnabled(true)
    self.img:setTouchEnabled(true)
    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)
        end
    end
    for i = 1,3 do
        self.wheelbtntab[i]:setTouchEnabled(true)
    end
    local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(true)
        end
    end
end

function HappyWheel:SelectItemMsg()
    local tab = {}
    for k,v in pairs(self.selecttab) do
        table.insert(tab,tonumber(v))
    end
    MessageMgr:sendPost('choice_happy_wheel_award','activity',json.encode({id = tab}),
    function(response)
        if(response.code ~= 0) then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_3'), COLOR_TYPE.RED)
            return
        end
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_4'), COLOR_TYPE.GREEN)
        self:update()
    end)
end
return HappyWheel