local RoleExchangeUI = class("RoleExchangeUI", BaseUI)

function RoleExchangeUI:ctor(callback)
	self.uiIndex = GAME_UI.UI_ROLEEXCHANGE
	self.callback = callback
end

function RoleExchangeUI:init()
	local bgImg = self.root:getChildByName("exchange_bg_img")
	local exchangeImg = bgImg:getChildByName("exchange_img")
	local cancelBtn = exchangeImg:getChildByName("cancel_btn")
	local infoTx = cancelBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_CANCEL'))
	local okBtn = exchangeImg:getChildByName("ok_btn")
	infoTx = okBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_OK'))
    self:adaptUI(bgImg, exchangeImg)
    local titletx = exchangeImg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('EXCHANGEROLE'))
	cancelBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
	    end
	end)
	okBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
			if self.callback then
				self.callback()
			end
	    end
	end)
	local closebtn = exchangeImg:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleExchange()
	    end
	end)	

	local x,y = 140,440
	local tx = GlobalApi:getLocalStr('STR_PERCENT_100')
    for i=1,6 do
		local richText = xx.RichText:create()
	    local tx1 = '   '..GlobalApi:getLocalStr('EXCHANGE_ROLE_DESC_'..i)
	    -- local re1 = ccui.RichElementText:create(1, COLOR_TYPE.GREEN, 255, tx, "font/gamefont.ttf", 25,false,true,COLOROUTLINE_TYPE.GREEN,2)
	    -- local re2 = ccui.RichElementText:create(1, COLOR_TYPE.YELLOW, 255, tx1, "font/gamefont.ttf", 25,false,true,COLOROUTLINE_TYPE.YELLOW,2)
	    local re1  = xx.RichTextLabel:create(tx,25, COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	   	local re2  = xx.RichTextLabel:create(tx1,25, COLOR_TYPE.ORANGE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    --richText:formatText()
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(10 ,y - (i)*47.5))
	    exchangeImg:addChild(richText)
    end
end

return RoleExchangeUI