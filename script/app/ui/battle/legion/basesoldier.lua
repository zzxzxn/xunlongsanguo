local ClassHero = require("script/app/ui/battle/legion/battlehero")
local ClassSoldier = require("script/app/ui/battle/legion/battlesoldier")
local ClassSummon = require("script/app/ui/battle/legion/battlesummon")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleSkill = require("script/app/ui/battle/skill/battleskill")
local ClassBattleBuff = require("script/app/ui/battle/skill/battlebuff")
local BaseSoldier = class("BaseSoldier")

local SOLDIER_STATUS = BattleHelper.ENUM.SOLDIER_STATUS
local MOVE_ACTION_TAG = 888
local HP_ACTION_TAG = 1000
local LOSE_CONTROL_TAG = 8
local MIN_DISTANCE = BattleHelper.CONST.MIN_DISTANCE
local RECALCULATE_TIME = 0.5 -- 重新计算目标点的时间间隔
local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

local function getDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
end

function BaseSoldier:ctor(legionObj, soldierType, soldierIndex)
	self.guid = legionObj.guid
	self.legionObj = legionObj
	self.soldierType = soldierType
	self.soldierIndex = soldierIndex
	self.specialAI = self:getAIBySoldierType(soldierType)
end

function BaseSoldier:getAIBySoldierType(soldierType)
	if soldierType == 1 then
		return ClassHero
	elseif soldierType == 2 then
		return ClassSoldier
	elseif soldierType == 3 then
		return ClassSummon
	end
end

function BaseSoldier:init(position, offsetPos)
	self.offsetPos = offsetPos
	self.specialAI:initAttribute(self)
	self:initReportAttribute()
	self.battlefield = self.legionObj.battlefield
	self:createNode(position)
	self:initActionInfo() -- 计算战报用
	self.status = 0
	self.currAction = ""
	self.currSkill = nil
	self.needIdle = false
	self.ypHero = 0 -- 战斗中的站位偏移量
	self.lockEnemy = nil
	self.beLockedEnemyArr = {}
	self.beLockedHeroNum = 0
	self.standDir = 1 -- 站位方向
	self.buffList = {} -- 中的buff
	self.buffMode = {} -- 中的buff类型
	self.isLeader = false
	self.costTime = -1
	self.finalPosition = nil
	if self.attackType == 1 then -- 近战
		self.rangeOffset = self.attackRange*0.3
	else
		self.rangeOffset = self.attackRange*0.1
	end
	self.specialAttackRange = false -- 如果移动到目标点后可以立即释放技能, 那么此次检测攻击范围的容错值翻番
	self.moveAfterAttack = 0
	self.posAfterAttack = { -- 动作完成后需要移动的目标
		x = 0,
		y = 0
	}
	self.loseControlId = 0 -- 不受控制状态
	self.pauseFlag = false
	self.rolePosOffset = {
		x = 0,
		y = 0
	}
	self.damageCount = {0,0} -- 伤害统计
	self.hurtCount = 0
	if self.soldierType == 1 then
		if self.legionObj.heroInfo.preDamageCount then
			self:addDamageCount(self.legionObj.heroInfo.preDamageCount, self.guid, 1)
		end
		if self.legionObj.heroInfo.preHurtCount then
			self:addHurtCount(self.legionObj.heroInfo.preHurtCount)
		end
	end
	self.changeSkillFlag = false
	self:playAction("idle", true)
	self.moveToOther = false
	self.minDistance = MIN_DISTANCE
	self.recalculateTime = RECALCULATE_TIME
	self.targetLockMe = false
	self.attackFinishTime = 0
	self.legionType = self.legionObj.legionType
	self.isTalking = false
	self.skillLoopOver = false
	self.selectEnable = 1
	self.attackTimes = 0
	self.rootScale = 1
	self:initSkill()
	self:updateZorder(position.y)
end

function BaseSoldier:initReportAttribute()
end

function BaseSoldier:initActionInfo()
end

function BaseSoldier:createNode(position)
	self.root = cc.Node:create()
	self.battlefield.bgImg:addChild(self.root)
	self.root:setPosition(position)
	-- 角色节点
	local roleNode = cc.Node:create()
	self.root:addChild(roleNode)
	self.roleNode = roleNode
	if self.guid == 2 then
		self:setDirection(-1)
	end
	self.armature = self:initModel() -- 动画节点
	roleNode:addChild(self.armature)
	-- 血条喊话等乱七八糟的东西的节点
	self.effectNode = cc.Node:create()
	self.effectNode:setPosition(position)
	self.battlefield.bgImg:addChild(self.effectNode)
	local soldierTypeName = self.soldierType == 1 and "hero" or "soldier"
	local hpNode = cc.Sprite:createWithSpriteFrameName("battle_" .. soldierTypeName .. "_hp_4.png")
	local hpBarPre = ccui.LoadingBar:create("battle_" .. soldierTypeName .. "_hp_2.png", ccui.TextureResType.plistType, 100)
	local hpBar = nil
	if self.guid == 1 then
		hpBar = ccui.LoadingBar:create("battle_" .. soldierTypeName .. "_hp_3.png", ccui.TextureResType.plistType, 100)
	else
		hpBar = ccui.LoadingBar:create("battle_" .. soldierTypeName .. "_hp_1.png", ccui.TextureResType.plistType, 100)
	end
	hpBar:setPercent(self.hp*100/self.maxHp)
	hpBarPre:setPercent(self.hp*100/self.maxHp)
	local sz = hpNode:getContentSize()
	hpBarPre:setPosition(sz.width/2, sz.height/2)
	hpBar:setPosition(sz.width/2, sz.height/2)
	hpNode:addChild(hpBarPre)
	hpNode:addChild(hpBar)
	hpNode:setPosition(cc.p(0, self.hpBarHeight))
	self.hpNode = hpNode
	self.hpBarPre = hpBarPre
	self.hpBar = hpBar
	self.hpNode:setVisible(false)
	self.effectNode:addChild(hpNode)
	if self.soldierType == 1 then
		-- 金将特效
		local herochangeconf = GameData:getConfData('herochange')
		local MAXPROTYPE = #herochangeconf
		local promoteType = 0
		if self.promote and self.promote[1] then
			promoteType = self.promote[1]
		end
		if promoteType >= MAXPROTYPE then
			self.godAni = BattleHelper:createAniByName("god_hero")
			self.godAni:setScale(1.1*self.originalScale*3)
			self.godAni:getAnimation():playWithIndex(0, -1, 1)
			roleNode:addChild(self.godAni)
		end
		-- 怒气条
		local mpBar = ccui.LoadingBar:create("battle_hero_hp_5.png", ccui.TextureResType.plistType, self.mp/self.maxMp)
		mpBar:setPosition(sz.width/2, sz.height/2 - 4)
		hpNode:addChild(mpBar)
		self.mpBar = mpBar
		-- 普通喊话
		local talkNode = cc.Sprite:create("uires/ui/battle/bg_talk_" .. self.guid .. ".png")
		talkNode:setCascadeOpacityEnabled(true)
		local talkLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
		talkLabel:setMaxLineWidth(100)
		talkLabel:setTextColor(COLOR_TYPE.BLACK)
		talkLabel:setPosition(cc.p(65, 47.5))
		talkNode:setPositionY(self.hpBarHeight + 30)
		talkNode:setVisible(false)
		talkNode:addChild(talkLabel)
		self.effectNode:addChild(talkNode)
		self.talkNode = talkNode
		self.talkLabel = talkLabel
		-- 技能喊话
		local skillShoutNode = cc.Sprite:create()
		skillShoutNode:setVisible(false)
		self.effectNode:addChild(skillShoutNode)
		self.skillShoutNode = skillShoutNode
		self.skillShoutName = ""
		self.shadow = self.armature:getBone(self.url .. "_shadow")
	elseif self.soldierType == 2 then
		local talkNode = cc.Sprite:createWithSpriteFrameName("battle_say_" .. self.guid .. "_1.png")
		talkNode:setPositionY(self.hpBarHeight - 16)
		talkNode:setVisible(false)
		self.effectNode:addChild(talkNode)
		self.talkNode = talkNode
	end
	self.effectNode:setVisible(false)
end

function BaseSoldier:initModel()
	local armatureNode
	if self.soldierType == 1 then
		-- if string.sub(self.url, 1, 4) == "nan_" then
		-- 	armatureNode = BattleHelper:createAniByName(self.url, "animation/nan/nan", self.changeEquipObj)
		-- else

			if self.changeEquipObj and self.changeEquipObj.bones and self.changeEquipObj.equips then
				self.changeEquipObj.dragon = UserData:getUserObj():getDragon()
			end
			armatureNode = BattleHelper:createAniByName(self.url, nil, self.changeEquipObj)
		-- end
	else
		if self.urlType == 1 then
			armatureNode = BattleHelper:createAniByName(self.url, "animation_littlelossy/xiaobing/xiaobing")
		else
			armatureNode = BattleHelper:createAniByName(self.url)
		end
	end
	self.originalScale = self.scale*0.01
	armatureNode:setScale(self.originalScale)
	local function movementFun(armature, movementType, movementID)
		if movementType == 1 then
			if movementID == "dead" then
				self.armature:setOpacity(100)
				self.armature:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.FadeOut:create(3), cc.CallFunc:create(function ()
					self.root:setVisible(false)
				end)))
			else
				if self.liveTime and self.attackTimes >= self.liveTime then
					self:die(self)
				else
					self:movementComplete(movementID)
				end
			end
		end
	end
	local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
		if frameEventName == "-1" then
			if self.currSkill then
				if not self.currSkill:isFinished() and not self.currSkill:isCasting() then
					self.attackTimes = self.attackTimes + 1
					self.currSkill:effect()
				end
			end
		end
	end
	armatureNode:getAnimation():setMovementEventCallFunc(movementFun)
	armatureNode:getAnimation():setFrameEventCallFunc(frameFun)
	return armatureNode
end

function BaseSoldier:movementComplete(movementID)
	if movementID == "hit" and self.needIdle then
		self:playAction("idle", true)
	else
		if self.currSkill then
			if self.currSkill:isFinished() then
				self:restoreScale()
				self.currSkill = nil
				self.attackFinishTime = self.battlefield.time
				if self.playWinAction then
					if self.guid == 1 then
						self:setDirection(1)
					else
						self:setDirection(-1)
					end
					self:playAction("shengli", true)
					return
				end
				if self.moveAfterAttack == 0 then
					if self.needIdle then
						if self.lockEnemy == nil or self.lockEnemy:isDead() then
							self:setStatus(SOLDIER_STATUS.LOSE_TARGET)
						else
							self:setStatus(SOLDIER_STATUS.ATTACK)
						end
					end
				elseif self.moveAfterAttack == 1 then
					self.moveAfterAttack = 0
					if self.legionObj:isWait() then
						self:moveTogether(self.legionObj.moveToPos)
					else
						if self.legionObj:isMovingByLegion() then
							self:moveToByLegion(self.legionObj.moveToPos)
						else
							self:setFinalPosition(nil)
							if self.lockEnemy and self.lockEnemy:getTargeLockMe() and self.lockEnemy.moveToOther then
								self.lockEnemy:setFinalPosition(nil)
								self.lockEnemy:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
							end
							self:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
						end
					end
				elseif self.moveAfterAttack == 2 then
					self.moveAfterAttack = 0
					self:setFinalPosition(nil)
					if self.lockEnemy and self.lockEnemy:getTargeLockMe() and self.lockEnemy.moveToOther then
						self.lockEnemy:setFinalPosition(nil)
						self.lockEnemy:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
					end
					self:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
				end
			elseif self.currSkill:isCasting() then -- 引导技能
				self:playAction(self.currAction, false, true)
			end
		elseif self.needIdle then
			self:playAction("idle", true)
		end
	end
end

-- 召唤物特性
function BaseSoldier:initSummonSpeciality()
	local summonInfo = self.summonInfo
	self.selectEnable = summonInfo.selectEnable
	if summonInfo.buffId > 0 then -- 出生buff
		self:createBuff(summonInfo.buffId, self)
	end
	local deathType = summonInfo.deathType -- 死亡类型
	if deathType == 2 then -- 按时间嗝屁
		self:dieAfterAWhile(summonInfo.liveTime)
	elseif deathType == 3 then -- 按攻击次数嗝屁
		self.liveTime = summonInfo.attackTimes
	elseif deathType == 4 then -- 按被攻击次数嗝屁
		self.beAttackDieTimes = summonInfo.beAttackTimes
	end
	if summonInfo.dieWithMaster > 0 then
		self.owner.summons = self.owner.summons or {}
		table.insert(self.owner.summons, self)
	end
	self:showBornAnimation()
	if self.owner.soldierType == 1 then
		self.owner:effectWhenSummon(self)
	end
end

function BaseSoldier:initSkill()
	local skillGroupInfo = GameData:getConfData("skillgroup")[self.skillGroupId]
	if skillGroupInfo == nil then
		return
	end
	if skillGroupInfo.baseSkill > 0 then
		self.baseSkill = self:createSkill(skillGroupInfo.baseSkill, SKILL_TYPE.NORMAL_ATTACK)
	end
	if skillGroupInfo.autoSkill1 > 0 then
		self.autoSkills = self:createSkill(skillGroupInfo.autoSkill1 + self.skillLevel - 1, SKILL_TYPE.AUTO_SKILL)
		self.autoSkillTimes = skillGroupInfo.autoSkillTimes1
	end
	if skillGroupInfo.angerSkill > 0 then
		self.angerSkill = self:createSkill(skillGroupInfo.angerSkill + self.skillLevel - 1, SKILL_TYPE.ANGER_SKILL)
	end
end

function BaseSoldier:forgetSkill(index)
	if index == SKILL_TYPE.AUTO_SKILL then
		self.autoSkills = nil
	elseif index == SKILL_TYPE.ANGER_SKILL then
		self.angerSkill = nil
	elseif index == 0 then
		self.autoSkills = nil
		self.angerSkill = nil
	end
end

function BaseSoldier:changeSkill(skillGroupId)
	if self.changeSkillFlag then
		return
	end
	local skillGroupInfo = GameData:getConfData("skillgroup")[skillGroupId]
	if skillGroupInfo == nil then
		return
	end
	self.changeSkillFlag = true
	if skillGroupInfo.baseSkill > 0 then -- 普通攻击
		local baseSkillUsedTimes = 0
		if self.baseSkill then
			self._baseSkill = self.baseSkill
			baseSkillUsedTimes = self.baseSkill:getUsedTimes()
		end
		self.baseSkill = self:createSkill(skillGroupInfo.baseSkill, SKILL_TYPE.NORMAL_ATTACK)
		self.baseSkill:setUsedTimes(baseSkillUsedTimes)
	end
	if skillGroupInfo.autoSkill1 > 0 then -- 触发技能
		if self.autoSkills then
			self._autoSkills = self.autoSkills
			self._autoSkillTimes = self.autoSkillTimes
		end
		self.autoSkills = self:createSkill(skillGroupInfo.autoSkill1 + self.skillLevel - 1, SKILL_TYPE.AUTO_SKILL)
		self.autoSkillTimes = skillGroupInfo.autoSkillTimes1
	end
	if skillGroupInfo.angerSkill > 0 then -- 手动技能
		if self.angerSkill then
			self._angerSkill = self.angerSkill
		end
		self.angerSkill = self:createSkill(skillGroupInfo.angerSkill + self.skillLevel - 1, SKILL_TYPE.ANGER_SKILL)
	end
end

function BaseSoldier:changeSkillForever(skillGroupId)
	local skillGroupInfo = GameData:getConfData("skillgroup")[skillGroupId]
	if skillGroupInfo == nil then
		return
	end
	if skillGroupInfo.baseSkill > 0 then -- 普通攻击
		local baseSkillUsedTimes = 0
		if self.baseSkill then
			baseSkillUsedTimes = self.baseSkill:getUsedTimes()
		end
		self.baseSkill = self:createSkill(skillGroupInfo.baseSkill, SKILL_TYPE.NORMAL_ATTACK)
		self.baseSkill:setUsedTimes(baseSkillUsedTimes)
	end
	if skillGroupInfo.autoSkill1 > 0 then -- 触发技能
		self.autoSkills = self:createSkill(skillGroupInfo.autoSkill1 + self.skillLevel - 1, SKILL_TYPE.AUTO_SKILL)
		self.autoSkillTimes = skillGroupInfo.autoSkillTimes1
	end
	if skillGroupInfo.angerSkill > 0 then -- 手动技能
		self.angerSkill = self:createSkill(skillGroupInfo.angerSkill + self.skillLevel - 1, SKILL_TYPE.ANGER_SKILL)
	end
end

function BaseSoldier:resetSkill()
	if self.changeSkillFlag then
		self.changeSkillFlag = false
		local baseSkillUsedTimes = 0
		if self.baseSkill then
			baseSkillUsedTimes = self.baseSkill:getUsedTimes()
		end
		self.baseSkill = self._baseSkill
		self.baseSkill:setUsedTimes(baseSkillUsedTimes)
		self.angerSkill = self._angerSkill
		self.autoSkills = self._autoSkills
		self.autoSkillTimes = self._autoSkillTimes
	end
end

function BaseSoldier:resetSkillLoop()
	self.skillLoopOver = false
	self.baseSkill:resetUsedTimes()
end

-- 一套技能循环是否结束(只包括普攻加自动技能)
function BaseSoldier:isSkillLoopOver()
	return self.skillLoopOver
end

function BaseSoldier:getAvailableSkill()
	return self.specialAI:getAvailableSkill(self)
end

function BaseSoldier:prepare()
	self.specialAI:prepare(self)
end

function BaseSoldier:searchTarget(forceFlag, moveFlag)
	local haveTarget = self:checkTarget(forceFlag)
	if haveTarget then
		return
	end
	self.specialAI:searchTarget(self, forceFlag, moveFlag)
end

-- 设置状态
function BaseSoldier:setStatus(status)
	if status == SOLDIER_STATUS.DEAD then
		self.status = status
		return
	end
	if self.status == SOLDIER_STATUS.DEAD or self.status == SOLDIER_STATUS.OVER then
		return
	end
	self.status = status
	if status == SOLDIER_STATUS.ATTACK then
		if self.currSkill then
			return
		end
		if self.lockEnemy then
			local x1, y1 = self:getPosition()
			local x2, y2 = self.lockEnemy:getPosition()
			if x1 < x2 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
		end
		if self.moveToOther then
			self:stopMove()
		end
		self:checkAttackCD()
	elseif status == SOLDIER_STATUS.LOSE_TARGET then
		self:searchTarget(false, true)
	elseif status == SOLDIER_STATUS.MOVE_TO_TARGET then
		self:moveToLockTarget()
	end
end

function BaseSoldier:checkTarget(forceFlag)
	if self:isDead() then
		return true
	end
	if forceFlag then -- 如果强制换目标
		return false
	end
	if self.lockEnemy then
		if self.lockEnemy:isDead() then
			return false
		else
			return true
		end
	else
		return false
	end
end

-- 集合
function BaseSoldier:moveTogether(pos, callback)
	if self.currSkill then
		self.moveAfterAttack = 1
		return
	end
	if self.limitMove > 0 then
		return
	end
	local targetPos = cc.pAdd(pos, self.offsetPos)
	local x, y = self:getPosition()
	if x < targetPos.x then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end
	local time = getDistance(x, y, targetPos.x, targetPos.y)/self.moveSpeed
	if time > 0.01 then
		self:setEffectNodePosition(cc.p(x, y))
		self:runMoveAction(time, targetPos, function ()
			if self.guid == 1 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
			self:playAction("idle", true)
			if callback then
				callback()
			end
		end, 1)
	end
end

function BaseSoldier:moveToByLegion(pos, callback)
	if self.currSkill then
		self.moveAfterAttack = 1
		return
	end
	if self.limitMove > 0 then
		return
	end
	local x, y = self:getPosition()
	if x < pos.x then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end
	local time = getDistance(x, y, pos.x, pos.y)/self.moveSpeed
	if time < 0.01 then -- 就在目标点附近
		if self.attackType == 2 then
			self:setStatus(SOLDIER_STATUS.ATTACK)
		else
			self:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
		end
	else
		self.moveToOther = true
		self.minDistance = MIN_DISTANCE
		self.recalculateTime = RECALCULATE_TIME
		self:setEffectNodePosition(cc.p(x, y))
		self:runMoveAction(time, cc.pAdd(pos, self.offsetPos), function ()
			self.moveToOther = false
			if callback then
				callback()
			else
				if self.attackType == 2 then
					self:setStatus(SOLDIER_STATUS.ATTACK)
				else
					self:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
				end
			end
		end, 1)
	end
end

function BaseSoldier:moveToBySelf(pos, time)
	if self.currSkill then
		self.moveAfterAttack = 2
		return
	end
	local x, y = self:getPosition()
	if x < pos.x then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end
	if self.attackType == 1 then -- 近战移动冲锋
		time = time * 0.7
	end
	self.moveToOther = true
	self.minDistance = MIN_DISTANCE
	self.recalculateTime = RECALCULATE_TIME
	self:setEffectNodePosition(cc.p(x, y))
	self:runMoveAction(time, pos, function ()
		self.moveToOther = false
		self.specialAttackRange = true
		self:setStatus(SOLDIER_STATUS.ATTACK)
		self.specialAttackRange = false
	end, 2)
end

function BaseSoldier:moveToLockTarget()
	local target = self.lockEnemy
	if target == nil or target:isDead() then
		self:setStatus(SOLDIER_STATUS.LOSE_TARGET)
		return
	end
	if self.limitMove > 0 then
		return
	end
	if self.targetLockMe then -- 如果是相互朝着对方移动
		local pos = self:getFinalPosition()
		if pos == nil then
			pos = self:calculateFinalPosition()
		end
		if self.costTime < 0.01 then
			self.finalPosition = nil
			self.costTime = 0
			self:setStatus(SOLDIER_STATUS.ATTACK)
		else
			self:moveToBySelf(pos, self.costTime)
			self.finalPosition = nil
			self.costTime = 0
		end
	else
		if self.attackType == 2 then -- 如果我是远程
			local x1, y1 = self:getPosition()
			local x2, y2 = target:getPosition()
			local d = getDistance(x1, y1, x2, y2)
			if d <= self.attackRange then -- 如果在射程内就直接攻击
				self:setStatus(SOLDIER_STATUS.ATTACK)
			else -- 不在射程内
				local nd = d - self.attackRange --需要移动的距离
				local ty = nd*(y2-y1)/d + y1
				local tx = nd*(x2-x1)/d + x1
				local costTime = nd/self.moveSpeed
				self:moveToBySelf(cc.p(tx, ty), costTime)
			end
		else -- 如果我是近战, 就移动到对方的正前方或者正后方在攻击
			local x1, y1 = self:getPosition()
			local x2, y2 = target:getPosition()
			local direction = target:getDirection()
			local x3 = x2 + self.attackRange*self.standDir*direction
			local y3 = y2
			local d = getDistance(x1, y1, x3, y3)
			local costTime = d/self.moveSpeed
			self:moveToBySelf(cc.p(x3, y3), costTime)
		end
	end
end

function BaseSoldier:recheckTargetPos(dt)
	self.recalculateTime = self.recalculateTime - dt
	if self.recalculateTime < 0 then
		self.recalculateTime = RECALCULATE_TIME
		self:moveToLockTarget()
	end
end

function BaseSoldier:moveToBySkill(timeType, pos, scale, func)
	if self.limitMove > 0 then
		return false
	end
	self.moveToOther = false
	self.moveAfterAttack = 0
	local x, y = self:getPosition()
	if x < pos.x then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end
	local time
	if timeType == 1 then
		local dis = getDistance(pos.x, pos.y, x, y)
		time = dis/self.moveSpeed/scale
	else
		time = scale
	end
	self:setEffectNodePosition(cc.p(x, y))
	self:runMoveAction(time, pos, function ()
		if func then
			func()
		end
	end)
	return true
end

function BaseSoldier:beforeAttack()
	if self.lockEnemy == nil or self.lockEnemy:isDead() then
		return false, SOLDIER_STATUS.LOSE_TARGET
	end
	if self.limitAtt > 0 then
		return false, -1
	end
	if not self:checkAttack() then
	 	return false, SOLDIER_STATUS.MOVE_TO_TARGET
	end
	return true, -1
end

-- 取消与其有关的所有锁定
function BaseSoldier:cancelAllLock()
	local lockEnemy = self.lockEnemy
	if lockEnemy then
		if lockEnemy:getTargeLockMe() then
			lockEnemy:setTargetLockMe(false)
		end
		self.lockEnemy = nil
		self:effectWhenCancelLock()
		lockEnemy:unlockBySoldier(self)
		for k, v in ipairs(lockEnemy.beLockedEnemyArr) do
			if v == self then
				table.remove(lockEnemy.beLockedEnemyArr, k)
				if self.soldierType == 1 and self.attackType == 1 then
					lockEnemy.beLockedHeroNum = lockEnemy.beLockedHeroNum - 1
				end
				break
			end
		end
	end
end

function BaseSoldier:effectWhenCancelLock()
	if self.talentSkill then
		self.talentSkill:effectWhenCancelLock()
	end
end

function BaseSoldier:unlockBySoldier(target)
	if self.talentSkill then
		self.talentSkill:effectWhenUnlockBySoldier(target)
	end
end

-- 检查目标是否在攻击范围，如果在，进行攻击
function BaseSoldier:checkAttack()
	local enemy = self.lockEnemy
	local x1, y1 = self:getPosition()
	local x2, y2 = enemy:getPosition()
	local l = getDistance(x1, y1, x2, y2)
	local flag = false
	if self:getTargeLockMe() then -- 互为目标
		if self.attackType == 1 and enemy.attackType == 1 then -- 都是近战
			if l <= (self.attackRange + enemy.attackRange)/2 + self.rangeOffset then
				flag = true
			end
		else
			if l <= self.attackRange + self.rangeOffset then -- 加点容错
				flag = true
			end
		end
	else
		if self.attackType ~= 1 or math.abs(y1 - y2) < self.attackRange/2 then
			if self.specialAttackRange then
				if l <= self.attackRange + self.rangeOffset*3 then -- 加点容错
					flag = true
				end
			else
				if l <= self.attackRange + self.rangeOffset then -- 加点容错
					flag = true
				end
			end
		end
	end
	return flag
end

-- 使用技能
function BaseSoldier:useSkill(skillObj)
	self:recordUseSkill(skillObj)
	self:stopAllActions()
	self.currSkill = skillObj
	if self.currSkill:isNeedShout() then
		self:showSkillShout()
		self:showSkillLight()
	end
	skillObj:useSkill()
	if self.talentSkill then
		self.talentSkill:effectWhenUseSkill(skillObj)
	end
	self:playAction(skillObj:getActionName(), false, true) -- 有些攻击是第一帧就生效
	skillObj:afterPlaySkillAnimation()
end

function BaseSoldier:recordUseSkill(skillObj)
end

function BaseSoldier:playAction(actionName, repeatFlag, needIdle)
	if self.pauseFlag then
		return
	end
	if repeatFlag and actionName == self.currAction then
		return
	end
	if repeatFlag then
		self:playAnimation(actionName, 1)
	else
		self:playAnimation(actionName, -1)
	end
	self.currAction = actionName
	self.needIdle = needIdle
end

-- 获取最终效果
-- @flag: 1--免疫,2--闪避,3--暴击,4--反弹,5--吸血
function BaseSoldier:getEffect(atker, hpNum, showNum, flag, skillType, damageCoefficient, addAnger, skillOrBuffId)
	if self.battlefield:isBattleEnd() then
		return
	end
	atker:addDamageCount(hpNum, atker.guid, damageCoefficient)
	if self:isDead() then
		return
	end
	self:recordDmgInReport(atker, hpNum, showNum, flag, skillType, skillOrBuffId)
	if self.beAttackDieTimes then
		if hpNum < 0 then
			self.beAttackDieTimes = self.beAttackDieTimes - 1
			if self.beAttackDieTimes <= 0 then
				self:die(atker)
			end
		end
	else
		if hpNum ~= 0 then
			if self.soldierType < 3 then
				if hpNum + self.hp < 0 then -- 伤害溢出
					self.battlefield:addPlayerHealth(self.guid, -self.hp, self.soldierType)
				elseif hpNum + self.hp > self.maxHp then -- 加血溢出
					self.battlefield:addPlayerHealth(self.guid, self.maxHp - self.hp, self.soldierType)
				else
					self.battlefield:addPlayerHealth(self.guid, hpNum, self.soldierType)
				end
			end
			self.hp = self.hp + hpNum
			if self.hp <= 0 then
				self.hp = 0
				self:effectWhenChangeHp()
				self:die(atker)
			else
				if self.hp > self.maxHp then
					self.hp = self.maxHp
				end
				self:effectWhenChangeHp()
				if self.soldierType == 1 then
					self:showHpBar()
					if skillType > 1 and hpNum < 0 and self.currAction == "idle" then
						self:playAction("hit", false, true)
					end
				elseif showNum then
					self:showHpBar()
				end
				if hpNum < 0 and addAnger then
					self:addMp(-hpNum)
				end
			end
			self:setHpBarPercent(hpNum)
		end
	end
	self:showDamage(showNum, hpNum, flag)
end

-- 停止攻击
function BaseSoldier:stop()
	if self:isDead() then
		return
	end
	self:stopAttack(0)
	self:stopAllActions()
	self:playAction("idle", true)
end

function BaseSoldier:battleOver(playWinAction)
	self:setStatus(SOLDIER_STATUS.OVER)
	self:removeBuffs()
	if playWinAction then
		if self.currSkill then
			self.playWinAction = true
		else
			if self.guid == 1 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
			self:stop()
			self:playAction("shengli", true)
		end
	else
		self:stop()
	end
end

function BaseSoldier:effectWhenKillTarget(target)
	if self.talentSkill then
		self.talentSkill:effectWhenKillTarget(target)
	end
end

function BaseSoldier:effectWhenDie(killer)
	if self.talentSkill then
		self.talentSkill:effectWhenDie(killer)
	end
end

function BaseSoldier:effectWhenSummon(summon)
	if self.talentSkill then
		self.talentSkill:effectWhenSummon(summon)
	end
end

function BaseSoldier:playDeadSound()
	if self.deadEffect and self.deadEffect ~= "0" then
		BattleHelper:playDeadSound(self.deadEffect)
	end
end

function BaseSoldier:die(atker)
	if self:isDead() then
		return
	end
	if self.selectEnable > 0 then
		self:removeBuffs()
		self:stopAttack(0)
		self:stopAllActions()
		self:playAction("dead")
		self:setStatus(SOLDIER_STATUS.DEAD)
		atker:effectWhenKillTarget(self)
		self:effectWhenDie(atker)
		local x, y = self:getPosition()
		local legionObj = self.legionObj
		legionObj:die(cc.p(x, y), self.soldierType, self.soldierIndex) -- 军队数量减一
		self:cancelAllLock() -- 取消锁定
		if legionObj:isDead() then -- 部队被消灭
			for k2, v2 in ipairs(self.beLockedEnemyArr) do
				if not v2.needIdle then -- 如果当前动画不是需要完成之后才做休闲动画，直接做休闲动画
					v2:playAction("idle", true)
				end
				v2.lockEnemy = nil
				v2:effectWhenCancelLock()
				self:unlockBySoldier(v2)
			end
			legionObj:cancelAllLockWhenDie()
		else
			if self.isLeader then
				legionObj:changeLeader()
			end
			for k2, v2 in ipairs(self.beLockedEnemyArr) do
				v2.lockEnemy = nil
				v2:effectWhenCancelLock()
				self:unlockBySoldier(v2)
				self.battlefield:addChangeTargetSoldier(v2.guid, v2.legionObj.pos, v2)
			end
		end
		self.beLockedEnemyArr = {}
		self.beLockedHeroNum = 0
		self:setHpBarVis(false)
		if self.soldierType == 1 then
			self:clearMp() -- 清除怒气
			if legionObj.guid == 2 then -- 敌方英雄死亡，播放死亡动画
				self:playKillAnimation(x, y)
			end
			if atker and atker.legionObj.headpic then
				self.battlefield:addKillAnimation(self.guid, legionObj.pos, legionObj.headpic, atker.legionObj.headpic)
			else
				self.battlefield:addKillAnimation(self.guid, legionObj.pos, legionObj.headpic)
			end
			BattleMgr:setLegionDieAnimation(self.guid, legionObj.pos, legionObj.headpic, atker.legionObj.headpic)
			self:playDeadSound()
		end
		if self.summons then
			for k, v in ipairs(self.summons) do
				if not v:isDead() then
					v:die(v)
				end
			end
			self.summons = nil
		end
		legionObj:battleEnd() -- 判断战斗是否结束
	else
		self:removeBuffs()
		self:stopAttack(0)
		self:stopAllActions()
		self:playAction("dead")
		self:setStatus(SOLDIER_STATUS.DEAD)
		self:setHpBarVis(false)
		self:hideSoldier()
	end
	self:removeAllAnimation()
	self:recordDie(atker)
end

function BaseSoldier:removeAllAnimation()
	if self.godAni then
		self.godAni:removeFromParent()
		self.godAni = nil
	end
end

function BaseSoldier:hideSoldier()
	self.root:setVisible(false)
end

function BaseSoldier:recordDie(atker)
end

function BaseSoldier:addLimitStatus(limitMove, limitAtt, limitSkill)
	if limitMove > 0 then
		if self.limitMove <= 0 then
			if self.currAction == "run" or self.currAction == "walk" then
				self:playAction("idle", true)
			end
			self:stopMove()
			if self.lockEnemy and self.lockEnemy:getTargeLockMe() then
				self.lockEnemy:setFinalPosition(nil)
			end
		end
		self.limitMove = self.limitMove + limitMove
	end
	if limitAtt > 0 then
		if self.limitAtt <= 0 then
			self:stopAttack(0)
		end
		self.limitAtt = self.limitAtt + limitAtt
	end
	if limitSkill > 0 then
		if self.limitSkill <= 0 then
			self:stopAttack(2)
		end
		self.limitSkill = self.limitSkill + limitSkill
	end
end

-- 移除控制状态
function BaseSoldier:removeLimitStatus(limitMove, limitAtt, limitSkill)
	self.limitMove = self.limitMove - limitMove
	self.limitAtt = self.limitAtt - limitAtt
	self.limitSkill = self.limitSkill - limitSkill
	if self:isDead() then
		return
	end
	if self.limitAtt <= 0 and limitAtt > 0 then -- 重新可以攻击
		if self.status == SOLDIER_STATUS.ATTACK then
			if self.lockEnemy == nil or self.lockEnemy:isDead() then
				self:setStatus(SOLDIER_STATUS.LOSE_TARGET)
			else
				self:setStatus(SOLDIER_STATUS.ATTACK)
			end
		end
	end
	if self.limitMove <= 0 and limitMove > 0 then -- 重新可以移动
		if self.status ~= SOLDIER_STATUS.ATTACK then
			if self.legionObj:isWait() then
				self:moveTogether(self.legionObj.moveToPos)
			else
				if self.legionObj:isMovingByLegion() then
					self:moveToByLegion(self.legionObj.moveToPos)
				else
					self:setFinalPosition(nil)
					if self.lockEnemy and self.lockEnemy:getTargeLockMe() and self.lockEnemy.moveToOther then
						self.lockEnemy:setFinalPosition(nil)
						self.lockEnemy:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
					end
					self:moveToLockTarget()
				end
			end
		end
	end
end

-- 锁定一个单位
function BaseSoldier:onLock(obj_, moveFlag)
	if obj_ then
		self.finalPosition = nil
		self.moveToOther = false
		self:cancelAllLock()
		self.lockEnemy = obj_
		if self.talentSkill then
			self.talentSkill:effectWhenLockTarget(obj_)
		end
		if obj_.lockEnemy == self then -- 如果相互为目标
			self.targetLockMe = true
			obj_:onLocked(self, true)
		else
			self.targetLockMe = false
			obj_:onLocked(self)
			if self.legionObj.sneakFlag then -- 绕后攻击状态
				self.standDir = -1
			else
				local lockNum
				if self.soldierType == 1 and obj_.soldierType == 1 then -- 如果都是英雄单位
					lockNum = obj_.beLockedHeroNum
				else
					lockNum = #obj_.beLockedEnemyArr
				end
				if lockNum%2 == 0 then -- 加上我自己一共有偶数个单位攻击对方
					self.standDir = -1
				else
					self.standDir = 1
				end
			end
		end
		if self.attackType == 1 then -- 近战根据目标的体型改变自己的攻击范围
			self.attackRange = self.baseAttackRange + obj_.bodySize
		end
		if moveFlag then
			if self.currSkill then
				self.moveAfterAttack = 2
			elseif not self.legionObj.sneakFlag then
				self:setStatus(SOLDIER_STATUS.MOVE_TO_TARGET)
			end
		end
	end
end

-- 被一个单位锁定
function BaseSoldier:onLocked(obj_, flag)
	if flag then
		self.targetLockMe = true
	end
	table.insert(self.beLockedEnemyArr, obj_)
	if obj_.soldierType == 1 and obj_.attackType == 1 then
		self.beLockedHeroNum = self.beLockedHeroNum + 1
	end
	if self.talentSkill then
		self.talentSkill:effectWhenLockedBySoldier(obj_)
	end
end

function BaseSoldier:removeBuffs()
	for i, buff in ipairs(self.buffList) do
		buff:remove()
	end
	self.buffList = {}
end

-- 延长buff
function BaseSoldier:extendBuffById(id)
	for i, buff in ipairs(self.buffList) do
		if buff.sid == id then
			buff:reset()
			break
		end
	end
end

function BaseSoldier:removeBuffById(id)
	for i, buff in ipairs(self.buffList) do
		if buff.sid == id then
			buff:remove()
			table.remove(self.buffList, i)
			break
		end
	end
end

-- 驱散buff
function BaseSoldier:dispelBuff(_type)
	if _type == 3 then -- 驱散所有buff
		local buffListNum = #self.buffList
		for i = buffListNum, 1, -1 do
			local buff = self.buffList[i]
			if buff.baseInfo.type == 1 and buff.baseInfo.dirType < 3 then
				buff:remove()
				table.remove(self.buffList, i)
			end
		end
	else -- 驱散正面或者负面的buff
		local buffListNum = #self.buffList
		for i = buffListNum, 1, -1 do
			local buff = self.buffList[i]
			if buff.baseInfo.type == 1 and buff.baseInfo.dirType == _type then
				buff:remove()
				table.remove(self.buffList, i)
			end
		end
	end
end

function BaseSoldier:setCostTime(time)
	self.costTime = time
end

function BaseSoldier:calculateFinalPosition()
	local target = self.lockEnemy
	local x1, y1 = self:getPosition()
	local x2, y2 = target:getPosition()
	if self.attackType == 1 and target.attackType == 1 then -- 都是近战
		local direction = 1
		if x1 > x2 then
			direction = -1
		end
		local attackRange = (self.attackRange + target.attackRange)/2*direction
		local targetSpeed = target.limitMove > 0 and 0 or target.moveSpeed
		local x3 = self.moveSpeed/(self.moveSpeed+targetSpeed)*(x2-x1-attackRange) + x1
		local y3 = targetSpeed/(self.moveSpeed+targetSpeed)*(y1 - y2) + y2 + self.ypHero
		self.ypHero = 0
		target.ypHero = 0
		local x4 = x3 + attackRange
		local finalPos = cc.p(x3, y3)
		local d = getDistance(x1, y1, x3, y3)
		local costTime = d/self.moveSpeed
		self:setFinalPosition(finalPos)
		target:setFinalPosition(cc.p(x4, y3))
		self:setCostTime(costTime)
		target:setCostTime(costTime)
		return finalPos
	elseif self.attackType == 2 and target.attackType == 2 then -- 都是远程
		local d = getDistance(x1, y1, x2, y2)
		if d > self.attackRange and d > target.attackRange then -- 如果双方都在对方的射程外
			local longerRange = nil
			local costTime1 = nil
			local costTime2 = nil
			local targetSpeed = target.limitMove > 0 and 0 or target.moveSpeed
			if self.attackRange > target.attackRange then
				longerRange = self.attackRange
				local rangeDis = self.attackRange - target.attackRange
				costTime1 = (d - longerRange)/(self.moveSpeed + targetSpeed)
				costTime2 = costTime1 + rangeDis/target.moveSpeed
			elseif self.attackRange < target.attackRange then
				longerRange = target.attackRange
				local rangeDis = target.attackRange - self.attackRange
				costTime2 = (d - longerRange)/(self.moveSpeed + targetSpeed)
				costTime1 = costTime2 + rangeDis/self.moveSpeed
			else
				longerRange = self.attackRange
				costTime1 = (d - longerRange)/(self.moveSpeed + targetSpeed)
				costTime2 = costTime1
			end
			local x3 = (x2 - x1)*self.moveSpeed*costTime1/d + x1
			local y3 = (y2 - y1)*self.moveSpeed*costTime1/d + y1
			local x4 = (x2 - x1)*(d - targetSpeed*costTime2)/d + x1
			local y4 = (y2 - y1)*(d - targetSpeed*costTime2)/d + y1
			if costTime1 < costTime2 then -- 我先到达目的地
				y3 = y3 + self.ypHero
			elseif costTime1 > costTime2 then
				y4 = y4 + target.ypHero
			else
				y3 = y3 + self.ypHero
				y4 = y4 + self.ypHero
			end
			self.ypHero = 0
			target.ypHero = 0
			local finalPos = cc.p(x3, y3)
			self:setFinalPosition(finalPos)
			target:setFinalPosition(cc.p(x4, y4))
			self:setCostTime(costTime1)
			target:setCostTime(costTime2)
			return finalPos
		else -- 只有一方在射程内，或者都在射程内
			local costTime1 = 0
			local x3 = x1
			local y3 = y1
			local costTime2 = 0
			local x4 = x2
			local y4 = y2
			if d > self.attackRange then -- 我在射程外
				costTime1 = (d - self.attackRange)/self.moveSpeed
				x3 = (x2 - x1)*self.moveSpeed*costTime1/d + x1
				y3 = (y2 - y1)*self.moveSpeed*costTime1/d + y1
			end
			if d > target.attackRange and target.limitMove <= 0 then -- 他在射程外
				costTime2 = (d - target.attackRange)/target.moveSpeed
				x4 = (x2 - x1)*(d - target.moveSpeed*costTime2)/d + x1
				y4 = (y2 - y1)*(d - target.moveSpeed*costTime2)/d + y1
			end
			self.ypHero = 0
			target.ypHero = 0
			local finalPos = cc.p(x3, y3)
			self:setFinalPosition(finalPos)
			target:setFinalPosition(cc.p(x4, y4))
			self:setCostTime(costTime1)
			target:setCostTime(costTime2)
			return finalPos
		end
	else -- 一个远程一个近战
		local d = getDistance(x1, y1, x2, y2) 
		if self.attackType == 2 then -- 我是远程
			if d > self.attackRange then -- 我在射程外
				local longerRange = self.attackRange
				local targetSpeed = target.limitMove > 0 and 0 or target.moveSpeed
				local costTime1 = (d - longerRange)/(self.moveSpeed + targetSpeed)
				local x3 = (x2 - x1)*self.moveSpeed*costTime1/d + x1
				local y3 = (y2 - y1)*self.moveSpeed*costTime1/d + y1 + self.ypHero
				local finalPos = cc.p(x3, y3)
				self:setFinalPosition(finalPos)
				self:setCostTime(costTime1)
				local x4
				if x1 < x2 then
					x4 = x3 + target.attackRange
				else
					x4 = x3 - target.attackRange
				end
				local y4 = y3
				self.ypHero = 0
				target.ypHero = 0
				local costTime2 = 0
				if targetSpeed > 0 then
					costTime2 = getDistance(x2, y2, x4, y4)/targetSpeed
				end
				target:setFinalPosition(cc.p(x4, y4))
				target:setCostTime(costTime2)
				return finalPos
			else -- 我在射程内
				self:setFinalPosition(cc.p(x1, y1))
				self:setCostTime(0)
				local x4
				if x1 < x2 then
					x4 = x1 + target.attackRange
				else
					x4 = x1 - target.attackRange
				end
				local y4 = y1
				self.ypHero = 0
				target.ypHero = 0
				local costTime2 = 0
				if target.moveSpeed > 0 then
					costTime2 = getDistance(x2, y2, x4, y4)/target.moveSpeed
				end
				target:setFinalPosition(cc.p(x4, y4))
				target:setCostTime(costTime2)
				return cc.p(x1, y1)
			end
		else -- 对方是远程
			if d > target.attackRange then -- 对方在射程外
				local longerRange = target.attackRange
				local targetSpeed = target.limitMove > 0 and 0 or target.moveSpeed
				local costTime2 = (d - longerRange)/(self.moveSpeed + targetSpeed)
				local x4 = (x1 - x2)*targetSpeed*costTime2/d + x2
				local y4 = (y1 - y2)*targetSpeed*costTime2/d + y2 + target.ypHero
				target:setFinalPosition(cc.p(x4, y4))
				target:setCostTime(costTime2)
				local x3
				if x1 < x2 then
					x3 = x4 - self.attackRange
				else
					x3 = x4 + self.attackRange
				end
				local y3 = y4
				self.ypHero = 0
				target.ypHero = 0
				local finalPos = cc.p(x3, y3)
				local costTime1 = getDistance(x1, y1, x3, y3)/self.moveSpeed
				self:setFinalPosition(finalPos)
				self:setCostTime(costTime1)
				return finalPos
			else -- 对方在射程内
				target:setFinalPosition(cc.p(x2, y2))
				target:setCostTime(0)
				local x3
				if x1 < x2 then
					x3 = x2 - self.attackRange
				else
					x3 = x2 + self.attackRange
				end
				local y3 = y2
				self.ypHero = 0
				target.ypHero = 0
				local costTime1 = getDistance(x1, y1, x3, y3)/self.moveSpeed
				self:setFinalPosition(cc.p(x3, y3))
				self:setCostTime(costTime1)
				return cc.p(x3, y3)
			end
		end
	end
end

function BaseSoldier:breakSkill()
	self:restoreScale()
end

function BaseSoldier:stopAttack(skillType)
	if skillType == 0 then -- 所有攻击
		if self.currSkill then
			if not self.currSkill:isFinished() then
				self.currSkill:breaked()
			end
			self.currSkill = nil
			self:breakSkill()
			self:playAction("idle", true)
		end
	elseif skillType == 1 then -- 普攻
		if self.currSkill and self.currSkill == self.baseSkill then
		 	if not self.currSkill:isFinished() then
				self.currSkill:breaked()
			end
			self.currSkill = nil
			self:breakSkill()
			self:playAction("idle", true)
		end
	elseif skillType == 2 then -- 非普攻
		if self.currSkill and self.currSkill ~= self.baseSkill then
			if not self.currSkill:isFinished() then
				self.currSkill:breaked()
			end
			self.currSkill = nil
			self:breakSkill()
			self:playAction("idle", true)
		end
	end
end

function BaseSoldier:isDead()
	return self.status == SOLDIER_STATUS.DEAD
end

function BaseSoldier:setLeader(isLeader)
	self.isLeader = isLeader
end

function BaseSoldier:isLeader()
	return self.isLeader
end

function BaseSoldier:checkEnemyTargetIsMe()
	if self.lockEnemy and self.lockEnemy.lockEnemy and self.lockEnemy.lockEnemy == self then
		return true
	end
	return false
end

function BaseSoldier:getTargeLockMe()
	return self.targetLockMe
end

function BaseSoldier:setTargetLockMe(flag)
	self.targetLockMe = flag
end

function BaseSoldier:addDamageCount(num, guid, damageCoefficient)
	local dmgNum = num
	if dmgNum > 0 then -- 加血统计
		self.damageCount[1] = self.damageCount[1] + dmgNum
	else -- 伤害统计
		dmgNum = dmgNum/damageCoefficient
		self.damageCount[2] = self.damageCount[2] - dmgNum
	end
	self.legionObj:addDamageCount(dmgNum, guid, self.soldierType)
end

function BaseSoldier:getDamageCount()
	return self.damageCount
end

function BaseSoldier:addHurtCount(num)
	self.hurtCount = self.hurtCount - num
	self.legionObj:addHurtCount(num, self.soldierType)
end

function BaseSoldier:getHurtCount()
	return self.hurtCount
end

function BaseSoldier:getPlayingAction()
	return self.currAction
end

function BaseSoldier:addMp(mpNum)
	if self.soldierType == 1 then
		if mpNum > 0 then
			self.mp = self.mp + mpNum*(1 + self.recoverMp)
		else
			self.mp = self.mp + mpNum
		end
		if self.mp <= 0 then
			self.mp = 0
		elseif self.mp >= self.maxMp then
			self.mp = self.maxMp
		end
		local percent = self.mp*100/self.maxMp
		if self.mpBar then
			self.mpBar:setPercent(percent)
		end
		self:recordMp(percent)
	end
end

function BaseSoldier:recordMp(percent)
end

function BaseSoldier:addMpPercentage(p)
	self:addMp(self.maxMp*p)
end

function BaseSoldier:clearMp()
	self:addMp(-self.maxMp)
end

-- 消耗怒气
function BaseSoldier:consumeMp()
	if self.soldierType == 1 then
		local remainMp = 0
		if self.talentSkill then
			remainMp = self.talentSkill:effectWhenConsumeMp()
		end
		self.mp = remainMp
		local percent = remainMp*100/self.maxMp
		if self.mpBar then
			self.mpBar:setPercent(remainMp/self.maxMp)
		end
		self:recordMp(percent)
	end
end

function BaseSoldier:setFinalPosition(pos)
	self.finalPosition = pos
end

function BaseSoldier:getFinalPosition()
	return self.finalPosition
end

function BaseSoldier:getRolePosOffset()
	return self.rolePosOffset
end

function BaseSoldier:useTalentSkillBeforeFight()
	if self.talentSkill then
		self.talentSkill:effectBeforeFight()
	end
end

function BaseSoldier:effectWhenHurtTarget(hpNum, flag, skillType, target)
	if self.talentSkill then
		return self.talentSkill:effectWhenHurtTarget(hpNum, flag, skillType, target)
	else
		return hpNum
	end
end

function BaseSoldier:effectWhenGetHurt(hpNum, flag, skillType, target)
	if self.talentSkill then
		return self.talentSkill:effectWhenGetHurt(hpNum, flag, skillType, target)
	else
		return hpNum
	end
end

function BaseSoldier:effectWhenLockedByLegion(legion)
	if self.talentSkill then
		self.talentSkill:effectWhenLockedByLegion(legion)
	end
end

function BaseSoldier:effectWhenCancelLockByLegion(legion)
	if self.talentSkill then
		self.talentSkill:effectWhenCancelLockByLegion(legion)
	end
end

function BaseSoldier:effectWhenChangeHp()
	if self.talentSkill then
		self.talentSkill:effectWhenChangeHp()
	end
end

function BaseSoldier:addBuffMode(modeId)
	if self.buffMode[modeId] == nil then
		self.buffMode[modeId] = 0
	end
	self.buffMode[modeId] = self.buffMode[modeId] + 1
end

function BaseSoldier:removeBuffMode(modeId)
	if self.buffMode[modeId] then
		self.buffMode[modeId] = self.buffMode[modeId] - 1
	end
end

function BaseSoldier:restoreScale()
	if self.rootScale ~= 1 then
		self.rootScale = 1
		self.root:setScale(1)
	end
end

function BaseSoldier:runMoveAction(time, pos, callback, dashFlag)
	local moveAct = cc.MoveTo:create(time, pos)
	local moveAct2 = cc.MoveTo:create(time, pos)
	moveAct2:setTag(MOVE_ACTION_TAG)
	local act1 = cc.Sequence:create(moveAct, cc.CallFunc:create(callback))
	act1:setTag(MOVE_ACTION_TAG)
	self.root:stopActionByTag(MOVE_ACTION_TAG)
	self.root:runAction(act1)
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
	self.effectNode:runAction(moveAct2)
	if dashFlag == 1 then -- 普通移动
		if self.soldierType == 2 then
			self:playAction("walk", true)
		else
			self:playAction("run", true)
		end
	elseif dashFlag == 2 then -- 加速移动
		self:playAction("run", true)
	end
end

function BaseSoldier:checkAttackCD()
	local waitTime = self.battlefield.time - self.attackFinishTime
	local attackSpeed = self.attackSpeed < self.minAttackSpeed and self.minAttackSpeed or self.attackSpeed
	if waitTime > attackSpeed then
		local flag, status = self:beforeAttack()
		if flag then
			local skill = self:getAvailableSkill()
			if skill == nil then
				self:playAction("idle", true)
			else
				self:useSkill(skill)
			end
		else
			if status == -1 then
				self:playAction("idle", true)
			else
				local act = cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
					self:setStatus(status)
				end))
				self.root:runAction(act)
				self:playAction("idle", true)
			end
		end
	else
		local act = cc.Sequence:create(cc.DelayTime:create(attackSpeed - waitTime), cc.CallFunc:create(function ()
			local flag, status = self:beforeAttack()
			if flag then
				local skill = self:getAvailableSkill()
				if skill == nil then
					self:playAction("idle", true)
				else
					self:useSkill(skill)
				end
			else
				if status == -1 then
					self:playAction("idle", true)
				else
					self:setStatus(status)
				end
			end
		end))
		self.root:runAction(act)
		self:playAction("idle", true)
	end
end

function BaseSoldier:playAnimation(name, loopType)
	self.armature:getAnimation():play(name, -1, loopType)
end

function BaseSoldier:showHpBar()
	local act1 = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ()
		self.hpNode:setVisible(false)
	end))
	self.hpNode:setVisible(true)
	act1:setTag(HP_ACTION_TAG)
	self.hpNode:stopActionByTag(HP_ACTION_TAG)
	self.hpNode:runAction(act1)
end

function BaseSoldier:setHpBarPercent(hpNum)
	local percent = self.hp*100/self.maxHp
	local hpBar
	local setBarAct = cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function ()
		hpBar:setPercent(percent)
	end))
	if hpNum > 0 then
		self.hpBarPre:setPercent(percent)
		hpBar = self.hpBar
		hpBar:runAction(setBarAct)
	else
		self.hpBar:setPercent(percent)
		hpBar = self.hpBarPre
		hpBar:runAction(setBarAct)
		self:addHurtCount(hpNum)
	end
end

function BaseSoldier:showDamage(showNum, hpNum, flag)
	if showNum then
		local x, y = self:getPosition()
		local obj = {
			hpNum = hpNum,
			flag = flag,
			pos = cc.p(x, y),
			hpBarHeight = self.hpBarHeight
		}
		self.battlefield:addDamageLabel(obj)
	end
end

function BaseSoldier:setHpBarVis(vis)
	self.hpNode:setVisible(vis)
end

function BaseSoldier:playKillAnimation(x, y)
	local killImg = ccui.ImageView:create('uires/ui/battle/battle_kill.png')
	killImg:setScale(1.5)
	killImg:setPosition(x, y + 80)
	self.battlefield.bgImg:addChild(killImg)
	BattleHelper:setZorder(killImg, y + 80, 2)
	killImg:runAction(cc.Sequence:create(
						cc.ScaleTo:create(0.2, 0.9),
						cc.DelayTime:create(1),
						cc.ScaleTo:create(0.1, 1),
						cc.FadeOut:create(0.2),
						cc.CallFunc:create(function ()
							killImg:removeFromParent()
						end)))
end

-- 随机喊话
function BaseSoldier:talkBySoldier()
	if self:isDead() then
		return
	end
	if math.random(500) > 1 then
		return
	end
	if self.isTalking then
		return
	end
	self.isTalking = true
	local talkNode = self.talkNode
	local function endFun()
		self.isTalking = false
		talkNode:setVisible(false)
	end
	local act = cc.Sequence:create(cc.ScaleTo:create(0.3, 1),
						cc.DelayTime:create(0.9),
						cc.FadeOut:create(0.2),
						cc.CallFunc:create(endFun))
	local url
	if self.guid == 1 then
		url = string.format("battle_say_1_%d.png", math.random(1, 4))
	else
		url = string.format("battle_say_2_%d.png", math.random(1, 4))
	end
	talkNode:setSpriteFrame(url)
	talkNode:setVisible(true)
	talkNode:setScale(0.2)
	talkNode:setOpacity(255)
	talkNode:stopAllActions()
	talkNode:runAction(act)
end

function BaseSoldier:talkByHero()
	if self:isDead() then
		return
	end
	if math.random(100) > 15 then
		return
	end
	if self.isTalking then
		return
	end
	self.isTalking = true
	local talkNode = self.talkNode
	local function endFun()
		self.isTalking = false
		talkNode:setVisible(false)
	end
	local act = cc.Sequence:create(cc.ScaleTo:create(0.2, 1),
						cc.DelayTime:create(0.9),
						cc.FadeOut:create(0.2),
						cc.CallFunc:create(endFun))
	self.talkLabel:setString(BattleHelper:getRandomTalk())
	talkNode:setVisible(true)
	talkNode:setScale(0.2)
	talkNode:setOpacity(255)
	talkNode:stopAllActions()
	talkNode:runAction(act)
end

function BaseSoldier:showSkillShout()
	if self.isTalking then
		self.isTalking = false
		self.talkNode:setVisible(false)
	end
	local shoutName = self.currSkill:getSkillShoutName()
	if shoutName == "0" then
		return
	end
	if shoutName ~= self.skillShoutName then
		self.skillShoutNode:setTexture("uires/ui/battle/shout/" .. shoutName)
		self.skillShoutName = shoutName
	end
	local dir = self:getDirection()
	self.skillShoutNode:setPosition(cc.p(-80*dir, self.hpBarHeight))
	self.skillShoutNode:setVisible(true)
	self.skillShoutNode:setScale(0.2)
	self.skillShoutNode:setOpacity(255)
	self.skillShoutNode:stopAllActions()
	self.skillShoutNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5),
						cc.ScaleTo:create(0.1, 1),
						cc.DelayTime:create(0.5),
						cc.FadeOut:create(0.3),
						cc.CallFunc:create(function ()
							self.skillShoutNode:setVisible(false)
						end)))
end

function BaseSoldier:showSkillLight()
	if self.guid == 1 then
		self.rootScale = 1.7
		self.root:setScale(self.rootScale)
		if self.skillLight then
			self.skillLight:setVisible(true)
			self.skillLight:getAnimation():playWithIndex(0, -1, 0)
		else
			self.skillLight = BattleHelper:createAniByName("ui_bishaji")
			self.skillLight:setScale(self.buffScale/100)
			self.skillLight:setPosition(cc.p(self.attPx_c, self.attPy_c))
			self.skillLight:setLocalZOrder(4)
			self.roleNode:addChild(self.skillLight)
			self.skillLight:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
				if movementType == 1 then
					self.skillLight:setVisible(false)
					self:updateZorder(self:getPositionY())
				end
			end)
			self.skillLight:getAnimation():playWithIndex(0, -1, 0)
		end
		self.battlefield:showSkillMask(self)
	end
end

function BaseSoldier:loseControl(buffId, moveType)
	if self.loseControlId > 0 then
		return
	end
	local act = self.roleNode:getActionByTag(LOSE_CONTROL_TAG)
	if act == nil then
		if moveType == 1 then -- 站原地不动
			self.rolePosOffset = cc.p(0, 0)
			self:pause()
		elseif moveType == 2 then -- 空中上下浮动
			self.rolePosOffset = cc.p(0, 90)
			act = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(0, 80)), cc.MoveTo:create(0.5, cc.p(0, 60))))
			act:setTag(LOSE_CONTROL_TAG)
			self.roleNode:runAction(act)
			if self.shadow then
				self.shadow:changeDisplayWithIndex(-1, true)
			end
		elseif moveType == 3 then -- 顶飞到空中
			self.rolePosOffset = cc.p(0, 0)
			act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveTo:create(0.15, cc.p(0, 80))), cc.EaseExponentialIn:create(cc.MoveTo:create(0.2, cc.p(0, 0))), cc.CallFunc:create(function ()
				if self.shadow then
					self.shadow:changeDisplayWithIndex(0, true)
				end
				self:removeLimitStatus(1, 1, 1)
			end))
			act:setTag(LOSE_CONTROL_TAG)
			self.roleNode:runAction(act)
			if self.shadow then
				self.shadow:changeDisplayWithIndex(-1, true)
			end
			self:addLimitStatus(1, 1, 1)
		end
		self.loseControlId = buffId
		self:addLimitStatus(1, 1, 1)
	end
end

function BaseSoldier:resumeControl(buffId, moveType)
	if self.loseControlId == buffId then
		self:removeLoseControlStatus(moveType)
	end
end

function BaseSoldier:removeLoseControlStatus(moveType)
	if moveType == 1 then
		self:resume()
		self.rolePosOffset = cc.p(0, 0)
		self.loseControlId = 0
		self:removeLimitStatus(1, 1, 1)
	elseif moveType == 2 then
		local act = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0, 0)), cc.CallFunc:create(function ()
			self.rolePosOffset = cc.p(0, 0)
			self.loseControlId = 0
			if self.shadow then
				self.shadow:changeDisplayWithIndex(0, true)
			end
			self:removeLimitStatus(1, 1, 1)
		end))
		act:setTag(LOSE_CONTROL_TAG)
		self.roleNode:stopActionByTag(LOSE_CONTROL_TAG)
		self.roleNode:runAction(act)
	elseif moveType == 3 then
		self.rolePosOffset = cc.p(0, 0)
		self.loseControlId = 0
		self:removeLimitStatus(1, 1, 1)
	end
end

function BaseSoldier:setPosition(position)
	self.root:setPosition(position)
	self.effectNode:setPosition(position)
end

function BaseSoldier:getPosition()
	return self.root:getPosition()
end

function BaseSoldier:getPositionX()
	return self.root:getPositionX()
end

function BaseSoldier:getPositionY()
	return self.root:getPositionY()
end

function BaseSoldier:updateZorder(posy)
	BattleHelper:setSoldierTag(self)
	BattleHelper:setSoldierZorder(self)
	BattleHelper:setSoldierHpZorder(self.effectNode, posy)
end

function BaseSoldier:setLocalZOrder(zOrder)
	self.root:setLocalZOrder(zOrder)
end

function BaseSoldier:setVisible(vis)
	self.root:setVisible(vis)
end

function BaseSoldier:getDirection()
	return self.roleNode:getScaleX()
end

function BaseSoldier:setDirection(scaleX)
	self.roleNode:setScaleX(scaleX)
end

function BaseSoldier:runSkillAction(action)
	self.roleNode:runAction(action)
end

function BaseSoldier:stopSkillAction(action)
	self.roleNode:stopAction(action)
end

function BaseSoldier:stopSkillActionByTag(tag)
	self.roleNode:stopActionByTag(tag)
end

function BaseSoldier:runAction(action)
	self.root:stopAllActions()
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
	self.moveToOther = false
	self.root:runAction(action)
end

function BaseSoldier:stopAllActions()
	self.finalPosition = nil
	self.root:stopAllActions()
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
	self.moveToOther = false
end

function BaseSoldier:stopMove()
	self.root:stopActionByTag(MOVE_ACTION_TAG)
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
	self.moveToOther = false
	self.finalPosition = nil
end

function BaseSoldier:showEffectNode()
	local x, y = self:getPosition()
	self.effectNode:setPosition(cc.p(x, y))
	self.effectNode:setVisible(true)
end

function BaseSoldier:setEffectNodePosition(position)
	self.effectNode:setPosition(position)
end

function BaseSoldier:pause()
	self.pauseFlag = true
	xx.Utils:Get():pauseArmatureAnimation(self.armature)
end

function BaseSoldier:resume()
	self.pauseFlag = false
	xx.Utils:Get():resumeArmatureAnimation(self.armature)
end

function BaseSoldier:remove()
	self.root:removeFromParent()
end

function BaseSoldier:showSuckAnimation()
	if self.suckBloodAni == nil then
		self.suckBloodAni = BattleHelper:createAniByName("buff_xixue_01")
		self.suckBloodAni:setScale(self.buffScale/100)
		self.suckBloodAni:setPosition(cc.p(self.attPx_c, self.attPy_c))
		self.suckBloodAni:setLocalZOrder(3)
		self.roleNode:addChild(self.suckBloodAni)
		self.suckBloodAni:getAnimation():playWithIndex(0, -1, 0)
		self.suckBloodAni:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
			if movementType == 1 then
				self.suckBloodAni:setVisible(false)
			end
		end)
	else
		self.suckBloodAni:getAnimation():playWithIndex(0, -1, 0)
		self.suckBloodAni:setVisible(true)
	end
end

function BaseSoldier:createBuff(sid, owner)
	ClassBattleBuff.new(sid, owner, self)
end

function BaseSoldier:createSkill(skillId, skillType)
	return ClassBattleSkill.new(skillId, self, skillType)
end

function BaseSoldier:addBuff(buff)
	table.insert(self.buffList, buff)
end

function BaseSoldier:finishRemoveBuff(sid)
end

function BaseSoldier:recordDmgInReport(atker, hpNum, showNum, flag, skillType, skillOrBuffId)
end

function BaseSoldier:dieAfterAWhile(time)
	self.armature:runAction(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(function ()
		self:die(self)
	end)))
end

function BaseSoldier:showBornAnimation()
	if self.summonInfo.appearEf ~= "0" then
		local appearEfNode = BattleHelper:createAniByName(self.summonInfo.appearEf)
		appearEfNode:setScale(self.summonInfo.appearEfScale/100)
		appearEfNode:setPosition(cc.p(self.summonInfo.posX, self.summonInfo.posY))
		if self.summonInfo.appearZorder == 2 then
			appearEfNode:setLocalZOrder(-1)
		end
		self.roleNode:addChild(appearEfNode)
		local function movementFun(armature, movementType, movementID)
			if movementType == 1 then
				appearEfNode:removeFromParent()
				self:searchTarget(false, true)
			end
		end
		appearEfNode:getAnimation():setMovementEventCallFunc(movementFun)
		appearEfNode:getAnimation():playWithIndex(0, -1, 0)
	else
		self:searchTarget(false, true)
	end
	BattleHelper:setSoldierTag(self, self.summonInfo.zorderType)
end

function BaseSoldier:moveToOtherPos(action)
	self.root:stopAllActions()
	self.root:runAction(action)
end

return BaseSoldier