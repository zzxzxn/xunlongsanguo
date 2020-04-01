local LegionLevelsBattleUI = class("LegionLevelsBattleUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local MAXCOPY = 6
function LegionLevelsBattleUI:ctor(progress,chapter)
    self.uiIndex = GAME_UI.UI_LEGIONLEVELSBATTLE
    self.data = LegionMgr:getLegionLevelsData()
    self.progress = progress
    self.chapter = chapter
    self.legioncopyconf = GameData:getConfData("legioncopy")[self.chapter]
    self.formationconf = GameData:getConfData("formation")
    self.legionconf = GameData:getConfData('legion')
end

function LegionLevelsBattleUI:onShow()
    self.data = LegionMgr:getLegionLevelsData()
    self:update()
end
function LegionLevelsBattleUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName("bg_img1")
    self:adaptUI(bgimg, bgimg1)
    local closebtn = bgimg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionLevelsBattleUI()
        end
    end)
    local titlebg = bgimg1:getChildByName('title_img')
    local titletx = titlebg:getChildByName('city_name_tx')
    titletx:setString(self.legioncopyconf.name)
    self.leftbg = bgimg1:getChildByName('left_bg_img')
    self.rightbg = bgimg1:getChildByName('right_bg_img')
    self.infotx = bgimg1:getChildByName('info_tx')
 
    local autofuncbtn = self.rightbg:getChildByName('auto_occupy_btn')
    local autofuncbtntx = autofuncbtn:getChildByName('info_tx')
    autofuncbtntx:setString(GlobalApi:getLocalStr('STR_AUTO_CHALLENGE'))
    autofuncbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if  self.legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy > 0 then
                local args = {
                    chapter = self.chapter,
                    progress = self.progress
                }
                MessageMgr:sendPost('get_enemy','legion',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local conf = GameData:getConfData("legioncopy")
                        local customObj = {
                            id = conf[data.chapter][tostring('formation'..data.progress)],
                            healths = data.healths,
                            node = self.root,
                            rand1 = math.random(10000),
                            rand2 = math.random(10000)
                        }
                        -- 初始化死亡人数
                        BattleMgr:initLegionDie()
                        BattleMgr:showBattleCountDown(BATTLE_TYPE.LEGION, customObj, function (reportField, sig)
                            local report = reportField.totalReport
                            local starNum = report.isWin and report.starNum or 1
                            local numtab = {}
                            for k, v in pairs(reportField.enemyMap) do
                                local obj = {
                                    pos = v.pos,
                                    -- hurt = v.heroObj:getHurtCount()
                                    hurt = v:getHurtCount()
                                }
                                table.insert(numtab, obj)
                            end
                            table.sort(numtab, function (a, b)
                                return a.pos < b.pos
                            end)
                            local hurtArr = {}
                            local posArr = {}
                            for k, v in ipairs(numtab) do
                                table.insert(hurtArr, v.hurt)
                                table.insert(posArr, v.pos)
                            end
                            local damageInfo = reportField:getDamageInfo()
							local roleMap = RoleData:getRoleMap()
							local heroTotalLv = 0
							for k, heroObj in pairs(roleMap) do
								heroTotalLv = heroTotalLv + heroObj:getLevel()
							end
                            local args = {
                                pos = posArr, 
                                damage = hurtArr,
                                sig = sig,
                                autofight = 1,
								ff = RoleData:getFightForce(),
								levels = heroTotalLv
                            }
                            MessageMgr:sendPost("fight", "legion", json.encode(args), function (jsonObj)
                                local code = jsonObj.code
                                if code == 0 then
                                    local lastLv = UserData:getUserObj():getLv()
                                    GlobalApi:parseAwardData(jsonObj.data.awards)
                                    local costs = jsonObj.data.costs
                                    if costs then
                                        GlobalApi:parseAwardData(costs)
                                    end
                                    local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                                    local kingLvUpData = {}
                                    kingLvUpData.lastLv = lastLv
                                    kingLvUpData.nowLv = UserData:getUserObj():getLv()
                                    local legioninfo = UserData:getUserObj():getLegionInfo()
                                    legioninfo.copy_count =  legioninfo.copy_count + 1
                                    LegionMgr:setLegionLevelsData(jsonObj.data.copy)
                                    if jsonObj.data.pass == 1 then
                                        LegionMgr:hideLegionLevelsUI()
                                        LegionMgr:hideLegionLevelsBattleUI()
                                    end
                                    BattleMgr:showBattleResultWithoutBattlefield(true, displayAwards, starNum, nil, kingLvUpData, damageInfo, true)
                                end
                            end)
                        end)
                    elseif code == 111 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_13'), COLOR_TYPE.RED)
                        LegionMgr:hideLegionLevelsBattleUI()
                        LegionMgr:hideLegionLevelsUI()
                        LegionMgr:hideLegionLevelsMainUI()
                        LegionMgr:showLegionLevelsMainUI()
                    elseif code == 116 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC18'), COLOR_TYPE.RED)
                        LegionMgr:hideLegionLevelsBattleUI()
                        LegionMgr:hideLegionLevelsUI()
                        LegionMgr:hideLegionLevelsMainUI()
                        self.data.chapter = data.chapter
                        self.data.progress = data.progress
                        self.data.healths = data.healths
                        LegionMgr:showLegionLevelsMainUI()
                    end
                end)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC10'), COLOR_TYPE.RED)
            end
        end
    end)
    local funcbtn = self.rightbg:getChildByName('occupy_btn')
    local funcbtntx = funcbtn:getChildByName('info_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_MANUAL_CHALLENGE'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if  self.legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy > 0 then
                local args = {
                    chapter = self.chapter,
                    progress = self.progress
                }
                MessageMgr:sendPost('get_enemy','legion',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local conf = GameData:getConfData("legioncopy")
                        local customObj = {
                                id = conf[data.chapter][tostring('formation'..data.progress)],
                                healths = data.healths
                            }
                        BattleMgr:playBattle(BATTLE_TYPE.LEGION, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                LegionMgr:showMainUI(function ()
                                    LegionMgr:showLegionLevelsMainUI()
                                end)
                            end, nil, GAME_UI.UI_LEGIONLEVELSMAIN)
                        end)
                    elseif code == 111 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_13'), COLOR_TYPE.RED)
                        LegionMgr:hideLegionLevelsBattleUI()
                        LegionMgr:hideLegionLevelsUI()
                        LegionMgr:hideLegionLevelsMainUI()
                        LegionMgr:showLegionLevelsMainUI()
                    elseif code == 116 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC18'), COLOR_TYPE.RED)
                        LegionMgr:hideLegionLevelsBattleUI()
                        LegionMgr:hideLegionLevelsUI()
                        LegionMgr:hideLegionLevelsMainUI()
                        self.data.chapter = data.chapter
                        self.data.progress = data.progress
                        self.data.healths = data.healths
                        LegionMgr:showLegionLevelsMainUI()
                    end
                end)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC10'), COLOR_TYPE.RED)
            end
        end
    end)
    local zhanBgImg = self.leftbg:getChildByName("zhan_bg_img")
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    forceLabel:setString('')

    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)
    local awardbg = self.rightbg:getChildByName('award_bg_img')
    local awardBgNode1 = awardbg:getChildByName('award_bg_1_node')
    local awardCell1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    awardBgNode1:addChild(awardCell1.awardBgImg)
    self.awardCell1 = awardCell1
    local titletx1 =awardbg:getChildByName('attack_tx')
    titletx1:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC3'))

    local awardBgNode2 = awardbg:getChildByName('award_bg_2_node')
    local awardCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    awardBgNode2:addChild(awardCell2.awardBgImg)
    self.awardCell2 = awardCell2
    local titletx2 =awardbg:getChildByName('kill_tx')
    titletx2:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC4'))

    local lvbgimg = self.leftbg:getChildByName('lv_bg_img')
    self.lvLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.lvLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.lvLabel:setPosition(cc.p(25.50, 25.50))
    self.lvLabel:setScale(0.7)
    lvbgimg:addChild(self.lvLabel)

    self.richText = xx.RichText:create()
    self.re1 = xx.RichTextLabel:create("",28, COLOR_TYPE.ORANGE)
    self.re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.re2 = xx.RichTextLabel:create("",28, COLOR_TYPE.WHITE)
    self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richText:addElement(self.re1)
    self.richText:addElement(self.re2)
    self.richText:setPosition(cc.p(231, 20))
    self.richText:setContentSize(cc.size(250, 40))
    self.richText:setVerticalAlignment('middle')
    self.richText:setAlignment('middle')
    self.rightbg:addChild(self.richText)
    self:update()
end

function LegionLevelsBattleUI:update()
    
    local monsterconf = GameData:getConfData('monster')
    --local namebg = self.leftbg:getChildByName('name_bg_img')
    local nametx = self.leftbg:getChildByName('name_tx')
    nametx:setString(self.legioncopyconf[tostring('name'..self.progress)])


    local spineAni = self.leftbg:getChildByTag(9999)
    if spineAni then
        spineAni:removeFromParent()
    end
    local formationid = self.legioncopyconf[tostring('formation'..self.progress)]
    local bosspos = self.formationconf[formationid].boss
    local bossid = self.formationconf[formationid][tostring('pos'..bosspos)]
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
        local spineAni = GlobalApi:createLittleLossyAniByName(monsterconf[bossid].url.."_display")
        if spineAni then
            spineAni:setOpacity(0)
            spineAni:setPosition(cc.p(170,100))
            self.leftbg:addChild(spineAni,1,9999)
            spineAni:getAnimation():play('idle', -1, 1)
            spineAni:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
        end
    end)))
    self.forceLabel:setString(self.formationconf[formationid].fightforce)
    self.lvLabel:setString(monsterconf[bossid].level)
    local award1 = {'user','legion',self.legionconf['legionCopyFightReward'].value}
    local displayobj1 = DisplayData:getDisplayObj(award1)
    ClassItemCell:updateItem(self.awardCell1, displayobj1, 1)
    self.awardCell1.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(displayobj1, false)
        end
    end)

    local award2 = {'user','legion',self.legionconf['legionCopyPassReward'].value}
    local displayobj2 = DisplayData:getDisplayObj(award2)
    ClassItemCell:updateItem(self.awardCell2, displayobj2, 1)
    self.awardCell2.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(displayobj2, false)
        end
    end)

    self.infotx:setString('')
    local tx1 = GlobalApi:getLocalStr('LEGION_LEVELS_DESC5')
    local tx2 = self.legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy
    self.re1:setString(tx1)
    self.re2:setString(tx2)
    self.richText:format(true)
end

return LegionLevelsBattleUI