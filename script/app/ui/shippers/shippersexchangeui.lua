local ShippersExchangeUI = class("ShippersExchangeUI", BaseUI)

function ShippersExchangeUI:ctor(callBack)
	self.uiIndex = GAME_UI.UI_TAVEN_EXCHANGE_PANNEL
    self.callBack = callBack
    self.data = ShippersMgr:getMainUIData()
end

function ShippersExchangeUI:init()
	local bg = self.root:getChildByName('award_bg_img')
	local bg1 = bg:getChildByName('award_alpha_img')
	self:adaptUI(bg, bg1)

    local middleNode = bg1:getChildByName('middle_node')
    local titleTx = middleNode:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('SHIPPER_INFO_8'))

    local cancleBtn = middleNode:getChildByName('cancle_btn')
    cancleBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('GIVE_UP_TEXT'))
	cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	ShippersMgr:hideShippersExchange()
        end
    end)

    local requireBtn = middleNode:getChildByName('require_btn')
    requireBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('REQUIRE_TEXT'))
    requireBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.data.type >= 5 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SHIPPER_INFO_9'), COLOR_TYPE.RED)
                ShippersMgr:hideShippersExchange()
            else
            	ShippersMgr:exchange(self.callBack,function()
                    ShippersMgr:hideShippersExchange()
                end)
            end
        end
    end)


    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(280, 40))
	local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('TAVERN_EXCHANGE_DES'),TavernMgr:exchangeCostLuckValue()), 28, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_INFO_5'), 28, COLOR_TYPE.RED)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_EXCHANGE_DES1'), 28, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(-140,35))
	middleNode:addChild(richText)
end

return ShippersExchangeUI