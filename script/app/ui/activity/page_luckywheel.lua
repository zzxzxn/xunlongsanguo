local LuckyWheel = class("LuckyWheel")
local ClassItemCell = require('script/app/global/itemcell')
local ActivityLuckyWheelRankUI = require("script/app/ui/activity/page_luckywheel_rank")

function LuckyWheel:init(msg)
    self.rootBG = self.root:getChildByName("root")
    self.msg = msg

    UserData:getUserObj().luckyWheelTag = 0
    if UserData:getUserObj().todayDoubleTag == 0 and UserData:getUserObj().luckyWheelTag == 0 and UserData:getUserObj().payOnlyTag == 0 then
        UserData:getUserObj().first_login = 0
    end

    self:initData()
    self:initTop()
    self:initLeft()
    self:initCenter()
    self:initRight()

    self:updateMark()

end

function LuckyWheel:updateMark()
    if UserData:getUserObj():getSignByType('lucky_wheel') then
		ActivityMgr:showMark("lucky_wheel", true)
	else
		ActivityMgr:showMark("lucky_wheel", false)
	end
end

function LuckyWheel:initData()
    self.luckyWheelConf = GameData:getConfData('avluckywheel')
    self.luckyWheelScoreConf = GameData:getConfData('avluckywheelscore')
    self.cells = {}
end

function LuckyWheel:initTop()
    ActivityMgr:showRightLuckyWheelRemainTime()
    ActivityMgr:showLuckyWheelCount(self.msg.lucky_wheel.score)
end

function LuckyWheel:initLeft()
    local left = self.rootBG:getChildByName('left')
    local title = left:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES3'))

    local sv = left:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    local rewardCell = sv:getChildByName('cell')
    rewardCell:setVisible(false)

    local dataTable = {}
    for k,v in pairs(self.luckyWheelScoreConf) do
        table.insert(dataTable,v)
    end
    table.sort(dataTable,function (a,b)  return a.score < b.score end)

    local num = #dataTable
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 25

    local height = num * rewardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = rewardCell:getContentSize().height
    self.leftBtns = {}
    for i = 1,num do
        local data = dataTable[i]
        local tempCell = rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        sv:addChild(tempCell)

        -- 
        local tx = tempCell:getChildByName('tx')
        local icon = tempCell:getChildByName('icon')
        local getImg = tempCell:getChildByName('get_img')
        local getBtn = tempCell:getChildByName('recharge_btn')
        getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))

        local awardData = data.award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local frame = tempCell:getChildByName('icon')
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setScale(64/94)
        cell.awardBgImg:setPosition(cc.p(32,32))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)


        tempCell.data = dataTable[i]
        tempCell.tx = tx
        tempCell.i = i
        tempCell.awardBgImg = cell.awardBgImg
        tempCell.awards = awards
        tempCell.getImg = getImg
        tempCell.getBtn = getBtn

        table.insert(self.leftBtns,getBtn)
        
        table.insert(self.cells,tempCell)
        self:updateCell(i)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function LuckyWheel:updateCell(i)
    local tempCell = self.cells[i]
    local data = tempCell.data
    local tx = tempCell.tx
    local awardBgImg = tempCell.awardBgImg
    local getImg = tempCell.getImg  -- 显示状态
    local getBtn = tempCell.getBtn

    local hasCount = self.msg.lucky_wheel.score
    local allCount = data.score
    local showCount = hasCount
    if hasCount > allCount then
        showCount = allCount
    end
    tx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES4'),showCount,allCount))

    -- 判断是否领取
    local reward = self.msg.lucky_wheel.reward
    if reward[tostring(data.score)] and reward[tostring(data.score)] == 1 then  -- 已领取
        tx:setVisible(false)
        getBtn:setVisible(false)
        getImg:setVisible(true)
    else
        if hasCount < allCount then -- 未达成
            tx:setVisible(true)
            getBtn:setVisible(false)
            getImg:setVisible(false)
        else
            tx:setVisible(false)
            getBtn:setVisible(true)
            getImg:setVisible(false)
        end
    end

    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --GetWayMgr:showGetwayUI(tempCell.awards,false)

            if showCount < allCount then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES13'), COLOR_TYPE.RED)
                return
            end

            MessageMgr:sendPost('get_lucky_wheel_score_reward','activity',json.encode({score = data.score}),
		    function(response)
			    if(response.code ~= 0) then
				    return
			    end
			    local awards = response.data.awards
			    if awards then
				    GlobalApi:parseAwardData(awards)
				    GlobalApi:showAwardsCommon(awards,nil,nil,true)
			    end               

                self.msg.lucky_wheel.reward[tostring(data.score)] = 1

                self:updateCell(i)
		    end)

        end
    end)
end

function LuckyWheel:initCenter()
    local center = self.rootBG:getChildByName('center')

    local wheel = center:getChildByName('wheel')
    local arrow = wheel:getChildByName('arrow')
    self.arrow = arrow
    local img = wheel:getChildByName('img')

    local title = img:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES9'))


    local num = #self.luckyWheelConf
    for i = 1,num do
        local data = self.luckyWheelConf[i]
        local frame = wheel:getChildByName('icon_' .. i)

        local awardType = data.type
        if awardType == 1 then
            local awardData = data.award
            local disPlayData = DisplayData:getDisplayObjs(awardData)
            
            local awards = disPlayData[1]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
            cell.awardBgImg:setScale(1.1)
            cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
            cell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        else
            local awardBgImg = ccui.ImageView:create('uires/ui/common/frame_yellow.png')
            local size = awardBgImg:getContentSize()
            awardBgImg:setTouchEnabled(true)
            awardBgImg:setScale(1.1)
            awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
            frame:addChild(awardBgImg)

            local awardImg = ccui.ImageView:create('uires/ui/rech/rech_icon_8.png')
            awardImg:setScale(0.6)
            awardImg:setPosition(cc.p(size.width/2,size.height/2))
            awardBgImg:addChild(awardImg)

            local percentImg = ccui.ImageView:create('uires/ui/activity/percent_bg.png')
            percentImg:setScale(1.5)
            percentImg:setPosition(cc.p(size.width - 10,15))
            awardBgImg:addChild(percentImg)

            local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 14)
            nameTx:setPosition(cc.p(20,15))
            nameTx:setColor(COLOR_TYPE.YELLOW)
            nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BLACK))
            nameTx:setAnchorPoint(cc.p(0.5,0.5))
            nameTx:setString(data.cashPercent .. '%')
            percentImg:addChild(nameTx)

            local realValueArr = string.split('user.cash:100', ',')
			local realValue = {}
			for k, v in pairs(realValueArr) do
				local segs = string.split(v, ":")
				if #segs == 2 then
					local award = string.split(segs[1], ".")
					table.insert(award, tonumber(segs[2]))
					table.insert(realValue, award)
				end
			end           
            local disPlayData = DisplayData:getDisplayObjs(realValue)           
            local awards = disPlayData[1]
            awards.baseinfo = clone(awards.baseinfo)
            awards.baseinfo.desc = string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES17'),data.cashPercent) .. '%'
            
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(awards,false)
                end
            end)

        end

    end

    -- 元宝
    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))

    local re1 = xx.RichTextImage:create("uires/ui/res/res_cash.png")
    re1:setScale(0.7)
    
    -- 显示上看是否加'万'字
    local pond = self.msg.pond
    --if pond > 10000 then
        --pond = math.floor(pond/10000) .. GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES12')
    --end
	local re2 = xx.RichTextLabel:create(pond, 22, COLOR_TYPE.WHITE)
	re2:setStroke(COLOR_TYPE.BLACK,1)
    re2:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
    richText.re2 = re2

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))

    richText:setPosition(cc.p(52,35))
    img:addChild(richText)
    richText:format(true)
    self.cashRichText = richText
end

function LuckyWheel:initRight()
    local right = self.rootBG:getChildByName('right')

    local countRankBtn = right:getChildByName('count_rank_btn')
    countRankBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES5'))
    countRankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            MessageMgr:sendPost('get_lucky_wheel_rank','activity',json.encode({}),
		    function(response)
			    if(response.code ~= 0) then
				    return
			    end
			    local rank = response.data.rank_list -- 有可能是空的

                local activityLuckyWheelRankUI = ActivityLuckyWheelRankUI.new(rank)
			    activityLuckyWheelRankUI:showUI()

		    end)


        end
    end)
    self.countRankBtn = countRankBtn

    --
    local oneAwardBtn = right:getChildByName('one_award_btn')
    oneAwardBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES6'))
    oneAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:scrollToServer(1,callBack)
        end
    end)
    self.oneAwardBtn = oneAwardBtn

    self.oneRichText = self:getRichText2()
    self.oneRichText:setPosition(cc.p(oneAwardBtn:getPositionX(),oneAwardBtn:getPositionY() + 60))
    right:addChild(self.oneRichText)

    self.oneRichText.re3:setString(GlobalApi:getGlobalValue("luckyWheelCost"))
    self.oneRichText:format(true)

    local fiveAwardBtn = right:getChildByName('five_award_btn')
    fiveAwardBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES20'))
    fiveAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local cost = tonumber(GlobalApi:getGlobalValue("luckyWheelCost"))*50
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES31'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                self:scrollToServer(50,callBack)
            end)
        end
    end)
    self.fiveAwardBtn = fiveAwardBtn

    -- 显示
    self.fiveRichText = self:getRichText()
    self.fiveRichText:setPosition(cc.p(fiveAwardBtn:getPositionX(),fiveAwardBtn:getPositionY() + 60))
    right:addChild(self.fiveRichText)

    --[[local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("luckyWheelCostItemId")))
    local hasNum = 0
    if item then
        hasNum = item:getNum()
    end
    --]]

    self.fiveRichText.re3:setString(GlobalApi:getGlobalValue("luckyWheelCost")*50)
    self.fiveRichText:format(true)

    --
    local tenAwardBtn = right:getChildByName('ten_award_btn')
    tenAwardBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES7'))
    tenAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local cost = tonumber(GlobalApi:getGlobalValue("luckyWheelCost"))*10
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES11'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                self:scrollToServer(10,callBack)
            end)
        end
    end)
    self.tenAwardBtn = tenAwardBtn

    -- 显示
    self.tenRichText = self:getRichText2()
    self.tenRichText:setPosition(cc.p(tenAwardBtn:getPositionX(),tenAwardBtn:getPositionY() + 60))
    right:addChild(self.tenRichText)

    self.tenRichText.re3:setString(GlobalApi:getGlobalValue("luckyWheelCost")*10)
    self.tenRichText:format(true)

end

function LuckyWheel:getRichText()
    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES8'), 25, cc.c3b(0x6e, 0x47, 0x30))
	re1:setStroke(cc.c4b(239, 219, 176, 255),1)
    re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
    local data = self:getCostPropData()
    local re3 = xx.RichTextImage:create("uires/icon/user/cash.png")
    re3:setScale(50/80)
    
	local re2 = xx.RichTextLabel:create('', 25, cc.c3b(0x6e, 0x47, 0x30))
	re2:setStroke(cc.c4b(239, 219, 176, 255),1)
    re2:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))

    richText.re3 = re2
    return richText
end

function LuckyWheel:getRichText2()
    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))

    local data = self:getCostPropData()
    local re2 = xx.RichTextImage:create("uires/icon/user/cash.png")
    re2:setScale(50/80)
    
	local re1 = xx.RichTextLabel:create('', 25, cc.c3b(0x6e, 0x47, 0x30))
	re1:setStroke(cc.c4b(239, 219, 176, 255),1)
    re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))

    richText.re3 = re1
    return richText
end
-- 消耗道具的数据
function LuckyWheel:getCostPropData()
    --local propId = tonumber(GlobalApi:getGlobalValue('luckyWheelCostItemId'))
    --local data = GameData:getConfData('item')[propId]
    --return data
    return tonumber(GlobalApi:getGlobalValue('luckyWheelCost'))

end

function LuckyWheel:costPropCost()
    return 1
end

-- 转到通讯
function LuckyWheel:scrollToServer(count,callBack)
    self:disableBtn()

    --[[local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("luckyWheelCostItemId")))
    local hasNum = 0
    if item then
        hasNum = item:getNum()
    end
    local allCost = count * self:costPropCost()
    if allCost > hasNum then
        self:openBtn()
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES10'), COLOR_TYPE.RED)
        return
    end
    --]]
    -- 元宝消耗
    local function callBack()  
        MessageMgr:sendPost('turn_lucky_wheel','activity',json.encode({time = count}),
	    function(response)
		    if(response.code ~= 0) then
                self:openBtn()
			    return
		    end
            self:disableBtn()

            self.msg.lucky_wheel.score = response.data.score
            self.msg.pond = response.data.pond

            -- 开始转动
            self:scrollStart(response.data)
	    end)
    end

    local cost = tonumber(GlobalApi:getGlobalValue("luckyWheelCost"))*count

    local hasCash = UserData:getUserObj():getCash()
    if cost > hasCash then
        self:openBtn()
        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("cash")
        end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
        return
    else
        callBack()
    end

end

-- 转动开始
function LuckyWheel:scrollStart(data)
    local id = data.ids[1]
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

            -- 刷新显示
            self.arrow:setRotation(0)

            for i = 1,#self.cells do
                self:updateCell(i)
            end
            --
            ActivityMgr:showLuckyWheelCount(self.msg.lucky_wheel.score)
            --
            local pond = self.msg.pond
            --if pond > 10000 then
                --pond = math.floor(pond/10000) .. GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES12')
            --end
            self.cashRichText.re2:setString(pond)
            self.cashRichText:format(true)
            --
            --[[
            local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("luckyWheelCostItemId")))
            local hasNum = 0
            if item then
                hasNum = item:getNum()
            end
            self.oneRichText.re3:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES4'),self:costPropCost(),hasNum))
            self.oneRichText:format(true)

            self.tenRichText.re3:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES4'),self:costPropCost() * 10,hasNum))
            self.tenRichText:format(true)
            --]]

	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

-- 禁用按钮
function LuckyWheel:disableBtn()
    self.countRankBtn:setTouchEnabled(false)
    self.oneAwardBtn:setTouchEnabled(false)
    self.fiveAwardBtn:setTouchEnabled(false)
    self.tenAwardBtn:setTouchEnabled(false)
    for i = 1,#self.cells do
        self.cells[i].awardBgImg:setTouchEnabled(false)
    end
    local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(false)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(false)
    end

    if cue4Help then
        cue4Help:setTouchEnabled(false)
    end

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)    
        end
    end

    for i = 1,#self.leftBtns do
       self.leftBtns[i]:setTouchEnabled(false)
    end
end

-- 启用按钮
function LuckyWheel:openBtn()
    self.countRankBtn:setTouchEnabled(true)
    self.oneAwardBtn:setTouchEnabled(true)
    self.fiveAwardBtn:setTouchEnabled(true)
    self.tenAwardBtn:setTouchEnabled(true)
    for i = 1,#self.cells do
        self.cells[i].awardBgImg:setTouchEnabled(true)
    end
    local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(true)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(true)
    end

    if cue4Help then
        cue4Help:setTouchEnabled(true)
    end

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)
        end
    end
    for i = 1,#self.leftBtns do
       self.leftBtns[i]:setTouchEnabled(true)
    end
end

return LuckyWheel