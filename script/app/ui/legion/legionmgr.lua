local ClassLegionMainUI = require('script/app/ui/legion/legionmainpanel')
local ClassLegionApplyUI = require('script/app/ui/legion/legionapplypanel')
local ClassLegionIconSelectUI = require('script/app/ui/legion/legioniconselectpanel')
local ClassLegionManageUI = require('script/app/ui/legion/legionmanagepanel')
local ClassLegionInfoUI = require('script/app/ui/legion/legioninfopanel')
local ClassLegionSettingUI = require('script/app/ui/legion/legionsettingpanel')
local ClassLegionPubSettingUI = require('script/app/ui/legion/legionpubsettingpanel')
local ClassLegionApplyListUI = require('script/app/ui/legion/legionapplylistpanel')
local ClassLegionMemberInfoUI = require('script/app/ui/legion/legionmemberinfopanel')
local ClassLegionMemberListUI = require('script/app/ui/legion/legionmemberlistpanel')
local ClassLegionPosManageUI = require('script/app/ui/legion/legionposmanagepanel')
local ClassLegionLogUI = require('script/app/ui/legion/legionlogpanel')
local ClassLegionActivityMainUI = require('script/app/ui/legion/legionactivity/legionactivitymainpanel')
local ClassLegionActivityBoonUI = require('script/app/ui/legion/legionactivity/legionactivityboonpanel')
local ClassLegionActivityShakeUI = require('script/app/ui/legion/legionactivity/legionactivityshakepanel')
local ClassLegionActivityMercenaryUI = require('script/app/ui/legion/legionactivity/legionactivitymercenarypanel')
local ClassLegionActivityRoleListUI = require('script/app/ui/legion/legionactivity/legionactivityrolelistpanel')
local ClassLegionActivityTrialUI = require('script/app/ui/legion/legionactivity/legionactivitytrialpanel')
local ClassLegionActivityTrialStarUI = require('script/app/ui/legion/legionactivity/legionactivitytrialstarpanel')
local ClassLegionActivitySelRoleListUI = require('script/app/ui/legion/legionactivity/legionactivityselrolelistpanel')
local ClassLegionLevelsMainUI = require('script/app/ui/legion/legionlevels/legionlevelsmainpanel')
local ClassLegionLevelsUI = require('script/app/ui/legion/legionlevels/legionlevelspanel')
local ClassLegionLevelsBattleUI = require('script/app/ui/legion/legionlevels/legionlevelsbattlepanel')
local ClassLegionCityMainUI = require('script/app/ui/legion/legioncity/legioncitymainpanel')
local ClassLegionCityListUI = require('script/app/ui/legion/legioncity/legioncitylistpanel')
local ClassLegionCityAreaSelectUI = require('script/app/ui/legion/legioncity/legioncityareaselectpanel')
local ClassLegionCityUpgradeUI = require('script/app/ui/legion/legioncity/legioncityupgradepanel')
local ClassLegionWarMainUI = require('script/app/ui/legion/legionwar/legionwarmainpanel')
local ClassLegionWarLogUI = require('script/app/ui/legion/legionwar/legionwarlogpanel')
local ClassLegionWarBattleUI = require('script/app/ui/legion/legionwar/legionwarbattlepanel')
local ClassLegionWarBattleListUI = require('script/app/ui/legion/legionwar/legionwarbattlelistpanel')
local ClassLegionWarAwardsUI = require('script/app/ui/legion/legionwar/legionwarawardspanel')
local ClassLegionWarCityInfoUI = require('script/app/ui/legion/legionwar/legionwarcityinfopanel')
local ClassLegionWarCityDefUI = require('script/app/ui/legion/legionwar/legionwarcitydefpanel')
local ClassLegionWarCityDefListUI = require('script/app/ui/legion/legionwar/legionwarcitydeflistpanel')
local ClassLegionWarBuffUI = require('script/app/ui/legion/legionwar/legionwarbuffpanel')
local ClassLegionWarRankInfoUI = require('script/app/ui/legion/legionwar/legionwarrankinfopanel')
local ClassLegionDonateUI = require('script/app/ui/legion/legiondonatepanel')
local ClassLegionMemberAgainstUI = require('script/app/ui/legion/legionmemberagainst')
local ClassLegionCitySuipianUI = require('script/app/ui/legion/legioncity/legioncitysuipian')

cc.exports.LegionMgr = {
	uiClass = {
		LegionMainUI = nil,
		LegionApplUI = nil,
		LegionIconSelectUI = nil,
		LegionManageUI = nil,
		LegionInfoUI = nil,
		LegionSettingUI = nil,
		LegionPubSettingUI = nil,
		LegionApplyListUI = nil,
		LegionMemberInfoUI = nil,
		LegionMemberListUI = nil,
		LegionPosManageUI = nil,
		LegionLogUI = nil,
		LegionActivityMainUI = nil,
		LegionActivityBoonUI = nil,
		LegionActivityShakeUI = nil,
		LegionActivityMercenaryUI = nil,
		LegionActivityRoleListUI = nil,
		LegionActivityTrialUI = nil,
		LegionActivityTrialStarUI = nil,
		LegionActivitySelRoleListUI = nil,
		LegionLevelsMainUI = nil,
		LegionLevelsUI = nil,
		LegionLevelsBattleUI = nil,

		LegionCityMainUI = nil,
		LegionCityInfoUI = nil,
		LegionCityListUI = nil,
		LegionCityAreaSelectUI = nil,
		LegionCityAttackListUI = nil,
		LegionCityLogUI = nil,
		LegionCityUpgradeUI = nil,

		LegionWarMainUI = nil,
		LegionWarLogUI = nil,
		LegionWarBattleUI =	nil,
		LegionWarBattleListUI = nil,
		LegionWarAwardsUI = nil,
		LegionWarCityInfoUI = nil,
		LegionWarCityDefUI = nil,
		LegionWarCityDeflistUI = nil,
		LegionWarBuffUI = nil,
		LegionWarRankInfoUI = nil,

		LegionDonateUI = nil,
        TerritorialWarsUI = nil,
        TerritorialWarsElementUI = nil,
        TerritorialWarsMineUI = nil,
        TerritorialWarsCreature = nil,
        LegionMemberAgainstUI = nil,
        legionCityUpgradeEffectUI = nil,

        LegionCitySuipianUI = nil,

	},
	selecticonid = 1,
	selecticonhaschange = false,
	legionpos = 4, --默认团员
	mercenaies = {},
	legionwardata = {},
	legionbattledata = {},
	legionwarcitytab = {},
    construct_progress = 0,
    legionlevelsdata  = {},
}

setmetatable(LegionMgr.uiClass, {__mode = "v"})

function LegionMgr:showLegionMainUI(data,callback)
	if self.uiClass["LegionMainUI"] == nil then
		self.uiClass["LegionMainUI"] = ClassLegionMainUI.new(data)
		self.uiClass["LegionMainUI"]:showUI()
	    if not UserData:getUserObj():getName() or UserData:getUserObj():getName() == "" then
	        SettingMgr:showSettingChangeName(true)
	    end
	    if callback then
	    	callback()
	    end
	end
end

function LegionMgr:hideLegionMainUI()
	MainSceneMgr:showMainCity()
	if self.uiClass["LegionMainUI"] then
		self.uiClass["LegionMainUI"]:hideUI()
		self.uiClass["LegionMainUI"] = nil
	end
end

function LegionMgr:showLegionApplyUI(data)
	if self.uiClass["LegionApplUI"] == nil then
		self.uiClass["LegionApplUI"] = ClassLegionApplyUI.new(data)
		self.uiClass["LegionApplUI"]:showUI()
	end
end

function LegionMgr:hideLegionApplyUI()
	if self.uiClass["LegionApplUI"] then
		self.uiClass["LegionApplUI"]:hideUI()
		self.uiClass["LegionApplUI"] = nil
	end
end

function LegionMgr:showMainUI(callback)
	MessageMgr:sendPost('get','legion',"{}",function (response)
		--
		local code = response.code
		local data = response.data
		if code == 0 then
			if data.legion then
				local firstJoin = cc.UserDefault:getInstance():getBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',false)
				if not firstJoin then
					cc.UserDefault:getInstance():setBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',true)
				end
				if UserData:getUserObj():getLid() == 0 then
					UserData:getUserObj():setLegion(data.legion.lid, data.legion.name, data.legion.level,data.legion.gold_tree)
                    UserData:getUserObj().wish = data.legion.wish
				end
				UserData:getUserObj():setLegionData(data.legion)
                self:setLegionConstructProgress(data.legion.construct_progress)
				self:showLegionMainUI(data.legion,callback)
			elseif data.legions then
                UserData:getUserObj().lid = 0
				self:showLegionApplyUI(response.data)
			end
		end
	end)
end

function LegionMgr:setLegionConstructProgress(construct_progress)
    self.construct_progress = construct_progress
end

function LegionMgr:getLegionConstructProgress()
    return self.construct_progress or 0
end

function LegionMgr:showLegionIconSelectUI(legionMemberData)
	if self.uiClass["LegionIconSelectUI"] == nil then
		self.uiClass["LegionIconSelectUI"] = ClassLegionIconSelectUI.new(legionMemberData)
		self.uiClass["LegionIconSelectUI"]:showUI()
	end
end

function LegionMgr:hideLegionIconSelectUI()
	if self.uiClass["LegionIconSelectUI"] then
		self.uiClass["LegionIconSelectUI"]:hideUI()
		self.uiClass["LegionIconSelectUI"] = nil
	end
end
--pos 职位
function LegionMgr:showLegionManageUI(data)
	if self.uiClass["LegionManageUI"] == nil then
		self.uiClass["LegionManageUI"] = ClassLegionManageUI.new(data)
		self.uiClass["LegionManageUI"]:showUI()
	end
end

function LegionMgr:hideLegionManageUI()
	if self.uiClass["LegionManageUI"] then
		self.uiClass["LegionManageUI"]:hideUI()
		self.uiClass["LegionManageUI"] = nil
	end
end

function LegionMgr:showLegionInfoUI(data)
	if self.uiClass["LegionInfoUI"] == nil then
		self.uiClass["LegionInfoUI"] = ClassLegionInfoUI.new(data)
		self.uiClass["LegionInfoUI"]:showUI()
	end
end

function LegionMgr:hideLegionInfoUI()
	if self.uiClass["LegionInfoUI"] then
		self.uiClass["LegionInfoUI"]:hideUI()
		self.uiClass["LegionInfoUI"] = nil
	end
end

function LegionMgr:showLegionSettingUI(data)
	if self.uiClass["LegionSettingUI"] == nil then
		self.uiClass["LegionSettingUI"] = ClassLegionSettingUI.new(data)
		self.uiClass["LegionSettingUI"]:showUI()
	end
end

function LegionMgr:hideLegionSettingUI()
	if self.uiClass["LegionSettingUI"] then
		self.uiClass["LegionSettingUI"]:hideUI()
		self.uiClass["LegionSettingUI"] = nil
	end
end

function LegionMgr:showLegionPubSettingUI(data)
	if self.uiClass["LegionPubSettingUI"] == nil then
		self.uiClass["LegionPubSettingUI"] = ClassLegionPubSettingUI.new(data)
		self.uiClass["LegionPubSettingUI"]:showUI()
	end
end

function LegionMgr:hideLegionPubSettingUI()
	if self.uiClass["LegionPubSettingUI"] then
		self.uiClass["LegionPubSettingUI"]:hideUI()
		self.uiClass["LegionPubSettingUI"] = nil
	end
end


function LegionMgr:showLegionApplyListUI(data)
	if self.uiClass["LegionApplyListUI"] == nil then
		self.uiClass["LegionApplyListUI"] = ClassLegionApplyListUI.new(data)
		self.uiClass["LegionApplyListUI"]:showUI()
	end
end

function LegionMgr:hideLegionApplyListUI()
	if self.uiClass["LegionApplyListUI"] then
		self.uiClass["LegionApplyListUI"]:hideUI()
		self.uiClass["LegionApplyListUI"] = nil
	end
end

function LegionMgr:showLegionMemberInfoUI(legiondata,memberdata)
	if self.uiClass["LegionMemberInfoUI"] == nil then
		self.uiClass["LegionMemberInfoUI"] = ClassLegionMemberInfoUI.new(legiondata,memberdata)
		self.uiClass["LegionMemberInfoUI"]:showUI()
	end
end

function LegionMgr:hideLegionMemberInfoUI()
	if self.uiClass["LegionMemberInfoUI"] then
		self.uiClass["LegionMemberInfoUI"]:hideUI()
		self.uiClass["LegionMemberInfoUI"] = nil
	end
end

function LegionMgr:showLegionMemberListUI(data)
	if self.uiClass["LegionMemberListUI"] == nil then
		MessageMgr:sendPost('get_hall','legion',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionMemberListUI"] = ClassLegionMemberListUI.new(data.legion)
				self.uiClass["LegionMemberListUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionMemberListUI()
	if self.uiClass["LegionMemberListUI"] then
		self.uiClass["LegionMemberListUI"]:hideUI()
		self.uiClass["LegionMemberListUI"] = nil
	end
end

function LegionMgr:showLegionPosManageUI(legiondata,memberdata)
	if self.uiClass["LegionPosManageUI"] == nil then
		self.uiClass["LegionPosManageUI"] = ClassLegionPosManageUI.new(legiondata,memberdata)
		self.uiClass["LegionPosManageUI"]:showUI()
	end
end

function LegionMgr:hideLegionPosManageUI()
	if self.uiClass["LegionPosManageUI"] then
		self.uiClass["LegionPosManageUI"]:hideUI()
		self.uiClass["LegionPosManageUI"] = nil
	end
end

function LegionMgr:showLegionActivityMainUI(data)
	if self.uiClass["LegionActivityMainUI"] == nil then
		self.uiClass["LegionActivityMainUI"] = ClassLegionActivityMainUI.new(data)
		self.uiClass["LegionActivityMainUI"]:showUI()
	end
end

function LegionMgr:hideLegionActivityMainUI()
	if self.uiClass["LegionActivityMainUI"] then
		self.uiClass["LegionActivityMainUI"]:hideUI()
		self.uiClass["LegionActivityMainUI"] = nil
	end
end

function LegionMgr:showLegionActivityBoonUI()
	if self.uiClass["LegionActivityBoonUI"] == nil then
		self.uiClass["LegionActivityBoonUI"] = ClassLegionActivityBoonUI.new()
		self.uiClass["LegionActivityBoonUI"]:showUI()
	end
end

function LegionMgr:hideLegionActivityBoonUI()
	if self.uiClass["LegionActivityBoonUI"] then
		self.uiClass["LegionActivityBoonUI"]:hideUI()
		self.uiClass["LegionActivityBoonUI"] = nil
	end
end


function LegionMgr:showLegionActivityShakeUI(legiondata)
	if self.uiClass["LegionActivityShakeUI"] == nil then
		MessageMgr:sendPost('get_gold_tree','legion',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivityShakeUI"] = ClassLegionActivityShakeUI.new(response.data,legiondata)
				self.uiClass["LegionActivityShakeUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionActivityShakeUI()
	if self.uiClass["LegionActivityShakeUI"] then
		self.uiClass["LegionActivityShakeUI"]:hideUI()
		self.uiClass["LegionActivityShakeUI"] = nil
	end
end

function LegionMgr:showLegionActivityMercenaryUI(legiondata)
	if self.uiClass["LegionActivityMercenaryUI"] == nil then
		MessageMgr:sendPost('mercenary','legion',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivityMercenaryUI"] = ClassLegionActivityMercenaryUI.new(response.data,legiondata)
				self.uiClass["LegionActivityMercenaryUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionActivityMercenaryUI()
	if self.uiClass["LegionActivityMercenaryUI"] then
		self.uiClass["LegionActivityMercenaryUI"]:hideUI()
		self.uiClass["LegionActivityMercenaryUI"] = nil
	end
end

function LegionMgr:showLegionActivityRoleListUI(data)
	if self.uiClass["LegionActivityRoleListUI"] == nil then
		self.uiClass["LegionActivityRoleListUI"] = ClassLegionActivityRoleListUI.new(data)
		self.uiClass["LegionActivityRoleListUI"]:showUI()
	end
end

function LegionMgr:hideLegionActivityRoleListUI()
	if self.uiClass["LegionActivityRoleListUI"] then
		self.uiClass["LegionActivityRoleListUI"]:hideUI()
		self.uiClass["LegionActivityRoleListUI"] = nil
	end
end

function LegionMgr:showLegionActivityTrialUI()
	if self.uiClass["LegionActivityTrialUI"] == nil then
		MessageMgr:sendPost('trial_get','legion',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivityTrialUI"] = ClassLegionActivityTrialUI.new(response.data)
				self.uiClass["LegionActivityTrialUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionActivityTrialUI()
	if self.uiClass["LegionActivityTrialUI"] then
		self.uiClass["LegionActivityTrialUI"]:hideUI()
		self.uiClass["LegionActivityTrialUI"] = nil
	end
end

function LegionMgr:showLegionActivityTrialStarUI(data)
	if self.uiClass["LegionActivityTrialStarUI"] == nil then
		self.uiClass["LegionActivityTrialStarUI"] = ClassLegionActivityTrialStarUI.new(data)
		self.uiClass["LegionActivityTrialStarUI"]:showUI()
	end
end

function LegionMgr:hideLegionActivityTrialStarUI()
	if self.uiClass["LegionActivityTrialStarUI"] then
		self.uiClass["LegionActivityTrialStarUI"]:hideUI()
		self.uiClass["LegionActivityTrialStarUI"] = nil
	end
end

function LegionMgr:showLegionActivitySelRoleListUI(battleType,customObj)
	if self.uiClass["LegionActivitySelRoleListUI"] == nil then
		MessageMgr:sendPost('get_mercenaries','legion',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivitySelRoleListUI"] = ClassLegionActivitySelRoleListUI.new(response.data,battleType,customObj)
				self.uiClass["LegionActivitySelRoleListUI"]:showUI()
			end
		end)
	end
end

-- 新版军团开黑
function LegionMgr:showLegionActivitySelRoleListNewLegionTrialUI(battleType, customObj,callBack)
	if self.uiClass["LegionActivitySelRoleListUI"] == nil then
		MessageMgr:sendPost('get_trial_mercenaries','legion',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivitySelRoleListUI"] = ClassLegionActivitySelRoleListUI.new(response.data,battleType,customObj,nil,callBack)
				self.uiClass["LegionActivitySelRoleListUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:showLegionActivitySelRoleListTowerUI(battleType,customObj,num)
	if self.uiClass["LegionActivitySelRoleListUI"] == nil then
		MessageMgr:sendPost('get_mercenaries','tower',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionActivitySelRoleListUI"] = ClassLegionActivitySelRoleListUI.new(response.data,battleType,customObj,num)
				self.uiClass["LegionActivitySelRoleListUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionActivitySelRoleListUI()
	if self.uiClass["LegionActivitySelRoleListUI"] then
		self.uiClass["LegionActivitySelRoleListUI"]:hideUI()
		self.uiClass["LegionActivitySelRoleListUI"] = nil
	end
end

function LegionMgr:showLegionLogUI()
	if self.uiClass["LegionLogUI"] == nil then
		MessageMgr:sendPost('get_log','legion',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionLogUI"] = ClassLegionLogUI.new(response.data)
				self.uiClass["LegionLogUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionLogUI()
	if self.uiClass["LegionLogUI"] then
		self.uiClass["LegionLogUI"]:hideUI()
		self.uiClass["LegionLogUI"] = nil
	end
end

function LegionMgr:showLegionLevelsMainUI()
	if self.uiClass["LegionLevelsMainUI"] == nil then
		MessageMgr:sendPost('get_copy','legion',"{}",function (response)
			local code = response.code
			local data = response.data
			self.legionlevelsdata = response.data
			if code == 0 then
				self.uiClass["LegionLevelsMainUI"] = ClassLegionLevelsMainUI.new()
				self.uiClass["LegionLevelsMainUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionLevelsMainUI()
	if self.uiClass["LegionLevelsMainUI"] then
		self.uiClass["LegionLevelsMainUI"]:hideUI()
		self.uiClass["LegionLevelsMainUI"] = nil
	end
end

function LegionMgr:getLegionLevelsData()
	return self.legionlevelsdata
end

function LegionMgr:setLegionLevelsData(data)
	self.legionlevelsdata = data
end

function LegionMgr:showLegionLevelsUI(index)
	if self.uiClass["LegionLevelsUI"] == nil then
		self.uiClass["LegionLevelsUI"] = ClassLegionLevelsUI.new(index)
		self.uiClass["LegionLevelsUI"]:showUI()
	end
end

function LegionMgr:hideLegionLevelsUI()
	if self.uiClass["LegionLevelsUI"] then
		self.uiClass["LegionLevelsUI"]:hideUI()
		self.uiClass["LegionLevelsUI"] = nil
	end
end

function LegionMgr:showLegionLevelsBattleUI(index,progress)
	if self.uiClass["LegionLevelsBattleUI"] == nil then
		self.uiClass["LegionLevelsBattleUI"] = ClassLegionLevelsBattleUI.new(index,progress)
		self.uiClass["LegionLevelsBattleUI"]:showUI()
	end
end

function LegionMgr:hideLegionLevelsBattleUI()
	if self.uiClass["LegionLevelsBattleUI"] then
		self.uiClass["LegionLevelsBattleUI"]:hideUI()
		self.uiClass["LegionLevelsBattleUI"] = nil
	end
end

function LegionMgr:showLegionCityMainUI(data,callback)
	if UserData:getUserObj():getLid() <= 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		return
	end
	if data then
		if self.uiClass["LegionCityMainUI"] == nil then
			self.uiClass["LegionCityMainUI"] = ClassLegionCityMainUI.new(data)
			self.uiClass["LegionCityMainUI"]:showUI()
		end
	else
		if self.uiClass["LegionCityMainUI"] == nil then
			MessageMgr:sendPost('get_castle','legion',"{}",function (response)
				
				local code = response.code
				local data = response.data
				if code == 0 then
					self.uiClass["LegionCityMainUI"] = ClassLegionCityMainUI.new(response.data)
					self.uiClass["LegionCityMainUI"]:showUI()
					if callback then
						callback()
					end
				else
					promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC15'), COLOR_TYPE.RED)
				end
			end)
		end
	end
end

function LegionMgr:hideLegionCityMainUI()
	if self.uiClass["LegionMainUI"] then
		if self.uiClass["LegionCityMainUI"] then
			self.uiClass["LegionCityMainUI"]:hideUI()
			self.uiClass["LegionCityMainUI"] = nil
		end
	else
		LegionMgr:showMainUI(function()
			if self.uiClass["LegionCityMainUI"] then
				self.uiClass["LegionCityMainUI"]:hideUI()
				self.uiClass["LegionCityMainUI"] = nil
			end
		end)
	end
end

function LegionMgr:showLegionCityListUI(data)
	if self.uiClass["LegionCityListUI"] == nil then
		self.uiClass["LegionCityListUI"] = ClassLegionCityListUI.new(data)
		self.uiClass["LegionCityListUI"]:showUI()
	end
end

function LegionMgr:hideLegionCityListUI()
	if self.uiClass["LegionCityListUI"] then
		self.uiClass["LegionCityListUI"]:hideUI()
		self.uiClass["LegionCityListUI"] = nil
	end
end

function LegionMgr:showLegionCityAreaSelectUI(data)
	if self.uiClass["LegionCityAreaSelectUI"] == nil then
		self.uiClass["LegionCityAreaSelectUI"] = ClassLegionCityAreaSelectUI.new(data)
		self.uiClass["LegionCityAreaSelectUI"]:showUI()
	end
end

function LegionMgr:hideLegionCityAreaSelectUI()
	if self.uiClass["LegionCityAreaSelectUI"] then
		self.uiClass["LegionCityAreaSelectUI"]:hideUI()
		self.uiClass["LegionCityAreaSelectUI"] = nil
	end
end

function LegionMgr:showLegionCityUpgradeUI()
	if self.uiClass["LegionCityUpgradeUI"] == nil then
		self.uiClass["LegionCityUpgradeUI"] = ClassLegionCityUpgradeUI.new()
		self.uiClass["LegionCityUpgradeUI"]:showUI()
	end
end

function LegionMgr:hideLegionCityUpgradeUI()
	if self.uiClass["LegionCityUpgradeUI"] then
		self.uiClass["LegionCityUpgradeUI"]:hideUI()
		self.uiClass["LegionCityUpgradeUI"] = nil
	end
end

function LegionMgr:ChangePage(page)
	if self.uiClass["LegionCityMainUI"] ~= nil then
		self.uiClass["LegionCityMainUI"]:changeToPage(page)
	end
end
function LegionMgr:setSelectIconID(id)
	self.selecticonid = id
end

function LegionMgr:getSelectIconID()
	return self.selecticonid
end

function LegionMgr:setSelectIconChange(value)
	self.selecticonhaschange = value
end
function LegionMgr:getIsSelectIconChange()
	return self.selecticonhaschange
end
function LegionMgr:getSelfLegionPos()
	return self.legionpos
end

function LegionMgr:setSelfLegionPos(pos)
	self.legionpos = pos
end
--data 传 members
function LegionMgr:getMemberCount(data)
    local num = 0
    for k,v in pairs(data) do
        num = num + 1
    end
    return num
end

--data 传 members
function LegionMgr:getActiveCount(data)
    local num = 0
    for k,v in pairs(data) do
        if Time.date('%Y%m%d',v.login_time) == Time.getDayToModifiedServerDay() then
        	num = num + 1
        end
    end
    return num
end

function LegionMgr:judgeTodayIsActive(login_time)
    local judge = false
    if Time.date('%Y%m%d',login_time) == Time.getDayToModifiedServerDay() then
        judge = true
    end
    return judge
end

--pos  职位
--data 传 members
function LegionMgr:getMemberCountByPos(pos,data)
	local num = 0
	for k,v in pairs(data) do
		if v.duty == pos then
	        num = num + 1
	    end
    end
    return num
end

function LegionMgr:setMercenaies(mercenariestab)
	self.mercenaies = mercenariestab
end

function LegionMgr:getMercenaies()
	return self.mercenaies
end

function LegionMgr:calccopyHp(data,chapter,index)
	local index = index or data.progress
    local maxhp = 0
    local curhp = 0
    local legioncopyconf = GameData:getConfData("legioncopy") 
    local formationconf = GameData:getConfData("formation")
    local monsterconf = GameData:getConfData('monster')
    local formationid = legioncopyconf[data.chapter][tostring('formation'..index)]
    local tempindex = 0
    for j=1,9 do
        if formationconf[formationid][tostring('pos'..j)] > 0 then
        	tempindex = tempindex + 1
            local monsterid = formationconf[formationid][tostring('pos'..j)]
            if index==data.progress then
                if  data.healths and data.healths[tempindex] then
	                curhp = curhp + (monsterconf[monsterid].baseHp*data.healths[tempindex]/100)
	            else
	                curhp = curhp + monsterconf[monsterid].baseHp
                end
                maxhp = maxhp + monsterconf[monsterid].baseHp
            elseif index < data.progress then
            	curhp = curhp
            	maxhp = maxhp + monsterconf[monsterid].baseHp
            elseif index > data.progress then
            	curhp = curhp + monsterconf[monsterid].baseHp
            	maxhp = maxhp + monsterconf[monsterid].baseHp
            end
        end
    end    
    if data.chapter == chapter then
    	return string.format("%.2f", curhp*100/maxhp)
    elseif data.chapter > chapter then
    	return 0
   	end
end

function LegionMgr:calccopypercent(data,chapter)
	--副本每关6个怪
	local num = 0
	for i=data.progress,6 do
		num = num + self:calccopyHp(data,chapter,i)
	end
	return string.format("%.2f", num/6)
end

function LegionMgr:openBag(callback)
    local args = {}
    MessageMgr:sendPost("get_hook_repos", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
            if callback then
            	callback(data)
            end
        end
    end)
end

function LegionMgr:getTeam(callback)
    local args = {}
    MessageMgr:sendPost("get", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
            if callback then
            	callback(data)
            end
        end
    end)
end

function LegionMgr:createTeam(callback)
    local args = {}
    MessageMgr:sendPost("create_queue", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
            if callback then
            	callback(data)
            end
        end
    end)
end

function LegionMgr:refreshTeam(callback)
    local args = {}
    MessageMgr:sendPost("get_queues", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
           	if callback then
				callback(data)
			end
        end
    end)
end

function LegionMgr:joinTeam(id,callback)
    local args = {qid = id}
    MessageMgr:sendPost("join_queue", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
           	if callback then
				callback(data)
			end
        end
    end)
end

function LegionMgr:leaveTeam(id,callback)
    local args = {qid = id}
    MessageMgr:sendPost("leave_queue", "hook", json.encode(args), function (response)
    	
        if response.code == 0 then
        	local data = response.data
           	if callback then
				callback(data)
			end
        end
    end)
end

function LegionMgr:extendBag(callback)
    local args = {}
    MessageMgr:sendPost("extend_repos", "hook", json.encode(args), function (response)
        if response.code == 0 then
        	local data = response.data
        	local vol = data.vol
           	if callback then
				callback(vol)
			end
        end
    end)
end

function LegionMgr:showLegionWarMainUI(callback)
	if self.uiClass["LegionWarMainUI"] == nil then
		MessageMgr:sendPost('get_mainpage_info','legionwar',"{}",function (response)
			local code = response.code
			self.legionwardata  = response.data
			if code == 0 then
				self.uiClass["LegionWarMainUI"] = ClassLegionWarMainUI.new()
				self.uiClass["LegionWarMainUI"]:showUI()
				if callback then
					callback()
				end
			elseif code == 101 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR1'), COLOR_TYPE.RED)
			elseif code == 102 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR2'), COLOR_TYPE.RED)
			elseif code == 103 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_SERVER_ERROR3'), COLOR_TYPE.RED)
			end
		end)
	end
end

function LegionMgr:getLegionWarData()
	return self.legionwardata
end

function LegionMgr:setLegionWarData(data)
	self.legionwardata = data
end
function LegionMgr:hideLegionWarMainUI()
	if self.uiClass["LegionWarMainUI"] then
		self.uiClass["LegionWarMainUI"]:hideUI()
		self.uiClass["LegionWarMainUI"] = nil
	end
end

function LegionMgr:calcTrialLv()
	local trialconf = GameData:getConfData('trial') 
	local tablelv = {}
	for k,v in pairs(trialconf) do
		table.insert(tablelv,k)
	end
	table.sort( tablelv, function(a,b)
		return a < b
	end )
	--printall(tablelv)
	local userlv = UserData:getUserObj():getLv()
	local lv = tablelv[#tablelv]
	for i=1 ,#tablelv do
		if i < (#tablelv-1) and userlv >= tablelv[i] and userlv < tablelv[i+1] then
			lv = tablelv[i]
		end
	end
	return lv 
end

function LegionMgr:showLegionWarLogUI(logdata)
	if self.uiClass["LegionWarLogUI"] == nil then
		self.uiClass["LegionWarLogUI"] = ClassLegionWarLogUI.new(logdata)
		self.uiClass["LegionWarLogUI"]:showUI()
	end
end

function LegionMgr:hideLegionWarLogUI()
	if self.uiClass["LegionWarLogUI"] then
		self.uiClass["LegionWarLogUI"]:hideUI()
		self.uiClass["LegionWarLogUI"] = nil
	end
end

function LegionMgr:showLegionWarAwardsUI()
	if self.uiClass["LegionWarAwardsUI"] == nil then
		MessageMgr:sendPost('get_user_fightnum_info','legionwar','{}',function (response)
			local code = response.code
			local awardsdata = response.data
			if code == 0 then
				self.uiClass["LegionWarAwardsUI"] = ClassLegionWarAwardsUI.new(awardsdata)
				self.uiClass["LegionWarAwardsUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionWarAwardsUI()
	if self.uiClass["LegionWarAwardsUI"] then
		self.uiClass["LegionWarAwardsUI"]:hideUI()
		self.uiClass["LegionWarAwardsUI"] = nil
	end
end

function LegionMgr:showLegionWarBattleUI()
	if self.uiClass["LegionWarBattleUI"] == nil then
		MessageMgr:sendPost('get_battlepage_info','legionwar',"{}",function (response)
			local code = response.code
			self.legionbattledata = response.data
			if code == 0 then
				LegionMgr:setSelfLegionPos(self.legionbattledata.user.duty)
				self.uiClass["LegionWarBattleUI"] = ClassLegionWarBattleUI.new()
				self.uiClass["LegionWarBattleUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:getLegionBattleData()
	return self.legionbattledata
end

function LegionMgr:setLegionBattleData(data)
	self.legionbattledata = data
end
function LegionMgr:hideLegionWarBattleUI()
	if self.uiClass["LegionWarBattleUI"] then
		self.uiClass["LegionWarBattleUI"]:hideUI()
		self.uiClass["LegionWarBattleUI"] = nil
	end
end

function LegionMgr:showLegionWarBattleListUI()
	if self.uiClass["LegionWarBattleListUI"] == nil then
		MessageMgr:sendPost('get_history','legionwar',"{}",function (response)
			local code = response.code
			local historydata = response.data
			if code == 0 then
				self.uiClass["LegionWarBattleListUI"] = ClassLegionWarBattleListUI.new(historydata)
				self.uiClass["LegionWarBattleListUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionWarBattleListUI()
	if self.uiClass["LegionWarBattleListUI"] then
		self.uiClass["LegionWarBattleListUI"]:hideUI()
		self.uiClass["LegionWarBattleListUI"] = nil
	end
end

function LegionMgr:showLegionWarCityInfoUI(isself,index,legionid)
	if self.uiClass["LegionWarCityInfoUI"] == nil then
		local args = {
			lid = legionid,
			city = index,
		}
		MessageMgr:sendPost('get_city_info','legionwar',json.encode(args),function (response)
			local code = response.code
			local cityinfo = response.data
			if code == 0 then
				self.uiClass["LegionWarCityInfoUI"] = ClassLegionWarCityInfoUI.new(isself,index,cityinfo)
				self.uiClass["LegionWarCityInfoUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionWarCityInfoUI()
	if self.uiClass["LegionWarCityInfoUI"] then
		self.uiClass["LegionWarCityInfoUI"]:hideUI()
		self.uiClass["LegionWarCityInfoUI"] = nil
	end
end

function LegionMgr:showLegionWarCityDefUI(index,cityinfo,legionwardata)
	if self.uiClass["LegionWarCityDefUI"] == nil then
		self.uiClass["LegionWarCityDefUI"] = ClassLegionWarCityDefUI.new(index,cityinfo,legionwardata)
		self.uiClass["LegionWarCityDefUI"]:showUI()
	end
end

function LegionMgr:hideLegionWarCityDefUI()
	if self.uiClass["LegionWarCityDefUI"] then
		self.uiClass["LegionWarCityDefUI"]:hideUI()
		self.uiClass["LegionWarCityDefUI"] = nil
	end
end

function LegionMgr:showLegionWarCityDefListUI(cityinfo,cityid,posid)
	if self.uiClass["LegionWarCityDefListUI"] == nil then
		MessageMgr:sendPost('get_hall','legion',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionWarCityDefListUI"] = ClassLegionWarCityDefListUI.new(data.legion,cityinfo,cityid,posid)
				self.uiClass["LegionWarCityDefListUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionWarCityDefListUI()
	if self.uiClass["LegionWarCityDefListUI"] then
		self.uiClass["LegionWarCityDefListUI"]:hideUI()
		self.uiClass["LegionWarCityDefListUI"] = nil
	end
end

function LegionMgr:showLegionWarBuffUI()
	if self.uiClass["LegionWarBuffUI"] == nil then
		self.uiClass["LegionWarBuffUI"] = ClassLegionWarBuffUI.new()
		self.uiClass["LegionWarBuffUI"]:showUI()
	end
end

function LegionMgr:hideLegionWarBuffUI()
	if self.uiClass["LegionWarBuffUI"] then
		self.uiClass["LegionWarBuffUI"]:hideUI()
		self.uiClass["LegionWarBuffUI"] = nil
	end
end

function LegionMgr:showLegionWarRankInfoUI()
	if self.uiClass["LegionWarRankInfoUI"] == nil then
		MessageMgr:sendPost('get_rankinfo','legionwar',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionWarRankInfoUI"] = ClassLegionWarRankInfoUI.new(data)
				self.uiClass["LegionWarRankInfoUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionWarRankInfoUI()
	if self.uiClass["LegionWarRankInfoUI"] then
		self.uiClass["LegionWarRankInfoUI"]:hideUI()
		self.uiClass["LegionWarRankInfoUI"] = nil
	end
end

function LegionMgr:calcRank(score)
    local rankid = 1
    local rankconf = GameData:getConfData('legionwarrank')
    for k,v in pairs(rankconf) do
        if score >= v.minScore and score <= v.maxScore then
            rankid = k
        end
    end
    return rankid
end

function LegionMgr:showLegionDonateUI()
	if self.uiClass["LegionDonateUI"] == nil then
		MessageMgr:sendPost('get_construct','legion',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["LegionDonateUI"] = ClassLegionDonateUI.new(data)
				self.uiClass["LegionDonateUI"]:showUI()
			end
		end)
	end
end

function LegionMgr:hideLegionDonateUI()
	if self.uiClass["LegionDonateUI"] then
		self.uiClass["LegionDonateUI"]:hideUI()
		self.uiClass["LegionDonateUI"] = nil
	end
end

function LegionMgr:showLegionMemberAgainstUI(data,uid)
	if self.uiClass["LegionMemberAgainstUI"] == nil then
		self.uiClass["LegionMemberAgainstUI"] = ClassLegionMemberAgainstUI.new(data,uid)
		self.uiClass["LegionMemberAgainstUI"]:showUI()
	end
end

function LegionMgr:hideLegionMemberAgainstUI()
	if self.uiClass["LegionMemberAgainstUI"] then
		self.uiClass["LegionMemberAgainstUI"]:hideUI()
		self.uiClass["LegionMemberAgainstUI"] = nil
	end
end

function LegionMgr:showLegionCityUpgradeEffectUI(cityLevel)
	if self.uiClass["legionCityUpgradeEffectUI"] == nil then
		self.uiClass["legionCityUpgradeEffectUI"] = require('script/app/ui/legion/legioncity/legioncityupgradeeffectui').new(cityLevel)
		self.uiClass["legionCityUpgradeEffectUI"]:showUI()
	end
end

function LegionMgr:hideLegionCityUpgradeEffectUI()
	if self.uiClass["legionCityUpgradeEffectUI"] then
		self.uiClass["legionCityUpgradeEffectUI"]:hideUI()
		self.uiClass["legionCityUpgradeEffectUI"] = nil
	end
end

function LegionMgr:showLegionSuiPianUI(tempRole,id)
	if self.uiClass["LegionCitySuipianUI"] == nil then
		self.uiClass["LegionCitySuipianUI"] = ClassLegionCitySuipianUI.new(tempRole,id)
		self.uiClass["LegionCitySuipianUI"]:showUI()
	end
end

function LegionMgr:hideLegionSuiPianUI()
	if self.uiClass["LegionCitySuipianUI"] then
		self.uiClass["LegionCitySuipianUI"]:hideUI()
		self.uiClass["LegionCitySuipianUI"] = nil
	end
end

