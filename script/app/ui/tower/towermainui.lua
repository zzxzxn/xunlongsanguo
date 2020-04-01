local TowerUI = class("TowerUI", BaseUI)
local attconf =GameData:getConfData('attribute')
function TowerUI:ctor(data,stype)
  self.uiIndex = GAME_UI.UI_TOWER_MAIN
  self.data = data
  self.stype = stype
end

function TowerUI:init()
    local basnode = self.root:getChildByName('base_node')
    local bgimg = basnode:getChildByName("bg_img")
    local bgimg1 = basnode:getChildByName('bg_img1')
    local bigbg2 = basnode:getChildByName('bg_img2')

    local bgimg2 = bgimg1:getChildByName('bg_img2')
    local closebtn = bgimg1:getChildByName('closebtn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideTowerMain()
        end
    end)
    local winSize = cc.Director:getInstance():getWinSize()
    basnode:setPosition(cc.p(winSize.width/2,winSize.height/2))
    closebtn:setPosition(cc.p(closebtn:getPositionX()+(winSize.width-960)/2,closebtn:getPositionY()+(winSize.height-640)/2))

    local Image_35 = self.root:getChildByName('Image_35')
    Image_35:setPosition(cc.p(10,winSize.height-10))

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.TOWER)
    btn:setPosition(cc.p(winSize.width - 120,winSize.height - 50))
    self.root:addChild(btn)

    -- 3个按钮
    local shop = self.root:getChildByName('shop')
    shop:setPosition(cc.p(winSize.width - 10,10))
    shop:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showShop(21,{min = 21,max = 22},self.data.max_star or 0)
        end
    end)

    local rank = self.root:getChildByName('rank')
    rank:setPosition(cc.p(winSize.width - (shop:getContentSize().width + 0) - 10,10))
    rank:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain(3)
        end
    end)

    local group = self.root:getChildByName('group')
    group:setPosition(cc.p(winSize.width - (shop:getContentSize().width + 0) * 2 - 10,10))
    group:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 军团是否开放
            local legionConf = GameData:getConfData('legion')
            local needLv = tonumber(legionConf['legionTrialOpenLevel'].value)
            local open = GlobalApi:getOpenInfo('legion')
            if open == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DESC7'), COLOR_TYPE.RED)
                return
            end
            -- 是否加入军团
            if UserData:getUserObj().lid == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DESC8'), COLOR_TYPE.RED)
                return
            end

            -- 军团等级是否到2级
            if UserData:getUserObj().lid ~= 0 and UserData:getUserObj().llevel < needLv then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_DESC9'),needLv), COLOR_TYPE.RED)
                return
            end

            local remainMerNum = tonumber(GlobalApi:getGlobalValue("towerHireCount")) - self.data.hire_mercenary_num
            if remainMerNum <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DESC10'), COLOR_TYPE.RED)
                return
            end
            
            if self.data.failed == 0 and ((self.data.cur_floor < self:getMaxLvcount()) or (self.data.cur_floor == self:getMaxLvcount() and self.data.cur_room < 4 ))  then
            else
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('TOWER_TALK_3'),(self.data.cur_floor-1)*3+self.data.cur_room-1), COLOR_TYPE.RED)
                return
            end

            local attarr = {}
            for i= 1,#attconf do
                attarr[i] =  self.data.attrs[tostring(i)]  or 0
            end
            local cur_floor = (self.data.cur_floor-1)*3+self.data.cur_room
            local customObj = {
                id = 10000+(self.data.cur_floor-1)*3+self.data.cur_room,
                levelType = (self.data.cur_floor-1)%2 +1,
                attrs = attarr,
                cur_floor = cur_floor,
                cur_room = self.data.cur_room
            }
            LegionMgr:showLegionActivitySelRoleListTowerUI(BATTLE_TYPE.TOWER,customObj,remainMerNum)
        end
    end)

    local redBg = group:getChildByName('red_bg')
    local num = redBg:getChildByName('num')
    self.groupNum = num

    -- 塔币
    local rightBg = self.root:getChildByName('right_bg')
    rightBg:setPosition(cc.p(winSize.width,150))
    
    self.infoTowerlabel = {}

    self.infoTowerRichtext = xx.RichText:create()
    self.infoTowerRichtext:setName("info_tower_richtext")
    self.infoTowerRichtext:setContentSize(cc.size(800, 40))
    self.infoTowerlabel[1] = xx.RichTextLabel:create('', 24, COLOR_TYPE.ORANGE)
    self.infoTowerlabel[1]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    self.infoTowerlabel[2] = xx.RichTextImage:create('uires/ui/res/res_tower.png')

    self.infoTowerlabel[3] = xx.RichTextLabel:create('', 24, COLOR_TYPE.WHITE)
    self.infoTowerlabel[3]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    self.infoTowerRichtext:addElement(self.infoTowerlabel[1])
    self.infoTowerRichtext:addElement(self.infoTowerlabel[2])
    self.infoTowerRichtext:addElement(self.infoTowerlabel[3])

    self.infoTowerRichtext:setAlignment('right')
    self.infoTowerRichtext:setVerticalAlignment('middle')

    self.infoTowerRichtext:setAnchorPoint(cc.p(1,0.5))
    self.infoTowerRichtext:setPosition(cc.p(winSize.width,155))
    self.root:addChild(self.infoTowerRichtext)
    self.infoTowerRichtext:format(true)
    --
    local descnode = basnode:getChildByName('desc_node')
    local descbg = descnode:getChildByName('desc_bg')
    descbg:setPositionX(winSize.width - 10 - (winSize.width - 960)/2)
    self.descarr = {}
    for i=1,3 do
        local arr = {}
        local bg = descbg:getChildByName('desc_'..i..'_pl')
        arr.desctx = bg:getChildByName('desc_1_tx')
        arr.numtx = bg:getChildByName('awardnum_tx')
        self.descarr[i]= arr
    end
    local bgimg3node = bgimg1:getChildByName('bg_img_3_node')
    local bgimg3 = bgimg3node:getChildByName('bg_img_3')
    local bgimg4 = bgimg3:getChildByName('bg_img_4')
    bgimg3:ignoreContentAdaptWithSize(false)
    bgimg4:ignoreContentAdaptWithSize(false)
    bgimg3:setContentSize(cc.size(bgimg3:getContentSize().width+(winSize.width-960),bgimg3:getContentSize().height))
    bgimg3node:setPosition(cc.p((960-winSize.width)/2,bgimg3node:getPositionY()+(640-winSize.height)/2))
    bgimg4:setContentSize(cc.size(bgimg4:getContentSize().width+(winSize.width-960),bgimg4:getContentSize().height))
    local autobtnnode = bgimg1:getChildByName('autofight_btn_node')
    self.autobtn = autobtnnode:getChildByName('autofight_btn')
    self.autobtn:loadTextureNormal('uires/ui/tower/tower_autofight.png')
    self.autobtn:ignoreContentAdaptWithSize(true)
    self.autobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --TowerMgr:setTowerAction(true)
            TowerMgr:setTowerShowAttReward(true)
            TowerMgr:showTowerAutoFight(self.data.cur_floor,self.data.cur_room)
            self.autobtn:setTouchEnabled(false)
        end
    end)

    self.autobtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
        cc.ScaleTo:create(0.3, 1.1),
        cc.ScaleTo:create(0.3, 1))
    ))

    self.attAddBtn = autobtnnode:getChildByName('att_add_btn')
    self.attAddBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:showAttReward(self.data.reward,self.data.refresh_num,self.data,true)
        end
    end)


    autobtnnode:setPosition(cc.p(55-(winSize.width-960)/2,autobtnnode:getPositionY()+(640-winSize.height)/2 - 130))
    local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]
    bgimg4:getChildByName('freereset_btn'):setVisible(false)
    bgimg4:getChildByName('cash_bg'):setVisible(false)
    bgimg4:getChildByName('reset_btn'):setVisible(false)
    bgimg4:getChildByName('reset_cost_tx'):setVisible(false)
    --[[self.freeresetbtn = bgimg4:getChildByName('freereset_btn')
    local freeresetbtntx = self.freeresetbtn:getChildByName('btn_tx')
    freeresetbtntx:setString(GlobalApi:getLocalStr('TOWER_REFRESH'))  
    self.freeresetbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.data.reset >= vipconf['towerReset'] then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_DESC_3'), COLOR_TYPE.RED)
                return
            end
            if self.data.failed == 1 or ((self.data.cur_floor == self:getMaxLvcount() and self.data.cur_room > 3 ))then
                self:Reset(false)
            else
              promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_RESET_NO'), COLOR_TYPE.GREEN)
            end
        end
    end)
    self.cashbg = bgimg4:getChildByName('cash_bg')
    self.resetbtn = bgimg4:getChildByName('reset_btn')
    local resetbtntx = self.resetbtn:getChildByName('btn_tx')
    resetbtntx:setString(GlobalApi:getLocalStr('TOWER_CASHREFRESH'))  
    self.resetbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then         
            if self.data.reset >= vipconf['towerReset'] then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_DESC_3'), COLOR_TYPE.RED)
                return
            end
            local conf = GameData:getConfData('buy')[tonumber(self.data.reset+1)]
            if self.data.failed == 1 or ((self.data.cur_floor == self:getMaxLvcount() and self.data.cur_room > 3 )) then
                local str = string.format(GlobalApi:getLocalStr('TOWER_DESC_4'),conf.towerReset)
                    UserData:getUserObj():cost('cash',conf.towerReset,function()
                        self:Reset(true)
                    end,true,str)
            else
               promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_RESET_NO'), COLOR_TYPE.GREEN)
            end
        end
    end)
    --]]
    self.infolabel = {}
    
    local attdescinfo = bgimg4:getChildByName('desc_info_tx')
    attdescinfo:setString('')
    self.inforichtext = xx.RichText:create()
    self.inforichtext:setContentSize(cc.size(240, 60))
    self.infolabel[1] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[1]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.infolabel[2] = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
    self.infolabel[3] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[3]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.infolabel[4] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[4]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.infolabel[5] = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
    self.infolabel[6] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[6]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.infolabel[7] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[7]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    self.infolabel[8] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[8]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.infolabel[9] = xx.RichTextLabel:create('', 22, COLOR_TYPE.ORANGE)
    self.infolabel[10] = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')

    self.inforichtext:addElement(self.infolabel[8])
    self.inforichtext:addElement(self.infolabel[10])
    self.inforichtext:addElement(self.infolabel[9])
    self.inforichtext:addElement(self.infolabel[1])
    self.inforichtext:addElement(self.infolabel[2])
    self.inforichtext:addElement(self.infolabel[3])
    self.inforichtext:addElement(self.infolabel[4])
    self.inforichtext:addElement(self.infolabel[5])
    self.inforichtext:addElement(self.infolabel[6])
    self.inforichtext:addElement(self.infolabel[7])

    self.inforichtext:setAnchorPoint(cc.p(0,0.5))
    self.inforichtext:setPosition(cc.p(0,3))
    attdescinfo:addChild(self.inforichtext,9527)
    self.inforichtext:setVisible(true)

    self.atttab = {}
    --self.resetcost = bgimg4:getChildByName('reset_cost_tx')

    --self.freeresetbtn:setPosition(cc.p(self.freeresetbtn:getPositionX()+(winSize.width-960),60))
    --self.resetbtn:setPosition(cc.p(self.resetbtn:getPositionX()+(winSize.width-960),60))
    --self.resetcost:setPosition(cc.p(self.resetcost:getPositionX()+(winSize.width-960),60))
    --self.cashbg:setPosition(cc.p(self.cashbg:getPositionX()+(winSize.width-960),60))

    local attpl = bgimg4:getChildByName('att_bg')  
    self.attlabeltab = {}
    for i=1,8 do
        self.attlabeltab[i] = attpl:getChildByName('att_desc_'..i..'_tx')
    end
    self.enemytab = {}
    self.norpl = bgimg2:getChildByName('nor_pl')
    self.failedpl  = bgimg2:getChildByName('failed_pl')
    local failedbg = self.failedpl:getChildByName('failed_bg')
    local npc = ccui.ImageView:create('uires/ui/yindao/yindao_5.png')
    npc:setPosition(cc.p(300, -30))
    failedbg:addChild(npc)

    local talkfimg = failedbg:getChildByName('talk_img')
    self.talkftx = talkfimg:getChildByName('talk_tx')
    self.talkftx:ignoreContentAdaptWithSize(false)
    self.talkftx:setTextAreaSize(cc.size(120,80))
    for i=1,3 do
        local enemyatt = {}
        enemyatt.enemybg = self.norpl:getChildByName('enemy_'..i ..'_bg')
        enemyatt.nameimg = self.norpl:getChildByName('name_'..i..'_img')
        enemyatt.nametx =  enemyatt.nameimg:getChildByName('name_tx')
        enemyatt.pl =  enemyatt.nameimg:getChildByName('info_pl')
        enemyatt.passimg = enemyatt.pl:getChildByName('pass_img')
        enemyatt.talkbg =  enemyatt.nameimg:getChildByName('talk_img')
        enemyatt.talktx = enemyatt.talkbg:getChildByName('talk_tx')
        enemyatt.talktx:ignoreContentAdaptWithSize(false)
        enemyatt.talktx:setTextAreaSize(cc.size(120,80))
        local stararr = {}
        for i=1,3 do
            stararr[i] = enemyatt.nameimg:getChildByName('xing_'..i..'_img')
        end
        enemyatt.stararr = stararr
        enemyatt.enemybg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local attarr = {}
                for i= 1,#attconf do
                    attarr[i] =  self.data.attrs[tostring(i)]  or 0
                end
                local cur_floor = (self.data.cur_floor-1)*3+self.data.cur_room
                local customObj = {
                    id = 10000+(self.data.cur_floor-1)*3+self.data.cur_room,
                    levelType = (self.data.cur_floor-1)%2 +1,
                    attrs = attarr,
                    cur_floor = cur_floor,
                    cur_room = self.data.cur_room
                }
                --if self.data.cur_room == 3 then
                    --TowerMgr:setTowerShowAttReward(true)
                --end
                BattleMgr:playBattle(BATTLE_TYPE.TOWER, customObj, function ()
                    MainSceneMgr:showMainCity(function()
                        TowerMgr:showTowerMain()
                    end, nil, GAME_UI.UI_TOWER_MAIN)
                end)
            end
        end)
        self.enemytab[i] = enemyatt
    end
    self.spineAniarr = {}
    --if self.data.reward and TowerMgr:getTowerShowAttReward() then
        --TowerMgr:setTowerShowAttReward(false)
        --TowerMgr:showAttReward(self.data.reward,self.data.refresh_num,self.data)
        --for i=1,3 do
            --self.enemytab[i].nameimg:setVisible(false)
            --self.enemytab[i].enemybg:setVisible(false) 
        --end
    --end
    self:update()

    if self.stype == 'shop1' then
        MainSceneMgr:showShop(22,{min = 21,max = 22},self.data.max_star or 0)
    end
end

function TowerUI:onShowUIAniOver()
    if self.data.cur_floor == 1 and self.data.cur_room == 2 then -- 玩家第一次打完第一关时触发引导
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.TOWER)
    end
end

function TowerUI:onShow()
    self:doupdate()
end

function TowerUI:doupdate()
    MessageMgr:sendPost('get','tower',"{}",function (response)
        
        local code = response.code
        if code == 0 then
            self.data = response.data
            UserData:getUserObj():initTower(response.data)
            TowerMgr:setTowerData(self.data)
            self:update()
        end
    end)
end

function TowerUI:getMaxLvcount()
    local formationconf = GameData:getConfData('formation')
    local num = 0
    for k,v in pairs (formationconf) do
        if tonumber(k)> 10000 and tonumber(k) < 20000 then
            num = num + 1
        end
    end
    return math.floor(num/3)
    
end
function TowerUI:update()
    if TowerMgr:getTowerAction() then
        TowerMgr:setTowerAction(false)
        local action = cc.CSLoader:createTimeline("csb/towermainpanel.csb")
        self.root:runAction(action)
        action:gotoFrameAndPlay(0, false)
        self:updatemain()
        -- action:play("animation0", false)
        -- xx.Utils:Get():setActionTimelineAnimationEndCallFunc(action, "animation0", function ()
        --     xx.Utils:Get():removeActionTimelineAnimationEndCallFunc(action, "animation0")
        --     self:updatemain()
        -- end)
    else
        self:updatemain()
    end
end

function TowerUI:updatemain()
    local conf = GameData:getConfData('buy')[self.data.reset+1]
    local towertypeconf = GameData:getConfData('towertype')
    local  leveltype = (self.data.cur_floor-1)%2 +1
    local str = ''
    if leveltype ==1 then
        str = GlobalApi:getLocalStr('TOWER_TIME')
    else
        str = GlobalApi:getLocalStr('TOWER_DEAD')
    end
    if self.data.failed == 0 and ((self.data.cur_floor < self:getMaxLvcount()) or (self.data.cur_floor == self:getMaxLvcount() and self.data.cur_room < 4 ))  then
        self.failedpl:setVisible(false)
        self.norpl:setVisible(true) 
        for i=1,3 do
            local formationconf = GameData:getConfData('formation')[10000+(self.data.cur_floor-1)*3+i]
            local bosspos = formationconf.boss
            local bossid = formationconf[tostring('pos' .. bosspos)]
            local monsterconf = GameData:getConfData('monster')[bossid]
            self.enemytab[i].nametx:setString(string.format(GlobalApi:getLocalStr('TOWER_GUANQIA'),(self.data.cur_floor-1)*3+i))
            self:createAni(self.enemytab[i].enemybg,monsterconf.url,i,monsterconf.uiOffsetY)
            self.enemytab[i].nameimg:removeChildByTag(9527)
            self.enemytab[i].nameimg:setVisible(true)
            self.enemytab[i].enemybg:setTouchEnabled(false)
            self.enemytab[i].talkbg:setVisible(false)
            self.enemytab[i].pl:setVisible(false)
            self.enemytab[i].enemybg:setVisible(true)
            if self.data.cur_room == i then
                self.spineAniarr[i]:getAnimation():play('idle', -1, 1)
                self.enemytab[i].enemybg:setTouchEnabled(true)
                self.enemytab[i].talkbg:setVisible(true)
                local strtalk = string.format(GlobalApi:getLocalStr('TOWER_TALK_'..leveltype),towertypeconf[leveltype]['condLevel3'])
                self.enemytab[i].talktx:setString(strtalk)
                local fightainmintion = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
                if fightainmintion then
                    fightainmintion:setPosition(cc.p(80,60))
                    fightainmintion:setTag(9527)
                    fightainmintion:setAnimation(0, 'animation', true)
                    self.enemytab[i].nameimg:addChild(fightainmintion)
                end
            elseif self.data.cur_room > i then
                self.spineAniarr[i]:getAnimation():play('idle', -1, 1)
                self.spineAniarr[i]:getAnimation():gotoAndPause(0)
                ShaderMgr:setGrayForArmature(self.spineAniarr[i])
                self.enemytab[i].pl:setVisible(true)
            elseif self.data.cur_room < i then
                self.spineAniarr[i]:getAnimation():play('idle', -1, 1)
            end
            for j=1,3 do
                self.enemytab[i].stararr[j]:setVisible(false)
            end
            if self.data.last_stars[tostring(i)] then
                for j=1,tonumber(self.data.last_stars[tostring(i)]) do
                    self.enemytab[i].stararr[j]:setVisible(true)
                end
            end
        end
       
        if conf.towerReset > 0 then
            --self.resetcost:setVisible(true)
            --self.resetbtn:setVisible(true)
            --self.cashbg:setVisible(true)
            --self.freeresetbtn:setVisible(false)
        else
            --self.resetcost:setVisible(false)
            --self.resetbtn:setVisible(false)
            --self.cashbg:setVisible(false)
            --self.freeresetbtn:setVisible(true)
        end
    else
        for i=1,3 do
            self.enemytab[i].nameimg:setVisible(false)
            self.enemytab[i].enemybg:setVisible(false) 
        end
        self.failedpl:setVisible(true)

        self.norpl:setVisible(false)
        if conf.towerReset > 0 then
            --self.resetcost:setVisible(true)
            --self.resetbtn:setVisible(true)
            --self.cashbg:setVisible(true)
            --self.freeresetbtn:setVisible(false)
        else
            --self.resetcost:setVisible(false)
            --self.resetbtn:setVisible(false)
            --self.cashbg:setVisible(false)
            --self.freeresetbtn:setVisible(true)
        end
        self.talkftx:setString(string.format(GlobalApi:getLocalStr('TOWER_TALK_3'),(self.data.cur_floor-1)*3+self.data.cur_room-1))
    end

    for i=1,3 do
        self.descarr[i].desctx:setString(string.format(str,towertypeconf[leveltype][tostring('condLevel' .. i)]))
        self.descarr[i].numtx:setString('')
    end
    local attarr = {}
    for k, v in pairs(self.data.attrs) do
        local att = {}
        att[1] = k
        att[2] = v
        table.insert(attarr,att)
    end
    table.sort( attarr, function (a,b)
        return a[1] < b[1]
    end )

    for i=1,8 do
        local conf = attconf[tonumber(i)]
        self.attlabeltab[i]:setString(conf.name..'+0%')
        self.attlabeltab[i]:setColor(COLOR_TYPE.GRAY)
        self.attlabeltab[i]:enableOutline(COLOROUTLINE_TYPE.TOWERATT, 1)
    end
    
    for i=1,#attarr do
        local conf = attconf[tonumber(attarr[tonumber(i)][1])]
        self.attlabeltab[tonumber(attarr[tonumber(i)][1])]:setString(conf.name..'+'..attarr[i][2]..'%')
        self.attlabeltab[tonumber(attarr[tonumber(i)][1])]:setColor(COLOR_TYPE.GREEN)
        self.attlabeltab[tonumber(attarr[tonumber(i)][1])]:enableOutline(COLOROUTLINE_TYPE.PALE, 1)
    end

    self.infolabel[8]:setString(GlobalApi:getLocalStr('TOWER_DESC_10'))
    self.infolabel[9]:setString(self.data.star or 0)

    self.infolabel[1]:setString(GlobalApi:getLocalStr('TOWER_DESC_5'))
    self.infolabel[3]:setString(self.data.cur_star)
    self.infolabel[4]:setString(GlobalApi:getLocalStr('TOWER_DESC_6'))
    self.infolabel[6]:setString(self.data.top_star or 0)
    self.infolabel[7]:setString('） ')
    self.inforichtext:format(true)
    
    self.infoTowerlabel[1]:setString(GlobalApi:getLocalStr('TOWER_DESC_7'))
    self.infoTowerlabel[3]:setString(UserData:getUserObj().tower)
    self.infoTowerRichtext:format(true)

    --self.resetcost:setString(conf.towerReset)
    local allFloor = #GameData:getConfData('towercoinreward')/3
    if TowerMgr:getTowerShowAttReward() then
        TowerMgr:setTowerShowAttReward(false)
        if self.data.cur_floor >= allFloor and self.data.cur_room >= 4 then
        else
            if self.data.reward then
                TowerMgr:showAttReward(self.data.reward,self.data.refresh_num,self.data)
                for i=1,3 do
                    self.enemytab[i].nameimg:setVisible(false)
                    self.enemytab[i].enemybg:setVisible(false) 
                end
            end
        end
    end

    if self.data.auto == 0 then
        self.autobtn:setVisible(false)
        local allNum = self.data.cur_floor - 1
        if not self.data.cur_selected then
            self.data.cur_selected = 0
        end
        if allNum - self.data.cur_selected <= 0 then
            self.attAddBtn:setVisible(false)
        else
            self.attAddBtn:setVisible(true)
        end
    else
        self.autobtn:setVisible(true)
        self.attAddBtn:setVisible(false)
    end
    self:getMaxLvcount()

    if self.data.cur_floor >= allFloor and self.data.cur_room >= 4 then
        self.autobtn:setVisible(false)
        self.attAddBtn:setVisible(false)
        self.talkftx:setString(GlobalApi:getLocalStr('TOWER_TALK_4'))
    end

    -- 更新每日可以带的佣兵剩余数量
    -- 已经雇佣的人数self.data.hire_mercenary_num
    self.groupNum:setString(tonumber(GlobalApi:getGlobalValue("towerHireCount")) - self.data.hire_mercenary_num)

    if self.enemytab[1].nameimg:isVisible() == true then
        self.autobtn:setTouchEnabled(true)
    end
end

function TowerUI:createAni(parentnode,url,index,uiOffsetY)
    parentnode:removeAllChildren()
    local spineAni = GlobalApi:createLittleLossyAniByName(url.."_display")
    if spineAni then
        self.spineAniarr[index] = spineAni
        spineAni:setPosition(cc.p(parentnode:getContentSize().width/2,uiOffsetY))
        parentnode:addChild(spineAni)
    end
end

function TowerUI:Reset(isneedcash)
    local conf = GameData:getConfData('buy')[tonumber(self.data.reset+1)]
    local args = {}
    if isneedcash then
        args = {
            cash = conf.towerReset,
        }
    end
    MessageMgr:sendPost('reset','tower',json.encode(args),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            GlobalApi:parseAwardData(response.data.awards)
            local costs = response.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            -- self.data.reset = self.data.reset + 1
            -- self.data.failed = 0
            self:doupdate()
        end
    end)

end
return TowerUI