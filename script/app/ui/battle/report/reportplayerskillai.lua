local BattleHelper = require("script/app/ui/battle/battlehelper")
local PlayerSkillAI = require("script/app/ui/battle/playerskill/playerskillai")
local ClassReportBuff = require("script/app/ui/battle/report/reportbuff")

local ReportPlayerSkillAI = {}

function ReportPlayerSkillAI:playSkillAnimation(guid, targetOrPos, skill, skillConf, battleField, size, index)
    self["playAnimation" .. skillConf.id+1](guid, targetOrPos, skill, skillConf, battleField, size, index)
end

function ReportPlayerSkillAI.playAnimation2(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = 1,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                waitTime = actionInfo.keyframe/60,
                                func = function ()
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

function ReportPlayerSkillAI.playAnimation3(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 400)/1000
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 400 - aniPos.x)/1000
    end
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                waitTime = actionInfo.keyframe/60,
                                func = function ()
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

function ReportPlayerSkillAI.playAnimation4(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
    end
    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = actionInfo["fly"].totalframe/60,
                func = function ()
                    if guid == 1 then
                        skill:useSkill(cc.p(aniPos.x + size.width + 400, pos.y))
                        skill:effect(cc.p(aniPos.x + 200, pos.y))
                    else
                        skill:useSkill(cc.p(aniPos.x - size.width - 400, pos.y))
                        skill:effect(cc.p(aniPos.x - 200, pos.y))
                    end
                end
            }
        }
    }
    battleField:runAction(act)
end

function ReportPlayerSkillAI.playAnimation5(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 400)/1000
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 400 - aniPos.x)/1000
    end
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                -- waitTime = actionInfo.keyframe/60,
                                waitTime = actionInfo.totalframe/60,
                                func = function ()
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

function ReportPlayerSkillAI.playAnimation6(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 400)/1000
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 400 - aniPos.x)/1000
    end
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                waitTime = actionInfo.keyframe/60,
                                func = function ()
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

-- 崩龙的动画
function ReportPlayerSkillAI.playAnimation7(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 200)/800
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 200 - aniPos.x)/800
    end
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                waitTime = actionInfo.keyframe/60,
                                func = function ()
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

-- 迅龙的动画
function ReportPlayerSkillAI.playAnimation8(guid, effectInfo, skill, skillConf, battleField, size, index)
    local target = effectInfo.target
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 200)/1000
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 200 - aniPos.x)/1000
    end
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    if not battleField:isBattleEnd() then
                        skill:useSkill(pos)
                        local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                        local act2 = {
                            index = 1,
                            actions = {
                                {
                                    name = "callback",
                                    waitTime = actionInfo.keyframe/60,
                                    func = function ()
                                        skill:effect()
                                    end
                                }
                            }
                        }
                        battleField:runAction(act2)
                        local act3 = {
                            index = 1,
                            actions = {
                                {
                                    name = "callback",
                                    waitTime = actionInfo.totalframe/60 - 0.2,
                                    func = function ()
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
                                    end
                                }
                            }
                        }
                        battleField:runAction(act3)
                    end
                end
            }
        }
    }
    battleField:runAction(act)
end

-- 苍龙的动画
function ReportPlayerSkillAI.playAnimation9(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
    end
    skill:useSkill(pos)
    local actionInfo = battleField:getDragonActionInfo(skillConf.res2)["attack"]
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = actionInfo.keyframe/60,
                func = function ()
                    skill:effect()
                end
            }
        }
    }
    battleField:runAction(act)
end

-- 轰龙的动画
function ReportPlayerSkillAI.playAnimation10(guid, effectInfo, skill, skillConf, battleField, size, index)
    local pos = effectInfo.pos
    battleField:recordUsePlayerSkill(guid, index, pos)
    if guid == 1 then
        skill:useSkill(cc.p(size.width + 250, pos.y))
        skill:effect(cc.p(-250, pos.y))
    else
        skill:useSkill(cc.p(-250, pos.y))
        skill:effect(cc.p(size.width + 250, pos.y))
    end
end

-- 暴龙的动画
function ReportPlayerSkillAI.playAnimation11(guid, effectInfo, skill, skillConf, battleField, size, index)
    local target = effectInfo.target
    local pos = cc.p(target:getPosition())
    battleField:recordUsePlayerSkill(guid, index, pos)
    local aniPos
    local t
    if guid == 1 then
        aniPos = cc.p(pos.x + skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (aniPos.x + 200)/500
    else
        aniPos = cc.p(pos.x - skillConf.offsetX, pos.y + skillConf.offsetY)
        t = (size.width + 200 - aniPos.x)/500
    end
    ClassReportBuff.new(10000, target, skill.owner) -- 先给目标加个晕眩buff
    local act = {
        index = 1,
        actions = {
            {
                name = "callback",
                waitTime = t,
                func = function ()
                    skill:useSkill(pos)
                    local actionInfo = battleField:getDragonActionInfo(skillConf.res, "animation_littlelossy/" .. skillConf.res .. "/" .. skillConf.res .. ".json")["attack"]
                    local act2 = {
                        index = 1,
                        actions = {
                            {
                                name = "callback",
                                waitTime = actionInfo.keyframe/60,
                                func = function ()
                                    target:removeBuffById(10000)
                                    skill.targets = {target}
                                    skill:effect()
                                end
                            }
                        }
                    }
                    battleField:runAction(act2)
                end
            }
        }
    }
    battleField:runAction(act)
end

return ReportPlayerSkillAI