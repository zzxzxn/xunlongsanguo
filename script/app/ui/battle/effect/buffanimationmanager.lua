local BattleHelper = require("script/app/ui/battle/battlehelper")

local BuffAniMgr = {
	aniPools = nil
}

-- 初始化
function BuffAniMgr:init()
	self.aniPools = BattleHelper:createObjPools()
	self.preloadList = {}
end

function BuffAniMgr:clear()
	if self.aniPools then
		for k, v in pairs(self.aniPools.dataPools) do
			for k2, v2 in ipairs(v.data) do
				v2:release()
			end
		end
		self.aniPools = nil
	end
	self.preloadList = nil
end

function BuffAniMgr:addPreloadAni(buffId, skillInfo, onlyAddToCaster)
	local buffConf = GameData:getConfData("buff")
	local preloadNum = 1
	if not onlyAddToCaster then
		if skillInfo.targetMaxNum == 0 then
			preloadNum = 1
		elseif skillInfo.targetMaxNum < 20 then
			preloadNum = skillInfo.targetMaxNum
		else
			preloadNum = 30
		end
		if skillInfo.bulletNum > 1 then
			preloadNum = preloadNum*skillInfo.bulletNum
		end
	end
	if buffConf[buffId].buffRes ~= "0" then
		self.preloadList[buffConf[buffId].buffRes] = self.preloadList[buffConf[buffId].buffRes] or 0
		self.preloadList[buffConf[buffId].buffRes] = self.preloadList[buffConf[buffId].buffRes] + preloadNum
	end
	if buffConf[buffId].buffRes2 ~= "0" then
		self.preloadList[buffConf[buffId].buffRes2] = self.preloadList[buffConf[buffId].buffRes2] or 0
		self.preloadList[buffConf[buffId].buffRes2] = self.preloadList[buffConf[buffId].buffRes2] + preloadNum
	end
	if buffConf[buffId].type == 2 then -- 光环型buff
		local buffInfo2 = buffConf[buffConf[buffId].sendBuffId]
		if buffInfo2.rangeTargetType == 1 then
			preloadNum = 10
		else
			preloadNum = preloadNum*30
		end
		if buffInfo2.buffRes ~= "0" then
			self.preloadList[buffInfo2.buffRes] = self.preloadList[buffInfo2.buffRes] or 0
			self.preloadList[buffInfo2.buffRes] = self.preloadList[buffInfo2.buffRes] + preloadNum
		end
		if buffInfo2.buffRes2 ~= "0" then
			self.preloadList[buffInfo2.buffRes2] = self.preloadList[buffInfo2.buffRes2] or 0
			self.preloadList[buffInfo2.buffRes2] = self.preloadList[buffInfo2.buffRes2] + preloadNum
		end
	end
end

function BuffAniMgr:preloadAni()
	for res, num in pairs(self.preloadList) do
		for i = 1, num do
			local buffAni = self:createBuffAni(res)
			buffAni:retain()
			self.aniPools:push(res, buffAni)
		end
	end
	self.preloadList = nil
end

function BuffAniMgr:createBuffAni(res)
	local buffAni = BattleHelper:createAniByName(res)
	local function movementFun(armature, movementType, movementID)
		if movementType == 1 then
			buffAni:setVisible(false)
		end
	end
	buffAni:getAnimation():setMovementEventCallFunc(movementFun)
	return buffAni
end

function BuffAniMgr:showBuffAni(roleNode, buffRes)
	local ani = self.aniPools:pop(buffRes)
	if ani then
		roleNode:addChild(ani)
		ani:release()
	else
		ani = self:createBuffAni(buffRes)
		roleNode:addChild(ani)
	end
	return ani
end

function BuffAniMgr:putBack(res, buffAni)
	buffAni:retain()
	buffAni:removeFromParent(false)
	self.aniPools:push(res, buffAni)
end

return BuffAniMgr