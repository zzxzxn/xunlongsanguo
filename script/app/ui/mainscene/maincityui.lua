local MainCityUI = class("MainCityUI", BaseUI)
local openTypes = {
    [1] = 'arena',
    [2] = 'boat',
    [3] = 'blacksmith',
    [4] = 'pub',
    [5] = 'mail',
    [6] = 'tower',
    [7] = 'goldmine_enter',
    [8] = 'altar',
    [9] = 'statue',
    [10] = 'train',
    [11] = 'shop',
    [12] = 'worldwar',
}

function MainCityUI:ctor(callback,stype,ntype,waitUIIndex)
	self.uiIndex = GAME_UI.UI_MAINCITY
    self.callback = callback
    self.panelTouchEnable = true
    self.ntype = ntype
    self.stype = stype -- 屏幕位置
    self.allPos = {
        nameImg = {},
        layout = {},
    }
    self.npcPos = nil
    self.waitUIIndex = waitUIIndex

    -- SdkData:sendOrder()
end

function MainCityUI:getMainCity()
    return self.root
end

function MainCityUI:update()
    self:updateSigns()

    self:updateTaskPanel()
end

function MainCityUI:onShow()
    UIManager:setBlockTouch(false)
    self:update()
    self:handAction()
    UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
end

function MainCityUI:openPanel(index)
    UIManager:setBlockTouch(false)
    GlobalApi:getGotoByModule(openTypes[index])
    self.panelTouchEnable = true
    self.panel1:setTouchEnabled(self.panelTouchEnable)
end

function MainCityUI:updateSigns()
    if self.newImgs then
        local signs = {
            false,  -- UserData:getUserObj():getSignByType('arena'),           --群仙会
            false,  -- UserData:getUserObj():getSignByType('boat'),         --上清天
            false,  -- UserData:getUserObj():getSignByType('blacksmith'),      --熔炉
            UserData:getUserObj():getSignByType('tavern'),
            UserData:getUserObj():getSignByType('mail'),
            UserData:getUserObj():getSignByType('tower'),
            false,  -- UserData:getUserObj():getSignByType('goldmine_digging'),        --山海异闻
            UserData:getUserObj():getSignByType('altar'),       --祭坛
            false,  -- UserData:getUserObj():getSignByType('statue'),      --封神榜
            false,
            false,  -- UserData:getUserObj():getSignByType('shop'),  --商店
            UserData:getUserObj():getSignByType('worldwar'),        --九州之争
            UserData:getUserObj():getSignByType('train'),
        }
        local open = {
            GlobalApi:getOpenInfo('arena'),
            GlobalApi:getOpenInfo('boat'),
            GlobalApi:getOpenInfo('blacksmith'),
            GlobalApi:getOpenInfo('pub'),
            true,
            GlobalApi:getOpenInfo('tower'),
            GlobalApi:getOpenInfo('goldmine'),
            GlobalApi:getOpenInfo('altar'),
            GlobalApi:getOpenInfo('statue'),
            false,
            GlobalApi:getOpenInfo('shop'),
            GlobalApi:getOpenInfo('worldwar'),
            GlobalApi:getOpenInfo('train'),
        }
        for i,v in ipairs(self.newImgs) do
            v:setVisible(signs[i] and open[i])
        end
    end
end

--- 更新山海异闻
function MainCityUI:updateGoldMineDiggingSign()
    if self.newImgs then
        if self.newImgs[7]:isVisible() == false then
            -- local sign = UserData:getUserObj():getSignByType('goldmine_digging')
            -- local open = GlobalApi:getOpenInfo('goldmine')
            -- self.newImgs[7]:setVisible(sign and open)
        end      
    end
end

--- 更新上清天
function MainCityUI:updateBoatSign()
    if self.newImgs then
        if self.newImgs[2]:isVisible() == false then
            -- local sign = UserData:getUserObj():getSignByType('boat')
            -- local open = GlobalApi:getOpenInfo('boat')
            -- self.newImgs[2]:setVisible(sign and open)
        end      
    end
end


function MainCityUI:createBuilding()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityLandImg = panel3:getChildByName("main_city_land_img")
    local node_cloud = cityLandImg:getChildByName("node_cloud")

    local conf = GameData:getConfData("local/building")

    local animalScale = 0.2

    self.newImgs = {}

    self.building = {}

    --云相对建筑偏移
    local arr = {
        [8] = {-40,-5,1},    --祭坛
        [6] = {20,-5,2},     --酒馆
        [9] = {20,0,3},      --封神榜
        [1] = {40,-40,4},    --擂台
    }

    local touchX, touchY = 0
    local isCanTouch = true
    for k,v in ipairs(conf) do
        self.building[k] = {}
        self.building[k].nameImg = cityLandImg:getChildByName("building_"..v.pos)
        local size = self.building[k].nameImg:getContentSize()

        --名字背景
        local nameImgBG = ccui.ImageView:create('uires/ui/maincity/maincity_building_bg.png')
        nameImgBG:setPosition(size.width/2, size.height/2)
        local nameImgBGSize = nameImgBG:getContentSize()
        self.building[k].nameImg:addChild(nameImgBG, -1)

        --点击区域
        self.building[k].layout = self.building[k].nameImg:getChildByName("layout_"..v.pos)
        self.building[k].layout:setTouchEnabled(true)
        self.building[k].layout:setAnchorPoint(cc.p(0.5, 0.5))
        self.building[k].layout:setBackGroundColorOpacity(0)
        self.building[k].layout:setSwallowTouches(false)
        self.building[k].layout:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                isCanTouch = true
                touchX = sender:getTouchBeganPosition().x
            elseif eventType == ccui.TouchEventType.moved then
                local touchMoveX = sender:getTouchMovePosition().x
                if math.abs(touchMoveX - touchX) > 32 then
                    isCanTouch = false
                end
            elseif eventType == ccui.TouchEventType.ended then
                if isCanTouch == false then
                    return
                end
                self.building[k].layout:setTouchEnabled(false)
                if sender:getTouchBeganPosition().x == sender:getTouchEndPosition().x or UIManager:getGuideNode() then
                    self.building[k].nameImg:runAction(cc.Sequence:create(
                        cc.ScaleTo:create(0.1,0.9),
                        cc.ScaleTo:create(0.1, 1),
                        cc.CallFunc:create(function()
                            self.building[k].layout:setTouchEnabled(true)
                            self.building[k].layout:setSwallowTouches(false)
                            self:openPanel(v.pos)
                        end)
                    ))
                else
                    self.building[k].layout:setTouchEnabled(true)
                    self.building[k].layout:setSwallowTouches(false)
                end
            end
        end)

        --建筑animation
        self.building[k].animal = GlobalApi:createAniByName(v.url)
        self.building[k].animal:getAnimation():play("idle", -1, -1)
        self.building[k].animal:setScale(animalScale)
        self.building[k].animal:setAnchorPoint(cc.p(0.5, 0.5))
        local layoutSize = self.building[k].layout:getContentSize()
        self.building[k].animal:setPosition(layoutSize.width/2, layoutSize.height/2)
        self.building[k].layout:addChild(self.building[k].animal, -2)

        --小红点
        local newImg = ccui.ImageView:create('uires/ui/buoy/new_point.png')
        newImg:setPosition(size.width / 2, size.height + 16)
        self.newImgs[v.pos] = newImg
        self.building[k].nameImg:addChild(newImg)

        local nameImgPos = cc.p(self.building[k].nameImg:getPositionX(),self.building[k].nameImg:getPositionY())
        local layoutPos = cc.p(self.building[k].layout:getPositionX(),self.building[k].layout:getPositionY())
        self.allPos["nameImg"][v.url] = nameImgPos
        self.allPos["layout"][v.url] = layoutPos

        --锁
        local lockImg = ccui.ImageView:create('uires/ui/buoy/buoy_001.png')
        lockImg:setPosition(cc.p(size.width/2, size.height + 5))
        local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo(openTypes[v.pos])
        if not isOpen then
            self.building[k].nameImg:addChild(lockImg)
        end

        --某些建筑上加云动画
        if arr[k] then
            self.building[k].yun = GlobalApi:createAniByName("yun"..arr[k][3])
            local layoutSize = self.building[k].layout:getContentSize()
            self.building[k].yun:setPosition(layoutSize.width/2 + arr[k][1], arr[k][2])
            self.building[k].yun:getAnimation():play('idle', -1, 1)
            self.building[k].layout:addChild(self.building[k].yun, -1)
        end
    end

    --界面单独加云
    self.cloud = {}

    --云的位置
    local cloudPos = {
        [1] = {1200,200},
    }

    for i=1,#cloudPos do
        self.cloud[i] = GlobalApi:createAniByName("yun"..i+4)              --从5开始为单独加的云
        self.cloud[i]:setPosition(cc.p(cloudPos[i][1],cloudPos[i][2]))
        self.cloud[i]:getAnimation():play('idle', -1, 1)
        self.cloud[i]:setScale(0.6)
        node_cloud:addChild(self.cloud[i])
    end

    -- GuideMgr:startGuideOnlyOnceTest(7, 20)
end

function MainCityUI:monsterMove(pl,npc,npos)
    local posX,posY = npos.x,npos.y
    local pos = {cc.p(posX - 200,posY),cc.p(posX,posY),cc.p(posX + 200,posY)}
    local function getRandom()
        repeat
            local random =math.random(1,3)
            if random == self.random then
                self.random = random %3 + 1
                return
            else
                self.random = random
                return
            end
        until false
    end
    getRandom()
    local posX1 = pos[self.random].x
    local currPosX = pl:getPositionX()
    local time = math.abs(currPosX - posX1)/100
    if currPosX < posX1 then
        npc:setScaleX(math.abs(npc:getScaleX()))
    else
        npc:setScaleX(-math.abs(npc:getScaleX()))
    end

    npc:setAnimation(0,'walk', false)
    pl:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,cc.p(posX1,posY)),
        cc.CallFunc:create(function()
            npc:setAnimation(0,'idle', false)
        end),
        cc.DelayTime:create(math.random(3,5)),
        cc.CallFunc:create(function()
            self:monsterMove(pl,npc,npos)
        end)
    ))
end

function MainCityUI:createNPC()
    local pl = self.cityLandImg:getChildByName('building_img_13')

    local newImg = ccui.ImageView:create('uires/ui/buoy/new_point.png')
    local size = pl:getContentSize()
    newImg:setPosition(size.width, size.height)
    pl:addChild(newImg)

    self.newImgs[13] = newImg
    self.newImgs[13]:ignoreContentAdaptWithSize(true)
    self.newImgs[13]:setLocalZOrder(9)
    local npc = GlobalApi:createSpineByName("train", "spine/city_building/train", 1)
    npc:setScale(0.77)
    local size = pl:getContentSize()
    npc:setName('train')
    npc:setPosition(cc.p(size.width/2,0))
    -- npc:setName('train')
    pl:addChild(npc)
    pl:setLocalZOrder(9)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'walk' then
            npc:setAnimation(0, 'walk', false)
        else
            npc:setAnimation(0, 'idle', false)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'idle2' then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                self:openPanel(13)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function( )
                local pos = cc.p(pl:getPositionX(),pl:getPositionY())
                self:monsterMove(pl,npc,pos)
            end)
            ))
        end
    end, sp.EventType.ANIMATION_END)

    local point1
    local point2
    pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            point1 = sender:getTouchBeganPosition()
        end
        if eventType == ccui.TouchEventType.ended then
            point2 = sender:getTouchEndPosition()
            if point1 then
                local dis =cc.pGetDistance(point1,point2)
                if self.panelTouchEnable == false or dis <= 50 then
                    npc:setAnimation(0, 'idle2', false)
                    pl:stopAllActions()
                    UIManager:setBlockTouch(true)
                end
            end
        end
    end)
    npc:setAnimation(0, 'idle', false)
    
    local pos = cc.p(pl:getPositionX(),pl:getPositionY())
    self:monsterMove(pl,npc,pos)
end

function MainCityUI:createFly1(animal1)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,2)
    local height = size.height - math.random(110,180)
    local beginPos = {
        cc.p(-100,height),
        cc.p(size.width + 100,height),
    }
    local endPos = {
        cc.p(size.width + 100,height),
        cc.p(-100,height),
    }
    animal1:setPosition(cc.p(beginPos[index]))
    if beginPos[index].x < endPos[index].x then
        animal1:setScaleX(-math.abs(animal1:getScaleX()))
    else
        animal1:setScaleX(math.abs(animal1:getScaleX()))
    end
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal1:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly1(animal1)
        end)
        ))
end

function MainCityUI:createFly2(animal2)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,3)
    local beginPos = {
        cc.p(size.width/2 + math.random(-50,50),0),
        cc.p(size.width/2 + math.random(50,150),0),
        cc.p(size.width/2 + math.random(150,250),0)
    }
    local endPos = {
        cc.p(-100,size.height - math.random(50,120)),
        cc.p(size.width/2 - math.random(450,550),size.height + 100),
        cc.p(size.width + 100,size.height - math.random(100,180))
    }
    animal2:setPosition(cc.p(beginPos[index]))
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal2:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly2(animal2)
        end)
        ))
end

-- ntype 是否直接定位
-- 定位
function MainCityUI:setWinPosition(stype,lock)
    print(" setWinPosition  == ",stype)

    if stype == "task" then
        return
    end
    
    if lock then
        self.panelTouchEnable = false
        self.panel1:setTouchEnabled(self.panelTouchEnable)
    end

    if stype == "train" then
        stype = "xunlian"
    end
    
    local buildPosX = self.allPos.nameImg[stype].x + self.allPos.layout[stype].x
    local winSize = cc.Director:getInstance():getVisibleSize()
    local posX = 0

    if buildPosX <= winSize.width/2 then
        return
    else
        posX = buildPosX -  winSize.width/2
        if posX > 960 then
            posX = 960 + self.allPos.layout[stype].x
        end
        local panel1 = self.root:getChildByName("Panel_1")
        local panel2 = panel1:getChildByName("Panel_2")
        local panel3 = panel2:getChildByName("Panel_3")
        local cityCloudImg = panel3:getChildByName("main_city_cloud_img")
        local cityLandImg = panel3:getChildByName("main_city_land_img")
        cityLandImg:setPositionX(-posX)
    end

end

function MainCityUI:initCity()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityCloudImg = panel3:getChildByName("main_city_cloud_img")
    local cityLandImg = panel3:getChildByName("main_city_land_img")
    cityLandImg:setPositionX(-180)
    self.cityLandImg = cityLandImg
    -- cityCloudImg:ignoreContentAdaptWithSize(true)
    self.panel1 = panel1

    local winSize = cc.Director:getInstance():getVisibleSize()
    panel1:setContentSize(winSize)

    local cityLandImgSize = cityLandImg:getContentSize()

    --拖动主界面
    local landPos = 0
    panel1:addTouchEventListener(function (sender, eventType)
        local movePosX = sender:getTouchMovePosition().x
        if eventType == ccui.TouchEventType.began then
            landPos = cityLandImg:getPositionX()
        elseif eventType == ccui.TouchEventType.moved then
            local beganPosX = sender:getTouchBeganPosition().x
            local moveX = movePosX - beganPosX
            cityLandImg:setPositionX(landPos + moveX)

            --边界处理
            if cityLandImg:getPositionX() < -(cityLandImgSize.width - winSize.width) then
                cityLandImg:setPositionX(-(cityLandImgSize.width - winSize.width))
            elseif cityLandImg:getPositionX() > 0 then
                cityLandImg:setPositionX(0)
            end
        end
    end)

    self.Img_Frame = panel1:getChildByName('Img_Frame')
    self:adaptSizeUI(self.Img_Frame)

    self.fightBtn = panel1:getChildByName('fight_btn')
    self.fightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:printScreen()
        end
    end)

    self.task_panel = panel1:getChildByName('task_panel')
    self.task_panel:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --MainSceneMgr:showTask(1)
            MainSceneMgr:showTaskNewUI()
        end
    end)
    self.task_panel:setVisible(false)

    self.task_panel.msg_text = self.task_panel:getChildByName('msg_text')
    self.task_panel.percent_text = self.task_panel:getChildByName('percent_text')
    self.task_panel.get_btn = self.task_panel:getChildByName('get_btn')
    self.task_panel.get_btn.basePosX = self.task_panel.get_btn:getPositionX()
    self.task_panel.btn_text = self.task_panel.get_btn:getChildByName('btn_text')
    self.task_panel.btn_text:setString(GlobalApi:getLocalStr('STR_GET'))
    self.task_panel.new_img = self.task_panel:getChildByName('new_img')

    self:createBuilding()
    self:handAction()
    -- self:createNPC()
    self:update()

    UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
   
    if self.callback then
        self.callback()
    end

    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_FINISH,function()
        if self:isOnTop() then
            UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
        end
    end)
    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_START,function()
        self:handAction(true)
    end)
end

function MainCityUI:handAction(b)
    local panel1 = self.root:getChildByName("Panel_1")
    local level = UserData:getUserObj():getLv()
    local guideImg = panel1:getChildByName('guide_img')
    local size = self.fightBtn:getContentSize()
    if not guideImg then
        guideImg = ccui.ImageView:create('uires/ui/maincity/maincity_new.png')
        guideImg:setPosition(cc.p(size.width*3/4,size.height))
        panel1:addChild(guideImg)
        guideImg:setName('guide_img')
        guideImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.DelayTime:create(0.5),cc.FadeIn:create(2))))
        guideImg:setCascadeOpacityEnabled(true)

        local descTx = ccui.Text:create()
        descTx:setFontName("font/gamefont.ttf")
        descTx:setFontSize(24)
        descTx:setPosition(cc.p(size.width/2 - 5,43))
        descTx:setTextColor(COLOR_TYPE.WHITE)
        descTx:enableOutline(cc.c3b(146,58,5), 1)
        descTx:setAnchorPoint(cc.p(0.5,0.5))
        descTx:setName('desc_tx')
        guideImg:addChild(descTx)
    end
    local descTx = guideImg:getChildByName('desc_tx')
    guideImg:setVisible(false)
    if not b and level <= 15 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_1'))
    elseif not b and level <= 25 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_2'))
    elseif MapMgr.thief then
        local hadThief = false
        local nowTime = GlobalData:getServerTime()
        local conf = GameData:getConfData("thief")
        for k,v in pairs(MapMgr.thief) do
            local thiefConf = conf[tonumber(v.id)]
            local beginTime = tonumber(v.time)
            local diffTime = beginTime + tonumber(thiefConf.liveTime)*60 - GlobalData:getServerTime()
            if diffTime > 0 then
                hadThief = true
                break
            end
        end
        if hadThief then
            guideImg:setVisible(true)
            descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_3'))
        end
    end
end

function MainCityUI:printScreen()
     print(socket.gettime())

     UIManager:runLoadingAction(nil,function()
        MainSceneMgr:hideMainCity()
        -- MapMgr:showMainScene(2,nil,nil,0.4)
        MapMgr:showMainScene(2,nil,nil,nil,true,function()
            UIManager:removeLoadingAction()
        end)
        -- screen:removeFromParent()
    end)
end

function MainCityUI:loadingTexture()
    local loadingUI = UIManager:getLoadingUI()
    loadingUI:setPercent(0)
    local loadedImgCount = 0
    local loadedImgMaxCount = 21
    local function imageLoaded()
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        loadingUI:setPercent(loadingPercent)
        if loadedImgCount >= loadedImgMaxCount then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                loadingUI:runToPercent(0.2, 100, function ()
                    if self.waitUIIndex then
                        self:addCustomEventListener(CUSTOM_EVENT.UI_SHOW, function (uiIndex)
                            if uiIndex == self.waitUIIndex then
                                self:removeCustomEventListener(CUSTOM_EVENT.UI_SHOW)
                                self.waitUIIndex = nil
                                UIManager:hideLoadingUI()
                            end
                        end)
                    else
                        UIManager:hideLoadingUI()
                    end
                    self:initCity()
                end)
            end)))
        end
    end
    UserData:getUserObj():getMainCityInfo(imageLoaded)

    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_building_bg.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/new_point.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/guard/guard_lock.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/fight_nor_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/buoy/fight_sel_btn.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_cash.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_food.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/res_gold.png',imageLoaded)

    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_arena.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_boat.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_blacksmith.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_pub.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_mail.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_tower.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_goldmine.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_altar.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_statue.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_stable.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_shop.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/maincity_worldwar.png',imageLoaded)
end

function MainCityUI:init()
    if self.ntype then
        self:initCity()
    else
        self:loadingTexture()
    end

    if self._isEnter == nil then
        CustomEventMgr:addEventListener("update_maincity_daily",self,function (respData) 
            self:updatePanelByDaily(respData)
        end)
        self._isEnter = true
    end

    local function onNodeEvent(event)
        if "exit" == event then
            CustomEventMgr:removeEventListener("update_maincity_daily",self)
        end
    end

    self.root:registerScriptHandler(onNodeEvent)
end

--更新任务栏信息
function MainCityUI:updateTaskPanel()
    local isShowTask = GlobalApi:getOpenInfo('task')
    self.task_panel:setVisible(isShowTask)
    
    if isShowTask == false then
        return
    end

    self.task_panel.msg_text:setString(GlobalApi:getLocalStr('STR_LOADING'))

    local args = {}
    MessageMgr:sendPost('get','task',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            CustomEventMgr:dispatchEvent("update_maincity_daily", data)
            -- self:updatePanelByDaily(data)
        end
    end)
end

--日常任务检测
function MainCityUI:updatePanelByDaily(respData)
    local dailyDataList, cangetCount = TaskMgr:getDailyData(respData)

    local isSign = 0
    for i,v in ipairs(dailyDataList) do
        local status = v.status
        if v.status == 0 then
            isSign = 1
            break
        end
    end
    UserData:getUserObj():setSignByType('daily_task', isSign)

    self.task_panel.new_img:setVisible(false)
    local sign = UserData:getUserObj():getSignByType('task')
    local open = GlobalApi:getOpenInfo('task')
    self.task_panel.new_img:setVisible(sign and open)
    
    local dailyData = dailyDataList[1]
    if dailyData.status ~= 0 then
        self.task_panel.get_btn:setVisible(false)
    end

    if dailyData.status == 2 then   --已领取
        self.task_panel.msg_text:setString(GlobalApi:getLocalStr('STR_DAILY_TASK_FINISHED'))
    end

    local msgDesc, percentDesc, percentColor = TaskMgr:getDailyCellDesc(dailyData)

    self.task_panel.msg_text:setString(msgDesc)
    self.task_panel.percent_text:setPositionX(self.task_panel.msg_text:getPositionX() + self.task_panel.msg_text:getContentSize().width)
    self.task_panel.percent_text:setColor(percentColor)
    self.task_panel.percent_text:setString(percentDesc)

    local rightPosX = self.task_panel.percent_text:getPositionX() + self.task_panel.percent_text:getContentSize().width
    if rightPosX + self.task_panel.get_btn:getContentSize().width * self.task_panel.get_btn:getScaleX() / 2 + 4 > self.task_panel.get_btn.basePosX then
        self.task_panel.get_btn:setPositionX(rightPosX + self.task_panel.get_btn:getContentSize().width * self.task_panel.get_btn:getScaleX() / 2 + 4)
    else
        self.task_panel.get_btn:setPositionX(self.task_panel.get_btn.basePosX)
    end

    if dailyData.status == 0 then   --可领取
        self.task_panel.get_btn:setVisible(true)
        self.task_panel.btn_text:setString(GlobalApi:getLocalStr('STR_GET'))

        self.task_panel.get_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TaskMgr:getDailyReward(dailyDataList, function(respData2, getTab)
                    local conf = GameData:getConfData('dailytask')
                    for k=1,#getTab do
                        local taskId = getTab[k]
                        if taskId == 16 then
                            UserData:getUserObj().task.daily_reward['16'] = 1
                        end
                        respData.task.daily_reward[tostring(taskId)] = 1
                    end

                    local lastLv = UserData:getUserObj():getLv()
                    local awards = respData2.awards
                    local lockAwards = respData2.already_lock_awards
                    if awards then
                        GlobalApi:parseAwardData(awards)

                        GlobalApi:showAwardsCommon(awards,nil,function ()
                            
                        end,true)
                    end
                    local costs = respData2.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end

                    local nowLv = UserData:getUserObj():getLv()
                    GlobalApi:showKingLvUp(lastLv,nowLv)

                    self:updatePanelByDaily(respData)
                end)
            end
        end)
    elseif dailyData.status == 1 then   --未达成
        self.task_panel.get_btn:setVisible(true)
        self.task_panel.btn_text:setString(GlobalApi:getLocalStr('GOTO_1'))

        self.task_panel.get_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local routeto = GameData:getConfData("routeto")[dailyData.baseConf.key]
                if not routeto then
                    return
                end
                if routeto.value == 1 then
                    GlobalApi:getGotoByModule(routeto.key)
                else
                    GlobalApi:getGotoLegionModule(routeto.key)   
                end
            end
        end)
    end

    return true
end

return MainCityUI