local WorldWarMyReplayUI = class("WorldWarMyReplayUI", BaseUI)

local PROMOTION_DESC = {
    [1] = string.format(GlobalApi:getLocalStr('PROMOTION_DESC_1'),16),
    [2] = string.format(GlobalApi:getLocalStr('PROMOTION_DESC_1'),8),
    [3] = GlobalApi:getLocalStr('PROMOTION_DESC_2'),
    [4] = GlobalApi:getLocalStr('PROMOTION_DESC_3'),
    [5] = GlobalApi:getLocalStr('PROMOTION_DESC_4'),
}
function WorldWarMyReplayUI:ctor(top32,records,replays)
    self.uiIndex = GAME_UI.UI_WORLDWARMYREPLAY
    self.cells = {}
    self.records = records
    self.top32 = top32
    self.replays = replays
end

function WorldWarMyReplayUI:getMyRecordsId(ntype,index)
    local recordsId = 0
    local temp = (index + index%2)/2
    local index16 = temp
    temp = (temp + temp%2)/2
    local index8 = temp + 16
    temp = (temp + temp%2)/2
    local index4 = temp + 24
    temp = (temp + temp%2)/2
    local index2 = temp + 28
    temp = (temp + temp%2)/2
    local index1 = temp + 30
    -- print(index1,index2,index4,index8,index16)
    if ntype == 1 then
        return index16,GlobalApi:getLocalStr('KNOCK_OUT_1')
    elseif ntype == 2 then
        return index8,GlobalApi:getLocalStr('KNOCK_OUT_2')
    elseif ntype == 3 then
        return index4,GlobalApi:getLocalStr('KNOCK_OUT_3')
    elseif ntype == 4 then
        return index2,GlobalApi:getLocalStr('KNOCK_OUT_4')
    elseif ntype == 5 then
        return index1,GlobalApi:getLocalStr('KNOCK_OUT_5')
    end
end

function WorldWarMyReplayUI:createCell(desc,recordsId,str,isWin,replayId)
    self.index = self.index + 1
    local cellNode = cc.CSLoader:createNode("csb/worldwarmyreplaycell.csb")
    local myReplayImg = cellNode:getChildByName('my_replay_img')
    local bgImg = myReplayImg:getChildByName('bg_img')
    local roundTx = myReplayImg:getChildByName('round_tx')
    local matchTx = myReplayImg:getChildByName('match_tx')
    local resultImg = myReplayImg:getChildByName('result_img')
    local resultTx = myReplayImg:getChildByName('result_tx')
    local replayBtn = myReplayImg:getChildByName('replay_btn')
    replayBtn:setVisible(false)
    local infoTx = replayBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('REPLAY_1'))
    bgImg:setVisible(self.index%2 == 1)
    replayBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if not replayId then
                return
            end
            WorldWarMgr:playReplay(replayId)
        end
    end)
    if not str then
        local players = self.top32
        local playerAid,playerBid = WorldWarMgr:getPlayerId(recordsId,self.records)
        local playerA,playerB = players[playerAid],players[playerBid]
        local player
        local myuid = UserData:getUserObj():getUid()
        if playerA.uid ~= myuid then
            player = playerA
        else
            player = playerB
        end
        roundTx:setString(desc)
        matchTx:setString(player.name..string.format(GlobalApi:getLocalStr('FU_1'),player.sid))
        if isWin == true then
            resultImg:loadTexture('uires/ui/arena/victory.png')
        else
            resultImg:loadTexture('uires/ui/arena/failure.png')
        end
        resultTx:setString('')
    else
        bgImg:loadTexture('uires/ui/common/common_tiao_mid_4.png')
        bgImg:setVisible(true)
        roundTx:setString('')
        matchTx:setString('')
        resultImg:setVisible(false)
        replayBtn:setVisible(false)
        resultTx:setString(str)
    end
    myReplayImg:removeFromParent(false)
    self.cellSv:addChild(myReplayImg,1,self.index + 1000)
    -- self.cells[i] = {reportImg = reportImg}
end

function WorldWarMyReplayUI:createCells(index,myIndex,desc,desc1,round)
    local riseId = self.records[index]
    local replays = self.replays[index]
    -- print(riseId,replays,myIndex,index)
    if not replays or riseId < 0 then
        return false
    end
    local isWin = false
    if riseId + 1 == myIndex then
        isWin = true
    end

    for i,v in ipairs(replays) do
        local win = false
        if v.win + 1 == myIndex then
            win  = true
        end
        self:createCell(desc1,index,nil,win,v.rid)
    end
    if isWin == true then
        self:createCell(desc1,nil,PROMOTION_DESC[round])
    elseif riseId + 1 ~= 0 then
        self:createCell(desc1,nil,desc)
        return false
    end
    return true
end

function WorldWarMyReplayUI:updatePanel()
    local myuid = UserData:getUserObj():getUid()
    local me = WorldWarMgr:getPlayerById(myuid,self.top32)
    self.index = 0
    if not me then
        self:createCell('',nil,GlobalApi:getLocalStr('KNOCK_OUT_0'),false)
    else
        local isEnd = true
        for i=1,5 do
            local index,desc = self:getMyRecordsId(i,me.index)
            if isEnd == true then
                isEnd = self:createCells(index,me.index,desc,string.format(GlobalApi:getLocalStr('KNOCKOUT_ROUND_DESC'),i),i)
            end
        end
    end
    -- self:updateListCell()
    local size = self.cellSv:getContentSize()
    if self.index > 6 then
        self.cellSv:setInnerContainerSize(cc.size(size.width,self.index * 68))
        for i=1,self.index do
            local img = self.cellSv:getChildByTag(1000 + i)
            if img then
                img:setPosition(cc.p(2,(self.index - i)*68))
            end
        end
    else
        self.cellSv:setInnerContainerSize(size)
        for i=1,self.index do
            local img = self.cellSv:getChildByTag(1000 + i)
            if img then
                img:setPosition(cc.p(2,size.height - i*68))
            end
        end
    end
    self.noReportImg:setVisible(self.index <= 0 )
    self.roundTx:setVisible(self.index > 0 )
    self.teamTx:setVisible(self.index > 0 )
    self.resultTx:setVisible(self.index > 0 )
end

function WorldWarMyReplayUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideMyReplay()
        end
    end)
    local bgImg = worldwarImg:getChildByName('bg_img')
    self.cellSv = bgImg:getChildByName('cell_sv')
    self.cellSv:setScrollBarEnabled(false)
    local titleBgImg = worldwarImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('MY_REPLAY'))
    self.noReportImg = worldwarImg:getChildByName('no_report_img')

    self.roundTx = bgImg:getChildByName('round_tx')
    self.roundTx:setString(GlobalApi:getLocalStr('ROUND_1'))
    self.teamTx = bgImg:getChildByName('team_tx')
    self.teamTx:setString(GlobalApi:getLocalStr('TEAM_2'))    
    self.resultTx = bgImg:getChildByName('result_tx')
    self.resultTx:setString(GlobalApi:getLocalStr('RESULT_1'))

    self:updatePanel()
end

return WorldWarMyReplayUI