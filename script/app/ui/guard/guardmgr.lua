local ClassGuardMapUI = require("script/app/ui/guard/guardmappanel")
local ClassGuardMainUI = require("script/app/ui/guard/guardmainpanel")
local ClassGuardListUI = require('script/app/ui/guard/guardlistpanel')
local ClassGuardSkillUI = require('script/app/ui/guard/guardskillpanel')
local ClassGuardFriendListUI = require('script/app/ui/guard/guardfriendlistpanel')

cc.exports.GuardMgr = {
	uiClass = {
		guardMapUI = nil,
		guardMainUI = nil,
		guardListUI = nil,
		guardSkillUI = nil,
		guardFriendListUI = nil,
	},
	selectRole = 0,
	allCityData = {},
	enteruid = nil,
}

setmetatable(GuardMgr.uiClass, {__mode = "v"})
--uid 进入领地的UID，如果是自己的领地，则为nil
function GuardMgr:showGuardMap(guardid ,uid)
	if self.uiClass["guardMapUI"] == nil then
		MessageMgr:sendPost("get", "guard", "{}", function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
                UserData:getUserObj().guard.field_sync = jsonObj.data.guard.field
                UserData:getUserObj():addGlobalTime()
	        	self:setAllCityData(jsonObj.data)
	            self.uiClass["guardMapUI"] = ClassGuardMapUI.new(uid)
				self.uiClass["guardMapUI"]:showUI()
				if guardid  then
					GuardMgr:showGuardMain(guardid)
				end
	        end
	    end)
	end
end

function GuardMgr:hideGuardMap()
	if self.uiClass["guardMapUI"] then
		self.uiClass["guardMapUI"]:hideUI()
		self.uiClass["guardMapUI"] = nil
	end
end

function GuardMgr:showGuardMain(id)
	if self.uiClass["guardMainUI"] == nil then
		self.uiClass["guardMainUI"] = ClassGuardMainUI.new(id)
		self.uiClass["guardMainUI"]:showUI()
	end
end

function GuardMgr:updateGuardMain(status)
	if self.uiClass["guardMainUI"] then
		self.uiClass["guardMainUI"]:update(status)
	end
end

function GuardMgr:hideGuardMain()
	if self.uiClass["guardMainUI"] then
		self.uiClass["guardMainUI"]:hideUI()
		self.uiClass["guardMainUI"] = nil
	end
end

function GuardMgr:showGuardList()
	if self.uiClass["guardListUI"] == nil then
		self.uiClass["guardListUI"] = ClassGuardListUI.new()
		self.uiClass["guardListUI"]:showUI()
	end
end

function GuardMgr:hideGuardList()
	if self.uiClass["guardListUI"] then
		self.uiClass["guardListUI"]:hideUI()
		self.uiClass["guardListUI"] = nil
	end
end

function GuardMgr:showGuardFriendList()
	if self.uiClass["LegionActivityShakeUI"] == nil then
		MessageMgr:sendPost('get_member_list','guard',"{}",function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["guardFriendListUI"] = ClassGuardFriendListUI.new(response.data)
				self.uiClass["guardFriendListUI"]:showUI()
			end
		end)
	end
end

function GuardMgr:hideGuardFriendList()
	if self.uiClass["guardFriendListUI"] then
		self.uiClass["guardFriendListUI"]:hideUI()
		self.uiClass["guardFriendListUI"] = nil
	end
end

function GuardMgr:showGuardSkill()
	if self.uiClass["guardSkillUI"] == nil then
		self.uiClass["guardSkillUI"] = ClassGuardSkillUI.new()
		self.uiClass["guardSkillUI"]:showUI()
	end
end

function GuardMgr:hideGuardSkill()
	if self.uiClass["guardSkillUI"] then
		self.uiClass["guardSkillUI"]:hideUI()
		self.uiClass["guardSkillUI"] = nil
	end
end

function GuardMgr:getSelectRoleId()
	return self.selectRole
end

function GuardMgr:setSelectRoleId(id)
	self.selectRole = id
end

function GuardMgr:setCityAccumulate(time)
	self.allCityData.guard.accumulate = (self.allCityData.guard.accumulate or 0) + time
end

function GuardMgr:getAllCityData()
	return self.allCityData
end

function GuardMgr:setAllCityData(data)
	self.allCityData = data

    UserData:getUserObj().guard.free_hour = self.allCityData.guard.free_hour
    local field_sync = UserData:getUserObj().guard.field_sync

    for k,v in pairs(self.allCityData.guard.field) do
        if field_sync[k] then
            field_sync[k].type = v.type or field_sync[k].type or 0
            field_sync[k].status = v.status or field_sync[k].status or 0
            field_sync[k].time = v.time or field_sync[k].time or 0
        else
            field_sync[k] = {}
            field_sync[k].type = v.type
            field_sync[k].status = v.status
            field_sync[k].time = v.time
        end
	end
end

function GuardMgr:setEnterdata(data)
	self.enterdata = data
end

function GuardMgr:getEnterdata()
	return self.enterdata
end

function GuardMgr:addAllCityData(data,id)
	self.allCityData.guard.field[tostring(id)] = data
end

function GuardMgr:wRand(id,seed)
	local tabweighttab,total =  self:ismess(id)
    local  rand = 0
    local offset = 0

    for i=1,#tabweighttab do
	    if seed then
	    	GlobalApi:setRandomSeed(seed)
	    	rand = GlobalApi:random(0, total)
	    end
    	offset = offset + tabweighttab[i]
    	if rand < offset then
    		return i
    	end
    end
    return nil
end

function GuardMgr:ismess(id)
	local weightstab = {}
	local guardconf = GameData:getConfData('guard')[id]
	for i=1,#guardconf do
		if guardconf[i]['weight'] then
			table.insert(weightstab,guardconf[i]['weight'])
		end
	end

	local total = 0
	for i=1,#weightstab do
		total = total + weightstab[i]
	end
	return weightstab ,total
end

function GuardMgr:getFreeTimes()
	local guardfieldconf = GameData:getConfData('guardfield')
	local time = 0
	for i=1,#guardfieldconf do
		for k,v in pairs(self.allCityData.guard.field) do
			if tonumber(k) == i then
				time = time + guardfieldconf[i].free
			end
		end
	end
	if time - self.allCityData.guard.free_hour > 0 then
		return time - self.allCityData.guard.free_hour
	else
		return 0
	end
end

function GuardMgr:getMessIndex(friendnum)
	local index = math.random(1,friendnum)
	return index
end
