local ActiveTavernActiveBoxUI = class("ActiveTavernActiveBoxUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActiveTavernActiveBoxUI:ctor(id,callBack,state,isLevel)
    self.uiIndex = GAME_UI.UI_ACTIVE_TAVERN_ACTIVE_BOX
    self.avTavernRecruitConf = GameData:getConfData('avtavernrecruit')
    self.state = state  -- 1领取，2查看
    self.id = id
    self.callBack = callBack
    self.isLevel = isLevel
end

function ActiveTavernActiveBoxUI:init()
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
            self:hideUI()
        end
    end)

    local confData = self.avTavernRecruitConf[self.id]

    -- 领取还是查看
    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    if self.state == 1 then
        infoTx:setString(GlobalApi:getLocalStr("STR_GET_1"))
    else
        infoTx:setString(GlobalApi:getLocalStr("STR_OK2"))
    end

    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.state == 1 then
                local act = 'get_tavern_recruit_award'
                if self.isLevel then
                    act = 'get_tavern_recruit_level_award'
                end
                MessageMgr:sendPost(act,'activity',json.encode({id = self.id}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                        self.callBack()
                        self:hideUI()
		        end)

            else
                self:hideUI()
            end
        end
    end)

    -- 标题
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(confData.name)

    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 30))
	richText:setAlignment('middle')
	local tx1 = GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES5')
	local tx2 = tostring(confData.num)
	local tx3 = GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES6')
	local re1 = xx.RichTextLabel:create(tx1, 25,COLOR_TYPE.ORANGE)
	local re2 = xx.RichTextLabel:create(tx2,25,COLOR_TYPE.WHITE)
	local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re2:setStroke(COLOR_TYPE.BLACK, 1)
	re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)

    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(262 ,110))
    self.neiBgImg:addChild(richText)

    -- 奖励品
    local awards = confData.awards
    local awardBgImg = self.neiBgImg:getChildByName('award_bg_img')
    local size = awardBgImg:getContentSize()
    local num = #awards

    local icon1 = awardBgImg:getChildByName('icon1')
    local icon2 = awardBgImg:getChildByName('icon2')
    local icon3 = awardBgImg:getChildByName('icon3')

    local disPlayData = DisplayData:getDisplayObjs(awards)
    if #awards == 1 then
        icon1:setVisible(true)
        icon2:setVisible(false)
        icon3:setVisible(false)

        local awardsData = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awardsData, icon1)
        cell.awardBgImg:setPosition(cc.p(47,45))
        local godId = awardsData:getGodId()
        awardsData:setLightEffect(cell.awardBgImg)
        icon1:setPosition(cc.p(size.width/2,size.height/2))
    elseif #awards == 2 then
        icon1:setVisible(true)
        icon2:setVisible(true)
        icon3:setVisible(false)

        for i = 1,2 do
            local icon = awardBgImg:getChildByName('icon' .. i)

            local awardsData = disPlayData[i]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awardsData, icon)
            cell.awardBgImg:setPosition(cc.p(47,45))
            local godId = awardsData:getGodId()
            awardsData:setLightEffect(cell.awardBgImg)
        end
        icon1:setPosition(cc.p(size.width/2 - 100,size.height/2))
        icon2:setPosition(cc.p(size.width/2 + 100,size.height/2))

    elseif #awards == 3 then
        icon1:setVisible(true)
        icon2:setVisible(true)
        icon3:setVisible(true)

        for i = 1,3 do
            local icon = awardBgImg:getChildByName('icon' .. i)

            local awardsData = disPlayData[i]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awardsData, icon)
            cell.awardBgImg:setPosition(cc.p(47,45))
            local godId = awardsData:getGodId()
            awardsData:setLightEffect(cell.awardBgImg)
        end
    end


end

return ActiveTavernActiveBoxUI