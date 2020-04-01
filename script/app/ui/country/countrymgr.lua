local ClassCountrySelectUI = require("script/app/ui/country/countryselectui")
local ClassCountryMainUI = require("script/app/ui/country/countrymainui")
local ClassCountryOfficeAwardsUI = require("script/app/ui/country/countryofficeawardsui")
local ClassCountryOfficeTipsUI = require("script/app/ui/country/countryofficetipsui")
local ClassCounreyPillarUI = require("script/app/ui/country/counreypillarui")

cc.exports.CountryMgr = {
    uiClass = {
        countrySelectUI = nil,
        countryMainUI = nil,
        counreyPillarUI = nil
    }
}

setmetatable(CountryMgr.uiClass, {__mode = "v"})

function CountryMgr:showCountrySelect(callback)
    if self.uiClass["countrySelectUI"] == nil then
        self.uiClass["countrySelectUI"] = ClassCountrySelectUI.new(callback)
        self.uiClass["countrySelectUI"]:showUI()
    end
end

function CountryMgr:hideCountrySelect()
    if self.uiClass["countrySelectUI"] then
        self.uiClass["countrySelectUI"]:hideUI()
        self.uiClass["countrySelectUI"] = nil
    end
end

function CountryMgr:showCountryMain()
    if UserData:getUserObj():getCountry() == 0 then
        MapMgr:showMainScene(3,nil,function()
            self:showCountrySelect(function()
                MapMgr:showViewPrefecturePanel()
            end)
        end)
    else
        if self.uiClass["countryMainUI"] == nil then
            MessageMgr:sendPost("get", "country", json.encode(obj), function (response)
                if response.code == 0 then
                    UserData:getUserObj():setPosition(response.data.position)
                    self.uiClass["countryMainUI"] = ClassCountryMainUI.new(response.data)
                    self.uiClass["countryMainUI"]:showUI()
                end
            end)
            
        end
    end
end

function CountryMgr:hideCountryMain()
    if self.uiClass["countryMainUI"] then
        self.uiClass["countryMainUI"]:hideUI()
        self.uiClass["countryMainUI"] = nil
    end
end

function CountryMgr:showCountryOfficeAwards()
    local countryOfficeAwardsUI = ClassCountryOfficeAwardsUI.new()
    countryOfficeAwardsUI:showUI()
end

function CountryMgr:showCityCraftOfficeTips(index, fightforce, country)
    local uiObj = ClassCountryOfficeTipsUI.new(index, fightforce, country)
    uiObj:showUI()
end

function CountryMgr:updateCountry()
    if self.uiClass["countryMainUI"] then
        self.uiClass["countryMainUI"]:updateNewSign()
    end
end

function CountryMgr:showLordCountrySalary()
    MessageMgr:sendPost("get_lord_count", "battle", "{}", function (response)
        if response.code == 0 then
            local uiObj = require("script/app/ui/country/lordcountrysalaryui").new(response.data.lord_count)
            uiObj:showUI()
        end
    end)
end

function CountryMgr:showCountryPillar(country, data)
    if self.uiClass["counreyPillarUI"] == nil then
        self.uiClass["counreyPillarUI"] = ClassCounreyPillarUI.new(country, data)
        self.uiClass["counreyPillarUI"]:showUI()
    end
end

function CountryMgr:hideCountryPillar()
    if self.uiClass["counreyPillarUI"] then
        self.uiClass["counreyPillarUI"]:hideUI()
        self.uiClass["counreyPillarUI"] = nil
    end
end
