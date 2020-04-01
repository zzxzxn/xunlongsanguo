local WorldWarMainUI = class("WorldWarMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function WorldWarMainUI:ctor()
	self.uiIndex = GAME_UI.UI_WORLDWAR
    self.roleSpines = {}
end

function WorldWarMainUI:timeoutCallback(tx,time)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local label = self.root:getChildByTag(9999)
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 22)
    label:setPosition(cc.p(winSize.width/2 + 60,winSize.height - 140))
    label:setAnchorPoint(cc.p(0,0.5))
    label:setVisible(false)
    self.root:addChild(label,1,9999)
    Utils:createCDLabel(label,time,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT,tx,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.ORANGE,22,function ()
        WorldWarMgr:getRecords(function(records,replays)
            WorldWarMgr:showWorldWar()
            WorldWarMgr:hideWorldWarMain()
        end)
    end)
end

function WorldWarMainUI:setSigns()
    local featsWallBtn = self.root:getChildByName("feats_wall_btn")
    local newImg = featsWallBtn:getChildByName('new_img')
    newImg:setVisible(UserData:getUserObj():getSignByType('exploit_wall'))
    local reportBtn = self.root:getChildByName("report_btn")
    local newImg = reportBtn:getChildByName('new_img')
    newImg:setVisible(UserData:getUserObj():getSignByType('worldwar_report'))
    self.goWarNewImg:setVisible(UserData:getUserObj():getSignByType('worldwar_battle'))
end

function WorldWarMainUI:onShow()
    self:updatePanel()
end

function WorldWarMainUI:updatePanel()
    local worldwarImg = self.root:getChildByName("worldwar_img")
    local leftTopImg = self.root:getChildByName("left_top_img")
    local roleBgNode = leftTopImg:getChildByName('role_bg_node')
    local myBgImg = roleBgNode:getChildByName('award_bg_img')
    local myIcon = myBgImg:getChildByName('award_img')
    local headframe = myBgImg:getChildByName('headframeImg')
    local nameTx = leftTopImg:getChildByName('name_tx')
    local rankTx = leftTopImg:getChildByName('rank_tx')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local role = clone(RoleData:getRoleMap())
    table.sort( role, function(a,b)
        return a:getFightForce() > b:getFightForce()
    end )
    local roleObj = RoleData:getRoleInfoById(tonumber(role[1]:getId()))
    nameTx:setString(UserData:getUserObj():getName())
    -- rankTx:setString(GlobalApi:getLocalStr("SCORE")..WorldWarMgr.score)
    rankTx:setString('')

    if not self.rts then
        local richText = xx.RichText:create()
        leftTopImg:addChild(richText)
        richText:setContentSize(cc.size(400, 28))
        richText:setPosition(cc.p(0,0))
        richText:setAlignment('left')
        local re1 = xx.RichTextLabel:create(WorldWarMgr.rank, 25, COLOR_TYPE.GREEN)
        re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC3"), 25, COLOR_TYPE.WHITE)
        re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        local re3 = xx.RichTextLabel:create(' '..WorldWarMgr.score, 25, COLOR_TYPE.ORANGE)
        re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr("MINUTE"), 25, COLOR_TYPE.WHITE)
        re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:addElement(re4)
        richText:setPosition(cc.p(286,40))
        richText:setVisible(true)
        self.rts = {richText = richText,re1 = re1,re2 = re2,re3 = re3,re4 = re4}
    else
        self.rts.re1:setString(WorldWarMgr.rank)
        self.rts.re3:setString(' '..WorldWarMgr.score)
        self.rts.richText:format(true)
    end

    local headpic = UserData:getUserObj().headpic
    local obj = RoleData:getHeadPicObj(headpic)
    myBgImg:loadTexture(obj:getBgImg())
    myIcon:loadTexture(obj:getIcon())
    headframe:loadTexture(UserData:getUserObj():getHeadFrame())
    headframe:setVisible(true)

    myIcon:ignoreContentAdaptWithSize(true)
    local pos1 = {cc.p(90,0),cc.p(90,0),cc.p(90,0)}
    local pos2 = {cc.p(95,-25),cc.p(95,-25),cc.p(90,-25)}
    local pos3 = {cc.p(95,0),cc.p(95,0),cc.p(90,0)}
    for i=1,3 do
        local zhuzi = worldwarImg:getChildByName('zhuzi'..i)
        local roleBgImg = zhuzi:getChildByName('role_bg_img')
        local nameTx = zhuzi:getChildByName('name_tx')
        local pl = zhuzi:getChildByName('pl')
        nameTx:setLocalZOrder(3)
        if WorldWarMgr.top3[i] then
            roleBgImg:setVisible(false)
            pl:setVisible(true)
            if not self.roleSpines[i] then
                local promote = nil
                local weapon_illusion = nil
                local wing_illusion = nil
                if WorldWarMgr.top3[i].promote and WorldWarMgr.top3[i].promote[1] then
                    promote = WorldWarMgr.top3[i].promote[1]
                end
                local heroConf = GameData:getConfData("hero")
                if heroConf[tonumber(WorldWarMgr.top3[i].max_hid)].camp == 5 then
                    if WorldWarMgr.top3[i].weapon_illusion and WorldWarMgr.top3[i].weapon_illusion > 0 then
                        weapon_illusion = WorldWarMgr.top3[i].weapon_illusion
                    end
                    if WorldWarMgr.top3[i].wing_illusion and WorldWarMgr.top3[i].wing_illusion > 0 then
                        wing_illusion = WorldWarMgr.top3[i].wing_illusion
                    end
                end
                local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
                self.roleSpines[i] = GlobalApi:createLittleLossyAniByRoleId(tonumber(WorldWarMgr.top3[i].max_hid), changeEquipObj)
                self.roleSpines[i]:setPosition(pos1[i])
                -- pl:setPosition(pos[i])
                pl:addChild(self.roleSpines[i])
                self.roleSpines[i]:getAnimation():play('idle', -1, 1)
                self.roleSpines[i]:setLocalZOrder(2)

                local str = 'guangsuxian_'..i..'_1'
                local animation = GlobalApi:createLittleLossyAniByName(str)
                animation:getAnimation():playWithIndex(0, -1, 1)
                pl:addChild(animation)
                animation:setName(str)
                animation:setScale(2.75)
                animation:setPosition(pos2[i])
                animation:setLocalZOrder(3)
                animation:getAnimation():setSpeedScale(0.8)

                local str1 = 'guangsuxian_'..i..'_2'
                local animation = GlobalApi:createLittleLossyAniByName(str1)
                animation:getAnimation():playWithIndex(0, -1, 1)
                pl:addChild(animation)
                animation:setName(str1)
                animation:setScale(2.2)
                animation:setPosition(pos3[i])
                animation:setLocalZOrder(1)
                animation:getAnimation():setSpeedScale(0.8)
                pl:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        BattleMgr:showCheckInfo(WorldWarMgr.top3[i].uid,'universe')
                    end
                end)
            end
            nameTx:setString(WorldWarMgr.top3[i].name)
        else
            pl:setVisible(false)
            roleBgImg:setVisible(true)
            nameTx:setString('')
        end
    end
    if WorldWarMgr.progress == 'rank' then
        local bt = Time.beginningOfWeek()
        local dt = WorldWarMgr:getScheduleByProgress(16)
        local startTime = bt + (tonumber(dt.startWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
        local nowTime = GlobalData:getServerTime()
        if startTime - nowTime > 0 then
            self:timeoutCallback(GlobalApi:getLocalStr("WORLD_WAR_DESC_7"),startTime - nowTime)
        end
    end
    self:setSigns()
end

function WorldWarMainUI:init()
	local worldwarImg = self.root:getChildByName("worldwar_img")
	local closeBtn = self.root:getChildByName("close_btn")
	local featsWallBtn = self.root:getChildByName("feats_wall_btn")
	local awardBtn = self.root:getChildByName("award_btn")
	local shopBtn = self.root:getChildByName("shop_btn")
	local rankBtn = self.root:getChildByName("rank_btn")
	local reportBtn = self.root:getChildByName("report_btn")
	local goWarBtn = self.root:getChildByName("go_war_btn")
    self.goWarNewImg = goWarBtn:getChildByName('new_img')
    goWarBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('WORLD_WAR_DESC_100'))
    local timeTx = self.root:getChildByName("time_tx")
    local leftTopImg = self.root:getChildByName("left_top_img")
    local titleImg = self.root:getChildByName("title_img")
    local infoTx = self.root:getChildByName("info_tx")
    local lastBtn = self.root:getChildByName("last_btn")

    local roleBgNode = leftTopImg:getChildByName('role_bg_node')
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    roleBgNode:addChild(headpicCell.awardBgImg)

    local helpBtn = leftTopImg:getChildByName('help_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideWorldWarMain()
        end
    end)
    helpBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --WorldWarMgr:showHelp()
        end
    end)
    helpBtn:setVisible(false)


    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.PACK_ARMY)
    btn:setName('normal_help_btn')
    btn:setPosition(cc.p(helpBtn:getPositionX() + btn:getContentSize().width/2,helpBtn:getPositionY() - btn:getContentSize().height/2))
    leftTopImg:addChild(btn)


    featsWallBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showFeatsWall()
        end
    end)
    awardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showAward()
        end
    end)
    shopBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showShop(41,{min = 41,max = 41})
        end
    end)
    rankBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- WorldWarMgr:showList()
            RankingListMgr:showRankingListMain(6,1)
        end
    end)
    reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if WorldWarMgr.progress == 'rank' then
                WorldWarMgr:showReport()
            elseif WorldWarMgr.progress == 'close' then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_NOT_OPEN"), COLOR_TYPE.RED)
            elseif WorldWarMgr.progress == 'stop' then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_NOT_OPEN_2"), COLOR_TYPE.RED)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_NOT_OPEN_1"), COLOR_TYPE.RED)
            end
        end
    end)
    goWarBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showGoWar()
        end
    end)
    lastBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:showWorldKnockoutWar()
        end
    end)
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local size = shopBtn:getContentSize()
    worldwarImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    shopBtn:setPosition(cc.p(winSize.width - size.width*0.5,size.height*0.8))
    featsWallBtn:setPosition(cc.p(winSize.width - size.width*0.5,size.height*1.8))
    reportBtn:setPosition(cc.p(winSize.width - size.width*0.5,size.height*2.8))

    lastBtn:setPosition(cc.p(size.width*0.5,size.height*2.8))
    rankBtn:setPosition(cc.p(size.width*0.5,size.height*1.8))
    awardBtn:setPosition(cc.p(size.width*0.5,size.height*0.8))

    goWarBtn:setPosition(cc.p(winSize.width*0.5,40))
    infoTx:setPosition(cc.p(winSize.width*0.5,90))
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    leftTopImg:setPosition(cc.p(0,winSize.height - 15))
    titleImg:setPosition(cc.p(winSize.width/2,winSize.height))

    goWarBtn:setVisible(WorldWarMgr.progress == 'rank')
    lastBtn:setVisible(WorldWarMgr.progress == 'rank' and #WorldWarMgr.lastTop32 > 0 )
    
    if WorldWarMgr.progress == 'stop' then
        infoTx:setString(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC22"))
    else
        local conf = GameData:getConfData("worldwarschedule")[32]
        local time = conf.startHour*60
        local str = math.floor(time/60)..':'..(time%60)
        infoTx:setString(string.format(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC5"),
            GlobalApi:getLocalStr("NUM_"..conf.endWeek),str))
    end

    self:updatePanel()
end

return WorldWarMainUI