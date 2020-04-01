local BattleHelper = require("script/app/ui/battle/battlehelper")

local BulletMgr = {
	bulletPools = nil,
	bfNode = nil
}

local BULLET_RENDER_ZORDER = 20000
local BULLET_PLIST_RES = "animation/battle_bullet/battle_bullet"

local function rotateBullet(bullet, startPos, endPos)    
    local pos = cc.pSub(endPos, startPos)
    local rotateRadians = cc.pToAngleSelf(pos)
    local rotateDegrees = math.deg( -1 * rotateRadians)
    bullet:setRotation(rotateDegrees)
end

-- 初始化
function BulletMgr:init(bfNode)
	self.bulletPools = BattleHelper:createObjPools()
	self.bfNode = bfNode
	self.preloadList = {}
end

function BulletMgr:clear()
	self.bulletPools = nil
	self.bfNode = nil
	self.preloadList = nil
end

function BulletMgr:addPreloadBullet(bulletInfo, skillInfo)
	if skillInfo.bulletNum > 0 then
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
		preloadNum = preloadNum*skillInfo.bulletNum
		self.preloadList[bulletInfo.id] = self.preloadList[bulletInfo.id] or 0
		self.preloadList[bulletInfo.id] = self.preloadList[bulletInfo.id] + preloadNum
	end
end

function BulletMgr:preloadBullet()
	for id, num in pairs(self.preloadList) do
		for i = 1, num do
			local bulletObj = self:createBullet(id)
			bulletObj.bulletNode:setVisible(false)
			self.bulletPools:push(id, bulletObj)
		end
	end
	self.preloadList = nil
end

-- 创建出一个子弹对象
function BulletMgr:createBullet(sid)
	local bulletObj = {}
	local info = GameData:getConfData("bullet")[sid]
	local bulletNode = nil
	if info.bulletType == 3 then
	-- 连线
		bulletNode = BattleHelper:createAniByName(info.res, BULLET_PLIST_RES)
		local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
			if frameEventName == "1" then
				if bulletObj.toCallback then
					bulletObj:toCallback()
				end
			end
		end
		local function movementFun(armature, movementType, movementID)
			if movementType == 1 then
			-- 连线动画完成
				bulletObj.toCallback = nil
				self:putBack(bulletObj)
			end
		end
		bulletNode:getAnimation():setFrameEventCallFunc(frameFun)
		bulletNode:getAnimation():setMovementEventCallFunc(movementFun)
		bulletNode:setAnchorPoint(cc.p(0, 0.5))
		bulletNode:setScaleY(info.scale/100)
	else
		if info.resType == 1 then
		-- 图片
			bulletNode = GlobalApi:createWithSpriteFrameName(info.res .. ".png")
		else
		-- 动画
			bulletNode = BattleHelper:createAniByName(info.res, BULLET_PLIST_RES)
		end
		bulletNode:setScale(info.scale/100)
	end

	self.bfNode:addChild(bulletNode)

	bulletObj.sid = sid
	bulletObj.info = info
	bulletObj.bulletNode = bulletNode
	bulletObj.scaleX = info.scale/100

	return bulletObj
end

-- 发射一个子弹
-- @skill: 技能obj
-- @sid: 子弹在数据表格中的sid
-- @startPos: 子弹初始位置
-- @dir: 子弹的方向
-- @targetOrPos: 子弹到达目标或者坐标
-- @effectCallback: 子弹到达目标后产生的回调
-- @positionFlag: 1是一个坐标 2是一个目标对象 3是一个目标对象数组
function BulletMgr:sendBullet(skill, sid, startPos, dir, targetOrPos, effectCallback, positionFlag)
	local bulletObj = self:getBullet(sid)
	local info = bulletObj.info
	-- 设置子弹起始坐标、目的坐标、方向等
	local x1 = startPos.x
	local y1 = startPos.y
	local x2, y2
	local offSet = {
		x = 0,
		y = 0
	}
	local bodyOffsetY = 0
	local target
	if positionFlag == 1 then
		x2 = targetOrPos.x
		y2 = targetOrPos.y
	elseif positionFlag == 2 then
		target = targetOrPos
		x2, y2 = target:getPosition()
		offSet = target:getRolePosOffset()
		bodyOffsetY = target.attPy_c
	else
		target = table.remove(targetOrPos)
		x2, y2 = target:getPosition()
		offSet = target:getRolePosOffset()
		bodyOffsetY = target.attPy_c
	end
	local x3, y3
	if dir == 1 then
		x1 = x1 + info.fireOffsetX
		x3 = x2 + info.hitOffsetX
	else
		x1 = x1 - info.fireOffsetX
		x3 = x2 - info.hitOffsetX
	end
	y1 = y1 + info.fireOffsetY
	y3 = y2 + info.hitOffsetY + bodyOffsetY
	if info.bulletType ~= 4 then -- 非光环型子弹
		x3 = x3 + offSet.x
		y3 = y3 + offSet.y
	end
	if info.targetOffset > 0 then
		local radian = cc.pGetAngle(cc.p(0, 0), cc.p(x3 - x1, y3 - y1))
		local rotatePosX = info.targetOffset*math.cos(radian)
		local rotatePosY = info.targetOffset*math.sin(radian)
		x3 = x3 + rotatePosX
		y3 = y3 + rotatePosY
	end
	local px = x3 - x1
	local py = y3 - y1
	bulletObj.bulletNode:setPosition(x1, y1)
	if info.bulletType == 1 then -- 直线型子弹
		local hitCallback
		local nextTargetCallback
		if positionFlag == 3 then
			local x4 = x3
			local y4 = y3
			hitCallback = function ()
				if effectCallback then
					effectCallback(target)
				end
			end
			nextTargetCallback = function ()
				if #targetOrPos > 0 then
					local notAllDead = true
					target = table.remove(targetOrPos)
					while target:isDead() do
						if #targetOrPos == 0 then
							notAllDead = false
							break
						end
						target = table.remove(targetOrPos)
					end
					if notAllDead then
						local x5, y5 = target:getPosition()
						BattleHelper:setBulletZorder(bulletObj.bulletNode, y5)
						local offSet2 = target:getRolePosOffset()
						local bodyOffsetY2 = target.attPy_c
						local dir2 = 1
						if x5 > x4 then
							x5 = x5 + info.hitOffsetX + offSet2.x
						else
							dir2 = -1
							x5 = x5 - info.hitOffsetX + offSet2.x
						end
						y5 = y5 + info.hitOffsetY + offSet2.y + bodyOffsetY2
						local px2 = x5 - x4
						local py2 = y5 - y4
						if info.autoRotation > 0 then
							bulletObj.bulletNode:setScaleX(dir2*bulletObj.scaleX)
							bulletObj.bulletNode:setRotation(-dir2*math.deg(math.atan2(py2, px2*dir2)))
						end
						local t = math.sqrt(math.pow(px2, 2)+math.pow(py2, 2))/tonumber(info.speed)
						local act
						if info.delayTime > 0 then
							act = cc.Sequence:create(cc.MoveTo:create(t, cc.p(x5, y5)), cc.CallFunc:create(hitCallback), cc.DelayTime:create(info.delayTime/1000), cc.CallFunc:create(nextTargetCallback))
						else
							act = cc.Sequence:create(cc.MoveTo:create(t, cc.p(x5, y5)), cc.CallFunc:create(function ()
								hitCallback()
								nextTargetCallback()
							end))
						end
						bulletObj.bulletNode:runAction(act)
						x4 = x5
						y4 = y5
					else
						self:putBack(bulletObj)
					end
				else
					self:putBack(bulletObj)
				end
			end
		else
			hitCallback = function ()
				if effectCallback then
					effectCallback(target)
				end
			end
			nextTargetCallback = function ()
				self:putBack(bulletObj)
			end
		end
		if info.autoRotation > 0 then
			bulletObj.bulletNode:setScaleX(dir*bulletObj.scaleX)
			bulletObj.bulletNode:setRotation(-dir*math.deg(math.atan2(py, px*dir)))
		end
		local t = math.sqrt(math.pow(px, 2)+math.pow(py, 2))/tonumber(info.speed)
		local act
		if info.delayTime > 0 then
			act = cc.Sequence:create(cc.MoveTo:create(t, cc.p(x3, y3)), cc.CallFunc:create(hitCallback), cc.DelayTime:create(info.delayTime/1000), cc.CallFunc:create(nextTargetCallback))
		else
			act = cc.Sequence:create(cc.MoveTo:create(t, cc.p(x3, y3)), cc.CallFunc:create(function ()
				hitCallback()
				nextTargetCallback()
			end))
		end
		bulletObj.bulletNode:runAction(act)
		BattleHelper:setBulletZorder(bulletObj.bulletNode, y2)
	elseif info.bulletType == 2 then -- 抛物线型子弹
		local bezier1
		local midX = (x1 + x3)/2
		if y3 > y1 then
			bezier1 = {
	   		    cc.p(midX, y3+150),
	        	cc.p(0, 0),
	   	    	cc.p(x3, y3)
	        }
		else
			bezier1 = {
	   		    cc.p(midX, y1+150),
	        	cc.p(0, 0),
	   	    	cc.p(x3, y3)
	        }
		end
		local l = cc.pGetDistance(cc.p(x1, y1), bezier1[1])
		l = l + cc.pGetDistance(cc.p(x3, y3), bezier1[1])
		local t = l/info.speed
		local bezierAction1 = cc.ArrowPathBezier:create(t, bezier1, true)
		local act
		if info.delayTime > 0 then
			act = cc.Sequence:create(bezierAction1, cc.CallFunc:create(function ()
				if effectCallback then
					effectCallback(target)
				end
			end), cc.DelayTime:create(info.delayTime/1000), cc.CallFunc:create(function ()
				self:putBack(bulletObj)
			end))
		else
			act = cc.Sequence:create(bezierAction1, cc.CallFunc:create(function ()
				if effectCallback then
					effectCallback(target)
				end
				self:putBack(bulletObj)
			end))
		end
		bulletObj.bulletNode:runAction(act)
		rotateBullet(bulletObj.bulletNode, cc.p(x1, y1), bezier1[1])
		BattleHelper:setBulletZorder(bulletObj.bulletNode, y3)
	elseif info.bulletType == 3 then
	-- 连线型子弹
		if positionFlag == 3 then
			local x4 = x3
			local y4 = y3
			local callback
			callback = function()
				if effectCallback then
					effectCallback(target)
				end
				if #targetOrPos > 0 then
					local notAllDead = true
					target = table.remove(targetOrPos)
					while target:isDead() do
						if #targetOrPos == 0 then
							notAllDead = false
							break
						end
						target = table.remove(targetOrPos)
					end
					if notAllDead then
						local bulletObj2 = self:getBullet(sid)
						local info = bulletObj2.info
						-- 目标坐标
						local x5, y5 = target:getPosition()
						BattleHelper:setBulletZorder(bulletObj2.bulletNode, y5)
						local offSet2 = target:getRolePosOffset()
						local bodyOffsetY2 = target.attPy_c
						if x5 > x4 then
							x5 = x5 + info.hitOffsetX + offSet2.x
						else
							x5 = x5 - info.hitOffsetX + offSet2.x
						end
						y5 = y5 + info.hitOffsetY + offSet2.y + bodyOffsetY2
						local px2 = x5 - x4
						local py2 = y5 - y4
						if info.autoRotation > 0 then
							bulletObj2.bulletNode:setRotation(-math.deg(math.atan2(py2, px2)))
						end
						bulletObj2.bulletNode:setPosition(x4, y4)
						bulletObj2.bulletNode:setScaleX(math.sqrt(math.pow(px2, 2) + math.pow(py2, 2))/info.speed)
						bulletObj2.toCallback = callback
						x4 = x5
						y4 = y5
					end
				end
			end
			bulletObj.toCallback = callback
		else
			bulletObj.toCallback = function()
				if effectCallback then
					effectCallback(target)
				end
			end
		end
		bulletObj.bulletNode:setScaleX(math.sqrt(math.pow(px, 2) + math.pow(py, 2))/info.speed)
		bulletObj.bulletNode:setRotation(-math.deg(math.atan2(py, px)))
		BattleHelper:setBulletZorder(bulletObj.bulletNode, y2)
	elseif info.bulletType == 4 then -- 光环型子弹
		local effectAct
		if effectCallback then
			bulletObj.soldierList = {}
			bulletObj.influenceList = {}
			local rangeTargetType = skill.baseInfo.rangeTargetType
			local battlefield = skill.owner.battlefield
			local armyArr
			if (skill.guid == 1 and rangeTargetType > 100) or (skill.guid == 2 and rangeTargetType < 100) then
				armyArr = battlefield.armyArr[1]
			else
				armyArr = battlefield.armyArr[2]
			end
			for k, v in ipairs(armyArr) do
				if not v:isDead() then
					if not v.heroObj:isDead() then
						table.insert(bulletObj.soldierList, v.heroObj)
					end
					for k2, v2 in ipairs(v.soldierObjs) do
						if not v2:isDead() then
							table.insert(bulletObj.soldierList, v2)
						end
					end
					for k3, v3 in ipairs(v.summonObjs) do
						if not v3:isDead() then
							table.insert(bulletObj.soldierList, v3)
						end
					end
				end
			end
			local radian = -cc.pGetAngle(cc.p(0, 0), cc.p(px, py))
			local effectActions = {}
			local function isInRange(obj, posx, posy)
				local posx1, posy1 = obj:getPosition()
				local pos = cc.pRotateByAngle(cc.p(posx1, posy1), cc.p(posx, posy), radian)
				local rx = pos.x - posx
				local ry
				if dir == 1 then
					ry = pos.y - posy
				else
					ry = posy - pos.y
				end
				
				if (info.rangeX1 <= rx and rx <= info.rangeX2) and (info.rangeY1 <= ry and ry <= info.rangeY2) then
					return true
				else
					return false
				end
			end
			local function effectFun()
				local posx, posy = bulletObj.bulletNode:getPosition()
				local targets = {}
				local targetNum = 0
				for k, v in ipairs(bulletObj.soldierList) do
					if bulletObj.influenceList[v] == nil and isInRange(v, posx, posy) then
						bulletObj.influenceList[v] = true
						table.insert(targets, v)
						targetNum = targetNum + 1
					end
				end
				if targetNum > 0 then
					effectCallback(targets)
				end
			end
			-- 第一个效果
			table.insert(effectActions, cc.CallFunc:create(effectFun))
			-- 剩下的效果
			table.insert(effectActions, cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(effectFun)), 999999))
			effectAct = cc.Sequence:create(effectActions)
		end
		local callback = function ()
			bulletObj.bulletNode:stopAllActions()
			self:putBack(bulletObj)
		end
		if info.autoRotation > 0 then
			bulletObj.bulletNode:setScaleX(dir*bulletObj.scaleX)
			bulletObj.bulletNode:setRotation(-dir*math.deg(math.atan2(py, px*dir)))
		end
		local t = math.sqrt(math.pow(px, 2)+math.pow(py, 2))/tonumber(info.speed)
		local act = cc.Sequence:create(cc.MoveTo:create(t, cc.p(x3, y3)), cc.CallFunc:create(callback))
		if effectAct then
			bulletObj.bulletNode:runAction(cc.Spawn:create(effectAct, act))
		else
			bulletObj.bulletNode:runAction(act)
		end
		BattleHelper:setBulletZorder(bulletObj.bulletNode, y2)
	end
end

function BulletMgr:putBack(bulletObj)
	if bulletObj.info.resType ~= 1 then
		xx.Utils:Get():pauseArmatureAnimation(bulletObj.bulletNode)
	end
	bulletObj.bulletNode:setVisible(false)
	self.bulletPools:push(bulletObj.sid, bulletObj)
end

function BulletMgr:getBullet(sid)
	local bulletObj = self.bulletPools:pop(sid)
	if bulletObj == nil then
		bulletObj = self:createBullet(sid)
	else
		bulletObj.bulletNode:setVisible(true)
	end
	if bulletObj.info.resType ~= 1 then
		bulletObj.bulletNode:getAnimation():playWithIndex(0, -1, -1)
	end
	return bulletObj
end

return BulletMgr