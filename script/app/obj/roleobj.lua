local RoleObj = class("RoleObj")
local ClassItemObj = require('script/app/obj/itemobj')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')

local function creatDefaultObj( id,num )
	local obj={
		posid = 0,
		hid = id,
		level = 1,
		xp = 0,
		--dragon = UserData:getUserObj():getDragon(),
		destiny = {
			level = 1,
			energy = 0,
			expect  = 0
		},
		talent = 0,
		equipMap = {
			[1] = nil,
			[2] = nil,
			[3] = nil,
			[4] = nil,
			[5] = nil,
			[6] = nil
		},
		soldier ={
			level = 1,
			dress = {
				[1] = 0,
				[2] = 0,
				[3] = 0,
				[4] = 0,
				[5] = 0,
				[6] = 0
			},
			skills ={
				[1] =0,
				[2] =0,
				[3] =0,
				[4] =0
			},
		},
		part = {
			['1'] = {
				level = 0,
				exp = 0,
			},
			['2'] = {
				level = 0,
				exp = 0,
			},
			['3'] = {
				level = 0,
				exp = 0,
			},
			['4'] = {
				level = 0,
				exp = 0,
			},
			['5'] = {
				level = 0,
				exp = 0,
			},
			['6'] = {
				level = 0,
				exp = 0,
			},
		},
		cardnum = num,
		quality = 1,
		heroQuality = 1,
		audioId = {},
		promote = {},
        exclusive = {
            ['1'] = 0,
			['2'] = 0,
			['3'] = 0,
			['4'] = 0
        }
	}
	return obj
end

--[[
	count参数是给已有武将卡牌创建的属性
	上阵武将或者武将碎片展示武将信息时这个count应该传0
	另外pos在创建role的时候是位置（pos），在创建卡牌或者碎片展示的时候是武将ID（hid）
	………………偷懒的代价
]]
function RoleObj:ctor(pos,num, obj)
	obj = obj or creatDefaultObj(pos,num)
--[[								--装备顺序
	hat								--头盔
	weapon							--武器
	belt							--腰带
	armour							--盔甲
	shoes							--鞋子
	necklace						--项链
]]
	self.equipMap = {} 				--装备
	self.posid = pos					--posID
	self.hid = obj.hid           	--该位置武将ID
	self.level = obj.level			--等级
	self.xp = obj.xp				--经验
	--self.dragon = UserData:getUserObj():getDragon()		--坐骑
--[[								--天命结构
		level 						--天命等级
		energy						--天命能量
		upgrade						--升级到下一级的能量注入次数
]]
	self.destiny = obj.destiny			--天命
	self.cardnum = num
	self.talent = obj.talent		--天赋（突破,武将星级）
--[[							--小兵结构
		level = 0,				--小兵等级
		train = 0				--小兵训练次数	
]]
	self.soldier = obj.soldier
	self.part = obj.part
	self.allattr = {}	--人物全部属性
	-- 	[1] = 0,        -- 攻击
	-- 	[2] = 0,		-- 物防
	-- 	[3] = 0,		-- 法防
	-- 	[4] = 0,		-- 生命
	-- 	[5] = 0,		-- 命中
	-- 	[6] = 0,		-- 闪避
	-- 	[7] = 0,		-- 暴击
	-- 	[8] = 0,		-- 韧性
	-- 	[9] = 0,		-- 移动速度
	-- 	[10] = 0,		-- 攻击速度
	-- 	[11] = 0,		-- 伤害加成
	-- 	[12] = 0,		-- 伤害减免
	-- 	[13] = 0,		-- 暴击伤害
	-- 	[14] = 0,		-- 无视防御几率
	-- 	[15] = 0,		-- 每五秒回血
	-- 	[16] = 0,		-- 掉落道具加成
	-- 	[17] = 0,		-- 掉落金币加成
	-- 	[18] = 0,		-- 初始怒气
	-- 	[19] = 0,		-- 怒气回复速度
	-- }

	local attconf =GameData:getConfData('attribute')
	local att = {}
	for i=1,#attconf do
		att[i] = 0
	end
	self.allattr = att[i]
	self.attcount = #attconf
	self.baseCalAtt = {}
	self.baseCalAtt_check = {}
	self.fateinfoarr = {
		fateid = 0,
		index = 0,
		hidarr = {}
	}

	self.assist = {}
	if obj.assist ~= nil then
		for k, v in pairs(obj.assist) do
			k = tonumber(k)
			self.assist[k] = {}
			for i, m in ipairs(v) do
				m = tonumber(m)
				table.insert(self.assist[k], m)
			end
		end
	end

	self.suitFlag = false
	self.dirty = true
	self.heroQuality = obj.quality
	self.promote = obj.promote
	self:calbaseAtt()
	self.audioId = {}
    self.lastLevel = obj.level -- 保存的是武将以前的等级
    self.exclusive = {
        ['1'] = 0,
		['2'] = 0,
		['3'] = 0,
		['4'] = 0
    }
    if obj.exclusive then
        for i = 1,4 do
            self.exclusive[tostring(i)] = obj.exclusive[tostring(i)] or 0
        end
    end
end

function RoleObj:setPartInfoByPos(pos,tab)
	self.part[tostring(pos)] = tab
	for k, v in pairs(self.equipMap) do
		if tonumber(k) == tonumber(pos) then
			local partLv = tab.level
			v:activateGodByPart(tab.level)
		end
	end
end

function RoleObj:getPartInfoByPos(pos)
	return self.part[tostring(pos)]
end

--obj类型
function RoleObj:getObjType()
	return 'card'
end
--装备
function RoleObj:getEquipByIndex(index)
	return self.equipMap[index]
end
--是否有更好的装备
function RoleObj:isHavebetterEquip(index)
	local ishave = false
	local canequip = false
	local equipObj = self.equipMap[index]
	local equips = {}
	local equipMap = BagData:getEquipMapByType(index)
	local roleLevel = UserData:getUserObj():getLv() + 10

	local fightforce = 0
	if equipObj then
		fightforce = equipObj:getFightForce()
	end
	if BagData:getEquipNumByPos(index) == 0 then
		ishave = false
		canequip = false
	else
		local equiatt = {}
		for k, v in pairs(equipMap) do
			if equipObj then
				local isOk = true
				if v:getQuality() <= equipObj:getQuality() and v:getLevel() < equipObj:getLevel() and not v:isAncient() then
					ishave = false
					canequip = false
					isOk = false
				end
				if v:getQuality() < equipObj:getQuality() and v:getLevel() == equipObj:getLevel() then
					ishave = false
					canequip = false
					isOk = false
				end
				if isOk then
					local obj = clone(v)
					local att = {}	
					for i=1, self.attcount do
						att[i] = 0
						equiatt[i] = 0
					end
					equiatt = obj:getAllAttr()
					for i=1,obj:getMaxGemNum() do
						local gemObj = equipObj:getGems()[i]
						if gemObj then
							local attrId = gemObj:getAttrId()
							att[attrId] = att[attrId] + gemObj:getValue()
						end
						local gemObj1 = obj:getGems()[i]
						if gemObj1 then
							local attrId = gemObj1:getAttrId()
							att[attrId] = att[attrId] - gemObj1:getValue()
						end
					end
					local godId = obj:getGodId()
					local godId1 = equipObj:getGodId()
					if godId == 0 and godId1 ~= 0 then
						local godAttr = equipObj:getGodAttr()
						for k,v in pairs(godAttr) do
							if v.double then
								att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)*2
							else
								att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)
							end
						end
					-- elseif godId > 0 then
					-- 	local talent = self:getTalent()
					-- 	v:activateGodByTalent(talent)
					end
					-- local talent = self:getTalent()
					-- v:activateGodByTalent(talent)
					local partInfo = self:getPartInfoByPos(tostring(obj:getType()))
					obj:activateGodByPart(partInfo.level)
					local attemp = {}
					for i=1, self.attcount do
						attemp[i] = 0
						attemp[i] = equiatt[i]+att[i]
					end
					if tonumber(fightforce) < tonumber(obj:getFightForcePre(attemp)) then
						ishave = true
						if obj:getLevel() <= roleLevel then
							canequip = true
							break
						end
					end
				end
			else
				equiatt = v:getAllAttr()
				if tonumber(fightforce) < tonumber(v:getFightForce()) then
					ishave = true
					if v:getLevel() <= roleLevel then
						canequip = true
						break
					end
				end
			end
		end
	end

	return ishave ,canequip
end

function RoleObj:isHavebetterEquipOutSide()
	local ishavetab = {}
	local roleLevel = UserData:getUserObj():getLv() + 10
	for x=1,6 do
		local ishave = false
		local equips = {}
		local equipObj = self.equipMap[x]
		local fightforce = 0
		if equipObj then
			fightforce = equipObj:getFightForce()
		end
		if BagData:getEquipNumByPos(x) == 0 then
			ishave = false
			--break
		else
			local equipMap = BagData:getEquipMapByType(x)
			local equiatt = {}
			for k, v in pairs(equipMap) do
				if equipObj then
					local att = {}	
					for i=1, self.attcount do
						att[i] = 0
						equiatt[i] = 0
					end
					equiatt = v:getAllAttr()
					for i=1,v:getMaxGemNum() do
						local gemObj = equipObj:getGems()[i]
						if gemObj then
							local attrId = gemObj:getAttrId()
							att[attrId] = att[attrId] + gemObj:getValue()
						end
						local gemObj1 = v:getGems()[i]
						if gemObj1 then
							local attrId = gemObj1:getAttrId()
							att[attrId] = att[attrId] - gemObj1:getValue()
						end
					end
					local godId = v:getGodId()
					local godId1 = equipObj:getGodId()
					if godId == 0 and godId1 ~= 0 then
						local godAttr = equipObj:getGodAttr()
						for k,v in pairs(godAttr) do
							if v.double then
								att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)*2
							else
								att[tonumber(v.id)] = att[tonumber(v.id)] + tonumber(v.value)
							end
						end
					elseif godId > 0 then
						v = clone(v)
						local partInfo = self:getPartInfoByPos(tostring(v:getType()))
						v:activateGodByPart(partInfo.level)
					end
					local attemp = {}
					for i=1, self.attcount do
						attemp[i] = 0
						attemp[i] = equiatt[i]+att[i]
					end
					if tonumber(fightforce) < tonumber(v:getFightForcePre(attemp)) then
						if v:getLevel() <= roleLevel then
							ishave = true
							break
						end
					end
				else
					if  tonumber(v:getFightForce()) > 0 then
						if v:getLevel() <= roleLevel then
							ishave = true
							break
						end
					end
				end
			end
		end
		ishavetab[x] = ishave
	end
	return ishavetab
end
--能否升星
function RoleObj:isCanRiseStar()
	local isRise = false
	local quality = self:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]
	local conf1 = GameData:getConfData('heroquality')[quality + 1]
	if not conf1 then
		return isRise
	end
	local level = self:getLevel()
	isRise = level >= conf.conditionHeroLevel

	local isOpen = GlobalApi:getOpenInfo('elite')
	if conf.conditionHeroSoldier > 0 then
		if isOpen then
			local soldier = self:getSoldier()
			isRise = isRise and soldier.level >= conf.conditionHeroSoldier
		else
			isRise = false
		end
	end

	local isOpen = GlobalApi:getOpenInfo('reborn')
	if conf.conditionHeroTalent > 0 then
		if isOpen then
			local level = self:getTalent()
			isRise = isRise and level >= conf.conditionHeroTalent
		else
			isRise = false
		end
	end

	local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
	local itemobj = BagData:getMaterialById(itemId)
	if not itemobj then
		itemobj = ClassItemObj.new(tonumber(itemId),0)
	end
	if itemobj:getNum() >= conf.itemNum then
		isRise = isRise and true
	else
		isRise = false
	end
	return isRise
end

--能否升级
function RoleObj:isCanUpdateLv()
	local isRise = false
	if BagData:getMaterialById(200001):getNum() > 0 then
		isRise = true
	elseif BagData:getMaterialById(200002):getNum() > 0 then
		isRise = true
	elseif BagData:getMaterialById(200003):getNum() > 0 then
		isRise = true
	end

	if self:getLevel() >= UserData:getUserObj().level then
		isRise = false
	end
	
	return isRise
end

function RoleObj:isCanrPromoted()
	local herochangeconf = GameData:getConfData('herochange')
	local MAXPROTYPE = #herochangeconf
	local isPromoted = false
	if  self:getId() < 10000 and self:getId() > 0  and self:isJunZhu()== false and self:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit'))  then
		self.lv = 0
		self.protype = 0
		if self.promote and self.promote[1] then
			self.protype = self.promote[1]
			self.lv = self.promote[2]
		end
		self.nextlv = 0
		self.nextprotype = self.protype 
		if self.lv + 1 >= MAXPROMOTEDLV then
			self.nextlv = 0
			if self.nextprotype + 1 <= MAXPROTYPE then
				self.nextprotype = self.nextprotype + 1
			end
		else
			self.nextlv = self.lv + 1
		end
		if self.nextprotype == MAXPROTYPE then
			self.nextlv = 0
		end
		self.protype ,self.nextprotype  = self:checkPromoteType(self.protype ,self.nextprotype)
		local promotedconf = self:getPromotedConf()
		if self.protype < MAXPROTYPE then
	    	local awards = DisplayData:getDisplayObjs(promotedconf[self.nextprotype][self:getProfessionType()*100+self.nextlv]['cost'])
	    	if awards[1] and awards[1]:getOwnNum() >= awards[1]:getNum() and awards[2] and awards[2]:getOwnNum() >= awards[2]:getNum() then
	    		isPromoted = true
	    	end
	    end    
	end

	return isPromoted
end

--碎片合成数量
function RoleObj:getMergeNum()
	local mergeNum = 0
    if self.baseConf['camp'] ~= 5 and self.baseConf['camp'] ~= 0 then
		local itemobj = BagData:getMaterialById(self.hid)
		if not itemobj then
			itemobj = ClassItemObj.new(tonumber(self.hid),0)
		end
		mergeNum = itemobj:getMergeNum()
	end
	return mergeNum
end

--小兵能否升级
function RoleObj:isSoldierCanLvUp()
	local canlvup = true
	local arr = {}
	local canequip = {}
	local equiparr = self:getSoldierArmArr()

	for i=1,6 do
		local lvlimit = equiparr[i].poslevel
		 if self.soldier.dress[tostring(i)] == 1 then
		 		arr[i] = true
		 		canequip[i] = false
		 else
		 	local dressobj = BagData:getDressById(equiparr[i].id)
		 	if dressobj ~= nil and equiparr[i].num <= dressobj:getNum() and self:getLevel() >=lvlimit then
		 		arr[i] = true
		 		canequip[i] = true
		 	elseif dressobj ~= nil and equiparr[i].num <= dressobj:getNum() then
		 		arr[i] = false
		 		canequip[i] = false
			else
				arr[i] = false
				canequip[i] = false
		 	end
		 end
	end
	for i=1,6 do
		if arr[i] == false  then
			canlvup = false
		end
	end
	for i=1,6 do
		if canequip[i] == true then
			canlvup = true
		end
	end
	if self.soldier.level >= MAXSOLDIERLV then
		canlvup = false
	end
	return canlvup
end
--小兵是否有装备可穿
function RoleObj:isSoldierCanEquip()
	local canequip = false
	local equiparr = self:getSoldierArmArr()

	for i=1,6 do
		local lvlimit = equiparr[i].poslevel
		 if self.soldier.dress[tostring(i)] ~= 1 then
		 	local dressobj = BagData:getDressById(equiparr[i].id)
		 	if dressobj ~= nil and equiparr[i].num <= dressobj:getNum() and self:getLevel() >=lvlimit then
		 		canequip = true
		 	end
		 end
	end
	return canequip
end

function RoleObj:isSoldierSkillCanLvUp()
	local canelvup = false
	
	for i=1,4 do
		local skillarr = self:getSoldierSkillArr()
		local lvlimit = skillarr[i][1]
		if self.soldier.level >= lvlimit then
			local lvconf  = GameData:getConfData('level')
			if tonumber(self.soldier.skills[tostring(i)]+1) < tonumber(#lvconf) then
                local costvalue = 0
                if self.soldier.skills[tostring(i)] == 0 then
                    costvalue = lvconf[1]['soldierskilllevelupcost'] or 0
                else
                    costvalue = lvconf[self.soldier.skills[tostring(i)]]['soldierskilllevelupcost'] or 0
                end

				if tonumber(self.soldier.skills[tostring(i)]+1) <= self:getLevel() and UserData:getUserObj():getGold() >= tonumber(costvalue) then
					canelvup =  true
					break
				else
					canelvup = false
				end
			end
		end
	end
	return canelvup
end

function RoleObj:isFateCanAcitive()
	local fateatt =	self:getFateArr()
	local heroconf = GameData:getConfData('hero')
	local active = false
	local alfatetab = RoleData:getAlreadyFate(RoleData:getRoleByPos(self:getPosId()))
	for j = 1,#fateatt do 
		local statustab = {}
		local n = GlobalApi:tableFind(alfatetab, fateatt[j].fid) 
		if n == 0 then
			for i, v in ipairs(fateatt[j].roleStatus) do
				local tempRole = RoleData:getRoleInfoById(v.hid)

				local zhenren = RoleData:getRoleById(v.hid)
				local card = BagData:getCardById(v.hid)
				if self:isAsssist(fateatt[j].fid, v.hid) then
					statustab[i] = true
				elseif zhenren == nil and card == nil then
					statustab[i] = false
				elseif zhenren ~= nil then
					statustab[i] = true
				elseif zhenren == nil and card ~= nil then
					statustab[i] = true
				end
			end
			local isactive = true
			for i,v in ipairs(statustab) do
				if v == false then
					isactive = false
				end
			end
			if isactive == true then
				return true
			end
		end
	end
	return active
end

function RoleObj:getAutoExchangeEquips()
	local equiparr = {}
	local equipidarr = {}
	local needinheritnum = 0
	local inheriteritgold = 0
	for i=1,6 do
		equipidarr[i] = 0
	end
	for i=1,6 do
		local canexchange = self:isHavebetterEquip(i)
		--print('canexchange==='..tostring(canexchange))
		local equipObj = clone(self.equipMap[i])
		local equipObj1 = self.equipMap[i]
		if canexchange then
			local equips = {}
			local equipMap = clone(BagData:getEquipMapByType(i))
			for k, v in pairs(equipMap) do	
				v:removeAllGem()
				--print(v:getFightForce())
				table.insert(equips, v)
			end
			table.sort(equips, function (a, b)
				local q1 = a:getFightForce()
				local q2 = b:getFightForce()
				if q1 == q2 then
					local f1 = a:getQuality()
					local f2 = b:getQuality()
					return f1 > f2
				else
					return q1 > q2
				end
			end)
			for k,v in pairs(equips) do
				if v:getLevel() <= UserData:getUserObj():getLv() + 10 then
					if equipObj  then
						equipObj:removeAllGem()
						if v:getGodId() == 0 and equipObj:getGodId() > 0 then
							equipObj:resetGod()
						elseif v:getGodId() > 0 then
							local partInfo = self:getPartInfoByPos(tostring(v:getType()))
							v:activateGodByPart(partInfo.level)
						end
						if v:getFightForce() > equipObj:getFightForce() then
							equipidarr[i] = v:getSId()
							equiparr[i] = v:getType()
						end
					else
						equipidarr[i] = v:getSId()
						equiparr[i] = v:getType()
					end
					if equipObj1 and  equipObj1:getGodId() ~= 0 and v:getGodId() == 0 and equipidarr[i] ~= 0  then
						needinheritnum = needinheritnum + 1 
						inheriteritgold = inheriteritgold + v:getInheritCost()
					end
					if equipidarr[i] > 0 then
						break
					end
				end 
			end
		end
	end
	return equipidarr, needinheritnum , inheriteritgold,equiparr
end
--是否能突破
function RoleObj:isTupo()
	local iscantupo = true
	--local  conf = self:getrebornConfByLv(self.talent+1)
	local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('reborn')
	if  not isOpen then
		iscantupo  = false
		return iscantupo 
	end

    local  conf = self:getrebornConfByLv(self.talent+1)
    if not conf then
    	iscantupo  = false
    	return iscantupo 
    end
 	if conf and self:getLevel() < conf['roleLevel'] then
 		iscantupo  = false
 	end
 	local award  = nil 
 	if conf['cost'] and conf['cost'][1] then
		award = DisplayData:getDisplayObj(conf['cost'][1])
	end
   	if award and award:getOwnNum() < award:getNum() then
    	iscantupo  = false
	end
	local award2 = nil 
	if conf['cost'] and conf['cost'][2] then
		award2 = DisplayData:getDisplayObj(conf['cost'][2])
	end
	
    if award2:getOwnNum() < award2:getNum() then
    	iscantupo  = false
    end

    local cardobj =BagData:getCardById(self.hid)
	local havecardnum = 0
	if cardobj ~= nil then
		havecardnum =cardobj:getNum()
	end

    if conf and conf['cardCost'] > 0 and havecardnum <  conf['cardCost'] then
    	iscantupo  = false
    end

    local fragmentobj =BagData:getFragmentById(self.hid)
	local fragmentnum = 0
	if fragmentobj ~= nil then
		fragmentnum =fragmentobj:getNum()
	end

    if conf and conf['fragmentCost'] > 0 and fragmentnum <  conf['fragmentCost'] then
    	iscantupo  = false
    end

    return iscantupo
end
--槽位ID
function RoleObj:getPosId()
	return self.posid
end
--武将ID
function RoleObj:getId( )
	return self.hid
end

--设置武将ID
function RoleObj:setId(id)
	self.hid = id 
end

function RoleObj:getExclusiveId(slot)
	return self.exclusive[tostring(slot)] or 0
end

function RoleObj:setExclusiveId(slot,value)
	self.exclusive[tostring(slot)] = value
end

function RoleObj:judgeHasDrop()
    local judge = false
    local useEffect = self.baseConf.useEffect
    if useEffect then
        local tab = string.split(useEffect,'.')
        if tab and tab[1] == 'drop' then
	        local tab2 = string.split(tab[2],':')
            local dropId = tab2[1]
            if tonumber(dropId) == 5006 or tonumber(dropId) == 5007 or tonumber(dropId) == 5008 or tonumber(dropId) == 5009 or tonumber(dropId) == 5010 then
                judge = false
            else
                judge = true
            end
        end
    end
    return judge
end

function RoleObj:isJunZhu()
	if self.hid > 0 then
		return GameData:getConfData("hero")[self.hid].camp == 5
	else
		return false
	end
end
--是否是主公，用作排序
function RoleObj:isJunZhuforSort()
	local rv = 0
	if self.hid > 0  and GameData:getConfData("hero")[self.hid].camp == 5 then
		rv = 1
	end
	return rv 
end
--战斗力
function RoleObj:getFightForce()
	return RoleData:getPosFightForceByPos(self)
end

--等级
function RoleObj:getLevel()
	if self.baseConf and self.baseConf['camp'] == 5 then
		return UserData:getUserObj():getLv()
	end
	return self.level
end
--经验
function RoleObj:getXp()
	if self.baseConf and self.baseConf['camp'] == 5 then
		return UserData:getUserObj():getXp()
	end
	return self.xp
end
--小兵装备
function RoleObj:setSoldierdress(pos)
	self.soldier.dress[tostring(pos)] = 1
end

-- 得到小兵装备数量
function RoleObj:getSoldierdressNum()
    local num = 0
	for k,v in pairs(self.soldier.dress) do
        if tonumber(v) == 1 then
            num = num + 1
        end
    end
    return num
end

-- 得到小兵装备增加的属性,单独穿戴的数量增加的属性
function RoleObj:getSoldierdressAtts(lv)
	if self.baseConf then        
		local soldiertype = tonumber(self.baseConf['soldierId'])
		local lv = lv or self.soldier.level 

        if lv >= 15 then
            return nil
        end

        local dressSuitTemp = GameData:getConfData('dresssuit')[soldiertype][lv]
        local num = self:getSoldierdressNum()
        

        local atts = {}
        local allAtts = {}
        for k,v in pairs(dressSuitTemp) do
            if v.att1 and v.value1 and v.att1 > 0 and v.value1 > 0 then
                if tonumber(v.dressnum) <= num then
                    atts[tonumber(v.dressnum)] = {}
                    atts[tonumber(v.dressnum)].att1 = v.att1
                    atts[tonumber(v.dressnum)].value1 = v.value1
                end

                allAtts[tonumber(v.dressnum)] = {}
                allAtts[tonumber(v.dressnum)].att1 = v.att1
                allAtts[tonumber(v.dressnum)].value1 = v.value1

            end

        end

        return atts,allAtts
    end
end

--小兵装备
function RoleObj:getSoldierdress(pos)
	return self.soldier.dress[tostring(pos)]
end

--小兵等级
function RoleObj:setSoldierLv()
	self.soldier.level = self.soldier.level +1
	for i=1,6 do
		self.soldier.dress[tostring(i)] = 0
	end
	local skillarr = self:getSoldierSkillArr()
	for i=1,4 do
		if skillarr[i][1] == self.soldier.level then
			self.soldier.skills[tostring(i)] = 1
		end
	end
end

function RoleObj:getSoldierLv()
	return self.soldier.level
end

--小兵技能等级
function RoleObj:setSoldierSkillLv(index)
	self.soldier.skills[tostring(index)] = self.soldier.skills[tostring(index)] + 1
end

--设置小兵技能等级
function RoleObj:setSoldierSkillLvByLv(index,lv)
	self.soldier.skills[tostring(index)] = lv
end

function RoleObj:getSoldierSkillLv(index)
	return self.soldier.skills[tostring(index)]
end

--设置经验相关
function RoleObj:setLevelandXp(level ,xp)
	self.level = level
	self.xp = xp
	self:calbaseAtt()
end

--判断武将等级是否变化
function RoleObj:getLevelIsChange()
    if self.lastLevel ~= self.level then
        self.lastLevel = self.level
        return true
    else
        return false
    end
end

--经验
function RoleObj:getExpPercent()
	local lvconf = GameData:getConfData('level')[self.level]
	local precent = 0
	local curlvexp = 0
	local lvupneedxp = 0
	if lvconf then
		lvupneedxp = lvconf.roleExp
		curlvexp = self.xp
		precent = string.format("%.2f", curlvexp/lvupneedxp*100)  
	end
    if curlvexp == lvupneedxp - 1 then
        precent = 99.99
    end
	return precent,curlvexp,lvupneedxp
end
--属性变化标记
function RoleObj:setFightForceDirty(value)
	self.dirty = value
end
--属性变化标记
function RoleObj:getFightForceDirty()
	return self.dirty
end
--阵营
function RoleObj:getCamp()
	if self.baseConf then
		return self.baseConf['camp']
	end
end
--龙
function RoleObj:getDragon()
	return self.dragon
end
--龙
function RoleObj:setDragon(dragon)
	self.dragon = dragon
end
--龙
function RoleObj:getUrl()
	local roleConf = GameData:getConfData("hero")[tonumber(self.hid)]
	return roleConf.url
end
--计算缘分
function RoleObj:calFate()
	local fatearr = {}
	fatearr = self.baseConf['fateGroup']
	local fateconf = GameData:getConfData('fate')

	for i=1,#fatearr do
		local fatehidarr = {}
		local attidx = 0
		if tonumber(fatearr[i]) > 0 then
			local fateidconf = fateconf[tonumber(fatearr[i])]
			if tonumber(fatearr[i]) > 1000 then -- 主角缘分
				attidx = 1
				fatehidarr[1] = 0
				for j = 2, 5 do
					fatehidarr[j] = fateidconf['hid'..j]
				end
			else
				for j = 1, 5 do
					fatehidarr[j] = fateidconf['hid'..j]
					if fatehidarr[j] == self.hid then
						attidx = j
						fatehidarr[j] = 0 
					end
				end
			end
			local fateatttemp ={
				fateid = 0,    --缘分id
				index = 0,	   --在缘分的第几个位置
				hidarr = {}    --激活需要上阵的武将
			}
			fateatttemp.fateid = fatearr[i]
			fateatttemp.index = attidx
			fateatttemp.hidarr = fatehidarr
			self.fateinfoarr[i] = fateatttemp
		end
	end
end
--缘分
function RoleObj:getfatearrnum()
	return self.fateinfoarr
end
--基础属性
function RoleObj:calbaseAtt()
	local roleConf = GameData:getConfData("hero")[tonumber(self.hid)]
	
	self.baseConf = roleConf
 	if self.baseConf then
 		local rebornconf = GameData:getConfData('reborn')[self.baseConf['rebornType']][self.talent]
		local starconf = GameData:getConfData('heroqualityattr')[self.heroQuality][self.baseConf['ability']]

		self.quality = self.baseConf['quality']

		local attbase = {}
		local atttupo = {}
		local attstar = {}
		local attpromote = {}

		for i=1, self.attcount do
			attbase[i] = 0
			atttupo[i] = 0
			attstar[i] = 0
			attpromote[i] = 0
		end

		--封将属性
		self.promoteconf = self:getPromotedConf()
		if self.promote and self.promote[1] then
			local protype = self:getPromoteType()
			local lv = tonumber(self:getProfessionType()*100 + self.promote[2])
			if self:isJunZhu() == false and protype > 0 then
				attpromote[1] = self.promoteconf[tonumber(protype)][lv]['promoteAddAtk']
				attpromote[2] = self.promoteconf[tonumber(protype)][lv]['promoteAddDef']
				attpromote[3] = self.promoteconf[tonumber(protype)][lv]['promoteAddMagDef']
				attpromote[4] = self.promoteconf[tonumber(protype)][lv]['promoteAddHp']
			end
		end

		--武将表基础属性
		attbase[1] = self.baseConf['baseAttack']
		attbase[2] = self.baseConf['baseDef']
		attbase[3] = self.baseConf['baseMagDef']
		attbase[4] = self.baseConf['baseHp']
		attbase[5] = self.baseConf['baseHit']
		attbase[6] = self.baseConf['baseDodge']
		attbase[7] = self.baseConf['baseCrit']
		attbase[8] = self.baseConf['baseResi']
		attbase[9] = self.baseConf['baseSpeed']
		attbase[10] = self.baseConf['attackSpeed']

		--突破属性 = 突破基础属性+ 等级 * 突破等级对应成长 ;
		atttupo[1] = rebornconf['baseAtk'] + (self:getLevel()-1)*(rebornconf['atkGrowth']*(1+attpromote[1]))
		atttupo[2] = rebornconf['baseDef'] + (self:getLevel()-1)*(rebornconf['defGrowth']*(1+attpromote[2]))
		atttupo[3] = rebornconf['baseMagDef'] + (self:getLevel()-1)*(rebornconf['magDefGrowth']*(1+attpromote[3]))
		atttupo[4] = rebornconf['baseHp'] + (self:getLevel()-1)*(rebornconf['hpGrowth']*(1+attpromote[4]))

		--升星属性
		attstar[1] = starconf['attack']
		attstar[2] = starconf['defence']
		attstar[3] = starconf['mdefence']
		attstar[4] = starconf['hp']



		for i=1,#attbase do
			local attnum = attbase[i] + atttupo[i] + attstar[i]
			self.baseCalAtt_check[i] = GlobalApi:fuckAttribute(attnum)
			self.baseCalAtt[i] = attnum
		end
		self:calFate()
	else
		self.quality = 1
	end
end
--天命激活属性
function RoleObj:getDestinyAttpercent()
	local att = {}
	for i=1,self.attcount do
		att[i] = 0
	end
	if self.destiny.level > 0 then
		local destinyconf =GameData:getConfData('destiny')[self.destiny.level]
		att[1] = destinyconf['atk']
		att[2] = destinyconf['def']
		att[3] = destinyconf['mdef']
		att[4] = destinyconf['hp'] 
	end
	return att 
end

function RoleObj:getDestinyFightForce()
	local destinyconf =GameData:getConfData('destiny')
	local attprcoeffconf = GameData:getConfData('attprcoeff')
	local fightforce = 0
	if self.destiny.level > 0 and self:getQuality() >= 3  then
		fightforce = destinyconf[self.destiny.level][tostring('virtualPower'..self:getQuality())]*attprcoeffconf[self:getLevel()]['sPrC']
	end
	return fightforce
end
--突破激活属性
function RoleObj:getTupoactiveAtt()
	local tupoatt = {}
	if self.baseConf then
		local teamnum = 1
		local talenttype = self.baseConf['rebornType']
		local innateGroupconf =GameData:getConfData('innategroup')[tonumber(self.baseConf['innateGroup'])] 
		local teamtab = innateGroupconf['teamvaluegroup']
		local teamheroID = innateGroupconf['teamheroID']
		local innateconf = GameData:getConfData('innate')
		local teamobj = RoleData:getRoleById(teamheroID)
		local idx = 1
		for i=1,self.talent do
			local s = GlobalApi:tableFind(teamtab,i)
			local att = {}
			if innateGroupconf then 
				local innateid = tonumber(innateGroupconf['level' .. i])
				if innateid < 1000 then
					local effect = innateGroupconf['value' .. i]
					att[1] = innateconf[innateid]['att1']
					att[2] = effect
					
					if tonumber(innateconf[innateid]['att2']) > 0 then
						att[3] = innateconf[innateid]['att2']
						att[4] = effect
					else
						att[3] = 0
						att[4] = 0
					end
					
					if s ~= 0 and teamobj  then
						att[2] = att[2] + innateGroupconf[tostring('teamValues'..teamnum)]
						if tonumber(innateconf[innateid]['att2']) > 0 then
							att[4] = att[4] + innateGroupconf[tostring('teamValues'..teamnum)]
						end			
						teamnum = teamnum + 1
					end
				end
			else
				att[1] = 0
				att[2] = 0
				att[3] = 0
				att[4] = 0
			end
			tupoatt[idx] = att
			idx = idx + 1
		end
	end
	return tupoatt
end
--小兵升级属性
function RoleObj:getSoldierUpgradeAtt(lv,isnext)
	
	lv = lv or self.soldier.level 
	local attarr = {}
	local precentarr = {}
	for i=1,self.attcount do
		attarr[i] = 0
		precentarr[i] = 0
	end

	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		local conf = GameData:getConfData('soldierlevel') [soldiertype][lv]
		for j=1,4 do
			local attid = conf['att'..j ]
			local value1 = conf['value'.. j]
			local value2 = conf['coefficient'.. j]
			attarr[attid] = attarr[attid] + value1
			precentarr[attid] = precentarr[attid] + value2
		end
		if isnext then 
			local conf = GameData:getConfData('soldierlevel') [soldiertype][lv]
			if conf.skillPos > 0 then
				local skillconf = GameData:getConfData('soldierskill')[conf.skillPos]
				local attid = tonumber(skillconf['att'][1])
				local skillvalue = skillconf['value']
				local attBase1 = skillconf['attBase1']
                local attBase2 = skillconf['attBase2']
                local attBase3 = skillconf['attBase3']
				--local skilllv = 1
                -- 这里算增幅
                attarr[attid] = attarr[attid] + skillvalue + lv*lv*attBase1 + lv*attBase2 + attBase3 
				if skillconf['att'][2] then
                    attarr[tonumber(skillconf['att'][2])] = attarr[tonumber(skillconf['att'][2])] + skillvalue + lv*lv*attBase1 + lv*attBase2 + attBase3			
				end
			end

            local atts,allAtts = self:getSoldierdressAtts()
	        for i=1,19 do
                if atts then        
                    for k,v in pairs(atts) do
                        if i == tonumber(v.att1) and attarr[i] then
                            attarr[i] = attarr[i] - v.value1
                        end
                    end
                end
	        end


		end
	end

	-- print('-------------------------')
	-- printall(attarr)
	-- print('-------------------------')
	-- print('+++++++++++++++++++++++++')
	-- printall(precentarr)
	-- print('+++++++++++++++++++++++++')
	return attarr,precentarr
end
--小兵真实属性
function RoleObj:getSoldierAtt(lv,isnext)

	lv = lv or self.soldier.level 
	isnext = isnext or false
	local attarr = {}
	local precentarr = {}
    for i=1,self.attcount do
        attarr[i] = 0
		precentarr[i] = 0
	end

    local atts,allAtts = self:getSoldierdressAtts(lv)
	for i=1,self.attcount do
        if atts then        
            for k,v in pairs(atts) do
                if i == tonumber(v.att1) then
                    attarr[i] = v.value1
                end
            end
        end
	end


	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		
		for x =1,lv-1 do  -- 这里暂时不删除
			local conftemp = GameData:getConfData('soldierlevel') [soldiertype][x]
			for i=1,6 do
				local equipNum = conftemp['equipNum' .. i]
				local equipId = conftemp['equipId' .. i]
				local dressconf = GameData:getConfData('dress')[equipId]
				if dressconf then
					for j=1,2 do
						local dressatt = dressconf['att'.. j]
						local dressvalue = dressconf['value' .. j]*equipNum
						attarr[dressatt] = attarr[dressatt] + dressvalue
					end
				end
			end
		end
		local conf = GameData:getConfData('soldierlevel') [soldiertype][lv]
		for i=1,6 do
			local equipNum = conf['equipNum' .. i]
			local equipId = conf['equipId' .. i]
			local dressconf = GameData:getConfData('dress')[equipId]
			if dressconf and self.soldier.dress[tostring(i)] == 1 and isnext == false then
				for j=1,2 do
					local dressatt = dressconf['att'.. j]
					local dressvalue = dressconf['value' .. j]*equipNum
					attarr[dressatt] = attarr[dressatt] + dressvalue
				end
			end
		end
		for j=1,4 do
			local attid = conf['att'..j ]
			local value1 = conf['value'.. j]
			local value2 = conf['coefficient'.. j]
			attarr[attid] = attarr[attid] + value1
			precentarr[attid] = precentarr[attid] + value2
		end
       
	end

	local skillarr = self:getSoldierSkillArr()
	for i=1,#skillarr do
		if lv >= skillarr[i][1] then
			local skillconf = GameData:getConfData('soldierskill')[skillarr[i][2]]
			local attid = tonumber(skillconf['att'][1])
			local skillvalue = skillconf['value']
			local attBase1 = skillconf['attBase1']
            local attBase2 = skillconf['attBase2']
            local attBase3 = skillconf['attBase3']
			local lv = self.soldier.skills[tostring(i)]
            for m = 1,lv do
                attarr[attid] = attarr[attid] + skillvalue + m*m*attBase1 + m*attBase2 + attBase3
            end
			if skillconf['att'][2] then
                for j = 1,lv do
                    attarr[tonumber(skillconf['att'][2])] = attarr[tonumber(skillconf['att'][2])] + skillvalue + j*j*attBase1 + j*attBase2 + attBase3
                end
			end
		end
	end



	-- print('-------------------------')
	-- printall(attarr)
	-- print('-------------------------')
	-- print('+++++++++++++++++++++++++')
	-- printall(precentarr)
	-- print('+++++++++++++++++++++++++')
	for i,v in ipairs(attarr) do
		attarr[i] = math.floor(v)
	end
	return attarr,precentarr
end
--装备属性
function RoleObj:getEquipAtt()
	local att = {}
	for i=1,self.attcount do
		att[i] = 0
	end
	for i=1,6 do
		if self.equipMap[i] then
		local eatt = self.equipMap[i]:getAllAttr()
			for j=1,self.attcount do
				att[j] = att[j] + eatt[j]
			end
		end
	end
	
	return att
end
--天命
function RoleObj:getDestiny()
	--print('self.destiny.expect==============='..self.destiny.expect)
	return self.destiny
end
--天命
function RoleObj:setDestiny(level,energy,expect)
	self.destiny.level = level
	self.destiny.energy = energy
	--print('self.destiny.expect2222222222222222==============='..self.destiny.expect)
	self.destiny.expect = expect
end

--突破
function RoleObj:getTalent()
	return self.talent
end
--修改突破
function RoleObj:setTalent(level)
	if self.talent ~= level then
		self.talent = level
		self:calbaseAtt()
	end
end
--策划定的计算用基础属性 ====所有属性百分比提升的部分为：（武将基础属性 + 突破属性）* 百分比
function RoleObj:getCalBaseAtt(isonlyforcalc)
	for k, v in ipairs(self.baseCalAtt) do
		GlobalApi:checkAttribute(v, self.baseCalAtt_check[k])
	end
	isonlyforcalc = isonlyforcalc or false
	if isonlyforcalc then
		self:calbaseAtt()
	end
	return self.baseCalAtt
end
--小兵数据
function RoleObj:getSoldier()
	return self.soldier
end
--小兵进阶清空装备
function RoleObj:cleanSoldierDress()
	for i=1,6 do
		self.soldier.dress[tostring(i)] = 0
	end
end
--小兵兵种
function RoleObj:getSoldierId()
	local id = 1
	if self.baseConf then
		id = self.baseConf['soldierId']
	end
	return id 
end
--武将卡片数量
function  RoleObj:getNum()
	return self.cardnum
end

--武将卡片数量--tips用
function  RoleObj:getOwnNum()
	return self.cardnum
end

--修改武将卡片数量
function RoleObj:addNum( num )
	self.cardnum = self.cardnum + num
end
--头像
function RoleObj:getIcon()
	if self.baseConf then
		return 'uires/icon/hero/' .. self.baseConf['heroIcon']
	else
		return ''
	end
end

--武将描述
function RoleObj:getBrief()
	return self.baseConf['roleBrief']
end

--立绘
function RoleObj:getBigCardImg()
	if self.baseConf then
		local url = 'uires/icon/big_hero/' .. self.baseConf['bigIcon']
		-- url = string.gsub(url,'.png','.jpg')
		return url
	else
		return ''
	end
end

--全身像
function RoleObj:getBigIcon()
	if self.baseConf then
		return 'uires/icon/big_hero/' .. self.baseConf['bigIcon']
	else
		return ''
	end
end

--卡背
function RoleObj:getCardIcon()
	if self.baseConf then
		return COLOR_CARDBG[self:getQuality()]
	else
		return COLOR_CARDBG[1]
	end
end

-- 台子~~~~
function RoleObj:getTabIcon()
	if self.baseConf then
		return COLOR_TABBG[self:getQuality()]
	else
		return COLOR_TABBG[1]
	end
end

-- title~~~~
function RoleObj:getTitleIcon()
	if self.baseConf then
		return COLOR_TITLEBG[self:getQuality()]
	else
		return COLOR_TITLEBG[1]
	end
end

--头像框
function RoleObj:getFrame()
	local ALPHA = 'uires/ui/common/bg1_alpha.png'
	return ALPHA
end

function RoleObj:getProfessionType()
	return tonumber(self.baseConf['professionType'])
end

function RoleObj:getProfessionTypeImg()
	local proTypeimg =PROFESSIONTYPE_ICON[1]
	if self.baseConf and self.hid ~= 0 then
		local professionType = tonumber(self.baseConf['ability'])
		proTypeimg = PROFESSIONTYPE_ICON[professionType]
	end
	return proTypeimg
end

--职业
function RoleObj:getAbilityType()
	return tonumber(self.baseConf['ability'])
end

-- 职业图片
function RoleObj:getAbilityImg()
	local ret = ABILITY_ICON[1]
	if self.baseConf and self.hid ~= 0 then
		local ability = tonumber(self.baseConf['ability'])
		ret = ABILITY_ICON[ability]
	end
	return ret
end
--分解获得将魂数量
function RoleObj:getSoulNum()
	local soul = 0
	if self.hid ~= 0 then
		soul = tonumber(self.baseConf['soul'])
	end
	return soul
end

--品质
function RoleObj:setHeroQuality(quality)
	self.heroQuality = quality
	self:calbaseAtt()
end

--品质
function RoleObj:getHeroQuality()
	return self.heroQuality
end

--武将展示品质
function RoleObj:getQuality()
	self.promoteconf = self:getPromotedConf()
	if self.promote and self.promote[1] then
		if  self:getId() < 10000 and self:getId() > 0  and tonumber(self.promote[1]) > 0 and self:isJunZhu() == false
		and self:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit'))  then
			local lv = tonumber(self:getProfessionType()*100 + self.promote[2])
			return self.promoteconf[tonumber(self:getPromoteType())][lv]['quality']
		else
			return self.quality
		end

	else
		return self.quality
	end
end
--武将真实品质
function RoleObj:getRealQulity()
	if self.hid > 0 then
		return GameData:getConfData("hero")[tonumber(self.hid)].quality
	else
		return 1
	end
end


--封神
function RoleObj:getPromoted()
	return self.promote
end

function RoleObj:getPromoteType()
	local protype = 1
	if self:getId() < 10000 and self:getId() > 0 and self.promote and self.promote[1] and self:isJunZhu() == false 
  		and self:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit')) then
		protype = self.promote[1]
		protype = self:checkPromoteType(protype)
	end
	return protype
end
--封神配置
function RoleObj:getPromotedConf()
	local conf = GameData:getConfData('promoteorange')
	if self:getRealQulity() == 5 then
    	conf = GameData:getConfData('promoteorange')
	elseif self:getRealQulity() == 6 then
		conf = GameData:getConfData('promotered')
	elseif self:getRealQulity() == 7 then
		conf = GameData:getConfData('promotegold')
	else
		conf = GameData:getConfData('promoteorange')
	end
	return conf
end
--检查矫正封神进度配置
function RoleObj:checkPromoteType(protype,nextprotype)
    if self:getRealQulity() == 5 then
        if protype < 1 then
            protype = 1
        end
        if nextprotype and nextprotype < 1 then
        	nextprotype = 1
        end
    elseif self:getRealQulity() == 6 then
        if protype < 2 then
            protype = 2
        end
        if nextprotype and nextprotype < 2 then
        	nextprotype = 2
        end
    elseif self:getRealQulity() == 7 then
        if protype < 3 then
            protype = 3
        end
        if nextprotype and nextprotype < 3 then
        	nextprotype = 3
        end
    else
    	protype = 0
    	if nextprotype then
        	nextprotype = 0
        end
    end
   	if nextprotype then
    	return protype , nextprotype
    else
    	return protype
    end
end

function RoleObj:getPromotedIshaveStar(protype, lv)
	local promotedconf = self:getPromotedConf()
	lv = self:getProfessionType()*100+lv
	protype = self:checkPromoteType(protype)
	local havestar = false
	if protype == 3 then
		return havestar
	end
	if lv-1 < self:getProfessionType()*100 then
		if promotedconf[tonumber(protype)][100]['heroStars'] > 0 then
			havestar = true
		end
	elseif lv-1 == self:getProfessionType()*100 then
		if promotedconf[tonumber(protype)][lv]['heroStars'] > 0 then
			havestar = true
		end
	elseif lv-1 > self:getProfessionType()*100 and lv+1 < (self:getProfessionType()*100+MAXPROMOTEDLV) then
		local have1 = promotedconf[tonumber(protype)][lv]['heroStars']
		local have2 = promotedconf[tonumber(protype)][lv+1]['heroStars']
		if have2 > have1 then
			havestar = true
		end
	end
	return havestar
end

function RoleObj:setPromoted(promote)
	self.promote = promote
	self:calbaseAtt()
end
-- 名称颜色
function RoleObj:getNameColor()
	if self.baseConf then
		return COLOR_QUALITY[self:getQuality()]
	else
		return COLOR_TYPE['GRAY']
	end
end

-- 名称描边颜色
function RoleObj:getNameOutlineColor()
	if self.baseConf then
		return COLOROUTLINE_QUALITY
	else
		return COLOROUTLINE_TYPE['GRAY']
	end
end

--武将名
function RoleObj:getName()
	if self.baseConf then
		-- return JunZhu name
		if self.baseConf['camp'] == 5 then
			return GlobalApi:getLocalStr('STR_MAIN_NAME')
		end
		return self.baseConf['heroName']
	else
		return ""
	end
end
--突破类型
function RoleObj:getrebornType()
	local borntype = 1
	if self.baseConf then
		borntype = self.baseConf['rebornType']
	end
	return  borntype
end
--突破基础属性
function RoleObj:getrebornConfByLv(lv)
	local borntype = 1
	if self.baseConf then
		borntype = self.baseConf['rebornType']
	end
	return  GameData:getConfData("reborn")[borntype][lv]
end
--突破激活效果组
function RoleObj:getInnateGroup()
	local groupId = 0
	if self.baseConf then
		groupId = self.baseConf['innateGroup']
	end
	return groupId
end
--突破配置
function RoleObj:getTupoConf()
	return self.tupoConf
end
--目前展示技能固定2个
function RoleObj:getSkillIdTab()
	local skilltab ={}
	local protype = 0

	if self:getId() < 10000 and self:getId() > 0 and self.promote and self.promote[1] and self:isJunZhu() == false 
		and self:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit')) then
		protype = self:getPromoteType()
	end
	local skillgroup = self.baseConf['skillGroupId'][1]
	if protype > 0  then
		skillgroup = self.baseConf['skillGroupId'][protype]
	else
		skillgroup = self.baseConf['skillGroupId'][1]
	end
	local skillgroupconf = GameData:getConfData("skillgroup")
	local skillgrouptab = skillgroupconf[skillgroup]
	local skillid1 = skillgrouptab['autoSkill1']
	local skillid2 = skillgrouptab['angerSkill']
	skilltab[1] = skillid1
	skilltab[2] = skillid2
	return skilltab
end
-- 穿装备
function RoleObj:putOnEquip(equipObj)
	local pos = equipObj:getType()
	local obj = self.equipMap[pos]
	if obj then -- 这个位置已经有装备就先吧装备脱了
		obj:takeOff()
	end
	equipObj:putOn(self.posid, obj, self.talent)
	self.equipMap[pos] = equipObj
end
-- 脱装备
function RoleObj:takeOffEquip(equipPos)
	local obj = self.equipMap[equipPos]
	if obj then -- 这个位置有装备
		obj:takeOff()
		self.equipMap[equipPos] = nil
	end
end
--换将
function RoleObj:exchangeRole(hid,isJunZhu)
	self.hid =hid
    if not isJunZhu then -- 玉玺那个主公换将，不重置品
        self.heroQuality = 1
    end
    self.fateinfoarr = {}
    --self.promote = {}
	if not isJunZhu then
		self.talent = 0
	end
	local roleConf = GameData:getConfData("hero")[self.hid]
	self.baseConf = roleConf
	local protype = 0
    protype = self:checkPromoteType(protype)
    self.promote = {protype,0}
	self:calbaseAtt()
	self:calFate()
	self:setFightForceDirty(true)
end

--缘分激活排序
function  RoleObj:sortByQuality(arr)
	table.sort(arr, function (a, b)
		local q1 = a.isactive
		local q2 = b.isactive
		if (q1 == true and q2 == true)  or (q1 == false and q2 == false ) then
			-- local f1 = a.fname
			-- local f2 = b.fname
			-- return f1 < f2
			return tonumber(a.fid) < tonumber(b.fid)
		elseif q1 == true and q2 == false then 
			return true
		elseif q1 == false and q2 == true then
			return false
		end
	end)
end
--缘分展示数据
function RoleObj:getFateArr(isGetActive)
	local arr = {}
	local heroconf = GameData:getConfData('hero')
	local fateconf = GameData:getConfData('fate')
	local attconf = GameData:getConfData('attribute')

	local currNum = 0
	local maxNum = 0
	local idx = 1
	for i=1,#self.fateinfoarr do
		local atttemp = {
			fid = nil,
			fname = nil,				-- 缘分名字
			roleStatus = {},			-- 相关武将状态 [1] = { hid = 1, active = true }
			effect1 = nil,				-- 效果1名字 [攻击]
			effvalue1 = nil,			-- 效果1值
			effect2 = nil,				-- 效果2名字
			effvalue2 = nil,			-- 效果2值
			isactive = false			-- 是否激活
		}

		atttemp.fid = self.fateinfoarr[i].fateid
		local fname = fateconf[tonumber(self.fateinfoarr[i].fateid)].name
		-- local str = ''
		for j = 1, 5 do
			local hid = tonumber(self.fateinfoarr[i].hidarr[j])
			if hid > 0 then
				local temp = {}
				temp.hid = hid
				local assign = RoleData:getRoleById(hid)
				local assist = self:isAsssist(atttemp.fid, hid)
				temp.active = (assign ~= nil) or assist
				table.insert(atttemp.roleStatus, temp)
			end
		end
		-- str = string.sub(str,0,string.len(str)-3)
		local realeffect = false
		local atttab  = fateconf[tonumber(self.fateinfoarr[i].fateid)]['att'..self.fateinfoarr[i].index ..'1']
		local attvalue = fateconf[tonumber(self.fateinfoarr[i].fateid)]['value'..self.fateinfoarr[i].index ..'1']
		atttemp.fname = fname
		-- atttemp.hnamestr = str
		if atttab  and tonumber(atttab[1]) > 0 then
			if  #atttab > 1 then
				-- 当有多个属性的时候 只有可能是防御
				atttemp.effect1 = GlobalApi:getLocalStr('PROFESSION_NAME3')
			else
				atttemp.effect1 = attconf[tonumber(atttab[1])].name
			end	
			atttemp.effvalue1 = tostring(attvalue)
			realeffect = true
		end

		atttemp.isactive = RoleData:isFateActive(self.fateinfoarr[i].fateid, self)
		local atttab2 = fateconf[tonumber(self.fateinfoarr[i].fateid)]['att'..self.fateinfoarr[i].index ..'2']
		local attvalue2 = fateconf[tonumber(self.fateinfoarr[i].fateid)]['value'..self.fateinfoarr[i].index ..'2']
		--if  tonumber(atttab2[1]) > 0 then
			if atttab2 and tonumber(atttab2[1]) > 0 then
				if #atttab2 > 1 then 
					atttemp.effect2 = GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					atttemp.effect2 = attconf[tonumber(atttab2[1])].name
				end
				atttemp.effvalue2 = tostring(attvalue2)
				realeffect = true
			end

		--end
		if realeffect then
			arr[idx] = atttemp
			maxNum = maxNum + 1
			idx = idx + 1
		end
		if atttemp.isactive then
			currNum = currNum + 1
		end
	end

	if isGetActive then
		return currNum,maxNum
	end
	self:sortByQuality(arr)
	return arr
end
--获取小兵技能信息
function RoleObj:getSoldierSkillArr()
	local soldierlvconf = GameData:getConfData('soldierlevel')
	local arrskill = {}
	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		for i = 1, MAXSOLDIERLV do
			local conf = soldierlvconf[soldiertype][i]
			if tonumber(conf['skillPos']) > 0 then
				local arr = {}
				arr[1] = i
				arr[2] = conf['skillPos']
				table.insert( arrskill, arr)
			end
		end
	end
	return arrskill
end

--获取小兵进阶信息
function RoleObj:getSoldierInfoArr()
	local soldierlvconf = GameData:getConfData('soldierlevel')
	local arrlv = {}
	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		for i=1,MAXSOLDIERLV do
			local conf = soldierlvconf[soldiertype][i]
			local conf1 = nil
			if i>1 then
				conf1 = soldierlvconf[soldiertype][i-1]
			end
			if not conf1 or (conf1 and (conf['soldierIcon'] ~= conf1['soldierIcon']) )  then
				local arr = {}
				arr[1] = i
				arr[2] = conf['soldierIcon']
				table.insert( arrlv, arr)
			end
		end
	end
	-- print('arrlv')
	-- printall(arrlv)
	-- print('arrlv')
	return arrlv
end

--获取小兵装备信息
function RoleObj:getSoldierArmArr()
	local soldierlvconf = GameData:getConfData('soldierlevel') 
	local arrArm = {}
	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		local conf = soldierlvconf[soldiertype][self.soldier.level]
		for i=1,6 do
			local  arr ={}
			arr.id = conf['equipId' .. i]
			arr.poslevel = conf['poslevel' .. i]
			arr.num = conf['equipNum' .. i]
			table.insert(arrArm,arr)
		end
	end
	return arrArm
end
--获取小兵升阶属性
function RoleObj:getSoldierAttarrByLv(lv)
	local soldierlvconf = GameData:getConfData('soldierlevel') 
	local arrAtt = {}
	if self.baseConf then
		local soldiertype = tonumber(self.baseConf['soldierId'])
		local conf = soldierlvconf[soldiertype][lv]
		for i=1,4 do
			local  arr ={}
			arr[1] = conf['att' .. i]
			arr[2] = conf['value' .. i]
			arr[3] = conf['coefficient' .. i]
			table.insert(arrAtt,arr)
		end
	end
	return arrAtt
end
--类型
function RoleObj:getCategory()
	 return 'card'
end
--背景
function RoleObj:getBgImg()
	local frame =COLOR_FRAME[1]
	if self.baseConf then
		frame = COLOR_FRAME[self:getQuality()]
	end
	return frame
end

--获取Y轴偏移
function RoleObj:getUiOffsetY()
	return self.baseConf['uiOffsetY']
end

--碎片脚
function RoleObj:getChip()
	return COLOR_CHIP[self:getRealQulity()]
end

--描述
function RoleObj:getDesc()
	return GlobalApi:getLocalStr('BUY_AND_GET')..self:getName()
end

-- 助阵
function RoleObj:getAssist(fid)
	fid = tonumber(fid)
	return self.assist[fid]
end

function RoleObj:addAssist(fid, hid)
	fid = tonumber(fid)
	hid = tonumber(hid)
	if self.assist[fid] == nil then
		self.assist[fid] = {}
	end
	table.insert(self.assist[fid], hid)
	RoleData:calcFateCards()
end

function RoleObj:delAssist(fid, hid)
	fid = tonumber(fid)
	hid = tonumber(hid)
	if self.assist[fid] == nil then
		return
	end
	local idx = -1
	for i,v in ipairs(self.assist[fid]) do
		if v == hid then
			idx = i
			break
		end
	end
	if idx == -1 then
		return
	end
	table.remove(self.assist[fid], idx)
	RoleData:calcFateCards()
end

function RoleObj:isAsssist(fid, hid)
	fid = tonumber(fid)
	hid = tonumber(hid)
	if self.assist == nil or self.assist[fid] == nil then
		return false
	end

	for i, v in ipairs(self.assist[fid]) do
		if v == hid then
			return true
		end
	end

	return false
end

function RoleObj:cleanupAssist()
	self.assist = {}
end

-- 获得套装属性
function  RoleObj:getRiseStarAttr()
	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
	local quality = self.heroQuality
	local conf = GameData:getConfData('heroqualityattr')[quality][self.baseConf['ability']]
	att[1] = conf.attack
	att[2] = conf.defence
	att[3] = conf.mdefence
	att[4] = conf.hp
	return att
end

-- 获得部位强化属性
function  RoleObj:getPartRefineAttr()
	local attrs = {}
	local attributeConf = GameData:getConfData("attribute")
	for i=1,#attributeConf do
		attrs[i] = 0
	end
	local conf = GameData:getConfData("equiprefine")
	for i=1,6 do
		local partInfo = self:getPartInfoByPos(i)
		local partLv = partInfo.level
		for i,v in pairs(conf[i][partInfo.level].attribute) do
			local tab = string.split(v, ':')
			attrs[tonumber(tab[1])] = attrs[tonumber(tab[1])] + tonumber(tab[2])
		end
	end
	return attrs
end

-- 获得套装属性
function  RoleObj:getSuitAttr()
	local suitLv = {
		[1] = {0,''},
		[2] = {0,''},
		[3] = {0,''},
		[4] = {
				[1] = {},
				[60] = {},
				[70] = {},
				[80] = {},
				[90] = {},
				[100] = {},
				[105] = {},
				},
			}
	local pos = self.posid
	local attrs = {}
	local attributeConf = GameData:getConfData("attribute")
	for i=1,#attributeConf do
		attrs[i] = 0
	end

	local minGodLv = 15
	local minGemLv = 12
	local minRefineLv = 15
	local equipNumTab = {}
	for i=1,6 do
		local obj = self:getEquipByIndex(i)
		if obj then
			local godlv = obj:getGodLevel()
			minGodLv = (godlv > minGodLv) and minGodLv or godlv
			local gems = obj:getGems()
			for i=1,4 do
				local gem = gems[i]
				if gem then
					local gemLv = gem:getLevel()
					minGemLv = (gemLv > minGemLv) and minGemLv or gemLv
				else
					minGemLv = 0
				end
			end
			local currLv = obj:getLevel()
			if obj:isAncient() then
				equipNumTab[currLv] = (equipNumTab[currLv] or 0) + 1
			end
		else
			minGodLv = 0
			minGemLv = 0
		end
		local partInfo = self:getPartInfoByPos(i)
		local partLv = partInfo.level
		minRefineLv = (partLv > minRefineLv) and minRefineLv or partLv
	end
	local lvConf = GameData:getConfData("equiplvsuit")
	local confs = {GameData:getConfData("equipsuit"),GameData:getConfData("gemsuit"),GameData:getConfData("equiprefinesuit")}
	local lvs = {minGodLv,minGemLv,minRefineLv}
	local indexs = {5,7,11}
	for i=1,3 do
		local conf = confs[i][lvs[i]]
		local attr = {}
		local attributes = conf.attribute
		for j,v in ipairs(attributes) do
			local tab = string.split(v, ':')
			attr[tonumber(tab[1])] = tonumber(tab[2])
		end
		suitLv[i] = {lvs[i],GlobalApi:getLocalStr('STR_TAOZHUANG')..':'..GlobalApi:getLocalStr('SUIT_DESC_'..indexs[i])..' Lv.'..lvs[i]..' '..GlobalApi:getLocalStr('STR_JIHUO')}
		for i,v in pairs(attr) do
			attrs[i] = (attrs[i] or 0) + v
		end
	end
	local suitNewData = {
		[1] = {},
		[60] = {},
		[70] = {},
		[80] = {},
		[90] = {},
		[100] = {},
		[105] = {},
	}
	for k,v in pairs(equipNumTab) do
		local currAttrIndex = 0
		local conf = lvConf[k]
		for i=1,4 do
			for j=currAttrIndex + 1,6 do
				if conf['attribute'..j] then
					currAttrIndex = j
					break
				end
			end
			if v >= currAttrIndex then
				suitLv[#suitLv][k][currAttrIndex] = GlobalApi:getLocalStr('STR_TAOZHUANG')..':'..
				conf.name..currAttrIndex..GlobalApi:getLocalStr('SUIT_DESC_1')..' '..GlobalApi:getLocalStr('STR_JIHUO')
				suitNewData[k][currAttrIndex] = 1
				local attributes = conf['attribute'..currAttrIndex]
				for j,v in ipairs(attributes) do
					local tab = string.split(v, ':')
					attrs[tonumber(tab[1])] = attrs[tonumber(tab[1])] + tonumber(tab[2])
				end
			end
		end
	end
	if not self.suitOldData then
		self.suitFlag = false
		self.suitOldData = suitNewData
	else
		local isNew = false
		local updateOld = false
		for k,v in pairs(suitNewData) do
			for k1,v1 in pairs(v) do
				if not self.suitOldData[k][k1] then
					isNew = true
				end
			end
		end
		if not isNew then
			for k,v in pairs(self.suitOldData) do
				for k1,v1 in pairs(v) do
					if not suitNewData[k][k1] then
						updateOld = true
					end
				end
			end
		end
		if updateOld then
			self.suitOldData = suitNewData
			self.suitNewData = suitNewData
		end
		self.suitNewData = suitNewData
	end
	return attrs,suitLv
end

-- 设置套装更新标记
function RoleObj:updateSuitFlag()
	self.suitFlag = false
	self.suitOldData = self.suitNewData
end

-- 获取套装更新标记
function RoleObj:getSuitData()
	return self.suitOldData,self.suitNewData
end

-- 获取套装更新标记
function RoleObj:getSuitFlag()
	if not self.suitNewData or not self.suitOldData then
		return false
	end

	for k,v in pairs(self.suitNewData) do
		for k1,v1 in pairs(v) do
			if not self.suitOldData[k][k1] then
				return true
			end
		end
	end
	return false
end

-- 获取当前武将的配置表 hero
function RoleObj:getConfig(config)
	if config == 'hero' then
		local conf = GameData:getConfData('hero')
		return conf[self.hid]
	elseif config == 'soldierlevel' then
		local conf = self:getConfig('hero')
		if conf ~= nil then
			local soldierlvconf = GameData:getConfData('soldierlevel')
			local soldierid = conf.soldierId
			local level = self:getSoldierLv()
			return soldierlvconf[soldierid][level]
		end
	end
end

-- 播放这个武将的某声音
function RoleObj:playSound(soundType)
	local heroConf = self:getConfig('hero')
	local audioId = nil
	if soundType == 'sound' then
		if heroConf.soundEffect ~= 0 then
			audioId = AudioMgr.playEffect('media/hero/'..heroConf.soundEffect..'.mp3', false)
		end
	elseif soundType == 'dead' then
		if heroConf.deadEffect ~= 0 then
			audioId = AudioMgr.playEffect('media/hero/'..heroConf.deadEffect..'.mp3', false)
		end
	end
	self.audioId[soundType] = audioId
	-- print('[LOG]: play audio id ... ' .. audioId)
end

function RoleObj:stopSound(soundType)
	-- print('[LOG]: stop audio id ... ' .. self.audioId[soundType])
	if self.audioId[soundType] ~= nil then
		AudioMgr.stopEffect(self.audioId[soundType])
		self.audioId[soundType]=nil
	end
end

function RoleObj:getChangeEquipState(customObj)
	local promote
	local weapon_illusion
	local wing_illusion
	if customObj and customObj.advanced then
		promote = customObj.advanced
	else
		promote = self:getPromoteType()
	end
	if self:isJunZhu() then
		local peopleKingData = UserData:getUserObj():getPeopleKing()
		if customObj and customObj.weapon_illusion then
			weapon_illusion = customObj.weapon_illusion
		else
			weapon_illusion = peopleKingData.weapon_illusion
		end
		if customObj and customObj.wing_illusion then
			wing_illusion = customObj.wing_illusion
		else
			wing_illusion = peopleKingData.wing_illusion
		end
	end
	return GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion, self.dragon)
end

-- 宝物装备
function RoleObj:putOnExclusive(id)
    local exclusiveObj = BagData:getExclusiveObjById(id)
	self.exclusive[tostring(exclusiveObj:getType())] = id
end

-- 宝物卸下
function RoleObj:takeOffExclusive(id)
    local exclusiveObj = BagData:getExclusiveObjById(id)
	self.exclusive[tostring(exclusiveObj:getType())] = 0
end

-- 得到宝物属性
function  RoleObj:getExclusiveAttr()
	local attributeConf = GameData:getConfData("attribute")
	local attr = {}
	local attrPer = {}
	local attrName = {}
	local MAX_ITEM = 4
	local MAX_ATTR = 8
	for i=1,MAX_ATTR do
		attr[i] = 0
		attrPer[i] = 0
		attrName[i] = attributeConf[i].name
	end
	for i=1,MAX_ITEM do
		local id = self.exclusive[tostring(i)]
		if id and id ~= 0 then
			local obj = ClassExclusiveObj.new(tonumber(id), 0)
			local baseAttr = obj:getBaseAttrInfo(true)
			local baseAttrPer = obj:getSpecialAttrInfo(true)
			for i=1,MAX_ATTR do
				attr[i] = attr[i] + (baseAttr[i] or 0)
				attrPer[i] = attrPer[i] + (baseAttrPer[i] or 0)
			end
		end
	end
	for i=1,MAX_ATTR do
		attr[i] = attr[i] + math.floor(attr[i] * attrPer[i]*0.01)
	end
	return attr,attrName
end

function RoleObj:isCanEquipExclusiveByType(type)
	local canEquip = false
    if self.exclusive[tostring(type)] == 0 then
        local exclusiveMap = BagData:getAllExclusive()
	    local tab = exclusiveMap[type]
	    if tab then
            for k, v in pairs(tab) do
                if v then
                    canEquip = true
                    break
                end
            end
	    end
    end
    return canEquip
end

function RoleObj:isCanEquipBetterExclusiveByType(type)
    local isHave = false
    local id = self.exclusive[tostring(type)]
    if id > 0 then
        local obj = ClassExclusiveObj.new(id, 0)
        local exclusiveMap = BagData:getAllExclusive()
	    local tab = exclusiveMap[type]
	    if tab then
            for k, v in pairs(tab) do
                if v:getQuality() > obj:getQuality() or (v:getQuality() == obj:getQuality() and v:getLevel() > obj:getLevel()) then
                    isHave = true
                    break
                end
            end
	    end
    end

    return isHave
end

function RoleObj:isCanEquipExclusive()
    local canEquip = false
    for i = 1,4 do
        if self:isCanEquipExclusiveByType(i) == true or self:isCanEquipBetterExclusiveByType(i) == true then
            canEquip = true
            break
        end
    end
    return canEquip
end

function RoleObj:setLightEffect(awardBgImg)
	local effect = awardBgImg:getChildByName('chip_light')
	if effect then
		effect:setVisible(false)
	end
end

function RoleObj:isEquipSpecialExclusive()
	if self.baseConf.exclusiveId > 0 then
		for k, v in pairs(self.exclusive) do
			if self.baseConf.exclusiveId == v then
				return true
			end
		end
	end
	return false
end

function RoleObj:getSpecialExclusiveDes()
	if self.baseConf.exclusiveId > 0 then
		local obj = ClassExclusiveObj.new(tonumber(self.baseConf.exclusiveId), 0)
		return obj:getName(),obj:getExclusiveHeroDesc()
	end
	return nil
end

function RoleObj:isCanRiseQuality()
	local isRise = false
	local level = self:getLevel()
	local soldier = self:getSoldier()
	local quality = self:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]

	isRise = level >= conf.conditionHeroLevel

	if conf.conditionHeroSoldier <= 0 then
		isRise = isRise and true
	else
		isRise = isRise and (soldier.level >= conf.conditionHeroSoldier)
	end
	if conf.conditionHeroTalent <= 0 then
		isRise = isRise and true
	else
		isRise = isRise and (level >= conf.conditionHeroTalent)
	end
	return isRise
end

return RoleObj