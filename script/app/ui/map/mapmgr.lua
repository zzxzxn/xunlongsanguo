
local ClassMainSceneUI = require("script/app/ui/map/mapui")
local ClassExpeditionUI = require("script/app/ui/map/expeditionpanel")
local ClassCombatUI = require("script/app/ui/map/combatpanel")
local ClassPatrolUI = require("script/app/ui/map/patrolpanel")
local ClassPrefectureUI = require("script/app/ui/map/prefecturepanel")
local ClassRaidsUI = require("script/app/ui/map/raids")
local ClassPatrolSpeedUI = require("script/app/ui/map/patrolspeed")
local ClassPatrolAwardsUI = require("script/app/ui/map/patrolawards")
local ClassPatrolViewPrefectureUI = require("script/app/ui/map/viewprefectureui")
local ClassShowAwardUI = require("script/app/ui/map/mapaward")
local ClassPowerEndUI = require("script/app/ui/map/powerend")
local ClassTalkUI = require("script/app/ui/map/maptalk")
local ClassModuleopenUI = require("script/app/ui/map/moduleopen")
local ClassGodUI = require("script/app/ui/map/mapgod")
local ClassExpeditionCellUI = require("script/app/ui/map/expeditioncell")
local ClassTributeUI = require("script/app/ui/map/tribute")
local ClassDragonDiDiUI = require("script/app/ui/map/dragondidipanel")

cc.exports.MapMgr = {
	uiClass = {
		MainSceneUI = nil,
		ExpeditionPanelUI = nil,
		CombatPanelUI = nil,
		PatrolPanelUI = nil,
		PrefecturePanelUI = nil,
		RaidsUI = nil,
		PatrolSpeedUI = nil,
		PatrolAwardsUI = nil,
		ViewPrefecturePanelUI = nil,
		ShowAwardUI = nil,
		PowerEndUI = nil,
		TalkUI = nil,
		ModuleopenUI = nil,
		GodUI = nil,
		ExpeditionCellUI = nil,
		TributeUI = nil,
        DragonDiDiUI = nil,
	},
	locatePage = 1,
	mapClose = false,
}

setmetatable(MapMgr.uiClass, {__mode = "v"})

function MapMgr:showTributePanel()
	if self.uiClass['TributeUI'] == nil then
		self.uiClass['TributeUI'] = ClassTributeUI.new()
		self.uiClass['TributeUI']:showUI()
	end
end

function MapMgr:hideTributePanel()
	if self.uiClass['TributeUI'] then
		self.uiClass['TributeUI']:hideUI()
		self.uiClass['TributeUI'] = nil
	end
end

function MapMgr:showExpeditionCellPanel(id)
	if self.uiClass['ExpeditionCellUI'] == nil then
		self.uiClass['ExpeditionCellUI'] = ClassExpeditionCellUI.new(id)
		self.uiClass['ExpeditionCellUI']:showUI()
	end
end

function MapMgr:hideExpeditionCellPanel()
	if self.uiClass['ExpeditionCellUI'] then
		self.uiClass['ExpeditionCellUI']:hideUI()
		self.uiClass['ExpeditionCellUI'] = nil
	end
end

function MapMgr:showLiubeiInfoPanel(showAnimation)
    self:showDragonDiDiPanel(showAnimation)
end

function MapMgr:showDragonDiDiPanel(showAnimation)
    MessageMgr:sendPost('get_drops_dragon','activity',json.encode(args),function (response)       
        local code = response.code
        local data = response.data
        if code == 0 then
            if self.uiClass['DragonDiDiUI'] == nil then
		        self.uiClass['DragonDiDiUI'] = ClassDragonDiDiUI.new(data,showAnimation)
		        self.uiClass['DragonDiDiUI']:showUI()
            end
        end

    end)
end

function MapMgr:hideDragonDiDiPanel()
	if self.uiClass['DragonDiDiUI'] then
		self.uiClass['DragonDiDiUI']:hideUI()
		self.uiClass['DragonDiDiUI'] = nil
        self:refreshRunBar()
	end
end

function MapMgr:refreshRunBar()
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:refreshRunBar()
	end
end

function MapMgr:showModuleopenPanel(id)
	if self.uiClass['ModuleopenUI'] == nil then
		self.uiClass['ModuleopenUI'] = ClassModuleopenUI.new(id)
		self.uiClass['ModuleopenUI']:showUI()
	end
end

function MapMgr:hideModuleopenPanel()
	if self.uiClass['ModuleopenUI'] then
		self.uiClass['ModuleopenUI']:hideUI()
		self.uiClass['ModuleopenUI'] = nil
	end
end

function MapMgr:sendTribute(id,callack)
    local cityData = MapData.data[id]
    local args = {}
    MessageMgr:sendPost('get_tribute','battle',json.encode(args),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
            end
            -- if MapData.data[self.id].conf.moduleOpenId <= 0 or MapData.data[self.id].conf.moduleOpenId > 100 then
            --     MapData.data[self.id]:setBfirst(false)
            -- end
            -- if cityData.conf.guideIndex > 0 then
            --     if callack then
            --     	callack()
            --     end
            --     GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
            -- else
                -- MapData.data[id]:setBfirst(false)
                if callack then
                	callack()
                end
            -- end
        end
    end) 
end

function MapMgr:showAwardPanel()
	if self.uiClass['ShowAwardUI'] == nil then
		local fightedId = MapData:getFightedCityId()
		local cityData = MapData.data[fightedId]
		local awards = cityData:getTribute()
		local equipTab = {}
		local unlockAwards = cityData:getPatrolEquip()
	    for k,v in pairs(unlockAwards) do
	    	equipTab[#equipTab + 1] = v
	    end
		-- print(#awards,#equipTab)
		-- printall(awards)
		local startGuide = function ()
			local cityData = MapData.data[fightedId]
		    MapMgr:sendTribute(fightedId,function()
		        MapData.data[fightedId]:setBfirst(false)
		        MapMgr:hideAwardPanel()
		        if cityData.conf.guideIndex > 0 then
		            print('=================================',cityData.conf.guideIndex)
		            if cityData.conf.guideIndex == 114 then
		                local finishFirstpay = UserData:getUserObj():getMark().first_pay >= 2 and true or false
		                if not finishFirstpay then
		                    GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
		                end
		            else
		                GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
		            end
		        end
		    end)
		end

		if #awards > 0 then
			startGuide()
		elseif #equipTab > 0 then
			if fightedId == 10 then
				startGuide()
			else
				MapData.data[fightedId]:setBfirst(false)
				local id = GameData:getConfData('moduleopen')['elite'].cityId
				if id == fightedId then
					self:updateLocation()
				end
	            if MapData.data[fightedId].conf.guideIndex > 0 then
	                GuideMgr:startCityOpenGuide(MapData.data[fightedId].conf.guideIndex, 1)
	            else
	            	MapMgr:showPatrolPanel(true)
	            end
				MapMgr:sendTribute(fightedId)
			end
		else
			local args = {}
			MessageMgr:sendPost('get_tribute','battle',json.encode(args),function (response)
				
				local code = response.code
				local data = response.data
				if code == 0 then
					MapData.data[MapData:getFightedCityId()]:setBfirst(false)
					local awards = data.awards
					if awards then
						GlobalApi:parseAwardData(awards)
					end
				end
			end)
		end
	end
end

function MapMgr:showTalkPanel(id,callack,ntype)
	if self.uiClass['TalkUI'] == nil then
		self.uiClass['TalkUI'] = ClassTalkUI.new(id,callack,ntype)
		self.uiClass['TalkUI']:showUI()
	end
end

function MapMgr:hideTalkPanel()
	if self.uiClass['TalkUI'] then
		self.uiClass['TalkUI']:hideUI()
		self.uiClass['TalkUI'] = nil
	end
end

function MapMgr:showGodPanel(award,desc,callack)
	if self.uiClass['GodUI'] == nil then
		self.uiClass['GodUI'] = ClassGodUI.new(award,desc,callack)
		self.uiClass['GodUI']:showUI()
	end
end

function MapMgr:hideGodPanel()
	if self.uiClass['GodUI'] then
		self.uiClass['GodUI']:hideUI()
		self.uiClass['GodUI'] = nil
	end
end

function MapMgr:showPowerEndPanel(name,callack,id)
	if self.uiClass['PowerEndUI'] == nil then
		self.uiClass['PowerEndUI'] = ClassPowerEndUI.new(name,callack,id)
		self.uiClass['PowerEndUI']:showUI()
	end
end

function MapMgr:hidePowerEndPanel()
	if self.uiClass['PowerEndUI'] then
		self.uiClass['PowerEndUI']:hideUI()
		self.uiClass['PowerEndUI'] = nil
	end
end

function MapMgr:hideAwardPanel()
	if self.uiClass['ShowAwardUI'] then
		self.uiClass['ShowAwardUI']:hideUI()
		self.uiClass['ShowAwardUI'] = nil
	end
end

function MapMgr:showExpeditionPanel(id,page,obj,needNum)
	if not id then
		id = MapData.currProgress
	end
    local level = UserData:getUserObj():getLv()
    if MapMgr.locatePage == 1 then
        local cityData = MapData.data[id]
        local needLevel = cityData:getLevel()
        if level < needLevel then
            id = MapData:getFightedCityId()
        end
    end
	local fightedId = MapData:getFightedCityId()
	local cityData = MapData.data[id]
	local pformation = cityData:getPformation1()
	if id <= fightedId or MapData.cityProcess >= #pformation or pformation[1] == 0 then
		if self.uiClass['ExpeditionPanelUI'] == nil then
			self.uiClass['ExpeditionPanelUI'] = ClassExpeditionUI.new(id,page,obj,needNum)
			self.uiClass['ExpeditionPanelUI']:showUI()
		end
	else
		MapMgr:showExpeditionCellPanel(id)
	end
end

function MapMgr:hideExpeditionPanel()
	if self.uiClass['ExpeditionPanelUI'] then
		self.uiClass['ExpeditionPanelUI']:hideUI()
		self.uiClass['ExpeditionPanelUI'] = nil
	end
end

function MapMgr:showCombatPanel(id,obj)
	id = id or MapData.currProgress
	if self.uiClass['CombatPanelUI'] == nil then
		self.uiClass['CombatPanelUI'] = ClassCombatUI.new(id,obj)
		self.uiClass['CombatPanelUI']:showUI()
	end
end

function MapMgr:hideCombatPanel()
	if self.uiClass['CombatPanelUI'] then
		self.uiClass['CombatPanelUI']:hideUI()
		self.uiClass['CombatPanelUI'] = nil
	end
end

function MapMgr:setLordBtnVisible(b)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:setLordBtnVisible(b)
	end
end

function MapMgr:setBuoyBtnsVisible()
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:setBuoyBtnsVisible(1)
	end
end

function MapMgr:closeMapOnshow()
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:closeMapOnshow()
	end
end

-- ntype = 1 直接设置坐标 = 2 移动到坐标
function MapMgr:setWinPosition(cityId,ntype,callack)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:setWinPosition(cityId,ntype,nil,callack)
	end
end

function MapMgr:updateCloudBtn()
	if self.uiClass['MainSceneUI'] ~= nil then
		self.uiClass['MainSceneUI']:updateCloudBtn()
	end
end

function MapMgr:updateLocation()
	if self.uiClass['MainSceneUI'] ~= nil then
		self.uiClass['MainSceneUI']:updateLocation()
	end
end

function MapMgr:feilongFlyCallback()
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:feilongFlyCallback()
	end
end

function MapMgr:feilongFly(cityId,callack)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:feilongFly(cityId,callack)
	end
end

function MapMgr:updateRunBar(callback)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:updateRunBar(callback)
	end
end

function MapMgr:showRunBar(callback)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:showRunBar(callback)
	end
end

function MapMgr:getFeilongBoxAwards(callback)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:getFeilongBoxAwards(callback)
	end
end

function MapMgr:showDiDiGet(callback)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:showDiDiGet(callback)
	end
end

function MapMgr:showMainScene(ntype,cityId,callack,scale,isCity,callback)
	if self.uiClass['MainSceneUI'] == nil then
		local function enter(thief,reward)
            UIManager:closeAllUI()
			self.uiClass['MainSceneUI'] = ClassMainSceneUI.new(cityId,callack,scale,isCity,thief,reward)
			self.uiClass['MainSceneUI']:showUI()
			if callback then
				callback()
			end
		end
    	local args = {}
        MessageMgr:sendPost('get','battle',json.encode(args),function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                if data.tips then
				    UserData:getUserObj():setTipsInfo(data.tips)
			    end
                MapData.lordId = data.self
                local thief = data.thief
                self.thief = data.thief
                local reward = data.reward
                local cityTribute = data.city_tribute
                MapData:setCityTribute(cityTribute)
                MapData:setDropDragons(data.drops_dragon)
                if data.passbox == 0 then
                    local fightedId = MapData:getFightedCityId()
                    local conf = GameData:getConfData('feilongfly')[fightedId]
                    if reward == 1 and conf and conf.play ~= 0 then
                        MapMgr:sendTribute(fightedId,function()
                            reward = nil
                            MapData.data[fightedId]:setBfirst(false)
                            enter(thief,reward)
                        end)
                    else
                        enter(thief,reward)
                    end
                else
                    enter(thief,reward)
                end
            end
        end)
	else
		self:setWinPosition(cityId or MapData.currProgress,ntype,callack,scale)
	end
end


function MapMgr:guideZoomMap(callback)
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:guideZoomMap(callback)
	end
end

-- ntype 战斗类型
-- cityId 城池ID
-- ntype1 1 普通 2精英 3切磋
function MapMgr:playBattle(ntype,cityId,ntype1,callack,process)
	local obj = {
		cityId = cityId,
		difficulty = ntype1,
		process = process,
	}
	MapMgr:hideMainScene()
	BattleMgr:playBattle(ntype, obj, callack)
end

-- ntype 战斗类型
-- cityId 城池ID
-- ntype1 4 太守
-- info 对手信息
-- callbcak 回调函数
function MapMgr:playPVPBattle(ntype,cityId,ntype1,info,callack)
	local obj = {
		cityId = cityId,
		difficulty = ntype1,
		info = info
	}
	MapMgr:hideMainScene()
	BattleMgr:playBattle(ntype, obj, callack)
end

function MapMgr:hideMainScene()
	if self.uiClass['MainSceneUI'] then
		self.uiClass['MainSceneUI']:hideUI()
		self.uiClass['MainSceneUI'] = nil
	end
end

function MapMgr:showPatrolPanel(isShow)
    -- local cityData = MapData.data[1]
    -- if cityData then
    --     local star = cityData:getStar(1)
    --     if star <= 0 then
    --     	promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_OPEN_PATROL'), COLOR_TYPE.RED)
    --     	return
    --     end
    -- end
	if self.uiClass['PatrolPanelUI'] == nil then
		self.uiClass['PatrolPanelUI'] = ClassPatrolUI.new(data,isShow)
		self.uiClass['PatrolPanelUI']:showUI()
	end
end

function MapMgr:hidePatrolPanel()
	if self.uiClass['PatrolPanelUI'] then
		self.uiClass['PatrolPanelUI']:hideUI()
		self.uiClass['PatrolPanelUI'] = nil
	end
end

function MapMgr:showViewPrefecturePanelBylist()
    if UserData:getUserObj():getCountry() == 0 then
        CountryMgr:showCountrySelect(function()
        	self:showViewPrefecturePanel()
        end)
    else
        MessageMgr:sendPost('get_lord_list','battle',json.encode({}),function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local owners = data.lord
                MapData:setLordDrop(data.self_lord_drop)
                if data.self then
                    MapData.lordId = tonumber(data.self)
                    self:showPrefecturePanel(tonumber(data.self),owners[tostring(data.self)])
                else
                	UserData:getUserObj():setGuideCityTime(0)
                    self:showViewPrefecturePanel(owners)
                end
            end
        end)
    end
end    

function MapMgr:showPrefecturePanel(id)
	if UserData:getUserObj():getCountry() == 0 then
        CountryMgr:showCountrySelect(function()
        	self:showViewPrefecturePanel()
        end)
    else
    	local fightedId = MapData:getFightedCityId()
		id = id or fightedId
		if self.uiClass['PrefecturePanelUI'] == nil then
			local args = {
				id = id
			}
			MessageMgr:sendPost('lord_get','battle',json.encode(args),function (response)
				local code = response.code
				local data = response.data
				if code == 0 then
					-- local cityData = MapData.data[id]
	                -- cityData:setOwner(data.owner)
	                -- local uid = UserData:getUserObj():getUid()
	                -- if data.owner and data.owner.uid == uid then
	                --     local id = self.id
	                --     MapData.lordId = id
	                -- end
	                if data.self then
	                    MapData.lordId = data.self
	                else
	                    MapData.lordId = nil
	                end
	                MapData:setLordDrop(data.self_lord_drop)
					self.uiClass['PrefecturePanelUI'] = ClassPrefectureUI.new(id,data.owner,data.surplus_time)
					self.uiClass['PrefecturePanelUI']:showUI()
				end
			end)
		end
	end
end

function MapMgr:hidePrefecturePanel()
	if self.uiClass['PrefecturePanelUI'] then
		self.uiClass['PrefecturePanelUI']:hideUI()
		self.uiClass['PrefecturePanelUI'] = nil
	end
end

function MapMgr:showRainsPanel(awards,id,page,times,raidaward,oldNum,needNum,showGet)
	if self.uiClass['RaidsUI'] == nil then
		self.uiClass['RaidsUI'] = ClassRaidsUI.new(awards,id,page,times,raidaward,oldNum,needNum,showGet)
		self.uiClass['RaidsUI']:showUI()
	end
end

function MapMgr:hideRainsPanel()
	if self.uiClass['RaidsUI'] then
		self.uiClass['RaidsUI']:hideUI()
		self.uiClass['RaidsUI'] = nil
	end
end

function MapMgr:showPatrolSpeedPanel(callback)
	if self.uiClass['PatrolSpeedUI'] == nil then
		self.uiClass['PatrolSpeedUI'] = ClassPatrolSpeedUI.new(callback)
		self.uiClass['PatrolSpeedUI']:showUI()
	end
end

function MapMgr:hidePatrolSpeedPanel()
	if self.uiClass['PatrolSpeedUI'] then
		self.uiClass['PatrolSpeedUI']:hideUI()
		self.uiClass['PatrolSpeedUI'] = nil
	end
end

function MapMgr:showPatrolAwardsPanel(awards,time)
	if self.uiClass['PatrolAwardsUI'] == nil then
		self.uiClass['PatrolAwardsUI'] = ClassPatrolAwardsUI.new(awards,time)
		self.uiClass['PatrolAwardsUI']:showUI()
	end
end

function MapMgr:hidePatrolAwardsPanel()
	if self.uiClass['PatrolAwardsUI'] then
		self.uiClass['PatrolAwardsUI']:hideUI()
		self.uiClass['PatrolAwardsUI'] = nil
	end
end
        
function MapMgr:showViewPrefecturePanel(owners)
    if UserData:getUserObj():getCountry() == 0 then
        CountryMgr:showCountrySelect(function()
        	self:showViewPrefecturePanel(owners)
        end)
    else
		if self.uiClass['ViewPrefecturePanelUI'] == nil then
			if not owners then
				local args = {}
				MessageMgr:sendPost('get_lord_list','battle',json.encode(args),function (response)
					local code = response.code
					local data = response.data
					if code == 0 then
						MapData:setLordDrop(data.self_lord_drop)
						self.uiClass['ViewPrefecturePanelUI'] = ClassPatrolViewPrefectureUI.new(data.lord)
						self.uiClass['ViewPrefecturePanelUI']:showUI()
					end
				end)
			else
				self.uiClass['ViewPrefecturePanelUI'] = ClassPatrolViewPrefectureUI.new(owners)
				self.uiClass['ViewPrefecturePanelUI']:showUI()
			end
		end
	end
end

function MapMgr:showViewPrefecturePanelByGuide()
	if self.uiClass['ViewPrefecturePanelUI'] == nil then
		local args = {}
		MessageMgr:sendPost('get_lord_list','battle',json.encode(args),function (response)
			local code = response.code
			local data = response.data
			if code == 0 and data.self == nil then
				MapData:setLordDrop(data.self_lord_drop)
				self.uiClass['ViewPrefecturePanelUI'] = ClassPatrolViewPrefectureUI.new(data.lord)
				self.uiClass['ViewPrefecturePanelUI']:showUI()
				GuideMgr:startCityOpenGuide(18, 1)
			end
		end)
	else
		if MapData.lordId == nil then
			GuideMgr:startCityOpenGuide(18, 1)
		end
	end
end

function MapMgr:hideViewPrefecturePanel()
	if self.uiClass['ViewPrefecturePanelUI'] then
		self.uiClass['ViewPrefecturePanelUI']:hideUI()
		self.uiClass['ViewPrefecturePanelUI'] = nil
	end
end

function MapMgr:hideUIAllPanel()
	if self.uiClass['PatrolAwardsUI'] then
		self.uiClass['PatrolAwardsUI']:hideUI()
		self.uiClass['PatrolAwardsUI'] = nil
	end
	if self.uiClass['ExpeditionPanelUI'] then
		self.uiClass['ExpeditionPanelUI']:hideUI()
		self.uiClass['ExpeditionPanelUI'] = nil
	end
	if self.uiClass['CombatPanelUI'] then
		self.uiClass['CombatPanelUI']:hideUI()
		self.uiClass['CombatPanelUI'] = nil
	end
	if self.uiClass['PatrolPanelUI'] then
		self.uiClass['PatrolPanelUI']:hideUI()
		self.uiClass['PatrolPanelUI'] = nil
	end
	if self.uiClass['PrefecturePanelUI'] then
		self.uiClass['PrefecturePanelUI']:hideUI()
		self.uiClass['PrefecturePanelUI'] = nil
	end
	if self.uiClass['RaidsUI'] then
		self.uiClass['RaidsUI']:hideUI()
		self.uiClass['RaidsUI'] = nil
	end
	if self.uiClass['PatrolSpeedUI'] then
		self.uiClass['PatrolSpeedUI']:hideUI()
		self.uiClass['PatrolSpeedUI'] = nil
	end
	if self.uiClass['ViewPrefecturePanelUI'] then
		self.uiClass['ViewPrefecturePanelUI']:hideUI()
		self.uiClass['ViewPrefecturePanelUI'] = nil
	end
end


--取消大地图界面战斗托管
function MapMgr:cancelBattleTrust()
    if self.uiClass['MainSceneUI'] then
	    GlobalApi:clearScheduler(self.uiClass['MainSceneUI'].trust)

		BattleMgr:setTrust(false)

	    if self.uiClass['MainSceneUI'].root:getChildByName("backImg") then
	        self.uiClass['MainSceneUI'].root:getChildByName("backImg"):removeFromParent()
	    end
	    if self.uiClass['MainSceneUI'].root:getChildByName("lableTrustBGImg") then
	        self.uiClass['MainSceneUI'].root:getChildByName("lableTrustBGImg"):removeFromParent()
	    end

	    UIManager:showSidebar({1,2,4,5,6},{1,2,3},true,true)
	    UIManager:getSidebar():setFrameBtnsVisible(true)
        UIManager:getSidebar():setBottomBtnsVisible(false)
	end
end