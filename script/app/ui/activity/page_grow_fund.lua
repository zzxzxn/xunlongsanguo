local GrowFund = class("GrowFund")
local ClassItemCell = require('script/app/global/itemcell')

local NORMARLBG = 'uires/ui/common/common_btn_4.png'
local PRESSBG   = 'uires/ui/common/common_btn_8.png'

local YILINGQU  = 'uires/ui/activity/yilingq.png'
local WEIDACHENG= 'uires/ui/activity/weidac.png'

function GrowFund:init(msg)
    self.serverData = msg
    self.rootBG = self.root:getChildByName("root")

    UserData:getUserObj().activityGrowFundFirstOpen = false

    UserData:getUserObj().grow_fund_count = self.serverData.count
    UserData:getUserObj().activity.grow_fund = self.serverData.grow_fund

    if not self.serverData.grow_fund.bought_type then
        self.serverData.grow_fund.bought_type = 0
    end

    self.leftBg = self.rootBG:getChildByName("left_bg")
    self.rightBottom = self.rootBG:getChildByName("right_bottom")
    self.rightTop = self.rootBG:getChildByName("right_top")

    self:initData()
    self:initCell()
    self:initLeft()

    self:initRightTop()
    self:initRightBottom()

    self:refresh()

    self:updateMark()
end

function GrowFund:initData()
    self.conf = GameData:getConfData('avgrowfund')
    -- 1:是成长基金，2:查看奖励
    self.state = 1

    self.growFundConf = {}
    self.awardFundConf = {}
    for i = 1,#self.conf do
        local data = clone(self.conf[i])
        data.id = i
        if data.type == 0 then
            table.insert(self.growFundConf,data)
        else
            table.insert(self.awardFundConf,data)
        end
    end
end

function GrowFund:initCell()
    local cell = self.rootBG:getChildByName('cell')
    cell:setVisible(false)
    self.cell = cell

end

function GrowFund:updateMark()
    if UserData:getUserObj():getSignByType('grow_fund') then
		ActivityMgr:showMark("grow_fund", true)
	else
		ActivityMgr:showMark("grow_fund", false)
	end
end

function GrowFund:initLeft()
    local topBg = self.leftBg:getChildByName("top_bg")
    local peopleBg = topBg:getChildByName("people_bg")

    -- 已购人数:9999
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES1'), 22, cc.c3b(0x6e, 0x47, 0x30))
	re1:setStroke(cc.c4b(239, 219, 176,255),1)
    re1:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(1, 22, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(peopleBg:getContentSize().width/2,peopleBg:getContentSize().height/2 - 2))
    richText:format(true)
    peopleBg:addChild(richText)
    richText.re2 = re2

    self.hasBuyPeopleRichText = richText
    self:refrshHasBuyPeople(self.serverData.count)

    -- 购买基金
    local buyFundBtn = self.leftBg:getChildByName("buy_fund_btn")
    self.buyFundBtn = buyFundBtn
    buyFundBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local vip = 0
            local costCash = 0
            local des = ''
            if self.serverData.grow_fund.bought_type == 0 then
                vip = tonumber(GlobalApi:getGlobalValue('growFundVip'))
                costCash = tonumber(GlobalApi:getGlobalValue('growFund'))
                des = string.format(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES13'),costCash)
            else
                vip = tonumber(GlobalApi:getGlobalValue('growFundUpgradeVip'))
                costCash = tonumber(GlobalApi:getGlobalValue('growFundUpgrade'))

                local returnCash = 0
                local userLv = UserData:getUserObj():getLv()
                for i = 1,#self.growFundConf do
                    local confData = self.growFundConf[i]
                    if userLv >= confData.condition and self.serverData.grow_fund.rewards[tostring(confData.id)] and self.serverData.grow_fund.rewards[tostring(confData.id)] == 1 then
                        local awards1 = confData.awards1
                        local awards2 = confData.awards2

                        local disPlayData1 = DisplayData:getDisplayObjs(awards1)[1]
                        local disPlayData2 = DisplayData:getDisplayObjs(awards2)[1]

                        returnCash = returnCash + disPlayData2:getNum() - disPlayData1:getNum()
                    end
                end
                des = string.format(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES18'),costCash,returnCash)
            end

            -- vip等级不足
            if UserData:getUserObj():getVip() < vip then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES12'), COLOR_TYPE.RED)
                return
            end

            promptmgr:showMessageBox(des,
                MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                -- 元宝不足
                if UserData:getUserObj():getCash() < costCash then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                else -- 购买
                    MessageMgr:sendPost('buy_grow_fund','activity',json.encode({}),
		                function(response)
			                if(response.code ~= 0) then
				                return
			                end
                            if response.data.costs then
                                GlobalApi:parseAwardData(response.data.costs)
                            end

                            local awards = response.data.awards
			                if awards then
				                GlobalApi:parseAwardData(awards)
				                GlobalApi:showAwardsCommon(awards,nil,nil,true)
			                end

                            promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES14'), COLOR_TYPE.GREEN)

                            -- 刷新数据
                            self.serverData.grow_fund.bought_type = self.serverData.grow_fund.bought_type + 1
                            self.serverData.count = self.serverData.count + 1

                            UserData:getUserObj().grow_fund_count = self.serverData.count
                            UserData:getUserObj().activity.grow_fund = self.serverData.grow_fund

                            -- 刷新显示
                            self:refresh()
                            self:refrshBuyState()
                            self:refrshShowStatus()
                            self:refrshHasBuyPeople(self.serverData.count)
                            self:updateMark()
		                end)

                end
            end)

        end
    end) 

    -- 元宝消耗
    local infoBg = self.leftBg:getChildByName("info_bg")
    local costCashText = infoBg:getChildByName("num_tx")

    -- tips
    local tips = self.leftBg:getChildByName("tips")
    tips:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES3'))

    -- 成长基金按钮
    local growFundBtn = self.leftBg:getChildByName("grow_fund_btn")
    local growFundBtnTx = growFundBtn:getChildByName("func_tx")
    growFundBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES4'))
    growFundBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.state == 1 then
                return
            end
            self.state = 1
            self:refresh()
        end
    end)
    self.growFundBtn = growFundBtn
    self.growFundBtnTx = growFundBtnTx
    self.growFundBtnInfoImg = growFundBtn:getChildByName("info_img")

    -- 查看奖励按钮
    local awardFundBtn = self.leftBg:getChildByName("award_fund_btn")
    local awardFundBtnTx = awardFundBtn:getChildByName("func_tx")
    awardFundBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES5'))
    awardFundBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.state == 2 then
                return
            end
            self.state = 2
            self:refresh()
        end
    end)
    self.awardFundBtn = awardFundBtn
    self.awardFundBtnTx = awardFundBtnTx
    self.awardFundBtnInfoImg = awardFundBtn:getChildByName("info_img")

    self:refrshBuyState()
    self:refrshShowStatus()
end

function GrowFund:refrshBuyState()
    local buyFundBtn = self.buyFundBtn
    local buyFundBtnTx = buyFundBtn:getChildByName('func_tx')
    local costCash = 0

    if self.serverData.grow_fund.bought_type == 0 then   -- 未购买
        buyFundBtn:setTouchEnabled(true)
        buyFundBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES2'))
        buyFundBtnTx:setTextColor(COLOR_TYPE.WHITE)
        buyFundBtnTx:enableShadow(cc.c4b(25, 25, 25, 255), cc.size(0, -1), 0)
        buyFundBtnTx:enableOutline(cc.c4b(165, 70, 6, 255), 1)
        ShaderMgr:restoreWidgetDefaultShader(buyFundBtn)
        costCash = tonumber(GlobalApi:getGlobalValue('growFund'))
    elseif self.serverData.grow_fund.bought_type == 1 then   -- 小基金
        buyFundBtn:setTouchEnabled(true)
        buyFundBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES18'))
        buyFundBtnTx:setTextColor(COLOR_TYPE.WHITE)
        buyFundBtnTx:enableShadow(cc.c4b(25, 25, 25, 255), cc.size(0, -1), 0)
        buyFundBtnTx:enableOutline(cc.c4b(165, 70, 6, 255), 1)
        ShaderMgr:restoreWidgetDefaultShader(buyFundBtn)
        costCash = tonumber(GlobalApi:getGlobalValue('growFundUpgrade'))
    else    -- 大基金
        buyFundBtn:setTouchEnabled(false)
        buyFundBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES15'))
        ShaderMgr:setGrayForWidget(buyFundBtn)
        buyFundBtnTx:setTextColor(COLOR_TYPE.GRAY)
        buyFundBtnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        buyFundBtnTx:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
        costCash = tonumber(GlobalApi:getGlobalValue('growFundUpgrade'))
    end

    local infoBg = self.leftBg:getChildByName("info_bg")
    local costCashText = infoBg:getChildByName("num_tx")
    costCashText:setString(costCash)

end

function GrowFund:refrshHasBuyPeople(num)
    self.hasBuyPeopleRichText.re2:setString(num or 1000)
    self.hasBuyPeopleRichText:format(true)
end

function GrowFund:refrshShowStatus()
    self.growFundBtnInfoImg:setVisible(UserData:getUserObj():getActivityGrowFundAwardShowStatus())
    self.awardFundBtnInfoImg:setVisible(UserData:getUserObj():getActivityGrowFundAllAwardShowStatus())
end

function GrowFund:refresh()
    if self.state == 1 then
        self.growFundBtn:loadTextureNormal(PRESSBG)
        self.awardFundBtn:loadTextureNormal(NORMARLBG)

        self.growFundBtnTx:setTextColor(cc.c4b(255, 253, 249, 255))
        self.growFundBtnTx:enableOutline(cc.c4b(9, 69, 121, 255), 1)

        self.awardFundBtnTx:setTextColor(COLOR_TYPE.WHITE)
        self.awardFundBtnTx:enableOutline(cc.c4b(165, 70, 6, 255), 1)

        self.rightImg1:setVisible(true)
        self.rightImg3:setVisible(true)
        self.rightTopDes1:setVisible(true)
        self.rightTopDes2:setVisible(false)
        self.rightTopDes3:setVisible(false)
        self.rightImg2:setVisible(false)

        local vip = 0
        local costCash = 0
        local des = '' 
        local img = 'uires/ui/activity/1000.png'
        
        if self.serverData.grow_fund.bought_type == 0 then
            vip = tonumber(GlobalApi:getGlobalValue('growFundVip'))
            costCash = tonumber(GlobalApi:getGlobalValue('growFund'))
            des = GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES7')
            img = 'uires/ui/activity/4888.png'
            self.rightTopDes3:setVisible(true)
        else
            vip = tonumber(GlobalApi:getGlobalValue('growFundUpgradeVip'))
            costCash = tonumber(GlobalApi:getGlobalValue('growFundUpgrade'))
            des = GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES17')
            self.rightTopDes2:setVisible(true)
        end

        self.rightTopDes1.re1:setString('vip' .. vip)
        self.rightTopDes1.re3:setString(costCash)
        self.rightTopDes1.re4:setString(des)
        self.rightTopDes1:format(true)

    else
        self.growFundBtn:loadTextureNormal(NORMARLBG)
        self.awardFundBtn:loadTextureNormal(PRESSBG)

        self.awardFundBtnTx:setTextColor(cc.c4b(255, 253, 249, 255))
        self.awardFundBtnTx:enableOutline(cc.c4b(9, 69, 121, 255), 1)

        self.growFundBtnTx:setTextColor(COLOR_TYPE.WHITE)
        self.growFundBtnTx:enableOutline(cc.c4b(165, 70, 6, 255), 1)

        self.rightImg1:setVisible(false)
        self.rightImg3:setVisible(false)
        self.rightTopDes1:setVisible(false)
        self.rightTopDes2:setVisible(false)
        self.rightTopDes3:setVisible(false)
        self.rightImg2:setVisible(true)

    end
    self:refreshSv()
end

function GrowFund:initRightTop()
    self.rightImg1 = self.rightTop:getChildByName('img1')
    self.rightImg2 = self.rightTop:getChildByName('img2')
    self.rightImg3 = self.rightTop:getChildByName('img3')
    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create('vip3', 22, COLOR_TYPE.YELLOW)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES6'), 22, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(tonumber(GlobalApi:getGlobalValue('growFund')), 22, COLOR_TYPE.GREEN)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')

    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES7'), 22, COLOR_TYPE.WHITE)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(165,49))
    richText:format(true)
    self.rightTop:addChild(richText)
    richText.re1 = re1
    richText.re4 = re4
    richText.re3 = re3
    self.rightTopDes1 = richText

    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))

	local re21 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES8'), 22, COLOR_TYPE.WHITE)
	re21:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re21:setFont('font/gamefont.ttf')

    local re22 = xx.RichTextImage:create('uires/ui/activity/1000.png')

    local re23 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES9'), 22, COLOR_TYPE.WHITE)
	re23:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re23:setFont('font/gamefont.ttf')

	richText2:addElement(re21)
	richText2:addElement(re22)
    richText2:addElement(re23)

    richText2:setAlignment('left')
    richText2:setVerticalAlignment('middle')

	richText2:setAnchorPoint(cc.p(0,0.5))
	richText2:setPosition(cc.p(165,18)) 
    richText2:format(true)
    self.rightTop:addChild(richText2)
    self.rightTopDes2 = richText2

    local richText3 = xx.RichText:create()
	richText3:setContentSize(cc.size(500, 40))

	local re31 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES8'), 22, COLOR_TYPE.WHITE)
	re31:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re31:setFont('font/gamefont.ttf')

    local re32 = xx.RichTextImage:create('uires/ui/activity/4888.png')

    local re33 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES9'), 22, COLOR_TYPE.WHITE)
	re33:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re33:setFont('font/gamefont.ttf')

	richText3:addElement(re31)
	richText3:addElement(re32)
    richText3:addElement(re33)

    richText3:setAlignment('left')
    richText3:setVerticalAlignment('middle')

	richText3:setAnchorPoint(cc.p(0,0.5))
	richText3:setPosition(cc.p(165,18)) 
    richText3:format(true)
    self.rightTop:addChild(richText3)
    self.rightTopDes3 = richText3
end

function GrowFund:initRightBottom()
    local sv = self.rightBottom:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    self.sv = sv
end

function GrowFund:refreshSv()
    if self.rightBottom:getChildByName('scrollView_sv') then
        self.rightBottom:removeChildByName('scrollView_sv')
    end
    local sv = self.sv:clone()
    sv:setVisible(true)
    sv:setName('scrollView_sv')
    self.rightBottom:addChild(sv)

    local conf
    if self.state == 1 then
        conf = self.growFundConf
    else
        conf = self.awardFundConf
    end

    local num = #conf
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

    local offset = 0
    local tempWidth = self.cell:getContentSize().width
    for i = 1,num,1 do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local confData = conf[i]

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)
        -- 状态
        local bg = tempCell:getChildByName('bg')
        local getBtn = bg:getChildByName('one_award_btn')
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
        local stateImage = bg:getChildByName('get_state_img')
        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                if self.state == 1 then
                    if self.serverData.grow_fund.bought_type == 0 then              
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES17'), COLOR_TYPE.RED)
                        return
                    end
                end

                MessageMgr:sendPost('get_grow_fund_award','activity',json.encode({id = confData.id}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        
                        -- 刷新数据
                        self.serverData.grow_fund.rewards[tostring(confData.id)] = 1
                        
                        UserData:getUserObj().grow_fund_count = self.serverData.count
                        UserData:getUserObj().activity.grow_fund = self.serverData.grow_fund

                        -- 刷新显示
                        sender.callBack()
                        self:refrshShowStatus()
                        self:updateMark()

		            end)
            end
        end)

        -- 标题
        local titleBg = tempCell:getChildByName('title_bg')
        if self.state == 1 then
            -- 君主等级25
            local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(500, 40))

	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES10') .. confData.condition, 25, cc.c4b(254,185,2,255))
	        re1:setStroke(cc.c4b(78,49,17,255),1)
            re1:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')

	        richText:addElement(re1)

            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0.5,0.5))
	        richText:setPosition(cc.p(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2 - 5))
            richText:format(true)
            titleBg:addChild(richText)

        else
            local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(500, 40))

	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES11'), 25, COLOR_TYPE.YELLOW)
	        re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re1:setFont('font/gamefont.ttf')

            local re2 = xx.RichTextLabel:create(confData.condition, 25, COLOR_TYPE.WHITE)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
            richText:addElement(re2)

            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0.5,0.5))
	        richText:setPosition(cc.p(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2 - 5))
            richText:format(true)
            titleBg:addChild(richText)

        end

        
        local function callBack()
            -- 条件
            local condition = confData.condition
            local userLv = UserData:getUserObj():getLv()
            if self.state == 1 then
                if self.serverData.grow_fund.bought_type > 0 then  -- 已购买
                    if userLv >= condition then -- 是否达成
                        if self.serverData.grow_fund.rewards[tostring(confData.id)] and self.serverData.grow_fund.rewards[tostring(confData.id)] == 1 then  -- 已领取
                            stateImage:setVisible(true)
                            getBtn:setVisible(false)
                            stateImage:loadTexture(YILINGQU)
                        else    -- 未领取状态
                            stateImage:setVisible(false)
                            getBtn:setVisible(true)
                            getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))                       
                        end
                    else
                        stateImage:setVisible(true)
                        getBtn:setVisible(false)
                        stateImage:loadTexture(WEIDACHENG)
                    end

                else
                    stateImage:setVisible(false)
                    getBtn:setVisible(true)
                    getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVE_GORW_FUND_DES16'))
                end

            else
                if self.serverData.count >= condition then
                    if self.serverData.grow_fund.rewards[tostring(confData.id)] and self.serverData.grow_fund.rewards[tostring(confData.id)] == 1 then  -- 已领取
                        stateImage:setVisible(true)
                        getBtn:setVisible(false)
                        stateImage:loadTexture(YILINGQU)
                    else
                        stateImage:setVisible(false)
                        getBtn:setVisible(true)
                    end
                else
                    stateImage:setVisible(true)
                    getBtn:setVisible(false)
                    stateImage:loadTexture(WEIDACHENG)
                end
            end
        end
        getBtn.callBack = callBack
        callBack()

        -- icon
        local icon1 = bg:getChildByName('icon1')
        local icon2 = bg:getChildByName('icon2')
        local icon3 = bg:getChildByName('icon3')
        -- 看奖励品的数目来决定显示情况
        local awardData = confData.awards1
        if self.serverData.grow_fund.bought_type <= 1 then
            awardData = confData.awards1
        else
            awardData = confData.awards2
        end
        
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awardNum = #disPlayData
        if awardNum == 1 then
            icon3:setVisible(true)
            icon1:setVisible(false)
            icon2:setVisible(false)

            local awards = disPlayData[1]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon3)
            cell.awardBgImg:setScale(66/94)
            cell.awardBgImg:setPosition(cc.p(94 - 66 + 5,94 - 66 + 2))
            cell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        else
            icon3:setVisible(false)
            icon1:setVisible(true)
            icon2:setVisible(true)

            for i = 1,2 do
                local awards = disPlayData[1]
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, bg:getChildByName('icon' .. i))
                cell.awardBgImg:setScale(66/94)
                cell.awardBgImg:setPosition(cc.p(94 - 66 + 5,94 - 66 + 2))
                cell.lvTx:setString('x'..awards:getNum())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            end

        end

    end
    innerContainer:setPositionX(0)

end

return GrowFund