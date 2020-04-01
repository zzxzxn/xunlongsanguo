local ClassTowerMainUI = require("script/app/ui/tower/towermainui")
local ClassTowerAutoFightUI = require("script/app/ui/tower/towerautofightui")
local CLassTowerAttRewardUI = require("script/app/ui/tower/towerattrewardui")
cc.exports.TowerMgr = {
	uiClass = {
		towerMainUI = nil,
		towerAutoFightUI = nil,
		towerAttRewardUI = nil,
	},
	towerdata = nil,
	towerAction = false,
    towerShowAttReward = false,
}
setmetatable(TowerMgr.uiClass, {__mode = "v"})
function TowerMgr:showTowerMain(stype)
	if self.uiClass['towerMainUI'] == nil then
		MessageMgr:sendPost('get','tower',"{}",function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
                UserData:getUserObj():initTower(response.data)
				self.uiClass['towerMainUI'] = ClassTowerMainUI.new(data,stype)
				self.towerdata = data
				self.uiClass['towerMainUI']:showUI(UI_SHOW_TYPE.STUDIO)
			end
		end)
	end
end

function TowerMgr:hideTowerMain()
	if self.uiClass['towerMainUI'] then
		self.uiClass['towerMainUI']:hideUI()
		self.uiClass['towerMainUI'] = nil
	end
end

function TowerMgr:showTowerAutoFight(floor,cur_room)
	if self.uiClass['towerAutoFightUI'] == nil then
		MessageMgr:sendPost('auto_fight','tower',"{}",function (response)
			local code = response.code
			local awards = response.data.awards
			local spec_awards =response.data.spec_awards
			if spec_awards and awards then
				GlobalApi:parseAwardData(awards,spec_awards)
			elseif awards and not spec_awards then
                GlobalApi:parseAwardData(awards)
            end
            local costs = response.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			if code == 0 then
				self.uiClass['towerAutoFightUI'] = ClassTowerAutoFightUI.new(awards,floor,cur_room)
				self.uiClass['towerAutoFightUI']:showUI()
			end
		end)
	end
end

function TowerMgr:hideTowerAutoFight()
	if self.uiClass['towerAutoFightUI'] then
		self.uiClass['towerAutoFightUI']:hideUI()
		self.uiClass['towerAutoFightUI'] = nil
	end
end

function TowerMgr:showAttReward(awards,refresh_num,data,isFromBtn)
	if self.uiClass['towerAttRewardUI'] == nil then
		self.uiClass['towerAttRewardUI'] = CLassTowerAttRewardUI.new(awards,refresh_num,data,isFromBtn)
		self.uiClass['towerAttRewardUI']:showUI()
	end
end

function TowerMgr:hideAttReward()
	if self.uiClass['towerAttRewardUI'] then
		self.uiClass['towerAttRewardUI']:hideUI()
		self.uiClass['towerAttRewardUI'] = nil
	end
end

function TowerMgr:setTowerAction(value)
	self.towerAction = value
end

function TowerMgr:getTowerAction()
	return self.towerAction
end

function TowerMgr:setTowerShowAttReward(value)
	self.towerShowAttReward = value
end

function TowerMgr:getTowerShowAttReward()
	return self.towerShowAttReward
end

function TowerMgr:getTowerData()
	return self.towerdata
end

function TowerMgr:setTowerData(data)
	self.towerdata = data
end


