local ArenaReportCell = class("ArenaReportCell")
local ClassItemCell = require('script/app/global/itemcell')

function ArenaReportCell:ctor(reportArr, index)
    self.width = 824
    self.height = 80
    self.index = index
    self:initCell(reportArr)
end

function ArenaReportCell:initCell(reportArr)
    local bgImg = ccui.ImageView:create()
    if self.index%2 == 0 then
        bgImg:loadTexture("uires/ui/common/bg1_alpha.png")
    else
        bgImg:loadTexture("uires/ui/common/common_bg_10.png")
    end
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(self.width, self.height))

    local time = reportArr[1]
    local win = reportArr[2] == 1
    local uid = reportArr[3]
    local rankChange = tostring(reportArr[4])
    local name
    local headpic
    local level
    local quality
    local reportId
    local headframe
    if reportArr[12] then
        reportId = reportArr[5]
        name = reportArr[6]
        headpic = tonumber(reportArr[7])
        level = tostring(reportArr[8])
        quality = reportArr[9]
        headframe = reportArr[12]
    else
        name = reportArr[5]
        headpic = tonumber(reportArr[6])
        level = tostring(reportArr[7])
        quality = reportArr[8]
        headframe = reportArr[11]
    end

    local flagImg
    if win then
        flagImg = cc.Sprite:create("uires/ui/arena/victory.png")
    else
        flagImg = cc.Sprite:create("uires/ui/arena/failure.png")
    end
    flagImg:setPosition(cc.p(50, 40))
    bgImg:addChild(flagImg)

    -- 排名变化
    local changeImg
    local changeLabel = cc.Label:createWithTTF(rankChange, "font/gamefont.ttf", 23)
    changeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    if win then
        changeImg = cc.Sprite:create("uires/ui/common/arrow_up1.png")
        changeLabel:setTextColor(COLOR_TYPE.GREEN)
        changeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    else
        changeImg = cc.Sprite:create("uires/ui/common/arrow_down1.png")
        changeLabel:setTextColor(COLOR_TYPE.RED)
        changeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    end
    changeImg:setPosition(cc.p(110, 55))
    bgImg:addChild(changeImg)
    changeLabel:setPosition(cc.p(110, 20))
    bgImg:addChild(changeLabel)

    -- 头像
    local headConf = GameData:getConfData("settingheadicon")
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    bgImg:addChild(headpicCell.awardBgImg)
    headpicCell.awardBgImg:setScale(0.7)
    headpicCell.awardBgImg:setPosition(cc.p(265, 40))
    if uid <= 1000000 then -- 机器人
        headpicCell.awardBgImg:loadTexture(COLOR_FRAME[4])
    else
        headpicCell.awardBgImg:loadTexture(COLOR_FRAME[quality])
    end
    headpicCell.awardImg:loadTexture(headConf[headpic].icon)
    headpicCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(headframe))
    headpicCell.headframeImg:setVisible(true)

    -- 姓名
    local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameLabel:setString(name)
    nameLabel:setPosition(cc.p(305, 55))
    bgImg:addChild(nameLabel)

    -- 等级图标
    local lvSp = cc.Sprite:create("uires/ui/common/lv_art.png")
    lvSp:setPosition(cc.p(322, 25))
    bgImg:addChild(lvSp)
    -- 等级
    local lvLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    lvLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    lvLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lvLabel:setString(tostring(level))
    lvLabel:setPosition(cc.p(338, 25))
    bgImg:addChild(lvLabel)

    -- 时间
    local timeLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    timeLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    timeLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    timeLabel:setPosition(cc.p(520, 40))
    if GlobalData:getServerTime() - time > 86400 then
        timeLabel:setString(GlobalApi:getLocalStr("STR_ONEDAY_BEFORE"))
    else
        timeLabel:setString(Time.date("%H:%M:%S", time))
    end
    bgImg:addChild(timeLabel)

    -- 战报
    if reportId then
        local replayBtn = ccui.Button:create("uires/ui/common/icon_replay.png")
        replayBtn:setScale(1.2)
        replayBtn:setPosition(cc.p(700, 40))
        replayBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    id = reportId
                }
                MessageMgr:sendPost('get', 'replay', json.encode(args), function (jsonObj)
                    if jsonObj.code == 0 then
                        local customObj = {
                            info = jsonObj.data.info,
                            enemy = jsonObj.data.enemy,
                            rand1 = jsonObj.data.rand1,
                            rand2 = jsonObj.data.rand2
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function (battleReportJson)
                            MainSceneMgr:showMainCity(function()
                                ArenaMgr:showArenaV2(battleReportJson)
                            end, nil, GAME_UI.UI_ARENA_V2)
                        end)
                    end
                end)
            end
        end)
        bgImg:addChild(replayBtn)
    end
    self.panel = bgImg
end

function ArenaReportCell:getPanel()
    return self.panel
end

function ArenaReportCell:getSize()
    return self.width, self.height
end

function ArenaReportCell:setPosition(pos)
    self.panel:setPosition(pos)
end

return ArenaReportCell
