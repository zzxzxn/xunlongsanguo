local ClassMapObj  =require('script/app/obj/mapobj')

cc.exports.MapData = {
	maxProgress = nil,
	currProgress = nil,  --当前已通关的最高关卡
    cloud = 1,
	data = {},
    thiefClick = {},
    allThiefPos = {},
    patrolAccelerate = 0,
    lordId = nil,
    cityProcess = 0,
    combatReset = nil,
    eliteReset = nil,
    lorddrop = 1
}

function MapData:removeAllData()
    self.maxProgress = nil
    self.currProgress = nil
    self.cloud = 1
    self.data = {}
    self.thiefClick = {}
    self.allThiefPos = {}
    self.patrolAccelerate = 0
    self.cityProcess = 0
    self.combatReset = {}
    self.eliteReset = {}
    self.cityTribute = {}
end

function MapData:createAllCity()
	local conf = GameData:getConfData("city")
	for i=0,#conf do
		local mapObj = ClassMapObj.new(conf[i])
        mapObj:setBfirst(true)
		self.data[i] = mapObj
	end
end

function MapData:getUsableStar()
    local maxStar = self:getMaxStar()
    local usedStar = 0
    local tab = UserData:getUserObj():getSkills()
    local conf = GameData:getConfData("playerskillslot")
    for k,v in pairs(tab) do
        local level = tonumber(v.level)
        for i=2,level do
            usedStar = usedStar + conf[tonumber(k)]['star'..i]
        end
    end
    return maxStar - usedStar
end

function MapData:getMaxStar()
    local allStarNum = 0
    for i, v in pairs(self.data) do
        local star = ((v:getStar(1) == -1) and 0 ) or v:getStar(1)
        local star1 = ((v:getStar(2) == -1) and 0 ) or v:getStar(2)
        allStarNum = (allStarNum or 0) + (star or 0) + (star1 or 0)
    end
    return allStarNum
end

function MapData:getCurrEliteCityId()
    local elite = GlobalApi:getOpenInfo('elite')
    if not elite then
        return 0
    end
    local progress = 0
    for i,v in ipairs(self.data) do
        if v:getStar(2) > 0 then
            progress = i
        end
    end
    local data = self.data[progress + 1]
    if data and data:getStar(1) > 0 then
        progress = progress + 1
    end
    return progress
end

function MapData:getFightedEliteCityId()
    local progress = 0
    for i,v in ipairs(self.data) do
        if v:getStar(2) > 0 then
            progress = i
        end
    end
    return progress
end

--当前已通关的最高关卡
function MapData:getFightedCityId()
    local progress = 0
    for i,v in ipairs(self.data) do
        if v:getStar(1) > 0 then
            progress = i
        end
    end
    return progress
end

function MapData:getCanFighttingIdByPage(page)
    if page == 1 then
        return self.currProgress
    elseif page == 2 then
        local id = self:getFightedEliteCityId()
        if self.data[id + 1] and self.data[id + 1]:getStar(1) > 0 then
            return id + 1
        else
            return id
        end
    elseif page == 3 then
        if self.data[self.currProgress] and self.data[self.currProgress]:getStar(1) > 0 then
            return self.currProgress
        else
            return self.currProgress - 1
        end
    -- 太守
    elseif page == 4 then
        return self:getFightedCityId()
    end
end

function MapData:setCityTribute(tribute)
    self.cityTribute = tribute
end

function MapData:initWithData(mapData)
	self:createAllCity()
	self.maxProgress = mapData.max_progress
    self.patrolAccelerate = mapData.patrol_accelerate or 0
    self.lord = mapData.lord
    self.tribute = mapData.tribute
    if mapData.max_progress == mapData.progress then
	   self.currProgress = mapData.progress
    else
        self.currProgress = mapData.progress + 1
    end
    self.patrol = mapData.patrol
	for k, v in pairs(mapData.city) do
		self.data[tonumber(k)]:setCityData(v)
	end
    for i=1,#self.data do
        self.data[i]:setTribute()
    end
    self.cityProcess = mapData.city_process
    self.combatReset = mapData.combat_reset
    self.eliteReset = mapData.elite_reset
    self.cityTribute = mapData.city_tribute
end

function MapData:getOpenCloud()
    local cityData = MapData.data[self.maxProgress]
    local cityData1 = MapData.data[MapData.maxProgress + 1]
    local cloudId = cityData:getGroup()
    local needStar = 10000
    if cityData1 then
       needStar = tonumber(cityData1:getNeedStar())
    end
    local star = MapData:getMaxStar()
    if cityData:getStar(1) > 0 and self.maxProgress ~= #self.data and star >= needStar then
        return true
    else
        if needStar - star > 0 then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('STR_MAX_PROGRESS_CAN_EXPLORE'),needStar - star), COLOR_TYPE.RED)
            MainSceneMgr:showCityCraftRemarkUI()
        else
            MapMgr:setWinPosition(self.currProgress,2)
        end

        return false
    end
end

function MapData:sendCloud(callback)
    local args = {}
    MessageMgr:sendPost('explore','battle',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            local maxProgress = data.max_progress
            if maxProgress then
                self.maxProgress = maxProgress
            end
            local star = self.data[self.currProgress]:getStar(1)
            if star > 0 then
            	self.currProgress = self.currProgress + 1
            	self.data[self.currProgress]:setStar(0,1)
            end
            if callback then
            	callback()
            end
        end
    end)
end

function MapData:setCurrProgress(currProgress)
    self.currProgress = currProgress
end

function MapData:getCombatReset()
    return self.combatReset
end

function MapData:addCombatReset(cityId)
    cityId = tostring(cityId)
    self.combatReset[cityId] = self.combatReset[cityId] or 0
    self.combatReset[cityId] = self.combatReset[cityId] + 1
end

function MapData:getEliteReset()
    return self.eliteReset
end

function MapData:addEliteReset(cityId)
    cityId = tostring(cityId)
    self.eliteReset[cityId] = self.eliteReset[cityId] or 0
    self.eliteReset[cityId] = self.eliteReset[cityId] + 1
end

function MapData:getDropDragons()
    return self.drops_dragon
end

function MapData:setDropDragons(drops_dragon)
    self.drops_dragon = drops_dragon
end

function MapData:setLordDrop( value)
    self.lorddrop = value
end

function MapData:getLordDrop()
    return GameData:getConfData("drop")[self.lorddrop]
end