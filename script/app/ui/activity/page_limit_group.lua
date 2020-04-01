local LimitGroup = class("LimitGroup")
local ClassSellTips = require('script/app/ui/tips/selltips')
local ClassItemCell = require('script/app/global/itemcell')

function LimitGroup:init(msg)
    self.rootBG = self.root:getChildByName("root")

    -- 折扣图片
    self.imgDiscount = self.rootBG:getChildByName("img_discount")
    self.imgDiscount:setVisible(false)

    UserData:getUserObj().activity.limit_group.day = msg.limit_group.day
    self.msg = msg

    self:initData()

    local rightBg = self.rootBG:getChildByName("right_bg")
    local cell2 = rightBg:getChildByName('cell2')   
    local leftBtn = cell2:getChildByName('left_btn')
    local rightBtn = cell2:getChildByName('right_btn')
    self.leftBtn = leftBtn
    self.rightBtn = rightBtn

    self:initTop()
    self:initLeft()
    self:initRight()


     
    leftBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.curChooseIndex == 1 then
                return
            end
            local curId = self.curChooseIndex - 1
            if curId < self.curSmallId then
                self.curSmallId = self.curSmallId - 1
                self.curBigId = self.curBigId - 1  
                self:refreshSv()                          
            end
            self:refreshChooseId(curId)
        end
    end)

    rightBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local curId = self.curChooseIndex + 1
            if curId > self.allNum then
                return
            end
            if curId > self.curBigId then
                self.curSmallId = self.curSmallId + 1
                self.curBigId = self.curBigId + 1     
                self:refreshSv()                       
            end
            self:refreshChooseId(curId)
        end
    end)

    self:updateMark()
end

function LimitGroup:updateMark()
    if UserData:getUserObj():getSignByType('limit_group') then
		ActivityMgr:showMark("limit_group", true)
	else
		ActivityMgr:showMark("limit_group", false)
	end
end

function LimitGroup:initData()
    self.avLimitGroup = {}

    local avLimitGroup = GameData:getConfData('avlimitgroup')
    for k,v in pairs(avLimitGroup) do
        if v.sell == 1 then
            table.insert(self.avLimitGroup,v)
        end
    end

    table.sort(self.avLimitGroup, function (a, b) return a.id < b.id end)

    self.curChooseIndex = 1
    --self.cut = 10   -- 当前的折扣是多少折
    self.propCell = {}

    self.allNum = #self.avLimitGroup
    self.num = 5
    
    self.curSmallId = 1
    self.curBigId = self.curSmallId + self.num - 1
end

function LimitGroup:initTop()
    ActivityMgr:showRightLimitGroupRemainTime()
    ActivityMgr:showLeftLimitGroupCue(self:getAllReturnCash())
end

function LimitGroup:initLeft()
    local leftBg = self.rootBG:getChildByName("left_bg")
    local image = leftBg:getChildByName("image")
    image:ignoreContentAdaptWithSize(true)
    image:setScale(0.8)

    leftBg:getChildByName('tips1'):setString(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES4'))
end

function LimitGroup:initRight()
    self:refreshRightTop()
    self:refreshSv()
end

function LimitGroup:refreshRightTop()
    local rightBg = self.rootBG:getChildByName("right_bg")
    local chooseData = self.avLimitGroup[self.curChooseIndex]
    local hasNum = self:getHasBuyNum(chooseData.id)

    -- 已购买，富文本
    if not self.hasBuyCount then
        local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 40))

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES5'), 21, COLOR_TYPE.WHITE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create('', 21, cc.c3b(0xfe, 0xa5, 0x00))
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES6'), 21, COLOR_TYPE.WHITE)
	    re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(19,225))
        rightBg:addChild(richText)

        self.hasBuyCount = richText
        self.re2 = re2
    end
    self.re2:setString(hasNum)
    self.hasBuyCount:format(true)

    -- 进度条,百分比等候来设置
    local expBar = rightBg:getChildByName("exp_bar")
    expBar:setScale9Enabled(true)
    expBar:setCapInsets(cc.rect(10,15,1,1))

    local allNum = 9999
    for i = 1,5 do
        local people = rightBg:getChildByName('people' .. i)
        if people then
            local requireNum = chooseData['require' .. i] or 9999
            people:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES13'),requireNum))
        end

        local discount = rightBg:getChildByName('discount' .. i)
        if i == 1 then
            discount:setVisible(false)
        end
        if discount then
            local cutNum = chooseData['cut' .. i] or 10
            discount:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES7'),cutNum))
        end

        if i == 5 then
            allNum = chooseData['require' .. i] or 9999
        end
    end

    local posInit = 40
    local allWidth = 608
    for i = 2,4 do
        local requireNum = chooseData['require' .. i]
        local people = rightBg:getChildByName('people' .. i)
        local discount = rightBg:getChildByName('discount' .. i)
        local per = requireNum/allNum
        people:setPositionX(posInit + allWidth * per)
        discount:setPositionX(posInit + allWidth * per)
    end

    local percent
    if hasNum >= allNum then
        percent = 100
    else
        percent = hasNum/allNum * 100
    end
    expBar:setPercent(percent)

    -- cell1里面的
    local cell1 = rightBg:getChildByName("cell1")
    local icon = cell1:getChildByName("icon")

    if icon:getChildByName('award_bg_img') then
        icon:removeChildByName('award_bg_img')
    end

    local disPlayData = DisplayData:getDisplayObjs(chooseData['goods'])
    local awards = disPlayData[1]
    if awards then       
        local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        awardCell.awardBgImg:setPosition(cc.p(47,47))
        awardCell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(awardCell.awardBgImg)

        local name = cell1:getChildByName("name")
        name:setString(awards:getName())
        name:enableOutline(awards:getNameOutlineColor(),1)
        name:setTextColor(awards:getNameColor())
        name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        -- 打折显示
        local imgDiscount = self.imgDiscount:clone()
        awardCell.awardBgImg:addChild(imgDiscount)
        imgDiscount:setVisible(true)
        local cut,cutPrice = self:getCutById(self.curChooseIndex)
        imgDiscount:getChildByName('price'):setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES6'),cut))
        imgDiscount:setPosition(cc.p(-14.88,40))
    end


    local costCash = cell1:getChildByName("cost_cash")
    costCash:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES8'),chooseData['oriPrice']))
    local cash1 = cell1:getChildByName("cash1")
    cash1:setPositionX(costCash:getPositionX() + costCash:getContentSize().width + 5)

    local returnCash = cell1:getChildByName("return_cash")
    local cut,cutPrice = self:getCutById(self.curChooseIndex)
    returnCash:setString(chooseData['oriPrice'] - cutPrice)
    local cash2 = cell1:getChildByName("cash2")
    cash2:setPositionX(returnCash:getPositionX() + returnCash:getContentSize().width + 5)

    -- 购买按钮
    local buyBtn = cell1:getChildByName("buy_btn")
    buyBtn:getChildByName("tx"):setString(GlobalApi:getLocalStr('BUY'))

    buyBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            local hasBuy = self.msg.limit_group.buy[tostring(chooseData.id)] or 0
            if hasBuy >= chooseData['buy'] then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES10'), COLOR_TYPE.RED)
                return
            end
            local awardData = DisplayData:getDisplayObjs(chooseData['goods'])
            local tab = {}
            tab.icon = 'uires/ui/res/res_cash.png'
            tab.num = UserData:getUserObj():getCash()   -- 拥有的元宝数
            tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
            tab.id = 'cash'
            tab.costNum = chooseData['oriPrice']     -- 单价
            tab.confId = nil
            tab.sellNum = 1     -- 这个暂时好像没用
                                
            local hasBuyCount = self.msg.limit_group.buy[tostring(chooseData.id)] or 0

            self:showTips(awardData[1],tab,nil,function(callback,num,cash)
                if callback then
                    callback()
                end
                if num == 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES12'), COLOR_TYPE.RED)
                else
                    self:buyProp(chooseData.id,num,cash)
                end
                
            end,nil,chooseData['buy'] - hasBuyCount,'show_at_limit_group')

        end
    end)

    local buyDes = cell1:getChildByName("buy_des")
    local hasBuy = self.msg.limit_group.buy[tostring(chooseData.id)] or 0
    buyDes:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES9'),hasBuy,chooseData['buy']))


    self.leftBtn:setVisible(true)
    self.leftBtn:setTouchEnabled(true)

    self.rightBtn:setVisible(true)
    self.rightBtn:setTouchEnabled(true)

    self.leftBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.1),
        cc.ScaleTo:create(0.3, 1))
    ))
    
    self.rightBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.1),
        cc.ScaleTo:create(0.3, 1))
    ))

    ShaderMgr:restoreWidgetDefaultShader(self.leftBtn)
    ShaderMgr:restoreWidgetDefaultShader(self.rightBtn)

    if self.curChooseIndex == 1 then
        self.leftBtn:setTouchEnabled(false)
        self.leftBtn:stopAllActions()
        ShaderMgr:setGrayForWidget(self.leftBtn)
    elseif self.curChooseIndex == self.allNum then
        self.rightBtn:setTouchEnabled(false)
        self.rightBtn:stopAllActions()
        ShaderMgr:setGrayForWidget(self.rightBtn)
    end

end

-- 根据id得到折扣和折扣价格
function LimitGroup:getCutById(index)
    local data = self.avLimitGroup[index]
    local hasNum = self:getHasBuyNum(data.id)
    local cut = 10
    local cutPrice = data['price1']
    for i = 5,1,-1 do
        local requireNum = data['require' .. i]
        if hasNum >= requireNum then
            cut = data['cut' .. i]
            cutPrice = data['price' .. i]
            break
        end
    end
    return cut,cutPrice
end

function LimitGroup:refreshSv()
    self.propCell = {}

    local rightBg = self.rootBG:getChildByName("right_bg")
    local avLimitGroup = self.avLimitGroup

    local cell2 = rightBg:getChildByName('cell2')   
    -- 道具
    local index = self.curSmallId 
    for i = 1,5 do
        local data = avLimitGroup[index]
        local disPlayData = DisplayData:getDisplayObjs(data['goods'])
        local awards = disPlayData[1]

        local icon = cell2:getChildByName('icon' .. i)
        icon.img_light = icon:getChildByName('img_light')
        icon.img_light:loadTexture('uires/ui/activity/xuanzhongkuang.png')
        icon.img_light:setScale(0.65)
        icon.img_light:setLocalZOrder(10000)
        icon.id = index

        if icon:getChildByName('award_bg_img') then
            icon:removeChildByName('award_bg_img')
        end

        if awards and icon then
            local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
            awardCell.awardBgImg:setPosition(cc.p(47,47))
            awardCell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(awardCell.awardBgImg)

            -- 打折显示
            local imgDiscount = self.imgDiscount:clone()
            awardCell.awardBgImg:addChild(imgDiscount)
            imgDiscount:setVisible(true)
            local cut,cutPrice = self:getCutById(index)
            imgDiscount:getChildByName('price'):setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES6'),cut))
            imgDiscount:setPosition(cc.p(-14.88,40))

            awardCell.awardBgImg.id = index
            awardCell.awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
			        AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if sender.id == self.curChooseIndex then 
                        return
                    end
                    --print('+++++++++++++++++++++++' .. sender.id)                
                    self:refreshChooseId(sender.id)
                end
            end)
            table.insert(self.propCell,icon)
        end

        if index == self.curChooseIndex then
            icon.img_light:setVisible(true)
        else
            icon.img_light:setVisible(false)
        end
        index = index + 1
    end

end

function LimitGroup:refreshChooseId(id)
    self.curChooseIndex = id or 1
    for i = 1,#self.propCell do
        local cell = self.propCell[i] 
        if cell.id == id then
            cell.img_light:setVisible(true)
        else
            cell.img_light:setVisible(false)           
        end
    end
    self:refreshRightTop()

end


function LimitGroup:buyProp(id,num,cost)
    local num = num or 1
    local function sendToServer()
		MessageMgr:sendPost('buy_limit_group','activity',json.encode({id = id,num = num}),
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

            local allBuy = self.msg.all_buy
            local buy = self.msg.limit_group.buy
            if buy[tostring(id)] then
                self.msg.limit_group.buy[tostring(id)] = buy[tostring(id)] + num
            else
                self.msg.limit_group.buy[tostring(id)] = num
            end

            if allBuy[tostring(id)] then
                self.msg.all_buy[tostring(id)] = allBuy[tostring(id)] + num
            else
                self.msg.all_buy[tostring(id)] = num
            end

            if self.msg.self_buy[tostring(id)] then
                self.msg.self_buy[tostring(id)] = self.msg.self_buy[tostring(id)] + num
            else
                self.msg.self_buy[tostring(id)] = num
            end

            self:refreshRightTop()
            self:refreshSv()
            ActivityMgr:showLeftLimitGroupCue(self:getAllReturnCash())
            
		end)
	end
	UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
end

function LimitGroup:getAllReturnCash()
    local avLimitGroup = self.avLimitGroup
    local allCost = 0
    local buy = self.msg.self_buy
    for k,v in pairs(buy) do
        local hasBuyNum = tonumber(v)
        for i,m in pairs(avLimitGroup) do
            if tonumber(m.id) == tonumber(k) then
                local oriPrice = avLimitGroup[tonumber(i)]['oriPrice']
                local cut,cutPrice = self:getCutById(tonumber(i))
                allCost = allCost + (oriPrice - cutPrice) * hasBuyNum
                break
            end
        end
    end
    return allCost
end

-- 得到"全服"已经购买多少件,根据id去读取
function LimitGroup:getHasBuyNum(id)
    local allBuy = self.msg.all_buy
    local allNum = allBuy[tostring(id)] or 0
    return allNum
end

function LimitGroup:showTips(award,tab,status,callback,sidebarList,num,showType)
    local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num,showType)
    sellTipsUI:showUI()
end

return LimitGroup