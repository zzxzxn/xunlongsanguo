local LegionTrialAdventureSubPannelUI = class("LegionTrialAdventureSubPannelUI")
local ClassItemCell = require('script/app/global/itemcell')

-- 商人
function LegionTrialAdventureSubPannelUI:init(pos,serverData)
    self.rootBG = self.root:getChildByName("root")
 
    self.pos = pos
    self.serverData = serverData

    self:initLeft()
    self:initRight()
    self:refreshBuy()

end

function LegionTrialAdventureSubPannelUI:initLeft()
    local leftPanel = self.rootBG:getChildByName('leftPanel')
    local tipsBg = leftPanel:getChildByName('tipsBg')

    local tips = tipsBg:getChildByName('tips')
    tips:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC31'))

    local tips2 = tipsBg:getChildByName('tips2')
    tips2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC32'))

    local tips3 = tipsBg:getChildByName('tips3')
    tips3:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC33'))

    -- spine
    local spine = GlobalApi:createSpineByName('shop', "spine/city_building/shop", 1)
    spine:setPosition(cc.p(60,20))
    leftPanel:addChild(spine)
    spine:setAnimation(0, 'idle_in', true)
    spine:setVisible(false)

    spine:setLocalZOrder(100)
    tipsBg:setLocalZOrder(101)
end
    
function LegionTrialAdventureSubPannelUI:initRight()
    local serverData = self.serverData
    local index = serverData.index
    local data = serverData.data

    local confData = GameData:getConfData('legiontrialgoods')[data.param1][data.param2]

    local lastPrice = confData.shamCost
    local nowPrice = confData.cost
    local award = confData.award

    local disPlayData1 = DisplayData:getDisplayObjs(lastPrice)[1]
    local disPlayData2 = DisplayData:getDisplayObjs(nowPrice)[1]
    local disPlayData3 = DisplayData:getDisplayObjs(award)[1]

    local rightPanel = self.rootBG:getChildByName('panel1')
    -- 奖励品
    local awardPanel = rightPanel:getChildByName('itemPanel')
    local itemNode = awardPanel:getChildByName("node")	
    
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, disPlayData3, itemNode)
    cell.lvTx:setString('x'..disPlayData3:getNum())
    local godId = disPlayData3:getGodId()
    disPlayData3:setLightEffect(cell.awardBgImg)

    local name = awardPanel:getChildByName('name')
    name:setString(disPlayData3:getName())
    name:setColor(disPlayData3:getNameColor())
    name:enableOutline(disPlayData3:getNameOutlineColor(),1)
    name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

    --
    local buyBtn = rightPanel:getChildByName('rise_btn')
    self.buyBtn = buyBtn

    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 判断时间到了没
            local nowTime = GlobalData:getServerTime()
            if nowTime >= self.serverData.data.time then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            local function callBack2()
                local function callBack(data)
                    local awards = data.awards
				    if awards then
					    GlobalApi:parseAwardData(awards)
					    GlobalApi:showAwardsCommon(awards,nil,nil,true)
				    end
				    local costs = data.costs
				    if costs then
					    GlobalApi:parseAwardData(costs)
				    end

                    -- 刷新数据
                    self.serverData.data.award_got = 1
                    self:refreshBuy()
                    LegionTrialMgr:refreshLegionTrialAdventure(self.serverData)

                    -- 达成成就
                    LegionTrialMgr:refreshLegionTrialAchievement(data.achievement)

                end
                LegionTrialMgr:legionTrialBuyShopItemFromServer(index,callBack)
            end

            if disPlayData2:getId() == "cash" then
                UserData:getUserObj():cost('cash',disPlayData2:getNum(),function()
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),disPlayData2:getNum()), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        callBack2()
                    end)
                end)
            else    -- 金币
                local userCoin = UserData:getUserObj():getCash()
                if userCoin >= disPlayData2:getNum() then
                    callBack2()
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC40'), COLOR_TYPE.RED)
                end
            end
        end
    end)

    -- 原价
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC38'), 20, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
    local re2 = xx.RichTextImage:create(disPlayData2:getIcon())
    re2:setScale(0.4)

    local re3 = xx.RichTextLabel:create(disPlayData1:getNum(), 20,COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(buyBtn:getPositionX(),buyBtn:getPositionY() + 90))
    richText:format(true)
    rightPanel:addChild(richText)

    local xianImg = ccui.ImageView:create('uires/ui/activity/hongxian.png')
    xianImg:setScaleX(1.2)
    xianImg:setPosition(cc.p(buyBtn:getPositionX(),buyBtn:getPositionY() + 90 + 2))
    rightPanel:addChild(xianImg)

    -- 现价
    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC37'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
    local re2 = xx.RichTextImage:create(disPlayData2:getIcon())
    re2:setScale(0.5)

    local re3 = xx.RichTextLabel:create(disPlayData2:getNum(), 22,COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
	richText2:addElement(re2)
    richText2:addElement(re3)

    richText2:setAlignment('middle')
    richText2:setVerticalAlignment('middle')

	richText2:setAnchorPoint(cc.p(0.5,0.5))
	richText2:setPosition(cc.p(buyBtn:getPositionX(),buyBtn:getPositionY() + 45))
    richText2:format(true)
    rightPanel:addChild(richText2)

end

function LegionTrialAdventureSubPannelUI:refreshBuy()
    local serverData = self.serverData
    local index = serverData.index
    local data = serverData.data

    local buyBtn = self.buyBtn
    local infoTx = buyBtn:getChildByName('info_tx')

    if serverData.data.award_got == 1 then  -- 已经购买了
        buyBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(buyBtn)
        infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC42'))
        
        infoTx:setColor(COLOR_TYPE.GRAY)
        infoTx:enableOutline(COLOR_TYPE.BLACK)
    else
        ShaderMgr:restoreWidgetDefaultShader(buyBtn)
        buyBtn:setTouchEnabled(true)
        infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC41'))

        infoTx:setColor(COLOR_TYPE.WHITE)
        infoTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)
    end

end

return LegionTrialAdventureSubPannelUI