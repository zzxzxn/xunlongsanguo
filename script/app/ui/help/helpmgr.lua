local HelpUI = require("script/app/ui/help/help")

cc.exports.HelpMgr = {
	uiClass = {
		helpUI = nil
	}
}

cc.exports.HELP_SHOW_TYPE = {
    LEGION_WAR = 1,     -- ¾üÍÅÕù°ÔËµÃ÷
    CITY_CRAFT = 2,     -- »Ê³ÇÕù°ÔËµÃ÷
    GUARD = 3,          -- Ñ²ÂßËµÃ÷
    SHIPPER = 4,        -- ÔËïÚËµÃ÷
    PACK_ARMY = 5,      -- ÈºÐÛÕù°ÔËµÃ÷
    ARENAV = 6,         -- ÀÞÌ¨ËµÃ÷
    GOLDMINE = 7,       -- ½ð¿óËµÃ÷
    MINEUI = 8,         -- ÍÚ¿óËµÃ÷
    FUSION = 9,         -- Ìú½³ÆÌËµÃ÷
    TOWER = 10,         -- Ç§²ãËþËµÃ÷   
    COUNTRY_JADE = 11,  -- ºÏèµËµÃ÷
    LEGION_LEVEL_BATTLE = 12,       -- ¾üÍÅÔ¶Õ÷ËµÃ÷
    DRAGON_DIDI = 14,               -- µÎµÎ´òÁúËµÃ÷
    TAVERN_RECRUIT = 15,            -- ÕÐÄ¼»î¶¯ËµÃ÷
    INFINITE_BATTLE_BOSS = 20,   --  无限关卡BOSS
    INFINITE_BATTLE_MAIN = 22,   --   无限关卡
    LEGION_CITY_UPGRADE = 23,   --   城池升级
    TERRITORIALWAR_HELP = 24,   --   领地战
    ROLEPROMOTED = 30,   --   封将
    COUNTRYWAR_HELP = 34,   --   国战
    PEOPLEKING = 35,   --   人皇
    CLOUD_BUY = 39, -- 云购
}

setmetatable(HelpMgr.uiClass, {__mode = "v"})

function HelpMgr:showHelpUI(id)
	if self.uiClass["helpUI"] == nil then
		self.uiClass["helpUI"] = HelpUI.new(id)
		self.uiClass["helpUI"]:showUI()
	end
end

function HelpMgr:hideHelpUI()
	if self.uiClass["helpUI"] then
		self.uiClass["helpUI"]:hideUI()
		self.uiClass["helpUI"] = nil
	end
end

function HelpMgr:getBtn(id)
	local btn = ccui.Button:create("uires/ui/common/btn_help.png", nil, nil)
    btn:setTouchEnabled(true)

    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:showHelpUI(id)
        end
    end)

    return btn
end


