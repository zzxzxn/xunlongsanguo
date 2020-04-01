local WorldWarReplayUI = class("WorldWarReplayUI", BaseUI)

function WorldWarReplayUI:ctor(id,top32,records,replays)
	self.uiIndex = GAME_UI.UI_WORLDWARSUPPORT
    self.id = id
    self.playerImgs = {}
    self.page = 1 -- TODO
    self.records = records
    self.top32 = top32
    self.replays = replays
end

function WorldWarReplayUI:updatePanel()
    local playerAid,playerBid = WorldWarMgr:getPlayerId(self.id,self.records)
    local allPlayers = self.top32
    self.players = {allPlayers[playerAid],allPlayers[playerBid]}
    for i=1,2 do
        self.playerImgs[i].nameTx:setString(self.players[i].name)
        self.playerImgs[i].serverTx:setString('（'..self.players[i].sid..GlobalApi:getLocalStr('FU')..'）')
        self.playerImgs[i].fightforceTx:setString(self.players[i].fight_force)
        self.playerImgs[i].checkImg:setVisible(self.page == i)
        local roleObj = RoleData:getRoleInfoById(tonumber(self.players[i].headpic))
        self.playerImgs[i].roleImg:loadTexture(roleObj:getIcon())
    end
    local level = UserData:getUserObj():getLv()
    local conf = GameData:getConfData('level')
    local num = conf[tonumber(level)].goldAward
    self.goldTx:setString(string.format(GlobalApi:getLocalStr('SUPPORT_CAN_GET'),num))
end

function WorldWarReplayUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideSupport()
        end
    end)
    self.noReportImg = worldwarImg:getChildByName('no_report_img')
    self.goldTx = worldwarImg:getChildByName('gold_tx')
    local titleTx = worldwarImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('SUPPORT'))

    for i=1,2 do
        local playerBgImg = worldwarImg:getChildByName('player_'..i..'_img')
        local roleBgImg = playerBgImg:getChildByName('role_bg_img')
        local roleImg = roleBgImg:getChildByName('role_img')
        local nameTx = playerBgImg:getChildByName('name_tx')
        local serverTx = playerBgImg:getChildByName('server_tx')
        local fightImg = playerBgImg:getChildByName('fight_img')
        local fightforceTx = fightImg:getChildByName('fightforce_tx')
        local kuangBgImg = playerBgImg:getChildByName('kuang_bg_img')
        local checkImg = kuangBgImg:getChildByName('check_img')
        local infoTx1 = playerBgImg:getChildByName('info_1_tx')
        local infoTx2 = playerBgImg:getChildByName('info_2_tx')
        infoTx1:setString(GlobalApi:getLocalStr('NAME'))
        infoTx2:setString(GlobalApi:getLocalStr('FU_NUM'))
        self.playerImgs[i] = {nameTx = nameTx,serverTx = serverTx,fightforceTx = fightforceTx,checkImg = checkImg,roleImg = roleImg}
        kuangBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
    end
    local supportBtn = worldwarImg:getChildByName('support_btn')
    local infoTx = supportBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    supportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:support(self.players[self.page].uid)
        end
    end)

    self:updatePanel()
end

return WorldWarReplayUI