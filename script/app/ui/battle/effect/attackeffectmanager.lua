local BattleHelper = require("script/app/ui/battle/battlehelper")

local AttackEffectMgr = {
	attEffectsPools = nil
}

local ATTACK_EFFECT_TAG = 100

-- 初始化
function AttackEffectMgr:init()
	self.attEffectsPools = BattleHelper:createObjPools()
	self.preloadList = {}
end

function AttackEffectMgr:clear()
	if self.attEffectsPools then
		for k, v in pairs(self.attEffectsPools.dataPools) do
			for k2, v2 in pairs(v.data) do
				v2:release()
			end
		end
		self.attEffectsPools = nil
	end
	self.preloadList = nil
end

function AttackEffectMgr:addPreloadAni(skillInfo)
	local preloadNum = 1
	if skillInfo.targetMaxNum == 0 then
		preloadNum = 1
	elseif skillInfo.targetMaxNum < 20 then
		preloadNum = skillInfo.targetMaxNum
	else
		preloadNum = 30
	end
	if skillInfo.bulletNum > 1 then
		preloadNum = preloadNum*skillInfo.bulletNum
	end
	self.preloadList[skillInfo.affectedRes] = self.preloadList[skillInfo.affectedRes] or 0
	self.preloadList[skillInfo.affectedRes] = self.preloadList[skillInfo.affectedRes] + preloadNum
end

function AttackEffectMgr:preloadAni()
	for res, num in pairs(self.preloadList) do
		for i = 1, num do
			local attEffectsNode = self:createAttEffect(res)
			attEffectsNode:retain()
			self.attEffectsPools:push(res, attEffectsNode)
		end
	end
	self.preloadList = nil
end

-- 创建出一个受击特效
function AttackEffectMgr:createAttEffect(res)
	local attEffectNode = BattleHelper:createAniByName(res)
	local animation = attEffectNode:getAnimation()
	local function movementFun(armature, movementType, movementID)
		if movementType == 1 then
		-- 特效播放结束
			attEffectNode:retain()
			attEffectNode:removeFromParent(false)
			self.attEffectsPools:push(res, attEffectNode)
		end
	end
	animation:setMovementEventCallFunc(movementFun)
	attEffectNode:setTag(ATTACK_EFFECT_TAG)
	return attEffectNode
end

-- 为ai设置一个受击特效
-- @aiObj: 受击ai
-- @res: 特效资源
-- @pos: 特效位置
-- @zOrder: 特效渲染层级
function AttackEffectMgr:setAttEffect(aiObj, res, pos, zOrder, scale)
	if aiObj.roleNode:getChildByTag(ATTACK_EFFECT_TAG) then
		return
	end
	local position
	if pos == 1 then
		position = cc.p(aiObj.attPx_t, aiObj.attPy_t)
	elseif pos == 2 then
		position = cc.p(aiObj.attPx_c, aiObj.attPy_c)
	else
		position = cc.p(aiObj.attPx_b, aiObj.attPy_b)
	end
	local attEffectsNode = self.attEffectsPools:pop(res)
	if attEffectsNode == nil then
		attEffectsNode = self:createAttEffect(res)
		aiObj.roleNode:addChild(attEffectsNode)
	else
		aiObj.roleNode:addChild(attEffectsNode)
		attEffectsNode:release()
	end
	if zOrder == 1 then
		attEffectsNode:setLocalZOrder(3)
	else
		attEffectsNode:setLocalZOrder(-1)
	end
	attEffectsNode:setPosition(position)
	attEffectsNode:setScale(scale/100)
	attEffectsNode:getAnimation():playWithIndex(0, -1, 0)
end

return AttackEffectMgr