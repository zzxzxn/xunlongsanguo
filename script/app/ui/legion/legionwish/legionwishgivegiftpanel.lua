local LegionWishGiveGiftPanelUI = class("LegionWishGiveGiftPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionWishGiveGiftPanelUI:ctor(wishData,callBack)
	self.uiIndex = GAME_UI.UI_LEGION_WISH_GIVE_GIFT
    self.wishData = wishData
    self.callBack = callBack
end

function LegionWishGiveGiftPanelUI:init()
    local activeBgImg = self.root:getChildByName("active_bg_img")
    local activeImg = activeBgImg:getChildByName("active_img")
    self:adaptUI(activeBgImg, activeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    activeImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    -- Êý¾Ý
    local progressData = self.wishData.data[tostring(1)]
    local fragmentId = progressData.fragment
    local awardData = {{'fragment',tostring(fragmentId),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]

    local titleTx = activeImg:getChildByName('title_tx')
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WISH_DESC16'), 24, COLOR_TYPE.WHITE)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(progressData.name, 24,COLOR_TYPE.ORANGE)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WISH_DESC17'), 24,COLOR_TYPE.WHITE)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(titleTx:getPositionX(),titleTx:getPositionY() - 4))
    richText:format(true)
    activeImg:addChild(richText)


    self.neiBgImg = activeImg:getChildByName('nei_bg_img')
    local closeBtn = activeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hidLlegionWishGiveGiftPanelUI()
        end
    end)

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                ruid = self.wishData.uid,
                times = 1,
                id = fragmentId
            }
            MessageMgr:sendPost('wish_give','legion',json.encode(args),function (response)
                local code = response.code
		        local data = response.data
		        if code == 0 then
                    LegionWishMgr:setLegionGiveData(LegionWishMgr:getGiveNum() + 1)
                    local awards = data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                    end
                    local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    LegionWishMgr:hidLlegionWishGiveGiftPanelUI()
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC31'), COLOR_TYPE.GREEN)
                    self.callBack()
                else
                    LegionWishMgr:popWindowErrorCode(code)
		        end
	        end)
        end
    end)

    local cancleBtn = self.neiBgImg:getChildByName('cancle_btn')
    cancleBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('STR_CANCEL_1'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hidLlegionWishGiveGiftPanelUI()
        end
    end)

    local icon = self.neiBgImg:getChildByName('icon')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    cell.lvTx:setString('x'..awards:getNum())
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)
    
    local haveDescTx = self.neiBgImg:getChildByName('have_desc_tx')
    local haveNumTx = self.neiBgImg:getChildByName('have_num_tx')
    local awardDescTx = self.neiBgImg:getChildByName('award_desc_tx')
    local awardNumTx = self.neiBgImg:getChildByName('award_num_tx')
    local img = self.neiBgImg:getChildByName('img')

    haveDescTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC18'))
    local num = 0
    if BagData:getFragmentById(fragmentId) then
        num = BagData:getFragmentById(fragmentId):getNum()
    end
    haveNumTx:setString(string.format(GlobalApi:getLocalStr('LEGION_WISH_DESC19'),num))
    awardDescTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC20'))

    local quality = GameData:getConfData("item")[tonumber(fragmentId)].quality
    local awardData2 = LegionWishMgr:getLegionConfDataByQuality(quality).award
    local disPlayData2 = DisplayData:getDisplayObjs(awardData2)
    local awards2 = disPlayData2[1]
    img:loadTexture(awards2:getIcon())
    awardNumTx:setString(awards2:getNum())

    cell.lvTx:setString('x'..LegionWishMgr:getLegionConfDataByQuality(quality).giveLimit)
end

return LegionWishGiveGiftPanelUI