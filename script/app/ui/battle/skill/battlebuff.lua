local BattleHelper = require("script/app/ui/battle/battlehelper")
local BuffAniMgr = require("script/app/ui/battle/effect/buffanimationmanager")

local BattleBuff = class("BattleBuff")

local HALO_ACTION_TAG = 100000000
local REMOVE_ACTION_TAG = 200000000
local EFFECT_ACTION_TAG = 300000000

function BattleBuff:ctor(sid, owner, sender)
	self.sid = sid
	local baseInfo = GameData:getConfData("buff")[sid]
	self.baseInfo = baseInfo
	self.owner = owner
	self.sender = sender
	self.guid = sender.guid
	self.skillType = 0
	if owner.ignoreMag > 0 and baseInfo.type == 1 and baseInfo.dirType == 1 then -- 拥有者魔法免疫 & 此为普通负面buff
		return
	end
	if owner.ignoreControl > 0 then -- 免疫控制技能
		if baseInfo.banMove > 0 or baseInfo.banAtt > 0 or baseInfo.banSkill > 0 then
			return
		end
	end
	local buffListNum = #owner.buffList
	if baseInfo.ignoreMag > 0 then -- 魔法免疫，清除所有所有负面buff
		for i = buffListNum, 1, -1 do
			local buff = owner.buffList[i]
			if buff.baseInfo.type == 1 and buff.baseInfo.dirType == 1 then
				buff:remove()
				table.remove(owner.buffList, i)
			end
		end
	end
	-- 重置相同的buff
	for i, buff in ipairs(owner.buffList) do
		if buff.sid == sid then
			buff:reset()
			return
		end
	end
	-- buff发送的效果
	if baseInfo.effectId > 0 then
		self:effectTargetByBuff(owner, sender, baseInfo)
	end
	if baseInfo.attributeId > 0 then
		if baseInfo.attributeId == 1 then
			owner.maxHp = owner.maxHp + baseInfo.attributeValue
			owner.maxHp = owner.maxHp + owner.baseHp*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 2 then
			owner.atk = owner.atk + baseInfo.attributeValue
			owner.atk = owner.atk + owner.baseAtk*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 4 then
			owner.phyDef = owner.phyDef + baseInfo.attributeValue
			owner.phyDef = owner.phyDef + owner.basePhyDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 8 then
			owner.magDef = owner.magDef + baseInfo.attributeValue
			owner.magDef = owner.magDef + owner.baseMagDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 12 then
			owner.phyDef = owner.phyDef + baseInfo.attributeValue
			owner.phyDef = owner.phyDef + owner.basePhyDef*baseInfo.attributePercent*0.01
			owner.magDef = owner.magDef + baseInfo.attributeValue
			owner.magDef = owner.magDef + owner.baseMagDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 16 then
			owner.hit = owner.hit + baseInfo.attributeValue
			owner.hit = owner.hit + owner.baseHit*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 32 then
			owner.dodge = owner.dodge + baseInfo.attributeValue
			owner.dodge = owner.dodge + owner.baseDodge*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 64 then
			owner.crit = owner.crit + baseInfo.attributeValue
			owner.crit = owner.crit + owner.baseCrit*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 128 then
			owner.resi = owner.resi + baseInfo.attributeValue
			owner.resi = owner.resi + owner.baseResi*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 256 then
			owner.attackSpeed = owner.attackSpeed + baseInfo.attributeValue*0.001
			owner.attackSpeed = owner.attackSpeed + owner.baseAttackSpeed*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 512 then
			owner.moveSpeed = owner.moveSpeed + baseInfo.attributeValue
			owner.moveSpeed = owner.moveSpeed + owner.baseMoveSpeed*baseInfo.attributePercent*0.01
		end
	end
	-- buff属性(记录数值)
	owner.attPercent = owner.attPercent + baseInfo.attPercent/100 					-- 造成伤害百分比修改
	owner.defPercent = owner.defPercent + baseInfo.defPercent/100 					-- 承受伤害百分比修改
	owner.reboundDmg = owner.reboundDmg + baseInfo.reboundDmg/100 					-- 反弹物理伤害百分比
	owner.cureIncrease = owner.cureIncrease + baseInfo.cureIncrease/100				-- 治疗效果加成
	owner.suckBlood = owner.suckBlood + baseInfo.suckBlood 						-- 攻击吸血固定值
	owner.suckBloodPercent = owner.suckBloodPercent + baseInfo.suckBloodPercent -- 攻击吸血百分比
	-- buff特殊属性(一下属性记录次数)
	owner.ignorePhy = owner.ignorePhy+baseInfo.ignorePhy 						-- 物理免疫
	owner.ignoreMag = owner.ignoreMag+baseInfo.ignoreMag 						-- 魔法免疫
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
		for i = buffListNum, 1, -1 do
			local buff = owner.buffList[i]
			if buff.baseInfo.reUrl ~= "0" then
				buff:remove()
				table.remove(owner.buffList, i)
				break
			end
		end
		self:changeModal()
	end
	if baseInfo.changeSkillGroup > 0 then -- 改变技能组
		owner:changeSkill(baseInfo.changeSkillGroup)
	end
	owner:addBuff(self)
	if baseInfo.buffMode > 0 then
		owner:addBuffMode(baseInfo.buffMode)
	end
	self.soldierList = {}
	self.influenceList = {}
	-- 光环buff
	if baseInfo.type == 2 and baseInfo.sendBuffId > 0 then
		local rangeTargetType = baseInfo.rangeTargetType
		local legionObj = owner.legionObj
		local armyArr
		if (legionObj.guid == 1 and rangeTargetType > 100) or (legionObj.guid == 2 and rangeTargetType < 100) then
			armyArr = legionObj.battlefield.armyArr[1]
		else
			armyArr = legionObj.battlefield.armyArr[2]
		end
		rangeTargetType = rangeTargetType%100
		if rangeTargetType == 1 then -- 英雄
			for k, v in ipairs(armyArr) do
				table.insert(self.soldierList, v.heroObj)
			end
		elseif rangeTargetType == 2 then -- 小兵
			for k, v in ipairs(armyArr) do
				for k2, v2 in ipairs(v.soldierObjs) do
					table.insert(self.soldierList, v2)
				end
			end
		elseif rangeTargetType == 3 then -- 所有
			-- 先英雄
			for k, v in ipairs(armyArr) do
				table.insert(self.soldierList, v.heroObj)
			end
			-- 再士兵
			for k, v in ipairs(armyArr) do
				for k2, v2 in ipairs(v.soldierObjs) do
					table.insert(self.soldierList, v2)
				end
			end
			-- 最后召唤物
			for k, v in ipairs(armyArr) do
				for k2, v2 in ipairs(v.summonObjs) do
					table.insert(self.soldierList, v2)
				end
			end
		end
		local function isInRange(obj)
			local x, y = obj:getPosition()
			local x2, y2 = owner:getPosition()
			if cc.pGetDistance(cc.p(x, y), cc.p(x2, y2)) > baseInfo.range then
				return false
			end
			return true
		end
		local function effectFun()
			for k, v in ipairs(self.soldierList) do
				if not v:isDead() then
					if isInRange(v) then
						if self.influenceList[v] then -- 如果已经在范围内
							if baseInfo.haloType == 1 then
								v:extendBuffById(baseInfo.sendBuffId)
							end
						else
							self.influenceList[v] = true
							self:createNewBuff(baseInfo, v, sender)
						end
					else
						if baseInfo.haloType == 1 then
							if self.influenceList[v] then -- 如果之前在范围内
								v:removeBuffById(baseInfo.sendBuffId)
							end
						end
					end
				end
			end
		end
		self:haloBuffTakeEffect(owner, baseInfo, effectFun)
	end
	self.arrivalTime = false
	-- 结束时间
	if baseInfo.durationTime > 0 then
		self:setOverTime(owner, baseInfo)
	end
end

function BattleBuff:remove()
	local baseInfo = self.baseInfo
	local owner = self.owner
	local sender = self.sender
	if baseInfo.effectId > 0 then
		owner:stopSkillActionByTag(EFFECT_ACTION_TAG + baseInfo.id)
	end
	if baseInfo.attributeId > 0 then
		if baseInfo.attributeId == 1 then
			owner.maxHp = owner.maxHp - baseInfo.attributeValue
			owner.maxHp = owner.maxHp - owner.baseHp*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 2 then
			owner.atk = owner.atk - baseInfo.attributeValue
			owner.atk = owner.atk - owner.baseAtk*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 4 then
			owner.phyDef = owner.phyDef - baseInfo.attributeValue
			owner.phyDef = owner.phyDef - owner.basePhyDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 8 then
			owner.magDef = owner.magDef - baseInfo.attributeValue
			owner.magDef = owner.magDef - owner.baseMagDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 12 then
			owner.phyDef = owner.phyDef - baseInfo.attributeValue
			owner.phyDef = owner.phyDef - owner.basePhyDef*baseInfo.attributePercent*0.01
			owner.magDef = owner.magDef - baseInfo.attributeValue
			owner.magDef = owner.magDef - owner.baseMagDef*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 16 then
			owner.hit = owner.hit - baseInfo.attributeValue
			owner.hit = owner.hit - owner.baseHit*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 32 then
			owner.dodge = owner.dodge - baseInfo.attributeValue
			owner.dodge = owner.dodge - owner.baseDodge*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 64 then
			owner.crit = owner.crit - baseInfo.attributeValue
			owner.crit = owner.crit - owner.baseCrit*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 128 then
			owner.resi = owner.resi - baseInfo.attributeValue
			owner.resi = owner.resi - owner.baseResi*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 256 then
			owner.attackSpeed = owner.attackSpeed - baseInfo.attributeValue*0.001
			owner.attackSpeed = owner.attackSpeed - owner.baseAttackSpeed*baseInfo.attributePercent*0.01
		elseif baseInfo.attributeId == 512 then
			owner.moveSpeed = owner.moveSpeed - baseInfo.attributeValue
			owner.moveSpeed = owner.moveSpeed - owner.baseMoveSpeed*baseInfo.attributePercent*0.01
		end
	end
	-- buff属性(记录数值)
	owner.attPercent = owner.attPercent - baseInfo.attPercent/100					-- 造成物理伤害百分比修改
	owner.defPercent = owner.defPercent - baseInfo.defPercent/100					-- 承受伤害百分比修改
	owner.reboundDmg = owner.reboundDmg - baseInfo.reboundDmg/100 					-- 反弹物理伤害百分比
	owner.cureIncrease = owner.cureIncrease - baseInfo.cureIncrease/100				-- 治疗效果加成
	owner.suckBlood = owner.suckBlood - baseInfo.suckBlood 							-- 攻击吸血固定值
	owner.suckBloodPercent = owner.suckBloodPercent - baseInfo.suckBloodPercent 	-- 攻击吸血百分比
	-- buff特殊属性(一下属性记录次数)
	owner.ignorePhy = owner.ignorePhy-baseInfo.ignorePhy 						-- 物理免疫
	owner.ignoreMag = owner.ignoreMag-baseInfo.ignoreMag 						-- 魔法免疫
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
	if baseInfo.changeSkillGroup > 0 then -- 改变技能组
		owner:resetSkill()
	end
	if baseInfo.type == 2 and baseInfo.sendBuffId > 0 then -- 光环buff
		owner:stopSkillActionByTag(HALO_ACTION_TAG + baseInfo.id)
		if baseInfo.haloType == 1 then
			for k, v in pairs(self.influenceList) do
				k:removeBuffById(baseInfo.sendBuffId)
			end
		end
	end
	if baseInfo.buffMode > 0 then
		owner:removeBuffMode(baseInfo.buffMode)
	end
	if self.halo then
		self.halo.influenceList[owner] = nil
	end
	if not self.arrivalTime then
		owner:stopSkillActionByTag(REMOVE_ACTION_TAG + baseInfo.id)
	end
	owner:finishRemoveBuff(self.sid)
end

function BattleBuff:reset()
	if self.effects then
		if self.baseInfo.buffResType == 1 then
			self.effects:setVisible(true)
			self.effects:getAnimation():playWithIndex(0, -1, 0)
		end
	end
	if self.effects2 then
		if self.baseInfo.buffResType2 == 1 then
			self.effects2:setVisible(true)
			self.effects2:getAnimation():playWithIndex(0, -1, 0)
		end
	end
	self.arrivalTime = false
	self:resetOverTime()
end

-- *************************************************
-- 下面的方法战报里重写过,如果要修改的话战报也得改

function BattleBuff:effectTargetByBuff(owner, sender, baseInfo)
	local effectAct = nil
	local effectActions = {}
	local lastTime = baseInfo.durationTime
	local function effectFun()
		if not owner.battlefield:isBattleEnd() then
			BattleHelper:skillEffect(self, sender, owner)
		end
	end
	-- 延迟
	if baseInfo.effectDelay > 0 then
		table.insert(effectActions, cc.DelayTime:create(baseInfo.effectDelay/1000))
		lastTime = lastTime - baseInfo.effectDelay
	end
	-- 第一个效果
	table.insert(effectActions, cc.CallFunc:create(effectFun))
	-- 剩下的效果
	if baseInfo.effectInterval > 0 then
		table.insert(effectActions, cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(baseInfo.effectInterval/1000), cc.CallFunc:create(effectFun)), 999999))
	end
	-- 结束
	effectAct = cc.Sequence:create(effectActions)
	effectAct:setTag(EFFECT_ACTION_TAG + self.sid)
	owner:runSkillAction(effectAct)
end

function BattleBuff:createBuffAni(owner, baseInfo)
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

function BattleBuff:createBuffAni2(owner, baseInfo)
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

function BattleBuff:setOverTime(owner, baseInfo)
	local removeAct = cc.Sequence:create(cc.DelayTime:create(baseInfo.durationTime/1000), cc.CallFunc:create(function ()
		self.arrivalTime = true
		self:remove()
		-- 将buff从相应的列表中移除
		for i, buff in ipairs(owner.buffList) do
			if buff == self then
				table.remove(owner.buffList, i)
				break
			end
		end
	end))
	removeAct:setTag(REMOVE_ACTION_TAG + self.sid)
	owner:runSkillAction(removeAct)
end

function BattleBuff:haloBuffTakeEffect(owner, baseInfo, effectFun)
	local effectActions = {}
	-- 第一个效果
	table.insert(effectActions, cc.CallFunc:create(effectFun))
	-- 剩下的效果
	if baseInfo.checkInterval > 0 then
		table.insert(effectActions, cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(baseInfo.checkInterval/1000), cc.CallFunc:create(effectFun)), 999999))
	end
	local effectAct = cc.Sequence:create(effectActions)
	effectAct:setTag(HALO_ACTION_TAG + self.sid)
	owner:runSkillAction(effectAct)
end

function BattleBuff:changeModal()
	local baseInfo = self.baseInfo
	local owner = self.owner
	owner.armature:setVisible(false)
	local armatureNode = BattleHelper:createAniByName(baseInfo.reUrl)
	owner.roleNode:addChild(armatureNode)
	armatureNode:setScale(baseInfo.reScale/100)
	armatureNode:getAnimation():play("idle", -1, -1)
	owner._armature = armatureNode
end

function BattleBuff:resetModal()
	if self.owner._armature then
		self.owner._armature:removeFromParent()
		self.owner._armature = nil
	end
	self.owner.armature:setVisible(true)
end

function BattleBuff:resetOverTime()
	local owner = self.owner
	local removeAct = cc.Sequence:create(cc.DelayTime:create(self.baseInfo.durationTime/1000), cc.CallFunc:create(function ()
		self.arrivalTime = true
		self:remove()
		for i, buff in ipairs(owner.buffList) do
			if buff == self then
				table.remove(owner.buffList, i)
				break
			end
		end
	end))
	removeAct:setTag(REMOVE_ACTION_TAG + self.baseInfo.id)
	owner:stopSkillActionByTag(REMOVE_ACTION_TAG + self.baseInfo.id)
	owner:runSkillAction(removeAct)
end

function BattleBuff:createNewBuff(baseInfo, v, sender)
	local newBuff = BattleBuff.new(baseInfo.sendBuffId, v, sender)
	newBuff.halo = self
end

-- *************************************************

return BattleBuff