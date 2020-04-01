local ClassBattleLegion = require("script/app/ui/battle/legion/battlelegion")
local BattleHelper = require("script/app/ui/battle/battlehelper")
local BulletMgr = require("script/app/ui/battle/skill/bulletmanager")
local EffectMgr = require("script/app/ui/battle/effect/effectmanager")
local AttackEffectMgr = require("script/app/ui/battle/effect/attackeffectmanager")
local BuffAniMgr = require("script/app/ui/battle/effect/buffanimationmanager")
local PlayerSkillAI = require("script/app/ui/battle/playerskill/playerskillai")
local ClassPlayerSkillObj = require("script/app/ui/battle/playerskill/playerskillobj")
local ClassReportField = require("script/app/ui/battle/report/reportfield")

local BattleUI = class("BattleUI", BaseUI)

local REPORT_NAME = BattleHelper.ENUM.REPORT_NAME
local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local BATTLE_STATUS = BattleHelper.ENUM.BATTLE_STATUS
local SOLDIER_HP_RATIO = BattleHelper.CONST.HERO_DAMAGE_COEFFICIENT
local FORMATION_CORRECTION = BattleHelper.ENUM.FORMATION_CORRECTION
local TIMESCALE = 1000000
local INITIAL_POINT = 30 -- 初始技能点
local FONT_FILE = {"uires/ui/number/font1_negative.fnt", "uires/ui/number/font1_yellownum.fnt", "uires/ui/number/font1_positive.fnt", "uires/ui/number/font1_cure_crit.fnt", "uires/ui/number/font1_text.fnt"}
local FONT_NUM = {100, 100, 50, 10, 10}
local WINSIZE = cc.Director:getInstance():getVisibleSize()
local SPEEDUP_SCALE = {1.5,2.0,2.5}
local STR_MISS = GlobalApi:getLocalStr('STR_BATTLE_SANBI')
local STR_IMMUNE = GlobalApi:getLocalStr('STR_BATTLE_MAINYI')

local function getTime(t)
	local m = string.format("%02d", math.floor(t%3600/60))
	local s = string.format("%02d", math.floor(t%3600%60%60))
	return m..':'..s
end

function BattleUI:ctor(battleType, armyData, enemyData, customObj)
	self.uiIndex = GAME_UI.UI_BATTLE
	self.battleType = battleType
	self.battleConfig = GameData:getConfData("battleconfig")[battleType]
	self.customObj = customObj
	self.armyData = armyData
	self.enemyData = enemyData
	self.battleStatus = BATTLE_STATUS.INIT
	self.armyMap = {}
	self.enemyMap = {}
	self.armyArr = {{},{}}
	self.legionCount = {
		[1] = 0,
		[2] = 0
	}
	self.damageCount = { -- 伤害统计
		[1] = {0, 0},
		[2] = {0, 0}
	}
	self.hurtCount = {0, 0} -- 受伤统计
	self.time = 0
	self.overTime = 120 -- 普通战斗120秒结束
	self.lastTime = 0
	self.dieNum = { -- 作战单位的死亡数量
		[1] = 0,
		[2] = 0
	}
	self.dieLegionNum = { -- 军团的死亡数量
		[1] = 0,
		[2] = 0
	}
	self.killAnimationList = {} -- 击杀表现效果
	self.killAnimationFlag = false
	self.killHeadNum = {0, 0}
	self.damageLabels = {}
	self.showDamageFlag = false
	self.damageLabelPools = {
		{
			num = 0,
			arr = {},
			indexs = {}
		},
		{
			num = 0,
			arr = {},
			indexs = {}
		},
		{
			num = 0,
			arr = {},
			indexs = {}
		},
		{
			num = 0,
			arr = {},
			indexs = {}
		},
		{
			num = 0,
			arr = {},
			indexs = {}
		}
	}
	self.waitFlag = false
	self.pointAddTimes = {0, 0}
	self.pointPerSecond = {2, 2} -- 能量点默认一秒加2点
	self.starNum = 3
	self.handleWhenSoldierDieMap = {}
	self.handleWhenSoldierDieNum = 0
	self.handleWhenLegionDieMap = {}
	self.handleWhenLegionDieNum = 0
    self.embattleCoutdown = false                   --布阵倒计时是否结束
    
    --保存已经播放过死亡头像的英雄
    self.dies = {
    	[1] = {},
    	[2] = {}
    }
	local uid = UserData:getUserObj():getUid()
	local playerLv = UserData:getUserObj():getLv()
	local speedUpLv1 = tonumber(GlobalApi:getGlobalValue("battleSpeedUpLvLimit1"))
	local speedUpLv2 = tonumber(GlobalApi:getGlobalValue("battleSpeedUpLvLimit2"))
	if playerLv < speedUpLv1 then
		self.speedUp = SPEEDUP_SCALE[1]
		self.canSpeedUp = 1
		self.speedUpLv = speedUpLv1
	elseif playerLv < speedUpLv2 then
		self.speedUp = cc.UserDefault:getInstance():getFloatForKey(uid .. "_battle_speed", SPEEDUP_SCALE[1])
		if self.speedUp >= SPEEDUP_SCALE[2] then
			self.speedUp = SPEEDUP_SCALE[2]
		end
		if playerLv == speedUpLv1 and self.speedUp < SPEEDUP_SCALE[2] then -- 满足第一档加速所需等级时自动加速
			local autoSpeedUpStatus = cc.UserDefault:getInstance():getIntegerForKey(uid .. "_first_speedup", 0)
			if autoSpeedUpStatus < 1 then
				self.speedUp = SPEEDUP_SCALE[2]
				cc.UserDefault:getInstance():setIntegerForKey(uid .. "_first_speedup", 1)
			end
		end
		self.canSpeedUp = 2
		self.speedUpLv = speedUpLv2
	else
		
		self.speedUp = cc.UserDefault:getInstance():getFloatForKey(uid .. "_battle_speed", SPEEDUP_SCALE[1])
		if self.speedUp >= SPEEDUP_SCALE[3] then
			self.speedUp = SPEEDUP_SCALE[3]
		end
		if playerLv == speedUpLv2 and self.speedUp < SPEEDUP_SCALE[3] then -- 满足第二档加速所需等级时自动加速
			local autoSpeedUpStatus = cc.UserDefault:getInstance():getIntegerForKey(uid .. "_first_speedup", 0)
			if autoSpeedUpStatus < 2 then
				self.speedUp = SPEEDUP_SCALE[3]
				cc.UserDefault:getInstance():setIntegerForKey(uid .. "_first_speedup", 2)
			end
		end
		self.canSpeedUp = 3
		self.speedUpLv = speedUpLv2
	end
	self.slowDownSpeedScale = 1
	self.autoFlag = {}
	if self.battleConfig.autoFight1 == 0 then
		local auto = cc.UserDefault:getInstance():getIntegerForKey(uid .. "_auto_fight", 0)
		if auto == 0 then
			self.autoFlag[1] = false
		else
			self.autoFlag[1] = true
		end
	elseif self.battleConfig.autoFight1 == 1 then
		self.autoFlag[1] = true
	elseif self.battleConfig.autoFight1 == 2 then
		self.autoFlag[1] = false
	end
	if self.battleConfig.autoFight2 == 0 then
		self.autoFlag[2] = false
	elseif self.battleConfig.autoFight2 == 1 then
		self.autoFlag[2] = true
	elseif self.battleConfig.autoFight2 == 2 then
		self.autoFlag[2] = false
	end
	self.playerSkillPoints = {INITIAL_POINT, INITIAL_POINT} -- 默认30个豆
	self.playerSkillArr = {{}, {}}
	self.playerSkillStatusArr = {{},{}}
	self:initPlayerSkill()
	-- 战斗校验用
	self.verifyObj = {
		pos = 1,
		attrs = {1}
	}
	math.randomseed(os.time())
end

function BattleUI:initPlayerSkill()
	local playerLv = UserData:getUserObj():getLv()
	local playerSkillConf = GameData:getConfData("playerskill")
	for k, v in pairs(self.armyData.playerskills) do
		if v.id > 0 then
			local obj = ClassPlayerSkillObj.new(self, 1, k, playerSkillConf[v.id], playerLv, v.level)
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

function BattleUI:init()
	self.battleBgPl = self.root:getChildByName("battle_bg_pl")
	self.battleBgPl:setContentSize(WINSIZE)
	if self.battleConfig.bgId == 0 then
		self.bgImg = ccui.ImageView:create("uires/ui/battle/bg_battle" .. math.random(1, 5) .. ".jpg")
	else
		self.bgImg = ccui.ImageView:create("uires/ui/battle/bg_battle" .. self.battleConfig.bgId .. ".jpg")
	end
	self.bgImg:setPosition(cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5))
	self.battleBgPl:addChild(self.bgImg)
	self:initMgr()
	self:initReportField()
	self:initLoadingUI()
	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
		self:loadResource()
	end)))
	self.root:registerScriptHandler(function (event)
		if event == "exit" then
			math.randomseed(os.time())
			local uid = UserData:getUserObj():getUid()
			cc.UserDefault:getInstance():setFloatForKey(uid .. "_battle_speed", self.speedUp)
			if self.battleConfig.autoFight1 == 0 then
				if self.autoFlag[1] then
					cc.UserDefault:getInstance():setIntegerForKey(uid .. "_auto_fight", 1)
				else
					cc.UserDefault:getInstance():setIntegerForKey(uid .. "_auto_fight", 0)
				end
			end
			if self.runningTargets then
				cc.Director:getInstance():getActionManager():resumeTargets(self.runningTargets)
				self.runningTargets = nil
			end
			cc.Director:getInstance():getScheduler():setTimeScale(1)
			UIManager:setTouchEffectSpeed(1)
			if self.listener1 then
                ScriptHandlerMgr:getInstance():removeObjectAllHandlers(self.listener1)
                self.battleBgPl:getEventDispatcher():removeEventListener(self.listener1)
                self.listener1 = nil
            end
			self.root:unscheduleUpdate()
			self.root:unregisterScriptHandler()
			self:clear()
		end
	end)

	if BattleMgr:getTrust() then
		local lableTrustBGImg = ccui.ImageView:create('uires/ui/common/common_tiao44.png')
        lableTrustBGImg:setPosition(WINSIZE.width/2, WINSIZE.height/2)
        local size = lableTrustBGImg:getContentSize()

        local tips = cc.Label:createWithTTF(GlobalApi:getLocalStr('MAP_UI_4'), 'font/gamefont.ttf', 20)
        tips:setColor(cc.c4b(255,255,255, 255))
        tips:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        tips:setPosition(size.width/2, size.height/2 - 100)
        tips:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.FadeIn:create(1))))

		local lableTrust = cc.Label:createWithTTF(GlobalApi:getLocalStr('MAP_UI_11'), 'font/gamefont.ttf', 30)
	    lableTrust:setColor(cc.c4b(255,255,255, 255))
	    lableTrust:enableOutline(COLOROUTLINE_TYPE.BLACK,2)
	    lableTrust:setPosition(size.width/2, size.height/2 + 10)

	    lableTrustBGImg:addChild(tips)
        lableTrustBGImg:addChild(lableTrust)

        local backImg = ccui.ImageView:create('loginpanel/bg1_gray11.png')
        backImg:setPosition(WINSIZE.width/2, WINSIZE.height/2)
        backImg:setScale(9999)
        backImg:setTouchEnabled(true)
        backImg:setSwallowTouches(true)
        backImg:addTouchEventListener(function (sender, eventType)
            promptmgr:showMessageBox(GlobalApi:getLocalStr("MAP_UI_5"), 
            MESSAGE_BOX_TYPE.MB_OK_CANCEL,
            function ()
                BattleMgr:cancelBattleTrust()
            end)
        end)

        lableTrustBGImg:setName("lableTrustBGImg")
        backImg:setName("backImg")

	    self.root:addChild(backImg)
	    self.root:addChild(lableTrustBGImg)
	end
end

function BattleUI:initReportField()
	local customObj = {
		rand1 = self.customObj.rand1,
	 	rand2 = self.customObj.rand2,
		node = self.root
	}
	self.reportField = ClassReportField.new(self.battleType, self.armyData, self.enemyData, customObj)
end

function BattleUI:initAfterLoading()
	self:initField()
	self:initBossSign()
	self:initAnimals()
	local function afterInitLegion()
		self:initSkillListPanel() -- 君主技能
		self:initTopUI()
		self:initCornerUI() -- 四个角落的ui
		self:initExtraUI() 	-- 不同类型的战斗额外的ui
		self:initLegionInfoImg()
		-- 先创建一定数量的伤害数字label
		for i = 1, 5 do
			local fontFile = FONT_FILE[i]
			local fontNum = FONT_NUM[i]
			for j = 1, fontNum do
				local obj = {nil, nil}
				obj[1] = cc.LabelBMFont:create()
				obj[1]:setVisible(false)
				obj[1]:setFntFile(fontFile)
				self.bgImg:addChild(obj[1])
				local act1 = cc.Spawn:create(cc.EaseElasticOut:create(cc.MoveBy:create(0.3, cc.p(0, 40))),cc.ScaleBy:create(0.3, 2))
				local act2 = cc.DelayTime:create(0.2)
				local act3 = cc.Spawn:create(cc.EaseBackIn:create(cc.MoveBy:create(0.3, cc.p(0, 50))),cc.ScaleBy:create(0.35, 1),cc.FadeOut:create(0.3))
				local act4 = cc.CallFunc:create(function ()
					obj[1]:setVisible(false)
					table.insert(self.damageLabelPools[i].indexs, j)
					self.damageLabelPools[i].num = self.damageLabelPools[i].num + 1
				end)
				obj[2] = cc.Sequence:create(act1, act2, act3, act4)
				obj[2]:retain()
				table.insert(self.damageLabelPools[i].arr, obj)
				table.insert(self.damageLabelPools[i].indexs, j)
			end
			self.damageLabelPools[i].num = self.damageLabelPools[i].num + fontNum
		end
		self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function ()
			self.loadingUI:runToPercent(0.2, 100, function ()
				self.loadingUI:removeFromParent()
				self.loadingUI = nil
				self:otherSpecialHandle()
				self:_onShowUIAniOver()
			end)
		end)))
		self:initCompleted()
	end
	self:initLegion(afterInitLegion) -- 军团
end

function BattleUI:initLoadingUI()
	local loadingUI = require ("script/app/ui/loading/loadingui").new(1)
	local loadingPanel = loadingUI:getPanel()
	loadingPanel:setPosition(cc.p(WINSIZE.width/2, WINSIZE.height/2))
	self.root:addChild(loadingPanel, 9999)
	self.loadingUI = loadingUI
end

function BattleUI:loadResource()
	self.animationMap = {}
	self.animationCount = 0
	local skillGroupConf = GameData:getConfData("skillgroup")
	local skillConf = GameData:getConfData("skill")
	local skillAnimationConf = GameData:getConfData("skillanimation")
	local buffConf = GameData:getConfData("buff")
	local bulletConf = GameData:getConfData("bullet")
	local playerSkillConf = GameData:getConfData("playerskill")
	local summonConf = GameData:getConfData("summon")
	local soldierConf = GameData:getConfData("soldier")
	local function _loadBuffRes(buffId)
		local buffRes = buffConf[buffId].buffRes
		if buffRes ~= "0" then
			buffRes = "animation/" .. buffRes .. "/" .. buffRes
			if self.animationMap[buffRes] == nil then
				self.animationMap[buffRes] = 0
				self.animationCount = self.animationCount + 1
			end
		end
		local buffRes2 = buffConf[buffId].buffRes2
		if buffRes2 ~= "0" then
			buffRes2 = "animation/" .. buffRes2 .. "/" .. buffRes2
			if self.animationMap[buffRes2] == nil then
				self.animationMap[buffRes2] = 0
				self.animationCount = self.animationCount + 1
			end
		end
		local reUrl = buffConf[buffId].reUrl
		if reUrl ~= "0" then
			reUrl = "animation/" .. reUrl .. "/" .. reUrl
			-- if self.animationMap[reUrl] == nil then
			-- 	self.animationMap[reUrl] = "animation_littlelossy/xiaobing/xiaobing"
			-- 	self.animationCount = self.animationCount + 1
			-- end
		end
		if buffConf[buffId].sendBuffId > 0 then
			_loadBuffRes(buffConf[buffId].sendBuffId)
		end
	end
	local function _loadSkillRes(guid, skillInfo)
		if skillInfo.skillAnimationId > 0 then
			local skillEffectsRes = skillAnimationConf[skillInfo.skillAnimationId].res
			skillEffectsRes = "animation/" .. skillEffectsRes .. "/" .. skillEffectsRes
			if self.animationMap[skillEffectsRes] == nil then
				self.animationMap[skillEffectsRes] = 0
				self.animationCount = self.animationCount + 1
			end
		end
		if skillInfo.skillAnimationId2 > 0 then
			local skillEffectsRes = skillAnimationConf[skillInfo.skillAnimationId2].res
			skillEffectsRes = "animation/" .. skillEffectsRes .. "/" .. skillEffectsRes
			if self.animationMap[skillEffectsRes] == nil then
				self.animationMap[skillEffectsRes] = 0
				self.animationCount = self.animationCount + 1
			end
		end
		EffectMgr:addPreloadAni(skillInfo)
		if skillInfo.affectedRes ~= "0" then
			local skillEffectsRes = "animation/" .. skillInfo.affectedRes .. "/" .. skillInfo.affectedRes
			if self.animationMap[skillEffectsRes] == nil then
				self.animationMap[skillEffectsRes] = 0
				self.animationCount = self.animationCount + 1
			end
			AttackEffectMgr:addPreloadAni(skillInfo)
		end
		if skillInfo.buffId > 0 then
			_loadBuffRes(skillInfo.buffId)
			BuffAniMgr:addPreloadAni(skillInfo.buffId, skillInfo, false)
		end
		if skillInfo.ownerBuffId > 0 then
			_loadBuffRes(skillInfo.ownerBuffId)
			BuffAniMgr:addPreloadAni(skillInfo.ownerBuffId, skillInfo, true)
		end
		if skillInfo.bulletId > 0 and bulletConf[skillInfo.bulletId].resType == 2 then
			local bulletRes = "animation/" .. bulletConf[skillInfo.bulletId].res .. "/" .. bulletConf[skillInfo.bulletId].res
			if self.animationMap[bulletRes] == nil then
				self.animationMap[bulletRes] = "animation/battle_bullet/battle_bullet"
				self.animationCount = self.animationCount + 1
			end
			BulletMgr:addPreloadBullet(bulletConf[skillInfo.bulletId], skillInfo)
		end
		if skillInfo.summonId > 0 then
			local summonInfo = summonConf[skillInfo.summonId]
			local soldierInfo = soldierConf[summonInfo.modelArmyTypeId]
			local soldierUrl
			if soldierInfo.urlType == 1 then
				if guid == 1 then
					soldierUrl = "animation/" .. soldierInfo.url .. "_g/" .. soldierInfo.url .. "_g"
				else
					soldierUrl = "animation/" .. soldierInfo.url .. "_r/" .. soldierInfo.url .. "_r"
				end
				-- if self.animationMap[soldierUrl] == nil then
				-- 	self.animationMap[soldierUrl] = "animation_littlelossy/xiaobing/xiaobing"
				-- 	self.animationCount = self.animationCount + 1
				-- end
			else
				soldierUrl = "animation/" .. soldierInfo.url .. "/" .. soldierInfo.url
				if self.animationMap[soldierUrl] == nil then
					self.animationMap[soldierUrl] = 0
					self.animationCount = self.animationCount + 1
				end
			end
			if summonInfo.appearEf ~= "0" then
				local appearRes = "animation/" .. summonInfo.appearEf .. "/" .. summonInfo.appearEf
				if self.animationMap[appearRes] == nil then
					self.animationMap[appearRes] = 0
					self.animationCount = self.animationCount + 1
				end
			end
			if summonInfo.buffId > 0 then
				local buffRes = buffConf[summonInfo.buffId].buffRes
				if buffRes ~= "0" then
					buffRes = "animation/" .. buffRes .. "/" .. buffRes
					if self.animationMap[buffRes] == nil then
						self.animationMap[buffRes] = 0
						self.animationCount = self.animationCount + 1
					end
				end
			end
			if soldierInfo.skillGroupId > 0 then
				local summonSkillGroup = skillGroupConf[soldierInfo.skillGroupId]
				if summonSkillGroup.baseSkill > 0 then
					_loadSkillRes(guid, skillConf[summonSkillGroup.baseSkill])
				end
				if summonSkillGroup.autoSkill1 > 0 then
					_loadSkillRes(guid, skillConf[summonSkillGroup.autoSkill1])
				end
				if summonSkillGroup.angerSkill > 0 then
					_loadSkillRes(guid, skillConf[summonSkillGroup.angerSkill])
				end
			end
		end
	end
	for i = 1, 2 do
		for k, v in ipairs(self.playerSkillArr[i]) do
			if v.info.res ~= "0" then
				local skillEffectsRes = v.info.res
				skillEffectsRes = "animation_littlelossy/" .. skillEffectsRes .. "/" .. skillEffectsRes
				if self.animationMap[skillEffectsRes] == nil then
					self.animationMap[skillEffectsRes] = 0
					self.animationCount = self.animationCount + 1
				end
			end
			if v.info.res2 ~= "0" then
				local skillEffectsRes = v.info.res2
				skillEffectsRes = "animation/" .. skillEffectsRes .. "/" .. skillEffectsRes
				if self.animationMap[skillEffectsRes] == nil then
					self.animationMap[skillEffectsRes] = 0
					self.animationCount = self.animationCount + 1
				end
			end
			if v.info.res3 ~= "0" then
				local skillEffectsRes = v.info.res3
				skillEffectsRes = "animation/" .. skillEffectsRes .. "/" .. skillEffectsRes
				if self.animationMap[skillEffectsRes] == nil then
					self.animationMap[skillEffectsRes] = 0
					self.animationCount = self.animationCount + 1
				end
			end
			_loadSkillRes(i, v.baseSkill.baseInfo)
		end
	end
	for k, v in ipairs(self.armyData.legionArr) do
		-- 英雄
		local heroUrl = "animation/" .. v.heroInfo.url .. "/" .. v.heroInfo.url
		if self.animationMap[heroUrl] == nil then
			-- if string.sub(v.heroInfo.url, 1, 4) == "nan_" then
			-- 	self.animationMap[heroUrl] = "animation/nan/nan"
			-- else
				self.animationMap[heroUrl] = 0
			-- end
			self.animationCount = self.animationCount + 1
		end
		-- 小兵
		if v.info.soldierUrl ~= "" then
			local soldierUrl = v.info.soldierUrl .. "_g"
			soldierUrl = "animation/" .. soldierUrl .. "/" .. soldierUrl
			-- if self.animationMap[soldierUrl] == nil then
			-- 	self.animationMap[soldierUrl] = "animation_littlelossy/xiaobing/xiaobing"
			-- 	self.animationCount = self.animationCount + 1
			-- end
		end
		-- 技能
		local skillGroup = skillGroupConf[v.heroInfo.skillGroupId]
		local skillArr = {
			[1] = skillConf[skillGroup.baseSkill],
			[2] = skillConf[skillGroup.angerSkill + v.heroInfo.skillLevel - 1],
			[3] = skillConf[skillGroup.autoSkill1 + v.heroInfo.skillLevel - 1]
		}
		if v.soldierInfo then
			local soldierSkillGroup = skillGroupConf[v.soldierInfo.skillGroupId]
			skillArr[4] = skillConf[soldierSkillGroup.baseSkill]
		end
		for k2, v2 in ipairs(skillArr) do
			_loadSkillRes(1, v2)
		end
	end
	for k, v in ipairs(self.enemyData.legionArr) do
		local heroUrl = "animation/" .. v.heroInfo.url .. "/" .. v.heroInfo.url
		if self.animationMap[heroUrl] == nil then
			-- if string.sub(v.heroInfo.url, 1, 4) == "nan_" then
			-- 	self.animationMap[heroUrl] = "animation/nan/nan"
			-- else
				self.animationMap[heroUrl] = 0
			-- end
			self.animationCount = self.animationCount + 1
		end
		if v.info.soldierUrl ~= "" then
			local soldierUrl = v.info.soldierUrl .. "_r"
			soldierUrl = "animation/" .. soldierUrl .. "/" .. soldierUrl
			-- if self.animationMap[soldierUrl] == nil then
			-- 	self.animationMap[soldierUrl] = "animation_littlelossy/xiaobing/xiaobing"
			-- 	self.animationCount = self.animationCount + 1
			-- end
		end
		local skillGroup = skillGroupConf[v.heroInfo.skillGroupId]
		local skillArr = {
			[1] = skillConf[skillGroup.baseSkill],
			[2] = skillConf[skillGroup.angerSkill + v.heroInfo.skillLevel - 1],
			[3] = skillConf[skillGroup.autoSkill1 + v.heroInfo.skillLevel - 1]
		}
		if v.soldierInfo then
			local soldierSkillGroup = skillGroupConf[v.soldierInfo.skillGroupId]
			skillArr[4] = skillConf[soldierSkillGroup.baseSkill]
		end
		for k2, v2 in ipairs(skillArr) do
			_loadSkillRes(2, v2)
		end
	end
	local suckAni = "animation/buff_xixue_01/buff_xixue_01"
	if self.animationMap[suckAni] == nil then
		self.animationMap[suckAni] = 0
		self.animationCount = self.animationCount + 1
	end
	local bishaji = "animation/ui_bishaji/ui_bishaji"
	if self.animationMap[bishaji] == nil then
		self.animationMap[bishaji] = 0
		self.animationCount = self.animationCount + 1
	end
	local plistArr = {"uires/ui/battle/plist/battle_ui", "animation/battle_bullet/battle_bullet"}
	local totalCount = self.animationCount + #plistArr + 1 -- animation 加 plist 加 spine
	local loadedCount = 0
	local countPerFrame = math.ceil(totalCount/30)
	local co = coroutine.create(function ()
		for k, v in pairs(self.animationMap) do
			if v == 0 then
				BattleHelper:loadAnimationRes(k, k)
			else
				BattleHelper:loadAnimationRes(v, k)
			end
			loadedCount = loadedCount + 1
			if loadedCount%countPerFrame == 0 then
				coroutine.yield()
			end
		end
		for k, v in ipairs(plistArr) do
			BattleHelper:loadPlist(v)
			loadedCount = loadedCount + 1
			coroutine.yield()
		end
	end)
	self.root:scheduleUpdateWithPriorityLua(function (dt)
		self.loadingUI:setPercent(loadedCount/totalCount*70)
		if not coroutine.resume(co) then
			self.root:unscheduleUpdate()
			self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
				self:initAfterLoading()
			end)))
		end
	end, 0)
end

function BattleUI:initField()
	local bgImgSize = self.bgImg:getContentSize()
	local bgMaskImg = ccui.ImageView:create("uires/ui/common/bg_gray2.png")
	bgMaskImg:setVisible(false)
	bgMaskImg:setScale9Enabled(true)
	bgMaskImg:setContentSize(bgImgSize)
	bgMaskImg:setPosition(cc.p(bgImgSize.width*0.5, bgImgSize.height*0.5))
	bgMaskImg:setLocalZOrder(100)
	self.bgImg:addChild(bgMaskImg)
	self.bgMaskImg = bgMaskImg

	self.skillMaskImg = ccui.ImageView:create("uires/ui/common/bg_gray2.png")
	self.skillMaskImg:setOpacity(100)
	self.skillMaskImg:setVisible(false)
	self.skillMaskImg:setScale9Enabled(true)
	self.skillMaskImg:setContentSize(bgImgSize)
	self.skillMaskImg:setPosition(cc.p(bgImgSize.width*0.5, bgImgSize.height*0.5))
	BattleHelper:setSkillMaskImgZorder(self.skillMaskImg)
	self.bgImg:addChild(self.skillMaskImg)
	local touchArr = {}
	local touchNum = 0
	local canNotTouch = false
	local startDis = 0
	local bgImgScale = 1
	local bgImgPos = cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5)
	local limitLW = WINSIZE.width - bgImgSize.width/2
	local limitRW = bgImgSize.width/2
	local limitUH = bgImgSize.height/2
	local limitDH = WINSIZE.height - 410
	local function getWorldAnchorPoint(point)
		return cc.p(point.x/bgImgSize.width/bgImgScale, point.y/bgImgSize.height/bgImgScale)
	end
	local function getWorldPosition(point)
		return cc.p(bgImgSize.width*bgImgScale*self.bgImg:getAnchorPoint().x + point.x - self.bgImg:getPositionX(), bgImgSize.height*bgImgScale*self.bgImg:getAnchorPoint().y + point.y - self.bgImg:getPositionY())
	end
	local function onTouchesMoved(touches, event)
		if canNotTouch then
			return
		end
		if touchNum == 1 then -- 拖动地图
			for k, v in pairs(touches) do
				if touchArr[tostring(v:getId())] then
					touchArr[tostring(v:getId())] = v:getLocation()
					local diffPos = v:getDelta()
					bgImgPos = cc.pAdd(bgImgPos, diffPos)
					if bgImgPos.x > limitRW then
						bgImgPos.x = limitRW
					end
					if bgImgPos.x < limitLW then
						bgImgPos.x = limitLW
					end
					if bgImgPos.y > limitUH then
						bgImgPos.y = limitUH
					end
					if bgImgPos.y < limitDH then
						bgImgPos.y = limitDH
					end
					self.bgImg:setPosition(bgImgPos)
					break
				end
			end
		elseif touchNum == 2 then -- 缩放地图
			local pos1 = nil
			local pos2 = nil
			for k, v in pairs(touches) do
				if touchArr[tostring(v:getId())] then
					touchArr[tostring(v:getId())] = v:getLocation()
				end
			end
			for k, v in pairs(touchArr) do
				if pos1 == nil then
					pos1 = v
				elseif pos2 == nil then
					pos2 = v
				end
			end
			local dis = cc.pGetDistance(pos1, pos2)
			local midPoint = cc.pMidpoint(pos1, pos2)
			if dis ~= startDis and dis > startDis * 0.8 and dis > 100 then
				local newscale = bgImgScale*(1 + (dis-startDis)/500)
				startDis = dis
				if newscale < 1 then
					newscale = 1
				elseif newscale > 2 then
					newscale = 2
				end
				if newscale == bgImgScale then
					return
				end
				local wPoint = getWorldPosition(midPoint)
				local wAnchor = getWorldAnchorPoint(wPoint)
				local x = bgImgSize.width*newscale*wAnchor.x
				local y = bgImgSize.height*newscale*wAnchor.y
				local x1 = bgImgSize.width*newscale*(1-wAnchor.x)
				local y1 = bgImgSize.height*newscale*(1-wAnchor.y)
				if x < midPoint.x then
					midPoint.x = 0
					wAnchor.x = 0
				end
				if x1 < WINSIZE.width - midPoint.x then
					midPoint.x = WINSIZE.width
					wAnchor.x = 1
				end
				if y < midPoint.y then
					midPoint.y = 0
					wAnchor.y = 0
				end
				if y1 < WINSIZE.height - midPoint.y then
					midPoint.y = WINSIZE.height
					wAnchor.y = 1
				end
				self.bgImg:setPosition(midPoint)
				self.bgImg:setAnchorPoint(wAnchor)
				self.bgImg:setScale(newscale)
				bgImgScale = newscale
				bgImgPos = midPoint
				limitLW = WINSIZE.width - bgImgSize.width*newscale*(1 - wAnchor.x)
				limitRW = bgImgSize.width*newscale*wAnchor.x
				limitUH = bgImgSize.height*newscale*wAnchor.y
				limitDH = WINSIZE.height - bgImgSize.height*newscale*(1 - wAnchor.y)
			end
		end
	end
	local function onTouchesBegan(touches, event)
		if canNotTouch then
			return
		end
		if touchNum == 0 then
			touchArr[tostring(touches[1]:getId())] = touches[1]:getLocation()
			if touches[2] then
				touchArr[tostring(touches[2]:getId())] = touches[2]:getLocation()
				touchNum = 2
				startDis = cc.pGetDistance(touches[1]:getLocation(), touches[2]:getLocation())
			else
				touchNum = 1
			end
		elseif touchNum == 1 then
			touchArr[tostring(touches[1]:getId())] = touches[1]:getLocation()
			local pos1 = nil
			local pos2 = nil
			for k, v in pairs(touchArr) do
				if pos1 == nil then
					pos1 = v
				elseif pos2 == nil then
					pos2 = v
				end
			end
			startDis = cc.pGetDistance(pos1, pos2)
			touchNum = 2
		end
	end
	local function onTouchesEnded(touches, event)
		for k, v in pairs(touches) do
			if touchArr[tostring(v:getId())] then
				touchArr[tostring(v:getId())] = nil
				if touchNum == 2 then
					canNotTouch = true
				elseif touchNum == 1 then
					canNotTouch = false
				end
				touchNum = touchNum - 1
			end
		end
	end
	local listener1 = cc.EventListenerTouchAllAtOnce:create()
	listener1:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
	listener1:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN ) 
	listener1:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED ) 
	self.battleBgPl:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener1, self.battleBgPl)
	self.listener1 = listener1
	
	local targetLegion = nil
	self.pedestalArr = {}
	self.battleCounterArr = {}
	for i = 1, 3 do
		local battleCounterAni = BattleHelper:createLittleLossyAniByName("battle_counter")
		battleCounterAni:setPosition(cc.p((LEGION_POS[2][i].x + LEGION_POS[1][i].x)/2, LEGION_POS[1][i].y + 30))
		self.battleCounterArr[i] = battleCounterAni
		battleCounterAni:setVisible(false)
		self.bgImg:addChild(battleCounterAni)
	end
	-- 布阵底座
	for i = 1, 9 do
		local pedestal = ccui.ImageView:create("uires/ui/battle/img_base2.png")
		self.pedestalArr[i] = pedestal
		pedestal:setTouchEnabled(true)
		pedestal:setPosition(cc.p(LEGION_POS[1][i].x, LEGION_POS[1][i].y + 20))
		self.bgImg:addChild(pedestal)
		local particle = cc.ParticleSystemQuad:create("particle/battle_circle.plist")
		particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
		particle:setPosition(cc.p(76, 38))
		particle:setScaleY(0.7)
		pedestal:addChild(particle)
		pedestal:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				targetLegion = self.armyMap[i]
				if targetLegion then
					self.battleBtn:setTouchEnabled(false)
					BattleHelper:setSoldierTopZorder(targetLegion.heroObj)
					for k, v in ipairs(self.pedestalArr) do
						if k ~= i then
							v:setTouchEnabled(false)
						end
					end
				end
			elseif eventType == ccui.TouchEventType.moved then
				if targetLegion then
					local pos = sender:getTouchMovePosition()
					local convertPos = self.bgImg:convertToNodeSpace(pos)
					targetLegion.heroObj:setPosition(convertPos)
				end
			elseif eventType == ccui.TouchEventType.ended then
				if targetLegion == nil then
					return
				end
				self.battleBtn:setTouchEnabled(true)
				targetLegion.heroObj:setPosition(LEGION_POS[1][i])
				BattleHelper:setSoldierZorder(targetLegion.heroObj)
				for k, v in ipairs(self.pedestalArr) do
					v:setTouchEnabled(true)
				end
			elseif eventType == ccui.TouchEventType.canceled then
				if targetLegion == nil then
					return
				end
				local endPos = sender:getTouchEndPosition()
				local convertPos = self.bgImg:convertToNodeSpace(endPos)
				local minLength = 10000
				local minIndex = 0
				for n = 1, 9 do
					local lengh = cc.pGetDistance(LEGION_POS[1][n], convertPos)
					if minLength > lengh then
						minLength = lengh
						minIndex = n
					end
				end
				local action = nil
				if minLength > 100 or minIndex == i then  -- 离最近的一个底座也太远了
					action = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[1][i]), cc.CallFunc:create(function ()
						self.battleBtn:setTouchEnabled(true)
						for k, v in ipairs(self.pedestalArr) do
							v:setTouchEnabled(true)
						end
						BattleHelper:setSoldierZorder(targetLegion.heroObj)
					end))
				else
					local swopLegion = self.armyMap[minIndex]
					if swopLegion ~= nil then
						local swopAction = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[1][i]), cc.CallFunc:create(function ()
							BattleHelper:setSoldierZorder(swopLegion.heroObj)
							swopLegion:setSoldierPos(LEGION_POS[1][i])
							swopLegion:setPos(i)
							self.armyflags[i]:setVisible(true)
							self.armyflags[i]:setTexture("uires/ui/battle/flag_" .. swopLegion.legionType .. ".png")
							local starNum = swopLegion.soldierLv%5
							starNum = starNum == 0 and 5 or starNum
							local starLv = math.ceil(swopLegion.soldierLv/5)
							for j = 1, 5 do
								if swopLegion.soldierLv > 1 and starNum >= j then
									self.armyStars[i][j]:setVisible(true)
									self.armyStars[i][j]:setTexture("uires/ui/role/role_star_" .. starLv .. ".png")
								else
									self.armyStars[i][j]:setVisible(false)
								end
							end
						end))
						swopLegion.heroObj:moveToOtherPos(swopAction)
					end
					action = cc.Sequence:create(cc.MoveTo:create(0.2, LEGION_POS[1][minIndex]), cc.CallFunc:create(function ()
						self.armyMap[i] = swopLegion
						self.armyMap[minIndex] = targetLegion
						targetLegion:setPos(minIndex)
						BattleHelper:setSoldierZorder(targetLegion.heroObj)
						targetLegion:setSoldierPos(LEGION_POS[1][minIndex])
						self.armyflags[minIndex]:setVisible(true)
						self.armyflags[minIndex]:setTexture("uires/ui/battle/flag_" .. targetLegion.legionType .. ".png")
						local starNum = targetLegion.soldierLv%5
						starNum = starNum == 0 and 5 or starNum
						local starLv = math.ceil(targetLegion.soldierLv/5)
						for j = 1, 5 do
							if targetLegion.soldierLv > 1 and starNum >= j then
								self.armyStars[minIndex][j]:setVisible(true)
								self.armyStars[minIndex][j]:setTexture("uires/ui/role/role_star_" .. starLv .. ".png")
							else
								self.armyStars[minIndex][j]:setVisible(false)
							end
						end
						if swopLegion == nil then
							self.armyflags[i]:setVisible(false)
							for j = 1, 5 do
								self.armyStars[i][j]:setVisible(false)
							end
						end
						self:checkFormation()
						for k, v in pairs(self.pedestalArr) do
							v:setTouchEnabled(true)
						end
						self.battleBtn:setTouchEnabled(true)
					end))
				end
				targetLegion.heroObj:moveToOtherPos(action)
				for k, v in pairs(self.pedestalArr) do
					v:setTouchEnabled(false)
				end
			end
		end)
 	end
end

function BattleUI:initBossSign()
	if self.battleType == BATTLE_TYPE.NORMAL then
	 	local isShow = GameData:getConfData("city")[self.customObj.cityId].bossShow
	 	if self.customObj.process then
	 		isShow = 0
	 	end
		local star = MapData.data[self.customObj.cityId]:getStar(1)
		isShow = (isShow > 0) and true or false
		if isShow and star <= 0 then
			for k, v in ipairs(self.enemyData.legionArr) do
				if v.isBoss then
					local sign = ccui.ImageView:create("uires/ui/battle/bosssign.png")
					sign:setTouchEnabled(true)
					self.bosssign = sign
					BattleHelper:setSpecialNodeZorder(sign)
					self.bgImg:addChild(sign)
					sign:setPosition(cc.p(LEGION_POS[2][v.info.pos].x, LEGION_POS[2][v.info.pos].y+100))
					sign:addClickEventListener(function ()
						if self.bosssign then
							self.bosssign:removeFromParent()
							self.bosssign = nil
							BattleMgr:showBossInfo(self.battleType, v)
						end
					end)

					local pedestal = ccui.ImageView:create("uires/ui/battle/img_base2.png")
					pedestal:setTouchEnabled(true)
					self.pedestal = pedestal
					pedestal:setPosition(cc.p(LEGION_POS[2][v.info.pos].x, LEGION_POS[2][v.info.pos].y + 20))
					self.bgImg:addChild(pedestal)
					local particle = cc.ParticleSystemQuad:create("particle/battle_circle.plist")
					particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
					particle:setPosition(cc.p(76, 38))
					particle:setScaleY(0.7)
					pedestal:addChild(particle)
					pedestal:addClickEventListener(function ()
						if self.bosssign then
							self.bosssign:removeFromParent()
							self.bosssign = nil
							BattleMgr:showBossInfo(self.battleType, v)
						end
					end)
					break
				end
			end
		end
	end
end

function BattleUI:initAnimals()
	-- 地面的
	local pos = {
		{{200, 700}, {600, 700}},
		{{700, 1300}, {40, 140}},
		{{1000, 1400}, {600, 700}}
	}
	local index = {0,0,0}
	for i = 1, 3 do
		index[i] = math.random(10, 20)
		local animal = BattleHelper:createLittleLossyAniByName("battle_animal_" .. i)
		animal:setScale(0.8)
		local oriPos = cc.p(math.random(pos[i][1][1], pos[i][1][2]), math.random(pos[i][2][1], pos[i][2][2]))
		self.bgImg:addChild(animal)
		animal:setPosition(oriPos)
		if math.random(100) > 50 then
			animal:setScaleX(0.8)
		else
			animal:setScaleX(-0.8)
		end
		animal:getAnimation():play("idle", -1, -1)
		animal:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
			if movementType == 2 then
				if movementID == "idle" then
					index[i] = index[i] - 1
					if index[i] < 0 then
						index[i] = math.random(10, 20)
						animal:getAnimation():play("walk", -1, -1)
						local targetPos = cc.p(math.random(pos[i][1][1], pos[i][1][2]), math.random(pos[i][2][1], pos[i][2][2]))
						local dis = cc.pGetDistance(oriPos, targetPos)
						local time = math.abs(dis/10)
						if targetPos.x > oriPos.x then
							animal:setScaleX(-0.8)
						else
							animal:setScaleX(0.8)
						end
						oriPos = targetPos
						animal:runAction(cc.Sequence:create(cc.MoveTo:create(time, targetPos), cc.CallFunc:create(function ()
							animal:getAnimation():play("idle", -1, -1)
						end)))
					end
				end
			end
		end)
	end

	-- 天上的
	local index2 = 20
	local animal2 = BattleHelper:createLittleLossyAniByName("battle_animal_101")
	local oriPosY2 = math.random(0, 820)
	local oriPos2
	BattleHelper:setZorder(animal2, 0, 1)
	self.bgImg:addChild(animal2)
	if math.random(100) > 50 then
		animal2:setScaleX(1)
		oriPos2 = cc.p(1900, oriPosY2)
	else
		animal2:setScaleX(-1)
		oriPos2 = cc.p(-100, oriPosY2)
	end
	animal2:setPosition(oriPos2)
	animal2:getAnimation():play("walk", -1, -1)
	animal2:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
		if movementType == 2 then
			if movementID == "walk" then
				index2 = index2 - 1
				if index2 < 0 then
					index2 = math.random(20, 40)
					animal2:getAnimation():play("idle", -1, -1)
					local targetPosY2 = math.random(0, 820)
					local targetPos2 = cc.p(1800 - oriPos2.x, targetPosY2)
					local dis2 = cc.pGetDistance(oriPos2, targetPos2)
					local time2 = math.abs(dis2/300)
					if targetPos2.x > oriPos2.x then
						animal2:setScaleX(-1)
						animal2:setRotation(math.deg(math.atan2(oriPos2.y - targetPos2.y, targetPos2.x - oriPos2.x)))
					else
						animal2:setScaleX(1)
						animal2:setRotation(-math.deg(math.atan2(oriPos2.y - targetPos2.y, oriPos2.x - targetPos2.x)))
					end
					oriPos2 = targetPos2
					animal2:runAction(cc.Sequence:create(cc.MoveTo:create(time2, targetPos2), cc.CallFunc:create(function ()
						animal2:getAnimation():play("walk", -1, -1)
					end)))
				end
			end
		end
	end)
end

function BattleUI:initSkillListPanel()
	self.skillListNode = self.root:getChildByName("skill_list_node")
	self.skillListNode:setPosition(cc.p(WINSIZE.width - 160, 0))
	local skillBorderPos = {0,0,0,0,0}
	local visibleNum = 0
	local touchBegin = false
	local startPos
	local dragonRangeImg = {
		[1] = ccui.ImageView:create("uires/ui/battle/playerskill_range_circle.png"),
		[2] = ccui.ImageView:create("uires/ui/battle/playerskill_range_rect.png")
	}
	self.battleBgPl:addChild(dragonRangeImg[1])
	self.battleBgPl:addChild(dragonRangeImg[2])
	dragonRangeImg[1]:setVisible(false)
	dragonRangeImg[2]:setVisible(false)
	self.dragonArr = {}
	local currDragon
	for i = 1, 5 do
		local skillBorder = self.skillListNode:getChildByName("skill_border_" .. i)
		skillBorder:setLocalZOrder(6-i)
		skillBorderPos[i] = cc.p(skillBorder:getPosition())
		local playerskill = self.playerSkillArr[1][i]
		if playerskill then
			self.dragonArr[i] = {}
			visibleNum = visibleNum + 1
			local dragon = skillBorder:getChildByName("dragon")
			dragon:setTexture("uires/ui/treasure/treasure_" .. playerskill.info.icon)
			local pointLabel = skillBorder:getChildByName("text")
			pointLabel:setString(tostring(playerskill.info.skillPoints))
			local mask = skillBorder:getChildByName("mask")
			local label = mask:getChildByName("text")
			-- local flag = skillBorder:getChildByName("flag")
			-- local levelLabel = flag:getChildByName("text")
			-- levelLabel:setString(tostring(playerskill.level))
			self.playerSkillStatusArr[1][i].border = skillBorder
			self.playerSkillStatusArr[1][i].dragon = dragon
			self.playerSkillStatusArr[1][i].mask = mask
			self.playerSkillStatusArr[1][i].label = label
			self.playerSkillStatusArr[1][i].pointLabel = pointLabel
			-- self.playerSkillStatusArr[1][i].flag = flag
			if self.battleConfig.autoFight1 == 0 then
				skillBorder:addTouchEventListener(function (sender, eventType)
					if self.battleStatus ~= BATTLE_STATUS.FIGHTING then
						return
					end
					if eventType == ccui.TouchEventType.began then
						if self.playerSkillStatusArr[1][i].disable then
							return
						end
						if self.autoFlag[1] then
							self:setAutoFight(1, false)
						end
						for k, v in ipairs(self.playerSkillStatusArr[1]) do
							if k ~= i then
								v.border:setTouchEnabled(false)
							end
						end
						touchBegin = true
						startPos = sender:getTouchBeganPosition()
						if not self.dragonArr[i].dragon then
							if self.playerSkillArr[1][i].info.res == "0" then
								self.dragonArr[i].dragon = BattleHelper:createAniByName(self.playerSkillArr[1][i].info.res2)
							else
								local changeEquipObj = GlobalApi:getChangeEquipState(self.playerSkillArr[1][i].level)
								self.dragonArr[i].dragon = BattleHelper:createLittleLossyAniByName(self.playerSkillArr[1][i].info.res, nil, changeEquipObj)
							end
							self.dragonArr[i].dragon:setOpacity(100)
							self.dragonArr[i].dragon:getAnimation():play("attack", -1, -1)
							self.dragonArr[i].dragon:getAnimation():gotoAndPause(self.playerSkillArr[1][i].info.pauseFrame)
							self.dragonArr[i].dragon:setVisible(false)
							self.dragonArr[i].visible = false
							self.dragonArr[i].rangeImg = dragonRangeImg[self.playerSkillArr[1][i].info.rangeType]
							self.dragonArr[i].offsetX = self.playerSkillArr[1][i].info.offsetX
							self.dragonArr[i].offsetY = self.playerSkillArr[1][i].info.offsetY
							self.battleBgPl:addChild(self.dragonArr[i].dragon)
						end
						currDragon = self.dragonArr[i]
						currDragon.rangeImg:setScaleX(self.playerSkillArr[1][i].info.rangeScaleX/100)
						currDragon.rangeImg:setScaleY(self.playerSkillArr[1][i].info.rangeScaleY/100)
						currDragon.effectByClick = true
					elseif eventType == ccui.TouchEventType.moved then
						if touchBegin then
							local currPos = sender:getTouchMovePosition()
							local disPos = cc.pSub(currPos, startPos)
							if currDragon.visible then
								if currPos.y <= skillBorderPos[1].y + 100 then
									currDragon.dragon:setVisible(false)
									currDragon.rangeImg:setVisible(false)
									currDragon.visible = false
								else
									currDragon.dragon:setPosition(cc.p(currPos.x + currDragon.offsetX, currPos.y - 55))
									currDragon.rangeImg:setPosition(cc.p(currPos))
								end
							else
								if currPos.y >= skillBorderPos[1].y + 100 then
									currDragon.effectByClick = false
									currDragon.dragon:setVisible(true)
									currDragon.rangeImg:setVisible(true)
									currDragon.visible = true
									currDragon.dragon:setPosition(cc.p(currPos.x + currDragon.offsetX, currPos.y - 55))
									currDragon.rangeImg:setPosition(cc.p(currPos))
								end
							end
						end
					elseif eventType == ccui.TouchEventType.ended then
						if touchBegin then
							for k, v in ipairs(self.playerSkillStatusArr[1]) do
								v.border:setTouchEnabled(true)
							end
							if currDragon.visible then
								currDragon.dragon:setVisible(false)
								currDragon.rangeImg:setVisible(false)
								currDragon.visible = false
							end
							touchBegin = false
							if currDragon.effectByClick then -- 按点击逻辑使用君主技能
								if self.playerSkillPoints[1] >= self.playerSkillStatusArr[1][i].needPoint then
									if self.playerSkillStatusArr[1][i].time == 0 then
										self:usePlayerSkill(1, i)
									end
								end
							end
						end
					elseif eventType == ccui.TouchEventType.canceled then
						if touchBegin then
							for k, v in ipairs(self.playerSkillStatusArr[1]) do
								v.border:setTouchEnabled(true)
							end
							if currDragon.visible then
								currDragon.dragon:setVisible(false)
								currDragon.rangeImg:setVisible(false)
								currDragon.visible = false
								if self.playerSkillPoints[1] >= self.playerSkillStatusArr[1][i].needPoint then
									if self.playerSkillStatusArr[1][i].time == 0 then
										local endPos = sender:getTouchEndPosition()
										self:usePlayerSkill(1, i, endPos)
									end
								end
							end
							touchBegin = false
						end
					end
				end)
			end
		else
			skillBorder:setVisible(false)
		end
	end
	for i = 1, visibleNum do
		self.playerSkillStatusArr[1][i].border:setPosition(skillBorderPos[6-i])
	end
	self.skillPointImg = self.skillListNode:getChildByName("skill_point_img")
	self.skillPointImg:setVisible(false)
	self.skillPointImg:setPosition(cc.p(240 - WINSIZE.width, 20))
	self.skillPointLabel = self.skillPointImg:getChildByName("skill_point_tx")
	self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
	self.counterBtn = self.skillListNode:getChildByName("counter_btn")
	self.counterBtn:setPosition(cc.p(220 - WINSIZE.width, 10))
	local counterLabel = self.counterBtn:getChildByName("text")
	counterLabel:setString(string.format(GlobalApi:getLocalStr("STR_COUNTER_RELATION"), "\n"))
	self.counterBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			BattleMgr:showBattleCounterV2()
		end
	end)
end

function BattleUI:isAuto(guid)
	if self.waitFlag then
		return false
	else
		return self.autoFlag[guid]
	end
end

function BattleUI:setAutoFight(guid, flag)
	self.autoFlag[guid] = flag
	if guid == 1 then
		if flag then
			self.autoSelectedNode:setVisible(true)
			self.autoLabel:setString(GlobalApi:getLocalStr("STR_CANCEL"))
		else
			self.autoSelectedNode:setVisible(false)
			self.autoLabel:setString(string.format(GlobalApi:getLocalStr("STR_AUTO_FIGHT"), "\n"))
		end
	end
end

function BattleUI:initTopUI()
	self.topPl = self.root:getChildByName("top_pl")
	self.topPl:setPosition(cc.p(WINSIZE.width/2, WINSIZE.height))
	self.fightPl = self.topPl:getChildByName("fight_pl")
	self.fightPl:setVisible(false)
	self.timeLabel = self.fightPl:getChildByName("time_tx")
	self.timeLabel:setString(getTime(self.overTime))
	self.fightforceNode = self.topPl:getChildByName("fightforce_node")
	local label1 = self.fightforceNode:getChildByName("text_1")
	local label2 = self.fightforceNode:getChildByName("text_2")
	label1:setString(GlobalApi:getLocalStr("FIGHTFORCE_OF_ARMY"))
	label2:setString(GlobalApi:getLocalStr("FIGHTFORCE_OF_ENEMY"))
	local fightforceLabel1 = cc.LabelAtlas:_create(self.armyData.fightforce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	local fightforceLabel2 = cc.LabelAtlas:_create(self.enemyData.fightforce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0')) 
	fightforceLabel1:setScale(0.8)
	fightforceLabel2:setScale(0.8)
	fightforceLabel1:setString(self.armyData.fightforce)
	fightforceLabel2:setString(self.enemyData.fightforce)
	fightforceLabel1:setAnchorPoint(cc.p(0.5, 0.5))
	fightforceLabel2:setAnchorPoint(cc.p(0.5, 0.5))
	self.fightforceNode:addChild(fightforceLabel1)
	self.fightforceNode:addChild(fightforceLabel2)
	fightforceLabel1:setPosition(cc.p(-130, -21))
	fightforceLabel2:setPosition(cc.p(126, -21))
	self.playerHealth = {
		{ healthBar = self.fightPl:getChildByName("health_bar_1"), maxHp = 0, currentHp = 0},
		{ healthBar = self.fightPl:getChildByName("health_bar_2"), maxHp = 0, currentHp = 0}
	}
	for k, v in pairs(self.armyMap) do
		self:setPlayerHealthBar(1, v.heroObj.hp, v.heroObj.maxHp, false)
		for k2, v2 in pairs(v.soldierObjs) do
			self:setPlayerHealthBar(1, v2.hp, v2.maxHp, true)
		end
	end
	for k, v in pairs(self.enemyMap) do
		self:setPlayerHealthBar(2, v.heroObj.hp, v.heroObj.maxHp, false)
		for k2, v2 in pairs(v.soldierObjs) do
			self:setPlayerHealthBar(2, v2.hp, v2.maxHp, true)
		end
	end
	self.playerHealth[1].healthBar:setPercent(self.playerHealth[1].currentHp/self.playerHealth[1].maxHp*100)
	self.playerHealth[2].healthBar:setPercent(self.playerHealth[2].currentHp/self.playerHealth[2].maxHp*100)
end

function BattleUI:setPlayerHealthBar(guid, hp, maxHp, isSoldier)
	local ratio = isSoldier and SOLDIER_HP_RATIO or 1
	self.playerHealth[guid].currentHp = self.playerHealth[guid].currentHp + hp/ratio
	self.playerHealth[guid].maxHp = self.playerHealth[guid].maxHp + maxHp/ratio
end

function BattleUI:initCornerUI()

	-- 左上角返回按钮
	self.backBtn2 = self.root:getChildByName("back_btn")
	self.backBtn2:setPosition(cc.p(WINSIZE.width - 160, WINSIZE.height - 60))
	self.backBtn2:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.battleType == BATTLE_TYPE.LEGION_WAR then
				promptmgr:showMessageBox(GlobalApi:getLocalStr("QUIT_BATTLE_CONFIRM"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
					BattleMgr:exitBattleField()
				end)
			elseif self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER then
                MessageMgr:sendPost('cancel_fight', 'territorywar', json.encode({}), function (jsonObj)
                    local code = jsonObj.code
                    if code == 0 then
                        TerritorialWarMgr:setBattleEnd(nil,nil,nil)
                        BattleMgr:exitBattleField()
                    end
                end)
            else
				BattleMgr:exitBattleField()
			end
		end
	end)

    --布阵倒计时（领地战）
    self.embattleText = self.root:getChildByName("embattle_text")
    self.embattleTime = self.root:getChildByName("embattle_time")
    self.embattleText:setPosition(cc.p(10, WINSIZE.height - 50))
    self.embattleTime:setPosition(cc.p(195, WINSIZE.height - 50))
    self.embattleTime:setVisible(false)
    self.embattleText:setVisible(false)
    if self.battleType == BATTLE_TYPE.TERRITORALWAR_PLAYER  then
        self.embattleTime:setVisible(true)
        self.embattleText:setVisible(true)
        self.embattleCoutdown = true
        self:countDownTime()
    elseif self.battleType == BATTLE_TYPE.LEGION_WAR then
    	self.embattleTime:setVisible(true)
        self.embattleText:setVisible(true)
        self.embattleCoutdown = true
        self:countDownLegionWar()
    end

	-- 右下角开始战斗
	self.battleBtn = self.root:getChildByName("battle_btn")
	if self.battleType == BATTLE_TYPE.REPLAY then
		local battleBtnImg = self.battleBtn:getChildByName("img")
		battleBtnImg:setTexture("uires/ui/common/icon_replay.png")
	end
	self.battleBtn:setPosition(cc.p(WINSIZE.width - 60, 60))

	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function ()
		if GlobalData:getLockFormation() == 1 or BattleMgr:getTrust() then
			self:beforeFight()
		else
			self.battleBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					self:beforeFight()
				end
			end)
		end
	end)))

	-- 暂停界面
	local pauseBg = self.root:getChildByName("pause_bg")
	pauseBg:setContentSize(WINSIZE)
	pauseBg:setPosition(cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5))
	pauseBg:setVisible(false)
	pauseBg:setLocalZOrder(10)

	local bg_img1 = pauseBg:getChildByName("bg_img1")
	bg_img1:setPosition(cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5))

	local backBtn = bg_img1:getChildByName("back_btn")
	backBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:showQuitConfirm()
		end
	end)

	local backLabel = bg_img1:getChildByName("back_text")
	backLabel:setString(GlobalApi:getLocalStr("STR_QUIT"))

	local continueBtn = bg_img1:getChildByName("continue_btn")
	continueBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.battleStatus == BATTLE_STATUS.PAUSE_BY_SKILL then
				if self.runningTarget then
					cc.Director:getInstance():getActionManager():resumeTarget(self.runningTarget)
				end
			elseif not self:isBattleEnd() then
				self:continueFight()
			end
			pauseBg:setVisible(false)
		end
	end)
	local continueLabel = bg_img1:getChildByName("continue_text")
	continueLabel:setString(GlobalApi:getLocalStr("STR_CONTINUE"))

	local tx_content = bg_img1:getChildByName("tx_content")
	tx_content:setString(GlobalApi:getLocalStr("BATTLE_LEAVE"))

	local title_bg = bg_img1:getChildByName("title_bg")
	local title_tx = title_bg:getChildByName("title_tx")
	title_tx:setString(GlobalApi:getLocalStr("BATTLE_MESSAGE"))

	-- 左上角暂停
	self.pauseBtn = self.root:getChildByName("pause_btn")
	self.pauseBtn:setVisible(false)
	self.pauseBtn:setPosition(cc.p(60, WINSIZE.height - 30))
	self.pauseBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self:isBattleEnd() then
				return
			end
			if self.battleStatus == BATTLE_STATUS.PAUSE_BY_SKILL then
				if self.runningTarget then
					cc.Director:getInstance():getActionManager():pauseTarget(self.runningTarget)
				end
			else
				self:pauseFight()
			end
			pauseBg:setVisible(true)
		end
	end)
	-- 加速按钮
	self.speedBtn = self.root:getChildByName("speed_btn")
	if self.speedUp == SPEEDUP_SCALE[1] then
		self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn1.png")
	elseif self.speedUp == SPEEDUP_SCALE[2] then
		self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn2.png")
	elseif self.speedUp == SPEEDUP_SCALE[3] then
		self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn3.png")
	end
	self.speedBtn:setVisible(false)
	self.speedBtn:setPosition(cc.p(130, WINSIZE.height - 30))
	self.speedBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			if self.battleStatus == BATTLE_STATUS.FIGHTING then
				if self.speedUp == SPEEDUP_SCALE[1] then
					if self.canSpeedUp == 1 then
						promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("LIMIT_BATTLE_SPEEDUP"), self.speedUpLv, self.canSpeedUp+1), COLOR_TYPE.RED)
					else
						self.speedUp = SPEEDUP_SCALE[2]
						self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn2.png")
						cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
					end
				elseif self.speedUp == SPEEDUP_SCALE[2] then
					if self.canSpeedUp == 3 then
						self.speedUp = SPEEDUP_SCALE[3]
						self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn3.png")
					else
						self.speedUp = SPEEDUP_SCALE[1]
						self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn1.png")
						promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("LIMIT_BATTLE_SPEEDUP"), self.speedUpLv, self.canSpeedUp+1), COLOR_TYPE.RED)
					end
					cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
				elseif self.speedUp == SPEEDUP_SCALE[3] then
					self.speedUp = SPEEDUP_SCALE[1]
					self.speedBtn:loadTextureNormal("uires/ui/battle/speed_btn1.png")
					cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
				end
			end
		end
	end)
	-- 自动战斗
	self.autoBtn = self.root:getChildByName("auto_btn")
	self.autoBtn:setVisible(false)
	self.autoSelectedNode = self.autoBtn:getChildByName("selected_node")
	local autoSelectedImg = self.autoSelectedNode:getChildByName("selected_img")
	autoSelectedImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, -360)))
	self.autoLabel = self.autoBtn:getChildByName("text")
	if self.autoFlag[1] then
		self.autoSelectedNode:setVisible(true)
		self.autoLabel:setString(GlobalApi:getLocalStr("STR_CANCEL"))
	else
		self.autoSelectedNode:setVisible(false)
		self.autoLabel:setString(string.format(GlobalApi:getLocalStr("STR_AUTO_FIGHT"), "\n"))
	end
	self.autoBtn:setPosition(cc.p(WINSIZE.width - 60, 60))
	if self.battleConfig.autoFight1 == 0 then
		self.autoBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				if self.autoFlag[1] then
					self:setAutoFight(1, false)
				else
					self:setAutoFight(1, true)
				end
			end
		end)
	else
		self.autoBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
		end)
	end
	-- 跳过,仅支持战报跳过
	self.skipBtn = self.root:getChildByName("skip_btn")
	self.skipBtn:setPosition(cc.p(WINSIZE.width - 60, WINSIZE.height - 60))
	self.skipBtn:setVisible(false)
	self.skipBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local vip = UserData:getUserObj():getVip()
			local level = UserData:getUserObj():getLv()
			local skipPVPBattleVip = tonumber(GlobalApi:getGlobalValue("skipPVPBattleVip"))
			local skipPVPBattleLevel = tonumber(GlobalApi:getGlobalValue("skipPVPBattleLevel"))
			if vip >= skipPVPBattleVip or level >= skipPVPBattleLevel then
				self:skip()
			else
				promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("OPEN_AFTER_LEVEL_OR_VIP"), skipPVPBattleLevel,skipPVPBattleVip), COLOR_TYPE.RED)
			end
		end
	end)
end

function BattleUI:initExtraUI()
    -- 如果抢夺的玉璧，有合璧时间，则显示
    if self.battleType == BATTLE_TYPE.COUNTRY_JADE then
        local diffTime = self.customObj.roomData.finishTime - GlobalData:getServerTime()
        if diffTime > 0 then
            local node = cc.Node:create()
            node:setAnchorPoint(cc.p(0.5,0.5))
            self.root:addChild(node)
            local color = cc.c4b(228,191,139, 255)
            Utils:createCDLabel(node,diffTime,color,COLOROUTLINE_TYPE.BLACK,CDTXTYPE.FRONT, GlobalApi:getLocalStr('COUNTRY_JADE_DES42'),color,COLOROUTLINE_TYPE.BLACK,24,function ()
		        if diffTime <= 0 then
                    node:setVisible(false)
		        end
	        end,2)
            local width = 0
            if node:getChildByTag(9527) then
                node:getChildByTag(9527):enableShadow(cc.c4b(64,64,64, 255), cc.size(0, -1))
            end
            if node:getChildByTag(9528) then
                node:getChildByTag(9528):enableShadow(cc.c4b(64,64,64, 255), cc.size(0, -1))
            end
            node:setPosition(cc.p(WINSIZE.width/2 + 45,WINSIZE.height - 105))
            self.remainTimeTx = node
        end
    end
end 

function BattleUI:initLegionInfoImg()
	-- 兵种旗子
 	self.armyflags = {}
 	-- 兵种星级
 	self.armyStars = {}
	for i = 1, 9 do
		self.armyflags[i] = cc.Sprite:create()
		BattleHelper:setZorder(self.armyflags[i], 0, 0)
		self.armyflags[i]:setPosition(cc.p(LEGION_POS[1][i].x - 50, LEGION_POS[1][i].y + 50))
		self.bgImg:addChild(self.armyflags[i])
		if self.armyMap[i] then
			self.armyflags[i]:setTexture("uires/ui/battle/flag_" .. self.armyMap[i].legionType .. ".png")
		else
			self.armyflags[i]:setVisible(false)
		end
		local starNum = 0
		local starLv = 1
		if self.armyMap[i] and self.armyMap[i].soldierLv > 1 then
			starNum = self.armyMap[i].soldierLv%5
			starNum = starNum == 0 and 5 or starNum
			starLv = math.ceil(self.armyMap[i].soldierLv/5)
		end
		self.armyStars[i] = {}
		for j = 1, 5 do
			self.armyStars[i][j] = cc.Sprite:create()
			BattleHelper:setZorder(self.armyStars[i][j], 0, 0)
			self.armyStars[i][j]:setPosition(cc.p(LEGION_POS[1][i].x - 85, LEGION_POS[1][i].y + 5 + 15*j))
			self.bgImg:addChild(self.armyStars[i][j])
			if starNum >= j then
				self.armyStars[i][j]:setTexture("uires/ui/role/role_star_" .. starLv .. ".png")
			else
				self.armyStars[i][j]:setVisible(false)
			end
		end
	end
	for i = 1, 9 do
		self.armyflags[9 + i] = cc.Sprite:create()
		BattleHelper:setZorder(self.armyflags[9 + i], 0, 0)
		self.armyflags[9 + i]:setPosition(cc.p(LEGION_POS[2][i].x + 50, LEGION_POS[2][i].y + 50))
		self.bgImg:addChild(self.armyflags[9 + i])
		if self.enemyMap[i] then
			self.armyflags[9 + i]:setTexture("uires/ui/battle/flag_" .. self.enemyMap[i].legionType .. ".png")
		else
			self.armyflags[9 + i]:setVisible(false)
		end
		local starNum = 0
		local starLv = 1
		if self.enemyMap[i] and self.enemyMap[i].soldierLv > 1 then
			starNum = self.enemyMap[i].soldierLv%5
			starNum = starNum == 0 and 5 or starNum
			starLv = math.ceil(self.enemyMap[i].soldierLv/5)
		end
		self.armyStars[9 + i] = {}
		for j = 1, 5 do
			self.armyStars[9 + i][j] = cc.Sprite:create()
			BattleHelper:setZorder(self.armyStars[9 + i][j], 0, 0)
			self.armyStars[9 + i][j]:setPosition(cc.p(LEGION_POS[2][i].x + 80, LEGION_POS[2][i].y + 5 + 15*j))
			self.bgImg:addChild(self.armyStars[9 + i][j])
			if starNum >= j then
				self.armyStars[9 + i][j]:setTexture("uires/ui/role/role_star_" .. starLv .. ".png")
			else
				self.armyStars[9 + i][j]:setVisible(false)
			end
		end
	end
end

function BattleUI:initMgr()
	if self.customObj.pvp then
		BattleHelper:init(true)
	else
		BattleHelper:init(self.battleConfig.enableSpecial > 0)
	end
	BulletMgr:init(self.bgImg)
	EffectMgr:init(self.bgImg)
	AttackEffectMgr:init()
	BuffAniMgr:init()
end

function BattleUI:clear()
	BulletMgr:clear()
	EffectMgr:clear()
	AttackEffectMgr:clear()
	BuffAniMgr:clear()
	BattleHelper:clear()
	for k, v in ipairs(self.damageLabelPools) do
		for k2, v2 in ipairs(v.arr) do
			v2[2]:release()
		end
	end
	self.damageLabelPools = nil
end

function BattleUI:initLegion(callback)
	if self.customObj.rand1 then
		math.randomseed(self.customObj.rand1)
	end
	local co = coroutine.create(function ()
		local index = 0
		for k, v in ipairs(self.armyData.legionArr) do
			index = index + 1
			local legion = self:createLegion(self.armyData.guid, v, true)
			self.armyMap[v.info.pos] = legion
			table.insert(self.armyArr[1], legion)
			self.legionCount[1] = self.legionCount[1] + 1
			self.loadingUI:setPercent(70 + index)
			coroutine.yield()
		end
		for k2, v2 in ipairs(self.enemyData.legionArr) do
			index = index + 1
			local enemyLegion = self:createLegion(self.enemyData.guid, v2, true)
			table.insert(self.armyArr[2], enemyLegion)
			self.enemyMap[v2.info.pos] = enemyLegion
			self.legionCount[2] = self.legionCount[2] + 1
			self.loadingUI:setPercent(70 + index)
			coroutine.yield()
		end
		BulletMgr:preloadBullet()
		EffectMgr:preloadAni()
		AttackEffectMgr:preloadAni()
		BuffAniMgr:preloadAni()
	end)
	self.root:scheduleUpdateWithPriorityLua(function (dt)
		if not coroutine.resume(co) then
			if self.customObj.rand1 then
				math.randomseed(os.time())
			end
			self.root:unscheduleUpdate()
			self:checkFormation()
			callback()
		end
	end, 0)
end

function BattleUI:createLegion(guid, data, isFirstWave)
	return ClassBattleLegion.new(guid, data, isFirstWave, self)
end

-- 检测阵型
function BattleUI:checkFormation()
	-- 特殊处理引导布阵
	if self.embattleFinger then
		self.embattleFinger:removeFromParent()
		self.embattleFinger = nil
	end
	-- 特殊处理第一关精英
	if self.battleType == BATTLE_TYPE.NORMAL and self.customObj.cityId == 1 then
		local star1 = MapData.data[1]:getStar(1)
		local star2 = MapData.data[1]:getStar(2)
		if star1 > 0 and star2 <= 0 then
			return
		end
	end
	for i = 1, 3 do
		local leftLegoin
		local rightLegion
		for j = i + 6, i, -3 do
			if self.armyMap[j] then
				leftLegoin = self.armyMap[j]
			end
			if self.enemyMap[j] then
				rightLegion = self.enemyMap[j]
			end
		end
		if leftLegoin and rightLegion then
			local actionName
			if FORMATION_CORRECTION[leftLegoin.legionType][rightLegion.legionType] > 1 then
				actionName = "green"
			elseif FORMATION_CORRECTION[leftLegoin.legionType][rightLegion.legionType] < 1 then
				actionName = "red"
			end
			if actionName then
				if not self.battleCounterArr[i]:isVisible() or actionName ~= self.battleCounterArr[i]:getAnimation():getCurrentMovementID() then
					self.battleCounterArr[i]:setVisible(true)
					self.battleCounterArr[i]:getAnimation():play(actionName, -1, 1)
				end
			else
				self.battleCounterArr[i]:setVisible(false)
			end
		else
			self.battleCounterArr[i]:setVisible(false)
		end
	end
end

function BattleUI:pauseFight()
	cc.Director:getInstance():getScheduler():setTimeScale(1/TIMESCALE)
	self.runningTargets = cc.Director:getInstance():getActionManager():pauseAllRunningActions()
	UIManager:setTouchEffectSpeed(TIMESCALE)
	self.battleStatus = BATTLE_STATUS.PAUSE
end

function BattleUI:continueFight()
	cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
	if self.runningTargets then
		cc.Director:getInstance():getActionManager():resumeTargets(self.runningTargets)
		self.runningTargets = nil
	end
	UIManager:setTouchEffectSpeed(1)
	self.battleStatus = BATTLE_STATUS.FIGHTING
end

function BattleUI:countDownTime()

    local conf = GameData:getConfData('dfbasepara')
    local diffTime = tonumber(conf['combatLockTime'].value[1])

	local node = cc.Node:create()
	node:setTag(9527)		 
    local size = self.embattleTime:getContentSize()
    node:setPosition(cc.p(0,size.height/2))
	self.embattleTime:removeChildByTag(9527)
	self.embattleTime:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK,'',cc.c3b(255,255,255),cc.c4b(0,0,0,255),20,function ()
		self.embattleTime:removeAllChildren()
        if self.embattleCoutdown == true then
             MessageMgr:sendPost('cancel_fight', 'territorywar', json.encode({}), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    TerritorialWarMgr:setBattleEnd(3,nil,nil)
                    BattleMgr:exitBattleField()
                end
            end)
        end        
	end)
end

function BattleUI:countDownLegionWar()
	local conf = GameData:getConfData('legion')
    local diffTime = tonumber(conf['legionWarCombatLockTime'].value)
	local node = cc.Node:create()
	node:setTag(9527)		 
    local size = self.embattleTime:getContentSize()
    node:setPosition(cc.p(0,size.height/2))
	self.embattleTime:removeChildByTag(9527)
	self.embattleTime:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK,'',cc.c3b(255,255,255),cc.c4b(0,0,0,255),20,function ()
		self.embattleTime:removeAllChildren()
		---时间到了直接开始战斗    
		if self.embattleCoutdown == true then
			self:beforeFight()
		end
	end)
end

function BattleUI:beforeFight()
	if RoleData:checkAttribute() then
		GlobalApi:kickBecauseCheat()
		return
	end
	BattleMgr:initLegionDie()
	self.fightforceNode:setVisible(false)
	self.counterBtn:setVisible(false)
	if self.battleBtnHand then
		self.battleBtnHand:removeFromParent()
	end
	self.battleBtn:setVisible(false)
	self.backBtn2:setVisible(false)
    self.embattleTime:setVisible(false)
    self.embattleText:setVisible(false)
    self.embattleCoutdown = false
	if self.pedestal then
		self.pedestal:removeFromParent()
		self.pedestal = nil
	end
	if self.bosssign then
		self.bosssign:removeFromParent()
		self.bosssign = nil
	end
	for k, v in ipairs(self.pedestalArr) do
		v:removeFromParent()
	end
	for k, v in ipairs(self.battleCounterArr) do
		v:removeFromParent()
	end
	for k, v in ipairs(self.armyflags) do
		v:removeFromParent()
	end
	for k, v in ipairs(self.armyStars) do
		for k2, v2 in ipairs(v) do
			v2:removeFromParent()
		end
	end
	self.pedestalArr = nil
	self.battleCounterArr = nil
	self.armyflags = nil
	self.armyStars = nil
	-- for k, v in pairs(self.playerSkillStatusArr[1]) do
	-- 	v.flag:setVisible(false)
	-- end
	self:showBattleStartAnimation()
end

function BattleUI:sendMessageBeforeFight()
	local formation = {0,0,0,0,0,0,0,0,0}
	for k, v in pairs(self.armyMap) do
		if not v.legionInfo.isMercenary then
			formation[v.legionInfo.rolePos] = k
		end
	end
	if self.battleType == BATTLE_TYPE.NORMAL 
		or self.battleType == BATTLE_TYPE.COMBAT 
		or self.battleType == BATTLE_TYPE.LORD then
		UserData:getUserObj():setFormation(formation)
		local args = {
			type = self.customObj.difficulty,
			id = self.customObj.cityId,
			process = self.customObj.process,
		}
		MessageMgr:sendPost("before_fight", "battle", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				-- 特殊处理引导布阵
				if self.embattleFinger then
					self.embattleFinger:removeFromParent()
					self.embattleFinger = nil
				end
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.TOWER then -- 爬塔
		UserData:getUserObj():setFormation(formation)
		MessageMgr:sendPost("before_fight", "tower", "{}", function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif 	self.battleType == BATTLE_TYPE.TRIAL then
		UserData:getUserObj():setFormation(formation)
		local args = {
			target = self.customObj.target
		}
		MessageMgr:sendPost("trial_before_fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
    elseif 	self.battleType == BATTLE_TYPE.NEW_LEGION_TRIAL then
		UserData:getUserObj():setFormation(formation)
		local args = {
			target = self.customObj.target,
            index = self.customObj.index
		}
		MessageMgr:sendPost("trial_adventure_before_fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif 	self.battleType == BATTLE_TYPE.LEGION then
		UserData:getUserObj():setFormation(formation)
		local args = {
			target = self.customObj.target
		}
		MessageMgr:sendPost("before_fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			elseif code == 111 then
				promptmgr:showMessageBox(GlobalApi:getLocalStr("FRIENDS_MSG_DESC_13"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)				
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR1"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif 	self.battleType == BATTLE_TYPE.GUARD then
		UserData:getUserObj():setFormation(formation)
		local args = {
			id = self.customObj.id,
			type = self.customObj.type,
			target = self.customObj.target
		}
		MessageMgr:sendPost("before_fight", "guard", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.DIGGING then
		UserData:getUserObj():setFormation(formation)
		local args = {
			x = self.customObj.x,
			y = self.customObj.y
		}
		MessageMgr:sendPost("before_fight", "digging", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			end
		end)
	-- elseif 	self.battleType == BATTLE_TYPE.COUNTRY_WAR then
	-- 	UserData:getUserObj():setFormation(formation)
	-- 	local args = {
	-- 		city_id = self.customObj.city_id,
	-- 		enemy_uid = self.customObj.enemy_uid,
	-- 	}
	-- 	MessageMgr:sendPost("before_fight", "countrywar", json.encode(args), function (jsonObj)
	-- 		local code = jsonObj.code
	-- 		if code == 0 then
	-- 			self.verifyObj.pos = jsonObj.data.rand_pos or 1
	-- 			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
	-- 			self:battleStart()
	-- 		else
	-- 			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
	-- 				BattleMgr:exitBattleField()
	-- 			end)
	-- 		end
	-- 	end)
	-- elseif 	self.battleType == BATTLE_TYPE.WORLDWAR_1 then
	-- 	UserData:getUserObj():setFormation(formation)
	-- 	local args = {
	-- 		enemy = self.customObj.challengeUid
	-- 	}
	-- 	MessageMgr:sendPost("before_fight", "worldwar", json.encode(args), function (jsonObj)
	-- 		local code = jsonObj.code
	-- 		if code == 0 then
	-- 			self.verifyObj.pos = jsonObj.data.rand_pos or 1
	-- 			self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
	-- 			self:battleStart()
	-- 		else
	-- 			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
	-- 				BattleMgr:exitBattleField()
	-- 			end)
	-- 		end
	-- 	end)

    elseif self.battleType == BATTLE_TYPE.COUNTRY_JADE then
        --合璧剩余时间不足2分钟时，玩家点击掠夺提示，前端判断
        if self.remainTimeTx and self.remainTimeTx:getChildByTag(9527) and self.remainTimeTx:getChildByTag(9527).time then
            if CountryJadeMgr:judgeJadeIsCompleteByRob(self.remainTimeTx:getChildByTag(9527).time) then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES50'), COLOR_TYPE.RED)
                return
            end
        end

        UserData:getUserObj():setFormation(formation)
		local args = {
			country = self.customObj.country,
			roomId = self.customObj.roomId
		}
		MessageMgr:sendPost("before_fight", "country_jade", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.LEGION_WAR then
        UserData:getUserObj():setFormation(formation)
		local args = {
			city = self.customObj.city,
			arm = self.customObj.arm
		}
		MessageMgr:sendPost("before_fight", "legionwar", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
    elseif self.battleType == BATTLE_TYPE.TERRITORALWAL_MONSTER then
        local args = {
			cellId = self.customObj.cellId
		}
        UserData:getUserObj():setFormation(formation)
        MessageMgr:sendPost("before_fight_monster", "territorywar", json.encode(args), function (jsonObj)
        	local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.INFINITE_BATTLE_BOSS then
        UserData:getUserObj():setFormation(formation)
		MessageMgr:sendPost("challenge_before", "unlimited", "{}", function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.INFINITE_BATTLE then
		UserData:getUserObj():setFormation(formation)
		local args = {
			id = self.customObj.chapterId,
			cityId = self.customObj.cityId,
			progress = self.customObj.progress,
			type = self.customObj.type,
		}
		MessageMgr:sendPost("before_fight", "unlimited", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
				self.verifyObj.pos = jsonObj.data.rand_pos or 1
				self.verifyObj.attrs = jsonObj.data.rand_attrs or {}
				self:battleStart()
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	else
		self:battleStart()
	end
end

function BattleUI:generateVerifyMD5()
	local roleObj = RoleData:getRoleByPos(self.verifyObj.pos)
	local heroAtts = RoleData:getPosAttByPos(roleObj)
	local sigStr = ""	
	for k, v in ipairs(self.verifyObj.attrs) do
		sigStr = sigStr .. heroAtts[v] .. ":"
	end
	sigStr = sigStr .. "battle|"
	return xx.Utils:Get():generateBattleVerifyMD5(sigStr)
end

function BattleUI:sendMessageAfterFight(isWin)
	if self.battleType == BATTLE_TYPE.NORMAL then
		local starNum = isWin and self.starNum or 0
		local roleMap = RoleData:getRoleMap()
		local heroTotalLv = 0
		for k, heroObj in pairs(roleMap) do
			heroTotalLv = heroTotalLv + heroObj:getLevel()
		end
		local args = {
			type = self.customObj.difficulty,
			id = self.customObj.cityId,
			star = starNum,
			sig = self:generateVerifyMD5(),
			process = self.customObj.process,
			ff = self.armyData.fightforce,
			levels = heroTotalLv
		}
		MessageMgr:sendPost("fight", "battle", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				if jsonObj.data.costs then
					GlobalApi:parseAwardData(jsonObj.data.costs)
				end
				if isWin then
					local cityData = MapData.data[self.customObj.cityId]
					local dragon = cityData:getDragon()
					if self.customObj.process then
						local pformation = cityData:getPformation1()
						if self.customObj.difficulty == 1 then
							MapData.cityProcess = MapData.cityProcess + 1
						end
					else
						cityData:addTimes(self.customObj.difficulty, 1)
						local oldStar = cityData:getStar(self.customObj.difficulty)
						if starNum > oldStar then
							cityData:setStar(starNum, self.customObj.difficulty)
						end
						if self.customObj.difficulty == 1 and oldStar <= 0 then
							MapData.cityProcess = 0
							if dragon > 0 then
								local treasureInfo = UserData:getUserObj():getTreasure()
								treasureInfo.id = dragon
								treasureInfo.active = 0
								UserData:getUserObj():setTreasure(treasureInfo)
								RoleData:updateDragonMap()
							end
						end
					end
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.LORD then
		local starNum = isWin and self.starNum or 0
		local args = {
			type = self.customObj.difficulty,
			id = self.customObj.cityId,
			star = starNum,
			sig = self:generateVerifyMD5()
		}
		MessageMgr:sendPost("fight", "battle", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.TOWER then
		local starNum = isWin and self.starNum or 0
		local roleMap = RoleData:getRoleMap()
		local heroTotalLv = 0
		for k, heroObj in pairs(roleMap) do
			heroTotalLv = heroTotalLv + heroObj:getLevel()
		end

        if isWin == true and self.customObj.cur_room == 3 then
            TowerMgr:setTowerShowAttReward(true)
        end

		local args = {
			star = starNum,
			sig = self:generateVerifyMD5(),
			ff = self.armyData.fightforce,
			levels = heroTotalLv
		}
		MessageMgr:sendPost("fight", "tower", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
				local specialAwardDatas = {}
                specialAwardDatas.battleType = BATTLE_TYPE.TOWER
                specialAwardDatas.cur_floor = self.customObj.cur_floor
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,specialAwardDatas,kingLvUpData)
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.TRIAL then
		--local starNum = isWin and self.starNum or 0
        local isWin = isWin
        local starNum = 0
        local costTime = math.floor(self.time)
        if costTime >= 0 and costTime <= 60 then
            starNum = 3
        elseif costTime > 60 and costTime <= 90 then
            starNum = 2
        elseif costTime >= 91 then
            starNum = 1
        end
        if isWin == false then
            starNum = 0
        end

		local args = {
			star = starNum,
			target = self.customObj.target,
			sig = self:generateVerifyMD5()
		}
		MessageMgr:sendPost("trial_fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)

				local legioninfo = UserData:getUserObj():getLegionInfo()
				legioninfo.trial_count = legioninfo.trial_count + 1
				--legioninfo.trial_stars = legioninfo.trial_stars + starNum
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)	
			end
		end)
    elseif self.battleType == BATTLE_TYPE.NEW_LEGION_TRIAL then
		--local starNum = isWin and self.starNum or 0
        local isWin = isWin
        local starNum = 0
        local costTime = math.floor(self.time)
        if costTime >= 0 and costTime <= 60 then
            starNum = 3
        elseif costTime > 60 and costTime <= 90 then
            starNum = 2
        elseif costTime >= 91 then
            starNum = 1
        end
        if isWin == false then
            starNum = 0
        end

		local args = {
			star = starNum,
			target = self.customObj.target,
			sig = self:generateVerifyMD5(),
            index = self.customObj.index
		}
		MessageMgr:sendPost("trial_adventure_fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)	
			end
		end)
	elseif self.battleType == BATTLE_TYPE.LEGION then
		local starNum = isWin and self.starNum or 1
		local numtab = {}
		for k, v in pairs(self.enemyMap) do
			local obj = {
				pos = v.pos,
				hurt = v.heroObj:getHurtCount()
			}
			table.insert(numtab, obj)
		end
		table.sort(numtab, function (a, b)
			return a.pos < b.pos
		end)
		local hurtArr = {}
		local posArr = {}
		for k, v in ipairs(numtab) do
			table.insert(hurtArr, v.hurt)
			table.insert(posArr, v.pos)
		end
		local roleMap = RoleData:getRoleMap()
		local heroTotalLv = 0
		for k, heroObj in pairs(roleMap) do
			heroTotalLv = heroTotalLv + heroObj:getLevel()
		end
		local args = {
			pos = posArr,
			damage = hurtArr,
			sig = self:generateVerifyMD5(),
			ff = self.armyData.fightforce,
			levels = heroTotalLv
		}
		MessageMgr:sendPost("fight", "legion", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(true, displayAwards, starNum,nil,kingLvUpData)

				local legioninfo = UserData:getUserObj():getLegionInfo()
				legioninfo.copy_count =  legioninfo.copy_count + 1
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR1"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.GUARD then
		local starNum = isWin and self.starNum or 0
		local args = {
			id = self.customObj.id,
			type = self.customObj.type,
			star = starNum,
			target = self.customObj.target,
			sig = self:generateVerifyMD5()
		}
		MessageMgr:sendPost("fight", "guard", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)

			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.DIGGING then
		local starNum = isWin and self.starNum or 0
		local args = {
			x = self.customObj.x,
			y = self.customObj.y,
			star = starNum,
			sig = self:generateVerifyMD5()
		}
		MessageMgr:sendPost("fight", "digging", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end		
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,nil,kingLvUpData)
			end
		end)
    elseif self.battleType == BATTLE_TYPE.COUNTRY_JADE then
        local starNum = isWin and self.starNum or 0
		local args = {
			country = self.customObj.country,
			roomId = self.customObj.roomId,
            star = starNum,
			sig = self:generateVerifyMD5()
		}
		MessageMgr:sendPost("fight", "country_jade", json.encode(args), function (jsonObj)
			local code = jsonObj.code
			if code == 0 then
                local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
                local specialAwardIcon
                local user = jsonObj.data.user
                local specialAwardDatas = nil
                if user and user.jade and user.jade ~= 0 then   -- 失败user为空
                    specialAwardDatas = {}
                    specialAwardDatas.battleType = BATTLE_TYPE.COUNTRY_JADE
                    specialAwardDatas.icon = GameData:getConfData('countryjade')[tonumber(user.jade)].icon
                    specialAwardDatas.pos = GameData:getConfData('countryjade')[tonumber(user.jade)].subType
                    specialAwardDatas.type = GameData:getConfData('countryjade')[tonumber(user.jade)].type
                end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum,specialAwardDatas,kingLvUpData)
			else
				promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
			end
		end)
	-- elseif self.battleType == BATTLE_TYPE.LEGION_WAR then
 --        local starNum = isWin and self.starNum or 0
	-- 	local args = {
	-- 		city = self.customObj.city,
	-- 		arm = self.customObj.arm,
	-- 		star = starNum,
	-- 	}
	-- 	MessageMgr:sendPost("fight", "legionwar", json.encode(args), function (jsonObj)
	-- 		local code = jsonObj.code
	-- 		if code == 0 then
 --                local lastLv = UserData:getUserObj():getLv()
	-- 			GlobalApi:parseAwardData(jsonObj.data.awards)
	-- 			local costs = jsonObj.data.costs
	-- 			if costs then
	-- 				GlobalApi:parseAwardData(costs)
	-- 			end
	-- 			local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
 --                local kingLvUpData = {}
 --                kingLvUpData.lastLv = lastLv
 --                kingLvUpData.nowLv = UserData:getUserObj():getLv()
	-- 			BattleMgr:showBattleResult(isWin, displayAwards, starNum,specialAwardIcon,kingLvUpData)
	-- 		else
	-- 			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
	-- 				BattleMgr:exitBattleField()
	-- 			end)
	-- 		end
	-- 	end)
    elseif self.battleType == BATTLE_TYPE.TERRITORALWAL_MONSTER then                --领地战攻击怪物

        --计算耐力值
        local winStayingPower = 0
        local starNum = isWin and self.starNum or 0
        if isWin == true then
            winStayingPower = self.customObj.stayingPower
            TerritorialWarMgr:setBattleEnd(nil,nil,nil)
        else
            local cost = math.floor((self.playerHealth[2].maxHp-self.playerHealth[2].currentHp)/self.playerHealth[2].maxHp*100)
            local costPower = math.min(cost,self.customObj.stayingPower)
            winStayingPower = self.customObj.stayingPower-costPower
            TerritorialWarMgr:setBattleEnd(1,isWin,costPower)
        end

		local args = {
			cellId = self.customObj.cellId,
            star = starNum,
            stayingPower = winStayingPower,
		}

		MessageMgr:sendPost("fight_monster", "territorywar", json.encode(args), function (jsonObj)
            local code = jsonObj.code
            if code == 0 then
                GlobalApi:parseAwardData(jsonObj.data.awards)
                local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
                BattleMgr:showBattleResult(isWin,displayAwards,starNum)
            else
				 promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
					BattleMgr:exitBattleField()
				end)
            end
        end)
	elseif self.battleType == BATTLE_TYPE.INFINITE_BATTLE then
		local starNum = isWin and self.starNum or 0
		local args = {
			id = self.customObj.chapterId,
			cityId = self.customObj.cityId,
			progress = self.customObj.progress,
			type = self.customObj.type,
			star = starNum,
		}
		MessageMgr:sendPost('fight','unlimited',json.encode(args),function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				GlobalApi:parseAwardData(data.awards)
				local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				if isWin then
				 	if self.customObj.type == 0 then -- 主线
						InfiniteBattleMgr:updateInfiniteData(self.customObj.chapterId, self.customObj.cityId, self.customObj.progress)
						-- 更新星星红点数据
						local itsectionboxConf = GameData:getConfData("itsectionbox")[self.customObj.chapterId]
		                local infiniteStarNum, infiniteAllNum = InfiniteBattleMgr:getStarByChapterId(self.customObj.chapterId)
		                local canGet = false
		                for i,v in ipairs(itsectionboxConf) do
		                    if InfiniteBattleMgr.chapters[self.customObj.chapterId].stars[tostring(i)] == nil and infiniteStarNum >= v.needStar then -- 可领取
		                        canGet = true
		                        break
		                    end
		                end
		                if canGet then
		                    local infinite = UserData:getUserObj():getInfinite()
		                    if infinite.tip and infinite.tip.stars then
		                    	local needUpdate = true
		                        for k, v in ipairs(infinite.tip.stars) do
		                            if v == self.customObj.chapterId then
		                            	needUpdate = false
		                                break
		                            end
		                        end
		                        if needUpdate then
		                        	table.insert(infinite.tip.stars, self.customObj.chapterId)
		                        end
		                    end
		                end
		            else
		            	InfiniteBattleMgr:updateInfiniteBranchProgress(self.customObj.chapterId, self.customObj.cityId, self.customObj.progress)
		            end
		            -- 更新宝箱和boss增强道具的红点数据
		            InfiniteBattleMgr:checkBossBoxRedPointStatus(self.customObj.chapterId)
				end
				local displayAwards = DisplayData:getDisplayObjs(data.awards)
				BattleMgr:showBattleResult(isWin, displayAwards,starNum)
			end
		end)
	elseif self.battleType == BATTLE_TYPE.INFINITE_BATTLE_BOSS then
		local starNum = isWin and self.starNum or 0
		local args = {
			star = starNum,
			type = 2
		}
		MessageMgr:sendPost("explore", "unlimited", json.encode(args), function (jsonObj)
			if jsonObj.code == 0 then
				local lastLv = UserData:getUserObj():getLv()
				GlobalApi:parseAwardData(jsonObj.data.awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				if isWin then
					local infiniteData = UserData:getUserObj():getInfinite()
					infiniteData.boss_sweep = jsonObj.data.boss_sweep
				end
				local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
				local kingLvUpData = {}
                kingLvUpData.lastLv = lastLv
                kingLvUpData.nowLv = UserData:getUserObj():getLv()
				BattleMgr:showBattleResult(isWin, displayAwards, starNum, nil, kingLvUpData)
			end
		end)
	else
		local starNum = isWin and self.starNum or 0
		BattleMgr:showBattleResult(isWin, {}, starNum)
	end
end

function BattleUI:showBattleStartAnimation()
	local overFlag = false
	local startAni = ccui.ImageView:create('uires/ui/battle/battle_001.png')
	startAni:setVisible(false)
	startAni:setPosition(cc.p(WINSIZE.width/2, WINSIZE.height/2 + 50))
	self.root:addChild(startAni)
	local act = cc.Sequence:create(cc.DelayTime:create(0.5), 
				cc.CallFunc:create(function ()
					startAni:setVisible(true)
					AudioMgr.playEffect("media/effect/battle_start.mp3", false)
					self.fightPl:setVisible(true)
					local moveUpAct = cc.EaseBounceOut:create(cc.MoveBy:create(0.5, cc.p(0, -65)))
					self.fightPl:runAction(moveUpAct)
				end),
				-- cc.DelayTime:create(1.5), 
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

function BattleUI:battleStart()
	self.pauseBtn:setVisible(true)
	self.skillPointImg:setVisible(true)
	if self.battleConfig.autoFight1 ~= 2 then
		self.autoBtn:setVisible(true)
	end
	self.speedBtn:setVisible(true)
    self.embattleTime:setVisible(false)
    self.embattleText:setVisible(false)
	if self.canSpeedUp == 1 then
		local tipsTx = ccui.Text:create()
		tipsTx:setName("tips_tx")
		tipsTx:setFontName("font/gamefont.ttf")
		tipsTx:setFontSize(18)
		tipsTx:setColor(COLOR_TYPE.ORANGE)
		tipsTx:enableOutline(COLOR_TYPE.BLACK, 1)
		tipsTx:setString(string.format(GlobalApi:getLocalStr("LIMIT_BATTLE_SPEEDUP"), self.speedUpLv, self.canSpeedUp+1))
		self.root:addChild(tipsTx)
		tipsTx:setPosition(cc.p(130, WINSIZE.height - 65))
	elseif self.canSpeedUp == 2 then
		local tipsTx = ccui.Text:create()
		tipsTx:setName("tips_tx")
		tipsTx:setFontName("font/gamefont.ttf")
		tipsTx:setFontSize(18)
		tipsTx:setColor(COLOR_TYPE.ORANGE)
		tipsTx:enableOutline(COLOR_TYPE.BLACK, 1)
		tipsTx:setString(string.format(GlobalApi:getLocalStr("LIMIT_BATTLE_SPEEDUP"), self.speedUpLv, self.canSpeedUp+1))
		self.root:addChild(tipsTx)
		tipsTx:setPosition(cc.p(130, WINSIZE.height - 65))
	end
	self:prepare()
	self.battleStatus = BATTLE_STATUS.FIGHTING
	self.root:scheduleUpdateWithPriorityLua(function (dt)
		self:update(dt)
	end, 0)
	xx.Utils:Get():autoSetZOrder(self.bgImg, 0.1, "autoSetZOrder")
	cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp)

	-- 特殊处理, 第1关精英关卡和第4关引导君主技能
	if self.battleType == BATTLE_TYPE.NORMAL then
		if self.customObj.cityId == 1 then
			if GuideMgr:isRunning() then
				local star1 = MapData.data[self.customObj.cityId]:getStar(1)
				local star2 = MapData.data[self.customObj.cityId]:getStar(2)
				if star1 > 0 and star2 <= 0 then
					self.pauseBtn:setVisible(false)
				end
			end
		end
    elseif self.battleType == BATTLE_TYPE.COUNTRY_JADE then   -- 抢夺玉璧把暂停按钮去掉
        self.pauseBtn:setVisible(false)
	end
end

function BattleUI:prepare()
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
end

function BattleUI:battleEnd(isWin, timeoutFlag)
	if self:isBattleEnd() then
		return
	end
	self.speedBtn:setTouchEnabled(false)
	self.pauseBtn:setTouchEnabled(false)
	self.battleStatus = BATTLE_STATUS.OVER
	for k, v in pairs(self.dragonArr) do
		if v.dragon then
			v.dragon:setVisible(false)
			v.rangeImg:setVisible(false)
			v.visible = false
		end
	end
	if isWin then
		for k, v in pairs(self.armyMap) do
			v:playWin()
		end
		for k2, v2 in pairs(self.enemyMap) do
			v2:playLose()
		end
	else
		for k, v in pairs(self.armyMap) do
			v:playLose()
		end
		for k2, v2 in pairs(self.enemyMap) do
			v2:playWin()
		end
	end
	--计算星星
	self:calculateStar()
	self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.CallFunc:create(function ()
		if RoleData:checkAttribute() then
			GlobalApi:kickBecauseCheat()
		else
			self:sendMessageAfterFight(isWin)
		end
	end)))

	if timeoutFlag then
		cc.Director:getInstance():getScheduler():setTimeScale(1)
		UIManager:setTouchEffectSpeed(1)
	else
		self.bgImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.22), cc.CallFunc:create(function ()
			cc.Director:getInstance():getScheduler():setTimeScale(1)
			UIManager:setTouchEffectSpeed(1)
		end)))
		cc.Director:getInstance():getScheduler():setTimeScale(0.1)
	end
end

function BattleUI:calculateStar()
	local dieLegionNum = self.dieLegionNum[1]
	if dieLegionNum == 0 then
		--跳过战斗时特殊处理,计算死亡英雄
		dieLegionNum = BattleMgr:getLegionDie()[1]
	end
	self.starNum = self.starNum - dieLegionNum
	if self.starNum < 1 then
		self.starNum = 1
	end

	--跳过战斗时特殊处理,显示死亡英雄头像
	local dieAnimations = BattleMgr:getLegionDieAnimation()
	for k,v in ipairs(dieAnimations) do
		local add = true
		for i=1,#self.dies[1] do
			if v[1] == self.dies[1][i] and v[2] == self.dies[2][i] then
				add = false
			end
		end

		if add then
			self:addKillAnimation(v[1], v[2], v[3], v[4], true)
		end
	end
end

function BattleUI:isBattleEnd()
	return self.battleStatus == BATTLE_STATUS.OVER
end

-- 屏幕震动
function BattleUI:runShakeAction(time, strengthx, strengthy)
	if self.shakeFalg then
		return
	end
	self.battleBgPl:runAction(cc.Sequence:create(cc.Shake:create(time, strengthx, strengthy), cc.CallFunc:create(function ()
		self.shakeFalg = false
		self.battleBgPl:setPosition(cc.p(0, 0))
	end)))
	self.shakeFalg = true
end

-- 使用君主技能
function BattleUI:usePlayerSkill(guid, index, pos)
	self.playerSkillPoints[guid] = self.playerSkillPoints[guid] - self.playerSkillStatusArr[guid][index].needPoint
	self.playerSkillStatusArr[guid][index].time = self.time + 5
	self.playerSkillStatusArr[guid][index].useTimes = self.playerSkillStatusArr[guid][index].useTimes + 1
	self.playerSkillStatusArr[guid][index].needPoint = self.playerSkillStatusArr[guid][index].basePoint + self.playerSkillStatusArr[guid][index].basePoint*(self.playerSkillStatusArr[guid][index].useTimes)/2
	if guid == 1 then
		self.playerSkillStatusArr[1][index].mask:setVisible(true)
		self.playerSkillStatusArr[1][index].label:setString("5")
		self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
		for k, v in ipairs(self.playerSkillStatusArr[1]) do
			if self.playerSkillPoints[1] < v.needPoint then
				ShaderMgr:setGrayForSprite(v.dragon)
				v.disable = true
			end
		end
		self.playerSkillStatusArr[1][index].pointLabel:setString(tostring(self.playerSkillStatusArr[1][index].needPoint))
	else
		for k, v in ipairs(self.playerSkillStatusArr[2]) do
			if self.playerSkillPoints[2] < v.needPoint then
				v.disable = true
			end
		end
	end
	local info = self.playerSkillArr[guid][index].info
	local skill = self.playerSkillArr[guid][index].baseSkill
	local size = self.bgImg:getContentSize()
	local effectInfo
	if pos then
		local convertPos = self.bgImg:convertToNodeSpace(pos)
		if info.searchId2 > 0 then
			effectInfo = PlayerSkillAI:useSkillWithPos(info.searchId2, guid, self.armyArr, size, convertPos)
		else
			effectInfo = {
				pos = convertPos
			}
		end
	else
		effectInfo = PlayerSkillAI:useSkillWithoutPos(info.searchId, guid, self.armyArr, size)
	end
	if effectInfo then
		if guid == 1 then
			self:pauseByPlayerSkill()
			local runningTargets = cc.Director:getInstance():getActionManager():pauseAllRunningActions()
			local sprite1 = cc.Sprite:create("uires/ui/battle/" .. info.skillImg .. ".png")
			sprite1:setLocalZOrder(1)
			self.runningTarget = sprite1
			self.root:addChild(sprite1)
			sprite1:setPosition(cc.p(-200, WINSIZE.height/2))
			local sprite2 = cc.Sprite:create("uires/ui/battle/" .. info.skillImg .. "1.png")
			sprite1:addChild(sprite2)
			sprite2:setAnchorPoint(cc.p(0, 0))
			AudioMgr.playEffect("media/effect/playerskill_cast.mp3", false)	-- 播放cast音效
			sprite2:runAction(cc.Sequence:create(cc.DelayTime:create(0.1/TIMESCALE), cc.FadeOut:create(0.1/TIMESCALE)))
			sprite1:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveTo:create(0.8/TIMESCALE, cc.p(200, WINSIZE.height/2)), 20), cc.Spawn:create(cc.MoveTo:create(0.15/TIMESCALE, cc.p(WINSIZE.width/2, WINSIZE.height/2)), cc.FadeOut:create(0.15/TIMESCALE)), cc.CallFunc:create(function ()
				self.runningTarget = nil
				cc.Director:getInstance():getActionManager():resumeTargets(runningTargets)
				self:resumeByPlayerSkill()
				sprite1:removeFromParent()
				local changeEquipObj = GlobalApi:getChangeEquipState(self.playerSkillArr[guid][index].level)
				PlayerSkillAI:playSkillAnimation(guid, effectInfo, skill, info, self, size, changeEquipObj)
			end)))
		else
			local changeEquipObj = GlobalApi:getChangeEquipState(self.playerSkillArr[guid][index].level)
			PlayerSkillAI:playSkillAnimation(guid, effectInfo, skill, info, self, size, changeEquipObj)
		end
	end
end

-- 君主技能动作
function BattleUI:runSkillAction(action)
	self.skillListNode:runAction(action)
end

-- 停止君主技能动作
function BattleUI:stopSkillAction(action)
	self.skillListNode:stopAction(action)
end

-- 设置战场总血条
function BattleUI:addPlayerHealth(guid, value, soldierType)
	local ratio = soldierType == 1 and 1 or SOLDIER_HP_RATIO
	self.playerHealth[guid].currentHp = self.playerHealth[guid].currentHp + value/ratio
	self.playerHealth[guid].healthBar:setPercent(self.playerHealth[guid].currentHp/self.playerHealth[guid].maxHp*100)
end

-- 伤害统计
function BattleUI:addDamageCount(num, guid, soldierType)
	if num > 0 then
		self.damageCount[guid][1] = self.damageCount[guid][1] + num
	else
		self.damageCount[guid][2] = self.damageCount[guid][2] - num
	end
end

function BattleUI:getDamageCount()
	return self.damageCount
end

-- 受伤统计
function BattleUI:addHurtCount(num, guid, soldierType)
	self.hurtCount[guid] = self.hurtCount[guid] - num
end

function BattleUI:getDamageInfo()
	local armyArr = self.armyArr[1]
	local enemyArr = self.armyArr[2]
	local damageArr = {}
	for k, v in ipairs(armyArr) do
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
	for k, v in ipairs(enemyArr) do
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

function BattleUI:addHandleWhenSoldierDie(owner, func)
	if self.handleWhenSoldierDieMap[owner] == nil then
		self.handleWhenSoldierDieMap[owner] = func
		self.handleWhenSoldierDieNum = self.handleWhenSoldierDieNum + 1
	end
end

function BattleUI:removeHandleWhenSoldierDie(owner)
	if self.handleWhenSoldierDieMap[owner] then
		self.handleWhenSoldierDieMap[owner] = nil
		self.handleWhenSoldierDieNum = self.handleWhenSoldierDieNum - 1
	end
end

function BattleUI:addHandleWhenLegionDie(owner, func)
	if self.handleWhenLegionDieMap[owner] == nil then
		self.handleWhenLegionDieMap[owner] = func
		self.handleWhenLegionDieNum = self.handleWhenLegionDieNum + 1
	end
end

function BattleUI:removeHandleWhenLegionDie(owner)
	if self.handleWhenLegionDieMap[owner] then
		self.handleWhenLegionDieMap[owner] = nil
		self.handleWhenLegionDieNum = self.handleWhenLegionDieNum - 1
	end
end

-- 死亡统计
function BattleUI:addDieNum(guid, position, soldierType)
	self.dieNum[guid] = self.dieNum[guid] + 1
	if self.handleWhenSoldierDieNum > 0 then
		for k, func in pairs(self.handleWhenSoldierDieMap) do
			func(guid, soldierType)
		end
	end
end

function BattleUI:addLegionDieNum(pos, guid, position)
	self.legionCount[guid] = self.legionCount[guid] - 1
	self.dieLegionNum[guid] = self.dieLegionNum[guid] + 1
	if self.handleWhenLegionDieNum > 0 then
		for k, func in pairs(self.handleWhenLegionDieMap) do
			func(guid)
		end
	end
end

function BattleUI:pauseByPlayerSkill()
	self.lastStatus = self.battleStatus
	self.battleStatus = BATTLE_STATUS.PAUSE_BY_SKILL
	self.bgMaskImg:setVisible(true)
	cc.Director:getInstance():getScheduler():setTimeScale(1/TIMESCALE)
	UIManager:setTouchEffectSpeed(TIMESCALE)
end

function BattleUI:resumeByPlayerSkill()
	if not self:isBattleEnd() then
		self.battleStatus = self.lastStatus or BATTLE_STATUS.FIGHTING
		cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
	end
	self.lastStatus = nil
	self.bgMaskImg:setVisible(false)
	UIManager:setTouchEffectSpeed(1)
end

function BattleUI:updateTime()
	local time = math.floor(self.time)
	local nowTime = self.overTime - time
	self.lastTime = time
	if nowTime <= 0 then
		self:battleEnd(false, true)
		self.timeLabel:setString("00:00")
	else
		self.timeLabel:setString(getTime(nowTime))
	end
end

function BattleUI:updatePlayerSkillPoint()
	local totalAddTimes1 = math.floor(self.time*self.pointPerSecond[1]) -- 半秒加一次
	local point1 = totalAddTimes1 - self.pointAddTimes[1]
	if point1 > 0 then
		self.playerSkillPoints[1] = self.playerSkillPoints[1] + point1
		self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
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

function BattleUI:addPointPerSecond(guid, point)
	self.pointPerSecond[guid] = self.pointPerSecond[guid] + point 
end

function BattleUI:addPoint(guid, point)
	self.playerSkillPoints[guid] = self.playerSkillPoints[guid] + point
	if guid == 1 then
		self.skillPointLabel:setString(tostring(self.playerSkillPoints[1]))
	end
	self:updatePlayerSkill(guid)
end

function BattleUI:updatePlayerSkill(guid)
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
				if guid == 1 then
					if lastTime > 0 then
						v.label:setString(tostring(math.ceil(lastTime)))
					else
						v.mask:setVisible(false)
						v.time = 0
					end
				else
					if lastTime <= 0 then
						v.time = 0
					end
				end
			end
			if v.disable then
				if self.playerSkillPoints[guid] >= v.needPoint then
					if guid == 1 then
						ShaderMgr:restoreSpriteDefaultShader(v.dragon)
					end
					v.disable = false
				end
			end
		end
	end
	if self.time > 5 and self:isAuto(guid) and autoUseIndex > 0 and self.battleStatus == BATTLE_STATUS.FIGHTING then
		self:usePlayerSkill(guid, autoUseIndex)
	end
end

-- 击杀效果
function BattleUI:addKillAnimation(dieGuid, legionPos, dieurl, killurl, noAct)
	self.dies[1][#self.dies[1] + 1] = dieGuid
	self.dies[2][#self.dies[2] + 1] = legionPos

	self.killHeadNum[dieGuid] = self.killHeadNum[dieGuid] + 1
	if killurl then
		if self.killAnimationFlag then
			local obj = {
				dieGuid = dieGuid,
				killurl = killurl,
				dieurl = dieurl,
				index = self.killHeadNum[dieGuid]
			}
			table.insert(self.killAnimationList, 1, obj)
		else
			self.killAnimationFlag = true
			self:playKillAnimation(dieGuid, self.killHeadNum[dieGuid], killurl, dieurl, noAct)
		end
	else
		local index = self.killHeadNum[dieGuid]
		local headImg = cc.Sprite:create(dieurl)
		local headImg2 = cc.Sprite:create(dieurl)
		ShaderMgr:setGrayForSprite(headImg)
		ShaderMgr:setGrayForSprite(headImg2)
		headImg:setScale(0.4)
		headImg2:setScale(1.5)
		self.fightPl:addChild(headImg)
		self.fightPl:addChild(headImg2)
		if dieGuid == 1 then
			headImg:setPosition(cc.p(290 - index*40, 136))
			headImg2:setPosition(cc.p(290 - index*40, 136))
		else
			headImg:setPosition(cc.p(670 + index*40, 136))
			headImg2:setPosition(cc.p(670 + index*40, 136))
		end
		headImg2:setOpacity(150)
		if noAct then
			headImg2:setScale(0.3)
			headImg2:removeFromParent()
		else
			headImg2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 0.4), cc.CallFunc:create(function ()
				headImg2:removeFromParent()
			end)))
		end
	end
end

function BattleUI:playKillAnimation(dieGuid, index, killurl, dieurl ,noAct)
	local widget = ccui.Widget:create()
	widget:setCascadeOpacityEnabled(true)
	local leftHead
	local rightHead
	local swordImg = cc.Sprite:create("uires/ui/common/fightbg.png")
	if dieGuid == 1 then
		leftHead = cc.Sprite:create(dieurl)
		rightHead = cc.Sprite:create(killurl)
		swordImg:setScaleX(-1)
	else
		leftHead = cc.Sprite:create(killurl)
		rightHead = cc.Sprite:create(dieurl)
	end
	leftHead:setScale(0.6)
	rightHead:setScale(0.6)
	leftHead:setPosition(cc.p(50, 0))
	swordImg:setPosition(cc.p(100, 0))
	rightHead:setPosition(cc.p(160, 0))
	widget:addChild(leftHead)
	widget:addChild(swordImg)
	widget:addChild(rightHead)
	self.root:addChild(widget)
	widget:setPosition(cc.p(-200, WINSIZE.height/2 + 100))
	local delayTime1 = 0.3
	local delayTime2 = 0.5
	local delayTime3 = 0.6
	if noAct then
		delayTime1 = 0
		delayTime2 = 0
		delayTime3 = 0.1
	end
	widget:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(0, WINSIZE.height/2 + 100)), cc.CallFunc:create(function ()
	end), cc.DelayTime:create(delayTime1), cc.CallFunc:create(function ()
		if dieGuid == 1 then
			-- ShaderMgr:setGrayForSprite(leftHead)
			leftHead:setColor(COLOR_TYPE.RED)
		else
			-- ShaderMgr:setGrayForSprite(rightHead)
			rightHead:setColor(COLOR_TYPE.RED)
		end
		local headImg = cc.Sprite:create(dieurl)
		local headImg2 = cc.Sprite:create(dieurl)
		ShaderMgr:setGrayForSprite(headImg)
		ShaderMgr:setGrayForSprite(headImg2)
		headImg:setScale(0.4)
		headImg2:setScale(1.5)
		self.fightPl:addChild(headImg)
		self.fightPl:addChild(headImg2)
		local maxNum = 6 + math.floor((WINSIZE.width - 930)/40)
		if dieGuid == 1 then
			if index <= maxNum then
				headImg:setPosition(cc.p(290 - index*40, 136))
				headImg2:setPosition(cc.p(290 - index*40, 136))
			else
				headImg:setPosition(cc.p(290 - (index-maxNum)*40, 96))
				headImg2:setPosition(cc.p(290 - (index-maxNum)*40, 96))
			end
		else
			if index <= maxNum then
				headImg:setPosition(cc.p(670 + index*40, 136))
				headImg2:setPosition(cc.p(670 + index*40, 136))
			else
				headImg:setPosition(cc.p(670 + (index-maxNum)*40, 96))
				headImg2:setPosition(cc.p(670 + (index-maxNum)*40, 96))
			end
		end
		headImg2:setOpacity(150)
		headImg2:runAction(cc.Sequence:create(cc.ScaleTo:create(delayTime1, 0.4), cc.CallFunc:create(function ()
			headImg2:removeFromParent()
		end)))
	end), cc.DelayTime:create(delayTime2), cc.Spawn:create(cc.MoveBy:create(delayTime3, cc.p(0, 80)), cc.FadeOut:create(delayTime3)), cc.CallFunc:create(function ()
		widget:removeFromParent()
		if #self.killAnimationList > 0 then
			local obj = table.remove(self.killAnimationList)
			self:playKillAnimation(obj.dieGuid, obj.index, obj.killurl, obj.dieurl, noAct)
		else
			self.killAnimationFlag = false
		end
	end)))
end

function BattleUI:getDamageLabel(labelType)
	if self.damageLabelPools[labelType].num > 0 then
		self.damageLabelPools[labelType].num = self.damageLabelPools[labelType].num - 1
		return self.damageLabelPools[labelType].arr[table.remove(self.damageLabelPools[labelType].indexs)]
	else
		local addIndex = #self.damageLabelPools[labelType].arr + 1
		local obj = {nil, nil}
		obj[1] = cc.LabelBMFont:create()
		obj[1]:setFntFile(FONT_FILE[labelType])
		self.bgImg:addChild(obj[1])
		local act1 = cc.Spawn:create(cc.EaseElasticOut:create(cc.MoveBy:create(0.3, cc.p(0, 40))),cc.ScaleBy:create(0.3, 2))
		local act2 = cc.DelayTime:create(0.2)
		local act3 = cc.Spawn:create(cc.EaseBackIn:create(cc.MoveBy:create(0.3, cc.p(0, 50))),cc.ScaleBy:create(0.35, 1),cc.FadeOut:create(0.3))
		local act4 = cc.CallFunc:create(function ()
			obj[1]:setVisible(false)
			table.insert(self.damageLabelPools[labelType].indexs, addIndex)
			self.damageLabelPools[labelType].num = self.damageLabelPools[labelType].num + 1
		end)
		obj[2] = cc.Sequence:create(act1, act2, act3, act4)
		obj[2]:retain()
		table.insert(self.damageLabelPools[labelType].arr, obj)
		return obj
	end
end

function BattleUI:addDamageLabel(obj)
	table.insert(self.damageLabels, obj)
	self.showDamageFlag = true
end

function BattleUI:showDamageLabel()
	if self.showDamageFlag then
		for k, v in ipairs(self.damageLabels) do
			local numString
			local labelType 
			local labelScale = 0.2
			if v.hpNum > 0 then
				-- 加血
				if v.flag == 3 then
					labelType = 4
				else
					labelType = 3
				end
				numString = "+" .. v.hpNum
			elseif v.hpNum < 0 then
				if v.flag == 3 then
				-- 暴击
					labelType = 2
					labelScale = 0.3
				else
					labelType = 1
				end
				numString = tostring(math.abs(v.hpNum))
			else
				labelType = 3
				if v.flag == 1 then
					numString = STR_IMMUNE
					labelType = 5
					labelScale = 0.3
				elseif v.flag == 2 then
					numString = STR_MISS
					labelType = 5
					labelScale = 0.3
				end
			end
			local obj = self:getDamageLabel(labelType)
			obj[1]:setString(numString)
			obj[1]:setVisible(true)
			obj[1]:setOpacity(255)
			obj[1]:setScale(labelScale)
			if v.flag == 3 then
				obj[1]:setPosition(cc.p(v.pos.x, v.pos.y + v.hpBarHeight))
			else
				obj[1]:setPosition(cc.p(v.pos.x + math.random(-20, 20), v.pos.y + v.hpBarHeight - 20 + math.random(-20, 20)))
			end
			obj[1]:runAction(obj[2])
			BattleHelper:setSoldierNumZorder(obj[1], v.pos.y)
		end
		self.showDamageFlag = false
		self.damageLabels = {}
	end
end

function BattleUI:addChangeTargetLegion(guid, legion)
	self.changeTargetLegions = self.changeTargetLegions or {}
	self.changeTargetLegions[guid] = self.changeTargetLegions[guid] or {}
	self.changeTargetLegions[guid][legion.pos] = legion
end

function BattleUI:addChangeTargetSoldier(guid, legionPos, soldier)
	self.changeTargetSoldiers = self.changeTargetSoldiers or {}
	self.changeTargetSoldiers[guid] = self.changeTargetSoldiers[guid] or {}
	self.changeTargetSoldiers[guid][legionPos] = self.changeTargetSoldiers[guid][legionPos] or {}
	table.insert(self.changeTargetSoldiers[guid][legionPos], soldier)
end

function BattleUI:searchTarget()
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

function BattleUI:showSkillMask(soldier)
	if self:isBattleEnd() then
		return
	end
	if self.skillMaskImg:isVisible() then
		self.skillMaskImg:stopAllActions()
		self.skillMaskImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			self.skillMaskImg:setVisible(false)
			self.slowDownSpeedScale = 1
			if not self:isBattleEnd() then
				cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
			end
		end)))
	else
		self.slowDownSpeedScale = 0.5
		cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
		self.skillMaskImg:setVisible(true)
		self.skillMaskImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			self.skillMaskImg:setVisible(false)
			self.slowDownSpeedScale = 1
			if not self:isBattleEnd() then
				cc.Director:getInstance():getScheduler():setTimeScale(self.speedUp*self.slowDownSpeedScale)
			end
		end)))
	end
	BattleHelper:setSoldierZorderOnSkillMask(soldier)
end

function BattleUI:update(dt)
	if self.battleStatus == BATTLE_STATUS.FIGHTING then
		-- local time1 = socket.gettime()
		self.time = self.time + dt
		for k, v in ipairs(self.armyArr[1]) do
			v:update(dt)
		end
		for k2, v2 in ipairs(self.armyArr[2]) do
			v2:update(dt)
		end
		self:showDamageLabel()
		self:searchTarget()
		self:updatePlayerSkillPoint()
		if self.time - self.lastTime > 1 then
			self:updateTime()
		end
		-- local time2 = socket.gettime()
		-- if time2-time1 > 0.005 then
		-- 	release_print('======================update cost time = ' .. time2-time1)
		-- end
		
		if self.battleType == BATTLE_TYPE.NORMAL then
			self.skipBtn:setVisible(true)
		end
	end
end

function BattleUI:otherSpecialHandle()
end

function BattleUI:initCompleted()
end

function BattleUI:onShow()
	-- 特殊处理引导布阵
	if self.specialEmbattleFlag then
		if self.embattleFinger == nil then
			self.embattleFinger = GlobalApi:createLittleLossyAniByName("guide_finger")
			self.embattleFinger:getAnimation():play("idle02", -1, -1)
			self.embattleFinger:getAnimation():gotoAndPause(0)
			self.embattleFinger:setRotation(90)
			self.bgImg:addChild(self.embattleFinger)
			BattleHelper:setSpecialNodeZorder(self.embattleFinger)
			self.embattleFinger:setPosition(LEGION_POS[1][1])
			self.embattleFinger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, LEGION_POS[1][2]), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
				self.embattleFinger:setPosition(LEGION_POS[1][1])
			end))))
		end
		self.specialEmbattleFlag = false
	end
end

function BattleUI:guideSpecialEmbattle()
	self.specialEmbattleFlag = true
end

function BattleUI:findSoldierAndPlayDie(reportSoldier, soldierType)
	local legion
	local soldier
	if reportSoldier.guid == 1 then
		legion = self.armyMap[reportSoldier.legionObj.pos]
	else
		legion = self.enemyMap[reportSoldier.legionObj.pos]
	end
	if soldierType == 1 then
		soldier = legion.heroObj
		-- soldier:playDie()
	elseif soldierType == 2 then
		soldier = legion.soldierObjs[reportSoldier.report.recordObj[4]]
		if soldier then
			-- soldier:playDie()
		end
	end
end

-- pvp专有的跳过功能
function BattleUI:skip()
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

-- 引导点击开始战斗按钮
function BattleUI:showBattleBtnHand()
	local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    hand:getAnimation():play("idle01", -1, 1)
    local btnSize = self.battleBtn:getContentSize()
    hand:setPosition(cc.p(btnSize.width/2, btnSize.height/2))
    self.battleBtn:addChild(hand)
    self.battleBtnHand = hand
    GuideMgr:finishCurrGuide()
end

function BattleUI:showQuitConfirm()
	if self.battleType == BATTLE_TYPE.LEGION_WAR then
		if self.quitConfirmNode == nil then
			self.quitConfirmNode = cc.CSLoader:createNode("csb/messagebox.csb")
			local bgImg = self.quitConfirmNode:getChildByName("messagebox_bg_img")
			local messageboxImg = bgImg:getChildByName("messagebox_img")
			local closeBtn = messageboxImg:getChildByName("close_btn")
			closeBtn:setVisible(false)
			bgImg:setScale9Enabled(true)
			bgImg:setContentSize(WINSIZE)
			bgImg:setPosition(cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5))
			messageboxImg:setPosition(cc.p(WINSIZE.width*0.5, WINSIZE.height*0.5))
			local neiBgImg = messageboxImg:getChildByName("nei_bg_img")
			local okBtn1 = neiBgImg:getChildByName("ok_1_btn")
			local okBtn2 = neiBgImg:getChildByName("ok_2_btn")
			okBtn2:setVisible(false)
			local okTx1 = okBtn1:getChildByName("info_tx")
			okTx1:setString(GlobalApi:getLocalStr("STR_OK2"))
			local cancelBtn = neiBgImg:getChildByName('cancel_btn')
			local cancelTx = cancelBtn:getChildByName('info_tx')
			cancelTx:setString(GlobalApi:getLocalStr("STR_CANCEL_1"))
			okBtn1:addClickEventListener(function ()
				cc.Director:getInstance():getScheduler():setTimeScale(1)
				UIManager:setTouchEffectSpeed(1)
				BattleMgr:exitBattleField()
			end)
			cancelBtn:addClickEventListener(function ()
				self.quitConfirmNode:setVisible(false)
			end)
			local checkBoxBtn = neiBgImg:getChildByName("checkbox")
			checkBoxBtn:setVisible(false)
			local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("QUIT_BATTLE_CONFIRM"), "font/gamefont.ttf", 25)
			msg:setAnchorPoint(cc.p(0.5, 0.5))
			msg:setPosition(cc.p(262, 216))
			msg:setMaxLineWidth(424)
			msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
			msg:setColor(COLOR_TYPE.ORANGE)
			msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
			neiBgImg:addChild(msg)
			local pauseBg = self.root:getChildByName("pause_bg")
			pauseBg:addChild(self.quitConfirmNode)
		else
			self.quitConfirmNode:setVisible(true)
		end
	else
		cc.Director:getInstance():getScheduler():setTimeScale(1)
		UIManager:setTouchEffectSpeed(1)
		BattleMgr:exitBattleField()
	end
end

return BattleUI