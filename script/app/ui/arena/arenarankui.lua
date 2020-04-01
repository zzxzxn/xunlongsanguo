local ClassArenaRankCell = require("script/app/ui/arena/arenarankcell")
local ClassArenaAwardsCell = require("script/app/ui/arena/arenaawardscell")
local ClassArenaReportCell = require("script/app/ui/arena/arenareportcell")

local ArenaRankUI = class("ArenaRankUI", BaseUI)

local MAX_PAGE = 50
local BUNDLE_PAGE = 50
local NUM_PER_PAGE = 10

function ArenaRankUI:ctor(page)
    self.uiIndex = GAME_UI.UI_ARENA_RANK
    self.cardList = {}
    self.page = page or 1
    self.bundle = 1
    self.rankList = {}
    self.rankCellNum = 0
    self.maxRankCellNum = 0
    self.rankCellTotalHeight = 10
    self.createAwardsFlag = false
    self.reportCellNum = 0
    self.maxReportCellNum = 0
    self.reportCellTotalHeight = 10
    self.reportList = {}
    self.getRankMsg = false
    self.getReportMsg = false
end

function ArenaRankUI:init()
    local arenarankBgImg = self.root:getChildByName("arenarank_bg_img")
    local arenarankAlphaImg = arenarankBgImg:getChildByName("arenarank_alpha_img")
    self:adaptUI(arenarankBgImg, arenarankAlphaImg)

    local arenarankImg = arenarankAlphaImg:getChildByName("arenarank_img")
    self.noReportImg = arenarankImg:getChildByName('no_report_img')
    local closeBtn = arenarankImg:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        ArenaMgr:hideArenaRank()
    end)

    local rankBtn = arenarankImg:getChildByName("rank_btn")
    local rankLabel = rankBtn:getChildByName("text")
    local reportBtn = arenarankImg:getChildByName("report_btn")
    local reportLabel = reportBtn:getChildByName("text")
    local awardsBtn = arenarankImg:getChildByName("awards_btn")
    local awardsLabel = awardsBtn:getChildByName("text")
    rankLabel:setString(GlobalApi:getLocalStr("STR_RANK_2"))
    reportLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT1"))
    awardsLabel:setString(GlobalApi:getLocalStr("STR_EVERYDAT_AWARD"))
    rankLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    reportLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    awardsLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    rankLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    reportLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    awardsLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    if self.page == 1 then
        rankBtn:setBrightStyle(ccui.BrightStyle.highlight)
        reportBtn:setBrightStyle(ccui.BrightStyle.normal)
        awardsBtn:setBrightStyle(ccui.BrightStyle.normal)
        rankBtn:setTouchEnabled(false)
        rankLabel:setTextColor(COLOR_TYPE.PALE)
        reportLabel:setTextColor(COLOR_TYPE.DARK)
        awardsLabel:setTextColor(COLOR_TYPE.DARK)
    elseif self.page == 2 then
        rankBtn:setBrightStyle(ccui.BrightStyle.normal)
        reportBtn:setBrightStyle(ccui.BrightStyle.normal)
        awardsBtn:setBrightStyle(ccui.BrightStyle.highlight)
        awardsBtn:setTouchEnabled(false)
        rankLabel:setTextColor(COLOR_TYPE.DARK)
        reportLabel:setTextColor(COLOR_TYPE.DARK)
        awardsLabel:setTextColor(COLOR_TYPE.PALE)
    else
        rankBtn:setBrightStyle(ccui.BrightStyle.normal)
        reportBtn:setBrightStyle(ccui.BrightStyle.highlight)
        awardsBtn:setBrightStyle(ccui.BrightStyle.normal)
        reportBtn:setTouchEnabled(false)
        rankLabel:setTextColor(COLOR_TYPE.DARK)
        reportLabel:setTextColor(COLOR_TYPE.PALE)
        awardsLabel:setTextColor(COLOR_TYPE.DARK)
    end
    rankBtn:addClickEventListener(function ()
        rankBtn:setBrightStyle(ccui.BrightStyle.highlight)
        reportBtn:setBrightStyle(ccui.BrightStyle.normal)
        awardsBtn:setBrightStyle(ccui.BrightStyle.normal)
        rankBtn:setTouchEnabled(false)
        reportBtn:setTouchEnabled(true)
        awardsBtn:setTouchEnabled(true)
        rankLabel:setTextColor(COLOR_TYPE.PALE)
        reportLabel:setTextColor(COLOR_TYPE.DARK)
        awardsLabel:setTextColor(COLOR_TYPE.DARK)
        self:showPage(1)
    end)
    awardsBtn:addClickEventListener(function ()
        rankBtn:setBrightStyle(ccui.BrightStyle.normal)
        reportBtn:setBrightStyle(ccui.BrightStyle.normal)
        awardsBtn:setBrightStyle(ccui.BrightStyle.highlight)
        rankBtn:setTouchEnabled(true)
        reportBtn:setTouchEnabled(true)
        awardsBtn:setTouchEnabled(false)
        rankLabel:setTextColor(COLOR_TYPE.DARK)
        reportLabel:setTextColor(COLOR_TYPE.DARK)
        awardsLabel:setTextColor(COLOR_TYPE.PALE)
        self:showPage(2)
    end)
    reportBtn:addClickEventListener(function ()
        rankBtn:setBrightStyle(ccui.BrightStyle.normal)
        reportBtn:setBrightStyle(ccui.BrightStyle.highlight)
        awardsBtn:setBrightStyle(ccui.BrightStyle.normal)
        rankBtn:setTouchEnabled(true)
        reportBtn:setTouchEnabled(false)
        awardsBtn:setTouchEnabled(true)
        rankLabel:setTextColor(COLOR_TYPE.DARK)
        reportLabel:setTextColor(COLOR_TYPE.PALE)
        awardsLabel:setTextColor(COLOR_TYPE.DARK)
        self:showPage(3)
    end)

    local rankNode = arenarankImg:getChildByName("rank_node")
    local reportNode = arenarankImg:getChildByName("report_node")
    local awardsNode = arenarankImg:getChildByName("awards_node")
    self.rankNode = rankNode
    self.reportNode = reportNode
    self.awardsNode = awardsNode

    local rankSv = rankNode:getChildByName("rank_sv")
    rankSv:setScrollBarEnabled(false)
    self.rankSv = rankSv
    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            self:addRankCells()
        end
    end
    rankSv:addEventListener(scrollViewEvent)
    self.rankSvSize = rankSv:getContentSize()
    self.rankContentWidget = ccui.Widget:create()
    rankSv:addChild(self.rankContentWidget)

    local awardsSv = awardsNode:getChildByName("awards_sv")
    self.awardsSv = awardsSv
    awardsSv:setScrollBarEnabled(false)
    self.awardsSvSize = awardsSv:getContentSize()
    self.awardsContentWidget = ccui.Widget:create()
    awardsSv:addChild(self.awardsContentWidget)

    local reportSv = reportNode:getChildByName("report_sv")
    reportSv:setScrollBarEnabled(false)
    self.reportSv = reportSv
    local function scrollViewEvent2(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            self:addReportCells()
        end
    end
    reportSv:addEventListener(scrollViewEvent2)
    self.reportSvSize = reportSv:getContentSize()
    self.reportContentWidget = ccui.Widget:create()
    reportSv:addChild(self.reportContentWidget)
    
    self:showPage(self.page)
end

function ArenaRankUI:showPage(page)
    if page == 1 then
        if self.getRankMsg then
            self:showRankPage()
        else
            MessageMgr:sendPost("rank_list", "arena", "{}", function (jsonObj)
                if jsonObj.code == 0 then
                    self.getRankMsg = true
                    self.rankList = jsonObj.data.rank_list
                    self.maxRankCellNum = #self.rankList
                    self:showRankPage()
                end
            end)
        end
    elseif page == 2 then
        self:showAwardsPage()
    else
        if self.getReportMsg then
            self:showReportPage()
        else
            local obj = {
                uid = UserData:getUserObj():getUid()
            }
            MessageMgr:sendPost("get_report", "arena", json.encode(obj), function (jsonObj)
                --print(json.encode(jsonObj))
                if jsonObj.code == 0 then
                    self.getReportMsg = true
                    self.reportList = jsonObj.data.report
                    self.maxReportCellNum = #self.reportList
                    self:showReportPage()
                end
            end)
        end
    end
end

function ArenaRankUI:showRankPage()
    self.noReportImg:setVisible(false)
    self.rankNode:setVisible(true)
    self.reportNode:setVisible(false)
    self.awardsNode:setVisible(false)
    self:addRankCells()
end

function ArenaRankUI:showAwardsPage()
    self.noReportImg:setVisible(false)
    self.rankNode:setVisible(false)
    self.reportNode:setVisible(false)
    self.awardsNode:setVisible(true)
    if not self.createAwardsFlag then
        self:createAwardsCells()
        self.createAwardsFlag = true
    end
end

function ArenaRankUI:showReportPage()
    self.noReportImg:setVisible(self.maxReportCellNum <= 0)
    self.rankNode:setVisible(false)
    self.reportNode:setVisible(true)
    self.awardsNode:setVisible(false)
    self:addReportCells()
end

function ArenaRankUI:addRankCells()
    if self.rankCellNum < self.maxRankCellNum then -- 每次创建20个
        local currNum = self.rankCellNum
        self.rankCellNum = self.rankCellNum + 20
        self.rankCellNum = self.rankCellNum > self.maxRankCellNum and self.maxRankCellNum or self.rankCellNum
        for i = currNum + 1, self.rankCellNum do
            local cell = ClassArenaRankCell.new(self.rankList[i], i)
            local w, h = cell:getSize()
            self.rankCellTotalHeight = self.rankCellTotalHeight + h + 5
            cell:setPosition(cc.p(0, h*0.5 - self.rankCellTotalHeight + 10))
            self.rankContentWidget:addChild(cell:getPanel())
        end
        local posY = self.rankSvSize.height
        if self.rankCellTotalHeight > posY then
            posY = self.rankCellTotalHeight
        end
        self.rankSv:setInnerContainerSize(cc.size(self.rankSvSize.width, posY))
        self.rankContentWidget:setPosition(cc.p(self.rankSvSize.width*0.5, posY))
    end
end

function ArenaRankUI:createAwardsCells()
    local awardsConf = GameData:getConfData("arenadaily")
    local maxCount = #awardsConf
    local awardsCellTotalHeight = 10
    for i = 1, maxCount do
        local lastObj = nil
        if i > 1 then
            lastObj = awardsConf[i-1]
        end
        local cell = ClassArenaAwardsCell.new(lastObj, awardsConf[i], i)
        local w, h = cell:getSize()
        awardsCellTotalHeight = awardsCellTotalHeight + h + 5
        cell:setPosition(cc.p(0, h*0.5 - awardsCellTotalHeight + 10))
        self.awardsContentWidget:addChild(cell:getPanel())
    end
    local posY = self.awardsSvSize.height
    if awardsCellTotalHeight > posY then
        posY = awardsCellTotalHeight
    end
    self.awardsSv:setInnerContainerSize(cc.size(self.awardsSvSize.width, posY))
    self.awardsContentWidget:setPosition(cc.p(self.awardsSvSize.width*0.5, posY))
end

function ArenaRankUI:addReportCells()
    if self.reportCellNum < self.maxReportCellNum then -- 每次创建10个
        local currNum = self.reportCellNum
        self.reportCellNum = self.reportCellNum + 20
        self.reportCellNum = self.reportCellNum > self.maxReportCellNum and self.maxReportCellNum or self.reportCellNum
        for i = currNum + 1, self.reportCellNum do
            local cell = ClassArenaReportCell.new(self.reportList[i], i)
            local w, h = cell:getSize()
            self.reportCellTotalHeight = self.reportCellTotalHeight + h + 5
            cell:setPosition(cc.p(0, h*0.5 - self.reportCellTotalHeight + 10))
            self.reportContentWidget:addChild(cell:getPanel())
        end
        local posY = self.reportSvSize.height
        if self.reportCellTotalHeight > posY then
            posY = self.reportCellTotalHeight
        end
        self.reportSv:setInnerContainerSize(cc.size(self.reportSvSize.width, posY))
        self.reportContentWidget:setPosition(cc.p(self.reportSvSize.width*0.5, posY))
    end
end

return ArenaRankUI