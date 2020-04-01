local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassEffects = require("script/app/ui/battle/effect/battleeffect")

local EffectMgr = {
	bfNode = nil,
	effectsPools = nil
}

-- 初始化
function EffectMgr:init(bfNode)
	self.effectsPools = BattleHelper:createObjPools()
	self.bfNode = bfNode
	self.preloadList = {}
end

function EffectMgr:clear()
	self.bfNode = nil
	self.effectsPools = nil
	self.preloadList = nil
end

-- 获取一个特效对象
-- @sid: 特效表中对应的sid
function EffectMgr:getEffectsObj(sid)
	local effectsObj = self.effectsPools:pop(sid)
	if effectsObj == nil then
	-- 特效池中没有可用特效、创建一个新的
		effectsObj = ClassEffects.new(sid, self.effectsPools)
		self.bfNode:addChild(effectsObj.effectsNode)
	end
	return effectsObj
end

function EffectMgr:addPreloadAni(skillInfo)
	if skillInfo.skillAnimationId > 0 or skillInfo.skillAnimationId2 > 0 then
		local skillAnimationConf = GameData:getConfData("skillanimation")
		local preloadNum = 1
		if skillInfo.bulletType ~= 2 then -- 非中心点型子弹
			if skillInfo.bulletType == 3 then
				preloadNum = 2
			else
				if skillInfo.targetMaxNum == 0 then
					preloadNum = 1
				elseif skillInfo.targetMaxNum < 20 then
					preloadNum = skillInfo.targetMaxNum
				else
					preloadNum = 20
				end
			end
		end
		if skillInfo.bulletNum > 1 then
			preloadNum = preloadNum*skillInfo.bulletNum
		end
		if skillInfo.skillAnimationId > 0 then
			self.preloadList[skillInfo.skillAnimationId] = self.preloadList[skillInfo.skillAnimationId] or 0
			if skillAnimationConf[skillInfo.skillAnimationId].num > 0 then
				self.preloadList[skillInfo.skillAnimationId] = self.preloadList[skillInfo.skillAnimationId] + preloadNum*skillAnimationConf[skillInfo.skillAnimationId].num
			else
				self.preloadList[skillInfo.skillAnimationId] = self.preloadList[skillInfo.skillAnimationId] + preloadNum
			end
		end
		if skillInfo.skillAnimationId2 > 0 then
			self.preloadList[skillInfo.skillAnimationId2] = self.preloadList[skillInfo.skillAnimationId2] or 0
			if skillAnimationConf[skillInfo.skillAnimationId2].num > 0 then
				self.preloadList[skillInfo.skillAnimationId2] = self.preloadList[skillInfo.skillAnimationId2] + preloadNum*skillAnimationConf[skillInfo.skillAnimationId2].num
			else
				self.preloadList[skillInfo.skillAnimationId2] = self.preloadList[skillInfo.skillAnimationId2] + preloadNum
			end
		end
	end
end

function EffectMgr:preloadAni()
	for id, num in pairs(self.preloadList) do
		for i = 1, num do
			local aniObj = ClassEffects.new(id, self.effectsPools)
			aniObj.effectsNode:setVisible(false)
			self.bfNode:addChild(aniObj.effectsNode)
			self.effectsPools:push(id, aniObj)
		end
	end
	self.preloadList = nil
end

-- 显示一个特效
function EffectMgr:playEffects(skillAnimationId, skill, direction, position)
	local skillInfo = skill.baseInfo
	local sid = skillAnimationId
	local times = skillInfo.effectsTimes
	local effectsObj = self:getEffectsObj(sid)
	local info = effectsObj.info
	local px = position.x + info.px*direction
	effectsObj:getCCNode():setScaleX(effectsObj.scale*direction)
	local py = position.y + info.py
	local lastEffectsObj = effectsObj
	effectsObj:init(times, info.py, skill, true)
	effectsObj:play(0, px, py, info.randomPlay, info.randomRange)
	if info.type == 2 then
	-- 多个特效
		for i = 1, info.num do
			if i > 1 then
				local effectsChild = self:getEffectsObj(sid)
				effectsChild:getCCNode():setScaleX(effectsObj.scale*direction)
				effectsChild:init(times, info.py)
				effectsChild:play(info.interval*(i-1), px, py, info.randomPlay, info.randomRange)
				effectsObj:addChild(effectsChild)
				lastEffectsObj = effectsChild
			end
		end
	end

	-- 需要显示范围光圈并且只有君主技能才显示
	--[[
	if skillInfo.showRange > 0 then
		local rangeNode = cc.Node:create()
		local rangeSprite
		if aiSender.guid == 2 then
			rangeSprite = cc.Sprite:create("uires/ui/battle/skill_range2.png")
		else
			rangeSprite = cc.Sprite:create("uires/ui/battle/skill_range1.png")
		end
		local w = skillInfo.rangeX2-skillInfo.rangeX1
		local h = skillInfo.rangeY2-skillInfo.rangeY1
		rangeNode:setScaleX(w/200)
		rangeNode:setScaleY(h/200)
		rangeNode:setPosition(position)
		self.bfNode:addChild(rangeNode)
		rangeNode:addChild(rangeSprite)

		--local rangeObj = {}
		--function rangeObj:getCCNode()
			--return rangeNode
		--end
		BattleHelper:setZorder(rangeNode, position.y, 1)

		--local act1 = cc.RepeatForever:create(cc.RotateBy:create(5, 360))
		--local act2 = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, 10), cc.FadeTo:create(0.5, 120)))
		--rangeSprite:setOpacity(120)
		--rangeSprite:runAction(act1)
		--rangeSprite:runAction(act2)

		lastEffectsObj.rangeNode = rangeNode
	end
	]]
	return effectsObj
end

return EffectMgr