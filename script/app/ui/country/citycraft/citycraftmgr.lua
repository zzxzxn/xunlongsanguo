local ClassCityCraftUI = require("script/app/ui/country/citycraft/citycraftui")
local ClassCityCraftOfficeUI = require("script/app/ui/country/citycraft/citycraftofficeui")
local ClassCityCraftPlayerInfoUI = require("script/app/ui/country/citycraft/citycraftplayerinfoui")
local ClassCityCraftReportUI = require("script/app/ui/country/citycraft/citycraftreportui")


cc.exports.CityCraftMgr = {
    uiClass = {
        CityCraftUI = nil,
        CityCraftOfficeUI = nil,
        CityCraftPlayerInfoUI = nil,
        CityCraftReportUI = nil
    },
    challengeTimes = 0
}

setmetatable(CityCraftMgr.uiClass, {__mode = "v"})

function CityCraftMgr:showCityCraft(flag)
    if self.uiClass["CityCraftUI"] == nil then
        self.uiClass["CityCraftUI"] = ClassCityCraftUI.new(flag)
        self.uiClass["CityCraftUI"]:showUI()
    end
end

function CityCraftMgr:hideCityCraft()
    if self.uiClass["CityCraftUI"] then
        self.uiClass["CityCraftUI"]:hideUI()
        self.uiClass["CityCraftUI"] = nil
    end
end

function CityCraftMgr:showCityCraftOffice(myPosition, index)
    if self.uiClass["CityCraftOfficeUI"] == nil then
        self.uiClass["CityCraftOfficeUI"] = ClassCityCraftOfficeUI.new(myPosition, index)
        self.uiClass["CityCraftOfficeUI"]:showUI()
    end
end

function CityCraftMgr:hideCityCraftOffice()
    if self.uiClass["CityCraftOfficeUI"] then
        self.uiClass["CityCraftOfficeUI"]:hideUI()
        self.uiClass["CityCraftOfficeUI"] = nil
    end
end

function CityCraftMgr:showCityCraftPlayerInfo(posName, roleInfo)
    if self.uiClass["CityCraftPlayerInfoUI"] == nil then
        self.uiClass["CityCraftPlayerInfoUI"] = ClassCityCraftPlayerInfoUI.new(posName, roleInfo)
        self.uiClass["CityCraftPlayerInfoUI"]:showUI()
    end
end

function CityCraftMgr:hideCityCraftPlayerInfo()
    if self.uiClass["CityCraftPlayerInfoUI"] then
        self.uiClass["CityCraftPlayerInfoUI"]:hideUI()
        self.uiClass["CityCraftPlayerInfoUI"] = nil
    end
end

function CityCraftMgr:showCityCraftReport(reports)
    if self.uiClass["CityCraftReportUI"] == nil then
        UserData:getUserObj():setSignByType('country_report',0)
        self.uiClass["CityCraftReportUI"] = ClassCityCraftReportUI.new(reports)
        self.uiClass["CityCraftReportUI"]:showUI()
    end
end

function CityCraftMgr:hideCityCraftReport()
    if self.uiClass["CityCraftReportUI"] then
        self.uiClass["CityCraftReportUI"]:hideUI()
        self.uiClass["CityCraftReportUI"] = nil
    end
end