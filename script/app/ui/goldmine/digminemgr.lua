cc.exports.DigMineMgr = {
    uiClass = {
    	digMineUI = nil,
        digMineEventUI = nil,
        sixSelectOneAwardUI = nil
    },
}

setmetatable(DigMineMgr.uiClass, {__mode = "v"})

function DigMineMgr:showDigMine()
    MessageMgr:sendPost("get", "digging", "{}", function(jsonObj)
        if jsonObj.code == 0 then
            if self.uiClass["digMineUI"] == nil then
                self.uiClass["digMineUI"] = require("script/app/ui/goldmine/digmineui").new(jsonObj.data)
                self.uiClass["digMineUI"]:showUI()
            end
        end
    end)
end

function DigMineMgr:hideDigMine()
	if self.uiClass["digMineUI"] ~= nil then
        self.uiClass["digMineUI"]:hideUI()
        self.uiClass["digMineUI"] = nil
    end
end

function DigMineMgr:showDigMineEvent(eventType, eventObj, callback)
    if self.uiClass["digMineEventUI"] == nil then
        self.uiClass["digMineEventUI"] = require("script/app/ui/goldmine/digmineeventui").new(eventType, eventObj, callback)
        self.uiClass["digMineEventUI"]:showUI()
    end
end

function DigMineMgr:hideDigMineEvent()
    if self.uiClass["digMineEventUI"] ~= nil then
        self.uiClass["digMineEventUI"]:hideUI()
        self.uiClass["digMineEventUI"] = nil
    end
end

function DigMineMgr:showSixSelectOneAward(selectAward, awards)
    if selectAward and selectAward[1] and self.uiClass["sixSelectOneAwardUI"] == nil then
        self.uiClass["sixSelectOneAwardUI"] = require("script/app/ui/goldmine/sixselectoneawardui").new(selectAward, awards)
        self.uiClass["sixSelectOneAwardUI"]:showUI()
    end
end

function DigMineMgr:hideSixSelectOneAward()
    if self.uiClass["sixSelectOneAwardUI"] ~= nil then
        self.uiClass["sixSelectOneAwardUI"]:hideUI()
        self.uiClass["sixSelectOneAwardUI"] = nil
    end
end