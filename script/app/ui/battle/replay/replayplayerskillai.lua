local BattleHelper = require("script/app/ui/battle/battlehelper")

local PlayerSkillAI = {}

function PlayerSkillAI:playSkillAnimation(guid, targetOrPos, skill, skillConf, battleField, size, changeEquipObj)
    self["playAnimation" .. skillConf.id+1](guid, targetOrPos, skill, skillConf, battleField, size, changeEquipObj)
end

function PlayerSkillAI.playAnimation2(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
    end)))
end

function PlayerSkillAI.playAnimation3(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
    end)))
end

function PlayerSkillAI.playAnimation4(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
                targetPosX = size.width + 200
            else
                effectAni:setScaleX(-1)
                effectAni:setPosition(cc.p(aniPos.x - 200, pos.y))
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

function PlayerSkillAI.playAnimation5(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
        ani2:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:removeFromParent()
            end
        end)
        ani:getAnimation():setFrameEventCallFunc(function (bone, frameEventName, originFrameIndex, currentFrameIndex)
            if frameEventName == "-1" then
                local baobao = BattleHelper:createAniByName(skillConf.res3)
                local targetPosX
                local time2
                if guid == 1 then
                    targetPosX = size.width + 200
                    time2 = (targetPosX - aniPos.x)/500
                else
                    baobao:setScaleX(-1)
                    targetPosX = -200
                    time2 = (aniPos.x + 200)/500
                end
                baobao:setPosition(cc.p(aniPos.x, aniPos.y))
                battleField.bgImg:addChild(baobao)
                BattleHelper:setZorder(baobao, aniPos.y, 3)
                baobao:getAnimation():play("attack", -1, -1)
                baobao:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
                    if movementType == 1 then
                        baobao:getAnimation():play("run", -1, -1)
                        baobao:runAction(cc.Sequence:create(cc.MoveTo:create(time2, cc.p(targetPosX, aniPos.y)), cc.CallFunc:create(function ()
                            baobao:removeFromParent()
                        end)))
                    end
                end)
            end
        end)
    end)))
end

-- 岚龙的动画
function PlayerSkillAI.playAnimation6(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
        ani:getAnimation():play("attack", -1, -1)
        ani2:getAnimation():playWithIndex(0, -1, 0)
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
    end)))
end

-- 崩龙的动画
function PlayerSkillAI.playAnimation7(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
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
        end)
    end)))
end

-- 迅龙的动画
function PlayerSkillAI.playAnimation8(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
            ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
                if movementType == 1 then
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
function PlayerSkillAI.playAnimation9(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
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
    ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            ani:removeFromParent()
        end
    end)
end

-- 轰龙的动画
function PlayerSkillAI.playAnimation10(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
    local offsetX = {-250, -150, -250}
    local offsetY = {50, 0, -50}
    local moveSpeed = GameData:getConfData("bullet")[skill.baseInfo.bulletId].speed
    local time = (size.width + 500)/moveSpeed
    local targetPosX
    if guid == 1 then
        targetPosX = size.width + 500
    else
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
function PlayerSkillAI.playAnimation11(guid, pos, skill, skillConf, battleField, size, changeEquipObj)
    local ani = BattleHelper:createLittleLossyAniByName(skillConf.res, nil, changeEquipObj)
    battleField.bgImg:addChild(ani)
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
    ani:runAction(cc.Sequence:create(cc.MoveTo:create(time, aniPos), cc.CallFunc:create(function ()
        ani:getAnimation():play("attack", -1, 0)
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:getAnimation():play("run", -1, 1)
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
        end)
    end)))
end

return PlayerSkillAI