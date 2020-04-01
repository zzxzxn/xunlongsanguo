local ClassLegionWishGiveMainPanelUI = require('script/app/ui/legion/legionwish/legionwishgivemainpanel')
local ClassLegionWishGiveGiftPanelUI = require('script/app/ui/legion/legionwish/legionwishgivegiftpanel')
local ClassLegionWishLogPanelUI = require('script/app/ui/legion/legionwish/legionwishlogpanel')
local ClassLegionWishMakeWishPanelUI = require('script/app/ui/legion/legionwish/legionwishmakewishpanel')
local ClassLegionWishWeekAwardPanelUI = require('script/app/ui/legion/legionwish/legionwishweekawardpanel')

cc.exports.LegionWishMgr = {
	uiClass = {
        legionWishGiveMainPanelUI = nil,
        legionWishGiveGiftPanelUI = nil,
        legionWishLogPanelUI = nil,
        legionWishMakeWishPanelUI = nil,
        legionWishWeekAwardPanelUI = nil
	},
    dirty = false
}

setmetatable(LegionWishMgr.uiClass, {__mode = "v"})

function LegionWishMgr:showLegionWishGiveMainPanelUI()
	MessageMgr:sendPost('get_wish_list','legion',"{}",function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
	        if self.uiClass["legionWishGiveMainPanelUI"] == nil then
                self:setLegionWishData(data)
                UserData:getUserObj().tips.legion_wish = 0
                UserData:getUserObj().wish = data.own_wish[tostring(UserData:getUserObj():getUid())]
		        self.uiClass["legionWishGiveMainPanelUI"] = ClassLegionWishGiveMainPanelUI.new()
		        self.uiClass["legionWishGiveMainPanelUI"]:showUI()
	        end
        else
            LegionWishMgr:popWindowErrorCode(code)
		end
	end)
end

function LegionWishMgr:hideLegionWishGiveMainPanelUI()
	if self.uiClass["legionWishGiveMainPanelUI"] then
		self.uiClass["legionWishGiveMainPanelUI"]:hideUI()
		self.uiClass["legionWishGiveMainPanelUI"] = nil
	end
end

function LegionWishMgr:setLegionWishData(data)
    self.data = data
end

function LegionWishMgr:getLegionWishData()
    return self.data
end

function LegionWishMgr:setLegionGiveData(give)
    --self.give = give    -- 已经赠送的次数
    UserData:getUserObj():getLegionInfo().wish.give = give
end

function LegionWishMgr:setLegionOwnData(own)
    --self.own = own      -- 已经许愿的次数
    UserData:getUserObj():getLegionInfo().wish.own = own
end

function LegionWishMgr:getLeigionWishTimes()
    local conf = GameData:getConfData('legion')
    return tonumber(conf['leigionWishTimes'].value)
end

function LegionWishMgr:getLeigionWishGiveTimes()
    local conf = GameData:getConfData('vip')
    return conf[tostring(UserData:getUserObj():getVip())].wishGiveTimes
end

function LegionWishMgr:getGiveNum()
    return UserData:getUserObj():getLegionInfo().wish.give or 0
end

function LegionWishMgr:getOwnNum()
    return UserData:getUserObj():getLegionInfo().wish.own or 0
end

function LegionWishMgr:showLegionWishGiveGiftPanelUI(wishData,callBack)
    if self.uiClass["legionWishGiveGiftPanelUI"] == nil then
		self.uiClass["legionWishGiveGiftPanelUI"] = ClassLegionWishGiveGiftPanelUI.new(wishData,callBack)
		self.uiClass["legionWishGiveGiftPanelUI"]:showUI()
	end
end

function LegionWishMgr:hidLlegionWishGiveGiftPanelUI()
	if self.uiClass["legionWishGiveGiftPanelUI"] then
		self.uiClass["legionWishGiveGiftPanelUI"]:hideUI()
		self.uiClass["legionWishGiveGiftPanelUI"] = nil
	end
end

function LegionWishMgr:showLegionWishLogPanelUI()
    MessageMgr:sendPost('get_wish_log','legion',"{}",function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
	        if self.uiClass["legionWishLogPanelUI"] == nil then
		        self.uiClass["legionWishLogPanelUI"] = ClassLegionWishLogPanelUI.new(data)
		        self.uiClass["legionWishLogPanelUI"]:showUI()
	        end
        else
            LegionWishMgr:popWindowErrorCode(code)
		end
	end)
end

function LegionWishMgr:hideLegionWishLogPanelUI()
	if self.uiClass["legionWishLogPanelUI"] then
		self.uiClass["legionWishLogPanelUI"]:hideUI()
		self.uiClass["legionWishLogPanelUI"] = nil
	end
end

function LegionWishMgr:showLegionWishMakeWishPanelUI()
    if self.uiClass["legionWishMakeWishPanelUI"] == nil then
		self.uiClass["legionWishMakeWishPanelUI"] = ClassLegionWishMakeWishPanelUI.new()
		self.uiClass["legionWishMakeWishPanelUI"]:showUI()
	end
end

function LegionWishMgr:hideLegionWishMakeWishPanelUI()
	if self.uiClass["legionWishMakeWishPanelUI"] then
		self.uiClass["legionWishMakeWishPanelUI"]:hideUI()
		self.uiClass["legionWishMakeWishPanelUI"] = nil
	end
end

function LegionWishMgr:showLegionWishWeekAwardPanelUI()
    MessageMgr:sendPost('get_wish_awards_message','legion',"{}",function (response)
		local code = response.code
		local data = response.data
		if code == 0 then
	        if self.uiClass["legionWishWeekAwardPanelUI"] == nil then
		        self.uiClass["legionWishWeekAwardPanelUI"] = ClassLegionWishWeekAwardPanelUI.new(data)
		        self.uiClass["legionWishWeekAwardPanelUI"]:showUI()
	        end
        else
            LegionWishMgr:popWindowErrorCode(code)
		end
	end)
end

function LegionWishMgr:hideLegionWishWeekAwardPanelUI()
	if self.uiClass["legionWishWeekAwardPanelUI"] then
		self.uiClass["legionWishWeekAwardPanelUI"]:hideUI()
		self.uiClass["legionWishWeekAwardPanelUI"] = nil
	end
end

function LegionWishMgr:getLegionWishGiveTimes()
    local vipConf = GameData:getConfData('vip')
    return vipConf[tostring(UserData:getUserObj():getVip())].wishGiveTimes
end

function LegionWishMgr:getLegionConfDataByQuality(quality)
    local legionWishConf = GameData:getConfData('legionwishconf')
    for i = 1,#legionWishConf do
        if legionWishConf[i].heroQuality == quality then
            return legionWishConf[i]
        end
    end
    return legionWishConf[1]
end

function LegionWishMgr:setDirty(dirty)
    self.dirty = dirty
end

function LegionWishMgr:getDirty()
    return self.dirty
end

function LegionWishMgr:popWindowErrorCode(code)
    if code == 101 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("LEGION_WISH_DESC34"), COLOR_TYPE.RED)
    elseif code == 102 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("LEGION_WISH_DESC35"), COLOR_TYPE.RED)
    elseif code == 103 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("LEGION_WISH_DESC36"), COLOR_TYPE.RED)
    elseif code == 104 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("LEGION_WISH_DESC37"), COLOR_TYPE.RED)
    elseif code == 105 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("LEGION_WISH_DESC38"), COLOR_TYPE.RED)
    end
end
