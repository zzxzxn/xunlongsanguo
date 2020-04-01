local BattleHelper = require("script/app/ui/battle/battlehelper")

local BattleHero = {}

function BattleHero:initAttribute(soldier)
	local data = soldier.legionObj.heroInfo
	soldier.heroId = data.heroId
	soldier.professionType = data.professionType   	-- 职业类型
	soldier.attackType = data.attackType 				-- 射程类型
	soldier.baseAttackRange = data.attackRange 		-- 射程距离
	soldier.attackRange = data.attackRange 			-- 射程距离
	soldier.bodySize = data.bodySize					-- 体型大小
	soldier.baseAttackSpeed = data.baseAttackSpeed/1000 -- 攻击速度(基础)
	soldier.attackSpeed = data.attackSpeed/1000 		-- 攻击速度
	soldier.minAttackSpeed = soldier.baseAttackSpeed*0.2 -- 攻击间隔加个最小限制
	soldier.moveSpeed = data.moveSpeed  				-- 移动速度
	soldier.baseMoveSpeed = data.moveSpeed				-- 基础移动速度
	soldier.baseHp = data.baseHp						-- 血量(基础)
	soldier.maxHp = data.maxHp							-- 最大血量
	soldier.hp = data.hp 								-- 当前血量
	soldier.maxMp = data.baseHp						-- 最大怒气
	soldier.mp = soldier.maxMp*data.mp/100 				-- 怒气
	soldier.baseAtk = data.baseAtk 					-- 攻击(基础)
	soldier.atk = data.atk								-- 攻击
	soldier.basePhyDef = data.basePhyDef 				-- 物理防御(基础)
	soldier.phyDef = data.phyDef 						-- 物理防御
	soldier.baseMagDef = data.baseMagDef 				-- 魔法抗性(基础)
	soldier.magDef = data.magDef 						-- 魔法抗性
	soldier.baseHit = data.baseHit 					-- 命中(基础)
	soldier.hit = data.hit 							-- 命中
	soldier.baseDodge = data.baseDodge					-- 闪避值(基础)
	soldier.dodge = data.dodge 						-- 闪避值
	soldier.baseCrit = data.baseCrit					-- 暴击值(基础)
	soldier.crit = data.crit							-- 暴击值
	soldier.critCoefficient = BattleHelper.CONST.CRIT_DAMAGE_COEFFICIENT + data.critCoefficient/100
	soldier.baseResi = data.baseResi 					-- 韧性(基础)
	soldier.resi = data.resi 							-- 韧性
	soldier.attPercent = data.attPercent/100			-- 造成伤害百分比修改
	soldier.defPercent = data.defPercent/100			-- 承受伤害百分比修改
	soldier.pvpAttPercent = data.pvpAttPercent/100		-- PVP造成伤害百分比修改
	soldier.pvpDefPercent = data.pvpDefPercent/100		-- PVP承受伤害百分比修改
	soldier.ignoreDef = data.ignoreDef					-- 无视防御
	soldier.cureIncrease = data.cureIncrease/100			-- 治疗加成
	soldier.recoverMp = data.recoverMp/100					-- 回怒
	soldier.reboundDmg = 0 							-- 反弹伤害百分比
	soldier.suckBlood = 0 								-- 攻击吸血固定值
	soldier.suckBloodPercent = 0						-- 攻击吸血百分比
	soldier.ignorePhy = 0 								-- 物理免疫
	soldier.ignoreMag = 0 								-- 魔法免疫
	soldier.ignoreControl = 0							-- 免疫控制技能
	soldier.invincibleOnce = false						-- 无敌一次伤害
	soldier.limitMove = 0								
	soldier.limitAtt = 0
	soldier.limitSkill = 0
	soldier.promote = data.promote
	soldier.changeEquipObj = data.changeEquipObj
	soldier.skillGroupId = data.skillGroupId
	soldier.skillLevel = data.skillLevel
	soldier.url = data.url
	soldier.urlType = 2
	soldier.scale = data.scale
	soldier.hpBarHeight = data.hpBarHeight
	soldier.attPx_t = data.attPx_t
	soldier.attPy_t = data.attPy_t
	soldier.attPx_c = data.attPx_c
	soldier.attPy_c = data.attPy_c
	soldier.attPx_b = data.attPx_b
	soldier.attPy_b = data.attPy_b
	soldier.hitScale = data.hitScale
	soldier.buffScale = data.buffScale
	soldier.deadEffect = data.deadEffect
	soldier.camp = data.camp
	if data.talentSkill then
		soldier.talentSkill = data.talentSkill:clone()
		soldier.talentSkill:setOwner(soldier)
	end
end

function BattleHero:prepare(soldier)
	local lockLegion = soldier.legionObj.lockLegion
	local lockTarget
	if lockLegion.heroObj and not lockLegion.heroObj:isDead() then
		lockTarget = lockLegion.heroObj
	end
	soldier:onLock(lockTarget, false)
end

-- 当前可用的技能
function BattleHero:getAvailableSkill(soldier)
	if soldier.limitSkill > 0 then -- 如果禁止放技能就放普攻
		return soldier.baseSkill
	end
	if soldier.angerSkill and soldier.mp >= soldier.maxMp then -- 优先判断怒气技能
		return soldier.angerSkill
	end
	if soldier.autoSkills and soldier.baseSkill:getUsedTimes() >= soldier.autoSkillTimes then
		soldier.skillLoopOver = true
		return soldier.autoSkills
	else
		return soldier.baseSkill
	end
end

-- 战斗过程中寻找并锁定目标
function BattleHero:searchTarget(soldier, forceFlag, moveFlag)
	local lockLegion = soldier.legionObj.lockLegion
	if lockLegion then
		local lockTarget = nil
		if lockLegion.heroObj:isDead() then -- 如果英雄死亡,选择攻击人数最少的士兵
			local lockNum = -1
			for i, v in ipairs(lockLegion.soldierObjs) do
				if not v:isDead() then
					local lockNum_ = #v.beLockedEnemyArr
					if lockNum == -1 or lockNum_ < lockNum then
						lockTarget = v
						lockNum = lockNum_
					end
				end
			end
			-- 每个没有士兵，选择召唤物
			if lockTarget == nil then
				lockNum = -1
				for i, summon in ipairs(lockLegion.summonObjs) do
					if not summon:isDead() then
						local lockNum_ = #summon.beLockedEnemyArr
						if lockNum == -1 or lockNum_ < lockNum then
							lockTarget = summon
							lockNum = lockNum_
						end
					end
				end
			end
		else
			lockTarget = lockLegion.heroObj
		end
		soldier:onLock(lockTarget, moveFlag)
	end
end

return BattleHero