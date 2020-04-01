local PageMoonCard = class("PageMoonCard")

function PageMoonCard:init()
    self.rootBG     = self.root:getChildByName("root")
    --self.scrollView = self.rootBG:getChildByName("scrollView")
	for i=1,4 do
		local bg = self.rootBG:getChildByName('tips'..i)
		bg:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_TIPS'..i))		
	end
	
	self.leftPic1=self.rootBG:getChildByName('leftPic1')
	self.leftPic1:loadTexture("uires/ui/activity/yuela2.png")
	self.leftPic2=self.rootBG:getChildByName('leftPic2')
	
	self.leftPic1:setLocalZOrder(10)
	self.leftPic2:setLocalZOrder(5)
	
	self.leftPic1:addClickEventListener(function ()
			print("leftPic1 click")
			AudioMgr.PlayAudio(11)
			self:FlipCard(self.leftPic1, self.leftPic2)
	end)
	
	self.leftPic2:addClickEventListener(function ()
			print("leftPic2 click")
			AudioMgr.PlayAudio(11)
			self:FlipCard(self.leftPic2, self.leftPic1)
	end)			
	
	self.rightPic1=self.rootBG:getChildByName('rightPic1')
	self.rightPic2=self.rootBG:getChildByName('rightPic2')
	
	self.rightPic1:setLocalZOrder(10)
	self.rightPic2:setLocalZOrder(5)	
	
	self.rightPic1:addClickEventListener(function ()
			print("rightPic1 click")
			AudioMgr.PlayAudio(11)
			self:FlipCard(self.rightPic1, self.rightPic2)
	end)
	
	self.rightPic2:addClickEventListener(function ()
			print("rightPic2 click")
			AudioMgr.PlayAudio(11)
			self:FlipCard(self.rightPic2, self.rightPic1)
	end)
	
	local paymentInfo = UserData:getUserObj():getPayment()
	
	self.buyBtn1=self.rootBG:getChildByName('buy_btn1')
	local tx1=self.buyBtn1:getChildByName('tx')
	tx1:setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_BUYBTN1'))
	self.buyBtn1:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:SendBuyCardMsg()
			end
		end)
	if paymentInfo.month_card>0 then
		ShaderMgr:setGrayForWidget(self.buyBtn1)
		tx1:setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_BUYBTN2'))
        tx1:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.buyBtn1:setTouchEnabled(false)
	end
	
	
	self.buyBtn2=self.rootBG:getChildByName('buy_btn2')
	local tx2=self.buyBtn2:getChildByName('tx')
	tx2:setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_BUYBTN1'))
	self.buyBtn2:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:SendBuyCardMsg()
			end
		end)

	if paymentInfo.long_card>0 then
		ShaderMgr:setGrayForWidget(self.buyBtn2)
		tx2:setString(GlobalApi:getLocalStr('ACTIVITY_MOONCARD_BUYBTN2'))
        tx2:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.buyBtn2:setTouchEnabled(false)
	end
	
	local desc1=self.leftPic2:getChildByName('desc')
	desc1:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_MOONCARD_DESC1"), '\n', '\n', '\n', '\n'))
	local name1=self.leftPic2:getChildByName('name')
	name1:setString(UserData:getUserObj():getName())
	local desc2=self.rightPic2:getChildByName('desc')
	desc2:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_MOONCARD_DESC2"), '\n', '\n', '\n', '\n'))
	local name2=self.rightPic2:getChildByName('name')
	name2:setString(UserData:getUserObj():getName())
	
	ActivityMgr:showMark("mooncard", false)
end

function PageMoonCard:FlipCard(pic1, pic2)
	local flipTime=1
	local act1=cc.CallFunc:create(
		function ()
			pic1:setVisible(true)
			pic2:setVisible(false)
			pic1:setTouchEnabled(false)
			pic2:setTouchEnabled(false)
			--pic1:setLocalZOrder(10)
			--pic2:setLocalZOrder(5)
			pic1:setScaleX(1)
			pic2:setScaleX(-1)
			pic1:runAction(cc.OrbitCamera:create(flipTime, 1, 0, 0, 180, 0, 0))
			pic2:runAction(cc.OrbitCamera:create(flipTime, 1, 0, 0, -180, 0, 0))
		end)
	local act2=cc.DelayTime:create(flipTime/2)
	local act3=cc.CallFunc:create(
		function ()
			pic1:setVisible(false)
			pic2:setVisible(true)
			--pic1:setLocalZOrder(5)
			--pic2:setLocalZOrder(10)
			pic1:setTouchEnabled(true)
			pic2:setTouchEnabled(true)
		end)
				
	self.rootBG:runAction(cc.Sequence:create(act1, act2, act3))
end

function PageMoonCard:SendBuyCardMsg()
	RechargeMgr:showRecharge()
end

return PageMoonCard