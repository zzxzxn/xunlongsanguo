local UserObj ={
	uid = 0,
	level = 0,  --等级
--	honor = 0,  --幸运值
	gold = 0,   --金币
	cash = 0,   --元宝
	xp = 0,     --经验
	vip = 0,    --VIP等级
	vip_xp = 0, --VIP经验
	food = 0,   --粮草
    digging = 0,-- 挖矿次数
	tower = 0,  --爬塔币
	arena = 0,  --竞技场币
	legion = 0, --军团币
	legionwar = 0, --军团战货币
    trial_coin = 0, --军团试炼货币
    love = 0,       -- 限时招募爱心值
	soul = 0,   --将魂
	luck = 0, 	--幸运值
	ntoken = 0, --普通招募令
	htoken = 0,	--高级招募令
	gtoken = 0, --神将商店刷新令
	mtoken = 0, --神秘商店刷新令
	rtoken = 0, --竞技商店刷新令
	ttoken = 0, --爬塔商店刷新令
	free_gtoken = 0,
	free_mtoken = 0,
	boon = 0,  	--红包
	egg = 0, 	--成就蛋
	wood = 0,   --木材
    country = 0,-- 国家
    goods = 0,   --物资
    countrywar = 0,   --军资
    countryCurrency,    -- 国币
    first_login = 0,    -- 玩家每天第1次登陆的标志
	tavern = {
		ntime = 0,	    --普通招募下次免费招募时间
		htime = 0,		--高级招募下次免费招募时间
		nfree = 0,		--已经使用的普通招募免费次数
		hcount = 0,		--高级招募的总次数
		purple = 0,		--N次高级招募之内是否获得了紫卡或橙卡
		orange = 0,		--M次高级招募之内是否获得了橙卡
        hot_time = 0,   --酒馆限时抽奖免费时间
        luck = 0        --将星值
	},
	rescopy = {
		gold = {
			count = 0,			--金币副本今日攻打次数
			damage = 0			--历史最高伤害
		},
		xp = {
			count = 0,			--经验副本今日攻打次数
			kill = 0				--历史最高击杀武将数
		},
		reborn = {
			count = 0,		--突破石副本今日攻打次数
			time  = 0		--历史最长时间, 秒数
		},
		destiny ={
			count = 0,		--天命石副本今日攻打次数
			round = 0		--历史最大攻击波数
		}
	},
	treasure = {			-- 宝物
		id = 1,				-- 当前正在激活的宝物id
		got = 10,			-- 当前已得到的宝物碎片数量
		active = 1			-- 当前已激活的宝物碎片数量
	},
	fightForce = 0,
	runLock = {},
	mailIdTab = {
		[0] = 0,
		[1] = 0
	},
	shipper = {
		rob = 0,
		delivery = 0
	},
	altar ={},
	sign ={
		day = 0, 				--上次签到日期
		count = 0, 				--当月已签到次数
		continuous = 0, 		--连续签到天数
		continuous_reward = 0, 	--连续奖励是否领取
	},
	lid = 0, 		--军团ID
	lname = '',		--军团名
	llevel = 0,		--军团等级
	lgold_tree = { --军团摇钱树果子
		--out_come = 0,
		--time = 0
	}, 
	firstrecharge = 0, --是否首冲过
	jade_seal = {
		--[[
			id:1,	--玉玺是否领奖
		]]
	}, --玉玺功能
	jade_seal_hero = {
		--star: 0/1        --玉玺星星奖励领取状态
	},
	payment = {
        paid = 0,  -- 已充值的元宝
        month_card = {
            day = 0,
            got_day = 0,
            type = 0
        },
        gift_cash = 0,
        pay_list = {},
        cost = 0
    },
    legioninfo = {}, --军团详细信息,里面有grab_boon（抢红包次数）
    tips = {},
    guard = {}, -- 巡逻信息
    warCollege = {}, -- 战争学院
    city = {},
    infinite = {}, -- 无限关卡
    openCDKey = 1,
    active = 0,
    nobility = {1,0},
    guide = {
    	citytime = 0,
    	legionwarstage = 0,
    	worldwarstage = 'rank',
    	legionwar_citybufnum = 0,		--已增筑次数
    	legionwar_attacknum = 4,		--剩余攻击次数
	},
	peopleKing = {}, -- 人皇
	sky_book = 0,	 -- 技能书
	reminder = {},    -- 一些功能提示,每次登陆后只提示一次
    identity = {
        normal = 0,     -- 已普通鉴宝次数
        normal_day = 0, -- 普通鉴宝上次刷新
        medium = 0,     -- 已中级鉴宝次数
        medium_day = 0, -- 中级鉴宝上次刷新
        super = 0,      -- 已高级鉴宝次数
        super_day = 0   -- 高级鉴宝上次刷新
	},
    ncheck = 0,	 -- 普通鉴宝令
    hcheck = 0,	 -- 高级鉴宝券
}

function UserObj:initUserStatus( json,first_login )
	self.level = json.level or 0
	self.honor = json.honor or 0
	self.gold = json.gold or 0
	self.cash = json.cash or 0
	self.xp = json.xp or 0
	self.vip = json.vip or 0
	self.vip_xp = json.vip_xp or 0
	self.food = json.food or 0
	self.soul = json.soul or 0
	self.luck = json.luck or 0
	self.digging = json.digging or 0
	self.legion = json.legion or 0
	self.legionwar = json.legionwar or 0
    self.trial_coin = json.trial_coin or 0
    self.love = json.love or 0
	self.gtoken = json.gtoken or 0 -- 神将
	self.free_gtoken = json.free_gtoken or 0	--免费刷新次数
	self.ntoken = json.ntoken or 0
	self.htoken = json.htoken or 0
	self.mtoken = json.mtoken or 0 -- 神秘
	self.free_mtoken = json.free_mtoken or 0 	--装备免费刷新次数
	self.rtoken = json.rtoken or 0 -- 竞技场令牌
	self.ttoken = json.ttoken or 0 -- 塔令牌
	self.token = json.token or 0 -- 荣誉令牌
	self.arena = json.arena or 0 -- 竞技场币
	self.arena_xp = json.arena_xp or 0 -- 竞技场币
	self.oldArenaXp = self.arena_xp
	self.arena_level = json.arena_level or 0 -- 竞技场币
	self.oldArenaLv = clone(self.arena_level)
	self.tower = json.tower or 0
	self.boon = json.boon or 0
	self.smelt = json.smelt or 0
	self.egg = json.egg or 0
	self.wood = json.wood or 0
	self.salary = json.salary or 0
	self.goods = json.goods or 0
	self.countrywar = json.countrywar or 0
    self.first_login = first_login or 0
    self.shas = json.shas or 0
    self.country_score = json.country_score or 0
    self.countryCurrency = json.country
	local maxFood = tonumber(GlobalApi:getGlobalValue('foodMax'))
	if self.food >= maxFood then
		self.foodMax = true
	else
		self.foodMax = false
	end


    self.lastVip = json.vip or 0
    self.seventTag = 1
    self.petitionTag = 1

    self.todayDoubleTag = 1
    self.luckyWheelTag = 1
    self.happyWheelTag = 1
    self.payOnlyTag = 1

    self.islvChange = false
    self.goldMineTag = 1
    self.socketMailStatus = false

    self.activityGrowFundFirstOpen = false

    self.action_point = json.action_point
    self.staying_power = json.staying_power

    self.mine_1 = json.mine_1
    self.mine_2 = json.mine_2
    self.mine_3 = json.mine_3
    self.mine_4 = json.mine_4
    self.mine_5 = json.mine_5

    self.activity_value_key = GameData:getConfData("activities_value_key")
    self.friendToTwenty = false

    self.sky_book = json.sky_book or 0
    self.reminder = {}
    self.ncheck = json.ncheck or 0
    self.hcheck = json.hcheck or 0

	if not GlobalData:getLockFormation() then
		GlobalData:setLockFormation(0)
	end
end

function UserObj:markReminder(key)
	self.reminder[key] = true
end

function UserObj:getReminder(key)
	return self.reminder[key]
end

function UserObj:getMilitarySign()
	
	local dailyplayConf = GameData:getConfData("local/dailyplay")
	for k,v in pairs(dailyplayConf) do
		local showType = self:getDailyText(v.event)
		if "hook" == v.event then
			showType = 3
		end
		if showType == 1 then
			return true
		end
	end
	return false
end

function UserObj:getWarCollegeSign()
	local conf = GameData:getConfData("warcollege")
    local progress = self.warCollege.challenge
    if progress < #conf then
    	local cityProgress = MapData:getFightedCityId()
    	local condition = conf[progress+1].condition
    	if cityProgress >= condition then
    		return true
    	end
    end
    return false
end

function UserObj:judgeWarCollegeSign()
	local conf = GameData:getConfData("warcollege")
    local progress = self.warCollege.challenge
    if progress >= #conf then
    	return false
    end
    return true
end

function UserObj:initUserTavern( json )
	self.tavern.ntime = json.ntime or 0
	self.tavern.htime = json.htime or 0
	self.tavern.nfree = json.nfree or 0
	self.tavern.hcount = json.hcount or 0
	self.tavern.purple = json.purple or 0
	self.tavern.orange = json.orange or 0
    self.tavern.hot_time = json.hot_time or 0
    self.tavern.luck = json.luck or 0
end

-- 已经合璧的次数
function UserObj:initCountryJade(country_jade,country_jade_time)
    self.country_jade = country_jade or 0
    self:setCountryJadeFinishTime(country_jade_time)
end

function UserObj:setCountryJadeFinishTime(countryJadeFinishTime)
    self.countryJadeFinishTime = countryJadeFinishTime or 0
end

function UserObj:getCountryJadeFinishTime()
    return self.countryJadeFinishTime or 0
end

function UserObj:setTavenHotTime(value)
	self.tavern.hot_time = value or 0
end

function UserObj:setTavenLuck(value)
	self.tavern.luck = value or 0
end

function UserObj:getTavenLuck()
	return self.tavern.luck or 0
end

function UserObj:setLegionInfo(json)
	self.legioninfo = json or {}
    if self.staying_power then
        local maxStayingPower = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
	    if self.staying_power >= maxStayingPower then
		    self.stayingPowerMax = true
	    else
		    self.stayingPowerMax = false
	    end
    end
    
    if self.action_point then
        local actionPointMaxVal = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
        actionPointMaxVal = TerritorialWarMgr:getRealCount('actionMax', actionPointMaxVal)
	    if self.action_point >= actionPointMaxVal then
		    self.actionPointMax = true
	    else
		    self.actionPointMax = false
	    end
    end
end

function UserObj:setLegionCopyCount(num)
	self.legioninfo.copy_count = num
end

function UserObj:setLegionCopyBuy(num)
	self.legioninfo.copy_buy = num
end

function UserObj:getLegionInfo()
	return self.legioninfo
end

function UserObj:setLegionCityInfo(data)
    self.legioninfo.city = data
end

function UserObj:getLegionCityMainLevel()
    local level = 1
    local legionCityMainConf = GameData:getConfData('legioncitymain')
    local totalLevel = self:getLegionCityTotalLevel()
    for k,v in ipairs(legionCityMainConf) do
        if totalLevel >= tonumber(v.condition) then
            level = k + 1
        end
    end
    if level > #legionCityMainConf then
    	level = #legionCityMainConf
    end
    return level
end

function UserObj:getLegionCityTotalLevel()
    local totalLevel = 0
    for k, v in pairs(self.legioninfo.city.buildings) do
        totalLevel = totalLevel + self.legioninfo.city.buildings[k].level
    end

    return totalLevel
end

-- 获取城池等级
function UserObj:getLegionCityBuildingLevel(buildingId)
    if self.legioninfo.city.buildings[tostring(buildingId)] then
        return self.legioninfo.city.buildings[tostring(buildingId)].level
    end

    return 0
end

function UserObj:setLegionCityBuildingLevel(buildingId, level)
    if self.legioninfo.city.buildings[tostring(buildingId)] == nil then
        self.legioninfo.city.buildings[tostring(buildingId)] = {}
    end
        
    self.legioninfo.city.buildings[tostring(buildingId)].level = level
end

-- 获取奖励个数
function UserObj:getLegionCityAwardNum(awardId)
    if self.legioninfo.city.awards[tostring(awardId)] then
        return self.legioninfo.city.awards[tostring(awardId)].num
    end

    return 0
end

function UserObj:setLegionCityAwards(awards)
    self.legioninfo.city.awards = awards
end

function UserObj:getLegionCityAwardTime(awardId)
    if self.legioninfo.city.awards[tostring(awardId)] then
        return self.legioninfo.city.awards[tostring(awardId)].time
    end

    return GlobalData:getServerTime()
end

function UserObj:setLegionConstructCount(num)
	self.legioninfo.construct_count = num
end

function UserObj:setActivityInfo(activity,grow_fund_count,avconf)
	self.activity = activity
    self.grow_fund_count = grow_fund_count or 0
    self.avconf = avconf
end

function UserObj:getActivityInfo()
	return self.activity
end

function UserObj:setServerOpenTime(time)
	self.serverOpenTime = time
end

function UserObj:getServerOpenTime()
	return self.serverOpenTime
end

function UserObj:setWorldWarOpenTime(time)
	self.worldWarOpenTime = time
end

function UserObj:getWorldWarOpenTime()
	return self.worldWarOpenTime
end

function UserObj:initShipper(json)
	self.shipper.rob = json.rob or 0
	self.shipper.delivery = json.delivery or 0
end

function UserObj:getShipper()
	return self.shipper
end

function UserObj:initMark(json)
	self.mark = json
end

function UserObj:initMake(json)
	self.make = json
end

function UserObj:initTower(json)
	self.towerInfo = json
end

function UserObj:initTrain(json)
	self.train = json
end

function UserObj:getTower()
	return self.tower
end

function UserObj:getTrain()
	return self.train
end

function UserObj:getMark()
	return self.mark
end

function UserObj:getDayWorldChatCount()
    if self.mark and self.mark.day_world_chat_count  then
		return self.mark.day_world_chat_count 
	else
		return 0
	end
end

function UserObj:setDayWorldChatCount(count)
    self.mark.day_world_chat_count = count
end

function UserObj:getDiggingTime()
	if self.mark and self.mark.digging_time  then
		return self.mark.digging_time 
	else
		return 0
	end
end

function UserObj:setFoodTime(time)
	self.mark.food_time = time
end

function UserObj:getFoodTime()
	if self.mark and self.mark.food_time  then
		return self.mark.food_time 
	else
		return 0
	end
end

function UserObj:initPayment(json)
	self.payment = json
end

function UserObj:getPayment()
	return self.payment
end

function UserObj:setPayment(tab)
	self.payment = tab
end

function UserObj:initSign(json)
	self.sign = json
end

function UserObj:getSign()
	return self.sign
end

function UserObj:initTask(json)
	self.task = json
	self.privilege = self.task.privilege
	self.nobility = self.task.nobility
	local vipExp = GlobalApi:getPrivilegeById("vipExp") or 0
	if vipExp then
		self.vip_xp = self.vip_xp + vipExp
	end
end

function UserObj:getTask()
	return self.task
end

function UserObj:initJadeSeal(json)
	self.jade_seal = json
end

function UserObj:initGuard(guard)
	self.guard = guard
end

function UserObj:getGuard()
	return self.guard
end

function UserObj:getJadeSeal()
	return self.jade_seal
end

function UserObj:getJadeSealAddition(key)
	local jade_seal_addition = {false, 0}
	local jadesealconf = GameData:getConfData("jadeseal")
    local unlock
    local jadeIndex = "0"
    for k, v in ipairs(jadesealconf) do
        unlock = string.split(v.unlock, ".")
        if unlock[1] == key then
            jadeIndex = tostring(k)
            jade_seal_addition[2] = tonumber(unlock[2])
            break
        end
    end
    if self.jade_seal[jadeIndex] == 1 then
    	jade_seal_addition[1] = true
    else
        jade_seal_addition[1] = false
    end
	return jade_seal_addition
end

function UserObj:initJadeSealHero(json)
	self.jade_seal_hero = json
end

function UserObj:getJadeSealHero()
	return self.jade_seal_hero
end

function UserObj:initAltar(json)
	self.altar = json
end

function UserObj:getAltar()
	return self.altar
end

function UserObj:setAddAltar(index,num)
	index = tostring(index)
    if self.altar[index] then
    	if not num then
    		self.altar[index] = self.altar[index] + 1
    	else
    		self.altar[index] = self.altar[index] + num
    	end
    else
        if num then
            self.altar[index] = num
        else
            self.altar[index] = 1
        end

    end
end
function UserObj:updateShipper(key, value)
	self.shipper[key] = value or sself.shipper[key]
end

function UserObj:setSkills(json)
	self.skills = json
end

function UserObj:getSkills()
	return self.skills
end

function UserObj:getLegion()
	return self.legion
end

function UserObj:getLegionwar()
	return self.legionwar
end

function UserObj:getTrialCoin()
	return self.trial_coin
end

function UserObj:setTrialCoin(trial_coin)
	self.trial_coin = trial_coin
end

function UserObj:getLove()
	return self.love
end

function UserObj:setLove(love)
	self.love = love
end

function UserObj:setTreasure(json)
	self.treasure = json
end

function UserObj:getTreasure()
	return self.treasure
end

function UserObj:getMailSysMax(sys)
	return self.mailIdTab[sys]
end

function UserObj:setMailStatus(id)
	if self.mail and type(self.mail) == 'table' then
		self.mail[id] = 1
	end
end

function UserObj:getMail()
	return self.mail
end

function UserObj:getMails()
	return self.mails
end

function UserObj:getHadNewMail()
	local hadNewMail = false
	if not self.mails then
		return hadNewMail or self.socketMailStatus
	end
	for i,v in pairs(self.mails) do
		if v.sys == 0 or not self.mail[tostring(v.id)] then
			hadNewMail = true
		end
	end
	return hadNewMail or self.socketMailStatus
end

-- 推送的邮件提醒
function UserObj:setSocketMailStatus(status)
	self.socketMailStatus = status
end

function UserObj:removeMail(arrId)
	self.mails[arrId] = nil
end

function UserObj:initUserMail( json )
	if not json.mails then
		json.mails = {}
	end
	for i,v in pairs(json.mails) do
		if v.id > self.mailIdTab[v.sys] then
			self.mailIdTab[v.sys] = v.id
		end
	end
	self.mails = json.mails
	self.mail = json.mail
end

function UserObj:setLegion(lid, name, level,gold_tree,lduty,ltype,wish)
	self.lid = lid or 0
	self.lname = name or ''
	self.llevel = level or ''
	self.lgold_tree = gold_tree or {}
    self.wish = wish
    self.lduty = lduty or 0
    self.ltype = ltype or 0
end

--legionid
function UserObj:getLid()
	return self.lid
end

function UserObj:getLLevel()
	return self.llevel
end

function UserObj:getLGoldtree()
	return self.lgold_tree
end

function UserObj:setPosition(position)
	self.position = position
end

function UserObj:getPosition()
	if not self.position or self.position == 0 then
		self.position = 32
	end
	return self.position
end

function UserObj:getCountryWar()
	return self.countrywar
end

function UserObj:getGoods()
	return self.goods
end

function UserObj:getLduty()
	return self.lduty
end

function UserObj:getLtype()
	return self.ltype
end

function UserObj:initUserInfo( json )
	self.country = json.country or 0
	self.uid = json.uid or ''
	self.headpic = json.headpic or 0
    self.headframe = json.headframe or 0
	self.createTime = json.create or 0  -- 创建时间
	self.name = json.un or ''
	self.dragon = json.dragon
	self.position = json.position or 32
end

function UserObj:getDragon()
	return self.dragon
end

function UserObj:setDragon(dragon)
	self.dragon = dragon or 0
end

function UserObj:initUserResCopy(json)
	self.rescopy.gold.count= json.gold.count or 0
	self.rescopy.gold.damage = json.gold.damage or 0
	self.rescopy.gold.difficulty = json.gold.difficulty or 1
	self.rescopy.gold.first = json.gold.first or 0
	self.rescopy.gold.buy = json.gold.buy or 0
	self.rescopy.xp.count = json.xp.count or 0
	self.rescopy.xp.kill = json.xp.kill or 0
	self.rescopy.xp.difficulty = json.xp.difficulty or 1
	self.rescopy.xp.first = json.xp.first or 0
	self.rescopy.xp.buy = json.xp.buy or 0
	self.rescopy.reborn.count = json.reborn.count or 0
	self.rescopy.reborn.time = json.reborn.time or 0
	self.rescopy.reborn.difficulty = json.reborn.difficulty or 1
	self.rescopy.reborn.first = json.reborn.first or 0
	self.rescopy.reborn.buy = json.reborn.buy or 0
	self.rescopy.destiny.count = json.destiny.count or 0
	self.rescopy.destiny.round = json.destiny.round or 0
	self.rescopy.destiny.difficulty = json.destiny.difficulty or 1
	self.rescopy.destiny.first = json.destiny.first or 0
	self.rescopy.destiny.buy = json.destiny.buy or 0
end

function UserObj:addAttrData(data)
	local num = self[data[2]]
	if data[2] == "arena_xp" then
		self.oldArenaXp = clone(self.arena_xp)
	end

    if data[2] == "country" then    -- 国币特殊处理
       data[2] = "countryCurrency"
    end
    self[data[2]] = self[data[2]] + data[3]

	if data[2] == "xp" then
		self:updateLv()
	elseif data[2] == "arena_xp" then
		self:updateArenaLv()
	elseif data[2] == "food" then
		local maxFood = tonumber(GlobalApi:getGlobalValue('foodMax'))
		-- print(self.food , maxFood,self.foodMax)
		if self.food >= maxFood then
			self.foodMax = true
			self.mark.food_time = GlobalData:getServerTime()
			UIManager:getSidebar():removeFoodRestore()
		elseif self.foodMax == true then
			self.foodMax = false
			-- print('==========================22',self.mark.food_time,GlobalData:getServerTime())
			local diffTime = GlobalApi:getGlobalValue('foodInterval')*60 + (self.mark.food_time or 0) - GlobalData:getServerTime()
			-- print('==========================23',diffTime)
			if diffTime < 0 then
				-- print('==========================2',self.mark.food_time)
				self.mark.food_time = GlobalData:getServerTime()
				-- print('==========================21',self.mark.food_time)
				GlobalApi:parseAwardData({{'user','food',1}})
				return
			else
				UIManager:getSidebar():resetFoodRestore()
			end
		else
			self.foodMax = false
			UIManager:getSidebar():resetFoodRestore()
		end
    elseif data[2] == "staying_power" then
        -- 耐力有上限
        local powerMax = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
        if self.staying_power >= powerMax then
            self.staying_power = powerMax
            self.mark.staying_power_time = GlobalData:getServerTime()
            self.stayingPowerMax = true
            UIManager:getSidebar():removeStayingPowerRestore()
        elseif self.stayingPowerMax then
            self.stayingPowerMax = false

            local recover = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
            local interval = TerritorialWarMgr:getRealCount('enduranceRecoverRate',recover)
            local diffTime = interval + (self.mark.staying_power_time or 0) - GlobalData:getServerTime()
            if diffTime < 0 then
				self.mark.staying_power_time = GlobalData:getServerTime()
				GlobalApi:parseAwardData({{'user','staying_power',1}})
				return
			else
				UIManager:getSidebar():resetStayingPowerRestore()
			end
        else
            self.stayingPowerMax = false
            UIManager:getSidebar():resetStayingPowerRestore()
        end
    elseif data[2] == "action_point" then
        local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
        actionPointMax = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
        if self.action_point >= actionPointMax then
            self.mark.action_point_time = GlobalData:getServerTime()
            self.actionPointMax = true
            UIManager:getSidebar():removeActionPointRestore()
        elseif self.actionPointMax then
            self.actionPointMax = false

            local num = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
            local interval = TerritorialWarMgr:getRealCount('actionRecoverRate',num)

            local diffTime = interval + (self.mark.action_point_time or 0) - GlobalData:getServerTime()
            if diffTime < 0 then
				self.mark.action_point_time = GlobalData:getServerTime()
				GlobalApi:parseAwardData({{'user','action_point',1}})
				return
			else
                self.actionPointMax = false
				UIManager:getSidebar():resetActionPointRestore()
			end
        else
            UIManager:getSidebar():resetActionPointRestore()
        end
        UIManager:updateSidebar()
	end
	
	if self[data[2]] and data[2] ~= "action_point" then
		UIManager:runNum(data[2],num)
	end

    if (data[2] == 'cash') and (data[3] < 0) then -- 消耗元宝
        if self:getActivityStatus('expend_gift') == true and self.isGetMoneyDragonPost == nil then
            local paid = self.activity.expend_gift and self.activity.expend_gift.paid or 0
            self.activity.expend_gift.paid = paid + math.abs(data[3])
        end
        if self:getActivityStatus('daily_cost') == true and self.isGetMoneyDragonPost == nil then
            local day_cost = self.activity.daily_cost.day_cost or 0
            self.activity.daily_cost.day_cost = day_cost + math.abs(data[3])
        end
        self.isGetMoneyDragonPost = nil
    end

end

function UserObj:getEquipValume()
	return self.eauipValume or 0
end

function UserObj:getDragonGemValume()
	return self.dragongemValume or 0
end

function UserObj:setWorldWarSupSign(sup)
	self.tips.ww_sup = sup
end

function UserObj:setWorldWarCount(battle)
	if not self.worldwar then
		self.worldwar = {}
	end
	self.worldwar.battle = battle
end

function UserObj:setWorldWarFighted(fighted)
	self.worldwar.fighted = fighted
end

function UserObj:setWorldWarMatchCount(match)
	self.worldwar.match = match
end

function UserObj:setInfinite(json)
	self.infinite = json
end

function UserObj:getInfinite()
	return self.infinite
end

function UserObj:setFriendsysInfo(json)
	self.friendsys_info = json
end

function UserObj:getFriendsysInfo()
	return self.friendsys_info
end


function UserObj:initConspiracy(json)
	self.conspiracy = json
end

function UserObj:getConspiracy()
	return self.conspiracy
end

function UserObj:setPromoteWheel(json)
	self.promote_wheel = json
end

function UserObj:getPromoteWheel(json)
	return self.promote_wheel
end

function UserObj:initWorldWar(json)
	self.worldwar = json
end

function UserObj:getWorldWar()
	return self.worldwar
end

function UserObj:setDragonGemValume(valume)
	self.dragongemValume = valume
end

function UserObj:setEquipValume(valume)
	self.eauipValume = valume
end

function UserObj:getMineDuration()
	return self.mineDuration or 0
end

function UserObj:addMineDuration(mineDuration)
	self.mineDuration = mineDuration + (self.mineDuration or 0)
end

function UserObj:setMineDuration(mineDuration)
	self.mineDuration = mineDuration or 0
end

function UserObj:setMineId(id)
	self.mine_id = id
end

function UserObj:setSmelt(smelt)
	self.smelt = smelt
end

function UserObj:getSmelt()
	return self.smelt
end

function UserObj:getRToken()
	return self.rtoken
end

function UserObj:setRToken(token)
	self.rtoken = token
end

function UserObj:getSalary()
	return self.salary
end

function UserObj:setSalary(salary)
	self.salary = salary
end

function UserObj:getToken()
	return self.token
end

function UserObj:setToken(token)
	self.token = token
end

function UserObj:getTToken()
	return self.ttoken
end

function UserObj:setTToken(token)
	self.ttoken = token
end

function UserObj:getMToken()
	return self.mtoken
end

function UserObj:setMToken(token)
	self.mtoken = token
end

function UserObj:getGToken()
	return self.gtoken
end

function UserObj:setGToken(token)
	self.gtoken = token
end

function UserObj:getFreeGToken()
	return self.free_gtoken
end

function UserObj:setFreeGToken(token)
	self.free_gtoken = token
end

function UserObj:getFreeMToken()
	return self.free_mtoken
end

function UserObj:setFreeMToken(token)
	self.free_mtoken = token
end

function UserObj:getCountry()
	return self.country
end

function UserObj:setCountry(country)
	self.country = country
end

function UserObj:getCountryCurrency()
	return self.countryCurrency
end

function UserObj:setCountryCurrency(countryCurrency)
	self.countryCurrency = countryCurrency
end

function UserObj:getLv()
	return self.level
end

function UserObj:getHonor()
	return self.honor
end

function UserObj:countryScore()
	return self.country_score
end

function UserObj:getShas()
	return self.shas
end

function UserObj:getGold()
	return self.gold
end

function UserObj:getCash()
	return self.cash
end

function UserObj:getSoul()
	return self.soul
end

function UserObj:getXp()
	return self.xp
end

function UserObj:getVip()
	return self.vip
end

function UserObj:getVipXp()
	return self.vip_xp
end

function UserObj:setVip(vip)
	self.vip = vip
end

function UserObj:setVipXp(vip_xp)
	self.vip_xp = vip_xp
end

function UserObj:getFood()
	return self.food
end

function UserObj:getLuck()
	return self.luck
end
 
function UserObj:getBoon()
	return self.boon
end

function UserObj:getSkybook()
	return self.sky_book
end

function UserObj:getNcheck()
	return self.ncheck
end

function UserObj:getHcheck()
	return self.hcheck
end

function UserObj:initUserIdentity(json)
    self.identity.normal = json.normal or 0
    self.identity.normal_day = json.normal_day or 0
    self.identity.medium = json.medium or 0
    self.identity.medium_day = json.medium_day or 0
    self.identity.super = json.super or 0
    self.identity.super_day = json.super_day or 0
end

function UserObj:getIdentity()
    return self.identity
end

function UserObj:initWarCollege(warCollege)
	self.warCollege = warCollege
end

function UserObj:getWarCollege()
	return self.warCollege
end

function UserObj:addWarCollegeChallenge()
	self.warCollege.challenge = self.warCollege.challenge + 1
end

function UserObj:lvPrecent()
	local lvConf = GameData:getConfData("level")[self.level]
	local exp = lvConf.exp
	return self.xp/exp*100
end

function UserObj:updateLv()
	local levelUpFlag = false
	local lvConf = GameData:getConfData("level")
	local oldLv = self.level
	while self.xp >= lvConf[self.level].exp do
		self.xp = self.xp - lvConf[self.level].exp
		if self.level >= #lvConf then
			return
		end
		self.level = self.level + 1
		levelUpFlag = true
	end

	-- 七天乐
	if (not self.activity['open_seven'] or not self.activity['open_seven']['open_day'] or self.activity['open_seven']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		self.activity['open_seven'] = {}
		self.activity['open_seven']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
        self.activity['open_seven']['progress'] = {}
	end
    -- 许愿
	if (not self.activity['petition'] or not self.activity['petition']['open_day'] or self.activity['petition']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		self.activity['petition'] = {}
		self.activity['petition']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
        self.activity['petition']['got'] = 1
        self.activity['petition']['reward'] = {}
        self.activity['petition']['fan'] = 0
	end

    -- 酒馆招募等级活动
	if (not self.activity['tavern_recruit_level'] or not self.activity['tavern_recruit_level']['open_day'] or self.activity['tavern_recruit_level']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		self.activity['tavern_recruit_level'] = {}
		self.activity['tavern_recruit_level']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
        self.activity['tavern_recruit_level']['num'] = 0
        self.activity['tavern_recruit_level']['rewards'] = {}
        self.activity['tavern_recruit_level']['frequency'] = 0
	end

	if (not self.activity['money_buy'] or not self.activity['money_buy']['open_day'] or self.activity['money_buy']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		local activitiesLevelSchedule = GameData:getConfData('activities_level_schedule')
        local roundData = activitiesLevelSchedule['money_buy'][1]
        local startDay = roundData.startDay
        local endDay = roundData.endDay
        self.activity['money_buy'] = {}
        local now = os.date('*t', tonumber(GlobalData:getServerTime()))
        local day = 0
        if now.hour < 5 then
            day = 1
        end
		self.activity['money_buy']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime() + (startDay - day)*86400))
        GameData.data['activities'] = nil
        UserData:getUserObj().avconf['money_buy'].duration = endDay - startDay
	end

    if (not self.activity['money_buy2'] or not self.activity['money_buy2']['open_day'] or self.activity['money_buy2']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		local activitiesLevelSchedule = GameData:getConfData('activities_level_schedule')
        local roundData = activitiesLevelSchedule['three_money_buy'][1]
        local startDay = roundData.startDay
        local endDay = roundData.endDay
        self.activity['money_buy2'] = {}
        local now = os.date('*t', tonumber(GlobalData:getServerTime()))
        local day = 0
        if now.hour < 5 then
            day = 1
        end
		self.activity['money_buy2']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime() + (startDay - day)*86400))
        GameData.data['activities'] = nil
        UserData:getUserObj().avconf['three_money_buy'].duration = endDay - startDay
	end

    -- 招财龙开启
	if (not self.activity['lucky_dragon'] or not self.activity['lucky_dragon']['open_day'] or self.activity['lucky_dragon']['open_day'] == 0) and self.level >= 5 and oldLv < 5 then
		self.activity['lucky_dragon'] = {}
		self.activity['lucky_dragon']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
        self.activity['lucky_dragon']['use'] = 0
        self.activity['lucky_dragon']['last'] = 0
	end

    -- 人皇限购
	if (not self.activity['sky_limit_buy'] or not self.activity['sky_limit_buy']['open_day'] or self.activity['sky_limit_buy']['open_day'] == 0) and self.level >= 38 and oldLv < 38 then
		self.activity['sky_limit_buy'] = {}
		self.activity['sky_limit_buy']['open_day'] = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
        self.activity['sky_limit_buy']['rewards'] = {['1'] = -1, ['2'] = -1}
	end

    if self.level == 5 then -- 等于5级的时候开放
        self.activityGrowFundFirstOpen = true
    end

    if oldLv <= 19 and self.level >= 20 then
        self.friendToTwenty = true
    end

	local conf = GameData:getConfData('moduleopen')['statue']
	if oldLv == conf.level - 1 and self.level == conf.level then
		self.statueStatus = true
	end
end

function UserObj:getEgg()
	return self.egg
end

function UserObj:getWood()
	return self.wood
end

function UserObj:setName(name)
	self.name = name
end

function UserObj:getName()
	return self.name or ''
end

function UserObj:getUid()
	return self.uid
end

function UserObj:getCreateTime()
	return self.createTime
end

function UserObj:getFightforce()
	return RoleData:getFightForce() + self.fightForce
end

function UserObj:runFightforce(fightLabel,plId)
	-- 计算主君总战斗力
	local fightforce = RoleData:getFightForce() + self.fightForce
	if self.oldFightForce and fightforce ~= self.oldFightForce then
        self.runLock[plId] = true
        fightLabel:setString(self.oldFightForce)
        fightLabel:stopAllActions()
        fightLabel:setScale(1.1)
        fightLabel:runAction(cc.DynamicNumberTo:create('LabelAtlas', 1, fightforce, function()
            self.runLock[plId] = false
            fightLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                if self.runLock[plId] == true then
                    return
                end
                fightLabel:runAction(cc.ScaleTo:create(0.3,1))
                fightLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                	fightLabel:setString(fightforce)
                	self.oldFightForce = fightforce
                    end)))
            end)))
        end))
	else
		fightLabel:setString(fightforce)
		self.oldFightForce = fightforce
	end
end

-- 获取阵型
function UserObj:getFormation()
	local formationStr = cc.UserDefault:getInstance():getStringForKey(self.uid .. "_player_formation", "")
	if formationStr == "" then
		return {}
	else
		return string.split(formationStr, ",")
	end
end

function UserObj:setFormation(t)
	local str = table.concat(t, ",")
	cc.UserDefault:getInstance():setStringForKey(self.uid .. "_player_formation", str)
end

function UserObj:setnToken(token)
	self.ntoken = token
end

function UserObj:getnToken()
	return self.ntoken
end

function UserObj:sethToken(token)
	self.htoken = token
end

function UserObj:gethToken()
	return self.htoken
end

function UserObj:getTaverninfo()
	return self.tavern
end

function UserObj:setCountryCount(challenge)
	if not self.CountryInfo then
		self.CountryInfo = {}
	end
	self.CountryInfo.challenge = challenge
end

function UserObj:setArenaCD(time)
	self.arenaInfo.challenge_cd = time
end

function UserObj:initCountryInfo(json)
	self.CountryInfo = json
    if self.first_login == 1 and self:getActivityStatus('petition') == true then
        ActivityMgr:getActivityPetiton()
    end
end

function UserObj:setArenaCount(count)
	if not self.arenaInfo then
		self.arenaInfo = {}
	end
	self.arenaInfo.count = count
end

function UserObj:initArenaInfo(json)
	self.arenaInfo = json
end

function UserObj:getArena()
	return self.arena
end

function UserObj:getRescopyinfo()
	return self.rescopy
end

function UserObj:sethToken(token)
	self.htoken = token
end

function UserObj:getArenaLv()
	return self.arena_level
end

function UserObj:getOldArenaLv()
	return self.oldArenaLv
end

function UserObj:setOldArenaLv(lv)
	self.oldArenaLv = lv
end

function UserObj:getArenaXp()
	return self.arena_xp
end

function UserObj:getOldArenaXp()
	return self.oldArenaXp
end

function UserObj:setOldArenaXp(oldArenaXp)
	self.oldArenaXp = oldArenaXp
end

function UserObj:updateArenaLv()
	self.oldArenaLv = clone(self.arena_level)
	local lvConf = GameData:getConfData("arenalevel")
	while self.arena_xp >= lvConf[self.arena_level].xp do
		if lvConf[self.arena_level + 1] then
			self.arena_xp = self.arena_xp - lvConf[self.arena_level].xp
			if self.arena_level >= #lvConf then
				return
			end
			self.arena_level = self.arena_level + 1
		else
			return
		end
	end
end

function UserObj:cost(sztype, count, func, ipw, tip)
	if sztype == 'gold' or sztype == 'cash' or sztype == 'food' then
		-- if ipw then
		-- 	promptmgr:showMessageBox(tip, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
		-- 		UserObj:cost(sztype, count, func)
		-- 	end)
		-- 	return
		-- end
		if self[sztype] < count then
			local str = ''
			if sztype == 'gold' then
				str = GlobalApi:getLocalStr('STR_GOLD')
			elseif sztype == 'cash' then
				str = GlobalApi:getLocalStr('STR_CASH')
			elseif sztype == 'food' then
				str = GlobalApi:getLocalStr('STR_FOOD')
			end
			promptmgr:showMessageBox(
				str..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. str .. '？',
				MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				function ()
					--: todo
					-- post buy gold message
					-- UserObj:cost(sztype, count, func, ipw, tip)
					GlobalApi:getGotoByModule(sztype)
				end)
			return false
		end
		if ipw then
			promptmgr:showMessageBox(tip, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
				UserObj:cost(sztype, count, func)
			end)
			return
		end
		--self[sztype] = self[sztype] - count
		-- cost succ and RETURN TRUE
		return func and func() or true
	elseif sztype == 'vip' then
		if tonumber(self:getVip()) >= tonumber(count) then
			-- self.vip = self.food - count
			-- cost succ and RETURN TRUE
			return func and func() or true
		end

		promptmgr:showMessageBox(GlobalApi:getLocalStr('STR_NEED_VIP'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
				--: todo
				-- post buy gold message
				--UserObj:cost(sztype, count, ipw, func)
				RechargeMgr:showRecharge()
				return
			end)
		return func and func() and false
	end
end

function UserObj:getHeadpic()
	--temp filter
	local headId= (self.headpic==0 or self.headpic>100) and 1 or self.headpic
	local path=GameData:getConfData('settingheadicon')[headId].icon
	return path
end

function UserObj:getHeadpicId()
	return self.headpic
end

function UserObj:getHeadFrame()
    local headframeid = self.headframe
    return GlobalApi:getHeadFrame(headframeid)
end


function UserObj:getHeadFrameId()
    return self.headframe
end

function UserObj:setHeadFrameId(value)
    self.headframe = value
end

function UserObj:setTipsInfo(data)
    if data == nil then
        return
    end

	self.tips.main_task = data.main_task or self.tips.main_task or 0 -- 主线任务提醒
	self.tips.daily_task = data.daily_task or self.tips.daily_task or 0 -- 每日任务提醒
	self.tips.world_reward = data.world_reward or self.tips.world_reward or 0 -- 天下大势提醒
	self.tips.open_seven = data.open_seven or self.tips.open_seven or 0 -- 七天乐提醒
	self.tips.mine_report = data.mine_report or self.tips.mine_report or 0 -- 金矿有战报
	self.tips.arena_report = data.arena_report or self.tips.arena_report or 0 -- 竞技场有战报
	self.tips.ww_report = data.ww_report or self.tips.ww_report or 0 -- 武圣争霸积分赛有战报
	self.tips.ww_sup = data.ww_sup or self.tips.ww_sup or 0 -- 武圣争霸可以支持
	self.tips.shipper_report = data.shipper_report or self.tips.shipper_report or 0 -- 押镖有战报
	self.tips.country_report = data.country_report or self.tips.country_report or 0 -- 国家有战报
	self.tips.exploit_wall = data.exploit_wall or self.tips.exploit_wall or 0 -- 功勋墙奖励提醒
    self.tips.mine_report = data.mine_report or self.tips.mine_report or 0 -- 是否金矿被人攻打
    self.tips.legionwar_citybufnum = data.legionwar_citybufnum or self.tips.legionwar_citybufnum or 0 -- 玩家还有增筑次数
    self.tips.legionwar_attacknum = data.legionwar_attacknum or self.tips.legionwar_attacknum or 0 -- 玩家还有攻击次数
    self.tips.legionwar_cityaward = data.legionwar_cityaward or self.tips.legionwar_cityaward or 0 -- 玩家有攻破城池的奖励可领取
    self.tips.legionwar_canaddforce = data.legionwar_canaddforce or self.tips.legionwar_canaddforce or 0 -- 玩家还可以上阵人员
    self.tips.legionwar_fightnum = data.legionwar_fightnum or self.tips.legionwar_fightnum or 0 -- 战斗次数红点
    self.tips.exchange_points = data.exchange_points or self.tips.exchange_points or 0 -- 积分兑换红点
    self.tips.accumulate_recharge = data.accumulate_recharge or self.tips.accumulate_recharge or 0 -- 累计充值红点
    self.tips.friend_message = data.friend_message or self.tips.friend_message or 0     -- 好友消息红点（登陆只发一次）
    self.tips.friend_gift = data.friend_gift or self.tips.friend_gift or 0     -- 好友收礼物红点
    self.tips.friend_apply = data.friend_apply or self.tips.friend_apply or 0     -- 好友申请红点
    self.tips.legion_wish = data.legion_wish or self.tips.legion_wish or 0     -- 军团许愿有碎片奖励可领取红点
    self.tips.day_challenge = data.day_challenge or self.tips.day_challenge or 0     -- 每日挑战红点
    self.tips.day_vouchsafe = data.day_vouchsafe or self.tips.day_vouchsafe or 0     -- 每日特惠红点
    self.tips.campTaskAwards = data.campTaskAwards or self.tips.campTaskAwards or 0     -- 服战阵营任务奖励红点
    self.tips.personalTaskAwards = data.personalTaskAwards or self.tips.personalTaskAwards or 0     -- 服战个人任务奖励红点
    self.tips.first_pay = data.first_pay or self.tips.first_pay or 0
end

function UserObj:setSignByType(stype,value)
	print('===============xxxx',stype,value)
	self.tips[stype] = value
end

function UserObj:getCellSignByType(stype,ntype)
	local conf = GameData:getConfData("rescplist")
	local info = UserData:getUserObj():getRescopyinfo()
	local isOpen = GlobalApi:getOpenInfo(stype)
	local counts = {
		info.reborn.count - info.reborn.buy,
		info.xp.count - info.xp.buy,
		info.gold.count - info.gold.buy,
		info.destiny.count - info.destiny.buy
	}
	if isOpen and conf[ntype].limit - counts[ntype] > 0 then
		return true
	end
	return false
end

-- 判断小红点是否可以显示
function UserObj:getSignByType(stype)
	if stype == 'task' then
		if (self.tips.main_task and self.tips.main_task > 0) 
			or (self.tips.daily_task and self.tips.daily_task > 0) 
			or (self:getFoodShowStatus()) 
			or (self.tips.world_reward and self.tips.world_reward > 0) 
			then
			return true
		end
	elseif stype == 'world_reward' then
		if self.tips.world_reward and self.tips.world_reward > 0 then
			return true
		end
	elseif stype == 'main_task' then
		if self.tips.main_task and self.tips.main_task > 0 then
			return true
		end
	elseif stype == 'open_seven' then
		return self:getActivitySevenShowStatus()
	elseif stype == 'arena_report' then
		return (self.tips.arena_report and self.tips.arena_report > 0 )
	elseif stype == 'arena' then
		local count = 0
		if self.arenaInfo then
			count = self.arenaInfo.count
		end
		local extraTimes = tonumber(GlobalApi:getGlobalValue('arenaMaxCount'))
	    local num = extraTimes - count
        local nowTime = GlobalData:getServerTime()
		local challengeCD = self.arenaInfo.challenge_cd - nowTime
		return (self.tips.arena_report and self.tips.arena_report > 0 ) or ((num > 0) and challengeCD <= 0)
	elseif stype == 'statue' then
		return self.statueStatus
    elseif stype == 'digging' then
		return self:judgeDigging()
	elseif stype == 'goldmine' then
		return self:judgeGoldMine()
	elseif stype == 'goldmine_count' then
		return self:judgeGoldMineCount()
    elseif stype == 'goldmine_digging' then -- 金矿和挖矿
        local judge1 = self:judgeGoldMine()
        local judge2 = self:judgeDigging()
		return judge1 or judge2
	elseif stype == 'shipper' then
		local report = (self.tips.shipper_report and self.tips.shipper_report > 0 )
	    local shipper = self:getShipper()
	    local num1 = tonumber(GlobalApi:getGlobalValue("shipperDeliveryCount")) - shipper.delivery
	    local isOpen = GlobalApi:getOpenInfo('shipper')
	    return (report or (num1 > 0)) and isOpen
	elseif stype == 'boat' then
		local report = UserData:getUserObj():getSignByType('shipper')
		local rescopy = UserData:getUserObj():getSignByType('rescopy')
        local guard = UserData:getUserObj():getSignByType('guard')
		return report or rescopy or guard
    elseif stype == 'guard' then -- 巡逻
		return self:getGuardShowStatus() or self:getGuardRepressStatus()
	elseif stype == 'countrywarcamptask' then -- 阵营任务
		return (self.tips.campTaskAwards and self.tips.campTaskAwards > 0)
	elseif stype == 'countrywarpersonaltask' then -- 个人任务
		return (self.tips.personalTaskAwards and self.tips.personalTaskAwards > 0)
	elseif stype == 'countrywartask' then -- 任务
		return UserData:getUserObj():getSignByType('countrywarcamptask') or UserData:getUserObj():getSignByType('countrywarpersonaltask')
	elseif stype == 'country' then -- 国家
		return self:getCountryShowStatus()
	elseif stype == 'countrywar' then -- 服战
		return UserData:getUserObj():getSignByType('countrywartask')
    elseif stype == 'country_city' then -- 皇城
		return self:getCountryGoCityShowStatus()
    elseif stype == 'country_fight_report' then -- 战报
		return self:getCountryFightReportShowStatus()
    elseif stype == 'bag_item' then -- 
		local tab = BagData:getAllMaterial()
		for i,v in pairs(tab) do
			if v:getNew() and v:getUseable() == 1 and v:getShowable() == 1 then
				return true,false
			end
		end
		local tab1 = BagData:getAllDresses()
		for i,v in pairs(tab1) do
			if v:getNew() and v:getUseable() == 1 and v:getShowable() == 1 then
				return true,false
			end
		end
		return false
	elseif stype == 'bag' then
		local isFull = BagData:getEquipFull()
		if isFull then
			return true,true
		end
		return self:getSignByType('bag_item')
	elseif stype == 'hook' then
        local diffTime = GlobalData:getServerTime() - MapData.patrol
        if diffTime > tonumber(GlobalApi:getGlobalValue('patrolInterval')) * 60 * 60 and MapData.patrol ~= 0 then
        	return true
        end
    elseif stype == 'xpRescopy' then
    	return self:getCellSignByType(stype,2)
    elseif stype == 'rebornRescopy' then
    	return self:getCellSignByType(stype,1)
    elseif stype == 'goldRescopy' then
    	return self:getCellSignByType(stype,3)
    elseif stype == 'destinyRescopy' then
    	return self:getCellSignByType(stype,4)
    elseif stype == 'rescopy' then
        local stypes = {'rebornRescopy','xpRescopy','goldRescopy','destinyRescopy'}
        for i=1,#stypes do
        	if self:getCellSignByType(stypes[i],i) then
        		return true
        	end
        end
    elseif stype == 'worldwar_report' then
    	return (self.tips.ww_report and self.tips.ww_report > 0)
    elseif stype == 'exploit_wall' then
    	return (self.tips.exploit_wall and self.tips.exploit_wall > 0)
    elseif stype == 'worldwar_support' then
    	return (self.tips.ww_sup and self.tips.ww_sup > 0)
    elseif stype == 'worldwar_battle' then
		local maxMatchTimes = tonumber(GlobalApi:getGlobalValue('worldwarMatchLimitPerDay'))
		local maxBattleTimes = tonumber(GlobalApi:getGlobalValue('worldwarBattleLimitPerDay'))
		local canBattle = false
		local isRank = false
    	if (self.worldwar.battle < maxBattleTimes and self.worldwar.match < maxMatchTimes) 
    		or (self.worldwar.battle < maxBattleTimes and self.worldwar.fighted == 0) then
    		canBattle = true
    	end
        local bt = Time.beginningOfWeek()
        local dt = WorldWarMgr:getScheduleByProgress(32)
        local startTime = bt + (tonumber(dt.endWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
        local nowTime = GlobalData:getServerTime()
        if nowTime < startTime then
            isRank = true
        end
    	return canBattle and isRank
    elseif stype == 'worldwar' then
    	local report = UserData:getUserObj():getSignByType('worldwar_report')
    	local wall = UserData:getUserObj():getSignByType('exploit_wall')
    	local sup = UserData:getUserObj():getSignByType('worldwar_support')
    	local battle = UserData:getUserObj():getSignByType('worldwar_battle')
    	return report or wall or sup or battle
    elseif stype == 'train' then
    	local conf = GameData:getConfData("training")
		local lv=UserData:getUserObj():getLv()
		local vip=UserData:getUserObj():getVip()
		local isFree = false
    	for i=1,6 do
			local data = self.train[tostring(i)]
            if data[3] == 1 then
			    local isLock = false
			    if vip < conf[i].vip or lv < conf[i].level then
				    isLock = true
			    end
			    if not isLock then
				    local time = data[2]
				    local diffTime = time - GlobalData:getServerTime()
				    if diffTime <= 0 then
					    isFree = true
					    break
				    end
			    end
            end
    	end
    	return isFree
    elseif stype == 'tower' then
        if self.towerInfo.failed == 1 then  -- 失败
            return false
        else    -- 成功
            return true
        end
    	--local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]
    	--return self.towerInfo.reset < vipconf.towerReset
    elseif stype == 'blacksmith' then
	    local isUp = false
	    local equipConf = GameData:getConfData("equip")[tonumber(self.make.equip)]
	    local tab = {}
	    for k,v in pairs(self.make.subattr) do
	    	tab[tonumber(k)] = (tab[tonumber(k)] or 0) + v
	    end
	    tab[equipConf.attributeType] = equipConf.attributeValue
	    for i=1,RoleData:getRoleNum() do
	    	local roleObj = RoleData:getRoleByPos(i)
	    	if roleObj and tonumber(roleObj:getId()) > 0 then
	    		local eauiped = roleObj:getEquipByIndex(tonumber(equipConf.type))
	    		if eauiped then
					local up = GlobalApi:getProFightForce(tab,eauiped,tonumber(equipConf.quality) - 1)
					local diffLevel = tonumber(equipConf.level) - UserData:getUserObj():getLv()
					isUp = up and (diffLevel <= 10)
					if isUp then
		                break
		            end
	    		else
	    			isUp = true
	    			break
	    		end
	    	end
	    end
	    local isEnough = self.smelt >= self.make.smelt_cost
	    return isUp and isEnough
    elseif stype == 'mail' then
    	local hadNewMail = UserData:getUserObj():getHadNewMail() or false
    	return hadNewMail
    elseif stype == 'tavern_free' then
    	return self:judgeTavenFreeState()
    elseif stype == 'tavern_ten' then
    	return self:judgeTavenTenState()
    elseif stype == 'tavern_limit' then
    	return self:judgeTavenLimitState()
    elseif stype == 'tavern' or stype == 'pub' then
        return self:judgeTavenFreeState() or self:judgeTavenTenState() or self:judgeTavenLimitState()
        or self:judgeExclusiveNormalFreeState() or self:judgeExclusiveMiddleFreeState() or self:judgeExclusiveSuperFreeState()
    elseif stype == 'real_tavern' then
        return self:judgeTavenFreeState() or self:judgeTavenTenState() or self:judgeTavenLimitState()
    elseif stype == 'exclusive_check' then
        return self:judgeExclusiveNormalFreeState() or self:judgeExclusiveMiddleFreeState() or self:judgeExclusiveSuperFreeState()
    elseif stype == 'exclusive' then
        return self:judgeExclusiveStatus()
	elseif stype == 'treasure' then
	    local treasureInfo = UserData:getUserObj():getTreasure()
	    local id = tonumber(treasureInfo.id)
	    local dragonInfo = RoleData:getDragonMap()[id]
	    if not dragonInfo and id > 2 then
	    	return true
	    else
	    	return false
	    end
    elseif stype == 'countryJade' then -- 合璧红点
        return self:judgeCountryJade()
    elseif stype == 'firstrecharge' then -- 首冲
        return self:getActivityFirstPayShowStatus()
    elseif stype == 'sign' then -- 签到
        return self:getActivitySignShowStatus()

    elseif stype == 'levelgift' then -- 等级礼包
        return self:getActivityLevelGiftShowStatus()

    elseif stype == 'limit_buy' then -- 每日限购
        return self:getActivitLimitBuyShowStatus() 

    elseif stype == 'petition' then -- 许愿（情愿东风）
        return self:getActivityPetitionShowStatus() 

    elseif stype == 'activitys' then -- 主界面活动按钮
		local activityDatas = GameData:getConfData("local/activityentry")
		for key,activityData in pairs(activityDatas) do
			if(activityData["type"] == 2) then
				if self:getSignByType(key) == true then
					return true
				end
			end
		end
		return false
    elseif stype == 'week' then -- 每周礼包
        return self:getActivityWeekShowStatus()

    elseif stype == 'privilege' then -- 特权礼包
        return self:getActivityPrivilegeShowStatus()

    elseif stype == 'value_package' then -- 超值礼包
        return self:getActivitySaleShowStatus()
    elseif stype == 'value_package_new' then -- 超值礼包新
        return self:getActivitySaleNewShowStatus()
    elseif stype == 'sale' then -- 买买买
        local activityDatas = GameData:getConfData("local/activityentry")
		for key,activityData in pairs(activityDatas) do
			if(activityData["type"] == 1) then
				if self:getSignByType(key) == true then
					return true
				end
			end
		end
		return false

    elseif stype == 'todaydouble' then -- 今日双倍
        return self:getActivityTodayDoubleShowStatus()
    elseif stype == 'login_goodgift' then -- 登陆好礼
        return self:getActivityLoginGoodGiftShowStatus()
    elseif stype == 'limit_seckill' then -- 限时秒杀
        return self:getActivityLimitSeckillShowStatus()
    elseif stype == 'pay_only' then -- 充值专享
        return self:getActivityPayOnlyShowStatus()
    elseif stype == 'limit_group' then -- 限时团购
        return self:getActivityLimitGroupShowStatus()
    elseif stype == 'lucky_wheel' then -- 幸运轮盘
        return self:getActivityLuckyWheelShowStatus()
    elseif stype == 'grow_fund' then -- 成长基金
        return self:getActivityGrowFundShowStatus()
    elseif stype == 'lv_grow_fund' then -- 等级豪礼
    	return self:getActivityLvGrowFundShowStatus()
    elseif stype == 'accumulate_recharge' then -- 累计活动
        return self:getActivityAcumulateRechargeShowStatus()
    elseif stype == 'daily_recharge' then -- 每日充值
        return self:getActivityDailyRechargeShowStatus()
    elseif stype == 'single_recharge' then -- 单充好礼
        return self:getActivitySingleRechargeShowStatus()
    elseif stype == 'expend_gift' then -- 消费有礼
        return self:getActivityExpendGiftShowStatus()
    elseif stype == 'tavern_recruit' then -- 酒馆招募
        return self:getActivityTavernRecruitShowStatus()
    elseif stype == 'tavern_recruit_level' then -- 酒馆招募等级活动
        return self:getActivityTavernRecruitLevelShowStatus()
    elseif stype == 'exchange_points' then -- 积分兑换
        return self:getActivityExchangePointsShowStatus()
    elseif stype == 'day_challenge' then -- 每日挑战
        return self:getActivityDayChallengeShowStatus()
    elseif stype == 'day_vouchsafe' then
        return self:getActivityDayVouchasafeShowStatus()
    elseif stype == 'surprise_step' then
        return self:getActivitySurpriseStepShowStatus()
    elseif stype == 'daily_cost' then
        return self:getActivityDailyCostShowStatus()
    elseif stype == 'promote_exchange' then
        return self:getActivityPromoteExchangeShowStatus()
    elseif stype == 'human_wing' then
        return self:getActivityHumanWingShowStatus()
    elseif stype == 'human_arms' then
        return self:getActivityHumanArmsShowStatus()
	elseif stype == 'surprise_turn' then
        return self:getActivitySurpriseTurnShowStatus()
	elseif stype == 'buy_hot_free' then
        return self:getActivityBuyHotFreeShowStatus()
	elseif stype == 'invincible_gold_will' then
        return self:getActivityInvincibleGoldWillShowStatus()
	elseif stype == 'integral_carnival' then
        return self:getActivityIntegralCarnivalShowStatus()
	elseif stype == 'christmas_tree' then
        return self:getActivityChristmasTreeShowStatus()
	elseif stype == 'surprise_box' then
        return self:getActivitySurpriseBoxShowStatus()
    elseif stype == 'time_limit_activitys' then -- 限时活动图标
        return self:getActivityLoginGoodGiftShowStatus() 
        or self:getActivityTodayDoubleShowStatus() 
        or self:getActivityPayOnlyShowStatus() 
        or self:getActivityAcumulateRechargeShowStatus() 
        or self:getActivitySaleShowStatus() 
        or self:getActivityDailyRechargeShowStatus() 
        or self:getActivityLimitGroupShowStatus() 
        or self:getActivityLuckyWheelShowStatus() 
        or self:getActivityExpendGiftShowStatus() 
        or self:getActivityTavernRecruitShowStatus() 
        or self:getActivityExchangePointsShowStatus() 
        or self:getActivitySingleRechargeShowStatus() 
        or self:getActivityDailyCostShowStatus()
        or self:getActivityDayVouchasafeShowStatus()
        or self:getActivityPromoteExchangeShowStatus()
        or self:getActivitySurpriseStepShowStatus()
        or self:getActivityHumanWingShowStatus()
        or self:getActivityHumanArmsShowStatus()
		or self:getActivitySurpriseTurnShowStatus()
		or self:getActivityChristmasTreeShowStatus()
		or self:getActivitySurpriseBoxShowStatus()
		or self:getActivityBuyHotFreeShowStatus()
		or self:getActivityInvincibleGoldWillShowStatus()
		or self:getActivityIntegralCarnivalShowStatus()
    elseif stype == 'altar' then
    	local havenew = false
	    local altarconf = GameData:getConfData('altar')
	    for i=1,4 do
	        if UserData:getUserObj():getLv() >= altarconf[i].level then
	            if self.altar and self.altar[tostring(i)] then
	                local count = tonumber(self.altar[tostring(i)])
	                if count < altarconf[i].free then
	                    havenew = true
	                    return havenew
	                end
	            else
            		havenew = true
                    return havenew
	            end
	        end
	    end
	    return havenew
	elseif stype == 'legion' then
		return self:getLegionShowStatus()
	elseif stype == 'legion_fightnum' then
		return self:getLegionWarFightnumStatus()
	elseif stype == 'legion_war_city' then
		return self:getLegionWarCityStatus()
	elseif stype == 'legion_war' then
		return self:getLegionWarCityStatus() or self:getLegionWarFightnumStatus()
	elseif stype == 'legion_boon' then
		return self:getLegionBoonStatus()
	elseif stype == 'legion_construct' then
		return self:getLegionConstructStatus()
	elseif stype == 'legion_goldtree' then
		return self:getLegionGoldTreeStatus()
	elseif stype == 'legion_trial' then
		return self:getLegionTrialStatus()
	elseif stype == 'legion_mercenary' then
		return self:getLegionMercenaryStatus()
	elseif stype == 'legion_copy' then
		return self:getLegionCopyStatus()
    elseif stype == 'legion_wish' then
		return self:getLegionWishState()
    elseif stype == 'chip' then   --  碎片
		return self:getChipShowStatus()
    elseif stype == 'legionTrial' then   --  秘境探险红点
        return self:getLegionTrialShowStatus()
    elseif stype == 'legion_member_hall' then
        return self:getLegionMemberHallStatus()
	elseif stype == 'lucky_dragon' then
		if self:getActivityStatus(stype) then
			if self.activity[stype] then
				local conf = GameData:getConfData("avluckydragon")
				if conf and self.activity[stype]["use"] < GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())].luckyDragon then
					return true
				end
			end
		end
    elseif stype == 'friend' then
        return self:judgeFriendState()
    elseif stype == 'report' then
		return UserData:getUserObj():getSignByType('arena_report') or UserData:getUserObj():getSignByType('country_fight_report') or UserData:getUserObj():getSignByType('worldwar_report')
    elseif stype == 'money_buy' then
        return self:getMoneyBuyShowStatus()
    elseif stype == 'three_money_buy' then
        return self:getThreeMoneyBuyShowStatus()
    elseif stype == 'eight_money_buy' then
        return self:getEightMoneyBuyShowStatus()
    elseif stype == 'promote_get_soul' then
        return self:getPromoteGetSoulShowStatus()
    elseif stype == 'happy_wheel' then -- 如意轮盘
        return self:getActivityLuckyWheelShowStatus()
    elseif stype == 'weapon' then
    	return self:getPeopleKingBtn(1) or self:getPeopleKingBtn(2)
    end
	return false
end

function UserObj:getLegionBoonStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['legionBoonOpenLevel'].value) then
			if self.boon >= 10 then
				return true
			end
		end
	end
	return false
end

function UserObj:getLegionConstructStatus()
	local conf = GameData:getConfData('legion')
	local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]
	if self.lid > 0 and self.legioninfo then
		-- print('vipconflegionConstruct'..vipconf['legionConstruct'])
		-- print('construct_count'..self.legioninfo.construct_count)
		if vipconf['legionConstruct'] - self.legioninfo.construct_count > 0 then
			return true
		end
	end
	return false
end

function UserObj:getLegionGoldTreeStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['legionGoldTreeOpenLevel'].value) then
			if self.legioninfo.shake_tree < tonumber(conf['shakeGoldTreeCount'].value) and self.lgold_tree.outcome > 0 then
				if	GlobalData:getServerTime() - self.legioninfo.shake_time > tonumber(conf['shakeGoldTreeInterval'].value*60 ) then
					return true
				end
			end
		end
	end
	return false
end

function UserObj:getLegionTrialStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['legionTrialOpenLevel'].value) then
			if self.legioninfo.trial_count < tonumber(conf['legionTrialMaxCount'].value) then
				return true
			end
            --[[
			for i=1,5 do
                if self.legioninfo.trial_stars >= i*3 then
                    if self.legioninfo.trial_award == nil or (self.legioninfo.trial_award ~= nil and tonumber(self.legioninfo.trial_award[tostring(i*3)]) ~= 1) then
						return true
                    end
                end
            end
            --]]
		end
	end
	return false
end

function UserObj:getLegionMercenaryStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['legionMercenaryOpenLevel'].value) then
			local mercenaryarr = {}
		    if self.legioninfo.mercenary then
		        for k,v in pairs (self.legioninfo.mercenary) do 
		            local arr = {}
		            arr[1] = k
		            arr[2] = v
		            table.insert( mercenaryarr,arr)
		        end
		    end
		    local vip = UserData:getUserObj():getVip()
		    local num = GameData:getConfData('vip')[tostring(vip)].mercenary
		    if #mercenaryarr < num then
				return true
			end
		end
	end
	return false
end

function UserObj:getLegionCopyStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['legionCopyOpenLevel'].value) then
			if self.legioninfo.copy_count < tonumber(conf['legionCopyFightLimit'].value) then
				return true
			end
		end
	end
	return false
end

function UserObj:getLegionWarCityStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo and self.llevel >= tonumber(conf['legionWarMinJoinLevel'].value) then
	    local status1 = self.tips.legionwar_citybufnum and self.tips.legionwar_citybufnum > 0
	    local status2 = self.tips.legionwar_attacknum and self.tips.legionwar_attacknum > 0
	    local status3 = self.tips.legionwar_cityaward and self.tips.legionwar_cityaward > 0
	    local status4 = self.tips.legionwar_canaddforce and self.tips.legionwar_canaddforce > 0
	    return status1 or status2 or status3 or status4
	end
	return false
end

function UserObj:getLegionWarFightnumStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
	    return self.tips.legionwar_fightnum and self.tips.legionwar_fightnum > 0
	end
	return false
end

function UserObj:getLegionShowStatus()
	local status1 = self:getLegionBoonStatus()
	local status2 = self:getLegionGoldTreeStatus()
	local status3 = self:getLegionTrialStatus()
	local status4 = self:getLegionMercenaryStatus()
	local status5 = self:getLegionCopyStatus()
	local status6 = self:getLegionConstructStatus()
    local status7 = self:getLegionTrialShowStatus()
    local status8 = self:getLegionMemberHallStatus()
    local status9 = self:getSignByType('legion_wish')
    local fighted = MapData:getFightedCityId()
    local firstJoin = cc.UserDefault:getInstance():getBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',false)
    local isOpen = GlobalApi:getOpenInfo('legion')
    local status10 = isOpen and not firstJoin
	-- 军团城池相关
	-- if self.legioninfo.castle_rescue < conf['legionCastleRescueCount']value then
	-- 	return true
	-- end	
	-- if self.legioninfo.castle_occupy < conf['legionCastleAttackCount']value then
	-- 	return true
	-- end	
	return status1 or status2 or status3 or status4 or status5 or status6 or status7 or status8 or status9 or status10
end

function UserObj:getChipShowStatus()
    local status = false
    local allfragment = BagData:getFragment()
	for k, v in pairs(allfragment) do
		if v:getId() < 10000 then
			if self:getSingleChipShowStatus(v) == true then
                status = true
                break
            end
		end
	end

    return status
end

-- 得到单个碎片是否提醒
function UserObj:getSingleChipShowStatus(chipObj)
    local roleObj = RoleData:getRoleById(chipObj:getId())
    local cardObj = BagData:getCardById(chipObj:getId())
    if roleObj or cardObj then
        return false
    else
        local num = chipObj:getNum()
	    local mergenum = chipObj:getMergeNum()
        if num >= mergenum then
            return true
        else
            return false
        end
        return false
    end
end

-- 判断传入的id，是否有武将，或者武将有对应的特殊缘分(特殊缘分武将也要上阵)
function UserObj:judgeIsHasRoleOrSpecialFate(id)
    local roleObj = RoleData:getRoleById(tonumber(id))
    if roleObj then
        return true
    else
        local data = GameData:getConfData('hero')[tonumber(id)]
        local innateGroupId = data['innateGroup']
	    local groupconf = GameData:getConfData('innategroup')[innateGroupId]
        local teamheroID = groupconf['teamheroID']
        if teamheroID > 0 and RoleData:getRoleById(teamheroID) then
            return true
        else
            return false
        end
    end
end

function UserObj:getLegionTrialShowStatus()
    local isOpen,_,cityId,level = GlobalApi:getOpenInfo("legionTrial")
    if not isOpen then
        return false
    end

    local judge = false

    -- 有剩余探索次数
    if self.legioninfo.trial.explore_count < LegionTrialMgr:getLegionTrialAllEcploreCount() then
        judge = true
    end

    return judge or self:getLegionTrialAdventureShowStatus() or self:getLegionTrialAchievementShowStatus()
end


function UserObj:getLegionMemberHallStatus()
	local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		return false
	end
	return false
end

function UserObj:getLegionTrialAdventureShowStatus()
    local isOpen,_,cityId,level = GlobalApi:getOpenInfo("legionTrial")
    if not isOpen then
        return false
    end

    local judge = false
    local adventure = self.legioninfo.trial.adventure
    for k,v in pairs(adventure) do
        local time = v.time
        local nowTime = GlobalData:getServerTime()
        if nowTime < time and v.type == 2 then
            if v.pass == 1 then     -- 已经通关,未领取 
                if v.award_got == 0 then
                    judge = true
                    break
                end
            else
                judge = true
                break
            end
        end
    end

    return judge
end

function UserObj:getLegionTrialAchievementShowStatus()
    local isOpen,_,cityId,level = GlobalApi:getOpenInfo("legionTrial")
    if not isOpen then
        return false
    end

    local judge = false

    local achievement = self.legioninfo.trial.achievement
    local legionTrialAchievementType = GameData:getConfData('legiontrialachievementtype')
    local legionTrialAchievement = GameData:getConfData('legiontrialachievement')

    for i = 1,#legionTrialAchievementType do
        local achivementConfData = legionTrialAchievement[i]

        local allNum = #achivementConfData
        local achivementSeverData = achievement[tostring(i)]
        local award_got_level = 0
        local progress = 0
        if achivementSeverData then
            award_got_level = achivementSeverData.award_got_level
            progress = achivementSeverData.progress
        end
        local isHasGet = false
        local award_got_level = award_got_level + 1
        if award_got_level >= allNum then
            award_got_level = allNum
            isHasGet = true
        end
        local gotLevelData = achivementConfData[award_got_level]

        if gotLevelData.target <= progress and progress > 0 then 
            if isHasGet == true then
            else
                judge = true
                break
            end
        end
    end

    return judge
end

function UserObj:getMainCityInfo(callback)
    local args = {}
    MessageMgr:sendPost('get_main_city','user',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
        	self.food = data.food or 0
            self.digging = data.digging or 0
        	if self.mark then
				self.mark.food_time = data.food_time
                self.mark.digging_time = data.digging_time
			end
			if data.tips then
				self:setTipsInfo(data.tips)
			end
        	UIManager:getSidebar():resetFoodRestore()
			if callback then
				callback()
			end
        end
    end)
end

function UserObj:judgeDigging()
    -- 判断挖矿是否开启
    if GlobalApi:getOpenInfo('digging') == false then
        return false
    end
    -- 改功能,先将红点屏蔽
    return false
end

function UserObj:judgeGoldMine()
    -- 判断金矿是否开启
    if GlobalApi:getOpenInfo('goldmine') == false then
        return false
    end

    local judge1 = (self.tips.mine_report and self.tips.mine_report > 0 )
    -- 免费时间，则有红点
    return judge1 or self.goldMineStatus
end

function UserObj:judgeGoldMineCount()
	-- 判断金矿是否开启
	if GlobalApi:getOpenInfo('goldmine') == false then
        return false
    end
    return self.goldMineCountStatus
end

function UserObj:judgeCountryJade()
    -- 判断合璧是否开启
    if GlobalApi:getOpenInfo('countryJade') == false then
        return false
    end
    local country_jade = self.country_jade
    if country_jade < tonumber(GlobalApi:getGlobalValue("countryJadeFreeCount")) then
        return self.countryJadeStatus
    else
        return false
    end
end

-- 战报
function UserObj:judgeGoldMineIsHasReport()
    -- 判断金矿是否开启
    if GlobalApi:getOpenInfo('digging') == false then
        return false
    end

    local judge = (self.tips.mine_report and self.tips.mine_report > 0 )
    return judge
end

-- 活动是否开放
function UserObj:getActivityStatus(stype)
    local conf = GameData:getConfData('activities')[stype]
    if not conf then
        return false
    end
    local level = UserData:getUserObj():getLv()
    if level < conf.openLevel then
        return false
    end

    local openDay = conf.openDay
    local duration = conf.duration
    local delayDays = conf.delayDays
    local openLoginDay = conf.openLoginDay

    local openServerTime = UserData:getUserObj():getServerOpenTime()
    local nowTime = Time.getCorrectServerTime()

    if openDay ~= 0 then    -- openDay等于0表示就是开服活动
        local now = Time.date('*t', openServerTime)
        local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
        local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})

        local endTime = GlobalApi:convertTime(1,conf.endTime)
        local delayTime = conf.delayDays * 86400
        if conf.startTime and conf.startTime ~= 0 then  -- 如果有开启时间，openDay表示开服时间距离开启时间的天数
            local startTime = GlobalApi:convertTime(1,conf.startTime)
            if conf.type == 1 then
                if (nowTime - newOpenServerTime < openDay * 86400) or (newOpenServerTime > (endTime + delayTime)) then
                    return false
                end
            else
                if startTime - newOpenServerTime < openDay * 86400 then
                    return false
                end
            end
        else    -- openDay现在时间距离开服时间的天数
            if conf.type == 1 then
                if (nowTime - newOpenServerTime < openDay * 86400) or (newOpenServerTime > (endTime + delayTime)) then
                    return false
                end
            else
                if nowTime - newOpenServerTime < openDay * 86400 then
                    return false
                end
            end
        end
    end

    if conf.type == 0 then -- 开服活动
        local openServerTime = UserData:getUserObj():getServerOpenTime()
        local now = Time.date('*t', openServerTime)
        local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
        local newOpenServerTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})

        local beginTime = Time.activityBeginningOfOneDay(newOpenServerTime) + openDay*24*3600
        if nowTime - beginTime > (conf.duration + conf.delayDays)* 86400 then
            return false
        end
    elseif conf.type == 1 then -- 限时活动
        local startTime = GlobalApi:convertTime(1,conf.startTime)
        local endTime = GlobalApi:convertTime(1,conf.endTime)
        local delayTime = conf.delayDays * 86400
        if nowTime < startTime or nowTime > (endTime + delayTime) then
            return false
        end
    elseif conf.type == 2 then -- 等级活动
    	local time = 0
        local stype2 = stype
        if stype == 'three_money_buy' then
            stype2 = 'money_buy2'
        end
    	if self.activity and self.activity[stype2] and self.activity[stype2]['open_day'] then
    		time = self.activity[stype2]['open_day']
    	end
    	if time ~= 0 then
    		local beginTime = GlobalApi:convertTime(2,time) + openDay*24*3600 + 5*3600
	    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400 
	    	if nowTime < beginTime or nowTime > endTime then
	    		return false
	    	end
        else
            return false
    	end
    elseif conf.type == 3 then
    	local time = 0
        local stype2 = stype
        if stype == 'three_money_buy' then
            stype2 = 'money_buy2'
        end
    	if self.activity and self.activity[stype2] and self.activity[stype2]['time'] then
    		time = self.activity[stype2]['time']
    	end
    	if time ~= 0 then
            --[[
    		local beginTime = time
	    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400
	    	if nowTime < beginTime or nowTime > endTime then
	    		return false
	    	end
            --]]

            local createTime = UserData:getUserObj():getCreateTime()
            local now = Time.date('*t',createTime)
            local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
            local refTime = GlobalData:getServerTime() - Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
            if(now.hour < resetHour) then
                refTime = refTime + 24*3600
            end
        
            if refTime < openLoginDay*24*3600 then
                return false
            else
                if refTime < openLoginDay*24*3600 + (conf.duration + conf.delayDays)*86400 then
                else
                    return false
                end
            end
        else
            return false
    	end
    elseif conf.type == 4 then
    	local time = 0
    	if self.activity and self.activity[stype] and self.activity[stype]['time'] then
    		time = self.activity[stype]['time']
    	end
    	if time ~= 0 then
    		local beginTime = GlobalApi:convertTime(2,time) + openDay*24*3600
	    	local endTime = beginTime + (conf.duration + conf.delayDays)* 86400 + 5*3600
	    	if nowTime < beginTime or nowTime > endTime then
	    		return false
	    	end
        else
            return false
    	end
    else
        return false
    end
    return true
end

function UserObj:getActivityFirstPayShowStatus()
    if UserObj:getActivityStatus('first_pay') == false then
        return false
    end

    if self.tips.first_pay == 1 then
        return true
    end

    local val = self:getMark().first_pay
    if val == 1 then
		return true
	end

    if val == 2 then
        local progress = self.activity.first_pay and self.activity.first_pay.progress or {}
        local rewards = self.activity.first_pay and self.activity.first_pay.rewards or {}

        local tempData = GameData:getConfData('avfirstpay')
        for i = 1,#tempData do
            local v = tempData[i]
            local target1 = v.target1
            local target2 = v.target2
            local progress2 = progress[tostring(i)]

            local progress1 = progress2[tostring(1)] or 0
            local progress2 = progress2[tostring(2)] or 0
            if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
                if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                else
                    return true
                end
            end
        end
    end
    return false     
end

function UserObj:judgeFirstPayIsOpen()
    if UserObj:getActivityStatus('first_pay') == false then
        return false
    end

    local progress = self.activity.first_pay and self.activity.first_pay.progress or {}
    local rewards = self.activity.first_pay and self.activity.first_pay.rewards or {}

    local tempData = GameData:getConfData('avfirstpay')

    local judge = false
    local val = self:getMark().first_pay
    if val == 2 then
        for i = 1,#tempData do
            local v = tempData[i]
            local target1 = v.target1
            local target2 = v.target2
            local progress2 = progress[tostring(i)]

            local progress1 = progress2[tostring(1)] or 0
            local progress2 = progress2[tostring(2)] or 0
            if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
                if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                else
                    judge = true
                    break
                end
            else
                judge = true
                break
            end
        end
    else
        return true
    end

    return judge
end

-- 活动显示状态标记
function UserObj:getActivitySignShowStatus()
    if UserObj:getActivityStatus('sign') == false then
        return false
    end

    local signconf = GameData:getConfData('sign')
	local signdata = self:getSign()

    local everySignState = false
    local continueSignState = false

    local num = #signconf
    for index=1,num,1 do
        if index <= Time.getCurDay() then
            if index == signdata.count+1 and (tonumber(signdata.day) ~= tonumber(Time.getDayToModifiedServerDay())) then
                everySignState = true
            end
        end
    end

    if signdata.continuous_reward == 0 then
        continueSignState = true
	end
    return everySignState or continueSignState
end

function UserObj:getActivityLevelGiftShowStatus()
    local cfg = GameData:getConfData("avlevelgift")

    if self:getActivityStatus('level') then 
        local level_gift = self.activity.level_gift
        local lv = self:getLv()

        local allIsGanGet = false

        for k,v in pairs(cfg) do
		    local isGetGift=false		
		    for m,n in pairs(level_gift) do
			    if tonumber(m)==tonumber(k) then
				    isGetGift=true
			    end
		    end

            local isCanGet
            if lv>=v.level then
		        if isGetGift==true then
			        allIsGanGet = false
		        else -- 可以领取
			        allIsGanGet = true
                    break
		        end
	        else
		        allIsGanGet = false
	        end

	    end
        if allIsGanGet == true and self:judgeLevelGiftIsFinished() == false then
            return true
        else
            return false
        end
    else
        return false
    end
end

function UserObj:judgeLevelGiftIsFinished()
    local cfg = GameData:getConfData("avlevelgift")

    if self:getActivityStatus('level') then 
        local level_gift = self.activity.level_gift
        local lv = self:getLv()

        local judge = true

        for k,v in pairs(cfg) do
		    local isGetGift = false
            		
		    for m,n in pairs(level_gift) do
			    if tonumber(m)==tonumber(k) then
				    isGetGift=true
			    end
		    end

            local isCanGet
            if lv>=v.level then
		        if isGetGift == true then
		        else
			        judge = false
                    break
		        end
	        else
		        judge = false
                break
	        end
	    end
        return judge
    else
        return true
    end
end

function UserObj:getActivitLimitBuyShowStatus()
    if self:getActivityStatus('limit_buy') == false then
        return false
    end
    
    local serverDay = tonumber(Time.getDayToModifiedServerDay())

    local limit_buy = self.activity.limit_buy

    if limit_buy.day == serverDay then
        return false
    else
        return true
    end  
end

function UserObj:getActivityPetitionShowStatus()
    if self:getActivityStatus('petition') == false then
        return false
    end

    local petition = self.activity.petition

    --if petition.day ~= tonumber(Time.getDayToModifiedServerDay()) then -- 防止第1次登录出错
        --ActivityMgr:getActivityPetiton()
        --return false
   -- end


    local isGet = false
    if tonumber(petition.got) > 0 then
        isGet = false
    else
        isGet = true
    end


    -- 次数许愿
    local isPetiton = false
    if #petition.reward == 10 then
        isPetiton = false
    else
        isPetiton = (petition.fan > 0) and true or false
    end

    -- 延迟天数不能许愿
    if ActivityMgr:judgeActivityIsPetiton() == true then
        isPetiton = false
    end

    local value = isGet or isPetiton


    -- 通关小于24关，不能领取
    local currProgress = MapData:getFightedCityId()
    if currProgress == nil or currProgress and currProgress < 24 then -- 未达到24关
        return false
    end

    if value == true then
        return value
    else       
        if isGet == false and #petition.reward == 10 then -- 这种情况不请求了，因为这种情况许愿已经领取了，并且有10次了

        else
            if ActivityMgr:judgeActivityIsPetiton() == true then
                
            else
                ActivityMgr:getActivityPetiton()
            end

        end

        return false
    end
end

function UserObj:getActivityWeekShowStatus()
    if self.vip == 0 then -- vip等级限制,为0就不能买
       return false
    end
    -- 1，2，3，4，5，6，0  周日7是0

    local update = self.activity.week_gift.update

    local wday = tonumber(Time.date('%w', GlobalData:getServerTime())) -- 这个日期是周几

    local nowWeekDayTime = GlobalData:getServerTime()
    if wday == 2 or wday == 3 or wday == 4 or wday == 5 or wday == 6 then
        nowWeekDayTime = GlobalData:getServerTime() - 24*3600*(wday - 1)
    elseif wday == 0 then
        nowWeekDayTime = GlobalData:getServerTime() - 24*3600*6
    end

    local nowWeekDayOne = tonumber(Time.date('%Y%m%d', nowWeekDayTime))

    local updateDay = tonumber(Time.date('%Y%m%d',update)) -- 服务器更新的时间

    if updateDay and updateDay >= nowWeekDayOne then
        return false
    else
        return true
    end
end

function UserObj:getActicityInfoByKey(key)
	return self.activity[key]
end

function UserObj:setActicityInfoByKey(key,data)
	self.activity[key] = data
end

function UserObj:judgeSkyLimitBuyIsGet()
    if self:getActivityStatus('sky_limit_buy') == false then
        return false
    end

    local num = 0
    for k,v in pairs(self.activity.sky_limit_buy.rewards) do
    	if v == 1 then
    		num = num + 1
    	end
    end
    if num < 2 then
        return true
    end
    return false
end

function UserObj:getActivityPrivilegeShowStatus()
    if self.lastVip ~= self.vip and self:judgePrivilegeActivityIsFinished() == false then
        return true
    end
    return false
end

function UserObj:getMoneyBuyShowStatus()
    if self:getActivityStatus('money_buy') == false then
        return false
    end
    if self.activity.money_buy.status == 1 then
        return true
    end
    return false
end

function UserObj:judgeMoneyBuyIsGet()
    if self:getActivityStatus('money_buy') == false then
        return false
    end

    if self.activity.money_buy.status == 2 then
        return false
    end
    return true
end

function UserObj:getThreeMoneyBuyShowStatus()
    if self:getActivityStatus('three_money_buy') == false then
        return false
    end
    if self.activity.money_buy2.status == 1 then
        return true
    end
    return false
end

function UserObj:getEightMoneyBuyShowStatus()
    if self:getActivityStatus('eight_money_buy') == false then
        return false
    end
    if self.activity.money_buy3.status == 1 then
        return true
    end
    return false
end

function UserObj:getPromoteGetSoulShowStatus()
    if self:getActivityStatus('promote_get_soul') == false then
        return false
    end
    local promote_get_soul = self.activity.promote_get_soul
    local tempData = GameData:getConfData('avpromotegetsoul')
    local progress = promote_get_soul.progress or {}
    local rewards = promote_get_soul.rewards or {}
    local judge = false
    for i = 1,#tempData do
        local data = tempData[i]
        local rechargeNum = progress[tostring(i)] or 0
        local hasGetNum = rewards[tostring(i)] or 0
        local maxGetNum = data.limitCount
        if hasGetNum >= maxGetNum then
        elseif hasGetNum < rechargeNum then
            judge = true
            break
        else
        end
    end

    return judge
end

function UserObj:judgePromoteGetSoulIsFinish()
    if self:getActivityStatus('promote_get_soul') == false then
        return false
    end

    local promote_get_soul = self.activity.promote_get_soul
    local tempData = GameData:getConfData('avpromotegetsoul')
    local progress = promote_get_soul.progress or {}
    local rewards = promote_get_soul.rewards or {}
    local judge = false
    for i = 1,#tempData do
        local data = tempData[i]
        local rechargeNum = progress[tostring(i)] or 0
        local hasGetNum = rewards[tostring(i)] or 0
        local maxGetNum = data.limitCount
        if hasGetNum >= maxGetNum then
        else
            judge = true
            break
        end
    end

    return judge
end

function UserObj:getUnlimitedStarsShowStatus(stype)
	local infinite = self:getInfinite()
	if infinite.tip and infinite.tip.stars then
		if stype then
			if #infinite.tip.stars > 0 then
				for k, v in ipairs(infinite.tip.stars) do
					if v == stype then
						return true
					end
				end
			end
			return false
		else
			if #infinite.tip.stars > 0 then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function UserObj:getUnlimitedShasShowStatus()
	if self:getShas() > 0 then
		return true
	else
		return false
	end
end

function UserObj:getUnlimitedBossBoxShowStatus(stype)
	local infinite = self:getInfinite()
	if infinite.tip and infinite.tip.bossBox then
		if stype then
			if #infinite.tip.bossBox > 0 then
				for k, v in ipairs(infinite.tip.bossBox) do
					if v == stype then
						return true
					end
				end
			end
			return false
		else
			if #infinite.tip.bossBox > 0 then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function UserObj:judgeThreeMoneyBuyIsGet()
    if self:getActivityStatus('three_money_buy') == false then
        return false
    end

    if self.activity.money_buy2.status == 2 then
        return false
    end
    return true
end

function UserObj:judgeEightMoneyBuyIsGet()
    if self:getActivityStatus('eight_money_buy') == false then
        return false
    end

    if self.activity.money_buy3.status == 2 then
        return false
    end
    return true
end

function UserObj:judgePrivilegeActivityIsFinished()
    local privilegeDatas = GameData:getConfData("vip")

    local vip = self:getVip()
    local judge = true
    for key,data in pairs(privilegeDatas) do
        local paymentInfo = UserData:getUserObj():getPayment()
	    if paymentInfo.vip_rewards[key] ~= nil then
        else
            judge = false
            break
        end
    end
    return judge
end

function UserObj:getActivitySaleShowStatus()
    if self:getActivityStatus('value_package') == false then
        return false
    end

    local day = self.activity.overvalued_gift.day
    
    local serverDay = tonumber(Time.getDayToModifiedServerDay())

    if day == serverDay then
        return false
    else
        return true
    end  
    return false
end

function UserObj:getActivitySaleNewShowStatus()
    if self:getActivityStatus('value_package_new') == false then
        return false
    end

    local day = self.activity.overvalued_gift_new.day
    
    local serverDay = tonumber(Time.getDayToModifiedServerDay())

    if day == serverDay then
        return false
    else
        return true
    end  
    return false
end

function UserObj:getActivityTodayDoubleShowStatus()
    if self:getActivityStatus('todaydouble') == false then
        return false
    end
    local time = Time.getCorrectServerTime()
    local conf = GameData:getConfData('activities')['todaydouble']
    local startTime = GlobalApi:convertTime(1,conf.startTime)
    local diffTime = time - startTime
    local wday = math.ceil(diffTime/(24*3600))


    local todayDoubleConf = GameData:getConfData('avtodaydouble')
    local data = todayDoubleConf[wday]
    if not data then
        return false
    end
    local gateway1 = data.gateway1
    local gateway2 = data.gateway2

    if gateway1 == '0' and gateway2 == '0' then
        return false
    end


    if self.first_login == 1 then
        if self.todayDoubleTag == 1 then
            return true
        else
            return false
        end       
    else
        return false
    end
end

function UserObj:getActivityLoginGoodGiftShowStatus()
    if self:getActivityStatus('login_goodgift') == false then
        return false
    end
    local value = false

    local allDays = self.activity.login_goodgift.login
    local reward = self.activity.login_goodgift.reward -- 至少为{}

    local tempData = GameData:getConfData('avlogingift')
    for i = 1,#tempData do
        if allDays >= i then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:getActivityLimitSeckillShowStatus()
    if self:getActivityStatus('limit_seckill') == false then
        return false
    end
    if self.first_login == 1 then
        return false    -- 暂时先为false
    else
        return false
    end
end

function UserObj:getActivityPayOnlyShowStatus()
    if self:getActivityStatus('pay_only') == false then
        return false
    end

    --local serverDay = tonumber(Time.getDayToModifiedServerDay())
    local pay_only = self.activity.pay_only
    --local judge1 = false
    --if pay_only.day ~= serverDay then
        --judge1 = true
    --end   

    -- 第一次登陆
    local judge1 = false
        
    if self.first_login == 1 then
        if self.payOnlyTag == 1 then
            judge1 = true
        else
            judge1 = false
        end       
    else
        judge1 = false
    end

    local judge2 = false

    local award = pay_only.award
    local payOnlyConf = GameData:getConfData('avpayonly')
    local num = #payOnlyConf
    local nowCash = pay_only.paid
    for i = 1,num do
        local tempData = payOnlyConf[i]
        local costCash = tempData.require
        if nowCash >= costCash then
            local judge = false
            for k,v in pairs(award) do
                if tonumber(v) == tempData.id then
                    judge = true
                    break
                end
            end
            if judge == false then
                judge2 = true
                break
            end
        end
    end

    return judge1 or judge2
end

function UserObj:getActivityLimitGroupShowStatus()
    if self:getActivityStatus('limit_group') == false then
        return false
    end
    local serverDay = tonumber(Time.getDayToModifiedServerDay())
    local limit_group = self.activity.limit_group
    if limit_group.day ~= serverDay then
        return true
    else
        return false
    end   
end

function UserObj:getActivityLuckyWheelShowStatus()
    if self:getActivityStatus('lucky_wheel') == false then
        return false
    end
    
    if self.first_login == 1 then
        if self.luckyWheelTag == 1 then
            return true
        else
            return false
        end       
    else
        return false
    end

end

function UserObj:getActivityHappyWheelShowStatus()
    if self:getActivityStatus('happy_wheel') == false then
        return false
    end
    
    if self.first_login == 1 then
        if self.happyWheelTag == 1 then
            return true
        else
            return false
        end       
    else
        return false
    end

end

function UserObj:getActivityGrowFundShowStatus()
    if self:getActivityStatus('grow_fund') == false then
        return false
    end
    local judge =  self.activityGrowFundFirstOpen or self:getActivityGrowFundAwardShowStatus() or self:getActivityGrowFundAllAwardShowStatus()
    return judge
end

-- 等级豪礼小红点是否可以显示
function UserObj:getActivityLvGrowFundShowStatus()
	-- print("xi---------------------------------------->")
    if self:getActivityStatus('lv_grow_fund') == false then
        return false
    end
    local judge = self:getLvGrowFundAllAwardsStatus()
    return judge
end

function UserObj:getActivityAcumulateRechargeShowStatus()
    if self:getActivityStatus('accumulate_recharge') == false then
        return false
    end
    if self.tips.accumulate_recharge and self.tips.accumulate_recharge == 1 then
        return true
    end

    local value = false

    local allMoney = self.activity.accumulate_recharge and self.activity.accumulate_recharge.paid or 0
    local reward = self.activity.accumulate_recharge and self.activity.accumulate_recharge.rewards or {} -- 至少为{}

    local tempData = GameData:getConfData('avaccumulaterecharge')
    for i = 1,#tempData do
        local money = tempData[i].needRechargeGoldNumber
        if allMoney >= money then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:getActivityExpendGiftShowStatus()
    if self:getActivityStatus('expend_gift') == false then
        return false
    end
    local value = false

    local allMoney = self.activity.expend_gift and self.activity.expend_gift.paid or 0
    local reward = self.activity.expend_gift and self.activity.expend_gift.rewards or {} -- 至少为{}

    local tempData = GameData:getConfData('avexpendgift')
    for i = 1,#tempData do
        local money = tempData[i].paid
        if allMoney >= money then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:addActivityTavernFrequency(num)
    if self.activity.tavern_recruit then
        self.activity.tavern_recruit.frequency = self.activity.tavern_recruit.frequency + num
    end
    if self.activity.tavern_recruit_level then
        self.activity.tavern_recruit_level.frequency = self.activity.tavern_recruit_level.frequency + num
    end
end

function UserObj:getActivityTavernRecruitShowStatus()
    if self:getActivityStatus('tavern_recruit') == false then
        return false
    end
    if self.activity.tavern_recruit then
        local avTavernRecruitConf = GameData:getConfData('avtavernrecruit')
        local value = false
        local frequency = self.activity.tavern_recruit.frequency
        -- 次数道具奖励
        for i = 1,5 do
            if frequency >= avTavernRecruitConf[i].num then
                local rewards = self.activity.tavern_recruit.rewards
                if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                else
                    value = true
                    break
                end
            end
        end
        if value == true then
            return value
        end

        -- 次数卡牌奖励
        local num = self.activity.tavern_recruit.num
        local id = num + 1

        local avTavernRecruitFrequencyConf = GameData:getConfData('avtavernrecruitfrequency')

        local judge = 1  -- 1:不能领取，2：可以领取，3：已经领取完了，显示第1轮的
        if id > #avTavernRecruitFrequencyConf then
        else        
            if frequency >= avTavernRecruitFrequencyConf[id].num then
                value = true
            end
        end

        return value
    else
        return false
    end


end

function UserObj:getActivityTavernRecruitLevelShowStatus()
    if self:getActivityStatus('tavern_recruit_level') == false then
        return false
    end
    if self.activity.tavern_recruit_level then
        local avTavernRecruitConf = GameData:getConfData('avtavernrecruit')
        local value = false
        local frequency = self.activity.tavern_recruit_level.frequency
        -- 次数道具奖励
        for i = 1,5 do
            if frequency >= avTavernRecruitConf[i].num then
                local rewards = self.activity.tavern_recruit_level.rewards
                if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                else
                    value = true
                    break
                end
            end
        end
        if value == true then
            return value
        end

        -- 次数卡牌奖励
        local num = self.activity.tavern_recruit_level.num
        local id = num + 1

        local avTavernRecruitFrequencyConf = GameData:getConfData('avtavernrecruitfrequency')

        local judge = 1  -- 1:不能领取，2：可以领取，3：已经领取完了，显示第1轮的
        if id > #avTavernRecruitFrequencyConf then
        else        
            if frequency >= avTavernRecruitFrequencyConf[id].num then
                value = true
            end
        end

        return value
    else
        return false
    end


end
function UserObj:getActivityExchangePointsShowStatus()
    if self:getActivityStatus('exchange_points') == false then
        return false
    end

    if self.tips.exchange_points and self.tips.exchange_points == 1 then
        return true
    end

    local exchangePointsConf = GameData:getConfData('avexchangepoints')
    local exchangePointsTimeConf = GameData:getConfData('avexchangepointstime')

    -- 当前轮数
    local curRound = 1
    local nowTime = Time.getCorrectServerTime()
    for i = 1,#exchangePointsTimeConf do
        local data = exchangePointsTimeConf[i]
        local startTime = GlobalApi:convertTime(1,data.startTime)
        local endTime = GlobalApi:convertTime(1,data.endTime)
        if nowTime >= startTime and nowTime <= endTime then
            curRound = i
            break
        end
    end

    local temp ={}
    for k,v in pairs(exchangePointsConf[curRound]) do
        if type(v) ~= "string" then
            table.insert(temp,v)
        end
    end
    local num = #temp
    local curProgress = self.activity.exchange_points.progress

    local judge = false
    for i = 1,num,1 do
        local confData = temp[i]
        local nowProgress = curProgress[tostring(confData.key)] or 0
        -- 达到进度
        if nowProgress >= confData.target then
            if self.activity.exchange_points.rewards[tostring(confData.id)] and self.activity.exchange_points.rewards[tostring(confData.id)] == 1 then
            else
                judge = true
                break
            end
        end
    end

    return judge
end

function UserObj:getActivitySurpriseStepShowStatus()
    if self:getActivityStatus('surprise_step') == false then
        return false
    end

    return false
end

function UserObj:getActivityDayVouchasafeShowStatus()
    if self:getActivityStatus('day_vouchsafe') == false then
        return false
    end

    local nowTime = GlobalData:getServerTime()
    local time = os.date('*t',nowTime)
    local now =tonumber(time.year..string.format('%02d',time.month)..string.format('%02d',time.day))
    local nowDay = 1
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    if self.activity.day_vouchsafe.rewards then
        nowDay = #self.activity.day_vouchsafe.rewards
        -- dump("now"..now)
        -- dump("day_pay:"..tonumber(self.activity.day_vouchsafe.day_pay) )
        -- dump(self.activity.day_vouchsafe.day_money)
        -- dump(num)
        if now > tonumber(self.activity.day_vouchsafe.day_pay) 
        	or (now == tonumber(self.activity.day_vouchsafe.day_pay) and self.activity.day_vouchsafe.day_money < num) then
            nowDay = nowDay + 1
        end
    else
        nowDay = 1
    end

    local isCanGet = false
    for i=1,nowDay - 1 do
        if not self.activity.day_vouchsafe.rewards[i] or self.activity.day_vouchsafe.rewards[i] ~= 1 then
            isCanGet = true
            break
        end
    end
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    if (self.activity.day_vouchsafe.rewards and self.activity.day_vouchsafe.rewards[nowDay] and self.activity.day_vouchsafe.rewards[nowDay] == 0) 
        or (self.activity.day_vouchsafe.day_money >= num and now == tonumber(self.activity.day_vouchsafe.day_pay) 
        and (not self.activity.day_vouchsafe.rewards or not self.activity.day_vouchsafe.rewards[nowDay] or self.activity.day_vouchsafe.rewards[nowDay] ~= 1) ) then
        isCanGet = true
    end
    if isCanGet or (self.tips.day_vouchsafe == 1) then
    	return true
    else
	    local isFirstTime = false
		local time = cc.UserDefault:getInstance():getIntegerForKey(self.uid..'day_vouchsafe',0)
		if  tonumber(time) == 0 then
			return true
		end
		local beginTime = Time.beginningOfOneDay(time)
		local today = Time.beginningOfToday()
		if beginTime ~= today then
			return true
		end
		return false
	end
end

function UserObj:getActivityDayChallengeShowStatus()
    if self:getActivityStatus('day_challenge') == false then
        return false
    end

    if self.tips.day_challenge and self.tips.day_challenge == 1 then
        return true
    end

    local value = false

    local allMoney = self.activity.day_challenge and self.activity.day_challenge.progress or {}
    local reward = self.activity.day_challenge and self.activity.day_challenge.rewards or {}

    local conf = GameData:getConfData('activities')['day_challenge']
    local openDay = conf.openDay
    local duration = conf.duration
    local delayDays = conf.delayDays
    local openLoginDay = conf.openLoginDay

    local createTime = UserData:getUserObj():getCreateTime()
    local now = Time.date('*t',createTime)
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local refTime = GlobalData:getServerTime() - Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
    if(now.hour < resetHour) then
        refTime = refTime + 24*3600
    end

    local diffTime = refTime - openLoginDay*24*3600
    local day = math.ceil(diffTime/(24*3600))

    local tempData = GameData:getConfData('avdaychallenge')[day]
    if not tempData then
        return false
    end
    local temp = {}
    for k,v in pairs(tempData) do
        if type(v) == "table" then
            table.insert(temp,v)
        end
    end
    table.sort(temp,function(a, b)
		return b.id > a.id
	end)

    for i = 1,#temp do
        local money = temp[i].target
        local key = temp[i].key
        local allProgress = allMoney[key] or 0
        if allProgress >= money then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:getActivityDailyCostShowStatus()
    if self:getActivityStatus('daily_cost') == false then
        return false
    end
    local value = false

    local allMoney = self.activity.daily_cost and self.activity.daily_cost.day_cost or 0
    local reward = self.activity.daily_cost and self.activity.daily_cost.rewards or {} -- 至少为{}

    local tempData = GameData:getConfData('avdailycost')
    for i = 1,#tempData do
        local money = tempData[i].cost
        if allMoney >= money then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:getActivityHumanWingShowStatus()
    if self:getActivityStatus('human_wing') == false then
        return false
    end

    local judge = false

    local peopleKingData = UserData:getUserObj():getPeopleKing()
    local curProgress = peopleKingData and peopleKingData.wing_level or 0

    if self.activity.human_wing then
        local reward = self.activity.human_wing.achieve or {}
        local tempData = GameData:getConfData('avhuman_wing')
        for i = 1,#tempData do
            local level = tempData[i].level
            if reward[tostring(level)] and reward[tostring(level)] == 1 then
            else
                if curProgress >= level then
                    judge = true
                    break
                end
            end
        end
    end
    return judge
end

function UserObj:getActivityHumanArmsShowStatus()
    if self:getActivityStatus('human_arms') == false then
        return false
    end

    local judge = false

    local peopleKingData = UserData:getUserObj():getPeopleKing()
    local curProgress = peopleKingData and peopleKingData.weapon_level or 0

    if self.activity.human_arms then
        local reward = self.activity.human_arms.achieve or {}
        local tempData = GameData:getConfData('avhuman_arms')
        for i = 1,#tempData do
            local level = tempData[i].level
            if reward[tostring(level)] and reward[tostring(level)] == 1 then
            else
                if curProgress >= level then
                    judge = true
                    break
                end
            end
        end
    end
    return judge
end

function UserObj:getActivitySurpriseTurnShowStatus()
    if self:getActivityStatus('surprise_turn') == false then
        return false
    end
	    
    local serverDay = tonumber(Time.getDayToModifiedServerDay())
    if self.activity.surprise_turn.day == serverDay then
        return false
    else
        return true
    end
end

function UserObj:getActivityBuyHotFreeShowStatus()
    if self:getActivityStatus('buy_hot_free') == false then
        return false
    end
	    
    local serverDay = tonumber(Time.getDayToModifiedServerDay())
    if self.activity.buy_hot_free.day == serverDay then
        return false
    else
        return true
    end
end

function UserObj:getActivityInvincibleGoldWillShowStatus()
    if self:getActivityStatus('invincible_gold_will') == false then
        return false
    end
	
    return false
end

function UserObj:getActivityIntegralCarnivalShowStatus()
    if self:getActivityStatus('integral_carnival') == false then
        return false
    end
	
    return false
end

function UserObj:getActivityChristmasTreeShowStatus()
    if self:getActivityStatus('christmas_tree') == false then
        return false
    end

	if self.tips.christmas_tree and self.tips.christmas_tree == 1 then
        return true
    end

	local serverDay = tonumber(Time.getDayToModifiedServerDay())
    if self.activity.christmas_tree.day ~= serverDay then
        return true
    end

	local tempData = GameData:getConfData('avchristmastree')
	for i = 1,3 do
		local confData = tempData[i]
		local serverData = self.activity.christmas_tree.rewards[tostring(i)]
		local aid = 0
		local id = {}
		if serverData then
			aid = serverData.aid or 0
			id = serverData.id or {}
		end
		for j = 1,5 do
			local disPlayData = DisplayData:getDisplayObjs(confData[j].cost)
			local awards = disPlayData[1]
			local judge = 1
			if j > aid and aid + 1 == j and awards:getOwnNum() >= awards:getNum() then
				return true
			end
		end
	end

	return false
end

function UserObj:getActivitySurpriseBoxShowStatus()
    if self:getActivityStatus('surprise_box') == false then
        return false
    end
	return false
end
function UserObj:getActivityPromoteExchangeShowStatus()
    if self:getActivityStatus('promote_exchange') == false then
        return false
    end

    local value = false

    return value
end

function UserObj:getActivityDailyRechargeShowStatus()
    if self:getActivityStatus('daily_recharge') == false then
        return false
    end
    local value = false

    local allMoney = self.payment.day_money or 0
    local reward = self.activity.daily_recharge and self.activity.daily_recharge.rewards or {} -- 至少为{}

    local tempData = GameData:getConfData('avdailyrecharge')
    for i = 1,#tempData do
        local money = tempData[i].money
        if allMoney >= money then
            if reward[tostring(i)] and tonumber(reward[tostring(i)]) == 1 then                   
            else
                value = true
                break
            end
        end
    end

    return value
end

function UserObj:getActivitySingleRechargeShowStatus()
    if self:getActivityStatus('single_recharge') == false then
        return false
    end

    local value = false

    --local allMoney = self.activity.single_recharge and self.activity.single_recharge.money or {}
    local rewards = self.activity.single_recharge and self.activity.single_recharge.rewards or {} -- 至少为{}
    local progress = self.activity.single_recharge and self.activity.single_recharge.progress or {} -- 至少为{}

    local tempData = GameData:getConfData('avsinglerecharge')
    for i = 1,#tempData do
        local rechargeNum = progress[tostring(i)] or 0
        local hasGetNum = rewards[tostring(i)] or 0
        local maxGetNum = tempData[i].limitCount

        if hasGetNum >= maxGetNum then
        elseif hasGetNum < rechargeNum then
            value = true
            break
        end
    end

    return value
end


function UserObj:getActivityGrowFundAwardShowStatus()
    if self:getActivityStatus('grow_fund') == false then
        return false
    end
    -- 成长基金是否可以领取
    local grow_fund_count = self.grow_fund_count
    local conf = GameData:getConfData('avgrowfund')
    local grow_fund = self.activity.grow_fund
    local userLv = self:getLv()
    local bought_type = grow_fund.bought_type or 0

    local judge = false
    for i = 1,#conf do
        local confData = conf[i]
        local type = confData.type
        local condition = confData.condition
        if type == 0 and bought_type > 0 and userLv >= condition then    -- 购买了基金
            if grow_fund.rewards[tostring(i)] and grow_fund.rewards[tostring(i)] == 1 then  -- 领取了
            else
                judge = true
                break
            end
        end
    end

    return judge  -- true表示是可以进行显示的
end

function UserObj:getActivityGrowFundAllAwardShowStatus()
    if self:getActivityStatus('grow_fund') == false then
        return false
    end
    
    -- 全名奖励是否可以领取
    local grow_fund_count = self.grow_fund_count
    local conf = GameData:getConfData('avgrowfund')
    local grow_fund = self.activity.grow_fund

    local judge = false
    for i = 1,#conf do
        local confData = conf[i]
        local type = confData.type
        local condition = confData.condition
        if type == 1 and grow_fund_count >= condition then
            if grow_fund.rewards[tostring(i)] and grow_fund.rewards[tostring(i)] == 1 then  -- 领取了
            else
                judge = true
                break
            end
        end
    end

    return judge
end



-- 判断是否显示等级豪礼的图标
function UserObj:getLvGrowFundIconStatus()
	-- 根据配置表判断现在是不是开启活动时间
    if self:getActivityStatus('lv_grow_fund') == false then
        return false
    end
    -- 根据服务器下发的数据判断是否奖品已经领完，领完了也不显示
    local conf = GameData:getConfData('avlvgrowfund')
    local lv_grow_fund = self.activity.lv_grow_fund
    local userLv = self:getLv()

    local judge = false
    for i = 1,#conf do
        local confData = conf[i]
        if lv_grow_fund.rewards[tostring(i)] and lv_grow_fund.rewards[tostring(i)] == 1 then  -- 领取了
        else
            judge = true
            break
        end
    end

    return judge 
end


-- 判断是否等级豪礼是否有小红点
function UserObj:getLvGrowFundAllAwardsStatus()
    if self:getActivityStatus('lv_grow_fund') == false then
        return false
    end

    -- 查看是否今日首次登陆
    -- local isTodayLogin = GlobalData:TodayFirstLogin()
    local uid = UserData:getUserObj():getUid()
    local conf = GameData:getConfData('avlvgrowfund')
    local lv_grow_fund = self.activity.lv_grow_fund
    local userLv = self:getLv()
    local bought = lv_grow_fund.bought
    local judge = false
    -- 判断是否已经购买，没有购买显示小红点
    if bought == 0 then  	
    	-- if isTodayLogin then
    	-- 	cc.UserDefault:getInstance():getBoolForKey(uid.."LvGrowFund",true)
	    -- 	return true
    	-- end
    	if self.first_login == 1 then
    		cc.UserDefault:getInstance():getBoolForKey(uid.."LvGrowFund",true)
	    	return true
    	end
    	return cc.UserDefault:getInstance():getBoolForKey(uid.."LvGrowFund")
    end
    -- 已经购买了，查看是否有可以领取的
    for i = 1,#conf do
        local confData = conf[i]
        local condition = confData.condition
        if userLv >= condition then
            if lv_grow_fund.rewards[tostring(i)] and lv_grow_fund.rewards[tostring(i)] == 1 then  -- 领取了
            else
                judge = true
                break
            end
        end
    end

    return judge
end


function UserObj:getActivitySevenShowStatus() -- 前台不能即时获取最新进度的状态
    if self:getActivityStatus('open_seven') == false then
        return false
    end

    if UserData:getUserObj().tips.open_seven and UserData:getUserObj().tips.open_seven == 1 then
        return true
    end

    if FirstWeekActivityMgr:judgeLogic() == false then
        
        --if self.seventTag == 2 then  -- 防止死循环
            --self.seventTag = 1
            --return false
        --end

        --FirstWeekActivityMgr:GetNewServerData()  -- 不用请求，每次要更新tips

        --self.seventTag = self.seventTag + 1

        return false

    else
        return FirstWeekActivityMgr:judgeLogic()
    end  
end

function UserObj:getCountryShowStatus()
    return self:getCountryGoCityShowStatus() or self:judgeCountryJade()
end

function UserObj:getCountryGoCityShowStatus()
    local isOpen = GlobalApi:getOpenInfo('citycraft')
    if isOpen == false then
        return false
    end
	local isReport = self:getCountryFightReportShowStatus()
	local count = self:getCountryFightCounts()
    return isReport or (count > 0)
end

function UserObj:getCountryFightReportShowStatus()
    if self.tips.country_report and self.tips.country_report > 0 then
        return true
    else
        return false
    end
end

function UserObj:getCountryFightCounts()
	local count = 0
	if self.CountryInfo then
		count = self.CountryInfo.challenge - self.CountryInfo.buy
	end
	local extraTimes = tonumber(GlobalApi:getGlobalValue('countryChallengeLimit'))
	local num = extraTimes - count
    if num < 0 then
    	num = 0
    end
    return num
end

function UserObj:getGuardShowStatus()
    local isOpen = GlobalApi:getOpenInfo('patrol')
    if isOpen == false then
        return false
    end

    local guardfieldconf = GameData:getConfData('guardfield')
	local time = 0
    local freeStatus = false
	for i=1,#guardfieldconf do
		for k,v in pairs(self.guard.field_sync) do
			if tonumber(k) == i then
				time = time + guardfieldconf[i].free
                if v.status == 0 then
                    freeStatus = true
                end
			end
		end
	end
	if time - self.guard.free_hour > 0 then  -- free_hour是已经用的免费时间
		time = time - self.guard.free_hour
	else
		time = 0
	end
    local judge = false
    -- 有免费时间并且有空位，显示提醒
    if time > 0 and freeStatus then
        judge = true
    else
        judge = false
    end

    return judge or self.guardAwardStatus
end

-- -1:功能未开启
-- 0:不推荐
-- 2:有可巡逻并且有免费的时间或有可领取的奖励,
function UserObj:getGuardRecommendStatus()
	local isOpen = GlobalApi:getOpenInfo('patrol')
    if isOpen == false then
        return -1
    end
    local guardfieldconf = GameData:getConfData('guardfield')
	local time = 0
    local freeStatus = false
	for i=1,#guardfieldconf do
		for k,v in pairs(self.guard.field_sync) do
			if tonumber(k) == i then
				time = time + guardfieldconf[i].free
                if v.status == 0 then
                    freeStatus = true
                end
			end
		end
	end
	if time - self.guard.free_hour > 0 then  -- free_hour是已经用的免费时间
		time = time - self.guard.free_hour
	else
		time = 0
	end
	if freeStatus and time > 0 then
		return 2
	elseif self.guardAwardStatus then
		return 2
	else
		return 0
	end
end

function UserObj:getGuardRepressStatus()
    local isOpen = GlobalApi:getOpenInfo('patrol')
    if isOpen == false then
        return false
    end
	local value = false
	local maxrep = GlobalApi:getGlobalValue('guardRepressLimitEachDay')
	if maxrep - self.guard.repress > 0 and self:getLid() > 0 then
		value = true
	end
	return value
end
function UserObj:addGlobalTime()
    if self.Sid then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.Sid)
        self.Sid = nil
    end
    self.guardAwardStatus = false
    self.goldMineStatus = false
    self.goldMineCountStatus = false
    self.friendExploreStatus = false
    self.countryJadeStatus = false
    local scheduler = cc.Director:getInstance():getScheduler()
    local function callBack()
        -- 是否正在合璧
        local finishTime = self:getCountryJadeFinishTime()
        if finishTime - GlobalData:getServerTime() <= 0 then
            self.countryJadeStatus = true
        else
            self.countryJadeStatus = false
        end

        -- 巡逻奖励
        local serverTime = GlobalData:getServerTime()
        local guardfieldconf = GameData:getConfData('guardfield')
	    local time = 0
	    for i=1,#guardfieldconf do
            if self.guardAwardStatus == true then   -- 防止大量的重新计算
                break
            end
		    for k,v in pairs(self.guard.field_sync) do
			    if tonumber(k) == i then				    
                    if v.type == 1 then
                        local starTime = tonumber(v.time)
                        local finishTime = starTime + tonumber(GlobalApi:getGlobalValue('guardHourType' .. v.type)) * 3600
                        if tonumber(serverTime) >= finishTime then
                            self.guardAwardStatus = true
                            break
                        end
                    end

			    end
		    end
	    end

        -- 金矿
        if self.tips.mine_report and self.tips.mine_report > 0 then
            self.goldMineStatus = true
        else
            local mineKeepMaxTime = tonumber(GlobalApi:getGlobalValue("mineKeepMaxTime"))*60    -- 最大占领时间
            --print('================' .. mineKeepMaxTime)
            if self.mineDuration and self.mineDuration < mineKeepMaxTime then
                --print('================' .. mineKeepMaxTime)
                if self.mine_id and self.mine_id > 0 then -- 表示有矿正在占领
                    self.goldMineStatus = false
                    self.goldMineCountStatus = false
                else
                    self.goldMineStatus = true
                    self.goldMineCountStatus = true
                end
                
            else
                --print('================++++++')
                self.goldMineStatus = false
                self.goldMineCountStatus = false
            end
            if self.mine_id and self.mine_id > 0 then   -- 表示有矿正在占领
                if self.mineDuration and self.mineDuration < mineKeepMaxTime then
                    self.mineDuration = self.mineDuration + 1
                end
            end
            --if self.goldMineTag == 1 and self.mineDuration then
                --self.mineDuration = self.mineDuration + 1
            --end
            --print('=======+++++++++++++++' .. self.mineDuration)
        end

        -- 防止下一贞不刷新
        if (self.goldMineStatus == true) and (GlobalApi:getOpenInfo('digging') == true) and (GlobalApi:getOpenInfo('goldmine') == true) then
            MainSceneMgr:updateGoldMineDiggingSign()
        end
        if self.guardAwardStatus == true then
            MainSceneMgr:updateBoatSign()
        end

        -- 好友探索
        local friendsysInfo = self:getFriendsysInfo() 
        local explorationtime = friendsysInfo.explorationtime
        local friendconf = GameData:getConfData('friend')
        local explorationInterval = tonumber(friendconf['explorationInterval'].value*3600)
        local difftime = explorationInterval-(GlobalData:getServerTime() - explorationtime)

        local lv = UserData:getUserObj():getLv()
        local limitlv = tonumber(friendconf['explorationLevel'].value)

        local isOpen = GlobalApi:getOpenInfo('friend')
        if isOpen and lv >= limitlv and difftime <= 0 then
            self.friendExploreStatus = true
        else
            self.friendExploreStatus = false
        end

        -- 限时道具
        for k,v in pairs(BagData:getAllLimitMat()) do
        	if v:getTime() - GlobalData:getServerTime() <= 0 then
        		BagData:reduceLimitMatByTime(v:getSId())
        		break
        	end 	
        end 
    end
    self.Sid = scheduler:scheduleScriptFunc(callBack,1,false)
end

-- 判断粮草是否可以领取
function UserObj:getFoodShowStatus()
    local nowTime = GlobalData:getServerTime()
    local nowHour = Time.date('*t', nowTime).hour
    local dailyFoodNoon = GlobalApi:getGlobalValue('dailyFoodNoon')
    local dailyFoodEvening = GlobalApi:getGlobalValue('dailyFoodEvening')
    -- local dailyFoodNight = GlobalApi:getGlobalValue('dailyFoodNight')

    local foodNoon = string.split(dailyFoodNoon, "-")
    local foodEvening = string.split(dailyFoodEvening, "-")
    -- local foodNight = string.split(dailyFoodNight, "-")
    -- 先判断是否在时间段,12-14,不包含等于14点的
    if nowHour >= tonumber(foodNoon[1]) and nowHour < tonumber(foodNoon[2]) then
        if self.task.daily_reward['16'] == 0 then
            return true
        else
            return false
        end

    elseif nowHour >= tonumber(foodEvening[1]) and nowHour < tonumber(foodEvening[2]) then
        if self.task.daily_reward['16'] == 0 then
            return true
        else
            return false
        end
    -- elseif nowHour >= tonumber(foodNight[1]) and nowHour < tonumber(foodNight[2]) then
    --     if self.task.daily_reward['16'] == 0 then
    --         return true
    --     else
    --         return false
    --     end
    else
        self.task.daily_reward['16'] = 0
        return false
    end
end

function UserObj:getRescopyTimes(stype,ntype)
	local conf = GameData:getConfData("rescplist")
	local info = UserData:getUserObj():getRescopyinfo()
	local isOpen = GlobalApi:getOpenInfo(stype)
	local counts = {	
		info.reborn.count - info.reborn.buy,
		info.xp.count - info.xp.buy,
		info.gold.count - info.gold.buy,
		info.destiny.count - info.destiny.buy
	}
	if isOpen then
		return {1, conf[ntype].limit - counts[ntype], conf[ntype].limit}
	end
end

--- 判断酒馆限时抽奖是否免费
function UserObj:judgeTavenLimitState()

	local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
	if self:getVip() < tonumber(GlobalApi:getGlobalValue('tavernHotVIPRequire')) and (not openLimit) then
        return false
    end

    local value = false

    local nowTime = GlobalData:getServerTime()
    local endTime = self.tavern.hot_time
    if endTime - nowTime <= 0 then
        value = true
    end
    return value
end

function UserObj:judgeTavenFreeState()
	local freeTavernPerDay = GlobalApi:getGlobalValue('freeTavernPerDay')
    local counts = freeTavernPerDay - self.tavern.nfree
    local nDiffTime = (self.tavern.ntime - GlobalData:getServerTime())
    return (counts > 0 and (self.tavern.ntime == 0 or nDiffTime <= 0))

end

function UserObj:judgeExclusiveNormalFreeState()
	local isOpen = GlobalApi:getOpenInfo('exclusive_check')
    if isOpen == false then
        return isOpen
    end
    
    local isFree = true
    local day = self.identity.normal_day
    local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    local endTime = beginTime + tonumber(GlobalApi:getGlobalValue('normalDay')) * 86400 
    local diffTime = endTime - GlobalData:getServerTime()
    if day ~= 0 and diffTime > 0 then
        isFree = false
    end

    return isFree
end

function UserObj:judgeExclusiveMiddleFreeState()
	local isOpen = GlobalApi:getOpenInfo('exclusive_check')
    if isOpen == false then
        return isOpen
    end
    
    local isFree = true
    local day = self.identity.medium_day
    local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    local endTime = beginTime + tonumber(GlobalApi:getGlobalValue('mediumDay')) * 86400 
    local diffTime = endTime - GlobalData:getServerTime()
    if day ~= 0 and diffTime > 0 then
        isFree = false
    end

    return isFree
end

function UserObj:judgeExclusiveSuperFreeState()
	local isOpen = GlobalApi:getOpenInfo('exclusive_check')
    if isOpen == false then
        return isOpen
    end
    
    local isFree = true
    local day = self.identity.super_day
    local beginTime = GlobalApi:convertTime(2,day) + 5*3600
    local endTime = beginTime + tonumber(GlobalApi:getGlobalValue('superDay')) * 86400 
    local diffTime = endTime - GlobalData:getServerTime()
    if day ~= 0 and diffTime > 0 then
        isFree = false
    end

    return isFree
end

function UserObj:judgeExclusiveStatus()
    local isOpen = GlobalApi:getOpenInfo('exclusive')
    if isOpen == false then
        return isOpen
    end

    -- if ExclusiveMgr:canTreasureExclusive() == true or ExclusiveMgr:canMakeExclusive() == true then
    --     return true
    -- end

    if ExclusiveMgr:canTreasureExclusive() == true then
        return true
    end

    return false
end

function UserObj:judgeTavenTenState()
	local diffTime = (self.tavern.htime - GlobalData:getServerTime())
    return (self.tavern.htime == 0 or diffTime <= 0)
end

function UserObj:judgeFriendState()
    local isOpen = GlobalApi:getOpenInfo('friend')
    if isOpen == false then
        return isOpen
    end

    -- 特殊19升级到20级红点
    if self.friendToTwenty == true then
        return true
    end

    if (self.tips.friend_message and self.tips.friend_message == 1) or (self.tips.friend_gift and self.tips.friend_gift == 1) or (self.tips.friend_apply and self.tips.friend_apply == 1) then
        return true
    end

    -- 可进行探索
    if self.friendExploreStatus then
        return true
    end

    -- 有好友申请
    if FriendsMgr:getFriendApplyStatus() then
        return true
    end

    -- 有未读消息
    local isNotRead = FriendsMgr:getFriendNotReadStatus()
    if isNotRead then
        return true
    end

    -- 有好友礼物可以领取
    if FriendsMgr:getFriendGiftStatus() then
        return true
    end

    return false
end

function UserObj:getLegionWishFragmentGetState()
    local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['leigionWishOpenLevel'].value) then
			if self.tips.legion_wish and self.tips.legion_wish == 1 then
                return true
            end
            if self.wish then
                local progressData = self.wish[tostring(1)]
                if progressData and progressData.has_got > progressData.has_collect then
                    return true
                end
            end
		end
	end
	return false
end

function UserObj:getLegionWishWeekAwardState()
    local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['leigionWishOpenLevel'].value) then
			if self.legioninfo.wish and self.legioninfo.wish.wish_reward and self.legioninfo.wish.wish_progress then
                local wish_progress = self.legioninfo.wish.wish_progress
                local award = self.legioninfo.wish.wish_reward
                local legionWishaAhievementConf = GameData:getConfData('legionwishachievement')
                local returnState = false
                for i = 1,2 do
                    local confData = legionWishaAhievementConf[i + 1]
                    local progress = wish_progress[tostring(i + 1)] or 0
                    local tab = {}
                    for k,v in pairs(confData) do
                        if type(v) == 'table' then
                            table.insert(tab,v)
                        end
                    end
                    table.sort(tab, function (a, b)
		                return a.level < b.level
	                end)
                    local data = tab[#tab]
                    local judge = false
                    for j = 1,#tab do
                        local level = award[tostring(i + 1)] or 0
                        if (level + 1) == tonumber(tab[j].level) then
                            data = tab[j]
                            judge = true
                            break
                        end
                    end

                    if judge == true then
                        if progress >= data.target then -- 达成
                            returnState = true
                            break
                        end
                    end

                end
                return returnState
            end
		end
	end
	return false
end

function UserObj:getLegionWishCountState()
    local conf = GameData:getConfData('legion')
	if self.lid > 0 and self.legioninfo then
		if self.llevel >= tonumber(conf['leigionWishOpenLevel'].value) then
			if self.legioninfo.wish then
                if LegionWishMgr:getLeigionWishTimes() - self.legioninfo.wish.own > 0 then
                    return true
                end
            end
		end
	end
	return false
end

function UserObj:getDailyText(stype)

	--sign:可操作提示
	--stage:阶段(1-可操作阶段 2-倒计时阶段 3-带开启阶段)
	--num1,num2：数字显示(描述：num1 或者 描述：num1/num2)
	--time:时间

	local function changeTime(time)
		if not time then
			return
		end
		local h = math.floor(time/3600)
		local m = math.floor(time%3600/60)
		local s = math.floor(time%3600%60)
		local timeStr = string.format("%02d",h)..':'..string.format("%02d",m)..':'..string.format("%02d",s)
		return timeStr
	end

	local sign = self:getSignByType(stype)
	local showType,str1,str2,cdtime,color2 = 1,'','',-1
	if stype == 'shipper' then
		local shipper = self:getShipper()
	    local nowTime = Time.getCorrectServerTime() - Time.beginningOfToday()
		local noon = GlobalApi:getGlobalValue('shipperNoon')
		local night = GlobalApi:getGlobalValue('shipperNight')
		local keyArr1 = string.split(noon , '-')
		local keyArr2 = string.split(night , '-')
		local inAddTime = false
		local addtime = "12:00"
		if (nowTime > 3600 *tonumber(keyArr1[1]) and nowTime < 3600 * tonumber(keyArr1[2])) 
			or (nowTime > 3600 *tonumber(keyArr2[1]) and nowTime < 3600 * tonumber(keyArr2[2])) then
			inAddTime = true
		elseif nowTime < 3600 *tonumber(keyArr1[1]) or nowTime > 3600 * tonumber(keyArr2[2]) then
			addtime = keyArr1[1] .. ":00"
		elseif nowTime > 3600 * tonumber(keyArr1[2]) or nowTime < 3600 *tonumber(keyArr2[1]) then
			addtime = keyArr2[1] .. ":00"
		end

	    local num1 = tonumber(GlobalApi:getGlobalValue("shipperDeliveryCount")) - shipper.delivery
	    if inAddTime then
	    	if num1 >0 then
	    		str1 = GlobalApi:getLocalStr("MILITARY_DESC_11")
	    		showType = 1
	    	else
	    		showType = 3
	    		str1 = GlobalApi:getLocalStr("SHIPPER_NO_FREE_TIMES")
	    	end
	    else
	    	showType = 3 
	    	str1 = addtime
	    	str2 = GlobalApi:getLocalStr("TAVEN_CAN_START2")
	    end

	elseif stype == 'tavern_free' then
		local freeTavernPerDay = GlobalApi:getGlobalValue('freeTavernPerDay')		--每天免费招募次数
		local freeTavernInterval = GlobalApi:getGlobalValue('freeTavernInterval')	--普通招募免费间隔分钟数
		local diffTime = 0
		if self.tavern.ntime ~= 0 then
			diffTime = self.tavern.ntime- GlobalData:getServerTime()
		end
		local leftcount = freeTavernPerDay - self.tavern.nfree
		leftcount = (leftcount<0) and 0 or leftcount
		if sign then
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_12")
			showType = 1
		else
			if diffTime > 0 and diffTime <= freeTavernInterval*60 then
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_12")..":"
				str2 = changeTime(diffTime)
				cdtime = diffTime
				showType = 2
			elseif diffTime > freeTavernInterval*60 then
				if leftcount > 0 then
					str1 = GlobalApi:getLocalStr("MILITARY_DESC_14")
					showType = 1
				else
					str1 = GlobalApi:getLocalStr("MILITARY_DESC_13")
					showType = 3
				end
			end
		end 

    elseif stype == 'goldmine' then
    	local maxTimes = tonumber(GlobalApi:getGlobalValue("mineKeepMaxTime"))*60
    	local dtime = maxTimes - (self.mineDuration or 0)
    	if sign then
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_6")
			showType = 1
		else
			if dtime == 0 then
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_7")
				showType = 3
			else
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_8")
				str2 = changeTime(dtime)
				cdtime = dtime
				showType = 2
			end
		end
    elseif stype == 'patrol' then
	    local guardInfo = self:getGuard()
		local serverTime = GlobalData:getServerTime()
        local guardfieldconf = GameData:getConfData('guardfield')
	    local dtime,freepos,canFight= 8*3600,0,0
	    local canget = false
	    local playerLv = self:getLv()
	    for i=1,#guardfieldconf do
	    	local count = 0
		    for k,v in pairs(guardInfo.field_sync) do
			    if tonumber(k) == i then				    
                    if v.type ~= 0 then
                        local starTime = tonumber(v.time)
                        local finishTime = starTime + tonumber(GlobalApi:getGlobalValue('guardHourType' .. v.type)) * 3600
                        if tonumber(serverTime) >= finishTime then
                            canget = true
                        else
                        	local leftTime = finishTime - tonumber(serverTime)
                        	if leftTime < dtime then
                        		dtime = leftTime
                        	end
                        end
                    else
                    	freepos = freepos + 1
                    end
			    end
			    count = count + 1
		    end
		    if playerLv >= guardfieldconf[i].level then
	    		canFight = canFight + 1
	    		if canFight > count then
	    			canFight = count + 1
	    		end
	    	end
	    end
	    if canget then
	    	showType = 1
	    	str1 = GlobalApi:getLocalStr("MILITARY_DESC_4")
	    else
	    	if dtime ~= 8*3600 then
	    		showType = 3
	    		str1 = GlobalApi:getLocalStr("MILITARY_DESC_9")
	    		str2 = changeTime(dtime)
	    		cdtime = dtime
	    	else
	    		showType = 2
	    		str1 = GlobalApi:getLocalStr("MILITARY_DESC_10")
	    		str2 = freepos .. "/" ..canFight
	    	end
	    end

	elseif stype == 'worldwar' then

		if self.guide.worldwarstage == "close" then
			showType = 3
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_31")
			str2 = GlobalApi:getLocalStr("TAVEN_CAN_START2")
		else
			if self.guide.worldwarstage == "rank" then
				showType = 1
				local pointrace = false
				local bt = Time.beginningOfWeek()
		        local dt = WorldWarMgr:getScheduleByProgress(32)
		        local startTime = bt + (tonumber(dt.endWeek) - 1) * 24 * 3600 + tonumber(dt.startHour) * 3600
		        local nowTime = GlobalData:getServerTime()
		        if nowTime < startTime then
		            pointrace = true
		        end
		        if pointrace then
					local worldwartab = self:getWorldWar()
					local battleTims,matchTimes = worldwartab.battle or 0,worldwartab.match or 0
					local surplusBattleTimes = WorldWarMgr.maxBattleTimes - battleTims
					local surplusMatchTimes = WorldWarMgr.maxMatchTimes - matchTimes
					surplusBattleTimes = (surplusBattleTimes < 0) and 0 or surplusBattleTimes 
					surplusMatchTimes = (surplusMatchTimes < 0) and 0 or surplusMatchTimes
					if surplusBattleTimes > 0 and surplusMatchTimes > 0 then
						str1 = GlobalApi:getLocalStr("MILITARY_DESC_23") 
					else
						str1 = GlobalApi:getLocalStr("MILITARY_DESC_25") 
						showType = 3
					end
				else
					local surport = self.tips.ww_sup or 0
					if surport>0 then
						str1 = GlobalApi:getLocalStr("MILITARY_DESC_24") 
					else
						str1 = GlobalApi:getLocalStr("MILITARY_DESC_25") 
						showType = 3
					end
		        end

			elseif self.guide.worldwarstage == "stop" then
				stage = 3
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_26") 
			else
				local surport = self.tips.ww_sup or 0
				if surport>0 then
					str1 = GlobalApi:getLocalStr("MILITARY_DESC_24") 
				else
					str1 = GlobalApi:getLocalStr("MILITARY_DESC_25") 
					showType = 3
				end
			end
		end
	elseif stype == "legionwar" then

		local leginData = GameData:getConfData("legion")
		if self.guide.legionwarstage == 1 then  	--准备阶段
			local maxBufnum = tonumber(leginData["legionWarAddCityBufNum"].value)
			local legionwar_citybufnum = self.guide.legionwar_citybufnum or 0
			str2 = legionwar_citybufnum.."/"..maxBufnum
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_27")
			showType = legionwar_citybufnum < maxBufnum and 1 or 3
			if legionwar_citybufnum >= maxBufnum then
				color2 = COLOR_TYPE.RED
			end
		elseif self.guide.legionwarstage == 2 then
			local maxAttack = tonumber(leginData["legionWarAttackNum"].value)
			local legionwar_attacknum = self.guide.legionwar_attacknum or 0
			local attackedNum = maxAttack - legionwar_attacknum    --已攻击次数
			if attackedNum < 0 then
				attackedNum = 0
			end
			showType = (attackedNum < maxAttack) and 1 or 3
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_28")
			str2 = attackedNum.. "/" ..maxAttack
			if attackedNum >= maxAttack then
				color2 = COLOR_TYPE.RED
			end
		else
			local weekday = os.date("%w", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
			--weekday[0-6 = Sunday-Saturday]]
			weekday = weekday == 0 and 7 or weekday
			local str = GlobalApi:getLocalStr("MILITARY_DESC_31")
		    if weekday == 3 then
		    	str = GlobalApi:getLocalStr("MILITARY_DESC_33")
		    end
			showType = 3
			str1 = str
			str2 = GlobalApi:getLocalStr("TAVEN_CAN_START2")
		end
	elseif stype == 'hook' then
	    local vip = self:getVip()
	    local conf = GameData:getConfData("vip")[tostring(vip)]
	    local times = conf.patrol - MapData.patrolAccelerate
	    if sign then
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_4")
			showType = 1
		else
			if times > 0 then
				showType = 1
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_5")
				str2 = times.."/"..conf.patrol
			else
				showType = 3
				str1 = GlobalApi:getLocalStr("MILITARY_DESC_32")
				str2 = ''
			end
		end
    elseif stype == "countryJade" then
    	local finishTime = self:getCountryJadeFinishTime()
    	local leftTime = finishTime - GlobalData:getServerTime()
        if leftTime <= 0 then
        	local totalCount = tonumber(GlobalApi:getGlobalValue("countryJadeMergeCount"))
        	local surplusCount = totalCount - self.country_jade
        	if surplusCount<=0 then
        		showType = 3
        		str1 = GlobalApi:getLocalStr("MILITARY_DESC_16")
        	else
        		str1 = GlobalApi:getLocalStr("MILITARY_DESC_17")
        		str2 = surplusCount.."/"..totalCount
        		showType = 1
        	end
        else
        	str1 = GlobalApi:getLocalStr("MILITARY_DESC_18")
        	str2 = changeTime(leftTime)
        	cdtime = leftTime
        	showType = 2
        end
    elseif stype == "tribute" then
		local conf = GameData:getConfData('citytribute')
	    local fightedId = MapData:getFightedCityId()
	    local cityTribute = MapData.cityTribute
	    local canGet = false
	    for i,v in ipairs(conf) do
	        if v.cityId <= fightedId and not cityTribute[tostring(i)] then
	            canGet = true
	            break
	        end
	    end
	    if canGet then
	    	showType = 1
	    	str1 = GlobalApi:getLocalStr("MILITARY_DESC_4")
	    else
	    	local endTime = Time.beginningOfToday() + 86400 + tonumber(GlobalApi:getGlobalValue('resetHour')) * 3600
	        local nowTime = GlobalData:getServerTime()
	        if nowTime - Time.beginningOfToday() < 5 * 3600 then
	            endTime = Time.beginningOfToday() + tonumber(GlobalApi:getGlobalValue('resetHour')) * 3600
	        end
	        local diffTime = endTime - nowTime
	        str1 = GlobalApi:getLocalStr("MILITARY_DESC_15")
			str2 = changeTime(diffTime)
			cdtime = diffTime
	        showType = 2
	    end  
	elseif stype == "territoryboss" then
    	local dfbaseCfg = GameData:getConfData("dfbasepara")
    	local startHour,startMinute = string.match(dfbaseCfg["bossActivityTime"].value[1],"(%d+):(%d+)")
	    local endHour,endMinute = string.match(dfbaseCfg["bossActivityTime"].value[2],"(%d+):(%d+)")
	    local hour = os.date("%H", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
	    local minute = os.date("%M", GlobalData:getServerTime() + GlobalData:getTimeZoneOffset()*3600)%100
	    local startTime,endTime,curTime = startHour*60+startMinute,endHour*60+endMinute,hour*60+minute
	    local isOpenTime = (curTime >= startTime and curTime <endTime) and true or false
	    if isOpenTime then
	    	showType = 1
	    	str1 = GlobalApi:getLocalStr("MILITARY_DESC_11")
	    else
	    	showType = 3
	    	str1 = dfbaseCfg["bossActivityTime"].value[1]
	    	str2 = GlobalApi:getLocalStr("KING_LV_UPDES3")
	    end
	elseif stype == "lord" then
		local cityTime = self.guide.citytime
		local lefttime = cityTime - GlobalData:getServerTime() + GlobalApi:getGlobalValue('lordMaxHour')*3600
		if lefttime > 0 then
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_29")
			str2 = changeTime(lefttime)
			cdtime = lefttime
			showType = 2
		else
			showType = 1
			str1 = GlobalApi:getLocalStr("MILITARY_DESC_30")
		end
    end
    return showType,str1,str2,cdtime,color2
end

function UserObj:getLegionWishState()
    return self:getLegionWishFragmentGetState() or self:getLegionWishWeekAwardState() or self:getLegionWishCountState()
end

function UserObj:getStrengthPercent(conf)
	local stype = conf.event
	if stype == 'role_lv' then
		local maxLv = RoleData:getRoleNum() * self.level
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				lv = lv + v:getLevel()
			end
		end
        if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
		
	elseif stype == 'equip_lv' then
		local maxLv = RoleData:getRoleNum() * math.floor(self.level/10)*10 * 6
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				for i=1,6 do
					local obj = v:getEquipByIndex(i)
					if obj then
						lv = lv + obj:getLevel()
					end
				end
			end
		end
		if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
    elseif stype == 'refine' then

    	local conf = GameData:getConfData("equiprefine")
		local maxPartLv = #conf[1] or 10
    	local maxRefineLv = RoleData:getRoleNum() * 6 * maxPartLv
    	local roleMap = RoleData:getRoleMap()
    	local lv = 0
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				for i=1,6 do
					local partInfo = v:getPartInfoByPos(i)
					if partInfo then
						lv = lv + partInfo.level
					end
				end
			end
		end
		print("refineInfo:" ,lv,maxRefineLv)
		if maxRefineLv == 0 then
            return 0
        else
            return lv / maxRefineLv*100
        end
    elseif stype == 'promote' then
    	--
    	local curLv,maxLv = 0,0
    	local roleMap = RoleData:getRoleMap()
    	for k,v in pairs(roleMap) do
    		if v and v:getId() > 0 and v:getId() < 10000 and v:isJunZhu()== false 
    			 and v:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit'))  then

	    		local realQulity = v:getRealQulity()
	    		local showQulity = v:getQuality()
	    		local detaQulity = showQulity - realQulity
	    		detaQulity = (detaQulity <0) and 0 or detaQulity

	    		local maxPromoteLv = MAXPROMOTEDLV
	    		if realQulity < 6 then 			--品质红将以下
	    			maxPromoteLv =  2*MAXPROMOTEDLV
	    		end
	    		local name = v:getName()
	    		local lv = v.promote[2] + MAXPROMOTEDLV*detaQulity
	    		print("quality:" ,name,realQulity,lv,maxPromoteLv)
	    		curLv = lv + curLv
	    		maxLv = maxLv + maxPromoteLv	
    		end
    	end

    	print("promoteInfo:" ,curLv,maxLv)
    	if maxLv == 0 then
            return 0
        else
            return curLv / maxLv*100
        end
	elseif stype == 'equip_quality' then
		local maxLv = RoleData:getRoleNum() * 30
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				for i=1,6 do
					local obj = v:getEquipByIndex(i)
					if obj then
						lv = lv + obj:getQuality()
					end
				end
			end
		end
		if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
	elseif stype == 'destiny' then
		return self:getPerByType(conf)
	elseif stype == 'reborn' then
		local maxLv = 0
		local mainObj = RoleData:getMainRole()
		local conf = GameData:getConfData("reborn")[mainObj:getrebornType()]
		local isIn = false
		for i,v in ipairs(conf) do
			if mainObj:getLevel() <= conf[i].roleLevel then
				maxLv = i
				isIn = true
			end
		end
		if not isIn then
			maxLv = conf[#conf].level
		end
		maxLv = RoleData:getRoleNum() * maxLv
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		local conf
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				lv = lv + v:getTalent()
			end
		end
		if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
	elseif stype == 'hero_list' then
		local maxLv = RoleData:getRoleNum()
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				lv = lv + 1
			end
		end
        if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
	elseif stype == 'dress_skill' then
		local maxSkillNum = 0
		local allLv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				for i=1,4 do
					local lv = v:getSoldierSkillLv(i)
					if lv > 0 then
						allLv = allLv + lv
						maxSkillNum = maxSkillNum + 1
					end
				end
			end
		end
        if maxSkillNum * self.level == 0 then
            return 0
        else
            return allLv * 100 / (maxSkillNum * self.level)
        end
		
	elseif stype == 'dress_upgrade' then
		return self:getPerByType(conf)
	elseif stype == 'treasure' then
		return self:getPerByType(conf)
	elseif stype == 'equip_inherit' then
		return self:getPerByType(conf)
	elseif stype == 'gem' then
		return self:getPerByType(conf)
	elseif stype == 'role_fate' then
		local maxLv = 0
		local lv = 0
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				local curr,max = v:getFateArr(true)
				lv = lv + curr
				maxLv = maxLv + max
			end
		end
		if maxLv == 0 then
            return 0
        else
            return lv *100 / maxLv
        end
    else
    	return 0
	end
end

function UserObj:getPerByType(conf)
	local stype = conf.event
	local num = 0
	local maxNum = 0
	local id = 1
	for i=1,10 do
		id = i
		local level = conf['level'..i]
		if self.level < level then
			id = i - 1
			break
		end
	end
	maxNum = conf['target'..id]
	if stype == 'treasure' then
		local slotConf = GameData:getConfData("playerskillslot")
		for i=1,5 do
			local openLevel = tonumber(slotConf[i].open)
			if self.level >= openLevel then
				num = num + self.skills[tostring(i)].level
			else
				break
			end
		end
	else
		local roleMap = RoleData:getRoleMap()
		for k,v in pairs(roleMap) do
			if v and v:getId() > 0 then
				if stype == 'dress_upgrade' then
					num = num + v:getSoldier().level
				elseif stype == 'destiny' then
					num = num + v:getDestiny().level
				elseif stype == 'equip_inherit' then
					for i=1,6 do
						local obj = v:getEquipByIndex(i)
						if obj then
							num = num + obj:getGodLevel()
						end
					end
				elseif stype == 'gem' then
					for i=1,6 do
						local obj = v:getEquipByIndex(i)
						if obj then
							local maxGem = obj:getMaxGemNum()
							local gems = obj:getGems()
							for j=1,maxGem do
								if gems[j] then
									num = num + gems[j]:getLevel()
								end
							end
						end
					end
				end
			end
		end
	end
    if maxNum == 0 then
        return 0
    else
        return num *100 / maxNum
    end
end

--获得领地战行动点数
function UserObj:getActionPoint()
	return self.action_point
end

function UserObj:setActionPoint(val)
    self.action_point = val
end

--获取领地战耐力
function UserObj:getEndurance()
    return self.staying_power
end

function UserObj:setStayingPower(val)
    self.staying_power = val
    local powerMax = tonumber(GameData:getConfData('dfbasepara').enduranceLimit.value[1])
    if self.staying_power > powerMax then
        self.staying_power = powerMax
    end

    if self.staying_power >= powerMax then
        self.stayingPowerMax = true
    else
        self.stayingPowerMax = false
    end
end

function UserObj:setTerritorialWar(data)
    self.territoryWar = data
end

function UserObj:getTerritorialWar()
    return self.territoryWar
end

function UserObj:getMine(mine_type)
    return self['mine_' .. mine_type]
end

function UserObj:getStayingPowerTime()
    if self.mark and self.mark.staying_power_time  then
		return self.mark.staying_power_time 
	else
		return 0
	end
end

function UserObj:setStayingPowerTime(time)
    if self.mark and self.mark.staying_power_time  then
		self.mark.staying_power_time = time 
	end
end

function UserObj:getActionPointTime()
    if self.mark and self.mark.action_point_time  then
		return self.mark.action_point_time 
	else
		return 0
	end
end

function UserObj:setActionPointTime(time)
    if self.mark and self.mark.action_point_time  then
		self.mark.action_point_time = time 
	end
end


function UserObj:setOpenCDKeyStatus(openCDKey)
	self.openCDKey = openCDKey
end

function UserObj:isOpenCDKey()
	return self.openCDKey == 1
end
function UserObj:setResBackSign(hasresback)
	self.hasresback = hasresback
end

function UserObj:getResGetBack()
    return self.hasresback and self.hasresback == 1
end

function UserObj:getPrivilege(privilegeId)
	privilegeId = tostring(privilegeId)
	if not self.privilege then
		return 
	end
	return self.privilege[privilegeId]
end

function UserObj:setPrivilege(privilegeId,value)
	privilegeId = tostring(privilegeId)
	self.privilege[privilegeId] = value
end

function UserObj:setNobility(nobilityId,star)
	self.nobility[1] = nobilityId
	self.nobility[2] = star
end

function UserObj:getNobility()
	return self.nobility[1],self.nobility[2]
end

function UserObj:setLegionData(legionData)
	self.legionData = legionData
end

function UserObj:getLegionData()
	return self.legionData
end

function UserObj:initGuide(guide)

	if not guide then
		return
	end
	self.guide.citytime = guide.citytime or 0
	self.guide.legionwarstage = guide.legionwarstage or 0
	self.guide.worldwarstage = guide.worldwarstage or 'rank'
	self.guide.legionwar_citybufnum = guide.legionwar_CityBufNum or 0
    self.guide.legionwar_attacknum = guide.legionwar_attackNum or 0
	printall(self.guide)
end

function UserObj:getGuideData()
	return self.guide
end

function UserObj:setGuideCityTime(time)
	self.guide.citytime = time or 0
end

function UserObj:setGuideCitybufnum(citybufnum)
	self.guide.legionwar_citybufnum = citybufnum or 0
    
end

function UserObj:setGuideAttacknum(attacknum)
	self.guide.legionwar_attacknum = attacknum or 4
end

function UserObj:initPeopleKing(peopleKing)

	self.peopleKing = peopleKing
	local skychangecfg = GameData:getConfData("skychange")
	--拥有的武器
	local ownWeapon = {}
	--永久
	for k,v in pairs(peopleKing.weapon_illusion_equip) do
		ownWeapon[#ownWeapon+1] = tonumber(k)
	end

	--时限道具
	for k,v in pairs(peopleKing.weapon_illusion_equip_time) do
		ownWeapon[#ownWeapon+1] = tonumber(k)
	end

	--升阶解锁处理
	local weaponCfg = skychangecfg[1]
	for i=1,#weaponCfg do
		if weaponCfg[i].condition == "level" and peopleKing.weapon_level >= weaponCfg[i].value then
			ownWeapon[#ownWeapon+1] = tonumber(weaponCfg[i].id)
		end
	end
	self.peopleKing.ownWeapon = ownWeapon

	--拥有的翅膀
	local ownWing = {}
	for k,v in pairs(peopleKing.wing_illusion_equip) do
		ownWing[#ownWing+1] = tonumber(k)
	end
	for k,v in pairs(peopleKing.wing_illusion_equip_time) do
		ownWing[#ownWing+1] = tonumber(k)
	end

	--升阶解锁处理
	local wingCfg = skychangecfg[2]
	for i=1,#wingCfg do
		if wingCfg[i].condition == "level" and peopleKing.wing_level >= wingCfg[i].value then
			ownWing[#ownWing+1] = tonumber(wingCfg[i].id)
		end
	end
	self.peopleKing.ownWing = ownWing
end

function UserObj:getPeopleKing()
	return self.peopleKing
end

function UserObj:getPeopleKingReddot(ntype)

	if ntype == nil then
		for i = 1,2 do
			local collectItemCfg = GameData:getConfData("skychange")[i]
			for j=1,#collectItemCfg do

				local keyType = i.."_"..collectItemCfg[j].id
	           	local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
	           	local flag = cc.UserDefault:getInstance():getBoolForKey(key) or false
				if flag then
					return true
				end
			end
		end
	else
		local collectItemCfg = GameData:getConfData("skychange")[ntype]
		if not collectItemCfg then
			return false
		end
		for j=1,#collectItemCfg do
			local keyType = ntype.."_"..collectItemCfg[j].id
           	local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
           	local flag = cc.UserDefault:getInstance():getBoolForKey(key) or false
			if flag then
				return true
			end
		end
	end
	return false
end

function UserObj:getPeopleKingBtn(ntype)
	local stypes = {'weapon','wing'}
	local isOpen = GlobalApi:getOpenInfo(stypes[ntype])
	if not isOpen then
		return false
	end
	return self:getPeopleKingAwake(ntype) 
		or self:getPeopleKingAward1(ntype) 
		or self:getPeopleKingAward2(ntype) 
		or self:getPeopleKingReddot(ntype) 
		or self:skillCouldUp(ntype)
end

function UserObj:getPeopleKingAwake(ntype)
	local conf = {
		[1] = GameData:getConfData('skygasawaken'),
		[2] = GameData:getConfData('skybloodawaken'),
	}
	local data = UserData:getUserObj():getPeopleKing()
	local levels = {data.weapon_level,data.wing_level}
	local obj1 = BagData:getMaterialById(300)
	local obj2 = BagData:getMaterialById(301)
	local nums = {obj1:getNum(),obj2:getNum()}
	local counts = {
		[1] = {data.weapon_gas,data.weapon_blood},
		[2] = {data.wing_gas,data.wing_blood}
	}
	for i=1,2 do
		local conf1 = conf[i][ntype][levels[ntype]]
		if counts[ntype][i] < conf1.num and nums[i] > 0 then
			return true
		end
	end
	return false
end

function UserObj:getPeopleKingAward1(ntype)
	local conf = {
		[1] = GameData:getConfData('skyweap'),
		[2] = GameData:getConfData('skywing'),
	}
	local data = UserData:getUserObj():getPeopleKing()
	local levels = {data.weapon_level,data.wing_level}
	local energys = {data.weapon_energy,data.wing_energy}
	local obj1 = BagData:getMaterialById(100)
	local obj2 = BagData:getMaterialById(200)
	local nums = {obj1:getNum(),obj2:getNum()}
	local conf1 = conf[ntype][0]
	local obj = DisplayData:getDisplayObj(conf1.cost1[1])

	if levels[ntype] >= 1 or energys[ntype] > 0 or obj:getNum() > nums[ntype] then
		return false
 	end
	return true
end

function UserObj:getPeopleKingAward2(ntype)
	local conf = {
		[1] = GameData:getConfData('skyweap'),
		[2] = GameData:getConfData('skywing'),
	}
	local data = UserData:getUserObj():getPeopleKing()
	local levels = {data.weapon_level,data.wing_level}
	local energys = {data.weapon_energy,data.wing_energy}
	local obj1 = BagData:getMaterialById(101)
	local obj2 = BagData:getMaterialById(201)
	local nums = {obj1:getNum(),obj2:getNum()}

	if levels[ntype] > 1 or energys[ntype] > 0 or nums[ntype] <= 0 then
		return false
	end
	return true
end

function UserObj:skillCouldUp(ntype)
	local data = UserData:getUserObj():getPeopleKing()
	local skillConf = GameData:getConfData("skyskill")[ntype]
	local skillupConf = GameData:getConfData("skyskillup")
	local JieShu = ntype == 1 and data.weapon_level or data.wing_level
	local skills = ntype == 1 and data.weapon_skills or data.wing_skills
	local up = true
	for id=1,4 do
		local skillLv = skills[tostring(id)]
		if skillLv and skillLv > 0 then
			up = true
			if not skillConf[id] then
				up = false
			end
			local skillId = ntype*100+id
			if not skillupConf[skillId] then
				up = false
			end
			local maxLvOfStage = skillConf[id].levelLimit*JieShu
			if skillLv >= maxLvOfStage then
				up = false
			else
				local costnum = skillupConf[skillId][skillLv].cost[1][3] or 0
				local ownbooks = UserData:getUserObj():getSkybook()
				if ownbooks < -costnum then
					up = false
				end
			end
			if up == true then
				return true
			end
		else
			up = false
		end
	end
	return false
end

return UserObj