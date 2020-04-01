local PagePrivilege = class("PagePrivilege")
local ClassItemCell = require('script/app/global/itemcell')

function PagePrivilege:init()
    self.rootBG     = self.root:getChildByName("root")
    self.tempItemCell = cc.CSLoader:createNode("csb/activity_itemcell.csb"):getChildByName("root")

    -- 点击一下这个分页叹号就消失
    UserData:getUserObj().lastVip = UserData:getUserObj().vip
    self:updateMark()

    -- bg
    local vipConf = GameData:getConfData("vip")
    local userVip = 0
    for k, v in pairs(vipConf) do
        if userVip < tonumber(k) then
            userVip = tonumber(k)
        end
    end
    local showVips = {}
    for i = 1,userVip + 1 do
        local paymentInfo = UserData:getUserObj():getPayment()
	    if paymentInfo.vip_rewards[tostring(i - 1)] ~= nil then -- 已经购买
        else
            table.insert(showVips,i - 1)
        end
    end
    self.showVips = showVips

    self.curPos = 1
    local bg = self.rootBG:getChildByName("panel")
    local img = bg:getChildByName('img')
    img:setVisible(false)

    local infoBg = bg:getChildByName('info_bg')
    infoBg:getChildByName('text'):setString(GlobalApi:getLocalStr("ACTIVITY_VIPLIMIT5"))

    local imgs = {}
    local height = 191
    local initPosX = 450
    local offset = 310
    local allPos = {}
    for i = 1,#self.showVips do
        local tempImg = img:clone()
        bg:addChild(tempImg)
        tempImg:setVisible(true)
        table.insert(imgs,tempImg)
        if #self.showVips == 1 then
            local pos = cc.p(initPosX,height)
            tempImg:setPosition(pos)
            table.insert(allPos,pos)
        elseif #self.showVips == 2 then
            if i == 1 then
                local pos = cc.p(initPosX - 204,height)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            else
                local pos = cc.p(initPosX + 204,height)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            end
        elseif #self.showVips == 3 then
            local index = i%3 + 1
            local pos = cc.p(initPosX + offset * (index - 2),height)
            tempImg:setPosition(pos)
            table.insert(allPos,pos)
        else
            if i >= #self.showVips - 1 then
                local pos = cc.p(initPosX - offset*(#self.showVips - i + 1),height)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            else
                local pos = cc.p(initPosX + offset*(i - 1),height)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            end
        end
        self:refreshItem(i,tempImg)
    end
    self.imgs = imgs
    if #self.showVips <= 0 then
        infoBg:setVisible(true)
    else
        infoBg:setVisible(false)
        local leftNum
        local rightNum
        local isNotHide
        if #self.showVips == 3 then
            leftNum = 1
            rightNum = 1
            isNotHide = true
        elseif #self.showVips > 3 then
            leftNum = 2
            rightNum = #self.showVips - 3
            isNotHide = false
        end
        if leftNum then
            GlobalApi:setCardRunRound(bg,imgs,self.curPos or 1,leftNum,rightNum,200,isNotHide,nil,{1,0.8},
            function(i)
                self.curPos = i
                self:refreshCurPos()
                self:refreshItem(self.curPos,self.imgs[self.curPos])
            end,allPos)
            self:refreshCurPos()
        end
    end
end

function PagePrivilege:refreshItem(i,img)
    local vip = self.showVips[i]
    if img.iconCells then
        for k = 1,#img.iconCells do
            local icon = img.iconCells[k]
            icon:removeFromParent()
        end
    end
    img.iconCells = {}
    local topImg = img:getChildByName('top_img')
    local topVip = topImg:getChildByName('img')

    if topImg:getChildByName('vipfnt') then
        topImg:removeChildByName('vipfnt')
    end
    local vipFnt = cc.LabelAtlas:_create(vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
    vipFnt:setName('vipfnt')
    vipFnt:setScale(1.2)     
    vipFnt:setAnchorPoint(cc.p(0, 0.5))
    topImg:addChild(vipFnt)
    if vip >= 10 then
        topVip:setPositionX(89.40 - 5)
    end
    vipFnt:setPosition(cc.p(89.40 + 10,topVip:getPositionY()))

    --
    local privilegeDatas = GameData:getConfData("vip")
    local userVip = UserData:getUserObj():getVip()
    local data = privilegeDatas[tostring(vip)]
    local price = img:getChildByName('price')
    local oriPrice = price:getChildByName('ori_price')
    oriPrice:setString(data.cost)
    local curPrice = price:getChildByName('cur_price')
    curPrice:setString(data.curPrice)

    local icon = price:getChildByName('icon')
    local iconImg = price:getChildByName('img')
    icon:setPositionX(oriPrice:getPositionX() - oriPrice:getContentSize().width/2 - 40)
    iconImg:setPositionX(oriPrice:getPositionX() - oriPrice:getContentSize().width/2 - 40)

    local icon0 = price:getChildByName('icon_0')
    icon0:setPositionX(curPrice:getPositionX() - curPrice:getContentSize().width/2 - 40)
    -- 
    local vipBtn = img:getChildByName('vip_btn')
    vipBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr("ACTIVITY_VIPLIMIT2"))
    vipBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RechargeMgr:showRecharge(vip)
	    	ActivityMgr:hideUI()
        end
    end)

    local hadFood = false
    local awardsData = DisplayData:getDisplayObjs(data.awards)
    for i = 1,#awardsData do
        if awardsData[i]:getId() == 'food' then
			hadFood = true
            break
		end
    end

    local judge = 1
    local paymentInfo = UserData:getUserObj():getPayment()
	if paymentInfo.vip_rewards[tostring(vip)] ~= nil then -- 已经购买
        judge = 1
    else
        if userVip >= vip then  -- 能购买
            judge = 2
        else    -- 充值
            judge = 3
        end
    end

    local buyBtn = img:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if judge == 2 then
                if eventType == ccui.TouchEventType.ended then
                    if hadFood == true then
                        local food = UserData:getUserObj():getFood()
                        local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                        if food >= maxFood then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                            return
                        end
                    end

                    if UserData:getUserObj():getCash() < data.curPrice then
                        promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					            GlobalApi:getGotoByModule('cash')
				            end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                        return
                    end
                    local function callBack()
                        self:refreshItem(i,img)
                    end
                    self:sendBuyGiftMessage(vip,callBack)
                end

            else
                RechargeMgr:showRecharge()
            end
        end
    end)
    local butText = buyBtn:getChildByName('info_tx')
    buyBtn:setTouchEnabled(true)
    ShaderMgr:restoreWidgetDefaultShader(buyBtn)
    butText:setColor(COLOR_TYPE.WHITE)
    butText:enableOutline(cc.c4b(165, 70, 0, 255), 1)
    if judge == 1 then
        butText:setString(GlobalApi:getLocalStr("PURCHASED"))
        buyBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(buyBtn)
        butText:setColor(COLOR_TYPE.GRAY)
        butText:enableOutline(COLOR_TYPE.BLACK)
    elseif judge == 2 then
        butText:setString(GlobalApi:getLocalStr("ACTIVITY_VIPLIMIT3"))
    else
        butText:setString(GlobalApi:getLocalStr("ACTIVITY_VIPLIMIT4"))
    end


    -- 奖励
    local awards = DisplayData:getDisplayObjs(data.awards)
    local num = #awards
    local icon1 = img:getChildByName('icon1')
    local icon2 = img:getChildByName('icon2')
    local icon3 = img:getChildByName('icon3')
    local temp = {}
    if num == 3 then
        for i = 1,6 do
            local icon = img:getChildByName('icon' .. i)
            if i ~= 4 and i ~= 5 and i ~= 6 then
                table.insert(temp,icon)
            else
                icon:setVisible(false)
            end
        end
        icon1:setPositionY(212.95)
        icon2:setPositionY(212.95)
        icon3:setPositionY(212.95)
    elseif num == 4 then
        icon1:setVisible(false)
        icon3:setVisible(false)
        for i = 1,6 do
            if i ~= 1 and i ~= 3 then
                local icon = img:getChildByName('icon' .. i)
                table.insert(temp,icon)
            end
        end
    elseif num == 5 then
        icon3:setVisible(false)
        icon1:setPositionX(105.25)
        icon2:setPositionX(195.25)
        for i = 1,6 do
            if i ~= 3 then
                local icon = img:getChildByName('icon' .. i)
                table.insert(temp,icon)
            end
        end
    else
        for i = 1,6 do
            local icon = img:getChildByName('icon' .. i)
            table.insert(temp,icon)
        end
    end

    for i = 1,num do
        local icon = temp[i]
        local award = awards[i]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, icon)
        table.insert(img.iconCells,cell.awardBgImg)
        cell.awardBgImg:setScale(0.8)
        cell.awardBgImg:setPosition(cc.p(75.2/2,75.2/2))
        cell.lvTx:setString('x'..award:getNum())
        local godId = award:getGodId()
        award:setLightEffect(cell.awardBgImg)

        local effect = cell.awardBgImg:getChildByName('chip_light')
        local size = cell.awardBgImg:getContentSize()
        if not effect and tonumber(vip) >= 6 then
            effect = GlobalApi:createLittleLossyAniByName('chip_light')
            effect:setPosition(cc.p(size.width/2,size.height/2))
            effect:getAnimation():playWithIndex(0, -1, 1)
            effect:setName('chip_light')
            cell.awardBgImg:addChild(effect)
        end
    end

end

function PagePrivilege:refreshCurPos()
    for i = 1,#self.showVips do
        local img = self.imgs[i]
        local lightImg = img:getChildByName('light_img')
        local buyBtn = img:getChildByName('buy_btn')
        local vipBtn = img:getChildByName('vip_btn')
        if i == self.curPos then
            lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
            buyBtn:setTouchEnabled(true)
            vipBtn:setTouchEnabled(true)
        else
            lightImg:stopAllActions()
            buyBtn:setTouchEnabled(false)
            vipBtn:setTouchEnabled(false)
        end

        local iconCells = img.iconCells
        for j = 1,#iconCells do
            local icon = iconCells[j]
            if i == self.curPos then
                icon:setTouchEnabled(true)
            else
                icon:setTouchEnabled(false)
            end

        end
    end
end

function PagePrivilege:updateMark()
    if UserData:getUserObj():getActivityPrivilegeShowStatus() then
        ActivityMgr:showMark("sale", true)
    else
        ActivityMgr:showMark("sale", false)
    end

end

function PagePrivilege:sendBuyGiftMessage(giftKey,callBack)
    MessageMgr:sendPost('get_vip_reward','user',json.encode({vip = tonumber(giftKey)}),function(jsonObj)
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
        local paymentInfo = UserData:getUserObj():getPayment()
        paymentInfo.vip_rewards[tostring(giftKey)] = 1
		UserData:getUserObj():setPayment(paymentInfo)

        if callBack then
            callBack()
        end
    end)
end

return PagePrivilege