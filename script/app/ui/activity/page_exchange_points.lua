local ExchangePoints = class("ExchangePoints",BaseUI)

local NORMARLBG = 'uires/ui/common/common_btn_4.png'
local PRESSBG   = 'uires/ui/common/common_btn_8.png'

local YILINGQU  = 'uires/ui/activity/yilingq.png'
local WEIDACHENG= 'uires/ui/activity/weidac.png'

local PointsExchageAwardUI = require("script/app/ui/activity/page_points_exchage_award")

function ExchangePoints:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.exchange_points = msg.exchange_points
    UserData:getUserObj().activity.exchange_points.integral = self.exchange_points.integral
    UserData:getUserObj().tips.exchange_points = 0
    UserData:getUserObj().activity.exchange_points = self.exchange_points

    self:initData()
    self:initTop()
    self:initThisTop()
    self:initBottom()

    self:updateMark()
end

function ExchangePoints:updateMark()
    if UserData:getUserObj():getSignByType('exchange_points') then
		ActivityMgr:showMark("exchange_points", true)
	else
		ActivityMgr:showMark("exchange_points", false)
	end
end

function ExchangePoints:initData()
    self.exchangePointsConf = GameData:getConfData('avexchangepoints')
    self.exchangePointsTimeConf = GameData:getConfData('avexchangepointstime')

    -- 当前轮数
    self.curRound = 1
    local nowTime = Time.getCorrectServerTime()
    for i = 1,#self.exchangePointsTimeConf do
        local data = self.exchangePointsTimeConf[i]
        local startTime = GlobalApi:convertTime(1,data.startTime)
        local endTime = GlobalApi:convertTime(1,data.endTime)
        if nowTime >= startTime and nowTime <= endTime then
            self.curRound = i
            break
        end
    end

end

function ExchangePoints:initTop()
    ActivityMgr:showRightExchangePointsRemainTime()
end

function ExchangePoints:initThisTop()
    local top = self.rootBG:getChildByName("top")
    local title = top:getChildByName("title")
    title:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES1'))

    local timeDesc = top:getChildByName("time_desc")
    timeDesc:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES2'))

    local textTime = top:getChildByName("time")
    local endTime = GlobalApi:convertTime(1,self.exchangePointsTimeConf[self.curRound].endTime)
    self:timeoutCallback(textTime,endTime)

    local exchangeBtn = self.rootBG:getChildByName("btn_exchange")
    exchangeBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES3'))
    exchangeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local pointsExchageAwardUI = PointsExchageAwardUI.new(self.exchange_points.integral,self)
			pointsExchageAwardUI:showUI()
        end
    end)

    -- 当前积分
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES4'), 26, cc.c3b(0xfe, 0xa5, 0x00))
	re1:setStroke(COLOR_TYPE.BLACK,1)
    re1:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local re2 = xx.RichTextLabel:create('', 26, COLOR_TYPE.WHITE)
	re2:setStroke(COLOR_TYPE.BLACK,1)
    re2:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

   	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

    richText:setPosition(cc.p(exchangeBtn:getPositionX(),exchangeBtn:getPositionY() + 50))
    self.rootBG:addChild(richText)

    richText.re2 = re2
    self.nowCountRichText = richText

    self:refreshCount()

end

function ExchangePoints:timeoutCallback(parent ,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - Time.getCorrectServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)	 
	node:setPosition(cc.p(0,0))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.GREEN,cc.c4b(0,0,0,255),CDTXTYPE.FRONT, nil,nil,nil,22,function ()
		if diffTime <= 0 then
			parent:removeAllChildren()
		else
			self:timeoutCallback(parent ,time)
		end
	end)
end

function ExchangePoints:refreshCount(counts)
    self.exchange_points.integral = counts or self.exchange_points.integral
    self.nowCountRichText.re2:setString(self.exchange_points.integral)
    self.nowCountRichText:format(true)
end

function ExchangePoints:initBottom()
    local bottom = self.rootBG:getChildByName('bottom')
    local title = self.rootBG:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES5'))

    local rightBottom = self.rootBG:getChildByName('right_bottom')
    self.rightBottom = rightBottom
    local sv = self.rootBG:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    self.sv = sv

    self.cell = self.rootBG:getChildByName('cell')
    self.cell:setVisible(false)

    self:refreshSv()
end

function ExchangePoints:refreshSv()
    if self.rootBG:getChildByName('scrollView_sv') then
        self.rootBG:removeChildByName('scrollView_sv')
    end
    local sv = self.sv:clone()
    sv:setVisible(true)
    sv:setName('scrollView_sv')
    self.rootBG:addChild(sv)

    local exchangePointsConf = self.exchangePointsConf
    local exchangePointsConfRound = exchangePointsConf[self.curRound]

    local temp = {}

    for k,v in pairs(exchangePointsConfRound) do
        if type(v) ~= "string" then
            table.insert(temp,v)
        end
    end

    table.sort(temp,function(a, b)
		return b.sort > a.sort
	end)
    local num = #temp

    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 18

    local width = num * self.cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local curProgress = self.exchange_points.progress

    local offset = 0
    local tempWidth = self.cell:getContentSize().width
    for i = 1,num,1 do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local confData = temp[i]

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        local nowProgress = curProgress[tostring(confData.key)] or 0

        local getStateimg = tempCell:getChildByName('get_state_img')

        local getBtn = tempCell:getChildByName('get_btn')
        local getBtnTx = getBtn:getChildByName('tx')

        local count = tempCell:getChildByName('count')
        count:setString(string.format(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES7'),confData.points))

        local progressDesc = tempCell:getChildByName('progress_desc')
        progressDesc:setString(confData.desc)

        local progress = tempCell:getChildByName('progress')
        progress:setString(string.format(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES9'),nowProgress > confData.target and confData.target or nowProgress,confData.target))

        tempCell.getStateimg = getStateimg
        tempCell.getBtn = getBtn
        tempCell.confData = confData
        tempCell.nowProgress = nowProgress
        tempCell.getBtnTx = getBtnTx
        self:refreshTempCell(i,tempCell)
    end
    innerContainer:setPositionX(0)
end

function ExchangePoints:refreshTempCell(i,tempCell)
    local stateImage = tempCell.getStateimg
    local getBtn = tempCell.getBtn
    local confData = tempCell.confData
    local nowProgress = tempCell.nowProgress
    local getBtnTx = tempCell.getBtnTx

    local state = 1
    -- 达到进度
    if nowProgress >= confData.target then
        if self.exchange_points.rewards[tostring(confData.id)] and self.exchange_points.rewards[tostring(confData.id)] == 1 then  -- 已领取
            stateImage:setVisible(true)
            getBtn:setVisible(false)
            stateImage:loadTexture(YILINGQU)
        else    -- 领取
            stateImage:setVisible(false)
            getBtn:setVisible(true)
            
            getBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES6'))
            getBtn:loadTextureNormal(NORMARLBG)
            getBtnTx:setTextColor(COLOR_TYPE.WHITE)
            getBtnTx:enableOutline(cc.c4b(165, 70, 6, 255), 1)
            state = 1
        end
    else    -- 前往
        stateImage:setVisible(false)
        getBtn:setVisible(true)

        if confData.key2 == 'cash' then
            getBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_VIPLIMIT4'))
        else
            getBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES10'))
        end
        getBtn:loadTextureNormal(PRESSBG)
        getBtnTx:setTextColor(cc.c4b(255, 253, 249, 255))
        getBtnTx:enableOutline(cc.c4b(9, 69, 121, 255), 1)

        state = 2

    end


    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if state == 1 then              
                MessageMgr:sendPost('get_exchange_points_award','activity',json.encode({id = confData.id}),
		        function(response)
			        if(response.code ~= 0) then
				        return
			        end
			        local awards = response.data.awards
			        if awards then
				        GlobalApi:parseAwardData(awards)
				        --GlobalApi:showAwardsCommon(awards,nil,nil,true)
			        end
                    self.exchange_points.integral = self.exchange_points.integral + response.data.points
                    UserData:getUserObj().activity.exchange_points.integral = self.exchange_points.integral
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES11'),response.data.points), COLOR_TYPE.WHITE)
                    -- 刷新数据
                    self.exchange_points.rewards[tostring(confData.id)] = 1
                    UserData:getUserObj().activity.exchange_points = self.exchange_points
                    -- 刷新显示
                    self:refreshTempCell(i,tempCell)
                    self:refreshCount()
                    self:judgeIsAllGet()
                    self:updateMark()

		        end)

            else
                if confData.key2 == 'citycraft' then
                    local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo(confData.key2)
                    if isOpen == true then
                        if UserData:getUserObj().country == 0 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES16'), COLOR_TYPE.RED)
                        else
                            GlobalApi:getGotoByModule(confData.key2)
                        end
                    else
                        GlobalApi:getGotoByModule(confData.key2)
                    end 
                else
                    local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo(confData.key2)
                    GlobalApi:getGotoByModule(confData.key2)
                    if isOpen == true then
                        ActivityMgr:hideUI()
                    end
                end

            end
        end
    end)

end

function ExchangePoints:judgeIsAllGet()
    local curProgress = self.exchange_points.progress
    local exchangePointsConf = self.exchangePointsConf
    local temp ={}
    for k,v in pairs(exchangePointsConf[self.curRound]) do
        if type(v) ~= "string" then
            table.insert(temp,v)
        end
    end
    local num = #temp

    local judge = false
    for i = 1,num,1 do
        local confData = temp[i]
        local nowProgress = curProgress[tostring(confData.key)] or 0
        -- 达到进度
        if nowProgress >= confData.target then
            if self.exchange_points.rewards[tostring(confData.id)] and self.exchange_points.rewards[tostring(confData.id)] == 1 then
            else
                judge = true
                break
            end
        end
    end
end

return ExchangePoints