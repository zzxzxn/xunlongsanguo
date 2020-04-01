local LegionWarBattleUI = class("LegionWarBattleUI", BaseUI)

function LegionWarBattleUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGIONWAR_BATTLE
    self.battledata = LegionMgr:getLegionBattleData()
    self.selectid = 0
end

function LegionWarBattleUI:init()
	self.bgimg1 = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.bgimg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self:inituibg()
    self:initmap()
    self:initcity(self.bgimg1)
    self:calcinfo()
end

function LegionWarBattleUI:onShow()
    self:update()
end
function LegionWarBattleUI:update()
    self.battledata = LegionMgr:getLegionBattleData()
    self:upatebottom()
    self:updatetop()
    self:initcity()
    self:calcinfo()
    if self.battledata.ownLegion.score >= self:calcTotalScore() then
       UserData:getUserObj():setSignByType('legionwar_attacknum',0) 
    end 
end
function LegionWarBattleUI:inituibg()
	local winSize = cc.Director:getInstance():getVisibleSize()
	local uibgimg = self.root:getChildByName("ui_bg_img")
    uibgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    uibgimg:setContentSize(cc.size(winSize.width,winSize.height))
    self.bottombgimg = uibgimg:getChildByName('bottom_bg_img')
    self:upatebottom()
    self.topbgimg = uibgimg:getChildByName('top_bg_img')
    local timetx  = self.topbgimg:getChildByName('time_tx')
    timetx:setString('')
    timetx:setPosition(cc.p(winSize.width/2,-30))
    local time = LegionMgr:getLegionWarData().stageEnd - GlobalData:getServerTime()
    Utils:createCDLabel(timetx,time,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,GlobalApi:getLocalStr('LEGION_WAR_DESC7'),COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.WHITE,25,function()
        LegionMgr:hideLegionWarBattleUI()
    end)
    self:updatetop()
end

function LegionWarBattleUI:initmap(battlestate)
    local mapNode = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.bgImgSize = mapNode:getContentSize()
    local limitLW = winSize.width - self.bgImgSize.width
    local limitRW = 0
    local preMovePos = nil
    local movePos = nil
    local bgImgDiffPos = nil
    local bgImgPosX = limitLW/2
    local bgImgPosY = -(self.bgImgSize.height-winSize.height)/2
    local beganPos = nil
    -- if LegionMgr:getLegionWarData().stage == 1 then
    -- 	limitLW = winSize.width - self.bgImgSize.width/2
    -- 	bgImgPosX = limitLW/2
    -- end
    mapNode:setPosition(cc.p(bgImgPosX, bgImgPosY))
    mapNode:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
                local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY)
                if targetPos.x > limitRW then
                    targetPos.x = limitRW
                end
                if targetPos.x < limitLW then
                    targetPos.x = limitLW
                end
                bgImgPosX = targetPos.x
                mapNode:setPosition(targetPos)
            end
        elseif eventType == ccui.TouchEventType.began then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
            beganPos = sender:getTouchBeganPosition()
            self.touchMine = false
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        elseif eventType == ccui.TouchEventType.canceled then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        end
    end)
end

function LegionWarBattleUI:updatetop()
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.topbgimg:setContentSize(cc.size(winSize.width,60))
    self.topbgimg:setPosition(cc.p(winSize.width/2,winSize.height))
    local tiaoimg2 = self.topbgimg:getChildByName('tiao_img')
    tiaoimg2:setContentSize(cc.size(winSize.width,2))
    tiaoimg2:setPosition(cc.p(winSize.width/2,0))
    local legion1bg = self.topbgimg:getChildByName('legion_1_bg')
    legion1bg:setPosition(cc.p(0,0))
    local legion2bg = self.topbgimg:getChildByName('legion_2_bg')
    legion2bg:setPosition(cc.p(winSize.width,0))
    local middlebg = self.topbgimg:getChildByName('top_middle_bg')
    middlebg:setPosition(cc.p(winSize.width/2,30))


    local iconConf = GameData:getConfData("legionicon")
    local legionselfflagimg = legion1bg:getChildByName('leigon_flag_img')
    legionselfflagimg:loadTexture(iconConf[self.battledata.ownLegion.icon].icon)
    local legionselfnametx = legion1bg:getChildByName('legion_name_tx')
    legionselfnametx:setString(self.battledata.ownLegion.name)
    legionselfnametx:setTextColor(COLOR_TYPE[iconConf[self.battledata.ownLegion.icon].nameColor])
    local legionselfqutx = legion1bg:getChildByName('legion_qu_tx')
    legionselfqutx:setString(self.battledata.ownLegion.sid..GlobalApi:getLocalStr('FU'))

    local legionenemyflagimg = legion2bg:getChildByName('leigon_flag_img')
    legionenemyflagimg:loadTexture(iconConf[self.battledata.enemyLegion.icon].icon)
    local legionenemynametx = legion2bg:getChildByName('legion_name_tx')
    legionenemynametx:setString(self.battledata.enemyLegion.name)
    legionenemynametx:setTextColor(COLOR_TYPE[iconConf[self.battledata.enemyLegion.icon].nameColor])
    local legionenemyqutx = legion2bg:getChildByName('leigon_qu_tx')
    legionenemyqutx:setString(self.battledata.enemyLegion.sid..GlobalApi:getLocalStr('FU'))

    local selfscoretx = middlebg:getChildByName('score_1_tx')
    selfscoretx:setString(self.battledata.ownLegion.score)
    local enemyscoretx = middlebg:getChildByName('score_2_tx')
    enemyscoretx:setString(self.battledata.enemyLegion.score)
    local selfbarbg = middlebg:getChildByName('bar_1_bg')
    local selfbar = selfbarbg:getChildByName('bar')
    selfbar:setPercent((self.battledata.ownLegion.score/self:calcTotalScore())*100)
    local enemybarbg = middlebg:getChildByName('bar_2_bg')
    local enemybar = enemybarbg:getChildByName('bar')
    enemybar:setPercent((self.battledata.enemyLegion.score/self:calcTotalScore())*100)
end

function LegionWarBattleUI:upatebottom()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closebtn = self.bottombgimg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarBattleUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width-60,41))
    self.bottombgimg:setContentSize(cc.size(winSize.width,46))
    self.bottombgimg:setPosition(cc.p(winSize.width/2,0))
    local tiaoimg1 =self.bottombgimg:getChildByName('tiao_img')
    tiaoimg1:setContentSize(cc.size(winSize.width,2))
    tiaoimg1:setPosition(cc.p(winSize.width/2,46))

    local funcbtn = self.bottombgimg:getChildByName('func_btn_1')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionWarBuffUI()
        end
    end)

    local refbtn = self.bottombgimg:getChildByName('func_btn_2')
    refbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('get_battlepage_info','legionwar',"{}",function (response)
                local code = response.code
                local data = response.data
                if code == 0 then
                    local legiondata = LegionMgr:getLegionBattleData()
                    LegionMgr:setSelfLegionPos(legiondata.user.duty)                 
                    LegionMgr:setLegionBattleData(data)
                    self:update()
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC37'),COLOR_TYPE.GREEN)
                end
            end)
        end
    end)
    local perpl =  self.bottombgimg:getChildByName('per_pl')
    perpl:setPosition(cc.p(winSize.width/2,0))
    local perdesctx1 = perpl:getChildByName('desc_1_tx')
    perdesctx1:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC10')..':')
    local pernumtx1 = perpl:getChildByName('num_1_tx')
    pernumtx1:setString(self.battledata.user.coin)

    local perdesctx2 = perpl:getChildByName('desc_2_tx')
    perdesctx2:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC11')..':')
    local pernumtx2 = perpl:getChildByName('num_2_tx')
    local legionconf = GameData:getConfData('legion')
    pernumtx2:setString(tonumber(legionconf['legionWarAddCityBufNum'].value) - self.battledata.user.addCityBufNum)
    if tonumber(legionconf['legionWarAddCityBufNum'].value) - self.battledata.user.addCityBufNum > 0 then
        pernumtx2:setColor(COLOR_TYPE.GREEN)
    else
        pernumtx2:setColor(COLOR_TYPE.RED)
    end
    local perdesc4tx = perpl:getChildByName('desc_4_tx')
    --perdesc4tx:setPosition(cc.p(winSize.width-100,30)) 
    perdesc4tx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC12'))

    local battlepl =  self.bottombgimg:getChildByName('battle_pl')
    battlepl:setPosition(cc.p(winSize.width/2,0))
    local battledesctx1 = battlepl:getChildByName('desc_1_tx')
    battledesctx1:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC10')..':')
    local battlenumtx1 = battlepl:getChildByName('num_1_tx')
    battlenumtx1:setString(self.battledata.user.coin)

    local battledesctx2 = battlepl:getChildByName('desc_2_tx')
    battledesctx2:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC5'))
    local battlenumtx2 = battlepl:getChildByName('num_2_tx')
    battlenumtx2:setString(self.battledata.user.attackNum)

    local battledesctx3 = battlepl:getChildByName('desc_3_tx')
    battledesctx3:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC67')..':')
    local battlenumtx3 = battlepl:getChildByName('num_3_tx')
    battlenumtx3:setString(UserData:getUserObj():getLegionwar())
    local iconimg = battlepl:getChildByName('icon_img')
    iconimg:loadTexture('uires/ui/res/res_legionwar.png')

    if self.battledata.user.attackNum > 0 then
        battlenumtx2:setColor(COLOR_TYPE.GREEN)
    else
        battlenumtx2:setColor(COLOR_TYPE.RED)
    end
    local legionconf = GameData:getConfData('legion')
    --print('self.battledata.user.addCityBufNum==='..self.battledata.user.addCityBufNum)
  

    if LegionMgr:getLegionWarData().stage == 2 or LegionMgr:getLegionWarData().stage == 3 then
        -- desctx3:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC5'))
        -- numtx3:setString(self.battledata.user.attackNum)
        -- desc4tx:setString('')
        -- if self.battledata.user.attackNum > 0 then
        --     numtx3:setColor(COLOR_TYPE.GREEN)
        -- else
        --     numtx3:setColor(COLOR_TYPE.RED)
        -- end
        battlepl:setVisible(true)
        perpl:setVisible(false)
    else
        battlepl:setVisible(false)
        perpl:setVisible(true)
        -- desctx3:setString('')
        -- numtx3:setString('')
        -- desc4tx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC12'))
    end
end

function LegionWarBattleUI:calcTotalScore()
    local legioncityconf = GameData:getConfData('legionwarcity')
    local totalscore = 0
    for i,v in ipairs(legioncityconf) do
        totalscore = totalscore + legioncityconf[i].score
    end
    --print("totalscore=="..totalscore)
    return totalscore
end

function LegionWarBattleUI:initcity()
    local bgimg1 = self.bgimg1:getChildByName('bg_img_1')
    local bgimg2 = self.bgimg1:getChildByName('bg_img_2')
    local bgimg3 = self.bgimg1:getChildByName('bg_img_3')
    self.selflinetab = {}
    self.enemylinetab = {}
    self.selfcitytab = {}
    self.enemycitytab = {}
    if LegionMgr:getLegionWarData().stage == 1 then
        bgimg3:setVisible(true)
    else
        bgimg3:setVisible(false)
    end
    for i=1,24 do
        self.selflinetab[i] = bgimg1:getChildByName('line_b_'..i)
        self.selflinetab[i]:setVisible(false)
        self.enemylinetab[i] = bgimg1:getChildByName('line_r_'..i)
        self.enemylinetab[i]:setVisible(false)
    end

    for i=1,16 do
        local temptab = {}
        temptab.btn = bgimg2:getChildByName('city_b_'..i..'_btn')
        temptab.namebg = temptab.btn:getChildByName('name_bg')
        temptab.nametx = temptab.namebg:getChildByName('name_tx')
        temptab.lvtx = temptab.namebg:getChildByName('lv_tx')
        temptab.lvtx:setVisible(true)
        temptab.barbg = temptab.btn:getChildByName('bar_bg')
        temptab.bar = temptab.barbg:getChildByName('bar')
        self.selfcitytab[i] = temptab
        GlobalApi:regiesterBtnHandler(self.selfcitytab[i].btn,function ()
            LegionMgr:showLegionWarCityInfoUI(1,i,self.battledata.ownLegion.lid)
        end)
        --self.selfcitytab[i].btn:setSwallowTouches(false)
        local temptab2 = {}
        temptab2.btn = bgimg2:getChildByName('city_r_'..i..'_btn')
        temptab2.namebg = temptab2.btn:getChildByName('name_bg')
        temptab2.nametx = temptab2.namebg:getChildByName('name_tx')
        temptab2.lvtx = temptab2.namebg:getChildByName('lv_tx')
        temptab2.lvtx:setVisible(true)
        self.enemycitytab[i] = temptab2
        GlobalApi:regiesterBtnHandler(self.enemycitytab[i].btn,function ()
            if self.battledata.user.cards['7'] 
                and self.battledata.user.cards['7'].have > 0 
                and self.battledata.enemyLegion.cities[tostring(i)].aliveArm > 1
                and (self.battledata.enemyLegion.cities[tostring(i)].canAttack == false and self.battledata.enemyLegion.cities[tostring(i)].canJump == true) then
                promptmgr:showMessageBox(GlobalApi:getLocalStr('LEGION_WAR_DESC57'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        self:useCard(i)
                end,GlobalApi:getLocalStr('STR_OK2'),GlobalApi:getLocalStr('MESSAGE_NO'))
            else
                if LegionMgr:getLegionWarData().stage == 2 or  LegionMgr:getLegionWarData().stage == 3 then
                    if self.battledata.enemyLegion.cities[tostring(i)].aliveArm <= 0  and self.battledata.enemyLegion.cities[tostring(i)].canAttack == true then
                        if not self.battledata.user.cityAwardMark[tostring(i)] then
                            self:getCityAwardsMsg(i)
                        else
                            LegionMgr:showLegionWarCityInfoUI(0,i,self.battledata.enemyLegion.lid)
                        end
                    else
                        LegionMgr:showLegionWarCityInfoUI(0,i,self.battledata.enemyLegion.lid)
                    end
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC68'),COLOR_TYPE.RED)
                end
            end
        end)
        --self.enemycitytab[i].btn:setSwallowTouches(false)   
    end

    local legioncityconf = GameData:getConfData('legionwarcity')
    for i=1,16 do
        local num = 0
        if self.battledata.ownLegion.cities[tostring(i)].aliveArm >= 0 then
            num = self.battledata.ownLegion.cities[tostring(i)].aliveArm
        end
        self.selfcitytab[i].nametx:setString(legioncityconf[i].name..num ..'/'..legioncityconf[i].arm)
        self.selfcitytab[i].lvtx:setString('（'..self.battledata.ownLegion.cities[tostring(i)].buffLevel..GlobalApi:getLocalStr('LEGION_LV_DESC')..'）')
        if self.battledata.ownLegion.cities[tostring(i)].buffXp == 0 and self.battledata.ownLegion.cities[tostring(i)].buffLevel == 0 or
            self.battledata.ownLegion.cities[tostring(i)].buffLevel == legioncityconf[i].maxBufLevel then
            self.selfcitytab[i].barbg:setVisible(false)
        else
            self.selfcitytab[i].barbg:setVisible(true)
            local curxp = self.battledata.ownLegion.cities[tostring(i)].buffXp
            local maxxp = legioncityconf[i][tostring('buf'..(self.battledata.ownLegion.cities[tostring(i)].buffLevel+1)..'Xp')]
            local percent = math.floor(curxp/maxxp*100)
            self.selfcitytab[i].bar:setPercent(percent)
            self.selfcitytab[i].barbg:removeChildByTag(9527)
            local bufaction = GlobalApi:createLittleLossyAniByName('scene_tx_wakuang')
            local size = self.selfcitytab[i].barbg:getContentSize()
            bufaction:setPosition(cc.p(size.width/2,size.height/2 + 50))
            bufaction:setAnchorPoint(cc.p(0.5,0.5))
            bufaction:setLocalZOrder(10000)
            bufaction:setTag(9527)
            self.selfcitytab[i].barbg:addChild(bufaction)
            bufaction:getAnimation():play("Animation2", -1, 1)
        end
    end
    if LegionMgr:getLegionWarData().stage == 1  then
        for i=1,16 do
            self.enemycitytab[i].nametx:setString(legioncityconf[i].name) 
            self.enemycitytab[i].lvtx:setString('')
        end
    end        
    if LegionMgr:getLegionWarData().stage == 2 or  LegionMgr:getLegionWarData().stage == 3 then  
        for i=1,16 do
            self.selfcitytab[i].barbg:setVisible(false)
            local selfcanattack1 = self.battledata.ownLegion.cities[tostring(i)].canAttack
            local num = 0
            if self.battledata.enemyLegion.cities[tostring(i)].aliveArm >= 0 then
                num = self.battledata.enemyLegion.cities[tostring(i)].aliveArm
            end
            self.enemycitytab[i].nametx:setString(legioncityconf[i].name..num ..'/'..legioncityconf[i].arm)
            self.enemycitytab[i].lvtx:setString('（'..self.battledata.enemyLegion.cities[tostring(i)].buffLevel..GlobalApi:getLocalStr('LEGION_LV_DESC')..'）') 
            if self.battledata.ownLegion.cities[tostring(i)].aliveArm <= 0 and selfcanattack1 then
                self.selfcitytab[i].btn:loadTextureNormal("uires/ui/legionwar/legionwar_po.png")
                self.selfcitytab[i].btn:setContentSize(cc.size(120,85))
            end
            local enemycanattack1 = self.battledata.enemyLegion.cities[tostring(i)].canAttack
            local enemycanjump = self.battledata.enemyLegion.cities[tostring(i)].canJump
            if self.battledata.enemyLegion.cities[tostring(i)].aliveArm <= 0 and enemycanattack1
                and (not self.battledata.user.cityAwardMark[tostring(i)] or  self.battledata.user.cityAwardMark[tostring(i)] == 0 ) then
                self.enemycitytab[i].btn:loadTextureNormal("uires/ui/legionwar/legionwar_po.png")
                self.enemycitytab[i].btn:setContentSize(cc.size(120,85))
                local node =  self.enemycitytab[i].btn:getChildByTag(9527) 
                if node then
                    node:stopAllActions()
                    node:removeFromParent()
                end
                local awardstab = DisplayData:getDisplayObjs(legioncityconf[i].award)
                if #awardstab > 0 then
                    local img = ccui.ImageView:create('uires/ui/guard/guard_jiangli.png')
                    local size = self.selfcitytab[i].btn:getContentSize()
                    img:setPosition(cc.p(149/2,99/2 + 50))
                    img:setAnchorPoint(cc.p(0.5,0.5))
                    img:setLocalZOrder(10000)
                    img:setTag(9527)
                    self.enemycitytab[i].btn:addChild(img)
                    local pos1 = cc.p(75,100)
                    local pos2 = cc.p(75,125)
                    img:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3),cc.MoveTo:create(1, pos2),cc.MoveTo:create(1, pos1))))
                end
            end
            if enemycanattack1 and self.battledata.enemyLegion.cities[tostring(i)].aliveArm > 0 and LegionMgr:getLegionWarData().stage == 2  then
                local node =  self.enemycitytab[i].btn:getChildByTag(9999) 
                if node then
                    node:stopAllActions()
                    node:removeFromParent()
                end
                local sprite = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
                --sprite:setPosition(cc.p(btn:getPositionX()*self.currScale,btn:getPositionY()*self.currScale))
                sprite:setAnimation(0, 'animation', true)
                sprite:setPosition(cc.p(75,100))
                sprite:setAnchorPoint(cc.p(0.5,0.5))
                sprite:setLocalZOrder(10000)
                sprite:setScale(0.7)
                sprite:setTag(9999)
                self.enemycitytab[i].btn:addChild(sprite)
            end
            if not enemycanattack1 and  enemycanjump then
                local node =  self.enemycitytab[i].btn:getChildByTag(9528) 
                if node then
                    node:stopAllActions()
                    node:removeFromParent()
                end
                local img = ccui.ImageView:create('uires/ui/legionwar/legionwar_qiangxi2.png')
                local size = self.selfcitytab[i].btn:getContentSize()
                img:setPosition(cc.p(149/2,99/2 + 50))
                img:setAnchorPoint(cc.p(0.5,0.5))
                img:setLocalZOrder(10000)
                img:setTag(9528)                
                self.enemycitytab[i].btn:addChild(img)
                local pos1 = cc.p(75,100)
                local pos2 = cc.p(75,125)
                img:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3),cc.MoveTo:create(1, pos2),cc.MoveTo:create(1, pos1))))
            end

            if self.battledata.user.cityAwardMark[tostring(i)] == 1 then
                local node =  self.enemycitytab[i].btn:getChildByTag(9527) 
                if node then
                    node:stopAllActions()
                    node:removeFromParent()
                end
                self.enemycitytab[i].btn:loadTextureNormal("uires/ui/legionwar/legionwar_po.png")
                self.enemycitytab[i].btn:setContentSize(cc.size(120,85))
            end
            --线
            local lineconf = GameData:getConfData('local/legionwarline')
            for i=1,24 do
                local selfcanattack1 = self.battledata.ownLegion.cities[tostring(lineconf[i]['city1'])].canAttack
                local selfcanattack2 = self.battledata.ownLegion.cities[tostring(lineconf[i]['city2'])].canAttack
                local selfaliveArm1 = self.battledata.ownLegion.cities[tostring(lineconf[i]['city1'])].aliveArm
                local selfaliveArm2 = self.battledata.ownLegion.cities[tostring(lineconf[i]['city2'])].aliveArm
                if selfcanattack1 == true and selfcanattack2 and (selfaliveArm1 <=1 or selfaliveArm2 <=1) then
                    self.selflinetab[i]:setVisible(true)
                end
                local enemycanattack1 = self.battledata.enemyLegion.cities[tostring(lineconf[i]['city1'])].canAttack
                local enemycanattack2 = self.battledata.enemyLegion.cities[tostring(lineconf[i]['city2'])].canAttack
                local enemyaliveArm1 = self.battledata.enemyLegion.cities[tostring(lineconf[i]['city1'])].aliveArm
                local enemyaliveArm2 = self.battledata.enemyLegion.cities[tostring(lineconf[i]['city2'])].aliveArm
                if enemycanattack1 == true and enemycanattack2 and (enemyaliveArm1 <=1 or enemyaliveArm2 <=1) then
                    self.enemylinetab[i]:setVisible(true)
                end
            end
        end
    end
end

function LegionWarBattleUI:getCityAwardsMsg(cityid)
    local args = {
        city = cityid,
    }
    self.selectid = cityid
    MessageMgr:sendPost("get_city_award", "legionwar", json.encode(args), function (response)
        local code = response.code
        if code == 0 then
            local data = response.data
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local tab = {}
            tab = 1
            self.battledata.user.cityAwardMark[tostring(cityid)]  = tab
            self:update()
        end
    end)
end

--使用探明暗格的卡牌
function LegionWarBattleUI:useCard(cityid)
    local args = {
            card = 7,
            target = {
                city = cityid,
            },
        }

    MessageMgr:sendPost('use_card','legionwar',json.encode(args),function (response)
        local code = response.code
        if code == 0 then
            self.battledata.user.cards['7'].have = self.battledata.user.cards['7'].have - 1
            if self.battledata.user.cards['7'].have < 0 then
                self.battledata.user.cards['7'].have = 1
            end
            local data = response.data
            for k,v in pairs(data.cityMap) do
                self.battledata.enemyLegion.cities[tostring(k)].canAttack = true
            end
            for k,v in pairs(data.jumpMap) do
                self.battledata.enemyLegion.cities[tostring(k)].canJump = true
            end
            self:update() 
        end
    end)
end
function LegionWarBattleUI:calcinfo()
    -- print("LegionMgr:getLegionWarData().stage==="..LegionMgr:getLegionWarData().stage)
    if LegionMgr:getLegionWarData().stage == 2 then
        if self.battledata.user.attackNum > 0 then
            -- print('xxxx')
            UserData:getUserObj():setSignByType('legionwar_attacknum',1)
            if self.battledata.ownLegion.score >= self:calcTotalScore() then
               UserData:getUserObj():setSignByType('legionwar_attacknum',0) 
            end 
        else
            -- print('aaaaa')
           UserData:getUserObj():setSignByType('legionwar_attacknum',0)       
        end  
    end

    if LegionMgr:getLegionWarData().stage == 2 or LegionMgr:getLegionWarData().stage == 3 then
        UserData:getUserObj():setSignByType('legionwar_citybufnum',0)   
        for i = 1, 16 do
            local enemycanattack1 = self.battledata.enemyLegion.cities[tostring(i)].canAttack
            if not self.battledata.user.cityAwardMark[tostring(i)] and self.battledata.enemyLegion.cities[tostring(i)].aliveArm <= 0 and enemycanattack1 then
                UserData:getUserObj():setSignByType('legionwar_cityaward',1)
                return
            end
        end
        UserData:getUserObj():setSignByType('legionwar_cityaward',0)
        -- print('self.battledata.user.attackNum'..self.battledata.user.attackNum)   
    end
    if LegionMgr:getLegionWarData().stage == 1  then
        local legionconf = GameData:getConfData('legion')
        if tonumber(legionconf['legionWarAddCityBufNum'].value) - self.battledata.user.addCityBufNum > 0 then
            UserData:getUserObj():setSignByType('legionwar_citybufnum',1)
            return
        end
        UserData:getUserObj():setSignByType('legionwar_citybufnum',0)      
    end
end

return LegionWarBattleUI