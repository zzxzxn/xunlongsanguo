local CountryJadeChooseCountryUI = class("CountryJadeChooseCountryUI", BaseUI)

function CountryJadeChooseCountryUI:ctor(countryIds)
    self.uiIndex = GAME_UI.UI_COUNTRY_JADE_CHOOSECOUNTRY
    self.countryIds = countryIds
    self:initData()
end

function CountryJadeChooseCountryUI:initData()
    self.countryDatas = {
	    [1] = { ["light_img"] = 'uires/ui/country/country_flag_1_1.png', ["country_img"] = 'uires/ui/country/country_flag_1.png',["name"] = GlobalApi:getLocalStr('COUNTRY_JADE_DES13')},
	    [2] = { ["light_img"] = 'uires/ui/country/country_flag_2_2.png', ["country_img"] = 'uires/ui/country/country_flag_2.png',["name"] = GlobalApi:getLocalStr('COUNTRY_JADE_DES14')},
	    [3] = { ["light_img"] = 'uires/ui/country/country_flag_3_3.png', ["country_img"] = 'uires/ui/country/country_flag_3.png',["name"] = GlobalApi:getLocalStr('COUNTRY_JADE_DES15')},
    }
end

-- 初始化
function CountryJadeChooseCountryUI:init()
    local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName("bg")
    self:adaptUI(bgimg, bg)

    local closebtn = bg:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            CountryJadeMgr:hideCountryJadeChooseCountryUI()
        end
    end)

    for i = 1,2 do
        local country = bg:getChildByName("country" .. i)
        local lightImg = country:getChildByName("light_img")
        local countryImg = country:getChildByName("country_img")
        local tx = country:getChildByName("tx")

        local id = self.countryIds[i]

        lightImg:loadTexture(self.countryDatas[id]['light_img'])
        countryImg:loadTexture(self.countryDatas[id]['country_img'])
        tx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES16') .. self.countryDatas[id]['name'])

        country:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                CountryJadeMgr:hideMyOwnCountryJadeMainUI()
                CountryJadeMgr:hideCountryJadeChooseCountryUI()
                CountryJadeMgr:showOtherCountryJadeMainUI(COUNTRY_JADE_SHOW_TYPE.OTHER,id)
            end
        end)
    end

end

return CountryJadeChooseCountryUI