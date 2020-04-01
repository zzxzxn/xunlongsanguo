local HonorHallUI = class("HonorHallUI", BaseUI)
function HonorHallUI:ctor(id)
    self.uiIndex = GAME_UI.UI_HONORHALL
    self.numOfMoveRoles = 30
    self.nextMoveTime = 5
    self.types = {"fight_force","arena","tower","country1","country2","country3","pvp","legion","tavern"}
    self.cellPosX = {94,281,472,666,866,1068,1271,1478,1684}
    self.allTags = {}
    self.bulletColors = {COLOR_TYPE.RED,COLOR_TYPE.YELLOW,COLOR_TYPE.GREEN,COLOR_TYPE.WHITE}

end
function HonorHallUI:init()

    local root =  self.root:getChildByName("root")
    self.rootBG = root
    

    local SceneView  =  ccui.Helper:seekWidgetByName(root,"SceneView")
    SceneView:setScrollBarEnabled(false)
    local UIRoot     =  ccui.Helper:seekWidgetByName(root,"UIRoot")
    self.uiRoot = UIRoot

    self.MoveZoon     = ccui.Helper:seekWidgetByName(SceneView,"MoveZoon")
    self.tempRoleName = ccui.Helper:seekWidgetByName(self.MoveZoon,"roleName")
    self.tempRoleName:setVisible(false)

    self.tempBullet = ccui.Helper:seekWidgetByName(UIRoot,"bullet")
    self.tempRoleName:setVisible(true)

    self.rolesRoot   =  ccui.Helper:seekWidgetByName(SceneView,"Roles")

    self.closeBtn    =  ccui.Helper:seekWidgetByName(UIRoot,"closeBtn")
    self.rangkingBtn =  ccui.Helper:seekWidgetByName(UIRoot,"rangkingBtn")
    self.tagBtn      =  ccui.Helper:seekWidgetByName(UIRoot,"tagBtn")
    self.banIcon     =   ccui.Helper:seekWidgetByName(UIRoot,"banIcon")

   

    self.roleCell = ccui.Helper:seekWidgetByName(UIRoot,"role_cell")
    self.roleCell:setVisible(false)

    

   

    --self:adaptUI(UIRoot,nil,false)
    local winSize = cc.Director:getInstance():getWinSize()
    root:setPositionY(winSize.height)
    UIRoot:setContentSize(winSize)
    self.closeBtn:setPosition(winSize.width,winSize.height)
    self.tagBtn:setPosition(cc.p(50,20))
    self.rangkingBtn:setPosition(cc.p(winSize.width-50,20))

    self.MoveZoon:setContentSize(cc.size(self.MoveZoon:getContentSize().width,self.MoveZoon:getContentSize().height - (768 - winSize.height)))
    SceneView:setContentSize(winSize.width/winSize.height*768,SceneView:getContentSize().height)
    SceneView:setScale(winSize.height/768)
    SceneView:jumpToPercentHorizontal(50)




    self:registerTouchEvents()

    

end
function HonorHallUI:DoLayout()
   

end
function HonorHallUI:ActionClose(call)
    self:hideUI()
end
function HonorHallUI:registerTouchEvents()

   local function clickRanking(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            RankingListMgr:showRankingListMain()
            -- RankingListMgr:showRankingListMain()
        end
   end
   self.rangkingBtn:addTouchEventListener(clickRanking)

   local function clickClose(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            HonorHallMgr:hideUI()
        end
    end
    self.closeBtn:addTouchEventListener(clickClose)

    local function clickTag(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
              if(self.showingTags) then
                   self:hideTags()
              else
                   self:showTags()
                   self.banIcon:setVisible(false)
              end
        end
    end
    self.tagBtn:addTouchEventListener(clickTag)

end
function HonorHallUI:replcaceType(typeString,data)
    self.roleList[typeString] = data

    for k,cell in pairs(self.roleCells)  do
        if(cell.typeString == typeString) then
            if(cell.animation ~= nil) then
                cell:removeChild(cell.animation)
                cell.animation = nil
            end
            self:ShowRole(cell,data)
        end
    end
end
function HonorHallUI:addTag(tag)
    table.insert(self.allTags,tag) 
    if(#self.allTags == 1) then
        self:showTags()
    end
end
function HonorHallUI:showTags()
    self.banIcon:setVisible(false)
    if(#self.allTags <= 0) then
        return
    end
    self.showingTags = true
    self.nextTagTime = 0
    self.curLoopTime = 0
    self.curTagIndex = 1
end
function HonorHallUI:hideTags()
    self.banIcon:setVisible(true)
    self.showingTags = false

end
function HonorHallUI:updateTags(dt)
    

    self.nextTagTime = self.nextTagTime - dt
    self.curLoopTime = self.curLoopTime + dt

    if(self.nextTagTime > 0) then
        return
    end  
    self.nextTagTime = math.random(200,400)

    if(self.curTagIndex < #self.allTags) then
        self.curTagIndex = self.curTagIndex +1 
    else
        if(self.curLoopTime > 4000) then
            self.curLoopTime = 0
            self.curTagIndex = 1
        else
            return
        end
    end

    local cIdx = math.random(1,#self.bulletColors)
    local color = self.bulletColors[cIdx]
    local newCell = self.tempBullet:clone()
    newCell:setString(self.allTags[self.curTagIndex])
    newCell:setTextColor(color)
    self.uiRoot:addChild(newCell)
    local targetX = self.uiRoot:getContentSize().width
    local targetY = math.random(30,self.uiRoot:getContentSize().height-30)
    newCell:setPosition(cc.p(targetX,targetY))
    newCell:runAction(cc.Sequence:create(cc.MoveBy:create(math.random(2.5,3.5),cc.p(-(self.uiRoot:getContentSize().width + newCell:getContentSize().width),0)),
            cc.CallFunc:create(function ()
            self.uiRoot:removeChild(newCell)
        end))
   )

end
function HonorHallUI:ShowRole(cell,data)
       
   
    local heroconf = GameData:getConfData('hero')
    local width = self.roleCell:getContentSize().width

    local  sortRoleDatas = {}
    for key,data in pairs(heroconf) do
        table.insert(sortRoleDatas,data)
        math.random(1,#sortRoleDatas)
    end
    
    if(data~= nil and heroconf[data.headpic] ~= nil) then
        local nameText = ccui.Helper:seekWidgetByName(cell,"name")
        nameText:setString(data.un)
        local animation  = nil
        local path = heroconf[data.headpic].url
        local promote = nil
        local weapon_illusion = nil
        local wing_illusion = nil
        if data.promote and data.promote[1] then
            promote = data.promote[1]
        end
        if heroconf[data.headpic].camp == 5 then
            if data.weapon_illusion and data.weapon_illusion > 0 then
                weapon_illusion = data.weapon_illusion
            end
            if data.wing_illusion and data.wing_illusion > 0 then
                wing_illusion = data.wing_illusion
            end
        end
        local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
        animation = GlobalApi:createLittleLossyAniByName(path .. "_display", nil, changeEquipObj)

        animation:setPositionY(-10 + heroconf[data.headpic].uiOffsetY)

        cell.animation = animation
        animation:getAnimation():play("idle", -1, 1)
        --animation:getAnimation():gotoAndPause(0)
        cell:addChild(animation)
        animation:setPositionX(width * 0.5 + 5)

        animation:setLocalZOrder(-1)
        animation:setScale(0.8)

            --ShaderMgr:setLightnessColorForArmature(animation,'particle/wenli_00257.tga')
--             animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
--                 ShaderMgr:setLightnessColorForArmature(animation,cc.vec4(0.1,0.1,0,1),cc.vec4(0.85,0.85,0.4,1))
--            end)))

        local function clickHonorHero(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                HonorHallMgr:GetTagData(cell.typeString,data.uid)
            end
        end
        cell:addTouchEventListener(clickHonorHero)
    else
         local nameBG = ccui.Helper:seekWidgetByName(cell,"nameBG")
         nameBG:setVisible(false)
    end
end
function HonorHallUI:setTopRoles(roleList)
    
    self.roleList = roleList
   
    self.roleCells = {}
    for i = 1,#self.types do
        local newCell = self.roleCell:clone()
        newCell:setVisible(true)
        

        local roleType = self.types[i]
        newCell.typeString = roleType
        local roleData = roleList[roleType]

        if(roleData ~= nil) then
            self.rolesRoot:addChild(newCell)
            newCell:setPosition(self.cellPosX[i],0)
            self:ShowRole(newCell,roleData)
        
            table.insert(self.roleCells,newCell)

            if(roleData.bullet ~= nil) then
                for  k,v in pairs(roleData.bullet) do
                    table.insert(self.allTags,v)
                end
            end
        end

    end

    
end
function HonorHallUI:createMoveRoles(names)
    if(names == nil) then
        return
    end
    self.roles = {}
    local heroconf = GameData:getConfData('hero')
    local  sortRoleDatas = {}
    for key,data in pairs(heroconf) do
        table.insert(sortRoleDatas,data)
    end
    
    for i = 1,#names do        
       local index = math.floor(math.random(1,#sortRoleDatas))
       local path = sortRoleDatas[index].url
       local animation = GlobalApi:createLittleLossyAniByName(path .. "_display")
       animation:getAnimation():play("idle", -1, 1)
       self.MoveZoon:addChild(animation)

       local name = self.tempRoleName:clone()
       name:setAnchorPoint(cc.p(0.5,0))
       name:setScale(2)
       name:setVisible(true)
       name:setString(names[i])
       name:setLocalZOrder(10000)

       animation.name = name
       animation:setScale(0.5)
       local hpBarHeight = sortRoleDatas[index].hpBarHeight
       local size = animation:getContentSize()
       name.hpBarHeight = hpBarHeight
       --name:setPosition(cc.p(0,math.abs(sortRoleDatas[index].uiOffsetY * 0.5)))
       --name:removeFromParent(false)
       name:setPosition(cc.p(animation:getPositionX(),name.hpBarHeight + animation:getPositionY()))
       self.MoveZoon:addChild(name)
       local pos = name:convertToWorldSpace(cc.p(0, 0))
       local despos = animation:convertToNodeSpace(cc.p(pos.x,pos.y))
       name:removeFromParent(false)
       animation:addChild(name)

       animation:setPosition(self:randomMovePoint())
       name:setPosition(cc.p(0,despos.y + 32))

       table.insert(self.roles,animation)
    end
    self:showTags()
    self.rootBG:scheduleUpdateWithPriorityLua(function (dt)
                self:update(dt)
            end, 0)


end
function HonorHallUI:update(dt)
    self:updateRoles(dt)

    if(self.showingTags) then
        self:updateTags(dt * 1000)
    end
end
function HonorHallUI:updateRoles(dt)
    self.nextMoveTime =self.nextMoveTime -  dt
    local moveSpeed = 100 --pixel/s
    if(self.nextMoveTime < 0) then
        self.nextMoveTime = math.random(3,7)
        local numOfCurMoveRole = math.random(1,3)
        for i = 1,numOfCurMoveRole do
            local index =  math.random(1,#self.roles)
            local role = self.roles[index]
            role:stopAllActions()
            local curPoint = cc.p(role:getPosition())
            local x = math.random(math.max(curPoint.x - 250,0),math.min(curPoint.x + 250,self.MoveZoon:getContentSize().width))
            local y = math.random(math.max(curPoint.y - 250,0),math.min(curPoint.y + 250,self.MoveZoon:getContentSize().height))
            local target = cc.p(x,y)
            local len = cc.pGetDistance(target,curPoint)

            --local target2 = cc.p(x,y + role.name.hpBarHeight)

            if(len > 40) then
                local time = len / moveSpeed
                role:getAnimation():play("run", -1, 1)
                if(target.x - role:getPositionX() > 0) then
                    role:setScaleX(0.5)
                    role.name:setScaleX(2)
                else
                    role:setScaleX(-0.5)
                    role.name:setScaleX(-2)
                end
                role:runAction( cc.Sequence:create(cc.MoveTo:create(time,target),cc.CallFunc:create(function ()
                    role:getAnimation():play("idle", -1, 1)
                end)))

              --role.name:runAction( cc.Sequence:create(cc.MoveTo:create(time,target2),cc.CallFunc:create(function ()   
                    --role.name:setPosition(target2)     
                --end)))
            end

        end
        
    end

    table.sort( self.roles, function (a, b)
		return a:getPositionY() > b:getPositionY()
	end)
    for i = 1,#self.roles do
        self.roles[i]:setLocalZOrder(i)
    end
end
function HonorHallUI:randomMovePoint()
    local x = math.random(0,self.MoveZoon:getContentSize().width)
    local y = math.random(0,self.MoveZoon:getContentSize().height)
    return cc.p(x,y)
end
return HonorHallUI