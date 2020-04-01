local LegionActivitySelRoleListUI = class("LegionActivitySelRoleListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj = require('script/app/obj/roleobj')

function LegionActivitySelRoleListUI:ctor(data,battleType,customObj,towerMergerNum,callBack)
    self.uiIndex = GAME_UI.UI_LEGIONACTIVITYSELROLELISTUI
    self.data = data
    self.roletab = {}
    self.battleType = battleType or BATTLE_TYPE.TRIAL
    self.customObj = customObj
    self.towerMergerNum = towerMergerNum  -- 剩余可雇佣的数量
    self.callBack = callBack
    self.cells = {}
end

function LegionActivitySelRoleListUI:onShow()
    self:update()
end
function LegionActivitySelRoleListUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivitySelRoleListUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titlebg = bgimg2:getChildByName('title_bg')
    self.noroleimg = bgimg2:getChildByName('norole_img')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_ROLELIST_TITLE'))
    local funcbtn = bgimg2:getChildByName('func_btn')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            
            if self.battleType == BATTLE_TYPE.TRIAL then
                local ownertab ,hidtab = self:inithire()
                local trialconf = GameData:getConfData('trial')[LegionMgr:calcTrialLv()]
                if #ownertab > 0 then
                    local args = {
                        owners = ownertab,
                        hids = hidtab
                    }
                    MessageMgr:sendPost('hire_mercenary','legion',json.encode(args),function (response)
                    
                        local code = response.code
                        local data = response.data
                        if code == 0 then
                            LegionMgr:setMercenaies(data.mercenaries)
                            local customObj = {
                                mercenaries = LegionMgr:getMercenaies()
                            }
                            customObj.trial_robot = self.customObj.trial_robot
                            BattleMgr:playBattle(BATTLE_TYPE.TRIAL, customObj, function ()
                                MainSceneMgr:showMainCity(function()                                   
                                    LegionMgr:showMainUI(function ()
                                        LegionMgr:showLegionActivityTrialUI()
                                    end)
                                end, nil, GAME_UI.UI_LEGIONACTIVITYTRIALUI)
                            end)
                        end    
                    end) 
                else
                    local customObj = {
                        mercenaries = {}
                    }
                    customObj.trial_robot = self.customObj.trial_robot
                    BattleMgr:playBattle(BATTLE_TYPE.TRIAL, customObj, function ()
                        MainSceneMgr:showMainCity(function()
                            LegionMgr:showMainUI(function ()
                                LegionMgr:showLegionActivityTrialUI()
                            end)
                        end, nil, GAME_UI.UI_LEGIONACTIVITYTRIALUI)
                    end)
                end

            elseif self.battleType == BATTLE_TYPE.TOWER then
                local ownertab ,hidtab = self:inithire()
                if #hidtab > self.towerMergerNum then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DESC11'), COLOR_TYPE.RED)
                    return
                end
                if #ownertab > 0 then
                    local args = {
                        owners = ownertab,
                        hids = hidtab,
                    }
                    MessageMgr:sendPost('hire_mercenary','tower',json.encode(args),function (response)
                    
                        local code = response.code
                        local data = response.data
                        if code == 0 then
                            self.customObj.mercenaries = data.mercenaries
                            BattleMgr:playBattle(BATTLE_TYPE.TOWER, self.customObj, function ()
                                MainSceneMgr:showMainCity(function()
                                    TowerMgr:showTowerMain()
                                end, nil, GAME_UI.UI_TOWER_MAIN)
                            end)
                        end    
                    end) 
                else
                    BattleMgr:playBattle(BATTLE_TYPE.TOWER, self.customObj, function ()
                        MainSceneMgr:showMainCity(function()
                            TowerMgr:showTowerMain()
                        end, nil, GAME_UI.UI_TOWER_MAIN)
                    end)
                end
            elseif self.battleType == BATTLE_TYPE.NEW_LEGION_TRIAL then
                if self.customObj.skipFight then
                    local ownertab ,hidtab = self:inithire()
                    if #ownertab > 0 then
                        local args = {
                            owners = ownertab,
                            hids = hidtab
                        }
                        MessageMgr:sendPost('hire_trial_mercenary','legion',json.encode(args),function (response)
                            local code = response.code
                            local data = response.data
                            if code == 0 then
                                LegionMgr:setMercenaies(data.mercenaries)
                                local customObj = {
                                    mercenaries = LegionMgr:getMercenaies(),
                                    node = self.root,
                                    rand1 = math.random(10000),
                                    rand2 = math.random(10000),
                                }
                                customObj.trial_robot = self.customObj.trial_robot
                                customObj.index = self.customObj.index
                                BattleMgr:showBattleCountDown(BATTLE_TYPE.NEW_LEGION_TRIAL, customObj, function (reportField, sig)
                                    local report = reportField.totalReport
                                    local starNum = 0
                                    local isWin = report.isWin
                                    if report.isWin then
                                        local costTime = math.floor(reportField.time)
                                        if costTime >= 0 and costTime <= 60 then
                                            starNum = 3
                                        elseif costTime > 60 and costTime <= 90 then
                                            starNum = 2
                                        elseif costTime >= 91 then
                                            starNum = 1
                                        end
                                    end
                                    local damageInfo = reportField:getDamageInfo()
                                    local args = {
                                        star = starNum,
                                        sig = sig,
                                        index = customObj.index,
                                        autofight = 1
                                    }
                                    MessageMgr:sendPost("trial_adventure_fight", "legion", json.encode(args), function (jsonObj)
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
                                            BattleMgr:showBattleResultWithoutBattlefield(isWin, displayAwards, starNum, nil, kingLvUpData, damageInfo)
                                            LegionMgr:hideLegionActivitySelRoleListUI()
                                            if self.callBack then
                                                self.callBack(starNum)
                                            end
                                        end
                                    end)
                                end)
                            end    
                        end) 
                    else
                        local customObj = {
                            mercenaries = {},
                            node = self.root,
                            rand1 = math.random(10000),
                            rand2 = math.random(10000),
                        }
                        customObj.trial_robot = self.customObj.trial_robot
                        customObj.index = self.customObj.index
                        BattleMgr:showBattleCountDown(BATTLE_TYPE.NEW_LEGION_TRIAL, customObj, function (reportField, sig)
                            local report = reportField.totalReport
                            local isWin = report.isWin
                            local starNum = 0
                            if report.isWin then
                                local costTime = math.floor(reportField.time)
                                if costTime >= 0 and costTime <= 60 then
                                    starNum = 3
                                elseif costTime > 60 and costTime <= 90 then
                                    starNum = 2
                                elseif costTime >= 91 then
                                    starNum = 1
                                end
                            end
                            local damageInfo = reportField:getDamageInfo()
                            local args = {
                                star = starNum,
                                sig = sig,
                                index = customObj.index,
                                autofight = 1
                            }
                            MessageMgr:sendPost("trial_adventure_fight", "legion", json.encode(args), function (jsonObj)
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
                                    BattleMgr:showBattleResultWithoutBattlefield(isWin, displayAwards, starNum, nil, kingLvUpData, damageInfo)
                                    LegionMgr:hideLegionActivitySelRoleListUI()
                                    if self.callBack then
                                        self.callBack(starNum)
                                    end
                                end
                            end)
                        end)
                    end
                else
                    local ownertab ,hidtab = self:inithire()
                    if #ownertab > 0 then
                        local args = {
                            owners = ownertab,
                            hids = hidtab
                        }
                        MessageMgr:sendPost('hire_trial_mercenary','legion',json.encode(args),function (response)
                            local code = response.code
                            local data = response.data
                            if code == 0 then
                                LegionMgr:setMercenaies(data.mercenaries)
                                local customObj = {
                                    mercenaries = LegionMgr:getMercenaies()
                                }
                                customObj.trial_robot = self.customObj.trial_robot
                                customObj.index = self.customObj.index
                                BattleMgr:playBattle(BATTLE_TYPE.NEW_LEGION_TRIAL, customObj, function ()
                                    MainSceneMgr:showMainCity(function()                                  
                                        LegionMgr:showMainUI(function ()
                                            LegionTrialMgr:showLegionTrialMainPannelUI(customObj.index)
                                        end)
                                    end, nil, GAME_UI.UI_LEGION_TRIAL_MAIN_PANNEL)
                                end)

                            end    
                        end) 
                    else
                        local customObj = {
                            mercenaries = {}
                        }
                        customObj.trial_robot = self.customObj.trial_robot
                        customObj.index = self.customObj.index
                        BattleMgr:playBattle(BATTLE_TYPE.NEW_LEGION_TRIAL, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                LegionMgr:showMainUI(function ()
                                    LegionTrialMgr:showLegionTrialMainPannelUI(customObj.index)
                                end)
                            end, nil, GAME_UI.UI_LEGION_TRIAL_MAIN_PANNEL)
                        end)
                    end
                end
            end
        end
    end)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_OK'))

    self.seltab = {}
    for i=1,2 do
        local arr = {}
        local frameNode = bgimg2:getChildByName('frame_'..i..'_node')
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
        frameNode:addChild(cell.awardBgImg)
        cell.awardImg:setVisible(false)
        arr.selectindex = 0
        arr.cell = cell
        self.seltab[i] = arr
    end
    self.sv = bgimg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function LegionActivitySelRoleListUI:update()
    
    self.objarr = {}
    self.noUseObj = {}

    local legiondat = GameData:getConfData('legion')
    local legionMercenaryOpenLevelLimit = tonumber(legiondat['legionMercenaryOpenLevelLimit'].value)
    self.legionMercenaryOpenLevelLimit = legionMercenaryOpenLevelLimit
    local roleJunZhuObj = RoleData:getMainRole()
    local junZhuLv = roleJunZhuObj:getLevel()

    self.num  = 0
    self.objNum = 0 
    self.noUseNum = 0
    for k, v in pairs(self.data.mercenaries) do   
        self.num = self.num + 1
        if v.level > junZhuLv + legionMercenaryOpenLevelLimit then  -- 无法雇佣
            self.noUseNum = self.noUseNum + 1
            self.noUseObj[self.noUseNum] = v
            v.isUse = false
        else
            self.objNum = self.objNum + 1
            self.objarr[self.objNum] = v
            v.isUse = true
        end
    end

    table.sort( self.noUseObj,function(a,b)
        return a.fight_force > b.fight_force
    end)

    table.sort( self.objarr,function(a,b)
        return a.fight_force > b.fight_force
    end)

    for i = 1,self.noUseNum,1 do
        table.insert(self.objarr,self.noUseObj[i])
    end

    self.selstate = {}
    for i=1,self.num do
       self:addCells(i)
       self.selstate[i] = 0
    end

    if self.num < 1 then
        self.noroleimg:setVisible(true)
    else
        self.noroleimg:setVisible(false)
    end
end

function LegionActivitySelRoleListUI:addCells(index)
    local node = cc.CSLoader:createNode("csb/legionactivityselrolelistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local icon_bg_img = bgimg:getChildByName("icon_bg_img")
    local no_use_img = icon_bg_img:getChildByName("no_use_img")
    no_use_img:setLocalZOrder(2)
    local frame_alpha_img = icon_bg_img:getChildByName("frame_alpha_img")
    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
    headCell.awardBgImg:setTouchEnabled(false)
    icon_bg_img:addChild(headCell.awardBgImg)
    headCell.awardBgImg:setPosition(cc.p(frame_alpha_img:getPosition()))
    self.roletab[index] = ccui.Widget:create()
    self.roletab[index]:addChild(bgimg)
    self.cells[index] = headCell
    self:updateCell(index)
    local bgimg = self.roletab[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if math.ceil(self.num/2)*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,math.ceil(self.num/2)*(contentsize.height+5)+20))
    end
    local posx = -1*(index%2)*(contentsize.width+4) + contentsize.width+6
    local posy = self.sv:getInnerContainerSize().height-math.ceil(index/2)*(5 + contentsize.height)-10 
    self.roletab[index]:setPosition(cc.p(posx,posy))
    self.sv:addChild(self.roletab[index])
end

function LegionActivitySelRoleListUI:updateCell(index)
    local bgimg = self.roletab[index]:getChildByName('bg_img')
    local haveselectimg = bgimg:getChildByName('haveselect_img')
    local obj = ClassRoleObj.new(self.objarr[index].hid, 0)
    obj:setPromoted(self.objarr[index].promote)
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.objarr[index].isUse == false then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_11'),self.legionMercenaryOpenLevelLimit), COLOR_TYPE.RED)
                return
            end
            if self.seltab[1].selectindex == 0 then
                self.seltab[1].selectindex = index
                self.selstate[index] = 1
                ClassItemCell:updateHero(self.seltab[1].cell, obj, 1)
                self.seltab[1].cell.awardImg:setVisible(true)
                haveselectimg:setVisible(true)
            elseif self.seltab[2].selectindex == 0 then
                self.seltab[2].selectindex = index
                self.selstate[index] = 2
                ClassItemCell:updateHero(self.seltab[2].cell, obj, 1)
                self.seltab[2].cell.awardImg:setVisible(true)
                haveselectimg:setVisible(true)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_6'), COLOR_TYPE.RED)
            end
        end
    end)

    ClassItemCell:updateHero(self.cells[index], obj, 1)
    local iconbg = bgimg:getChildByName('icon_bg_img')
    local namebg = bgimg:getChildByName('namebg_img')
    local nametx = namebg:getChildByName('name_tx')
    local soldierimg = namebg:getChildByName('soldiertype_img')
    if  self.objarr[index].talent > 0  then
        nametx:setString(obj:getName().. ' +' .. self.objarr[index].talent)
    else
        nametx:setString(obj:getName())
    end
    nametx:setTextColor(obj:getNameColor())
    soldierimg:loadTexture('uires/ui/common/soldier_'..obj:getSoldierId()..'.png')
    soldierimg:ignoreContentAdaptWithSize(true)    

    local lvtx = namebg:getChildByName('lv_tx')
    lvtx:setString(self.objarr[index].level)
    local titlenamebg = bgimg:getChildByName('name_title_bg')
    local alphabg = titlenamebg:getChildByName('alpha_bg')
    local masternametx = alphabg:getChildByName('name_tx')
    masternametx:setString(GlobalApi:getLocalStr('STR_JUNZHU')..'：'.. self.objarr[index].name) 

    local fightforceImg = bgimg:getChildByName('fightforce_img')
    local fightforcetx = bgimg:getChildByName('fightforce_tx')
    fightforcetx:setString('')
    local leftLabel = cc.LabelAtlas:_create(self.objarr[index].fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    leftLabel:setAnchorPoint(cc.p(0,0.5))
    leftLabel:setPosition(cc.p(0,0))
    fightforcetx:addChild(leftLabel)

    haveselectimg:setVisible(false)
    haveselectimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.selstate[index] = 0
            haveselectimg:setVisible(false)
            if self.seltab[1].selectindex == index then
                self.seltab[1].cell.awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
                self.seltab[1].cell.awardImg:setVisible(false)
                self.seltab[1].selectindex = 0  
            elseif self.seltab[2].selectindex == index then
                self.seltab[2].cell.awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
                self.seltab[2].cell.awardImg:setVisible(false)
                self.seltab[2].selectindex = 0
            end
        end
    end)

    -- 是否可用
    local noUseimg = iconbg:getChildByName('no_use_img')
    local lvLimitTx = bgimg:getChildByName('lv_limit_tx')
    if self.objarr[index].isUse == true then
        noUseimg:setVisible(false)
        lvLimitTx:setVisible(false)
        fightforceImg:setVisible(true)
        fightforcetx:setVisible(true)
    else
        noUseimg:setVisible(true)
        lvLimitTx:setVisible(true)
        fightforceImg:setVisible(false)
        fightforcetx:setVisible(false)
        lvLimitTx:setString(string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_10'),self.legionMercenaryOpenLevelLimit))
    end
end

function LegionActivitySelRoleListUI:inithire()
    local ownerstab = {}
    local hidstab = {}
    if self.seltab[1].selectindex > 0 then
        table.insert(ownerstab,self.objarr[self.seltab[1].selectindex].owner)
        table.insert(hidstab,self.objarr[self.seltab[1].selectindex].hid)
    end
    if self.seltab[2].selectindex > 0 then
        table.insert(ownerstab,self.objarr[self.seltab[2].selectindex].owner)
        table.insert(hidstab,self.objarr[self.seltab[2].selectindex].hid)
    end
    return ownerstab , hidstab
end
return LegionActivitySelRoleListUI