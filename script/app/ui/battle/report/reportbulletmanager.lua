local BulletMgr = {}

function BulletMgr:sendBullet(skill, sid, startPos, dir, targetOrPos, effectCallback, positionFlag)
	local battlefield = skill.owner.battlefield
	local info = GameData:getConfData("bullet")[sid]
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
	if info.bulletType == 1 then
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
						local t = math.sqrt(math.pow(px2, 2)+math.pow(py2, 2))/tonumber(info.speed)
						local act
						if info.delayTime > 0 then
							act = {
								index = 1,
								actions = {
									{
										name = "callback",
										waitTime = t,
										func = hitCallback
									},
									{
										name = "callback",
										waitTime = info.delayTime/1000,
										func = nextTargetCallback
									}
								}
							}
						else
							act = {
								index = 1,
								actions = {
									{
										name = "callback",
										waitTime = t,
										func = function ()
											hitCallback()
											nextTargetCallback()
										end
									}
								}
							}
						end
						battlefield:runAction(act)
						x4 = x5
						y4 = y5
					end
				end
			end
		else
			hitCallback = function ()
				if effectCallback then
					effectCallback(target)
				end
			end
			nextTargetCallback = function ()
			end
		end
		local t = math.sqrt(math.pow(px, 2)+math.pow(py, 2))/tonumber(info.speed)
		local act
		if info.delayTime > 0 then
			act = {
				index = 1,
				actions = {
					{
						name = "callback",
						waitTime = t,
						func = hitCallback
					},
					{
						name = "callback",
						waitTime = info.delayTime/1000,
						func = nextTargetCallback
					}
				}
			}
		else
			act = {
				index = 1,
				actions = {
					{
						name = "callback",
						waitTime = t,
						func = function ()
							hitCallback()
							nextTargetCallback()
						end
					}
				}
			}
		end
		battlefield:runAction(act)
	elseif info.bulletType == 2 then
		local bezierPos
		local midX = (x1 + x3)/2
		if y3 > y1 then
			bezierPos = cc.p(midX, y3 + 150)
		else
			bezierPos = cc.p(midX, y1 + 150)
		end
		local l = cc.pGetDistance(cc.p(x1, y1), bezierPos)
		l = l + cc.pGetDistance(cc.p(x3, y3), bezierPos)
		local t = l/info.speed
		local act = {
			index = 1,
			actions = {
				{
					name = "callback",
					waitTime = t,
					func = function ()
						if effectCallback then
							effectCallback(target)
						end
					end
				}
			}
		}
		battlefield:runAction(act)
	elseif info.bulletType == 3 then
	-- 连线型子弹
		if positionFlag == 3 then
			local x4 = x3
			local y4 = y3
			local callback
			local bulletActionInfo = battlefield:getJsonActionInfo(info.res)
			local transmitbulletWaitTime = bulletActionInfo.keyframe/60
			local function sendTransmitBullet()
				local act = {
					index = 1,
					actions = {
						{
							name = "callback",
							waitTime = transmitbulletWaitTime,
							func = callback
						}
					}
				}
				battlefield:runAction(act)
			end
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
						-- 目标坐标
						local x5, y5 = target:getPosition()
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
						sendTransmitBullet()
						x4 = x5
						y4 = y5
					end
				end
			end
			sendTransmitBullet()
		else
			local bulletActionInfo = battlefield:getJsonActionInfo(info.res)
			local act = {
				index = 1,
				actions = {
					{
						name = "callback",
						waitTime = bulletActionInfo.keyframe/60,
						func = function ()
							if effectCallback then
								effectCallback(target)
							end
						end
					}
				}
			}
			battlefield:runAction(act)
		end
	elseif info.bulletType == 4 then -- 光环型子弹
		local t = math.sqrt(math.pow(px, 2)+math.pow(py, 2))/tonumber(info.speed)
		local bulletObj = {
			bulletType = info.bulletType,
			x2 = x3,
			y2 = y3,
			x = x1,
			y = y1,
			t = t
		}
		if effectCallback then
			local soldierList = {}
			local influenceList = {}
			local rangeTargetType = skill.baseInfo.rangeTargetType
			local armyArr
			if (skill.guid == 1 and rangeTargetType > 100) or (skill.guid == 2 and rangeTargetType < 100) then
				armyArr = battlefield.armyArr[1]
			else
				armyArr = battlefield.armyArr[2]
			end
			for k, v in ipairs(armyArr) do
				if not v:isDead() then
					if not v.heroObj:isDead() then
						table.insert(soldierList, v.heroObj)
					end
					for k2, v2 in pairs(v.soldierObjs) do
						if not v2:isDead() then
							table.insert(soldierList, v2)
						end
					end
					for k3, v3 in pairs(v.summonObjs) do
						if not v3:isDead() then
							table.insert(soldierList, v3)
						end
					end
				end
			end
			local radian = -cc.pGetAngle(cc.p(0, 0), cc.p(px, py))
			local function isInRange(obj, posx, posy)
				local posx1, posy1 = obj:getPosition()
				local pos = cc.pRotateByAngle(cc.p(posx1, posy1), cc.p(posx, posy), radian)
				local rx
				local ry = pos.y - posy
				if dir == 1 then
					rx = pos.x - posx
				else
					rx = posx - pos.x
				end
				if (info.rangeX1 <= rx and rx <= info.rangeX2) and (info.rangeY1 <= ry and ry <= info.rangeY2) then
					return true
				else
					return false
				end
			end
			local function effectFun()
				local posx = bulletObj.x
				local posy = bulletObj.y
				local targets = {}
				local targetNum = 0
				for k, v in pairs(soldierList) do
					if influenceList[v] == nil and isInRange(v, posx, posy) then
						influenceList[v] = true
						table.insert(targets, v)
						targetNum = targetNum + 1
					end
				end
				if targetNum > 0 then
					effectCallback(targets)
				end
			end
			local act = {
				index = 1,
				actions = {
					{
						name = "moveto",
						startPosX = x1,
						startPosY = y1,
						diffPosX = px,
						diffPosY = py,
						startTime = battlefield.time,
						time = t,
						func = effectFun,
						interval1 = 0.1,
						interval2 = battlefield.time
					}
				}
			}
			act.owner = bulletObj
			battlefield:runAction(act)
		end
	end
end

return BulletMgr