local BattleHelper = require("script/app/ui/battle/battlehelper")
local BuffAniMgr = require("script/app/ui/battle/effect/buffanimationmanager")

local ReplayBuff = class("BattleBuff")

function ReplayBuff:ctor(sid, owner)
	self.sid = sid
	local baseInfo = GameData:getConfData("buff")[sid]
	self.baseInfo = baseInfo
	self.owner = owner
	owner:addLimitStatus(baseInfo.banMove, baseInfo.banAtt, baseInfo.banSkill)	-- 设置控制
	if baseInfo.loseControl > 0 then -- 不受控制
		owner:loseControl(sid, baseInfo.loseControl)
	end
	if baseInfo.buffRes ~= "0" then -- buff特效1
		self:createBuffAni(owner, baseInfo)
	end
	if baseInfo.buffRes2 ~= "0" then -- buff特效2
		self:createBuffAni2(owner, baseInfo)
	end
	if baseInfo.reUrl ~= "0" then -- 变身
		self:changeModal()
	end
	owner:addBuff(self)
end

function ReplayBuff:remove()
	local baseInfo = self.baseInfo
	local owner = self.owner
	owner:removeLimitStatus(baseInfo.banMove, baseInfo.banAtt, baseInfo.banSkill)		-- 移除控制
	if baseInfo.loseControl > 0 then -- 恢复控制
		owner:resumeControl(self.sid, baseInfo.loseControl)
	end
	if self.effects then -- buff特效
		BuffAniMgr:putBack(baseInfo.buffRes, self.effects)
		self.effects = nil
	end
	if self.effects2 then
		BuffAniMgr:putBack(baseInfo.buffRes2, self.effects2)
		self.effects2 = nil
	end
	if baseInfo.reUrl ~= "0" then -- 恢复之前的模型
		self:resetModal()
	end
end

function ReplayBuff:createBuffAni(owner, baseInfo)
	local ani = BuffAniMgr:showBuffAni(owner.roleNode, baseInfo.buffRes)
	ani:setScale(owner.buffScale/100)
	local position
	if baseInfo.buffPos == 1 then
		position = cc.p(owner.attPx_t, owner.attPy_t)
	elseif baseInfo.buffPos == 2 then
		position = cc.p(owner.attPx_c, owner.attPy_c)
	else
		position = cc.p(owner.attPx_b, owner.attPy_b)
	end
	if baseInfo.buffZorder == 1 then
		ani:setLocalZOrder(2)
	else
		ani:setLocalZOrder(-1)
	end
	ani:setPosition(cc.p(baseInfo.buffOffsetX + position.x, baseInfo.buffOffsetY + position.y))
	if baseInfo.buffResType == 1 then
		ani:getAnimation():playWithIndex(0, -1, 0)
	else
		ani:getAnimation():playWithIndex(0, -1, 1)
	end
	self.effects = ani
end

function ReplayBuff:createBuffAni2(owner, baseInfo)
	local ani = BuffAniMgr:showBuffAni(owner.roleNode, baseInfo.buffRes2)
	ani:setScale(owner.buffScale/100)
	local position
	if baseInfo.buffPos2 == 1 then
		position = cc.p(owner.attPx_t, owner.attPy_t)
	elseif baseInfo.buffPos2 == 2 then
		position = cc.p(owner.attPx_c, owner.attPy_c)
	else
		position = cc.p(owner.attPx_b, owner.attPy_b)
	end
	if baseInfo.buffZorder2 == 1 then
		ani:setLocalZOrder(2)
	else
		ani:setLocalZOrder(-1)
	end
	ani:setPosition(cc.p(baseInfo.buffOffsetX2 + position.x, baseInfo.buffOffsetY2 + position.y))
	if baseInfo.buffResType2 == 1 then
		ani:getAnimation():playWithIndex(0, -1, 0)
	else
		ani:getAnimation():playWithIndex(0, -1, 1)
	end
	self.effects2 = ani
end

function ReplayBuff:changeModal()
	local baseInfo = self.baseInfo
	local owner = self.owner
	owner.armature:setVisible(false)
	local armatureNode = BattleHelper:createAniByName(baseInfo.reUrl)
	owner.roleNode:addChild(armatureNode)
	armatureNode:setScale(baseInfo.reScale/100)
	armatureNode:getAnimation():play("idle", -1, -1)
	owner._armature = armatureNode
end

function ReplayBuff:resetModal()
	if self.owner._armature then
		self.owner._armature:removeFromParent()
		self.owner._armature = nil
	end
	self.owner.armature:setVisible(true)
end

function ReplayBuff:reset()
end

return ReplayBuff