local ClassReportLegion = require("script/app/ui/battle/report/reportlegion")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassPlayerSkillObj = require("script/app/ui/battle/playerskill/playerskillobj")
local PlayerSkillAI = require("script/app/ui/battle/playerskill/playerskillai")
local ReportPlayerSkillAI = require("script/app/ui/battle/report/reportplayerskillai")

local ReportField = class("ReportField")

local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS
local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME
local INITIAL_POINT = 30
local DT = 0.1 -- 算1秒10帧, 1帧100毫秒
local OVERTIME = 120

function ReportField:ctor(battleType, armyData, enemyData, customObj)
	self.armyData = armyData
	self.enemyData = enemyData
	self.customObj = customObj
	self.legionCount = {
		[1] = 0,
		[2] = 0
	}
	self.damageCount = { -- 伤害统计
		[1] = {0, 0},
		[2] = {0, 0}
	}
	self.hurtCount = {0, 0} -- 受伤统计
	self.dieNum = { -- 作战单位的死亡数量
		[1] = 0,
		[2] = 0
	}
	self.dieLegionNum = { -- 军团的死亡数量
		[1] = 0,
		[2] = 0
	}
	self.pointAddTimes = {0, 0}
	self.pointPerSecond = {2, 2} -- 能量点默认一秒加2点
	self.soldierActionInfo = {}
	self.dragonActionInfo = {}
	self.jsonActionInfo = {}
	self.actionArr = {}
	self.handleWhenSoldierDieMap = {}
	self.handleWhenSoldierDieNum = 0
	self.handleWhenLegionDieMap = {}
	self.handleWhenLegionDieNum = 0
	self.time = 0
	self.shakeTime = 0
	self.starNum = 3
	self.armyArr = {{},{}}
	self.armyMap = {}
	self.enemyMap = {}
	self.totalReport = {}
	self.totalReport.soldierReport = {}
	self.totalReport.otherReport = {}
	self.isReport = true
	self.playerSkillPoints = {INITIAL_POINT, INITIAL_POINT} -- 默认30个豆
	self.playerSkillArr = {{}, {}}
	self.playerSkillStatusArr = {{},{}}
	self:initPlayerSkill()
	self.battleStatus = BATTLE_STATUS.INIT
	self.battleType = battleType
end

function ReportField:initPlayerSkill()
	local playerSkillConf = GameData:getConfData("playerskill")
	for k, v in pairs(self.armyData.playerskills) do
		if v.id > 0 then
			local obj = ClassPlayerSkillObj.new(self, 1, k, playerSkillConf[v.id], self.armyData.level, v.level)
			table.insert(self.playerSkillArr[1], obj)
		end
	end
	table.sort(self.playerSkillArr[1], function (a, b)
		return a.index > b.index
	end)
	for k, v in ipairs(self.playerSkillArr[1]) do
		local obj = {
				time = 0,
				disable = false,
				basePoint = v.info.skillPoints,
				needPoint = v.info.skillPoints,
				useTimes = 0
			}
		self.playerSkillStatusArr[1][k] = obj
	end
	for k, v in pairs(self.enemyData.playerskills) do
		if v.id > 0 then
			local obj = ClassPlayerSkillObj.new(self, 2, k, playerSkillConf[v.id], self.enemyData.level, v.level)
			table.insert(self.playerSkillArr[2], obj)
		end
	end
	table.sort(self.playerSkillArr[2], function (a, b)
		return a.index > b.index
	end)
	for k, v in ipairs(self.playerSkillArr[2]) do
		local obj = {
				time = 0,
				disable = false,
				basePoint = v.info.skillPoints,
				needPoint = v.info.skillPoints,
				useTimes = 0
			}
		self.playerSkillStatusArr[2][k] = obj
	end
end

function ReportField:battleEnd(isWin, timeoutFlag)
	if self.battleStatus == BATTLE_STATUS.OVER then
		return
	end
	self.battleStatus = BATTLE_STATUS.OVER
	self.customObj.isWin = isWin
	self:calculateStar()
	local obj = {
		[1] = self.time,
		[2] = REPORT_NAME.BATTLEEND,
		[3] = isWin,
		[4] = timeoutFlag
	}
	table.insert(self.totalReport.otherReport, obj)
	self.totalReport.isWin = self.customObj.isWin
	self.totalReport.starNum = self.starNum
end

function ReportField:getDamageInfo()
	local damageArr = {}
	for k, v in ipairs(self.armyArr[1]) do
		local obj = {
			hid = v.heroInfo.heroId,
			headpic = v.headpic,
			guid = 1,
			quality = v.heroQuality,
			dmg = v:getDamageCount()[2],
			promote = v.heroInfo.promote,
			isMonster = v.legionInfo.isMonster
		}
		table.insert(damageArr, obj)
	end
	for k, v in ipairs(self.armyArr[2]) do
		local obj = {
			hid = v.heroInfo.heroId,
			headpic = v.headpic,
			guid = 2,
			quality = v.heroQuality,
			dmg = v:getDamageCount()[2],
			promote = v.heroInfo.promote,
			isMonster = v.legionInfo.isMonster
		}
		table.insert(damageArr, obj)
	end
	table.sort(damageArr, function (a, b)
		return a.dmg > b.dmg
	end)
	local damageInfo = {
		atkName = self.armyData.name,
		defName = self.enemyData.name,
		damageArr = damageArr
	}
	return damageInfo
end

function ReportField:calculateStar()
	self.starNum = self.starNum - self.dieLegionNum[1]
	if self.starNum < 1 then
		self.starNum = 1
	end
end

function ReportField:isBattleEnd()
	return self.battleStatus == BATTLE_STATUS.OVER
end

function ReportField:addChangeTargetLegion(guid, legion)
	self.changeTargetLegions = self.changeTargetLegions or {}
	self.changeTargetLegions[guid] = self.changeTargetLegions[guid] or {}
	self.changeTargetLegions[guid][legion.pos] = legion
end

function ReportField:addChangeTargetSoldier(guid, legionPos, soldier)
	self.changeTargetSoldiers = self.changeTargetSoldiers or {}
	self.changeTargetSoldiers[guid] = self.changeTargetSoldiers[guid] or {}
	self.changeTargetSoldiers[guid][legionPos] = self.changeTargetSoldiers[guid][legionPos] or {}
	table.insert(self.changeTargetSoldiers[guid][legionPos], soldier)
end

function ReportField:searchTarget()
	if self.changeTargetSoldiers then
		for guid, legions in pairs(self.changeTargetSoldiers) do
			for pos, legion in pairs(legions) do
				for i, soldier in ipairs(legion) do
					if self.changeTargetLegions == nil or self.changeTargetLegions[guid] == nil or self.changeTargetLegions[guid][pos] == nil then
						soldier:searchTarget(false, true)
					end
				end
			end
		end
		self.changeTargetSoldiers = nil
	end
	if self.changeTargetLegions then
		for guid, legions in pairs(self.changeTargetLegions) do
			for pos, legion in pairs(legions) do
				legion:searchTarget()
			end
		end
		self.changeTargetLegions = nil
	end
end

function ReportField:addDamageCount(num, guid, soldierType)
	if num > 0 then
		self.damageCount[guid][1] = self.damageCount[guid][1] + num
	else
		self.damageCount[guid][2] = self.damageCount[guid][2] - num
	end
end

function ReportField:addHurtCount(num, guid, soldierType)
	self.hurtCount[guid] = self.hurtCount[guid] - num
end

function ReportField:addPlayerHealth(guid, value, soldierType)
end

-- 死亡统计
function ReportField:addDieNum(guid, position, soldierType)
	self.dieNum[guid] = self.dieNum[guid] + 1
	if self.handleWhenSoldierDieNum > 0 then
		for k, func in pairs(self.handleWhenSoldierDieMap) do
			func(guid, soldierType)
		end
	end
end

function ReportField:addHandleWhenSoldierDie(owner, func)
	if self.handleWhenSoldierDieMap[owner] == nil then
		self.handleWhenSoldierDieMap[owner] = func
		self.handleWhenSoldierDieNum = self.handleWhenSoldierDieNum + 1
	end
end

function ReportField:removeHandleWhenSoldierDie(owner)
	if self.handleWhenSoldierDieMap[owner] then
		self.handleWhenSoldierDieMap[owner] = nil
		self.handleWhenSoldierDieNum = self.handleWhenSoldierDieNum - 1
	end
end

function ReportField:addHandleWhenLegionDie(owner, func)
	if self.handleWhenLegionDieMap[owner] == nil then
		self.handleWhenLegionDieMap[owner] = func
		self.handleWhenLegionDieNum = self.handleWhenLegionDieNum + 1
	end
end

function ReportField:addKillAnimation(dieGuid, legionPos, dieurl, killurl)
end

function ReportField:removeHandleWhenLegionDie(owner)
	if self.handleWhenLegionDieMap[owner] then
		self.handleWhenLegionDieMap[owner] = nil
		self.handleWhenLegionDieNum = self.handleWhenLegionDieNum - 1
	end
end

function ReportField:addLegionDieNum(pos, guid, position)
	BattleMgr:calculateLegionDie(guid)
	self.legionCount[guid] = self.legionCount[guid] - 1
	self.dieLegionNum[guid] = self.dieLegionNum[guid] + 1
	if self.handleWhenLegionDieNum > 0 then
		for k, func in pairs(self.handleWhenLegionDieMap) do
			func(guid)
		end
	end
end

function ReportField:runShakeAction(time, strengthx, strengthy)
	if self.time > self.shakeTime then
		self.shakeTime = self.time + time
		local obj = {
			[1] = self.time,
			[2] = REPORT_NAME.SHAKESCREEN,
			[3] = time,
			[4] = strengthx,
			[5] = strengthy
		}
		table.insert(self.totalReport.otherReport, obj)
	end
end

function ReportField:calculateReport(callback)
	collectgarbage("stop")
	self.callback = callback
	self:initLegion()
end

function ReportField:initLegion()
	local index = 1
	local maxNum1 = #self.armyData.legionArr
	local maxNum2 = #self.enemyData.legionArr
	self.customObj.node:scheduleUpdateWithPriorityLua(function (_dt)
		if index > maxNum1 and index > maxNum2 then
			self.customObj.node:unscheduleUpdate()
			self:onInitLegionOver()
		else
			local soldierReport = self.totalReport.soldierReport
			if self.battleType == BATTLE_TYPE.ARENA then
				math.randomseed(self.customObj.rand1 + index)
			end
			if index <= maxNum1 then
				local legionData = self.armyData.legionArr[index]
				local legion = ClassReportLegion.new(self.armyData.guid, legionData, true, self)
				self.armyMap[legionData.info.pos] = legion
				table.insert(self.armyArr[1], legion)
				self.legionCount[1] = self.legionCount[1] + 1

				table.insert(soldierReport, legion.heroObj.report.recordObj)
				for k2, soldierObj in ipairs(legion.soldierObjs) do
					table.insert(soldierReport, soldierObj.report.recordObj)
				end
				for k2, summonObj in ipairs(legion.summonObjs) do
					table.insert(soldierReport, summonObj.report.recordObj)
				end
				for k2, specialSummonObjs in ipairs(legion.specialSummonObjs) do
					table.insert(soldierReport, specialSummonObjs.report.recordObj)
				end
			end
			if index <= maxNum2 then
				local legionData2 = self.enemyData.legionArr[index]
				local enemyLegion = ClassReportLegion.new(self.enemyData.guid, legionData2, true, self)
				table.insert(self.armyArr[2], enemyLegion)
				self.enemyMap[legionData2.info.pos] = enemyLegion
				self.legionCount[2] = self.legionCount[2] + 1

				table.insert(soldierReport, enemyLegion.heroObj.report.recordObj)
				for k2, soldierObj in ipairs(enemyLegion.soldierObjs) do
					table.insert(soldierReport, soldierObj.report.recordObj)
				end
				for k2, summonObj in ipairs(enemyLegion.summonObjs) do
					table.insert(soldierReport, summonObj.report.recordObj)
				end
				for k2, specialSummonObjs in ipairs(enemyLegion.specialSummonObjs) do
					table.insert(soldierReport, specialSummonObjs.report.recordObj)
				end
			end
			index = index + 1
		end
	end, 0)
end

function ReportField:onInitLegionOver()
	local function sortfunction(a, b)
		return a.pos < b.pos
	end
	table.sort(self.armyArr[1], sortfunction)
	table.sort(self.armyArr[2], sortfunction)
	for k, v in ipairs(self.armyArr) do
		for k2, v2 in ipairs(v) do
			v2:prepare1()
		end
	end
	for k, v in ipairs(self.armyArr) do
		for k2, v2 in ipairs(v) do
			v2:prepare2()
		end
	end
	
	if self.battleType == BATTLE_TYPE.ARENA then
		BattleHelper:setRandomSeed(self.customObj.rand2)
	end

	self.battleStatus = BATTLE_STATUS.FIGHTING
	local updateTimes = 0
	collectgarbage("collect")
	collectgarbage("stop")
	self.customObj.node:scheduleUpdateWithPriorityLua(function (_dt)
		updateTimes = updateTimes + 1
		if updateTimes % 20 == 0 then
			collectgarbage("collect")
			collectgarbage("stop")
		else
			for i = 1, 20 do
				if self:isBattleEnd() then
					collectgarbage("restart")
					self.customObj.node:unscheduleUpdate()
					self.callback()
					break
				end
				self.time = self.time + DT
				if self.time >= OVERTIME then
					collectgarbage("restart")
					self:battleEnd(false, true)
					self.customObj.node:unscheduleUpdate()
					self.callback()
					break
				end
				self:_calculate()
			end
		end
	end, 0)
end

function ReportField:_calculate()
	self.executeBulletAction = true
	local totalNum = #self.actionArr
	if totalNum > 0 then
		for k = totalNum, 1, -1 do
			local action = self.actionArr[k]
			if action.remove then
				table.remove(self.actionArr, k)
			else
				local one = action.actions[action.index]
				if one.name == "moveto" then
					if self.time - one.startTime >= one.time then
						action.owner.x = one.startPosX + one.diffPosX
						action.owner.y = one.startPosY + one.diffPosY
						action.index = action.index + 1
						if action.index > #action.actions then
							table.remove(self.actionArr, k)
						end
					else
						action.owner.x = one.startPosX + one.diffPosX*(self.time - one.startTime)/one.time
						action.owner.y = one.startPosY + one.diffPosY*(self.time - one.startTime)/one.time
						if self.time - one.interval2 >= one.interval1 then
							one.interval2 = one.interval2 + one.interval1
							one.func()
						end
					end
				elseif one.name == "callback" then
					if one.start == nil then
						one.start = true
						one.startTime =  self.time
					end
					if self.time - one.startTime >= one.waitTime then
						one.start = nil
						action.index = action.index + 1
						if action.index > #action.actions then
							if action.reportIndex then
								action.index = action.reportIndex
							else								
								table.remove(self.actionArr, k)
							end
						end
						one.func()
					end
				end
			end
		end
	end
	self.executeBulletAction = false
	for k, v in ipairs(self.armyArr[1]) do
		v:checkBeforeUpdate()
	end
	for k2, v2 in ipairs(self.armyArr[2]) do
		v2:checkBeforeUpdate()
	end
	for k, v in ipairs(self.armyArr[1]) do
		v:update(DT)
	end
	for k2, v2 in ipairs(self.armyArr[2]) do
		v2:update(DT)
	end
	self:searchTarget()
	self:updatePlayerSkillPoint()
end

function ReportField:addPointPerSecond(guid, point)
	local obj = {
		[1] = self.time,
		[2] = REPORT_NAME.ADDPOINTPERSECOND,
		[3] = guid,
		[4] = point
	}
	table.insert(self.totalReport.otherReport, obj)
	self.pointPerSecond[guid] = self.pointPerSecond[guid] + point 
end

function ReportField:addPoint(guid, point)
	local obj = {
		[1] = self.time,
		[2] = REPORT_NAME.ADDPOINT,
		[3] = guid,
		[4] = point
	}
	table.insert(self.totalReport.otherReport, obj)
	self.playerSkillPoints[guid] = self.playerSkillPoints[guid] + point
	self:updatePlayerSkill(guid)
end

function ReportField:updatePlayerSkillPoint()
	local totalAddTimes1 = math.floor(self.time*self.pointPerSecond[1]) -- 半秒加一次
	local point1 = totalAddTimes1 - self.pointAddTimes[1]
	if point1 > 0 then
		self.playerSkillPoints[1] = self.playerSkillPoints[1] + point1
		self.pointAddTimes[1] = totalAddTimes1
		self:updatePlayerSkill(1)
	end
	local totalAddTimes2 = math.floor(self.time*self.pointPerSecond[2])
	local point2 = totalAddTimes2 - self.pointAddTimes[2]
	if point2 > 0 then
		self.playerSkillPoints[2] = self.playerSkillPoints[2] + point2
		self.pointAddTimes[2] = totalAddTimes2
		self:updatePlayerSkill(2)
	end
end

function ReportField:updatePlayerSkill(guid)
	local autoUseIndex = 0
	local minNeedPoint
	for k, v in ipairs(self.playerSkillStatusArr[guid]) do
		if not v.disable and v.time == 0 then
			if minNeedPoint == nil or minNeedPoint >= v.needPoint then
				minNeedPoint = v.needPoint
				autoUseIndex = k
			end
		else
			if v.time > 0 then
				local lastTime = v.time - self.time
				if lastTime <= 0 then
					v.time = 0
				end
			end
			if v.disable then
				if self.playerSkillPoints[guid] >= v.needPoint then
					v.disable = false
				end
			end
		end
	end
	if self.time > 5 and autoUseIndex > 0 and self.battleStatus == BATTLE_STATUS.FIGHTING then
		self:usePlayerSkill(guid, autoUseIndex)
	end
end

function ReportField:usePlayerSkill(guid, index)
	self.playerSkillPoints[guid] = self.playerSkillPoints[guid] - self.playerSkillStatusArr[guid][index].needPoint
	self.playerSkillStatusArr[guid][index].time = self.time + 5
	self.playerSkillStatusArr[guid][index].useTimes = self.playerSkillStatusArr[guid][index].useTimes + 1
	self.playerSkillStatusArr[guid][index].needPoint = self.playerSkillStatusArr[guid][index].basePoint + self.playerSkillStatusArr[guid][index].basePoint*(self.playerSkillStatusArr[guid][index].useTimes)/2
	for k, v in ipairs(self.playerSkillStatusArr[guid]) do
		if self.playerSkillPoints[guid] < v.needPoint then
			v.disable = true
		end
	end
	local info = self.playerSkillArr[guid][index].info
	-- if info.id == 1 then
	-- 	return
	-- end
	local skill = self.playerSkillArr[guid][index].baseSkill
	local size = cc.size(1800, 820)
	local effectInfo = PlayerSkillAI:useSkillWithoutPos(info.searchId, guid, self.armyArr, size)
	if effectInfo then
		ReportPlayerSkillAI:playSkillAnimation(guid, effectInfo, skill, info, self, size, index)
	end
end

function ReportField:getSoldierActionInfo(url)
	if self.soldierActionInfo[url] == nil then
		local jsonRes = "animation/" .. url .. "/" .. url .. ".json"
		local content = cc.FileUtils:getInstance():getStringFromFile(jsonRes)
		local jsonData = json.decode(content)
		local attackData = {}
		local acts = jsonData.animation_data[1].mov_data
		for i = 1, #acts do
			if string.sub(acts[i].name, 1, 6) == "attack" or string.sub(acts[i].name, 1, 5) == "skill" then
				attackData[acts[i].name] = {
					totalframe = acts[i].dr
				}
				local movBoneDatas = acts[i].mov_bone_data
				for j = 1, #movBoneDatas do
					local frameDatas = movBoneDatas[j].frame_data
					for k = 1, #frameDatas do
						if frameDatas[k].evt then
							attackData[acts[i].name]["keyframe"] = frameDatas[k].fi
							break
						end
					end
					if attackData[acts[i].name]["keyframe"] then
						break
					end
				end
			end
		end
		self.soldierActionInfo[url] = attackData
	end
	return self.soldierActionInfo[url]
end

function ReportField:getDragonActionInfo(name, url)
	if self.dragonActionInfo[name] == nil then
		local folder = "animation"
		if string.sub(name, 1, 9) == "nan_fabao" then
			folder = "animation_littlelossy"
		end
		local jsonRes = url or folder.."/" .. name .. "/" .. name .. ".json"
		local content = cc.FileUtils:getInstance():getStringFromFile(jsonRes)
		local jsonData = json.decode(content)
		local attackData = {}
		local acts = jsonData.animation_data[1].mov_data
		for i = 1, #acts do
			attackData[acts[i].name] = {
				totalframe = acts[i].dr
			}
			if acts[i].name == "attack" then
				local movBoneDatas = acts[i].mov_bone_data
				for j = 1, #movBoneDatas do
					local frameDatas = movBoneDatas[j].frame_data
					for k = 1, #frameDatas do
						if frameDatas[k].evt then
							attackData[acts[i].name]["keyframe"] = frameDatas[k].fi
							break
						end
					end
					if attackData[acts[i].name]["keyframe"] then
						break
					end
				end
			end
		end
		self.dragonActionInfo[name] = attackData
	end
	return self.dragonActionInfo[name]
end

function ReportField:getJsonActionInfo(url)
	if self.jsonActionInfo[url] == nil then
		local jsonRes = "animation/" .. url .. "/" .. url .. ".json"
		local content = cc.FileUtils:getInstance():getStringFromFile(jsonRes)
		local jsonData = json.decode(content)
		local attackData = {}
		local acts = jsonData.animation_data[1].mov_data[1]
		attackData.totalframe = acts.dr
		local movBoneDatas = acts.mov_bone_data
		for j = 1, #movBoneDatas do
			local frameDatas = movBoneDatas[j].frame_data
			for k = 1, #frameDatas do
				if frameDatas[k].evt then
					attackData.keyframe = frameDatas[k].fi
					break
				end
			end
			if attackData.keyframe then
				break
			end
		end
		self.jsonActionInfo[url] = attackData
	end
	return self.jsonActionInfo[url]
end

function ReportField:runAction(action)
	table.insert(self.actionArr, action)
end

function ReportField:runSkillAction(action)
	table.insert(self.actionArr, action)
end

function ReportField:stopActionByTag(tag)
	if self.executeBulletAction then
		for k, action in ipairs(self.actionArr) do
			if action.tag and action.tag == tag then
				action.remove = true
			end
		end
	else
		local totalNum = #self.actionArr
		if totalNum > 0 then
			for k = totalNum, 1, -1 do
				local action = self.actionArr[k]
				if action.tag and action.tag == tag then
					table.remove(self.actionArr, k)
				end
			end
		end
	end
end

function ReportField:recordAddSummon(guid, pos, sid, position)
	local obj = {
		[1] = self.time,
		[2] = REPORT_NAME.ADDSUMMON,
		[3] = guid,
		[4] = pos,
		[5] = sid,
		[6] = position.x,
		[7] = position.y
	}
	table.insert(self.totalReport.otherReport, obj)
end

function ReportField:recordUsePlayerSkill(guid, index, position)
	local obj = {
		[1] = self.time,
		[2] = REPORT_NAME.USEPLAYERSKILL,
		[3] = self.playerSkillPoints[guid],
		[4] = guid,
		[5] = index,
		[6] = position.x,
		[7] = position.y
	}
	table.insert(self.totalReport.otherReport, obj)
end

function ReportField:addReport(obj)
	table.insert(self.totalReport.otherReport, obj)
end

function ReportField:calculateReportForServer()
	local maxNum1 = #self.armyData.legionArr
	local maxNum2 = #self.enemyData.legionArr
	local index = 1
	while true do
		if index > maxNum1 and index > maxNum2 then
			break
		else
			local soldierReport = self.totalReport.soldierReport
			if self.battleType == BATTLE_TYPE.ARENA then
				math.randomseed(self.customObj.rand1 + index)
			end
			if index <= maxNum1 then
				local legionData = self.armyData.legionArr[index]
				local legion = ClassReportLegion.new(self.armyData.guid, legionData, true, self)
				self.armyMap[legionData.info.pos] = legion
				table.insert(self.armyArr[1], legion)
				self.legionCount[1] = self.legionCount[1] + 1

				table.insert(soldierReport, legion.heroObj.report.recordObj)
				for k2, soldierObj in ipairs(legion.soldierObjs) do
					table.insert(soldierReport, soldierObj.report.recordObj)
				end
				for k2, summonObj in ipairs(legion.summonObjs) do
					table.insert(soldierReport, summonObj.report.recordObj)
				end
				for k2, specialSummonObjs in ipairs(legion.specialSummonObjs) do
					table.insert(soldierReport, specialSummonObjs.report.recordObj)
				end
			end
			if index <= maxNum2 then
				local legionData2 = self.enemyData.legionArr[index]
				local enemyLegion = ClassReportLegion.new(self.enemyData.guid, legionData2, true, self)
				table.insert(self.armyArr[2], enemyLegion)
				self.enemyMap[legionData2.info.pos] = enemyLegion
				self.legionCount[2] = self.legionCount[2] + 1

				table.insert(soldierReport, enemyLegion.heroObj.report.recordObj)
				for k2, soldierObj in ipairs(enemyLegion.soldierObjs) do
					table.insert(soldierReport, soldierObj.report.recordObj)
				end
				for k2, summonObj in ipairs(enemyLegion.summonObjs) do
					table.insert(soldierReport, summonObj.report.recordObj)
				end
				for k2, specialSummonObjs in ipairs(enemyLegion.specialSummonObjs) do
					table.insert(soldierReport, specialSummonObjs.report.recordObj)
				end
			end
			index = index + 1
		end
	end

	local function sortfunction(a, b)
		return a.pos < b.pos
	end
	table.sort(self.armyArr[1], sortfunction)
	table.sort(self.armyArr[2], sortfunction)
	for k, v in ipairs(self.armyArr) do
		for k2, v2 in ipairs(v) do
			v2:prepare1()
		end
	end
	for k, v in ipairs(self.armyArr) do
		for k2, v2 in ipairs(v) do
			v2:prepare2()
		end
	end

	if self.battleType == BATTLE_TYPE.ARENA then
		BattleHelper:setRandomSeed(self.customObj.rand2)
	end
	collectgarbage("stop")
	self.battleStatus = BATTLE_STATUS.FIGHTING
	for i = 1, 900 do
		if self:isBattleEnd() then
			break
		end
		self.time = self.time + DT
		if self.time >= OVERTIME then
			self:battleEnd(false, true)
			break
		end
		self:_calculate()
	end
	collectgarbage("restart")
	return self.totalReport
end

function ReportField:generateVerifyMD5()
	local pos = self.customObj.rand_pos or 1
	local attrs = self.customObj.rand_attrs or {}
	local roleObj = RoleData:getRoleByPos(pos)
	local heroAtts = RoleData:getPosAttByPos(roleObj)
	local sigStr = ""	
	for k, v in ipairs(attrs) do
		sigStr = sigStr .. heroAtts[v] .. ":"
	end
	sigStr = sigStr .. "battle|"
	return xx.Utils:Get():generateBattleVerifyMD5(sigStr)
end

return ReportField