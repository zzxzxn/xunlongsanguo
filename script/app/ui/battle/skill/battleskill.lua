local BulletMgr = require("script/app/ui/battle/skill/bulletmanager")
local EffectMgr = require("script/app/ui/battle/effect/effectmanager")
local AttackEffectMgr = require("script/app/ui/battle/effect/attackeffectmanager")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleBuff = require("script/app/ui/battle/skill/battlebuff")

local BattleSkill = class("BattleSkill")
local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE

local function sortByMinHp(a, b)
	return a.hp < b.hp
end

local function sortByMinHpRatio(a, b)
	return a.hp/a.maxHp < b.hp/b.maxHp
end

function BattleSkill:ctor(skillId, owner, skillType)
	self.skillId = skillId
	self.owner = owner
	self.targets = {}
	self.pCenter = {}
	self.castingAnimations = {}
	self.skillType = skillType --技能类型
	self.usedTimes = 0 -- 使用次数
	self.guid = owner.guid
	self.baseInfo = GameData:getConfData("skill")[skillId]
	if self.baseInfo.specialHandle ~= "0" then
		self.specialHandle = require("script/app/ui/battle/special/" .. self.baseInfo.specialHandle)
	end
	self.battlefield = self.owner.battlefield
end

function BattleSkill:getName()
	return self.baseInfo.name
end

function BattleSkill:getSkillShoutName()
	return self.baseInfo.skillShoutName
end

-- 判断技能是否可以使用
function BattleSkill:isUsable()
	if self.baseInfo.type == 3 then
	-- 被动触发技能
		return false
	end
	if self.skillType == SKILL_TYPE.PLAYER_SKILL then
	-- 手动技能，通过其他方式判断
		return true
	end
	return true
end

-- 选择目标
function BattleSkill:selectTarget()
	local targets = {}
	local baseInfo = self.baseInfo
	-- 根据类型选择军队队列
	local function getArmyMapByType(type_)
		local armyType = math.floor(type_/100)
		if (self.guid == 1 and armyType == 1) or (self.guid == 2 and armyType == 0) then -- 我方
			return self.battlefield.armyArr[1]
		else -- 敌方
			return self.battlefield.armyArr[2]
		end
	end
	if baseInfo.rangeType == 0 then
		targets = nil
	elseif baseInfo.rangeType == 1 then
	-- 直接选择目标
		if baseInfo.targetType == 1 then
		-- 锁定的目标
			targets[1] = self.owner.lockEnemy
		elseif baseInfo.targetType == 101 then
		-- 施法者本身
			targets[1] = self.owner
		else
			local targetType = baseInfo.targetType%100
			local armyArr = getArmyMapByType(baseInfo.targetType)
			if targetType == 2 then
			-- 全体英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
						if #targets >= baseInfo.targetMaxNum then
							return targets
						end
					end
				end
			elseif targetType == 3 then
			-- 随机多个英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
					end
				end
				local num = #targets
				local index = 0
				local targets2 = {}
				while num > 0 do
					index = index + 1
					if index <= baseInfo.targetMaxNum then
						table.insert(targets2, table.remove(targets, BattleHelper:random(1, num+1)))
					else
						break
					end
					num = num - 1
				end
				targets = targets2
			elseif targetType==4 then
			-- 血量最多的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target == nil or armyObj.heroObj.hp > target.hp then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType==5 then
			-- 血量最少的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target == nil or armyObj.heroObj.hp < target.hp then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType==6 then
			-- 怒气最多的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target == nil or armyObj.heroObj.mp > target.mp then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType==7 then
			-- 怒气最少的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target == nil or armyObj.heroObj.mp < target.mp then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType==8 then
			-- 除施法者/目标之外的英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() and armyObj.heroObj ~= self.owner and armyObj.heroObj ~= self.owner.lockEnemy then
						table.insert(targets, armyObj.heroObj)
						if #targets >= tonumber(baseInfo.targetMaxNum) then
							return targets
						end
					end
				end
			elseif targetType==9 then
			-- 血量剩余比例最多的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target == nil or (armyObj.heroObj.hp/armyObj.heroObj.maxHp)>(target.hp/target.maxHp) then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType==10 then
			-- 血量剩余比例最少的英雄
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						if target==nil or (armyObj.heroObj.hp/armyObj.heroObj.maxHp)<(target.hp/target.maxHp) then
							target = armyObj.heroObj
						end
					end
				end
				targets[1] = target
			elseif targetType == 50 then
			-- 全部单位
				-- 先英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
						if #targets >= tonumber(baseInfo.targetMaxNum) then
							return targets
						end
					end
				end
				-- 再士兵
				for _, armyObj in ipairs(armyArr) do
					for _, soldierObj in ipairs(armyObj.soldierObjs) do
						if not soldierObj:isDead() then
							table.insert(targets, soldierObj)
							if #targets >= baseInfo.targetMaxNum then
								return targets
							end
						end
					end
				end
				-- 最后召唤物
				for _, armyObj in ipairs(armyArr) do
					for _, summonObj in ipairs(armyObj.summonObjs) do
						if not summonObj:isDead() then
							table.insert(targets, summonObj)
							if #targets >= baseInfo.targetMaxNum then
								return targets
							end
						end
					end
				end
			elseif targetType == 51 then
			-- 全部士兵
				for _, armyObj in ipairs(armyArr) do
					for _, soldierObj in ipairs(armyObj.soldierObjs) do
						if not soldierObj:isDead() then
							table.insert(targets, soldierObj)
							if #targets >= baseInfo.targetMaxNum then
								return targets
							end
						end
					end
				end
			elseif targetType == 52 then
			-- 施法者/目标所在部队的全部单位
				local armyObj
				if baseInfo.targetType == 152 then
					armyObj = self.owner
				else
					armyObj = self.owner.lockEnemy.legionObj
				end
				if not armyObj.heroObj:isDead() then
					table.insert(targets, armyObj.heroObj)
					if #targets >= baseInfo.targetMaxNum then
						return targets
					end
				end
				for _, soldierObj in ipairs(armyObj.soldierObjs) do
					if not soldierObj:isDead() then
						table.insert(targets, soldierObj)
						if #targets >= baseInfo.targetMaxNum then
							return targets
						end
					end
				end
				for _, summonObj in ipairs(armyObj.summonObjs) do
					if not summonObj:isDead() then
						table.insert(targets, summonObj)
						if #targets >= baseInfo.targetMaxNum then
							return targets
						end
					end
				end
			elseif targetType==53 then
			-- 血量最少的士兵
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					for _, soldierObj in ipairs(armyObj.soldierObjs) do
						if not soldierObj:isDead() then
							if target == nil or soldierObj.mp < target.mp then
								target = soldierObj
							end
						end
					end
				end
				targets[1] = target
			elseif targetType==54 then
			--血量最多的士兵
				local target = nil
				for _, armyObj in ipairs(armyArr) do
					for _, soldierObj in ipairs(armyObj.soldierObjs) do
						if not soldierObj:isDead() then
							if target == nil or soldierObj.mp > target.mp then
								target = soldierObj
							end
						end
					end
				end
				targets[1] = target
			elseif targetType==55 then
			-- 从全部的单位里随一定数量的单位
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
					end
					for _, soldierObj in ipairs(armyObj.soldierObjs) do
						if not soldierObj:isDead() then
							table.insert(targets, soldierObj)
						end
					end
					for _, summonObj in ipairs(armyObj.summonObjs) do
						if not summonObj:isDead() then
							table.insert(targets, summonObj)
						end
					end
				end
				local targetMaxNum = #targets
				if targetMaxNum > baseInfo.targetMaxNum then
					local num = targetMaxNum - baseInfo.targetMaxNum
					for i = 1, num do
						local randomIndex = BattleHelper:random(1, targetMaxNum+1)
						targets[randomIndex] = targets[targetMaxNum]
						targetMaxNum = targetMaxNum - 1
						table.remove(targets)
					end
				end
				return targets
			elseif targetType == 56 then
			-- 血量最低的若干个英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
					end
				end
				table.sort(targets, sortByMinHp)
				if #targets > baseInfo.targetMaxNum then
					for i = baseInfo.targetMaxNum+1, #targets do
						table.remove(targets)
					end
				end
				return targets
			elseif targetType == 57 then
				-- 血量剩余比例最少的英雄
				for _, armyObj in ipairs(armyArr) do
					if not armyObj.heroObj:isDead() then
						table.insert(targets, armyObj.heroObj)
					end
				end
				table.sort(targets, sortByMinHpRatio)
				if #targets > baseInfo.targetMaxNum then
					for i = baseInfo.targetMaxNum+1, #targets do
						table.remove(targets)
					end
				end
				return targets
			end
		end
	else
		-- 2矩形,3圆形,4扇形
		local isInRange = nil
		if self.skillType == SKILL_TYPE.PLAYER_SKILL then
			if baseInfo.rangeType == 2 then
				isInRange = function (aiObj)
					local x, y = aiObj:getPosition()
					local rx = x - self.pCenter.x
					local ry = y - self.pCenter.y
					if (rx >= baseInfo.rangeX1 and rx <= baseInfo.rangeX2) and (ry >= baseInfo.rangeY1 and ry <= baseInfo.rangeY2) then
						return true
					end
					return false
				end
			elseif baseInfo.rangeType == 3 then
				isInRange = function (aiObj)
					local x, y = aiObj:getPosition()
					if cc.pGetDistance(cc.p(x, y), cc.p(self.pCenter.x, self.pCenter.y)) > baseInfo.rangeRadius then
						return false
					end
					return true
				end
			end
		else
			if baseInfo.rangeType == 2 then
				isInRange = function (aiObj)
					local x, y = aiObj:getPosition()
					local rx
					local ry = y - self.pCenter.y
					if self.owner:getDirection() == 1 then
						rx = x - self.pCenter.x
					else
						rx = self.pCenter.x - x
					end
					if (baseInfo.rangeX1 <= rx and rx <= baseInfo.rangeX2) and (baseInfo.rangeY1 <= ry and ry <= baseInfo.rangeY2) then
						return true
					end
					return false
				end
			elseif baseInfo.rangeType == 3 then
				isInRange = function (aiObj)
					local x, y = aiObj:getPosition()
					local rx = self.pCenter.x
					local ry = self.pCenter.y
					if cc.pGetDistance(cc.p(x, y), cc.p(rx, ry)) > baseInfo.rangeRadius then
						return false
					end
					return true
				end
			elseif baseInfo.rangeType == 4 then -- 扇形
				-- 原理是先判断目标点与原点的距离是否大于扇形的半径
				-- 在判断两向量间的夹角是否小于扇形角度的1/2
				-- 其中一个向量为原点到目标点,另外一个向量平行于X轴,长度等于扇形半径,也就是目前只考虑角平分线与x轴平行的扇形的情况
				isInRange = function (aiObj)
					local x, y = aiObj:getPosition()
					local rx
					local ux
					if self.owner:getDirection() == 1 then
						rx = x - self.pCenter.x
						ux = 1
					else
						rx = x - self.pCenter.x
						ux = -1
					end
					local ry = y - self.pCenter.y
					--local uy = 0
					local squaredLength = rx*rx + ry*ry
					local squaredR = baseInfo.rangeRadius*baseInfo.rangeRadius
					if squaredLength > squaredR then -- 如果距离直接大于扇形半径 那么肯定不在扇形内
					    return false
					end
					local length = math.sqrt(squaredLength)
					local cosTheta = math.cos(math.rad(baseInfo.sectorAngle*0.5))
					-- 点乘求夹角
					-- return acos(dx*ux + dy*uy) < theta
					-- 上面的公式优化为 rx*ux + ry*uy > length * cos(theta) 其中uy为0 所以最终公式为:
					return rx*ux > length*cosTheta
				end
			end
		end

		local targetType = baseInfo.rangeTargetType%100
		local armyArr = getArmyMapByType(baseInfo.rangeTargetType)
		if targetType == 1 then
		-- 范围内英雄
			for _, armyObj in ipairs(armyArr) do
				if not armyObj.heroObj:isDead() and isInRange(armyObj.heroObj) then
					table.insert(targets, armyObj.heroObj)
					if #targets >= baseInfo.targetMaxNum then
						return targets
					end
				end
			end
		elseif targetType == 2 then
		-- 范围内士兵
			for _, armyObj in ipairs(armyArr) do
				for _, soldierObj in ipairs(armyObj.soldierObjs) do
					if not soldierObj:isDead() and isInRange(soldierObj) then
						table.insert(targets, soldierObj)
						if #targets >= baseInfo.targetMaxNum then
							return targets
						end
					end
				end
			end
		elseif targetType == 3 then
		-- 所有单位
			for _, armyObj in ipairs(armyArr) do
				if not armyObj.heroObj:isDead() and isInRange(armyObj.heroObj) then
					table.insert(targets, armyObj.heroObj)
				end
				for _, soldierObj in ipairs(armyObj.soldierObjs) do
					if not soldierObj:isDead() and isInRange(soldierObj) then
						table.insert(targets, soldierObj)
					end
				end
				for _, summonObj in ipairs(armyObj.summonObjs) do
					if not summonObj:isDead() and isInRange(summonObj) then
						table.insert(targets, summonObj)
					end
				end
			end
			local targetMaxNum = #targets
			if targetMaxNum > baseInfo.targetMaxNum then
				local num = targetMaxNum - baseInfo.targetMaxNum
				for i = 1, num do
				local randomIndex = math.floor(BattleHelper:random(1, targetMaxNum+1))
				targets[randomIndex] = targets[targetMaxNum]
				targetMaxNum = targetMaxNum - 1
				table.remove(targets)
				end
			end
			return targets
		end
	end
	return targets
end

-- 使用技能
function BattleSkill:useSkill(pCenter)
	local baseInfo = self.baseInfo
	if self.skillType == SKILL_TYPE.PLAYER_SKILL then
		self.pCenter = pCenter
	else
		if baseInfo.rangeType > 1 then
			if pCenter then
				self.pCenter = pCenter
			else
				if baseInfo.focusType > 2 then
					self.pCenter = cc.p(0, 0)
				else
					local x
					local y
					if baseInfo.focusType == 1 then
					-- 锁定目标作为中心点
						x, y = self.owner.lockEnemy:getPosition()
					else
					-- 施法者自身作为中心点
						x, y = self.owner:getPosition()
					end
					if self.baseInfo.targetOffset > 0 then
						x = x + self.baseInfo.targetOffset*self.owner:getDirection()
					end
					self.pCenter = cc.p(x, y)
				end
			end
		end
	end
	-- 选择目标
	if baseInfo.targetTimeType == 1 then
		-- 施法之前需要先选择目标
		self.targets = self:selectTarget()
	else
		self.targets = {}
	end

	self.finishedFlag = false
	self.casting = false
	self.breakFlag = false

	-- 引导技能特效和动作
	self.effectActs = {} --伤害效果
	self.bulletAtcs = {} --子弹

	if baseInfo.soundEffect ~= "0" then
		self:playSound(baseInfo.soundEffect, false)
	end
end

function BattleSkill:playSound(soundEffectRes, isLoop)
	BattleHelper:playSound(soundEffectRes, isLoop)
end

function BattleSkill:afterPlaySkillAnimation()
	if self.specialHandle and self.specialHandle.afterPlaySkillAnimation then
		self.specialHandle:afterPlaySkillAnimation(self)
	end
end

function BattleSkill:skip()
	self:recordSkip()
	self.usedTimes = self.usedTimes + 1
	self.owner:addMpPercentage(0.05)
	if self.skillType == SKILL_TYPE.ANGER_SKILL then
	-- 怒气技能 消耗怒气
		self.owner:consumeMp()
	elseif self.skillType == SKILL_TYPE.AUTO_SKILL then
	-- 自动技能
		if self.owner:isSkillLoopOver() then
			self.owner:resetSkillLoop()
		end
	end
	self:finished()
end

function BattleSkill:recordSkip()
end

function BattleSkill:effect(_pos)
	self.usedTimes = self.usedTimes + 1
	self.owner:addMpPercentage(0.05)
	if self.skillType == SKILL_TYPE.ANGER_SKILL then
	-- 怒气技能 消耗怒气
		self.owner:consumeMp()
	elseif self.skillType == SKILL_TYPE.AUTO_SKILL then
	-- 自动技能
		if self.owner:isSkillLoopOver() then
			self.owner:resetSkillLoop()
		end
	end
	local baseInfo = self.baseInfo
	local direction = 1
	local startPos
	if self.skillType == SKILL_TYPE.PLAYER_SKILL then
		startPos = _pos or cc.p(0, 0)
		if self.guid == 2 then
			direction = -1
		end
	else
		direction = self.owner:getDirection()
		startPos = cc.p(self.owner:getPosition())
	end
	local function effect(obj) -- 对目标效果
		if self.battlefield:isBattleEnd() then
			return
		end
		if obj and obj:isDead() then
			return
		end
		if baseInfo.affectedRes ~= "0" then -- 受击特效
			self:playAttEffect(obj, baseInfo)
		end
		if baseInfo.hitSoundEffect ~= "0" then
			self:playSound(baseInfo.hitSoundEffect, false)
		end
		if baseInfo.dispel > 0 then -- 驱散
			obj:dispelBuff(baseInfo.dispel)
		end
		if baseInfo.buffId > 0 then
			self:createBuff(baseInfo.buffId, obj, self.owner)
		end
		if baseInfo.effectId > 0 then
			BattleHelper:skillEffect(self, self.owner, obj)
		end
	end
	if baseInfo.type == 2 then -- 引导技能
		self.casting = true
	else
		self:finished()
	end
	local targets = nil
	-- 中心点型子弹(向目标点发射子弹,只有目标点播放特效)
	if baseInfo.bulletType == 2 then
		local function effectFun(targetArr)
			local function effectFinal()
				if baseInfo.targetTimeType == 1 then
					targets = self.targets
				elseif baseInfo.targetTimeType == 2 then
					targets = self:selectTarget()
				else
					targets = targetArr or {}
				end
				if baseInfo.shakeTime > 0 then
					self.battlefield:runShakeAction(baseInfo.shakeTime/1000, baseInfo.shakeX, baseInfo.shakeY)
				end
				if baseInfo.summonId > 0 then
					BattleHelper:addSummon(self, self.pCenter)
				end
				for i, target in ipairs(targets) do
					effect(target)
				end
				self:checkBreaked()
			end
			self:multiEffect(baseInfo, effectFinal)
			if baseInfo.skillAnimationId > 0 then
				self:playSkillAnimation(baseInfo.skillAnimationId, direction, self.pCenter)
			end
			if baseInfo.skillAnimationId2 > 0 then
				self:playSkillAnimation(baseInfo.skillAnimationId2, direction, self.pCenter)				
			end
		end
		self:sendMultiBullet(baseInfo, startPos, direction, effectFun)
	else
		-- 目标型子弹(向所有目标发射子弹、对所有目标播放特效)
		local function effectFun(target)
			local function effectFinal()
				if baseInfo.summonId > 0 then
					BattleHelper:addSummon(self, target)
				end
				if baseInfo.shakeTime > 0 then
					self.battlefield:runShakeAction(baseInfo.shakeTime/1000, baseInfo.shakeX, baseInfo.shakeY)
				end
				effect(target)
				self:checkBreaked()
			end
			self:multiEffect(baseInfo, effectFinal)
			if baseInfo.skillAnimationId > 0 then
				self:playSkillAnimation(baseInfo.skillAnimationId, direction, cc.p(target:getPosition()))
			end
			if baseInfo.skillAnimationId2 > 0 then
				self:playSkillAnimation(baseInfo.skillAnimationId2, direction, cc.p(target:getPosition()))				
			end
		end
		local sendBullet
		if baseInfo.bulletId > 0 then
			sendBullet = function ()
				if baseInfo.targetTimeType == 1 then
					targets = self.targets
				elseif baseInfo.targetTimeType == 2 then
					targets = self:selectTarget()
				else
					targets = {}
				end
				if baseInfo.bulletType == 3 then
					if #targets > 0 then
						if self.owner.lockEnemy then
							for k, v in ipairs(targets) do
								if v == self.owner.lockEnemy then
									table.insert(targets, 1, table.remove(targets, k))
									break
								end
							end
						end
						self:sendBullet(baseInfo.bulletId, startPos, direction, targets, effectFun, 3)
					end
				else
					for i, target in ipairs(targets) do
						self:sendBullet(baseInfo.bulletId, startPos, direction, target, effectFun, 2)
					end
				end
			end
		else
			-- 瞬间起效
			sendBullet = function ()
				if baseInfo.targetTimeType == 1 then
					targets = self.targets
				elseif baseInfo.targetTimeType == 2 then
					targets = self:selectTarget()
				else
					targets = {}
				end
				for i, target in ipairs(targets) do
					--effectFun(target)
					self:sendBullet(baseInfo.bulletId, startPos, direction, target, effectFun, 2)
				end
			end
		end
		self:sendMultiBulletByMelee(baseInfo, startPos, direction, sendBullet)
	end
	-- 对技能施放者自身加buff
	if baseInfo.ownerBuffId > 0 then
		self:createBuff(baseInfo.ownerBuffId, self.owner, self.owner)
	end
end

function BattleSkill:selectPointCenter(focusType)
	if focusType == 3 then
		local armyArr
		local armyType = math.floor(self.baseInfo.rangeTargetType/100)
		if (self.guid == 1 and armyType == 1) or (self.guid == 2 and armyType == 0) then -- 我方
			armyArr = self.battlefield.armyArr[1]
		else -- 敌方
			armyArr = self.battlefield.armyArr[2]
		end
		local heroTargets = {}
		for _, armyObj in ipairs(armyArr) do
			if not armyObj.heroObj:isDead() then
				table.insert(heroTargets, armyObj.heroObj)
			end
		end
		if #heroTargets > 0 then
			local randomTarget = heroTargets[BattleHelper:random(1, #heroTargets+1)]
			local x, y = randomTarget:getPosition()
			if self.baseInfo.targetOffset > 0 then
				x = x + self.baseInfo.targetOffset*self.owner:getDirection()
			end
			self.pCenter = cc.p(x, y)
			return true
		end
	end
	return false
end

-- 打断当前正在释放的技能
function BattleSkill:breaked()
	if self.casting then -- 引导技能才能被打断
		for act, v in pairs(self.bulletAtcs) do
			self.owner:stopSkillAction(act)
		end
		self:breakCastingSkill()
		self:finished()
	end
end

function BattleSkill:breakCastingSkill()
	self.breakFlag = true
end

function BattleSkill:checkBreaked()
	if self.breakFlag then
		for k, v in ipairs(self.castingAnimations) do
			v:setStop(self, true)
		end
		for act, v in pairs(self.effectActs) do
			self.owner:stopSkillAction(act)
		end
	end
end

function BattleSkill:finished()
	self.finishedFlag = true
	if self.casting then
		self.casting = false
		self:recordFinishCastingSkill()
	end
	if #self.castingAnimations > 0 then
		self.castingAnimations = {}
	end
	if self.specialHandle and self.specialHandle.afterSkillFinish then
		self.specialHandle:afterSkillFinish(self)
	end
end

function BattleSkill:recordFinishCastingSkill()
end

-- 技能施法是否完成
function BattleSkill:isFinished()
	return self.finishedFlag
end

-- 是否处于引导施法中
function BattleSkill:isCasting()
	return self.casting
end

function BattleSkill:getActionName()
	return self.baseInfo.action
end

function BattleSkill:getUsedTimes()
	return self.usedTimes
end

function BattleSkill:resetUsedTimes()
	self.usedTimes = 0
end

function BattleSkill:setUsedTimes(times)
	self.usedTimes = times
end

function BattleSkill:isPlayerSkill()
	return self.skillType == SKILL_TYPE.PLAYER_SKILL
end

function BattleSkill:isAngerSkill()
	return self.skillType == SKILL_TYPE.ANGER_SKILL
end

function BattleSkill:isBaseSkill()
	return self.skillType == SKILL_TYPE.NORMAL_ATTACK
end

function BattleSkill:isNeedShout()
	return self.skillType == SKILL_TYPE.ANGER_SKILL
end

function BattleSkill:playAttEffect(obj, baseInfo)
	AttackEffectMgr:setAttEffect(obj, baseInfo.affectedRes, baseInfo.affectedPos, baseInfo.affectedZorder, obj.hitScale)
end

function BattleSkill:multiEffect(baseInfo, effectFinal)
	local effectAct
	if baseInfo.effectTimes == 1 then
		if baseInfo.effectDelay <= 0 then
			effectFinal()
		else
			if self.casting then
				effectAct = cc.Sequence:create(cc.DelayTime:create(baseInfo.effectDelay/1000), cc.CallFunc:create(function ()
					effectFinal()
					self.effectActs[effectAct] = nil
				end))
			else
				effectAct = cc.Sequence:create(cc.DelayTime:create(baseInfo.effectDelay/1000), cc.CallFunc:create(function ()
					effectFinal()
				end))
			end
		end
	elseif baseInfo.effectTimes > 1 then
		local effectActions = {}
		for i = 1, baseInfo.effectTimes do
			if i == 1 then
				table.insert(effectActions, cc.DelayTime:create(baseInfo.effectDelay/1000))
			else
				table.insert(effectActions, cc.DelayTime:create(baseInfo.effectInterval/1000))
			end
			table.insert(effectActions, cc.CallFunc:create(effectFinal))
		end
		if self.casting then
			table.insert(effectActions, cc.CallFunc:create(function ()
				self.effectActs[effectAct] = nil
				self:finished()
			end))
		end
		effectAct = cc.Sequence:create(effectActions)
	end
	if effectAct then
		self.owner:runSkillAction(effectAct)
		if self.casting then
			self.effectActs[effectAct] = 1
		end
	end
end

function BattleSkill:playSkillAnimation(skillAnimationId, direction, pos)
	local skillAni = EffectMgr:playEffects(skillAnimationId, self, direction, pos)
	if self.casting then
		table.insert(self.castingAnimations, skillAni)
	end
end

function BattleSkill:sendBullet(bulletId, startPos, direction, posOrTargets, effectFun, positionFlag)
	if bulletId == 0 then
		effectFun(posOrTargets)
	else
		BulletMgr:sendBullet(self, bulletId, startPos, direction, posOrTargets, effectFun, positionFlag)
	end
end

function BattleSkill:sendMultiBullet(baseInfo, startPos, direction, effectFun)
	if baseInfo.rangeType > 1 and baseInfo.focusType > 2 then
		if self:selectPointCenter(baseInfo.focusType) then
			self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
		end
	else
		self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
	end
	if baseInfo.bulletNum > 1 then
		local bulletActions = {}
		for i = 2, baseInfo.bulletNum do
			table.insert(bulletActions, cc.DelayTime:create(baseInfo.bulletInterval/1000))
			table.insert(bulletActions, cc.CallFunc:create(function ()
				if baseInfo.rangeType > 1 and baseInfo.focusType > 2 then
					if self:selectPointCenter(baseInfo.focusType) then
						self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
					end
				else
					self:sendBullet(baseInfo.bulletId, startPos, direction, self.pCenter, effectFun, 1)
				end
			end))
		end
		local bulletAct
		if self.casting then
			table.insert(bulletActions, cc.CallFunc:create(function ()
				self.bulletAtcs[bulletAct] = nil
			end))
			bulletAct = cc.Sequence:create(bulletActions)
			self.bulletAtcs[bulletAct] = 1
		else
			bulletAct = cc.Sequence:create(bulletActions)
		end
		self.owner:runSkillAction(bulletAct)
	end
end

function BattleSkill:sendMultiBulletByMelee(baseInfo, startPos, direction, func)
	func()
	if baseInfo.bulletNum > 1 then
		local bulletActions = {}
		for i = 2, baseInfo.bulletNum do
			table.insert(bulletActions, cc.DelayTime:create(baseInfo.bulletInterval/1000))
			table.insert(bulletActions, cc.CallFunc:create(func))
		end
		local bulletAct
		if self.casting then
			table.insert(bulletActions, cc.CallFunc:create(function ()
				self.bulletAtcs[bulletAct] = nil
			end))
			bulletAct = cc.Sequence:create(bulletActions)
			self.bulletAtcs[bulletAct] = 1
		else
			bulletAct = cc.Sequence:create(bulletActions)
		end
		self.owner:runSkillAction(bulletAct)
	end
end

function BattleSkill:createBuff(sid, owner, sender)
	ClassBattleBuff.new(sid, owner, sender)
end

return BattleSkill