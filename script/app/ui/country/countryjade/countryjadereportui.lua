local CountryJadeReportUI = class("CountryJadeReportUI", BaseUI)

local HEIGHT = 80
local WIDTH = 824

function CountryJadeReportUI:ctor(msg)
    self.uiIndex = GAME_UI.UI_COUNTRY_JADE_REPORT
    self.msg = msg
    self:initData()
end

function CountryJadeReportUI:initData()
    
end

-- 初始化
function CountryJadeReportUI:init()
    local arenarankBgImg = self.root:getChildByName("arenarank_bg_img")
    local arenarankAlphaImg = arenarankBgImg:getChildByName("arenarank_alpha_img")
    self:adaptUI(arenarankBgImg, arenarankAlphaImg)

    local arenarankImg = arenarankAlphaImg:getChildByName("arenarank_img")
    local closebtn = arenarankImg:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            CountryJadeMgr:hideCountryJadeReportUI()
        end
    end)

    local titleBg = arenarankImg:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr('STR_BATTLE_REPORT1'))

    local noReportImg = arenarankImg:getChildByName('no_report_img')
    local reportNode = arenarankImg:getChildByName('report_node')
	local reportSv = reportNode:getChildByName('report_sv')
	reportSv:setScrollBarEnabled(false)

    local reports = self.msg.reports

    if #reports > 0 then    -- 有战报
        noReportImg:setVisible(false)
        reportSv:setVisible(true)

        local num = #reports
        local size = reportSv:getContentSize()
        local innerContainer = reportSv:getInnerContainer()
        local allHeight = size.height
        local cellSpace = 5

        local height = num * HEIGHT + (num - 1)*cellSpace

        if height > size.height then
            innerContainer:setContentSize(cc.size(size.width,height))
            allHeight = height
        end

        local offset = 0
        local tempHeight = HEIGHT
        for i = 1,num do
            local space = 0
            if i ~= 1 then
                space = cellSpace
            end
            offset = offset + tempHeight + space
            local cell = self:getCell(i,reports[i])
            cell:setPosition(cc.p(6,allHeight - offset))
            reportSv:addChild(cell)
        end
        innerContainer:setPositionY(size.height - allHeight)
    else
        noReportImg:setVisible(true)
        reportSv:setVisible(false)
    end

end

function CountryJadeReportUI:getCell(i,cellData)
    local widget = ccui.Widget:create()
    local bgImg = ccui.ImageView:create()
    widget:addChild(bgImg)
    if i%2 == 0 then
        bgImg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bgImg:loadTexture("uires/ui/common/common_bg_10.png")
    end
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(WIDTH, HEIGHT))
    bgImg:setPosition(cc.p(WIDTH/2,HEIGHT/2))

    -- 胜利还是失败图片
    local flagImg
    if cellData.win then    -- 胜利
        flagImg = cc.Sprite:create("uires/ui/arena/victory.png")
    else
        flagImg = cc.Sprite:create("uires/ui/arena/failure.png")
    end
    flagImg:setPosition(cc.p(50, 40))
    bgImg:addChild(flagImg)

    
    -- 富文本
    --[[
        我是
    攻击：
	    胜利：你 成功抢夺了 xx 的玉璧
	    失败：你 抢夺 xx 的玉璧失败

    被攻击：
	    胜利：xx 抢夺 你 的玉璧失败
	    失败：你 的玉璧被 xx 抢走了
    --]]

    local richText = xx.RichText:create()
    richText:setName(richTextName)
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create('', 25, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.YELLOW,1)
    re1:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create('', 25, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local country = 0
    if cellData.country then
        country = cellData.country
    end
    local re3 = xx.RichTextImage:create('uires/ui/rankinglist_v3/rlistv3_flag_' .. country .. '.png')

	local re4 = xx.RichTextLabel:create('', 25, COLOR_TYPE.ORANGE)
	re4:setStroke(COLOROUTLINE_TYPE.YELLOW,1)
    re4:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
    re4:setFont('font/gamefont.ttf')

	local re5 = xx.RichTextLabel:create('', 25, COLOR_TYPE.WHITE)
	re5:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re5:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
    re5:setFont('font/gamefont.ttf')

    local judge = true
    if cellData.isAttacker then
        if cellData.win then
            re1:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES34'))
            re2:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES35'))
            re4:setString(cellData.defender)
            re5:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES36'))
        else
            re1:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES34'))
            re2:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES37'))
            re4:setString(cellData.defender)
            re5:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES38'))
        end
    else
        if cellData.win then
            re1:setString(cellData.attacker)
            re2:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES37'))
            re4:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES34'))
            re5:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES38'))
            judge = false
        else
            re1:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES34'))
            re2:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES39'))
            re4:setString(cellData.attacker)
            re5:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES40'))
        end
    end

    if judge then
	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)
        richText:addElement(re4)
        richText:addElement(re5)
    else
        richText:addElement(re3)
        richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re4)
        richText:addElement(re5)
    end

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(100,40))
    richText:format(true)
    bgImg:addChild(richText)

    local timeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    timeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    timeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    timeLabel:setPosition(cc.p(710, 40))
    bgImg:addChild(timeLabel)

    local time = cellData.time
    if GlobalData:getServerTime() - time > 86400 then
        timeLabel:setString(GlobalApi:getLocalStr("STR_ONEDAY_BEFORE"))
    else
        timeLabel:setString(Time.date("%H:%M:%S", time))
    end


    return widget
end

return CountryJadeReportUI