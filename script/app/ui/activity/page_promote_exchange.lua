local PromoteExchange = class("promote_exchange")
local ClassItemCell = require('script/app/global/itemcell')

function PromoteExchange:init(msg)
    self.rootBG = self.root:getChildByName("root")
    self.msg = msg

    self.avPromotEexchangeData = GameData:getConfData('avpromoteexchange')
    self.imgs = {}

    self:initTop()
    self:initLeft()
    self:initRight()
    self:updateMark()
end

function PromoteExchange:initTop()
    ActivityMgr:showRightPromoteExchangeRemainTime()
end

function PromoteExchange:updateMark()
    if UserData:getUserObj():getSignByType('promote_exchange') then
		ActivityMgr:showMark("promote_exchange", true)
	else
		ActivityMgr:showMark("promote_exchange", false)
	end
end

function PromoteExchange:initLeft()
    local tipsBg = self.rootBG:getChildByName('tips_bg')
    local tips1 = tipsBg:getChildByName('tips1')
    local tips2 = tipsBg:getChildByName('tips2')

    tips1:setString(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_1'))
    tips2:setString(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_2'))
end

function PromoteExchange:initRight()
    local img = self.rootBG:getChildByName('img')
    img:setVisible(false)

	local sv = self.rootBG:getChildByName('sv')
    sv:setScrollBarEnabled(false)

	local num = #self.avPromotEexchangeData
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 10

    local width = num * img:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = img:getContentSize().width
    for i = 1,num,1 do
        local cellImg = img:clone()
        cellImg:setVisible(true)
        local size = cellImg:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        cellImg:setPosition(cc.p(offset,0))
        sv:addChild(cellImg)

		cellImg.exchangeCount = 1
        local centerImg = cellImg:getChildByName('center_img')
        local nameBg = centerImg:getChildByName('name_bg')
        local editbox = cc.EditBox:create(nameBg:getContentSize(), 'uires/ui/common/touming.png')
        editbox:setName('editbox')
        editbox:setPosition(nameBg:getPosition())
        editbox:setMaxLength(10)
        editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        centerImg:addChild(editbox)
        cellImg.editbox = editbox
        self:updateItem(cellImg,i)
        table.insert(self.imgs,cellImg)
	end
end

function PromoteExchange:updateItem(img,i)
    local confData = self.avPromotEexchangeData[i]
    local lostId = confData.lostId
    local getId = confData.getId
    local scales = confData.scales
    local cash = confData.cash
    local num = confData.num
    local exchangeCount = img.exchangeCount
    local editbox = img.editbox

    -- 顶部
    local topIcon = img:getChildByName('top_icon')
    local awardData = {{'material',tostring(lostId),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]
    if topIcon:getChildByName('award_bg_img') then
        topIcon:removeChildByName('award_bg_img')
    end
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,topIcon)
    cell.awardBgImg:setScale(0.78)
    cell.awardBgImg:setPosition(cc.p(73.32/2,73.32/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    cell.lvTx:setString('x'..awards:getNum())
    cell.lvTx:setVisible(false)
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    local topName = img:getChildByName('top_name')
    topName:setString(awards:getName())
    topName:setColor(awards:getNameColor())
    topName:enableOutline(awards:getNameOutlineColor(),1)

    local topNameBg = img:getChildByName('top_name_bg')
    local topNameTx = topNameBg:getChildByName('tx')
    local lastNum = 0
    if BagData:getMaterialById(lostId) then
        lastNum = BagData:getMaterialById(lostId):getNum()
    end
    topNameTx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_3'),lastNum))
    
    -- 中间
    local centerImg = img:getChildByName('center_img')
    if centerImg:getChildByName('richText_name') then
        centerImg:removeChildByName('richText_name')
    end
    local richText = xx.RichText:create()
    richText:setName('richText_name')
	richText:setContentSize(cc.size(500, 26))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_5'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create(scales[1], 22, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_6'), 22, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create(scales[2], 22, COLOR_TYPE.GREEN)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setFont('font/gamefont.ttf')
	richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(298/2,170))
    richText:format(true)
    centerImg:addChild(richText)

    local leftIcon = centerImg:getChildByName('left_icon')
    if leftIcon:getChildByName('award_bg_img') then
        leftIcon:removeChildByName('award_bg_img')
    end
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,leftIcon)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    local leftNumTx = cell.lvTx
    leftNumTx:setPosition(cc.p(86,17))
    leftNumTx:setLocalZOrder(9999)
    leftNumTx:setScale(1.2)
    leftNumTx:setString(scales[1] * exchangeCount)
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    local rightIcon = centerImg:getChildByName('right_icon')
    local awardData = {{'material',tostring(getId),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]
    if rightIcon:getChildByName('award_bg_img') then
        rightIcon:removeChildByName('award_bg_img')
    end
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,rightIcon)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    local rightNumTx = cell.lvTx
    rightNumTx:setPosition(cc.p(86,17))
    rightNumTx:setLocalZOrder(9999)
    rightNumTx:setScale(1.2)
    rightNumTx:setString(scales[2] * exchangeCount)
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    local nameBg = centerImg:getChildByName('name_bg')
    local costNum = nameBg:getChildByName('tx')
    costNum:setString(exchangeCount)

    local hasExchangeNum = self.msg.promote_exchange[tostring(i)] or 0
    local canExchangeMaxNum1 = math.floor(lastNum/scales[1])
    local canExchangeMaxNum = num - hasExchangeNum
    if canExchangeMaxNum1 < canExchangeMaxNum then
        canExchangeMaxNum = canExchangeMaxNum1
    end

    editbox:registerScriptEditBoxHandler(function(event,pSender)
        local edit = pSender
		local strFmt 
		if event == "began" then
			editbox:setText(exchangeCount)
			costNum:setString('')
		elseif event == "ended" then
			local num = tonumber(editbox:getText())
			if not num then
				editbox:setText('')
				costNum:setString(exchangeCount)
				return
			end
            img.exchangeCount = num
            if img.exchangeCount >= canExchangeMaxNum then
                img.exchangeCount = canExchangeMaxNum
            end
            if img.exchangeCount <= 0 then
                img.exchangeCount = 1
            end
            editbox:setText('')
            self:updateItem(img,i)
		end
    end)

    local noTxt = centerImg:getChildByName('no_txt')
    
    local leftBtn = centerImg:getChildByName('left_btn')
    leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            img.exchangeCount = img.exchangeCount - 1
            if img.exchangeCount <= 0 then
                img.exchangeCount = 1
            end
            self:updateItem(img,i)
        end
    end)

    local rightBtn = centerImg:getChildByName('right_btn')
    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            img.exchangeCount = img.exchangeCount + 1
            if img.exchangeCount >= canExchangeMaxNum then
                img.exchangeCount = canExchangeMaxNum
            end
            self:updateItem(img,i)
        end
    end)
    if lastNum >= scales[1] then
        if exchangeCount <= 1 then
            ShaderMgr:setGrayForWidget(leftBtn)
            leftBtn:setTouchEnabled(false)
            ShaderMgr:restoreWidgetDefaultShader(rightBtn)
            rightBtn:setTouchEnabled(true)
        elseif exchangeCount >= canExchangeMaxNum then
            ShaderMgr:restoreWidgetDefaultShader(leftBtn)
            ShaderMgr:setGrayForWidget(rightBtn)
            leftBtn:setTouchEnabled(true)
            rightBtn:setTouchEnabled(false)
        else
            ShaderMgr:restoreWidgetDefaultShader(leftBtn)
            ShaderMgr:restoreWidgetDefaultShader(rightBtn)
            leftBtn:setTouchEnabled(true)
            rightBtn:setTouchEnabled(true)
        end
    else
        ShaderMgr:setGrayForWidget(leftBtn)
        ShaderMgr:setGrayForWidget(rightBtn)
        leftBtn:setTouchEnabled(false)
        rightBtn:setTouchEnabled(false)
    end

    if canExchangeMaxNum <= 1 then
        ShaderMgr:setGrayForWidget(leftBtn)
        ShaderMgr:setGrayForWidget(rightBtn)
        leftBtn:setTouchEnabled(false)
        rightBtn:setTouchEnabled(false)
    end

    -- 底部
    local txtCostDesc = img:getChildByName('txt_cost_desc')
    txtCostDesc:setString(string.format(GlobalApi:getLocalStr('ACTIVE_DAY_CHALLENGE_5'),num - hasExchangeNum))

    local exchangeBtn = img:getChildByName('exchange_btn')
    local exchangeBtnTx = exchangeBtn:getChildByName('tx')
    exchangeBtnTx:setString(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_4'))
    exchangeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if lastNum < scales[1] then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_7'), COLOR_TYPE.RED)
                return
            end

            if num - hasExchangeNum <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_8'), COLOR_TYPE.RED)
                return
            end

            local function callBack()
                MessageMgr:sendPost('promote_exchange','activity',json.encode({id = i,num = exchangeCount}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
                        local costs = response.data.costs
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        if costs then
				            GlobalApi:parseAwardData(costs)
			            end

                        if self.msg.promote_exchange[tostring(i)] then
                            self.msg.promote_exchange[tostring(i)] = self.msg.promote_exchange[tostring(i)] + exchangeCount
                        else
                            self.msg.promote_exchange[tostring(i)] = exchangeCount
                        end
                        img.exchangeCount = 1
                        for j = 1,#self.imgs do
                            self:updateItem(self.imgs[j],j)
                        end
		        end)
            end
            local costCash = exchangeCount * cash
            if costCash > 0 then
                local hasCash = UserData:getUserObj():getCash()
                if costCash > hasCash then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                else
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_9'),costCash),
                        MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            callBack()
                        end)
                end
            else
                callBack()
            end

        end
    end)

    local buyImg = img:getChildByName('buy_img')
    local yuanbaoImg = img:getChildByName('yuanbao_img')
    local txtCost = img:getChildByName('txt_cost')

    if cash <= 0 then
        buyImg:setVisible(false)
        yuanbaoImg:setVisible(false)
        txtCost:setVisible(false)
        txtCostDesc:setPositionY(45)
    else
        buyImg:setVisible(true)
        yuanbaoImg:setVisible(true)
        txtCost:setVisible(true)
        txtCostDesc:setPositionY(26)

        txtCost:setString(exchangeCount * cash)
    end

    if lastNum >= scales[1] then
        nameBg:setVisible(true)
        rightBtn:setVisible(true)
        leftBtn:setVisible(true)
        noTxt:setVisible(false)
        editbox:setVisible(true)
        txtCost:setTextColor(COLOR_TYPE.WHITE)
        leftNumTx:setTextColor(COLOR_TYPE.WHITE)
        rightNumTx:setTextColor(COLOR_TYPE.WHITE)
    else    -- 道具不足
        nameBg:setVisible(false)
        rightBtn:setVisible(false)
        leftBtn:setVisible(false)
        noTxt:setVisible(true)
        noTxt:setString(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_7'))
        txtCost:setTextColor(COLOR_TYPE.RED)
        leftNumTx:setTextColor(COLOR_TYPE.RED)
        rightNumTx:setTextColor(COLOR_TYPE.RED)
        editbox:setVisible(false)
    end

    if num - hasExchangeNum <= 0 then
        nameBg:setVisible(false)
        rightBtn:setVisible(false)
        leftBtn:setVisible(false)
        noTxt:setVisible(true)
        editbox:setVisible(false)
        noTxt:setString(GlobalApi:getLocalStr('ACTIVE_PROMOTE_EXCHANGE_10'))
    end
end

return PromoteExchange