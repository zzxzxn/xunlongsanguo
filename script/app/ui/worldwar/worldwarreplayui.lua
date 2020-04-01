local WorldWarReplayUI = class("WorldWarReplayUI", BaseUI)

function WorldWarReplayUI:ctor(id,top32,records,replays)
    print("id:"..id)
	self.uiIndex = GAME_UI.UI_WORLDWARREPLAY
    self.records = records
    self.top32 = top32
    self.replays = replays[id]
    self.id = id
    self.cells = {}
    self.playerInfoTxs = {}
end

function WorldWarReplayUI:createSpine()
    local players = self.top32
    local playerAid,playerBid = WorldWarMgr:getPlayerId(self.id,self.records)
    local playerA,playerB = players[playerAid],players[playerBid]
    if not self.spineAniA then
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if playerA.promote and playerA.promote[1] then
            promote = playerA.promote[1]
        end
        local heroConf = GameData:getConfData("hero")
        if heroConf[tonumber(playerA.max_hid)].camp == 5 then
            if playerA.weapon_illusion and playerA.weapon_illusion > 0 then
                weapon_illusion = playerA.weapon_illusion
            end
            if playerA.wing_illusion and playerA.wing_illusion > 0 then
                wing_illusion = playerA.wing_illusion
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        self.spineAniA = GlobalApi:createLittleLossyAniByRoleId(tonumber(playerA.max_hid), changeEquipObj)
        self.spineAniA:setPosition(cc.p(120,150))
        self.worldwarBgImg:addChild(self.spineAniA)
        self.spineAniA:getAnimation():play('idle', -1, 1)
    end
    if not self.spineAniB then
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if playerB.promote and playerB.promote[1] then
            promote = playerB.promote[1]
        end
        local heroConf = GameData:getConfData("hero")
        if heroConf[tonumber(playerB.max_hid)].camp == 5 then
            if playerB.weapon_illusion and playerB.weapon_illusion > 0 then
                weapon_illusion = playerB.weapon_illusion
            end
            if playerB.wing_illusion and playerB.wing_illusion > 0 then
                wing_illusion = playerB.wing_illusion
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        self.spineAniB = GlobalApi:createLittleLossyAniByRoleId(tonumber(playerB.max_hid), changeEquipObj)
        self.spineAniB:setPosition(cc.p(840,150))
        self.spineAniB:setScaleX(-1)
        self.worldwarBgImg:addChild(self.spineAniB)
        self.spineAniB:getAnimation():play('idle', -1, 1)
    end
end

function WorldWarReplayUI:getPos(i)
    local pos
    if #self.replays == 1 then
        pos = {cc.p(480,246)}
    elseif #self.replays == 2 then
        pos = {cc.p(480,284),cc.p(480,208)}
    elseif #self.replays == 3 then
        pos = {cc.p(480,322),cc.p(480,246),cc.p(480,170)}
    elseif #self.replays == 4 then
        pos = {cc.p(480,360),cc.p(480,284),cc.p(480,208),cc.p(480,132)}
    elseif #self.replays == 5 then
        pos = {cc.p(480,398),cc.p(480,322),cc.p(480,246),cc.p(480,170),cc.p(480,94)}
    end
    return pos[i]
end
function WorldWarReplayUI:updatePanel()
    local players = self.top32
    local playerAid,playerBid = WorldWarMgr:getPlayerId(self.id,self.records)
    local playerA,playerB = players[playerAid],players[playerBid]
    local numA = 0
    local numB = 0
    print("playerAid:"..playerAid)
    print("playerBid:"..playerBid)
    for i=1,5 do
        if self.replays[i] then
            self.cells[i].cellImg:setVisible(true)
            self.cells[i].numTx:setString(i)
            self.cells[i].cellImg:setPosition(self:getPos(i))
            if self.replays[i].win + 1 == playerAid then
                self.cells[i].cellImg:loadTexture('uires/ui/worldwar/worldwar_red_bg.png')
                self.cells[i].victoryImg:loadTexture('uires/ui/worldwar/worldwar_red_victory.png')
                self.cells[i].nameTx:setString(playerA.name)
                self.cells[i].serverTx:setString(playerA.sid..' '..GlobalApi:getLocalStr('FU'))
                numA = numA + 1
            else
                self.cells[i].cellImg:loadTexture('uires/ui/worldwar/worldwar_blue_bg.png')
                self.cells[i].victoryImg:loadTexture('uires/ui/worldwar/worldwar_blue_victory.png')
                self.cells[i].nameTx:setString(playerB.name)
                self.cells[i].serverTx:setString(playerB.sid..' '..GlobalApi:getLocalStr('FU'))
                numB = numB + 1
            end
            self.cells[i].replayBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local replayId = self.replays[i].rid
                    WorldWarMgr:playReplay(replayId)
                end
            end)
        else
            self.cells[i].cellImg:setVisible(false)
        end
    end
    self.playerInfoTxs[1].playerNameTx:setString(playerA.name)
    self.playerInfoTxs[2].playerNameTx:setString(playerB.name)
    self.playerInfoTxs[1].serverTx:setString(playerA.sid..' '..GlobalApi:getLocalStr('FU'))
    self.playerInfoTxs[2].serverTx:setString(playerB.sid..' '..GlobalApi:getLocalStr('FU'))

    self:createSpine()

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(520, 30))
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    local re = xx.RichTextLabel:create(numA..' ',60,COLOR_TYPE.RED)
    re:setStroke(COLOROUTLINE_TYPE.RED, 1)
    local re1 = xx.RichTextLabel:create(' :',60,COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    local re2 = xx.RichTextLabel:create(' '..numB,60,COLOR_TYPE.BLUE)
    re2:setStroke(COLOROUTLINE_TYPE.BLUE, 1)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(480,490))
    self.worldwarBgImg:addChild(richText)
end

function WorldWarReplayUI:init()
    self.worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local winSize = cc.Director:getInstance():getVisibleSize()

	local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideReplay()
        end
    end)

    for i=1,5 do
        local cellImg = self.worldwarBgImg:getChildByName('cell_'..i..'_img')
        local roundTx = cellImg:getChildByName('round_tx')
        local numTx = cellImg:getChildByName('num_tx')
        local nameTx = cellImg:getChildByName('name_tx')
        local serverTx = cellImg:getChildByName('server_tx')
        local victoryImg = cellImg:getChildByName('victory_img')
        local replayBtn = cellImg:getChildByName('replay_btn')
        self.cells[i] = {cellImg = cellImg,roundTx = roundTx,numTx = numTx,nameTx = nameTx,serverTx = serverTx,victoryImg = victoryImg,
                        replayBtn = replayBtn}
    end
    for i=1,2 do
        local playerNameTx = self.worldwarBgImg:getChildByName('player_name_'..i..'_tx')
        local serverTx = self.worldwarBgImg:getChildByName('server_'..i..'_tx')
        self.playerInfoTxs[i] = {playerNameTx = playerNameTx,serverTx = serverTx}
    end
    local bgImg = self.root:getChildByName('bg_img')
    local titleBgImg = self.root:getChildByName('title_bg_img')
    self.worldwarBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    titleBgImg:setPosition(cc.p(winSize.width/2,winSize.height))
    self:updatePanel()
end

return WorldWarReplayUI