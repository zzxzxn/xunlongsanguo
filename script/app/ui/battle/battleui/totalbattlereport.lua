local TotalBattleReportUI = class("TotalBattleReportUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local CELL_TYPE = {
    [1] = 1,
    [2] = 2,
    [3] = 2,
    [4] = 2
}

local PAGE = {
    COMMEND = 1,
    ARENA = 2,
    CITYCRAFT = 3,
    WORLDWAR = 4
}

local CELL_WIDTH = 920
local CELL_HEIGHT = 124
local CELL_SPACE = 8

local COLOR_NAME_OUTLINE = cc.c4b(100, 59, 36, 255)
 
function TotalBattleReportUI:ctor(page)
    self.uiIndex = GAME_UI.UI_TOTAL_BATTLE_REPORT
    self.currPage = 0
    self.firstOpenPage = page
    self.datas = {}
    self.cells = {{}, {}}
end

function TotalBattleReportUI:init()
    local report_bg_gray_img = self.root:getChildByName("report_bg_gray_img")
    local report_bg_img = report_bg_gray_img:getChildByName("report_bg_img")
    self:adaptUI(report_bg_gray_img, report_bg_img)

    local close_btn = report_bg_img:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:hideTotalBattleReport()
        end
    end)

    local embattle_img = report_bg_img:getChildByName("embattle_img")
    embattle_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:showEmbattleUI()
        end
    end)

    self.title_sv = report_bg_img:getChildByName("title_sv")
    self.title_sv:setScrollBarEnabled(false)
    self:initTitle()

    self.content_sv = report_bg_img:getChildByName("content_sv")
    self.content_sv:setScrollBarEnabled(false)
    self.svSize = self.content_sv:getContentSize()
    self.content_widget = ccui.Widget:create()
    self.content_widget:setPosition(cc.p(self.svSize.width/2, self.svSize.height))
    self.content_sv:addChild(self.content_widget)

    self.no_report = report_bg_img:getChildByName("no_report")
    local no_report_tx = self.no_report:getChildByName("text")
    no_report_tx:setString(GlobalApi:getLocalStr("STR_NO_REPORT"))

    self:checkNewImg()

    self:changePage(self.firstOpenPage)
end

function TotalBattleReportUI:initTitle()
    self.titles = {}
    self.newImgs = {}
    for i = 1, 4 do
        local title = self.title_sv:getChildByName("title_" .. i)
        self.titles[i] = title
        self.newImgs[i] = title:getChildByName("new_img")
        title:ignoreContentAdaptWithSize(true)
        title:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:changePage(i)
            elseif eventType == ccui.TouchEventType.canceled then
                title:loadTexture("uires/ui/worldwar/worldwar_feats_wall_bg.png")
            end
        end)
    end
end

function TotalBattleReportUI:changePage(page)
    if self.currPage == page then
        return
    end
    if self.currPage > 0 then
        self.titles[self.currPage]:setTouchEnabled(true)
        self.titles[self.currPage]:loadTexture("uires/ui/worldwar/worldwar_feats_wall_bg.png")
    end
    self.titles[page]:setTouchEnabled(false)
    self.titles[page]:loadTexture("uires/ui/common/common_bg_43.png")
    if page == PAGE.COMMEND then
        self:getCommendReport()
    elseif page == PAGE.ARENA then
        self:getArenaReport()
    elseif page == PAGE.CITYCRAFT then
        self:getCityCraftReport()
    elseif page == PAGE.WORLDWAR then
        self:getWorldWarReport()
    end
end

function TotalBattleReportUI:getCommendReport()
    if self.datas[PAGE.COMMEND] == nil then
        MessageMgr:sendPost("get_report", "worldwar", "{}", function (jsonObj)
            if jsonObj.code == 0 then
                self.datas[PAGE.COMMEND] = jsonObj.data.report
                self.newImgs[PAGE.COMMEND]:setVisible(false)
                self:showCommendReport()
            else
                self:showCommendReport()
            end
        end)
    else
        self:showCommendReport()    
    end
end

function TotalBattleReportUI:showCommendReport()
    if self.datas[PAGE.COMMEND] == nil then
        self.datas[PAGE.COMMEND] = {}
    end
    local dataNum = 0
    if self.datas[PAGE.COMMEND] then
        dataNum = #self.datas[PAGE.COMMEND]
    end
    self.commendData = {}
    local index = 0
    for i = 1, dataNum do
        if #self.datas[PAGE.COMMEND][i] > 0 then
            index = index + 1
            self.commendData[index] = self.datas[PAGE.COMMEND][i]
            self:updateCommendCell(CELL_TYPE[PAGE.COMMEND], index, i, self.datas[PAGE.COMMEND][i])
        end
    end
    local totalHeight = (CELL_HEIGHT+CELL_SPACE)*index
    if totalHeight < self.svSize.height then
        totalHeight = self.svSize.height
    end
    self.content_sv:setInnerContainerSize(cc.size(self.svSize.width, totalHeight))
    self.content_widget:setPositionY(totalHeight)
    if self.currPage > 0 then
        if CELL_TYPE[PAGE.COMMEND] == CELL_TYPE[self.currPage] then
            self:hideCells(CELL_TYPE[self.currPage], index)
        else
            self:hideCells(CELL_TYPE[self.currPage], 0)
        end
    end
    if index > 0 then
        self.no_report:setVisible(false)
    else
        self.no_report:setVisible(true)
    end
    self.currPage = PAGE.COMMEND
end

function TotalBattleReportUI:getArenaReport()
    if self.datas[PAGE.ARENA] == nil then
        local isOpen = GlobalApi:getOpenInfo('arena')
        if isOpen then
            local obj = {
                uid = UserData:getUserObj():getUid()
            }
            MessageMgr:sendPost("get_report", "arena", json.encode(obj), function (jsonObj)
                if jsonObj.code == 0 then
                    self.datas[PAGE.ARENA] = jsonObj.data.report
                    UserData:getUserObj():setSignByType("arena_report", 0)
                    self.newImgs[PAGE.ARENA]:setVisible(false)
                    self:showArenaReport()
                else
                    self:showArenaReport()
                end
            end)
        else
            self.datas[PAGE.ARENA] = {}
            self:showArenaReport()
        end
    else
        self:showArenaReport()
    end
end

function TotalBattleReportUI:showArenaReport()
    local dataNum = 0
    if self.datas[PAGE.ARENA] then
       dataNum = #self.datas[PAGE.ARENA]
    end
    if self.currPage > 0 then
        if CELL_TYPE[PAGE.ARENA] == CELL_TYPE[self.currPage] then
            self:hideCells(CELL_TYPE[self.currPage], dataNum)
        else
            self:hideCells(CELL_TYPE[self.currPage], 0)
        end
    end
    local totalHeight = (CELL_HEIGHT+CELL_SPACE)*dataNum
    if totalHeight < self.svSize.height then
        totalHeight = self.svSize.height
    end
    self.content_sv:setInnerContainerSize(cc.size(self.svSize.width, totalHeight))
    self.content_widget:setPositionY(totalHeight)
    for i = 1, dataNum do
        self:updateArenaCell(CELL_TYPE[PAGE.ARENA], i, self.datas[PAGE.ARENA][dataNum - i + 1])
    end
    if dataNum > 0 then
        self.no_report:setVisible(false)
    else
        self.no_report:setVisible(true)
    end
    self.currPage = PAGE.ARENA
end

function TotalBattleReportUI:getCityCraftReport()
    if self.datas[PAGE.CITYCRAFT] == nil then
        local country = UserData:getUserObj():getCountry()
        if country > 0 then
            MessageMgr:sendPost("get_report","country", "{}", function (response)
                if response.code == 0 then
                    self.datas[PAGE.CITYCRAFT] = response.data.reports
                    UserData:getUserObj():setSignByType("country_report", 0)
                    self.newImgs[PAGE.CITYCRAFT]:setVisible(false)
                    self:showCityCraftReport()
                else
                    self:showCityCraftReport()
                end
            end)
        else
            self.datas[PAGE.CITYCRAFT] = {}
            self:showCityCraftReport()
        end
    else
        self:showCityCraftReport()
    end
end

function TotalBattleReportUI:showCityCraftReport()
    local dataNum = 0
    if self.datas[PAGE.CITYCRAFT] then
        dataNum = #self.datas[PAGE.CITYCRAFT]
    end
    if self.currPage > 0 then
        if CELL_TYPE[PAGE.CITYCRAFT] == CELL_TYPE[self.currPage] then
            self:hideCells(CELL_TYPE[self.currPage], dataNum)
        else
            self:hideCells(CELL_TYPE[self.currPage], 0)
        end
    end
    local totalHeight = (CELL_HEIGHT+CELL_SPACE)*dataNum
    if totalHeight < self.svSize.height then
        totalHeight = self.svSize.height
    end
    self.content_sv:setInnerContainerSize(cc.size(self.svSize.width, totalHeight))
    self.content_widget:setPositionY(totalHeight)
    for i = 1, dataNum do
        self:updateCityCraftCell(CELL_TYPE[PAGE.CITYCRAFT], i, self.datas[PAGE.CITYCRAFT][dataNum - i + 1])
    end
    if dataNum > 0 then
        self.no_report:setVisible(false)
    else
        self.no_report:setVisible(true)
    end
    self.currPage = PAGE.CITYCRAFT
end

function TotalBattleReportUI:getWorldWarReport()
    if self.datas[PAGE.WORLDWAR] == nil then
        local isOpen = GlobalApi:getOpenInfo('worldwar')
        if isOpen then
            MessageMgr:sendPost("get_replay_list", "worldwar", "{}", function(response)
                if response.code == 0 then
                    self.datas[PAGE.WORLDWAR] = response.data.replays
                    UserData:getUserObj():setSignByType("worldwar_report", 0)
                    self.newImgs[PAGE.WORLDWAR]:setVisible(false)
                    self:showWorldWarReport()
                else
                    self:showWorldWarReport()
                end
            end)
        else
            self.datas[PAGE.WORLDWAR] = {}
            self:showWorldWarReport()
        end
    else
        self:showWorldWarReport()
    end
end

function TotalBattleReportUI:showWorldWarReport()
    local dataNum = 0
    if self.datas[PAGE.WORLDWAR] then
        dataNum = #self.datas[PAGE.WORLDWAR]
    end
    if self.currPage > 0 then
        if CELL_TYPE[PAGE.WORLDWAR] == CELL_TYPE[self.currPage] then
            self:hideCells(CELL_TYPE[self.currPage], dataNum)
        else
            self:hideCells(CELL_TYPE[self.currPage], 0)
        end
    end
    local totalHeight = (CELL_HEIGHT+CELL_SPACE)*dataNum
    if totalHeight < self.svSize.height then
        totalHeight = self.svSize.height
    end
    self.content_sv:setInnerContainerSize(cc.size(self.svSize.width, totalHeight))
    self.content_widget:setPositionY(totalHeight)
    for i = 1, dataNum do
        self:updateWorldWarCell(CELL_TYPE[PAGE.WORLDWAR], i, self.datas[PAGE.WORLDWAR][i])
    end
    if dataNum > 0 then
        self.no_report:setVisible(false)
    else
        self.no_report:setVisible(true)
    end
    self.currPage = PAGE.WORLDWAR
end

function TotalBattleReportUI:hideCells(cellType, startIndex)
    if self.cells[cellType] then
        for i = startIndex + 1, #self.cells[cellType] do
            self.cells[cellType][i].bg:setVisible(false)
        end
    end
end

function TotalBattleReportUI:updateWorldWarCell(cellType, index, data)
    if self.cells[cellType][index] == nil then
        self.cells[cellType][index] = self:createCell(cellType, index)
        self.content_widget:addChild(self.cells[cellType][index].bg)
        self.cells[cellType][index].bg:setPosition(cc.p(0, (0.5 - index)*(CELL_HEIGHT + CELL_SPACE)))
    end

    local cell = self.cells[cellType][index]
    cell.bg:setVisible(true)
    if data.win then
        cell.isWin:loadTexture("uires/ui/report/report_win.png")
    else
        cell.isWin:loadTexture("uires/ui/report/report_lose.png")
    end

    local headConf = GameData:getConfData("settingheadicon")
    if data.enemy_id <= 1000000 then -- 机器人
        cell.headpicBg:loadTexture(COLOR_FRAME[4])
    else
        cell.headpicBg:loadTexture(COLOR_FRAME[data.quality])
    end
    cell.headpic:loadTexture(headConf[data.headpic].icon)
    cell.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))

    if data.enemy_id == UserData:getUserObj():getUid() then
        cell.isEnemy:setVisible(false)
    else
        cell.isEnemy:setVisible(true)
    end

    cell.lvTx:setString(tostring(data.level))
    cell.nameTx:setString(data.name)
    cell.fightforceTx:setString(tostring(data.fight_force))

    if data.vip > 0 then
        cell.vImg:setVisible(true)
        cell.vNum:setVisible(true)
        local vx = cell.nameTx:getPositionX() + cell.nameTx:getContentSize().width + 20
        cell.vImg:setPositionX(vx)
        cell.vNum:setPositionX(vx + 10)
        cell.vNum:setString(tostring(data.vip))
    else
        cell.vImg:setVisible(false)
        cell.vNum:setVisible(false)
    end

    cell.timeTx:setVisible(false)

    if data.replay_id then
        cell.reportBtn:setVisible(true)
    else
        cell.reportBtn:setVisible(false)
    end
end

function TotalBattleReportUI:updateCommendCell(cellType, index, rank, data)
    if self.cells[cellType][index] == nil then
        self.cells[cellType][index] = self:createCell(cellType, index)
        self.content_widget:addChild(self.cells[cellType][index].bg)
        self.cells[cellType][index].bg:setPosition(cc.p(0, (0.5 - index)*(CELL_HEIGHT + CELL_SPACE)))
    end

    local cell = self.cells[cellType][index]
    cell.bg:setVisible(true)

    if rank <= 3 then
        cell.headpicBg:loadTexture(COLOR_FRAME[5])
        cell.headpic:loadTexture("uires/ui/report/report_rank_" .. rank .. ".png")
    else
        cell.headpicBg:loadTexture(COLOR_FRAME[1])
        cell.headpic:loadTexture("uires/ui/report/report_rank_0.png")
    end
    cell.winnerTx:setString(GlobalApi:getLocalStr("STR_WINNER"))
    cell.nameTx1:setString('“' .. data[1] .. '”')
    cell.vsTx:setString("VS")
    local vsPosX = cell.nameTx1:getPositionX() + cell.nameTx1:getContentSize().width + 10
    cell.vsTx:setPositionX(vsPosX)
    cell.nameTx2:setString('“' .. data[2] .. '”')
    cell.nameTx2:setPositionX(vsPosX + cell.vsTx:getContentSize().width - 5)
    if rank == 1 then
        cell.infoTx:setString("（" .. GlobalApi:getLocalStr("WORDWAR_MATCH_DESC_1") .. "）")
    elseif rank > 1 and rank <= 3 then
        cell.infoTx:setString("（" .. GlobalApi:getLocalStr("WORDWAR_MATCH_DESC_2") .. "）")
    elseif rank > 3 and rank <= 7 then
        cell.infoTx:setString("（" .. GlobalApi:getLocalStr("WORDWAR_MATCH_DESC_3") .. "）")
    elseif rank > 7 and rank <= 15 then
        cell.infoTx:setString("（" .. GlobalApi:getLocalStr("WORDWAR_MATCH_DESC_4") .. "）")
    else
        cell.infoTx:setString("（" .. GlobalApi:getLocalStr("WORDWAR_MATCH_DESC_5") .. "）")
    end
    
end

function TotalBattleReportUI:updateArenaCell(cellType, index, data)
    if self.cells[cellType][index] == nil then
        self.cells[cellType][index] = self:createCell(cellType, index)
        self.content_widget:addChild(self.cells[cellType][index].bg)
        self.cells[cellType][index].bg:setPosition(cc.p(0, (0.5 - index)*(CELL_HEIGHT + CELL_SPACE)))
    end

    local time = data[1]
    local win = data[2] == 1
    local uid = data[3]
    local name
    local headpicId
    local level
    local quality
    local reportId
    local vip
    local fightforce
    local headframe
    if data[12] then
        reportId = data[5]
        name = data[6]
        headpicId = tonumber(data[7])
        level = tostring(data[8])
        quality = data[9]
        vip = data[10]
        fightforce = data[11]
        headframe = data[12]
    else
        name = data[5]
        headpicId = tonumber(data[6])
        level = tostring(data[7])
        quality = data[8]
        vip = data[9]
        fightforce = data[10]
        headframe = data[11]
    end

    local cell = self.cells[cellType][index]
    cell.bg:setVisible(true)
    if win then
        cell.isWin:loadTexture("uires/ui/report/report_win.png")
    else
        cell.isWin:loadTexture("uires/ui/report/report_lose.png")
    end
   
    local headConf = GameData:getConfData("settingheadicon")
    if uid <= 1000000 then -- 机器人
        cell.headpicBg:loadTexture(COLOR_FRAME[4])
    else
        cell.headpicBg:loadTexture(COLOR_FRAME[quality])
    end
    cell.headpic:loadTexture(headConf[headpicId].icon)
    cell.headframe:loadTexture(GlobalApi:getHeadFrame(headframe))

    if uid == UserData:getUserObj():getUid() then
        cell.isEnemy:setVisible(false)
    else
        cell.isEnemy:setVisible(true)
    end

    cell.lvTx:setString(level)
    cell.nameTx:setString(name)
    cell.fightforceTx:setString(tostring(fightforce))

    if vip > 0 then
        cell.vImg:setVisible(true)
        cell.vNum:setVisible(true)
        local vx = cell.nameTx:getPositionX() + cell.nameTx:getContentSize().width + 20
        cell.vImg:setPositionX(vx)
        cell.vNum:setPositionX(vx + 10)
        cell.vNum:setString(tostring(vip))
    else
        cell.vImg:setVisible(false)
        cell.vNum:setVisible(false)
    end

    cell.timeTx:setVisible(true)
    if GlobalData:getServerTime() - time > 86400 then
        cell.timeTx:setString(GlobalApi:getLocalStr("STR_ONEDAY_BEFORE"))
    else
        cell.timeTx:setString(Time.date("%H:%M:%S", time))
    end

    if reportId then
        cell.reportBtn:setVisible(true)
    else
        cell.reportBtn:setVisible(false)
    end
end

function TotalBattleReportUI:updateCityCraftCell(cellType, index, data)
    if self.cells[cellType][index] == nil then
        self.cells[cellType][index] = self:createCell(cellType, index)
        self.content_widget:addChild(self.cells[cellType][index].bg)
        self.cells[cellType][index].bg:setPosition(cc.p(0, (0.5 - index)*(CELL_HEIGHT + CELL_SPACE)))
    end

    local cell = self.cells[cellType][index]
    cell.bg:setVisible(true)
    if data.success == 1 then
        cell.isWin:loadTexture("uires/ui/report/report_win.png")
    else
        cell.isWin:loadTexture("uires/ui/report/report_lose.png")
    end

    local headConf = GameData:getConfData("settingheadicon")
    if data.uid <= 1000000 then -- 机器人
        cell.headpicBg:loadTexture(COLOR_FRAME[4])
    else
        cell.headpicBg:loadTexture(COLOR_FRAME[data.quality])
    end
    cell.headpic:loadTexture(headConf[data.headpic].icon)
    cell.headframe:loadTexture(GlobalApi:getHeadFrame(data.headframe))

    if data.enemy_id == UserData:getUserObj():getUid() then
        cell.isEnemy:setVisible(false)
    else
        cell.isEnemy:setVisible(true)
    end

    cell.lvTx:setString(tostring(data.level))
    cell.nameTx:setString(data.un)
    cell.fightforceTx:setString(tostring(data.fight_force))

    if data.vip > 0 then
        cell.vImg:setVisible(true)
        cell.vNum:setVisible(true)
        local vx = cell.nameTx:getPositionX() + cell.nameTx:getContentSize().width + 20
        cell.vImg:setPositionX(vx)
        cell.vNum:setPositionX(vx + 10)
        cell.vNum:setString(tostring(data.vip))
    else
        cell.vImg:setVisible(false)
        cell.vNum:setVisible(false)
    end

    cell.timeTx:setVisible(true)
    if GlobalData:getServerTime() - data.time > 86400 then
        cell.timeTx:setString(GlobalApi:getLocalStr("STR_ONEDAY_BEFORE"))
    else
        cell.timeTx:setString(Time.date("%H:%M:%S", data.time))
    end

    if data.replay then
        cell.reportBtn:setVisible(true)
    else
        cell.reportBtn:setVisible(false)
    end
end

function TotalBattleReportUI:createCell(cellType, index)
    if cellType == 1 then
        return self:createCellTypeOne(index)
    elseif cellType == 2 then
        return self:createCellTypeTwo(index)
    end
end

function TotalBattleReportUI:createCellTypeOne(index)
    local bg = ccui.ImageView:create("uires/ui/common/common_bg_3.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(CELL_WIDTH, CELL_HEIGHT))

    local headpicBg = ccui.ImageView:create()
    headpicBg:setScale(1.2)
    headpicBg:ignoreContentAdaptWithSize(true)
    headpicBg:setPosition(cc.p(62, CELL_HEIGHT/2))
    bg:addChild(headpicBg)

    local headpic = ccui.ImageView:create()
    headpic:ignoreContentAdaptWithSize(true)
    headpic:setPosition(cc.p(62, CELL_HEIGHT/2))
    bg:addChild(headpic)

    local line = ccui.ImageView:create("uires/ui/activity/xuxian.png")
    line:setScaleY(1.2)
    line:setPosition(cc.p(124, CELL_HEIGHT/2))
    bg:addChild(line)

    local winnerTx = ccui.Text:create()
    winnerTx:setFontName("font/gamefont.ttf")
    winnerTx:setFontSize(28)
    winnerTx:setAnchorPoint(cc.p(0, 0.5))
    winnerTx:enableOutline(COLOR_NAME_OUTLINE, 2)
    winnerTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    winnerTx:setPosition(cc.p(140, 90))
    bg:addChild(winnerTx)

    local nameTx1 = ccui.Text:create()
    nameTx1:setFontName("font/gamefont.ttf")
    nameTx1:setFontSize(28)
    nameTx1:setAnchorPoint(cc.p(0, 0.5))
    nameTx1:setTextColor(COLOR_TYPE.ORANGE)
    nameTx1:enableOutline(COLOR_NAME_OUTLINE, 2)
    nameTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx1:setPosition(cc.p(200, 90))
    bg:addChild(nameTx1)

    local vsTx = ccui.Text:create()
    vsTx:setFontName("font/gamefont.ttf")
    vsTx:setFontSize(28)
    vsTx:setAnchorPoint(cc.p(0, 0.5))
    vsTx:enableOutline(COLOR_NAME_OUTLINE, 2)
    vsTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    vsTx:setPosition(cc.p(180, 90))
    bg:addChild(vsTx)

    local nameTx2 = ccui.Text:create()
    nameTx2:setFontName("font/gamefont.ttf")
    nameTx2:setFontSize(28)
    nameTx2:setAnchorPoint(cc.p(0, 0.5))
    nameTx2:setTextColor(COLOR_TYPE.ORANGE)
    nameTx2:enableOutline(COLOR_NAME_OUTLINE, 2)
    nameTx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx2:setPosition(cc.p(200, 90))
    bg:addChild(nameTx2)

    local infoTx = ccui.Text:create()
    infoTx:setFontName("font/gamefont.ttf")
    infoTx:setFontSize(26)
    infoTx:setAnchorPoint(cc.p(0, 0.5))
    infoTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    infoTx:setPosition(cc.p(130, 40))
    bg:addChild(infoTx)

    local reportBtn = ccui.Button:create("uires/ui/common/icon_replay.png")
    reportBtn:setScale(1.2)
    reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:clickReportBtn(index)
        end
    end)
    reportBtn:setPosition(cc.p(840, CELL_HEIGHT/2))
    bg:addChild(reportBtn)

    local obj = {
        bg = bg,
        headpicBg = headpicBg,
        headpic = headpic,
        winnerTx = winnerTx,
        nameTx1 = nameTx1,
        vsTx = vsTx,
        nameTx2 = nameTx2,
        infoTx = infoTx
    }
    return obj
end

function TotalBattleReportUI:createCellTypeTwo(index)
    local bg = ccui.ImageView:create("uires/ui/common/common_bg_3.png")
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(CELL_WIDTH, CELL_HEIGHT))

    local isWin = ccui.ImageView:create()
    isWin:ignoreContentAdaptWithSize(true)
    isWin:setPosition(cc.p(100, CELL_HEIGHT/2))
    bg:addChild(isWin)

    local line = ccui.ImageView:create("uires/ui/activity/xuxian.png")
    line:setScaleY(1.2)
    line:setPosition(cc.p(190, CELL_HEIGHT/2))
    bg:addChild(line)

    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    local headpicBg = headpicCell.awardBgImg
    headpicBg:setPosition(cc.p(300, CELL_HEIGHT/2))
    bg:addChild(headpicBg)

    local lvTx = ccui.Text:create()
    lvTx:setFontName("font/gamefont.ttf")
    lvTx:setFontSize(20)
    lvTx:setAnchorPoint(cc.p(1, 0.5))
    lvTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lvTx:setPosition(cc.p(88,15))
    headpicBg:addChild(lvTx)

    local isEnemy = ccui.ImageView:create("uires/ui/report/report_is_enemy.png")
    isEnemy:setPosition(cc.p(5, 80))
    headpicBg:addChild(isEnemy)

    local nameTx = ccui.Text:create()
    nameTx:setFontName("font/gamefont.ttf")
    nameTx:setFontSize(28)
    nameTx:setAnchorPoint(cc.p(0, 0.5))
    nameTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setPosition(cc.p(360, 90))
    bg:addChild(nameTx)

    local fightImg = ccui.ImageView:create("uires/ui/common/fightbg.png")
    fightImg:setPosition(cc.p(380, 40))
    bg:addChild(fightImg)

    local fightforceTx = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceTx:setScale(0.7)
    fightforceTx:setAnchorPoint(cc.p(0, 0.5))
    fightforceTx:setPosition(cc.p(400, 40))
    bg:addChild(fightforceTx)

    local vImg = ccui.ImageView:create("uires/ui/chat/chat_vip_small.png")
    vImg:setPosition(550, 90)
    bg:addChild(vImg)

    local vNum = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
    vNum:setAnchorPoint(cc.p(0, 0.5))
    vNum:setPosition(560, 90)
    bg:addChild(vNum)

    local timeTx = ccui.Text:create()
    timeTx:setFontName("font/gamefont.ttf")
    timeTx:setFontSize(30)
    timeTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    timeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    timeTx:setPosition(cc.p(660, CELL_HEIGHT/2))
    bg:addChild(timeTx)

    local reportBtn = ccui.Button:create("uires/ui/common/icon_replay.png")
    reportBtn:setScale(1.2)
    reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:clickReportBtn(index)
        end
    end)

    reportBtn:setPosition(cc.p(840, CELL_HEIGHT/2))
    bg:addChild(reportBtn)

    local obj = {
        bg = bg,
        isWin = isWin,
        headpicBg = headpicBg,
        headpic = headpicCell.awardImg,
        headframe = headpicCell.headframeImg,
        lvTx = lvTx,
        isEnemy = isEnemy,
        nameTx = nameTx,
        fightforceTx = fightforceTx,
        vImg = vImg,
        vNum = vNum,
        timeTx = timeTx,
        reportBtn = reportBtn
    }
    return obj
end

function TotalBattleReportUI:clickReportBtn(index)
    if self.currPage == PAGE.COMMEND then
        if self.datas[PAGE.COMMEND] then
            local data = self.commendData[index]
            local args = {
                id = data[3]
            }
            MessageMgr:sendPost("get_replay", "worldwar", json.encode(args), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    local data = jsonObj.data
                    if data and data.report then
                        local customObj = {
                            info = jsonObj.data.report.info,
                            enemy = jsonObj.data.report.enemy,
                            rand1 = jsonObj.data.report.rand1,
                            rand2 = jsonObj.data.report.rand2
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                BattleMgr:showTotalBattleReport(PAGE.COMMEND)
                            end, nil, GAME_UI.UI_TOTAL_BATTLE_REPORT)
                        end)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
                    end
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
                end
            end)
        end
    elseif self.currPage == PAGE.ARENA then
        if self.datas[PAGE.ARENA] then
            local dataNum = #self.datas[PAGE.ARENA]
            local data = self.datas[PAGE.ARENA][dataNum - index + 1]
            local args = {
                id = data[5]
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
                            BattleMgr:showTotalBattleReport(PAGE.ARENA)
                        end, nil, GAME_UI.UI_TOTAL_BATTLE_REPORT)
                    end)
                end
            end)
        end
    elseif self.currPage == PAGE.CITYCRAFT then
        if self.datas[PAGE.CITYCRAFT] then
            local dataNum = #self.datas[PAGE.CITYCRAFT]
            local data = self.datas[PAGE.CITYCRAFT][dataNum - index + 1]
            local args = {
                id = data.replay
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
                            BattleMgr:showTotalBattleReport(PAGE.CITYCRAFT)
                        end, nil, GAME_UI.UI_TOTAL_BATTLE_REPORT)
                    end)
                end
            end)
        end
    elseif self.currPage == PAGE.WORLDWAR then
        if self.datas[PAGE.WORLDWAR] then
            local dataNum = #self.datas[PAGE.WORLDWAR]
            local data = self.datas[PAGE.WORLDWAR][index]
            local args = {
                id = data.replay_id
            }
            MessageMgr:sendPost("get_replay", "worldwar", json.encode(args), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    local data = jsonObj.data
                    if data and data.report then
                        local customObj = {
                            info = jsonObj.data.report.info,
                            enemy = jsonObj.data.report.enemy,
                            rand1 = jsonObj.data.report.rand1,
                            rand2 = jsonObj.data.report.rand2
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                BattleMgr:showTotalBattleReport(PAGE.WORLDWAR)
                            end, nil, GAME_UI.UI_TOTAL_BATTLE_REPORT)
                        end)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
                    end
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC23"), COLOR_TYPE.RED)
                end
            end)
        end
    end
end

function TotalBattleReportUI:checkNewImg()
    self.newImgs[PAGE.COMMEND]:setVisible(false)
    self.newImgs[PAGE.ARENA]:setVisible(UserData:getUserObj():getSignByType("arena_report"))
    self.newImgs[PAGE.CITYCRAFT]:setVisible(UserData:getUserObj():getSignByType("country_fight_report"))
    self.newImgs[PAGE.WORLDWAR]:setVisible(UserData:getUserObj():getSignByType("worldwar_report"))
end

return TotalBattleReportUI