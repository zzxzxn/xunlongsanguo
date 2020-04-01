local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassBattleBuff = require("script/app/ui/battle/skill/battlebuff")

local ReportBuff = class("ReportBuff", ClassBattleBuff)

local HALO_ACTION_TAG = 100000000
local REMOVE_ACTION_TAG = 200000000
local EFFECT_ACTION_TAG = 300000000

function ReportBuff:effectTargetByBuff(owner, sender, baseInfo)
	local function effectFun()
		if not owner.battlefield:isBattleEnd() then
			BattleHelper:skillEffect(self, sender, owner)
		end
	end
	local act = {
		index = 1,
		actions = {
			{
				name = "callback",
				waitTime = baseInfo.effectDelay/1000,
				func = effectFun
			}
		}
	}
	-- 剩下的效果
	if baseInfo.effectInterval > 0 then
		act.actions[2] = {
			name = "callback",
			waitTime = baseInfo.effectInterval/1000,
			func = effectFun
		}
		act.repeatIndex = 2
	end
	-- 结束
	act.tag = EFFECT_ACTION_TAG + self.sid
	owner:runSkillAction(act)
end

function ReportBuff:createBuffAni(owner, baseInfo)
end

function ReportBuff:createBuffAni2(owner, baseInfo)
end

function ReportBuff:changeModal()
end

function ReportBuff:resetModal()
end

function ReportBuff:setOverTime(owner, baseInfo)
	local removeAct = {
		index = 1,
		actions = {
			{
				name = "callback",
				waitTime = baseInfo.durationTime/1000,
				func = function ()
					self.arrivalTime = true
					self:remove()
					-- 将buff从相应的列表中移除
					for i, buff in ipairs(owner.buffList) do
						if buff == self then
							table.remove(owner.buffList, i)
							break
						end
					end
				end
			}
		}
	}
	removeAct.tag = REMOVE_ACTION_TAG + self.sid
	owner:runSkillAction(removeAct)
end

function ReportBuff:resetOverTime()
	local owner = self.owner
	local removeAct = {
		index = 1,
		actions = {
			{
				name = "callback",
				waitTime = self.baseInfo.durationTime/1000,
				func = function ()
					self.arrivalTime = true
					self:remove()
					-- 将buff从相应的列表中移除
					for i, buff in ipairs(owner.buffList) do
						if buff == self then
							table.remove(owner.buffList, i)
							break
						end
					end
				end
			}
		}
	}
	removeAct.tag = REMOVE_ACTION_TAG + self.sid
	owner:stopSkillActionByTag(REMOVE_ACTION_TAG + self.sid)
	owner:runSkillAction(removeAct)
end

function ReportBuff:haloBuffTakeEffect(owner, baseInfo, effectFun)
	local act = {
		index = 1,
		actions = {
			{
				name = "callback",
				waitTime = 0,
				func = effectFun
			}
		}
	}
	if baseInfo.checkInterval > 0 then
		act.actions[2] = {
			name = "callback",
			waitTime = baseInfo.checkInterval/1000,
			func = effectFun
		}
		act.repeatIndex = 2
	end
	act.tag = HALO_ACTION_TAG + self.sid
	owner:runSkillAction(act)
end

function ReportBuff:createNewBuff(baseInfo, v, sender)
	local newBuff = ReportBuff.new(baseInfo.sendBuffId, v, sender)
	newBuff.halo = self
end

return ReportBuff