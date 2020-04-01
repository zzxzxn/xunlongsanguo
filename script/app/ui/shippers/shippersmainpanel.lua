local ShippersMainUI = class("ShippersUI", BaseUI)

local function getBiaocheSpine(type)
    local str = 'biaoche' .. type
    return str
end

local SMOKE_POS = {
    [1] = cc.p(-50, 150),
    [2] = cc.p(-50, 150),
    [3] = cc.p(-40, 150),
    [4] = cc.p(-50, 150),
    [5] = cc.p(-50, 150)
}

local CAR_POS = {
    cc.p(130, 380),
    cc.p(130, 230),
    cc.p(130, 80),
    cc.p(130, 130),
    cc.p(130, 280),
    cc.p(130, 330),
    cc.p(130, 180),
    cc.p(130, 330),
    cc.p(130, 480),
    cc.p(130, 200),
}

local TIME = 20
local function getFirePos(id)
    local x = 0
    local y = 0
    if id == 1 then
        x, y = 10 , 25
    elseif id == 2 then
        x, y = 2 , 30
    elseif id == 3 then
        x, y = -6 , 30
    elseif id == 4 then
        x, y = -16 , 33
    elseif id == 5 then
        x, y = -40 , 30
    end
    return cc.p(x,y)
end

local function getFireScale(id)
    local scale = 0
    if id == 1 or id == 2 then
        scale = 0.3
    elseif id == 3 or id == 4 then
        scale = 0.4
    elseif id == 5 then
        scale = 0.5
    end
    return scale
end

function ShippersMainUI:ctor()
	self.uiIndex = GAME_UI.UI_SHIPPERS
    self.bgPl = nil
    self.light = nil
    self.biaocheNode = {}
    self.myDeliveryTime = nil
    self.myRobTime = nil
    self.data = ShippersMgr:getMainUIData()
end

function ShippersMainUI:init()
	self.bgImg = self.root:getChildByName("shippers_bg_img")
    self:adaptUI(self.bgImg, self.bgImg)

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.bgPl = self.bgImg:getChildByName('bg_pl')
    self.bgPl:setScale(winSize.height / 768)

    local leftPl = self.bgImg:getChildByName('left_pl')
    leftPl:setPosition(cc.p(0, winSize.height - 400))
    leftPl:setLocalZOrder(999)

    local titleIco = leftPl:getChildByName('title_ico')

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.SHIPPER)
    btn:setScale(0.7)
    btn:setPosition(cc.p(titleIco:getPositionX() + titleIco:getContentSize().width/2 + 10 ,titleIco:getPositionY() - titleIco:getContentSize().height/2))
    leftPl:addChild(btn)

    local yunbiaoBtn = leftPl:getChildByName('yunbiao_btn')
    yunbiaoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			self:onClickYunbiao()
		end
	end)

	local zhanbaoBtn = leftPl:getChildByName('zhanbao_btn')
	zhanbaoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			self:onClickZhanbao()
		end
	end)

	local closeBtn = self.bgImg:getChildByName('close_btn')
	closeBtn:setPosition(cc.p(winSize.width, winSize.height))
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			ShippersMgr:hideShippersMain()
		end
	end)

	local changeBtn = self.bgImg:getChildByName('change_btn')
    local infoTx = changeBtn:getChildByName('change_tx')
    infoTx:setString(GlobalApi:getLocalStr('ARENA_CHANGE_ONCE'))
	changeBtn:setPosition(cc.p(winSize.width - 105, 55))
	changeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			self:onClickChange()
		end
	end)
    changeBtn:setLocalZOrder(1000)

    for i=1,2 do
        local infoTx = leftPl:getChildByName('info_'..i..'_tx')
        infoTx:setString(GlobalApi:getLocalStr('SHIPPER_DESC_'..i))
    end
    
	self:BgEffect()
    self:update()
end

function ShippersMainUI:BgEffect()
	-- self:BgAction1()
	-- self:BgAction2()
	self:BgAction3()
	self:BgAction4()
	-- self:BgAction5()
	-- self:BgAction6()
end

function ShippersMainUI:BgAction1()
	local yuan_1_ico = self.bgPl:getChildByName('yuan_1_img')
    yuan_1_ico:stopAllActions()
    -- local size = yuan_1_ico:getContentSize()
    local speed = 1317 / 15
    local move1 = cc.MoveTo:create(TIME, cc.p(-1317, 768))
    local fn = cc.CallFunc:create(function ()
    	yuan_1_ico:setPosition(cc.p(1317, 768))
    end)

    local move2 = cc.MoveTo:create(TIME, cc.p(0, 768))
    yuan_1_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, fn, move2)))   
end

function ShippersMainUI:BgAction2()
    local yuan_2_ico = self.bgPl:getChildByName('yuan_2_img')
    yuan_2_ico:stopAllActions()
    local speed = 1317 / 15
    local move = cc.MoveTo:create(TIME * 2, cc.p(-1317, 768))
    local fn = cc.CallFunc:create(function ()
    	yuan_2_ico:setPosition(cc.p(1317, 768))
    end)
    yuan_2_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move,fn)))   
end

function ShippersMainUI:BgAction3()
    local zhong_1_ico = self.bgPl:getChildByName('zhong_1_img')
    -- zhong_1_ico:stopAllActions()
    local size = zhong_1_ico:getContentSize()
    local speed = 1684 / 15
    local move1 = cc.MoveTo:create(TIME, cc.p(-size.width + 2, 0))
    local fn = cc.CallFunc:create(function ()
    	zhong_1_ico:setPosition(cc.p(size.width - 2, 0))
    end)

    local move2 = cc.MoveTo:create(TIME, cc.p(0, 0))
    zhong_1_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, fn, move2)))   
end

function ShippersMainUI:BgAction4()
    local zhong_2_ico = self.bgPl:getChildByName('zhong_2_img')
    -- zhong_2_ico:stopAllActions()
    local speed = 1684 / 15
    local size = zhong_2_ico:getContentSize()
    local move = cc.MoveTo:create(TIME * 2, cc.p(-size.width + 2, 0))
    local fn = cc.CallFunc:create(function ()
    	zhong_2_ico:setPosition(cc.p(size.width - 2, 0))
    end)
    zhong_2_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move,fn)))   
end

function ShippersMainUI:BgAction5()
    local jin_1_ico = self.bgPl:getChildByName('jin_1_ico')
    jin_1_ico:stopAllActions()
    local speed = 2077 / 15
    local move1 = cc.MoveTo:create(TIME, cc.p(-2077, 0))
    local fn = cc.CallFunc:create(function ()
    	jin_1_ico:setPosition(cc.p(2077, 0))
    end)

    local move2 = cc.MoveTo:create(TIME, cc.p(0, 0))
    jin_1_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, fn, move2)))   
end

function ShippersMainUI:BgAction6()
    local jin_2_ico = self.bgPl:getChildByName('jin_2_ico')
    jin_2_ico:stopAllActions()
    local speed = 2077 / 15
    local move = cc.MoveTo:create(TIME * 2, cc.p(-2077, 0))
    local fn = cc.CallFunc:create(function ()
    	jin_2_ico:setPosition(cc.p(2077, 0))
    end)
    jin_2_ico:runAction(cc.RepeatForever:create(cc.Sequence:create(move,fn)))   
end

function ShippersMainUI:update()
    self.data = ShippersMgr:getMainUIData()
    self:updateTimes()
    self:updateTopBtn()
    self:updateBtn()
    self:updateBiaoche()
end

function ShippersMainUI:updateTimes()
    local leftPl = self.bgImg:getChildByName('left_pl')

    local deliveryTx = leftPl:getChildByName('num_1_tx')
    local delivery = GlobalApi:getGlobalValue('shipperDeliveryCount') - self.data.delivery
    if delivery < 0 then
        delivery = 0
    end
    deliveryTx:setString(delivery)

    local robTx = leftPl:getChildByName('num_2_tx')
    local rob = GlobalApi:getGlobalValue('shipperRobCount') - self.data.rob
    if rob < 0 then
        rob = 0
    end
    robTx:setString(rob)
end


function ShippersMainUI:updateTopTime(img,diffTime)
    local label = img:getChildByTag(9999)
    local size = img:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setPosition(cc.p(-125, size.height/2 ))
    label:setAnchorPoint(cc.p(1,0.5))
    img:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, GlobalApi:getLocalStr('SHIPPER_PLUNDER_TIME'),COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,25,function ()
        self:updateTopBtn()
    end)
end

function ShippersMainUI:updateTopBtn()
    local speedBtn = self.bgImg:getChildByName('speed_1_btn')
    speedBtn:setLocalZOrder(999)
    speedBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('SHIPPER_CLEAR_PLUNDER_TIME'),tonumber(GlobalApi:getGlobalValue('shipperClearRobCDCash'))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                self:speedRobTime()
            end)   
        end
    end)
    speedBtn:setVisible(false)
    local serverTime = GlobalData:getServerTime()
    local finishTime = tonumber(self.data.rob_time) + tonumber(GlobalApi:getGlobalValue('shipperRobCD')) * 60
    if serverTime >= tonumber( self.data.rob_time) and serverTime <= finishTime then
        speedBtn:setVisible(true)
        self:updateTopTime(speedBtn, finishTime - serverTime)
    end
end

function ShippersMainUI:updateDeliveryTime(img,diffTime)
    local label = img:getChildByTag(9999)
    local size = img:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setPosition(cc.p(-100, size.height/2 ))
    label:setAnchorPoint(cc.p(1,0.5))
    img:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT,GlobalApi:getLocalStr('SHIPPER_REMAINDER'),COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,22,function ()
        MessageMgr:sendPost("get_reward", "shipper", "{}", function (jsonObj)
            if jsonObj.code == 0 then
                self:updateBtn()
                ShippersMgr:showShippersSuccess(tonumber(jsonObj.data.finished.type), jsonObj.data.awards)
            end
        end)  
    end)
end

function ShippersMainUI:updateBtn()
    local leftPl = self.bgImg:getChildByName('left_pl')
    local yunbiaoBtn = leftPl:getChildByName('yunbiao_btn')
    yunbiaoBtn:setVisible(true)
    local addBtn = leftPl:getChildByName('speed_2_btn')
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
            local vip = UserData:getUserObj():getVip()
            if vip < tonumber(GlobalApi:getGlobalValue('shipperSpeedVipLimit')) then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('SHIPPER_SPEED_VIP_LIMIT_DES'),tonumber(GlobalApi:getGlobalValue('shipperSpeedVipLimit'))), COLOR_TYPE.RED)
                return
            end

            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('SHIPPER_FINISH'),tonumber(GlobalApi:getGlobalValue('shipperImmediate'))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                self:speedDeliveryTime()
            end) 
        end
    end)
    addBtn:setVisible(false)
    local serverTime = GlobalData:getServerTime()
    for k, v in pairs(self.data.shippers) do
        if tonumber(v.uid) == UserData:getUserObj():getUid() then
            local finishTime = tonumber(v.time) + tonumber(GlobalApi:getGlobalValue('shipperDeliveryTime')) * 60       
            if serverTime >= tonumber(v.time) and serverTime <= finishTime then
                self:updateDeliveryTime(addBtn, finishTime - serverTime)
                yunbiaoBtn:setVisible(false)
                addBtn:setVisible(true)
            end
        end
    end
end

function ShippersMainUI:updateBiaoche()
    for i,v in pairs(self.biaocheNode) do
        if v then
            v:removeFromParent()
        end
    end
    self.biaocheNode = {}

    local i = 0
    for k,v in pairs(self.data.shippers) do
        local index
        if tonumber(v.uid) == UserData:getUserObj():getUid() then
            index = 10
        else
            i = i + 1
            index = i
        end
        local winSize = cc.Director:getInstance():getVisibleSize()
        local posx = CAR_POS[index].x + math.random(0, winSize.width - 200)
        -- local posx = CAR_POS[index].x
        self.biaocheNode[k] = cc.CSLoader:createNode("csb/biaochecell.csb")
        self.biaocheNode[k]:setPosition(cc.p(posx, CAR_POS[index].y))

        local biaochePl = self.biaocheNode[k]:getChildByName('biaoche_pl')
        biaochePl:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType ==  ccui.TouchEventType.ended then
                ShippersMgr:showShippersPlunder(tonumber(k))
            end
        end)

        local serverTime = GlobalData:getServerTime()
        local finishTime = tonumber(v.time) + tonumber(GlobalApi:getGlobalValue('shipperDeliveryTime')) * 60  
        if serverTime >= tonumber(v.time) and serverTime <= finishTime then
            self:deliveryOverTime(biaochePl, finishTime - serverTime, k)
        end

        local spineName = getBiaocheSpine(v.type)
        local spineAni = GlobalApi:createAniByName(spineName)
        spineAni:setScale(0.6)
        spineAni:setAnchorPoint(cc.p(0,0))
        spineAni:setPosition(cc.p(0, 0))
        spineAni:getAnimation():play('run', -1, 1)

        local smoke = GlobalApi:createLittleLossyAniByName("ui_biaoche_smoke")
        smoke:getAnimation():playWithIndex(0, -1, 1)
        smoke:setPosition(SMOKE_POS[tonumber(v.type)])
        biaochePl:addChild(smoke)

        if UserData:getUserObj():getUid() == tonumber(k) then
            self.light = GlobalApi:createLittleLossyAniByName("ui_shipper_select")
            self.light:getAnimation():playWithIndex(0, -1, 1)
            self.light:setVisible(false)
            self.light:setVisible(true)
            self.light:setScale(0.8)
            self.light:setPosition(cc.p(0,0))
            biaochePl:addChild(self.light)
        end

        if v.rob > 0 then
            local fire = GlobalApi:createLittleLossyAniByName("ui_biaoche_fire")
            fire:getAnimation():playWithIndex(0, -1, 1)
            fire:setPosition(getFirePos(tonumber(v.type)))
            fire:setLocalZOrder(999)
            fire:setVisible(true)
            fire:setScale(getFireScale(tonumber(v.type)))
            biaochePl:addChild(fire)
        end
       
        self.biaocheNode[k]:setLocalZOrder(999 - CAR_POS[index].y)
        biaochePl:addChild(spineAni)

        self.bgImg:addChild(self.biaocheNode[k])
        local function run()
            local posx = self.biaocheNode[k]:getPositionX()
            local beginPosx = CAR_POS[index].x + math.random(-100, 100)
            local time = math.abs(beginPosx - posx)/50 + math.random(0, 10)/10
            
            local move1 = cc.MoveTo:create(time, cc.p(beginPosx, CAR_POS[index].y))
            local fn1 = cc.CallFunc:create(function ()
                smoke:setVisible(false)
                spineAni:getAnimation():setSpeedScale(1)
            end)
            
            local diffSize = math.random(winSize.width - 320,winSize.width - 380)
            local time1 = (winSize.width - beginPosx)/500 + math.random(0, 10)/10
            local move2 = cc.MoveTo:create(time1, cc.p(winSize.width - beginPosx, CAR_POS[index].y))
            local fn2 = cc.CallFunc:create(function ()
                smoke:setVisible(true)
                spineAni:getAnimation():setSpeedScale(5)
            end)
            local fn3 = cc.CallFunc:create(function ()
                run()
            end)
            self.biaocheNode[k]:runAction(cc.Sequence:create(fn1,move1,fn2,move2,fn3))
        end
        run()
    end
end

function ShippersMainUI:deliveryOverTime(img, diffTime, k)
    local label = img:getChildByTag(9999)
    local size = img:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setPosition(cc.p(size.width/2 - 57.5,size.height/2 - 10))
    label:setAnchorPoint(cc.p(0,0.5))
    label:setVisible(false)
    img:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, nil,nil,nil,25,function ()
        if self.biaocheNode[k] then
            self.biaocheNode[k]:removeFromParent()
            self.biaocheNode[k] = nil
        end
        self.data.shippers[k] = nil
    end)
end

function ShippersMainUI:onClickYunbiao()
    local delivery = GlobalApi:getGlobalValue('shipperDeliveryCount') - self.data.delivery
    if delivery <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_NO_FREE_TIMES'), COLOR_TYPE.RED)
    else
        ShippersMgr:showShippersSelect()
    end
end

function ShippersMainUI:onClickZhanbao()
    MessageMgr:sendPost("get_report", "shipper", "{}", function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            ShippersMgr:showShippersReport(jsonObj.data)
        end
    end)
end

function ShippersMainUI:onClickChange()
	MessageMgr:sendPost("get", "shipper", "{}", function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            ShippersMgr:setMainUIData(jsonObj.data)
            self:update()
        end
    end)
end

function ShippersMainUI:speedDeliveryTime()
    -- local curCash = UserData:getUserObj():getCash()
    -- local needCash = 10
    -- if curCash < needCash then
    --     promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
    --     promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'),
    --         tonumber(GlobalApi:getGlobalValue('shipperImmediate'))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
    --         self:speedDeliveryTime()
    --     end)
    --     return
    -- end
    UserData:getUserObj():cost('cash',tonumber(GlobalApi:getGlobalValue('shipperImmediate')),function()
        MessageMgr:sendPost("delivery_immediate", "shipper", "{}", function (jsonObj)
            print(json.encode(jsonObj))
            if jsonObj.code == 0 then
                local data = jsonObj.data
                local uid = UserData:getUserObj():getUid()
                if data.costs then
                    GlobalApi:parseAwardData(data.costs)
                end
                GlobalApi:parseAwardData(jsonObj.data.awards)
                ShippersMgr:showShippersSuccess(tonumber(data.finished.type), data.awards)

                if self.biaocheNode[uid] then
                    self.biaocheNode[uid]:removeFromParent()
                    self.biaocheNode[uid] = nil
                end
                self.data.shippers[uid] = nil
                self:updateBiaoche()
                self:updateBtn()
            end
        end)
    end)
end

function ShippersMainUI:speedRobTime()
    local curCash = UserData:getUserObj():getCash()
    local needCash = 10
    if curCash < needCash then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
        return
    end
    MessageMgr:sendPost("clear_rob_cd", "shipper", "{}", function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            local data = jsonObj.data
            if data.costs then
                GlobalApi:parseAwardData(data.costs)
            end
            self.data.rob_time = 0
            self:updateTopBtn()
        end
    end)
end

return ShippersMainUI