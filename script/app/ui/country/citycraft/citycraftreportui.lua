local CityCraftReportUI = class("CityCraftReportUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CityCraftReportUI:ctor(reports)
    self.uiIndex = GAME_UI.UI_CITYCRAFTREPORT
    self.attackReports = {}
    self.defendReports = {}
    for k, v in ipairs(reports) do
        if v.attack == 1 then
            table.insert(self.attackReports, v)
        else
            table.insert(self.defendReports, v)
        end
    end
    self.cells = {}
    self.cellTotalHeight = 10
    local function sortOn(a, b)
        return a.time > b.time
    end
    if #self.attackReports > 1 then
        table.sort(self.attackReports, sortOn)
    end
    if #self.defendReports > 1 then
        table.sort(self.defendReports, sortOn)
    end
end

function CityCraftReportUI:init()
    local reportBgImg = self.root:getChildByName("report_bg_img")
    local reportAlphaImg = reportBgImg:getChildByName("report_alpha_img")
    self:adaptUI(reportBgImg, reportAlphaImg)

    local reportImg = reportAlphaImg:getChildByName("report_img")
    local closeBtn = reportImg:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        CityCraftMgr:hideCityCraftReport()
    end)

    local titleBg = reportImg:getChildByName("title_bg")
    local titleLabel = titleBg:getChildByName("title_tx")
    titleLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT1"))

    self.reportSv = reportImg:getChildByName("report_sv")
    self.reportSv:setScrollBarEnabled(false)
    self.svSize = self.reportSv:getContentSize()
    self.contentWidget = ccui.Widget:create()
    self.reportSv:addChild(self.contentWidget)

    self.pageBtn1 = reportImg:getChildByName("page_btn_1")
    self.pageLabel1 = self.pageBtn1:getChildByName("title_tx")
    self.pageLabel1:setString(string.format(GlobalApi:getLocalStr("STR_DEFEND_NEWLINE"), "\n"))
    
    self.pageBtn2 = reportImg:getChildByName("page_btn_2")
    self.pageLabel2 = self.pageBtn2:getChildByName("title_tx")
    self.pageLabel2:setString(string.format(GlobalApi:getLocalStr("STR_ATTACK_NEWLINE"), "\n"))

    self.pageBtn1:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        self:changePage(1)
    end)

    self.pageBtn2:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        self:changePage(2)
    end)

    self:changePage(1)
end

function CityCraftReportUI:changePage(page)
    local reports
    if page == 1 then -- 防守
        reports = self.defendReports
        self.pageBtn1:setBrightStyle(ccui.BrightStyle.highlight)
        self.pageBtn2:setBrightStyle(ccui.BrightStyle.normal)
        self.pageBtn1:setTouchEnabled(false)
        self.pageBtn2:setTouchEnabled(true)
        self.pageLabel1:setTextColor(COLOR_TYPE.PALE)
        self.pageLabel2:setTextColor(COLOR_TYPE.DARK)
    else -- 进攻
        reports = self.attackReports
        self.pageBtn1:setBrightStyle(ccui.BrightStyle.normal)
        self.pageBtn2:setBrightStyle(ccui.BrightStyle.highlight)
        self.pageBtn1:setTouchEnabled(true)
        self.pageBtn2:setTouchEnabled(false)
        self.pageLabel1:setTextColor(COLOR_TYPE.DARK)
        self.pageLabel2:setTextColor(COLOR_TYPE.PALE)
    end
    self.cellTotalHeight = 10
    local maxNum = #reports
    for i = 1, maxNum do
        if self.cells[i] then
            self:updateCell(self.cells[i], reports[i])
        else
            self:addCell(i, reports[i])
        end
    end
    local cellNum = #self.cells
    for j = maxNum + 1, cellNum do
        self.cells[j]:setVisible(false)
    end
    local posY = self.svSize.height
    if self.cellTotalHeight > posY then
        posY = self.cellTotalHeight
    end
    self.reportSv:setInnerContainerSize(cc.size(self.svSize.width, posY))
    self.contentWidget:setPosition(cc.p(self.svSize.width*0.5, posY))
    self.reportSv:scrollToTop(0.01, false)
end

function CityCraftReportUI:addCell(index, reportObj)
    local cellNode = cc.CSLoader:createNode("csb/citycraftreportcell.csb")
    local bgImg = cellNode:getChildByName("bg_img")
    self.cells[index] = bgImg

    local headpic_node = bgImg:getChildByName("headpic_node")
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headpic_node:addChild(headpicCell.awardBgImg) 

    local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    fightforceLabel:setPosition(cc.p(260, 24))
    fightforceLabel:setScale(0.8)
    fightforceLabel:setName("fightforce_tx")
    bgImg:addChild(fightforceLabel)
    if index%2 == 0 then
        bgImg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bgImg:loadTexture("uires/ui/common/touban.png")
    end
    bgImg:retain()
    bgImg:removeFromParent(false)
    self.contentWidget:addChild(bgImg)
    bgImg:release()
    self:updateCell(bgImg, reportObj)
end

function CityCraftReportUI:updateCell(bgImg, reportObj)
    bgImg:setVisible(true)
    local size = bgImg:getContentSize()
    self.cellTotalHeight = self.cellTotalHeight + size.height + 5
    bgImg:setPosition(cc.p(0, size.height*0.5 - self.cellTotalHeight + 10))
    local flagResult = bgImg:getChildByName("flag_result")
    if reportObj.success == 1 then
        flagResult:setTexture("uires/ui/arena/victory.png")
    else
        flagResult:setTexture("uires/ui/arena/failure.png")
    end

    local headConf = GameData:getConfData("settingheadicon")
    local headpicUrl
    if reportObj.headpic == 0 then
        headpicUrl = "uires/icon/hero/caocao_icon.png"
    else
        headpicUrl = headConf[reportObj.headpic].icon
    end

    local headpicNode = bgImg:getChildByName("headpic_node")
    local headpicBgImg = headpicNode:getChildByName("award_bg_img")
    local headpicImg = headpicBgImg:getChildByName("award_img")
    local headpicFrameImg = headpicBgImg:getChildByName("headframeImg")
    if reportObj.uid <= 1000000 then -- 机器人
        headpicBgImg:loadTexture(COLOR_FRAME[4])
    else
        headpicBgImg:loadTexture(COLOR_FRAME[reportObj.quality])
    end
    headpicImg:loadTexture(headpicUrl)
    headpicFrameImg:loadTexture(GlobalApi:getHeadFrame(reportObj.headframe))
    headpicFrameImg:setVisible(true)

    local quan = bgImg:getChildByName("quan")
    local lvLabel = quan:getChildByName("text")
    lvLabel:setString(reportObj.level)

    local flagCountry = bgImg:getChildByName("flag_country")
    flagCountry:setTexture("uires/ui/citycraft/citycraft_flag_" .. UserData:getUserObj():getCountry() .. ".png")

    local fightforceLabel = bgImg:getChildByName("fightforce_tx")
    fightforceLabel:setString(tostring(reportObj.fight_force))

    local nameLabel = bgImg:getChildByName("name_tx")
    nameLabel:setString(reportObj.un)

    local timeLabel = bgImg:getChildByName("time_tx")
    local happenTime = GlobalData:getServerTime() - reportObj.time
    if happenTime < 3600 then
        timeLabel:setString(string.format(GlobalApi:getLocalStr("MINUTE_AGO"), happenTime/60))
    elseif happenTime < 86400 then
        timeLabel:setString(string.format(GlobalApi:getLocalStr("HOUR_AGO"), happenTime/3600))
    else
        timeLabel:setString(string.format(GlobalApi:getLocalStr("DAY_AGO"), happenTime/86400))
    end

    local posLabel = bgImg:getChildByName("pos_tx")
    if reportObj.position == 0 then -- 官职不变
        posLabel:setString(GlobalApi:getLocalStr("POSITION_UNCHANGED"))
        posLabel:setTextColor(COLOR_TYPE.GRAY)
    else
        local conf = GameData:getConfData("position")
        if reportObj.success == 1 then
            if reportObj.position == 1 then
                posLabel:setString(GlobalApi:getLocalStr("POSITION_RAISE_TO") .. GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
            else
                posLabel:setString(GlobalApi:getLocalStr("POSITION_RAISE_TO") .. conf[reportObj.position].title)
            end
            posLabel:setTextColor(COLOR_TYPE.GREEN)
        else
            if reportObj.position == 1 then
                posLabel:setString(GlobalApi:getLocalStr("POSITION_FALL_TO") .. GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
            else
                posLabel:setString(GlobalApi:getLocalStr("POSITION_FALL_TO") .. conf[reportObj.position].title)
            end
            posLabel:setTextColor(COLOR_TYPE.RED)
        end
    end
    
    local replayBtn = bgImg:getChildByName("replay_btn")
    if reportObj.replay then
        replayBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    id = reportObj.replay
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
                                CityCraftMgr:showCityCraft()
                            end, nil, GAME_UI.UI_CITYCRAFT)
                        end)
                    end
                end)
            end
        end)
    else
        replayBtn:setVisible(false)
    end
end

return CityCraftReportUI