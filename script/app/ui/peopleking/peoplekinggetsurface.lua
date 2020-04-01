local PeopleKingGetSurfaceUI = class("PeopleKingGetSurfaceUI", BaseUI)

function PeopleKingGetSurfaceUI:ctor(surfaceAward)
    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_GET_SURFACE
    self.surfaceAward = surfaceAward
    self.awardCount = #self.surfaceAward
    self.showId = 1
    self.surfaceType = 1
end

function PeopleKingGetSurfaceUI:init()

    local nobilitybaseCfg = GameData:getConfData('nobiltybase')
    local alphaBg = self.root:getChildByName("alpha_bg")
    self.bg = alphaBg:getChildByName("bg_img")
    self:adaptUI(alphaBg, self.bg)

    self.oldweaponAttr = RoleData:getPeopleKingWeaponAttr() 
    self.oldwingAttr = RoleData:getPeopleKingWingAttr()
    for i = 1, 4 do
        self.oldweaponAttr[i] = self.oldweaponAttr[i] or 0
        self.oldwingAttr[i] = self.oldwingAttr[i] or 0
    end
    self.oldfightforce = RoleData:getFightForce()

    self:showMode(self.surfaceAward[self.showId])

    --获取按钮
    local getBtn = self.bg:getChildByName("goto_btn")
    local btnTx = getBtn:getChildByName("info_tx")
    btnTx:setString(GlobalApi:getLocalStr("STR_GOTO_VIEW"))
    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           PeopleKingMgr:showPeopleKingChangeLookUI(self.surfaceType)
           PeopleKingMgr:hidePeopleKingGetSurfaceUI()
        end
    end)

    --确定按钮
    local confirmBtn = self.bg:getChildByName("confirm_btn")
    local confirmTx = confirmBtn:getChildByName("info_tx")
    confirmTx:setString(GlobalApi:getLocalStr("STR_OK2"))
    confirmBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:close()
        end
    end)

    alphaBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:close()
        end
    end)
end

function PeopleKingGetSurfaceUI:close()
    
    if self.awardCount == 0 then
        PeopleKingMgr:hidePeopleKingGetSurfaceUI()
    else
       self.showId = self.showId + 1
       self:showMode(self.surfaceAward[self.showId]) 
    end
end

function PeopleKingGetSurfaceUI:showMode(siglesurfaceAward)

    if not siglesurfaceAward then
        return
    end
    print("self.awardCount",self.awardCount)
    local peopleKingData = UserData:getUserObj():getPeopleKing()

    local customObj = {}
    local typestr = siglesurfaceAward[1]
    local id = tonumber(siglesurfaceAward[2])
    local typeid,typenameStr = 1,''
    if typestr == "skyweapon" then
        typeid = 1
        customObj.weapon_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1")

        local ownWeapon = peopleKingData.ownWeapon
        local owned = false
        for k,v in pairs(ownWeapon) do
            if v == id then
                owned = true
                break
            end
        end

        if not owned then
            ownWeapon[#ownWeapon+1] = id
            UserData:getUserObj():getPeopleKing().ownWeapon = ownWeapon
            local collect = UserData:getUserObj():getPeopleKing().weapon_collect
            collect = collect + 1
            UserData:getUserObj():getPeopleKing().weapon_collect = collect
        end
    elseif typestr == "skywing" then
        typeid = 2
        customObj.wing_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")

        local ownWing = peopleKingData.ownWing
        local owned = false
        for k,v in pairs(ownWing) do
            if v == id then
                owned = true
                break
            end
        end

        if not owned then
            ownWing[#ownWing+1] = id
            UserData:getUserObj():getPeopleKing().ownWing = ownWing
            local collect = UserData:getUserObj():getPeopleKing().wing_collect
            collect = collect + 1
            UserData:getUserObj():getPeopleKing().wing_collect = collect
        end
    end


    self.surfaceType = typeid
    local skychangeConf = GameData:getConfData("skychange")[typeid]

    --展示模型
    local modelNode = self.bg:getChildByName("model_node")
    modelNode:removeAllChildren()
    local roleObj = RoleData:getMainRole()
    local mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState(customObj))
    mainRoleAni:getAnimation():play("idle", -1, 1)
    mainRoleAni:setPosition(cc.p(0, 0))
    modelNode:addChild(mainRoleAni)

    --类型名字
    local typeNameTx = self.bg:getChildByName("typename_tx")
    typeNameTx:setString(typenameStr)
    
    local nameTx = self.bg:getChildByName("name_tx")
    local nameStr = skychangeConf[id].name
    nameTx:setString(nameStr)

    local lightImg = self.bg:getChildByName("light_bg")
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(10, 360)))

    self.awardCount = self.awardCount - 1
    local newAttr = typeid == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
    local oldAttr = typeid == 1 and self.oldweaponAttr or self.oldwingAttr
    for i = 1, 4 do
        newAttr[i] = newAttr[i] or 0
    end
    RoleData:setAllFightForceDirty()
    local newfightforce = RoleData:getFightForce()
    GlobalApi:popupTips(oldAttr, newAttr, self.oldfightforce, newfightforce)

end

return PeopleKingGetSurfaceUI