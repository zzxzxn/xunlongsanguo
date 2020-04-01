local WorldWarReportUI = class("WorldWarReportUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function WorldWarReportUI:ctor(data)
	self.uiIndex = GAME_UI.UI_WORLDWARREPORT
    self.data = data.replays
    self.cells = {}
end

function WorldWarReportUI:updateListCell()
    local index = 0
    local singleSize
    for i=1,#self.data do
        local cellNode = cc.CSLoader:createNode("csb/worldwarreportcell.csb")
        local reportImg = cellNode:getChildByName('report_img')
        local bgImg = reportImg:getChildByName('bg_img')
        local resultImg = reportImg:getChildByName('result_img')
        local nameTx = reportImg:getChildByName('name_tx')
        local scoreTx = reportImg:getChildByName('score_tx')
        local fightBgImg = reportImg:getChildByName('fight_bg_img')
        local fightforceTx = fightBgImg:getChildByName('fight_force_tx')
        local roleBgNode = reportImg:getChildByName('role_bg_node')
        local revengeBtn = reportImg:getChildByName('revenge_btn')
        local infoTx = revengeBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('REVENGE_1'))
        local replayBtn = reportImg:getChildByName('replay_btn')
        infoTx = replayBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('REPLAY_1'))
        bgImg:setVisible(i%2 == 1)
        nameTx:setString(self.data[i].name)
        scoreTx:setString(self.data[i].score_add)
        fightforceTx:setString(self.data[i].fight_force)
        revengeBtn:setVisible(self.data[i].revenged ~= 1)
        if self.data[i].attacker == 1 then
            if self.data[i].win == true then
                resultImg:loadTexture('uires/ui/worldwar/worldwar_yellow_a.png')
            else
                resultImg:loadTexture('uires/ui/worldwar/worldwar_blue_a.png')
            end
        else
            if self.data[i].win == true then
                resultImg:loadTexture('uires/ui/worldwar/worldwar_yellow_d.png')
            else
                resultImg:loadTexture('uires/ui/worldwar/worldwar_blue_d.png')
            end
        end

        local headConf = GameData:getConfData("settingheadicon")
        local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
        roleBgNode:addChild(headpicCell.awardBgImg)
        if self.data[i].enemy_id <= 1000000 then -- 机器人
            headpicCell.awardBgImg:loadTexture(COLOR_FRAME[4])
        else
            headpicCell.awardBgImg:loadTexture(COLOR_FRAME[self.data[i].quality])
        end
        headpicCell.awardImg:loadTexture(headConf[self.data[i].headpic].icon)
        headpicCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.data[i].headframe))

        reportImg:removeFromParent(false)
        singleSize = reportImg:getContentSize()
        reportImg:setPosition(cc.p(0,(index - i)*singleSize.height))
        self.reportContentWidget:addChild(reportImg)
        index = index + 1
        self.cells[i] = {reportImg = reportImg} 

        replayBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local replayId = self.data[i].replay_id
                printall(self.data[i])
                if not replayId then
                    return
                end
                WorldWarMgr:playReplay(replayId)
            end
        end)

        printall(self.data[i])
        revengeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                -- WorldWarMgr:rankFight(callback,uid,cash,revenge,replayid)
                -- WorldWarMgr:rankFight(callback,uid,cash,revenge,replayid)
                -- WorldWarMgr:playReplay(replayId)
                if tonumber(WorldWarMgr.battleTimes) >= WorldWarMgr.maxBattleTimes then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('E_STR_ARENA_NO_FREE_COUNT'),WorldWarMgr.maxBuyBattle),MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        WorldWarMgr:rankFight(i - 1,self.data[i].enemy_id,WorldWarMgr.maxBuyBattle,1)
                    end)
                else
                    WorldWarMgr:rankFight(i - 1,self.data[i].enemy_id,nil,1)
                end
            end
        end)
    end

    local size = self.reportSv:getContentSize()
    if singleSize then
        self.reportCellTotalHeight = 0
        self.noReportImg:setVisible(false)
        for i=1,index do
            self.reportCellTotalHeight = self.reportCellTotalHeight + singleSize.height
            self.cells[i].reportImg:setPosition(cc.p(0, singleSize.height/2 - self.reportCellTotalHeight))
        end
        local posY = size.height
        if self.reportCellTotalHeight > posY then
            posY = self.reportCellTotalHeight
        end
        self.reportSv:setInnerContainerSize(cc.size(size.width, posY))
        self.reportContentWidget:setPosition(cc.p(size.width/2, posY))
    else
        self.noReportImg:setVisible(true)
    end
end

function WorldWarReportUI:updatePanel()
   self:updateListCell()
end

function WorldWarReportUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideReport()
        end
    end)
    self.reportSv = worldwarImg:getChildByName('report_sv')
    self.reportContentWidget = ccui.Widget:create()
    self.reportSv:addChild(self.reportContentWidget)
    self.reportSv:setScrollBarEnabled(false)
    self.noReportImg = worldwarImg:getChildByName('no_report_img')
    local titleBgImg = worldwarImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('BATTLE_LIST'))

    self:updatePanel()
end

return WorldWarReportUI