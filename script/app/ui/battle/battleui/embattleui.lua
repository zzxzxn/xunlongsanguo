local EmbattleUI = class("EmbattleUI", BaseUI)

local LEGION_POS = {
    [1] = cc.p(750, 560), [4] = cc.p(950, 560), [7] = cc.p(1150, 560),
    [2] = cc.p(810, 400), [5] = cc.p(1010, 400), [8] = cc.p(1210, 400),
    [3] = cc.p(870, 240), [6] = cc.p(1070, 240), [9] = cc.p(1270, 240)
}

function EmbattleUI:ctor(data,callback,stype)
    self.uiIndex = GAME_UI.UI_EMBATTLE
    self.data = data
    self.callback = callback
    self.stype = stype
end

function EmbattleUI:init()
    local winSize = cc.Director:getInstance():getWinSize()

    local bg_img = self.root:getChildByName("bg_img")
    bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))

    for i = 1, 3 do
        local ui_embattle_arrow = GlobalApi:createLittleLossyAniByName("ui_embattle_arrow")
        ui_embattle_arrow:getAnimation():playWithIndex(0, -1, -1)
        bg_img:addChild(ui_embattle_arrow)
        ui_embattle_arrow:setPosition(cc.p(LEGION_POS[i].x - 230, LEGION_POS[i].y))
        ui_embattle_arrow:setScale(1.2)
    end

    local modifyFlag = false
    local team = {}
    local skills = {0,0,0,0,0}
    local back_btn = self.root:getChildByName("back_btn")
    local backLabel = back_btn:getChildByName("text")
    backLabel:setString(string.format(GlobalApi:getLocalStr("SAVE_FORMATION"), "\n"))
    back_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if modifyFlag then
                local args = {
                    team = team,
                    skills = skills
                }
                if self.callback then
                    self.callback(args)
                else
                    MessageMgr:sendPost("set_def_info", "user", json.encode(args), function (jsonObj)
                        if jsonObj.code == 0 then
                            BattleMgr:hideEmbattleUI()
                        end
                    end)
                end
            else
                BattleMgr:hideEmbattleUI()
            end
        end
    end)
    back_btn:setPosition(cc.p(winSize.width - 80, 60))

    local counter_btn = self.root:getChildByName("counter_btn")
    local counterLabel = counter_btn:getChildByName("text")
    counterLabel:setString(string.format(GlobalApi:getLocalStr("STR_COUNTER_RELATION"), "\n"))
    counter_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:showBattleCounter()
        end
    end)
    counter_btn:setPosition(cc.p(80, 60))

    local skill_list_node = self.root:getChildByName("skill_list_node")
    skill_list_node:setPosition(cc.p(winSize.width*0.5, 0))

    local info_bg_img = self.root:getChildByName("info_bg_img")
    info_bg_img:setPosition(cc.p(0, winSize.height+4))
    local info_tx = info_bg_img:getChildByName("info_tx")
    if self.stype == 'countrywar' then
        info_tx:setString(GlobalApi:getLocalStr("STR_DEFENSE_EMBATTLE_1"))
        local descTx = cc.Label:createWithTTF(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_78"), "font/gamefont.ttf", 20)
        descTx:setColor(COLOR_TYPE.WHITE)
        descTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
        descTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        descTx:setAnchorPoint(cc.p(0,0.5))
        descTx:setPosition(cc.p(400,info_tx:getPositionY()))
        info_bg_img:addChild(descTx)
    else
        info_tx:setString(GlobalApi:getLocalStr("STR_DEFENSE_EMBATTLE"))
    end
    local myFightForce = tostring(UserData:getUserObj():getFightforce())
    local fightforceLabel = cc.LabelAtlas:_create(myFightForce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    info_bg_img:addChild(fightforceLabel)
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
    fightforceLabel:setPosition(cc.p(220, 40))
    fightforceLabel:setScale(0.8)
    -- 君主技能
    local playerSkillConf = GameData:getConfData("playerskill")
    local slotConf = GameData:getConfData("playerskillslot")
    local playerLevel = UserData:getUserObj():getLv()
    local skillBorderArr = {}
    local playerskills = UserData:getUserObj():getSkills()
    for i = 1, 5 do
        local skill_border = skill_list_node:getChildByName("skill_border_" .. i)
        local open_tx = skill_border:getChildByName("open_tx")
        local icon = skill_border:getChildByName("dragon")
        icon:ignoreContentAdaptWithSize(true)
        local flag = skill_border:getChildByName("flag")
        local label = flag:getChildByName("text")
        local add = skill_border:getChildByName("add")
        add:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1.5),cc.FadeOut:create(1.5),cc.DelayTime:create(0.5))))
        local obj = {
            icon = icon,
            label = label,
            add = add
        }
        skillBorderArr[i] = obj
        local openLevel = slotConf[i].open
        if playerLevel >= openLevel then
            skill_border:addClickEventListener(function ()
                MainSceneMgr:showSkillSelect(function(id)
                    if skills[i] ~= id then
                        modifyFlag = true
                        skillBorderArr[i].add:setVisible(false)
                        skillBorderArr[i].icon:setVisible(true)
                        skillBorderArr[i].icon:loadTexture("uires/ui/treasure/treasure_" .. playerSkillConf[id].icon)
                        local dragon = RoleData:getDragonById(id)
                        skillBorderArr[i].label:setString(tostring(dragon:getLevel()))
                        for k, v in ipairs(skills) do
                            if v == id then
                                skills[k] = 0
                                skillBorderArr[tonumber(k)].icon:setVisible(false)
                                skillBorderArr[tonumber(k)].add:setVisible(true)
                                skillBorderArr[tonumber(k)].label:setString("")
                                break
                            end
                        end
                        skills[i] = id
                    end
                end, GlobalApi:getLocalStr("SELECT_CHANGE_SKILL"), GlobalApi:getLocalStr("NOT_COMPLETE_HATCH"))
            end)
            open_tx:setVisible(false)
        else
            skill_border:setTouchEnabled(false)
            flag:setVisible(false)
            add:setVisible(false)
            open_tx:setString(openLevel .. GlobalApi:getLocalStr("STR_POSCANTOPEN_1"))
        end
    end

    for k, v in pairs(self.data.skills) do
        skills[tonumber(k)] = v
        if tonumber(v) > 0 then
            skillBorderArr[tonumber(k)].add:setVisible(false)
            skillBorderArr[tonumber(k)].icon:setVisible(true)
            skillBorderArr[tonumber(k)].icon:loadTexture("uires/ui/treasure/treasure_" .. playerSkillConf[tonumber(v)].icon)
            if self.stype == 'worldwar' or self.stype == 'countrywar' then
                local dragon = RoleData:getDragonById(tonumber(v))
                skillBorderArr[tonumber(k)].label:setString(dragon:getLevel())
            else
                skillBorderArr[tonumber(k)].label:setString(tostring(playerskills[k].level))
            end
        else
            skillBorderArr[tonumber(k)].icon:setVisible(false)
            skillBorderArr[tonumber(k)].label:setString("")
        end
    end
    -- 底座和旗子
    local aniMap = {}
    local targetHero
    local pedestalArr = {}
    local armyflags = {}
    local slotMap = {}
    for i = 1, 9 do
        local pedestal = bg_img:getChildByName("base_" .. i)
        pedestalArr[i] = pedestal
        pedestal:setTouchEnabled(true)
        pedestal:setPosition(cc.p(LEGION_POS[i].x, LEGION_POS[i].y+20))
        local particle = cc.ParticleSystemQuad:create("particle/battle_circle.plist")
        particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
        particle:setPosition(cc.p(76, 38))
        particle:setScaleY(0.7)
        pedestal:addChild(particle)
        pedestal:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                targetHero = aniMap[i]
                if targetHero then
                    targetHero.hero:setLocalZOrder(100)
                    for k, v in ipairs(pedestalArr) do
                        if k ~= i then
                            v:setTouchEnabled(false)
                        end
                    end
                end
            elseif eventType == ccui.TouchEventType.moved then
                if targetHero then
                    local pos = sender:getTouchMovePosition()
                    local convertPos = bg_img:convertToNodeSpace(pos)
                    targetHero.hero:setPosition(convertPos)
                end
            elseif eventType == ccui.TouchEventType.ended then
                if targetHero == nil then
                    return
                end
                targetHero.hero:setPosition(LEGION_POS[i])
                targetHero.hero:setLocalZOrder(10)
                for k, v in ipairs(pedestalArr) do
                    v:setTouchEnabled(true)
                end
            elseif eventType == ccui.TouchEventType.canceled then
                if targetHero == nil then
                    return
                end
                local endPos = sender:getTouchEndPosition()
                local convertPos = bg_img:convertToNodeSpace(endPos)
                local minLength = 10000
                local minIndex = 0
                for n = 1, 9 do
                    local lengh = cc.pGetDistance(LEGION_POS[n], convertPos)
                    if minLength > lengh then
                        minLength = lengh
                        minIndex = n
                    end
                end
                local action = nil
                if minLength > 100 or minIndex == i then  -- 离最近的一个底座也太远了
                    action = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[i]), cc.CallFunc:create(function ()
                        for k, v in ipairs(pedestalArr) do
                            v:setTouchEnabled(true)
                        end
                        targetHero.hero:setLocalZOrder(10)
                    end))
                else
                    local swopHero = aniMap[minIndex]
                    if swopHero then
                        local swopAction = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[i]), cc.CallFunc:create(function ()
                            swopHero.hero:setLocalZOrder(10)
                            swopHero.hero:setPosition(LEGION_POS[i])
                        end))
                        swopHero.hero:runAction(swopAction)
                    end
                    action = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[minIndex]), cc.CallFunc:create(function ()
                        modifyFlag = true
                        aniMap[minIndex] = targetHero
                        team[tostring(targetHero.slot)] = minIndex
                        targetHero.hero:setLocalZOrder(10)
                        aniMap[i] = swopHero
                        armyflags[minIndex]:setVisible(true)
                        armyflags[minIndex]:loadTexture("uires/ui/battle/flag_" .. targetHero.legionType .. ".png")
                        if swopHero == nil then
                            armyflags[i]:setVisible(false)
                        else
                            armyflags[i]:setVisible(true)
                            armyflags[i]:loadTexture("uires/ui/battle/flag_" .. swopHero.legionType .. ".png")
                            team[tostring(swopHero.slot)] = i
                        end
                        for k, v in pairs(pedestalArr) do
                            v:setTouchEnabled(true)
                        end
                    end))
                end
                targetHero.hero:runAction(action)
                for k, v in pairs(pedestalArr) do
                    v:setTouchEnabled(false)
                end
            end
        end)
        -- 旗子
        armyflags[i] = ccui.ImageView:create()
        armyflags[i]:setVisible(false)
        armyflags[i]:ignoreContentAdaptWithSize(true)
        armyflags[i]:setLocalZOrder(20)
        armyflags[i]:setPosition(cc.p(LEGION_POS[i].x + 50, LEGION_POS[i].y + 50))
        bg_img:addChild(armyflags[i])
    end
    -- 武将
    -- 先按服务器发来的数据站位
    for i = 1, 7 do
        local standPos = self.data.team[tostring(i)]
        if standPos and standPos > 0 then
            local heroObj = RoleData:getRoleByPos(i)
            if heroObj and heroObj:getId() > 0 then
                local heroBaseInfo = GameData:getConfData("hero")[heroObj:getId()]
                local ani = GlobalApi:createAniByName(heroObj:getUrl(), nil, heroObj:getChangeEquipState())
                bg_img:addChild(ani)
                ani:getAnimation():play("idle", -1, -1)
                ani:setScale(-heroBaseInfo.scale/100, heroBaseInfo.scale/100)
                aniMap[standPos] = {}
                aniMap[standPos].hero = ani
                aniMap[standPos].legionType = heroBaseInfo.legionType
                aniMap[standPos].slot = i
                ani:setPosition(cc.p(LEGION_POS[standPos]))
                slotMap[i] = 1
                team[tostring(i)] = standPos
                armyflags[standPos]:setVisible(true)
                armyflags[standPos]:loadTexture("uires/ui/battle/flag_" .. heroBaseInfo.legionType .. ".png")
            end
        end
    end
    -- 剩下的没有位置的武将找空位站
    local posIndex = 1
    for i = 1, 7 do
        local heroObj = RoleData:getRoleByPos(i)
        if heroObj and heroObj:getId() > 0 then
            if slotMap[i] == nil then
                while posIndex < 9 do
                    if aniMap[posIndex] == nil then
                        break
                    else
                        posIndex = posIndex + 1
                    end
                end
                local heroBaseInfo = GameData:getConfData("hero")[heroObj:getId()]
                local ani = GlobalApi:createAniByName(heroObj:getUrl(), nil, heroObj:getChangeEquipState())
                bg_img:addChild(ani)
                ani:getAnimation():play("idle", -1, -1)
                ani:setScale(-heroBaseInfo.scale/100, heroBaseInfo.scale/100)
                aniMap[posIndex] = {}
                aniMap[posIndex].hero = ani
                aniMap[posIndex].legionType = heroBaseInfo.legionType
                aniMap[posIndex].slot = i
                ani:setPosition(cc.p(LEGION_POS[posIndex]))
                slotMap[i] = 1
                team[tostring(i)] = posIndex
                armyflags[posIndex]:setVisible(true)
                armyflags[posIndex]:loadTexture("uires/ui/battle/flag_" .. heroBaseInfo.legionType .. ".png")
                posIndex = posIndex + 1
            end
        end
    end
end

function EmbattleUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.EMBATTLE)
end

return EmbattleUI