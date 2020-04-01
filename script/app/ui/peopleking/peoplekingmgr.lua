local ClassPeopleKingMainUI = require("script/app/ui/peopleking/peoplekingmainui")
local ClassPeopleKingAweakWeaponUI = require("script/app/ui/peopleking/peoplekingawakeweaponui")
local ClassPeopleKingChangeLookUI = require("script/app/ui/peopleking/peoplekingchangelookui")
local ClassPeopleKingSkillUpUI = require("script/app/ui/peopleking/peoplekingskillup")
local ClassPeopleKingSuitBuffUI = require("script/app/ui/peopleking/peoplekingsuitbuff")
local ClassPeopleKingGetSurfaceUI = require("script/app/ui/peopleking/peoplekinggetsurface")
local ClassPeopleKingDisplayUI = require("script/app/ui/peopleking/peoplekingdisplay")

cc.exports.PeopleKingMgr = {
    uiClass = {
        peopleKingMainUI = nil,
        peopleKingAweakWeaponUI = nil,
        peopleKingChangeLookUI = nil,
        peopleKingSkillUpUI = nil,
        peopleKingSuitBuffUI = nil,
        peopleKingGetSurfaceUI = nil,
        peopleKingDisplayUI = nil,
    }
}

setmetatable(PeopleKingMgr.uiClass, {__mode = "v"})

function PeopleKingMgr:showPeopleKingDsiplayUI(conf,pos)
    if self.uiClass["peopleKingDisplayUI"] == nil then
        self.uiClass["peopleKingDisplayUI"] = ClassPeopleKingDisplayUI.new(conf,pos)
        self.uiClass["peopleKingDisplayUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingDsiplayUI()
    if self.uiClass["peopleKingDisplayUI"] then
        self.uiClass["peopleKingDisplayUI"]:hideUI()
        self.uiClass["peopleKingDisplayUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingMainUI(page)
    if self.uiClass["peopleKingMainUI"] == nil then
        self.uiClass["peopleKingMainUI"] = ClassPeopleKingMainUI.new(page)
        self.uiClass["peopleKingMainUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingMainUI()
    if self.uiClass["peopleKingMainUI"] then
        self.uiClass["peopleKingMainUI"]:hideUI()
        self.uiClass["peopleKingMainUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingAwakeWeaponUI(page)
    if self.uiClass["peopleKingAweakWeaponUI"] == nil then
        self.uiClass["peopleKingAweakWeaponUI"] = ClassPeopleKingAweakWeaponUI.new(page)
        self.uiClass["peopleKingAweakWeaponUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingAwakeWeaponUI()
    if self.uiClass["peopleKingAweakWeaponUI"] then
        self.uiClass["peopleKingAweakWeaponUI"]:hideUI()
        self.uiClass["peopleKingAweakWeaponUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingChangeLookUI(page,callback)
    
    local openStr = page == 1 and "weapon" or "wing"
    local isOpen,isnotIn,cityId,level = GlobalApi:getOpenInfo(openStr)
    if isOpen == false then
        local str = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES1'),level)
        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
        return
    end

    if self.uiClass["peopleKingChangeLookUI"] == nil then
        MessageMgr:sendPost('get_sky_illusion', 'hero', json.encode({}), function (jsonObj)
            local code = jsonObj.code
            local data = jsonObj.data
            if code == 0 then
                self.uiClass["peopleKingChangeLookUI"] = ClassPeopleKingChangeLookUI.new(page,data,callback)
                self.uiClass["peopleKingChangeLookUI"]:showUI()
            end
        end)
    end
end

function PeopleKingMgr:hidePeopleKingChangeLookUI()
    if self.uiClass["peopleKingChangeLookUI"] then
        self.uiClass["peopleKingChangeLookUI"]:hideUI()
        self.uiClass["peopleKingChangeLookUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingSkillUpUI(type,callback)

    local openStr = type == 1 and "weapon" or "wing"
    local isOpen,isnotIn,cityId,level = GlobalApi:getOpenInfo(openStr)
    if isOpen == false then
        local str = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES1'),level)
        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
        return
    end

    if self.uiClass["peopleKingSkillUpUI"] == nil then
        self.uiClass["peopleKingSkillUpUI"] = ClassPeopleKingSkillUpUI.new(type,callback)
        self.uiClass["peopleKingSkillUpUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingSkillUpUI()
    if self.uiClass["peopleKingSkillUpUI"] then
        self.uiClass["peopleKingSkillUpUI"]:hideUI()
        self.uiClass["peopleKingSkillUpUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingSuitBuffUI()
    if self.uiClass["peopleKingSuitBuffUI"] == nil then
        self.uiClass["peopleKingSuitBuffUI"] = ClassPeopleKingSuitBuffUI.new()
        self.uiClass["peopleKingSuitBuffUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingSuitBuffUI()
    if self.uiClass["peopleKingSuitBuffUI"] then
        self.uiClass["peopleKingSuitBuffUI"]:hideUI()
        self.uiClass["peopleKingSuitBuffUI"] = nil
    end
end

function PeopleKingMgr:showPeopleKingGetSurfaceUI(surfaceAward)
    if self.uiClass["peopleKingGetSurfaceUI"] == nil then
        self.uiClass["peopleKingGetSurfaceUI"] = ClassPeopleKingGetSurfaceUI.new(surfaceAward)
        self.uiClass["peopleKingGetSurfaceUI"]:showUI()
    end
end

function PeopleKingMgr:hidePeopleKingGetSurfaceUI()
    if self.uiClass["peopleKingGetSurfaceUI"] then
        self.uiClass["peopleKingGetSurfaceUI"]:hideUI()
        self.uiClass["peopleKingGetSurfaceUI"] = nil
    end
end
