cc.exports.BagMgr = {
	uiClass = {
		bagUI = nil,
		sellUI = nil,
		fusionUI = nil,
		autoFusionUI = nil,
		dressMergeUI = nil,
		gemMergeUI = nil,
		gemMergeMailUI = nil,
		upgradeStarUI = nil,
		useUI = nil,
		heroboxUI = nil,
		guideUpgradeGodUI = nil,
        openBoxUI = nil,
        jadeSealAwardNewUI = nil,
		destinyMergeUI = nil
	},
}

setmetatable(BagMgr.uiClass, {__mode = "v"})

local ClassBagUI = require("script/app/ui/bag/bagui")
local ClassSellUI = require("script/app/ui/bag/sellui")
local ClassUseUI = require("script/app/ui/bag/useui")
local ClassFusionUI = require("script/app/ui/bag/fusionui")
local ClassAutoFusionUI = require("script/app/ui/bag/autofusionui")
local ClassDressMergeUI = require("script/app/ui/bag/dressmergeui")
local ClassGemMergeUI = require("script/app/ui/bag/gemmergeui")
local ClassUpgradeStarUI = require("script/app/ui/bag/upgradestarui")
local ClassHeroBoxUI = require("script/app/ui/bag/heroboxui")
local ClassGuideUpgradeGodUI = require("script/app/ui/bag/guideupgradegodui")
local ClassOpenBoxUI = require("script/app/ui/bag/openbox")
local ClassJadeSealAwardNewUI = require("script/app/ui/bag/jadesealawardnew")
local ClassDestinyMergeUI = require("script/app/ui/bag/destinymergeui")
function BagMgr:showHeroBox(id,itemId,maxNum)
	if self.uiClass['heroboxUI'] == nil then
		self.uiClass['heroboxUI'] = ClassHeroBoxUI.new(id,itemId,maxNum)
		self.uiClass['heroboxUI']:showUI()
	end
end

function BagMgr:hideHeroBox()
	if self.uiClass['heroboxUI'] ~= nil then
		self.uiClass['heroboxUI']:hideUI()
		self.uiClass['heroboxUI'] = nil
	end
end

function BagMgr:showJadeSealAwardNewUI(obj)
	if self.uiClass['jadeSealAwardNewUI'] == nil then
		self.uiClass['jadeSealAwardNewUI'] = ClassJadeSealAwardNewUI.new(obj)
		self.uiClass['jadeSealAwardNewUI']:showUI()
	end
end

function BagMgr:hideJadeSealAwardNewUI()
	if self.uiClass['jadeSealAwardNewUI'] ~= nil then
		self.uiClass['jadeSealAwardNewUI']:hideUI()
		self.uiClass['jadeSealAwardNewUI'] = nil
	end
end

function BagMgr:showBag(id)
	if self.uiClass['bagUI'] == nil then
		print(socket.gettime())
		self.uiClass['bagUI'] = ClassBagUI.new(id)
		self.uiClass['bagUI']:showUI()
		print(socket.gettime())
	end
end

function BagMgr:hideBag()
	if self.uiClass['bagUI'] ~= nil then
		self.uiClass['bagUI']:hideUI()
		self.uiClass['bagUI'] = nil
	end
end

function BagMgr:showUse(obj)
	if self.uiClass['useUI'] == nil then
		self.uiClass['useUI'] = ClassUseUI.new(obj)
		self.uiClass['useUI']:showUI()
	end
end

function BagMgr:hideUse()
	if self.uiClass['useUI'] ~= nil then
		self.uiClass['useUI']:hideUI()
		self.uiClass['useUI'] = nil
	end
end

function BagMgr:showSell(obj)
	if self.uiClass['sellUI'] == nil then
		self.uiClass['sellUI'] = ClassSellUI.new(obj)
		self.uiClass['sellUI']:showUI()
	end
end

function BagMgr:hideSell()
	if self.uiClass['sellUI'] ~= nil then
		self.uiClass['sellUI']:hideUI()
		self.uiClass['sellUI'] = nil
	end
end

function BagMgr:showFusion(obj,callback)
	if self.uiClass['fusionUI'] == nil then
		local args = {}
		MessageMgr:sendPost('make_get','equip',json.encode(args),function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass['fusionUI'] = ClassFusionUI.new(obj,data.make,callback)
				self.uiClass['fusionUI']:showUI()
			end
		end)
	end
end

function BagMgr:hideFusion()
	if self.uiClass['fusionUI'] ~= nil then
		self.uiClass['fusionUI']:hideUI()
		self.uiClass['fusionUI'] = nil
	end
end

function BagMgr:showAutoFusion()
	if self.uiClass['autoFusionUI'] == nil then
		self.uiClass['autoFusionUI'] = ClassAutoFusionUI.new(obj)
		self.uiClass['autoFusionUI']:showUI()
	end
end

function BagMgr:hideAutoFusion()
	if self.uiClass['autoFusionUI'] ~= nil then
		self.uiClass['autoFusionUI']:hideUI()
		self.uiClass['autoFusionUI'] = nil
		self:resetSelectMap()
	end
end

function BagMgr:resetSelectMap()
	if self.uiClass['fusionUI'] ~= nil then
		self.uiClass['fusionUI']:resetSelectMap()
	end
end

function BagMgr:showDressMerge(id,isNextLv)
	local currId,nextId
	if isNextLv then
		local conf = GameData:getConfData("dress")[tonumber(id + 10)]
		if not conf then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_LV'), COLOR_TYPE.RED)
			return
		end
		currId = id
		nextId = id + 10
	else
		local conf = GameData:getConfData("dress")[tonumber(id - 10)]
		if not conf then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('DRESS_CANNOT_MERGE'), COLOR_TYPE.RED)
			return
		end	
		currId = id - 10
		nextId = id
	end
	if self.uiClass['dressMergeUI'] == nil then
		self.uiClass['dressMergeUI'] = ClassDressMergeUI.new(currId,nextId)
		self.uiClass['dressMergeUI']:showUI()
	end
end

function BagMgr:hideDressMerge()
	if self.uiClass['dressMergeUI'] ~= nil then
		self.uiClass['dressMergeUI']:hideUI()
		self.uiClass['dressMergeUI'] = nil
	end
end
function BagMgr:showDestinyMerge(id,isfrom)
	local fromId,toId
	local isfrom = isfrom or false
	if isfrom then
		toId = nil
		fromId = id
		local conf = GameData:getConfData("item")[fromId]
		if conf and conf.useable == 2 then
			local displayobj = DisplayData:getDisplayObj(conf.mergeItem[1])
			toId = displayobj:getId()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('ITEM_CANNOT_MERGE'), COLOR_TYPE.RED)
			return
		end
	else
		toId = id
		fromId = nil
		local conf = GameData:getConfData("item")[toId]
		if conf then
			local conftemp = GameData:getConfData("item")
			for k,v in pairs (conftemp) do
				if v.mergeItem[1] and tonumber(v.mergeItem[1]) ~= 0 then
					local displayobj = DisplayData:getDisplayObj(v.mergeItem[1])
					if displayobj:getId() == toId then
						fromId = v.id
						break
					end
				end
			end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('ITEM_CANNOT_MERGE'), COLOR_TYPE.RED)
			return
		end		
	end
	if fromId == nil or toId == nil then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('ITEM_CANNOT_MERGE'), COLOR_TYPE.RED)
		return	
	end
	if self.uiClass['destinyMergeUI'] == nil then
		self.uiClass['destinyMergeUI'] = ClassDestinyMergeUI.new(fromId,toId)
		self.uiClass['destinyMergeUI']:showUI()
	end
end


function BagMgr:hideDestinyMerge()
	if self.uiClass['destinyMergeUI'] ~= nil then
		self.uiClass['destinyMergeUI']:hideUI()
		self.uiClass['destinyMergeUI'] = nil
	end
end


function BagMgr:showGemMerge(gemId,callback)
	if self.uiClass['gemMergeUI'] == nil then
		self.uiClass['gemMergeUI'] = ClassGemMergeUI.new(gemId,callback)
		self.uiClass['gemMergeUI']:showUI()
	end
end

function BagMgr:hideGemMerge()
	if self.uiClass['gemMergeUI'] ~= nil then
		self.uiClass['gemMergeUI']:hideUI()
		self.uiClass['gemMergeUI'] = nil
	end
end

function BagMgr:showUpgradeStar(obj)
	if self.uiClass['upgradeStarUI'] == nil then
		self.uiClass['upgradeStarUI'] = ClassUpgradeStarUI.new(obj)
		self.uiClass['upgradeStarUI']:showUI()
	end
end

function BagMgr:hideUpgradeStar()
	if self.uiClass['upgradeStarUI'] ~= nil then
		self.uiClass['upgradeStarUI']:hideUI()
		self.uiClass['upgradeStarUI'] = nil
	end
end

function BagMgr:showUpgradeGod(ntype)
	if self.uiClass['guideUpgradeGodUI'] == nil then
		self.uiClass['guideUpgradeGodUI'] = ClassGuideUpgradeGodUI.new(ntype)
		self.uiClass['guideUpgradeGodUI']:showUI()
	else
		self.uiClass['guideUpgradeGodUI']:showPl(ntype)
	end
end

function BagMgr:hideUpgradeGod()
	if self.uiClass['guideUpgradeGodUI'] ~= nil then
		self.uiClass['guideUpgradeGodUI']:hideUI()
		self.uiClass['guideUpgradeGodUI'] = nil
	end
end

function BagMgr:showOpenBox(obj)
	if self.uiClass['openBoxUI'] == nil then
		self.uiClass['openBoxUI'] = ClassOpenBoxUI.new(obj)
		self.uiClass['openBoxUI']:showUI()
	end
end

function BagMgr:hideOpenBox()
	if self.uiClass['openBoxUI'] ~= nil then
		self.uiClass['openBoxUI']:hideUI()
		self.uiClass['openBoxUI'] = nil
	end
end

return BagMgr