local MapObj = class("MapObj")

function MapObj:ctor(conf)
	self.conf = conf
end

-- 获取势力
function MapObj:getCamp()
	return self.conf.camp
end

-- 获取势力
function MapObj:getId()
	return self.conf.id
end

-- 设置数据
function MapObj:setCityData(data)
	self.data = data
end

function MapObj:setTribute()
	local isOpen = true
	if self.conf.id == MapData:getFightedCityId() then
		isOpen = MapData.tribute == 1
	end
	if self.data['1'] and self.data['1'].star > 0 and isOpen then
		self.bFirst = false
	else
		self.bFirst = true
	end
end

function MapObj:setBfirst(b)
	self.bFirst = b
end

function MapObj:getBfirst()
	return ((self.bFirst == nil) and true) or self.bFirst
end

function MapObj:checkData()
	if not self.data then
		self.data = {}
		self.data['1'] = {star = -1,time = 0}
		self.data['2'] = {star = 0,time = 0}
		self.data['3'] = {star = 0,time = 0}
		self.data.combat = 0
		self.data.camp = 1
	end
end

-- 获得星
function MapObj:getStar(stype)
	self:checkData()
	return self.data[tostring(stype)].star 
end

-- 设置星
function MapObj:setStar(star,stype)
	self:checkData()
	self.data[tostring(stype)].star = star
end

-- 获得次数
function MapObj:getTimes(stype)
	self:checkData()
	return self.data[tostring(stype)].time
end

-- 更改次数
function MapObj:addTimes(stype,num)
	self:checkData()
	self.data[tostring(stype)].time = self.data[tostring(stype)].time + num
end

-- 设置次数
function MapObj:setTimes(times,stype)
	self:checkData()
	self.data[tostring(stype)].time = times
end

-- -- 获得切磋次数
-- function MapObj:getCombat()
-- 	self:checkData()
-- 	return self.data.combat
-- end

-- -- 获得切磋次数
-- function MapObj:addCombat()
-- 	self:checkData()
-- 	self.data.combat = self.data.combat + 1
-- end

-- 名称
function MapObj:getName()
	return self.conf.name
end

-- 是否翻转
function MapObj:getTurn()
	return self.conf.turn
end

-- 城池组
function MapObj:getGroup()
	return self.conf.group
end

-- 城池类型
function MapObj:getType()
	return self.conf.type
end

-- 城池类型1
function MapObj:getType1()
	return self.conf.type1
end
-- 怪物
function MapObj:getFormation(id)
	local str = 'formation'..id
	return self.conf[str]
end

-- 消耗粮草
function MapObj:getFood(id)
	local str = 'food'..id
	return self.conf[str]
end

-- 挑战次数
function MapObj:getLimits(id)
	local str = 'limit'..id
	return self.conf[str]
end

-- 战斗力
function MapObj:getFightforce(id)
	local str = 'formation'..id
	local conf = GameData:getConfData('formation')[self.conf[str]]
	return conf.fightforce
end

-- 根据ID获得掉落
function MapObj:getDropByGroupId(id)
	local dropData = GameData:getConfData("drop")
	local conf = dropData[id]
	return conf
end

-- 掉落
function MapObj:getDrop(id)
	if id == 4 then
		return self:getDropByGroupId(self.conf['lord'])
	else
		local str = 'drop'..id
		return self:getDropByGroupId(self.conf[str])
	end
end

-- 敌军头像
function MapObj:getHeadpic(id)
	local str = 'headpic'..id
	return self.conf[str]
end

-- 首胜
function MapObj:getFirst(id)
	local str = 'first'..id
	return self.conf[str]
end

-- 文本
function MapObj:getText(id)
	local str = 'unlock'..id
	return self.conf[str]
end

-- 特殊掉落
function MapObj:getSpecial(id)
	if id ~= 3 then
		return
	end
	return self.conf['special']
end

-- 太守产出
function MapObj:getPrefecture()
	return self:getDropByGroupId(self.conf['lord'])
end

-- 巡逻产出金币
function MapObj:getPatrolGold()
	local addition = UserData:getUserObj():getJadeSealAddition("patrol")
	if addition[1] then
		return math.floor(self.conf['patrolGold']*(1 + addition[2]/100))
	else
		return self.conf['patrolGold']
	end
end

-- 巡逻产出金币
function MapObj:getPatrolXp()
	local addition = UserData:getUserObj():getJadeSealAddition("patrol")
	if addition[1] then
		return math.floor(self.conf['patrolXp']*(1 + addition[2]/100))
	else
		return self.conf['patrolXp']
	end
end

-- 巡逻装备
function MapObj:getPatrolEquip()
	local tab = {}
	if tonumber(self.conf['patrolEquipType1']) ~= 0 then
		local id1 = tostring(self.conf['patrolEquipType1']..self.conf['patrolEquipQuality']..string.format('%03d',tonumber(self.conf['patrolEquipLevel']))..'1')
		tab[tonumber(self.conf['patrolEquipType1'])] = {'equip',id1,0,1}
	end
	if tonumber(self.conf['patrolEquipType2']) ~= 0 then
		local id2 = tostring(self.conf['patrolEquipType2']..self.conf['patrolEquipQuality']..string.format('%03d',tonumber(self.conf['patrolEquipLevel']))..'1')
		tab[tonumber(self.conf['patrolEquipType2'])] = {'equip',id2,0,1}
	end
	return tab
end

-- 开启等级
function MapObj:getLevel()
	return self.conf['level']
end

-- 开启需要星
function MapObj:getNeedStar()
	return self.conf['star']
end

-- 城市资源
function MapObj:getBtnResource()
	-- return 'uires/ui/mainscene/mainscene_city'..self.conf.type..'.png'
	return 'uires/ui/mainscene/mainscene_city_'..self.conf.type..'_'..self.conf.type1..'.png'
end

-- 城市资源
function MapObj:getTypes()
	-- return 'uires/ui/mainscene/mainscene_city'..self.conf.type..'.png'
	return self.conf.type,self.conf.type1
end

-- 城市坐标
function MapObj:getBtnPos()
	return cc.p(self.conf.posX,self.conf.posY)
end

-- 地图碎片坐标
function MapObj:getThiefPos()
	local tab = self.conf.thiefpos
	return tab
end

-- 地图碎片资源
function MapObj:getMapChipResource()
	return 'uires/ui/mainscene/mainscene_'..self.conf.id..'.png'
end

-- chipImg
function MapObj:getBcakId()
	return self.conf.bcakId
end

function MapObj:getChipId()
	return self.conf.chipId
end

function MapObj:getOwner()
	return self.owner
end

function MapObj:setOwner(owner)
	self.owner = owner
end

function MapObj:getDesc()
	return self.conf.desc
end

function MapObj:getDesc1()
	return self.conf.desc1
end

function MapObj:getTribute()
	return self.conf.tribute
end

--内城,外城,帅府
function MapObj:getPformation1()
	return self.conf.pformation1
end

function MapObj:getPfirstDrop(page)
	local id = self.conf.pfirst1[page]
	return self:getDropByGroupId(id)
end

function MapObj:getFuncOpen()
	return self.conf.funcOpen
end

function MapObj:getDragon()
	return self.conf.dragon
end

return MapObj