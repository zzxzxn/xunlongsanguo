local RolePromoteLuckyWheel = class("RolePromoteLuckyWheel", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local RolePromoteLuckyWheelRankUI = require("script/app/ui/role/rolepromoteluckywheelrank")

local menuarrnor = {
    "uires/ui/activity/xingyunzhuanpan1.png",
    "uires/ui/activity/hongzhuanpan2.png"
}

local menuarrsel = {
    "uires/ui/activity/xingyunzhuanpan11.png",
    "uires/ui/activity/hongzhuanpan.png"
}
function RolePromoteLuckyWheel:ctor(msg)
    self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_LUCKY_WHEEL_PANEL
    self.msg = msg.promote_wheel
end

function RolePromoteLuckyWheel:init()
    local bgimg = self.root:getChildByName('bg_img')
    local bgalpha = bgimg:getChildByName('bg_alpha')
    local bgimg1 = bgalpha:getChildByName('bg_img_1')
    self:adaptUI(bgimg,bgalpha)
    self.rootBG = bgimg1:getChildByName("root")
    
    self.closeBtn = bgimg1:getChildByName('close_btn')
    self.closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRolePromotedLuckyWheel()
        end
    end)
    self.selectpage = 1
    self.topbtnarr = {}
    for i=1,2 do
        local tab = {}
        tab.bg = bgalpha:getChildByName('top_btn_'..i)
        tab.icon = tab.bg:getChildByName('icon')
        tab.mark = tab.bg:getChildByName('mark')
        tab.titlebg = tab.bg:getChildByName('titlebg')
        tab.titletx = tab.bg:getChildByName('titletx')
        self.topbtnarr[i] = tab
        local function clickMenu(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.selectpage = i
                self:selectMenu()
                 AudioMgr.PlayAudio(11)
                self:update()
            end
        end
        tab.bg:addTouchEventListener(clickMenu)
    end
    self.topbtnarr[1].titletx:setString(GlobalApi:getLocalStr('ROLE_DESC28'))
    self.topbtnarr[2].titletx:setString(GlobalApi:getLocalStr('ROLE_DESC29'))
    self.rightred = self.rootBG:getChildByName('right_red')
    self.rightorange = self.rootBG:getChildByName('right_orange')

    local vip = tonumber(UserData:getUserObj():getVip())
    self.isbigvip = false
    self.costone = 0
    self.costten = 0
    local openOrange,openRed = true,false
    if vip >= tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')) then
        openOrange = true
    end
    if GlobalApi:getPrivilegeById("orangeDial") then
        openOrange = true
    end

    if vip >= tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict')) then
        openRed = true
    end
    if GlobalApi:getPrivilegeById("redDial") then
        openRed = true
    end
    
    print("openOrange:" ,openOrange,openRed)
    self.topbtnarr[1].bg:setVisible(openOrange)
    self.topbtnarr[2].bg:setVisible(openRed)

    --[[
    if  vip >= tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')) and vip < tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict')) then
        self.topbtnarr[2].bg:setVisible(false)
        self.topbtnarr[1].bg:setVisible(true)
    elseif vip >= tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict')) then
        self.topbtnarr[2].bg:setVisible(true)
        self.topbtnarr[1].bg:setVisible(true)
    else
        self.topbtnarr[2].bg:setVisible(false)
        self.topbtnarr[1].bg:setVisible(true)        
    end]]  

    local topbg = self.rootBG:getChildByName('top_bg')
    local desctx = topbg:getChildByName('desc_tx')
    desctx:setString(GlobalApi:getLocalStr('TAVERN_NOW_OWN')..':')
    self.disGoods = {}
    for i=1,3 do
        local tab = {}
        tab.icon = topbg:getChildByName('res_icon_'..i)
        tab.numtx = topbg:getChildByName('res_num_'..i)
        self.disGoods[i] = tab
    end
    local helpbtn = self.rootBG:getChildByName('help_btn')
    helpbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectpage == 1 then
                HelpMgr:showHelpUI(31)
            elseif self.selectpage == 2 then
                HelpMgr:showHelpUI(32)
            end
        end
    end)
    self.cells = {}
    self:selectMenu()
    self:update()
    RechargeMgr.vipChanged = false
end

function RolePromoteLuckyWheel:update()
    self:selectMenu()
    if self.selectpage == 1 then
        self.rightred:setVisible(false)
        self.rightorange:setVisible(true)
        self.RolePromoteLuckyWheelConf = GameData:getConfData('promotelucklyorange')
        self.RolePromoteLuckyWheelScoreConf = GameData:getConfData('promoteawardorange')
        self.right = self.rightorange
        self.costone = tonumber(GlobalApi:getGlobalValue('promoteOrangeCost'))
        self.costten = tonumber(GlobalApi:getGlobalValue('promoteOrangeCostTen'))
    elseif self.selectpage == 2 then
        self.rightred:setVisible(true)
        self.rightorange:setVisible(false)
        self.RolePromoteLuckyWheelConf = GameData:getConfData('promotelucklyred')
        self.RolePromoteLuckyWheelScoreConf = GameData:getConfData('promoteawardred')
        self.right = self.rightred
        self.isbigvip = true
        self.costone = tonumber(GlobalApi:getGlobalValue('promoteRedCost'))
        self.costten = tonumber(GlobalApi:getGlobalValue('promoteRedCostTen'))
    end
    
    self:initTop()
    self:initLeft()
    self:initCenter()
    self:initRight()
end

function RolePromoteLuckyWheel:selectMenu()
    for i=1,2 do
        if i == self.selectpage then
            self.topbtnarr[i].icon:loadTexture(menuarrsel[i])
            self.topbtnarr[i].titlebg:loadTexture("uires/ui/activity/biaoti.png")
            self.topbtnarr[i].titletx:setTextColor(cc.c4b(128,67,13, 255))
            self:playEffect(i)
        else
            self.topbtnarr[i].icon:loadTexture(menuarrnor[i])
            self.topbtnarr[i].titlebg:loadTexture("uires/ui/activity/biaoti2.png")
            self.topbtnarr[i].titletx:setTextColor(cc.c4b(110,73,48,255))            
        end
    end 
end

function RolePromoteLuckyWheel:playEffect(index)
    if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end
    
    local size = self.topbtnarr[index].bg:getContentSize()
    local size1 = self.topbtnarr[index].bg:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(size.width/2 - 5 ,size.height/2 - 25))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    self.topbtnarr[index].icon:setLocalZOrder(101)
    self.topbtnarr[index].titlebg:setLocalZOrder(102)
    self.topbtnarr[index].titletx:setLocalZOrder(103)
    self.topbtnarr[index].mark:setLocalZOrder(104)
    self.topbtnarr[index].bg:addChild(lvUp)
    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)
    self.lvUp = lvUp
end

function RolePromoteLuckyWheel:initTop()
    local displayconf = GameData:getConfData('promoteredgoodsshow')
    
    for i=1,3 do
        local awardData = displayconf[self.selectpage][i]['goods']
        local displayobjs = DisplayData:getDisplayObjs(awardData)
        if displayobjs[1] then
            self.disGoods[i].icon:loadTexture(displayobjs[1]:getIcon())
            self.disGoods[i].numtx:setString('x' .. GlobalApi:toWordsNumber(displayobjs[1]:getOwnNum()))
        end
    end
end

function RolePromoteLuckyWheel:initLeft()
    self.cells = {}

    local left = self.rootBG:getChildByName('left')
    local title = left:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES3'))

    local sv = left:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    sv:removeAllChildren()
    local rewardCell = left:getChildByName('cell')
    rewardCell:setVisible(false)

    local score = 0
    local reward = {}
    if self.selectpage == 1 then
        score = self.msg.orange.score
        reward = self.msg.orange.reward
    elseif self.selectpage == 2 then
        score = self.msg.red.score
        reward = self.msg.red.reward
    end

    local dataTable = {}
    for k,v in pairs(self.RolePromoteLuckyWheelScoreConf) do
        local hasCount = tonumber(score)
        local allCount = v.number
        -- 判断是否领取
        --local reward = sreward
        if reward[tostring(v.number)] and reward[tostring(v.number)] == 1 then  -- 已领取
            v.canGet = 2
        else
            if hasCount < allCount then -- 未达成
                v.canGet = 1
            else
                v.canGet = 0
            end
        end
        table.insert(dataTable,v)
    end
    table.sort(dataTable,function (a,b)
        if a.canGet == b.canGet then
            return a.number < b.number
        end
        return a.canGet < b.canGet
    end)

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
        if not self.cells[i] then
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
            local tx = tempCell:getChildByName('tx')
            local icon = tempCell:getChildByName('icon')
            local getImg = tempCell:getChildByName('get_img')
            local getBtn = tempCell:getChildByName('recharge_btn')
            getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
            local frame = tempCell:getChildByName('icon')
            local cell = ClassItemCell:create()
            cell.awardBgImg:setScale(64/94)
            cell.awardBgImg:setPosition(cc.p(32,32))
            frame:addChild(cell.awardBgImg)
            tempCell.tx = tx
            tempCell.i = i
            tempCell.awardBgImg = cell.awardBgImg
            tempCell.awards = awards
            tempCell.getImg = getImg
            tempCell.getBtn = getBtn
            tempCell.cell = cell
            table.insert(self.leftBtns,getBtn)
            table.insert(self.cells,tempCell)
        end
        self.cells[i].data = dataTable[i]
        local data = dataTable[i]
        local awardData = data.award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        ClassItemCell:updateItem(self.cells[i].cell,awards,1)
        self.cells[i].cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        self.cells[i].cell.awardBgImg:setVisible(true)
        awards:setLightEffect(self.cells[i].cell.awardBgImg)
        self.cells[i].cell.awardBgImg:setTouchEnabled(true)
        self.cells[i].cell.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(awards,false)
            end
        end)
        self:updateCell(i)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function RolePromoteLuckyWheel:updateCell(i)
    local tempCell = self.cells[i]
    local data = tempCell.data
    local tx = tempCell.tx
    local awardBgImg = tempCell.awardBgImg
    local getImg = tempCell.getImg  -- 显示状态
    local getBtn = tempCell.getBtn

    local score = 0
    if self.selectpage == 1 then
        score = self.msg.orange.score
    elseif self.selectpage == 2 then
        score = self.msg.red.score
    end
    local hasCount = tonumber(score)
    local allCount = data.number
    local showCount = hasCount
    if hasCount > allCount then
        showCount = allCount
    end
    tx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES4'),showCount,allCount))
    -- 判断是否领取
    if data.canGet == 2 then  -- 已领取
        tx:setVisible(false)
        getBtn:setVisible(false)
        getImg:setVisible(true)
    elseif data.canGet == 1 then 
        tx:setVisible(true)
        getBtn:setVisible(false)
        getImg:setVisible(false)
    else
        tx:setVisible(false)
        getBtn:setVisible(true)
        getImg:setVisible(false)
    end

    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if showCount < allCount then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES13'), COLOR_TYPE.RED)
                return
            end

            MessageMgr:sendPost('get_promote_wheel_reward','activity',json.encode({score = data.number,ptype = self.selectpage}),
		    function(response)
			    if(response.code ~= 0) then
				    return
			    end
			    local awards = response.data.awards
			    if awards then
				    GlobalApi:parseAwardData(awards)
				    GlobalApi:showAwardsCommon(awards,nil,nil,true)
			    end               

                if self.selectpage == 1 then
                    self.msg.orange.reward[tostring(data.number)] = 1
                elseif self.selectpage == 2 then
                    self.msg.red.reward[tostring(data.number)] = 1
                end
                self:initTop()
                self:initLeft()
		    end)

        end
    end)
end

function RolePromoteLuckyWheel:initCenter()
    local center = self.rootBG:getChildByName('center')

    local wheel = center:getChildByName('wheel')


    local arrow = wheel:getChildByName('arrow')
    self.arrow = arrow
    local img = wheel:getChildByName('img')
    local midimg = img:getChildByName('mid_img')

    if self.selectpage == 1 then
        wheel:loadTexture('uires/ui/activity/chengjiangzhuanpan.png')
        midimg:loadTexture('uires/ui/activity/cheng_mid.png')
    elseif self.selectpage == 2 then
        wheel:loadTexture('uires/ui/activity/hong.png')
        midimg:loadTexture('uires/ui/activity/hong_mid.png')
    end
    local num = #self.RolePromoteLuckyWheelConf
    for i = 1,num do
        local data = self.RolePromoteLuckyWheelConf[i]
        local frame = wheel:getChildByName('icon_' .. i)
        local awardData = data.award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setScale(1.1)
        cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
    end
    self.cashRichText = richText
end

function RolePromoteLuckyWheel:initRight()
    if self.isbigvip and self.selectpage == 2 then
        local countRankBtn = self.right:getChildByName('count_rank_btn')
        countRankBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local startTime = self.msg.open_time
                local endTime = self.msg.end_time
                local nowTime = Time.getCorrectServerTime()
                if nowTime < startTime or nowTime > endTime then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC37'), COLOR_TYPE.RED)
                else
                    MessageMgr:sendPost('get_promote_wheel_rank','activity',json.encode({}),
    		        function(response)
    			        if(response.code ~= 0) then
    				        return
    			        end
                        RoleMgr:showRolePromotedLuckyWheelRank(response.data,startTime,endTime)
    		        end)
                end


            end
        end)
        self.countRankBtn = countRankBtn
    end

    local oneAwardBtn = self.right:getChildByName('one_award_btn')
    oneAwardBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ROLE_DESC31'))
    oneAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:scrollToServer(1,self.selectpage,callBack)
        end
    end)
    self.oneAwardBtn = oneAwardBtn

    -- 显示
    self.oneRichText = self:getRichText()
    self.oneRichText:setPosition(cc.p(oneAwardBtn:getPositionX(),oneAwardBtn:getPositionY() + 60))
    self.right:addChild(self.oneRichText)

    self.oneRichText.re3:setString(self.costone)
    self.oneRichText:format(true)

    local tenAwardBtn = self.right:getChildByName('ten_award_btn')
    tenAwardBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ROLE_DESC32'))
    tenAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local cost = self.costten
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES11'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                --self:scrollToServer(10,callBack)
                    ----------------------------------
                    local count = 10
                    -- 元宝消耗
                    local function callBack()  
                        MessageMgr:sendPost('turn_promote_wheel','activity',json.encode({time = count,ptype = self.selectpage}),
	                    function(response)
		                    if(response.code ~= 0) then
			                    return
		                    end

                            if self.selectpage == 1 then
                                self.msg.orange.score = response.data.score
                                self.msg.orange.item = response.data.item
                            elseif self.selectpage == 2 then
                                self.msg.red.score = response.data.score
                                self.msg.red.item = response.data.item
                            end

                            local awards = response.data.awards
                            local costs = response.data.costs
                            GlobalApi:showAwardsCommon(awards,true,nil,false)
                            if awards then
			                    GlobalApi:parseAwardData(awards)
		                    end
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            self.arrow:setRotation(0)
                            self:initTop()
                            self:initLeft()
                            -- for i = 1,#self.cells do
                            --     self:updateCell(i)
                            -- end

	                    end)
                    end
                    local cost = self.costone
                    if count == 10 then
                        cost = self.costten
                    end
                    local hasCash = UserData:getUserObj():getCash()
                    if cost > hasCash then
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                            GlobalApi:getGotoByModule("cash")
                        end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                        return
                    else
                        callBack()
                    end
                    ----------------------------------


            end)
        end
    end)
    self.tenAwardBtn = tenAwardBtn

    -- 显示
    self.tenRichText = self:getRichText()
    self.tenRichText:setPosition(cc.p(tenAwardBtn:getPositionX(),tenAwardBtn:getPositionY() + 60))
    self.right:addChild(self.tenRichText)

    self.tenRichText.re3:setString(self.costten)
    self.tenRichText:format(true)

end

function RolePromoteLuckyWheel:getRichText()
    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES8'), 25, cc.c3b(110, 71, 48))
    re1:setStroke(cc.c4b(239, 219, 176, 255),1)
    re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
    local data = self.costten --self:getCostPropData()
    local re3 = xx.RichTextImage:create("uires/icon/user/cash.png")
    re3:setScale(50/80)
    
	local re2 = xx.RichTextLabel:create('', 25, cc.c3b(110, 71, 48))
    re2:setStroke(cc.c4b(239, 219, 176, 255),1)
    re2:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re3)
    richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))

    richText.re3 = re2
    return richText
end

function RolePromoteLuckyWheel:costPropCost()
    return 1
end

-- 转到通讯
function RolePromoteLuckyWheel:scrollToServer(count,page,callBack)
    self:disableBtn()
    -- 元宝消耗
    local function callBack()  
        MessageMgr:sendPost('turn_promote_wheel','activity',json.encode({time = count,ptype = page }),
	    function(response)
		    if(response.code ~= 0) then
                self:openBtn()
			    return
		    end
            self:disableBtn()

            if self.selectpage == 1 then
                self.msg.orange.score = response.data.score
                self.msg.orange.item = response.data.item
            elseif self.selectpage == 2 then
                self.msg.red.score = response.data.score
                self.msg.red.item = response.data.item
            end
            -- 开始转动
            self:scrollStart(response.data)
	    end)
    end
    local cost = self.costone
    if count == 10 then
        cost = self.costten
    end
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
function RolePromoteLuckyWheel:scrollStart(data)
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
    local endDeg = (id - 3) * 60 --+ GlobalApi:random(3, 42)
    local vec = cc.pForAngle(math.rad(90 - endDeg))
	local offset = 20
    local offset1 = 20

    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(0.33, 120)),cc.RotateBy:create(0.4,360),cc.EaseSineOut:create(cc.RotateBy:create(1, endDeg + 360 * 2)))
    --local act2 = cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(vec.x*offset, vec.y*offset)), cc.MoveBy:create(0.5,cc.p(vec.x*-offset1, vec.y*-offset1)))
    local act2 = cc.DelayTime:create(0.01)
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
            self:initTop()
            self:initLeft()
            -- for i = 1,#self.cells do
            --     self:updateCell(i)
            -- end
	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

-- 禁用按钮
function RolePromoteLuckyWheel:disableBtn()
    if self.isbigvip then
        self.countRankBtn:setTouchEnabled(false)
    end
    self.oneAwardBtn:setTouchEnabled(false)
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
    if self.closeBtn then
        self.closeBtn:setTouchEnabled(false)
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
function RolePromoteLuckyWheel:openBtn()
    if self.isbigvip then
        self.countRankBtn:setTouchEnabled(true)
    end
    self.oneAwardBtn:setTouchEnabled(true)
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
    if self.closeBtn then
        self.closeBtn:setTouchEnabled(true)
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

return RolePromoteLuckyWheel