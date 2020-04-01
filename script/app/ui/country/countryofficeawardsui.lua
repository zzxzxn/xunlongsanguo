local CountryOfficeAwardsUI = class("CountryOfficeAwardsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CountryOfficeAwardsUI:ctor()
    self.uiIndex = GAME_UI.UI_COUNTRYOFFICEAWARDS
end

function CountryOfficeAwardsUI:init()
    local awardsBgImg = self.root:getChildByName("awards_bg_img")
    local awardsAlphaImg = awardsBgImg:getChildByName("awards_alpha_img")
    local awardsImg = awardsAlphaImg:getChildByName("awards_img")
    self:adaptUI(awardsBgImg, awardsAlphaImg)

    local closeBtn = awardsImg:getChildByName("close_btn")
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        self:hideUI()
    end)

    local titleLabel = awardsImg:getChildByName("title_tx")
    titleLabel:setString(GlobalApi:getLocalStr("POSITION_AWARD_EVERYDAY"))

    local sv = awardsImg:getChildByName("sv")
    sv:setScrollBarEnabled(false)

    for i = 1, 2 do
        local infoLabel = sv:getChildByName("info_tx_" .. i)
        infoLabel:setString(GlobalApi:getLocalStr("COUNTRY_OFFICE_AWARDS_" .. i))
    end

    local conf = GameData:getConfData("position")
    local time1 = socket.gettime()
    for i = 1, 32 do
        local cell = sv:getChildByName("cell_" .. i)
        local officeLabel = cell:getChildByName("office_tx")
        officeLabel:setTextColor(COLOR_QUALITY[conf[i].quality])
        if i == 1 then
            officeLabel:setString(GlobalApi:getLocalStr("COUNTRY_KING_" .. UserData:getUserObj():getCountry()))
        else
            officeLabel:setString(conf[i].title)
        end
        officeLabel:setPositionX(120)
        local displayArr = DisplayData:getDisplayObjs(conf[i].reward)
        for j = 1, 3 do
            if displayArr[j] then
                local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayArr[j], cell)
                itemcell.awardBgImg:setScale(0.7)
                itemcell.awardBgImg:setPosition(cc.p(300 + 70*(j-1), 42))
            end
        end
    end
end

return CountryOfficeAwardsUI
