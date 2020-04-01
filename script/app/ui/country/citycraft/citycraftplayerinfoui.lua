local CityCraftPlayerInfoUI = class("CityCraftPlayerInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CityCraftPlayerInfoUI:ctor(posName, roleInfo)
    self.uiIndex = GAME_UI.UI_CITYCRAFTPLAYERINFO
    self.roleInfo = roleInfo
    self.posName = posName
end

function CityCraftPlayerInfoUI:init()
    local infoBgImg = self.root:getChildByName("info_bg_img")
    local infoAlphaImg = infoBgImg:getChildByName("info_alpha_img")
    self:adaptUI(infoBgImg, infoAlphaImg)

    infoBgImg:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        CityCraftMgr:hideCityCraftPlayerInfo()
    end)

    local infoImg = infoAlphaImg:getChildByName("info_img")

    local myuid = UserData:getUserObj():getUid()
    local challengeBtn = infoImg:getChildByName("challenge_btn")
    local challengeLabel = challengeBtn:getChildByName("text")
    challengeLabel:setString(GlobalApi:getLocalStr("STR_CHALLENGE1"))
    if myuid == self.roleInfo.uid then
        challengeBtn:setBright(false)
        challengeBtn:setTouchEnabled(false)
        challengeLabel:enableOutline(cc.c3b(59, 59, 59), 1)
    else
        challengeBtn:addClickEventListener(function ()
            AudioMgr.PlayAudio(11)
            local isOpen,_,cityId,level = GlobalApi:getOpenInfo("citycraft")
            if not isOpen then
                if cityId then
                    local cityData = MapData.data[cityId]
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..
                        cityData:getName()..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
                    return
                end
                if level then
                    promptmgr:showSystenHint(level..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'), COLOR_TYPE.RED)
                    return
                end
            end
            if CityCraftMgr.challengeTimes <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("CHALLENGE_NOT_ENOUGH"), COLOR_TYPE.RED)
            else
                local obj = {
                    enemy = self.roleInfo.uid
                }
                MessageMgr:sendPost("challenge", "country", json.encode(obj), function (jsonObj)
                    if jsonObj.code == 0 then
                        local customObj = {
                            challengeUid = self.roleInfo.uid,
                            info = jsonObj.data.info,
                            enemy = jsonObj.data.enemy,
                            rand1 = jsonObj.data.rand1,
                            rand2 = jsonObj.data.rand2,
                            rand_pos = jsonObj.data.rand_pos,
                            rand_attrs = jsonObj.data.rand_attrs
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.CITYCRAFT, customObj, function (battleReportJson)
                            MainSceneMgr:showMainCity(function()
                                CityCraftMgr:showCityCraft(true)
                            end, nil, GAME_UI.UI_CITYCRAFTOFFICE)
                        end)
                    elseif jsonObj.code == 103 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("POSITION_CHANGE"), COLOR_TYPE.RED)
                    elseif jsonObj.code == 104 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("CHALLENGING_PLAYER"), COLOR_TYPE.RED)
                    elseif jsonObj.code == 105 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("NON_NORMAL_END"), COLOR_TYPE.RED)
                    end
                end)
            end
        end)
    end
    local roleNode = infoImg:getChildByName("role_node")
    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    roleNode:addChild(iconCell.awardBgImg)
    local obj = RoleData:getHeadPicObj(self.roleInfo.headpic)
    iconCell.awardImg:loadTexture(obj:getIcon())
    iconCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.roleInfo.headframe))
    if self.roleInfo.uid <= 1000000 then -- 机器人
        iconCell.awardBgImg:loadTexture(COLOR_FRAME[4])
    else
        iconCell.awardBgImg:loadTexture(COLOR_FRAME[self.roleInfo.quality])
    end
    iconCell.lvTx:setString('Lv.'..tostring(self.roleInfo.level))

    -- local headpicBg = infoImg:getChildByName("headpic_bg")
    -- local headpicIcon = headpicBg:getChildByName("icon")
    -- local obj = RoleData:getHeadPicObj(self.roleInfo.headpic)
    -- headpicIcon:setTexture(obj:getIcon())
    -- local lvImg = headpicBg:getChildByName("lv_img")
    -- local lvLabel = lvImg:getChildByName("text")
    -- lvLabel:setString(tostring(self.roleInfo.level))

    local nameLabel = infoImg:getChildByName("name_tx")
    nameLabel:setString("【" .. self.posName .. "】" .. self.roleInfo.un)

    local fightforceLabel = cc.LabelAtlas:_create(tostring(self.roleInfo.fight_force), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setScale(0.7)
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    fightforceLabel:setPosition(cc.p(210, 144))
    infoImg:addChild(fightforceLabel)

    local flagImg = infoImg:getChildByName("flag_img")
    local flagLabel = flagImg:getChildByName("text")
    flagLabel:setString(GlobalApi:getLocalStr("COUNTRY_NAME_" .. UserData:getUserObj():getCountry()))
end

return CityCraftPlayerInfoUI