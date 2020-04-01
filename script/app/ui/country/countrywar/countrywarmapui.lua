local CountryWarMapUI = class("CountryWarMapUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local BuoyZOrder = 10007 -- tag 9992 - 3
local CityNameZOrder = 10004
local CityAnimationZOrder = 5 --tag 9999 - 8
local CityZOrder = 10003

local MAX_WIDTH = 3584
local MAX_HEIGHT = 2560
local MAX_CITY_PASS = 15
local SPINE_ZORDER = 10020
local MAX_LITTLE_MSG = 5
-- local stypes = {'forward','specialMove','info'}
local BTNS = {
    ['forward'] = 'uires/ui/countrywar/qianwang.png',
    ['specialMove'] = 'uires/ui/countrywar/tujin.png',
    ['info'] = 'uires/ui/countrywar/junqing.png',
    ['back'] = 'uires/ui/countrywar/back.png',
    ['retreat'] = 'uires/ui/countrywar/chejun.png',
}
local SBTNS = {
    ['forward'] = 'uires/ui/countrywar/qianwang.png',
    ['specialMove'] = 'uires/ui/countrywar/tujin.png',
    ['info'] = 'uires/ui/countrywar/junqing.png',
    ['back'] = 'uires/ui/countrywar/back.png',
    ['retreat'] = 'uires/ui/countrywar/chejun.png',
}

local CAMP_COLOR = {
    COLOR_TYPE.BLUE,
    COLOR_TYPE.GREEN,
    COLOR_TYPE.RED,
}
function CountryWarMapUI:ctor(cityId,callback,callback1)
    self.chatMsgs = {}
    self.chatVisible = true

    self.uiIndex = GAME_UI.UI_COUNTRYWAR_MAP
    -- self.cityId = tonumber(CountryWarMgr.myCity)
    -- local conf = GameData:getConfData("countrywarcity")
    print('=================',cityId,CountryWarMgr.myCity)
    -- self.winBcakId = conf[cityId or CountryWarMgr.myCity].bcakId
    self.winCityId = cityId or CountryWarMgr.myCity
    self.callback = callback
    self.callback1 = callback1
    CountryWarMgr.mapClose = false
    self.camp = CountryWarMgr.camp
    -- promptmgr:showSystenHint('我的国家'..self.camp..'我的城池'..CountryWarMgr.myCity, COLOR_TYPE.RED)
    self.allBgId = {}
    self.littleChatMsgs = {}
    self.littleChatRts = {}
    self.topChatMsgs = {}
    self.chatEnd = true
    self.chatEnd1 = true
    -- print(socket.gettime(),'==================map2')
    -- if not self.cityId then
    --     local fightedId = MapData:getFightedCityId()
    --     local isFirst = MapData.data[fightedId]:getBfirst()
    --     if isFirst == true then
    --         self.cityId = fightedId
    --     end
    -- end
end

--边界检测
function CountryWarMapUI:detectEdges( point )
    if point.x > self.limitRW then
        point.x = self.limitRW
    end
    if point.x < self.limitLW then
        point.x = self.limitLW
    end
    if point.y > self.limitUH then
        point.y = self.limitUH
    end
    if point.y < self.limitDH then
        point.y = self.limitDH
    end
end

--重置边界值
function CountryWarMapUI:setLimit()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local point = self.panel3:getAnchorPoint()
    self.limitLW = winSize.width - MAX_WIDTH*(1 - point.x)
    self.limitRW = MAX_WIDTH*point.x
    self.limitUH = MAX_HEIGHT*point.y
    self.limitDH = winSize.height - MAX_HEIGHT*(1 - point.y)
end

function CountryWarMapUI:updateMapPosition(pos,isNotAction,time)
    self.mapKuangImg:stopAllActions()
    local size = self.mapPl:getContentSize()
    local size1 = self.mapKuangImg:getContentSize()
    local mapPos = cc.p(math.abs(pos.x)/MAX_WIDTH*size.width + size1.width/2,math.abs(pos.y)/MAX_HEIGHT*size.height + size1.height/2)
    if isNotAction then
        self.mapKuangImg:setPosition(mapPos)
    else
        self.mapKuangImg:runAction(cc.Sequence:create(cc.MoveTo:create(time or 0.5,mapPos)))
    end
end

-- ntype 是否直接定位
-- 定位
function CountryWarMapUI:setWinPosition(pos,isNotAction,cityId,callback)
    self.panel3:stopAllActions()
    self.root:stopAllActions()
    if not pos then
        local conf = GameData:getConfData("countrywarcity")[cityId or CountryWarMgr.myCity]
        local winSize = cc.Director:getInstance():getVisibleSize()
        pos = cc.p(-conf.posX + winSize.width/2,-conf.posY + winSize.height/2)
        self:detectEdges(pos)
    end
    if isNotAction then
        self.panel3:setPosition(pos)
        self:createBgByPos()
        if callback then
            callback()
        end
    else
        self.panel3:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,pos),cc.CallFunc:create(function()
            self:createBgByPos()
            if callback then
                callback()
            end
        end)))
    end
    self:updateMapPosition(pos,isNotAction)
end

function CountryWarMapUI:onShow()
    -- if self.isNotShow then
    --     UIManager:showSidebar({1,2,4,5,6},{1,2,3},true)
    --     self.isNotShow = false
    --     return
    -- end
    -- if self.isNotOnShow then
    --     -- 飞龙飞，会打开刘备合成界面,不刷新
    --     self:updateRunBar()
    --     UIManager:showSidebar({1,2,4,5,6},{1,2,3},true)
    --     self.isNotOnShow = false
    --     return
    -- end
    -- if self.ntype1 ~= 1 then
    --     self:updateCityName()
    UIManager:showSidebar({1},{3,23},true)
    self:setBtnsVisible()
    --     self:updateLocation()
    --     self:updateFinger()
    --     UIManager:showSidebar({1,2,4,5,6},{1,2,3},true)
    -- end
    -- self.ntype1 = 0
    self:updateChatShowStatus()
    self:updateNewImgs()
end

function CountryWarMapUI:updateMapHandler()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local MAX_SCALE = 1
    local startDistance = 0
    local touchArr = {}
    local currLocationArr = {}
    local moveFlag = true
    local isDraging = false
    local midpointNormalize =cc.p(0,0)
    local lastTouche1 = cc.p(0,0)
    self.mapPl:addTouchEventListener(function (sender, eventType)
        local pos
        if eventType == ccui.TouchEventType.moved then
            pos = sender:getTouchMovePosition()
        elseif eventType == ccui.TouchEventType.canceled then

        elseif eventType == ccui.TouchEventType.began then
            pos = sender:getTouchBeganPosition()
        elseif eventType == ccui.TouchEventType.ended then
            -- pos = sender:getTouchEndPosition()
        end
        if pos then
            local size = self.mapPl:getContentSize()
            local perX = pos.x/size.width
            local perY = (pos.y + size.height - winSize.height)/size.height
            local point = cc.p(-perX*MAX_WIDTH + winSize.width/2,-perY*MAX_HEIGHT + winSize.height/2)
            self:detectEdges(point)
            self:setWinPosition(point,true)
        end
    end)

    local bgPanelPrePos = nil
    local bgPanelPos = nil
    local bgPanelDiffPos = nil
    local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    local beginTime = 0
    local endTime = 0
    local a = 0
    local b = 0
    local isHideBtn = false
    self.panel1:addTouchEventListener(function (sender, eventType)
        if not moveFlag then
            return
        end
        if eventType == ccui.TouchEventType.moved then
            -- self:hideBtns(1)
            isHideBtn = true
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
                bgPanelDiffPos = cc.p(bgPanelPos.x - bgPanelPrePos.x, bgPanelPos.y - bgPanelPrePos.y)
                local targetPos = cc.pAdd(cc.p(self.panel3:getPositionX(),self.panel3:getPositionY()),bgPanelDiffPos)
                self:detectEdges(targetPos)
                self.panel3:setPosition(targetPos)
                self:updateMapPosition(targetPos,true)
                self:setBtnsVisible()
            end
        else
            if eventType == ccui.TouchEventType.canceled then
                if isHideBtn == true then
                    -- self:hideBtns(2)
                    isHideBtn = false
                end
            end
            bgPanelPrePos = nil
            bgPanelPos = nil
            bgPanelDiffPos = nil
            if eventType == ccui.TouchEventType.began then
                beginTime = socket.gettime()
                self.panel3:stopAllActions()
                self.mapKuangImg:stopAllActions()
                self.root:stopAllActions()
                beginPoint = sender:getTouchBeganPosition()
            end
            if eventType == ccui.TouchEventType.ended then
                if isHideBtn == true then
                    -- self:hideBtns(2)
                    isHideBtn = false
                end
                endPoint= sender:getTouchEndPosition()
                endTime = socket.gettime()
                local aSpeed = 0.8
                local speedX = endPoint.x - beginPoint.x
                local speedY = endPoint.y - beginPoint.y
                if (math.abs(speedX) < 50 and math.abs(speedY) < 50) or (endTime - beginTime)*1000 > 300 then
                    self:createBgByPos()
                    return
                end
                local diffPoint1 =cc.p(speedX*aSpeed,speedY*aSpeed)
                local diffPoint2 =cc.p(diffPoint1.x + speedX*math.pow(aSpeed,2),diffPoint1.y + speedY*math.pow(aSpeed,2))
                local diffPoint3 =cc.p(diffPoint2.x + speedX*math.pow(aSpeed,3),diffPoint2.y + speedY*math.pow(aSpeed,3))
                local diffPoint4 =cc.p(diffPoint3.x + speedX*math.pow(aSpeed,4),diffPoint3.y + speedY*math.pow(aSpeed,4))
                local diffPoint5 =cc.p(diffPoint4.x + speedX*math.pow(aSpeed,5),diffPoint4.y + speedY*math.pow(aSpeed,5))
                local diffPoint6 =cc.p(diffPoint5.x + speedX*math.pow(aSpeed,6),diffPoint5.y + speedY*math.pow(aSpeed,6))
                local diffPoint7 =cc.p(diffPoint6.x + speedX*math.pow(aSpeed,7),diffPoint6.y + speedY*math.pow(aSpeed,7))
                local diffPoint8 =cc.p(diffPoint7.x + speedX*math.pow(aSpeed,8),diffPoint7.y + speedY*math.pow(aSpeed,8))
                local diffPoint9 =cc.p(diffPoint8.x + speedX*math.pow(aSpeed,9),diffPoint8.y + speedY*math.pow(aSpeed,9))
                local tab = {diffPoint1,diffPoint2,diffPoint3,diffPoint4,diffPoint5,diffPoint6,diffPoint7,diffPoint8,diffPoint9}
                local x = self.panel3:getPositionX()
                local y = self.panel3:getPositionY()
                local newPoint1 = cc.pAdd(cc.p(x,y),diffPoint1)
                local newPoint2 = cc.pAdd(cc.p(x,y),diffPoint2)
                local newPoint3 = cc.pAdd(cc.p(x,y),diffPoint3)
                local newPoint4 = cc.pAdd(cc.p(x,y),diffPoint4)
                local newPoint5 = cc.pAdd(cc.p(x,y),diffPoint5)
                local newPoint6 = cc.pAdd(cc.p(x,y),diffPoint6)
                local newPoint7 = cc.pAdd(cc.p(x,y),diffPoint7)
                local newPoint8 = cc.pAdd(cc.p(x,y),diffPoint8)
                local newPoint9 = cc.pAdd(cc.p(x,y),diffPoint9)

                self:detectEdges(newPoint1)
                self:detectEdges(newPoint2)
                self:detectEdges(newPoint3)
                self:detectEdges(newPoint4)
                self:detectEdges(newPoint5)
                self:detectEdges(newPoint6)
                self:detectEdges(newPoint7)
                self:detectEdges(newPoint8)
                self:detectEdges(newPoint9)
                self.panel3:runAction(
                    cc.Sequence:create(
                    cc.MoveTo:create(0.1, newPoint1),
                    cc.MoveTo:create(0.1, newPoint2),
                    cc.MoveTo:create(0.1, newPoint3),
                    cc.MoveTo:create(0.1, newPoint4),
                    cc.MoveTo:create(0.1, newPoint5),
                    cc.MoveTo:create(0.1, newPoint6),
                    cc.MoveTo:create(0.1, newPoint7),
                    cc.MoveTo:create(0.1, newPoint8),
                    cc.CallFunc:create(function()
                        self:createBgByPos()
                    end))
                    )
                self.root:runAction(
                    cc.Sequence:create(
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint1,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint2,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint3,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint4,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint5,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint6,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint7,false,0.1)
                    end),
                    cc.DelayTime:create(0.1),                    
                    cc.CallFunc:create(function()
                        self:updateMapPosition(newPoint8,false,0.1)
                    end))
                    )
            end
        end
    end)
end

function CountryWarMapUI:createBgByPos(pos)
    local index = 0
    for i=1,35 do
        if self.allBgId[i] then
            index = index + 1
        end
    end
    if index >= 35 then
        return
    end
    local posX,posY
    if pos then
        posX,posY = pos.x,pos.y
    else
        posX,posY = self.panel3:getPosition()
    end
    local anchor = self.panel3:getAnchorPoint()
    local leftBottomPosX,leftBottomPosY = math.abs(posX - 3583*anchor.x),math.abs(posY - 2559*anchor.y)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local points = {
        cc.p(leftBottomPosX,leftBottomPosY + winSize.height), -- 左上
        cc.p((leftBottomPosX + winSize.width),leftBottomPosY + winSize.height),
        cc.p(leftBottomPosX,leftBottomPosY),
        cc.p(leftBottomPosX + winSize.width,leftBottomPosY),
    }
    local function getBg(point)
        local x = (point.x - point.x%512)/512 + 1
        local y = (point.y - point.y%512)/512 + 1
        return (5 - y)*7 + x
    end
    local ids = {}
    for i,v in ipairs(points) do
        local bgId = getBg(v)
        ids[i] = bgId
    end
    local newIds = {}
    local leftIds = {}
    local rightIds = {}
    for i=ids[1],ids[3],7 do
        leftIds[#leftIds + 1] = i
    end
    for i=ids[2],ids[4],7 do
        rightIds[#rightIds + 1] = i
    end
    for i,v in ipairs(leftIds) do
        for j=v,rightIds[i] do
            newIds[#newIds + 1] = j
            if j >= 1 and j <= 35 then
                local bgImg = self.panel2:getChildByTag(j + 1000)
                if not bgImg then
                    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/countrywar/countrywar_bg_'..j..'.jpg',function(texture)
                        local function getBgPos(i)
                            local index = (5 - math.floor((i - 1)/7 + 1))*7+(i - 1)%7 + 1
                            local posX = (math.floor((index - 1)%7 + 1) - 1)*512 + 256
                            local posY = (math.ceil(index/7) - 1)*512 + 256
                            return cc.p(posX,posY)
                        end
                        if CountryWarMgr.mapClose == true then
                            return
                        end
                        local img = ccui.ImageView:create('uires/ui/countrywar/countrywar_bg_'..j..'.jpg')
                        img:setPosition(getBgPos(j))
                        self.panel2:addChild(img,1,j+1000)
                        self:createCityBtnsByBg(tonumber(j))
                        self.allBgId[j] = 1
                    end)
                end
            end
        end
    end
end

--创建城池名称底板
function CountryWarMapUI:setNameBg(nameBgImg,btn)
    local size = btn:getContentSize()
    local posX,posY = btn:getPositionX(),btn:getPositionY()
    nameBgImg:setPosition(cc.p(posX,posY - size.height/2 + 20))
    self.panel2:addChild(nameBgImg,CityNameZOrder)
end

--更新当前城市名字的背景
function CountryWarMapUI:updateCityName()
    for i = 1,75 do
        local btn = self.panel2:getChildByName('map_city_'..i)
        if btn then
            local nameBgImg= self.panel2:getChildByName('name_bg_'..i)
            if not nameBgImg then
                nameBgImg = self:createNameBg(btn,i)
                self:setNameBg(nameBgImg,btn)
                nameBgImg:setName('name_bg_'..i)
            end
            local nameTx = nameBgImg:getChildByName('name_tx')
            -- nameBgImg:loadTexture('uires/ui/mainscene/mainscene_0-0.png')
            -- nameBgImg:ignoreContentAdaptWithSize(true)
        end
    end
end

--创建城池名称底板
function CountryWarMapUI:createNameBg(btn,cityId)
    local conf = GameData:getConfData("countrywarcity")[cityId]
    if not conf then
        return
    end
    local cityData = CountryWarMgr.citys[tostring(cityId)]
    local nameImg = ccui.ImageView:create('uires/ui/countrywar/countrywar_name_bg_'..cityData.hold_camp..'.png')
    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    nameTx:setPosition(cc.p(90,20))
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setName('name_tx')
    nameTx:setString(conf.name)
    nameImg:addChild(nameTx)
    return nameImg
end

function CountryWarMapUI:updateCityBtnCell(cityId)
    local btn = self.panel2:getChildByName('map_city_'..cityId)
    local nameBgImg = self.panel2:getChildByName('name_bg_'..cityId)
    local cityData = CountryWarMgr.citys[tostring(cityId)]
    if btn and not nameBgImg then
        nameBgImg = self:createNameBg(btn,cityId)
        self:setNameBg(nameBgImg,btn)
        nameBgImg:setName('name_bg_'..cityId)
    else
        if nameBgImg then
            nameBgImg:loadTexture('uires/ui/countrywar/countrywar_name_bg_'..cityData.hold_camp..'.png')
        end
    end
    self:updateSpecialMoveImg(cityId)
    if btn then
        local playersCountsImg = btn:getChildByName('players_counts_img')
        if cityData.fight_state == 1 then
            local size = btn:getContentSize()
            local maxNum = 0
            local cityData = CountryWarMgr.citys[tostring(cityId)]
            for i=1,3 do
                local players = cityData.players[tostring(i)]
                maxNum = maxNum > #players and maxNum or #players
            end
            if not playersCountsImg then
                playersCountsImg = ccui.ImageView:create('uires/ui/common/bg_gray70.png')
                playersCountsImg:setScale9Enabled(true)
                playersCountsImg:setContentSize(cc.size(36,20))
                playersCountsImg:setName('players_counts_img')
                local loadingBar1 = ccui.LoadingBar:create("uires/ui/battle/plist/battle_hero_hp_6.png")
                local loadingBar2 = ccui.LoadingBar:create("uires/ui/battle/plist/battle_hero_hp_3.png")
                local loadingBar3 = ccui.LoadingBar:create("uires/ui/battle/plist/battle_hero_hp_1.png")
                loadingBar1:setPosition(cc.p(1.5,17))
                loadingBar2:setPosition(cc.p(1.5,10))
                loadingBar3:setPosition(cc.p(1.5,3))
                loadingBar1:setAnchorPoint(cc.p(0,0.5))
                loadingBar2:setAnchorPoint(cc.p(0,0.5))
                loadingBar3:setAnchorPoint(cc.p(0,0.5))
                playersCountsImg:setPosition(cc.p(size.width + 40,size.height - 70))
                loadingBar1:setName('loading_bar_1')
                loadingBar2:setName('loading_bar_2')
                loadingBar3:setName('loading_bar_3')
                playersCountsImg:addChild(loadingBar1)
                playersCountsImg:addChild(loadingBar2)
                playersCountsImg:addChild(loadingBar3)
                btn:addChild(playersCountsImg)
            end
            local loadingBar1 = playersCountsImg:getChildByName('loading_bar_1')
            local loadingBar2 = playersCountsImg:getChildByName('loading_bar_2')
            local loadingBar3 = playersCountsImg:getChildByName('loading_bar_3')
            local bars = {loadingBar1,loadingBar2,loadingBar3}
            for i=1,3 do
                local players = cityData.players[tostring(i)]
                bars[i]:setPercent(#players/maxNum*100)
            end
        else
            if playersCountsImg then
                playersCountsImg:setVisible(false)
            end
        end
    end
end

--更新所有城池名称底板
function CountryWarMapUI:updateCityNameBg()
    for i = 1,75 do
        local btn = self.panel2:getChildByName('map_city_'..i)
        local nameBgImg = self.panel2:getChildByName('name_bg_'..i)
        local cityData = CountryWarMgr.citys[tostring(i)]
        if btn and not nameBgImg then
            nameBgImg = self:createNameBg(btn,i)
            self:setNameBg(nameBgImg,btn)
            nameBgImg:setName('name_bg_'..i)
        else
            if nameBgImg then
                nameBgImg:loadTexture('uires/ui/countrywar/countrywar_name_bg_'..cityData.hold_camp..'.png')
            end
        end
        if btn then
            local fire = btn:getChildByName('city_fire')
            local playersCountsImg = btn:getChildByName('players_counts_img')
            if cityData.fight_state == 1 then
                local size = btn:getContentSize()
                if not fire then
                    fire = GlobalApi:createLittleLossyAniByName("ui_biaoche_fire")
                    fire:getAnimation():playWithIndex(0, -1, 1)
                    fire:setPosition(cc.p(size.width/2,22))
                    fire:setName('city_fire')
                    btn:addChild(fire)
                end
                fire:setScale(0.45)
                fire:setVisible(true)
            else
                if fire then
                    fire:setVisible(false)
                end
            end
        end
        self:updateCityBtnCell(i)
    end
end

function CountryWarMapUI:updateSpecialMoveImg(cityId)
    local conf = GameData:getConfData("countrywarcity")
    -- print('============xxxxx',cityId,CountryWarMgr.myCity)
    local cityId1 = cityId or CountryWarMgr.myCity
    local cityData = CountryWarMgr.citys[tostring(cityId1)]
    local playerNum = #cityData.players[tostring(self.camp)]
    local playerNum1 = #cityData.players[tostring(cityData.hold_camp)]
    local endConf = conf[cityId1]
    local adjoin = endConf.adjoin
    local canMove = false
    if cityData.hold_camp ~= self.camp and playerNum >= playerNum1*2 and cityId1 == CountryWarMgr.myCity then
        canMove = true
    end
    for i,v in ipairs(adjoin) do
        local btn = self.panel2:getChildByName('map_city_'..v)
        if btn then
            local specialMoveImg = btn:getChildByName('special_move_img')
            if canMove then
                local cityData1 = CountryWarMgr.citys[tostring(v)]
                if cityData1.hold_camp ~= self.camp then
                    if not specialMoveImg then
                        specialMoveImg = ccui.ImageView:create('uires/ui/digmine/digmine_unknow_light.png')
                        local specialMoveBtn = ccui.Button:create('uires/ui/countrywar/tujin1.png','','')
                        local size = btn:getContentSize()
                        local size1 = specialMoveImg:getContentSize()
                        specialMoveImg:setPosition(cc.p(size.width/2,size.height/2))
                        specialMoveBtn:setPosition(cc.p(size1.width/2,size1.height/2))
                        specialMoveBtn:setName('special_move_btn')
                        specialMoveImg:setName('special_move_img')
                        specialMoveBtn:setSwallowTouches(false)
                        specialMoveImg:addChild(specialMoveBtn)
                        btn:addChild(specialMoveImg)
                        specialMoveBtn:addTouchEventListener(function (sender, eventType)
                            if eventType == ccui.TouchEventType.began then
                                AudioMgr.PlayAudio(11)
                            elseif eventType == ccui.TouchEventType.ended then
                                promptmgr:showMessageBox(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_74'),MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                                    self:fightCallback(v,'specialMove')
                                end)
                            end
                        end)
                    end
                    specialMoveImg:setVisible(true)
                else
                    if specialMoveImg then
                        specialMoveImg:setVisible(false)
                    end
                end
            else
                if specialMoveImg then
                    specialMoveImg:setVisible(false)
                end
            end
        end
    end
end

function CountryWarMapUI:updateCityBtns(cityId)
    -- local cityData = MapData.data[tonumber(cityId)]
    local conf = GameData:getConfData("countrywarcity")[cityId]
    local btn = self.panel2:getChildByName('map_city_'..cityId)
    local cityData = CountryWarMgr.citys[tostring(cityId)]
    local index = tonumber(cityId)
    if not btn then
        btn = ccui.Button:create('uires/ui/countrywar/'..cityData.hold_camp..'-'..conf.type..'.png')
        btn:setName("map_city_" .. cityId)
        btn:setScale(0.8)
        local size = btn:getContentSize()
        btn:setSwallowTouches(false)
        
        btn:setPosition(cc.p(conf.posX,conf.posY))
        btn:setLocalZOrder(CityZOrder)
        self.panel2:addChild(btn)
    end
    local function setCellScale(img,baseScale,scale)
        if img and img:isVisible() then
            img:setScale(baseScale*scale)
        end
    end
    btn:loadTextures('uires/ui/countrywar/'..cityData.hold_camp..'-'..conf.type..'.png','','')
    btn:addTouchEventListener(function (sender, eventType)
        local fire = btn:getChildByName('city_fire')
        local orderImg = btn:getChildByName('haoling_img')
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            self.panel2:stopAllActions()
            setCellScale(fire,1.1,0.45)
            setCellScale(orderImg,1.1,0.8)
        elseif eventType == ccui.TouchEventType.moved then
            setCellScale(fire,1.1,0.45)
            setCellScale(orderImg,1.1,0.8)
        elseif eventType == ccui.TouchEventType.ended then
            self:effectEnd(index,btn)
            setCellScale(fire,1,0.45)
            setCellScale(orderImg,1,0.8)
        elseif eventType == ccui.TouchEventType.canceled then
            setCellScale(fire,1,0.45)
            setCellScale(orderImg,1,0.8)
        end
    end)
end

--设置征战浮标是否显示
function CountryWarMapUI:setBtnsVisible()
    if self.isActEnd == true and self.isBtnEffEnd == true then
        local index = 9991
        local bar = self.panel2:getChildByTag(index)
        if bar then
            self.isBtnEffEnd = false
            local size = bar:getContentSize()
            for i=1,3 do
                local btn = bar:getChildByTag(i)
                if btn then
                    -- print(btn:getPositionX(),btn:getPositionY(),'=============='..i)
                    btn:runAction(cc.MoveTo:create(0.3,cc.p(size.width/2,0)))
                    btn:runAction(cc.ScaleTo:create(0.3,0.1))
                end
            end
            bar:runAction(cc.Sequence:create(cc.ProgressTo:create(0.3, 0),cc.CallFunc:create(function()
                -- local sprite = self.panel2:getChildByTag(9987)
                -- if sprite then
                --     sprite:setVisible(true)
                -- end
                bar:setVisible(false)
                self.isBtnEffEnd = true
            end)))
        end
    end
end

-- 浮标响应方法
function CountryWarMapUI:fightCallback(index,stype)
    local functions = {
        ['specialMove'] = function()
            local endConf = GameData:getConfData("countrywarcity")[CountryWarMgr.myCity]
            local adjoin = endConf.adjoin
            local isAdjoin = false
            for i,v in ipairs(adjoin) do
                if v == index then
                    isAdjoin = true
                end
            end
            if isAdjoin then
                CountryWarMgr:specialMove(index,function()
                    local moveData = CountryWarMgr:getMoveData()
                    self:startMoving(moveData.path[1],moveData.path[#moveData.path],moveData.path)
                end)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_13'), COLOR_TYPE.RED)
            end
        end,
        ['forward'] = function()
            local cityData = CountryWarMgr.citys[tostring(CountryWarMgr.myCity)]
            local id1 = math.ceil(CountryWarMgr.myCity/25)
            local id2 = CountryWarMgr.myCity%25
            if id2 == 1 and id1 ~= self.camp then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_33'), COLOR_TYPE.RED)
                return
            end
            if cityData.fight_state == 1 and CountryWarMgr.myCity ~= index then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_16'), COLOR_TYPE.RED)
            else
                local time = GlobalData:getServerTime() + CountryWarMgr.diffTime
                -- print('===========================',CountryWarMgr.runTime,time)
                if CountryWarMgr.runTime and CountryWarMgr.runTime + tonumber(CountryWarMgr:getBaseValue('runMapDiffTime')) > time then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_24'), COLOR_TYPE.RED)
                    return
                end
                local tab = {}
                local endId = index
                local beginId = CountryWarMgr.myCity
                tab[#tab + 1] = endId
                local isOk = self:countWay(beginId,endId,tostring(endId),tab)
                if isOk then
                    -- CountryWarMgr.runTime = GlobalData:getServerTime()
                    self:runMap(endId)
                -- else
                --     promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_17'), COLOR_TYPE.RED)
                end
            end
        end,
        ['back'] = function()
            local id2 = CountryWarMgr.myCity%25
            if id2 == 1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_25'), COLOR_TYPE.RED)
            else
                CountryWarMgr:showCountryWarMatch()
            end
        end,
        ['info'] = function()
            CountryWarMgr:showCountryWarCityInfo(index)
        end,
        ['retreat'] = function()
            CountryWarMgr:goBack(function()
                self:updatePanel()
            end)
        end
    }
    if functions[stype] then
        functions[stype]()
        local bar = self.panel2:getChildByName('bar')
        if bar then
            self.isBtnEffEnd = false
            local size = bar:getContentSize()
            for i=1,3 do
                local btn = bar:getChildByTag(i)
                if btn then
                    btn:runAction(cc.MoveTo:create(0.3,cc.p(size.width/2,0)))
                    btn:runAction(cc.ScaleTo:create(0.3,0.1))
                end
            end
            bar:runAction(cc.Sequence:create(cc.ProgressTo:create(0.3, 0),cc.CallFunc:create(function()
                -- local sprite = self.panel2:getChildByTag(9987)
                -- if sprite then
                --     sprite:setVisible(true)
                -- end
                bar:setVisible(false)
                self.isBtnEffEnd = true
            end)))
        end
    end
end

--城池动画播放完成
function CountryWarMapUI:effectEnd(id,btn)
    local index = 9991
    local bar = self.panel2:getChildByTag(index)
    if not bar then
        bar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/mainscene/mainscene_buoy_bg.png"))
        bar:setName("bar")
        bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        bar:setMidpoint(cc.p(0, 0))
        bar:setBarChangeRate(cc.p(1, 0))
        self.panel2:addChild(bar,BuoyZOrder,index)
    end
    bar:setVisible(false)
    bar:stopAllActions()
    self.isBtnEffEnd = true
    self.isActEnd = false
    local size = bar:getContentSize()
    local buoyBtns = {}
    local stypes = {'forward','specialMove','info','back','retreat'}
    local cityData = CountryWarMgr.citys[tostring(id)]
    local cityData1 = CountryWarMgr.citys[tostring(CountryWarMgr.myCity)]
    local tab = {}
    local endId = id
    local beginId = CountryWarMgr.myCity
    tab[#tab + 1] = endId
    local isOk = self:countWay(beginId,endId,tostring(endId),tab,true)
    local id1 = math.ceil(id/25)
    local id2 = id%25
    local isMyHome = id2 == 1 and id1 == self.camp
    local isTheirHome = id2 == 1 and id1 ~= self.camp
    local endConf = GameData:getConfData("countrywarcity")[endId]
    local adjoin = endConf.adjoin
    local isAdjoin = false
    for i,v in ipairs(adjoin) do
        if v == beginId then
            isAdjoin = true
        end
    end
    local visiables = {
        isOk and endId ~= beginId and not isTheirHome,
        isAdjoin and self.moveStart ~= true and cityData1.hold_camp ~= self.camp and cityData.hold_camp ~= self.camp ,
        true,
        true,
        true,
    }
    for i=1,3 do
        local buoyBtn = bar:getChildByTag(i)
        if not buoyBtn then
            buoyBtn = ccui.Button:create()
            buoyBtn:setName("buoy_btn_" .. i)
            bar:addChild(buoyBtn,BuoyZOrder,i)
        end
        local index = i
        if i == 1 and id == CountryWarMgr.myCity and self.moveStart ~= true and id2 ~= 1 then
            index = 4
        elseif i == 2 and id == CountryWarMgr.myCity then
            index = 5
        end
        buoyBtn:loadTextures(BTNS[stypes[index]],SBTNS[stypes[index]])
        if visiables[index] then
            buoyBtn:setBright(true)
            buoyBtn:setTouchEnabled(true)
        else
            buoyBtn:setBright(false)
            buoyBtn:setTouchEnabled(false)
        end
        buoyBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:fightCallback(id,stypes[index])
            end
        end)
        -- buoyBtn:setSwallowTouches(false)
        buoyBtn:setScale(0.8)
        -- buoyBtn:setPosition(btn:getPosition())
        buoyBtn:stopAllActions()
        buoyBtns[i] = buoyBtn
        buoyBtn:setVisible(false)
    end
    local endPoint = cc.p(btn:getPositionX(),btn:getPositionY() + size.height/2)
    local action = cc.Sequence:create(cc.MoveTo:create(0.3,endPoint),
            cc.CallFunc:create(function ()
                self.isActEnd = true
            end))
    -- local ntype = cityData:getType()
    local size1 = buoyBtns[1]:getContentSize()
    local pos = {
        cc.p(size.width/2,size.height - size1.height/4),
        cc.p(size1.width/4,size.height/4),
        cc.p(size.width - size1.width/4,size.height/4),
        cc.p(size.width/4,size.height/3*2),
        cc.p(size.width/4*3,size.height/3*2),
    }
    -- if star <= 0 then
    --     buoyBtns[3]:setPosition(pos[1])
    --     buoyBtns[3]:setVisible(true)
    --     self:fightCallback(id,3)
    --     return
    -- else
    -- local formation = cityData:getFormation(3)
        if id % 25 ~= 1 then
            buoyBtns[1]:setPosition(pos[1])
            buoyBtns[2]:setPosition(pos[2])
            buoyBtns[3]:setPosition(pos[3])
            buoyBtns[1]:setVisible(true)
            buoyBtns[2]:setVisible(true)
            buoyBtns[3]:setVisible(true)
        else
            buoyBtns[1]:setPosition(pos[1])
            buoyBtns[1]:setVisible(true)
        end
    -- end
    -- for i=1,3 do
    --     local buoyBtn = bar:getChildByTag(i)
    -- end
    -- local sprite = self.panel2:getChildByTag(9987)
    -- if sprite then
    --     sprite:setVisible(false)
    -- end

    bar:setVisible(true)
    bar:setPercentage(100)
    bar:setScale(0.1)
    bar:setPosition(btn:getPosition())
    bar:runAction(action)
    bar:runAction(cc.ScaleTo:create(0.3,1))
end

function CountryWarMapUI:createCityBtnsByBg(bgId)
    local cityIds = GameData:getConfData("countrywarcityres")[bgId]
    if not cityIds or not cityIds.cityId then
        return
    end
    for i,v in ipairs(cityIds.cityId) do
        self:updateCityBtns(tonumber(v))
        self:udpateCallOfDuty(tonumber(v))
    end
end

function CountryWarMapUI:createBgAfter()
    for i=1,35 do
        -- local bg = self.panel2:getChildByTag(1000 + i)
        -- if not bg then
        --     local img = ccui.ImageView:create('uires/ui/mainscene/mainscene_bg_'..i..'.jpg')
        --     img:setPosition(self:getBgPos(i))
        --     self.panel2:addChild(img,1,i+100)
        --     self:createCityBtnsByBg(i)
        -- end
        self:createCityBtnsByBg(i)
    end
end

function CountryWarMapUI:createBgBefore()
    -- local cityData = MapData.data[MapData.currProgress]
    local conf = GameData:getConfData("countrywarcity")[self.winCityId]
    local currId = conf.bcakId
    local diffs = {-8,-7,-6,-1,0,1,6,7,8}
    if currId%7 == 0 then
        diffs = {-8,-7,-1,0,6,7}
    elseif currId%7 == 1 then
        diffs = {-7,-6,0,1,7,8}
    end
    local ids = {}
    for i,v in ipairs(diffs) do
        local id = currId + v
        if id >= 1 and id <= 35 then
            ids[#ids + 1] = id
        end
    end
    local function getBgPos(i)
        local index = (5 - math.floor((i - 1)/7 + 1))*7+(i - 1)%7 + 1
        local posX = (math.floor((index - 1)%7 + 1) - 1)*512 + 256
        local posY = (math.ceil(index/7) - 1)*512 + 256
        return cc.p(posX,posY)
    end
    for i,v in ipairs(ids) do
        self:createCityBtnsByBg(tonumber(v))
    end
end

function CountryWarMapUI:createCurrCity()
    -- local cityData = MapData.data[MapData.currProgress]
    -- local currId = cityData:getBcakId()
    -- currId = 5
    local conf = GameData:getConfData("countrywarcity")[self.winCityId]
    self:createCityBtnsByBg(conf.bcakId)

    -- if self.cityId then
    --     local cityData1 = MapData.data[self.cityId]
    --     local currId1 = cityData1:getBcakId()
    --     if currId ~= currId1 then
    --         self:createCityBtnsByBg(currId1)
    --     end
    -- end
end

function CountryWarMapUI:registerBtnHandler()
    local btn_types = {
        'report',
        'order',
        'task',
        'list',
        'embattle',
    }
    local functions = {
        ['report'] = function()
            print('=================report')
            CountryWarMgr:showCountryWarBattlefieldInfo()
        end,
        ['order'] = function()
            CountryWarMgr:showCountryWarOrder()
        end,
        ['list'] = function()
            CountryWarMgr:showCountryWarList()
        end,
        ['task'] = function()
            CountryWarMgr:showCountryWarTask()
        end,
        ['embattle'] = function()
            CountryWarMgr:embattle(function()
                BattleMgr:hideEmbattleUI()
                promptmgr:showSystenHint(GlobalApi:getLocalStr("EMBATTLE_SUCC"), COLOR_TYPE.GREEN)
            end)
        end
    }
    local winSize = cc.Director:getInstance():getVisibleSize()
    local bottomImg = self.panel1:getChildByName('bottom_img')
    bottomImg:setPosition(cc.p(winSize.width,0))
    for i=1,5 do
        local btn = bottomImg:getChildByName('bottom_btn_'..i)
        local size = btn:getContentSize()
        -- btn:setPosition(cc.p(winSize.width - (i - 0.5)*size.width,size.height/2))
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if functions[btn_types[i]] then
                    functions[btn_types[i]]()
                end
            end
        end)
    end
    self.backToCityBtn = bottomImg:getChildByName("back_to_city_btn")
    self.backToCityBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- if self.moveStart then
            --     promptmgr:showSystenHint('当前正在路上', COLOR_TYPE.RED)
            -- else
                CountryWarMgr:showCountryWarMatch(CountryWarMgr.myCity)
            -- end
        end
    end)
end

-- function CountryWarMapUI:getMapRunFlag()
--     local tab = {1,2,3}
--     table.remove(tab,self.camp)
--     local cityData = CountryWarMgr.citys[tostring(CountryWarMgr.myCity)]
--     for i,v in ipairs(tab) do
--         if cityData.players and cityData.players[tostring(v)] and #cityData.players[tostring(v)] > 0 then
--             return true
--         end
--     end
--     return false
-- end

function CountryWarMapUI:updateNewImgs()
    local bottomImg = self.panel1:getChildByName('bottom_img')
    local marks = {
        false,
        CountryWarMgr:getCallOfDutySign(),
        UserData:getUserObj():getSignByType('countrywartask'),
        false,
        false,
    }
    for i=1,5 do
        local btn = bottomImg:getChildByName('bottom_btn_'..i)
        local newImg = btn:getChildByName('new_img')
        if newImg then
            newImg:setVisible(marks[i])
        end
    end
end

function CountryWarMapUI:updateBackToCityBtn()
    if self.moveStart then
        self.backToCityBtn:setVisible(false)
    else
        self.backToCityBtn:setVisible(CountryWarMgr.myCity%25 ~= 1)
    end
end

function CountryWarMapUI:removeOldPoint()
    if self.tempWay then
        for i=1,#self.tempWay - 1 do
            self:removeLinePoint(self.tempWay[i],self.tempWay[i + 1])
        end
    end
    self.tempWay = nil
end

function CountryWarMapUI:updateSpinePos(cityId)
    local conf = GameData:getConfData("countrywarcity")[cityId]
    self.spineCell:setPosition(cc.p(conf.posX + conf.offsetX,conf.posY + conf.offsetY))
    self.moveStart = false
    self.spineCell:stopAllActions()
    self.spine:getAnimation():play('idle', -1, 1)
    self:removeOldPoint()
end

function CountryWarMapUI:createCoolingTime(diffTime)
    -- local diffTime = tonumber(CountryWarMgr:getBaseValue('reliveTime'))
    local label = self.coolingTimeBgImg:getChildByName('cooling_time_tx')
    if label then
        label:removeFromParent()
    end
    local size = self.coolingTimeBgImg:getContentSize()
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    label:setName('cooling_time_tx')
    label:setPosition(cc.p(size.width/2,size.height/2))
    label:setAnchorPoint(cc.p(0,0.5))
    self.coolingTimeBgImg:addChild(label)
    self.coolingTimeBgImg:setVisible(true)
    -- GlobalApi:getLocalStr('TODAY_DOUBLE_DES11')
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,GlobalApi:getLocalStr('COUNTRY_WAR_DESC_23'),
        COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,25,function()
        label:removeFromParent()
        self.coolingTimeBgImg:setVisible(false)
    end,2)
end

function CountryWarMapUI:updateCoolingTime()
    local isDead,time = CountryWarMgr:isDead()
    if isDead then
        self.coolingTimeBgImg:setVisible(true)
        self:createCoolingTime(time)
    else
        self.coolingTimeBgImg:setVisible(false)
    end
end

function CountryWarMapUI:udpateCallOfDuty(cityId)
    local conf = GameData:getConfData("countrywarcity")[cityId]
    local btn = self.panel2:getChildByName('map_city_'..cityId)
    local cityData = CountryWarMgr.citys[tostring(cityId)]
    local index = tonumber(cityId)
    if btn then
        local orderImg = btn:getChildByName('haoling_img')
        if CountryWarMgr.callOfDutyData[tostring(cityId)] then
            local time = CountryWarMgr.callOfDutyData[tostring(cityId)].time
            local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
            local keepTime = tonumber(CountryWarMgr:getBaseValue('callKeepTime'))
            if nowTime >= (time + keepTime) then
                if orderImg then
                    orderImg:setVisible(false)
                end
            else
                if not orderImg then
                    orderImg = ccui.ImageView:create('uires/ui/countrywar/haoling.png')
                    local size = btn:getContentSize()
                    orderImg:setPosition(cc.p(size.width/2,size.height))
                    orderImg:setName('haoling_img')
                    orderImg:setScale(0.8)
                    btn:addChild(orderImg)
                end
                orderImg:setVisible(true)
                local size = orderImg:getContentSize()
                local label = orderImg:getChildByName('time_tx')
                if label then
                    label:removeFromParent()
                end
                local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 24)
                label:setName('time_tx')
                label:setPosition(cc.p(size.width/2,size.height/2 + 20))
                label:setVisible(false)
                orderImg:addChild(label)
                Utils:createCDLabel(label,(time + keepTime) - nowTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, nil,nil,nil,24,function ()
                    orderImg:setVisible(false)
                    self:updateNewImgs()
                end)
            end
        else
            if orderImg then
                orderImg:setVisible(false)
            end
        end
    end
end

function CountryWarMapUI:updatePanelWithoutSpine(cityId)
    print('=============================CountryWarMapUI:updatePanelWithoutSpine',cityId,type(cityId))
    self:updateCityNameBg()
    self:updateSmallMapCity()
    self:updateBackToCityBtn()
    self:updateCoolingTime()
    self:updateSpecialMoveImg()
    self:updateNewImgs()
    -- self.backToCityBtn:setVisible(self:getMapRunFlag())
    if cityId then
        self:updateCityBtns(cityId)
        self:udpateCallOfDuty(cityId)
    else
        local conf = GameData:getConfData("countrywarcity")
        for i=1,#conf do
            self:updateCityBtns(i)
            self:udpateCallOfDuty(i)
        end
    end
end

function CountryWarMapUI:updatePanel(cityId)
    print('=============================CountryWarMapUI:updatePanel',cityId,type(cityId))
    self:updateCityNameBg()
    self:updateSmallMapCity()
    self:updateSpinePos(tonumber(cityId or CountryWarMgr.myCity))
    self:updateBackToCityBtn()
    self:updateCoolingTime()
    self:updateSpecialMoveImg()
    self:updateNewImgs()
    -- self.backToCityBtn:setVisible(self:getMapRunFlag())
    if cityId then
        self:updateCityBtns(cityId)
        self:udpateCallOfDuty(cityId)
    else
        local conf = GameData:getConfData("countrywarcity")
        for i=1,#conf do
            self:updateCityBtns(i)
            self:udpateCallOfDuty(i)
        end
    end
end

function CountryWarMapUI:enterMap()
    self.ntype1 = 0
    local mapBgImg = self.panel2:getChildByName("map_bg_img")
    mapBgImg:setVisible(true)

    self.panel3:setScale(1)
    self:setLimit()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local size = self.mapPl:getContentSize()
    self.mapKuangImg:setContentSize(cc.size(winSize.width/MAX_WIDTH*size.width,winSize.height/MAX_HEIGHT*size.height))

    self.spineCell = ccui.Widget:create()
    self.spineCell:setAnchorPoint(cc.p(0,0))
    self.spineCell:setScale(0.3)
    local roleObj = RoleData:getRoleByPos(1)
    self.spine = GlobalApi:createLittleLossyAniByRoleId(roleObj:getId(), roleObj:getChangeEquipState())
    self.spine:getAnimation():play('idle', -1, 1)
    self.spineCell:addChild(self.spine)
    self.panel2:addChild(self.spineCell,SPINE_ZORDER)
    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
    nameTx:setColor(CAMP_COLOR[CountryWarMgr.camp or 1])
    nameTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setName('name_tx')
    nameTx:setScale(1/0.3)
    nameTx:setString(UserData:getUserObj():getName())

    local fuTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
    fuTx:setColor(COLOR_TYPE.YELLOW)
    fuTx:enableOutline(COLOROUTLINE_TYPE.YELLOW, 1)
    fuTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fuTx:setAnchorPoint(cc.p(0.5,0.5))
    fuTx:setName('fu_tx')
    fuTx:setScale(1/0.3)
    self.spineCell:addChild(nameTx)
    self.spineCell:addChild(fuTx)
    fuTx:setString(GlobalData:getSelectSeverUid()..GlobalApi:getLocalStr('FU'))
    local scaleX = 1/0.3
    nameTx:setPosition(cc.p(scaleX*10,250))
    fuTx:setPosition(cc.p(-nameTx:getContentSize().width/2*scaleX - scaleX*20,250))

    local conf = GameData:getConfData("countrywarcity")[self.winCityId]
    -- print('=======================',self.winCityId,conf.posX,conf.posY)
    local point1 = cc.p(-conf.posX + winSize.width/2,-conf.posY + winSize.height/2)
    self:detectEdges(point1)
    self:setWinPosition(point1,true)

    self:createBgAfter()
    self:updateMapHandler()
    self:registerBtnHandler()

    self:updateCityNameBg()
    self:updateSmallMapCity()
    self:updateSpinePos(self.winCityId)
    self:updateCoolingTime()
    self:updateBackToCityBtn()
    self:updateSpecialMoveImg()
    self:updateNewImgs()
    UIManager:showSidebar({1},{3,23},true)
    if self.callback1 then
        self.callback1()
    end
    if self.callback then
        self.callback()
    end
end

function CountryWarMapUI:initLoading()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local loadingUI,loadingPanel
    -- if not self.isCity then
        loadingUI = require ("script/app/ui/loading/loadingui").new(2)
        loadingPanel = loadingUI:getPanel()
        loadingPanel:setPosition(cc.p(winSize.width/2, winSize.height/2))
        self.root:addChild(loadingPanel, 9999)
        self.loadingUI = loadingUI
    -- end
    local loadedImgCount = 0
    local loadedImgMaxCount = 1
    local function imageLoaded(texture)
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        self.loadingUI:setPercent(loadingPercent)
        if loadedImgCount >= loadedImgMaxCount then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                local function callback()
                    self:createCurrCity()
                    self:createBgBefore()
                    self:enterMap()
                end
                UIManager:removeLoadingAction()
                self.loadingUI:runToPercent(0.2, 100, function ()
                    self.loadingUI:removeFromParent()
                    self.loadingUI = nil
                    callback()
                end)
            end)))
        end
    end
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/countrywar/countrywar_bg_img.jpg',imageLoaded)
end

function CountryWarMapUI:updateCityFightState(cityId)
    local conf = GameData:getConfData("countrywarcity")
    local cityConf = conf[cityId]
    if cityConf == nil then
        return
    end

    local size = self.mapPl:getContentSize()
    local scale = size.width/MAX_WIDTH

    local img = self.mapImg:getChildByName('small_map_city_'..cityId)
    local cityData = CountryWarMgr.citys[tostring(cityId)]
    if not img then
        img = ccui.ImageView:create()
        img:setName("small_map_city_" .. cityId)
        img:setScale(0.7)
        img:setPosition(cc.p(cityConf.posX*scale,cityConf.posY*scale))
        self.mapImg:addChild(img)
    end

    img:stopAllActions()
    img:setOpacity(255)
    img:loadTexture('uires/ui/countrywar/dian_'..cityData.hold_camp..'_'..cityConf.type..'.png')

    local dianImg = img:getChildByName('dian')
    if cityData.fight_state == 1 then
        if not dianImg then
            dianImg = ccui.ImageView:create('uires/ui/countrywar/dian_4_1.png')
            dianImg:setName("dian")
            local size = img:getContentSize()
            dianImg:setPosition(cc.p(size.width/2,size.height/2))
            img:addChild(dianImg)
            dianImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(1), cc.DelayTime:create(1))))
        end
        dianImg:setVisible(true)
    else
        -- img:loadTexture('uires/ui/countrywar/dian_'..cityData.hold_camp..'_'..cityConf.type..'.png')
        if dianImg then
            dianImg:setVisible(false)
        end
    end

    if cityId == CountryWarMgr.myCity then
        local meimg = self.mapImg:getChildByName('me_img')
        if not meimg then
            meimg = ccui.ImageView:create('uires/ui/common/me.png')
            meimg:setName('me_img')
            meimg:setAnchorPoint(cc.p(0.88,0))
            -- meimg:setScale(0.35)
            self.mapImg:addChild(meimg,9999)
        end
        meimg:setPosition(cc.p(cityConf.posX*scale, cityConf.posY*scale))
    end
end

function CountryWarMapUI:updateSmallMapCity()
    local conf = GameData:getConfData("countrywarcity")
    local cityNum = 0
    local score = 0
    for i,v in ipairs(conf) do
        self:updateCityFightState(i)
        local cityData = CountryWarMgr.citys[tostring(i)]
        if cityData.hold_camp == CountryWarMgr.camp then
            cityNum = cityNum + 1
            score = score + v.cityScore
        end
    end
    local flagImg = self.mapPl:getChildByName('flag_img')
    local descTx1 = self.mapPl:getChildByName('desc_tx_1')
    local descTx2 = self.mapPl:getChildByName('desc_tx_2')
    local numtx1 = self.mapPl:getChildByName('num_tx_1')
    local numtx2 = self.mapPl:getChildByName('num_tx_2')
    local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
    local correctTime = CountryWarMgr.openTimeCurTime + (nowTime - CountryWarMgr.openTimeNowTime)
    flagImg:loadTexture('uires/ui/countrywar/countrywar_flag_small_'..CountryWarMgr.camp..'.png')
    if correctTime >= tonumber(CountryWarMgr:getBaseValue('readyTime')) + CountryWarMgr.openTimeBeginTime then
        descTx1:setString(GlobalApi:getLocalStr('CITY')..':')
        descTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_57'))
        numtx1:setString(cityNum)
        numtx2:setString('+'..score..'/'..GlobalApi:getLocalStr('STR_MINUTE'))
    else
        local diffTime = tonumber(CountryWarMgr:getBaseValue('readyTime')) + CountryWarMgr.openTimeBeginTime - correctTime
        local label = self.mapPl:getChildByName('ready_time_tx_1')
        if label then
            label:removeFromParent()
        end
        local size = self.mapPl:getContentSize()
        label = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
        label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        label:setName('ready_time_tx_1')
        label:setPosition(cc.p(208,-21))
        label:setAnchorPoint(cc.p(0,0.5))
        self.mapPl:addChild(label)
        Utils:createCDLabel(label,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,
            GlobalApi:getLocalStr('COUNTRY_WAR_DESC_93')..':',
            COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,20,function()
            label:removeFromParent()
            self:updateSmallMapCity()
        end)

        if diffTime > 3 then
            local label = self.mapPl:getChildByName('ready_time_tx_2')
            if label then
                label:removeFromParent()
            end
            local size = self.mapPl:getContentSize()
            label = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
            label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            label:setName('ready_time_tx_2')
            label:setPosition(cc.p(208,-21))
            label:setAnchorPoint(cc.p(0,0.5))
            self.mapPl:addChild(label)
            label:setVisible(false)
            Utils:createCDLabel(label,diffTime - 3,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,
                GlobalApi:getLocalStr('COUNTRY_WAR_DESC_93')..':',
                COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,20,function()
                label:removeFromParent()
                GlobalApi:countDown(self.root)
            end)
        else
            GlobalApi:countDown(self.root,diffTime + 1)
        end
    end
end

function CountryWarMapUI:init()
    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            CountryWarMgr.mapClose = true
        end
    end)
    self.panel1 = self.root:getChildByName("Panel_1")
    self.panel3 = self.panel1:getChildByName("Panel_3")
    self.panel2 = self.panel3:getChildByName("Panel_2")
    self.mapPl = self.panel1:getChildByName("map_pl")
    self.mapImg = self.mapPl:getChildByName("map_img")
    self.mapKuangImg = self.mapPl:getChildByName("kuang_img")
    self.chatBgImg = self.panel1:getChildByName('chat_bg_img')
    self.chatBgImg:setCascadeOpacityEnabled(true)
    self.chatBgImg:setOpacity(0)
    self.chatSv = self.chatBgImg:getChildByName('sv')
    self.chatSv:setScrollBarEnabled(false)

    self.topChatBgImg = self.panel1:getChildByName('top_chat_bg_img')
    self.topChatBgImg:setVisible(false)
    self.coolingTimeBgImg = self.panel1:getChildByName('cooling_time_bg_img')
    local reliveBtn = self.coolingTimeBgImg:getChildByName('relive_btn')
    reliveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- CountryWarMgr:hideCountryWarMap()
            CountryWarMgr:fastRelive()
        end
    end)
    self.coolingTimeBgImg:setVisible(false)


    self.chatNode = self.panel1:getChildByName('chat_node')
    self.chatNode:setVisible(false)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.chatNode:setPosition(cc.p(winSize.width/2,winSize.height - 190))

    local closeBtn = self.panel1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarMap()

            local args = {}
            MessageMgr:sendPost('leave', 'countrywar', json.encode(args), function (response)

            end)
        end
    end)

    local chatBtn = self.panel1:getChildByName("chat_btn")
    chatBtn:loadTextureNormal("uires/ui/buoy/btn_arrow_right.png")
    chatBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ChatNewMgr:showChat(2)
        end
    end)
    self:updateChatShowStatus()

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.panel1:setContentSize(cc.size(winSize.width,winSize.height))
    self.coolingTimeBgImg:setPosition(cc.p(winSize.width/2,winSize.height - 150))
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    chatBtn:setPosition(cc.p(0,winSize.height - 260))
    self.mapPl:setPosition(cc.p(0,winSize.height))
    -- self.panel1:setSwallowTouches(false)
    self:initLoading()
end

function CountryWarMapUI:updateChatShowStatus()
    if self.root and self.panel1 then
        local value = false
        if ChatNewMgr then
            value =  ChatNewMgr.isChatShow
        end
        self.panel1:getChildByName('chat_btn'):getChildByName('new_img'):setVisible(value)
    end
end

function CountryWarMapUI:updateLittleChatMsg()
    -- self.chatBgImg:stopAllActions()
    -- self.root:stopAllActions()
    if #self.littleChatMsgs > MAX_LITTLE_MSG then
        table.remove(self.littleChatMsgs,1)
    end
    local maxHeight = 0
    local heights = {}
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatMsgs[i] then
            local stype = ''
            local un = self.littleChatMsgs[i].user.un or ''
            local vip = self.littleChatMsgs[i].user.vip
            local serverId = self.littleChatMsgs[i].user.serverId
            local position = self.littleChatMsgs[i].user.position
            local country = self.littleChatMsgs[i].user.country
            local content = self.littleChatMsgs[i].content
            local judge = false
            if serverId then
                stype = string.format('%03d',serverId)..GlobalApi:getLocalStr('CHAT_DESC_10')
                judge = true
            else
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL5')
                if un == '' then
                    un = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_22')
                end
            end
            if not self.littleChatRts[i] then
                local pl = ccui.Widget:create()
                pl:setAnchorPoint(cc.p(0,1))
                self.littleChatRts[i] = pl
                self.chatSv:addChild(pl)

                local channelTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                channelTx:setColor(COLOR_TYPE.ORANGE)
                channelTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                channelTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                channelTx:setAnchorPoint(cc.p(0,1))
                channelTx:setName('channel_tx')

                local positionTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                positionTx:setColor(COLOR_TYPE.WHITE)
                positionTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                positionTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                positionTx:setAnchorPoint(cc.p(0,1))
                positionTx:setName('position_tx')

                local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                nameTx:setColor(COLOR_TYPE.WHITE)
                nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                nameTx:setAnchorPoint(cc.p(0,1))
                nameTx:setName('name_tx')

                local vipTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                vipTx:setColor(COLOR_TYPE.RED)
                vipTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                vipTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                vipTx:setAnchorPoint(cc.p(0,1))
                vipTx:setName('vip_tx')

                local contentTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                contentTx:setColor(cc.c3b(132,212,210))
                contentTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                contentTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                contentTx:setAnchorPoint(cc.p(0,1))
                contentTx:setName('content_tx')
                contentTx:setMaxLineWidth(356)

                local voiceImg = ccui.ImageView:create('uires/ui/chat/chat_yuyin.png')
                voiceImg:setScale(0.5)
                voiceImg:setAnchorPoint(cc.p(0,1))
                voiceImg:setName('voice_img')

                pl:addChild(channelTx)
                pl:addChild(positionTx)
                pl:addChild(nameTx)
                pl:addChild(vipTx)
                pl:addChild(contentTx)
                pl:addChild(voiceImg)
            end
            local pl = self.littleChatRts[i]
            local channelTx = pl:getChildByName('channel_tx')
            local positionTx = pl:getChildByName('position_tx')
            local nameTx = pl:getChildByName('name_tx')
            local vipTx = pl:getChildByName('vip_tx')
            local contentTx = pl:getChildByName('content_tx')
            local voiceImg = pl:getChildByName('voice_img')
            channelTx:setString('['..stype..']')
            if un then
                nameTx:setString(un..':')
            else
                nameTx:setString('')
            end
            if vip then
                vipTx:setString('VIP'..vip)
            else
                vipTx:setString('')
            end
            contentTx:setString(content)

            if judge == true and position and country then
                local positionData = GameData:getConfData('position')[position]
                local positionName = nil
                if position <= 3 then
                    positionName = positionData.title
                else
                    positionName = positionData.posName .. GlobalApi:getLocalStr('CHAT_DESC_11')
                end
                positionTx:setString('[' .. positionName .. ']')
                positionTx:setColor(COLOR_QUALITY[positionData.quality])
            else
                positionTx:setString('')
            end

            local size = channelTx:getContentSize()
            local size3 = positionTx:getContentSize()
            local size1 = nameTx:getContentSize()
            local size2 = vipTx:getContentSize()
            heights[i] = contentTx:getContentSize().height + size.height
            pl:setContentSize(cc.size(250,heights[i]))
            channelTx:setPosition(cc.p(0,heights[i]))
            positionTx:setPosition(cc.p(size.width,heights[i]))
            nameTx:setPosition(cc.p(size.width + size3.width,heights[i]))
            vipTx:setPosition(cc.p(size.width + size1.width + size3.width,heights[i]))
            voiceImg:setPosition(cc.p(10 + size.width + size1.width + size1.width,heights[i]))
            contentTx:setPosition(cc.p(0,heights[i] - size.height))
            if isVoice then    -- 是语音
                voiceImg:setVisible(true)
            else
                voiceImg:setVisible(false)
            end
            pl:setVisible(true)
            maxHeight = maxHeight + heights[i]
        end
    end
    local size = self.chatSv:getContentSize()
    if maxHeight > size.height then
        self.chatSv:setInnerContainerSize(cc.size(46,maxHeight))
    else
        self.chatSv:setInnerContainerSize(size)
        maxHeight = size.height
    end
    local currHeight = maxHeight
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatRts[i] then
            self.littleChatRts[i]:setPosition(cc.p(0,currHeight))
            currHeight = currHeight - heights[i]
        end
    end
    self.chatSv:jumpToBottom()
    self.chatBgImg:setOpacity(255)
    -- self.chatBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(0.5)))
    -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(16.3),cc.CallFunc:create(function()
    --     for i=1,MAX_LITTLE_MSG do
    --         if self.littleChatRts[i] then
    --             self.littleChatRts[i].richText:setVisible(false)
    --         end
    --     end
    -- end)))
    -- self.littleChatRts[1].richText:setOpacity(0)
end

function CountryWarMapUI:setLittleChatMsg(msg)
    self.littleChatMsgs[#self.littleChatMsgs + 1] = msg
    self:updateLittleChatMsg()
end

function CountryWarMapUI:runMsgAction(msg)
    self.topChatBgImg:removeAllChildren()

    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(600, 30))
    local re = xx.RichTextLabel:create('['..msg.serverId..GlobalApi:getLocalStr('FU')..']', 24, COLOR_TYPE.ORANGE)
    re:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    local re1 = xx.RichTextLabel:create(msg.un, 24,CAMP_COLOR[msg.country])
    re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_21'), 24, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    local re3 = xx.RichTextLabel:create(msg.killCount..GlobalApi:getLocalStr('SOLDIER_REN')..'!', 40, COLOR_TYPE.YELLOW)
    richText:addElement(re)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    local size = self.topChatBgImg:getContentSize()
    richText:setPosition(cc.p(size.width/2,size.height/2 + 12))
    self.topChatBgImg:addChild(richText)

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.topChatBgImg:setVisible(true)
    self.topChatBgImg:setPosition(cc.p(winSize.width/2,winSize.height - 150))
    self.topChatBgImg:setScale(2.5)
    self.topChatBgImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1),cc.DelayTime:create(3),cc.CallFunc:create(function()
        self.topChatBgImg:setVisible(false)
        self:runChat()
    end)))
    self.topChatBgImg:runAction(cc.MoveTo:create(0.2,cc.p(winSize.width/2,winSize.height - 90)))
end

function CountryWarMapUI:runChat()
    self.chatEnd = true
    local msg = self.topChatMsgs[1]
    if msg then
        self.chatEnd = false
        table.remove(self.topChatMsgs,1)
        self:runMsgAction(msg)
    else
        self.chatEnd = true
    end
end

function CountryWarMapUI:setChatMsg(msg)
    self.topChatMsgs[#self.topChatMsgs + 1] = msg
    if self.chatEnd then
        self:runChat()
    end
end

--计算路径
function CountryWarMapUI:countWayByNum(num,beginId,endId,line,passTab)
    local endConf = GameData:getConfData("countrywarcity")[endId]
    local beginConf = GameData:getConfData("countrywarcity")[beginId]
    local beginCityData = CountryWarMgr.citys[tostring(beginId)]
    local endCityData = CountryWarMgr.citys[tostring(endId)]
    -- if not endConf then
    --     return
    -- end
    local adjoin = endConf.adjoin
    local str = line or ''
    -- printall(adjoin)
    for i,v in ipairs(adjoin) do
        local tab = clone(passTab)
        local cityData = CountryWarMgr.citys[tostring(v)]
        -- print('==========================',cityData.hold_camp , self.camp , endCityData.hold_camp)
        if v == beginId then
            if cityData.hold_camp == self.camp or endCityData.hold_camp == self.camp then
                -- lineNum = lineNum + 1
                tab[#tab + 1] = v
                self.endNum = (self.endNum > #tab) and #tab or self.endNum
                -- print('线路'..lineNum,str..'-'..v,self.endNum)
                self.lines[#self.lines + 1] = tab
            end
        else
            if #tab >= num then
                num = num + 1
            end
            -- print('================xxx1',line,v,isPassed,self.endNum)
            if num <= MAX_CITY_PASS and #tab < self.endNum - 1 then
                local isPassed = false
                for j,k in ipairs(tab) do
                    if v == k then
                        isPassed = true
                    end
                end
                if cityData.hold_camp == self.camp and not isPassed then
                    tab[#tab + 1] = v
                    self:countWayByNum(num,beginId,v,str..'-'..v,tab)
                end
            end
        end
    end
end

function CountryWarMapUI:runMap(endId,way)
    CountryWarMgr:runMap(endId,function()
        local moveData = CountryWarMgr:getMoveData()
        -- self.cityId = endId
        if way then
            for i=1,#way - 1 do
                self:removeLinePoint(way[i],way[i + 1])
            end
        end
        self:startMoving(moveData.path[1],moveData.path[#moveData.path],moveData.path)
    end)
end

function CountryWarMapUI:countWay(beginId,endId,line,passTab,isCount)
    local time = socket.gettime()
    self.endNum = MAX_CITY_PASS
    self.lines = {}
    self:countWayByNum(1,tonumber(beginId),endId,line,passTab)

    if #self.lines <= 0 then
        -- print(time1 - time,'==================22222',#self.lines,self.endNum)
        -- promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_17'), COLOR_TYPE.RED)
        return false
    end
    local ways = {}
    for i,v in ipairs(self.lines) do
        if #v <= self.endNum then
            ways[#ways + 1] = v
        end
    end
    -- printall(ways)
    -- local time1 = socket.gettime()
    -- print(time1 - time,'==================11111',#self.lines,self.endNum)
    -- printall(ways)
    if isCount then
        return true
    end
    if self.moveStart then
        self.isNewWay = true
        self.newWay = {beginId,endId,line,passTab}
        return false
    end
    return true
    -- CountryWarMgr:runMap(endId,function()
    --     local moveData = CountryWarMgr:getMoveData()
    --     -- self.cityId = endId
    --     self:startMoving(moveData.path[1],moveData.path[#moveData.path],moveData.path)
    -- end)
end

function CountryWarMapUI:removeLinePoint(beginId,endId)
    local min = math.min(beginId,endId)
    local max = math.max(beginId,endId)
    local conf = GameData:getConfData("countrywarcityway")[min..'-'..max]
    for i,v in ipairs(conf.wayPosXs) do
        local img = self.panel2:getChildByName(min..'-'..max..'-'..i)
        if img then
            img:removeFromParent()
        end
    end
end

function CountryWarMapUI:createLinePoint(way)
    local baseConf = GameData:getConfData("countrywarcityway")
    for i=1,#way - 1 do
        local min = math.min(way[i],way[i + 1])
        local max = math.max(way[i],way[i + 1])
        local conf = baseConf[min..'-'..max]
        for i1,v1 in ipairs(conf.wayPosXs) do
            local img = ccui.ImageView:create('uires/ui/countrywar/line_point.png')
            img:setPosition(cc.p(v1,conf.wayPosYs[i1]))
            img:setName(min..'-'..max..'-'..i1)
            img:setOpacity(0)
            img:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1),cc.FadeOut:create(1))))
            self.panel2:addChild(img,999)
        end
    end
end

function CountryWarMapUI:startMoving(beginId,endId,way)
    -- local way = {}
    -- local temp = {}
    -- if #ways == 1 then
    --     temp = ways[1]
    -- else
    --     local index = math.random(1,#ways)
    --     temp = ways[index]
    -- end
    -- for i = #temp,1,-1 do
    --     way[#way + 1] = temp[i]
    -- end
    self.moveStart = true
    self:updateBackToCityBtn()
    if way and #way > 0 and way[1] == beginId and way[#way] == endId then
        print(table.concat(way,'-',1,#way))
        self:createLinePoint(way)
        local conf = GameData:getConfData("countrywarcity")[tonumber(way[1])]
        self.spineCell:stopAllActions()
        if not self.moveStart then
            self:updateSpinePos(tonumber(way[1]))
        end
        self.tempWay = way
        self:moving(1,way)
    end
end

function CountryWarMapUI:getMoveFlag()
    return self.moveStart
end

function CountryWarMapUI:advance(spineCell,spine,way,index,callback,nameTx,meimg,fuTx)
    local str = ''
    local isFlip = false
    if way[index] < way[index + 1] then
        str = way[index]..'-'..way[index + 1]
    else
        str = way[index + 1]..'-'..way[index]
        isFlip = true
    end
    local wayConf = GameData:getConfData("countrywarcityway")[str]
    local beginConf = GameData:getConfData("countrywarcity")[way[index]]
    local endConf = GameData:getConfData("countrywarcity")[way[index + 1]]
    if endConf.posX < beginConf.posX then
        spineCell:setScaleX(-math.abs(spineCell:getScaleX()))
    else
        spineCell:setScaleX(math.abs(spineCell:getScaleX()))
    end
    if nameTx then
        local scaleX = 1/spineCell:getScaleX()
        nameTx:setScaleX(scaleX)
        fuTx:setScaleX(scaleX)
        nameTx:setPosition(cc.p(scaleX*10,250))
        fuTx:setPosition(cc.p(-nameTx:getContentSize().width/2*scaleX - scaleX*20,250))
    end
    spine:getAnimation():play('run', -1, 1)
    if isFlip then
        table.insert(wayConf.wayPosXs,1,endConf.posX + endConf.offsetX)
        table.insert(wayConf.wayPosYs,1,endConf.posY + endConf.offsetY)
        table.insert(wayConf.wayPosXs,beginConf.posX + beginConf.offsetX)
        table.insert(wayConf.wayPosYs,beginConf.posY + beginConf.offsetY)
    else
        table.insert(wayConf.wayPosXs,1,beginConf.posX + beginConf.offsetX)
        table.insert(wayConf.wayPosYs,1,beginConf.posY + beginConf.offsetY)
        table.insert(wayConf.wayPosXs,endConf.posX + endConf.offsetX)
        table.insert(wayConf.wayPosYs,endConf.posY + endConf.offsetY)
    end
    local maxLen = 0
    local allLens = {}
    for i=1,#wayConf.wayPosXs - 1 do
        local dis =cc.pGetDistance(cc.p(wayConf.wayPosXs[i],wayConf.wayPosYs[i]),
            cc.p(wayConf.wayPosXs[i + 1],wayConf.wayPosYs[i + 1]))
        table.insert(allLens,dis)
        maxLen = maxLen + dis
    end
    -- printall(conf)
    local moveData = CountryWarMgr:getMoveData()
    local time = 3
    if moveData then
        time = (moveData.reachTime - moveData.startTime) / (#moveData.path - 1)
    end
    -- local time1 = time/#wayConf.wayPosXs
    -- print('===============aaaaaaaaaa',time1)
    local size = self.mapPl:getContentSize()
    local scale = size.width/MAX_WIDTH
    local isFirst = true
    local function move(i)
        if i > #wayConf.wayPosXs or i <= 0 then
            if callback then
                callback()
            else
                spineCell:runAction(cc.Sequence:create(cc.FadeOut:create(0.5)))
            end
            return
        end
        local posX = spineCell:getPositionX()
        if wayConf.wayPosXs[i] < posX then
            spineCell:setScaleX(-math.abs(spineCell:getScaleX()))
        else
            spineCell:setScaleX(math.abs(spineCell:getScaleX()))
        end
        if nameTx then
            local scaleX = 1/spineCell:getScaleX()
            nameTx:setScaleX(scaleX)
            fuTx:setScaleX(scaleX)
            nameTx:setPosition(cc.p(scaleX*10,250))
            fuTx:setPosition(cc.p(-nameTx:getContentSize().width/2*scaleX - scaleX*20,250))
        end
        local time1
        if isFlip then
            time1 = time*allLens[i]/maxLen
        else
            print('===============',#allLens,i - 1,maxLen,time)
            if not allLens[i - 1] then
                time1 = time*allLens[1]/maxLen
            else
                time1 = time*allLens[i - 1]/maxLen
            end
        end
        local nextIndex = 0
        if isFlip then
            nextIndex = i - 1
        else
            nextIndex = i + 1
        end
        if meimg then
            meimg:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(wayConf.wayPosXs[i]*scale,wayConf.wayPosYs[i]*scale))))
            spineCell:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(wayConf.wayPosXs[i],wayConf.wayPosYs[i])),cc.CallFunc:create(function()
                move(nextIndex)
            end)))
         else
            if isFirst then
                isFirst = false
                spineCell:runAction(cc.Sequence:create(
                    cc.FadeIn:create(0.5),
                    cc.MoveTo:create(time1,cc.p(wayConf.wayPosXs[i],wayConf.wayPosYs[i])),cc.CallFunc:create(function()
                    move(nextIndex)
                end)))
            else
                spineCell:runAction(cc.Sequence:create(
                    cc.MoveTo:create(time1,cc.p(wayConf.wayPosXs[i],wayConf.wayPosYs[i])),cc.CallFunc:create(function()
                    move(nextIndex)
                end)))
            end
        end
    end
    if isFlip then
        move(#wayConf.wayPosXs - 1)
    else
        move(2)
    end
end

function CountryWarMapUI:syncMove(msg)
    local cell = self.panel2:getChildByName('spine_cell_'..msg.from)
    if not cell then
        cell = ccui.Widget:create()
        cell:setAnchorPoint(cc.p(0,0))
        cell:setScale(0.3)
        cell:setName('spine_cell_'..msg.from)
        local hid = msg.hid or 1501
        local weapon_illusion = nil
        local wing_illusion = nil
        if msg.weapon_illusion and msg.weapon_illusion > 0 then
            weapon_illusion = msg.weapon_illusion
        end
        if msg.wing_illusion and msg.wing_illusion > 0 then
            wing_illusion = msg.wing_illusion
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(nil, weapon_illusion, wing_illusion)
        local spine = GlobalApi:createLittleLossyAniByRoleId(hid, changeEquipObj)
        spine:getAnimation():play('idle', -1, 1)
        spine:setName('spine')
        local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
        nameTx:setColor(COLOR_TYPE.WHITE)
        nameTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        nameTx:setAnchorPoint(cc.p(0.5,0.5))
        nameTx:setName('name_tx')
        nameTx:setScale(1/0.3)

        local fuTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
        fuTx:setColor(COLOR_TYPE.WHITE)
        fuTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        fuTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        fuTx:setAnchorPoint(cc.p(0.5,0.5))
        fuTx:setName('fu_tx')
        fuTx:setScale(1/0.3)

        cell:addChild(spine)
        cell:addChild(nameTx)
        cell:addChild(fuTx)
        cell:setOpacity(0)
        cell:setCascadeOpacityEnabled(true)
        self.panel2:addChild(cell,SPINE_ZORDER)
    end

    local conf = GameData:getConfData("countrywarcity")[msg.from]
    cell:stopAllActions()
    cell:setPosition(cc.p(conf.posX + conf.offsetX,conf.posY + conf.offsetY))
    local spine = cell:getChildByName('spine')
    local nameTx = cell:getChildByName('name_tx')
    local fuTx = cell:getChildByName('fu_tx')
    nameTx:setString(msg.un)
    nameTx:setColor(CAMP_COLOR[msg.country])
    fuTx:setString(msg.serverId..GlobalApi:getLocalStr('FU'))
    fuTx:setColor(COLOR_TYPE.YELLOW)
    self:advance(cell,spine,{msg.from,msg.to},1,nil,nameTx,nil,fuTx)
end

function CountryWarMapUI:moving(index,way)
    if index >= #way then
        self.spine:getAnimation():play('idle', -1, 1)
        self.moveStart = false
        -- local runFlag = self:getMapRunFlag()
        self:updateBackToCityBtn()
        self:updateSpecialMoveImg()
        local cityData = CountryWarMgr.citys[tostring(CountryWarMgr.myCity)]
        if CountryWarMgr.myCity %25 ~= 1 and cityData.fight_state == 1 then
            CountryWarMgr:showCountryWarMatch(CountryWarMgr.myCity)
        end
        return
    end
    local meimg = self.mapImg:getChildByName('me_img')
    local nameTx = self.spineCell:getChildByName('name_tx')
    local fuTx = self.spineCell:getChildByName('fu_tx')
    self:advance(self.spineCell,self.spine,way,index,function()
        CountryWarMgr:reachCity(way[index + 1],function()
            self:updateSpecialMoveImg()
            if self.isNewWay then
                self.moveStart = false
                self.isNewWay = false
                local isOk = self:countWay(self.newWay[1],self.newWay[2],self.newWay[3],self.newWay[4])
                if isOk then
                    CountryWarMgr.runTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
                    self:runMap(self.newWay[2],way)
                end
                self.newWay = {}
            else
                -- CountryWarMgr.myCity = tonumber(way[index + 1])
                self:moving(index + 1,way)
                self:removeLinePoint(way[index],way[index + 1])
            end
        end)
    end,nameTx,meimg,fuTx)
    self.mapImg:stopAllActions()
end

function CountryWarMapUI:setMapChatShoutMsg(msg)
    self.chatMsgs[#self.chatMsgs + 1] = msg
    if self.chatEnd1 and self.chatVisible then
        -- self.chatEnd = false
        self:runChat2()
    end
end

function CountryWarMapUI:runChat2()
    self.chatEnd1 = true
    if not self.chatVisible then
        self.chatNode:setVisible(false)
        return
    end
    local msg = self.chatMsgs[1]
    if msg then
        self.chatEnd1 = false
        table.remove(self.chatMsgs,1)
        self:runMsgAction2(msg)
    else
        self.chatEnd1 = true
    end
end

function CountryWarMapUI:runMsgAction2(msg,again)
    if not self.chatVisible then
        self.chatNode:setVisible(false)
        -- return
    end

    self.chatNode:setVisible(true)
    local chatBgImg = self.chatNode:getChildByName('chat_bg_img')
    local nameTx = chatBgImg:getChildByName('name_tx')
    local serverIdTx = chatBgImg:getChildByName('server_id')
    local chatPl = chatBgImg:getChildByName('chat_pl')
    local chatImg = chatBgImg:getChildByName('chat_img')
    chatImg:setVisible(false)
    if chatPl:getChildByName('system_richtext') then
        chatPl:removeChildByName('system_richtext')
    end
    local msgTx = chatPl:getChildByName('msg_tx')
    local maohaoTx = chatBgImg:getChildByName('maohao_tx')
    local size = chatPl:getContentSize()
    if msg.act == 'system' then
        maohaoTx:setVisible(false)
        nameTx:setString(GlobalApi:getLocalStr('CHAT_DESC_3'))
        local chatNoticeConf = GameData:getConfData('chatnotice')
        local str,htmlstr = ChatNewMgr:getDesc(msg.sub_type,msg.str_array)
        local delay = 5
        local num = string.len(str)/3
        if num <= 1 then
            delay = 5
        elseif num <= 64 then
            delay = 5 + 15*(num/64)
        else
            delay = 20
        end

        local richText = xx.RichText:create()
        richText:setName('system_richtext')
        richText:setAlignment('left')
        richText:setVerticalAlignment('bottom')
	    richText:setContentSize(cc.size(5000, 40))
	    richText:setAnchorPoint(cc.p(0,0))
	    richText:setPosition((cc.p(size.width - 20,-2)))
	    chatPl:addChild(richText)

        local re1 = xx.RichTextLabel:create('\n',20, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,htmlstr)

        msgTx:setString(str)
        msgTx:setVisible(false)
        local size1 = msgTx:getContentSize()
        richText:setContentSize(cc.size(size1.width + 20, 40))
        richText:format(true)
        richText:runAction(cc.Sequence:create(cc.MoveTo:create(delay,cc.p(-size1.width + 20,-2)),cc.CallFunc:create(function()
            if again then
                self.chatNode:setVisible(false)
                -- if #self.chatMsgs > 0 then
                    self:runChat2()
                -- else
                --     self.chatEnd = true
                -- end
            else
                if #self.chatMsgs > 0 then
                    self.chatNode:setVisible(false)
                    self:runChat2()
                else
                    self:runMsgAction2(msg,true)
                end
            end
        end)))

    else
        local serverId = msg.user.serverId
        local stype = nil
        if serverId < 10 then
            stype = '00' .. serverId .. GlobalApi:getLocalStr('CHAT_DESC_10')
        elseif serverId >= 10 and serverId <= 100 then
            stype = '0' .. serverId .. GlobalApi:getLocalStr('CHAT_DESC_10')
        else
            stype = serverId .. GlobalApi:getLocalStr('CHAT_DESC_10')
        end
        serverIdTx:setString('[' .. stype .. ']')
        nameTx:setString(msg.user.un)
        serverIdTx:setPositionX(nameTx:getPositionX() - nameTx:getContentSize().width)
        nameTx:setTextColor(CAMP_COLOR[msg.user.camp])

        msgTx:setVisible(true)    
        msgTx:setString(msg.content)
        msgTx:setPosition(cc.p(size.width,3))
        maohaoTx:setVisible(true)
        local delay = 5
        local num = string.len(msg.content)/3
        if num <= 1 then
            delay = 5
        elseif num <= 64 then
            delay = 5 + 15*(num/64)
        else
            delay = 20
        end
        local size1 = msgTx:getContentSize()
        msgTx:runAction(cc.Sequence:create(cc.MoveTo:create(delay,cc.p(-size1.width,3)),cc.CallFunc:create(function()
            if again then
                self.chatNode:setVisible(false)
                -- if #self.chatMsgs > 0 then
                    self:runChat2()
                -- else
                --     self.chatEnd = true
                -- end
            else
                if #self.chatMsgs > 0 then
                    self.chatNode:setVisible(false)
                    self:runChat2()
                else
                    self:runMsgAction2(msg,true)
                end
            end
        end)))
    end
end

-- function CountryWarMapUI:moving(index,way)
--     if index >= #way then
--         self.spine:getAnimation():play('idle', -1, 1)
--         self.moveStart = false
--         -- local runFlag = self:getMapRunFlag()
--         self:updateBackToCityBtn()
--         if CountryWarMgr.myCity %25 ~= 1 then
--             CountryWarMgr:showCountryWarMatch(CountryWarMgr.myCity)
--         end
--         return
--     end
--     print('xxxxxxxxxxxxxxxxxxxxx',way[index],way[index + 1])
--     local bezier,bezier1 = self:getBezier(self.spineCell,self.spine,way,index)
--     local moveData = CountryWarMgr:getMoveData()
--     local time = (moveData.reachTime - moveData.startTime) / (#moveData.path - 1)
--     local bezierTo = cc.BezierTo:create(time, bezier)
--     local bezierTo1 = cc.BezierTo:create(time, bezier1)
--     self.spineCell:runAction(cc.Sequence:create(bezierTo,cc.CallFunc:create(function()
--         CountryWarMgr:reachCity(way[index + 1],function()
--             if self.isNewWay then
--                 self.moveStart = false
--                 self.isNewWay = false
--                 local isOk = self:countWay(self.newWay[1],self.newWay[2],self.newWay[3],self.newWay[4])
--                 if isOk then
--                     CountryWarMgr.runTime = GlobalData:getServerTime()
--                     self:runMap(self.newWay[2],way)
--                 end
--                 self.newWay = {}
--             else
--                 CountryWarMgr.myCity = tonumber(way[index + 1])
--                 self:moving(index + 1,way)
--                 self:removeLinePoint(way[index],way[index + 1])
--             end
--         end)
--     end)))
--     local meimg = self.mapImg:getChildByName('me_img')
--     meimg:runAction(cc.Sequence:create(bezierTo1))
--     -- printall(bezier)
--     self.mapImg:stopAllActions()
--     -- local maxTimes = 20
--     -- print('=============================xxxx',maxTimes)
--     -- local function printPos()
--     --     print('=============================xxxx1',maxTimes)
--     --     if maxTimes <= 0 then
--     --         return
--     --     end
--     --     maxTimes = maxTimes - 1
--     --     self.mapImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
--     --         local posX,posY = self.spineCell:getPositionX(),self.spineCell:getPositionY()
--     --         print(posX,posY)
--     --         printPos()
--     --         local img = ccui.ImageView:create('uires/ui/countrywar/line_point.png')
--     --         img:setPosition(cc.p(posX,posY))
--     --         self.panel2:addChild(img,999)
--     --     end)))
--     -- end
--     -- printPos()
-- end

return CountryWarMapUI