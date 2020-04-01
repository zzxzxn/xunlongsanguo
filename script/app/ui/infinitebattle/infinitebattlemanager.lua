cc.exports.InfiniteBattleMgr = {
	uiClass = {
		infiniteBattleMain = nil,
		infiniteBattle = nil,
		infiniteBattleBoss = nil,
		infiniteStarAward = nil,
		infiniteBattleBossLevelUp = nil
	},
	chapters = {},
	nextChapter = false
}

setmetatable(InfiniteBattleMgr.uiClass, {__mode = "v"})

function InfiniteBattleMgr:getStarByChapterId(chapterId)
	local infiniteData = UserData:getUserObj():getInfinite()
	local starNum = 0
	local allNum = 0
	local conf = GameData:getConfData("itmain")[chapterId]
	if chapterId < infiniteData.chapter_id then
		for i,v in ipairs(conf) do
			if v.isBranch == 0 then
				starNum = starNum + 3
			end
		end
		allNum = starNum
	elseif chapterId == infiniteData.chapter_id then
		for i,v in ipairs(conf) do
			if v.isBranch == 0 then
				allNum = allNum + 3
				if i < infiniteData.city_id then
					starNum = starNum + 3
				end
			end
		end
		starNum = starNum + infiniteData.progress
	else
		for i,v in ipairs(conf) do
			if v.isBranch == 0 then
				allNum = allNum + 3
			end
		end
	end
	return starNum,allNum
end

function InfiniteBattleMgr:getAllStarNum()
	local infiniteData = UserData:getUserObj():getInfinite()
	local starNum = 0
	for i=1,infiniteData.chapter_id - 1 do
		local conf = GameData:getConfData("itmain")[i]
		for i,v in ipairs(conf) do
			if v.isBranch == 0 then
				starNum = starNum + 3
			end
		end
	end
	local conf = GameData:getConfData("itmain")[infiniteData.chapter_id]
	for i,v in ipairs(conf) do
		if v.isBranch == 0 and i < infiniteData.city_id then
			starNum = starNum + 3
		end
	end
	starNum = starNum + infiniteData.progress
	return starNum
end

function InfiniteBattleMgr:updateInfiniteData(chapterId, cityId, progress)
	local infiniteData = UserData:getUserObj():getInfinite()
	if infiniteData.chapter_id == chapterId and infiniteData.city_id == cityId and progress < 3 then
		infiniteData.progress = infiniteData.progress + 1
		if infiniteData.progress >= 3 then
			local isUpdateMain = false
			local conf = GameData:getConfData("itmain")[infiniteData.chapter_id]
			local mainId = 0
			for i,v in ipairs(conf) do
				if infiniteData.city_id == v.openCondition and v.isBranch == 0 and not isUpdateMain then
					isUpdateMain = true
					mainId = i
				end
			end
			if isUpdateMain then
				infiniteData.city_id = mainId
				infiniteData.progress = 0
			else
				infiniteData.chapter_id = infiniteData.chapter_id + 1
				infiniteData.city_id = 1
				infiniteData.progress = 0
				if infiniteData.chapter_id <= #GameData:getConfData("itmain") then
					InfiniteBattleMgr.nextChapter = true
				end
			end
		end
	end
end

function InfiniteBattleMgr:updateInfiniteBranchProgress(chapterId, cityId, progress)
	local branchData = self.chapters[chapterId].branch
	local itmainConf = GameData:getConfData("itmain")[chapterId]
	local branchObj = branchData[tostring(itmainConf[cityId].isBranch)]
	if branchObj then -- 当前这条支线已经开启
		local branchCityKey = tostring(cityId)
		if branchObj[branchCityKey] and branchObj[branchCityKey] < 3 then
			branchObj[branchCityKey] = branchObj[branchCityKey] + 1
		end
	end
end

function InfiniteBattleMgr:showInfiniteBattleMain(page, openui)
	-- if self.uiClass["infiniteBattleMain"] == nil then
	-- 	self.uiClass["infiniteBattleMain"] = require("script/app/ui/infinitebattle/infinitebattlemain").new(page)
	-- 	self.uiClass["infiniteBattleMain"]:showUI()
	-- end
	if self.uiClass["infiniteBattleMain"] == nil then
		local args = {
			id = page
		}
		MessageMgr:sendPost('get','unlimited',json.encode(args),function (response)
			local code = response.code
			local data = response.data
			if code == 0 then
				local awardsStatus = data.awardsStatus
				self.chapters[page] = awardsStatus
				-- self.stars = awardsStatus.stars
				-- self.boss = awardsStatus.boss
				-- self.box = awardsStatus.box
				self.uiClass["infiniteBattleMain"] = require("script/app/ui/infinitebattle/infinitebattlemain").new(page, openui)
				self.uiClass["infiniteBattleMain"]:showUI()
			end
		end)
	end
end

function InfiniteBattleMgr:hideInfiniteBattleMain()
	if self.uiClass["infiniteBattleMain"] then
		self.uiClass["infiniteBattleMain"]:hideUI()
		self.uiClass["infiniteBattleMain"] = nil
	end
end

function InfiniteBattleMgr:showInfiniteBattle(chapterId, id, progress)
	if self.uiClass["infiniteBattle"] == nil then
		self.uiClass["infiniteBattle"] = require("script/app/ui/infinitebattle/infinitebattleui").new(chapterId, id, progress)
		self.uiClass["infiniteBattle"]:showUI()
	end
end

function InfiniteBattleMgr:hideInfiniteBattle()
	if self.uiClass["infiniteBattle"] then
		self.uiClass["infiniteBattle"]:hideUI()
		self.uiClass["infiniteBattle"] = nil
	end
end

function InfiniteBattleMgr:showInfiniteBattleBoss(chapterId, showAni)
	if self.uiClass["infiniteBattleBoss"] == nil then
		self.uiClass["infiniteBattleBoss"] = require("script/app/ui/infinitebattle/infinitebattleboss").new(chapterId, showAni)
		self.uiClass["infiniteBattleBoss"]:showUI()
	end
end

function InfiniteBattleMgr:hideInfiniteBattleBoss()
	if self.uiClass["infiniteBattleBoss"] then
		self.uiClass["infiniteBattleBoss"]:hideUI()
		self.uiClass["infiniteBattleBoss"] = nil
	end
end

function InfiniteBattleMgr:showInfiniteStarAward(chapter)
	if self.uiClass["infiniteStarAward"] == nil then
		self.uiClass["infiniteStarAward"] = require("script/app/ui/infinitebattle/infinitestarawardui").new(chapter)
		self.uiClass["infiniteStarAward"]:showUI()
	end
end

function InfiniteBattleMgr:hideInfiniteStarAward()
	if self.uiClass["infiniteStarAward"] then
		self.uiClass["infiniteStarAward"]:hideUI()
		self.uiClass["infiniteStarAward"] = nil
	end
end

function InfiniteBattleMgr:showInfiniteBattleBossLevelUp(canUpgrade, callback)
	if self.uiClass["infiniteBattleBossLevelUp"] == nil then
		self.uiClass["infiniteBattleBossLevelUp"] = require("script/app/ui/infinitebattle/infinitebattlebosslevelup").new(canUpgrade, callback)
		self.uiClass["infiniteBattleBossLevelUp"]:showUI()
	end
end

function InfiniteBattleMgr:hideInfiniteBattleBossLevelUp()
	if self.uiClass["infiniteBattleBossLevelUp"] then
		self.uiClass["infiniteBattleBossLevelUp"]:hideUI()
		self.uiClass["infiniteBattleBossLevelUp"] = nil
	end
end

-- 检查是否有可以领取的宝箱或boss增强道具
function InfiniteBattleMgr:checkBossBoxRedPointStatus(chapterId)
	local infiniteData = UserData:getUserObj():getInfinite()
	local conf = GameData:getConfData("itmapelement")[chapterId]
	local have = false
	for i,v in ipairs(conf) do
	    if v.type == 'box' then
	    	if InfiniteBattleMgr.chapters[chapterId].box[tostring(v.index)] == nil then
	    		local tab = string.split(v.getCondition, '-')
				if tab[1] == 'main' then
					if infiniteData.chapter_id > tonumber(tab[2]) then
						have = true
						break
					elseif infiniteData.chapter_id == tonumber(tab[2]) then
						if infiniteData.city_id > tonumber(tab[3]) then
							have = true
							break
						elseif infiniteData.city_id == tonumber(tab[3]) and infiniteData.progress >= 3 then
							have = true
							break
						end
					end
				elseif tab[1] == 'branch' then
					local branchData = InfiniteBattleMgr.chapters[chapterId].branch
					local itmainConf = GameData:getConfData("itmain")[chapterId]
					local branchObj = branchData[tostring(itmainConf[tonumber(tab[3])].isBranch)]
			    	if branchObj then -- 当前这条支线已经开启
			    		local pointId = next(branchObj)
			    		if pointId then
			    			if tonumber(pointId) > tonumber(tab[3]) then
			    				have = true
								break
			    			elseif tonumber(pointId) == tonumber(tab[3]) and branchObj[pointId] >= 3 then
			    				have = true
								break
			    			end
			    		end
			    	end
				end
	    	end
	    elseif v.type == 'enhance' then
	    	if InfiniteBattleMgr.chapters[chapterId] == nil or InfiniteBattleMgr.chapters[chapterId].boss[tostring(i)] == nil then
				local tab = string.split(v.getCondition, '-')
				if tab[1] == 'main' then
					if infiniteData.chapter_id > tonumber(tab[2]) then
					 	have = true
					 	break
					elseif infiniteData.chapter_id == tonumber(tab[2]) then
						if infiniteData.city_id > tonumber(tab[3]) then
							have = true
							break
						elseif infiniteData.city_id == tonumber(tab[3]) and infiniteData.progress >= 3 then
							have = true
							break
						end
					end
				elseif tab[1] == 'branch' then
					local branchData = InfiniteBattleMgr.chapters[chapterId].branch
					local itmainConf = GameData:getConfData("itmain")[chapterId]
					local branchObj = branchData[tostring(itmainConf[tonumber(tab[3])].isBranch)]
					if branchObj then -- 当前这条支线已经开启
						local pointId = next(branchObj)
						if pointId then
							if tonumber(pointId) > tonumber(tab[3]) then
								have = true
								break
							elseif tonumber(pointId) == tonumber(tab[3]) and branchObj[pointId] >= 3 then
								have = true
								break
							end
						end
					end
				end
	    	end
	    end
	end
	if have then
        if infiniteData.tip and infiniteData.tip.bossBox then
        	local needUpdate = true
            for k, v in ipairs(infiniteData.tip.bossBox) do
                if v == chapterId then
                	needUpdate = false
                    break
                end
            end
            if needUpdate then
            	table.insert(infiniteData.tip.bossBox, chapterId)
            end
        end
	else
        if infiniteData.tip and infiniteData.tip.bossBox then
            for k, v in ipairs(infiniteData.tip.bossBox) do
                if v == chapterId then
                    table.remove(infiniteData.tip.bossBox, k)
                    break
                end
            end
        end
	end
end
