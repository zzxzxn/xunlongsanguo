local ClassHero = require("script/app/ui/battle/legion/battlehero")
local ClassSoldier = require("script/app/ui/battle/legion/battlesoldier")
local ClassSummon = require("script/app/ui/battle/legion/battlesummon")
local ClassReplayBuff = require("script/app/ui/battle/replay/replaybuff")
local ClassReplaySkill = require("script/app/ui/battle/replay/replayskill")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local BulletMgr = require("script/app/ui/battle/skill/bulletmanager")
local AttackEffectMgr = require("script/app/ui/battle/effect/attackeffectmanager")

local ReplayBaseSoldier = class("ReplayBaseSoldier")

local SKILL_TYPE = BattleHelper.ENUM.SKILL_TYPE
local SOLDIER_STATUS = BattleHelper.ENUM.SOLDIER_STATUS
local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME
local MOVE_ACTION_TAG = 888
local HP_ACTION_TAG = 1000
local LOSE_CONTROL_TAG = 8

local function getDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2)))
end

function ReplayBaseSoldier:ctor(legionObj, soldierType, soldierIndex)
	self.guid = legionObj.guid
	self.legionObj = legionObj
	self.soldierType = soldierType
	self.soldierIndex = soldierIndex
	self.specialAI = self:getAIBySoldierType(soldierType)
end

function ReplayBaseSoldier:getAIBySoldierType(soldierType)
	if soldierType == 1 then
		return ClassHero
	elseif soldierType == 2 then
		return ClassSoldier
	elseif soldierType == 3 then
		return ClassSummon
	end
end

function ReplayBaseSoldier:init(position, offsetPos)
	self.offsetPos = offsetPos
	self.specialAI:initAttribute(self)
	self.battlefield = self.legionObj.battlefield
	self:createNode(position)
	self.needIdle = false
	self.currAction = ""
	self:playAction("idle", true)
	self.legionType = self.legionObj.legionType
	self.isTalking = false
	self.rolePosOffset = {
		x = 0,
		y = 0
	}
	self.buffList = {}
	self.pauseFlag = false
	self.loseControlId = 0
	self.selectEnable = 1
	self.limitMove = 0								
	self.limitAtt = 0
	self.limitSkill = 0
	self:initSkill()
	self:updateZorder(position.y)
end

function ReplayBaseSoldier:initSkill()
	local skillGroupInfo = GameData:getConfData("skillgroup")[self.skillGroupId]
	if skillGroupInfo == nil then
		return
	end
	self.skills = {}
	if skillGroupInfo.baseSkill > 0 then -- 普通攻击
		self.skills[skillGroupInfo.baseSkill] = self:createSkill(skillGroupInfo.baseSkill, SKILL_TYPE.NORMAL_ATTACK)
	end
	if skillGroupInfo.autoSkill1 > 0 then -- 触发技能
		local autoSkillId = skillGroupInfo.autoSkill1 + self.skillLevel - 1
		self.skills[autoSkillId] = self:createSkill(autoSkillId, SKILL_TYPE.AUTO_SKILL)
	end
	if skillGroupInfo.angerSkill > 0 then -- 手动技能
		local angerSkillId = skillGroupInfo.angerSkill + self.skillLevel - 1
		self.skills[angerSkillId] = self:createSkill(angerSkillId, SKILL_TYPE.ANGER_SKILL)
	end
end

function ReplayBaseSoldier:createSkill(skillId, skillType)
	return ClassReplaySkill.new(skillId, self, skillType)
end

function ReplayBaseSoldier:playAction(actionName, repeatFlag, needIdle)
	if repeatFlag and actionName == self.currAction then
		return
	end
	if repeatFlag then
		self.armature:getAnimation():play(actionName, -1, 1)
	else
		self.armature:getAnimation():play(actionName, -1, -1)
	end
	self.currAction = actionName
	self.needIdle = needIdle
end

function ReplayBaseSoldier:initSummonSpeciality()
	self.selectEnable = self.summonInfo.selectEnable
	self:showBornAnimation()
end

function ReplayBaseSoldier:showBornAnimation()
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
			end
		end
		appearEfNode:getAnimation():setMovementEventCallFunc(movementFun)
		appearEfNode:getAnimation():playWithIndex(0, -1, 0)
	end
	BattleHelper:setSoldierTag(self, self.summonInfo.zorderType)
end

function ReplayBaseSoldier:updateZorder(posy)
	BattleHelper:setSoldierTag(self)
	BattleHelper:setSoldierZorder(self)
	BattleHelper:setSoldierHpZorder(self.effectNode, posy)
end

function ReplayBaseSoldier:createNode(pos)
	self.root = cc.Node:create()
	self.battlefield.bgImg:addChild(self.root)
	self.root:setPosition(pos)
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
	self.effectNode:setPosition(pos)
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
end

function ReplayBaseSoldier:initModel()
	local armatureNode
	if self.soldierType == 1 then
		-- if string.sub(self.url, 1, 4) == "nan_" then
		-- 	armatureNode = BattleHelper:createAniByName(self.url, "animation/nan/nan", self.changeEquipObj)
		-- else
			armatureNode = BattleHelper:createAniByName(self.url, nil, self.changeEquipObj)
		-- end
	else
		-- if self.urlType == 1 then
		-- 	armatureNode = BattleHelper:createAniByName(self.url, "animation_littlelossy/xiaobing/xiaobing")
		-- else
			armatureNode = BattleHelper:createAniByName(self.url)
		-- end
	end
	self.originalScale = self.scale*0.01
	armatureNode:setScale(self.originalScale)
	local function movementFun(armature, movementType, movementID)
		if movementType == 1 then
			self:movementComplete(movementID)
		elseif self.playWinAction and movementType == 2 and self.currAction ~= "shengli" then
			if self.guid == 1 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
			self:playAction("shengli", true)
		end
	end
	armatureNode:getAnimation():setMovementEventCallFunc(movementFun)
	return armatureNode
end

function ReplayBaseSoldier:movementComplete(movementID)
	if self.currSkill then
		if self.playWinAction then
			if self.guid == 1 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
			self:playAction("shengli", true)
			return
		end
		if self.currSkill:isCasting() then
			self:playAction(self.currAction, false, true)
		else
			self.currSkill = nil
			if self.needIdle then
				self:playAction("idle", true)
			end
		end
	elseif self.needIdle then
		self:playAction("idle", true)
	end
end	

function ReplayBaseSoldier:getPosition()
	return self.root:getPosition()
end

function ReplayBaseSoldier:setLeader(isLeader)
	self.isLeader = isLeader
end

function ReplayBaseSoldier:getPositionX()
	return self.root:getPositionX()
end

function ReplayBaseSoldier:getPositionY()
	return self.root:getPositionY()
end

function ReplayBaseSoldier:getRolePosOffset()
	return self.rolePosOffset
end

function ReplayBaseSoldier:setDirection(scaleX)
	self.roleNode:setScaleX(scaleX)
end

function ReplayBaseSoldier:loseControl(buffId, moveType)
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

function ReplayBaseSoldier:pause()
	self.pauseFlag = true
	xx.Utils:Get():pauseArmatureAnimation(self.armature)
end

function ReplayBaseSoldier:resume()
	self.pauseFlag = false
	xx.Utils:Get():resumeArmatureAnimation(self.armature)
end

function ReplayBaseSoldier:resumeControl(buffId, moveType)
	if self.loseControlId == buffId then
		self:removeLoseControlStatus(moveType)
	end
end

function ReplayBaseSoldier:removeLoseControlStatus(moveType)
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

function ReplayBaseSoldier:runMoveAction(time, pos, callback, dashFlag)
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

function ReplayBaseSoldier:getSkill(skillId, skillType)
	if self.skills[skillId] == nil then
		self.skills[skillId] = self:createSkill(skillId, skillType)
	end
	return self.skills[skillId]
end

function ReplayBaseSoldier:stopAllActions()
	self.root:stopAllActions()
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
end

function ReplayBaseSoldier:showHpBar()
	local act1 = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function ()
		self.hpNode:setVisible(false)
	end))
	self.hpNode:setVisible(true)
	act1:setTag(HP_ACTION_TAG)
	self.hpNode:stopActionByTag(HP_ACTION_TAG)
	self.hpNode:runAction(act1)
end


function ReplayBaseSoldier:setHpBarPercent(hpNum)
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
	end
end

function ReplayBaseSoldier:isDead()
	return self.status == SOLDIER_STATUS.DEAD
end

function ReplayBaseSoldier:showDamage(showNum, hpNum, flag)
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

function ReplayBaseSoldier:addBuff(buff)
	table.insert(self.buffList, buff)
end

function ReplayBaseSoldier:removeBuffById(id)
	for i, buff in ipairs(self.buffList) do
		if buff.sid == id then
			buff:remove()
			table.remove(self.buffList, i)
			break
		end
	end
end

-- 停止攻击
function ReplayBaseSoldier:stop()
	if self:isDead() then
		return
	end
	self:stopAllActions()
	self:playAction("idle", true)
end

function ReplayBaseSoldier:removeBuffs()
	for i, buff in ipairs(self.buffList) do
		buff:remove()
	end
	self.buffList = {}
end

function ReplayBaseSoldier:setHpBarVis(vis)
	self.hpNode:setVisible(vis)
end

function ReplayBaseSoldier:battleOver(playWinAction)
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

function ReplayBaseSoldier:setStatus(status)
	if status == SOLDIER_STATUS.DEAD then
		self.status = status
		return
	end
	if self.status == SOLDIER_STATUS.DEAD or self.status == SOLDIER_STATUS.OVER then
		return
	end
	self.status = status
end

function ReplayBaseSoldier:moveTogether(pos)
	local targetPos = cc.pAdd(pos, self.offsetPos)
	local x, y = self:getPosition()
	if x < targetPos.x then
		self:setDirection(1)
	else
		self:setDirection(-1)
	end
	local time = getDistance(x, y, targetPos.x, targetPos.y)/self.moveSpeed
	if time > 0.01 then
		self:runMoveAction(time, targetPos, function ()
			if self.guid == 1 then
				self:setDirection(1)
			else
				self:setDirection(-1)
			end
			self:playAction("idle", true)
		end, 1)
	end
end

function ReplayBaseSoldier:moveToOtherPos(action)
	self.root:stopAllActions()
	self.root:runAction(action)
end

function ReplayBaseSoldier:setPosition(position)
	self.root:setPosition(position)
	self.effectNode:setPosition(position)
end

function ReplayBaseSoldier:addLimitStatus(limitMove, limitAtt, limitSkill)
	if limitMove > 0 then
		if self.limitMove <= 0 then
			if self.currAction == "run" or self.currAction == "walk" then
				self:playAction("idle", true)
			end
			self:stopMove()
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
function ReplayBaseSoldier:removeLimitStatus(limitMove, limitAtt, limitSkill)
	self.limitMove = self.limitMove - limitMove
	self.limitAtt = self.limitAtt - limitAtt
	self.limitSkill = self.limitSkill - limitSkill
end

function ReplayBaseSoldier:stopAttack(skillType)
	if skillType == 0 then -- 所有攻击
		if self.currSkill then
			self.currSkill = nil
			self:playAction("idle", true)
		end
	elseif skillType == 1 then -- 普攻
		if self.currSkill and self.currSkill.skillType == SKILL_TYPE.NORMAL_ATTACK then
			self.currSkill = nil
			self:playAction("idle", true)
		end
	elseif skillType == 2 then -- 非普攻
		if self.currSkill and self.currSkill.skillType ~= SKILL_TYPE.NORMAL_ATTACK then
			self.currSkill = nil
			self:playAction("idle", true)
		end
	end
end

function ReplayBaseSoldier:stopMove()
	self.root:stopActionByTag(MOVE_ACTION_TAG)
	self.effectNode:stopActionByTag(MOVE_ACTION_TAG)
end

function ReplayBaseSoldier:clearMp()
	self.mp = 0
	if self.mpBar then
		self.mpBar:setPercent(0)
	end
end

function ReplayBaseSoldier:getDirection()
	return self.roleNode:getScaleX()
end

function ReplayBaseSoldier:showSkillShout()
	if self.isTalking then
		self.isTalking = false
		self.talkNode:setVisible(false)
	end
	local shoutName = self.currSkill.baseInfo.skillShoutName
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

function ReplayBaseSoldier:showSuckAnimation()
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

function ReplayBaseSoldier:playDie()
	if not self:isDead() then
		self:removeBuffs()
		self:stopAllActions()
		self:playAction("dead")
		self:setStatus(SOLDIER_STATUS.DEAD)
		self:setHpBarVis(false)
		if self.selectEnable > 0 then
			self.armature:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.FadeOut:create(3.0), cc.CallFunc:create(function ()
				self.root:setVisible(false)
			end)))
		else
			self.root:setVisible(false)
		end
		if self.soldierType == 1 then
			self:clearMp()
			self.battlefield:addKillAnimation(self.guid, self.legionObj.pos, self.legionObj.headpic)
		end
		self:removeAllAnimation()
	end
end

function ReplayBaseSoldier:removeAllAnimation()
	if self.godAni then
		self.godAni:removeFromParent()
		self.godAni = nil
	end
end

function ReplayBaseSoldier:playWithRecord(act)
	if act[2] == REPORT_NAME.MOVE then
		local x, y = self:getPosition()
		if x < act[3] then
			self:setDirection(1)
		else
			self:setDirection(-1)
		end
		self:runMoveAction(act[5], cc.p(act[3], act[4]), function ()
			if self.currSkill == nil or self.currAction ~= self.currSkill:getActionName() then
				self:playAction("idle", true)
			end
		end, act[6])
	elseif act[2] == REPORT_NAME.USESKILL then
		local skill = self:getSkill(act[3], act[4])
		self.currSkill = skill
		if skill:isNeedShout() then
			self:showSkillShout()
		end
		skill:useSkill()
		self:setDirection(act[5])
		self:stopAllActions()
		self:playAction(skill:getActionName(), false, true)	
	elseif act[2] == REPORT_NAME.HURT then
		if act[3] ~= 0 then
			if self.soldierType < 3 then
				if act[3] + self.hp < 0 then -- 伤害溢出
					self.battlefield:addPlayerHealth(self.guid, -self.hp, self.soldierType)
				elseif act[3] + self.hp > self.maxHp then -- 加血溢出
					self.battlefield:addPlayerHealth(self.guid, self.maxHp - self.hp, self.soldierType)
				else
					self.battlefield:addPlayerHealth(self.guid, act[3], self.soldierType)
				end
			end
			self.hp = self.hp + act[3]
			if self.hp <= 0 then
				self.hp = 0
			else
				if self.hp > self.maxHp then
					self.hp = self.maxHp
				end
				if self.soldierType == 1 then
					self:showHpBar()
				elseif act[4] then
					self:showHpBar()
				end
			end
			self:setHpBarPercent(act[3])
		end
		self:showDamage(act[4], act[3], act[5])
		if act[6] ~= 0 then
			-- 1免疫,2闪避,3暴击,4反弹,5吸血
			if act[5] < 4 then
				local baseInfo = GameData:getConfData("skill")[act[6]]
				if baseInfo.affectedRes ~= "0" then -- 受击特效
					AttackEffectMgr:setAttEffect(self, baseInfo.affectedRes, baseInfo.affectedPos, baseInfo.affectedZorder, self.hitScale)
				end
				if baseInfo.hitSoundEffect ~= "0" then
					BattleHelper:playSound(baseInfo.hitSoundEffect, false)
				end
			elseif act[5] == 5 then
				self:showSuckAnimation()
			end
		end
	--elseif act[2] == REPORT_NAME.SKILLEFFECT then
	elseif act[2] == REPORT_NAME.SENDBULLET then
		local skill = self:getSkill(act[4], act[5])
		if act[8] == 1 then
			if skill.baseInfo.bulletId == 0 then
				if skill.baseInfo.skillAnimationId > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId, act[9], act[10])
				end
				if skill.baseInfo.skillAnimationId2 > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId2, act[9], act[10])
				end
			else
				BulletMgr:sendBullet(skill, skill.baseInfo.bulletId, cc.p(act[6], act[7]), act[9], act[10], function ()
					if skill.baseInfo.skillAnimationId > 0 then
						skill:playSkillAnimation(skill.baseInfo.skillAnimationId, act[9], act[10])
					end
					if skill.baseInfo.skillAnimationId2 > 0 then
						skill:playSkillAnimation(skill.baseInfo.skillAnimationId2, act[9], act[10])
					end
				end, act[8])
			end
		elseif act[8] == 2 then
			local legion
			local soldier
			if act[10][1] == 1 then
				legion = self.battlefield.armyMap[act[10][2]]
			else
				legion = self.battlefield.enemyMap[act[10][2]]
			end
			if act[10][3] == 1 then
				soldier = legion.heroObj
			elseif act[10][3] == 2 then
				soldier = legion.soldierObjs[act[10][4]]
			elseif act[10][3] == 3 then
				soldier = legion.summonObjs[act[10][4]]
			end
			if skill.baseInfo.bulletId == 0 then
				if skill.baseInfo.skillAnimationId > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId, act[9], cc.p(soldier:getPosition()))
				end
				if skill.baseInfo.skillAnimationId2 > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId2, act[9], cc.p(soldier:getPosition()))
				end
			else
				BulletMgr:sendBullet(skill, skill.baseInfo.bulletId, cc.p(act[6], act[7]), act[9], soldier, function (target)
					if skill.baseInfo.skillAnimationId > 0 then
						skill:playSkillAnimation(skill.baseInfo.skillAnimationId, act[9], cc.p(soldier:getPosition()))
					end
					if skill.baseInfo.skillAnimationId2 > 0 then
						skill:playSkillAnimation(skill.baseInfo.skillAnimationId2, act[9], cc.p(soldier:getPosition()))
					end
				end, act[8])
			end
		elseif act[8] == 3 then
			local targets = {}
			for k, v in ipairs(act[10]) do
				local legion
				local soldier
				if v[1] == 1 then
					legion = self.battlefield.armyMap[v[2]]
				else
					legion = self.battlefield.enemyMap[v[2]]
				end
				if v[3] == 1 then
					soldier = legion.heroObj
				elseif v[3] == 2 then
					soldier = legion.soldierObjs[v[4]]
				elseif v[3] == 3 then
					soldier = legion.summonObjs[v[4]]
				end
				targets[k] = soldier
			end
			BulletMgr:sendBullet(skill, skill.baseInfo.bulletId, cc.p(act[6], act[7]), act[9], targets, function (target)
				if skill.baseInfo.skillAnimationId > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId, act[9], cc.p(target:getPosition()))
				end
				if skill.baseInfo.skillAnimationId2 > 0 then
					skill:playSkillAnimation(skill.baseInfo.skillAnimationId2, act[9], cc.p(target:getPosition()))
				end
			end, act[8])
		end
	elseif act[2] == REPORT_NAME.FINISHCASTINGSKILL then
		if act[5] then
			self:setDirection(act[5])
		end
		local skill = self:getSkill(act[3], act[4])
		if self.currSkill == skill then
			skill:finished()
			self:movementComplete(skill:getActionName())
		end
	elseif act[2] == REPORT_NAME.BREAKCASTINGSKILL then
		local skill = self:getSkill(act[3], act[4])
		if self.currSkill == skill then
			skill:breaked()
			self:movementComplete(skill:getActionName())
		end
	elseif act[2] == REPORT_NAME.SKIPSKILL then
		local skill = self:getSkill(act[3], act[4])
		if self.currSkill == skill then
			skill:finished()
			self:movementComplete(skill:getActionName())
		end
	elseif act[2] == REPORT_NAME.ADDBUFF then
		ClassReplayBuff.new(act[3], self)
	elseif act[2] == REPORT_NAME.REMOVEBUFF then
		self:removeBuffById(act[3])
	elseif act[2] == REPORT_NAME.ADDMP then
		if self.mpBar then
			self.mpBar:setPercent(act[3])
		end
		self.mp = act[3]*self.maxMp/100
	elseif act[2] == REPORT_NAME.DEAD then
		self:removeBuffs()
		self:stopAllActions()
		self:playAction("dead")
		self:setStatus(SOLDIER_STATUS.DEAD)
		self:setHpBarVis(false)
		if self.selectEnable > 0 then
			self.armature:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.FadeOut:create(3.0), cc.CallFunc:create(function ()
				self.root:setVisible(false)
			end)))
		else
			self.root:setVisible(false)
		end
		if self.soldierType == 1 then
			self:clearMp()
			if act[3] then
				local atkLegion
				if act[3] == 1 then
					atkLegion = self.battlefield.armyMap[act[4]]
				else
					atkLegion = self.battlefield.enemyMap[act[4]]
				end
				self.battlefield:addKillAnimation(self.guid, self.legionObj.pos, self.legionObj.headpic, atkLegion.headpic)
			else
				self.battlefield:addKillAnimation(self.guid, self.legionObj.pos, self.legionObj.headpic)
			end
			if self.deadEffect and self.deadEffect ~= "0" then
				BattleHelper:playDeadSound(self.deadEffect)
			end
		end
	end
end

return ReplayBaseSoldier