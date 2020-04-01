cc.exports.MainSceneMgr = {
	uiClass = {
		mainCityUI = nil,
		campUI = nil,
		shopUI = nil,
		treasureUI = nil,
		treasureMergeUI = nil,
		mainShopUI = nil,
		mailUI = nil,
		taskUI = nil,
		altarUI = nil,
		signUI = nil,
		signRewardUI = nil,
		jadesealUI = nil,
		jadesealAwardUI = nil,
		jadesealGetAwardUI = nil,
		taskAttUI = nil,
		militaryUI = nil,
		militaryGetWayUI = nil,
		skillSelectUI = nil,
		dragonInfoUI = nil,
		chickenSuitUI = nil,
		inlayDragonGemUI = nil,
        oneYuanBuyUI = nil,
        threeYuanBuyUI = nil,
		resGetBackUI = nil,
		resGetBackCellUI = nil,
        tasknewUI = nil,
        tasknobilityUI = nil,
        tasknobilityUpUI = nil,
        citycraftremarkUI = nil,
        resGetBackAllUI = nil,
        openRankUI = nil,
        eightYuanBuyUI = nil,
        promoteGetSoulUI = nil,
		militaryEntranceUI = nil,
		NBSkyUI = nil,
		lvGrowFundUI =nil,
	},
	refreshTab = {}
}
setmetatable(MainSceneMgr.uiClass, {__mode = "v"})

local ClassMainCityUI = require("script/app/ui/mainscene/maincityui")
local ClassShopUI = require("script/app/ui/mainscene/shopui")
local ClassTreasureUI = require("script/app/ui/mainscene/treasure")
local ClassTreasureMergeUI = require("script/app/ui/mainscene/treasuremerge")
local ClassMainShopUI = require("script/app/ui/mainscene/shopmainui")
local ClassMailUI = require("script/app/ui/mainscene/mailui")
local ClassTaskUI = require("script/app/ui/mainscene/taskui")
local ClassAltarUI = require("script/app/ui/mainscene/altarui")
local ClassSignRewardUI = require("script/app/ui/mainscene/signrewardui")
local ClassJadesealUI = require("script/app/ui/mainscene/jadesealmainui")
local ClassJadesealAwardUI = require("script/app/ui/mainscene/jadesealawardui")
local ClassJadesealGetAwardUI = require("script/app/ui/mainscene/jadesealgetawardui")
local ClassTaskAttUI = require("script/app/ui/mainscene/taskattui")
local ClassMilitaryUI = require("script/app/ui/mainscene/militaryui")
local ClassMilitaryGetWayUI = require("script/app/ui/mainscene/militarygetwayui")
local ClassSkillSelectUI = require("script/app/ui/mainscene/skillselectui")
local ClassDragonInfoUI = require("script/app/ui/mainscene/dragoninfo")
local ClassChickenSuitUI = require("script/app/ui/mainscene/chickensuitui")
local ClassInlayDragonGemUI = require("script/app/ui/mainscene/inlaydragongemui")
local ClassOneYuanBuyUI = require("script/app/ui/activity/page_activity_one_yuan_buy")
local ClassThreeYuanBuyUI = require("script/app/ui/activity/page_activity_three_yuan_buy")
local ClassEightYuanBuyUI = require("script/app/ui/activity/page_activity_eight_yuan_buy")
local ClassActivityPromoteGetSoulUI = require("script/app/ui/activity/page_activity_promote_get_soul")
local ClassResGetBackUI = require("script/app/ui/mainscene/resgetback")
local ClassResGetBackCellUI = require("script/app/ui/mainscene/resgetbackcell")
local ClassTaskVTUI = require("script/app/ui/mainscene/taskvt")
local ClassTaskNobilityUI = require("script/app/ui/mainscene/tasknobilityui")
local ClassTaskNobilityUpUI = require("script/app/ui/mainscene/tasknobilityupui")
local ClassCityCraftRemarkUI = require("script/app/ui/mainscene/citycraftremark")
local ClassResGetBackAllUI = require("script/app/ui/mainscene/resgetbackall")
local ClassOpenRankUI = require("script/app/ui/mainscene/openrankui")
local ClassMilitaryEntranceUI = require("script/app/ui/mainscene/militaryentrance")
local ClassNBSkyUI = require("script/app/ui/mainscene/nbsky")
-- 新成长基金
local ClassLvGrowFundUI = require("script/app/ui/mainscene/lvgrowfund")

MainSceneMgr.needCashTab = {
    [11] = tonumber(GlobalApi:getGlobalValue('mysteryShopRefreshCashCost')),
    [12] = tonumber(GlobalApi:getGlobalValue('godShopRefreshCashCost')),
    [13] = 0,
    [21] = tonumber(GlobalApi:getGlobalValue('towerShopRefreshCashCost')),
    [22] = tonumber(GlobalApi:getGlobalValue('towerShopRefreshCashCost')),
    [31] = tonumber(GlobalApi:getGlobalValue('arenaShopRefreshCashCost')),
    [32] = 0,
    [41] = 0,
    [51] = tonumber(GlobalApi:getGlobalValue('legionShopRefreshCashCost')),
    [52] = 0,
    [53] = tonumber(GlobalApi:getGlobalValue('legionWarShopRefreshCashCost')),
    [54] = tonumber(GlobalApi:getGlobalValue('legionTrialShopRefreshCost')),
    [61] = tonumber(GlobalApi:getGlobalValue('countryWarShopRefreshCost')),
    [71] = 0,
    [72] = 0,
}

MainSceneMgr.refreshIntervalTab = {
    [11] = tonumber(GlobalApi:getGlobalValue('mysteryShopRefreshInterval')),
    [12] = tonumber(GlobalApi:getGlobalValue('godShopRefreshInterval')),
    [13] = 24,
    [21] = tonumber(GlobalApi:getGlobalValue('towerShopRefreshInterval')),
    [22] = tonumber(GlobalApi:getGlobalValue('towerShopRefreshInterval')),
    [31] = tonumber(GlobalApi:getGlobalValue('arenaShopRefreshInterval')),
    [32] = tonumber(GlobalApi:getGlobalValue('towerShopRefreshInterval')),
    [41] = tonumber(GlobalApi:getGlobalValue('worldwarShopRefreshInterval')),
    [51] = tonumber(GlobalApi:getGlobalValue('legionShopRefreshInterval')),
    [52] = 999999,
    [53] = 24,
    [54] = 24,
    [61] = 24,
    [71] = -1,
    [72] = -1,
}

MainSceneMgr.openLevelTab = {
    [11] = tonumber(GlobalApi:getGlobalValue('mysteryShopLevelLimit')),
    [12] = tonumber(GlobalApi:getGlobalValue('godShopLevelLimit')),
    [13] = tonumber(GlobalApi:getGlobalValue('marketOpenLevel')),
    [21] = 1,
    [22] = 1,
    [31] = 1,
    [32] = 1,
    [41] = 1,
    [51] = 1,
    [52] = 1,
    [53] = 1,
    [54] = 1,
    [61] = 1,
    [71] = 1,
    [72] = 1,
}

function MainSceneMgr:showNBSkyUI()
	if self.uiClass['NBSkyUI'] == nil then
		self.uiClass['NBSkyUI'] = ClassNBSkyUI.new()
		self.uiClass['NBSkyUI']:showUI()
	end
end

function MainSceneMgr:hideNBSkyUI()
	if self.uiClass['NBSkyUI'] ~= nil then
		self.uiClass['NBSkyUI']:hideUI()
		self.uiClass['NBSkyUI'] = nil
	end
end

function MainSceneMgr:showDragonInfoUI(id,isHide,callback)
	if self.uiClass['dragonInfoUI'] == nil then
		self.uiClass['dragonInfoUI'] = ClassDragonInfoUI.new(id,isHide,callback)
		self.uiClass['dragonInfoUI']:showUI()
	end
end

function MainSceneMgr:hideDragonInfoUI()
	if self.uiClass['dragonInfoUI'] ~= nil then
		self.uiClass['dragonInfoUI']:hideUI()
		self.uiClass['dragonInfoUI'] = nil
	end
end

function MainSceneMgr:setWinPosition(stype,lock)
	if self.uiClass['mainCityUI'] ~= nil then
		self.uiClass['mainCityUI']:setWinPosition(stype,lock)
	end
end

function MainSceneMgr:showMainCity(callback,stype,waitUIIndex)
	UIManager:closeAllUI()
	if self.uiClass['mainCityUI'] == nil then
		self.uiClass['mainCityUI'] = ClassMainCityUI.new(callback,stype,nil,waitUIIndex)
		self.uiClass['mainCityUI']:showUI()
	end
end

function MainSceneMgr:showMainCityFromLogin(callback,stype)
	if self.uiClass['mainCityUI'] == nil then
		self.uiClass['mainCityUI'] = ClassMainCityUI.new(callback,stype,1)
		self.uiClass['mainCityUI']:showUI()
	end
end

function MainSceneMgr:hideMainCity()
	if self.uiClass['mainCityUI'] ~= nil then
		self.uiClass['mainCityUI']:hideUI()
		self.uiClass['mainCityUI'] = nil
	end
end

function MainSceneMgr:getMainCity()
	if self.uiClass['mainCityUI'] ~= nil then
		return self.uiClass['mainCityUI']:getMainCity()
	end
end

function MainSceneMgr:updateSigns()
	if self.uiClass['mainCityUI'] ~= nil then
		self.uiClass['mainCityUI']:updateSigns()
	end
end

function MainSceneMgr:updateGoldMineDiggingSign()
	if self.uiClass['mainCityUI'] ~= nil then
		self.uiClass['mainCityUI']:updateGoldMineDiggingSign()
	end
end

function MainSceneMgr:updateBoatSign()
	if self.uiClass['mainCityUI'] ~= nil then
		self.uiClass['mainCityUI']:updateBoatSign()
	end
end

function MainSceneMgr.updateSigns2()
	if MainSceneMgr.uiClass.mainCityUI ~= nil then
        print('mailmail====================++++++++++++')
		MainSceneMgr.uiClass.mainCityUI:updateSigns()
	end
end

function MainSceneMgr:showTask(page,callback)

	if self.uiClass['taskUI'] == nil then
		local args = {}
		MessageMgr:sendPost('get','task',json.encode(args),function (response)
	        
	        local code = response.code
	        local data = response.data
	        if code == 0 then
			self.uiClass['taskUI'] = ClassTaskUI.new(page,data,callback)
			self.uiClass['taskUI']:showUI(UI_SHOW_TYPE.SCALEIN)
	        end
	    end)
	end
end

function MainSceneMgr:hideTask()
	if self.uiClass['taskUI'] ~= nil then
		self.uiClass['taskUI']:hideUI(UI_HIDE_TYPE.SCALEOUT)
		self.uiClass['taskUI'] = nil
	end
end

function MainSceneMgr:hideTask1()
	if self.uiClass['taskUI'] ~= nil then
		self.uiClass['taskUI']:hideUI()
		self.uiClass['taskUI'] = nil
	end
end

function MainSceneMgr:showSkillSelect(callback,desc,desc1)
	if self.uiClass['skillSelectUI'] == nil then
		self.uiClass['skillSelectUI'] = ClassSkillSelectUI.new(callback,desc,desc1)
		self.uiClass['skillSelectUI']:showUI()
	end
end

function MainSceneMgr:hideSkillSelect()
	if self.uiClass['skillSelectUI'] ~= nil then
		self.uiClass['skillSelectUI']:hideUI()
		self.uiClass['skillSelectUI'] = nil
	end
end

function MainSceneMgr:setCurrPos(currPos)
	if self.uiClass['treasureUI'] then
		self.uiClass['treasureUI']:setCurrPos(currPos)
	end
end

function MainSceneMgr:maekSpineDirty()
	if self.uiClass['treasureUI'] then
		self.uiClass['treasureUI']:maekSpineDirty()
	end
end

function MainSceneMgr:guideEquipDragon(callback)
	if self.uiClass['treasureUI'] then
		self.uiClass['treasureUI']:guideEquipDragon(callback)
	end
end

function MainSceneMgr:showTreasure(page)
	if self.uiClass['treasureUI'] == nil then
		self.uiClass['treasureUI'] = ClassTreasureUI.new(page)
		self.uiClass['treasureUI']:showUI()
	end
end

function MainSceneMgr:hideTreasure()
	if self.uiClass['treasureUI'] ~= nil then
		self.uiClass['treasureUI']:hideUI()
		self.uiClass['treasureUI'] = nil
	end
end

function MainSceneMgr:showTreasureMerge(page)
	if self.uiClass['treasureMergeUI'] == nil then
		self.uiClass['treasureMergeUI'] = ClassTreasureMergeUI.new(page)
		self.uiClass['treasureMergeUI']:showUI()
	end
end

function MainSceneMgr:hideTreasureMerge()
	if self.uiClass['treasureMergeUI'] ~= nil then
		self.uiClass['treasureMergeUI']:hideUI()
		self.uiClass['treasureMergeUI'] = nil
	end
end


function MainSceneMgr:showTaskAtt(ntype,id)
	if self.uiClass['taskAttUI'] == nil then
		self.uiClass['taskAttUI'] = ClassTaskAttUI.new(ntype,id)
		self.uiClass['taskAttUI']:showUI(UI_SHOW_TYPE.SCALEIN)
	end
end

function MainSceneMgr:hideTaskAtt()
	if self.uiClass['taskAttUI'] ~= nil then
		self.uiClass['taskAttUI']:hideUI()
		self.uiClass['taskAttUI'] = nil
	end
end

function MainSceneMgr:showMilitary(page)
	if self.uiClass['militaryUI'] == nil then
		self.uiClass['militaryUI'] = ClassMilitaryUI.new(page)
		self.uiClass['militaryUI']:showUI()
	end
end

function MainSceneMgr:hideMilitary()
	if self.uiClass['militaryUI'] ~= nil then
		self.uiClass['militaryUI']:hideUI()
		self.uiClass['militaryUI'] = nil
	end
end

function MainSceneMgr:showMilitaryGetWay(id)
	if self.uiClass['militaryGetWayUI'] == nil then
		self.uiClass['militaryGetWayUI'] = ClassMilitaryGetWayUI.new(id)
		self.uiClass['militaryGetWayUI']:showUI()
	end
end

function MainSceneMgr:hideMilitaryGetWay()
	if self.uiClass['militaryGetWayUI'] ~= nil then
		self.uiClass['militaryGetWayUI']:hideUI()
		self.uiClass['militaryGetWayUI'] = nil
	end
end

function MainSceneMgr:shopBuy(page,args,callback)
    if page == 51 then
    	page = 52
    end
	local act = {
		[11] = 'shop_buy',
		[12] = 'shop_buy',
		[13] = 'buy',
		[21] = 'shop_buy',
		[22] = 'gem_shop_buy',
		[31] = 'rank_shop_buy',
		[32] = 'shop_buy',
		[41] = 'shop_buy',
		[51] = 'shop_buy',
		[52] = 'buy_dress',
		[53] = 'shop_buy',
		[54] = 'trial_buy',
		[61] = 'shop_buy',
		[71] = 'position_shop_buy',
		[72] = 'salary_shop_buy',
	}
	local mod = {
		[11] = 'equip',
		[12] = 'tavern',
		[13] = 'market',
		[21] = 'tower',
		[22] = 'tower',
		[31] = 'arena',
		[32] = 'arena',
		[41] = 'worldwar',
		[51] = 'legion',
		[52] = 'legion',
		[53] = 'legionwar',
		[54] = 'legion',
		[61] = 'countrywar',
		[71] = 'country',
		[72] = 'country',
	}
    MessageMgr:sendPost(act[page],mod[page],json.encode(args),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsPeopleKingSurface(awards)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            if callback then
				callback()
			end
			promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN)
        end
    end)
end

function MainSceneMgr:getRefreshTimes(page)
	local vip = UserData:getUserObj():getVip()
	local conf = GameData:getConfData('vip')
	local refreshs = {
		[12] = conf[tostring(vip)].godShopRefresh,
	}
	return refreshs[page] or 100000
end

function MainSceneMgr:shopRefresh(page,args,callback,tokenRes)
    if page == 51 then
    	page = 52
    end
	local act = {
		[11] = 'shop_refresh',
		[12] = 'shop_refresh',
		[21] = 'shop_refresh',
		[22] = 'shop_refresh',
		[31] = 'shop_refresh',
		[32] = 'shop_refresh',
		[41] = 'shop_refresh',
		[51] = 'shop_refresh',
		[52] = 'shop_refresh',
		[53] = 'shop_refresh',
		[54] = 'refreshTrialShop',
		[61] = 'shop_refresh',
		[71] = 'shop_refresh',
		[72] = 'shop_refresh',
	}
	local mod = {
		[11] = 'equip',
		[12] = 'tavern',
		[13] = 'market',
		[21] = 'tower',
		[22] = 'tower',
		[31] = 'arena',
		[32] = 'arena',
		[41] = 'worldwar',
		[51] = 'legion',
		[53] = 'legionwar',
		[54] = 'legion',
		[61] = 'countrywar',
		[71] = 'arena',
		[72] = 'arena',
	}
	-- if tokenRes and tokenRes > 0 then
	-- else
		local times = self:getRefreshTimes(page)
		if self.refreshTab[page] >= times then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('REFRESH_LIMIT'), COLOR_TYPE.RED)
			return
		end
	-- end
	MessageMgr:sendPost(act[page],mod[page],json.encode(args),function (response)
		
		local code = response.code
		if code == 0 then
			local data = response.data
			self.refreshTab[page] = data.shop.count or 0
			local costs = data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end
			if callback then
				callback(data)
			end
			promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_REFRESH'), COLOR_TYPE.GREEN)
		end
	end)
end

function MainSceneMgr:shopGet(page,callback)
    if page == 51 then
    	page = 52
    end
	if page == 52 then
		local data = {}
		if callback then
			callback(data,page)
		end
		return
	end
	local act = {
		[11] = 'shop_get',
		[12] = 'shop_get',
		[13] = 'get',
		[21] = 'shop_get',
		[22] = 'gem_shop_get',
		[31] = 'rank_shop_get',
		[32] = 'shop_get',
		[41] = 'shop_get',
		[51] = 'shop_get',
		[53] = 'shop_get',
		[54] = 'trial_shop_get',
		[61] = 'shop_get',
		[71] = 'position_shop_get',
		[72] = 'salary_shop_get',
	}
	local mod = {
		[11] = 'equip',
		[12] = 'tavern',
		[13] = 'market',
		[21] = 'tower',
		[22] = 'tower',
		[31] = 'arena',
		[32] = 'arena',
		[41] = 'worldwar',
		[51] = 'legion',
		[53] = 'legionwar',
		[54] = 'legion',
		[61] = 'countrywar',
		[71] = 'country',
		[72] = 'country',
	}
	local vip = UserData:getUserObj():getVip()
    local needVip = tonumber(GlobalApi:getGlobalValue('blackShopVipLimit'))
    local level = UserData:getUserObj():getLv()
    if self.openLevelTab[page] > level then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
        return
    end
	local args = {}
	MessageMgr:sendPost(act[page],mod[page],json.encode(args),function (response)
		local code = response.code
		if code == 0 then
			local data = response.data
			self.refreshTab[page] = data.shop.count or 0
			if callback then
				callback(data,page)
			end
		end
	end)
end

function MainSceneMgr:showShop(page,maxPage,custom,targetAward,targetNum,targetAwardIds)
	local function openPanel(data)
		self.uiClass['shopUI'] = ClassShopUI.new(page,data.shop,maxPage,custom,targetAward,targetNum,targetAwardIds)
		self.uiClass['shopUI']:showUI()
	end
	if self.uiClass['shopUI'] == nil then
		self:shopGet(page,function(data)
			openPanel(data)
		end)
	end
end

function MainSceneMgr:hideShop()
	if self.uiClass['shopUI'] ~= nil then
		self.uiClass['shopUI']:hideUI()
		self.uiClass['shopUI'] = nil
	end
end

function MainSceneMgr:showMainShop()
	if self.uiClass['mainShopUI'] == nil then
		local args = {}
		MessageMgr:sendPost('shop_get','user',json.encode(args),function (response)
			
			local code = response.code
			if code == 0 then
				local data = response.data
				self.black = data.black
				self.uiClass['mainShopUI'] = ClassMainShopUI.new(data)
				self.uiClass['mainShopUI']:showUI(UI_SHOW_TYPE.STUDIO)
			end
		end)
	end
end

function MainSceneMgr:hideMainShop()
	if self.uiClass['mainShopUI'] ~= nil then
		self.uiClass['mainShopUI']:hideUI()
		self.uiClass['mainShopUI'] = nil
	end
end

function MainSceneMgr:GetLog()
    CustomEventMgr:addEventListener("mail_new",self,MainSceneMgr.ProcessChatMsg)
    CustomEventMgr:addEventListener("legion_kick",self,MainSceneMgr.ProcessLegionKickMsg)
    CustomEventMgr:addEventListener("country_jade_robbed",self,MainSceneMgr.ProcessCountryJadeRobbedMsg)
    CustomEventMgr:addEventListener("country_jade_join",self,MainSceneMgr.ProcessCountryJadeJoinMsg)
end

function MainSceneMgr.ProcessChatMsg()
    UserData:getUserObj():setSocketMailStatus(true)     -- 有可能是金矿或者合璧奖励
    -- 手动刷新一次
    MainSceneMgr.updateSigns2()
end

function MainSceneMgr.ProcessLegionKickMsg()
    UserData:getUserObj().lid = 0
end

function MainSceneMgr.ProcessCountryJadeRobbedMsg()
    UserData:getUserObj():setCountryJadeFinishTime(0)
    UserData:getUserObj():addGlobalTime()
end

function MainSceneMgr.ProcessCountryJadeJoinMsg()
    UserData:getUserObj():setCountryJadeFinishTime(GlobalData:getServerTime() + tonumber(GlobalApi:getGlobalValue('countryJadeNeedTime')))
    UserData:getUserObj():addGlobalTime()
end

function MainSceneMgr:readEmail(mail,callback)
	local args = {
		id = mail.id,
		sys = mail.sys
	}
	MessageMgr:sendPost('read_mail','user',json.encode(args),function (response)
		
		local code = response.code
		if code == 0 then
            local lastLv = UserData:getUserObj():getLv()

			local data = response.data
			local awards = data.awards
			local extAwards = data.ext_awards
			if mail.sys == 1 and not awards then
				UserData:getUserObj():setMailStatus(mail.id)
			elseif not mail.isNew then
				UserData:getUserObj():removeMail(mail.arrId)
			end
			local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			if awards then
				local oldLv = UserData:getUserObj():getArenaLv()
                GlobalApi:parseAwardData(awards)
				local level = UserData:getUserObj():getArenaLv()
				local xp1 = UserData:getUserObj():getArenaXp()
				local xp2 = UserData:getUserObj():getOldArenaXp()
				local showArena 
				print('======================',level , oldLv , extAwards)
				if extAwards then
					GlobalApi:parseAwardData(extAwards)
					if level ~= oldLv then
						showArena = function()
							local award = DisplayData:getDisplayObjs(extAwards)
							ArenaMgr:showArenaAward(2,'x'..award[1]:getNum())
						end
					end
				end
				UserData:getUserObj():setOldArenaXp(xp1)
				UserData:getUserObj():setOldArenaLv(level)
				if callback then
					callback()
				end
                GlobalApi:showAwardsCommon(awards,true,showArena,false)

                local nowLv = UserData:getUserObj():getLv()
                GlobalApi:showKingLvUp(lastLv,nowLv)
			end
		end
	end)
end

function MainSceneMgr:showEmail()
	if self.uiClass['mailUI'] == nil then
		local sys = UserData:getUserObj():getMailSysMax(0)
		local sys1 = UserData:getUserObj():getMailSysMax(1)
		local args = {ids = {sys,sys1}}
		MessageMgr:sendPost('get_mails','user',json.encode(args),function (response)
			local code = response.code
			if code == 0 then
				local data = response.data
                UserData:getUserObj():setSocketMailStatus(false)
				self.uiClass['mailUI'] = ClassMailUI.new(data)
				self.uiClass['mailUI']:showUI()
			end
		end)
	end
end

function MainSceneMgr:hideEmail()
	if self.uiClass['mailUI'] ~= nil then
		self.uiClass['mailUI']:hideUI()
		self.uiClass['mailUI'] = nil
	end
end

function MainSceneMgr:showAltar(id)
	if self.uiClass['altarUI'] == nil then
		self.uiClass['altarUI'] = ClassAltarUI.new(id)
		if not id or id == 1 then
			self.uiClass['altarUI']:showUI(UI_SHOW_TYPE.STUDIO)
		else
			self.uiClass['altarUI']:showUI()
		end
	end
end

function MainSceneMgr:hideAltar()
	if self.uiClass['altarUI'] ~= nil then
		self.uiClass['altarUI']:hideUI()
		self.uiClass['altarUI'] = nil
	end
end

function MainSceneMgr:showSignReward()
	if self.uiClass['signRewardUI'] == nil then
		self.uiClass['signRewardUI'] = ClassSignRewardUI.new()
		self.uiClass['signRewardUI']:showUI()
	end
end

function MainSceneMgr:hideSignReward()
	if self.uiClass['signRewardUI'] ~= nil then
		self.uiClass['signRewardUI']:hideUI()
		self.uiClass['signRewardUI'] = nil
	end
end

function MainSceneMgr:showJadesealUI()
	if self.uiClass['jadesealUI'] == nil then
		self.uiClass['jadesealUI'] = ClassJadesealUI.new()
		self.uiClass['jadesealUI']:showUI()
	end
end

function MainSceneMgr:hideJadesealUI()
	if self.uiClass['jadesealUI'] ~= nil then
		self.uiClass['jadesealUI']:hideUI()
		self.uiClass['jadesealUI'] = nil
	end
end

function MainSceneMgr:showJadesealAwardUI(id,index,canget)
	if self.uiClass['jadesealAwardUI'] == nil then
		self.uiClass['jadesealAwardUI'] = ClassJadesealAwardUI.new(id,index,canget)
		self.uiClass['jadesealAwardUI']:showUI()
	end
end

function MainSceneMgr:hideJadesealAwardUI()
	if self.uiClass['jadesealAwardUI'] ~= nil then
		self.uiClass['jadesealAwardUI']:hideUI()
		self.uiClass['jadesealAwardUI'] = nil
	end
end

function MainSceneMgr:showJadesealGetAwardUI(id,awards)
	if self.uiClass['jadesealGetAwardUI'] == nil then
		self.uiClass['jadesealGetAwardUI'] = ClassJadesealGetAwardUI.new(id,awards)
		self.uiClass['jadesealGetAwardUI']:showUI(UI_SHOW_TYPE.STUDIO)
	end
end

function MainSceneMgr:hideJadesealGetAwardUI()
	if self.uiClass['jadesealGetAwardUI'] ~= nil then
		self.uiClass['jadesealGetAwardUI']:hideUI()
		self.uiClass['jadesealGetAwardUI'] = nil
	end
end

function MainSceneMgr:showChickenSuitUI()
	if self.uiClass['chickenSuitUI'] == nil then
		self.uiClass['chickenSuitUI'] = ClassChickenSuitUI.new()
		self.uiClass['chickenSuitUI']:showUI()
	end
end

function MainSceneMgr:hideChickenSuitUI()
	if self.uiClass['chickenSuitUI'] ~= nil then
		self.uiClass['chickenSuitUI']:hideUI()
		self.uiClass['chickenSuitUI'] = nil
	end
end

function MainSceneMgr:setGetJadesealState(istrue)
	self.getjadesealstate = istrue
end

function MainSceneMgr:getGetJadesealState()
	return self.getjadesealstate
end


function MainSceneMgr:showInlayDragonGemUI(dragonId)
	if self.uiClass['inlayDragonGemUI'] == nil then
		self.uiClass['inlayDragonGemUI'] = ClassInlayDragonGemUI.new(dragonId)
		self.uiClass['inlayDragonGemUI']:showUI()
	end
end

function MainSceneMgr:hideInlayDragonGemUI()
	if self.uiClass['inlayDragonGemUI'] ~= nil then
		self.uiClass['inlayDragonGemUI']:hideUI()
		self.uiClass['inlayDragonGemUI'] = nil
	end
end

function MainSceneMgr:showOneYuanBuyUI()
	if self.uiClass["oneYuanBuyUI"] == nil then
		MessageMgr:sendPost("get_money_buy", "activity", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	            self.uiClass['oneYuanBuyUI'] = ClassOneYuanBuyUI.new(jsonObj.data)
		        self.uiClass['oneYuanBuyUI']:showUI()
	        end
	    end)
	end
end

function MainSceneMgr:hideOneYuanBuyUI()
	if self.uiClass['oneYuanBuyUI'] ~= nil then
		self.uiClass['oneYuanBuyUI']:hideUI()
		self.uiClass['oneYuanBuyUI'] = nil
	end
end

function MainSceneMgr:showThreeYuanBuyUI()
	if self.uiClass["threeYuanBuyUI"] == nil then
		MessageMgr:sendPost("get_money_buy2", "activity", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	            self.uiClass['threeYuanBuyUI'] = ClassThreeYuanBuyUI.new(jsonObj.data)
		        self.uiClass['threeYuanBuyUI']:showUI()
	        end
	    end)
	end
end

function MainSceneMgr:hideThreeYuanBuyUI()
	if self.uiClass['threeYuanBuyUI'] ~= nil then
		self.uiClass['threeYuanBuyUI']:hideUI()
		self.uiClass['threeYuanBuyUI'] = nil
	end
end

function MainSceneMgr:showOpenRankUI(data)
	if self.uiClass["openRankUI"] == nil then
		MessageMgr:sendPost("get_open_rank", "activity", "{}", function (jsonObj)
			local data = jsonObj.data
			if jsonObj.code == 0 then
				self.uiClass['openRankUI'] = ClassOpenRankUI.new(data)
				self.uiClass['openRankUI']:showUI()
			end
		end)
	end
end

function MainSceneMgr:hideOpenRankUI()
	if self.uiClass['openRankUI'] ~= nil then
		self.uiClass['openRankUI']:hideUI()
		self.uiClass['openRankUI'] = nil
	end
end

function MainSceneMgr:showMilitaryEntranceUI()
	if self.uiClass["militaryEntranceUI"] == nil then
        self.uiClass['militaryEntranceUI'] = ClassMilitaryEntranceUI.new()
        self.uiClass['militaryEntranceUI']:showUI()
	end
end

function MainSceneMgr:hideMilitaryEntranceUI()
	if self.uiClass['militaryEntranceUI'] ~= nil then
		self.uiClass['militaryEntranceUI']:hideUI()
		self.uiClass['militaryEntranceUI'] = nil
	end
end

function MainSceneMgr:showResGetBackAllUI(data,callback)
	if self.uiClass["resGetBackAllUI"] == nil then
        self.uiClass['resGetBackAllUI'] = ClassResGetBackAllUI.new(data,callback)
        self.uiClass['resGetBackAllUI']:showUI()
	end
end

function MainSceneMgr:hideResGetBackAllUI()
	if self.uiClass['resGetBackAllUI'] ~= nil then
		self.uiClass['resGetBackAllUI']:hideUI()
		self.uiClass['resGetBackAllUI'] = nil
	end
end

function MainSceneMgr:showEightYuanBuyUI()
	if self.uiClass["eightYuanBuyUI"] == nil then
		MessageMgr:sendPost("get_money_buy3", "activity", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	            self.uiClass['eightYuanBuyUI'] = ClassEightYuanBuyUI.new(jsonObj.data)
		        self.uiClass['eightYuanBuyUI']:showUI()
	        end
	    end)
	end
end

function MainSceneMgr:hideEightYuanBuyUI()
	if self.uiClass['eightYuanBuyUI'] ~= nil then
		self.uiClass['eightYuanBuyUI']:hideUI()
		self.uiClass['eightYuanBuyUI'] = nil
	end
end

function MainSceneMgr:showPromoteGetSoulUI()
	if self.uiClass["promoteGetSoulUI"] == nil then
		MessageMgr:sendPost("get_promote_soul", "activity", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	            self.uiClass['promoteGetSoulUI'] = ClassActivityPromoteGetSoulUI.new(jsonObj.data)
		        self.uiClass['promoteGetSoulUI']:showUI()
	        end
	    end)
	end
end

function MainSceneMgr:hidePromoteGetSoulUI()
	if self.uiClass['promoteGetSoulUI'] ~= nil then
		self.uiClass['promoteGetSoulUI']:hideUI()
		self.uiClass['promoteGetSoulUI'] = nil
	end
end

function MainSceneMgr:showResGetBackUI()
	if self.uiClass["resGetBackUI"] == nil then
		MessageMgr:sendPost("get_resback", "user", "{}", function (jsonObj)
			local data = jsonObj.data
	        if jsonObj.code == 0 then
	            self.uiClass['resGetBackUI'] = ClassResGetBackUI.new(data.resback)
		        self.uiClass['resGetBackUI']:showUI()
			end
	    end)
	end
end

function MainSceneMgr:hideResGetBackUI()
	if self.uiClass['resGetBackUI'] ~= nil then
		self.uiClass['resGetBackUI']:hideUI()
		self.uiClass['resGetBackUI'] = nil
	end
end

-- 新的成长基金
function MainSceneMgr:showLvGrowFundUI()
	if self.uiClass["lvGrowFundUI"] == nil then
		MessageMgr:sendPost("get_lv_grow_fund", "activity", "{}", function (jsonObj)
			local data = jsonObj.data
	        if jsonObj.code == 0 then
	            self.uiClass['lvGrowFundUI'] = ClassLvGrowFundUI.new(data)
		        self.uiClass['lvGrowFundUI']:showUI()
			end			
	    end)
	end
end

function MainSceneMgr:hideLvGrowFundUI()
	if self.uiClass['lvGrowFundUI'] ~= nil then
		self.uiClass['lvGrowFundUI']:hideUI()
		self.uiClass['lvGrowFundUI'] = nil
	end
end	


function MainSceneMgr:showResGetBackCellUI(key,data,callback,isAll,isCash)
	if self.uiClass["resGetBackCellUI"] == nil then
        self.uiClass['resGetBackCellUI'] = ClassResGetBackCellUI.new(key,data,callback,isAll,isCash)
        self.uiClass['resGetBackCellUI']:showUI()
	end
end

function MainSceneMgr:hideResGetBackCellUI()
	if self.uiClass['resGetBackCellUI'] ~= nil then
		self.uiClass['resGetBackCellUI']:hideUI()
		self.uiClass['resGetBackCellUI'] = nil
	end
end

function MainSceneMgr:showTaskNewUI()
	if self.uiClass["tasknewUI"] == nil then
		
        local args = {}
		MessageMgr:sendPost('get','task',json.encode(args),function (response)
	        
	        local code = response.code
	        local data = response.data
	        if code == 0 then
				self.uiClass['tasknewUI'] = ClassTaskVTUI.new(data)
				self.uiClass['tasknewUI']:showUI()

	        end
	    end)
	end
end

function MainSceneMgr:hideTaskNewUI()
	if self.uiClass['tasknewUI'] ~= nil then
		self.uiClass['tasknewUI']:hideUI()
		self.uiClass['tasknewUI'] = nil
	end
end

function MainSceneMgr:getPrivilegeDesc(nobilityId,id,value)
	if not self.uiClass["tasknewUI"] then
		return
	end
	local desc,newDesc = self.uiClass["tasknewUI"]:getPrivilegeDesc(nobilityId,id,value)
	return desc,newDesc
end

function MainSceneMgr:showTaskNobilityUI(nobilityId,nobilityStar)
	
	if self.uiClass["tasknobilityUI"] == nil then
		self.uiClass['tasknobilityUI'] = ClassTaskNobilityUI.new(nobilityId,nobilityStar)
		self.uiClass['tasknobilityUI']:showUI() 
	end
end

function MainSceneMgr:hideTaskNobilityUI()
	if self.uiClass['tasknobilityUI'] ~= nil then
		self.uiClass['tasknobilityUI']:hideUI()
		self.uiClass['tasknobilityUI'] = nil
	end
end

function MainSceneMgr:showTaskNobilityUpUI(callback,nobilityId,nobilityStar)
	
	if self.uiClass["tasknobilityUpUI"] == nil then
		self.uiClass['tasknobilityUpUI'] = ClassTaskNobilityUpUI.new(callback,nobilityId,nobilityStar)
		self.uiClass['tasknobilityUpUI']:showUI() 
	end
end

function MainSceneMgr:hideTaskNobilityUpUI()
	if self.uiClass['tasknobilityUpUI'] ~= nil then
		self.uiClass['tasknobilityUpUI']:hideUI()
		self.uiClass['tasknobilityUpUI'] = nil
	end
end

function MainSceneMgr:showCityCraftRemarkUI()
	
	if self.uiClass["citycraftremarkUI"] == nil then
		self.uiClass['citycraftremarkUI'] = ClassCityCraftRemarkUI.new()
		self.uiClass['citycraftremarkUI']:showUI() 
	end
end

function MainSceneMgr:hideCityCraftRemarkUI()
	if self.uiClass['citycraftremarkUI'] ~= nil then
		self.uiClass['citycraftremarkUI']:hideUI()
		self.uiClass['citycraftremarkUI'] = nil
	end
end