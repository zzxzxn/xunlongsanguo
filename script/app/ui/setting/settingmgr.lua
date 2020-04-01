local ClassSettingInfoUI = require("script/app/ui/setting/settinginfoui")
local ClassSettingChangeNameUI = require("script/app/ui/setting/settingchangenameui")
local ClassSettingChangeHeadUI = require("script/app/ui/setting/settingchangeheadui")
local ClassSettingExchangeUI = require("script/app/ui/setting/settingexchangeui")
local ClassSettingSystemUI = require("script/app/ui/setting/settingsystemui")
local ClassSettingChangeHeadFrameUI = require("script/app/ui/setting/settingchangeheadframeui")
cc.exports.SettingMgr = {
    uiClass = {
        SettingInfoUI = nil,
        SettingChangeNameUI = nil,
		SettingChangeHeadUI = nil,
		SettingExchangeUI = nil,
		SettingSystemUI = nil,
        SettingChangeHeadFrameUI = nil
    },
    framedata = {}
}

setmetatable(SettingMgr.uiClass, {__mode = "v"})


function SettingMgr:init()
    self:registerSynMsg()
end

function SettingMgr:showSettingInfo()
    if self.uiClass["SettingInfoUI"] == nil then
        self.uiClass["SettingInfoUI"] = ClassSettingInfoUI.new()
        self.uiClass["SettingInfoUI"]:showUI()
    end
end

function SettingMgr:hideSettingInfo()
    if self.uiClass["SettingInfoUI"] ~= nil then
        self.uiClass["SettingInfoUI"]:ActionClose()
        self.uiClass["SettingInfoUI"] = nil
    end
end	

function SettingMgr:showSettingChangeName(ntype)
    if self.uiClass["SettingChangeNameUI"] == nil then
        self.uiClass["SettingChangeNameUI"] = ClassSettingChangeNameUI.new(ntype)
        self.uiClass["SettingChangeNameUI"]:showUI()
    end
end

function SettingMgr:hideSettingChangeName()
    if self.uiClass["SettingChangeNameUI"] ~= nil then
        self.uiClass["SettingChangeNameUI"]:ActionClose()
        self.uiClass["SettingChangeNameUI"] = nil
    end
end


function SettingMgr:showSettingChangeHead()
    if self.uiClass["SettingChangeHeadUI"] == nil then
        self.uiClass["SettingChangeHeadUI"] = ClassSettingChangeHeadUI.new()
        self.uiClass["SettingChangeHeadUI"]:showUI()
    end
end

function SettingMgr:hideSettingChangeHead()
    if self.uiClass["SettingChangeHeadUI"] ~= nil then
        self.uiClass["SettingChangeHeadUI"]:ActionClose()
        self.uiClass["SettingChangeHeadUI"] = nil
    end
end


function SettingMgr:showSettingExchange()
    if self.uiClass["SettingExchangeUI"] == nil then
        self.uiClass["SettingExchangeUI"] = ClassSettingExchangeUI.new()
        self.uiClass["SettingExchangeUI"]:showUI()
    end
end

function SettingMgr:hideSettingExchange()
    if self.uiClass["SettingExchangeUI"] ~= nil then
        self.uiClass["SettingExchangeUI"]:ActionClose()
        self.uiClass["SettingExchangeUI"] = nil
    end
end	

function SettingMgr:showSettingSystem()
    if self.uiClass["SettingSystemUI"] == nil then
        self.uiClass["SettingSystemUI"] = ClassSettingSystemUI.new()
        self.uiClass["SettingSystemUI"]:showUI()
    end
end

function SettingMgr:hideSettingSystem()
    if self.uiClass["SettingSystemUI"] ~= nil then
        self.uiClass["SettingSystemUI"]:ActionClose()
        self.uiClass["SettingSystemUI"] = nil
    end
end	

function SettingMgr:showSettingChangeHeadFrame()
    if self.uiClass["SettingChangeHeadFrameUI"] == nil then
		MessageMgr:sendPost('get_head_frame_status','user',"{}",function (response)
			local code = response.code
			self.framedata = response.data.head_frame_status
            local data = response.data
			if code == 0 then
				self.uiClass["SettingChangeHeadFrameUI"] = ClassSettingChangeHeadFrameUI.new(nil,nil,data)
				self.uiClass["SettingChangeHeadFrameUI"]:showUI()
			end
		end)
	end
end

function SettingMgr:hideSettingChangeHeadFrame()
    if self.uiClass["SettingChangeHeadFrameUI"] ~= nil then
        self.uiClass["SettingChangeHeadFrameUI"]:ActionClose()
        self.uiClass["SettingChangeHeadFrameUI"] = nil
    end
end

--注册消息
function SettingMgr:registerSynMsg()
    CustomEventMgr:addEventListener("user_fight_force_top_change",self,function (msg)
        MessageMgr:sendPost('get_fight_force_top','user',"{}",function(msg)
            print('user_fight_force_top_change-----------------------------')
            UserData:getUserObj():setHeadFrameId(msg.data.headframe)
        end)
    end)

    CustomEventMgr:addEventListener("user_lucky_top_change",self,function (msg) 
        MessageMgr:sendPost('get_lucky_top','user',"{}",function(msg)
            print('user_lucky_top_change-----------------------------')
            UserData:getUserObj():setHeadFrameId(msg.data.headframe)
        end)
    end)

    CustomEventMgr:addEventListener("user_headframe_change",self,function (msg)
        UserData:getUserObj():setHeadFrameId(msg.headframe)
    end)
end

function SettingMgr:removeSynMsg()
    CustomEventMgr:removeEventListener("user_fight_force_top_change",self)

    CustomEventMgr:removeEventListener("user_lucky_top_change",self)

    CustomEventMgr:removeEventListener("user_headframe_change",self)
end
