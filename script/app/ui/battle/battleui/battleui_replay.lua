local BaseBattleUI = require("script/app/ui/battle/battleui/battleui")
local ClassReplayLegion = require("script/app/ui/battle/replay/replaylegion")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassReportField = require("script/app/ui/battle/report/reportfield")
local ReplayPlayerSkillAI = require("script/app/ui/battle/replay/replayplayerskillai")
local BulletMgr = require("script/app/ui/battle/skill/bulletmanager")

local BattleReplayUI = class("BattleReplayUI", BaseBattleUI)

local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS
local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME
local SOLDIER_HP_RATIO = BattleHelper.CONST.HERO_DAMAGE_COEFFICIENT

local function getTime(t)
	local m = string.format("%02d", math.floor(t%3600/60))
	local s = string.format("%02d", math.floor(t%3600%60%60))
	return m..':'..s
end

function BattleReplayUI:initReportField()
	local customObj = {
		rand1 = self.customObj.rand1,
	 	rand2 = self.customObj.rand2,
		node = self.root
	}
	self.reportField = ClassReportField.new(self.battleType, self.armyData, self.enemyData, customObj)
end

function BattleReplayUI:createLegion(guid, data, isFirstWave)
	local skillGroupConf = GameData:getConfData("skillgroup")
	local skillConf = GameData:getConfData("skill")
	local summonConf = GameData:getConfData("summon")
	local soldierConf = GameData:getConfData("soldier")
	local bulletConf = GameData:getConfData("bullet")
	self.reportField:getSoldierActionInfo(data.heroInfo.url)
	if guid == 1 then
		self.reportField:getSoldierActionInfo(data.info.soldierUrl .. "_g")
	else
		self.reportField:getSoldierActionInfo(data.info.soldierUrl .. "_r")
	end
	local skillGroup = skillGroupConf[data.heroInfo.skillGroupId]
	local skillArr = {
		[1] = skillConf[skillGroup.baseSkill],
		[2] = skillConf[skillGroup.angerSkill + data.heroInfo.skillLevel - 1],
		[3] = skillConf[skillGroup.autoSkill1 + data.heroInfo.skillLevel - 1]
	}
	for k, v in ipairs(skillArr) do
		if v.summonId > 0 then
			local summonInfo = summonConf[v.summonId]
			local baseInfo = soldierConf[summonInfo.modelArmyTypeId]
			if baseInfo.urlType == 1 then
				if guid == 1 then
					self.reportField:getSoldierActionInfo(baseInfo.url .. "_g")
				else
					self.reportField:getSoldierActionInfo(baseInfo.url .. "_r")
				end
			else
				self.reportField:getSoldierActionInfo(baseInfo.url)
			end
			if summonInfo.appearEf ~= "0" then
				self.reportField:getJsonActionInfo(summonInfo.appearEf)
			end
		end
		if v.bulletId > 0 then
			local bulletInfo = bulletConf[v.bulletId]
			if bulletInfo.resType == 2 then
				self.reportField:getJsonActionInfo(bulletInfo.res)
			end
		end
	end
	return ClassReplayLegion.new(guid, data, isFirstWave, self)
end

function BattleReplayUI:initCompleted()
	local winsize = cc.Director:getInstance():getVisibleSize()
	local summonConf = GameData:getConfData("summon")
	local soldierConf = GameData:getConfData("soldier")
	local bulletConf = GameData:getConfData("bullet")
	for i = 1, 2 do
		for k, v in ipairs(self.playerSkillArr[i]) do
			if v.info.res ~= "0" then
				self.reportField:getDragonActionInfo(v.info.res)
			end
			if v.info.res2 ~= "0" then
				self.reportField:getDragonActionInfo(v.info.res2)
			end
			if v.info.res3 ~= "0" then
				self.reportField:getDragonActionInfo(v.info.res3)
			end
			if v.baseSkill.baseInfo.summonId > 0 then
				local summonInfo = summonConf[v.baseSkill.baseInfo.summonId]
				local baseInfo = soldierConf[summonInfo.modelArmyTypeId]
				if baseInfo.urlType == 1 then
					if v.guid == 1 then
						self.reportField:getSoldierActionInfo(baseInfo.url .. "_g")
					else
						self.reportField:getSoldierActionInfo(baseInfo.url .. "_r")
					end
				else
					self.reportField:getSoldierActionInfo(baseInfo.url)
				end
				if summonInfo.appearEf ~= "0" then
					self.reportField:getJsonActionInfo(summonInfo.appearEf)
				end
			end
			if v.baseSkill.baseInfo.bulletId > 0 then
				local bulletInfo = bulletConf[v.baseSkill.baseInfo.bulletId]
				if bulletInfo.resType == 2 then
					self.reportField:getJsonActionInfo(bulletInfo.res)
				end
			end
		end
	end
	--self.overTime = 90
	--self.timeLabel:setString("01:30")
	if self.battleType == BATTLE_TYPE.REPLAY then
		local label1 = self.fightforceNode:getChildByName("text_1")
		local label2 = self.fightforceNode:getChildByName("text_2")
		label1:setString(self.armyData.name)
		label2:setString(self.enemyData.name)
		for k, v in ipairs(self.pedestalArr) do
			v:setTouchEnabled(false)
		end
		self.skillListNode:setVisible(false)
		self.watchOnly = true		
	else
		self.watchOnly = false
	end
end

function BattleReplayUI:prepare()
	self.skipBtn:setVisible(true)
	if self.battleType ~= BATTLE_TYPE.REPLAY then
		self.pauseBtn:setVisible(false)
	end
end

function BattleReplayUI:getSkill(guid, skillId)
	local skill
	for k, v in ipairs(self.playerSkillArr[guid]) do
		if v.baseSkill.skillId == skillId then
			skill = v.baseSkill
			break
		end
	end
	return skill
end

function BattleReplayUI:playWithRecord(act)
	if act[2] == REPORT_NAME.ADDSUMMON then
		local legion
		if act[3] == 1 then
			legion = self.armyMap[act[4]]
		else
			legion = self.enemyMap[act[4]]
		end
		legion:addSummonByRecord(act[5], act[6], act[7])
	elseif act[2] == REPORT_NAME.BATTLEEND then
		self.root:unscheduleUpdate()
		self:battleEnd(act[3], act[4])
	elseif act[2] == REPORT_NAME.USEPLAYERSKILL then
		if not self.watchOnly and act[4] == 1 then
			self.playerSkillPoints[act[4]] = act[3]
			self.playerSkillStatusArr[act[4]][act[5]].time = self.time + 5
			self.playerSkillStatusArr[act[4]][act[5]].useTimes = self.playerSkillStatusArr[act[4]][act[5]].useTimes + 1
			self.playerSkillStatusArr[act[4]][act[5]].needPoint = self.playerSkillStatusArr[act[4]][act[5]].basePoint + self.playerSkillStatusArr[act[4]][act[5]].basePoint*(self.playerSkillStatusArr[act[4]][act[5]].useTimes)/2
			self.playerSkillStatusArr[1][act[5]].mask:setVisible(true)
			self.playerSkillStatusArr[1][act[5]].label:setString("5")
			self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
			for k, v in ipairs(self.playerSkillStatusArr[1]) do
				if self.playerSkillPoints[1] < v.needPoint then
					ShaderMgr:setGrayForSprite(v.dragon)
					v.disable = true
				end
			end
			self.playerSkillStatusArr[1][act[5]].pointLabel:setString(tostring(self.playerSkillStatusArr[1][act[5]].needPoint))
		end
		local size = self.bgImg:getContentSize()
		local skill = self.playerSkillArr[act[4]][act[5]].baseSkill
		local info = self.playerSkillArr[act[4]][act[5]].info
		local changeEquipObj = {
			advanced = self.playerSkillArr[act[4]][act[5]].level
		}
		ReplayPlayerSkillAI:playSkillAnimation(act[4], cc.p(act[6], act[7]), skill, info, self, size, changeEquipObj)
	elseif act[2] == REPORT_NAME.SENDBULLET then
		local skill = self:getSkill(act[3], act[4])
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
				legion = self.armyMap[act[10][2]]
			else
				legion = self.enemyMap[act[10][2]]
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
					legion = self.armyMap[v[2]]
				else
					legion = self.enemyMap[v[2]]
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
	elseif act[2] == REPORT_NAME.ADDPOINT then
		self:addPoint(act[3], act[4])
	elseif act[2] == REPORT_NAME.ADDPOINTPERSECOND then
		self:addPointPerSecond(act[3], act[4])
	elseif act[2] == REPORT_NAME.SHAKESCREEN then
		self:runShakeAction(act[3], act[4], act[5])
	end
end

function BattleReplayUI:update(dt)
	if self.battleStatus == BATTLE_STATUS.FIGHTING then
		self.time = self.time + dt
		local otherReport = self.report.otherReport
		local act = otherReport[self.otherReportIndex]
		if act and act[1] <= self.time then
			local flag = true
			local nextAct = act
			while flag do
				self:playWithRecord(nextAct)
				self.otherReportIndex = self.otherReportIndex + 1
				local act2 = otherReport[self.otherReportIndex]
				if act2 and act2[1] <= self.time then
					nextAct = act2
				else
					flag = false
				end
			end
		end
		local soldierReport = self.report.soldierReport
		for k, report in ipairs(soldierReport) do
			if self.soldierActionIndexs[k] == nil then
				self.soldierActionIndexs[k] = 1
			end
			local act = report[5][self.soldierActionIndexs[k]]
			if act and act[1] <= self.time then
				local legion
				local soldier
				if report[1] == 1 then
					legion = self.armyMap[report[2]]
				else
					legion = self.enemyMap[report[2]]
				end
				if report[3] == 1 then
					soldier = legion.heroObj
				elseif report[3] == 2 then
					soldier = legion.soldierObjs[report[4]]
				elseif report[3] == 3 then
					if report[4] > 10000 then
						soldier = legion.specialSummonObjs[report[4]-10000]
					else
						soldier = legion.summonObjs[report[4]]
					end
				end
				local flag = true
				local nextAct = act
				while flag do
					soldier:playWithRecord(nextAct)
					self.soldierActionIndexs[k] = self.soldierActionIndexs[k] + 1
					local act2 = report[5][self.soldierActionIndexs[k]]
					if act2 and act2[1] <= self.time then
						nextAct = act2
					else
						flag = false
					end
				end
			end
		end
		self:showDamageLabel()
		if not self.watchOnly then
			self:updatePlayerSkillPoint()
		end
		if self.time - self.lastTime > 1 then
			self:updateTime()
		end
	end
end

function BattleReplayUI:updateTime()
	local time = math.floor(self.time)
	local nowTime = self.overTime - time
	self.lastTime = time
	if nowTime <= 0 then
		self.timeLabel:setString("00:00")
	else
		self.timeLabel:setString(getTime(nowTime))
	end
end

function BattleReplayUI:usePlayerSkill(guid, index, pos)
end

function BattleReplayUI:sendMessageBeforeFight()
	if self.battleType == BATTLE_TYPE.REPLAY then
		self:battleStart()
	else
		self.verifyObj.pos = self.customObj.rand_pos or 1
		self.verifyObj.attrs = self.customObj.rand_attrs or {}
		local formation = {0,0,0,0,0,0,0,0,0}
		local team = {}
		for k, v in pairs(self.armyMap) do
			if not v.legionInfo.isMercenary then
				formation[v.legionInfo.rolePos] = k
				team[tostring(v.legionInfo.rolePos)] = k
			end
		end
		UserData:getUserObj():setFormation(formation)
		if self.battleType == BATTLE_TYPE.ARENA then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				enemy = self.customObj.challengeUid,
				star = starNum,
				team = team,
				sig = self:generateVerifyMD5()
			}
			MessageMgr:sendPost("fight", "arena", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.awards = jsonObj.data.awards or {}
					self.customObj.ext_awards = jsonObj.data.ext_awards or {}
					if jsonObj.data.awards then
						local awards = GlobalApi:mergeAwards(jsonObj.data.awards)
						GlobalApi:parseAwardData(awards) 
					end
					BattleMgr:setReturnObj(jsonObj)
					self.customObj.responseData = jsonObj.data
					self:battleStart()
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.COUNTRY_WAR then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				enemy_uid = self.customObj.enemy_uid,
				star = starNum,
				winner_pos = {},
				sig = self:generateVerifyMD5(),
			}
			local legionArr = self.report.isWin and self.armyArr[1] or self.armyArr[2]
			for k, v in ipairs(legionArr) do
				local aliveSoldierNum = 0
				for k2, v2 in ipairs(v.soldierObjs) do
					if not v2:isDead() then
						aliveSoldierNum = aliveSoldierNum + 1
					end
				end
				args.winner_pos[tostring(v.legionInfo.rolePos)] = {hp = 100*v.heroObj.hp/v.heroObj.maxMp, soldierNum = aliveSoldierNum}
			end
			MessageMgr:sendPost("fight", "countrywar", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.awards = jsonObj.data.awards or {}
					GlobalApi:parseAwardData(jsonObj.data.awards) 
					BattleMgr:setReturnObj(jsonObj)
					self.customObj.responseData = jsonObj.data
					self:battleStart()
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.WORLDWAR_1 then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				enemy = self.customObj.challengeUid,
				revenge = self.customObj.revenge,
				star = starNum,
				team = team,
				rindex = self.customObj.rindex,
				sig = self:generateVerifyMD5(),
			}
			MessageMgr:sendPost("fight", "worldwar", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.awards = jsonObj.data.awards or {}
					self.customObj.ext_awards = jsonObj.data.ext_awards or {}
					GlobalApi:parseAwardData(jsonObj.data.awards) 
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					BattleMgr:setReturnObj(jsonObj)
					self.customObj.responseData = jsonObj.data
					self:battleStart()
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.WORLDWAR_2 then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				star = starNum,
				team = team,
				sig = self:generateVerifyMD5()
			}
			MessageMgr:sendPost("prepare_fight", "worldwar", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.awards = jsonObj.data.awards or {}
					self.customObj.ext_awards = jsonObj.data.ext_awards or {}
					GlobalApi:parseAwardData(jsonObj.data.awards) 
					BattleMgr:setReturnObj(jsonObj)
					self.customObj.responseData = jsonObj.data
					self:battleStart()
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.GOLDMINE then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				id = self.customObj.mineIndex,
				star = starNum,
				team = team,
				sig = self:generateVerifyMD5()
			}
			MessageMgr:sendPost("fight", "mine", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.responseData = jsonObj.data
					GlobalApi:parseAwardData(jsonObj.data.awards)
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					if jsonObj.data.status == "occupy" then -- 这个矿没有人,直接占领
						promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_PROMPT_6"), MESSAGE_BOX_TYPE.MB_OK, function ()
							BattleMgr:exitBattleField()
						end)
					else
						self:battleStart()
					end
				elseif code == 101 then -- 当前要打的矿换人了
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_1"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 102 then -- 自己占领的矿被攻击中，不能掠夺其他矿
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_2"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 103 then -- 别人当前正处于保护时间
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_3"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 104 then -- 最后5分钟不能被掠夺
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_4"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 105 then -- 我的占领时间用完了
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_PROMPT_5"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 106 then -- 我当前正处于保护时间
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_5"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 107 then -- 我的矿处于最后5分钟不能被掠夺
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_6"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				elseif code == 108 then -- 对方已经撤离，直接占领成功
					promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_7"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.SHIPPERS then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				star = starNum,
				target = self.customObj.target,
				team = team,
				sig = self:generateVerifyMD5()
			}
			MessageMgr:sendPost("fight", "shipper", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.responseData = jsonObj.data
					GlobalApi:parseAwardData(jsonObj.data.awards)
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					UserData:getUserObj():updateShipper("rob", jsonObj.data.rob)
					if jsonObj.data.awards then
						ShippersMgr:setSuccessAward(jsonObj.data.awards, jsonObj.data.type)
					end
					self:battleStart()
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.CITYCRAFT then
			local starNum = self.report.isWin and self.report.starNum or 0
			local args = {
				enemy = self.customObj.challengeUid,
				star = starNum,
				team = team,
				sig = self:generateVerifyMD5()
			}
			MessageMgr:sendPost("fight", "country", json.encode(args), function (jsonObj)
				local code = jsonObj.code
				if code == 0 then
					self.customObj.responseData = jsonObj.data
					GlobalApi:parseAwardData(jsonObj.data.awards)
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					self:battleStart()	
				else
					promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
						BattleMgr:exitBattleField()
					end)
				end
			end)
		elseif self.battleType == BATTLE_TYPE.LEGION_WAR then
		    local starNum = self.report.isWin and self.report.starNum or 0
		    local currHp = 0
		    local maxHp = 0
		    for k, v in ipairs(self.reportField.armyArr[2]) do
		    	if not v.heroObj:isDead() then
		    		currHp = currHp + v.heroObj.hp
		    	end
		    	maxHp = maxHp + v.heroObj.maxHp
				for k2, v2 in ipairs(v.soldierObjs) do
					if not v2:isDead() then
						currHp = currHp + v2.hp/SOLDIER_HP_RATIO
		    		end
		    		maxHp = maxHp + v2.maxHp/SOLDIER_HP_RATIO
				end
			end
			local power = 100 - currHp/maxHp*100
			if power < 0 then
				power = 0
			elseif power > 100 then
				power = 100
			end
		    local args = {
			    city = self.customObj.city,
				arm = self.customObj.arm,
			    star = starNum,
			    team = team,
			    power = math.floor(power),          --打掉的血量
			    sig = self:generateVerifyMD5()
		    }
            MessageMgr:sendPost('fight', 'legionwar', json.encode(args), function (jsonObj)
                local code = jsonObj.code
			    if code == 0 then	
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    self:battleStart()
			    else
				    promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					    BattleMgr:exitBattleField()
				    end)
			    end
            end)             		
        elseif self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER then

		    local starNum = self.report.isWin and self.report.starNum or 0
            local winArr = self.report.isWin and self.reportField.armyArr[1] or self.reportField.armyArr[2]
            local loseArr = (not self.report.isWin) and self.reportField.armyArr[1] or self.reportField.armyArr[2]
            local winBefor = self.report.isWin and self.customObj.myStayingPower or self.customObj.enemy.stayingPower
            local loseBefor = (not self.report.isWin) and self.customObj.myStayingPower or self.customObj.enemy.stayingPower
            local winHp,winMaxHp = 0,0
            local loseHp,loseMaxHp = 0,0

		    for k, v in ipairs(winArr) do
                winHp = winHp + v.heroObj.hp
                winMaxHp = winMaxHp + v.heroObj.maxHp
		    end
            for k, v in ipairs(loseArr) do
                loseHp = loseHp + v.heroObj.hp
                loseMaxHp = loseMaxHp + v.heroObj.maxHp
		    end

            local starNum = self.report.isWin and self.report.starNum or 0
		    local args = {
			    enemy = self.customObj.enemy.uid,
			    star = starNum,
			    power = 0,          --胜利方剩余耐力
                selfConsumePower = 0,   --自身消耗的耐力
                enemyConsumePower = 0,  --目标消耗的耐力
                team = team,
			    sig = self:generateVerifyMD5()
		    }

            local winDamage,loseDamage = (winMaxHp-winHp)/winMaxHp*100,(loseMaxHp-loseHp)/loseMaxHp*100

            local param = math.max(winDamage,self.customObj.minCost)
            param = TerritorialWarMgr:getRealCount('enduranceLoseDamping',param)
            local winLost = math.min(param,winBefor) 
            local loseLost = math.min(math.max(loseDamage,self.customObj.minCost),loseBefor)

            if self.report.isWin == true then
                args.selfConsumePower = math.floor(winLost)
                args.enemyConsumePower = math.floor(loseLost)
            else
                args.selfConsumePower = math.floor(loseLost)
                args.enemyConsumePower = math.floor(winLost)
            end
            args.power = math.floor(winBefor-winLost)

            MessageMgr:sendPost('fight_player', 'territorywar', json.encode(args), function (jsonObj)
                local code = jsonObj.code
			    if code == 0 then	
                    
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end

                    -- 确保耐力值跟服务器保持一致
                    local staying_power = jsonObj.data.selfStayingPower
                    local cur_staying_power = UserData:getUserObj():getEndurance()
                    if cur_staying_power ~= staying_power then
                        UserData:getUserObj():setStayingPower(staying_power)
                    end
                    if args.power == 0 then
                        TerritorialWarMgr:setBattleEnd(4,self.report.isWin,args.selfConsumePower)
                    else
                        TerritorialWarMgr:setBattleEnd(1,self.report.isWin,args.selfConsumePower)
                    end
                    self:battleStart()
			    else
				    promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					    BattleMgr:exitBattleField()
				    end)
			    end
            end)      
		end
	end
end

function BattleReplayUI:sendMessageAfterFight(isWin)
	if self.battleType == BATTLE_TYPE.ARENA then
		local data = self.customObj.responseData
		local displayAwards = DisplayData:getDisplayObjs(data.awards)
		BattleMgr:showBattleResult(self.report.isWin, displayAwards, self.report.starNum)
		if data.diff > 0 then -- 我的名次上升了
			if data.rank < self.customObj.maxRank then
				ArenaMgr:showArenaHighestRank(data.rank, data.diff, displayAwards)
			else
				ArenaMgr:showArenaChangeRank(self.customObj.headpic, self.customObj.quality,self.customObj.headframe, self.armyData.name, self.armyData.fightforce, self.enemyData.name, self.enemyData.fightforce, data.rank, data.enemy_rank, data.diff)
			end
		end
	elseif self.battleType == BATTLE_TYPE.GOLDMINE or
		   self.battleType == BATTLE_TYPE.SHIPPERS or
		   self.battleType == BATTLE_TYPE.WORLDWAR_1 or
		   self.battleType == BATTLE_TYPE.CITYCRAFT then
		local displayAwards = DisplayData:getDisplayObjs(self.customObj.responseData.awards)
		BattleMgr:showBattleResult(self.report.isWin, displayAwards, self.report.starNum) 
    elseif self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER or
    	   self.battleType == BATTLE_TYPE.LEGION_WAR then
		BattleMgr:showBattleResult(self.report.isWin,{},self.report.starNum)
	else
		BattleMgr:showBattleReportResult(self.report.isWin and self.report.starNum or 0)
	end
end

function BattleReplayUI:showBattleStartAnimation()
	local winsize = cc.Director:getInstance():getVisibleSize()
	local overFlag = false
	local startAni = ccui.ImageView:create('uires/ui/battle/battle_001.png')
	startAni:setVisible(false)
	startAni:setPosition(cc.p(winsize.width/2, winsize.height/2 + 50))
	self.root:addChild(startAni)
	local act = cc.Sequence:create(cc.DelayTime:create(0.5), 
				cc.CallFunc:create(function ()
					startAni:setVisible(true)
					AudioMgr.playEffect("media/effect/battle_start.mp3", false)
					self.fightPl:setVisible(true)
					local moveUpAct = cc.EaseBounceOut:create(cc.MoveBy:create(0.5, cc.p(0, -65)))
					self.fightPl:runAction(moveUpAct)
				end),
				-- cc.DelayTime:create(3.5), 
				cc.CallFunc:create(function ()
					startAni:runAction(cc.Sequence:create(
						cc.ScaleTo:create(0.2, 1.2),
						cc.ScaleTo:create(0.2, 0.9),
						cc.ScaleTo:create(0.1, 1),
						cc.CallFunc:create(function ()
							startAni:removeFromParent()
							if overFlag then
								self:sendMessageBeforeFight()
							else
								overFlag = true
							end
						end)
					))
				end))
	self.root:runAction(act)

	self.soldierActionIndexs = {}
	self.otherReportIndex = 1
	self.reportField:calculateReport(function ()
		self.report = self.reportField.totalReport
		if overFlag then
			self:sendMessageBeforeFight()
		else
			overFlag = true
		end
	end)
end

function BattleReplayUI:getDamageInfo()
	return self.reportField:getDamageInfo()
end

function BattleReplayUI:findSoldierAndPlayDie(reportSoldier, soldierType)
	local legion
	local soldier
	if reportSoldier.guid == 1 then
		legion = self.armyMap[reportSoldier.legionObj.pos]
	else
		legion = self.enemyMap[reportSoldier.legionObj.pos]
	end
	if soldierType == 1 then
		soldier = legion.heroObj
		soldier:playDie()
	elseif soldierType == 2 then
		soldier = legion.soldierObjs[reportSoldier.report.recordObj[4]]
		if soldier then
			soldier:playDie()
		end
	end
end

-- pvp专有的跳过功能
function BattleReplayUI:skip()
	if not self:isBattleEnd() then
		local function toFinalResult()
			self.time = self.reportField.time
			self:updateTime()
			local armyArr = self.reportField.armyArr
			local currentHp1 = 0
			local currentHp2 = 0
			for k, v in ipairs(armyArr[1]) do
				if v.heroObj:isDead() then
					self:findSoldierAndPlayDie(v.heroObj, 1)
				else
					currentHp1 = currentHp1 + v.heroObj.hp	
				end
				for k2, v2 in ipairs(v.soldierObjs) do
					if v2:isDead() then
						self:findSoldierAndPlayDie(v2, 2)
					else
						currentHp1 = currentHp1 + v2.hp/SOLDIER_HP_RATIO
					end
				end
			end
			for k, v in ipairs(armyArr[2]) do
				if v.heroObj:isDead() then
					self:findSoldierAndPlayDie(v.heroObj, 1)
				else
					currentHp2 = currentHp2 + v.heroObj.hp	
				end
				for k2, v2 in ipairs(v.soldierObjs) do
					if v2:isDead() then
						self:findSoldierAndPlayDie(v2, 2)
					else
						currentHp2 = currentHp2 + v2.hp/SOLDIER_HP_RATIO
					end
				end
			end
			if currentHp1 < self.playerHealth[1].currentHp then
				self.playerHealth[1].healthBar:setPercent(currentHp1/self.playerHealth[1].maxHp*100)	
			end
			if currentHp2 < self.playerHealth[2].currentHp then
				self.playerHealth[2].healthBar:setPercent(currentHp2/self.playerHealth[2].maxHp*100)
			end
		end
		local otherReportNum = #self.report.otherReport
		local act = self.report.otherReport[otherReportNum]
		if act then
			if act[2] == REPORT_NAME.BATTLEEND then
				self.root:unscheduleUpdate()
				self:battleEnd(act[3], act[4])
				toFinalResult()
			else
				local flag = true
				while flag do
					otherReportNum = otherReportNum - 1
					act = self.report.otherReport[otherReportNum]
					if act == nil or act[2] == REPORT_NAME.BATTLEEND then
						flag = false
					end
				end
				self.root:unscheduleUpdate()
				self:battleEnd(act[3], act[4])
				toFinalResult()
			end
		end
	end
end

function BattleReplayUI:setPlayerHealthBar(guid, hp, maxHp, isSoldier)
    if self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER then
        local config = GameData:getConfData('dfbasepara')
        local soldierHpParam = tonumber(config['soldierHpParam'].value[1])
        local ratio = isSoldier and soldierHpParam or 1
	    self.playerHealth[guid].currentHp = self.playerHealth[guid].currentHp + hp/ratio
	    self.playerHealth[guid].maxHp = self.playerHealth[guid].maxHp + maxHp/ratio
    else
        self.super.setPlayerHealthBar(self, guid, hp, maxHp, isSoldier)
    end
end

function BattleReplayUI:addPlayerHealth(guid, value, soldierType)
    if self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER then
        local config = GameData:getConfData('dfbasepara')
        local soldierHpParam = tonumber(config['soldierHpParam'].value[1])
        local ratio = soldierType == 1 and 1 or soldierHpParam
	    self.playerHealth[guid].currentHp = self.playerHealth[guid].currentHp + value/ratio
	    self.playerHealth[guid].healthBar:setPercent(self.playerHealth[guid].currentHp/self.playerHealth[guid].maxHp*100)
    else
	    self.super.addPlayerHealth(self, guid, value,soldierType)
    end
end

return BattleReplayUI