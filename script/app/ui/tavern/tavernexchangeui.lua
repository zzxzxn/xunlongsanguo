local TavernExchangeUI = class("TavernExchangeUI", BaseUI)

function TavernExchangeUI:ctor()
	self.uiIndex = GAME_UI.UI_TAVEN_EXCHANGE_PANNEL
    self.tavernHotConf = GameData:getConfData("tavernhot")
    self.tavenLimitData = TavernMgr:getTavenLimitData()

end

function TavernExchangeUI:init()
	local bg = self.root:getChildByName('award_bg_img')
	local bg1 = bg:getChildByName('award_alpha_img')
	self:adaptUI(bg, bg1)

    local middleNode = bg1:getChildByName('middle_node')
    local titleTx = middleNode:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LUCK_EXCHANGE'))

    local cancleBtn = middleNode:getChildByName('cancle_btn')
    cancleBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('GIVE_UP_TEXT'))
	cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	TavernMgr:hideTavernExchangeUI()
        end
    end)

    local requireBtn = middleNode:getChildByName('require_btn')
    requireBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('REQUIRE_TEXT'))
    requireBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack(awards)
                TavernMgr:hideTavernExchangeUI()
                TavernMgr:showTavernAnimate(awards, function()
			    end, 4)
            end

        	TavernMgr:exchangeHot(callBack)
        end
    end)


    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(280, 40))
	local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('TAVERN_EXCHANGE_DES'),TavernMgr:exchangeCostLuckValue()), 28, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

    local heroConf = GameData:getConfData("hero")
    local data = self.tavernHotConf[self.tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)
    local roleId = awards[1]:getId()
    local heroData = heroConf[roleId]
    local heroName = heroData.heroName

	local re2 = xx.RichTextLabel:create(heroName, 28, COLOR_TYPE.RED)
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

return TavernExchangeUI