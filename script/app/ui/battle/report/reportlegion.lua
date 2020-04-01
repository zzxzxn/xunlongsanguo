local ReportBaseSoldier = require("script/app/ui/battle/report/reportbasesoldier")
local ClassLegion = require("script/app/ui/battle/legion/battlelegion")

local ReportLegion = class("ReportLegion", ClassLegion)

function ReportLegion:createHero()
	return ReportBaseSoldier.new(self, 1, 0)
end

function ReportLegion:createSoldier(soldierIndex)
	return ReportBaseSoldier.new(self, 2, soldierIndex)
end

function ReportLegion:addSummonObj(master, sid, position)
	if self.battlefield:isBattleEnd() then
		return
	end
	self.battlefield:recordAddSummon(self.guid, self.pos, sid, position)
	local summonInfo = GameData:getConfData("summon")[sid]
	local summon
	if summonInfo.selectEnable > 0 then
		local soldierIndex = #self.summonObjs + 1
		summon = ReportBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.summonObjs, summon)
		self.soldierNum = self.soldierNum + 1
	else
		local soldierIndex = #self.specialSummonObjs + 10001
		summon = ReportBaseSoldier.new(self, 3, soldierIndex)
		table.insert(self.specialSummonObjs, summon)
	end
	summon.summonInfo = summonInfo
	summon.owner = master
	summon:init(position, cc.p(0, 0))
	summon:initSummonSpeciality()
	table.insert(self.battlefield.totalReport.soldierReport, summon.report.recordObj)
end

function ReportLegion:checkBeforeUpdate()
	if not self.heroObj:isDead() then
		self.heroObj:checkAction()
	end
	for k, soldierObj in ipairs(self.soldierObjs) do
		if not soldierObj:isDead() then
			soldierObj:checkAction()
		end
	end
	for k, summonObj in ipairs(self.summonObjs) do
		if not summonObj:isDead() then
			summonObj:checkAction()
		end
	end
	for k, specialSummonObjs in ipairs(self.specialSummonObjs) do
		if not specialSummonObjs:isDead() then
			specialSummonObjs:checkAction()
		end
	end
end

function ReportLegion:playSound(res, isLoop)
end

return ReportLegion