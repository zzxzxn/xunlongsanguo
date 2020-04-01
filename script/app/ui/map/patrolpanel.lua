local PatrolUI = class("PatrolUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PatrolUI:ctor(data,isShow)
	self.uiIndex = GAME_UI.UI_PATROL
    local cityData = MapData.data[MapData.currProgress]
    if cityData:getStar(1) <= 0 then
        self.id = MapData.currProgress - 1
    else
        self.id = MapData.currProgress
    end
    self.data = data
    self.defaultItem = nil
    self.itemIndex = 0
    self.allIds = {}
    self.isShow = isShow
end

function PatrolUI:runAction()
    self.spineAni1:setOpacity(255)
    self.spineAni1:setPosition(self.spineAniPos)
    local action2 = cc.MoveTo:create(3.75,cc.p(397.5,30))
    local action4 = cc.MoveTo:create(0.25,cc.p(370,30))
    local action3 = cc.CallFunc:create(function ()
        self:runHeroSpineAction('skill1')
    end)
    local action5 = cc.CallFunc:create(function ()
        self:runSSpineAction('attack')
    end)
    self.spineAni1:runAction(cc.Sequence:create(action2,action3,action4,action5))
    self:runBgAction()
end

function PatrolUI:runHeroSpineAction(spine)
    -- self.spineAni:setAnimation(0, spine, false)
    self.spineAni:getAnimation():play(spine, -1, -1)
end

function PatrolUI:runSSpineAction(spine)
    -- self.spineAni1:setAnimation(0, spine, false)
    self.spineAni1:getAnimation():play(spine, -1, -1)
end

function PatrolUI:runAgain()
    if self.goldActionEnd == true and self.fadeinEnd == true then
        self:runSpineAction()
    end
end

function PatrolUI:runSpineAction()
    self.beginTime = socket.gettime()
    self:runBgAction()
    -- self.spineAni:setAnimation(0, 'run', true)
    self.spineAni:getAnimation():play('run', -1, 1)
    -- self.spineAni1:setAnimation(0, 'run', true)
    self.spineAni1:getAnimation():play('run', -1, 1)
    self:runAction()
end

function PatrolUI:runGoldAction()
    local goldImg = self.bgSv:getChildByTag(9999)
    local expImg = goldImg:getChildByTag(9999)
    local posX,posY = 380,55
    goldImg:setPosition(cc.p(posX,posY))
    local bezier ={
        cc.p(posX+20,posY-10),
        cc.p(posX + 100,posY + 25),
        cc.p(self.getBtn:getPositionX(),self.getBtn:getPositionY())
    }   
    local bezier1 ={
        cc.p(posX,posY),
        cc.p(posX + 10,posY - 5),
        cc.p(400,45)
    }  
    local bezierTo = cc.BezierTo:create(0.6, bezier)
    goldImg:setScale(0.7)
    goldImg:setVisible(true)
    goldImg:setOpacity(1)
    self.goldActionEnd = false
    goldImg:runAction(cc.Sequence:create(cc.BezierTo:create(0.3, bezier1)))
    goldImg:runAction(cc.FadeIn:create(0.2))
    goldImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),
        bezierTo,
        cc.CallFunc:create(function ()
            local goldTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
            goldTx:setColor(COLOR_TYPE.GREEN)
            goldTx:enableOutline(COLOR_TYPE.BLACK, 1)
            goldTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            goldTx:setLocalZOrder(10)
            local cityData = MapData.data[self.id]
            local gold = cityData:getPatrolGold()
            local posX,posY = self.getBtn:getPositionX(),self.getBtn:getPositionY()
            goldTx:setString(GlobalApi:getLocalStr('STR_GOLD')..'+'.. gold)
            goldTx:setPosition(cc.p(posX,posY))
            goldTx:runAction(cc.Sequence:create(cc.MoveTo:create(2.5,cc.p(posX,posY + 50)),cc.CallFunc:create(function()
                goldTx:removeFromParent()
            end)))
            goldTx:runAction(cc.FadeOut:create(2.5))
            self.bgSv:addChild(goldTx)

            local expTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
            expTx:setColor(COLOR_TYPE.GREEN)
            expTx:enableOutline(COLOR_TYPE.BLACK, 1)
            expTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            expTx:setLocalZOrder(10)
            local cityData = MapData.data[self.id]
            local exp = cityData:getPatrolXp()
            local posX,posY = self.getBtn:getPositionX(),self.getBtn:getPositionY() - 25
            expTx:setString(GlobalApi:getLocalStr('STR_XP')..'+'.. exp)
            expTx:setPosition(cc.p(posX,posY))
            expTx:runAction(cc.Sequence:create(cc.MoveTo:create(2.5,cc.p(posX,posY + 50)),cc.CallFunc:create(function()
                expTx:removeFromParent()
            end)))
            expTx:runAction(cc.FadeOut:create(2.5))
            self.bgSv:addChild(expTx)

            self.goldActionEnd = true
            self:runAgain()
            goldImg:setVisible(false)
        end))
    )
    goldImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),
        cc.ScaleTo:create(0.6,0.2))
    )
end
function PatrolUI:registerAction()
    local function movementFun(armature, movementType, movementID)
        --0 开始
        --1 完成
        if movementType == 0 then
            if movementID == 'skill1' then
                self.protalBgImg:stopAllActions()
                self.protalBgImg1:stopAllActions()
            end
        elseif movementType == 1 then
            -- 动作完成
            if movementID == 'skill1' then
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
                    -- self.spineAni:setAnimation(0, 'idle', true)
                    self.spineAni:getAnimation():play('idle', -1, 1)
                end)))
            end
        end
    end
    local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
        if frameEventName == "-1" then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ()
                self:runSSpineAction('dead')
                self:runGoldAction()
            end)))
        end
    end
    self.spineAni:getAnimation():setMovementEventCallFunc(movementFun)
    self.spineAni:getAnimation():setFrameEventCallFunc(frameFun)

    local function movementFun1(armature, movementType, movementID)
        if movementType == 1 then
            -- 动作完成
            if movementID == 'dead' then
                self.fadeinEnd = false
                self.spineAni1:runAction(cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function ()
                    self.fadeinEnd = true
                    self:runAgain()
                end)))
                -- self:runGoldAction()
            end
        end
    end
    self.spineAni1:getAnimation():setMovementEventCallFunc(movementFun1)

    self:runSpineAction()
end

function PatrolUI:runBgAction1()
    self.protalBgImg:stopAllActions()
    local size = self.protalBgImg:getContentSize()
    local endPoint = cc.p(0 - size.width,0)
    local timeTotal = 30
    local speed = size.width/timeTotal
    local time = 0.1

    local pos = cc.p(self.protalBgImg:getPositionX(),self.protalBgImg:getPositionY())
    local action = cc.MoveTo:create(math.abs(endPoint.x - pos.x)/speed,cc.p(endPoint.x,pos.y))
    local actionFun = cc.CallFunc:create(function () 
        local size = self.protalBgImg:getContentSize()
        local p = cc.p(self.protalBgImg1:getPositionX(),self.protalBgImg1:getPositionY())
        self.protalBgImg:setPosition(cc.p(p.x + size.width - time*timeTotal - 4,p.y))
        self.protalBgImg:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction1()
        end)))
    end)
    self.protalBgImg:runAction(cc.Sequence:create(action,actionFun))
end

function PatrolUI:runBgAction2()
    self.protalBgImg1:stopAllActions()
    local size = self.protalBgImg:getContentSize()
    local endPoint = cc.p(0 - size.width,0)
    local timeTotal = 30
    local speed = size.width/timeTotal
    local time = 0.1

    local pos1 = cc.p(self.protalBgImg1:getPositionX(),self.protalBgImg1:getPositionY())
    local action1 = cc.MoveTo:create(math.abs(endPoint.x - pos1.x)/speed,cc.p(endPoint.x,pos1.y))
    local actionFun1 = cc.CallFunc:create(function ()
        local size = self.protalBgImg:getContentSize()
        local p = cc.p(self.protalBgImg:getPositionX(),self.protalBgImg:getPositionY())
        self.protalBgImg1:setPosition(cc.p(p.x + size.width - time*timeTotal - 4,p.y))
        self.protalBgImg1:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction2()
        end)))
    end)

    self.protalBgImg1:runAction(cc.Sequence:create(action1,actionFun1))
end
function PatrolUI:runBgAction()
    self:runBgAction1()
    self:runBgAction2()
end

function PatrolUI:getDefaultItem()
    local ret = ccui.ImageView:create()
        :setTouchEnabled(false)
        :loadTexture('uires/ui/common/frame_bg.png')
        :setAnchorPoint(0,0)
        :setTouchEnabled(true)
        :setName('awardBgImg1')

    ccui.Text:create()
        :setFontName('font/gamefont.ttf')
        :setFontSize(20)
        :setPosition(cc.p(65,115))
        :setColor(COLOR_TYPE.WHITE)
        :enableOutline(COLOR_TYPE.BLACK, 1)
        :setAnchorPoint(cc.p(0.5,0.5))
        :setName('name_tx')
        :addTo(ret)

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)

    cell.awardBgImg:setPosition(cc.p(64, 56))
    ret:addChild(cell.awardBgImg)
    return ret
end

function PatrolUI:createAwardList()
    local equipType = 6
    local equipTab = {0,0,0,0,0,0}
    local currProgress = 0
    local star = MapData.data[MapData.currProgress]:getStar(1)
    if star > 0 then
        currProgress = MapData.currProgress
    else
        currProgress = MapData.currProgress - 1
    end

    if self.defaultItem == nil then
        self.defaultItem = self:getDefaultItem()
        self.listSv:setItemModel(self.defaultItem)
        self.listSv:setItemsMargin(12)
    end
    local tab = {}
    for i=currProgress,1,-1 do
        local cityData = MapData.data[i]
        if cityData then
            local unlockAwards = cityData:getPatrolEquip()
            for j,v in pairs(unlockAwards) do
                if equipTab[j] == 0 then
                    equipTab[j] = 1
                    tab[j] = {v,i}
                end
            end
        end
    end
    for i,v in ipairs(tab) do
        self.listSv:pushBackDefaultItem()
        local childrenCount = self.listSv:getChildrenCount()
        local item = self.listSv:getItem(childrenCount - 1)

        local award = DisplayData:getDisplayObj(v[1])
        self.allIds[award:getId()] = {childrenCount - 1,v[2]}

        local awardBgImg = item:getChildByName('award_bg_img')
        ClassItemCell:updateItem(awardBgImg, award, 2)
        local lvTx = awardBgImg:getChildByName('lv_tx')
        lvTx:setVisible(true)
        lvTx:setString('Lv.'..award:getLevel())

        local obj = award:getObj()
        if obj then
            item:getChildByName('name_tx')
                :setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..obj:getType()))
        end

        item:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(award,false)
            end
        end)
    end
end

function PatrolUI:updatePanel()
    local cityData = MapData.data[self.id]
	self.goldTx:setString(cityData:getPatrolGold())
	self.expTx:setString(cityData:getPatrolXp())
    local keyArr = string.split(cityData:getName() , '.')
    self.cityNameTx:setString(GlobalApi:getLocalStr('PATROL_-')..keyArr[#keyArr])
    local diffTime = GlobalData:getServerTime() - MapData.patrol
    if diffTime > tonumber(GlobalApi:getGlobalValue('patrolMaxTime')) then
        diffTime = tonumber(GlobalApi:getGlobalValue('patrolMaxTime'))
    end
    if MapData.patrol == 0 then
        diffTime = 3600
    end

    local tx1 = GlobalApi:getLocalStr('HAD_PATROL1')
    local tx2 = tostring(math.floor(diffTime/3600))
    local tx3 = GlobalApi:getLocalStr('HOUR')
    local tx4 = tostring(math.floor((diffTime%3600)/60))
    local tx5 = GlobalApi:getLocalStr('MINUTE')
    if not self.rt1 then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(170, 30))
        local re1 = xx.RichTextLabel:create(tx1, 21, COLOR_TYPE.ORANGE)
        local re2 = xx.RichTextLabel:create(tx2, 21, COLOR_TYPE.GREEN)
        local re3 = xx.RichTextLabel:create(tx3, 21, COLOR_TYPE.ORANGE)
        local re4 = xx.RichTextLabel:create(tx4, 21, COLOR_TYPE.GREEN)
        local re5 = xx.RichTextLabel:create(tx5, 21, COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re4:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        re5:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:addElement(re4)
        richText:addElement(re5)
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(cc.p(15,135))
        self.bgSv:addChild(richText)
        self.rt1 = {richText = richText,re1 = re1,re2 = re2,re3 = re3,re4 = re4,re5 = re5}
    else
        self.rt1.re1:setString(tx1)
        self.rt1.re2:setString(tx2)
        self.rt1.re3:setString(tx3)
        self.rt1.re4:setString(tx4)
        self.rt1.re5:setString(tx5)
    end
    -- local infoTx = self.getBtn:getChildByName('info_tx')
    if diffTime < tonumber(GlobalApi:getGlobalValue('patrolInterval'))*60 then
        self.getBtn:setBright(false)
        self.getBtn:setTouchEnabled(false)
        -- infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
    else
        self.getBtn:setBright(true)
        self.getBtn:setTouchEnabled(true)
        -- infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    end
    -- self:createAwardList()
    -- self:scrollToIndex(0)
end

function PatrolUI:init()
    self.intervalSize = 20
	local bgImg = self.root:getChildByName("patrol_bg_img")
	local patrolImg = bgImg:getChildByName("patrol_img")
    self:adaptUI(bgImg, patrolImg)
    self.neiBgImg = patrolImg:getChildByName("patrol_nei_img")
    local winSize = cc.Director:getInstance():getVisibleSize()
    patrolImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
    local timeInfoTx = patrolImg:getChildByName("time_info_tx")
    local closeBtn = patrolImg:getChildByName("close_btn")
    self.bgSv = self.neiBgImg:getChildByName("bg_sv")
    local kuangImg = self.bgSv:getChildByName("kuang_img")
    kuangImg:setLocalZOrder(2)
    self.bgSv:setScrollBarEnabled(false)
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePatrolPanel()
        end
    end)

    self.fightingBtn = patrolImg:getChildByName("fighting_btn")
    local infoTx = self.fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('GO_FIGHITING'))
    self.accelerateBtn = patrolImg:getChildByName("accelerate_btn")
    infoTx = self.accelerateBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('ACCELERATE_PATROL'))
    self.getBtn = self.bgSv:getChildByName("get_btn")
    self.getBtn:setLocalZOrder(9)

    local addition_img = self.bgSv:getChildByName("addition_img")
    addition_img:setTouchEnabled(true)
    local additionPos = self.bgSv:convertToWorldSpace(cc.p(addition_img:getPosition()))
    addition_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TipsMgr:showJadeSealAdditionTips(additionPos, "patrol")
        end
    end)
    addition_img:setLocalZOrder(10)
    local addition_tx = addition_img:getChildByName("addition_tx")

    local addition = UserData:getUserObj():getJadeSealAddition("patrol")
    addition_tx:setString(addition[2] .. "%")
    if not addition[1] then
        ShaderMgr:setGrayForWidget(addition_img)
        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end

    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePatrolPanel()
            MapMgr:showMainScene(2,MapData.currProgress,function()
                MapMgr:showExpeditionPanel(MapData.currProgress)
            end)
        end
    end)
    self.accelerateBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_ACCELERATE_DESC'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            --     -- body
            -- end)
            MapMgr:showPatrolSpeedPanel(function()
                self:updatePanel()
            end)
        end
    end)
    self.getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if BagData:getEquipFull() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
                return
            end
            local args = {}
            MessageMgr:sendPost('patrol_get_award','battle',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    local lastLv = UserData:getUserObj():getLv()

                    local awards = data.awards
                    local gold_xp = data.gold_xp
                    if #awards > 0 then
                        MapMgr:showPatrolAwardsPanel(awards)
                    end
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:parseAwardData(gold_xp)
                    local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    MapData.patrol = data.patrol or MapData.patrol
                    self:updatePanel()

                    local nowLv = UserData:getUserObj():getLv()
                    GlobalApi:showKingLvUp(lastLv,nowLv)
                end
            end)
        end
    end)

    self.protalBgImg = self.bgSv:getChildByName("protal_bg_1_img")
    self.protalBgImg1 = self.bgSv:getChildByName("protal_bg_2_img")
    local awardBgImg = self.neiBgImg:getChildByName("award_bg_img")
    local titleImg = awardBgImg:getChildByName("title_bg_img")
    local titleTx = titleImg:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('AUTO_CAN_GET'))
    local leftBtn = awardBgImg:getChildByName("left_btn")
    local rightBtn = awardBgImg:getChildByName("right_btn")
    leftBtn:setVisible(false)
    rightBtn:setVisible(false)
    -- self.listSv = xx.ScrollView:create()
    self.listSv = ccui.ListView:create()
    self.listSv:setAnchorPoint(cc.p(0.5,0.5))
    self.listSv:setPosition(cc.p(451.00,76.5))
    self.listSv:setContentSize(cc.size(840,200))
    self.listSv:setScrollBarEnabled(false)
    self.listSv:setTouchEnabled(true)
    self.listSv:setDirection(ccui.ListViewDirection.horizontal)
    self.listSv:setGravity(ccui.ListViewGravity.centerVertical)
    self.listSv:setBounceEnabled(true)
    awardBgImg:addChild(self.listSv)
    -- self.listSv = awardBgImg:getChildByName("list_sv")
    -- self.listSv:setScrollBarEnabled(false)
    self.bgSv:setTouchEnabled(false)

    local goldImg = ccui.ImageView:create()
    goldImg:setTouchEnabled(false)
    goldImg:loadTexture('uires/ui/res/res_gold.png')
    self.bgSv:addChild(goldImg,1,9999)
    goldImg:setPosition(cc.p(-100,-120))
    goldImg:setScale(0.7)
    local size = goldImg:getContentSize()
    local expImg = ccui.ImageView:create()
    expImg:loadTexture('uires/ui/common/icon_exp.png')
    expImg:setPosition(cc.p(size.width/2,-5))
    goldImg:addChild(expImg,1,9999)

    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.itemIndex = self.itemIndex + 1
            local childrenCount = self.listSv:getChildrenCount()
            if self.itemIndex > childrenCount then
                self.itemIndex = childrenCount
            end
            self.listSv:scrollToItem(self.itemIndex, cc.p(0, 0), cc.p(0, 0), 0.1)
            -- self.index = self.index - 1
            -- self:scrollToIndex(1)
        end
    end)
    leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.itemIndex = self.itemIndex - 1
            if self.itemIndex < 0 then
                self.itemIndex = 0
            end
            self.listSv:scrollToItem(self.itemIndex, cc.p(0, 0), cc.p(0, 0), 0.1)
            -- self.index = self.index + 1
            -- self:scrollToIndex(-1)
        end
    end)

    local titleImg = patrolImg:getChildByName("title_img")
    self.cityNameTx = titleImg:getChildByName("city_name_tx")

    local nameBgImg = self.neiBgImg:getChildByName("name_bg_img")
   	self.goldTx = nameBgImg:getChildByName("gold_tx")
    self.expTx = nameBgImg:getChildByName("exp_tx")
    infoTx = nameBgImg:getChildByName("info_1_tx")
    infoTx:setString(GlobalApi:getLocalStr('PER_MIN_CAN_GET'))
    infoTx = nameBgImg:getChildByName("info_2_tx")
    infoTx:setString(GlobalApi:getLocalStr('PER_MIN_CAN_GET'))

    local role = RoleData:getMainRole()
    self.spineAni = GlobalApi:createLittleLossyAniByName(role:getUrl()..'_display', nil, role:getChangeEquipState())
    self.spineAni:setScale(0.4)
    self.spineAni:setPosition(cc.p(300,345))
    patrolImg:addChild(self.spineAni)

    self.spineAni1 = GlobalApi:createArmature("daobing_1_r", "animation/daobing_1_r/daobing_1_r", nil, 1)
    self.spineAni1:setPosition(cc.p(860,30))
    self.spineAni1:setScaleX(-1)
    self.spineAni1:setScaleY(1)
    self.spineAniPos = cc.p(860,30)
    self.bgSv:addChild(self.spineAni1,1)

    self:updatePanel()
    self:createAwardList()
    self:registerAction()

    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        local fightedId = MapData:getFightedCityId()
        if self.isShow or (fightedId == 10 and GuideMgr:isRunning() == true) then
            self:runShake()
        end
    end)))
end

function PatrolUI:runShake()
    local awardTab = MapData.data[self.id]:getPatrolEquip()
    local tab = {}
    for k,v in pairs(awardTab) do
        tab[#tab + 1] = v
    end
    for i,v in ipairs(tab) do
        local award = DisplayData:getDisplayObj(v)
        local obj = award:getObj()
        local index,cityId
        for k,v in pairs(self.allIds) do
            if award:getId() == k then
                index = v[1]
                cityId = v[2]
            end
        end
        if not index or not cityId then
            return
        end

        local equip
        for i= cityId - 1,1,-1 do
            local cityData = MapData.data[i]
            if cityData then
                local unlockAwards = cityData:getPatrolEquip()
                for j,v in pairs(unlockAwards) do
                    local award1 = DisplayData:getDisplayObj(unlockAwards[j])
                    local obj1 = award1:getObj()
                    if obj:getType() == obj1:getType() then
                        equip = award1
                        break
                    end
                end
                if equip then
                    break
                end
            end
        end

        if not equip then
            return
        end

        local item = self.listSv:getItem(index)
        local function update(award)
            item:getChildByName('award_bg_img')
                :loadTexture(award:getBgImg())
            item:getChildByName('award_bg_img'):getChildByName('award_img')
                :loadTexture(award:getIcon())
            item:getChildByName('award_bg_img'):getChildByName('lv_tx')
                :setString('Lv.'..award:getLevel())
            local obj = award:getObj()
            if obj then
                -- item:getChildByName('award_bg_img'):getChildByName('name_tx')
                --     :setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..obj:getType()))
            end
        end
        update(equip,true)

        item:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.2, 1),
            cc.ScaleTo:create(0.2, 1.2),
            cc.ScaleTo:create(0.2, 1),
            cc.CallFunc:create(function()
                local awardBgImg = item:getChildByName('award_bg_img')
                local size = awardBgImg:getContentSize()
                local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(awardBgImg:getPosition())
                particle:setName('getitem')
                particle:setScale(1.5)
                item:addChild(particle)
            end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function()
                update(award)
            end)
            ))
    end
end

return PatrolUI