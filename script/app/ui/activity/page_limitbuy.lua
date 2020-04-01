local PageLimitBuy = class("PageLimitBuy")
local ClassItemCell = require('script/app/global/itemcell')

function PageLimitBuy:init(msg)
    self.rootBG     = self.root:getChildByName("root")
    self.cfg = GameData:getConfData("avlimitbuy")
	self.curItemIdx = 1
	
	--self.buyNum=GlobalApi:getGlobalValue("limitBuyBuyCount")-msg.limit_buy.buy
	--self.cutNum=GlobalApi:getGlobalValue("limitBuyCutCount")-msg.limit_buy.cut
	self.goodsList=msg.limit_buy.goods
	self.goodsNum=0
	for k,v in pairs(self.goodsList) do
		self.goodsNum=self.goodsNum+1
	end
	
    local temp = {}
    for k,v in pairs(self.goodsList) do
        local goods = v
        goods.id = tonumber(k)
        goods.sort = 1
        if self.cfg[tonumber(k)] then
            goods.sort = self.cfg[tonumber(k)].sort
        end
        table.insert(temp,goods)
    end
    table.sort(temp,function(a, b)
		return b.sort > a.sort
	end)
    self.goodsList = temp

    self.rootBG:getChildByName("panel2"):getChildByName('itemPanel'):getChildByName('desc1_0'):setString(GlobalApi:getLocalStr('REMAINDER'))
    self.rootBG:getChildByName("panel1"):getChildByName('itemPanel'):getChildByName('desc1_0'):setString(GlobalApi:getLocalStr('REMAINDER'))
    self.rootBG:getChildByName("panel1"):getChildByName('bargainBtn'):getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_PRICE'))

	local leftPanel=self.rootBG:getChildByName("leftPanel")
	self.tips=ccui.Helper:seekWidgetByName(leftPanel,"tips")
	
    local Image_3=leftPanel:getChildByName("Image_3")
    Image_3:ignoreContentAdaptWithSize(true)
    Image_3:setScale(0.8)

	self.panel1=self.rootBG:getChildByName("panel1")
	self.panel2=self.rootBG:getChildByName("panel2")
	self:changePanel(1)	
	
	local desc3=self.panel1:getChildByName("desc3")
	local strList=string.split(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS3'),'@')
	local richText = xx.RichText:create()
    desc3:addChild(richText)
    richText:setContentSize(cc.size(300, 26))
    richText:setPosition(cc.p(0,0))
    richText:setAlignment('left')
	local re1 = xx.RichTextLabel:create(strList[1], 23, cc.c4b(110,73,48,255))
	re1:setStroke(cc.c4b(255,239,209,255), 1)
	re1:clearShadow()
	local re2 = xx.RichTextLabel:create(5, 23, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re3 = xx.RichTextLabel:create(strList[2], 23, cc.c4b(110,73,48,255))
	re3:setStroke(cc.c4b(255,239,209,255), 1)
	re3:clearShadow()
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setContentSize(richText:getElementsSize())
	
	
	local bargainBtn=ccui.Helper:seekWidgetByName(self.panel1,"bargainBtn")
	bargainBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:changePanel(2)

                UserData:getUserObj().activity.limit_buy.day = tonumber(Time.getDayToModifiedServerDay())

                self:updateMark()

			end
		end)
		
	local leftBtn=ccui.Helper:seekWidgetByName(self.panel1,"leftBtn")
	leftBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:changeItem(false)
			end
		end)
		
	local rightBtn=ccui.Helper:seekWidgetByName(self.panel1,"rightBtn")
	rightBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:changeItem(true)
			end
		end)
	leftBtn:setPositionX(leftBtn:getPositionX() - 5)
    rightBtn:setPositionX(rightBtn:getPositionX() + 5)

    leftBtn:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(0.75,cc.p(5,0)),
            cc.MoveBy:create(0.75,cc.p(-5,0))
    )))
    rightBtn:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(0.75,cc.p(-5,0)),
            cc.MoveBy:create(0.75,cc.p(5,0))
    )))


	local backBtn=ccui.Helper:seekWidgetByName(self.panel2,"backBtn")
	backBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:changePanel(1)
				
			end
		end)
		
	local npc_node1 = ccui.Helper:seekWidgetByName(self.panel2,"leftNpc")
	local npc1=npc_node1:getChildByName("pic")
	local talk1=npc_node1:getChildByName("talkBg")
    talk1:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TX1'))
	local npc_node2 = ccui.Helper:seekWidgetByName(self.panel2,"rightNpc")
	local npc2=npc_node2:getChildByName("pic")
	local talk2=npc_node2:getChildByName("talkBg")
    talk2:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TX2'))
	npc1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2,10), cc.RotateBy:create(1,-10))))
	npc2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(2,10), cc.RotateBy:create(1,-10))))
	talk1:setOpacity(0)
	talk2:setOpacity(0)
	
	npc_node1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			
            local goods = self:findGoods(self.curItemIdx)
            local cut = goods.cut or 0
            local remainCutNum = self.cfg[goods.id].cutNum - cut

            if remainCutNum <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_NOT_CURNUM'), COLOR_TYPE.RED)
                return
            end

			local goods=self:findGoods(self.curItemIdx)
			MessageMgr:sendPost('cut_limit_buy','activity',json.encode({id = goods.id}),
			function(response)
				
				if response.code == 0 then
                    if goods.cut then
                        goods.cut = goods.cut + 1
                    else
                        goods.cut = 1
                    end
					self.maskPanel:setTouchEnabled(true)
					self.topPanel:setOpacity(0)
					self.topPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.3),cc.FadeIn:create(0.1)))
				
					self.ani:setVisible(true)
					self.ani:setAnimation(0, 'idle', false)
				
					talk1:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(1.5), cc.FadeOut:create(0.3)))
					
					--self.cutNum=self.cutNum-1
                    self.goodsList[self.curItemIdx].price = response.data.price
					self.cash:setString(response.data.price)
					self:updateTips(2)
				elseif response.code == 1 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_LOWSTPRICE'), COLOR_TYPE.RED)
				end
			end)
		end
	end)
		
	npc_node2:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			
            local goods = self:findGoods(self.curItemIdx)

            if self.cfg[goods.id].num - self.goodsList[self.curItemIdx].buy <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_NOT_BUYNUM'), COLOR_TYPE.RED)
                return
            end


			local function sendToServer()
				local goods=self:findGoods(self.curItemIdx)
				MessageMgr:sendPost('buy_limit_buy','activity',json.encode({id = goods.id}),
				function(response)
					
					if response.code == 0 then
						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
						end
						local costs = response.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
				
						talk2:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(1.5), cc.FadeOut:create(0.3)))
						
						--self.buyNum=self.buyNum-1
                        self.goodsList[self.curItemIdx].buy = self.goodsList[self.curItemIdx].buy + 1
						self:updateTips(2)
						self:updateItem(self.panel2, self.curItemIdx)
					elseif response.code == 1 then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_SELLEMPTY'), COLOR_TYPE.RED)
					end
				end)
			end
			local cost=tonumber(self.cash:getString())
			UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
		end
	end)
	
	self.topPanel=ccui.Helper:seekWidgetByName(self.panel2,"topPanel")
	self.topPanel:setVisible(true)
	self.maskPanel=ccui.Helper:seekWidgetByName(self.panel2,"maskPanel")
	self.maskPanel:setTouchEnabled(false)
	
	self.ani = GlobalApi:createSpineByName("ui_meirixiangou", "spine/ui_meirixiangou/ui_meirixiangou", 1)
	local effectNode = ccui.Helper:seekWidgetByName(self.panel2,"bgNode")
	--ani:setAnimation(0, 'idle', true)
	self.ani:setLocalZOrder(999)
	local size=effectNode:getContentSize()
    effectNode:addChild(self.ani)
	self.ani:setPosition(cc.p(size.width/2, -26))
	self.ani:setVisible(false)
	
	self.ani:registerSpineEventHandler(function ()
		self.maskPanel:setTouchEnabled(false)
		self.topPanel:setVisible(true)
		self.ani:setVisible(false)
	end, sp.EventType.ANIMATION_COMPLETE)
	
	self.cash=ccui.Helper:seekWidgetByName(self.topPanel,"cashText")
	
	--ActivityMgr:showRightCueResetHour()

    -- 点击一下这个分页叹号就消失
    UserData:getUserObj().activity.limit_buy.day = tonumber(Time.getDayToModifiedServerDay())

	self:updateMark()
end

function PageLimitBuy:updateMark()
    if UserData:getUserObj():getActivitLimitBuyShowStatus() then
        ActivityMgr:showMark("limit_buy", true)
    else
        ActivityMgr:showMark("limit_buy", false)
    end

end

function PageLimitBuy:findGoods(idx)
	local goods = self.goodsList[idx]
	return goods
end

function PageLimitBuy:changePanel(val)
	if val==1 then
		--self.panel1:runAction(cc.FadeIn:create(0.2))
		--self.panel2:runAction(cc.FadeOut:create(0.2))
		self.panel1:setVisible(true)
		self.panel2:setVisible(false)
		self.panel1:setTouchEnabled(true)
		self.panel2:setTouchEnabled(false)
		self:updateItem(self.panel1, self.curItemIdx)
	elseif val==2 then
		--self.panel1:runAction(cc.FadeOut:create(0.2))
		--self.panel2:runAction(cc.FadeIn:create(0.2))
		self.panel1:setVisible(false)
		self.panel2:setVisible(true)
		self.panel1:setTouchEnabled(false)
		self.panel2:setTouchEnabled(true)
		self:updateItem(self.panel2, self.curItemIdx)
		
		local goods=self:findGoods(self.curItemIdx)
		self.cash:setString(goods.price)
	end
	self:updateTips(val)
end

function PageLimitBuy:changeItem(isNext)
	local idx=self.curItemIdx
	if isNext==true then
		idx= ((idx+1) > self.goodsNum) and 1 or (idx+1)
	else
		idx= ((idx-1) <= 0) and self.goodsNum or (idx-1)
	end
	
	self:updateItem(self.panel1, idx)
end

function PageLimitBuy:updateItem(panel, val)
	if panel==nil then
		return
	end
	print("PageLimitBuy:updateItem val "..val)
	self.curItemIdx=val
		
	local itemPanel=panel:getChildByName("itemPanel")
	local itemNode=itemPanel:getChildByName("node")	
	itemNode:removeAllChildren()
	local num=itemPanel:getChildByName("num")
	local name=itemPanel:getChildByName("name")
    local desc10=itemPanel:getChildByName("desc1_0")
	num:setVisible(false)
    desc10:setVisible(false)
    
    if itemPanel:getChildByName('RichText_name') then
        itemPanel:removeChildByName('RichText_name')
    end

	local goods=self:findGoods(val)
	local item = DisplayData:getDisplayObjs(self.cfg[goods.id].award)
	if(item[1] ~= nil) then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, item[1], itemNode)
		
		tab.awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				GetWayMgr:showGetwayUI(item[1],false)
			end
		end)
		
		name:setString(item[1]:getName())
		num:setString(self.cfg[goods.id].num-goods.buy)

        local richText = xx.RichText:create()
        richText:setName('RichText_name')
	    richText:setContentSize(cc.size(500, 26))

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS4'), 23, COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
    
	    local re2 = xx.RichTextLabel:create(self.cfg[goods.id].num-goods.buy, 26,COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS5'), 23,COLOR_TYPE.ORANGE)
	    re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(50,num:getPositionY()))
        richText:format(true)
        itemPanel:addChild(richText)

	end

    self:updateTips(self.val)
end

function PageLimitBuy:updateTips(val)
    self.val = val
	self.tips:removeAllChildren()
	if val==1 then
		local richText = xx.RichText:create()
		self.tips:addChild(richText)
		richText:setContentSize(cc.size(260, 80))
		richText:setPosition(cc.p(0,0))
		richText:setAlignment('left')
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS1'), 25, COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re1:setFont('font/gamefont.ttf')
		
		richText:addElement(re1)
		richText:format(true)
		richText:setAnchorPoint(cc.p(0,1))
		richText:setContentSize(richText:getElementsSize())
	elseif val==2 then
		local strList1=string.split(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS2_1'),'@')
		local strList2=string.split(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS2_2'),'@')
		
        --[[
		local richText1 = xx.RichText:create()
		self.tips:addChild(richText1)
		richText1:setContentSize(cc.size(400, 28))
		richText1:setPosition(cc.p(0,0))
		richText1:setAlignment('left')
		local re1 = xx.RichTextLabel:create(strList1[1], 25, COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re1:setFont('font/gamefont.ttf')
		local re2 = xx.RichTextLabel:create(self.buyNum, 25, COLOR_TYPE.RED)
		re2:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re2:setFont('font/gamefont.ttf')
		local re3 = xx.RichTextLabel:create(strList1[2], 25, COLOR_TYPE.ORANGE)
		re3:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re3:setFont('font/gamefont.ttf')
		richText1:addElement(re1)
		richText1:addElement(re2)
		richText1:addElement(re3)
		richText1:format(true)
		richText1:setAnchorPoint(cc.p(0,1))
		richText1:setContentSize(richText1:getElementsSize())
		
		local richText2 = xx.RichText:create()
		self.tips:addChild(richText2)
		richText2:setContentSize(cc.size(400, 28))
		richText2:setPosition(cc.p(0,-32))
		richText2:setAlignment('left')
		local re1 = xx.RichTextLabel:create(strList2[1], 25, COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re1:setFont('font/gamefont.ttf')
		local re2 = xx.RichTextLabel:create(self.cutNum, 25, COLOR_TYPE.RED)
		re2:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re2:setFont('font/gamefont.ttf')
		local re3 = xx.RichTextLabel:create(strList2[2], 25, COLOR_TYPE.ORANGE)
		re3:setStroke(COLOROUTLINE_TYPE.DARK, 1)
		re3:setFont('font/gamefont.ttf')
		richText2:addElement(re1)
		richText2:addElement(re2)
		richText2:addElement(re3)
		richText2:format(true)
		richText2:setAnchorPoint(cc.p(0,1))
		richText2:setContentSize(richText2:getElementsSize())
        --]]

        local goods = self:findGoods(self.curItemIdx)
        local cut = goods.cut or 0
        local remainCutNum = self.cfg[goods.id].cutNum - cut

        local richText = xx.RichText:create()
        richText:setName('RichText_name')
        self.tips:addChild(richText)
	    richText:setContentSize(cc.size(250, 28))

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS6'), 25, COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.DARK, 1)
        --re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
    
	    local re2 = xx.RichTextLabel:create(remainCutNum, 26,COLOR_TYPE.RED)
	    re2:setStroke(COLOROUTLINE_TYPE.DARK, 1)
        --re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LIMITBUY_TIPS5'), 25,COLOR_TYPE.ORANGE)
	    re3:setStroke(COLOROUTLINE_TYPE.DARK, 1)
        --re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)
        richText:format(true)
	    richText:setAnchorPoint(cc.p(0,1))
        richText:setPositionX(10)
        richText:setContentSize(richText:getElementsSize())
	end
	
end

return PageLimitBuy