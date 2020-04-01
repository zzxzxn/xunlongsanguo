local ClassGoldmineUI = require("script/app/ui/goldmine/goldmineui")
local ClassGoldmineReportUI = require("script/app/ui/goldmine/goldminereportui")
local ClassMineEntranceUI = require("script/app/ui/goldmine/mineentranceui")
local DragonHelpUI = require("script/app/ui/goldmine/dragonhelpui")


cc.exports.GoldmineMgr = {
    uiClass = {
        goldmineUI = nil,
        goldmineReportUI = nil,
        mineUI = nil,
        mineEntranceUI = nil,
        dragonHelpUI = nil
    },
    report = nil
}

setmetatable(GoldmineMgr.uiClass, {__mode = "v"})

function GoldmineMgr:showDragonHelp()
    if self.uiClass["dragonHelpUI"] == nil then
        self.uiClass["dragonHelpUI"] = DragonHelpUI.new()
        self.uiClass["dragonHelpUI"]:showUI()
    end
end

function GoldmineMgr:hideDragonHelp()
    if self.uiClass["dragonHelpUI"] ~= nil then
        self.uiClass["dragonHelpUI"]:hideUI()
        self.uiClass["dragonHelpUI"] = nil
    end
end

function GoldmineMgr:showGoldmine()
    if self.uiClass["goldmineUI"] == nil then
        MessageMgr:sendPost("get", "mine", "{}", function (jsonObj)
            -- self:praseJson(jsonObj)
            self.uiClass["goldmineUI"] = ClassGoldmineUI.new(jsonObj)
            self.uiClass["goldmineUI"]:showUI()
        end)
    end
end


function GoldmineMgr:hideGoldmine()
    if self.uiClass["goldmineUI"] ~= nil then
        self.uiClass["goldmineUI"]:hideUI()
        self.uiClass["goldmineUI"] = nil
        self.report = nil
    end
end

function GoldmineMgr:showGoldmineReport()
    if self.uiClass["goldmineReportUI"] == nil then
        UserData:getUserObj():setSignByType('mine_report',0)
        self.uiClass["goldmineReportUI"] = ClassGoldmineReportUI.new()
        self.uiClass["goldmineReportUI"]:showUI()
    end
end

function GoldmineMgr:hideGoldmineReport()
    if self.uiClass["goldmineReportUI"] ~= nil then
        self.uiClass["goldmineReportUI"]:hideUI()
        self.uiClass["goldmineReportUI"] = nil
    end
end

function GoldmineMgr:getReport()
    return self.report
end

function GoldmineMgr:setReport(report)
    self.report = report
end

function GoldmineMgr:showMineEntrance()
    if self.uiClass["mineEntranceUI"] == nil then
        self.uiClass["mineEntranceUI"] = ClassMineEntranceUI.new()
        self.uiClass["mineEntranceUI"]:showUI()
    end
end

function GoldmineMgr:hideMineEntrance()
    if self.uiClass["mineEntranceUI"] ~= nil then
        self.uiClass["mineEntranceUI"]:hideUI()
        self.uiClass["mineEntranceUI"] = nil
    end
end