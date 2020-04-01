local ClassGetWayUI = require('script/app/ui/getway/getwayui')
local ClassGetWayDropUI = require('script/app/ui/getway/getwaydrop')
local ClassGetWayFragmentUI = require('script/app/ui/getway/getwayfragment')
local ClassGetWayFragmentSpecialUI = require('script/app/ui/getway/getwayfragmentspecial')
local ClassGetWaySpecialUI = require('script/app/ui/getway/getwayspecialui')
local ClassGetWaySpecial2UI = require('script/app/ui/getway/getwayspecial2')

cc.exports.GetWayMgr = {
	uiClass = {
		GetWayUI = nil,
        GetWayDropUI = nil,
        GetWayFragmentUI = nil,
        GetWayFragmentSpecialUI = nil,
		GetWaySpecialUI = nil,
		GetWaySpecial2UI = nil,
	},
	obj = nil,
	getwayarr = {},
}

cc.exports.GETWAYITEM_TYPE = {
	MATERIAL = 1,
	CARD = 2,
	EQUIP = 3,
	FRAGMENT = 4,
	GEM = 5,
	DRESS = 6,
	LIMITMAT = 7
}

setmetatable(GetWayMgr.uiClass, {__mode = "v"})
--[[
************************************
参数obj  要展示的obj(material,role,equip,fragment,gem,dress)
	showgetway 是否展示来源
	num  需要数量
	posobj  属于哪个武将
	lv 装备该小兵装备需要多少等级
	ismerge 是否是合成界面
*************************************
]]
function GetWayMgr:showGetwayUI(obj,showgetway,num,posobj,lv,ismerge,isspecial)
	self.obj = obj
    if self.obj:judgeHasDrop(obj) and showgetway == false then
        self:showGetwayDropUI(obj)
    elseif self.obj.getShowGetWayType and self.obj:getShowGetWayType() == 1 then
        self:showGetWayFragmentUI(obj)
    elseif self.obj.getShowGetWayType and self.obj:getShowGetWayType() == 2 then
        self:showGetWayFragmentSpecialUI(obj)
    elseif self.obj:getObjType() == 'exclusive' and showgetway == false then
    	ExclusiveMgr:showExclusiveTipsUI(self.obj)
	elseif isspecial == true then
		self:showGetWaySpecialUI(obj,showgetway,num,posobj,lv,ismerge)
    else
        if self.uiClass["GetWayUI"] == nil then
		    self.uiClass["GetWayUI"] = ClassGetWayUI.new(obj,showgetway,num,posobj,lv,ismerge)
		    self.uiClass["GetWayUI"]:showUI()
	    end
    end
end

function GetWayMgr:showGetwayUI2(obj,showgetway,num,posobj,lv,ismerge)
	self.obj = obj
    if self.uiClass["GetWayUI"] == nil then
		self.uiClass["GetWayUI"] = ClassGetWayUI.new(obj,showgetway,num,posobj,lv,ismerge)
		self.uiClass["GetWayUI"]:showUI()
	end
end

function GetWayMgr:hideGetwayUI()
	if self.uiClass["GetWayUI"] then
		self.uiClass["GetWayUI"]:hideUI()
		self.uiClass["GetWayUI"] = nil
	end
end

function GetWayMgr:showGetwayDropUI(obj)
	if self.uiClass["GetWayDropUI"] == nil then
		self.uiClass["GetWayDropUI"] = ClassGetWayDropUI.new(obj)
		self.uiClass["GetWayDropUI"]:showUI()
	end
end

function GetWayMgr:hideGetwayDropUI()
	if self.uiClass["GetWayDropUI"] then
		self.uiClass["GetWayDropUI"]:hideUI()
		self.uiClass["GetWayDropUI"] = nil
	end
end

function GetWayMgr:showGetWaySpecial2UI(obj,awards)
	if self.uiClass["GetWaySpecial2UI"] == nil then
		self.uiClass["GetWaySpecial2UI"] = ClassGetWaySpecial2UI.new(obj,awards)
		self.uiClass["GetWaySpecial2UI"]:showUI()
	end
end

function GetWayMgr:hideGetWaySpecial2UI()
	if self.uiClass["GetWaySpecial2UI"] then
		self.uiClass["GetWaySpecial2UI"]:hideUI()
		self.uiClass["GetWaySpecial2UI"] = nil
	end
end

function GetWayMgr:showGetWaySpecialUI(obj,showgetway,num,posobj,lv,ismerge)
	if self.uiClass["GetWaySpecialUI"] == nil then
		self.uiClass["GetWaySpecialUI"] = ClassGetWaySpecialUI.new(obj,showgetway,num,posobj,lv,ismerge)
		self.uiClass["GetWaySpecialUI"]:showUI()
	end
end

function GetWayMgr:hideGetWaySpecialUI()
	if self.uiClass["GetWaySpecialUI"] then
		self.uiClass["GetWaySpecialUI"]:hideUI()
		self.uiClass["GetWaySpecialUI"] = nil
	end
end

function GetWayMgr:showGetWayFragmentUI(obj)
	if self.uiClass["GetWayFragmentUI"] == nil then
		self.uiClass["GetWayFragmentUI"] = ClassGetWayFragmentUI.new(obj)
		self.uiClass["GetWayFragmentUI"]:showUI()
	end
end

function GetWayMgr:hideGetWayFragmentUI()
	if self.uiClass["GetWayFragmentUI"] then
		self.uiClass["GetWayFragmentUI"]:hideUI()
		self.uiClass["GetWayFragmentUI"] = nil
	end
end

function GetWayMgr:showGetWayFragmentSpecialUI(obj)
	if self.uiClass["GetWayFragmentSpecialUI"] == nil then
		self.uiClass["GetWayFragmentSpecialUI"] = ClassGetWayFragmentSpecialUI.new(obj)
		self.uiClass["GetWayFragmentSpecialUI"]:showUI()
	end
end

function GetWayMgr:hideGetWayFragmentSpecialUI()
	if self.uiClass["GetWayFragmentSpecialUI"] then
		self.uiClass["GetWayFragmentSpecialUI"]:hideUI()
		self.uiClass["GetWayFragmentSpecialUI"] = nil
	end
end

--ntype 难度
function GetWayMgr:getMapObj(ntype)
	local rvobj = nil
	local rvobjarr = {}
	local ispass = false
	local maxId = MapData:getCanFighttingIdByPage(ntype)
	local isOpen = false
	if ntype == 1 then
		isOpen = true
	elseif ntype == 2 then
		isOpen = GlobalApi:getOpenInfo('elite')
	elseif ntype == 3 then
		isOpen = GlobalApi:getOpenInfo('combat')
	elseif ntype == 4 then
		isOpen = GlobalApi:getOpenInfo('lord')
	end
	for i=#MapData.data,1,-1 do
		local obj = MapData.data[i]
		local droparr = obj:getDrop(ntype)
		--printall(droparr)
		if droparr then
			for j=1,10 do
				local str = 'award' ..j
				if droparr[str][1] then
					local awards = DisplayData:getDisplayObj(droparr[str][1])
					if awards then
						local objtype = self.obj:getObjType()
						if self.obj:getObjType() == 'card' then
							objtype = 'fragment'
						end
						if awards:getId() == self.obj:getId() and awards:getObjType() == objtype then
							rvobj = obj
							local arr = {}
							arr[1] = obj
							if i <= maxId then
								ispass = true
								--return rvobj,(true and isOpen)
							end
							arr[2] = ispass
							arr[3] = isOpen
							arr[4] = ntype
							table.insert(rvobjarr,arr)
							break
						end
					end
				end
			end
		end
	end
	table.sort( rvobjarr, function(a,b)
		return a[1]:getId() < b[1]:getId()
	end )
	--printall(rvobjarr)
	-- for i=1,#rvobjarr do
	-- 	print(rvobjarr[i][1]:getName())
	-- end
	return rvobjarr--,(ispass and isOpen)
end

function GetWayMgr:getWayArr()
	local conf = nil
	local arr = {}
	local typestr = self.obj:getObjType()
	if typestr =='material' then
		conf = GameData:getConfData('item')
		-- 特殊处理封将材料根据VIP不同显示
		local both = 0
		for i,v in ipairs(conf[self.obj:getId()].getway) do
			if v == 1901 or v == 1902 then
				both = both + 1
			end
		end
		if both == 2 then
			local tab = {}
			local vip = UserData:getUserObj():getVip()
			local needVip = tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict'))
			for i,v in ipairs(conf[self.obj:getId()].getway) do
				if vip < needVip and v == 1902 then
				elseif vip >= needVip and v == 1901 then
				else
					tab[#tab + 1] = v
				end
			end
			conf[self.obj:getId()].getway = tab
		end
	elseif typestr == 'card' then
		conf = GameData:getConfData('hero')
	elseif typestr == 'equip' then
		conf = GameData:getConfData('equip')
	elseif typestr == 'fragment' then
		conf = GameData:getConfData('item')
	elseif typestr == 'gem' then
		conf = GameData:getConfData('gem')
	elseif typestr == 'dress' then
		conf = GameData:getConfData('dress')
	elseif typestr == 'user' then
		conf = GameData:getConfData('user')
	elseif typestr == 'dragon' then
		conf = GameData:getConfData('dragongem')
	elseif typestr == 'headframe' then
		conf = GameData:getConfData('settingheadframe')
	elseif typestr == "limitmat" then
		conf = GameData:getConfData('item')
	elseif typestr == "skyweapon" then
		conf = GameData:getConfData('skychange')[1]
	elseif typestr == "skywing" then
		conf = GameData:getConfData('skychange')[2]
	elseif typestr == "exclusive" then
		conf = GameData:getConfData('exclusive')
	end
	self.getwayarr = conf[self.obj:getId()].getway
	return self.getwayarr
end
--ntype 获取途径类型
function GetWayMgr:getwayCountarr(ntype,index)
	local arr = self.getwayarr
	local arrcount = 0
	local arrmaxcount = 0
	local mapobj = nil	
	local ispass = false
	local objarr = {}
	local recpconf = GameData:getConfData('rescplist')
	local info = UserData:getUserObj():getRescopyinfo()
	local conf = GameData:getConfData('getway')[tonumber(ntype)]
	--if conf.havelimit == "1" then
	if ntype == 101 then
		--print('101aaa')
		local obj = MapData.data[MapData.currProgress]
		arrmaxcount = obj:getLimits(1)
		arrcount = obj:getLimits(1)-obj:getTimes(1)
		ispass = true
	elseif ntype  == 201 then
		objarr = self:getMapObj(2)
		--print('201aaa')
		-- local obj,objispass = self:getMapObj(2)
		-- if obj then
		-- 	--print('aaaa')
		-- 	arrmaxcount = obj:getLimits(2)
		-- 	arrcount = obj:getLimits(2)-obj:getTimes(2)
		-- 	mapobj = obj
		-- 	ispass = objispass
		-- end
	elseif ntype == 301 then
		--print('301aaa')
		arrmaxcount = recpconf[1].limit
		arrcount = recpconf[1].limit-info.gold.count+info.gold.buy
		ispass = GlobalApi:getOpenInfo('goldRescopy')
	elseif ntype == 302 then
		--print('302aaa')
		arrmaxcount = recpconf[2].limit
		arrcount = recpconf[2].limit-info.xp.count+info.xp.buy
		ispass = GlobalApi:getOpenInfo('xpRescopy')
	elseif ntype == 303 then
		--print('303aaa')
		arrmaxcount = recpconf[3].limit
		arrcount = recpconf[3].limit-info.reborn.count+info.reborn.buy
		ispass = GlobalApi:getOpenInfo('rebornRescopy')
	elseif ntype == 304 then
		--print('304aaa')
		arrmaxcount = recpconf[4].limit
		arrcount = recpconf[4].limit-info.destiny.count+info.destiny.buy
		ispass = GlobalApi:getOpenInfo('destinyRescopy')
	elseif ntype == 401 then
		objarr = self:getMapObj(3)
		--print('401aaa')
		-- local obj,objispass = self:getMapObj(3)
		-- if obj then
		-- 	arrmaxcount = obj:getLimits(3)
		-- 	arrcount = obj:getLimits(3)-obj:getTimes(3)
		-- 	mapobj = obj
		-- 	ispass = objispass
		-- end
	elseif ntype == 501 then
		ispass = GlobalApi:getOpenInfo('shop')
	elseif ntype == 502 then
		ispass = GlobalApi:getOpenInfo('shop')
	elseif ntype == 503 then
		ispass = GlobalApi:getOpenInfo('shop')
	elseif ntype == 504 then
		ispass = GlobalApi:getOpenInfo('shop')
	elseif ntype == 505 then
		ispass =  GlobalApi:getOpenInfo('shop')
	elseif ntype == 506 then
		ispass =  (UserData:getUserObj():getLid() > 0) and true or false
	elseif ntype == 508 then
		ispass =  (UserData:getUserObj():getLid() > 0) and true or false
	elseif ntype == 509 then
		ispass =  (UserData:getUserObj():getLid() > 0) and true or false
	elseif ntype == 510 then
		ispass =  (UserData:getUserObj():getLid() > 0) and true or false
	elseif ntype == 511 then
		ispass =  GlobalApi:getOpenInfo('shop')
	elseif ntype == 512 then
		ispass =  GlobalApi:getOpenInfo('shop')
	elseif ntype == 601 then
		ispass =  true
	elseif ntype == 701 then
		local objarr = self:getMapObj(4)
		if #objarr > 0 then
			ispass =  true
		else
			ispass =  false
		end
	elseif ntype == 801 then
		ispass = GlobalApi:getOpenInfo('tower')
	elseif ntype == 901 then
		ispass = GlobalApi:getOpenInfo('patrol')
	elseif ntype == 1001 then
		ispass = GlobalApi:getOpenInfo('goldmine')
	elseif ntype == 1101 then
		ispass = GlobalApi:getOpenInfo('jadeSeal')
	elseif ntype == 1201 then
		ispass = true
	elseif ntype == 1301 then
		ispass = true
	elseif ntype == 1401 then
		ispass = GlobalApi:getOpenInfo('task')
	elseif ntype == 1501 then
		local shipper = UserData:getUserObj():getShipper()
		local num1 = tonumber(GlobalApi:getGlobalValue("shipperDeliveryCount")) - shipper.delivery
		arrmaxcount = GlobalApi:getGlobalValue("shipperDeliveryCount")
		arrcount = num1
		ispass = GlobalApi:getOpenInfo('shipper')
	elseif ntype == 1601 then
		ispass = GlobalApi:getOpenInfo('blacksmith')
	elseif ntype == 1701 then
		ispass = true
	elseif ntype == 1801 then
		ispass = true
    elseif ntype == 1802 then
		ispass = true
	elseif ntype == 1901 then
		ispass = GlobalApi:getOpenInfo('promote')
	elseif ntype == 1902 then
		ispass = GlobalApi:getOpenInfo('promote')
	elseif ntype == 2001 then
		ispass = true
	elseif ntype == 3001 then
		ispass = GlobalApi:getOpenInfo('exclusive')
	elseif ntype == 3002 then
		ispass = GlobalApi:getOpenInfo('exclusive')
	elseif ntype == 3003 then
		ispass = GlobalApi:getOpenInfo('exclusive_check')
	end	
	--end
	return arrcount,arrmaxcount,ispass,objarr
end

function GetWayMgr:goto(ntype,needNum)
	ntype = tostring(ntype)
	if ntype == '101' then
		-- local obj,objispass = self:getMapObj(1)
		-- if objispass then
	 --        GlobalApi:getGotoByModule('expedition',nil,{obj:getId(),1})
		-- end
		local obj = MapData.data[MapData.currProgress]
		GlobalApi:getGotoByModule('expedition',nil,{obj:getId(),1,self.obj})
	elseif ntype  == '201' then
		local obj,objispass = self:getMapObj(2)
		if objispass then
			GlobalApi:getGotoByModule('expedition',nil,{obj:getId(),2,self.obj})
		end
	elseif ntype  == '301' then
		local isopen = GlobalApi:getOpenInfo('goldRescopy')
		if isopen then
			GlobalApi:getGotoByModule('goldRescopy')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '302' then
		local isopen = GlobalApi:getOpenInfo('xpRescopy')
		if isopen then
			GlobalApi:getGotoByModule('xpRescopy')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '303' then
		local isopen = GlobalApi:getOpenInfo('rebornRescopy')
		if isopen then
			GlobalApi:getGotoByModule('rebornRescopy')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '304' then
		local isopen = GlobalApi:getOpenInfo('destinyRescopy')
		if isopen then
			GlobalApi:getGotoByModule('destinyRescopy')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '401' then
		local obj,objispass = self:getMapObj(3)
		if objispass then
	        GlobalApi:getGotoByModule('combat',nil,{obj:getId(),self.obj})
		end
	elseif ntype  == '501' then
		local isopen = GlobalApi:getOpenInfo('shop')
		if isopen then
			MainSceneMgr:showShop(11,{min = 11,max = 13})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '502' then
		local isopen = GlobalApi:getOpenInfo('shop')
		local id = self.obj:getShopId()
		if id and type(id) == 'table' and id[1] == 0 then
			id = self.obj:getId()
		end

		if isopen then
			MainSceneMgr:showShop(13,{min = 11,max = 13},nil,nil,nil,id)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end	
	elseif ntype  == '503' then
		local isopen = GlobalApi:getOpenInfo('shop')
		if isopen then
			MainSceneMgr:showShop(31,{min = 31,max = 32})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '504' then
		local isopen = GlobalApi:getOpenInfo('shop')
		if isopen then
			MainSceneMgr:showShop(22,{min = 21,max = 22})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '505' then
		local isopen = GlobalApi:getOpenInfo('shop')
		if isopen then
			MainSceneMgr:showShop(12,{min = 11,max = 13})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '506' then
		if UserData:getUserObj():getLid() > 0 then
			MainSceneMgr:showShop(54,{min = 51,max = 54})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
	elseif ntype  == '508' then
		if UserData:getUserObj():getLid() > 0 then
			MainSceneMgr:showShop(51,{min = 51,max = 54})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
	elseif ntype  == '509' then
		if UserData:getUserObj():getLid() > 0 then
			MainSceneMgr:showShop(52,{min = 51,max = 54},nil,self.obj,needNum)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
	elseif ntype  == '510' then
		if UserData:getUserObj():getLid() > 0 then
			MainSceneMgr:showShop(53,{min = 51,max = 54})
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
	elseif ntype  == '511' then
		local position = UserData:getUserObj():getPosition()
		local positionConf = GameData:getConfData('position')[position]
		MainSceneMgr:showShop(71,{min = 71,max = 72},positionConf.position)
	elseif ntype  == '512' then
		local position = UserData:getUserObj():getPosition()
		local positionConf = GameData:getConfData('position')[position]
		MainSceneMgr:showShop(72,{min = 71,max = 72},positionConf.position)
	elseif ntype  == '601' then
		GlobalApi:getGotoByModule('tavern')
	elseif ntype  == '701' then
		local objarr = self:getMapObj(4)
		if #objarr > 0 then
			GlobalApi:getGotoByModule('lord',nil,{objarr[1][1]:getId()})
		end 
		-- local obj,objispass = self:getMapObj(4)
		-- if objispass then
		-- 	GlobalApi:getGotoByModule('lord',nil,{obj:getId()})
		-- end
	elseif ntype  == '801' then
		local isopen = GlobalApi:getOpenInfo('tower')
		if isopen then
			TowerMgr:showTowerMain()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '901' then
		local isopen = GlobalApi:getOpenInfo('patrol')
		if isopen then
			GlobalApi:getGotoByModule('patrol')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '1001' then
		local isopen = GlobalApi:getOpenInfo('goldmine')
		if isopen then
			GlobalApi:getGotoByModule('goldmine')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '1101' then
		local isopen = GlobalApi:getOpenInfo('jadeSeal')
		if isopen then
			GlobalApi:getGotoByModule('jadeSeal')
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	elseif ntype  == '1201' then
		MapMgr:showMainScene(2)
	elseif ntype  == '1301' then
		local id = self.obj:getId()
		BagMgr:showDressMerge(id)
	elseif ntype  == '1401' then
		--MainSceneMgr:showTask(1)
		MainSceneMgr:showTaskNewUI()
	elseif ntype  == '1501' then
		ShippersMgr:showShippersMain()
	elseif ntype  == '1601' then
		BagMgr:showFusion()
	elseif ntype  == '1701' then
		ActivityMgr:showActivityPage('privilege')
	elseif ntype  == '1801' then
		if UserData:getUserObj():getLid() > 0 then
			TerritorialWarMgr:shoWarBossListUI()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
    elseif ntype  == '1802' then
		if UserData:getUserObj():getLid() > 0 then
			TerritorialWarMgr:showMapUI()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
		end
	elseif ntype  == '1901' then
		local vip = UserData:getUserObj():getVip()
		local needVip = tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict'))
		if vip < needVip then
			promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('OPEN_AFTER_VIP'),needVip), COLOR_TYPE.RED)
			return
		end
		RoleMgr:showRolePromotedLuckyWheel()
	elseif ntype  == '1902' then
		local vip = UserData:getUserObj():getVip()
		local needVip = tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict'))
		if vip < needVip then
			promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('OPEN_AFTER_VIP'),needVip), COLOR_TYPE.RED)
			return
		end
		RoleMgr:showRolePromotedLuckyWheel()
	elseif ntype  == '2001' then
		local id = self.obj:getId()
		BagMgr:showDestinyMerge(id)
	elseif ntype  == '3001' then
        ExclusiveMgr:showExclusiveMainUI(2,true)
	elseif ntype  == '3002' then
        ExclusiveMgr:showExclusiveMainUI(3,true)
	elseif ntype  == '3003' then
		ExclusiveMgr:showExclusiveCheckMainUI(true)
	end

end