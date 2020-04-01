local LegionTrialGetAwardPannelUI = class("LegionTrialGetAwardPannelUI", BaseUI)

function LegionTrialGetAwardPannelUI:ctor(trial,curChoosePage,callBack)
    self.uiIndex = GAME_UI.UI_LEGION_TRIAL_GET_AWARD_PANNEL
    self.trial = trial
    self.curChoosePage = curChoosePage
    self.callBack = callBack
    self.legionTrialCoinIncreaSetype = GameData:getConfData('legiontrialcoinincreasetype')
end

function LegionTrialGetAwardPannelUI:init()
    local activeBgImg = self.root:getChildByName("active_bg_img")
    local activeImg = activeBgImg:getChildByName("active_img")
    self:adaptUI(activeBgImg, activeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    activeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    self.neiBgImg = activeImg:getChildByName('nei_bg_img')
    local closeBtn = activeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
        end
    end)
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC16'))

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC18'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack1(data)
                LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
                self.callBack(data)
            end
            LegionTrialMgr:legionTrialGetExploreAwardFromServer(self.curChoosePage,callBack1)
        end
    end)

    local cancleBtn = self.neiBgImg:getChildByName('cancle_btn')
    cancleBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC17'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialGetAwardPannelUI()
        end
    end)

    local awardBgImg = self.neiBgImg:getChildByName('award_bg_img')

    local round = self.trial.round
    local coins = round[tostring(self.curChoosePage)].coins
    local temp = {}
    local hasGetNum = 0
    for i = 1,9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    local rates = LegionTrialMgr:getLegionTrialAddAwardRate(temp)
    local value = 0
    if rates[tostring(4)] == 1 then
        value = 2
    else
        for i = 1,3 do
            if rates[tostring(i)] > 0 then
                local awardIncrease = self.legionTrialCoinIncreaSetype[i].awardIncrease
                value = value + rates[tostring(i)] * awardIncrease
            end
        end
    end
    local value = string.format("%.1f", value)

    local value1 = value
    if math.floor(tonumber(value)) == math.ceil(tonumber(value)) then
        value1 = math.floor(tonumber(value))
    end
    -- ±¶ÂÊ
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC8'), 26, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create(LegionTrialMgr:getLegionTrialBaseRate(), 26,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC10'), value1), 26,COLOR_TYPE.GREEN)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(awardBgImg:getContentSize().width/2,awardBgImg:getContentSize().height/2 + 20))
    richText:format(true)
    awardBgImg:addChild(richText)


    -- Öµ
    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC9'), 26, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
    local re2 = xx.RichTextImage:create('uires/ui/res/res_trial_coin.png')
    
    self.legionTrialBaseConfig = GameData:getConfData('legiontrialbaseconfig')
    local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]
    local re3 = xx.RichTextLabel:create(legionTrialBaseConfigData.coinBaseAward, 26,COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

    local coinAddAward = string.format("%.1f", legionTrialBaseConfigData.coinBaseAward * value)
    local value2 = coinAddAward
    if math.floor(tonumber(coinAddAward)) == math.ceil(tonumber(coinAddAward)) then
        value2 = math.floor(tonumber(coinAddAward))
    end

    local re4 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC10'), value2), 26,COLOR_TYPE.GREEN)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re4:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
	richText2:addElement(re2)
    richText2:addElement(re3)
    richText2:addElement(re4)

    richText2:setAlignment('middle')
    richText2:setVerticalAlignment('middle')

	richText2:setAnchorPoint(cc.p(0.5,0.5))
	richText2:setPosition(cc.p(awardBgImg:getContentSize().width/2,awardBgImg:getContentSize().height/2 - 20))
    richText2:format(true)
    awardBgImg:addChild(richText2)

end

return LegionTrialGetAwardPannelUI