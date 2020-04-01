local ClassSoldierEquipTipsUI = require('script/app/ui/tips/soldierequiptips')
local ClassRoleSkillTipsUI = require('script/app/ui/tips/roleskilltips')
local ClassRolePrfessUI = require('script/app/ui/tips/roleprofesstips')
local ClassLegionExpTipsUI = require('script/app/ui/tips/legionexptips')
local ClassRoleAttTipsUI = require('script/app/ui/tips/roleatttips')
local CommonTipsUI = require('script/app/ui/tips/commontips')
local ClassDragonGemTipsUI = require('script/app/ui/tips/dragongemtips')
local ClassDragonGemFragmentTipsUI = require('script/app/ui/tips/dragongemfragmenttips')
local ClassJadeSealAdditionTipsUI = require('script/app/ui/tips/jadesealadditiontips')
local ClassTerritorialwarTipUI = require('script/app/ui/tips/territorialwar_tip')

cc.exports.TipsMgr = {
	uiClass = {
		SoldierEquipTipsUI = nil,
		RoleSkillTipsUI = nil,
		RoleProfessUI = nil,
		LegionExpTipsUI = nil,
		RoleAttTipsUI = nil,
        CommonTipsUI = nil,
        DragonGemTipsUI = nil,
        DragonGemFragmentTipsUI = nil,
        JadeSealAdditionTipsUI = nil,
        TerritorialwarTipUI = nil
	}
}
setmetatable(TipsMgr.uiClass, {__mode = "v"})

function TipsMgr:showSoldierEquipTips(obj,index,pos)
	if self.uiClass["SoldierEquipTipsUI"] == nil then
		self.uiClass["SoldierEquipTipsUI"] = ClassSoldierEquipTipsUI.new(obj,index,pos)
		self.uiClass["SoldierEquipTipsUI"]:showUI()
	end
end

function TipsMgr:hideSoldierEquipTips()
	if self.uiClass["SoldierEquipTipsUI"] then
		self.uiClass["SoldierEquipTipsUI"]:hideUI()
		self.uiClass["SoldierEquipTipsUI"] = nil
	end
end

function TipsMgr:showRoleSkillTips(lv,id,pos,isshownext)
	if self.uiClass["RoleSkillTipsUI"] == nil then
		self.uiClass["RoleSkillTipsUI"] = ClassRoleSkillTipsUI.new(lv,id,pos,isshownext)
		self.uiClass["RoleSkillTipsUI"]:showUI()
	end
end

function TipsMgr:hideRoleSkillTips()
	if self.uiClass["RoleSkillTipsUI"] then
		self.uiClass["RoleSkillTipsUI"]:hideUI()
		self.uiClass["RoleSkillTipsUI"] = nil
	end
end

function TipsMgr:showCommonTips(des1,des2,des3,pos)
	if self.uiClass["CommonTipsUI"] == nil then
		self.uiClass["CommonTipsUI"] = CommonTipsUI.new(des1,des2,des3,pos)
		self.uiClass["CommonTipsUI"]:showUI()
	end
end

function TipsMgr:hideCommonTips()
	if self.uiClass["CommonTipsUI"] then
		self.uiClass["CommonTipsUI"]:hideUI()
		self.uiClass["CommonTipsUI"] = nil
	end
end

function TipsMgr:showProfessTips(obj,pos)
	if self.uiClass["RoleProfessUI"] == nil then
		self.uiClass["RoleProfessUI"] = ClassRolePrfessUI.new(obj,pos)
		self.uiClass["RoleProfessUI"]:showUI()
	end	
end

function TipsMgr:hideProfessTips()
	if self.uiClass["RoleProfessUI"] then
		self.uiClass["RoleProfessUI"]:hideUI()
		self.uiClass["RoleProfessUI"] = nil
	end
end

function TipsMgr:showRoleAttTips(obj)
	if self.uiClass["RoleAttTipsUI"] == nil then
		self.uiClass["RoleAttTipsUI"] = ClassRoleAttTipsUI.new(obj)
		self.uiClass["RoleAttTipsUI"]:showUI()
	end	
end

function TipsMgr:hideRoleAttTips()
	if self.uiClass["RoleAttTipsUI"] then
		self.uiClass["RoleAttTipsUI"]:hideUI()
		self.uiClass["RoleAttTipsUI"] = nil
	end
end

function TipsMgr:showLegionExpTips()
	if self.uiClass["LegionExpTipsUI"] == nil then
		self.uiClass["LegionExpTipsUI"] = ClassLegionExpTipsUI.new()
		self.uiClass["LegionExpTipsUI"]:showUI()
	end	
end

function TipsMgr:hideLegionExpTips()
	if self.uiClass["LegionExpTipsUI"] then
		self.uiClass["LegionExpTipsUI"]:hideUI()
		self.uiClass["LegionExpTipsUI"] = nil
	end
end

function TipsMgr:showDragonGemTips(position, dragonGem, callback)
	if self.uiClass["DragonGemTipsUI"] == nil then
		self.uiClass["DragonGemTipsUI"] = ClassDragonGemTipsUI.new(position, dragonGem, callback)
		self.uiClass["DragonGemTipsUI"]:showUI()
	end	
end

function TipsMgr:hideDragonGemTips()
	if self.uiClass["DragonGemTipsUI"] then
		self.uiClass["DragonGemTipsUI"]:hideUI()
		self.uiClass["DragonGemTipsUI"] = nil
	end
end

function TipsMgr:showDragonGemFragmentTips(position, fragment, callback)
	if self.uiClass["DragonGemFragmentTipsUI"] == nil then
		self.uiClass["DragonGemFragmentTipsUI"] = ClassDragonGemFragmentTipsUI.new(position, fragment, callback)
		self.uiClass["DragonGemFragmentTipsUI"]:showUI()
	end	
end

function TipsMgr:hideDragonGemFragmentTips()
	if self.uiClass["DragonGemFragmentTipsUI"] then
		self.uiClass["DragonGemFragmentTipsUI"]:hideUI()
		self.uiClass["DragonGemFragmentTipsUI"] = nil
	end
end

function TipsMgr:showJadeSealAdditionTips(position, key)
	if self.uiClass["JadeSealAdditionTipsUI"] == nil then
		self.uiClass["JadeSealAdditionTipsUI"] = ClassJadeSealAdditionTipsUI.new(position, key)
		self.uiClass["JadeSealAdditionTipsUI"]:showUI()
	end	
end

function TipsMgr:hideJadeSealAdditionTips()
	if self.uiClass["JadeSealAdditionTipsUI"] then
		self.uiClass["JadeSealAdditionTipsUI"]:hideUI()
		self.uiClass["JadeSealAdditionTipsUI"] = nil
	end
end

function TipsMgr:showTerritorialwarBossTips(position,resCount,scoreParam, key)
	if self.uiClass["TerritorialwarTipUI"] == nil then
		self.uiClass["TerritorialwarTipUI"] = ClassTerritorialwarTipUI.new(position,resCount,scoreParam,key)
		self.uiClass["TerritorialwarTipUI"]:showUI()
	end	
end

function TipsMgr:hideTerritorialwarBossTips()
	if self.uiClass["TerritorialwarTipUI"] then
		self.uiClass["TerritorialwarTipUI"]:hideUI()
		self.uiClass["TerritorialwarTipUI"] = nil
	end
end
