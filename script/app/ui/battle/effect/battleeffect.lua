local BattleHelper = require("script/app/ui/battle/battlehelper")

local BattleEffect = class("BattleEffect")

function BattleEffect:ctor(sid, effectsPools)
	local info = GameData:getConfData("skillanimation")[sid]
	-- 创建特效节点
	local effectsNode = BattleHelper:createAniByName(info.res)
	local animation = effectsNode:getAnimation()
	local scale = info.scale/100
	effectsNode:setScale(scale)
	-- 设置特效属性
	self.info = info
	self.effectsNode = effectsNode
	self.animation = animation
	self.playTimes = 1
	self.playedTimes = 0
	self.px = 0
	self.py = 0
	self.zorderPy = 0
	self.scale = scale
	-- 设置回调
	local function movementFun(armature, movementType, movementID)
		if movementType == 0 then
		-- 特效播放开始
			if info.type == 2 then
				local posX = self.px + math.random(info.rangeX1, info.rangeX2)
				local posY = self.py + math.random(info.rangeY1, info.rangeY2)
				self.effectsNode:setPosition(posX, posY)
				BattleHelper:setZorder(self.effectsNode, posY-self.zorderPy-1, info.zorderType)
			elseif self.playedTimes == 0 then
				self.effectsNode:setPosition(self.px, self.py)
				BattleHelper:setZorder(self.effectsNode, self.py-self.zorderPy-1, info.zorderType)
			end
		elseif movementType == 2 then
		-- 特效播放结束
			local function endFun()
				self.animation:gotoAndPause(0)
				self.effectsNode:setVisible(false)
				effectsPools:push(sid, self)
				if self.rangeNode then
				-- 如果有范围光圈，移除光圈
					self.rangeNode:removeFromParent()
					self.rangeNode = nil
				end
			end
			if self.stopFlag then
				endFun()
				return
			end
			self.playedTimes = self.playedTimes + 1
			if self.playedTimes >= self.playTimes then
			-- 特效播放次数完成
				endFun()
				return
			end
			if info.type == 2 then
			-- 重新设置位置
				local posX = self.px + math.random(info.rangeX1, info.rangeX2)
				local posY = self.py + math.random(info.rangeY1, info.rangeY2)
				self.effectsNode:setPosition(posX, posY)
				BattleHelper:setZorder(self.effectsNode, posY-self.zorderPy-1, info.zorderType)
			end
		end
	end
	self.animation:setMovementEventCallFunc(movementFun)
end

-- 初始化
-- @playTimes: 播放次数
-- @majorFlag: 是否为主特效(多个特效的情况)
function BattleEffect:init(playTimes, zorderPy, skill, majorFlag)
	self.playTimes = playTimes
	self.skill = skill
	self.zorderPy = zorderPy
	self.playedTimes = 0
	self.majorFlag = majorFlag
	self.children = {}
end

-- getCCNode
-- 获取节点
function BattleEffect:getCCNode()
	return self.effectsNode
end

-- addChild
-- 添加子特效
function BattleEffect:addChild(effectsObj)
	table.insert(self.children, effectsObj)
end

function BattleEffect:setStop(skill, flag)
	if self.skill and self.skill == skill then
		self.stopFlag = flag
	end
end

-- 特效开始播放
-- @delay: 延迟时间(毫秒)
-- @px: 坐标x
-- @py: 坐标y
function BattleEffect:play(delay, px, py, randomPlay, randomRange)
	self.px = px
	self.py = py
	self.stopFlag = false
	local function playFun()
		self.effectsNode:setVisible(true)
		if randomPlay == 0 then
			self.animation:playWithIndex(0, -1, 1)
		else
			self.animation:play("Animation" .. math.random(1, randomRange), -1, 1)
		end
	end
	if delay > 0 then
		self.effectsNode:runAction(cc.Sequence:create(cc.DelayTime:create(delay/1000), cc.CallFunc:create(playFun)))
	else
		playFun()
	end
end

return BattleEffect