local ReplayBaseSoldier = require("script/app/ui/battle/replay/replaybasesoldier")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local ReplayLegion = class("ReplayLegion")

local LEGION_POS = BattleHelper.ENUM.LEGION_POS
local LEGION_STATUS = BattleHelper.ENUM.LEGION_STATUS
local P_YX = 80/150 --斜率

function ReplayLegion:ctor(guid, data, isFirstWave, battlefield)
	self.guid = guid
	self.isFirstWave = isFirstWave
	self.battlefield = battlefield
	self.legionInfo = data.info
	self.pos = data.info.pos
	self.headpic = data.info.headpic
	self.heroInfo = data.heroInfo
	self.name = self.heroInfo.name
	self.legionType = self.heroInfo.legionType
	-- 英雄
	local basePosition = LEGION_POS[guid][(data.info.pos-1)%9+1]
	self.heroQuality = self.heroInfo.heroQuality
	self.heroObj = self:createHero()
	self.heroObj:init(basePosition, cc.p(0, 0))
	-- 小兵
	self.soldierLv = data.info.soldierLv
	self.soldierObjs = {}
	local ownSoldierNum = data.info.soldierNum
	local soldierInfo = data.soldierInfo
	if soldierInfo then
		self.soldierInfo = soldierInfo
		local sY = (soldierInfo.ysoldierMaxNum - 1)*soldierInfo.ysoldierSep/2
		local sX = soldierInfo.heroSoldierSpacing
		local Onum = soldierInfo.ysoldierMaxNum/2
		for i = 1, ownSoldierNum do
			local numTmp = (i - 1)%soldierInfo.ysoldierMaxNum
			local rowIndex = math.ceil(i/soldierInfo.ysoldierMaxNum) - 1
			local y = sY - numTmp*soldierInfo.ysoldierSep + 1 -- 小兵多偏移1防止擋住武將
			local position = {}
			local offsetPos = {}
			position.y = basePosition.y + y
			offsetPos.y = y
			if self.guid == 1 then
				local x = sX + rowIndex*soldierInfo.xsoldierSep + y*P_YX
				position.x = basePosition.x - x
				offsetPos.x = -x
			else
				local x = sX + rowIndex*soldierInfo.xsoldierSep - y*P_YX
				position.x = basePosition.x + x
				offsetPos.x = x
			end
			local soldierObj = self:createSoldier(i)
			soldierObj:init(position, offsetPos)
			if numTmp < Onum then -- 属于上
				soldierObj.posAboveHero = 1
			else
				soldierObj.posAboveHero = 2
			end
			self.soldierObjs[i] = soldierObj
		end
	end
	self.summonObjs = {} -- 召唤物
	self.specialSummonObjs = {} -- 特殊召唤物
	self.soldierNum = 1 + ownSoldierNum
end

function ReplayLegion:createHero()
	return ReplayBaseSoldier.new(self, 1, 0)
end

function ReplayLegion:createSoldier(soldierIndex)
	return ReplayBaseSoldier.new(self, 2, soldierIndex)
end

function ReplayLegion:isDead()
	return self.status == LEGION_STATUS.DEAD
end


function ReplayLegion:setPos(pos)
	self.legionInfo.pos = pos
	self.pos = pos
	self.rowIndex = (self.pos - 1)%3 + 1
	self.columnIndex = math.ceil(self.pos/3)
end

function ReplayLegion:setSoldierPos(pos)
	local sY = (self.soldierInfo.ysoldierMaxNum - 1)*self.soldierInfo.ysoldierSep/2
	local sX = self.soldierInfo.heroSoldierSpacing
	for k, soldierObj in ipairs(self.soldierObjs) do
		local numTmp = (k - 1)%self.soldierInfo.ysoldierMaxNum
		local y = sY - numTmp*self.soldierInfo.ysoldierSep
		local position = {}
		position.y = pos.y + y
		if self.guid == 1 then
			local x = sX + (math.ceil(k/self.soldierInfo.ysoldierMaxNum) - 1)*self.soldierInfo.xsoldierSep + y*P_YX
			position.x = pos.x - x
		else
			local x = sX + (math.ceil(k/self.soldierInfo.ysoldierMaxNum) - 1)*self.soldierInfo.xsoldierSep - y*P_YX
			position.x = pos.x + x
		end
		soldierObj:setPosition(position)
	end
end

function ReplayLegion:playLose()
	self:setStatus(LEGION_STATUS.OVER)
	if self:isDead() then
		return
	end
	if not self.heroObj:isDead() then
		self.heroObj:battleOver()
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:battleOver()
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:battleOver()
		end
	end
end

function ReplayLegion:playWin()
	self:setStatus(LEGION_STATUS.OVER)
	if self:isDead() then
		return
	end
	if not self.heroObj:isDead() then
		self.heroObj:battleOver(true)
		local position = cc.p(self.heroObj:getPosition())
		for k, soldierObj in ipairs(self.soldierObjs) do
			if not soldierObj:isDead() then
				soldierObj:battleOver()
				soldierObj:moveTogether(position)
			end
		end
		for k, summonObj in ipairs(self.summonObjs) do
			if not summonObj:isDead() then
				summonObj:battleOver()
				summonObj:moveTogether(position)
			end
		end
	end
end

function ReplayLegion:setStatus(status)
	if not self:isDead() then
		self.status = status
	end
end

function ReplayLegion:addSummonByRecord(summonId, x, y)
	local summonInfo = GameData:getConfData("summon")[summonId]
	local summon
	if summonInfo.selectEnable > 0 then
		local soldierIndex = #self.summonObjs + 1
		summon = ReplayBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.summonObjs, summon)
		self.soldierNum = self.soldierNum + 1
	else
		local soldierIndex = #self.specialSummonObjs + 10001
		summon = ReplayBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.specialSummonObjs, summon)
	end
	summon.summonInfo = summonInfo
	summon:init(cc.p(x, y), cc.p(0, 0))
	summon:initSummonSpeciality()
end

return ReplayLegion