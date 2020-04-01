local ClassRoleObj = require('script/app/obj/roleobj')
local ClassDragonObj = require('script/app/obj/dragonobj')

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end

cc.exports.RoleData = {
	rolePosMap = {},		--上阵位置信息
	roleInfoMap	= {},		--纯武将信息
	rolePosAttMap = {},		--各个位置属性信息
	rolePosFightForceMap = {0,0,0,0,0,0,0}, --各个位置战斗力信息
	rolePosFateMap = {},	   --各个位置缘分激活属性
	allfightforce = 0,          --总战斗力
	roleoldatt = {},			--变化属性
	otherolddata = {},			-- 其他变化数据
	runLock = {},				-- 战力滚动锁
	oldFightForces = {},        --每个槽位旧战力
	oldFate = {},				-- 老的缘分记录
	worstequiparr = {},			--最差的6件装备
	dragonMap = {},
	fatecards = {}				--镶嵌在缘分中的卡牌
}

function RoleData:removeAllData()
	self.rolePosMap = {}
	self.roleInfoMap = {}
	self.rolePosAttMap = {}
	self.rolePosFightForceMap = {0,0,0,0,0,0,0}
	self.rolePosFateMap = {}
	self.allfightforce = 0
	self.roleoldatt = {}
	self.otherolddata = {}
	self.runLock = {}
	self.oldFightForces = {}
	self.oldFate = {}
	self.worstequiparr = {}
	self.dragonMap = {}
end

function RoleData:init()
	self:initOtherOldData()
	self:initFateOldData()
	self.attconf = GameData:getConfData('attribute')
	self.attcount = #self.attconf
end

function RoleData:initWithData(data)
	for k, v in pairs(data) do
		local roleObj = ClassRoleObj.new(tonumber(k),0, v)
		self.rolePosMap[tonumber(k)] = roleObj
	end
end

function RoleData:initOtherOldData()
	for i,v in ipairs(self.rolePosMap) do
		local attr,suit = v:getSuitAttr()
		self.otherolddata[i] = suit
	end
end

function RoleData:initDragon(dragon)
	self.dragonMap = {}
	local dragonId
	for k, v in pairs(dragon) do
		dragonId = tonumber(k)
		local dragonObj = ClassDragonObj.new(dragonId, v)
		self.dragonMap[dragonId] = dragonObj
	end
end

function RoleData:createDragon(dragonId,tab)
	local dragonObj = ClassDragonObj.new(dragonId, tab)
	self.dragonMap[dragonId] = dragonObj
end

------------------------------------------------------------------
-- fate attribute update
function RoleData:initFateOldData()
	self.oldFate = self:getAlreadyFateforShow()
end

function RoleData:refreshOldFate()
	self.oldFate = self:getAlreadyFateforShow()
end

function RoleData:getRoleFateOldData()
	return self.oldFate
end

function RoleData:setRoleFateOldData(fates)
	self.oldFate = fates
end

function RoleData:getAlreadyFate(obj)
	local ret = {}
	local fates = obj:getFateArr()
	for m, n in ipairs(fates) do
		if n.isactive == true then
			local have = false
			for j, k in ipairs(ret) do
				if k == n.fid then
					have = true
					break
				end
			end
			if have == false then
				table.insert(ret, n.fid)
			end
		end
	end
	return ret
end

function RoleData:getAlreadyFateforShow()
	local ret = {}
	for i, v in ipairs(self.rolePosMap) do
		local fates = v:getFateArr()
		for m, n in ipairs(fates) do
			if n.isactive == true then
				local have = false
				for j, k in ipairs(ret) do
					if k == n.fid then
						have = true
						break
					end
				end
				if have == false then
					table.insert(ret, n.fid)
				end
			end
		end
	end
	return ret
end
------------------------------------------------------------------

function RoleData:initInfoCard(hid)
	if self.roleInfoMap[hid] == nil then
		local roleobj = ClassRoleObj.new(tonumber(k),0)
		self.roleInfoMap[hid] = roleobj
	end
	return self.roleInfoMap[hid]
end

-- 穿装备
function RoleData:putOnEquip(rolePos, equipObj)
	if rolePos > 0 then
		local roleObj = self.rolePosMap[rolePos]
		if roleObj then
			roleObj:putOnEquip(equipObj)
			roleObj:setFightForceDirty(true)
		end
	end
end

-- 脱装备
function RoleData:takeOffEquip(rolePos, equipPos)
	if rolePos > 0 then
		local roleObj = self.rolePosMap[rolePos]
		if roleObj then
			roleObj:takeOffEquip(equipPos)
			roleObj:setFightForceDirty(true)
		end
	end
end
--换武将
function RoleData:exchangeRole(rolePos,hid,isjunzhu)
	if rolePos > 0 then
		local roleobj =self.rolePosMap[rolePos]
		if roleobj then
			roleobj:exchangeRole(hid,isjunzhu)
		end
	end
	for i=1,#self.rolePosMap do
		self.rolePosMap[i]:setFightForceDirty(true)
	end
end

function RoleData:getMainRole()
	local mainRoleObj
	for i,v in ipairs(self.rolePosMap) do
		if v:getCamp() == 5 then
			mainRoleObj = v
		end
	end
	return mainRoleObj
end

function RoleData:getRoleByPos(pos)
	return self.rolePosMap[pos]
end

function RoleData:getRoleById(id)
	local obj = nil
	for i,v in ipairs(self.rolePosMap) do
		if tonumber(v:getId()) == tonumber(id) then
			obj = v
		end
	end	
	return obj
end

function RoleData:getRoleMap()
	return self.rolePosMap
end

function RoleData:getRoleAssistMap()
	local assistmap = {}
	for k,v in pairs (self.rolePosMap) do
		if v:getId() ~= 0 then
		 	assistmap[v:getId()] = true
		 end
	end
	return assistmap
end

function RoleData:getRoleCardByPos(pos)
	return self.roleCardMap[pos]
end

function RoleData:getRoleInfoById(hid)
	if self.roleInfoMap[hid] == nil then
		self.roleInfoMap[hid] = ClassRoleObj.new(hid,0)
	end
	return self.roleInfoMap[hid]
end

function RoleData:setJunzhuObjId(id)
	local pos = 0
	for k,v in ipairs(self.rolePosMap) do
		if v:isJunZhu() then
			pos = k
			break
		end
	end
	self:exchangeRole(pos,tonumber(id),true)
end

function RoleData:getRoleCardNum()
	return #self.roleCardMap
end

function RoleData:getRoleNum()
	return #self.rolePosMap
end

--缘分是否激活
-- fid 目标缘分 id
-- role 当前缘分所属武将
function RoleData:isFateActive(fid, role)
	fid = tonumber(fid)
	local conf = GameData:getConfData('fate')[fid]
	local heroconf = GameData:getConfData('hero')
	if conf == nil then
		return false
	end

	local arrtemp = {}
	for j = 1,MAXROlENUM do
		local hid = self.rolePosMap[j]:getId()
		if hid > 0 then
			arrtemp[hid]  = hid
		end
	end

	-- add role assist into the array
	local assistArray = role:getAssist(fid)
	if assistArray ~= nil then
		for i, v in ipairs(assistArray) do
			arrtemp[v] = v
		end
	end

	local value = true
	for i=1,5 do
		local id = tonumber(conf['hid' .. i])
		if id > 0 and arrtemp[id] == nil and heroconf[id]['camp'] ~= 5  then
			value = false
			break
		end
	end
	return value 
end

function RoleData:getFateAtt(obj)
	local att = {}
	for i = 1, self.attcount do
		att[i] = 0
	end
	local fateconf = GameData:getConfData('fate')
	if obj:getId() > 0 then
		 local fateatt = obj:getfatearrnum() 
		 for i=1,#fateatt do
		 	local isactive = self:isFateActive(fateatt[i].fateid, obj)
		 	local atttab1 = fateconf[tonumber(fateatt[i].fateid)]['att'..fateatt[i].index ..'1']
			local attvalue = fateconf[tonumber(fateatt[i].fateid)]['value'..fateatt[i].index ..'1']
			local atttab2 = fateconf[tonumber(fateatt[i].fateid)]['att'..fateatt[i].index ..'2']
			local attvalue2 = fateconf[tonumber(fateatt[i].fateid)]['value'..fateatt[i].index ..'2']
			
			if atttab1 then
				for i=1,#atttab1 do
					if  tonumber(atttab1[i]) > 0 and isactive then
						att[tonumber(atttab1[i])] = att[tonumber(atttab1[i])] + attvalue
					end
				end
			end
			if atttab2 then
				for i=1,#atttab2 do
					if atttab2[i] and tonumber(atttab2[i]) > 0 and isactive then
						att[tonumber(atttab2[i])] = att[tonumber(atttab2[i])] + attvalue2
					end
				end
			end
		 end
	end
	return att
end

-- lua 没有 continue 简直可怕……
function RoleData:getTargetRoleAssitInfomation(trole, fid, hid)
	local ret = {}

	-- condition 1 
	-- 上阵武将
	local roles = RoleData:getRoleMap()
	for i, role in ipairs(roles) do
		local c2pass = false
		local c3pass = false
		local c4pass = true
		-- condition 2 
		-- 该武将有缘分尚未激活
		local fates = role:getfatearrnum()
		for k, fateAtt in ipairs(fates) do
		-- for k=1, #fates do
			if RoleData:isFateActive(fateAtt.fateid, role) == false then
				c2pass = true
				-- condition 3
				-- 该武将尚未激活的缘分需要当前点击的武将，
				-- 且当前点击的武将未助阵该武将
				for n, tid in ipairs(fateAtt.hidarr) do
					if tid == hid and role:isAsssist(fateAtt.fateid, hid) == false then
						c3pass = true
						break
					end
				end
			end

			-- condition 4
			-- 该武将的缘分不是当前打开的缘分。
			-- （比如此tips通过甲武将的A缘分中的乙武将点开，
			-- 甲武将的B缘分也需要乙武将，
			-- 则此时tips只显示B缘分，
			-- 不再显示A缘分）
			if role:getId() == trole:getId() and fateAtt.fateid == fid then
				c4pass = false
			end

			if c2pass == true and c3pass == true and c4pass == true then
				local t = {}
				t.role = role
				t.fid = fateAtt.fateid
				table.insert(ret, t)

				c2pass = false
				c3pass = false
				c4pass = false
			end
		end
	end

	return ret
end

--将武将激活的全员属性拆出来
function RoleData:CalPosInnateActive(obj,isonlyforcalc)
	local innateconf = GameData:getConfData('innate')
	local innateGroupconf = GameData:getConfData('innategroup')
	local heroconf = GameData:getConfData('hero')
	local rolePosInnateAllMap = {}  --全体有效的突破激活属性
	local rolePosInnateMap = {}	   --各个位置突破激活属性
	for i=1,MAXROlENUM do
		local objtemp = self:getRoleByPos(i)
		if objtemp:getId() > 0   then
			local att = {}
			local atttemp = {}
			if i ~= obj:getPosId() then
				local innatearr = objtemp:getTupoactiveAtt()
				for j=1,#innatearr do
					local groupid = heroconf[objtemp:getId()].innateGroup
					local innateid = tonumber(innateGroupconf[groupid]['level' .. j])
					if tonumber(innateconf[innateid].target) == 2 then
						atttemp[j] = innatearr[j]
						att[j] = {0,0,0,0}
					else
						att[j] = innatearr[j]
						atttemp[j] = {0,0,0,0}
					end
				end
			else
				local innatearr =obj:getTupoactiveAtt()
				for j=1,#innatearr do
					local groupid = heroconf[obj:getId()].innateGroup
					local innateid = tonumber(innateGroupconf[groupid]['level' .. j])
					if tonumber(innateconf[innateid].target) == 2 then
						atttemp[j] = innatearr[j]
						att[j] = {0,0,0,0}
					else
						att[j] = innatearr[j]
						atttemp[j] = {0,0,0,0}
					end
				end
			end
			rolePosInnateAllMap[i] = atttemp
			rolePosInnateMap[i] = att
		end
	end
	return rolePosInnateAllMap ,rolePosInnateMap
end
--计算突破对单个属性的加成
function RoleData:getInnateAtt(obj,isonlyforcalc)
	local rolePosInnateAllMap , rolePosInnateMap = self:CalPosInnateActive(obj,isonlyforcalc)
	local innateconf = GameData:getConfData('innate')
	local innateGroupconf = GameData:getConfData('innategroup')
	local heroconf = GameData:getConfData('hero')
	local innateposatt = rolePosInnateMap[obj:getPosId()]
	local inateallposatt = rolePosInnateAllMap
	local groupid = heroconf[obj:getId()].innateGroup
	local attpercent = {}
	local attnum = {}
	for i=1, self.attcount do
		attpercent[i] = 0
		attnum[i] = 0
	end
	for i=1,obj:getTalent() do
		local innateid = tonumber(innateGroupconf[groupid]['level' .. i])
		if innateid < 1000 then
			local innateaddtype = tonumber(innateconf[innateid].type)
			if innateposatt[i] then
				local id1 = tonumber(innateposatt[i][1])
				local effect1 = tonumber(innateposatt[i][2])
				local id2 = tonumber(innateposatt[i][3])
				local effect2 = tonumber(innateposatt[i][4])

				if innateaddtype == 1 then
					if id1 > 0 then
						attnum[id1] = attnum[id1] + effect1
					end
					if id2 > 0 then
						attnum[id2] = attnum[id2] + effect2
					end
				else
					if id1 > 0 then
						attpercent[id1] = attpercent[id1] + effect1
					end
					if id2 > 0 then
						attpercent[id2] = attpercent[id2] + effect2
					end
				end
			end
		end
	end
	for j=1,#inateallposatt do
		if inateallposatt[j] then
			for i=1,#inateallposatt[j] do
				local groupid = heroconf[self:getRoleByPos(j):getId()].innateGroup
				local innateid = tonumber(innateGroupconf[groupid]['level' .. i])
				local innateaddtype = tonumber(innateconf[innateid].type)
				local id1 = tonumber(inateallposatt[j][i][1])
				local effect1 = tonumber(inateallposatt[j][i][2])
				local id2 = tonumber(inateallposatt[j][i][3])
				local effect2 = tonumber(inateallposatt[j][i][4])
				if innateaddtype == 1 then
					if id1 > 0 then
						attnum[id1] = attnum[id1] + effect1
					end
					if id2 > 0 then
						attnum[id2] = attnum[id2] + effect2
					end
				else
					if id1 > 0 then
						attpercent[id1] = attpercent[id1] + effect1
					end
					if id2 > 0 then
						attpercent[id2] = attpercent[id2] + effect2
					end
				end
			end
		end
	end

	return attnum , attpercent
end
--isonlyforcalc 此参数为true时只做单纯计算，
function RoleData:CalPosAttByPos(obj,isonlyforcalc)
	isonlyforcalc = isonlyforcalc or false
	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
    --print('pos==============' .. obj:getPosId())
	--local id = 4102
	if obj:getId() > 0  then
		--基础属性
		local baseattarr = obj:getCalBaseAtt(isonlyforcalc)
		for i=1, self.attcount do
			att[i] = math.floor(baseattarr[i])
		end
		-- if obj:getId() == id then 
		-- 	print('------基础属性-----------')
		-- 	printall(att)
		-- 	print('--------基础属性---------')
		-- end
		--突破激活属性
		local attinnatenum , attinnatepercent = self:getInnateAtt(obj,isonlyforcalc)

		for i=1, self.attcount do
			att[i] =  att[i] + math.floor(baseattarr[i]*(attinnatepercent[i]/100))
			att[i] =  att[i] + attinnatenum[i]
		end
		-- if obj:getId() == id then 
		-- 	print('------突破激活属性-----------')
		-- 	printall(att)
		-- 	print('============================0')
		-- 	for i=1,19 do
		-- 		print(i,attinnatenum[i],attinnatepercent[i])
		-- 	end
		-- 	print('--------突破激活属性---------')
		-- end
		--天命属性
		local destinyattarr = obj:getDestinyAttpercent()
		for i=1, self.attcount do
			att[i] =  att[i] + math.floor(baseattarr[i]*(destinyattarr[i]/100))
		end
		-- if obj:getId() == id then 
		-- 	print('------天命属性-----------')
		-- 	printall(att)
		-- 	print('--------天命属性---------')
		-- end
		--缘分属性
		local fatearr = self:getFateAtt(obj)
		for i=1, self.attcount do
			att[i] =  att[i] + math.floor(baseattarr[i]*(fatearr[i]/100))
		end
		-- if obj:getId() == id then
		-- 	print('------缘分属性-----------')
		-- 	printall(att)
		-- 	print('--------缘分属性---------')
		-- end
		--龙属性
		local dragonTotalAttr = {}
	    local dragons = self:getDragonMap()
	    for k, dragon in pairs(dragons) do
	        local dragonAttr = dragon:getAttr()
	        for k2, v2 in pairs(dragonAttr) do
	        	dragonTotalAttr[k2] = dragonTotalAttr[k2] or 0
                dragonTotalAttr[k2] = dragonTotalAttr[k2] + v2
	        end
	    end
		for i, value in pairs(dragonTotalAttr) do
			att[i] =  att[i] + math.floor(value)
		end
		--装备属性
		local equipatt =obj:getEquipAtt()
		for i=1, self.attcount do
			att[i] =  att[i] + equipatt[i]
		end
		-- if obj:getId() == id then 
		-- 	print('------装备属性-----------')
		-- 	printall(att)
		-- 	print('--------装备属性---------')
		-- end
		--兵种属性
		local soldierarr ,soldierpercentarr = obj:getSoldierAtt()
		for i=1, self.attcount do
			att[i] =  att[i] + soldierarr[i]
			att[i] =  att[i] + math.floor(baseattarr[i]*(soldierpercentarr[i]/100))
		end
		-- if obj:getId() == id then 
		-- 	print('------小兵属性-----------')
		-- 	printall(att)
		-- 	print('--------小兵属性---------')
		-- end
		--套装属性
		local suitarr = self:getSuitAttr(obj:getPosId())
		for i=1, self.attcount do
			att[i] =  att[i] + suitarr[i]
		end
		-- if obj:getId() == id then
		-- 	print('------套装属性-----------')
		-- 	printall(att)
		-- 	print('--------套装属性---------')
		-- end
		--成就属性
		local achievementarr = self:getAchievementAttr()
		for i=1, self.attcount do
			att[i] =  att[i] + achievementarr[i]
		end
		-- if obj:getId() == id then
		-- 	print('------成就属性-----------')
		-- 	printall(att)
		-- 	print('--------成就属性---------')
		-- end
		--部位强化属性
		local partrefinetarr = self:getPartRefineAttr(obj:getPosId())
		for i=1, self.attcount do
			att[i] =  att[i] + partrefinetarr[i]
		end
		-- if obj:getId() == id then
		-- 	print('------部位强化属性-----------')
		-- 	printall(att)
		-- 	print('--------部位强化属性---------')
		-- end

		-- 天下合谋
        local attroleconspiracynum , attroleconspiracypercent = self:getRoleConspiracy(obj)
        for i=1, self.attcount do
			att[i] =  att[i] + attroleconspiracynum[i]
			att[i] =  att[i] + attroleconspiracypercent[i]
		end
		--[[
        if obj:getId() == id then 
            print('------天下合谋缘分属性-----------')
            printall(att)
            print('============================0')
            for i=1,19 do
	            print(i,attroleconspiracynum[i],attroleconspiracypercent[i])
            end
            print('--------天下合谋缘分属性---------')
        end
        --]]

		--每日任务爵位属性加成
		local nobilitytarr = self:getNobilityAttr(obj:getPosId())
		for i=1, self.attcount do
			att[i] =  att[i] + nobilitytarr[i]
		end

		-- 人皇属性
		local weaponAttr = self:getPeopleKingWeaponAttr()
		local wingAttr = self:getPeopleKingWingAttr()
		local peopleKingAttr = self:getPeopleKingPvpAttr()
		for i = 1, self.attcount do
			att[i] = att[i] + (weaponAttr[i] or 0) + (wingAttr[i] or 0) + (peopleKingAttr[i] or 0)
		end

		-- 宝物属性
		local exclusivearr = self:getExclusiveAttr(obj:getPosId())
		for i = 1, self.attcount do
			att[i] =  att[i] + exclusivearr[i]
		end
		--[[
		if obj:getId() == 5101 then
		 	print('------宝物属性-----------')
		 	printall(exclusivearr)
		 	print('--------宝物属性---------')
		 end
		 --]]
	end

	if not isonlyforcalc then
		self.roleoldatt[obj:getPosId()] = self.rolePosAttMap[obj:getPosId()]
		self.rolePosAttMap[obj:getPosId()] = att
		obj:setFightForceDirty(false)
	end
	return att
end

-- 天下谋合缘分战斗力计算
function RoleData:getRoleConspiracy(obj)
    local fateAdvancedTypeConf = GameData:getConfData('fateadvancedtype')
    local attributeConf = GameData:getConfData('attribute')
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')

    local att = {}
    local precentarr = {}
	for i=1, self.attcount do
		att[i] = 0
        precentarr[i] = 0
	end

    for i = 1,#fateAdvancedTypeConf do
        local fateAdvancedTypeData = fateAdvancedTypeConf[i]
        local nowLv = UserData:getUserObj():getConspiracy()[tostring(i)] or 0
        local attEffCamp = fateAdvancedTypeData.attEffCamp
        if tablefind(obj:getCamp(),attEffCamp) then
            -- 基础属性
            if nowLv > 0 then
                local fateadvancedData = fateadvancedConf[i][nowLv]
                for j = 1,4 do                
                    local attId = fateAdvancedTypeData['attId' .. j]
                    local attValue = fateadvancedData['attValue' .. j]
                    att[attId] = att[attId] + attValue
                end
                -- 特殊
                local attSpecialId = fateAdvancedTypeData['attSpecialId']
                local attSpecialValue = fateadvancedData['attSpecialValue']
                precentarr[attSpecialId] = precentarr[attSpecialId] + attSpecialValue/100
            end
        end
    end
    return att,precentarr
end

-- 获得套装属性
function  RoleData:getPartRefineAttr(pos)
	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
	if not self.rolePosMap[pos] then
		return att
	else
		local attr = self.rolePosMap[pos]:getPartRefineAttr()
		return attr
	end
end

function RoleData:setAllFightForceDirty()
	for i = 1, MAXROlENUM do
		local obj = self.rolePosMap[i]
		if obj then
			obj:setFightForceDirty(true)
		end
	end
end

function RoleData:CalPosFightForceByPos(obj)
	local fightforce = 0
	local att = self:getPosAttByPos(obj)
	local attprcoeffconf = GameData:getConfData('attprcoeff')
	for i=1,#self.attconf do
		local str = self.attconf[i]['aPrKey']
		fightforce = fightforce + att[i]*self.attconf[i]['factor']*attprcoeffconf[tonumber(obj:getLevel())][str]
	end
	fightforce = fightforce + obj:getDestinyFightForce()
	self.rolePosFightForceMap[obj:getPosId()] = math.floor(fightforce)
	return  math.floor(fightforce )
end

function RoleData:setOldFightForce(fightforce)
	self.oldFightForce = fightforce
end

function RoleData:getOldFightForce()
	if not self.oldFightForce then
		self.oldFightForce = self:getFightForce(true)
	end
	return self.oldFightForce
end

function RoleData:getFightForce(notShow)
	local fightforce = 0
	for i=1,MAXROlENUM do
		if self.rolePosFightForceMap[1] <=0 or (self.rolePosMap[i] and self.rolePosMap[i]:getFightForceDirty()) then
			fightforce = fightforce + self:getPosFightForceByPos(self.rolePosMap[i])
		else
			fightforce = fightforce + self.rolePosFightForceMap[i]
		end
	end
	-- if not notShow and self.oldFightForce and self.oldFightForce ~= fightforce then
	-- 	local showWidgets = {}
	-- 	local addStr = self.oldFightForce > fightforce and ' - ' or ' + '
	-- 	local color = self.oldFightForce > fightforce and COLOR_TYPE.RED or COLOR_TYPE.GREEN
	-- 	local name = GlobalApi:getLocalStr('FIGHT_FORCE')..addStr..math.abs(fightforce - self.oldFightForce)
	-- 	local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
	-- 	w:setTextColor(color)
	-- 	w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
	-- 	w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	-- 	table.insert(showWidgets, w)
	-- 	promptmgr:showAttributeUpdate(showWidgets)
	-- 	self:setOldFightForce(fightforce)
	-- end
	if not self.oldFightForce then
		self.oldFightForce = fightforce
	end
	return fightforce
end

function RoleData:getPosAttByPos( obj )
	local att = {}
	if obj:getFightForceDirty() == false  and obj:getId() > 0  then
		for i=1, self.attcount do
			att[i] = self.rolePosAttMap[obj:getPosId()][i]
		end
	else
		local atttemp = self:CalPosAttByPos(obj)
		self:calcWorstEquip()
		for i=1, self.attcount do
			att[i] = atttemp[i]
		end
	end
	return att
end

-- 获得宝物属性
function  RoleData:getExclusiveAttr(pos)
	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
	if not self.rolePosMap[pos] then
		return att,{{0,''},{0,''},{0,''}}
	else
		local attr,suit = self.rolePosMap[pos]:getExclusiveAttr()
		for i,v in ipairs(att) do
			att[i] = v + (attr[i] or 0)
		end
		return att
	end
end

-- 获得套装属性
function  RoleData:getSuitAttr(pos)
	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
	if not self.rolePosMap[pos] then
		return att,{{0,''},{0,''},{0,''}}
	else
		local attr,suit = self.rolePosMap[pos]:getSuitAttr()
		return attr,suit
	end
end

-- 获得成就属性
function  RoleData:getAchievementAttr()

	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end
	local attrTab = att
	local egg = UserData:getUserObj():getEgg()
	local conf = GameData:getConfData('achievement')
	local egg = UserData:getUserObj():getEgg()
	local min = 0
	local currProgress = 0
	for i,v in ipairs(conf) do
		if egg >= v.egg then
			for j=1,4 do
				attrTab[j] = attrTab[j] + v['attr'..j]
			end
		end
	end
	return attrTab
end

--获得爵位属性
function RoleData:getNobilityAttr()

	local att = {}
	for i=1, self.attcount do
		att[i] = 0
	end

	local nobilityId,nobiltyStar = UserData:getUserObj():getNobility()
	nobilityId = nobilityId or 1
	nobiltyStar = nobiltyStar or 0
	local nobilitybaseCfg = GameData:getConfData('nobiltybase')
	for i=1,4 do	
		local attrValue = nobilitybaseCfg[nobilityId]["attr" .. i] or 0
		att[i] = att[i] + attrValue
	end

	return att
end

function RoleData:runPosFightForceByPos(obj,fightLabel,type,scale)
	fightLabel:stopAllActions()
	fightLabel:setScale(scale)
	local endScale = (scale or 1)*1.5
	local index = obj:getPosId()
	local fightforce = self:CalPosFightForceByPos(obj)
	if self.oldFightForces[index] and fightforce ~= self.oldFightForces[index] then
        self.runLock[index] = true
        fightLabel:setString(self.oldFightForces[index])
        self.oldFightForces[index] = fightforce
        fightLabel:stopAllActions()
        fightLabel:setScale(endScale)
        fightLabel:runAction(cc.DynamicNumberTo:create(type, 1, fightforce, function() 
            self.runLock[index] = false
            fightLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                if self.runLock[index] == true then
                    return
                end
                fightLabel:runAction(cc.ScaleTo:create(0.5,scale))
                fightLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                	fightLabel:setString(fightforce)
                    end)))
            end)))
        end))
	else
		fightLabel:setString(fightforce)
		self.oldFightForces[index] = fightforce
	end
	-- dump(self.oldFightForces)
end

function RoleData:getPosFightForceByPos( obj )
	local fightforce = 0
	fightforce = self:CalPosFightForceByPos(obj)
	return fightforce 
end

function RoleData:getRoleOtherOldData(pos)
	return self.otherolddata[pos]
end

function RoleData:getRoleOldAtt(obj)
	local att = {}
	for i=1, self.attcount do
		if obj:getId() > 0 and self.roleoldatt[obj:getPosId()] then
			att[i] = self.roleoldatt[obj:getPosId()][i]
		else
			att[i] = 0
		end
	end
	return att
end

function RoleData:cleanOldAtt()
	for i=1,MAXROlENUM do
		local attchange = {}
		for i=1, self.attcount do
			attchange[i] = 0
		end
		self.roleoldatt[i] = attchange
	end
end

function RoleData:cleanOldOther(pos,newData)
	self.otherolddata[pos] = newData
end

function RoleData:purge()
	self.rolePosMap = {}
	self.roleCardMap = {}
	self.roleInfoMap = {}
	self.oldFate = {}
end

function RoleData:calcWorstEquip()
	for i=1,MAXEQUIPNUM do
		local arr = {}
		arr.pos = 0
		arr.fightforce = MAXNUM
		self.worstequiparr[i]= arr
	end
	for i=1,MAXROlENUM do
		local hid = self.rolePosMap[i]:getId()
		if hid > 0 then
			for j=1,MAXEQUIPNUM do
				local equipobj = clone(self.rolePosMap[i]:getEquipByIndex(j))
				local fightforce = 0
				if equipobj then
					local atttemp = {}
					for i=1, self.attcount do
						atttemp[i] = 0
					end
					atttemp = clone(equipobj:getAllAttr())
					for x=1,equipobj:getMaxGemNum() do
						local gemObj = clone(equipobj:getGems()[x])
						if gemObj then
							local attrId = gemObj:getAttrId()
							atttemp[attrId] = atttemp[attrId] - gemObj:getValue()
						end
					end
				 	fightforce = clone(equipobj:getFightForcePre(atttemp))
					if self.worstequiparr[j].fightforce > fightforce then
						self.worstequiparr[j].fightforce = fightforce
						self.worstequiparr[j].pos = i
					end
				else
					self.worstequiparr[j].fightforce = 0
					self.worstequiparr[j].pos = i
				end
			end
		end 
	end
end
--获取所有武将身上6个部位最差的一件
function RoleData:getWorstEquipArr()
	return self.worstequiparr
end

function RoleData:getHeadPicObj(id)
	local conf = GameData:getConfData('settingheadicon')[id or 1]

	local obj = {}
	function obj:getId()
		return id 
	end
	function obj:getIcon()
		if not conf then
			return GameData:getConfData('settingheadicon')[1].icon
		end
		return conf.icon
	end
	function obj:getBgImg()
		local frame = COLOR_FRAME[1]
		if conf then
			frame = COLOR_FRAME[conf.quality]
		end
		return frame
	end
	return obj
end

function RoleData:updateDragonMap()
	local treasureInfo = UserData:getUserObj():getTreasure()
	for i = 2,treasureInfo.id - 1 do
		if not self.dragonMap[i] then
			self:createDragon(i,{level = 1})
		end
	end
end

function RoleData:getDragonMap()
	return self.dragonMap
end

function RoleData:getDragonById(id)
	return self.dragonMap[id]
end

function RoleData:mountDragonGem(dragon, dragonGem)
	local dragonId = math.floor(dragon/100)
	if self.dragonMap[dragonId] then
		self.dragonMap[dragonId]:mountDragonGem(dragon%100, dragonGem)
	end
end

function RoleData:calcFateCards()
	self.fatecards = {}
	for m=1,self:getRoleNum() do
		local roleObj = self:getRoleByPos(m)
		local arr = roleObj:getfatearrnum()
		
		for i=1,#arr do
			local assistarr = roleObj:getAssist(arr[i].fateid)
			for j = 1, 5 do
				local hid = tonumber(arr[i].hidarr[j])

				local n = 0 
				if assistarr then
					n = GlobalApi:tableFind(assistarr,hid)
				end
				if n ~= 0 and hid > 0 and hid < 10000 then
					local havefind = false
					for k,v in pairs(self.fatecards) do
						if tonumber(k) == hid then
							havefind = true
							break
						end
					end
					if havefind then
						self.fatecards[hid] = self.fatecards[hid] + 1
					else
						self.fatecards[hid] = 1
					end
				end
			end
		end
	end
end

function RoleData:getFateCards()
	return self.fatecards
end

-- 检查客户端数据是否被修改过
function RoleData:checkAttribute()
	local roleMap = self:getRoleMap()
	for k, heroObj in pairs(roleMap) do
		heroObj:getCalBaseAtt()
		heroObj:getEquipAtt()
	end
	local dragons = self:getDragonMap()
    for k, dragon in pairs(dragons) do
        dragon:getAttr()
    end
	return GlobalApi:isCheat()
end

function RoleData:getPeopleKingWeaponAttr()
	local attr = {}
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	local skyskillConf = GameData:getConfData("skyskill")
	local skyskillupConf = GameData:getConfData("skyskillup")
	local skyweapConf = GameData:getConfData("skyweap")[peopleKingData.weapon_level]
	local skybloodawakenConf = GameData:getConfData("skybloodawaken")
	local skygasawakenConf = GameData:getConfData("skygasawaken")
	local skychangeConf = GameData:getConfData("skychange")[1]

	local skillAttrs = {}
	for k, v in pairs(peopleKingData.weapon_skills) do
        if v > 0 then
            local attrId = skyskillConf[1][tonumber(k)].att
            skillAttrs[attrId] = skillAttrs[attrId] or 0
            skillAttrs[attrId] = skillAttrs[attrId] + skyskillupConf[100 + tonumber(k)][v].attValue
        end
    end

    local changeAdd = 0
    local fixedAttrs = {}
    local attrDescs = {'addAtk','addDef','addMdef','addHp'}
    for k,v in pairs(peopleKingData.ownWeapon) do  	
    	local attrAdd = skychangeConf[v].attribute/100
    	changeAdd = changeAdd + attrAdd
    	for i=1,4 do
    		fixedAttrs[i] = (fixedAttrs[i] or 0) + skychangeConf[v][attrDescs[i]]
    	end
	end
	
    local weaponCollectLv = self:getPeopleKingWeaponCollectLv()
    if weaponCollectLv > 0 then
    	local skycollectConf = GameData:getConfData("skycollect")
    	local collectAdd = skycollectConf[1][weaponCollectLv].attribute/100
    	changeAdd = changeAdd + collectAdd
    end
    
    if peopleKingData.weapon_level > 0 then
        local bloodAtkPercent = skybloodawakenConf[1][peopleKingData.weapon_level].atk*peopleKingData.weapon_blood/100
        local gasAtk = skygasawakenConf[1][peopleKingData.weapon_level].atk*peopleKingData.weapon_gas
        attr[ATTRIBUTE_INDEX.ATK] = math.floor(skyweapConf.atk*(1 + bloodAtkPercent + changeAdd) + gasAtk + (skillAttrs[ATTRIBUTE_INDEX.ATK] or 0))

        local bloodHpPercent = skybloodawakenConf[1][peopleKingData.weapon_level].hp*peopleKingData.weapon_blood/100
        local gasHp = skygasawakenConf[1][peopleKingData.weapon_level].hp*peopleKingData.weapon_gas
        attr[ATTRIBUTE_INDEX.HP] = math.floor(skyweapConf.hp*(1 + bloodHpPercent + changeAdd) + gasHp + (skillAttrs[ATTRIBUTE_INDEX.HP] or 0))

        local bloodDefPercent = skybloodawakenConf[1][peopleKingData.weapon_level].def*peopleKingData.weapon_blood/100
        local gasDef = skygasawakenConf[1][peopleKingData.weapon_level].def*peopleKingData.weapon_gas
        attr[ATTRIBUTE_INDEX.PHYDEF] = math.floor(skyweapConf.def*(1 + bloodDefPercent + changeAdd) + gasDef + (skillAttrs[ATTRIBUTE_INDEX.PHYDEF] or 0))

        local bloodMdefPercent = skybloodawakenConf[1][peopleKingData.weapon_level].mdef*peopleKingData.weapon_blood/100
        local gasMdef = skygasawakenConf[1][peopleKingData.weapon_level].mdef*peopleKingData.weapon_gas
        attr[ATTRIBUTE_INDEX.MAGDEF] = math.floor(skyweapConf.mdef*(1 + bloodMdefPercent + changeAdd) + gasMdef + (skillAttrs[ATTRIBUTE_INDEX.MAGDEF] or 0))
    end
    for k,v in pairs(fixedAttrs) do
    	attr[k] = (attr[k] or 0) + v
    end
    return attr
end

function RoleData:getPeopleKingNextWeaponAttr()
	local attr = {}
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	local next_weapon_level = peopleKingData.weapon_level + 1
	if GameData:getConfData("skyweap")[next_weapon_level] == nil then
		return attr
	end
	local ownWeapon =  clone(peopleKingData.ownWeapon)
	local skyskillConf = GameData:getConfData("skyskill")[1]
	local skyskillupConf = GameData:getConfData("skyskillup")
	local skyweapConf = GameData:getConfData("skyweap")[next_weapon_level]
	local skybloodawakenConf = GameData:getConfData("skybloodawaken")
	local skygasawakenConf = GameData:getConfData("skygasawaken")
	local skychangeConf = GameData:getConfData("skychange")[1]

	local skillAttrs = {}
	local weapon_skills = clone(peopleKingData.weapon_skills)
	for i=1,#skyskillConf do
		if next_weapon_level >= skyskillConf[i].unlock and weapon_skills[tostring(i)] == 0 then
			weapon_skills[tostring(i)] = 1
			break
		end
	end

	for k,v in pairs(weapon_skills) do
        if v > 0 then
            local attrId = skyskillConf[tonumber(k)].att
            skillAttrs[attrId] = skillAttrs[attrId] or 0
            skillAttrs[attrId] = skillAttrs[attrId] + skyskillupConf[100 + tonumber(k)][v].attValue
        end
    end
    
    local changeAdd = 0
    local fixedAttrs = {}
    local attrDescs = {'addAtk','addDef','addMdef','addHp'}
    for k,v in pairs(peopleKingData.ownWeapon) do  	
    	for i=1,4 do
    		fixedAttrs[i] = (fixedAttrs[i] or 0) + skychangeConf[v][attrDescs[i]]
    	end
	end
    for i=1,#skychangeConf do
    	if skychangeConf[i].condition == "level" and skychangeConf[i].value == next_weapon_level then
    		ownWeapon[#ownWeapon+1] = tonumber(skychangeConf[i].id)
    		break
    	end
   	end
    for k,v in pairs(ownWeapon) do
    	local attrAdd = skychangeConf[v].attribute/100
    	changeAdd = changeAdd + attrAdd
	end
    local weaponCollectLv = self:getPeopleKingWeaponCollectLv(next_weapon_level)
    if weaponCollectLv > 0 then
    	local skycollectConf = GameData:getConfData("skycollect")
    	local collectAdd = skycollectConf[1][weaponCollectLv].attribute/100
    	changeAdd = changeAdd + collectAdd
    end

    local bloodAtkPercent = skybloodawakenConf[1][next_weapon_level].atk*peopleKingData.weapon_blood/100
    local gasAtk = skygasawakenConf[1][next_weapon_level].atk*peopleKingData.weapon_gas
    attr[ATTRIBUTE_INDEX.ATK] = math.floor(skyweapConf.atk*(1 + bloodAtkPercent + changeAdd) + gasAtk + (skillAttrs[ATTRIBUTE_INDEX.ATK] or 0))

    local bloodHpPercent = skybloodawakenConf[1][next_weapon_level].hp*peopleKingData.weapon_blood/100
    local gasHp = skygasawakenConf[1][next_weapon_level].hp*peopleKingData.weapon_gas
    attr[ATTRIBUTE_INDEX.HP] = math.floor(skyweapConf.hp*(1 + bloodHpPercent + changeAdd) + gasHp + (skillAttrs[ATTRIBUTE_INDEX.HP] or 0))

    local bloodDefPercent = skybloodawakenConf[1][next_weapon_level].def*peopleKingData.weapon_blood/100
    local gasDef = skygasawakenConf[1][next_weapon_level].def*peopleKingData.weapon_gas
    attr[ATTRIBUTE_INDEX.PHYDEF] = math.floor(skyweapConf.def*(1 + bloodDefPercent + changeAdd) + gasDef + (skillAttrs[ATTRIBUTE_INDEX.PHYDEF] or 0))

    local bloodMdefPercent = skybloodawakenConf[1][next_weapon_level].mdef*peopleKingData.weapon_blood/100
    local gasMdef = skygasawakenConf[1][next_weapon_level].mdef*peopleKingData.weapon_gas
    attr[ATTRIBUTE_INDEX.MAGDEF] = math.floor(skyweapConf.mdef*(1 + bloodMdefPercent + changeAdd) + gasMdef + (skillAttrs[ATTRIBUTE_INDEX.MAGDEF] or 0))
    for k,v in pairs(fixedAttrs) do
    	attr[k] = (attr[k] or 0) + v
    end
    return attr
end

function RoleData:getPeopleKingWingAttr()
	local attr = {}
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	local skyskillConf = GameData:getConfData("skyskill")
	local skyskillupConf = GameData:getConfData("skyskillup")
	local skywingConf = GameData:getConfData("skywing")[peopleKingData.wing_level]
	local skybloodawakenConf = GameData:getConfData("skybloodawaken")
	local skygasawakenConf = GameData:getConfData("skygasawaken")
	local skychangeConf = GameData:getConfData("skychange")[2]

	local skillAttrs = {}
	for k,v in pairs(peopleKingData.wing_skills) do
        if v > 0 then
            local attrId = skyskillConf[2][tonumber(k)].att
            skillAttrs[attrId] = skillAttrs[attrId] or 0
            skillAttrs[attrId] = skillAttrs[attrId] + skyskillupConf[200 + tonumber(k)][v].attValue
        end
    end
    local changeAdd = 0
    local fixedAttrs = {}
    local attrDescs = {'addAtk','addDef','addMdef','addHp'}
    for k,v in pairs(peopleKingData.ownWing) do
    	local attrAdd = skychangeConf[v].attribute/100
    	changeAdd = changeAdd + attrAdd
    	for i=1,4 do
    		fixedAttrs[i] = (fixedAttrs[i] or 0) + skychangeConf[v][attrDescs[i]]
    	end
	end

    local wingCollectLv = self:getPeopleKingWingCollectLv()
    if wingCollectLv > 0 then
    	local skycollectConf = GameData:getConfData("skycollect")
    	local collectAdd = skycollectConf[2][wingCollectLv].attribute/100
    	changeAdd = changeAdd + collectAdd
    end

    if peopleKingData.wing_level > 0 then
        local bloodAtkPercent = skybloodawakenConf[2][peopleKingData.wing_level].atk*peopleKingData.wing_blood/100
        local gasAtk = skygasawakenConf[2][peopleKingData.wing_level].atk*peopleKingData.wing_gas
        attr[ATTRIBUTE_INDEX.ATK] = math.floor(skywingConf.atk*(1 + bloodAtkPercent + changeAdd) + gasAtk + (skillAttrs[ATTRIBUTE_INDEX.ATK] or 0))

        local bloodHpPercent = skybloodawakenConf[2][peopleKingData.wing_level].hp*peopleKingData.wing_blood/100
        local gasHp = skygasawakenConf[2][peopleKingData.wing_level].hp*peopleKingData.wing_gas
        attr[ATTRIBUTE_INDEX.HP] = math.floor(skywingConf.hp*(1 + bloodHpPercent + changeAdd) + gasHp + (skillAttrs[ATTRIBUTE_INDEX.HP] or 0))

        local bloodDefPercent = skybloodawakenConf[2][peopleKingData.wing_level].def*peopleKingData.wing_blood/100
        local gasDef = skygasawakenConf[2][peopleKingData.wing_level].def*peopleKingData.wing_gas
        attr[ATTRIBUTE_INDEX.PHYDEF] = math.floor(skywingConf.def*(1 + bloodDefPercent + changeAdd) + gasDef + (skillAttrs[ATTRIBUTE_INDEX.PHYDEF] or 0))

        local bloodMdefPercent = skybloodawakenConf[2][peopleKingData.wing_level].mdef*peopleKingData.wing_blood/100
        local gasMdef = skygasawakenConf[2][peopleKingData.wing_level].mdef*peopleKingData.wing_gas
        attr[ATTRIBUTE_INDEX.MAGDEF] = math.floor(skywingConf.mdef*(1 + bloodMdefPercent + changeAdd) + gasMdef + (skillAttrs[ATTRIBUTE_INDEX.MAGDEF] or 0))
    end
    for k,v in pairs(fixedAttrs) do
    	attr[k] = (attr[k] or 0) + v
    end
    return attr
end

function RoleData:getPeopleKingNextWingAttr()
	local attr = {}
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	local next_wing_level = peopleKingData.wing_level + 1
	if GameData:getConfData("skywing")[next_wing_level] == nil then
		return attr
	end
	local ownWing = clone(peopleKingData.ownWing)
	local skyskillConf = GameData:getConfData("skyskill")[2]
	local skyskillupConf = GameData:getConfData("skyskillup")
	local skywingConf = GameData:getConfData("skywing")[next_wing_level]
	local skybloodawakenConf = GameData:getConfData("skybloodawaken")
	local skygasawakenConf = GameData:getConfData("skygasawaken")
	local skychangeConf = GameData:getConfData("skychange")[2]

	local skillAttrs = {}
	local wing_skills = clone(peopleKingData.wing_skills)
	for i=1,#skyskillConf do
		if next_wing_level >= skyskillConf[i].unlock and wing_skills[tostring(i)] == 0 then
			wing_skills[tostring(i)] = 1
			break
		end
	end
	for k, v in pairs(wing_skills) do
        if v > 0 then
            local attrId = skyskillConf[tonumber(k)].att
            skillAttrs[attrId] = skillAttrs[attrId] or 0
            skillAttrs[attrId] = skillAttrs[attrId] + skyskillupConf[200 + tonumber(k)][v].attValue
        end
    end
    local changeAdd = 0
    local fixedAttrs = {}
    local attrDescs = {'addAtk','addDef','addMdef','addHp'}
    for k,v in pairs(peopleKingData.ownWeapon) do  	
    	for i=1,4 do
    		fixedAttrs[i] = (fixedAttrs[i] or 0) + skychangeConf[v][attrDescs[i]]
    	end
	end
    local changeAdd = 0
    for i=1,#skychangeConf do
    	if skychangeConf[i].condition == "level" and skychangeConf[i].value == next_wing_level then
    		ownWing[#ownWing+1] = tonumber(skychangeConf[i].id)
    		break
    	end
   	end

    for k,v in pairs(ownWing) do
    	local attrAdd = skychangeConf[v].attribute/100
    	changeAdd = changeAdd + attrAdd
	end

    local wingCollectLv = self:getPeopleKingWingCollectLv(next_wing_level)
    if wingCollectLv > 0 then
    	local skycollectConf = GameData:getConfData("skycollect")
    	local collectAdd = skycollectConf[2][wingCollectLv].attribute/100
    	changeAdd = changeAdd + collectAdd
    end

    local bloodAtkPercent = skybloodawakenConf[2][next_wing_level].atk*peopleKingData.wing_blood/100
    local gasAtk = skygasawakenConf[2][next_wing_level].atk*peopleKingData.wing_gas
    attr[ATTRIBUTE_INDEX.ATK] = math.floor(skywingConf.atk*(1 + bloodAtkPercent + changeAdd) + gasAtk + (skillAttrs[ATTRIBUTE_INDEX.ATK] or 0))

    local bloodHpPercent = skybloodawakenConf[2][next_wing_level].hp*peopleKingData.wing_blood/100
    local gasHp = skygasawakenConf[2][next_wing_level].hp*peopleKingData.wing_gas
    attr[ATTRIBUTE_INDEX.HP] = math.floor(skywingConf.hp*(1 + bloodHpPercent + changeAdd) + gasHp + (skillAttrs[ATTRIBUTE_INDEX.HP] or 0))
    
    local bloodDefPercent = skybloodawakenConf[2][next_wing_level].def*peopleKingData.wing_blood/100
    local gasDef = skygasawakenConf[2][next_wing_level].def*peopleKingData.wing_gas
    attr[ATTRIBUTE_INDEX.PHYDEF] = math.floor(skywingConf.def*(1 + bloodDefPercent + changeAdd) + gasDef + (skillAttrs[ATTRIBUTE_INDEX.PHYDEF] or 0))

    local bloodMdefPercent = skybloodawakenConf[2][next_wing_level].mdef*peopleKingData.wing_blood/100
    local gasMdef = skygasawakenConf[2][next_wing_level].mdef*peopleKingData.wing_gas
    attr[ATTRIBUTE_INDEX.MAGDEF] = math.floor(skywingConf.mdef*(1 + bloodMdefPercent + changeAdd) + gasMdef + (skillAttrs[ATTRIBUTE_INDEX.MAGDEF] or 0))
    for k,v in pairs(fixedAttrs) do
    	attr[k] = (attr[k] or 0) + v
    end
    return attr
end

function RoleData:getPeopleKingWingCollectLv(wing_level)

	local wingCollectLv = 0
	local wing_collect = UserData:getUserObj():getPeopleKing().wing_collect
	if wing_level then
		local skychangeConf = GameData:getConfData("skychange")
		for k, v in ipairs(skychangeConf[2]) do
			if v.condition == "level" and v.value == wing_level then
				wing_collect = wing_collect + 1
				break
			end
		end
	end
	if wing_collect > 0 then
		local skycollectConf = GameData:getConfData("skycollect")
		for k, v in ipairs(skycollectConf[2]) do
			if wing_collect >= v.goalValue then
				wingCollectLv = k
			else
				break
			end
		end
	end
	return wingCollectLv
end

function RoleData:getPeopleKingWeaponCollectLv(weapon_level)

	local weaponCollectLv = 0
	local weapon_collect = UserData:getUserObj():getPeopleKing().weapon_collect
	if weapon_level then
		local skychangeConf = GameData:getConfData("skychange")
		for k, v in ipairs(skychangeConf[1]) do
			if v.condition == "level" and v.value == weapon_level then
				weapon_collect = weapon_collect + 1
				break
			end
		end
	end
	if weapon_collect > 0 then
		local skycollectConf = GameData:getConfData("skycollect")
		for k, v in ipairs(skycollectConf[1]) do
			if weapon_collect >= v.goalValue then
				weaponCollectLv = k
			else
				break
			end
		end
	end
	return weaponCollectLv
end

function RoleData:getPeopleKingPvpAttr()
	local attr = {}
	local peopleKingData = UserData:getUserObj():getPeopleKing()
	local skyBuffLv = peopleKingData.weapon_level
	if skyBuffLv > peopleKingData.wing_level then
		skyBuffLv = peopleKingData.wing_level
	end
	if skyBuffLv > 0 then
		local skybuffConf = GameData:getConfData("skybuff")
		if skybuffConf[skyBuffLv] then
			for k, v in ipairs(skybuffConf[skyBuffLv].att) do
				attr[v] = attr[v] or 0
				attr[v] = attr[v] + skybuffConf[skyBuffLv].value[k]
			end
		end
	end

	local skycollectConf = GameData:getConfData("skycollect")
	local weaponCollectLv = self:getPeopleKingWeaponCollectLv()
	if weaponCollectLv > 0 then
		local attId = skycollectConf[1][weaponCollectLv].att1
		attr[attId] = attr[attId] or 0
		attr[attId] = attr[attId] + skycollectConf[1][weaponCollectLv].value1
	end 

	local wingCollectLv = self:getPeopleKingWingCollectLv()
	if wingCollectLv > 0 then
		local attId = skycollectConf[2][wingCollectLv].att1
		attr[attId] = attr[attId] or 0
		attr[attId] = attr[attId] + skycollectConf[2][wingCollectLv].value1
	end

	return attr
end

--怪物战斗力计算
function RoleData:CalMonsterFightForce(monsterId)
	--计算战力需要的属性
	local calAtts = {
		[1] = "baseAttack",
		[2] = "baseDef",
		[3] = "baseMagDef",
		[4] = "baseHp",
		[5] = "baseHit",
		[6] = "baseDodge",
		[7] = "baseCrit",
		[8] = "baseResi",
		[9] = "",
		[10] = "",
		[11] = "dmgIncrease",
		[12] = "dmgReduce",
		[13] = "",
		[14] = "ignoreDef",
		[15] = "cureIncrease",
		[16] = "",
		[17] = "",
		[18] = "baseMp",
		[19] = "recoverMp",
		[20] = "",
		[21] = "",
		[22] = "",
		[23] = "",
		[24] = "",
		[25] = "",
		[26] = "",
		[27] = "",
	}

	local monsterObj = GameData:getConfData("monster")[monsterId]
	local fightforce = 0
	local attprcoeffconf = GameData:getConfData('attprcoeff')

	for k,v in pairs(calAtts) do
		if v ~= "" then
			local str = self.attconf[k]['aPrKey']
			fightforce = fightforce + monsterObj[v]*self.attconf[k]['factor']*attprcoeffconf[monsterObj.level][str]
		end
	end

	return  math.floor(fightforce)
end