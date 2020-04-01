local LegionWarMainUI = class("LegionWarMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionWarMainUI:ctor()
    self.uiIndex = GAME_UI.UI_LEGIONWAR_MAIN
    self.data = legionwardata
    self.wardata = LegionMgr:getLegionWarData()
end

function LegionWarMainUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgimg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    local closebtn = self.root:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarMainUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width,winSize.height))

    local helpbtn = self.root:getChildByName('help_btn')
    helpbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --print('helpbtn')
        end
    end)
    helpbtn:setPosition(cc.p(20,winSize.height-10))
    helpbtn:setVisible(false)

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.LEGION_WAR)
    btn:setPosition(cc.p(20 + btn:getContentSize().width/2,winSize.height- 10 - btn:getContentSize().height/2))
    self.root:addChild(btn)



    local awardbtn = self.root:getChildByName('award_btn')
    awardbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            print('awardbtn')
            LegionMgr:showLegionWarAwardsUI(self.data)
        end
    end)
    awardbtn:setPosition(cc.p(20,200))
    self.awardbtn = awardbtn

    local shopbtn = self.root:getChildByName('shop_btn')
    shopbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showShop(53,{min = 51,max = 54})
        end
    end)
    shopbtn:setPosition(cc.p( winSize.width - 20,200))

    local rankbtn = self.root:getChildByName('rank_btn')
    rankbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --LegionMgr:showLegionWarRankUI()
            if self.wardata.round == 1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC71'),COLOR_TYPE.RED)
            else
                RankingListMgr:showRankingListMain(8,nil,{8,9})
            end
        end
    end)
    rankbtn:setPosition(cc.p(winSize.width-20,10))

    local battlelistbtn = self.root:getChildByName('battle_list_btn')
    battlelistbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --print('battle_list_btn')
            LegionMgr:showLegionWarBattleListUI(self.data)
        end
    end)
    battlelistbtn:setPosition(cc.p(20,10))

    local titleimg = self.root:getChildByName('title_name_img')
    titleimg:setPosition(cc.p(winSize.width/2,winSize.height))

    local infobg = self.root:getChildByName('info_bg')
    infobg:setPosition(cc.p(winSize.width/2,winSize.height-120))

    self.legionnametx = infobg:getChildByName('legion_name_tx')
    self.legionflagimg = infobg:getChildByName('legion_flag_img')
    self.currankimg = infobg:getChildByName('rankcur_img')
    self.currankimg:setTouchEnabled(true)
    self.currankimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionWarRankInfoUI()
        end
    end)
    self.nextrankingimg = infobg:getChildByName('ranknext_img')
    self.nextrankingimg:setTouchEnabled(true)
    self.nextrankingimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionWarRankInfoUI()
        end
    end)
    self.curranktx = infobg:getChildByName('rankcur_tx')
    self.nextrankingtx = infobg:getChildByName('ranknext_tx')

    local expbarbg = infobg:getChildByName('exp_bar_bg')
    self.expbar = expbarbg:getChildByName('exp_bar')
    self.exptx = self.expbar:getChildByName('exp_tx')

    self.rankal = infobg:getChildByName('rank_al')
    self.ranktx = infobg:getChildByName('rank_tx')

    local desctx1 = infobg:getChildByName('desc_tx_1')
    desctx1:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC1'))
    local desctx2 = infobg:getChildByName('desc_tx_2')
    desctx2:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC2'))
    self.totaladdtx = infobg:getChildByName('num_tx_1')
    self.winratetx = infobg:getChildByName('num_tx_2')
    self.wintx = infobg:getChildByName('num_tx_3')

    local awardsbg = self.root:getChildByName('awards_bg')
    awardsbg:setPosition(cc.p(winSize.width/2,winSize.height/2-55))

    local awarddesctx = awardsbg:getChildByName('award_desc_tx')
    awarddesctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC8'))
    self.awardstab = {}
    for i=1,4 do
        self.awardstab[i] = awardsbg:getChildByName('node_'..i)
    end

    self.preparebg = self.root:getChildByName('prepare_pl')
    self.preparebg:setPosition(cc.p(winSize.width/2,-20))

    local addinfobg = self.preparebg:getChildByName('add_info_bg')

    local legionlvdesctx = addinfobg:getChildByName('legionlv_desc_tx')
    legionlvdesctx:setString(GlobalApi:getLocalStr('SETTING_INFO_GUILDLEVEL'))
    self.legionlvnumtx = addinfobg:getChildByName('legionlv_num_tx')
    local legionnumdesctx = addinfobg:getChildByName('legionnum_desc_tx')
    legionnumdesctx:setString(GlobalApi:getLocalStr('LEGION_DESC2'))
    self.legionnumnumtx = addinfobg:getChildByName('legionnum_num_tx')
    self.battletimenumtx = addinfobg:getChildByName('battletime_num_tx')
    self.funcbtn = self.root:getChildByName('func_btn')
    self.funcbtn:setPosition(cc.p(winSize.width/2,50))
    self.funcbtntx = self.funcbtn:getChildByName('btn_tx')
    self.funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local legionconf = GameData:getConfData('legion')
            if  self.wardata.newUser then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC73'), COLOR_TYPE.RED)
                return
            end
            if UserData:getUserObj():getLLevel() < tonumber(legionconf['legionWarMinJoinLevel'].value) then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionWarMinJoinLevel'].value), COLOR_TYPE.RED)
            else
                LegionMgr:showLegionWarBattleUI(self.data)
            end
        end
    end)

    self.battlepl = self.root:getChildByName('battle_pl')
    self.battlepl:setPosition(cc.p(winSize.width/2,-20))
    local battlebg = self.battlepl:getChildByName('battle_bg')
    self.battlelegionnametx1 = battlebg:getChildByName('legion_name_1')
    self.battlelegionnametx2 = battlebg:getChildByName('legion_name_2')
    self.battlelegionflagimg1 = battlebg:getChildByName('legion_flag_img_1')
    self.battlelegionflagimg2 = battlebg:getChildByName('legion_flag_img_2')
    self.battlelegionscoretx1 = battlebg:getChildByName('score_tx_1')
    self.battlelegionscoretx2 = battlebg:getChildByName('score_tx_2')

    local battledesctx = battlebg:getChildByName('desc_tx_1')
    battledesctx:setString('')
    self.battletimetx = battlebg:getChildByName('time_tx')
    if self.wardata.joined  and self.wardata.stage == 2 then
        self:reCheckMsg(self.battletimetx,'LEGION_WAR_DESC7')
    else
        self:reCheckMsg(self.battletimenumtx,'LEGION_WAR_DESC5')
    end
    self:update()
end

function LegionWarMainUI:onShow()
    self:update()
end
function LegionWarMainUI:update()
    self.wardata = LegionMgr:getLegionWarData()
    local selflegionwardata = self.wardata.ownLegion
    local enemylegionwardata = self.wardata.enemyLegion

    local iconConf = GameData:getConfData("legionicon")
    self.legionnametx:setString(selflegionwardata.name)
    self.legionnametx:setTextColor(COLOR_TYPE[iconConf[selflegionwardata.icon].nameColor])
    self.legionflagimg:loadTexture(iconConf[selflegionwardata.icon].icon)
    self.battlelegionnametx1:setString(selflegionwardata.name)
    self.battlelegionnametx1:setTextColor(COLOR_TYPE[iconConf[selflegionwardata.icon].nameColor])
    self.battlelegionflagimg1:loadTexture(iconConf[selflegionwardata.icon].icon)
    self.battlelegionscoretx1:setString(selflegionwardata.curScore)

    self.totaladdtx:setString(selflegionwardata.joinNum)
    self.wintx:setString(selflegionwardata.winNum)
    local rate = string.format("%.2f", (selflegionwardata.winNum*100/selflegionwardata.joinNum))..'%'
    if selflegionwardata.joinNum == 0 then
        rate = "0%"
    end
    self.winratetx:setString('('..GlobalApi:getLocalStr('LEGION_WAR_DESC6')..rate..")")

    local rankconf = GameData:getConfData('legionwarrank')
    local rankid =  LegionMgr:calcRank(selflegionwardata.score)
    self.expbar:setPercent(selflegionwardata.score*100/rankconf[rankid].maxScore)
    
    self.exptx:setString(selflegionwardata.score .."/"..rankconf[rankid].maxScore)
    if tonumber(selflegionwardata.curRank) == tonumber(-1) then
        self.rankal:setString('')
        self.ranktx:setString(GlobalApi:getLocalStr('RANKING_NO_INLIST'))
    else
        self.rankal:setString(selflegionwardata.curRank)
        self.ranktx:setString('')
    end
    
    self.curranktx:setString(rankconf[rankid].name)  
    self.currankimg:loadTexture("uires/ui/legionwar/legionwar_".. tostring(rankconf[rankid].icon))

    if rankid+1 >= #rankconf then      
        self.nextrankingtx:setString(rankconf[rankid].name)   
        self.nextrankingimg:loadTexture("uires/ui/legionwar/legionwar_".. tostring(rankconf[rankid].icon))
    else
        self.nextrankingimg:loadTexture("uires/ui/legionwar/legionwar_".. tostring(rankconf[rankid+1].icon))
        self.nextrankingtx:setString(rankconf[rankid+1].name)   
        local awardsconftab = DisplayData:getDisplayObjs(rankconf[rankid+1].award)
        for i=1,4 do
            if awardsconftab[i] then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awardsconftab[i],self.awardstab[i])
                awardsconftab[i]:setLightEffect(cell.awardBgImg)
                self.awardstab[i]:setScale(0.7)
            end
        end   
    end
    
    self.legionlvnumtx:setString(selflegionwardata.level.. GlobalApi:getLocalStr('LEGION_LV_DESC'))

    local legionconf = GameData:getConfData('legion')
    if self.wardata.joined  and self.wardata.stage == 2 then
        self.preparebg:setVisible(false)
        self.battlepl:setVisible(true)
        self.battlelegionnametx2:setString(enemylegionwardata.name)
        self.battlelegionflagimg2:loadTexture('uires/ui/legion/legion_'..enemylegionwardata.icon..'_jun.png')
        self.battlelegionscoretx2:setString(enemylegionwardata.curScore)
        --self:reCheckMsg(self.battletimetx,'LEGION_WAR_DESC7')
    else
        self.preparebg:setVisible(true)
        self.battlepl:setVisible(false)
        --self:reCheckMsg(self.battletimenumtx,'LEGION_WAR_DESC5')

        if tonumber(legionconf['legionWarMinJoinMembers'].value) <= selflegionwardata.memberCount then
            self.legionnumnumtx:setColor(COLOR_TYPE.GREEN)
            self.legionnumnumtx:setString(selflegionwardata.memberCount)
        else
            self.legionnumnumtx:setColor(COLOR_TYPE.RED)
            self.legionnumnumtx:setString('('..selflegionwardata.memberCount..'/'..legionconf['legionWarMinJoinMembers'].value..')')
        end
        if tonumber(legionconf['legionWarMinJoinLevel'].value) <= selflegionwardata.level then
            self.legionlvnumtx:setColor(COLOR_TYPE.GREEN)        
        else
            self.legionlvnumtx:setColor(COLOR_TYPE.RED)
        end
    end
    if self.wardata.joined then
        self.funcbtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(self.funcbtn)
        self.funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    else
        self.funcbtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(self.funcbtn)
        self.funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
    end  
    if self.wardata.stage == 1  then
        self.funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC3'))
    elseif self.wardata.stage == 2 then
        self.funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC4'))
    elseif self.wardata.stage == 3 then
        self.funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC59'))
    else
        self.funcbtntx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC3'))
    end

    local newImg = self.awardbtn:getChildByName('new_img')
    if newImg then
        newImg:setVisible(UserData:getUserObj():getSignByType('legion_fightnum'))
    end
    local newImg = self.funcbtn:getChildByName('new_img')
    if newImg then
        newImg:setVisible(UserData:getUserObj():getSignByType('legion_war_city'))
    end
end

function LegionWarMainUI:reCheckMsg(label,str)
    local time = self.wardata.stageEnd -GlobalData:getServerTime()
    Utils:createCDLabel(label,time,cc.c4b(237,236,191,255),COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,GlobalApi:getLocalStr(str),cc.c4b(194,163,97,255),COLOROUTLINE_TYPE.WHITE,25,function()
        MessageMgr:sendPost('get_mainpage_info','legionwar',"{}",function (response)
            local code = response.code
            local legionwardata = response.data
            if code == 0 then
                self.wardata = legionwardata
                self:update()
            elseif code == 101 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR1'), COLOR_TYPE.RED)
            elseif code == 102 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR2'), COLOR_TYPE.RED)
            elseif code == 103 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR3'), COLOR_TYPE.RED)
            end
        end)
    end)
end
return LegionWarMainUI