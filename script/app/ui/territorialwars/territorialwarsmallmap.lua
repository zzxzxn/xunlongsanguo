local TerritorialWarsSamllMap = class("TerritorialWarsSamllMap", BaseUI)

function TerritorialWarsSamllMap:ctor(openCells,posCellTab,territoryWar,hextab,curHexPos,otherObj,bossCellId)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_SAMLL_MAP
    self.openCells = openCells
    self.posCellTab = posCellTab
    self.territoryWar = territoryWar
    self.hextab = hextab
    self.curHexPos = curHexPos
    self.otherObj = otherObj
    self.bossCellId = bossCellId
    self.gidConfig = GameData:getConfData("dfmapgrid")
    self.paramConfig = GameData:getConfData("dfbasepara")
end

function TerritorialWarsSamllMap:init()
    local bgImg = self.root:getChildByName("bg_img")
    local pl = bgImg:getChildByName("pl")
    self.bgImg1 = pl:getChildByName("bg_img1")
    self.bgImg3 = pl:getChildByName("bg_img3")
    local bgImg2 = bgImg:getChildByName("bg_img2")
    self:adaptUI(bgImg, pl)
    local closeBtn = bgImg:getChildByName("close_btn")
    local winSize = cc.Director:getInstance():getVisibleSize()
    local topBgImg = pl:getChildByName('top_bg_img')
    self.cloudNode = pl:getChildByName("cloud_node")
    local descTx1 = topBgImg:getChildByName("desc_tx_1")
    local descTx2 = topBgImg:getChildByName("desc_tx_2")
    descTx1:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC5'))
    descTx2:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO41'))

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideSmallMapUI()
        end
    end)

    self.bgImg3:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local clickPos = sender:getTouchEndPosition()
            local clickMapPos = self.bgImg3:convertToNodeSpace(clickPos)
            local cellPos = self:GetCell(clickMapPos.x,clickMapPos.y)
            local cellId = self.hextab[cellPos.x][cellPos.y]._cellId
            local click = TerritorialWarMgr:isCellCanClick(cellId)
            if click then
                TerritorialWarMgr:hideSmallMapUI()
                TerritorialWarMgr:locationPos(cellPos)
            end
        end
    end)

    bgImg2:setPosition(cc.p(winSize.width/2,winSize.height/2))

    local bgImg2Size = bgImg2:getContentSize()
    closeBtn:setPosition(cc.p(winSize.width/2 + bgImg2Size.width/2 + 20, winSize.height/2 + bgImg2Size.height/2 + 25))
    local posX,posY = pl:getPosition()
    local size = pl:getContentSize()
    self.cloudNode:setPosition(cc.p(0,0))

    self:createBoss()
    self:createMyself()
    self:createOthers()
    local newBlockEffect = cc.Node:create()
    self.cloudNode:addChild(newBlockEffect)
    self:refreshClouds(newBlockEffect)
end

function TerritorialWarsSamllMap:GetCell(x, y)

    local points = {}
    local distance = 1000000
    local horizontalIndex,verticalIndex = 0,0
     for i=1,#self.gidConfig do
        local pos = self:convertToHexPos(i)
        if pos ~= nil then
            if self.hextab[pos.x][pos.y] ~= nil then
                local newDis = math.sqrt(self:distance2(x,y, self.hextab[pos.x][pos.y]._centerPosX/5, (self.hextab[pos.x][pos.y]._centerPosY-5)/5))
                if distance > newDis then
                    distance = newDis
                    horizontalIndex = pos.x
                    verticalIndex = pos.y
                end
             end
        end
    end

    points.x = horizontalIndex
    points.y = verticalIndex

    return points
end

function TerritorialWarsSamllMap:distance2(x1, y1, x2, y2)
    return ((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
end

function TerritorialWarsSamllMap:getCellPos(x, y)
    local key = x .. '_' .. y
    if self.posCellTab[key] == nil then
        return 0
    end

    return self.posCellTab[key].pos
end

function TerritorialWarsSamllMap:refreshClouds(newBlockEffect)
    local fogConf = GameData:getConfData('dffogconf')
    for k, v in pairs(fogConf) do
        local cellPos = self:getCellPos(v.pos[1], v.pos[2])
        if not self.openCells[k] then
            local cloud = ccui.ImageView:create('uires/ui/territorialwars/terwars_cloud.png')
            cloud:setPosition(cellPos)
            newBlockEffect:addChild(cloud)
        end
    end
end

function TerritorialWarsSamllMap:createBoss()

    if self.bossCellId then
        local bosshead = ccui.ImageView:create('uires/ui/territorialwars/terwars_bosshead.png')
        local hexPos = self:convertToHexPos(self.bossCellId)
        bosshead:setPosition(cc.p(self.hextab[hexPos.x][hexPos.y]._centerPosX/5,(self.hextab[hexPos.x][hexPos.y]._centerPosY-5)/5))
        self.bgImg3:addChild(bosshead)
    end
end

function TerritorialWarsSamllMap:convertToHexPos(Id)
    local cellId = tonumber(Id)
    if self.gidConfig[cellId] == nil then
        return
    end

    local pos = self.gidConfig[cellId]['pos']
    if #pos ~= 2 then
        return
    end
    local hexPos = {}
    hexPos.x,hexPos.y = pos[1],pos[2]
    return hexPos
end

function TerritorialWarsSamllMap:createMyself(gridBlock)
    local value = self.paramConfig.initialPos['value']
    local initCellId = tonumber(value[1])
    local sourcePos = {}
    if self.curHexPos == nil or self.curHexPos.horIndex == nil then
        sourcePos = self:convertToHexPos(initCellId)
    else
         sourcePos.x = self.curHexPos.horIndex
         sourcePos.y = self.curHexPos.verIndex
    end
    self:createPlayerMode(self.curHexPos.horIndex,self.curHexPos.verIndex,false)
end

function TerritorialWarsSamllMap:createOthers()
    local lid = UserData:getUserObj():getLid()
    for k,v in pairs(self.otherObj) do
        local pos = self:convertToHexPos(v.cellId)
        if pos and v.lid ~= lid then
            self:createPlayerMode(pos.x,pos.y,true)
        end
    end
end

function TerritorialWarsSamllMap:createPlayerMode(horizontalIndex,verticalIndex,isEnemy)
    
    if self.hextab[horizontalIndex] == nil or self.hextab[horizontalIndex][verticalIndex] == nil then
        return
    end

    local img = ccui.ImageView:create()
    if isEnemy then
        img:loadTexture('uires/ui/common/rhomb_4.png')
    else
        img:loadTexture('uires/ui/common/rhomb_1.png')
    end
    img:setAnchorPoint(cc.p(0.5, 0.5))
    img:setPosition(cc.p(self.hextab[horizontalIndex][verticalIndex]._centerPosX/5,(self.hextab[horizontalIndex][verticalIndex]._centerPosY-5)/5))

    self.bgImg1:addChild(img)
end

return TerritorialWarsSamllMap