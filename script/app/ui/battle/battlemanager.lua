local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleVictoryUI = require("script/app/ui/battle/battleui/battlevictoryui")
local ClassBattleFailureUI = require("script/app/ui/battle/battleui/battlefailureui")
local ClassBattleReportResultUI = require("script/app/ui/battle/battleui/battlereportresultui")
local ClassBossInfoUI = require("script/app/ui/battle/battleui/bossinfo")
local ClassCheckInfoUI = require("script/app/ui/battle/battleui/checkinfo")
local ClassEmbattleUI = require("script/app/ui/battle/battleui/embattleui")
local ClassReportField = require("script/app/ui/battle/report/reportfield")
local ClassCheckInfoMainUI = require("script/app/ui/battle/battleui/checkinfomain")

cc.exports.BattleMgr = {
	uiClass = {
		battleUI = nil,
		victoryUI = nil,
		failureUI = nil,
		reportResultUI = nil,
		bossinfoUI = nil,
		checkinfoUI = nil,
		embattleUI = nil,
		totalBattleReport = nil,
		friendsBossResultUI = nil,
        checkinfoMainUI = nil
	},
	battleType = 0,
	returnFunc = nil,
	trust = false				--战斗托管
}

cc.exports.BATTLE_TYPE = {
	NORMAL = 1,		-- 副本
	COMBAT = 2,   	-- 切磋
	LORD = 3, 		-- 争夺太守
	GOLDMINE = 4,   -- 金矿
	ARENA = 5,		-- 竞技场
	GOLD = 6,       -- 金币副本
	EXP = 7,        -- 经验丹副本
	REBORN = 8,		-- 突破石副本
	DESTINY = 9,	-- 天命石副本
	TOWER = 10,		-- 爬塔
	SHIPPERS = 11,  -- 运镖
	TRIAL = 12,		-- 试炼之地
	CITYCRAFT = 13, -- 皇城争霸
	GUARD = 14, 	-- 巡逻
	LEGION = 15, 	-- 军团副本
	GUIDE_1 = 16,   -- 新手引导假战斗1
	GUIDE_2 = 17,   -- 新手引导假战斗2
	WORLDWAR_1 = 18,  -- 群雄争霸
    DIGGING = 19,   -- 挖矿
    CHART = 20,     -- 将星录
    REPLAY = 21, 	-- 战斗回放
    COUNTRY_JADE = 22,  -- 抢夺玉璧
    LEGION_WAR = 23, --军团战
    WORLDWAR_2 = 24, --军团战,
    WARCOLLEGE = 25, -- 战争学院
    SOLO = 26, -- 单挑
    TAGMATCH = 27, -- 车轮战
    TIMELIMITDEFENCE = 28, -- 限时防守
    NEW_LEGION_TRIAL = 29, -- 新版军团开黑
    FRIENDS_COMBAT = 30, --好友切磋
    FRIENDS_BOSS = 31, --好友BOSS
    INFINITE_BATTLE = 33, -- 无限关卡
    INFINITE_BATTLE_BOSS = 34, -- 无限关卡BOSS
    TERRITORALWAL_MONSTER = 35, --领地战打怪
    TERRITORALWAR_PLAYER = 36,  --领地战攻击玩家
    TERRITORALWAR_PUPPET = 37,  --傀儡战
	TERRITORALWAR_BOSS = 38,	--boss
	COUNTRY_WAR = 39, -- 国战
}

local BATTLE_RES = {
	[BATTLE_TYPE.GOLDMINE] = "_replay",
	[BATTLE_TYPE.SHIPPERS] = "_replay",
	[BATTLE_TYPE.CITYCRAFT] = "_replay",
	[BATTLE_TYPE.GOLD] = "_gold",       		-- 金币副本
	[BATTLE_TYPE.EXP] = "_exp",       			-- 经验副本
	[BATTLE_TYPE.REBORN] = "_reborn",   		-- 突破副本
	[BATTLE_TYPE.DESTINY] = "_destiny",   		-- 天命副本
	[BATTLE_TYPE.GUIDE_1] = "_guide1",   		-- 新手引导假战斗1
	[BATTLE_TYPE.GUIDE_2] = "_guide2",   		-- 新手引导假战斗2
	[BATTLE_TYPE.TOWER] = "_tower",       		-- 爬塔
	[BATTLE_TYPE.WARCOLLEGE] = "_warcollege",   -- 战争学院
	[BATTLE_TYPE.SOLO] = "_solo",   			-- 单挑
	[BATTLE_TYPE.TAGMATCH] = "_tagmatch",   	-- 车轮战
	[BATTLE_TYPE.TIMELIMITDEFENCE] = "_timelimitdefence",   	-- 限时防守
	[BATTLE_TYPE.ARENA] = "_replay",
	[BATTLE_TYPE.REPLAY] = "_replay",
	[BATTLE_TYPE.WORLDWAR_1] = "_replay",
	[BATTLE_TYPE.WORLDWAR_2] = "_replay",
	[BATTLE_TYPE.COUNTRY_WAR] = "_replay",
    [BATTLE_TYPE.TERRITORALWAR_PLAYER] = "_replay",
    [BATTLE_TYPE.LEGION_WAR] = "_replay",
    [BATTLE_TYPE.TERRITORALWAR_PUPPET] = "_puppet",
	[BATTLE_TYPE.FRIENDS_BOSS] = "_friendsboss",
	[BATTLE_TYPE.TERRITORALWAR_BOSS] = "_fieldBoss"
}

setmetatable(BattleMgr.uiClass, {__mode = "v"})

local function getPlayerArmyData(attrs, mercenary, slots)
	attrs = attrs or {}
	slots = slots or {1,2,3,4,5,6,7}
	local attrConf = GameData:getConfData("attribute")
	for i = 1, #attrConf do
		if attrs[i] == nil then
			attrs[i] = 0
		end
	end
	local playerData = UserData:getUserObj()
	local armyData = {
		guid = 1,
		name = playerData:getName(),
		fightforce = 0,
		playerskills = UserData:getUserObj():getSkills(),
		level = UserData:getUserObj():getLv(),
		legionArr = {}
	}
	local formation = playerData:getFormation()
	local formationTable = {0, 0, 0, 0, 0, 0, 0, 0, 0}
	local attrIndex = ATTRIBUTE_INDEX
	local flag = true
	for _, i in ipairs(slots) do
		local heroObj = RoleData:getRoleByPos(i)
		if heroObj and heroObj:getId() > 0 then
			armyData.fightforce = armyData.fightforce + heroObj:getFightForce()
			if formation[i] and tonumber(formation[i]) > 0 then
				formationTable[tonumber(formation[i])] = 1
			else
				formation[i] = 0
				flag = false
			end
			local army = {}
			local heroAtts = RoleData:CalPosAttByPos(heroObj, true)
			local soldierId = heroObj:getSoldierId()
			local soldierLv = heroObj:getSoldierLv()
			local soldierLvConf = GameData:getConfData("soldierlevel")[soldierId][soldierLv]
			army.soldierInfo = GameData:getConfData("soldier")[soldierLvConf.soldierId] --军队信息
			local heroBaseInfo = GameData:getConfData("hero")[heroObj:getId()]
			-- 突破相关
			local talentSkill
			local talentLevel = heroObj:getTalent()
			local talent
			local haveTalent = false
			if talentLevel > 0 and heroBaseInfo.innateGroup > 0 then
				talent = talent or {}
				local innategroupConf = GameData:getConfData("innategroup")[heroBaseInfo.innateGroup]
				for i = 1, talentLevel do
					if innategroupConf["level" .. i] > 1000 then
						haveTalent = true
						local specialId = innategroupConf["level" .. i]-1000
						talent["skill" .. specialId] = true
						talent["value" .. specialId] = innategroupConf["specialValues" .. specialId]
					end
				end
			end
			if heroObj:isEquipSpecialExclusive() then
				haveTalent = true
				local exclusiveheroConf = GameData:getConfData("exclusivehero")
				local exclusiveConf = GameData:getConfData("exclusive")
				talent = talent or {}
				talent.skill3 = true
				talent.value3 = exclusiveheroConf[exclusiveConf[heroBaseInfo.exclusiveId].exclusiveId].specialValues
			end
			if haveTalent then
				local innategroupConf = GameData:getConfData("innategroup")[heroBaseInfo.innateGroup]
				talentSkill = require("script/app/ui/battle/special/hero/" .. innategroupConf.specialKey).new(talent)
			end
			local legionInfo = {
				pos = tonumber(formation[i]),
				rolePos = i,
				soldierUrl = army.soldierInfo.url,
				soldierNum = soldierLvConf.num,
				soldierLv = soldierLv,
				headpic = "uires/icon/hero/" .. heroBaseInfo.heroIcon,
				isMonster = false
			}
			local hero = {
				heroId = heroObj:getId(),
				heroName = heroBaseInfo.heroName,
				heroQuality = heroObj:getQuality(),
				baseAtk = heroAtts[attrIndex.ATK]*(1 + attrs[attrIndex.ATK]/100),
				atk = heroAtts[attrIndex.ATK]*(1 + attrs[attrIndex.ATK]/100),
				basePhyDef = heroAtts[attrIndex.PHYDEF]*(1 + attrs[attrIndex.PHYDEF]/100),
				phyDef = heroAtts[attrIndex.PHYDEF]*(1 + attrs[attrIndex.PHYDEF]/100),
				baseMagDef = heroAtts[attrIndex.MAGDEF]*(1 + attrs[attrIndex.MAGDEF]/100),
				magDef = heroAtts[attrIndex.MAGDEF]*(1 + attrs[attrIndex.MAGDEF]/100),
				baseHp = heroAtts[attrIndex.HP]*(1 + attrs[attrIndex.HP]/100),
				maxHp = heroAtts[attrIndex.HP]*(1 + attrs[attrIndex.HP]/100),
				hp = heroAtts[attrIndex.HP]*(1 + attrs[attrIndex.HP]/100),
				mp = heroAtts[attrIndex.MP]*(1 + attrs[attrIndex.MP]/100),
				baseHit = (heroAtts[attrIndex.HIT] + heroAtts[attrIndex.HITPERCENT]*100)*(1 + attrs[attrIndex.HIT]/100),
				hit = (heroAtts[attrIndex.HIT] + heroAtts[attrIndex.HITPERCENT]*100)*(1 + attrs[attrIndex.HIT]/100),
				baseDodge = (heroAtts[attrIndex.DODGE] + heroAtts[attrIndex.DODGEPERCENT]*100)*(1 + attrs[attrIndex.DODGE]/100),
				dodge = (heroAtts[attrIndex.DODGE] + heroAtts[attrIndex.DODGEPERCENT]*100)*(1 + attrs[attrIndex.DODGE]/100),
				baseCrit = (heroAtts[attrIndex.CRIT] + heroAtts[attrIndex.CRITPERCENT]*100)*(1 + attrs[attrIndex.CRIT]/100),
				crit = (heroAtts[attrIndex.CRIT] + heroAtts[attrIndex.CRITPERCENT]*100)*(1 + attrs[attrIndex.CRIT]/100),
				critCoefficient = heroAtts[attrIndex.CRITDMG]*(1 + attrs[attrIndex.CRITDMG]/100),
				baseResi = (heroAtts[attrIndex.RESI] + heroAtts[attrIndex.RESIPERCENT]*100)*(1 + attrs[attrIndex.RESI]/100),
				resi = (heroAtts[attrIndex.RESI] + heroAtts[attrIndex.RESIPERCENT]*100)*(1 + attrs[attrIndex.RESI]/100),
				baseAttackSpeed = heroAtts[attrIndex.ATTACKSPEED]*(1 - heroAtts[attrIndex.ATTACKSPEEDPERCENT]/100 - attrs[attrIndex.ATTACKSPEED]/100),
				attackSpeed = heroAtts[attrIndex.ATTACKSPEED]*(1 - heroAtts[attrIndex.ATTACKSPEEDPERCENT]/100 - attrs[attrIndex.ATTACKSPEED]/100),
				attPercent = heroAtts[attrIndex.DMGINCREASE]*(1 + attrs[attrIndex.DMGINCREASE]/100),
				defPercent = heroAtts[attrIndex.DMGREDUCE]*(1 + attrs[attrIndex.DMGREDUCE]/100),
				ignoreDef = heroAtts[attrIndex.IGNOREDEF]*(1 + attrs[attrIndex.IGNOREDEF]/100),
				cureIncrease = heroAtts[attrIndex.CUREINCREASE]*(1 + attrs[attrIndex.CUREINCREASE]/100),
				recoverMp = heroAtts[attrIndex.RECOVERMP]*(1 + attrs[attrIndex.RECOVERMP]/100),
				moveSpeed = heroBaseInfo.baseSpeed*(1 + heroAtts[attrIndex.MOVESPEEDPERCENT]/100),
				pvpAttPercent = heroAtts[attrIndex.PVPDMGINCREASE]*(1 + attrs[attrIndex.PVPDMGINCREASE]/100),
				pvpDefPercent = heroAtts[attrIndex.PVPDMGREDUCE]*(1 + attrs[attrIndex.PVPDMGREDUCE]/100),
				attackRange = heroBaseInfo.attackRange,
				bodySize = heroBaseInfo.bodySize,
				attackType = heroBaseInfo.attackType,
				professionType = heroBaseInfo.professionType,
				promote = heroObj:getPromoted(),
				changeEquipObj = heroObj:getChangeEquipState(),
				skillGroupId = heroBaseInfo.skillGroupId[heroObj:getPromoteType()],
				skillLevel = heroObj:getDestiny().level,
				url = heroObj:getUrl(),
				scale = heroBaseInfo.scale,
				hpBarHeight = heroBaseInfo.hpBarHeight,
				attPx_t = heroBaseInfo.attPx_t,
				attPy_t = heroBaseInfo.attPy_t,
				attPx_c = heroBaseInfo.attPx_c,
				attPy_c = heroBaseInfo.attPy_c,
				attPx_b = heroBaseInfo.attPx_b,
				attPy_b = heroBaseInfo.attPy_b,
				hitScale = heroBaseInfo.hitScale,
				buffScale = heroBaseInfo.buffScale,
				legionType = heroBaseInfo.legionType,
				deadEffect = heroBaseInfo.deadEffect,
				talentSkill = talentSkill,
				camp = heroBaseInfo.camp
			}
			army.info = legionInfo
			army.heroInfo = hero
			table.insert(armyData.legionArr, army)
		end
	end
	local index = 1
	if not flag then
		for k, v in ipairs(armyData.legionArr) do
			if v.info.pos == 0 then
				for i = index, 9 do
					if formationTable[i] == 0 then
						v.info.pos = i
						formationTable[i] = 1
						index = i + 1
						break
					end
				end
			end
		end
	end
	if mercenary then -- 如果有佣兵
		for k, v in pairs(mercenary.legionArr) do
			table.insert(armyData.legionArr, v)
			for i = index, 9 do
				if formationTable[i] == 0 then
					v.info.pos = i
					v.info.isMercenary = true
					formationTable[i] = 1
					index = i + 1
					break
				end
			end
		end
	end
	return armyData
end

local function createEnemyDataByServer(info, healths)
	local enemyData = {
		guid = 2,
		name = info.name,
		fightforce = "0",
		playerskills = info.skills or {},
		level = info.level or 1,
		legionArr = {}
	}
	local fightforce = 0
	local attrIndex = ATTRIBUTE_INDEX
	local weapon_illusion = info.weapon_illusion or 0
	local wing_illusion = info.wing_illusion or 0
	for k, v in pairs(info.pos) do
		if v.attr[tostring(attrIndex.HP)] > 0 then
			fightforce = fightforce + tonumber(v.fight_force)
			local enemy = {}
			local changeEquipObj
			local heroBaseInfo = GameData:getConfData("hero")[tonumber(v.hid)]
			local soldierId = heroBaseInfo.soldierId
			local soldierLv = v.soldier_level
			local soldierLvConf = GameData:getConfData("soldierlevel")[soldierId][soldierLv]
			enemy.soldierInfo = GameData:getConfData("soldier")[soldierLvConf.soldierId] --军队信息
			-- 突破相关
			local talentSkill
			local talentLevel = v.talent
			local talent
			local haveTalent = false
			if talentLevel > 0 and heroBaseInfo.innateGroup > 0 then
				talent = talent or {}
				local innategroupConf = GameData:getConfData("innategroup")[heroBaseInfo.innateGroup]
				for i = 1, talentLevel do
					if innategroupConf["level" .. i] > 1000 then
						haveTalent = true
						local specialId = innategroupConf["level" .. i]-1000
						talent["skill" .. specialId] = true
						talent["value" .. specialId] = innategroupConf["specialValues" .. specialId]
					end
				end
			end
			local exclusive = v.exclusive or {}
			for i = 1,4 do
				local exclusiveId = exclusive[tostring(i)] or 0
				if exclusiveId > 0 and exclusiveId == heroBaseInfo.exclusiveId then
					haveTalent = true
					local exclusiveheroConf = GameData:getConfData("exclusivehero")
					local exclusiveConf = GameData:getConfData("exclusive")
					talent = talent or {}
					talent.skill3 = true
					talent.value3 = exclusiveheroConf[exclusiveConf[heroBaseInfo.exclusiveId].exclusiveId].specialValues
					break
				end
			end
			if haveTalent then
				local innategroupConf = GameData:getConfData("innategroup")[heroBaseInfo.innateGroup]
				talentSkill = require("script/app/ui/battle/special/hero/" .. innategroupConf.specialKey).new(talent)
			end

			local legionInfo = {
				pos = tonumber(v.slot),
				rolePos = tonumber(k),
				soldierUrl = enemy.soldierInfo.url,
				soldierNum = v.soldierNum or soldierLvConf.num,
				soldierLv = soldierLv,
				headpic = "uires/icon/hero/" .. heroBaseInfo.heroIcon,
				isMonster = false
			}
			local promoteProgress = 1
			local promote = nil
	        local weapon = nil
	        local wing = nil
	        if v.promote and v.promote[1] then
				promote = v.promote[1]
				promoteProgress = v.promote[1]
			end
	        if heroBaseInfo.camp == 5 then
	            if weapon_illusion and weapon_illusion > 0 then
	                weapon = weapon_illusion
	            end
	            if wing_illusion and wing_illusion > 0 then
	                wing = wing_illusion
	            end
	        end
			local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon, wing)
			for attrName, attrIndex in pairs(attrIndex) do
				if v.attr[tostring(attrIndex)] == nil then
					v.attr[tostring(attrIndex)] = 0
				end
			end
			local currHp = v.attr[tostring(attrIndex.HP)]
			if healths and healths[k] then
				currHp = currHp*tonumber(healths[k])/100
			end
			local hero = {
				heroId = tonumber(v.hid),
				heroName = heroBaseInfo.heroName,
				heroQuality = heroBaseInfo.quality,
				baseAtk = v.attr[tostring(attrIndex.ATK)],
				atk = v.attr[tostring(attrIndex.ATK)],
				basePhyDef = v.attr[tostring(attrIndex.PHYDEF)],
				phyDef = v.attr[tostring(attrIndex.PHYDEF)],
				baseMagDef = v.attr[tostring(attrIndex.MAGDEF)],
				magDef = v.attr[tostring(attrIndex.MAGDEF)],
				baseHp = v.attr[tostring(attrIndex.HP)],
				hp = currHp,
				maxHp = v.attr[tostring(attrIndex.HP)],
				hp = v.attr[tostring(attrIndex.HP)] * (v.hp or 100)/100,
				mp = v.attr[tostring(attrIndex.MP)],
				baseHit = v.attr[tostring(attrIndex.HIT)] + v.attr[tostring(attrIndex.HITPERCENT)]*100,
				hit = v.attr[tostring(attrIndex.HIT)] + v.attr[tostring(attrIndex.HITPERCENT)]*100,
				baseDodge = v.attr[tostring(attrIndex.DODGE)] + v.attr[tostring(attrIndex.DODGEPERCENT)]*100,
				dodge = v.attr[tostring(attrIndex.DODGE)] + v.attr[tostring(attrIndex.DODGEPERCENT)]*100,
				baseCrit = v.attr[tostring(attrIndex.CRIT)] + v.attr[tostring(attrIndex.CRITPERCENT)]*100,
				crit = v.attr[tostring(attrIndex.CRIT)] + v.attr[tostring(attrIndex.CRITPERCENT)]*100,
				critCoefficient = v.attr[tostring(attrIndex.CRITDMG)],
				baseResi = v.attr[tostring(attrIndex.RESI)] + v.attr[tostring(attrIndex.RESIPERCENT)]*100,
				resi = v.attr[tostring(attrIndex.RESI)] + v.attr[tostring(attrIndex.RESIPERCENT)]*100,
				baseAttackSpeed = v.attr[tostring(attrIndex.ATTACKSPEED)]*(1 - v.attr[tostring(attrIndex.ATTACKSPEEDPERCENT)]/100),
				attackSpeed = v.attr[tostring(attrIndex.ATTACKSPEED)]*(1 - v.attr[tostring(attrIndex.ATTACKSPEEDPERCENT)]/100),
				moveSpeed = v.attr[tostring(attrIndex.MOVESPEED)]*(1 + v.attr[tostring(attrIndex.MOVESPEEDPERCENT)]/100),
				attPercent = v.attr[tostring(attrIndex.DMGINCREASE)],
				defPercent = v.attr[tostring(attrIndex.DMGREDUCE)],
				ignoreDef = v.attr[tostring(attrIndex.IGNOREDEF)],
				cureIncrease = v.attr[tostring(attrIndex.CUREINCREASE)],
				recoverMp = v.attr[tostring(attrIndex.RECOVERMP)],
				pvpAttPercent = v.attr[tostring(attrIndex.PVPDMGINCREASE)]/100,
				pvpDefPercent = v.attr[tostring(attrIndex.PVPDMGREDUCE)]/100,
				attackRange = heroBaseInfo.attackRange,
				bodySize = heroBaseInfo.bodySize,
				attackType = heroBaseInfo.attackType,
				professionType = heroBaseInfo.professionType,
				promote = v.promote,
				changeEquipObj = changeEquipObj,
				skillGroupId = heroBaseInfo.skillGroupId[promoteProgress],
				skillLevel = v.destiny,
				url = heroBaseInfo.url,
				scale = heroBaseInfo.scale,
				hpBarHeight = heroBaseInfo.hpBarHeight,
				attPx_t = heroBaseInfo.attPx_t,
				attPy_t = heroBaseInfo.attPy_t,
				attPx_c = heroBaseInfo.attPx_c,
				attPy_c = heroBaseInfo.attPy_c,
				attPx_b = heroBaseInfo.attPx_b,
				attPy_b = heroBaseInfo.attPy_b,
				hitScale = heroBaseInfo.hitScale,
				buffScale = heroBaseInfo.buffScale,
				legionType = heroBaseInfo.legionType,
				deadEffect = heroBaseInfo.deadEffect,
				fightForce = v.fight_force,
				talentSkill = talentSkill,
				camp = heroBaseInfo.camp
			}
			enemy.info = legionInfo
			enemy.heroInfo = hero
			table.insert(enemyData.legionArr, enemy)
		end
	end
	enemyData.fightforce = fightforce
	return enemyData
end

function BattleMgr:createCommonEnemyDataByServer(info)
    return createEnemyDataByServer(info)
end

function BattleMgr:createEnemyDataByMonsterId(ids)
	local heroConf = GameData:getConfData("hero")
	local enemyData = {
		guid = 2,
		name = "",
		bossId = 0,
		fightforce = 0,
		playerskills = {},
		level = 1,
		legionArr = {}
	}
	local monsterIdArr = {}
	for i = 1, 9 do
		if ids[i] and ids[i] > 0 then
			monsterIdArr[i] = heroConf[ids[i]].trialMonsterId
		else
			monsterIdArr[i] = 0
		end
	end
	self:createEnemyData(enemyData, monsterIdArr, 0)
	return enemyData
end

function BattleMgr:createEnemyDataByConf(monsterGroup, healths)
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
	local enemyData = {
		guid = 2,
		name = "",
		bossId = 0,
		fightforce = tostring(monsterConf.fightforce),
		playerskills = {},
		level = 1,
		legionArr = {}
	}
	local monsterIdArr = {}
	for i = 1, 9 do
		monsterIdArr[i] = monsterConf["pos" .. i]
	end
	self:createEnemyData(enemyData, monsterIdArr, monsterConf.boss, healths)
	return enemyData
end

-- 敌方战斗力现在本地计算
function BattleMgr:createEnemyDataByClient(monsterGroup, healths)
	local monsterConf = GameData:getConfData("formation")[monsterGroup]

	local fightforce = 0
	for i=1,9 do
	    local posId = monsterConf["pos"..i]
	    if posId and posId > 0 then
	        fightforce = fightforce + RoleData:CalMonsterFightForce(posId)
	    end
	end

	local enemyData = {
		guid = 2,
		name = "",
		bossId = 0,
		fightforce = tostring(fightforce),
		playerskills = {},
		level = 1,
		legionArr = {}
	}
	local monsterIdArr = {}
	for i = 1, 9 do
		monsterIdArr[i] = monsterConf["pos" .. i]
	end
	self:createEnemyData(enemyData, monsterIdArr, monsterConf.boss, healths)
	return enemyData
end


function BattleMgr:createEnemyData(enemyData, monsterIdArr, boss, healths)
	local index = 0
	for i = 1, 9 do
		local monsterId = monsterIdArr[i]
		if monsterId > 0 then
			index = index + 1
			local enemy = {}
			local monsterObj = GameData:getConfData("monster")[monsterId]
			-- 突破相关
			local talentSkill
			local talentLevel = monsterObj.talentLevel
			if talentLevel > 0 and monsterObj.innateGroup > 0 then
				local haveTalent = false
				local talent = {
					skill1 = false,
					skill2 = false
				}
				local innategroupConf = GameData:getConfData("innategroup")[monsterObj.innateGroup]
				for i = 1, talentLevel do
					if innategroupConf["level" .. i] > 1000 then
						haveTalent = true
						local specialId = innategroupConf["level" .. i]-1000
						talent["skill" .. specialId] = true
						talent["value" .. specialId] = innategroupConf["specialValues" .. specialId]
					end
				end
				if haveTalent then
					talentSkill = require("script/app/ui/battle/special/hero/" .. innategroupConf.specialKey).new(talent)
				end
			end
			local legionInfo = {
				pos = i,
				rolePos = 0,
				soldierUrl = "",
				soldierNum = 0,
				soldierLv = monsterObj.soldierStars,
				headpic = "uires/icon/hero/" .. monsterObj.heroIcon,
				isMonster = true
			}
			if monsterObj.soldierId > 0 then
				enemy.soldierInfo = GameData:getConfData("soldier")[monsterObj.soldierId] --军队信息
				legionInfo.soldierUrl = enemy.soldierInfo.url
				legionInfo.soldierNum = enemy.soldierInfo.ownSoldierNum
			end
			local monsterHp = monsterObj.baseHp
			if healths and healths[index] then
				monsterHp = monsterHp*tonumber(healths[index])/100
			end
			if monsterHp > 0 then
				local monster = {
					heroId = monsterId,
					heroName = monsterObj.heroName,
					heroQuality = monsterObj.quality,
					baseHp = monsterObj.baseHp,
					hp = monsterHp,
					maxHp = monsterObj.baseHp,
					mp = monsterObj.baseMp,
					baseAtk = monsterObj.baseAttack,
					atk = monsterObj.baseAttack,
					basePhyDef = monsterObj.baseDef,
					phyDef = monsterObj.baseDef,
					baseMagDef = monsterObj.baseMagDef,
					magDef = monsterObj.baseMagDef,
					baseHit = monsterObj.baseHit,
					hit = monsterObj.baseHit,
					baseDodge = monsterObj.baseDodge,
					dodge = monsterObj.baseDodge,
					baseCrit = monsterObj.baseCrit,
					crit = monsterObj.baseCrit,
					critCoefficient = 0,
					baseResi = monsterObj.baseResi,
					resi = monsterObj.baseResi,
					baseAttackSpeed = monsterObj.attackSpeed,
					attackSpeed = monsterObj.attackSpeed,
					moveSpeed = monsterObj.baseSpeed,
					attPercent = monsterObj.dmgIncrease,
					defPercent = monsterObj.dmgReduce,
					ignoreDef = monsterObj.ignoreDef,
					cureIncrease = monsterObj.cureIncrease,
					recoverMp = monsterObj.recoverMp,
					attackRange = monsterObj.attackRange,
					pvpAttPercent = 0,
					pvpDefPercent = 0,
					bodySize = monsterObj.bodySize,
					attackType = monsterObj.attackType,
					professionType = monsterObj.professionType,
					promote = {},
					skillGroupId = monsterObj.skillGroupId,
					skillLevel = math.ceil(monsterObj.level/10),
					url = monsterObj.url,
					scale = monsterObj.scale,
					hpBarHeight = monsterObj.hpBarHeight,
					attPx_t = monsterObj.attPx_t,
					attPy_t = monsterObj.attPy_t,
					attPx_c = monsterObj.attPx_c,
					attPy_c = monsterObj.attPy_c,
					attPx_b = monsterObj.attPx_b,
					attPy_b = monsterObj.attPy_b,
					hitScale = monsterObj.hitScale,
					buffScale = monsterObj.buffScale,
					legionType = monsterObj.legionType,
					deadEffect = "0",
					talentSkill = talentSkill,
					camp = monsterObj.camp
				}
				enemy.info = legionInfo
				enemy.heroInfo = monster
				table.insert(enemyData.legionArr, enemy)
				if i == boss then
					enemyData.name = monsterObj.heroName
					enemyData.bossId = monsterId
					enemy.isBoss = true
				end
			end
		end
	end
end

function BattleMgr:playBattle(battleType, customObj, returnFunc)
	UIManager:closeAllUI()
	self.returnFunc = returnFunc
	self.returnObj = nil
	customObj = customObj or {}
	local armyData
	local enemyData
	if battleType == BATTLE_TYPE.NORMAL then -- 普通
		local monsterGroup = 0
		if customObj.process then
			local cityData = MapData.data[customObj.cityId]
			local pformation = cityData:getPformation1()
			monsterGroup = pformation[customObj.process]
		else
			monsterGroup = GameData:getConfData("city")[customObj.cityId]["formation" .. customObj.difficulty]
		end
		enemyData = self:createEnemyDataByClient(monsterGroup)
		enemyData.cityId = customObj.cityId
	elseif battleType == BATTLE_TYPE.INFINITE_BATTLE then
		local conf = GameData:getConfData("itmain")[customObj.chapterId][customObj.cityId]
		local monsterGroup = conf['fightId'..(customObj.progress + 1)]
		enemyData = self:createEnemyDataByConf(monsterGroup)
		enemyData.cityId = customObj.cityId
	elseif battleType == BATTLE_TYPE.INFINITE_BATTLE_BOSS then
		enemyData = self:createEnemyDataByConf(customObj.bossId)
	elseif battleType == BATTLE_TYPE.LORD then -- 争夺太守
		enemyData = createEnemyDataByServer(customObj.info)
	elseif battleType == BATTLE_TYPE.GOLDMINE or 
		   battleType == BATTLE_TYPE.ARENA or 
		   battleType == BATTLE_TYPE.SHIPPERS or
		   battleType == BATTLE_TYPE.WORLDWAR_1 or
		   battleType == BATTLE_TYPE.WORLDWAR_2 or
		   battleType == BATTLE_TYPE.COUNTRY_WAR or
           battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER or
           battleType == BATTLE_TYPE.LEGION_WAR or
		   battleType == BATTLE_TYPE.CITYCRAFT then
		armyData = createEnemyDataByServer(customObj.info)
		armyData.guid = 1
		local playerData = UserData:getUserObj()
		local formation = playerData:getFormation()
		local formationTable = {0, 0, 0, 0, 0, 0, 0, 0, 0}
		local flag = true
		for k, v in ipairs(armyData.legionArr) do
			local slot = v.info.pos
			if formation[slot] and tonumber(formation[slot]) > 0 then
				formationTable[tonumber(formation[slot])] = 1
				v.info.pos = tonumber(formation[slot])
			else
				v.info.pos = 0
				flag = false
			end
		end
		if not flag then
			local index = 1
			for k, v in ipairs(armyData.legionArr) do
				if v.info.pos == 0 then
					for i = index, 9 do
						if formationTable[i] == 0 then
							v.info.pos = i
							formationTable[i] = 1
							index = i + 1
							break
						end
					end
				end
			end
		end
		enemyData = createEnemyDataByServer(customObj.enemy)
		table.sort(armyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
		table.sort(enemyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
	elseif battleType == BATTLE_TYPE.REPLAY then -- 战报
		armyData = createEnemyDataByServer(customObj.info)
		armyData.guid = 1
		enemyData = createEnemyDataByServer(customObj.enemy)
		table.sort(armyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
		table.sort(enemyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
	elseif battleType == BATTLE_TYPE.GOLD then -- 金币副本
		enemyData = self:createEnemyDataByConf(customObj.conf.formation)
	elseif battleType == BATTLE_TYPE.EXP then -- 经验丹副本
		local needMonsterCount = customObj.roundConf[1].posCount
		enemyData = createEnemyDataByServer(customObj.info)
		customObj.legionArr = enemyData.legionArr
		local newLegionArr = {}
		local maxMonsterCount = #enemyData.legionArr
		if needMonsterCount > maxMonsterCount then
			needMonsterCount = maxMonsterCount
		end
		local arr = {}
		for i = 1, maxMonsterCount do
			table.insert(arr, i)
		end
		local fightforce = 0
		while needMonsterCount > 0 do
			local legion = enemyData.legionArr[table.remove(arr, math.random(1, maxMonsterCount))]
			fightforce = fightforce + legion.heroInfo.fightForce
			table.insert(newLegionArr, legion)
			needMonsterCount = needMonsterCount - 1
			maxMonsterCount = maxMonsterCount - 1
		end
		enemyData.legionArr = newLegionArr
		enemyData.fightforce = fightforce
	elseif battleType == BATTLE_TYPE.REBORN then -- 突破石副本
		enemyData = createEnemyDataByServer(customObj.info)
	elseif battleType == BATTLE_TYPE.DESTINY then -- 天命石副本
		local needMonsterCount = customObj.roundConf[1].posCount
		enemyData = createEnemyDataByServer(customObj.info)
		customObj.legionArr = enemyData.legionArr
		local newLegionArr = {}
		local maxMonsterCount = #enemyData.legionArr
		if needMonsterCount > maxMonsterCount then
			needMonsterCount = maxMonsterCount
		end
		local arr = {}
		for i = 1, maxMonsterCount do
			table.insert(arr, i)
		end
		local fightforce = 0
		while needMonsterCount > 0 do
			local legion = enemyData.legionArr[table.remove(arr, math.random(1, maxMonsterCount))]
			fightforce = fightforce + legion.heroInfo.fightForce
			table.insert(newLegionArr, legion)
			needMonsterCount = needMonsterCount - 1
			maxMonsterCount = maxMonsterCount - 1
		end
		enemyData.legionArr = newLegionArr
		enemyData.fightforce = fightforce
	elseif battleType == BATTLE_TYPE.TOWER then -- 爬塔
		enemyData = self:createEnemyDataByConf(customObj.id)
		local mercenary = nil
        if customObj.mercenaries then
            local obj = {
			    name = "",
			    pos = customObj.mercenaries
		    }
		    mercenary = createEnemyDataByServer(obj)
        end
        armyData = getPlayerArmyData(customObj.attrs, mercenary, nil)
	elseif battleType == BATTLE_TYPE.TRIAL then --试炼之地
        local obj = {
			name = "",
			pos = customObj.trial_robot
		}
        enemyData = createEnemyDataByServer(obj)
		local obj = {
			name = "",
			pos = customObj.mercenaries
		}
		local mercenary = createEnemyDataByServer(obj)
		armyData = getPlayerArmyData(nil, mercenary, nil)
    elseif battleType == BATTLE_TYPE.NEW_LEGION_TRIAL then --新版军团开黑
        local obj = {
			name = "",
			pos = customObj.trial_robot,
            index = customObj.index
		}
        enemyData = createEnemyDataByServer(obj)
		local obj = {
			name = "",
			pos = customObj.mercenaries,
            index = customObj.index
		}
		local mercenary = createEnemyDataByServer(obj)
		armyData = getPlayerArmyData(nil, mercenary, nil)
	elseif battleType == BATTLE_TYPE.GUARD then --巡逻之地
		enemyData = self:createEnemyDataByConf(customObj.bossId)
    elseif battleType == BATTLE_TYPE.DIGGING then --挖矿
    	enemyData = createEnemyDataByServer(customObj.info)
	elseif battleType == BATTLE_TYPE.LEGION then --军团副本
		enemyData = self:createEnemyDataByConf(customObj.id, customObj.healths)
	elseif battleType == BATTLE_TYPE.GUIDE_1 then -- 新手引导假战斗1
		enemyData = self:createEnemyDataByConf(50004)
    	armyData = self:createEnemyDataByConf(50003)
    	armyData.guid = 1
    	armyData.playerskills = UserData:getUserObj():getSkills()
	elseif battleType == BATTLE_TYPE.GUIDE_2 then -- 新手引导假战斗2
		enemyData = self:createEnemyDataByConf(50002)
    	armyData = self:createEnemyDataByConf(50001)
    	armyData.guid = 1
    	armyData.playerskills = UserData:getUserObj():getSkills()
	elseif battleType == BATTLE_TYPE.CHART then -- 将星录
		enemyData = self:createEnemyDataByConf(customObj.formation)
		armyData = self:createEnemyDataByMonsterId(customObj.heroIds)
    	armyData.guid = 1
    	armyData.playerskills = UserData:getUserObj():getSkills()
    	armyData.fightforce = math.floor(#armyData.legionArr/#enemyData.legionArr*enemyData.fightforce)
    elseif battleType == BATTLE_TYPE.COUNTRY_JADE then -- 抢夺玉璧
        enemyData = createEnemyDataByServer(customObj.info)
	elseif battleType == BATTLE_TYPE.FRIENDS_COMBAT then -- 好友切磋
		enemyData = createEnemyDataByServer(customObj.enemy)
	elseif battleType == BATTLE_TYPE.FRIENDS_BOSS then -- 好友BOSS
		enemyData = self:createEnemyDataByConf(customObj.id, customObj.healths)
	elseif battleType == BATTLE_TYPE.WARCOLLEGE then -- 战争学院
		enemyData = self:createEnemyDataByConf(customObj.formation2)
		armyData = self:createEnemyDataByConf(customObj.formation1)
    	armyData.guid = 1
    	armyData.playerskills = customObj.playerskills
    elseif battleType == BATTLE_TYPE.SOLO then -- 单挑
		local monsterGroup = 0
		if customObj.process then
			local cityData = MapData.data[customObj.cityId]
			local pformation = cityData:getPformation1()
			monsterGroup = pformation[customObj.process]
		else
			monsterGroup = GameData:getConfData("city")[customObj.cityId]["formation" .. customObj.difficulty]
		end
		enemyData = self:createEnemyDataByConf(monsterGroup)
		enemyData.cityId = customObj.cityId
		armyData = getPlayerArmyData(nil, nil, customObj.selectedHeroes)
	elseif battleType == BATTLE_TYPE.TAGMATCH then -- 车轮战
		local monsterGroup = 0
		if customObj.process then
			local cityData = MapData.data[customObj.cityId]
			local pformation = cityData:getPformation1()
			monsterGroup = pformation[customObj.process]
		else
			monsterGroup = GameData:getConfData("city")[customObj.cityId]["formation" .. customObj.difficulty]
		end
		enemyData = self:createEnemyDataByConf(monsterGroup)
		enemyData.cityId = customObj.cityId
		customObj.legionArr = enemyData.legionArr
		local firstLegion = customObj.legionArr[1]
		enemyData.legionArr = {firstLegion}
		armyData = getPlayerArmyData(nil, nil, customObj.selectedHeroes)
	elseif battleType == BATTLE_TYPE.TIMELIMITDEFENCE then -- 限时防守
		local monsterGroup = 0
		if customObj.process then
			local cityData = MapData.data[customObj.cityId]
			local pformation = cityData:getPformation1()
			monsterGroup = pformation[customObj.process]
		else
			monsterGroup = GameData:getConfData("city")[customObj.cityId]["formation" .. customObj.difficulty]
		end
		enemyData = self:createEnemyDataByConf(monsterGroup)
		enemyData.cityId = customObj.cityId
		customObj.legionArr = enemyData.legionArr
		customObj.maxRound = 5
    elseif battleType == BATTLE_TYPE.TERRITORALWAL_MONSTER then     --领地战攻击怪物
		enemyData = self:createEnemyDataByConf(customObj.id)
	elseif battleType == BATTLE_TYPE.TERRITORALWAR_BOSS then		--领地BOSS
		enemyData = self:createEnemyDataByConf(customObj.id)
    elseif  battleType == BATTLE_TYPE.TERRITORALWAR_PUPPET then
		local needMonsterCount = customObj.needMonsterCount
		enemyData = createEnemyDataByServer(customObj.info)
		customObj.legionArr = enemyData.legionArr
		local newLegionArr = {}
		local maxMonsterCount = #enemyData.legionArr
		if needMonsterCount > maxMonsterCount then
			needMonsterCount = maxMonsterCount
		end
		local arr = {}
		for i = 1, maxMonsterCount do
			table.insert(arr, i)
		end
		local fightforce = 0
		while needMonsterCount > 0 do
			local legion = enemyData.legionArr[table.remove(arr, math.random(1, maxMonsterCount))]
			fightforce = fightforce + legion.heroInfo.fightForce
			table.insert(newLegionArr, legion)
			needMonsterCount = needMonsterCount - 1
			maxMonsterCount = maxMonsterCount - 1
		end
		enemyData.legionArr = newLegionArr
		enemyData.fightforce = fightforce
	end

	if armyData == nil then
		armyData = getPlayerArmyData()
	end
	-- enemyData = self:createEnemyDataByConf(100000)
	-- armyData = self:createEnemyDataByConf(100001)
	-- armyData.guid = 1
	self:executeSkillBeforeFight(armyData, enemyData)
	if self.uiClass["battleUI"] == nil then
		local res = "script/app/ui/battle/battleui/battleui"
		if BATTLE_RES[battleType] then
			res = res .. BATTLE_RES[battleType]
			customObj.pvp = true
		else
			customObj.pvp = false
		end
		-- battleType = BATTLE_TYPE.GUIDE_1
		-- 创建战斗实例
		print("fuck=============>", battleType, res)
		self.uiClass["battleUI"] = require(res).new(battleType, armyData, enemyData, customObj)
		self.uiClass["battleUI"]:showUI(UI_SHOW_TYPE.CUSTOM)
	end
end

function BattleMgr:executeSkillBeforeFight(armyData, enemyData)
	for k, v in ipairs(armyData.legionArr) do
		if v.heroInfo.talentSkill then
			v.heroInfo.talentSkill:effectBeforeCreate(v, armyData.legionArr, enemyData.legionArr)
		end
	end
	for k, v in ipairs(enemyData.legionArr) do
		if v.heroInfo.talentSkill then
			v.heroInfo.talentSkill:effectBeforeCreate(v, enemyData.legionArr, armyData.legionArr)
		end
	end
end

function BattleMgr:exitBattleField(uiName, uiIndex)
	if self.uiClass["battleUI"] ~= nil then
		self.uiClass["battleUI"]:hideUI()
		self.uiClass["battleUI"] = nil
		if uiName then
			self.returnObj = nil
			self.returnFunc = nil
			MainSceneMgr:showMainCity(function ()
				GlobalApi:getGotoByModule(uiName)
			end, nil, uiIndex)
		else
			if self.returnFunc then
				self.returnFunc(self.returnObj)
				self.returnObj = nil
				self.returnFunc = nil
			else
				self.returnObj = nil
				MainSceneMgr:showMainCity()
			end
		end
	end
end

function BattleMgr:setReturnObj(obj)
	self.returnObj = obj
end

function BattleMgr:showBattleReportResult(starNum)
	if self.uiClass["reportResultUI"] == nil then
		self.uiClass["reportResultUI"] = ClassBattleReportResultUI.new(starNum)
		self.uiClass["reportResultUI"]:showUI()
		AudioMgr.playEffect("media/effect/battle_victory.mp3", false)
	end
end

function BattleMgr:hideBattleReportResult()
	if self.uiClass["reportResultUI"] ~= nil then
		self.uiClass["reportResultUI"]:hideUI()
        self.uiClass["reportResultUI"] = nil
	end
end

function BattleMgr:showBattleResult(isVictory, displayAwards, starNum,specialAwardDatas,kingLvUpData, notFromBattlefield, damageInfo, otherPic)
	if isVictory then
		if self.uiClass["victoryUI"] == nil then
			-- self.uiClass["victoryUI"] = ClassBattleVictoryUI.new(displayAwards, starNum, specialAwardDatas, kingLvUpData)
			self.uiClass["victoryUI"] = ClassBattleVictoryUI.new(displayAwards, starNum, specialAwardDatas, kingLvUpData, notFromBattlefield, damageInfo, otherPic)
			self.uiClass["victoryUI"]:showUI()
			AudioMgr.playEffect("media/effect/battle_victory.mp3", false)
		end
	else
		if self.uiClass["failureUI"] == nil then
			self.uiClass["failureUI"] = ClassBattleFailureUI.new()
			self.uiClass["failureUI"]:showUI()
			AudioMgr.playEffect("media/effect/battle_failed.mp3", false)
		end
	end
end

function BattleMgr:showBattleResultWithoutBattlefield(isVictory, displayAwards, starNum, specialAwardDatas, kingLvUpData, damageInfo, otherPic)
	if isVictory then
		if self.uiClass["victoryUI"] == nil then
			self.uiClass["victoryUI"] = ClassBattleVictoryUI.new(displayAwards, starNum, specialAwardDatas, kingLvUpData, true, damageInfo, otherPic)
			self.uiClass["victoryUI"]:showUI()
			AudioMgr.playEffect("media/effect/battle_victory.mp3", false)
		end
	else
		if self.uiClass["failureUI"] == nil then
			self.uiClass["failureUI"] = ClassBattleFailureUI.new(true, damageInfo)
			self.uiClass["failureUI"]:showUI()
			AudioMgr.playEffect("media/effect/battle_failed.mp3", false)
		end
	end
end

function BattleMgr:hideVictory()
	if self.uiClass["victoryUI"] ~= nil then
		self.uiClass["victoryUI"]:hideUI()
        self.uiClass["victoryUI"] = nil
	end
end

function BattleMgr:hideFailure()
	if self.uiClass["failureUI"] ~= nil then
		self.uiClass["failureUI"]:hideUI()
        self.uiClass["failureUI"] = nil
	end
end

function BattleMgr:showFriendsBossResult(damage, score, displayAwards, starNum, specialAwardDatas, kingLvUpData)
	if self.uiClass["friendsBossResultUI"] == nil then
		self.uiClass["friendsBossResultUI"] = require("script/app/ui/battle/battleui/friendsbossresultui").new(damage, score, displayAwards, starNum, specialAwardDatas, kingLvUpData)
		self.uiClass["friendsBossResultUI"]:showUI()
		AudioMgr.playEffect("media/effect/battle_victory.mp3", false)
	end
end

function BattleMgr:hideFriendsBossResult()
	if self.uiClass["friendsBossResultUI"] ~= nil then
		self.uiClass["friendsBossResultUI"]:hideUI()
        self.uiClass["friendsBossResultUI"] = nil
	end
end

function BattleMgr:showBattleCounter()
	local battleCounterUI = require("script/app/ui/battle/battleui/battlecounterui").new()
	battleCounterUI:showUI()
end

function BattleMgr:showBattleCounterV2()
	local battleCounterV2UI = require("script/app/ui/battle/battleui/battlecounteruiv2").new()
	battleCounterV2UI:showUI()
end

function BattleMgr:showBossInfo(battleType, enemyData, callback)
	if self.uiClass["bossinfoUI"] == nil then
		self.uiClass["bossinfoUI"] = ClassBossInfoUI.new(battleType, enemyData, callback)
		self.uiClass["bossinfoUI"]:showUI()
	end
end

function BattleMgr:hideBossInfo()
	if self.uiClass["bossinfoUI"] ~= nil then
		self.uiClass["bossinfoUI"]:hideUI()
        self.uiClass["bossinfoUI"] = nil
	end
end

--from: world, state: '', 'arena', 'country', nil
--from: universe, state: 无所谓, 都没有用
function BattleMgr:showCheckInfo(uid, from, state)
	if self.uiClass["checkinfoMainUI"] == nil then
		local args={}
		args.enemy=uid
		args.from = from or "world"
		args.state = state
		MessageMgr:sendPost('get_enemy','user',json.encode(args),
			function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["checkinfoMainUI"] = ClassCheckInfoMainUI.new(data, uid)
				self.uiClass["checkinfoMainUI"]:showUI()
			end
		end)
	end
end

function BattleMgr:hideCheckInfo()
	if self.uiClass["checkinfoMainUI"] ~= nil then
		self.uiClass["checkinfoMainUI"]:ActionClose()
		self.uiClass["checkinfoMainUI"] = nil
	end
end

function BattleMgr:showCheckLastInfo(data, uid)
	if self.uiClass["checkinfoUI"] == nil then
		self.uiClass["checkinfoUI"] = ClassCheckInfoUI.new(data, uid)
		self.uiClass["checkinfoUI"]:showUI()
	end
end

function BattleMgr:hideCheckLastInfo()
	if self.uiClass["checkinfoUI"] ~= nil then
		self.uiClass["checkinfoUI"]:ActionClose()
		self.uiClass["checkinfoUI"] = nil
	end
end


function BattleMgr:showBattleDamageCount(isReport, damageInfo)
	if damageInfo == nil then
		if self.uiClass["battleUI"] then
			damageInfo = self.uiClass["battleUI"]:getDamageInfo()
		else
			return
		end
	end
	local battleDamageCountUI = require("script/app/ui/battle/battleui/battledamagecountui").new(damageInfo, isReport)
	battleDamageCountUI:showUI()
end

function BattleMgr:guideSpecialEmbattle()
	if self.uiClass["battleUI"] then
		self.uiClass["battleUI"]:guideSpecialEmbattle()
	end
end

function BattleMgr:showEmbattleForWorldwarUI(data,callback,stype)
	if self.uiClass["embattleUI"] == nil then
		self.uiClass["embattleUI"] = ClassEmbattleUI.new(data,callback,stype)
		self.uiClass["embattleUI"]:showUI()
	end
end

function BattleMgr:showEmbattleUI()
	if self.uiClass["embattleUI"] == nil then
		MessageMgr:sendPost("get_def_info", "user", "{}", function (jsonObj)
			if jsonObj.code == 0 then
				self.uiClass["embattleUI"] = ClassEmbattleUI.new(jsonObj.data)
				self.uiClass["embattleUI"]:showUI()
			end
		end)
	end
end

function BattleMgr:hideEmbattleUI()
	if self.uiClass["embattleUI"] ~= nil then
		self.uiClass["embattleUI"]:hideUI()
		self.uiClass["embattleUI"] = nil
	end
end

function BattleMgr:calculateReport(battleType, customObj, callback)
	if RoleData:checkAttribute() then
		GlobalApi:kickBecauseCheat()
		return
	end
	local armyData
	local enemyData
	if battleType == BATTLE_TYPE.LEGION then
		enemyData = self:createEnemyDataByConf(customObj.id, customObj.healths)
		armyData = getPlayerArmyData()
	elseif battleType == BATTLE_TYPE.NEW_LEGION_TRIAL then --新版军团开黑
        local obj = {
			name = "",
			pos = customObj.trial_robot,
            index = customObj.index
		}
        enemyData = createEnemyDataByServer(obj)
		local obj = {
			name = "",
			pos = customObj.mercenaries,
            index = customObj.index
		}
		local mercenary = createEnemyDataByServer(obj)
		armyData = getPlayerArmyData(nil, mercenary, nil)
	else
		armyData = createEnemyDataByServer(customObj.info)
		armyData.guid = 1
		enemyData = createEnemyDataByServer(customObj.enemy)
		table.sort(armyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
		table.sort(enemyData.legionArr, function (a, b)
			return a.info.rolePos < b.info.rolePos
		end)
	end
	self:executeSkillBeforeFight(armyData, enemyData)
	local reportCustomObj = {
		rand1 = customObj.rand1,
	 	rand2 = customObj.rand2,
		node = customObj.node
	}
	local battleConfig = GameData:getConfData("battleconfig")[battleType]
	BattleHelper:init(battleConfig.enableSpecial > 0)
	local reportField = ClassReportField.new(battleType, armyData, enemyData, reportCustomObj)
	reportField:calculateReport(function ()
		BattleHelper:clear()
		if callback then
			callback(reportField, reportField:generateVerifyMD5())
		end
	end)
end

function BattleMgr:showBattleCountDown(battleType, customObj, callback)
	if self.uiClass["battleCountDown"] == nil then
		self.uiClass["battleCountDown"] = require("script/app/ui/battle/battleui/battlecountdownui").new(battleType, customObj, callback)
		self.uiClass["battleCountDown"]:showUI()
	end
end

function BattleMgr:hideBattleCountDown()
	if self.uiClass["battleCountDown"] ~= nil then
		self.uiClass["battleCountDown"]:hideUI()
		self.uiClass["battleCountDown"] = nil
	end
end

function BattleMgr:showTotalBattleReport(page)
	if self.uiClass["totalBattleReport"] == nil then
		self.uiClass["totalBattleReport"] = require("script/app/ui/battle/battleui/totalbattlereport").new(page)
		self.uiClass["totalBattleReport"]:showUI()
	end
end

function BattleMgr:hideTotalBattleReport()
	if self.uiClass["totalBattleReport"] ~= nil then
		self.uiClass["totalBattleReport"]:hideUI()
		self.uiClass["totalBattleReport"] = nil
	end
end

function BattleMgr:calculateLegionDie(guid)
	self.dieLegionNum[guid] = self.dieLegionNum[guid] + 1
end

function BattleMgr:initLegionDie()
	self.dieLegionNum = {
		[1] = 0,
		[2] = 0
	}

	self.DieAnimation = {}
end

function BattleMgr:getLegionDie()
	return self.dieLegionNum
end

--跳过战斗保存死亡头像动画
function BattleMgr:setLegionDieAnimation(guid, pos, dieurl, killurl)
	local arr = {
		[1] = guid,
		[2] = pos,
		[3] = dieurl,
		[4] = killurl
	}
	self.DieAnimation[#self.DieAnimation + 1] = arr
end

function BattleMgr:getLegionDieAnimation()
	return self.DieAnimation
end

--设置是否托管战斗
function BattleMgr:setTrust(trust)
	self.trust = trust
end

function BattleMgr:getTrust()
	return self.trust
end

--取消战斗界面战斗托管
function BattleMgr:cancelBattleTrust()
    if self.uiClass["battleUI"] then
		BattleMgr:setTrust(false)

	    if self.uiClass['battleUI'].root:getChildByName("backImg") then
	        self.uiClass['battleUI'].root:getChildByName("backImg"):removeFromParent()
	    end
	    if self.uiClass['battleUI'].root:getChildByName("lableTrustBGImg") then
	        self.uiClass['battleUI'].root:getChildByName("lableTrustBGImg"):removeFromParent()
	    end
	end
end