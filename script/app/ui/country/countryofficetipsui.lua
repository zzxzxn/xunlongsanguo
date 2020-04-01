local CountryOfficeTipsUI = class("CountryOfficeTipsUI", BaseUI)

function CountryOfficeTipsUI:ctor(index, fightforce, country)
    self.uiIndex = GAME_UI.UI_COUNTRYOFFICETIPS
    self.index = index
    self.fightforce = fightforce
    self.country = country
end

function CountryOfficeTipsUI:init()
    local conf = GameData:getConfData("position")[self.index]
    local tipsBgImg = self.root:getChildByName("tips_bg_img")
    local tipsAlphaImg = tipsBgImg:getChildByName("tips_alpha_img")
    self:adaptUI(tipsBgImg, tipsAlphaImg)
    tipsBgImg:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        self:hideUI()
    end)
    local tipsImg = tipsAlphaImg:getChildByName("tips_img")
    local officeLabel = tipsImg:getChildByName("office_tx")
    if self.index == 1 then
        officeLabel:setString("【" .. conf.posName .. "】" .. GlobalApi:getLocalStr("COUNTRY_KING_" .. self.country))
    else
        officeLabel:setString("【" .. conf.posName .. "】" .. conf.title)
    end
    local numLabel = tipsImg:getChildByName("num_tx")
    numLabel:setString(GlobalApi:getLocalStr("POSITION_PEOPLE_NUM") .. "：" .. conf.count)
    local fightforceLabel = tipsImg:getChildByName("fightforce_tx")
    fightforceLabel:setString(GlobalApi:getLocalStr("MIN_FIGHTFORCE") .. "：" .. self.fightforce)
    local awardsLabel = tipsImg:getChildByName("awards_tx")
    awardsLabel:setString(GlobalApi:getLocalStr("POSITION_AWARD") .. "：")

    local displayArr = DisplayData:getDisplayObjs(conf.reward)
    for i = 1, 3 do
        local item = tipsImg:getChildByName("item_" .. i)
        if displayArr[i] then
            local icon = item:getChildByName("icon")
            icon:setTexture(displayArr[i]:getIcon())
            local label = item:getChildByName("tx")
            label:setString(tostring(displayArr[i]:getNum()))
        else
            item:setVisible(false)
        end
    end
end

return CountryOfficeTipsUI