local BattleHelper = {}

BattleHelper.ENUM = {
	LEGION_POS = {
		[1] = {
			[7] = cc.p(250, 540), [4] = cc.p(450, 540), [1] = cc.p(650, 540),
			[8] = cc.p(310, 370), [5] = cc.p(510, 370), [2] = cc.p(710, 370),
			[9] = cc.p(370, 200), [6] = cc.p(570, 200), [3] = cc.p(770, 200)
		},
		[2] = {
			[1] = cc.p(1050, 541), [4] = cc.p(1250, 541), [7] = cc.p(1450, 541),
			[2] = cc.p(1110, 371), [5] = cc.p(1310, 371), [8] = cc.p(1510, 371),
			[3] = cc.p(1170, 201), [6] = cc.p(1370, 201), [9] = cc.p(1570, 201)
		}
	},
	BATTLE_STATUS = {
		INIT = 0,
		FIGHTING = 1,
		PAUSE = 2,				-- 普通暂停
		PAUSE_BY_SKILL = 3,		-- 君主技能暂停
		OVER = 4
	},
	SOLDIER_STATUS = {
		INIT = 0,				--初始化状态
		STAND = 1,
		STAND_LOCK = 11,		--停止 锁定了目标
		MOVE = 2,
		MOVE_TO_TARGET = 21,	
		ATTACK = 3,
		LOSE_TARGET = 6,        -- 丢失锁定的目标
		LIMIT = 7,              -- 中了控制技能
		SPECIAL_MOVE = 8,		-- 特殊位移
		DONOTHING = 9,			-- 什么也不做
		OVER = 888,				-- 战斗结束
		DEAD = 999				-- 死亡
	},
	LEGION_STATUS = {
		SEARCH = 1,             -- 寻找目标
		STAND = 2,				-- 刚找到目标,开始移动
		MOVE = 3,				-- 移动中
		CLOSETO = 4,			-- 靠近中
		ATTACK = 5,				-- 攻击
		ATTACKING = 6,			-- 攻击进行中
		WAIT = 7,				-- 等待
		DONOTHING = 8,			-- 什么都不做
		DEAD = 100,				-- 死亡
		OVER = 888,				-- 结束
		ERROR = 999,			-- BUG了
	},
	SKILL_TYPE = {
		NORMAL_ATTACK = 1,
		AUTO_SKILL = 2,
		ANGER_SKILL = 3,
		PLAYER_SKILL = 4,
		SPECIAL = 5
	},
	FORMATION_CORRECTION = {
		-- 枪
		[1] = {
			[1] = 1,
			[2] = 0.8,
			[3] = 1.2,
		},
		-- 弓
		[2] = {
			[1] = 1.2,
			[2] = 1,
			[3] = 0.8,
		},
		-- 骑
		[3] = {
			[1] = 0.8,
			[2] = 1.2,
			[3] = 1,
		},
		-- 君主技能用
		[0] = {
			[1] = 1,
			[2] = 1,
			[3] = 1,
		}
	},
	REPORT_NAME = {
		ADDSUMMON = 1,
		MOVE = 2,
		DEAD = 3,
		USESKILL = 4,
		SKILLEFFECT = 5,
		ADDBUFF = 6,
		REMOVEBUFF = 7,
		HURT = 8,
		BREAKCASTINGSKILL = 9,
		SENDBULLET = 10,
		BATTLEEND = 11,
		USEPLAYERSKILL = 12,
		FINISHCASTINGSKILL = 13,
		ADDMP = 14,
		ADDPOINT = 15,
		ADDPOINTPERSECOND = 16,
		SKIPSKILL = 17,
		SHAKESCREEN = 18
	}
}

BattleHelper.CONST = {
	-- 武将伤害修正(武将打小兵的伤害加成)
	HERO_DAMAGE_COEFFICIENT = 3,
	-- 小兵伤害修正(小兵打武将的伤害修正)
	SOLDIER_DAMAGE_COEFFICIENT = 0.15,
	-- 检测小兵与目标之间的距离的初始值
	MIN_DISTANCE = 10000,
	-- 暴击倍率
	CRIT_DAMAGE_COEFFICIENT = 1.5
}

local BEHIND_RENDER_ZORDER = 1000   -- 小兵之下
local SOLDIER_RENDER_ZORDER = 2000  -- 小兵层级
local BULLET_RENDER_ZORDER = 4000	-- 子弹
local FRONT_RENDER_ZORDER = 5000	-- 小兵之上
local HP_RENDER_ZORDER = 6000		-- 血条
local MASK_SOLDIER_RENDER_ZORDER = 7000     -- 放技能时的遮罩
local MASK_HP_RENDER_ZORDER = 8000     		-- 放技能时的遮罩
local NUM_RENDER_ZORDER = 9000		-- 伤害数字
local SPECIAL_RENDER_ZORDER = 10000	-- 其他特殊

-- 命中几率修修正值
local HIT_CORRECTION = 90
-- 最低命中几率
local HIT_MIN = 10
-- 暴击几率修正值
local CRIT_CORRECTION = 5
-- 阵型克制伤害修正值
local FORMATION_CORRECTION = BattleHelper.ENUM.FORMATION_CORRECTION
-- 伤害加成上限(pvp)
local DAMAGE_MAX_ADDITION = 2.5
-- 伤害加成下限(pvp)
local DAMAGE_MIN_ADDITION = 0.1
-- 反弹伤害最高上限倍率
local REBOUND_MAX_ADDITION = 3

local HERO_DAMAGE_COEFFICIENT = BattleHelper.CONST.HERO_DAMAGE_COEFFICIENT
local SOLDIER_DAMAGE_COEFFICIENT = BattleHelper.CONST.SOLDIER_DAMAGE_COEFFICIENT

local SUMMON_BORN_POS = {
	{{1, 0}},
	{{1, 1}, {1, -1}},
	{{1, 1}, {1, 0}, {1, -1}},
	{{1, 1}, {1, -1}, {-1, 1}, {-1, -1}},
}

local PIC_EXTENSION = ".png"
local targetPlatform = CCApplication:getInstance():getTargetPlatform()
-- if targetPlatform == kTargetAndroid then
--     PIC_EXTENSION = ".pkm"
-- elseif targetPlatform == kTargetIphone or targetPlatform == kTargetIpad then
--     PIC_EXTENSION = ".pvr.ccz"
-- end

function BattleHelper:init(pvp)
	self.plistLoaded = {}
	self.jsonLoaded = {}
	self.audioMap = {}
	self.audioNum = 0
	self.talkConf = GameData:getConfData("local/battletalk")
	self.talkNum = #self.talkConf
	self.audioId = 0
	self.campCorrection = {}
	self.seed = os.time()
	self.pvp = pvp
end

function BattleHelper:clear()
	self.plistLoaded = nil
    if self.jsonLoaded then
	    for k, v in pairs(self.jsonLoaded) do
		    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(k .. ".json")
	    end
    end
	self.jsonLoaded = nil
	self.campCorrection = nil
end

function BattleHelper:setRandomSeed(seed)
	self.seed = seed
end

function BattleHelper:random(min, max)
	max = max or 1
    min = min or 0
    self.seed = (self.seed*9301 + 49297)%233280
    local rnd = self.seed/233280
    return min + math.floor(rnd*(max - min))
end

function BattleHelper:addCampCorrection(guid, defCamp, value)
	local index = guid*10 + defCamp
	if self.campCorrection[index] == nil then
		self.campCorrection[index] = 1
	end
	self.campCorrection[index] = self.campCorrection[index] + value
	if self.campCorrection[index] < 0 then
		self.campCorrection[index] = 0
	end
end

function BattleHelper:createAniByName(name, plistRes, changeEquipObj)
	local jsonRes = "animation/" .. name .. "/" .. name
	plistRes = plistRes or jsonRes
	self:loadAnimationRes(plistRes, jsonRes)
	local ani = self:createArmature(name, changeEquipObj)
	return ani
end

function BattleHelper:createLittleLossyAniByName(name, plistRes, changeEquipObj)
	local jsonRes = "animation_littlelossy/" .. name .. "/" .. name
	plistRes = plistRes or jsonRes
	self:loadAnimationRes(plistRes, jsonRes)
	local ani = self:createArmature(name, changeEquipObj)
	return ani
end

function BattleHelper:loadAnimationRes(plistRes, jsonRes)
	self:loadPlist(plistRes)
	self:loadJson(jsonRes)
end

function BattleHelper:loadPlist(plistRes)
	if self.plistLoaded[plistRes] == nil then
		self.plistLoaded[plistRes] = true
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plistRes .. ".plist")
	end
end

function BattleHelper:loadJson(jsonRes)
	if self.jsonLoaded[jsonRes] == nil then
		self.jsonLoaded[jsonRes] = true
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonRes .. ".json")
	end
end

function BattleHelper:createArmature(name, changeEquipObj)
	local armature = ccs.Armature:create(name)
	GlobalApi:changeModelEquip(armature, name, changeEquipObj, 1)
    if targetPlatform == kTargetAndroid then
        ShaderMgr:setShaderForArmature(armature, "default_etc")
    end
    return armature
end

-- 创建一个对象数据池
function BattleHelper:createObjPools()
	local pools = {
		dataPools = {}
	}
	-- 弹出一个对象
	function pools:pop(key_)
		local dataPool = pools.dataPools[key_]
		if dataPool == nil then
		-- 无数据
			return nil
		end
		local obj = nil
		if dataPool.num > 0 then
			obj = table.remove(dataPool.data)
			dataPool.num = dataPool.num - 1
		end
		return obj
	end

	-- 弹出一个对象
	function pools:push(key_, obj_)
		local dataPool = pools.dataPools[key_]
		if dataPool==nil then
		-- 还没该类型受击特效的池，创建一个空池
			dataPool = {
				data = {},
				num = 0
			}
			pools.dataPools[key_] = dataPool
		end
		-- 放入数据对象到尾部
		table.insert(dataPool.data, obj_)
		dataPool.num = dataPool.num + 1
	end

	return pools
end

function BattleHelper:setSoldierTag(soldier, type_)
	if type_ == 1 then
		soldier.root:setTag(BEHIND_RENDER_ZORDER)
	elseif type_ == 2 then
		soldier.root:setTag(FRONT_RENDER_ZORDER)
	else
		soldier.root:setTag(SOLDIER_RENDER_ZORDER)
	end
	soldier.effectNode:setTag(HP_RENDER_ZORDER)
end

function BattleHelper:setSoldierZorder(soldier)
	soldier.root:setLocalZOrder(SOLDIER_RENDER_ZORDER - soldier:getPositionY())
end

function BattleHelper:setSoldierHpZorder(hpNode, posY)
	hpNode:setLocalZOrder(HP_RENDER_ZORDER - posY)
end

function BattleHelper:setSoldierNumZorder(numNode, posY)
	numNode:setLocalZOrder(NUM_RENDER_ZORDER - posY)
end

function BattleHelper:setBulletZorder(bulletNode, posY)
	bulletNode:setLocalZOrder(BULLET_RENDER_ZORDER - posY)
end

function BattleHelper:setSoldierTopZorder(soldier)
	soldier.root:setLocalZOrder(SOLDIER_RENDER_ZORDER)
end

-- type_: 1--物体背后, 2--物体之前, 其他--小兵同级, 
function BattleHelper:setZorder(node, posY, type_)
	if type_ == 1 then
		node:setLocalZOrder(BEHIND_RENDER_ZORDER - posY)
	elseif type_ == 2 then
		node:setLocalZOrder(FRONT_RENDER_ZORDER - posY)
	else
		node:setLocalZOrder(SOLDIER_RENDER_ZORDER - posY)
	end
end

function BattleHelper:setSpecialNodeZorder(node)
	node:setLocalZOrder(SPECIAL_RENDER_ZORDER - node:getPositionY())
end

function BattleHelper:getRandomTalk()
	return self.talkConf[math.random(1, self.talkNum)].text
end

function BattleHelper:setSoldierZorderOnSkillMask(soldier)
	local y = soldier:getPositionY()
	soldier.root:setTag(MASK_SOLDIER_RENDER_ZORDER)
	soldier.effectNode:setTag(MASK_HP_RENDER_ZORDER)
	soldier.root:setLocalZOrder(MASK_SOLDIER_RENDER_ZORDER - y)
	soldier.effectNode:setLocalZOrder(MASK_HP_RENDER_ZORDER - y)
end

function BattleHelper:setSkillMaskImgZorder(img)
	img:setLocalZOrder(MASK_SOLDIER_RENDER_ZORDER - 1000)
end

function BattleHelper:playDeadSound(deadSound)
	if self.audioId > 0 then
		AudioMgr.stopEffect(self.audioId)
	end
	self.audioId = AudioMgr.playEffect("media/hero/" .. deadSound .. ".mp3", false)
end

function BattleHelper:playSound(soundRes, isLoop)
	if self.audioMap[soundRes] == nil and self.audioNum < 10 then
		local audioId = AudioMgr.playEffect(soundRes, isLoop)
		if audioId ~= -1 then
			self.audioMap[soundRes] = audioId
			self.audioNum = self.audioNum + 1
			AudioMgr.setFinishCallback(audioId, function (audioID, filePath)
				self.audioMap[soundRes] = nil
				self.audioNum = self.audioNum - 1
			end)
		end
	end
end

function BattleHelper:addSummon(skill, pointOrTarget)
	if skill:isPlayerSkill() then
		return
	end
	local skillBaseInfo = skill.baseInfo
	local summonId = skillBaseInfo.summonId
	local summonNum = skillBaseInfo.summonNum
	local bornPosType = skillBaseInfo.bornPosType
	local bornRelativePos = skillBaseInfo.bornRelativePos
	local pos = {x=0,y=0}
	local dir = 1
	local bodySize = 0
	if bornPosType == 1 then
		local x,y = skill.owner:getPosition()
		dir = skill.owner:getDirection()
		bodySize = skill.owner.bodySize
		pos.x = x
		pos.y = y
	elseif bornPosType == 2 then
		local x,y = pointOrTarget:getPosition()
		dir = pointOrTarget:getDirection()
		bodySize = pointOrTarget.bodySize
		pos.x = x
		pos.y = y
	else
		pos = pointOrTarget
	end
	if bornRelativePos == 2 then
		dir = dir*-1
	elseif bornRelativePos == 3 then
		dir = 0
	end
	local index = summonNum > 4 and 4 or summonNum
	for i = 1, summonNum do
		local index2 = (i-1)%4 + 1
		local posx = bodySize*SUMMON_BORN_POS[index][index2][1]*dir
		local posy = bodySize*SUMMON_BORN_POS[index][index2][2]*dir
		local bornPos = cc.pAdd(pos, cc.p(posx, posy))
		skill.owner.legionObj:addSummonObj(skill.owner, summonId, bornPos)
	end
end

function BattleHelper:skillEffect(skillOrBuff, attacker, defenser)
	local effectId = skillOrBuff.baseInfo.effectId
	if effectId == 1 then
		self:normalDamage(skillOrBuff, attacker, defenser)
	elseif effectId == 2 then
		self:tureDamage(skillOrBuff, attacker, defenser)
	end
end

function BattleHelper:normalDamage(skillOrBuff, attAI, defAI)
	local skillBaseInfo = skillOrBuff.baseInfo
	local fixedDamage = skillBaseInfo.fixedDamage
	local coefficient = skillBaseInfo.coefficient
	local flag = 0
	local hpNum = 0 		-- 具体伤害
	local reboundNum = 0 	-- 具体反弹伤害
	local suckNum = 0 		-- 具体吸血伤害
	local dirType = skillBaseInfo.dirType
	local showNum = skillBaseInfo.showNum or 1
	local ignoreDodge = skillBaseInfo.ignoreDodge or 0
	local ignoreDef = skillBaseInfo.ignoreDef or 0
	local addCrit = skillBaseInfo.addCrit or 0
	local suckBloodPercent = (skillBaseInfo.suckBloodPercent or 0) + (attAI.suckBloodPercent or 0)
	local suckBlood = (skillBaseInfo.suckBlood or 0) + (attAI.suckBlood or 0)
	local suckMpPercent = skillBaseInfo.suckMpPercent or 0
	local burnMpPercent = skillBaseInfo.burnMpPercent or 0
	local addAnger = true
	local damageCoefficient = 1 -- 伤害统计系数
	if dirType == 1 then
	-- 负面效果(减血)
		local ignoreDmg
		local enemyDef
		if attAI.professionType == 1 then -- 物理职业
			ignoreDmg = defAI.ignorePhy
			enemyDef = defAI.phyDef
		elseif attAI.professionType == 2 then -- 法系职业
			ignoreDmg = defAI.ignoreMag
			enemyDef = defAI.magDef
		end
		if ignoreDmg > 0 or defAI.invincibleOnce then
		-- 免疫
			flag = 1
			defAI.invincibleOnce = false
		else
			local hit
			if ignoreDodge == 0 then
				hit = HIT_CORRECTION + (attAI.hit - defAI.dodge)/100
				hit = hit < HIT_MIN and HIT_MIN or hit
			else
				hit = 100
			end
			if self:random(0, 100) > hit then -- 闪避
				flag = 2
			else
				local reduceDef = 100 - ignoreDef - attAI.ignoreDef
				if reduceDef < 0 then
					reduceDef = 0
				end
				local attDis = attAI.atk - enemyDef*reduceDef/100
				attDis = attDis < attAI.atk*0.05 and attAI.atk*0.05 or attDis

				local dmgPercent = 1 + attAI.attPercent - defAI.defPercent
				if self.pvp then
					dmgPercent = dmgPercent + attAI.pvpAttPercent - defAI.pvpDefPercent
					if dmgPercent > DAMAGE_MAX_ADDITION then
						dmgPercent = DAMAGE_MAX_ADDITION
					elseif dmgPercent < DAMAGE_MIN_ADDITION then
						dmgPercent = DAMAGE_MIN_ADDITION
					end
				end
				if attAI.soldierType ~= 2 and defAI.soldierType == 2 then
					hpNum = (attDis*coefficient/100 + fixedDamage)*dmgPercent*HERO_DAMAGE_COEFFICIENT
					damageCoefficient = HERO_DAMAGE_COEFFICIENT
				elseif attAI.soldierType == 2 and defAI.soldierType ~= 2 then
					hpNum = (attDis*coefficient/100 + fixedDamage)*dmgPercent*SOLDIER_DAMAGE_COEFFICIENT
				else
					hpNum = (attDis*coefficient/100 + fixedDamage)*dmgPercent
				end
				hpNum = hpNum*FORMATION_CORRECTION[attAI.legionType][defAI.legionType]
				hpNum = hpNum*(self.campCorrection[attAI.guid*10 + defAI.camp] or 1)
				local crit = CRIT_CORRECTION + (attAI.crit - defAI.resi)*0.01 + addCrit
				if self:random(0, 100) < crit then
				-- 暴击
					hpNum = hpNum*attAI.critCoefficient
					flag = 3
				end
				-- 伤害取整
				if hpNum < 1 then
					hpNum = 1
				else
					hpNum = math.floor(hpNum)
				end
				-- 反弹
				if defAI.reboundDmg > 0 then
					reboundNum = hpNum*defAI.reboundDmg
					if reboundNum < 1 then
						reboundNum = 1
					elseif reboundNum > defAI.atk*REBOUND_MAX_ADDITION then
						reboundNum = math.floor(defAI.atk*REBOUND_MAX_ADDITION)
					else
						reboundNum = math.floor(reboundNum)
					end
				end
				-- 吸血
				if suckBlood > 0 or suckBloodPercent > 0 then
					suckNum = hpNum*suckBloodPercent*0.01 + suckBlood
					if suckNum < 1 then
						suckNum = 1
					else
						suckNum = math.floor(suckNum)
					end
				end
				-- 负面效果，取负值
				hpNum = -hpNum
			end
		end
	elseif dirType == 2 then
	-- 正面效果(加血)
		hpNum = (attAI.atk*coefficient/100 + fixedDamage)*(1 + attAI.attPercent)*(1 + defAI.cureIncrease)
		local crit = CRIT_CORRECTION + attAI.crit*0.001 + addCrit
		if self:random(0, 100) < crit then
		-- 暴击
			hpNum = hpNum*attAI.critCoefficient
			flag = 3
		end
		if hpNum < 1 then
			hpNum = 1
		else
			hpNum = math.floor(hpNum)
		end
	end
	hpNum = attAI:effectWhenHurtTarget(hpNum, flag, skillOrBuff.skillType, defAI)
	hpNum = defAI:effectWhenGetHurt(hpNum, flag, skillOrBuff.skillType, attAI)
	if hpNum < 0 then
		-- 处理伤害反弹
		if reboundNum > 0 and not defAI:isDead() then
			local ignoreDmg
			if defAI.professionType == 1 then -- 物理职业
				ignoreDmg = attAI.ignorePhy or 0
			elseif defAI.professionType == 2 then -- 法系职业
				ignoreDmg = attAI.ignoreMag or 0
			else
				ignoreDmg = 0
			end
			if ignoreDmg > 0 or attAI.invincibleOnce then -- 免疫
				attAI.invincibleOnce = false
			else
				local dmgNum = -reboundNum
				dmgNum = defAI:effectWhenHurtTarget(dmgNum, 4, skillOrBuff.skillType, attAI)
				dmgNum = attAI:effectWhenGetHurt(dmgNum, 4, skillOrBuff.skillType, defAI)
				attAI:getEffect(defAI, dmgNum, showNum > 0, 4, skillOrBuff.skillType, 1, true, skillBaseInfo.id)
			end
		end
		if not attAI:isDead() then
			-- 处理吸血
			if suckNum > 0 then
				attAI:showSuckAnimation()
				attAI:getEffect(attAI, suckNum, true, 5, skillOrBuff.skillType, 1, true, skillBaseInfo.id)
			end
		end
		-- 吸怒
		if suckMpPercent > 0 then
			addAnger = false
			local mp = suckMpPercent/100
			defAI:addMpPercentage(-mp)
			if not attAI:isDead() then
				attAI:addMpPercentage(mp)
			end
		end
		-- 消怒
		if burnMpPercent > 0 then
			addAnger = false
			defAI:addMpPercentage(-burnMpPercent/100)
		elseif burnMpPercent < 0 then
			defAI:addMpPercentage(-burnMpPercent/100)
		end
	end
	-- 受击者获取受击效果
	defAI:getEffect(attAI, hpNum, showNum > 0, flag, skillOrBuff.skillType, damageCoefficient, addAnger, skillBaseInfo.id)
end

function BattleHelper:tureDamage(skillOrBuff, attAI, defAI)
	local skillBaseInfo = skillOrBuff.baseInfo
	local fixedDamage = skillBaseInfo.fixedDamage
	local coefficient = skillBaseInfo.coefficient
	local flag = 0
	local hpNum = 0 		-- 具体伤害
	local reboundNum = 0 	-- 具体反弹伤害
	local suckNum = 0 		-- 具体吸血伤害
	local dirType = skillBaseInfo.dirType
	local showNum = skillBaseInfo.showNum or 1
	local addCrit = skillBaseInfo.addCrit or 0
	local suckBloodPercent = (skillBaseInfo.suckBloodPercent or 0) + (attAI.suckBloodPercent or 0)
	local suckBlood = (skillBaseInfo.suckBlood or 0) + (attAI.suckBlood or 0)
	local suckMpPercent = skillBaseInfo.suckMpPercent or 0
	local burnMpPercent = skillBaseInfo.burnMpPercent or 0
	local damageCoefficient = 1 -- 伤害统计系数
	local addAnger = true
	if dirType == 1 then
		local ignoreDmg
		if attAI.professionType == 1 then -- 物理职业
			ignoreDmg = defAI.ignorePhy
		elseif attAI.professionType == 2 then -- 法系职业
			ignoreDmg = defAI.ignoreMag
		else
			ignoreDmg = 0
		end
		if ignoreDmg > 0 or defAI.invincibleOnce then
			flag = 1
			defAI.invincibleOnce = false
		else
			local dmgPercent = 1 + attAI.attPercent - defAI.defPercent
			if self.pvp then
				dmgPercent = dmgPercent + attAI.pvpAttPercent - defAI.pvpDefPercent
				if dmgPercent > DAMAGE_MAX_ADDITION then
					dmgPercent = DAMAGE_MAX_ADDITION
				elseif dmgPercent < DAMAGE_MIN_ADDITION then
					dmgPercent = DAMAGE_MIN_ADDITION
				end
			end
			if attAI.soldierType == 1 and defAI.soldierType ~= 1 then
				hpNum = (attAI.atk*coefficient/100 + fixedDamage)*dmgPercent*HERO_DAMAGE_COEFFICIENT
				damageCoefficient = HERO_DAMAGE_COEFFICIENT
			elseif attAI.soldierType ~= 1 and defAI.soldierType == 1 then
				hpNum = (attAI.atk*coefficient/100 + fixedDamage)*dmgPercent*SOLDIER_DAMAGE_COEFFICIENT
			else
				hpNum = (attAI.atk*coefficient/100 + fixedDamage)*dmgPercent
			end
			hpNum = hpNum*FORMATION_CORRECTION[attAI.legionType][defAI.legionType]
			hpNum = hpNum*(self.campCorrection[attAI.guid*10 + defAI.camp] or 1)
			local crit = addCrit
			if self:random(0, 100) <= crit then
			-- 暴击
				hpNum = hpNum*attAI.critCoefficient
				flag = 3
			end
			-- 伤害取整
			if hpNum < 1 then
				hpNum = 1
			else
				hpNum = math.floor(hpNum)
			end
			-- 反弹
			if defAI.reboundDmg > 0 then
				reboundNum = hpNum*defAI.reboundDmg
				if reboundNum < 1 then
					reboundNum = 1
				elseif reboundNum > defAI.atk*REBOUND_MAX_ADDITION then
					reboundNum = math.floor(defAI.atk*REBOUND_MAX_ADDITION)
				else
					reboundNum = math.floor(reboundNum)
				end
			end
			-- 吸血
			if suckBlood > 0 or suckBloodPercent > 0 then
				suckNum = hpNum*suckBloodPercent*0.01 + suckBlood
				if suckNum < 1 then
					suckNum = 1
				else
					suckNum = math.floor(suckNum)
				end
			end
			-- 负面效果，取负值
			hpNum = -hpNum
		end
	elseif dirType == 2 then
	-- 正面效果(加血)
		hpNum = (attAI.atk*coefficient/100 + fixedDamage)*(1 + attAI.attPercent)*(1 + defAI.cureIncrease)
		if hpNum < 1 then
			hpNum = 1
		else
			hpNum = math.floor(hpNum)
		end
	end
	hpNum = attAI:effectWhenHurtTarget(hpNum, flag, skillOrBuff.skillType, defAI)
	hpNum = defAI:effectWhenGetHurt(hpNum, flag, skillOrBuff.skillType, attAI)
	if hpNum < 0 then
		-- 处理伤害反弹
		if reboundNum > 0 and not defAI:isDead() then
			local ignoreDmg
			if defAI.professionType == 1 then -- 物理职业
				ignoreDmg = attAI.ignorePhy or 0
			elseif defAI.professionType == 2 then -- 法系职业
				ignoreDmg = attAI.ignoreMag or 0
			else
				ignoreDmg = 0
			end
			if ignoreDmg > 0 or attAI.invincibleOnce then -- 免疫
				attAI.invincibleOnce = false
			else
				local dmgNum = -reboundNum
				dmgNum = defAI:effectWhenHurtTarget(dmgNum, 4, skillOrBuff.skillType, attAI)
				dmgNum = attAI:effectWhenGetHurt(dmgNum, 4, skillOrBuff.skillType, defAI)
				attAI:getEffect(defAI, dmgNum, showNum > 0, 4, skillOrBuff.skillType, 1, true, skillBaseInfo.id)
			end
		end
		if not attAI:isDead() then
			-- 处理吸血
			if suckNum > 0 then
				attAI:showSuckAnimation()
				attAI:getEffect(attAI, suckNum, true, 5, skillOrBuff.skillType, 1, true, skillBaseInfo.id)
			end
		end
		-- 吸怒
		if suckMpPercent > 0 then
			addAnger = false
			local mp = suckMpPercent/100
			defAI:addMpPercentage(-mp)
			if not attAI:isDead() then
				attAI:addMpPercentage(mp)
			end
		end
		-- 消怒
		if burnMpPercent > 0 then
			addAnger = false
			defAI:addMpPercentage(-burnMpPercent/100)
		elseif burnMpPercent < 0 then
			defAI:addMpPercentage(-burnMpPercent/100)
		end
	end
	defAI:getEffect(attAI, hpNum, showNum > 0, flag, skillOrBuff.skillType, damageCoefficient, addAnger, skillBaseInfo.id)
end

return BattleHelper