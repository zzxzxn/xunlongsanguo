local ClassMineUI               = require("script/app/ui/goldmine/mineui")
local ClassMineQueueUI          = require("script/app/ui/goldmine/minequeue")
local ClassMineCollectListUI    = require("script/app/ui/goldmine/minecollectlist")


cc.exports.eResourceAreaResourceType=
{
	eResourceAreaResourceType_None=0,		--没有资源或异常
	eResourceAreaResourceType_Tong=1,		--铜
	eResourceAreaResourceType_Yin=2,		--银
	eResourceAreaResourceType_Jin=3,		--金
	eResourceAreaResourceType_HuangBaoShi=4,--黄宝石
	eResourceAreaResourceType_HongBaoShi=5,	--红宝石
	eResourceAreaResourceType_LvBaoShi=6,	--绿宝石
	eResourceAreaResourceType_LvBaoShi=7,	--绿宝石
	eResourceAreaResourceType_LvBaoShi=8,	--绿宝石
	eResourceAreaResourceType_LvBaoShi=9,	--绿宝石
	eResourceAreaResourceType_LvBaoShi=10,	--绿宝石
	eResourceAreaResourceType_Statue=11,	--雕像
};
--挖矿操作
cc.exports.eResourceAreaOpFlag = 
{
	eResourceAreaOpFlag_Other=0,--其他
	eResourceAreaOpFlag_PlayerExplore=1,--玩家挖掘
	eResourceAreaOpFlag_PlayerUseBomb=2,--玩家使用炸弹
	eResourceAreaOpFlag_SystemInit=3,--系统初始化
	eResourceAreaOpFlag_GetAllRes=4,--一键收取
	eResourceAreaOpFlag_UpdateGetResQueue=5,--更新收取队列
	eResourceAreaOpFlag_FightWithStatue=6,--与矿区雕像战斗
};

cc.exports.MineMgr = {
    uiClass = {
        mineUI = nil,
        mineQueueUI  = nil,
        mineCollectListUI = nil,
    },


    _aroundOffsets = {{x=0, y=2}, {x= -1, y= 1},{x = 0, y=1},
                    {x=1, y=1}, {x= -2, y= 0},{x =-1, y=0}, 
					{x=0, y=0}, {x= 1,  y= 0},{x = 2, y=0}, 
					{x=-1,y=-1},{x= 0,  y=-1}, {x=1, y=-1}, {x=0, y=-2},},

    _timeRatio = {},
 

    _bAcceptBaseData = false, --是否接受基础信息数据
		
	--矿区基本信息
	_refreshTime = 0, --矿区刷新时间
	_refreshConsumeJewel = 0, --矿区刷新单位时间消耗的血钻
	_refreshConsumeJewelTime = 0, --矿区刷新单位时间
	_curAreaID = 1, --当前所在区域ID
	_changeAreaFlag = false, --切换地图标记
	_resetFlag = false, --重置矿区标记
	_areas = {}, --矿区所对应随机数种子{.seed=seed, .width=width, .height=height, .maxDeep=maxDeep}
		
	--矿镐属性相关
	_sumDigCount = 0, --最大挖掘次数
	_remainDigCount = 0, --当前挖掘次数
	_mineAxeLev = 0, --矿镐等级
	_mineAxeDigTime = 0.0, --矿镐挖掘时间(1.5s)
	_mineAxeRecoverCD = 0.0, --矿镐恢复的总时间
	_mineAxeRecoverTime = 0.0, --矿镐上次恢复的时间点，比如减去当前时间等于15s，比如矿镐恢复总时间为10s，那么现在走到进度条走到中间5s那个位置
	_mineAxeAreaID = 0, --矿镐当前挖掘的区域ID
	_lastX = 0, --上次挖掘X坐标
	_lastY = 0, --上次挖掘Y坐标
	
    _buy = 0, -- 矿镐已购买次数

	--雕像相关
	_statueLev = 0, --雕像等级
	_statueCount = 0, --雕像个数
	_statueCueFlag = false, --雕像提示标志
	_bossAreaID = 0, --boss区域ID
	_bossPosX = 0, --boss坐标X
	_bossPosY = 0, --boss坐标Y
	_bossRemainTime = 0.0, --boss剩余时间
	_bossLev = 0, --bossID
	_bossCueFlag = false, --boss提示标志
	_boosResetFlag = false, --boss消失，时间重置标记
		
	_maxQueueCount = 0, --收矿队列最大值		
	_collectQueue = {}, --收取矿石队列
	_earth = {}, --矿区中稀有土壤表
	_grid = {}, --矿区中所显示所有的矿石表 {"ID" = {{"xy" = data}, ...}, ...}
	_unMask = {}, --阴影块
	_wait = {}, --等待块
	_getAllMine = {}, --全部收取表
	_updateGrid = {}, --更新消息更新的格子
	_updateDigGrid = {}; --单独缓存挖掘时更新的格子
	----_op = eResourceAreaOpFlag.eResourceAreaOpFlag_Other, --矿区操作(挖掘, 收矿, 炸弹, 一键收取)
		
	--服务器发过来矿区里面的矿石各个位判断标记(0-3位表示矿石的种类,4-6位表示矿石的等级,7位表示矿是否被挖掘)
	_mineTypeBit = 0, --矿石的类型
	_mineLevBit = 112, --矿石的等级
	_bDigBit = 0, --是否被挖掘

    areaMaxID = 5,
    cellWidth = 72,
    cellHeight = 72,
    _maxDeep = 1,

    _statueList = {},
    _curStatueIndex = 1,
}
setmetatable(MineMgr.uiClass, {__mode = "v"})

function MineMgr:showMineUI()
    if self.uiClass["mineUI"] == nil then
        self.uiClass["mineUI"] = ClassMineUI.new()
        self.uiClass["mineUI"]:showUI()
    end
end

function MineMgr:hideMineUI()
    if self.uiClass["mineUI"] ~= nil then
        self.uiClass["mineUI"]:hideUI()
        self.uiClass["mineUI"] = nil
    end
end
function MineMgr:refreshMineCons()
    if self.uiClass["mineUI"] ~= nil then
        self.uiClass["mineUI"]:refreshMineCons()
    end
end
function MineMgr:showMineQueueUI()
    if self.uiClass["mineQueueUI"] == nil then
        self.uiClass["mineQueueUI"] = ClassMineQueueUI.new()
        self.uiClass["mineQueueUI"]:showUI()
    end
end

function MineMgr:hideMineQueueUI()
    if self.uiClass["mineQueueUI"] ~= nil then
        self.uiClass["mineQueueUI"]:hideUI()
        self.uiClass["mineQueueUI"] = nil
    end
end
function MineMgr:showMineColloectListUI()
    if self.uiClass["mineColloectListUI"] == nil then
        self.uiClass["mineColloectListUI"] = ClassMineCollectListUI.new()
        self.uiClass["mineColloectListUI"]:showUI()
    end
end

function MineMgr:hideMineColloectListUI()
    if self.uiClass["mineColloectListUI"] ~= nil then
        self.uiClass["mineColloectListUI"]:hideUI()
        self.uiClass["mineColloectListUI"] = nil
    end
end

function MineMgr:initData()
		self._bAcceptBaseData = false;
		self._refreshTime = 0.0;
		self._refreshConsumeJewel = 0;
		self._refreshConsumeJewelTime = 0;
		self._curAreaID = 1;
		self._changeAreaFlag = false;
		self._areas = {};
		
		--矿镐属性相关
		self._sumDigCount = 0;
		self._remainDigCount = 0;
		self._mineAxeLev = 0;
		self._mineAxeDigTime = 0.0;
		self._mineAxeRecoverCD = 0.0;
		self._mineAxeRecoverTime = 0.0;
		self._mineAxeAreaID = 0;
		self._lastX = 0;
		self._lastY = 0;
		self._buy = 0

		--雕像相关
		self._statueLev = 0;
		self._statueCount = 0;
		self._statueCueFlag = false;
		self._bossAreaID = 0;
		self._bossPosX = 0;
		self._bossPosY = 0;
		self._bossRemainTime = 0.0;
		self._bossLev = 0;
		self._bossCueFlag = false;
		self._boosResetFlag = false;
					
		
		self._collectQueue = {};
		self._earth = {};
		self._grid = {};
		self._unMask = {};
		self._wait = {};
		self._getAllMine = {};
		self._updateGrid = {};
		self._updateDigGrid = {};
        self._statueList = {};
        self._curStatueIndex = 1;
		----self._op = eResourceAreaOpFlag.eResourceAreaOpFlag_Other;
		
		self._mineTypeBit = 15; --矿石的类型
		self._mineLevBit = 112; --矿石的等级
		self._bDigBit = 128; --是否被挖掘
        self._maxDeep = 1;
                                                   
        self.config_bomb    = GameData:getConfData("diggingbomb")
        self.config_ground  = GameData:getConfData("digginglevel")
        self.config_earth   = GameData:getConfData("diggingrock")
        self.config_mine    = GameData:getConfData("diggingproduct")
        self.config_show_mine = GameData:getConfData("local/diggingshowproduct")
        self.config_enemy   = GameData:getConfData("diggingenemy")

        for i = 1,3 do
            self._timeRatio[i] = tonumber(GlobalApi:getGlobalValue("diggingQualityCostTimes"..i))
        end

        local vip = UserData:getUserObj():getVip()
        self._maxQueueCount =  GameData:getConfData("vip")[tostring(vip)].diggingQueue
        self._mineAxeRecoverCD   = tonumber(GlobalApi:getGlobalValue("diggingToolCD"))
        self._diggingToolPrice   = tonumber(GlobalApi:getGlobalValue("diggingToolPrice"))
        self._diggingToolPerDeal = tonumber(GlobalApi:getGlobalValue("diggingToolPerDeal"))
        self._diggingCollectAllPrice     =  tonumber(GlobalApi:getGlobalValue("diggingCollectAllPrice"))
        self._diggingCollectAllUnitTime  =  tonumber(GlobalApi:getGlobalValue("diggingCollectAllUnitTime"))
        self._refreshConsumeJewel        =  tonumber(GlobalApi:getGlobalValue("diggingResetPrice"))
        self._refreshConsumeJewelTime    =  tonumber(GlobalApi:getGlobalValue("diggingResetUnitTime"))
        

        self.width  = tonumber(GlobalApi:getGlobalValue("diggingWidth"))
        self.height = tonumber(GlobalApi:getGlobalValue("diggingDepth"))
        

end

function MineMgr:getWidth()
--		if (nil == self._areas[self._curAreaID]) then
--			return 0;
--		end

--		local width = self._areas[self._curAreaID].width;
--		if (nil == width) then
--			return 0;
--		end
		return  self.width; 
	end
	
function MineMgr:getHeight() 
--		if (nil == self._areas[self._curAreaID]) then
--			return 0;
--		end

--		local height = self._areas[self._curAreaID].height;
--		if (nil == height) then
--			return 0;
--		end
		return self.height; 
end
function MineMgr:getMaskInCell(pos, id) 
	id = id or self._curAreaID;
	local index = tostring(id) .. "@" .. tostring(pos.x) .. "@" .. tostring(pos.y);
	return self._unMask[index];
end
	
function MineMgr:getMineType (data)
    return bit:_and(self._mineTypeBit, data); 
end


--获得矿区单元格的矿的种类:土, 矿(挖掘, 未挖掘), 空.ps返回两个值，一个土壤的枚举，一个矿的枚举
function MineMgr:getTypeInCell(pos, id) 
		id = id or self._curAreaID;
		local index = tostring(id) .. "@" .. tostring(pos.x) .. "@" .. tostring(pos.y);
		local earth = nil;
		local mine = nil;
		local mask = self:getMaskInCell(pos, id);
		
		--先检测该矿块是否矿
		local mineCell = self._grid[index];
		if (nil ~= mineCell) then --有矿 or 空
			mine = self:getMineType(mineCell.data); --矿的种类
			if (mine == eResourceAreaResourceType.eResourceAreaResourceType_None) then
				mine = nil;
			end
			
			local bDig = self:getMineDig(mineCell.data);
			if (bDig) then
				return earth, mine, mask;
			end
		end
		
		earth = self:getEarthInCell(pos, id);
		return earth, mine, mask;
end
function MineMgr:getEarthInCell(pos, id)
	id = id or self._curAreaID;
	local index = tostring(id) .. "@" .. tostring(pos.x) .. "@" .. tostring(pos.y);
	local earth = self._earth[index];
	return earth;
end
function MineMgr:getMinePath(goodId) 
	local goodIni = tb_Goods[goodId];
	if (nil == goodIni) then
		return;
	end
		
	local resId = goodIni.ResId;
	if (nil == resId) then
		return;
	end
	return "uires/ui/mine/" .. resId .. ".png";
end	

function MineMgr:getMineLev(data) 
    local lev = bit:_and(self._mineLevBit, data); 
    return bit:_rshift(lev, 4); 
end

function MineMgr:getMineLevInCell(pos) --获得单元格矿的等级
	local index = tostring(self._curAreaID) .. "@" .. tostring(pos.x) .. "@" .. tostring(pos.y);
	local mineCell = self._grid[index];
	if (nil == mineCell) then
		return 0;
	end
	return self:getMineLev(mineCell.data);
end

function MineMgr:getWaitInCell(pos, id)
	id = id or self._curAreaID;
	local index = tostring(id) .. "@" .. tostring(pos.x) .. "@" .. tostring(pos.y);
	return self._wait[index];
end

function MineMgr:IsInCollectQueue(pos, areaId)
	local cell = nil;
	for i=1, #self._collectQueue do
		repeat
		areaId = areaId or self._curAreaID;
		cell = self._collectQueue[i];
		if (nil == cell) then
			break;
		end
			
		if (areaId == cell.id) and (pos.x == cell.x) and (pos.y ==cell.y) then
			return true;
		end
		until true
	end
	return false;
end
function MineMgr:GetNextStatePos()

    local bossList = self._areas[self._curAreaID].bossList
    if(self._curStatueIndex > #bossList) then
        self._curStatueIndex = 1
    end

    if(self._curStatueIndex > #bossList) then
        return nil
    else
        local ret =  bossList[self._curStatueIndex]
        self._curStatueIndex = self._curStatueIndex + 1
        return ret
    end
end
function MineMgr:GetBossPos()
    if(self._bossRemainTime > 0) then
        return cc.p(self._bossPosX,self._bossPosY)
    end
    return nil
end
function MineMgr:getMaxDeepForArea()
	return self._maxDeep;
end
function MineMgr:coordinateConvertY(posY) 
    return self:getHeight() - 1 - posY;
end

function MineMgr:IsHasArea(areaID)
    return (nil ~= self._areas[areaID]); 
end
function MineMgr:getMineDig(data)
    return data >= self._bDigBit; 
end
function MineMgr:clearUpdateDigGrid()
    self._updateDigGrid = {}; 
end

function MineMgr:createMask(tab)
	local rect = cc.rect(0, 0, self:getWidth()-1, self:getHeight()-1);						
	for i=1, #tab do--k, v in pairs(tab) do
		repeat
		local key = tab[i];
		if (nil == key) then
			break;
		end
			
		local v = self._grid[key];
		if (nil == v) then
			break;
		end
			
		if (v.data == 39) then --矿区boss标记为无阴影
			local key = tostring(v.id) .. "@" .. tostring(v.x) .. "@" .. tostring(v.y);
			if (self._unMask[key] ~= nil) then
				break;
			end
			self._unMask[key] = {};
			self._unMask[key].x = v.x;
			self._unMask[key].y = v.y;
			self._unMask[key].id = id;
			break;
		end
			
		local bHit =  cc.rectContainsPoint(rect,cc.p(v.x, v.y))
		if (not bHit) then
			break;
		end
				
		local bDig = self:getMineDig(v.data);
		if (not bDig) then
			break;
		end
			
		local aroundPoses = {{x=v.x, y=v.y+2}, 
								{x=v.x-1, y=v.y+1}, 
								{x=v.x, y=v.y+1}, 
								{x=v.x+1, y=v.y+1}, 
								{x=v.x-2, y=v.y}, 
								{x=v.x-1, y=v.y}, 
								{x=v.x, y=v.y}, 
								{x=v.x+1, y=v.y}, 
								{x=v.x+2, y=v.y}, 
								{x=v.x-1, y=v.y-1}, 
								{x=v.x, y=v.y-1}, 
								{x=v.x+1, y=v.y-1}, 
								{x=v.x, y=v.y-2},};
			
		for i=1, #aroundPoses do
			repeat
				local aroundPos = aroundPoses[i];
				bHit = cc.rectContainsPoint(rect,cc.p(aroundPos.x, aroundPos.y))
				if (not bHit) then
					break;
				end
					
				local key = tostring(v.id) .. "@" .. tostring(aroundPos.x) .. "@" .. tostring(aroundPos.y);
				if (self._unMask[key] ~= nil) then
					break;
				end
				self._unMask[key] = {};
				self._unMask[key].x = aroundPos.x;
				self._unMask[key].y = aroundPos.y;
				self._unMask[key].id = id;
			until true
		end
		until true
	end
end

function MineMgr:getLimitLv()
    return self.config_ground[self._curAreaID].levelLimit
end

function MineMgr:createEarth()

	local earthIni = self.config_ground[self._curAreaID];
	if (nil == earthIni) then
		print("createEarth earthIni is empty");
		return;
	end
		
    local earthIniList = {{Type=earthIni.rock1,Per=earthIni.rockWeight1},{Type=earthIni.rock2,Per=earthIni.rockWeight2}}
	if (nil == earthIniList) then
		print("createEarth earthIniList is empty");
		return;
	end
		
	local areaInfo = self._areas[self._curAreaID];
	if (nil == areaInfo) then
		print("createEarth self._curAreaID is empty");
		return;
	end
		
	local basePer = 0;
	for i=1, #earthIniList do
		repeat
			local cell = earthIniList[i];
			if (nil == cell) then
				break;
			end
				
			basePer = basePer + cell.Per;
			cell.Per = basePer;
		until true
	end
		
	local width = self.width;
	local height = self.height;
	local seed = areaInfo.seed;
    print(seed)
    GlobalApi:setRandomSeed(seed)
	local num = width*height;
	for i=0, num-1 do
		repeat
		local randNum = GlobalApi:random(0,100);
        
		local cell = nil;
		for j=1, #earthIniList do
			cell = earthIniList[j];
			if (nil ~= cell) then
				if (randNum < cell.Per) then
					break;
				end
			end
		end
			
		local x = i%width;
		local y = math.floor(i/width);
		local index = tostring(self._curAreaID) .. "@" .. tostring(x) .. "@" .. tostring(y);
		self._earth[index] = cell.Type;
		until true
	end
end

function MineMgr:checkIndexPosMask(areaID, indexPos) --检车该点是否阴影(return mask:true; return unmask:false)

	local aroundPoses = {{x=indexPos.x, y=indexPos.y+2}, 
							{x=indexPos.x-1, y=indexPos.y+1}, 
							{x=indexPos.x, y=indexPos.y+1}, 
							{x=indexPos.x+1, y=indexPos.y+1}, 
							{x=indexPos.x-2, y=indexPos.y}, 
							{x=indexPos.x-1, y=indexPos.y}, 
							{x=indexPos.x+1, y=indexPos.y}, 
							{x=indexPos.x+2, y=indexPos.y}, 
							{x=indexPos.x-1, y=indexPos.y-1}, 
							{x=indexPos.x, y=indexPos.y-1}, 
							{x=indexPos.x+1, y=indexPos.y-1}, 
							{x=indexPos.x, y=indexPos.y-2},};
		
	local rect = cc.rect(0, 0, getWidth()-1, getHeight()-1);

	for i=1, #aroundPoses do
		repeat
			local aroundPos = aroundPoses[i];
			local bHit = rect:containsPoint(cc.p(aroundPos.x, aroundPos.y));
			if (not bHit) then
				break;
			end
				
			local key = tostring(areaID) .. "@" .. tostring(aroundPos.x) .. "@" .. tostring(aroundPos.y);
			local v = self._grid[key];
			if (nil == v) then
				break;
			end
				
			local bDig = getMineDig(v.data);
			if (bDig) then
				return false;
			end
		until true
	end
	return true;
end


---------------------------------------------------------------
--*********************Message*********************************
---------------------------------------------------------------
function MineMgr:SendGetMessage()
     MessageMgr:sendPost('get','digging',json.encode({}),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        self:initData();

        local diggingData = jsonObj.data.digging

        self._lastX = diggingData.posX;
        self._lastY = diggingData.posY;
        self._refreshTime = diggingData.reset;
        self._remainDigCount = diggingData.tool
        self._sumDigCount = GameData:getConfData("level")[UserData:getUserObj().level or 1].diggingMax
        self._statueCount = diggingData.enemy_count
        self._statueLev = diggingData.enemy_level
        self._curAreaID = tonumber(diggingData.posLevel)
        self._mineAxeAreaID = self._curAreaID;
        self._buy = diggingData.buy

        if(diggingData.boss_time ~= 0) then
	        self._bossRemainTime =diggingData.boss_time -  GlobalData:getServerTime()
            self._bossAreaID = diggingData.boss_pos[1]
	        self._bossPosX = diggingData.boss_pos[2]
	        self._bossPosY = diggingData.boss_pos[3]
            self._bossLev  = diggingData.boss_level
        end

        print(diggingData.seed)
        self._areas[self._curAreaID] = {seed = diggingData.seed,bossList = {}}
        self._maxDeep = diggingData.depth

        self._mineAxeRecoverTime = diggingData.tool_time;

        self:UpdateGrids(self._curAreaID,diggingData.ground)

        self:createEarth();

        self:showMineUI();

        self:UpdateQueue(diggingData.queue,diggingData.next_dequeue)

         if(self.uiClass.mineUI ~= nil) then
		    self.uiClass.mineUI:PostUpdateMineAxeInfo();
        end

         local awards = jsonObj.data.awards
         if awards then
            GlobalApi:parseAwardData(awards)
            GlobalApi:showAwardsCommon(awards,nil,nil,true)
            MineMgr:refreshMineCons()
        end



     end)
end
function MineMgr:SendDigMessage(x, y,consume)
    if (#self._updateDigGrid ~= 0) then
        promptmgr:showSystenHint('problem 6', COLOR_TYPE.RED)
		return;
	end

    --if(self.waitingDigResult) then
        --promptmgr:showSystenHint('problem 7', COLOR_TYPE.RED)
        --return
    --end

    print("dig:"..x..","..y)
    
    local msg = {}
    msg.level = self._curAreaID
    msg.x = x
    msg.y = y
    --MineMgr.waitingDigResult = true
    MessageMgr:sendPost('dig','digging',json.encode(msg),function(jsonObj)
        --MineMgr.waitingDigResult = false
       --print(json.encode(jsonObj))

        if(jsonObj.code == 100) then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('GOLDMINE_DESC_4'), COLOR_TYPE.RED)
            return
        end

        if(jsonObj.code ~= 0) then
            promptmgr:showSystenHint(jsonObj.desc, COLOR_TYPE.RED)
            return
        end
        --如果还在挖土的条还在读，数据缓存下来，等条走完在挖土那边发起处理
        --如果条已经走完，立即处理
        self.digResult = jsonObj.data
        self.digResult.x = x
        self.digResult.y = y
        if(jsonObj.data.costs ~= nil) then
            self.digResult.consume = jsonObj.data.costs[1][3]
        else
            self.digResult.consume = -consume
        end

       if(self.uiClass.mineUI ~= nil and not self.uiClass.mineUI.isDigBarVisible) then
            self:DelayProcessDigResult();
       end
       
    end)
end
function MineMgr:DelayProcessDigResult()
    if(self.digResult ~= nil) then
        self._lastX = self.digResult.x
        self._lastY = self.digResult.y
        if self._remainDigCount >= self._sumDigCount then
            print('==========++++++++++++6666666666666')
            MineMgr._mineAxeRecoverTime = GlobalData:getServerTime()
        end
        self._remainDigCount = self._remainDigCount + self.digResult.consume;
        self._maxDeep = self.digResult.depth

        self:UpdateGrids(self._curAreaID,self.digResult.update,eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerExplore)

        self.digResult = nil
        if(self.uiClass.mineUI ~= nil) then
            self.uiClass.mineUI:SetMineAxeText()
            self.uiClass.mineUI:SetMineAxeLoadingBar()
            self.uiClass.mineUI:SetAreaLoadingBar()
        end

        
    end
end
function MineMgr:SendBombMessage(x, y,bombID)
if (#self._updateDigGrid ~= 0) then
		return;
	end

    print("bomb:"..x..","..y)
    
    local msg = {}
    msg.level = self._curAreaID
    msg.x = x
    msg.y = y
    msg.id = bombID
    MessageMgr:sendPost('bomb','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        self._maxDeep = jsonObj.data.depth
        --self._curAreaID = tonumber(jsonObj.data.posLevel)
        --self._mineAxeAreaID = self._curAreaID;
        --self._areas[self._curAreaID] = {seed = jsonObj.data.seed,bossList = {}}

        local awards = jsonObj.data.awards
        local isBombAwards = nil
        if awards == nil or awards and #awards == 0 then
            isBombAwards = true
        end

        self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerUseBomb,isBombAwards)

        self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue)

        if awards then
            GlobalApi:parseAwardData(awards)
            GlobalApi:showAwardsCommon(awards,nil,nil,true)
        end

        --if awards == nil or awards and #awards == 0 then
            --promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_BOMB_EVERYTHING"), COLOR_TYPE.RED);
        --end

        local costs = jsonObj.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end

        if(self.uiClass.mineUI ~= nil) then
            self.uiClass.mineUI:PostUpdateBombNum()
            self.uiClass.mineUI:SetMineCons()

            -- 层数和深度显示更新
            self.uiClass.mineUI:SetMineAxeText()
            self.uiClass.mineUI:SetMineAxeLoadingBar()
            self.uiClass.mineUI:SetAreaLoadingBar()
        end

    end)
end
function MineMgr:SendCollectMessage(x, y)
    
    local key = tostring(self._curAreaID) .. "@" .. tostring(x) .. "@" .. tostring(y);
    local gridInfo  = self._grid[key]
    if(gridInfo == nil) then
        return
    end

    local msg = {}
    msg.level = self._curAreaID
    msg.x = x
    msg.y = y

    MessageMgr:sendPost('collect','digging',json.encode(msg),function(jsonObj)
        --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end
        local awards = jsonObj.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
        end

        local elem = {}
        elem[1] = self._curAreaID
        elem[2] = x
        elem[3] = y
        elem[4] = gridInfo.data

        local elemInQueue =  self:CollectEnqueue(elem)
        
        if(elemInQueue ~= nil) then
            local nextRemainTime = jsonObj.data.next_dequeue - GlobalData:getServerTime()
                if(#self._collectQueue == 1) then
			    elemInQueue.remainTime = nextRemainTime
            else
                elemInQueue.remainTime = elemInQueue.allTime
            end

            self.uiClass.mineUI:postUpdateQueueUI();
        end

        --- 通讯和刷新队列同时的问题
        self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue)
        self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_UpdateGetResQueue)
        if(self.uiClass.mineUI~= nil) then
            self.uiClass.mineUI:SetMineCons();
        end

        if (self.uiClass.mineQueueUI ~= nil) then
			self.uiClass.mineQueueUI:Update();
		end


    end)

end
function MineMgr:SendCollectAllMessage(x, y)
    
    local msg = {}
    msg.level = self._curAreaID
    msg.x = x
    msg.y = y
    MessageMgr:sendPost('collect_all','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end
        local elem = {}
        elem[1] = self._curAreaID
        elem[2] = x
        elem[3] = y

         local awards = jsonObj.data.awards
         if awards then
            GlobalApi:parseAwardData(awards)
            GlobalApi:showAwardsCommon(awards,nil,nil,true)
        end

        local costs = jsonObj.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end


        local function callBack()
            self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerExplore)

            self:UpdateQueue({},0)
        
            self.uiClass.mineUI:postUpdateQueueUI();
        end

        GlobalApi:timeOut(callBack,1)

        
    end)
end
function MineMgr:SendCancelMessage(x, y)
    local msg = {}
    msg.level = self._curAreaID
    msg.x = x
    msg.y = y
    MessageMgr:sendPost('cancel','digging',json.encode(msg),function(jsonObj)
        --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        local awards = jsonObj.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
        end
        
        self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue)

        self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_UpdateGetResQueue)


        if (self.uiClass.mineQueueUI ~= nil) then
			self.uiClass.mineQueueUI:Update();
		end

        if(self.uiClass.mineUI~= nil) then
            self.uiClass.mineUI:SetMineCons();
        end

    end)

end
function MineMgr:SendCancelAllMessage()
    local msg = {}
    MessageMgr:sendPost('cancel_all','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        GlobalApi:parseAwardData(jsonObj.data.awards)
        
        self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue) -- 更新矿区

        self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_UpdateGetResQueue) -- 更新队列


        if (self.uiClass.mineQueueUI ~= nil) then
			self.uiClass.mineQueueUI:Update();
		end

        if(self.uiClass.mineUI~= nil) then
            self.uiClass.mineUI:SetMineCons();
        end

    end)
end
function MineMgr:SendDequeueMessage()

    MessageMgr:sendPost('refresh_queue','digging',json.encode({}),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end
        local awards = jsonObj.data.awards
        if awards then
            GlobalApi:parseAwardData(awards)
        end

        self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue)

        self:UpdateGrids(self._curAreaID,jsonObj.data.update,eResourceAreaOpFlag.eResourceAreaOpFlag_UpdateGetResQueue)

        if(self.uiClass.mineUI~= nil) then
            self.uiClass.mineUI:SetMineCons();
        end

         if (self.uiClass.mineQueueUI ~= nil) then
			self.uiClass.mineQueueUI:Update();
		end
            
       
    end)
end
function MineMgr:SendChangeLevelMessage(inLevel)
    
    print(inLevel)
    local update = 0;

    if(self._areas[inLevel] ~= nil) then
        update = 1;
    end

    print("change to level:"..inLevel)

    local msg = {}
    msg.level = inLevel
    msg.update = update

    MessageMgr:sendPost('get_level','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        --self:UpdateQueue(jsonObj.data.queue,jsonObj.data.next_dequeue)
        self._changeAreaFlag = true;
        self._curAreaID = inLevel;
        if (nil == self._areas[inLevel]) then
			self._areas[inLevel] = {};
            if self._areas[inLevel].bossList == nil then
                self._areas[inLevel].bossList = {}
            end          
		end
		self._areas[inLevel].seed = jsonObj.data.seed;
        self._lastX = jsonObj.data.posX;
        self._lastY = jsonObj.data.posY;
        self._maxDeep = jsonObj.data.depth

        if(update == 0) then
            self:createEarth();
        end
        if jsonObj.data.first and jsonObj.data.first == 1 then  --玩家第1次打开这个层，并且在最上面有可能有boss
            self:UpdateGrids(self._curAreaID,jsonObj.data.ground,eResourceAreaOpFlag.eResourceAreaOpFlag_FightWithStatue)
        else
            self:UpdateGrids(self._curAreaID,jsonObj.data.ground)
        end

        

        self.uiClass.mineUI:postUpdateQueueUI()

    end)
end
function MineMgr:SendBuyToolsMessage()

    local msg = {}
    msg.num   = self._diggingToolPerDeal;
    MessageMgr:sendPost('buy_tool','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        self._remainDigCount = jsonObj.data.tool
        self._mineAxeRecoverTime = jsonObj.data.tool_time;

        self._buy = self._buy + 1

        if self._remainDigCount >= self._sumDigCount then
            
        end

        local awards = jsonObj.data.awards
        if awards then
            --GlobalApi:parseAwardData(awards)
        end
        local costs = jsonObj.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end

        if(self.uiClass.mineUI~= nil) then
            self.uiClass.mineUI:SetMineAxeText();
            self.uiClass.mineUI:SetMineAxeLoadingBar();
        end

    end)

end

function MineMgr:DoBattle(x,y)

    local data = self.config_enemy[self._statueLev];
    local customObj  = {}
    customObj.x = x;
    customObj.y = y;
    customObj.formation = data.formation
    BattleMgr:playBattle(BATTLE_TYPE.DIGGING, customObj, function ()
        MainSceneMgr:showMainCity(function()
            self.uiClass.mineUI = nil
            MainSceneMgr.uiClass.treasureUI = nil
            MainSceneMgr.uiClass.skillUpgradeUI = nil
            --self:SendGetMessage()
            MainSceneMgr:showTreasure()
            MineMgr:SendGetMessage()
        end, nil, GAME_UI.UI_TREASURE)
     end)
--    MainSceneMgr:showMainCity(function ()
--            CampaignMgr:showCampaignMain(1)
--        end)
--    end)

--    local data = self.config_enemy[self._statueLev];
--    MessageMgr:sendPost("before_fight", "digging", json.encode(msg), function (jsonObj)
--        if jsonObj.code == 0 then
--            local customObj = {
--                formation = data.formation
--            }

--        end
--    end)
end


function MineMgr:SendResetMessage(freeReset)
    local update = 0;

    local msg = {}
    if(freeReset) then
        msg.use_cash = 0
    else
        msg.use_cash = 1
    end

    MessageMgr:sendPost('reset','digging',json.encode(msg),function(jsonObj)
       --print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        self:initData();

        local diggingData = jsonObj.data.digging

        self._lastX = diggingData.posX;
        self._lastY = diggingData.posY;
        self._refreshTime = diggingData.reset;
        self._remainDigCount = diggingData.tool
        self._sumDigCount = GameData:getConfData("level")[UserData:getUserObj().level or 1].diggingMax
        self._statueLev = diggingData.enemy_level
        self._curAreaID = tonumber(diggingData.posLevel)
        self._mineAxeAreaID = self._curAreaID;
        self._buy = diggingData.buy

        self._areas[self._curAreaID] = {width = 72,height = 72,seed = diggingData.seed,bossList = {}}

        self._mineAxeRecoverTime = diggingData.tool_time;

        self:UpdateGrids(self._curAreaID,diggingData.ground)

        self:createEarth();

         if(self.uiClass.mineUI ~= nil) then
		    self.uiClass.mineUI:Reset();
        end

        local costs = jsonObj.data.costs
        if costs then
            GlobalApi:parseAwardData(costs)
        end


        self:UpdateQueue(diggingData.queue,diggingData.next_dequeue)
    end)

end


-- 是否炸到 道具物品
function MineMgr:UpdateGrids(areaID,gridsInfo,op,isBombAwards)
    
    self._updateGrid = {};
    local x,y
    local bossList = self._areas[areaID].bossList
    for sx,rowData in pairs(gridsInfo) do
        for sy,data in pairs(rowData) do
            x = tonumber(sx)
            y = tonumber(sy)
            local index = tostring(areaID) .. "@" .. tostring(x) .. "@" .. tostring(y);

            if (nil == self._grid[index]) then
				self._grid[index] = {};
				local mineType = self:getMineType(data);
				if (eResourceAreaResourceType.eResourceAreaResourceType_Statue == mineType) then
                    if(op ~= nil) then
					    local level = self:getMineLev(data);
					    if (1 == level) then
						    self._statueCueFlag = true;
					    elseif (2 == level) then
						    self._bossCueFlag = true;
                            self._bossAreaID = self._curAreaID
                            self._bossPosX = x;
                            self._bossPosY = y;
                            self._bossRemainTime = tonumber(GlobalApi:getGlobalValue("diggingBossTime"))
					    end
                        self._statueCount  = self._statueCount + 1
                    end
                    table.insert(bossList,cc.p(x,y))
				end
			end

            self._grid[index].data = data;
			self._grid[index].id = areaID
			self._grid[index].x = x;
			self._grid[index].y = y;
            table.insert(self._updateGrid, index);
            if(op == eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerExplore) then
                table.insert(self._updateDigGrid, index);
            end
		
        end

    end
    self:createMask(self._updateGrid);

    if (self._changeAreaFlag) then
        if (self.uiClass.mineUI ~= nil) then
			self.uiClass.mineUI:PostUpdateMineMgr(1);
		end
		self._changeAreaFlag = false;
	end

    if(self._statueCueFlag or self._bossCueFlag) then
        if(self._bossCueFlag) then
             self._bossLev = self._statueLev + self._statueCount
        end
        self.uiClass.mineUI:SetBossSV();
    end

    if(op ~= nil) then
        self.uiClass.mineUI:postUpdateGridUI(op,isBombAwards)
    end

end
function MineMgr:CollectEnqueue(elem,nextTime)

    local areaID = elem[1];
	local x      = elem[2];
	local y      = elem[3];
    local data   = elem[4]

    local ret = nil
        
    local index = #self._collectQueue+1;
	if (nil == self._collectQueue[index]) then
		self._collectQueue[index] = {};
	end

    local mineType  = self:getMineType(data)
    local mineLevel = self:getMineLev(data)

    ret = self._collectQueue[index]
    if(mineType > 0 and mineType < eResourceAreaResourceType.eResourceAreaResourceType_Statue) then
        ret.allTime = self.config_mine[mineType].time * self._timeRatio[mineLevel]
    else
        ret.allTime = 0
    end
	ret.id = areaID;
	ret.x = x;
	ret.y = y;
	ret.data = data;

	local key = tostring(areaID) .. "@" .. tostring(x) .. "@" .. tostring(y);
	if (nil == self._wait[key]) then
		self._wait[key] = {};
	end
	self._wait[key].id = areaID;
	self._wait[key].x = x;
	self._wait[key].y = y;

    return ret

end
function MineMgr:UpdateQueue(collectQueue,nextTime) 
		
        local nextRemainTime = 0
        if(nextTime ~= nil) then
          nextRemainTime = nextTime - GlobalData:getServerTime()
        end
		self._wait = {};
		self._collectQueue = {};
        
		for k, v in ipairs(collectQueue) do
        
            self:CollectEnqueue(v)
             if(k == 1) then
			    self._collectQueue[k].remainTime = nextRemainTime
             else
                self._collectQueue[k].remainTime = self._collectQueue[k].allTime
             end
		end
		
		self.uiClass.mineUI:postUpdateQueueUI();
		
----		if (IsUIVisble("MineQueue")) then
----			MineQueue.postUpdateQueueUI();
----		end
	end





