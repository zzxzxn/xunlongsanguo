local ClassBattleBuff = require("script/app/ui/battle/skill/battlebuff")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local BattleSummon = {}

function BattleSummon:initAttribute(soldier)
	local summonInfo = soldier.summonInfo
	local heroObj = soldier.legionObj.heroObj
	local baseInfo = GameData:getConfData("soldier")[summonInfo.modelArmyTypeId]
	if summonInfo.attackRange > 0 then
		soldier.baseAttackRange = summonInfo.attackRange
	else
		if baseInfo.attackType == 1 then
			soldier.baseAttackRange = (baseInfo.attackRange1 + baseInfo.attackRange2)/2
		else
			soldier.baseAttackRange = (baseInfo.attackRange1 + baseInfo.attackRange2)/2 + heroObj.attackRange
		end
	end
	soldier.attackRange = soldier.baseAttackRange
	soldier.bodySize = baseInfo.bodySize
	soldier.professionType = heroObj.professionType
	soldier.attackType = baseInfo.attackType
	soldier.attackSpeed = baseInfo.attackSpeed*0.001
	soldier.baseAttackSpeed = soldier.attackSpeed
	soldier.minAttackSpeed = soldier.baseAttackSpeed*0.2
	if summonInfo.baseSpeed > 0 then
		soldier.moveSpeed = summonInfo.baseSpeed
	else
		soldier.moveSpeed = heroObj.baseMoveSpeed + (baseInfo.speedRange1 + baseInfo.speedRange2)/2
	end
	soldier.baseMoveSpeed = soldier.moveSpeed
	soldier.maxHp = heroObj.baseHp*baseInfo.heaPowPercent*0.01 + summonInfo.baseHp
	soldier.baseHp = soldier.maxHp
	soldier.hp = soldier.maxHp
	soldier.maxMp = 0
	soldier.mp = 0
	soldier.atk = heroObj.baseAtk*baseInfo.attPowPercent*0.01 + summonInfo.baseAttack
	soldier.baseAtk = soldier.atk
	soldier.phyDef = heroObj.basePhyDef*baseInfo.phyArmPowPercent*0.01 + summonInfo.baseDef
	soldier.basePhyDef = soldier.phyDef
	soldier.magDef = heroObj.baseMagDef*baseInfo.magArmPowPercent*0.01 + summonInfo.baseMagDef
	soldier.baseMagDef = soldier.magDef
	soldier.hit = heroObj.baseHit + summonInfo.baseHit
	soldier.baseHit = soldier.hit
	soldier.dodge = heroObj.baseDodge + summonInfo.baseDodge
	soldier.baseDodge = soldier.dodge
	soldier.crit = heroObj.baseCrit + summonInfo.baseCrit
	soldier.critCoefficient = heroObj.critCoefficient
	soldier.baseCrit = soldier.crit
	soldier.resi = heroObj.baseResi + summonInfo.baseResi
	soldier.baseResi = soldier.resi
	soldier.attPercent = heroObj.attPercent
	soldier.defPercent = heroObj.defPercent
	soldier.pvpAttPercent = heroObj.pvpAttPercent
	soldier.pvpDefPercent = heroObj.pvpDefPercent
	soldier.reboundDmg = 0
	soldier.suckBlood = 0
	soldier.suckBloodPercent = 0
	soldier.ignoreDef = 0
	soldier.cureIncrease = 0
	soldier.recoverMp = 0
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
	if baseInfo.urlType == 1 then
		if soldier.guid == 1 then
			soldier.url = baseInfo.url .. "_g"
		else
			soldier.url = baseInfo.url .. "_r"
		end
	else
		soldier.url = baseInfo.url
	end
	soldier.urlType = baseInfo.urlType
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
	if summonInfo.ableMove <= 0 then
		soldier.limitMove = 1
	end
end

function BattleSummon:getAvailableSkill(soldier)
	if soldier.baseSkill == nil then
		return nil
	end
	if soldier.limitSkill > 0 then -- 如果禁止放技能就放普攻
		return soldier.baseSkill
	end
	if soldier.autoSkills and soldier.baseSkill:getUsedTimes() >= soldier.autoSkillTimes then
		soldier.skillLoopOver = true
		return soldier.autoSkills
	else
		return soldier.baseSkill
	end
end

function BattleSummon:prepare(soldier)
	soldier:searchTarget(false, false)
end

function BattleSummon:searchTarget(soldier, forceFlag, moveFlag)
	if soldier.summonInfo.forceNearest > 0 then
		self:searchNearestTarget(soldier, moveFlag)
	else
		self:searchTargetBySummon(soldier, moveFlag)
	end
end

function BattleSummon:searchNearestTarget(soldier, moveFlag)
	local armyArr = soldier.battlefield.armyArr[3 - soldier.guid]
	local lockTarget
	local minDis
	local x1, y1 = soldier:getPosition()
	for _, armyObj in ipairs(armyArr) do
		if not armyObj.heroObj:isDead() and isInRange(armyObj.heroObj) then
			local x2, y2 = armyObj.heroObj:getPosition()
			local dis = math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)
			if minDis == nil or dis < minDis then
				lockTarget = armyObj.heroObj
				minDis = dis
			end
		end
		for _, soldierObj in ipairs(armyObj.soldierObjs) do
			if not soldierObj:isDead() and isInRange(soldierObj) then
				local x2, y2 = soldierObj:getPosition()
				local dis = math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)
				if minDis == nil or dis < minDis then
					lockTarget = soldierObj
					minDis = dis
				end
			end
		end
		for _, summonObj in ipairs(armyObj.summonObjs) do
			if not summonObj:isDead() and isInRange(summonObj) then
				local x2, y2 = summonObj:getPosition()
				local dis = math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)
				if minDis == nil or dis < minDis then
					lockTarget = summonObj
					minDis = dis
				end
			end
		end
	end
	soldier:onLock(lockTarget, moveFlag)
end

function BattleSummon:searchTargetBySummon(soldier, moveFlag)
	local lockLegion = soldier.legionObj.lockLegion
	local summonInfo = soldier.summonInfo
	if lockLegion then
		local lockTarget
		if summonInfo.firstTargetType == 1 then -- 优先选择英雄
			if not lockLegion.heroObj:isDead() then
				lockTarget = lockLegion.heroObj
			end
		end
		-- 锁定士兵
		if lockTarget == nil then
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
		end
		if lockTarget == nil then
		-- 如果没有士兵，选择英雄
			if summonInfo.firstTargetType == 2 then
				if not lockLegion.heroObj:isDead() then
					lockTarget = lockLegion.heroObj
				end
			end
		end
		if lockTarget == nil then
		-- 最后选择召唤物
			local lockMeTargets = {} --锁定自己的
			local otherTargets = {} --未锁定自己的
			for i, summon in ipairs(lockLegion.summonObjs) do
				if not summon:isDead() then
					if summon.lockEnemy == soldier then
						table.insert(lockMeTargets, summon)
					else
						table.insert(otherTargets, summon)
					end
				end
			end
			-- 选定被锁定次数较少的
			-- 优先选择锁定自己的
			local lockNum = -1
			for i, summon in ipairs(lockMeTargets) do
				local lockNum_ = #summon.beLockedEnemyArr
				if lockNum == -1 or lockNum_ < lockNum then
					lockTarget = summon
					lockNum = lockNum_
				end
			end
			if lockTarget==nil then
			-- 如果没有锁定自己的，锁定其他
				local lockNum = -1
				for i, summon in ipairs(otherTargets) do
					local lockNum_ = #summon.beLockedEnemyArr
					if lockNum == -1 or lockNum_ < lockNum then
						lockTarget = summon
						lockNum = lockNum_
					end
				end
			end
		end
		soldier:onLock(lockTarget, moveFlag)
	end
end

return BattleSummon