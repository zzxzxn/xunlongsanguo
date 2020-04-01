local BattleHelper = require("script/app/ui/battle/battlehelper")

local BattleSoldier = {}

local SOLDIER_ATTACK_WAVE = {
	[1] = {8,10},
	[2] = {10,13},
	[3] = {8,13},
	[0] = {8,10}
}

function BattleSoldier:initAttribute(soldier)
	local heroObj = soldier.legionObj.heroObj
	local baseInfo = soldier.legionObj.soldierInfo
	local soldierIndex = soldier.soldierIndex
	if baseInfo.attackType == 1 then
		soldier.baseAttackRange = math.random(baseInfo.attackRange1, baseInfo.attackRange2)
	else
		soldier.baseAttackRange = math.random(baseInfo.attackRange1, baseInfo.attackRange2) + heroObj.attackRange
	end
	soldier.attackRange = soldier.baseAttackRange
	soldier.bodySize = baseInfo.bodySize
	soldier.professionType = heroObj.professionType
	soldier.attackType = baseInfo.attackType
	soldier.baseAttackSpeed = baseInfo.attackSpeed*0.001 * math.random(SOLDIER_ATTACK_WAVE[soldierIndex%4][1], SOLDIER_ATTACK_WAVE[soldierIndex%4][2])/10
	soldier.attackSpeed = soldier.baseAttackSpeed*heroObj.attackSpeed/heroObj.baseAttackSpeed
	soldier.minAttackSpeed = soldier.baseAttackSpeed*0.2
	soldier.moveSpeed = heroObj.moveSpeed + math.random(baseInfo.speedRange1, baseInfo.speedRange2)
	soldier.baseMoveSpeed = soldier.moveSpeed
	soldier.baseHp = heroObj.baseHp*baseInfo.heaPowPercent*0.01
	soldier.maxHp = heroObj.maxHp*baseInfo.heaPowPercent*0.01
	soldier.hp = heroObj.hp*baseInfo.heaPowPercent*0.01
	soldier.maxMp = 0
	soldier.mp = 0
	soldier.baseAtk = heroObj.baseAtk*baseInfo.attPowPercent*0.01
	soldier.atk = heroObj.atk*baseInfo.attPowPercent*0.01
	soldier.basePhyDef = heroObj.basePhyDef*baseInfo.phyArmPowPercent*0.01
	soldier.phyDef = heroObj.phyDef*baseInfo.phyArmPowPercent*0.01
	soldier.baseMagDef = heroObj.baseMagDef*baseInfo.magArmPowPercent*0.01
	soldier.magDef = heroObj.magDef*baseInfo.magArmPowPercent*0.01
	soldier.baseHit = heroObj.baseHit
	soldier.hit = heroObj.hit
	soldier.baseDodge = heroObj.baseDodge
	soldier.dodge = heroObj.dodge
	soldier.baseCrit = heroObj.baseCrit
	soldier.crit = heroObj.crit
	soldier.critCoefficient = heroObj.critCoefficient
	soldier.baseResi = heroObj.baseResi
	soldier.resi = heroObj.resi
	soldier.attPercent = heroObj.attPercent
	soldier.defPercent = heroObj.defPercent
	soldier.pvpAttPercent = heroObj.pvpAttPercent
	soldier.pvpDefPercent = heroObj.pvpDefPercent
	soldier.ignoreDef = 0
	soldier.cureIncrease = 0
	soldier.recoverMp = 0
	soldier.reboundDmg = 0
	soldier.suckBlood = 0
	soldier.suckBloodPercent = 0
	soldier.ignorePhy = 0
	soldier.ignoreMag = 0
	soldier.ignoreControl = 0
	soldier.invincibleOnce = false
	soldier.limitMove = 0
	soldier.limitAtt = 0
	soldier.limitSkill = 0
	soldier.promote = 0
	soldier.skillGroupId = baseInfo.skillGroupId
	soldier.skillLevel = 1
	local fix = "_g"
	if soldier.guid == 2 then
		fix = "_r"
	end
	soldier.url = soldier.legionObj.legionInfo.soldierUrl .. fix
	soldier.urlType = 2
	soldier.scale = baseInfo.scale
	soldier.hpBarHeight = baseInfo.hpBarHeight
	soldier.attPx_t = baseInfo.attPx_t
	soldier.attPy_t = baseInfo.attPy_t
	soldier.attPx_c = baseInfo.attPx_c
	soldier.attPy_c = baseInfo.attPy_c
	soldier.attPx_b = baseInfo.attPx_b
	soldier.attPy_b = baseInfo.attPy_b
	soldier.hitScale = baseInfo.hitScale
	soldier.buffScale = baseInfo.buffScale
	soldier.camp = heroObj.camp
end

function BattleSoldier:getAvailableSkill(soldier)
	-- 小兵只判断普通攻击
	return soldier.baseSkill
end

-- 战斗开始，锁定目标
function BattleSoldier:prepare(soldier)
	local lockLegion = soldier.legionObj.lockLegion
	-- 锁定目标
	local lockTarget = nil
	if lockLegion.soldierNum == 1 then -- 如果对手只有英雄没有小兵
		lockTarget = lockLegion.heroObj
	else
		local soldierNum2 = #lockLegion.soldierObjs
		local soldierIndex = soldier.soldierIndex%soldierNum2
		soldierIndex = soldierIndex == 0 and soldierNum2 or soldierIndex
		lockTarget = lockLegion.soldierObjs[soldierIndex]
	end
	soldier:onLock(lockTarget, false)
end

-- 战斗过程中寻找并锁定目标
function BattleSoldier:searchTarget(soldier, forceFlag, moveFlag)
	local lockLegion = soldier.legionObj.lockLegion
	if lockLegion then
		local lockTarget
		local lockMeTargets = {} --锁定自己的
		local otherTargets = {} --未锁定自己的
		for i, v in ipairs(lockLegion.soldierObjs) do
			if not v:isDead() then
				if v.lockEnemy == soldier then
					table.insert(lockMeTargets, v)
				else
					table.insert(otherTargets, v)
				end
			end
		end
		-- 选定被锁定次数较少的士兵
		-- 优先选择锁定自己的
		local lockNum = -1
		for i, v in ipairs(lockMeTargets) do
			local lockNum_ = #v.beLockedEnemyArr
			if lockNum == -1 or lockNum_ < lockNum then
				lockTarget = v
				lockNum = lockNum_
			end
		end

		if lockTarget == nil then
		-- 如果没有锁定自己的，锁定其他
			local lockNum = -1
			for i, v in ipairs(otherTargets) do
				local lockNum_ = #v.beLockedEnemyArr
				if lockNum == -1 or lockNum_ < lockNum then
					lockTarget = v
					lockNum = lockNum_
				end
			end
		end

		if lockTarget == nil then
		-- 如果没有士兵
			if not lockLegion.heroObj:isDead() then
			-- 选择英雄
				lockTarget = lockLegion.heroObj
			else
			-- 英雄死亡，选择召唤物
				local lockMeSummons = {} --锁定自己的
				local otherSummons = {} --未锁定自己的
				for i, summon in ipairs(lockLegion.summonObjs) do
					if not summon:isDead() then
						if summon.lockEnemy == soldier then
							table.insert(lockMeSummons, summon)
						else
							table.insert(otherSummons, summon)
						end
					end
				end
				-- 选定被锁定次数较少的召唤物
				-- 优先选择锁定自己的
				local lockNum = -1
				for i, summon in ipairs(lockMeSummons) do
					local lockNum_ = #summon.beLockedEnemyArr
					if lockNum == -1 or lockNum_ < lockNum then
						lockTarget = summon
						lockNum = lockNum_
					end
				end
				if lockTarget == nil then
				-- 如果没有锁定自己的，锁定其他
					local lockNum = -1
					for i, summon in ipairs(otherSummons) do
						local lockNum_ = #summon.beLockedEnemyArr
						if lockNum == -1 or lockNum_ < lockNum then
							lockTarget = summon
							lockNum = lockNum_
						end
					end
				end
			end
		end
		soldier:onLock(lockTarget, moveFlag)
	end
end

return BattleSoldier