local ClassRoleMainUI = require("script/app/ui/role/rolemainui")
local ClassRoleListUI = require("script/app/ui/role/rolelistui")
local ClassRoleSelectListOutSideUI = require('script/app/ui/role/roleselectlistoutsideui')
local ClassRoleResolveUI = require('script/app/ui/role/roleresolveui')
local ClassSoldierSkillUI = require('script/app/ui/role/soldierskillui')
local ClassSuitUI = require('script/app/ui/role/rolesuitui')
local ClassStrengthenPopupUI = require('script/app/ui/role/strengthenpopupui')
local ClassRoleExchangeUI = require('script/app/ui/role/roleexchangeui')
local ClassSoldierinfoUI = require('script/app/ui/role/rolesoldierinfoui')
local ClassSoldierUpgradeUI = require('script/app/ui/role/soldierupgrade')
local ClassFateShowUI = require('script/app/ui/role/fateshowui')
local ClassRoleTupoInfoUI = require('script/app/ui/role/roletupoinfoui')
local ClassPokedexUI = require('script/app/ui/role/rolepokedexui')
local ClassPokedexHeroUI = require('script/app/ui/role/rolepokedexheroui')
local ClassSkillUpgradeUI = require('script/app/ui/role/skillupgrade')
local ClassGemFillUI = require('script/app/ui/role/rolegemfill')
local ClassEquipRefineUI = require('script/app/ui/role/roleequiprefineui')
local ClassEquipRefineLvUpUI = require('script/app/ui/role/roleequiprefinelvupui')
local ClassRoleLvUpOneLevelPannelUI = require('script/app/ui/role/rolelvuponelevel')
local ClassRoleFateFateConspiracyActivePannelUI = require('script/app/ui/role/rolefatefateconspiracyactive')
local ClassRoleFateFateConspiracyChooseHerolUI = require('script/app/ui/role/rolefatefateconspiracychoosehero')
local ClassRoleFateFateConspiracyUpgradeUI = require('script/app/ui/role/rolefatefateconspiracyupgrade')
local ClassRolePromotedUI = require('script/app/ui/role/rolepromoted')
local ClassRolePromotedTipsUI = require('script/app/ui/role/rolepromotedtips')
local ClassRolePromotedUpgradeUI = require('script/app/ui/role/rolepromoteupgrade')
local ClassRolePromotedProviewUI = require('script/app/ui/role/rolepromoteproview')
local ClassRolePromotedUpgradeSkillUI = require('script/app/ui/role/rolepromoteupgradeskill')
local ClassRolePromotedUpgradeMaxUI = require('script/app/ui/role/rolepromoteupgrademax')
local ClassRolePromotedLuckyWheelUI = require('script/app/ui/role/rolepromoteluckywheel')
local ClassRolePromotedLuckyWheelRankUI = require('script/app/ui/role/rolepromoteluckywheelrank')
local ClassRoleAutoRebornUI = require('script/app/ui/role/roleautorebornui')
local ClassRoleAutoUpgradeStarUI = require('script/app/ui/role/roleautoupgradestarui')
local ClassRoleonelevelPannelUI = require('script/app/ui/role/roleonelevel')

cc.exports.RoleMgr = {
	uiClass = {
		RoleMainUI = nil,
		RoleListUI = nil,
		RoleSelectListOutSideUI = nil,
		RoleResolveUI = nil,
		SoldierSkillUI =nil,
		SuitUI =nil,
		StrengthenPopupUI = nil,
		RoleExchangeUI = nil,
		SoldierinfoUI = nil,
		SoldierUpgradeUI = nil,
		FateShowUI = nil,
		RoleTupoInfoUI = nil,
		PokedexUI = nil,
		PokedexHeroUI = nil,
		SkillUpgradeUI = nil,
		GemFillUI = nil,
		EquipRefineUI = nil,
		EquipRefineLvUpUI = nil,
        RoleLvUpOneLevelPannelUI = nil,
        RoleOneLevelPannelUI = nil,
        RoleFateFateConspiracyActivePannelUI = nil,
        RoleFateFateConspiracyChooseHerolUI = nil,
        RoleFateFateConspiracyUpgradeUI = nil,
		RolePromotedUI = nil,
		RolePromotedTipsUI = nil,
		RolePromotedUpgradeUI = nil,
		RolePromotedProviewUI = nil,
		RolePromotedUpgradeSkillUI = nil,
		RolePromotedUpgradeMaxUI = nil,
		RolePromotedLuckyWheelUI = nil,
		RolePromotedLuckyWheelRankUI = nil,
		RoleAutoRebornUI = nil,
		RoleAutoUpgradeStarUI = nil
	},
	openType = nil,
	rolelistdirty = false,
--	dirty = false,
	selectpos = 1,
	curHeroIschange = true,
	isshowAttributeUpdate = true
}

setmetatable(RoleMgr.uiClass, {__mode = "v"})

cc.exports.ROLEPANELTYPE = {
	UI_INFO = 1,  					--武将信息
	UI_TUPO = 2,					--武将突破
	UI_EQUIP = 3,					--武将装备选择
	UI_SOLDIER = 4,					--武将小兵
	UI_TIANMING = 5,				--武将技能
	UI_TAOZHUANG = 6,				--武将套装
	UI_EQUIP_INFO = 7,				--武将装备基本信息
	UI_SWAP_ROLE = 8,				--换将
	UI_LVUP	= 9,					--武将升级
	UI_UPGRADE_STAR = 10,			--升星
	UI_INHERIT = 11,				--传承
	UI_GEM = 12,					--宝石信息
	UI_RISESTAR = 13,				--升星
}

cc.exports.ROLELISTTYPE = {
	UI_ASSIST = 1,  			--出阵武将列表
	UI_CHIP = 2,				--武将碎片列表
	UI_BEASSIST = 3,			--武将卡片列表
	UI_FATE = 4,				--缘分
	UI_PROMOTED = 5,			--封将
}

function RoleMgr:showRoleMain(pos,pltype,equippos)
	pltype = pltype or nil
	if pltype == ROLEPANELTYPE.UI_EQUIP_INFO then
		equippos = equippos or 1
	end
	if self.uiClass["RoleMainUI"] == nil then
		self.uiClass["RoleMainUI"] = ClassRoleMainUI.new(pos,pltype,equippos)
		--self.openType =pltype
		self.uiClass["RoleMainUI"]:showUI(UI_SHOW_TYPE.SCALEIN)
	end
end

function RoleMgr:hideRoleMain()
	if self.uiClass["RoleMainUI"] then
		self.uiClass["RoleMainUI"]:hideUI(UI_HIDE_TYPE.MOVEOUTR)
		self.uiClass["RoleMainUI"] = nil
	end
	if self.uiClass["RoleListUI"] and self.rolelistdirty then
		self.rolelistdirty = false
		self.uiClass["RoleListUI"]:setDirty(true)
	end
	self.curHeroIschange = true
end

function RoleMgr:getRoleMainUIChangeBtn()
	if self.uiClass["RoleMainUI"] then
		return self.uiClass["RoleMainUI"]:getRoleMainUIChangeBtn()
	end
end
-- function RoleMgr:getOpenType()
-- 	return self.openType or ROLEPANELTYPE.UI_RISESTAR
-- end

function RoleMgr:showRoleList(page)
	if self.uiClass["RoleListUI"] == nil then
		self.uiClass["RoleListUI"] = ClassRoleListUI.new(page)
		self.uiClass["RoleListUI"]:showUI(UI_SHOW_TYPE.MOVEINL)
	end
end

function RoleMgr:hideRoleList()
	if self.uiClass["RoleListUI"] then
		self.uiClass["RoleListUI"]:hideUI(UI_HIDE_TYPE.MOVEOUTR)
		self.uiClass["RoleListUI"] = nil
	end
end

function RoleMgr:showRoleCardInfo(obj,ischip, index)
    local isshow = index or 2
    local state = ROLE_SHOW_TYPE.NORMAL
    if isshow == 3 then
        state = ROLE_SHOW_TYPE.NORMAL
    elseif isshow == 1 then
        if ischip then
            state = ROLE_SHOW_TYPE.CHIP_MERGET
        else
            state = ROLE_SHOW_TYPE.NORMAL
        end
    elseif isshow == 2 then
        if ischip then
            state = ROLE_SHOW_TYPE.CHIP_MERGET
        else
            state = ROLE_SHOW_TYPE.CARD_DECOMPOSE
        end
    end
    ChartMgr:showChartInfo(nil,state,obj)
end

function RoleMgr:showSoldierSkill(obj)
	if self.uiClass["SoldierSkillUI"] == nil then
		self.uiClass["SoldierSkillUI"] = ClassSoldierSkillUI.new(obj)
		self.uiClass["SoldierSkillUI"]:showUI()
	end
end

function RoleMgr:hideSoldierSkill()
	if self.uiClass["SoldierSkillUI"] then
		self.uiClass["SoldierSkillUI"]:hideUI()
		self.uiClass["SoldierSkillUI"] = nil
	end
end

function RoleMgr:showRoleSelectListOutSide(obj)
	if self.uiClass["RoleSelectListOutSideUI"] == nil then
		self.uiClass["RoleSelectListOutSideUI"] = ClassRoleSelectListOutSideUI.new(obj)
		self.uiClass["RoleSelectListOutSideUI"]:showUI()
	end
end

function RoleMgr:hideRoleSelectListOutSide()
	if self.uiClass["RoleSelectListOutSideUI"] then
		self.uiClass["RoleSelectListOutSideUI"]:hideUI()
		self.uiClass["RoleSelectListOutSideUI"] = nil
	end
end

function RoleMgr:showRoleResolve()
	if self.uiClass["RoleResolveUI"] == nil then
		self.uiClass["RoleResolveUI"] = ClassRoleResolveUI.new()
		self.uiClass["RoleResolveUI"]:showUI()
	end
end

function RoleMgr:hideRoleResolve()
	if self.uiClass["RoleResolveUI"] then
		self.uiClass["RoleResolveUI"]:hideUI()
		self.uiClass["RoleResolveUI"] = nil
	end
end

function RoleMgr:showRolePromotedUI(pos)
	if self.uiClass["RolePromotedUI"] == nil then
		self.uiClass["RolePromotedUI"] = ClassRolePromotedUI.new(pos)
		self.uiClass["RolePromotedUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedUI()
	if self.uiClass["RolePromotedUI"] then
		self.uiClass["RolePromotedUI"]:hideUI()
		self.uiClass["RolePromotedUI"] = nil
	end
end

function RoleMgr:showRolePromotedTipsUI(obj,protype,lv)
	if self.uiClass["RolePromotedTipsUI"] == nil then
		self.uiClass["RolePromotedTipsUI"] = ClassRolePromotedTipsUI.new(obj,protype,lv)
		self.uiClass["RolePromotedTipsUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedTipsUI()
	if self.uiClass["RolePromotedTipsUI"] then
		self.uiClass["RolePromotedTipsUI"]:hideUI()
		self.uiClass["RolePromotedTipsUI"] = nil
	end
end

function RoleMgr:showRolePromotedUpgradeUI(obj,fromatt,toatt,name,func)
	if self.uiClass["RolePromotedUpgradeUI"] == nil then
		self.uiClass["RolePromotedUpgradeUI"] = ClassRolePromotedUpgradeUI.new(obj,fromatt,toatt,name,func)
		self.uiClass["RolePromotedUpgradeUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedUpgradeUI()
	if self.uiClass["RolePromotedUpgradeUI"] then
		self.uiClass["RolePromotedUpgradeUI"]:hideUI()
		self.uiClass["RolePromotedUpgradeUI"] = nil
	end
end

function RoleMgr:showRolePromotedUpgradeSkillUI(obj,fromatt,toatt,func)
	if self.uiClass["RolePromotedUpgradeSkillUI"] == nil then
		self.uiClass["RolePromotedUpgradeSkillUI"] = ClassRolePromotedUpgradeSkillUI.new(obj,fromatt,toatt,func)
		self.uiClass["RolePromotedUpgradeSkillUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedUpgradeSkillUI()
	if self.uiClass["RolePromotedUpgradeSkillUI"] then
		self.uiClass["RolePromotedUpgradeSkillUI"]:hideUI()
		self.uiClass["RolePromotedUpgradeSkillUI"] = nil
	end
end

function RoleMgr:showRolePromotedUpgradeMaxUI(obj,fromatt,toatt,func)
	if self.uiClass["RolePromotedUpgradeMaxUI"] == nil then
		self.uiClass["RolePromotedUpgradeMaxUI"] = ClassRolePromotedUpgradeMaxUI.new(obj,fromatt,toatt,func)
		self.uiClass["RolePromotedUpgradeMaxUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedUpgradeMaxUI()
	if self.uiClass["RolePromotedUpgradeMaxUI"] then
		self.uiClass["RolePromotedUpgradeMaxUI"]:hideUI()
		self.uiClass["RolePromotedUpgradeMaxUI"] = nil
	end
end


function RoleMgr:showRolePromotedProviewUI(obj,protype)
	if self.uiClass["RolePromotedProviewUI"] == nil then
		self.uiClass["RolePromotedProviewUI"] = ClassRolePromotedProviewUI.new(obj,protype)
		self.uiClass["RolePromotedProviewUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedProviewUI()
	if self.uiClass["RolePromotedProviewUI"] then
		self.uiClass["RolePromotedProviewUI"]:hideUI()
		self.uiClass["RolePromotedProviewUI"] = nil
	end
end

function RoleMgr:showRolePromotedLuckyWheel()
	if self.uiClass["RolePromotedLuckyWheelUI"] == nil then
		MessageMgr:sendPost('get_promote_wheel','activity',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["RolePromotedLuckyWheelUI"] = ClassRolePromotedLuckyWheelUI.new(data)
				self.uiClass["RolePromotedLuckyWheelUI"]:showUI()
			end
		end)
	end
end

function RoleMgr:hideRolePromotedLuckyWheel()
	if self.uiClass["RolePromotedLuckyWheelUI"] then
		self.uiClass["RolePromotedLuckyWheelUI"]:hideUI()
		self.uiClass["RolePromotedLuckyWheelUI"] = nil
	end
end

function RoleMgr:showRolePromotedLuckyWheelRank(data,startTime,endTime)
	if self.uiClass["RolePromotedLuckyWheelRankUI"] == nil then
		self.uiClass["RolePromotedLuckyWheelRankUI"] = ClassRolePromotedLuckyWheelRankUI.new(data,startTime,endTime)
		self.uiClass["RolePromotedLuckyWheelRankUI"]:showUI()
	end
end

function RoleMgr:hideRolePromotedLuckyWheelRank()
	if self.uiClass["RolePromotedLuckyWheelRankUI"] then
		self.uiClass["RolePromotedLuckyWheelRankUI"]:hideUI()
		self.uiClass["RolePromotedLuckyWheelRankUI"] = nil
	end
end

function RoleMgr:showRoleAutoReborn(obj)
	if self.uiClass["RoleAutoRebornUI"] == nil then
		self.uiClass["RoleAutoRebornUI"] = ClassRoleAutoRebornUI.new(obj)
		self.uiClass["RoleAutoRebornUI"]:showUI()
	end
end

function RoleMgr:hideRoleAutoReborn()
	if self.uiClass["RoleAutoRebornUI"] then
		self.uiClass["RoleAutoRebornUI"]:hideUI()
		self.uiClass["RoleAutoRebornUI"] = nil
	end
end

function RoleMgr:showRoleAutoUpgradeStar(obj)
	if self.uiClass["RoleAutoUpgradeStarUI"] == nil then
		self.uiClass["RoleAutoUpgradeStarUI"] = ClassRoleAutoUpgradeStarUI.new(obj)
		self.uiClass["RoleAutoUpgradeStarUI"]:showUI()
	end
end

function RoleMgr:hideRoleAutoUpgradeStar()
	if self.uiClass["RoleAutoUpgradeStarUI"] then
		self.uiClass["RoleAutoUpgradeStarUI"]:hideUI()
		self.uiClass["RoleAutoUpgradeStarUI"] = nil
	end
end

function RoleMgr:hideChildPanelByIdx(idx)
	if self.uiClass["RoleMainUI"] then
		self.uiClass["RoleMainUI"]:hideChildPanelByIdx(idx)
	end
end

function RoleMgr:showChildPanelByIdx(idx, pos, immediately)
	if self.uiClass["RoleMainUI"] then
	   self.uiClass["RoleMainUI"]:showChildPanelByIdx(idx, pos, immediately)
	end
end

function RoleMgr:swapChildName(idx)
	--小兵界面标题特殊需求
	if self.uiClass["RoleMainUI"] and idx ~= 4 then 
	   self.uiClass["RoleMainUI"]:swapTitle(idx)
	end
end

function RoleMgr:setDirty(uitype,onlychild)
	onlychild = onlychild or true
	if uitype then
		if self.uiClass[uitype] then
			self.uiClass[uitype]:setDirty(onlychild)
		end
	else
		for k,v in pairs(self.uiClass) do
			v:setDirty(onlychild)
		end
	end
end

function RoleMgr:updateRoleMainUI()
	if self.uiClass['RoleMainUI'] ~= nil then
		self.uiClass['RoleMainUI']:update()
	end
end

function RoleMgr:updateLvRoleMainUI()
	if self.uiClass['RoleMainUI'] ~= nil then
		self.uiClass['RoleMainUI']:lvUpdate()
	end
end


function RoleMgr:getRoleMainUILv()
	if self.uiClass['RoleMainUI'] ~= nil then
		return self.uiClass['RoleMainUI']:getLv()
	end
end


function RoleMgr:updateRoleMainUIForce()
	if self.uiClass['RoleMainUI'] ~= nil then
		self.uiClass['RoleMainUI']:updateOutSide()
	end
end

function RoleMgr:updateRoleList(cur)
	if cur then
		if self.uiClass["RoleListUI"] then
			self.uiClass["RoleListUI"]:setDirty(true)
		end
	else
		self.rolelistdirty = true
	end
end

function RoleMgr:updateRoleListUI()
    if self.uiClass["RoleListUI"] then
		self.uiClass["RoleListUI"]:update()
	end
end

function RoleMgr:getSelectRolePos()
	return self.selectpos
end

function RoleMgr:setSelectRolePos(pos)
	self.selectpos = pos
end

function RoleMgr:setCurHeroChange( value )
	self.curHeroIschange = value
end

function RoleMgr:getCurHeroChange()
	return self.curHeroIschange
end

function RoleMgr:updateMainUIExpBar(oldlv,percent,level,index,callBack)
	if self.uiClass['RoleMainUI'] then
		self.uiClass['RoleMainUI']:updatelvbar(oldlv,percent,level,index,callBack)
	end
end
-- 武将排序:品质>战斗力>id
function  RoleMgr:sortByQuality(arr,arrtype)
	if arrtype == ROLELISTTYPE.UI_ASSIST or arrtype == ROLELISTTYPE.UI_BEASSIST or arrtype == ROLELISTTYPE.UI_PROMOTED then
		table.sort(arr, function (a, b)
			local junzhu1 = a:isJunZhuforSort()
			local junzhu2 = b:isJunZhuforSort()
			if junzhu1 == junzhu2  then
			    local q1 = a:getRealQulity()
				local q2 = b:getRealQulity()
				if q1 == q2 then
                    local f1 = 0
					local f2 = 0
                    if arrtype == ROLELISTTYPE.UI_BEASSIST then
                        f1 = f2
                    else
                        f1 = a:getFightForce()
					    f2 = b:getFightForce()
                    end
					if f1 == f2 then
						local level1 = a:getPosId()
						local level2 = b:getPosId()
						if  level1 == level2 then
							local id1 = a:getId()
							local id2 = b:getId()
							return id1 > id2						
						else
							return level1 < level2
						end
						
					else
						return f1 > f2
					end
				else
					return q1 > q2
				end
			else
				return junzhu1 >junzhu2
			end
		end)
	elseif arrtype == ROLELISTTYPE.UI_CHIP then
        for k,v in pairs(arr) do
            local num = v:getNum()
            local mergenum = v:getMergeNum()
            if num >= mergenum then
                v.canMerge = 1
            else
                v.canMerge = 0
            end

        end

		table.sort(arr, function (a, b)
            local canMerge1 = a.canMerge
            local canMerge2 = b.canMerge

            if canMerge1 == canMerge2 then
                local q1 = a:getNum()
			    local q2 = b:getNum()
			    if q1 == q2 then
				    local f1 = a:getId()
				    local f2 = b:getId()
				    return f1 > f2
			    else
				    return q1 > q2
			    end
            else
                return canMerge1 > canMerge2
            end

		end)
	end
end

function RoleMgr:showSuit(pos,page)
	if self.uiClass["SuitUI"] == nil then
		self.uiClass["SuitUI"] = ClassSuitUI.new(pos,page)
		self.uiClass["SuitUI"]:showUI()
	end
end

function RoleMgr:hideSuit()
	if self.uiClass["SuitUI"] then
		self.uiClass["SuitUI"]:hideUI()
		self.uiClass["SuitUI"] = nil
	end
end

function RoleMgr:showStengthenPopupUI(role, type, curarr ,nextarr, func, obj, targetlv)
	if self.uiClass["StrengthenPopupUI"] == nil then
		self.uiClass["StrengthenPopupUI"] = ClassStrengthenPopupUI.new(role, type, curarr ,nextarr, func, obj,targetlv)
		self.uiClass["StrengthenPopupUI"]:showUI()
	end
end

function RoleMgr:hideStengthenPopupUI()
	if self.uiClass["StrengthenPopupUI"] then
		self.uiClass["StrengthenPopupUI"]:hideUI()
		self.uiClass["StrengthenPopupUI"] = nil
	end
end


function RoleMgr:getRoleMainExpBarPos()
	local x = 0 
	local y = 0
	if self.uiClass["RoleMainUI"] then
		x,y = self.uiClass["RoleMainUI"]:getExpBarPos()
	end
	return x,y
end

function RoleMgr:setRoleMainTitle(str)
	if self.uiClass["RoleMainUI"] then
		self.uiClass["RoleMainUI"]:setTitleName(str)
	end
end

function RoleMgr:showRoleExchange(callback)
	if self.uiClass["RoleExchangeUI"] == nil then
		self.uiClass["RoleExchangeUI"] = ClassRoleExchangeUI.new(callback)
		self.uiClass["RoleExchangeUI"]:showUI()
	end
end

function RoleMgr:hideRoleExchange()
	if self.uiClass["RoleExchangeUI"] then
		self.uiClass["RoleExchangeUI"]:hideUI()
		self.uiClass["RoleExchangeUI"] = nil
	end
end

function RoleMgr:showRoleTupoInfoUI(obj)
	if self.uiClass["RoleTupoInfoUI"] == nil then
		self.uiClass["RoleTupoInfoUI"] = ClassRoleTupoInfoUI.new(obj)
		self.uiClass["RoleTupoInfoUI"]:showUI()
	end
end

function RoleMgr:hideRoleTupoInfoUI()
	if self.uiClass["RoleTupoInfoUI"] then
		self.uiClass["RoleTupoInfoUI"]:hideUI()
		self.uiClass["RoleTupoInfoUI"] = nil
	end
end

function RoleMgr:showSoldierinfo(obj)
	if self.uiClass["SoldierinfoUI"] == nil then
		self.uiClass["SoldierinfoUI"] = ClassSoldierinfoUI.new(obj)
		self.uiClass["SoldierinfoUI"]:showUI()
	end
end

function RoleMgr:hideSoldierinfo()
	if self.uiClass["SoldierinfoUI"] then
		self.uiClass["SoldierinfoUI"]:hideUI()
		self.uiClass["SoldierinfoUI"] = nil
	end
end

function RoleMgr:showSoldierUpgrade(role, fromAttr, toAttr, func)
	if self.uiClass["SoldierUpgradeUI"] == nil then
		self.uiClass["SoldierUpgradeUI"] = ClassSoldierUpgradeUI.new(role, fromAttr, toAttr, func)
		self.uiClass["SoldierUpgradeUI"]:showUI()
	end
end

function RoleMgr:hideSoldierUpgrade()
	if self.uiClass["SoldierUpgradeUI"] then
		self.uiClass["SoldierUpgradeUI"]:hideUI()
		self.uiClass["SoldierUpgradeUI"] = nil
	end
end

function RoleMgr:showSkillUpgrade(role,func)
	if self.uiClass["SkillUpgradeUI"] == nil then
		self.uiClass["SkillUpgradeUI"] = ClassSkillUpgradeUI.new(role,func)
		self.uiClass["SkillUpgradeUI"]:showUI()
	end
end

function RoleMgr:hideSkillUpgrade()
	if self.uiClass["SkillUpgradeUI"] then
		self.uiClass["SkillUpgradeUI"]:hideUI()
		self.uiClass["SkillUpgradeUI"] = nil
	end
end

function RoleMgr:showFateShow(role, fid)
	if self.uiClass.FateShowUI == nil then
		self.uiClass.FateShowUI = ClassFateShowUI.new(role, fid)
		self.uiClass.FateShowUI:showUI()
	end
end

function RoleMgr:hideFateShow()
	if self.uiClass.FateShowUI then
		self.uiClass.FateShowUI:hideUI()
		self.uiClass.FateShowUI = nil
	end
end

function RoleMgr:setIsShowAttUpdate(value)
	self.isshowAttributeUpdate = value
end

function RoleMgr:getIsShowAttUpdate()
	return self.isshowAttributeUpdate
end

function RoleMgr:popupTips(role,isAll)
	--local time1 = socket.gettime()
	local attchange = {}
	local arr1 = RoleData:getPosAttByPos(role)
	local arr2 = RoleData:getRoleOldAtt(role)
	local attconf =GameData:getConfData('attribute')
	local attcount = #attconf
	local isnew = true
	for i=1,attcount do
		if arr2[i] ~= 0 then
			isnew = false
		end
	end
	-- local showarr = {}
	local showWidgets = {}
	-- local popnum = 1
	if isnew == false then

		for i = 1,attcount do
			attchange[i] = arr1[i] - arr2[i]
			local desc = attconf[i].desc
			if desc == "0" then
				desc = ''
			end
			if attchange[i] > 0 then
			
				local str = math.abs(string.format("%.1f", attchange[i]))
				local name = role:getName().."  "..attconf[i].name ..' + '.. str..desc
				local color = COLOR_TYPE.GREEN
				if i == 10 then
					name = role:getName().."  "..attconf[i].name ..' - '.. str..desc
					color = COLOR_TYPE.RED
				end
				local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
				w:setTextColor(color)
				w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
				w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				table.insert(showWidgets, w)
			elseif attchange[i] < 0 then
				local str = math.abs(string.format("%.1f", attchange[i]))
				local name = role:getName().."  "..attconf[i].name ..' - '.. str..desc
				local color = COLOR_TYPE.RED
				if i == 10 then
					--print('name'..attconf[i].name)
					name = role:getName().."  "..attconf[i].name ..' + '.. str..desc
					color = COLOR_TYPE.GREEN
				end
				
				local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
				w:setTextColor(color)
				w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
				w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				table.insert(showWidgets, w)
			end
		end
		local oldSuit = RoleData:getRoleOtherOldData(role:getPosId())
		local _,newSuit = role:getSuitAttr()
		local function updateShowWidgets(i,name)
			local color = COLOR_TYPE.YELLOW
			local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
			w:setTextColor(color)
			w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		local maxSuit = 4
		for i=1,maxSuit do
			if i == maxSuit then
				for j,v in pairs(newSuit[maxSuit]) do
					for k,v1 in pairs(v) do
						if not oldSuit[maxSuit][j][k] then
							local name = role:getName().."  "..v1
							updateShowWidgets(i,name)
						end
					end
				end
			else
				if newSuit[tonumber(i)][1] > oldSuit[tonumber(i)][1] then
					local name = role:getName().."  "..newSuit[tonumber(i)][2]
					updateShowWidgets(i,name)
				end
			end
		end
		local oldFightForce = RoleData:getOldFightForce()
		local fightForce = RoleData:getFightForce(true)
		if oldFightForce ~= fightForce then
			local addStr = oldFightForce > fightForce and ' - ' or ' + '
			local color = oldFightForce > fightForce and COLOR_TYPE.RED or cc.c3b(0,252,255)
			local name = role:getName().."  "..GlobalApi:getLocalStr('FIGHT_FORCE')..addStr..math.abs(fightForce - oldFightForce)
			local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 26)
			w:setTextColor(color)
			w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		RoleData:setOldFightForce(fightForce)
		------------------------------------------------------------------------------------------------
		-- 计算 缘分 特么的提示
		local oldFates = RoleData:getRoleFateOldData()
		local newFates = RoleData:getAlreadyFateforShow()
		local addFates = {}
		local delFates = {}
		for i, v in ipairs(newFates) do
			local n = GlobalApi:tableFind(oldFates, v)
			if n == 0 then
				table.insert(addFates, v)
			end
		end
		for i, v in ipairs(oldFates) do
			local n = GlobalApi:tableFind(newFates, v)
			if n == 0 then
				table.insert(delFates, v)
			end
		end

		local fateconf = GameData:getConfData('fate')
		local attconf = GameData:getConfData('attribute')
		for i, v in ipairs(delFates) do
			v = tonumber(v)
			if fateconf[v] == nil then
				print('[ERROR]: fate.dat can not find id: ' .. v)
				break
			end

			local rt = xx.RichText:create()

			local title = '【' .. fateconf[v].name .. '】:'
			local rtl1 = xx.RichTextLabel:create(title, 24, COLOR_TYPE.ORANGE)
			rtl1:setStroke(COLOR_TYPE.BLACK, 1)
			rtl1:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))

			local str = GlobalApi:getLocalStr('FATE_TIP_LOSE')
			local atttab  = fateconf[v].att11
			local attvalue = fateconf[v].value11
			if atttab  and tonumber(atttab[1]) > 0 then
				if  #atttab > 1 then
					-- 当有多个属性的时候 只有可能是防御
					str = str .. GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					str = str .. attconf[tonumber(atttab[1])].name
				end	
				str = str .. GlobalApi:getLocalStr('FATE_TIP_DOWN')
				str = str .. attvalue .. '%'
			end

			local atttab2 = fateconf[v].att12
			local attvalue2 = fateconf[v].value12
			if atttab2 and tonumber(atttab2[1]) > 0 then
				str = str .. '、'
				if #atttab2 > 1 then 
					str = str .. GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					str = str .. attconf[tonumber(atttab2[1])].name
				end
				str = str .. GlobalApi:getLocalStr('FATE_TIP_DOWN')
				str = str .. attvalue2 .. '%'
			end

			local rtl2 = xx.RichTextLabel:create(str, 24, COLOR_TYPE.RED)
			rtl2:setStroke(COLOR_TYPE.BLACK, 1)
			rtl2:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))

			rt:addElement(rtl1)
			rt:addElement(rtl2)
			rt:format(true)
			rt:setContentSize(rt:getElementsSize())
			table.insert(showWidgets, rt)
		end

		for i, v in ipairs(addFates) do
			v = tonumber(v)
			if fateconf[v] == nil then
				print('[ERROR]: fate.dat can not find id: ' .. v)
				break
			end

			local rt = xx.RichText:create()

			local title = '【' .. fateconf[v].name .. '】:'
			local rtl1 = xx.RichTextLabel:create(title, 24, COLOR_TYPE.ORANGE)
			rtl1:setStroke(COLOR_TYPE.BLACK, 1)
			rtl1:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))

			local str = GlobalApi:getLocalStr('FATE_TIP_GET')
			local atttab  = fateconf[v].att11
			local attvalue = fateconf[v].value11
			if atttab  and tonumber(atttab[1]) > 0 then
				if  #atttab > 1 then
					-- 当有多个属性的时候 只有可能是防御
					str = str .. GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					str = str .. attconf[tonumber(atttab[1])].name
				end	
				str = str .. GlobalApi:getLocalStr('FATE_TIP_UP')
				str = str .. attvalue .. '%'
			end

			local atttab2 = fateconf[v].att12
			local attvalue2 = fateconf[v].value12
			if atttab2 and tonumber(atttab2[1]) > 0 then
				str = str .. '、'
				if #atttab2 > 1 then 
					str = str .. GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					str = str .. attconf[tonumber(atttab2[1])].name
				end
				str = str .. GlobalApi:getLocalStr('FATE_TIP_UP')
				str = str .. attvalue2 .. '%'
			end

			local rtl2 = xx.RichTextLabel:create(str, 24, COLOR_TYPE.GREEN)
			rtl2:setStroke(COLOR_TYPE.BLACK, 1)
			rtl2:setShadow(cc.c4b(40,40,40,255), cc.size(0, -1))

			rt:addElement(rtl1)
			rt:addElement(rtl2)
			rt:format(true)
			rt:setContentSize(rt:getElementsSize())
			table.insert(showWidgets, rt)
		end
		RoleData:setRoleFateOldData(newFates)
		------------------------------------------------------------------------------------------------

		-- local sz = self.fightforcebg:getContentSize()
		-- local x, y = self.fightforcebg:convertToWorldSpace(cc.p(sz.width / 2, sz.height/ 2))
		if RoleMgr:getIsShowAttUpdate() and not isAll then
			promptmgr:showAttributeUpdate(showWidgets)
			-- promptmgr:showAttributeUpdate(x, y, showarr)
		end
		if isAll then
			role:getFightForce()
		end
		RoleData:cleanOldAtt()
		RoleData:cleanOldOther(role:getPosId(), newSuit)
	end
	-- local time2 = socket.gettime()
	-- print('xxxx==='..time2-time1)
end

function RoleMgr:playFateGuild()
	if self.uiClass.RoleMainUI ~= nil then
		self.uiClass.RoleMainUI:playFateGuild()
	end
end

function RoleMgr:stopFateGuild()
	if self.uiClass.RoleMainUI ~= nil then
		self.uiClass.RoleMainUI:stopFateGuild()
	end
end

-- 播放role升级特效
function RoleMgr:playRoleUpgradeEffect()
    if self.uiClass.RoleMainUI == nil then
        return
    end

    local anim_pl = self.uiClass.RoleMainUI.anim_pl

    local size1 = anim_pl:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_jueseshengji_01')
    lvUp:setPosition(cc.p(size1.width/2,size1.height/2 + 20))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(10000)
    --lvUp:setScale(1.2)
    anim_pl:addChild(lvUp)
    lvUp:getAnimation():playWithIndex(0, -1, 0)
   
    lvUp:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		lvUp:removeFromParent()
	end)))

end

function RoleMgr:updateRoleMainUIEXP()
	if self.uiClass["RoleMainUI"]then
		self.uiClass["RoleMainUI"]:setEXP()
	end
end

function RoleMgr:showSelectRoleFight()
	local ui = require('script/app/ui/role/roleselectfight').new()
	ui:showUI()
end

function RoleMgr:showPokedex(id)
	if self.uiClass["PokedexUI"] == nil then
		self.uiClass["PokedexUI"] = ClassPokedexUI.new(id)
		self.uiClass["PokedexUI"]:showUI()
	end
end

function RoleMgr:hidePokedex()
	if self.uiClass["PokedexUI"] then
		self.uiClass["PokedexUI"]:hideUI()
		self.uiClass["PokedexUI"] = nil
	end
end

function RoleMgr:showPokedexHero(roleObj)
	if self.uiClass["PokedexHeroUI"] == nil then
		self.uiClass["PokedexHeroUI"] = ClassPokedexHeroUI.new(roleObj)
		self.uiClass["PokedexHeroUI"]:showUI()
	end
end

function RoleMgr:hidePokedexHero()
	if self.uiClass["PokedexHeroUI"] then
		self.uiClass["PokedexHeroUI"]:hideUI()
		self.uiClass["PokedexHeroUI"] = nil
	end
end

function RoleMgr:showGemFill(pos)
	if self.uiClass["GemFillUI"] == nil then
		self.uiClass["GemFillUI"] = ClassGemFillUI.new(pos)
		self.uiClass["GemFillUI"]:showUI()
	end
end

function RoleMgr:hideGemFill()
	if self.uiClass["GemFillUI"] then
		self.uiClass["GemFillUI"]:hideUI()
		self.uiClass["GemFillUI"] = nil
	end
end

function RoleMgr:showEquipRefine(rolePos,equipPos)
	if self.uiClass["EquipRefineUI"] == nil then
		self.uiClass["EquipRefineUI"] = ClassEquipRefineUI.new(rolePos,equipPos)
		self.uiClass["EquipRefineUI"]:showUI()
	end
end

function RoleMgr:hideEquipRefine()
	if self.uiClass["EquipRefineUI"] then
		self.uiClass["EquipRefineUI"]:hideUI()
		self.uiClass["EquipRefineUI"] = nil
	end
end

function RoleMgr:showEquipRefineLvUp(rolePos,equipPos,currLevel,nextLevel,page,callback)
	if self.uiClass["EquipRefineLvUpUI"] == nil then
		self.uiClass["EquipRefineLvUpUI"] = ClassEquipRefineLvUpUI.new(rolePos,equipPos,currLevel,nextLevel,page,callback)
		self.uiClass["EquipRefineLvUpUI"]:showUI()
	end
end

function RoleMgr:hideEquipRefineLvUp()
	if self.uiClass["EquipRefineLvUpUI"] then
		self.uiClass["EquipRefineLvUpUI"]:hideUI()
		self.uiClass["EquipRefineLvUpUI"] = nil
	end
end

function RoleMgr:showRoleOneLevelPannel(data,desc,callBack)
	if self.uiClass["RoleOneLevelPannelUI"] == nil then
		self.uiClass["RoleOneLevelPannelUI"] = ClassRoleonelevelPannelUI.new(data,desc,callBack)
		self.uiClass["RoleOneLevelPannelUI"]:showUI()
	end
end

function RoleMgr:hideRoleOneLevelPannel()
	if self.uiClass["RoleOneLevelPannelUI"] then
		self.uiClass["RoleOneLevelPannelUI"]:hideUI()
		self.uiClass["RoleOneLevelPannelUI"] = nil
	end
end

function RoleMgr:showRoleLvUpOneLevelPannel(lvUpData,pos,callBack)
	if self.uiClass["RoleLvUpOneLevelPannelUI"] == nil then
		self.uiClass["RoleLvUpOneLevelPannelUI"] = ClassRoleLvUpOneLevelPannelUI.new(lvUpData,pos,callBack)
		self.uiClass["RoleLvUpOneLevelPannelUI"]:showUI()
	end
end

function RoleMgr:hideRoleLvUpOneLevelPannel()
	if self.uiClass["RoleLvUpOneLevelPannelUI"] then
		self.uiClass["RoleLvUpOneLevelPannelUI"]:hideUI()
		self.uiClass["RoleLvUpOneLevelPannelUI"] = nil
	end
end

function RoleMgr:showRoleLvUpOneLevelPannelUI(type)
	if self.uiClass["RoleFateFateConspiracyActivePannelUI"] == nil then
		self.uiClass["RoleFateFateConspiracyActivePannelUI"] = ClassRoleFateFateConspiracyActivePannelUI.new(type)
		self.uiClass["RoleFateFateConspiracyActivePannelUI"]:showUI()
	end
end

function RoleMgr:hideRoleLvUpOneLevelPannelUI()
	if self.uiClass["RoleFateFateConspiracyActivePannelUI"] then
		self.uiClass["RoleFateFateConspiracyActivePannelUI"]:hideUI()
		self.uiClass["RoleFateFateConspiracyActivePannelUI"] = nil
	end
end

function RoleMgr:showRoleFateFateConspiracyChooseHerolPannel(type,heroIds,pos,callBack)
	if self.uiClass["RoleFateFateConspiracyChooseHerolUI"] == nil then
		self.uiClass["RoleFateFateConspiracyChooseHerolUI"] = ClassRoleFateFateConspiracyChooseHerolUI.new(type,heroIds,pos,callBack)
		self.uiClass["RoleFateFateConspiracyChooseHerolUI"]:showUI()
	end
end

function RoleMgr:hideRoleFateFateConspiracyChooseHerolPannel()
	if self.uiClass["RoleFateFateConspiracyChooseHerolUI"] then
		self.uiClass["RoleFateFateConspiracyChooseHerolUI"]:hideUI()
		self.uiClass["RoleFateFateConspiracyChooseHerolUI"] = nil
	end
end

function RoleMgr:showRoleFateFateConspiracyUpgradeUI(type,oldfight,newfightforce,nowLv,func)
	if self.uiClass["RoleFateFateConspiracyUpgradeUI"] == nil then
		self.uiClass["RoleFateFateConspiracyUpgradeUI"] = ClassRoleFateFateConspiracyUpgradeUI.new(type,oldfight,newfightforce,nowLv,func)
		self.uiClass["RoleFateFateConspiracyUpgradeUI"]:showUI()
	end
end

function RoleMgr:hideRoleFateFateConspiracyUpgradeUI()
	if self.uiClass["RoleFateFateConspiracyUpgradeUI"] then
		self.uiClass["RoleFateFateConspiracyUpgradeUI"]:hideUI()
		self.uiClass["RoleFateFateConspiracyUpgradeUI"] = nil
	end
end

function RoleMgr:calcRebornLvUpMaxNum(obj)
	local maxnum = 0
	local curlv = obj:getTalent()
	local lv = obj:getLevel()
	local rebornconf = GameData:getConfData('reborn')[obj:getrebornType()]
	maxnum = #rebornconf
	for i=1,#rebornconf do
		if lv >= rebornconf[i]['roleLevel'] then
			maxnum = i
		else
			break
		end
	end
	local costtab = {}
	local finalnum = 0
	for i = curlv+1,maxnum do
		local tab = rebornconf[i]['cost']
		for k,v in pairs (tab) do
			table.insert(costtab,v)
		end
		if obj:isJunZhu() == false then
			if rebornconf[i]['cardCost'] > 0 then
				local tab1 = {'card',obj:getId(),-rebornconf[i]['cardCost']}
				table.insert(costtab,tab1)
			end
			if rebornconf[i]['fragmentCost'] > 0 then
				local tab2 = {'fragment',obj:getId(),-rebornconf[i]['fragmentCost']}
				table.insert(costtab,tab2)
			end
		end
		local mergetab = GlobalApi:mergeAwards(costtab)
		local costobjs = DisplayData:getDisplayObjs(mergetab)
		local isgoodsok = true
		for k,v in pairs(costobjs) do
			if v:getNum() > v:getOwnNum() then
				isgoodsok = false
				break
			end
		end
		if isgoodsok then
			finalnum = finalnum + 1
		else
			break
		end
	end
	return finalnum 
end

function RoleMgr:calcRebornCost(obj,curlv,tolv)
	local costtab = {}
	local costobjs = {}
	local rebornconf = GameData:getConfData('reborn')[obj:getrebornType()]
	for i = curlv+1,curlv + tolv do
		local tab = rebornconf[i]['cost']
		for k,v in pairs (tab) do
			table.insert(costtab,v)
		end
		if obj:isJunZhu() == false then
			if rebornconf[i]['cardCost'] > 0 then
				local tab1 = {'card',obj:getId(),-rebornconf[i]['cardCost']}
				table.insert(costtab,tab1)
			end
			if rebornconf[i]['fragmentCost'] > 0 then
				local tab2 = {'fragment',obj:getId(),-rebornconf[i]['fragmentCost']}
				table.insert(costtab,tab2)
			end
		end
		local mergetab = GlobalApi:mergeAwards(costtab)
		costobjs = DisplayData:getDisplayObjs(mergetab)
	end
	return costobjs
end

function RoleMgr:sendRebornMsg(obj, tolv, curatt, nextatt, func)
	local costobjs = self:calcRebornCost(obj, obj:getTalent(), tolv)
	for k,v in pairs(costobjs) do
		if v:getNum() > v:getOwnNum() then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
			return
		end
	end
	local args = {
        pos = obj:getPosId(),
        upgrade = tolv
	}
	MessageMgr:sendPost("upgrade_talent", "hero", json.encode(args), function (jsonObj)
		print(json.encode(jsonObj))
		local code = jsonObj.code
		if code == 0 then
			RoleMgr:showStengthenPopupUI(obj, 'upgrade_talent',curatt, nextatt, function()
				local awards = jsonObj.data.awards
				GlobalApi:parseAwardData(awards)
				local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
				obj:setTalent(jsonObj.data.talent)

                local innateGroupId = obj:getInnateGroup()
                local groupconf = GameData:getConfData('innategroup')[innateGroupId]
                local innateid = groupconf[tostring('level' .. obj:getTalent())]
                local innateconf = GameData:getConfData('innate')[innateid]
                local tx ="" --string.format(GlobalApi:getLocalStr("ROLE_TUPO_ACTIVE_DESC"), innateconf['name'])                     
                
                if innateid < 1000 then
                	tx = string.format(GlobalApi:getLocalStr("ROLE_TUPO_ACTIVE_DESC"), innateconf['name']) 
                else
                	tx = string.format(GlobalApi:getLocalStr("ROLE_TUPO_ACTIVE_DESC"), groupconf[tostring('specialName'..innateid%1000)]) 
                end
                promptmgr:showSystenHint(tx,COLOR_TYPE.GREEN)
				--self.obj
				for i=1,MAXROlENUM do
					local obj = RoleData:getRoleByPos(i)
					if obj and obj:getId() > 0 then
						obj:setFightForceDirty(true)
					end
				end
                RoleMgr:updateRoleList()
				RoleMgr:updateRoleMainUI()
			end,nil,tolv)
		end
	end)
end

function RoleMgr:clacUpgradeStarMaxNum(obj)
	local minnum = 0
	local maxnum = 0
	local curlv = obj:getHeroQuality()
	local lv = obj:getLevel()
	local talent = obj:getTalent()
	local soldierlv = obj:getSoldierLv()
	local conf = GameData:getConfData('heroquality')
	for i=1,#conf-1 do
		if lv >= conf[i]['conditionHeroLevel'] then
			maxnum = maxnum + 1
		else
			break
		end
	end
	minnum = maxnum
	local maxnum1 = 0
	for i=1,#conf-1 do
		if talent >= conf[i]['conditionHeroTalent'] then
			maxnum1 = maxnum1 + 1
		else
			break
		end
	end
	if minnum > maxnum1 then
		minnum = maxnum1
	end
	local maxnum2 = 0
	for i=1,#conf-1 do
		if soldierlv >= conf[i]['conditionHeroSoldier'] then
			maxnum2 = maxnum2 + 1
		else
			break
		end
	end
	if minnum > maxnum2 then
		minnum = maxnum2
	end
    local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
	local costtab = {}
	local finalnum = 1 
	for i = curlv+1,minnum do
		local tab1 = {'material',itemId,-conf[i]['itemNum']}
		table.insert(costtab,tab1)
		local mergetab = GlobalApi:mergeAwards(costtab)
		local costobjs = DisplayData:getDisplayObjs(mergetab)
		local isgoodsok = true
		for k,v in pairs(costobjs) do
			if v:getNum() > v:getOwnNum() then
				isgoodsok = false
				break
			end
		end
		if isgoodsok then
			finalnum = finalnum + 1
		else
			break
		end
	end
	return finalnum
end

function RoleMgr:calcUpgradeStarCost(obj,curlv,tolv)
	local costtab = {}
	local costobjs = {}
	local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
	local conf = GameData:getConfData('heroquality')
	for i = curlv,curlv + tolv-1 do
		local tab1 = {'material',itemId,-conf[i]['itemNum']}
		table.insert(costtab,tab1)
		local mergetab = GlobalApi:mergeAwards(costtab)
		costobjs = DisplayData:getDisplayObjs(mergetab)
	end
	return costobjs
end

function RoleMgr:sendUpgradeStarMsg(obj, tolv, curatt, nextatt, func)
	local costobjs = self:calcUpgradeStarCost(obj, obj:getHeroQuality(), tolv)
	for k,v in pairs(costobjs) do
		if v:getNum() > v:getOwnNum() then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
			return
		end
	end
	local args = {
		pos = obj:getPosId(),
		upgrade = tolv
	}
    MessageMgr:sendPost('upgrade_heroquality','hero',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
			RoleMgr:showStengthenPopupUI(obj, 'upgrade_risestar',curatt,nextatt, function()
	            local costs = data.costs
	            if costs then
	                GlobalApi:parseAwardData(costs)
	            end
	            obj:setHeroQuality(data.quality)
	            obj:setFightForceDirty(true)
	            RoleMgr:updateRoleList()
	            RoleMgr:updateRoleMainUI()
	            --self:update(obj)
			end,nil,tolv)
        end
    end) 
end

function RoleMgr:popupFateConspiracyTips(type,nowLv,nextLv,oldfightforce,newfightforce)
    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[type]
    local attconf = GameData:getConfData('attribute')
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')

    local attcount = #attconf
    local arr1 = {}
    local arr2 = {}
    for i = 1,attcount do
        arr1[i] = 0
        arr2[i] = 0
    end

    local attSpecialId = fateAdvancedTypeData.attSpecialId
    
    if nowLv > 0 then
        local oldFateAdvancedData = fateadvancedConf[type][nowLv]
        arr1[attSpecialId] = oldFateAdvancedData.attSpecialValue/100 + arr1[attSpecialId]

        for i = 1,4 do
            local attId = fateAdvancedTypeData['attId' .. i]
            arr1[attId] = oldFateAdvancedData['attValue' .. i] + arr1[attId]
        end
    end

    local newFateAdvancedData = fateadvancedConf[type][nextLv]
    arr2[attSpecialId] = newFateAdvancedData.attSpecialValue/100 + arr2[attSpecialId]

    for i = 1,4 do
        local attId = fateAdvancedTypeData['attId' .. i]
        arr2[attId] = newFateAdvancedData['attValue' .. i] + arr2[attId]
    end

    local showWidgets = {}
    for i = 1,attcount do
        local attchange = arr2[i] - arr1[i]
        local desc = attconf[i].desc
        if desc == "0" then
            desc = ''
        end
        if attchange > 0 then
            local str = attchange
            local name = fateAdvancedTypeData.attAddDesc .."  "..attconf[i].name ..' + '.. str..desc
            local color = COLOR_TYPE.GREEN
            if i == 10 then
                name = fateAdvancedTypeData.attAddDesc .."  "..attconf[i].name ..' - '.. str..desc
                color = COLOR_TYPE.RED
            end
            local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
            w:setTextColor(color)
            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            table.insert(showWidgets, w)
        end
    end
    if newfightforce - oldfightforce > 0 then
        local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' + '.. math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 26)
        w:setTextColor(cc.c3b(0,252,255))
        w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        table.insert(showWidgets, w)
    elseif newfightforce - oldfightforce < 0 then
        local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' - '..math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 26)
        w:setTextColor(COLOR_TYPE.RED)
        w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        table.insert(showWidgets, w)
    end
    promptmgr:showAttributeUpdate(showWidgets)
end
