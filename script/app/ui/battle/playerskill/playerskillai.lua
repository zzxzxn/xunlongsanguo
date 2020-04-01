local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleBuff = require("script/app/ui/battle/skill/battlebuff")

local PlayerSkillAI = {}

local LEGION_POS = BattleHelper.ENUM.LEGION_POS

local BATTLE_AREAS = {
    cc.rect(0, 0, 1800, 300),
    cc.rect(0, 300, 1800, 140),
    cc.rect(0, 440, 1800, 380),
}

function PlayerSkillAI:useSkillWithoutPos(id, guid, armyArr, size)
    return self["searchTarget" .. id](guid, armyArr, size)
end

function PlayerSkillAI:useSkillWithPos(id, guid, armyArr, size, pos)
    return self["searchTargetWithPos" .. id](guid, armyArr, size, pos)
end


function PlayerSkillAI:playSkillAnimation(guid, targetOrPos, skill, skillConf, battleField, size, changeEquipObj)
    self["playAnimation" .. skillConf.id+1](guid, targetOrPos, skill, skillConf, battleField, size, changeEquipObj)
end

-- 冰龙
-- 一定范围的敌军单位受到伤害,战场三等分来搜索人数最多的区域
function PlayerSkillAI.searchTarget1(guid, armyArr, size)
    local legionArr = armyArr[3-guid]
    local armys = {{},{},{}}
    local function getRectIndex(obj)
        local index = 1
        local x, y = obj:getPosition()
        for i = 1, 3 do
            if cc.rectContainsPoint(BATTLE_AREAS[i], cc.p(x, y)) then
                index = i
                break
            end
        end
        return index
    end
    local rectIndex
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local hero = legion.heroObj
            if not hero:isDead() then
                rectIndex = getRectIndex(hero)
                table.insert(armys[rectIndex], hero)
            end
            for k2, soldier in ipairs(legion.soldierObjs) do
                if not soldier:isDead() then
                    rectIndex = getRectIndex(soldier)
                    table.insert(armys[rectIndex], soldier)
                end
            end
            for k3, summon in ipairs(legion.summonObjs) do
                if not summon:isDead() then
                    rectIndex = getRectIndex(summon)
                    table.insert(armys[rectIndex], summon)
                end
            end
        end
    end
    local maxNum = 0
    local maxNumIndex = 1
    for i = 1, 3 do
        local num = #armys[i]
        if maxNum < num then
            maxNum = num
            maxNumIndex = i
        end
    end
    local soldier
    if guid == 1 then
        local leftX = size.width
        for k, v in ipairs(armys[maxNumIndex]) do
            local x = v:getPositionX()
            if leftX > x then
                soldier = v
                leftX = x
            end
        end
    else
        local leftX = 0
        for k, v in ipairs(armys[maxNumIndex]) do
            local x = v:getPositionX()
            if leftX < x then
                soldier = v
                leftX = x
            end
        end
    end
    local effectInfo
    if soldier then
        effectInfo = {
            target = soldier,
            pos = cc.p(soldier:getPosition())
        }
    end
    return effectInfo
end

-- 迅龙
-- 选择己方士兵数最少的军团的leader
function PlayerSkillAI.searchTarget2(guid, armyArr, size)
    local legionArr = armyArr[guid]
    local effectInfo
    local leaders = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local obj = {
                soldierNum = legion.soldierNum,
                leader = legion.leaderObj
            }
            table.insert(leaders, obj)
        end
    end
    if #leaders == 1 then
        effectInfo = {
            target = leaders[1].leader,
            pos = cc.p(leaders[1].leader:getPosition())
        }
    elseif #leaders > 1 then
        table.sort(leaders, function (a, b)
            return a.soldierNum < b.soldierNum
        end)
        effectInfo = {
            target = leaders[1].leader,
            pos = cc.p(leaders[1].leader:getPosition())
        }
    end
    return effectInfo
end

-- 祖龙, 岚龙
-- 优先选择血量比例最少的武将
-- 若所有武将都阵亡，则随机选择一个小兵释放
function PlayerSkillAI.searchTarget3(guid, armyArr, size)
    local legionArr = armyArr[guid]
    local effectInfo
    local heroArr = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            if not legion.heroObj:isDead() then
                local obj = {
                    num = #legion.beLockedLegionArr,
                    hp = legion.heroObj.hp/legion.heroObj.maxHp,
                    hero = legion.heroObj
                }
                table.insert(heroArr, obj)
            end
        end
    end
    if #heroArr == 1 then
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        } 
    elseif #heroArr > 1 then
        table.sort(heroArr, function (a, b)
            if a.num > 0 and b.num <= 0 then
                return true
            elseif a.num <= 0 and b.num > 0 then
                return false
            else
                return a.hp < b.hp
            end
        end)
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        } 
    else
        local arr = {}
        for k, legion in ipairs(legionArr) do
            if not legion:isDead() then
                for k2, soldier in ipairs(legion.soldierObjs) do
                    if not soldier:isDead() then
                        table.insert(arr, soldier)
                    end
                end
                for k3, summon in ipairs(legion.summonObjs) do
                    if not summon:isDead() then
                        table.insert(arr, summon)
                    end
                end
            end
        end
        local num2 = #arr
        if num2 > 0 then
            local soldier = arr[BattleHelper:random(1, num2+1)]
            effectInfo = {
                target = soldier,
                pos = cc.p(soldier:getPosition())
            }
        end
    end
    return effectInfo
end

-- 苍龙
-- 选择敌方血量最少的武将，若武将全部阵亡，则选择血量最少的小兵
function PlayerSkillAI.searchTarget5(guid, armyArr, size)
    local legionArr = armyArr[3-guid]
    local effectInfo
    local hero
    local minHp
    for k, v in ipairs(legionArr) do
        if not v:isDead() then
            local heroObj = v.heroObj
            if not heroObj:isDead() then
                if minHp == nil then
                    minHp = heroObj.hp
                    hero = heroObj
                elseif minHp > heroObj.hp then
                    minHp = heroObj.hp
                    hero = heroObj
                end
            end
        end
    end
    if hero == nil then
        for k, v in ipairs(legionArr) do
            if not v:isDead() then
                for k2, v2 in ipairs(v.soldierObjs) do
                    if not v2:isDead() then
                        if minHp == nil then
                            minHp = v2.hp
                            hero = v2
                        elseif minHp > v2.hp then
                            minHp = v2.hp
                            hero = v2
                        end
                    end
                end
                for k2, v2 in ipairs(v.summonObjs) do
                    if not v2:isDead() then
                        if minHp == nil then
                            minHp = v2.hp
                            hero = v2
                        elseif minHp > v2.hp then
                            minHp = v2.hp
                            hero = v2
                        end
                    end
                end
            end
        end
        if hero then
            effectInfo = {
                target = hero,
                pos = cc.p(hero:getPosition())
            }
        end
    else
        effectInfo = {
            target = hero,
            pos = cc.p(hero:getPosition())
        }
    end
    return effectInfo
end

-- 雷龙
-- 将战场上中下三等分，优先选择中间区域内的武将释放
-- 若中间区域内有多个武将，则优先选择靠左边的武将释放
-- 若中间区域内没有武将，则随机选择其它武将释放
function PlayerSkillAI.searchTarget6(guid, armyArr, size)
    local legionArr = armyArr[3-guid]
    local leftArr = {}
    local rect = BATTLE_AREAS[2]
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local heroObj = legion.heroObj
            if not heroObj:isDead() then
                local x, y = heroObj:getPosition()
                if cc.rectContainsPoint(rect, cc.p(x, y)) then
                    table.insert(leftArr, heroObj)
                end
            end
        end
    end
    local hero
    if #leftArr > 0 then
        if guid == 1 then
            local leftX = size.width
            for k, v in ipairs(leftArr) do
                local x = v:getPositionX()
                if leftX > x then
                    hero = v
                    leftX = x
                end
            end
        else
            local rightX = 0
            for k, v in ipairs(leftArr) do
                local x = v:getPositionX()
                if rightX < x then
                    hero = v
                    rightX = x
                end
            end
        end
    else
        for k, legion in ipairs(legionArr) do
            if not legion:isDead() then
                if not legion.heroObj:isDead() then
                    hero = legion.heroObj
                    break
                end
            end
        end
    end
    if hero == nil then
        for k, legion in ipairs(legionArr) do
            if hero then
                break
            end
            if not legion:isDead() then
                for k2, soldier in ipairs(legion.soldierObjs) do
                    if not soldier:isDead() then
                        hero = soldier
                        break
                    end
                end
                if hero == nil then
                    for k2, summon in ipairs(legion.summonObjs) do
                        if not summon:isDead() then
                            hero = summon
                            break
                        end
                    end
                end
            end
        end
    end
    local effectInfo
    if hero then
        effectInfo = {
            target = hero,
            pos = cc.p(hero:getPosition())
        }
    end
    return effectInfo
end

-- 火龙,轰龙
-- 将战场上中下三等分，计算三块区域内敌方武将数量，选择武将数量最多的区域，
-- 选择最靠近左边的武将释放
-- 如果出现两个区域内武将数量相等，则任意选择一个区域
function PlayerSkillAI.searchTarget7(guid, armyArr, size)
    local legionArr = armyArr[3-guid]
    local armys = {{},{},{}}
    local function getRectIndex(obj)
        local index = 1
        local x, y = obj:getPosition()
        for i = 1, 3 do
            if cc.rectContainsPoint(BATTLE_AREAS[i], cc.p(x, y)) then
                index = i
                break
            end
        end
        return index
    end
    local rectIndex
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local heroObj = legion.heroObj
            if not heroObj:isDead() then
                rectIndex = getRectIndex(heroObj)
                table.insert(armys[rectIndex], heroObj)
            end
        end
    end
    local maxNum = 0
    local maxNumIndex = 0
    for i = 1, 3 do
        local num = #armys[i]
        if maxNum < num then
            maxNum = num
            maxNumIndex = i
        end
    end
    local hero
    if maxNumIndex == 0 then
        for k, legion in ipairs(legionArr) do
            if hero then
                break
            end
            if not legion:isDead() then
                for k2, soldier in ipairs(legion.soldierObjs) do
                    if not soldier:isDead() then
                        hero = soldier
                        break
                    end
                end
                if hero == nil then
                    for k2, summon in ipairs(legion.summonObjs) do
                        if not summon:isDead() then
                            hero = summon
                            break
                        end
                    end
                end
            end
        end
    else
        if guid == 1 then
            local leftX = size.width
            for k, v in ipairs(armys[maxNumIndex]) do
                local x = v:getPositionX()
                if leftX > x then
                    hero = v
                    leftX = x
                end
            end
        else
            local rightX = 0
            for k, v in ipairs(armys[maxNumIndex]) do
                local x = v:getPositionX()
                if rightX < x then
                    hero = v
                    rightX = x
                end
            end
        end
    end
    local effectInfo
    if hero then
        effectInfo = {
            target = hero,
            pos = cc.p(hero:getPosition())
        }
    end
    return effectInfo
end

-- 暴龙
-- 选择敌方输出伤害排名最高的武将
-- 若有排名相同，则随机选择
-- 若敌方武将全部阵亡，则随机选择一个小兵释放
-- 目标不能是魔免状态
function PlayerSkillAI.searchTarget9(guid, armyArr, size)
    local legionArr = armyArr[3-guid]
    local effectInfo
    local heroArr = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            if not legion.heroObj:isDead() and legion.heroObj.ignoreMag <= 0 then
                local obj = {
                    hero = legion.heroObj,
                    num = legion.heroObj.damageCount[2]
                }
                table.insert(heroArr, obj)
            end
        end
    end
    local heroNum = #heroArr
    if heroNum == 1 then
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        }
    elseif heroNum > 1 then
        table.sort(heroArr, function (a, b)
            return a.num > b.num
        end)
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        }
    else
        local arr = {}
        for k, legion in ipairs(legionArr) do
            if not legion:isDead() then
                for k2, soldier in ipairs(legion.soldierObjs) do
                    if not soldier:isDead() and soldier.ignoreMag <= 0 then
                        table.insert(arr, soldier)
                    end
                end
                for k3, summon in ipairs(legion.summonObjs) do
                    if not summon:isDead() and summon.ignoreMag <= 0 then
                        table.insert(arr, summon)
                    end
                end
            end
        end
        local num2 = #arr
        if num2 > 0 then
            local soldier = arr[BattleHelper:random(1, num2+1)]
            effectInfo = {
                target = soldier,
                pos = cc.p(soldier:getPosition())
            }
        end
    end
    return effectInfo
end

-- 崩龙
-- 选择乙方被攻击的军团数最多的军团的目标军团, 如果没有就选择他自己
function PlayerSkillAI.searchTarget10(guid, armyArr, size)
    local legionArr = armyArr[guid]
    local effectInfo
    local newLegionArr = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local obj = {
                num = #legion.beLockedLegionArr,
                legion = legion
            }
            table.insert(newLegionArr, obj)
        end
    end
    if #newLegionArr == 1 then
        local targetLegion = newLegionArr[1].legion
        if targetLegion.lockLegion and not targetLegion.lockLegion:isDead() then
            effectInfo = {
                target = targetLegion.lockLegion.leaderObj,
                pos = cc.p(targetLegion.lockLegion.leaderObj:getPosition())
            }
        else
            effectInfo = {
                target = targetLegion.leaderObj,
                pos = cc.p(targetLegion.leaderObj:getPosition())
            }
        end
    elseif #newLegionArr > 1 then
        table.sort(newLegionArr, function (a, b)
            return a.num > b.num
        end)
        local targetLegion = newLegionArr[1].legion
        if targetLegion.lockLegion and not targetLegion.lockLegion:isDead() then
            effectInfo = {
                target = targetLegion.lockLegion.leaderObj,
                pos = cc.p(targetLegion.lockLegion.leaderObj:getPosition())
            }
        else
            effectInfo = {
                target = targetLegion.leaderObj.leaderObj,
                pos = cc.p(targetLegion.leaderObj:getPosition())
            }
        end
    end
    return effectInfo
end

-- 迅龙
-- 选择距离目标点最近的leader
function PlayerSkillAI.searchTargetWithPos1(guid, armyArr, size, pos)
    local legionArr = armyArr[guid]
    local effectInfo
    local leaders = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            local posx, posy = legion.leaderObj:getPosition()
            local obj = {
                leader = legion.leaderObj,
                dis = math.pow(posx - pos.x, 2) + math.pow(posy - pos.y, 2)
            }
            table.insert(leaders, obj)
    end
    end
    if #leaders == 1 then
        effectInfo = {
            target = leaders[1].leader,
            pos = pos
        }
    elseif #leaders > 1 then
        table.sort(leaders, function (a, b)
            return a.dis < b.dis
        end)
        effectInfo = {
            target = leaders[1].leader,
            pos = pos
        }
    end
    return effectInfo
end

-- 暴龙
-- 选择距离目标点最近的武将
-- 若敌方武将全部阵亡，则选择最近的一个小兵释放
-- 目标不能是魔免状态
function PlayerSkillAI.searchTargetWithPos2(guid, armyArr, size, pos)
    local legionArr = armyArr[3-guid]
    local effectInfo
    local heroArr = {}
    for k, legion in ipairs(legionArr) do
        if not legion:isDead() then
            if not legion.heroObj:isDead() and legion.heroObj.ignoreMag <= 0 then
                local posx, posy = legion.heroObj:getPosition()
                local obj = {
                    hero = legion.heroObj,
                    dis = math.pow(posx - pos.x, 2) + math.pow(posy - pos.y, 2)
                }
                table.insert(heroArr, obj)
            end
        end
    end
    local heroNum = #heroArr
    if heroNum == 1 then
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        }
    elseif heroNum > 1 then
        table.sort(heroArr, function (a, b)
            return a.dis < b.dis
        end)
        effectInfo = {
            target = heroArr[1].hero,
            pos = cc.p(heroArr[1].hero:getPosition())
        }
    else
        local arr = {}
        for k, legion in ipairs(legionArr) do
            if not legion:isDead() then
                for k2, soldier in ipairs(legion.soldierObjs) do
                    if not soldier:isDead() and soldier.ignoreMag <= 0 then
                        local posx, posy = soldier:getPosition()
                        local obj = {
                            soldier = soldier,
                            dis = math.pow(posx - pos.x, 2) + math.pow(posy - pos.y, 2)
                        }
                        table.insert(arr, obj)
                    end
                end
                for k3, summon in ipairs(legion.summonObjs) do
                    if not summon:isDead() and summon.ignoreMag <= 0 then
                        local posx, posy = summon:getPosition()
                        local obj = {
                            soldier = summon,
                            dis = math.pow(posx - pos.x, 2) + math.pow(posy - pos.y, 2)
                        }
                        table.insert(arr, obj)
                    end
                end
            end
        end
        local num2 = #arr
        if num2 > 0 then
            table.sort(arr, function (a, b)
                return a.dis < b.dis
            end)
            effectInfo = {
                target = arr[1].soldier,
                pos = cc.p(arr[1].soldier:getPosition())
            }
        end
    end
    return effectInfo
end

-- 火龙的动画
function PlayerSkillAI.playAnimation2(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    local dragonOffsetX = -400
    local dragonOffsetY = 400
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    -- 特效
    local effectAni = BattleHelper:createAniByName(skillConf.res2)
    effectAni:setVisible(false)
    -- 影子
    local shadow = cc.Sprite:create("uires/ui/battle/shadow.png")
    battleField.bgImg:addChild(ani)
    battleField.bgImg:addChild(effectAni)
    battleField.bgImg:addChild(shadow)
    shadow:setLocalZOrder(1)
    local aniPos
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(aniPos.x + dragonOffsetX, aniPos.y + dragonOffsetY))
        effectAni:setPosition(cc.p(aniPos.x, aniPos.y))
        shadow:setPosition(cc.p(aniPos.x + dragonOffsetX, aniPos.y))
    else
        ani:setScaleX(-1)
        effectAni:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(aniPos.x - dragonOffsetX, aniPos.y + dragonOffsetY))
        effectAni:setPosition(cc.p(aniPos.x, aniPos.y))
        shadow:setPosition(cc.p(aniPos.x - dragonOffsetX, aniPos.y))
    end
    BattleHelper:setZorder(ani, aniPos.y, 3)
    BattleHelper:setZorder(effectAni, aniPos.y, 2)
    ani:getAnimation():play("fly", -1, 1)
    ani:runAction(cc.Sequence:create(cc.DelayTime:create(0.25), cc.CallFunc:create(function ()
        BattleHelper:playSound("media/effect/playerskill_huolong_act.mp3", false)  -- 播放动作音效
    end)))
    shadow:runAction(cc.Spawn:create(cc.MoveTo:create(1, cc.p(aniPos.x, aniPos.y)), cc.ScaleTo:create(1, 3)))
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(aniPos.x, aniPos.y)), cc.CallFunc:create(function ()
        effectAni:setVisible(true)
        effectAni:getAnimation():play("attack", -1, -1)
        ani:getAnimation():play("attack", -1, -1)
        skill:useSkill(pos)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                effectAni:removeFromParent()
                ani:getAnimation():play("fly", -1, 1)
                local targetPosX
                if guid == 1 then
                    targetPosX = size.width + 400
                else
                    targetPosX = -400
                end
                local time = math.abs((targetPosX - aniPos.x)/1500)
                shadow:runAction(cc.Spawn:create(cc.MoveTo:create(time, cc.p(targetPosX, aniPos.y)), cc.ScaleTo:create(1, 1)))
                ani:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(targetPosX, aniPos.y + size.height + 200)), cc.CallFunc:create(function ()
                    ani:removeFromParent()
                    shadow:removeFromParent()
                end)))
            end
        end)
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                skill:effect()
            end
        end)
    end)))
end

-- 祖龙的动画
function PlayerSkillAI.playAnimation3(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-400, aniPos.y))
        t = (aniPos.x + 400)/1000
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 400, aniPos.y))
        t = (size.width + 400 - aniPos.x)/1000
    end
    BattleHelper:setZorder(ani, aniPos.y, 2)
    ani:getAnimation():play("fly", -1, -1)
    BattleHelper:playSound("media/effect/playerskill_zulong_act.mp3", false)  -- 播放动作音效
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(t, aniPos), cc.CallFunc:create(function ()
        ani:getAnimation():play("attack", -1, -1)
        skill:useSkill(pos)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:getAnimation():play("fly", -1, 1)
                local t2
                local targetPosX
                if guid == 1 then
                    targetPosX = size.width + 400
                    t2 = (targetPosX - aniPos.x)/1000
                else
                    targetPosX = -400
                    t2 = (aniPos.x - targetPosX)/1000
                end
                ani:runAction(cc.Sequence:create(cc.MoveTo:create(t2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                    ani:removeFromParent()
                end)))
            end
        end)
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                skill:effect()
            end
        end)
    end)))
end

-- 冰龙的动画
function PlayerSkillAI.playAnimation4(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
    end
    ani:setPosition(cc.p(aniPos.x, aniPos.y))
    BattleHelper:setZorder(ani, aniPos.y, 2)
    ani:getAnimation():play("fly", -1, -1)
    BattleHelper:playSound("media/effect/playerskill_binglong_act.mp3", false)  -- 播放动作音效
    ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            local effectAni = BattleHelper:createAniByName(skillConf.res2)
            effectAni:getAnimation():playWithIndex(0, -1, -1)
            battleField.bgImg:addChild(effectAni)
            ani:getAnimation():play("attack", -1, -1)
            local targetPosX
            if guid == 1 then
                effectAni:setPosition(cc.p(aniPos.x + 200, pos.y))
                skill:useSkill(cc.p(aniPos.x + size.width + 400, pos.y))
                skill:effect(cc.p(aniPos.x + 200, pos.y))
                targetPosX = size.width + 200
            else
                effectAni:setScaleX(-1)
                effectAni:setPosition(cc.p(aniPos.x - 200, pos.y))
                skill:useSkill(cc.p(aniPos.x - size.width - 400, pos.y))
                skill:effect(cc.p(aniPos.x - 200, pos.y))
                targetPosX = -size.width - 200
            end
            local moveSpeed = GameData:getConfData("bullet")[skill.baseInfo.bulletId].speed
            local time = (size.width + 200)/moveSpeed
            ani:runAction(cc.Sequence:create(cc.MoveBy:create(time, cc.p(targetPosX, 0)), cc.CallFunc:create(function ()
                ani:removeFromParent()
                effectAni:removeFromParent()
            end)))
        end
    end)
end

-- 雷龙的动画
function PlayerSkillAI.playAnimation5(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    local time1
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-400, aniPos.y))
        time1 = (aniPos.x + 400)/1000
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 400, aniPos.y))
        time1 = (size.width + 400 - aniPos.x)/1000
    end
    BattleHelper:setZorder(ani, aniPos.y, 3)
    ani:getAnimation():play("run", -1, -1)
    ani:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        BattleHelper:playSound("media/effect/playerskill_dianlong_act.mp3", false)  -- 播放动作音效
    end)))
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time1, aniPos), cc.CallFunc:create(function ()
        local ani2 = BattleHelper:createAniByName(skillConf.res2)
        ani2:setLocalZOrder(10000)
        ani:addChild(ani2)
        ani:getAnimation():play("attack", -1, 0)
        ani2:getAnimation():playWithIndex(0, -1, 0)
        skill:useSkill(pos)
        ani2:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                skill:effect()
                ani:removeFromParent()
            end
        end)
        -- ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
        --     if frameEventName == "-1" then
        --         local baobao = BattleHelper:createAniByName(skillConf.res3)
        --         local targetPosX
        --         local time2
        --         if guid == 1 then
        --             targetPosX = size.width + 200
        --             time2 = (targetPosX - aniPos.x)/500
        --         else
        --             baobao:setScaleX(-1)
        --             targetPosX = -200
        --             time2 = (aniPos.x + 200)/500
        --         end
        --         baobao:setPosition(cc.p(aniPos.x, aniPos.y))
        --         battleField.bgImg:addChild(baobao)
        --         BattleHelper:setZorder(baobao, aniPos.y, 3)
        --         baobao:getAnimation():play("attack", -1, -1)
        --         baobao:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        --             if movementType == 1 then
        --                 baobao:getAnimation():play("run", -1, -1)
        --                 baobao:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
        --                     baobao:removeFromParent()
        --                 end)))
        --             end
        --         end)
        --         skill:effect()
        --     end
        -- end)
    end)))
end

-- 岚龙的动画
function PlayerSkillAI.playAnimation6(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-400, aniPos.y))
        t = (aniPos.x + 400)/1000
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 400, aniPos.y))
        t = (size.width + 400 - aniPos.x)/1000
    end
    BattleHelper:setZorder(ani, aniPos.y, 2)
    ani:getAnimation():play("fly", -1, -1)
    BattleHelper:playSound("media/effect/playerskill_fly.mp3", false)  -- 播放fly音效
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(t, aniPos), cc.CallFunc:create(function ()
        local ani2 = BattleHelper:createAniByName(skillConf.res2)
        ani2:setLocalZOrder(10000)
        ani:addChild(ani2)
        ani:getAnimation():play("attack", -1, 0)
        ani2:getAnimation():playWithIndex(0, -1, 0)
        skill:useSkill(pos)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:getAnimation():play("fly", -1, 1)
                BattleHelper:playSound("media/effect/playerskill_fly.mp3", false)  -- 播放fly音效
                local t2
                local targetPosX
                if guid == 1 then
                    targetPosX = size.width + 400
                    t2 = (targetPosX - aniPos.x)/1000
                else
                    targetPosX = -400
                    t2 = (aniPos.x - targetPosX)/1000
                end
                ani:runAction(cc.Sequence:create(cc.MoveTo:create(t2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                    ani:removeFromParent()
                end)))
            end
        end)
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                skill:effect()
            end
        end)
    end)))
end

-- 崩龙的动画
function PlayerSkillAI.playAnimation7(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    -- 本体
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    local time
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-200, aniPos.y))
        time = (aniPos.x + 200)/800
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 200, aniPos.y))
        time = (size.width + 200 - aniPos.x)/800
    end
    BattleHelper:setZorder(ani, aniPos.y, 3)
    ani:getAnimation():play("run", -1, -1)
    BattleHelper:playSound("media/effect/playerskill_benglong_act.mp3", false)  -- 播放动作音效
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time, aniPos), cc.CallFunc:create(function ()
        ani:getAnimation():play("attack", -1, 0)
        skill:useSkill(pos)
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                skill:effect()
            end
        end)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                if movementID == "attack" then
                    ani:getAnimation():play("run2", -1, -1)
                    local targetPosX
                    local time2
                    if guid == 1 then
                        targetPosX = size.width + 200
                        time2 = (targetPosX - aniPos.x)/800
                    else
                        targetPosX = -200
                        time2 = (aniPos.x - targetPosX)/800
                    end
                    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                        ani:removeFromParent()
                    end)))
                end
            end
        end)
    end)))
end

-- 迅龙的动画
function PlayerSkillAI.playAnimation8(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local target = effectInfo.target
    local pos = effectInfo.pos
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local aniPos
    local time
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-200, aniPos.y))
        time = (aniPos.x + 200)/1000
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 200, aniPos.y))
        time = (size.width + 200 - aniPos.x)/1000
    end
    BattleHelper:setZorder(ani, aniPos.y, 3)
    ani:getAnimation():play("fly1", -1, -1)
    BattleHelper:playSound("media/effect/playerskill_xunlong_act.mp3", false)  -- 播放动作音效
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time, aniPos), cc.CallFunc:create(function ()
        if battleField:isBattleEnd() then
            local targetPosX
            local time2
            if guid == 1 then
                targetPosX = size.width + 200
                time2 = (targetPosX - aniPos.x)/1000
            else
                targetPosX = -200
                time2 = (aniPos.x + 200)/1000
            end
            ani:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                ani:removeFromParent()
            end)))
        else
            ani:getAnimation():play("attack", -1, 0)
            skill:useSkill(pos)
            ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
                if frameEventName == "-1" then
                    skill:effect()
                end
            end)
            ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
                if movementType == 1 then
                    if skill.baseInfo.summonId > 0 then
                        if target:isDead() then
                            if target.legionObj:isDead() then
                                local effectInfo2 = PlayerSkillAI["searchTarget" .. skillConf.searchId](guid, battleField.armyArr, size)
                                if effectInfo2 then
                                    local newTarget = effectInfo2.target
                                    if guid == 1 then
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x + 22, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x + 72, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x - 68, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x - 40, pos.y + 1))
                                    else
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x - 22, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x - 72, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x + 68, pos.y))
                                        newTarget.legionObj:addSummonObj(newTarget, skill.baseInfo.summonId, cc.p(pos.x + 40, pos.y + 1))
                                    end
                                end
                            else
                                if guid == 1 then
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x + 22, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x + 72, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x - 68, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x - 40, pos.y + 1))
                                else
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x - 22, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x - 72, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x + 68, pos.y))
                                    target.legionObj:addSummonObj(target.legionObj.leaderObj, skill.baseInfo.summonId, cc.p(pos.x + 40, pos.y + 1))
                                end
                            end
                        else
                            if guid == 1 then
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x + 22, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x + 72, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x - 68, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x - 40, pos.y + 1))
                            else
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x - 22, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x - 72, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x + 68, pos.y))
                                target.legionObj:addSummonObj(target, skill.baseInfo.summonId, cc.p(pos.x + 40, pos.y + 1))
                            end
                        end
                    end
                    local targetPosX
                    local time2
                    if guid == 1 then
                        targetPosX = size.width + 200
                        time2 = (targetPosX - aniPos.x)/1000
                    else
                        targetPosX = -200
                        time2 = (aniPos.x + 200)/1000
                    end
                    ani:getAnimation():play("fly2", -1, -1)
                    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                        ani:removeFromParent()
                    end)))
                end
            end)
        end
    end)))
end

-- 苍龙的动画
function PlayerSkillAI.playAnimation9(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    local ani = BattleHelper:createAniByName(skillConf.res2)
    battleField.bgImg:addChild(ani)
    local aniPos
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
    end
    ani:setPosition(aniPos)
    BattleHelper:setZorder(ani, aniPos.y, 2)
    ani:getAnimation():play("attack", -1, -1)
    skill:useSkill(pos)
    ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            ani:removeFromParent()
        end
    end)
    ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
        if frameEventName == "-1" then
            skill:effect()
        end
    end)
end

-- 轰龙的动画
function PlayerSkillAI.playAnimation10(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local pos = effectInfo.pos
    local offsetX = {-250, -150, -250}
    local offsetY = {50, 0, -50}
    local moveSpeed = GameData:getConfData("bullet")[skill.baseInfo.bulletId].speed
    local time = (size.width + 500)/moveSpeed
    local targetPosX
    if guid == 1 then
        skill:useSkill(cc.p(size.width + 250, pos.y))
        skill:effect(cc.p(-250, pos.y))
        targetPosX = size.width + 500
    else
        skill:useSkill(cc.p(-250, pos.y))
        skill:effect(cc.p(size.width + 250, pos.y))
        targetPosX = -size.width - 500
    end
    for i = 1, 3 do
        local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
        local ani2 = BattleHelper:createAniByName(skillConf.res2)
        ani2:setLocalZOrder(10000)
        ani:addChild(ani2)
        battleField.bgImg:addChild(ani)
        local aniPos
        local direction = 1
        if guid == 1 then
            aniPos = cc.p(skillConf.offsetX + offsetX[i], pos.y + skillConf.offsetY + offsetY[i])
        else
            direction = -1
            aniPos = cc.p(size.width - skillConf.offsetX - offsetX[i], pos.y + skillConf.offsetY + offsetY[i])
        end
        if i == 2 then
            ani:setScale(0.65*direction, 0.65)
        else
            ani:setScale(0.5*direction, 0.5)
        end
        ani:setPosition(aniPos)
        BattleHelper:setZorder(ani, aniPos.y, 3)
        ani:getAnimation():play("attack", -1, 1)
        ani2:getAnimation():playWithIndex(0, -1, 1)
        ani:runAction(cc.Sequence:create(cc.MoveBy:create(time, cc.p(targetPosX, 0)), cc.CallFunc:create(function ()
            ani:removeFromParent()
        end)))
    end
end

-- 暴龙的动画
function PlayerSkillAI.playAnimation11(guid, effectInfo, skill, skillConf, battleField, size, changeEquipObj)
    local target = effectInfo.target
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
    local pos = cc.p(target:getPosition())
    local aniPos
    local time
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(-200, aniPos.y))
        time = (aniPos.x + 200)/500
    else
        ani:setScaleX(-1)
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        ani:setPosition(cc.p(size.width + 200, aniPos.y))
        time = (size.width + 200 - aniPos.x)/500
    end
    BattleHelper:setZorder(ani, aniPos.y, 3)
    ani:getAnimation():play("run", -1, -1)
    ani:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
        BattleHelper:playSound("media/effect/playerskill_baolong_act.mp3", false)  -- 播放动作音效
    end)))
    ClassBattleBuff.new(10000, target, skill.owner) -- 先给目标加个晕眩buff
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time, aniPos), cc.CallFunc:create(function ()
        ani:getAnimation():play("attack", -1, 0)
        skill:useSkill()
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                target:removeBuffById(10000)
                skill.targets = {target}
                skill:effect()
            end
        end)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                if movementID == "attack" then
                    ani:getAnimation():play("run", -1, -1)
                    local time2
                    local targetPosX
                    if guid == 1 then
                        targetPosX = size.width + 200
                        time2 = (size.width + 200 - aniPos.x)/500
                    else
                        targetPosX = -200
                        time2 = (aniPos.x + 200)/500
                    end
                    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                        ani:removeFromParent()
                    end)))
                end
            end
        end)
    end)))
end

return PlayerSkillAI