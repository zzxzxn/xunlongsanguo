local LegionMemberAgainstPannelUI = class("LegionMemberAgainstPannelUI", BaseUI)

function LegionMemberAgainstPannelUI:ctor(data,uid)
    self.uiIndex = GAME_UI.UI_LEGION_MEMBER_AGAINST_PANEL
    self.data = data
    self.uid = uid
end

function LegionMemberAgainstPannelUI:init()
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
            LegionMgr:hideLegionMemberAgainstUI()
        end
    end)
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES16'))

    local cancleBtn = self.neiBgImg:getChildByName('cancle_btn')
    cancleBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC17'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionMemberAgainstUI()
        end
    end)

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES15'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                lid = self.data.lid,
                uid = self.uid,
            }
            MessageMgr:sendPost('impeachment','legion',json.encode(args),function (response)	
				local code = response.code
                local datas = response.data
				if code == 0 then
                    self.data.impeachmentTime = datas.impeachmentTime
                    self.data.impeachmentInitiatorId = datas.impeachmentInitiatorId
                    LegionMgr:hideLegionMemberAgainstUI()
				end
			end)

        end
    end)

    --
    local awardBgImg = self.neiBgImg:getChildByName('award_bg_img')
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_MENBER_DES17'), 28, cc.c4b(255, 247, 228, 255))
	re1:setStroke(cc.c4b(78, 49, 17, 255),1)
    re1:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local legiondat = GameData:getConfData('legion')
    local legionHeadNotOnlineTimeLimit = tonumber(legiondat['legionHeadNotOnlineTimeLimit'].value)
	local re2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('LEGION_MENBER_DES18'),legionHeadNotOnlineTimeLimit), 28,COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_MENBER_DES19'), 28,cc.c4b(255, 247, 228, 255))
	re3:setStroke(cc.c4b(78, 49, 17, 255),1)
    re3:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

    richText:setRowSpacing(8)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(20,80))
    richText:format(true)
    awardBgImg:addChild(richText)

end

return LegionMemberAgainstPannelUI