local GoldmineReportUI = class("GoldmineReportUI", BaseUI)

local GOLDMINE_TX_RES = {"tx_goldmine_wzjk.png", "tx_goldmin_frjk.png", "tx_goldmine_ptjk.png", "tx_goldmine_pjjk.png", "tx_goldmine_kjjk.png"}

local function createReportWidget(arr, mineNames, index)
    local bg = ccui.ImageView:create()
    if index%2 == 0 then
        bg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bg:loadTexture("uires/ui/common/common_bg_6.png")
    end
    bg:setScale9Enabled(true)

    -- 时间
    local timeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    timeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    timeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    timeLabel:setAnchorPoint(cc.p(0, 1))
    bg:addChild(timeLabel)

    local time = arr[1]
    local goldType = 6 - arr[2]
    local uid1 = arr[3]
    local name1 = arr[4]
    local uid2 = arr[5]
    local name2 = arr[6]
    local gold = arr[7] or 0
    local win = arr[8] == 1 and true or false
    local reportId = arr[9]
    local timsStr = Time.date("%Y/%m/%d %X", time)
    local myUid = UserData:getUserObj():getUid()
    local isMe = false
    local color1 = COLOR_TYPE.ORANGE
    local outline1 = COLOROUTLINE_TYPE.ORANGE
    local color2 = COLOR_TYPE.ORANGE
    local outline2 = COLOROUTLINE_TYPE.ORANGE
    if uid1 == myUid then
        isMe = true
        name1 = GlobalApi:getLocalStr("STR_YOU")
        -- color1 = COLOR_TYPE.WHITE
        -- outline1 = COLOROUTLINE_TYPE.WHITE
    elseif uid2 == myUid then
        isMe = true
        name2 = GlobalApi:getLocalStr("STR_YOU")
        -- color2 = COLOR_TYPE.WHITE
        -- outline2 = COLOROUTLINE_TYPE.WHITE
    end
    local str1
    local str11
    local str2
    local str3
    if win then
        if gold == 0 then
            -- name1将XX从XX打的落荒而逃
            str1 = GlobalApi:getLocalStr("GOLDMINE_REPORT_1")
            str11 = GlobalApi:getLocalStr("GOLDMINE_REPORT_11")
            str2 = GlobalApi:getLocalStr("GOLDMINE_REPORT_2")
        else
            --name1将XX从XX打的落荒而逃并得到了XX的
            str1 = GlobalApi:getLocalStr("GOLDMINE_REPORT_1")
            str11 = GlobalApi:getLocalStr("GOLDMINE_REPORT_11")
            str2 = GlobalApi:getLocalStr("GOLDMINE_REPORT_3")
        end
    else
        if gold == 0 then
            -- name1企图将XX从XX赶走，结果被吊打
            str1 = GlobalApi:getLocalStr("GOLDMINE_REPORT_4")
            str11 = GlobalApi:getLocalStr("GOLDMINE_REPORT_11")
            str2 = GlobalApi:getLocalStr("GOLDMINE_REPORT_5")
        else
            --name1企图将XX从XX赶走，结果被吊打并损失了XX
            str1 = GlobalApi:getLocalStr("GOLDMINE_REPORT_4")
            str11 = GlobalApi:getLocalStr("GOLDMINE_REPORT_11")
            str2 = GlobalApi:getLocalStr("GOLDMINE_REPORT_6")
        end
    end
    timeLabel:setString(timsStr)
    -- 内容
    local richText = xx.RichText:create()
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(700, 30))
    local nameRe1 = xx.RichTextLabel:create(name1, 23, color1)
    nameRe1:setStroke(outline1, 1)
    local re1 = xx.RichTextLabel:create(str1, 23, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local nameRe2 = xx.RichTextLabel:create(name2..'\n', 23, color2)
    nameRe2:setStroke(outline2, 1)
    local re11 = xx.RichTextLabel:create(str11, 23, COLOR_TYPE.WHITE)
    re11:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(str2, 23, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re5 = xx.RichTextImage:create("uires/ui/text/" .. GOLDMINE_TX_RES[goldType])
    re5:setScale(0.8)
    richText:addElement(nameRe1)
    richText:addElement(re1)
    richText:addElement(nameRe2)
    richText:addElement(re11)
    richText:addElement(re5)
    richText:addElement(re2)
    if gold ~= 0 then
        local re3 = xx.RichTextLabel:create(tostring(math.abs(gold)), 23, COLOR_TYPE.WHITE)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re6 = xx.RichTextImage:create('uires/ui/res/res_gold.png')
        re6:setScale(0.8)
        richText:addElement(re6)
        richText:addElement(re3)
    end
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:format(true)
    bg:addChild(richText)
    local sizeHeight = 110
    bg:setContentSize(cc.size(860, sizeHeight))
    timeLabel:setPosition(cc.p(20, sizeHeight - 5))
    richText:setPosition(cc.p(20, sizeHeight - 50))
    if isMe then
        local isMeImg = cc.Sprite:create("uires/ui/common/common_flag_big_5.png")
        isMeImg:setPosition(cc.p(780, sizeHeight - 32))
        bg:addChild(isMeImg)
        local isMeLabel = cc.Label:createWithTTF(GlobalApi:getLocalStr("STR_ME"), "font/gamefont.ttf", 25)
        isMeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        isMeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        isMeLabel:setPosition(cc.p(30, 44))
        isMeImg:addChild(isMeLabel)
    end
    if reportId then
        local replayBtn = ccui.Button:create("uires/ui/common/icon_replay.png")
        replayBtn:setPosition(cc.p(680, sizeHeight - 55))
        replayBtn:setScale(1.2)
        replayBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    id = reportId
                }
                MessageMgr:sendPost("get", "replay", json.encode(args), function (jsonObj)
                    if jsonObj.code == 0 then
                        local customObj = {
                            info = jsonObj.data.info,
                            enemy = jsonObj.data.enemy,
                            rand1 = jsonObj.data.rand1,
                            rand2 = jsonObj.data.rand2
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function (battleReportJson)
                            MainSceneMgr:showMainCity(function()
                                GoldmineMgr:showGoldmine()
                            end, nil, GAME_UI.UI_GOLDMINE)
                        end)
                    end
                end)
            end
        end)
        bg:addChild(replayBtn)
    end
    return bg, sizeHeight
end

function GoldmineReportUI:ctor()
    self.uiIndex = GAME_UI.UI_GOLDMINEREPORT
    self.reports = {}
end

function GoldmineReportUI:init()
    local reportBgImg = self.root:getChildByName("mine_report_bg_img")
    local reportAlphaImg = reportBgImg:getChildByName("mine_report_alpha_img")
    self:adaptUI(reportBgImg, reportAlphaImg)

    local reportImg = reportAlphaImg:getChildByName("mine_report_img")
    local noReportImg = reportImg:getChildByName("no_report_img")
    local titlBg = reportImg:getChildByName("title_bg")
    local titleLabel = titlBg:getChildByName("title_tx")
    titleLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT1"))

    local closeBtn = reportImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            GoldmineMgr:hideGoldmineReport()
        end
    end)

    local reportSv = reportImg:getChildByName("report_sv")
    reportSv:setScrollBarEnabled(false)
    local contentWidget = ccui.Widget:create()
    reportSv:addChild(contentWidget)
    local svSize = reportSv:getContentSize()
    local reportCellNum = 0
    local maxReportCellNum = 0
    local cellTotalHeight = 10
    local function addReportCells()
        noReportImg:setVisible(maxReportCellNum <= 0)
        if reportCellNum < maxReportCellNum then -- 每次创建10个
            local currNum = reportCellNum
            reportCellNum = reportCellNum + 10
            reportCellNum = reportCellNum > maxReportCellNum and maxReportCellNum or reportCellNum
            for i = currNum + 1, reportCellNum do
                local widget, height = createReportWidget(self.reports[maxReportCellNum - i + 1], mineNames, i)
                cellTotalHeight = cellTotalHeight + height + 5
                widget:setPosition(cc.p(0, height*0.5 - cellTotalHeight + 10))
                contentWidget:addChild(widget)
            end
            local posY = svSize.height
            if cellTotalHeight > posY then
                posY = cellTotalHeight
            end
            reportSv:setInnerContainerSize(cc.size(svSize.width, posY))
            contentWidget:setPosition(cc.p(svSize.width*0.5, posY))
        end
    end

    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            addReportCells()
        end
    end
    reportSv:addEventListener(scrollViewEvent)


    local reports = GoldmineMgr:getReport() or {}
    local time = 0
    if #reports > 0 then
        time = reports[#reports][1]
    end
    local obj = {
        time = time
    }
    
    local mineNames = {GlobalApi:getLocalStr("GOLDMINE_NAME_1"), GlobalApi:getLocalStr("GOLDMINE_NAME_2"), GlobalApi:getLocalStr("GOLDMINE_NAME_3"), GlobalApi:getLocalStr("GOLDMINE_NAME_4"), GlobalApi:getLocalStr("GOLDMINE_NAME_5")}
    MessageMgr:sendPost("get_report", "mine", json.encode(obj), function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            for k, v in pairs(jsonObj.data.report) do
                table.insert(reports, v)
            end
            GoldmineMgr:setReport(reports)
            self.reports = reports
            maxReportCellNum = #reports
            addReportCells()
        end
    end)
end

return GoldmineReportUI