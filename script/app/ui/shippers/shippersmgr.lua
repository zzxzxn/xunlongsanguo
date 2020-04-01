local ClassShippersMainUI = require("script/app/ui/shippers/shippersmainpanel")
local ClassShippersSelectUI = require("script/app/ui/shippers/shippersselectpanel")
local ClassShippersPlunderUI = require("script/app/ui/shippers/shippersplunderpanel")
local ClassShippersSuccessUI = require("script/app/ui/shippers/shipperssuccesspanel")
local ClassShippersReportUI = require("script/app/ui/shippers/shippersreportpanel")
local ClassShippersExchangeUI = require("script/app/ui/shippers/shippersexchangeui")

cc.exports.ShippersMgr = {
	uiClass = {
		shippersMainUI = nil,
		shippersSelectUI = nil,
		shippersPlunderUI = nil,
		shippersSuccessUI = nil,
		shippersReportUI =nil,
		shippersExchangeUI =nil,
	},
	mainUIData = {},
	successAward = nil,
	successType = 0,
	successName = ''
}

setmetatable(ShippersMgr.uiClass, {__mode = "v"})

function ShippersMgr:showShippersMain()
	if self.uiClass["shippersMainUI"] == nil then
		MessageMgr:sendPost("get", "shipper", "{}", function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
	        	self:setMainUIData(jsonObj.data)
	            self.uiClass["shippersMainUI"] = ClassShippersMainUI.new()
				self.uiClass["shippersMainUI"]:showUI()

				if jsonObj.data.awards and jsonObj.data.finished then
					GlobalApi:parseAwardData(jsonObj.data.awards)
					self:showShippersSuccess(tonumber(jsonObj.data.finished.type), jsonObj.data.awards)
				end

				if self.successAward then
					self:showShippersSuccess(self.successType,self.successAward,2,self.successName)
					self:setSuccessAward(nil, 0)
					self:setSuccessName('')
				end
	        end
	    end)
	end
end

function ShippersMgr:updateShippersMain()
	if self.uiClass["shippersMainUI"] then
		self.uiClass["shippersMainUI"]:update()
	end
end

function ShippersMgr:hideShippersMain()
	if self.uiClass["shippersMainUI"] then
		self.uiClass["shippersMainUI"]:hideUI()
		self.uiClass["shippersMainUI"] = nil
	end
end

function ShippersMgr:showShippersSelect()
	if self.uiClass["shippersSelectUI"] == nil then
		self.uiClass["shippersSelectUI"] = ClassShippersSelectUI.new()
		self.uiClass["shippersSelectUI"]:showUI()
	end
end

function ShippersMgr:hideShippersSelect()
	if self.uiClass["shippersSelectUI"] then
		self.uiClass["shippersSelectUI"]:hideUI()
		self.uiClass["shippersSelectUI"] = nil
	end
end

function ShippersMgr:showShippersPlunder(key)
	if self.uiClass["shippersPlunderUI"] == nil then
		self.uiClass["shippersPlunderUI"] = ClassShippersPlunderUI.new(key)
		self.uiClass["shippersPlunderUI"]:showUI()
	end
end

function ShippersMgr:hideShippersPlunder()
	if self.uiClass["shippersPlunderUI"] then
		self.uiClass["shippersPlunderUI"]:hideUI()
		self.uiClass["shippersPlunderUI"] = nil
	end
end

function ShippersMgr:showShippersSuccess(type, award,ntype,name)
	if self.uiClass["shippersSuccessUI"] == nil then
		self.uiClass["shippersSuccessUI"] = ClassShippersSuccessUI.new(type, award,ntype,name)
		self.uiClass["shippersSuccessUI"]:showUI()
	end
end

function ShippersMgr:hideShippersSuccess()
	if self.uiClass["shippersSuccessUI"] then
		self.uiClass["shippersSuccessUI"]:hideUI()
		self.uiClass["shippersSuccessUI"] = nil
	end
end

function ShippersMgr:showShippersReport(data)
	if self.uiClass["shippersReportUI"] == nil then
		UserData:getUserObj():setSignByType('shipper_report',0)
		self.uiClass["shippersReportUI"] = ClassShippersReportUI.new(data)
		self.uiClass["shippersReportUI"]:showUI()
	end
end

function ShippersMgr:hideShippersReport()
	if self.uiClass["shippersReportUI"] then
		self.uiClass["shippersReportUI"]:hideUI()
		self.uiClass["shippersReportUI"] = nil
	end
end

function ShippersMgr:showShippersExchange(data)
	if self.uiClass["shippersExchangeUI"] == nil then
		self.uiClass["shippersExchangeUI"] = ClassShippersExchangeUI.new(data)
		self.uiClass["shippersExchangeUI"]:showUI()
	end
end

function ShippersMgr:hideShippersExchange()
	if self.uiClass["shippersExchangeUI"] then
		self.uiClass["shippersExchangeUI"]:hideUI()
		self.uiClass["shippersExchangeUI"] = nil
	end
end

function ShippersMgr:exchange(callback,callBack1)
	local args = {}
	MessageMgr:sendPost('exchange','shipper',json.encode(args),function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
			if callback then
				callback(data)
			end
			if callBack1 then
				callBack1()
			end
		end
	end)
end

-- function ShippersMgr:showShippersRobSuccess(name, type, award)
-- 	if self.uiClass["shippersRobSuccessUI"] == nil then
-- 		self.uiClass["shippersRobSuccessUI"] = ClassShippersRobSuccessUI.new(name, type, award)
-- 		self.uiClass["shippersRobSuccessUI"]:showUI()
-- 	end
-- end

-- function ShippersMgr:hideShippersRobSuccess()
-- 	if self.uiClass["shippersRobSuccessUI"] then
-- 		self.uiClass["shippersRobSuccessUI"]:hideUI()
-- 		self.uiClass["shippersRobSuccessUI"] = nil
-- 	end
-- end

function ShippersMgr:setMainUIData(data)
	self.mainUIData = {}
	self.mainUIData.rob = data.shipper.rob or 0
	self.mainUIData.delivery = data.shipper.delivery or 0
	self.mainUIData.type = data.shipper.type or 0
	self.mainUIData.free = data.shipper.free or 0
	self.mainUIData.rob_time = data.shipper.rob_time or 0
	self.mainUIData.exchangenum = data.shipper.exchangenum or 0
	self.mainUIData.shippers = {}
	for k, v in pairs(data.shippers) do	
		local tab = {}
		tab.uid = k
		tab.name = v.un
		tab.fight_force = v.fight_force
		tab.slevel = v.slevel
		tab.type = v.type
		tab.time = v.time
		tab.level = v.level
		tab.rob = v.rob
		tab.extra = v.extra
		tab.legion = v.legion
		--table.insert(self.mainUIData.shippers, tab)
		self.mainUIData.shippers[tonumber(k)] = tab
	end
end

function ShippersMgr:getMainUIData()
	return self.mainUIData
end

function ShippersMgr:addMyData(data)
	local tab = {}
	tab.uid = UserData:getUserObj():getUid()
	tab.name = data.shipper.un
	tab.fight_force = data.shipper.fight_force
	tab.slevel = data.shipper.slevel
	tab.type = data.shipper.type
	tab.time = data.shipper.time
	tab.level = data.shipper.level
	tab.rob = data.shipper.rob
	tab.extra = data.shipper.extra
	tab.legion = data.shipper.legion
	self.mainUIData.shippers[tonumber(tab.uid)] = tab
	--table.insert(self.mainUIData.shippers, tab)
end

function ShippersMgr:setSuccessAward(award, type)
	self.successAward = award
	self.successType = type
end

function ShippersMgr:setSuccessName(name)
	self.successName = name
end

function ShippersMgr:getSuccessData()
	return self.successName, self.successType, self.successAward
end

