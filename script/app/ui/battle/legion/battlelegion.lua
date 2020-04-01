local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBaseSoldier = require("script/app/ui/battle/legion/basesoldier")

local BattleLegion = class("BattleLegion")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local MIN_DISTANCE = BattleHelper.CONST.MIN_DISTANCE
local LEGION_STATUS = BattleHelper.ENUM.LEGION_STATUS
local P_YX = 80/150 --斜率
local DASH_DIS = 150 -- 准备开始冲刺的距离
local SNEAK_DIS = 150 -- 绕后的距离
local RECALCULATE_TIME = 1 -- 重新计算目标点的时间间隔
local PRIORITY_ROW = { -- 跨行找敌人的优先级
	[1] = {
		[1] = 1,
		[2] = 3,
		[3] = 2
	},
	[2] = {
		[1] = 3,
		[2] = 1,
		[3] = 2
	},
	[3] = {
		[1] = 2,
		[2] = 3,
		[3] = 1
	}
}

function BattleLegion:ctor(guid, data, isFirstWave, battlefield)
	self.guid = guid
	self.isFirstWave = isFirstWave
	self.battlefield = battlefield
	self.legionInfo = data.info
	self.isBoss = data.isBoss or false
	self.pos = data.info.pos
	self.headpic = data.info.headpic
	self.heroInfo = data.heroInfo
	self.name = self.heroInfo.name
	self.legionType = self.heroInfo.legionType
	self.damageCount = {0,0} -- 伤害统计
	self.hurtCount = 0
	-- 英雄
	local basePosition = LEGION_POS[guid][(data.info.pos-1)%9+1]
	self.heroQuality = self.heroInfo.heroQuality
	self.heroObj = self:createHero()
	self.heroObj:init(basePosition, cc.p(0, 0))
	self.leaderObj = self.heroObj
	self.heroObj:setLeader(true)
	-- 小兵
	self.soldierLv = data.info.soldierLv
	self.soldierObjs = {}
	local ownSoldierNum = data.info.soldierNum
	local soldierInfo = data.soldierInfo
	if soldierInfo then
		self.soldierInfo = soldierInfo
		local sY = (soldierInfo.ysoldierMaxNum - 1)*soldierInfo.ysoldierSep/2
		local sX = soldierInfo.heroSoldierSpacing
		local Onum = soldierInfo.ysoldierMaxNum/2
		for i = 1, ownSoldierNum do
			local numTmp = (i - 1)%soldierInfo.ysoldierMaxNum
			local rowIndex = math.ceil(i/soldierInfo.ysoldierMaxNum) - 1
			local y = sY - numTmp*soldierInfo.ysoldierSep + 1 -- 小兵多偏移1防止擋住武將
			local position = {}
			local offsetPos = {}
			position.y = basePosition.y + y
			offsetPos.y = y
			if self.guid == 1 then
				local x = sX + rowIndex*soldierInfo.xsoldierSep + y*P_YX
				position.x = basePosition.x - x
				offsetPos.x = -x
			else
				local x = sX + rowIndex*soldierInfo.xsoldierSep - y*P_YX
				position.x = basePosition.x + x
				offsetPos.x = x
			end
			local soldierObj = self:createSoldier(i)
			soldierObj:init(position, offsetPos)
			if numTmp < Onum then -- 属于上
				soldierObj.posAboveHero = 1
			else
				soldierObj.posAboveHero = 2
			end
			self.soldierObjs[i] = soldierObj
		end
	end
	self.summonObjs = {} -- 召唤物
	self.specialSummonObjs = {} -- 特殊召唤物
	self.soldierNum = 1 + ownSoldierNum
	self.dieSoldiers = {{},{},{}}
	self.lockLegion = nil
	self.beLockedLegionArr = {}
	self.beLockedMeleeNum = 0 -- 被攻击的近战军团数量
	self.sneakFlag = false -- 冲锋
	if self.legionType == 1 then -- 枪
		self.maxBeLockedMeleeNum = 2
	else
		self.maxBeLockedMeleeNum = 1
	end
	self.finalPosition = nil -- 互为目标的军团的目标点坐标
	self.costTime = 0
	self.minDistance = MIN_DISTANCE
	self.rowIndex = (self.pos - 1)%3 + 1 -- 行
	self.columnIndex = math.ceil(self.pos/3) -- 列
	self.moveToPos = nil -- 当前军团的目标点坐标
	self.errorTimes = 0
	self.recalculateTime = RECALCULATE_TIME
end

function BattleLegion:createHero()
	return ClassBaseSoldier.new(self, 1, 0)
end

function BattleLegion:createSoldier(soldierIndex)
	return ClassBaseSoldier.new(self, 2, soldierIndex)
end

function BattleLegion:setPos(pos)
	self.legionInfo.pos = pos
	self.pos = pos
	self.rowIndex = (self.pos - 1)%3 + 1
	self.columnIndex = math.ceil(self.pos/3)
end

function BattleLegion:startDash()
	if self.status == LEGION_STATUS.MOVE then
		self:setStatus(LEGION_STATUS.ATTACK)
		if self.lockLegion and self.lockLegion.lockLegion == self and self.lockLegion.status == LEGION_STATUS.MOVE then -- 如果是相互朝着对方移动
			self.lockLegion:setStatus(LEGION_STATUS.ATTACK)
		end
	end
end

-- 向目标移动(互为目标)
function BattleLegion:moveTo(pos)
	self:setStatus(LEGION_STATUS.MOVE)
	self.moveToPos = pos
	if not self.heroObj:isDead() then
		self.heroObj:moveToByLegion(pos, function ()
			self:startDash()
		end)
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:moveToByLegion(pos, function ()
				self:startDash()
			end)
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:moveToByLegion(pos, function ()
				self:startDash()
			end)
		end
	end
end

function BattleLegion:onArriveCloseToPos()
	if self.status == LEGION_STATUS.CLOSETO then
		self:moveToLockTarget()
	end
end

-- 向目标移动(不互为目标)
function BattleLegion:closeTo(pos)
	self:setStatus(LEGION_STATUS.CLOSETO)
	self.moveToPos = pos
	if self.sneakFlag and self.sneakY then -- 骑兵冲刺的特殊移动路径
		pos = cc.p(pos.x, self.sneakY)
	end
	if not self.heroObj:isDead() then
		self.heroObj:moveToByLegion(pos, function ()
			self:onArriveCloseToPos()
		end)
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:moveToByLegion(pos, function ()
				self:onArriveCloseToPos()
			end)
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:moveToByLegion(pos, function ()
				self:onArriveCloseToPos()
			end)
		end
	end
end

function BattleLegion:attack()
	self:playSound("media/effect/battle_chongfeng.mp3", false)
	if self.sneakFlag then
		self.sneakFlag = false
		self.sneakY = nil
		self.sneakTargetX = nil
	    if self.legionType == 3 and self.lockLegion then -- 骑兵冲锋成功后修改自己所在的行
			self.rowIndex = self.lockLegion.rowIndex
		end
	end
	self.minDistance = MIN_DISTANCE
	self.recalculateTime = RECALCULATE_TIME
	self:setStatus(LEGION_STATUS.ATTACKING)
	self:setFinalPosition(nil)
	self:setCostTime(0)
	if not self.heroObj:isDead() then
		self.heroObj:moveToLockTarget()
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:moveToLockTarget()
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:moveToLockTarget()
		end
	end
end

-- 移动过程中检查小兵是否跑偏了
function BattleLegion:checkSoldierRange(soldierObj, dt, talkFlag)
	if not soldierObj:isDead() and soldierObj.moveToOther then
		if talkFlag then
			soldierObj:talkBySoldier()
		end
		local x1, y1 = soldierObj:getPosition()
		local target = soldierObj.lockEnemy
		if target and not soldierObj:getTargeLockMe() then -- 和目标不是互为目标
			local x2, y2 = target:getPosition()
			local d = math.floor(math.sqrt(math.pow(x1-x2,2)+math.pow(y1-y2,2)))
			if d > soldierObj.attackRange + soldierObj.rangeOffset then
				if d > soldierObj.minDistance then -- 越走越远了
					soldierObj:recheckTargetPos(dt)
				else
					soldierObj.minDistance = d
				end
			elseif soldierObj.minDistance ~= MIN_DISTANCE then
				soldierObj:moveToLockTarget()
			end
		end
	end
end

-- 移动过程中检查整个军团是否跑偏了
function BattleLegion:checkRange(dt)
	local attackRange = self.leaderObj.attackRange
	if self.sneakFlag then
		local x1 = self.leaderObj:getPositionX()
		local d = math.abs(self.sneakTargetX - x1)
		if d <= attackRange then -- 已经跑到目标的初始位置了
			self:setStatus(LEGION_STATUS.ATTACK)
		else
			local x2
			if self.leaderObj.lockEnemy and not self.leaderObj.lockEnemy:isDead() then
				x2 = self.leaderObj.lockEnemy:getPositionX()
			else
				x2 = self.lockLegion.leaderObj:getPositionX()
			end
			if self.lockLegion.guid == 1 then
				x2 = x2 - SNEAK_DIS - attackRange
			else
				x2 = x2 + SNEAK_DIS + attackRange
			end
			d = math.abs(x2 - x1)
			if d <= attackRange then -- 在攻击范围内
				self:setStatus(LEGION_STATUS.ATTACK)
			else
				if d > self.minDistance then -- 越走越远了
					self.recalculateTime = self.recalculateTime - dt
					if self.recalculateTime < 0 then
						self.recalculateTime = RECALCULATE_TIME
						self:moveToLockTarget()
					end
				else
					self.minDistance = d
				end
			end
		end
	else
		local x1, y1 = self.leaderObj:getPosition()
		local x2, y2
		if self.leaderObj.lockEnemy and not self.leaderObj.lockEnemy:isDead() then
			x2, y2 = self.leaderObj.lockEnemy:getPosition()
		else
			x2, y2 = self.lockLegion.leaderObj:getPosition()
		end
		local d = math.floor(math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2)))
		attackRange = attackRange + DASH_DIS
		if d <= attackRange then -- 在攻击范围内
			self:setStatus(LEGION_STATUS.ATTACK)
		else
			if d > self.minDistance then -- 越走越远了
				self.recalculateTime = self.recalculateTime - dt
				if self.recalculateTime < 0 then
					self.recalculateTime = RECALCULATE_TIME
					self:moveToLockTarget()
				end
			else
				self.minDistance = d
			end
		end
	end
end

function BattleLegion:moveToLockTarget()
	if self.lockLegion == nil or self.lockLegion:isDead() then
		self:setStatus(LEGION_STATUS.SEARCH)
		return
	end
	local x1, y1 = self.leaderObj:getPosition()
	local x2, y2 
	if self.leaderObj.lockEnemy and not self.leaderObj.lockEnemy:isDead() then
		x2, y2 = self.leaderObj.lockEnemy:getPosition()
	else
		x2, y2 = self.lockLegion.leaderObj:getPosition()
	end
	local d = 0
	local attackRange = self.leaderObj.attackRange
	if self.sneakFlag then -- 绕后逻辑的目标点是目标身后xx个单位
		if self.lockLegion.lockLegion == self then -- 如果互为目标就终止绕后逻辑
			self.sneakFlag = false
			self.sneakY = nil
			self.sneakTargetX = nil
			d = math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
			attackRange = attackRange + DASH_DIS
		else
			if self.lockLegion.guid == 1 then
				x2 = x2 - SNEAK_DIS - attackRange
			else
				x2 = x2 + SNEAK_DIS + attackRange
			end
			d = math.abs(x2 - x1)
		end
	else
		d = math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
		attackRange = attackRange + DASH_DIS
	end
	if d <= attackRange then -- 攻击距离足够
		self:setStatus(LEGION_STATUS.ATTACK)
		if self.lockLegion.lockLegion == self and self.lockLegion.status == LEGION_STATUS.MOVE then -- 如果是相互朝着对方移动
			self.lockLegion:setStatus(LEGION_STATUS.ATTACK)
		end
	else -- 攻击距离不足
		if self.lockLegion.lockLegion == self then -- 如果是相互朝着对方移动
			local pos = self.finalPosition
			if pos == nil then
				pos = self:calculateFinalPosition()
			end
			if self.costTime < 0.01 then
				self:setStatus(LEGION_STATUS.ATTACK)
				if self.lockLegion.status == LEGION_STATUS.MOVE then
					self.lockLegion:setStatus(LEGION_STATUS.ATTACK)
				end
			else
				pos.x = pos.x - self.leaderObj.offsetPos.x
				pos.y = pos.y - self.leaderObj.offsetPos.y
				self:moveTo(pos)
				if self.lockLegion.status == LEGION_STATUS.CLOSETO then
					self.lockLegion:setStatus(LEGION_STATUS.STAND)
				end
			end
		else
			self.minDistance = d
			if self.legionType == 2 then -- 远程
				local nd = d - attackRange + 2
				local ty = nd*(y2-y1)/d + y1 - self.leaderObj.offsetPos.y
				local tx = nd*(x2-x1)/d + x1 - self.leaderObj.offsetPos.x
				self:closeTo(cc.p(tx, ty))
			else
				self:closeTo(cc.p(x2 - self.leaderObj.offsetPos.x, y2 - self.leaderObj.offsetPos.y))
			end
		end
	end
end

function BattleLegion:prepare()
	local targetLegions = self.battlefield.armyArr[3 - self.guid]
	local lockLegion = nil
	local x1, y1 = self.leaderObj:getPosition()
	if self.legionType == 1 then -- 步兵优先搞死同一排的
		local targets = {}
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				local x2, y2 = v.leaderObj:getPosition()
				local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
				local obj = {
					dis = dis,
					legion = v
				}
				table.insert(targets, obj)
			end
		end
		if #targets > 0 then
			table.sort(targets, function (a, b)
				if a.legion.rowIndex == b.legion.rowIndex then
					return a.dis < b.dis
				else
					if a.legion.rowIndex == self.rowIndex then
						return true
					elseif b.legion.rowIndex == self.rowIndex then
						return false
					else
						return PRIORITY_ROW[self.rowIndex][a.legion.rowIndex] > PRIORITY_ROW[self.rowIndex][b.legion.rowIndex]	
					end
				end
			end)
			lockLegion = targets[1].legion
			targets = nil
		end
	else -- 其他兵种寻找离自己最近的
		local targets = {}
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				local x2, y2 = v.leaderObj:getPosition()
				local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
				local obj = {
					dis = dis,
					legion = v
				}
				table.insert(targets, obj)
			end
		end
		if #targets > 0 then
			table.sort(targets, function (a, b)
				return a.dis < b.dis
			end)
			lockLegion = targets[1].legion
			targets = nil
		end
	end
	self:prepareOver(lockLegion)
end

-- 第一轮特殊逻辑寻敌
function BattleLegion:prepare1()
	local lockLegion = nil
	local targetLegions = self.battlefield.armyArr[3 - self.guid]
	if self.legionType == 1 then -- 步兵
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				if v.rowIndex == self.rowIndex then 
					if v.beLockedMeleeNum < v.maxBeLockedMeleeNum then
						lockLegion = v
						break
					end
				end
			end
		end
	elseif self.legionType == 2 then -- 弓兵先找离自己最近的有敌人的一列,然后优先跟自己同排的,没有人就找离自己最近的
		local targets = {}
		local x1, y1 = self.leaderObj:getPosition()
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				local x2, y2 = v.leaderObj:getPosition()
				local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
				local obj = {
					pos = v.pos,
					dis = dis,
					legion = v
				}
				table.insert(targets, obj)
			end
		end
		if #targets > 0 then
			table.sort(targets, function (a, b)
				if a.legion.columnIndex == b.legion.columnIndex then -- 同一列
					if a.legion.rowIndex == self.rowIndex then
						return true
					elseif b.legion.rowIndex == self.rowIndex then
						return false
					else
						return a.dis < b.dis
					end
				else
					return a.legion.columnIndex < b.legion.columnIndex
				end
			end)
			lockLegion = targets[1].legion
			targets = nil
		end
	elseif self.legionType == 3 then -- 骑 
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				if v.rowIndex == self.rowIndex then 
					if v.beLockedMeleeNum < v.maxBeLockedMeleeNum then
						lockLegion = v
						break
					end
				end
			end
		end
	end
	self:prepareOver(lockLegion)
end

-- 第二轮跨行特殊逻辑寻敌, 弓不需要走这个逻辑
function BattleLegion:prepare2()
	if self.lockLegion == nil then
		local lockLegion = nil
		local targetLegions = self.battlefield.armyArr[3 - self.guid]
		local x1, y1 = self.leaderObj:getPosition()
		if self.legionType == 1 then -- 步兵先按指定优先级找某一排, 然后在这一排寻找离自己最近的
			local targets = {}
			local targets2 = {}
			for k, v in ipairs(targetLegions) do
				if not v:isDead() then
					local x2, y2 = v.leaderObj:getPosition()
					local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
					local obj = {
						rowIndex = v.rowIndex,
						dis = dis,
						legion = v
					}
					if v.rowIndex ~= self.rowIndex then
						table.insert(targets, obj)	
					else
						table.insert(targets2, obj)
					end
				end
			end
			if #targets > 0 then
				table.sort(targets, function (a, b)
					if a.rowIndex == b.rowIndex then
						return a.dis < b.dis
					else
						if a.rowIndex == self.rowIndex then
							return true
						elseif b.rowIndex == self.rowIndex then
							return false
						else
							return PRIORITY_ROW[self.rowIndex][a.rowIndex] > PRIORITY_ROW[self.rowIndex][b.rowIndex]	
						end
					end
				end)
				lockLegion = targets[1].legion
				targets = nil
			end
			if lockLegion == nil and #targets2 > 0 then
				table.sort(targets2, function (a, b)
					return a.dis < b.dis
				end)
				lockLegion = targets2[1].legion
				targets2 = nil
			end
		elseif self.legionType == 3 then -- 骑兵先找离自己最远的一列,  然后在这一列按照指定优先级找
			local targets = {}
			local targets2 = {}
			local targets3 = {}
			for k, v in ipairs(targetLegions) do
				if not v:isDead() then
					local obj = {
						rowIndex = v.rowIndex,
						columnIndex = v.columnIndex,
						legion = v
					}
					if v.rowIndex ~= self.rowIndex then
						table.insert(targets, obj)
					else
						local x2, y2 = v.leaderObj:getPosition()
						obj.dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
						if v.beLockedMeleeNum < v.maxBeLockedMeleeNum then
							table.insert(targets2, obj)
						else
							table.insert(targets3, obj)
						end
					end
				end
			end
			if #targets > 0 then
				table.sort(targets, function (a, b)
					if a.columnIndex == b.columnIndex then
						return PRIORITY_ROW[self.rowIndex][a.rowIndex] > PRIORITY_ROW[self.rowIndex][b.rowIndex]
					else
						return a.columnIndex > b.columnIndex
					end
				end)
				lockLegion = targets[1].legion
				targets = nil
				self.sneakFlag = true
				self.sneakY = y1
				local attackRange = self.heroObj.attackRange
				if lockLegion.guid == 1 then
					self.sneakTargetX = LEGION_POS[lockLegion.guid][(lockLegion.pos-1)%9+1].x - attackRange
				else
					self.sneakTargetX = LEGION_POS[lockLegion.guid][(lockLegion.pos-1)%9+1].x + attackRange
				end
			end
			if lockLegion == nil then
			 	if #targets2 > 0 then
					table.sort(targets2, function (a, b)
						return a.dis < b.dis
					end)
					lockLegion = targets2[1].legion
					targets2 = nil
				elseif #targets3 > 0 then
					table.sort(targets3, function (a, b)
						return a.dis > b.dis
					end)
					lockLegion = targets3[1].legion
					targets3 = nil
				end
			end
		end
		self:prepareOver(lockLegion)
	end
end

function BattleLegion:prepareOver(lockLegion)
	if lockLegion then
		self:useTalentSkillBeforeFight()
		if lockLegion.lockLegion == self then -- 第一次和目标互相移动时 双方的小兵的额外y轴偏移
			for k, v in ipairs(self.soldierObjs) do
				local rowIndex = math.ceil(v.soldierIndex/self.soldierInfo.ysoldierMaxNum) - 1
				if v.posAboveHero == 1 then
					v.ypHero = 8*rowIndex
				else
					v.ypHero = -8*rowIndex
				end
			end
			for k, v in ipairs(lockLegion.soldierObjs) do
				local rowIndex = math.ceil(v.soldierIndex/lockLegion.soldierInfo.ysoldierMaxNum) - 1
				if v.posAboveHero == 1 then
					v.ypHero = 8*rowIndex
				else
					v.ypHero = -8*rowIndex
				end
			end
		end
		self:lockTarget(lockLegion)
		self:setStatus(LEGION_STATUS.STAND)
		self.heroObj:prepare()
		self.heroObj:showEffectNode()
		for k, soldierObj in ipairs(self.soldierObjs) do
			soldierObj:prepare()
			soldierObj:showEffectNode()
		end
		for k2, summonObj in ipairs(self.summonObjs) do
			summonObj:prepare()
			summonObj:showEffectNode()
		end
	end
end

function BattleLegion:isDead()
	return self.status == LEGION_STATUS.DEAD
end

function BattleLegion:changeTarget()
	self.battlefield:addChangeTargetLegion(self.guid, self)
	self:setStatus(LEGION_STATUS.DONOTHING)
end

-- 锁定一个目标(通过距离)
function BattleLegion:searchTarget()
	if self.sneakFlag then
		self.sneakFlag = false
		self.sneakY = nil
		self.sneakTargetX = nil
	end
	self:setFinalPosition(nil)
	self:setCostTime(0)
	local targetLegions = self.battlefield.armyArr[3 - self.guid]
	local lockLegion = nil
	local x1, y1 = self.leaderObj:getPosition()
	-- 所有兵种都是优先正在攻击自己的
	if self.legionType == 1 then -- 步兵先搞死同行的
		local targets = {}
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				local x2, y2 = v.leaderObj:getPosition()
				local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
				local flag = false
				if v.lockLegion == self then
					flag = true
				end
				local obj = {
					dis = dis,
					legion = v,
					flag = flag
				}
				table.insert(targets, obj)
			end
		end
		if #targets > 0 then
			-- 优先级以此为：1、互为目标，2、目标和自己同排，3、目标离自己的距离
			table.sort(targets, function (a, b)
				if a.flag == b.flag then
					if a.legion.rowIndex == b.legion.rowIndex then
						return a.dis < b.dis
					else
						if a.legion.rowIndex == self.rowIndex then
							return true
						elseif b.legion.rowIndex == self.rowIndex then
							return false
						else
							return PRIORITY_ROW[self.rowIndex][a.legion.rowIndex] > PRIORITY_ROW[self.rowIndex][b.legion.rowIndex]	
						end
					end
				else
					return a.flag
				end
			end)
			lockLegion = targets[1].legion
			targets = nil
		end
	else -- 其他兵种寻找离自己最近的
		local targets = {}
		for k, v in ipairs(targetLegions) do
			if not v:isDead() then
				local x2, y2 = v.leaderObj:getPosition()
				local dis = math.pow(x1-x2, 2) + math.pow(y1-y2, 2)
				local flag = false
				if v.lockLegion == self then
					flag = true
				end
				local obj = {
					dis = dis,
					legion = v,
					flag = flag
				}
				table.insert(targets, obj)
			end
		end
		if #targets > 0 then
			table.sort(targets, function (a, b)
				if a.flag == b.flag then
					return a.dis < b.dis
				else
					return a.flag
				end
			end)
			lockLegion = targets[1].legion
			targets = nil
		end
	end
	if lockLegion then
		self:setStatus(LEGION_STATUS.STAND)
		self:lockTarget(lockLegion)
		self.heroObj:searchTarget(false, false)
		for k, v in ipairs(self.soldierObjs) do
			v:searchTarget(false, false)
		end
		for k2, v2 in ipairs(self.summonObjs) do
			v2:searchTarget(false, false)
		end
		for k3, v3 in ipairs(self.specialSummonObjs) do
			v3:searchTarget(false, true)
		end
	else
		self:setStatus(LEGION_STATUS.ERROR)
	end
end

function BattleLegion:setTarget(targetLegion)
	if not targetLegion:isDead() then
		self:setFinalPosition(nil)
		self:setCostTime(0)
		self:setStatus(LEGION_STATUS.STAND)
		self:lockTarget(targetLegion)
		self.heroObj:searchTarget(true, false)
		for k, v in ipairs(self.soldierObjs) do
			v:searchTarget(true, false)
		end
		for k2, v2 in ipairs(self.summonObjs) do
			v2:searchTarget(true, false)
		end
	end
end

-- 军队停止攻击
function BattleLegion:stop()
	self.heroObj:stop()
	for k, v in ipairs(self.soldierObjs) do
		v:stop()
	end
	for k2, v2 in ipairs(self.summonObjs) do
		v2:stop()
	end
end

function BattleLegion:cancelLock()
	local lockLegion = self.lockLegion
	if lockLegion then
		self.lockLegion = nil
		lockLegion:effectWhenCancelLockByLegion(self)
		for k, v in ipairs(lockLegion.beLockedLegionArr) do
			if v == self then
				if self.legionType ~= 2 then -- 我是近战
					lockLegion.beLockedMeleeNum = lockLegion.beLockedMeleeNum - 1
				end
				table.remove(lockLegion.beLockedLegionArr, k)
				break
			end
		end
	end
end

-- 取消与其有关的所有锁定
function BattleLegion:cancelAllLockWhenDie()
	self:cancelLock()
	for k, v in ipairs(self.beLockedLegionArr) do
		v.lockLegion = nil
		v:changeTarget()
	end
	self.beLockedLegionArr = {}
	self.beLockedMeleeNum = 0
end

function BattleLegion:addSummonObj(master, sid, position)
	if self.battlefield:isBattleEnd() then
		return
	end
	local summonInfo = GameData:getConfData("summon")[sid]
	local summon
	if summonInfo.selectEnable > 0 then
		local soldierIndex = #self.summonObjs + 1
		summon = ClassBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.summonObjs, summon)
		self.soldierNum = self.soldierNum + 1
	else
		local soldierIndex = #self.specialSummonObjs + 10001
		summon = ClassBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.specialSummonObjs, summon)
	end
	summon.summonInfo = summonInfo
	summon.owner = master
	summon:init(position, cc.p(0, 0))
	summon:initSummonSpeciality()
end

function BattleLegion:onLocked(legion)
	if not self.heroObj:isDead() then
		self.heroObj:effectWhenLockedByLegion(legion)
	end
	if legion.legionType ~= 2 then
		self.beLockedMeleeNum = self.beLockedMeleeNum + 1
	end
	table.insert(self.beLockedLegionArr, legion)
end

function BattleLegion:lockTarget(legion)
	self:cancelLock()
	self.lockLegion = legion
	legion:onLocked(self)
end

function BattleLegion:effectWhenCancelLockByLegion(legion)
	if not self.heroObj:isDead() then
		self.heroObj:effectWhenCancelLockByLegion(legion)
	end
end

function BattleLegion:changeLeader()
	local successFlag = false
	if not self.heroObj:isDead() then
		self.leaderObj = self.heroObj
		self.heroObj:setLeader(true)
		successFlag = true
	end
	if not successFlag then
		for k, soldierObj in ipairs(self.soldierObjs) do
			if not soldierObj:isDead() then
				self.leaderObj = soldierObj
				soldierObj:setLeader(true)
				successFlag = true
				break
			end
		end
	end
	if not successFlag then
		for k, summonObj in ipairs(self.summonObjs) do
			if not summonObj:isDead() then
				self.leaderObj = summonObj
				summonObj:setLeader(true)
				break
			end
		end
	end
end

function BattleLegion:die(position, soldierType, soldierIndex)
	if self.dieSoldiers[soldierType][soldierIndex] then
		return
	end
	self.dieSoldiers[soldierType][soldierIndex] = true
	self.battlefield:addDieNum(self.guid, position, soldierType)
	self.soldierNum = self.soldierNum - 1
	if self.soldierNum <= 0 then
	-- 军队数量为0, 总军队数量减一
		self.battlefield:addLegionDieNum(self.pos, self.guid, position)
		self:setStatus(LEGION_STATUS.DEAD)
	end
end

function BattleLegion:battleEnd()
	if self.battlefield.legionCount[self.guid] <= 0 then
	-- 军队数量为0, 战斗结束
		self.battlefield:battleEnd(self.guid == 2)
	end
end

function BattleLegion:playWin()
	self:setStatus(LEGION_STATUS.OVER)
	if self:isDead() then
		return
	end
	if not self.heroObj:isDead() then
		self.heroObj:battleOver(true)
	end
	local position = cc.p(self.leaderObj:getPosition())
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:battleOver()
			soldierObj:moveTogether(position)
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:battleOver()
			summonObj:moveTogether(position)
		end
	end
end

function BattleLegion:playLose()
	self:setStatus(LEGION_STATUS.OVER)
	if self:isDead() then
		return
	end
	if not self.heroObj:isDead() then
		self.heroObj:battleOver()
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:battleOver()
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:battleOver()
		end
	end
end

function BattleLegion:setSoldierPos(pos)
	local sY = (self.soldierInfo.ysoldierMaxNum - 1)*self.soldierInfo.ysoldierSep/2
	local sX = self.soldierInfo.heroSoldierSpacing
	for k, soldierObj in ipairs(self.soldierObjs) do
		local numTmp = (k - 1)%self.soldierInfo.ysoldierMaxNum
		local y = sY - numTmp*self.soldierInfo.ysoldierSep
		local position = {}
		position.y = pos.y + y
		if self.guid == 1 then
			local x = sX + (math.ceil(k/self.soldierInfo.ysoldierMaxNum) - 1)*self.soldierInfo.xsoldierSep + y*P_YX
			position.x = pos.x - x
		else
			local x = sX + (math.ceil(k/self.soldierInfo.ysoldierMaxNum) - 1)*self.soldierInfo.xsoldierSep - y*P_YX
			position.x = pos.x + x
		end
		soldierObj:setPosition(position)
	end
end

function BattleLegion:remove()
	self.heroObj:remove()
	for k, soldierObj in ipairs(self.soldierObjs) do
		soldierObj:remove()
	end
	for k, summonObj in ipairs(self.summonObjs) do
		summonObj:remove()
	end
end

function BattleLegion:addDamageCount(num, guid, soldierType)
	if num > 0 then
		self.damageCount[1] = self.damageCount[1] + num
	else
		self.damageCount[2] = self.damageCount[2] - num
	end
	self.battlefield:addDamageCount(num, guid, soldierType)
end

function BattleLegion:getDamageCount()
	return self.damageCount
end

function BattleLegion:addHurtCount(num, soldierType)
	self.hurtCount = self.hurtCount - num
	self.battlefield:addHurtCount(num, self.guid, soldierType)
end

function BattleLegion:getHurtCount()
	return self.hurtCount
end

function BattleLegion:setFinalPosition(pos)
	self.finalPosition = pos
end

function BattleLegion:setCostTime(t)
	self.costTime = t
end

function BattleLegion:calculateFinalPosition()
	local target = self.lockLegion
	if self.leaderObj.attackType == 2 and target.leaderObj.attackType == 2 then -- 双方都是远程
		local x1, y1 = self.leaderObj:getPosition()
		local x2, y2 = target.leaderObj:getPosition()
		local d = math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
		local attackRange1 = self.heroObj.attackRange
		local attackRange2 = target.heroObj.attackRange
		local targetSpeed = target.heroObj.moveSpeed
		local mySpeed = self.heroObj.moveSpeed
		if d > attackRange1 and d > attackRange2 then -- 如果双方都在对方的射程外
			local longerRange = nil
			local costTime1 = nil
			local costTime2 = nil
			if attackRange1 > attackRange2 then
				longerRange = attackRange1
				local rangeDis = attackRange1 - attackRange2
				costTime1 = (d - longerRange)/(mySpeed + targetSpeed)
				costTime2 = costTime1 + rangeDis/targetSpeed
			elseif attackRange1 < attackRange2 then
				longerRange = attackRange2
				local rangeDis = attackRange2 - attackRange1
				costTime2 = (d - longerRange)/(mySpeed + targetSpeed)
				costTime1 = costTime2 + rangeDis/mySpeed
			else
				longerRange = attackRange1
				costTime1 = (d - longerRange)/(mySpeed + targetSpeed)
				costTime2 = costTime1
			end
			local x3 = (x2 - x1)*mySpeed*costTime1/d + x1
			local y3 = (y2 - y1)*mySpeed*costTime1/d + y1
			local x4 = (x2 - x1)*(d - targetSpeed*costTime2)/d + x1
			local y4 = (y2 - y1)*(d - targetSpeed*costTime2)/d + y1
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
			if d > attackRange1 then -- 我在射程外
				costTime1 = (d - attackRange1)/mySpeed
				x3 = (x2 - x1)*mySpeed*costTime1/d + x1
				y3 = (y2 - y1)*mySpeed*costTime1/d + y1
			end
			if d > attackRange2 then -- 他在射程外
				costTime2 = (d - attackRange2)/targetSpeed
				x4 = (x2 - x1)*(d - targetSpeed*costTime2)/d + x1
				y4 = (y2 - y1)*(d - targetSpeed*costTime2)/d + y1
			end
			local finalPos = cc.p(x3, y3)
			self:setFinalPosition(finalPos)
			target:setFinalPosition(cc.p(x4, y4))
			self:setCostTime(costTime1)
			target:setCostTime(costTime2)
			return finalPos
		end
	elseif self.leaderObj.attackType == 1 and target.leaderObj.attackType == 1 then -- 双方都是近战
		local x1, y1 = self.leaderObj:getPosition()
		local x2, y2 = target.leaderObj:getPosition()
		local d = math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
		local attackRange = (self.heroObj.attackRange + target.heroObj.attackRange)/2 + DASH_DIS
		local targetSpeed = target.heroObj.moveSpeed
		local mySpeed = self.heroObj.moveSpeed
		if d > attackRange then -- 如果双方都在对方的射程外
			local costTime = (d - attackRange)/(mySpeed + targetSpeed)
			local x3 = (x2 - x1)*mySpeed*costTime/d + x1
			local y3 = (y2 - y1)*mySpeed*costTime/d + y1
			local x4 = (x2 - x1)*(d - targetSpeed*costTime)/d + x1
			local y4 = (y2 - y1)*(d - targetSpeed*costTime)/d + y1
			local finalPos = cc.p(x3, y3)
			self:setFinalPosition(finalPos)
			target:setFinalPosition(cc.p(x4, y4))
			self:setCostTime(costTime)
			target:setCostTime(costTime)
			return finalPos
		else -- 都在射程内
			local finalPos = cc.p(x1, y1)
			self:setFinalPosition(finalPos)
			target:setFinalPosition(cc.p(x2, y2))
			self:setCostTime(0)
			target:setCostTime(0)
			return finalPos
		end
	else
		local ad = nil -- 近战
		local adc = nil -- 远程
		local flag = true
		if self.leaderObj.attackType == 1 then
			flag = false
			ad = self
			adc = target
		else
			ad = target
			adc = self
		end
		local x1, y1 = adc.leaderObj:getPosition()
		local x2, y2 = ad.leaderObj:getPosition()
		local d = math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
		local adRange = ad.heroObj.attackRange
		local adcRange = adc.heroObj.attackRange
		if d > adcRange then -- 如果双方都在对方的射程外
			local rangeDis = adcRange - adRange - DASH_DIS
			local adcCostTime = (d - adcRange)/(ad.heroObj.moveSpeed + adc.heroObj.moveSpeed)
			local adCostTime = adcCostTime + rangeDis/ad.heroObj.moveSpeed
			local x3 = (x2 - x1)*adc.heroObj.moveSpeed*adcCostTime/d + x1
			local y3 = (y2 - y1)*adc.heroObj.moveSpeed*adcCostTime/d + y1
			local x4 = (x2 - x1)*(d - ad.heroObj.moveSpeed*adCostTime)/d + x1
			local y4 = (y2 - y1)*(d - ad.heroObj.moveSpeed*adCostTime)/d + y1
			adc:setFinalPosition(cc.p(x3, y3))
			adc:setCostTime(adcCostTime)
			ad:setFinalPosition(cc.p(x4, y4))
			ad:setCostTime(adCostTime)
			if flag then
				return cc.p(x3, y3)
			else
				return cc.p(x4, y4)
			end
		elseif d > adRange then -- 远程在射程内，近战在射程外
			adc:setFinalPosition(cc.p(x1, y1))
			adc:setCostTime(0)
			local adCostTime = (d - adRange - DASH_DIS)/ad.heroObj.moveSpeed
			local x3 = (x1 - x2)*ad.heroObj.moveSpeed*adCostTime/d + x2
			local y3 = (y1 - y2)*ad.heroObj.moveSpeed*adCostTime/d + y2
			if flag then
				return cc.p(x1, y1)
			else
				return cc.p(x3, y3)
			end
		else -- 双方都在射程内
			adc:setFinalPosition(cc.p(x1, y1))
			ad:setFinalPosition(cc.p(x2, y2))
			self:setCostTime(0)
			target:setCostTime(0)
			if flag then
				return cc.p(x1, y1)
			else
				return cc.p(x2, y2)
			end
		end
	end
end

function BattleLegion:setStatus(status)
	if not self:isDead() then
		self.status = status
	end
end

function BattleLegion:setPosition(pos)
	self.heroObj:setPosition(cc.pAdd(pos, self.heroObj.offsetPos))
	for k, soldierObj in ipairs(self.soldierObjs) do
		soldierObj:setPosition(cc.pAdd(pos, soldierObj.offsetPos))
	end
	for k, summonObj in ipairs(self.summonObjs) do
		summonObj:setPosition(cc.pAdd(pos, summonObj.offsetPos))
	end
end

function BattleLegion:moveToPosition(pos, func)
	self.moveToPos = pos
	if not self.heroObj:isDead() then
		self.heroObj:moveTogether(pos, func)
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:moveTogether(pos)
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:moveTogether(pos)
		end
	end
end

function BattleLegion:checkError()
	if self:isDead() then
		return
	end
	if self.status == LEGION_STATUS.ERROR or self.status == LEGION_STATUS.WAIT then
		self:setStatus(LEGION_STATUS.SEARCH)
	end
end

function BattleLegion:wait()
	self:setStatus(LEGION_STATUS.WAIT)
end

function BattleLegion:isWait()
	return self.status == LEGION_STATUS.WAIT
end

function BattleLegion:setVisible(vis)
	self.heroObj:setVisible(vis)
	for k, soldierObj in ipairs(self.soldierObjs) do
		soldierObj:setVisible(vis)
	end
	for k, summonObj in ipairs(self.summonObjs) do
		summonObj:setVisible(vis)
	end
end

function BattleLegion:isMovingByLegion()
	if self.status == LEGION_STATUS.MOVE or self.status == LEGION_STATUS.CLOSETO then
		return true
	else
		return false
	end
end

function BattleLegion:useTalentSkillBeforeFight()
	if self.isFirstWave then
		self.heroObj:useTalentSkillBeforeFight()
	end
end

function BattleLegion:playSound(res, isLoop)
	BattleHelper:playSound(res, isLoop)
end

function BattleLegion:update(dt)
	if self:isDead() then
		return
	end
	if self.status == LEGION_STATUS.ATTACKING then -- 攻击目标军团中
		self:checkSoldierRange(self.heroObj, dt)
		for k, soldierObj in ipairs(self.soldierObjs) do
			self:checkSoldierRange(soldierObj, dt)
		end
		for k, summonObj in ipairs(self.summonObjs) do
			self:checkSoldierRange(summonObj, dt)
		end
	elseif self.status == LEGION_STATUS.MOVE then -- 向互为目标的军团移动中
		self:checkSoldierRange(self.heroObj, dt)
		for k, soldierObj in ipairs(self.soldierObjs) do
			self:checkSoldierRange(soldierObj, dt, true)
		end
		for k, summonObj in ipairs(self.summonObjs) do
			self:checkSoldierRange(summonObj, dt)
		end
	elseif self.status == LEGION_STATUS.CLOSETO then -- 向目标不是自己的军团靠近中
		self:checkRange(dt)
	elseif self.status == LEGION_STATUS.ATTACK then -- 开始攻击
		self:attack()
	elseif self.status == LEGION_STATUS.SEARCH then -- 重新索敌
	 	self:searchTarget()
	elseif self.status == LEGION_STATUS.STAND then -- 开始向目标军团移动
		self.heroObj:talkByHero()
		self:moveToLockTarget()
	elseif self.status == LEGION_STATUS.ERROR then
		self.errorTimes = self.errorTimes + 1
		if self.errorTimes >= 60 then -- 加点容错
			self.errorTimes = 0
			self:setStatus(LEGION_STATUS.SEARCH)
		end
	end
end

return BattleLegion