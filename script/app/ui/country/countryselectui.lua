local CountrySelectUI = class("CountrySelectUI", BaseUI)

function CountrySelectUI:ctor(callback)
    self.uiIndex = GAME_UI.UI_COUNTRYSELECT
    self.callback = callback
end

function CountrySelectUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local selectAlphaImg = self.root:getChildByName("select_alpha_img")
    local selectBgImg = selectAlphaImg:getChildByName("select_bg_img")
    self:adaptUI(selectAlphaImg, selectBgImg)

    selectBgImg:setScaleX(winsize.width/1400 + 0.01)
    selectBgImg:setScaleY(winsize.height/768 + 0.01)
    local closeBtn = selectAlphaImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winsize.width, winsize.height))
    closeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        CountryMgr:hideCountrySelect()
    end)

    local topNode = selectAlphaImg:getChildByName("top_node")
    topNode:setPosition(cc.p(winsize.width/2, winsize.height))
    local titleLabel = topNode:getChildByName("title_tx")
    titleLabel:setString(GlobalApi:getLocalStr("SELECT_COUNTRY"))

    local middleNode = selectAlphaImg:getChildByName("middle_node")
    middleNode:setPosition(cc.p(winsize.width/2, winsize.height/2 + 30))
    local flags = {}
    local flagLights = {}
    local selectIndex = 0
    local function selectFlag(index, flag)
        selectIndex = index
        local posx, posy = flag:getPosition()
        flag:setScale(1)
        flag:setTouchEnabled(false)
        for k, v in pairs(flags) do
            if tonumber(k) ~= index then
                v:setScale(0.8)
                v:setTouchEnabled(true)
                flagLights[k]:setVisible(false)
            else
                flagLights[k]:setVisible(true)
            end
        end
    end
    for i = 0, 3 do
        local flag = middleNode:getChildByName("flag_" .. i)
        local flag2 = middleNode:getChildByName("flag_" .. i .. "1")
        flags[tostring(i)] = flag
        flagLights[tostring(i)] = flag2
        flag:addClickEventListener(function ()
            AudioMgr.PlayAudio(11)
            selectFlag(i, flag)
        end)
    end
    selectFlag(0, flags["0"])

    local bottomNode = selectAlphaImg:getChildByName("bottom_node")
    bottomNode:setPosition(cc.p(winsize.width/2, 0))
    local agreeBtn = bottomNode:getChildByName("agree_btn")
    agreeBtn:setPosition(cc.p(winsize.width/2 - 100, 65))
    local agreeLabel = agreeBtn:getChildByName("text")
    agreeLabel:setString(GlobalApi:getLocalStr("STR_I_AGREE"))
    agreeBtn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        local obj = {
            country = selectIndex
        }
        MessageMgr:sendPost("set_country","country", json.encode(obj), function (response)
            if response.code == 0 then
                UserData:getUserObj():setCountry(response.data.country)
                -- CountryMgr:showCountryMain()

				-- 选了国家后，如果太守开了，打开太守界面，如果太守没开，就打开国家界面
				local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('lord')
				if isOpen == false then
					CountryMgr:showCountryMain()
					CountryMgr:hideCountrySelect()

					if response.data.awards then
						GlobalApi:parseAwardData(response.data.awards)
						GlobalApi:showAwardsCommon(response.data.awards, nil, nil, true)
					end
					return
				end

                local function callback()
                    GuideMgr:startCityOpenGuide(18, 1)
                end
                if response.data.awards then
                     if self.callback then
                        self.callback()
                    end
                    GlobalApi:parseAwardData(response.data.awards)
                    GlobalApi:showAwardsCommon(response.data.awards, nil, callback, true)
                else
                    if self.callback then
                        self.callback()
                        GuideMgr:startCityOpenGuide(18, 1)
                    end
                end
                CountryMgr:hideCountrySelect()
            end
        end)
    end)

    local npc = bottomNode:getChildByName("npc")
    npc:setLocalZOrder(2)
    --npc:setPosition(cc.p(-winsize.width/2 - 80, 0))

    local blackBg = bottomNode:getChildByName("black_bg")
    local tips_tx = blackBg:getChildByName("tips_tx")
    tips_tx:setString(GlobalApi:getLocalStr("COUNTRY_SELECT_TIPS_1"))

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(510, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("COUNTRY_SELECT_INFO_1"), 30, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr("COUNTRY_SELECT_INFO_2"), 30, COLOR_TYPE.YELLOW)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr("COUNTRY_SELECT_INFO_3"), 30, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re3:setFont('font/gamefont.ttf')
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setPosition(cc.p(60, 80))
    bottomNode:addChild(richText)
end

return CountrySelectUI