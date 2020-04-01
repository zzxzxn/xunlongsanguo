local CountryWarOrderUI = class("CountryWarOrderUI", BaseUI)
local COUNTRY_COLOR = {
    [1] = COLOR_TYPE.BLUE,
    [2] = COLOR_TYPE.GREEN,
    [3] = COLOR_TYPE.RED,
    [6] = COLOR_TYPE.YELLOW,
}
function CountryWarOrderUI:ctor(callList)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_ORDER
    self.cells = {}
    self.callList = callList
    self.rts = {}
end

function CountryWarOrderUI:updateTime(bgImg,time)
    local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 24)
    local winSize = cc.Director:getInstance():getVisibleSize()
    label:setName('time_tx')
    label:setPosition(cc.p(230,450))
    -- label:setPosition(cc.p(winSize.width/2,winSize.height/2))
    print('=============================',time)
    bgImg:addChild(label)
    Utils:createCDLabel(label,time,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, nil,nil,nil,24,function ()
        self:updatePanel()
    end)
end

function CountryWarOrderUI:updatePanel()
    local num = 0
    for k,v in pairs(self.callList) do
        local beginTime = v.time
        local endTime = v.time + tonumber(CountryWarMgr:getBaseValue('callKeepTime'))
        local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
        if nowTime > beginTime and nowTime < endTime then
            num = num + 1
        end
    end
    if num <= 0 then
        CountryWarMgr:hideCountryWarOrder()
        CountryWarMgr:updateMapNewImgs()
        return
    end
    local currId = 0
    for k,v in pairs(self.callList) do
        local beginTime = v.time
        local endTime = v.time + tonumber(CountryWarMgr:getBaseValue('callKeepTime'))
        local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
        if nowTime > beginTime and nowTime < endTime then
            currId = currId + 1
            if not self.cells[currId] then
                local cellNode = cc.CSLoader:createNode("csb/countrywarordercell.csb")
                local bgImg = cellNode:getChildByName('bg_img')
                bgImg:removeFromParent(false)
                self.sv:addChild(bgImg)
                self.cells[currId] = {bgImg = bgImg}
            end
            local bgImg = self.cells[currId].bgImg
            local attackImg = bgImg:getChildByName('attack_img')
            local countryBgImg = bgImg:getChildByName('country_bg_img')
            local cityImg = countryBgImg:getChildByName('city_img')
            local cityNameTx = countryBgImg:getChildByName('city_name_tx')
            local flag1 = bgImg:getChildByName('camp_img_1')
            local flag2 = bgImg:getChildByName('camp_img_2')
            local flag3 = bgImg:getChildByName('camp_img_3')
            local flag4 = bgImg:getChildByName('camp_img_4')
            local countryTx1 = flag1:getChildByName('country_tx')
            local countryTx2 = flag2:getChildByName('country_tx')
            local countryTx3 = flag3:getChildByName('country_tx')
            local countryTx4 = flag4:getChildByName('country_tx')
            local numTx1 = flag1:getChildByName('num_tx')
            local numTx2 = flag2:getChildByName('num_tx')
            local numTx3 = flag3:getChildByName('num_tx')
            local numTx4 = flag4:getChildByName('num_tx')
            local responseBtn = bgImg:getChildByName('response_btn')
            local infoTx = responseBtn:getChildByName('info_tx')
            infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_RESPONSE'))
            if not self.rts[currId] then
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(370, 30))
                richText:setAlignment('middle')
                richText:setVerticalAlignment('middle')
                local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_72'),25,COLOR_TYPE.WHITE)
                local re1 = xx.RichTextLabel:create(v.callerName,25,COLOR_TYPE.WHITE)
                local re2 = xx.RichTextLabel:create('['..(v.serverId or 0)..GlobalApi:getLocalStr('FU')..']',25,COLOR_TYPE.ORANGE)
                re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
                re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
                re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                richText:addElement(re)
                richText:addElement(re2)
                richText:addElement(re1)
                richText:setAnchorPoint(cc.p(0.5,0.5))
                richText:setPosition(cc.p(185,236))
                bgImg:addChild(richText)
                self.rts[currId] = {richText = richText,re = re,re1 = re1,re2 = re2}
            else
                self.rts[currId].re1:setString(v.callerName)
                self.rts[currId].re2:setString('['..(v.serverId or 0)..GlobalApi:getLocalStr('FU')..']')
                self.rts[currId].richText:format(true)
            end
            local tab = {1,2,3}
            table.remove(tab,v.defenseCountry)
            -- local attackNum = 0
            -- for i,v in ipairs(tab) do
            --     print(i,v)
            -- end
            local camp = CountryWarMgr.camp
            if v.defenseCountry ~= camp then
                attackImg:loadTexture('uires/ui/countrywar/attack.png')
            else
                attackImg:loadTexture('uires/ui/countrywar/defense.png')
            end

            local cityData = CountryWarMgr.citys[tostring(k)]
            local conf = GameData:getConfData('countrywarcity')[tonumber(k)]
            countryBgImg:loadTexture('uires/ui/countrywar/country_di_'..cityData.hold_camp..'_1.png')
            countryBgImg:ignoreContentAdaptWithSize(true)
            cityImg:loadTexture('uires/ui/countrywar/'..cityData.hold_camp..'-'..conf.type..'.png')
            cityImg:ignoreContentAdaptWithSize(true)
            cityImg:setScale(0.6)
            cityNameTx:setString(conf.name)

            numTx1:setString(v.playerCount[tostring(tab[1])]..GlobalApi:getLocalStr('SOLDIER_REN'))
            countryTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_'..tab[1]))
            countryTx1:setColor(COUNTRY_COLOR[tab[1]])
            numTx2:setString(v.playerCount[tostring(tab[2])]..GlobalApi:getLocalStr('SOLDIER_REN'))
            countryTx2:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_'..tab[2]))
            countryTx2:setColor(COUNTRY_COLOR[tab[2]])
            numTx3:setString((v.playerCount[tostring(v.defenseCountry)] - v.npcCount)..GlobalApi:getLocalStr('SOLDIER_REN'))
            countryTx3:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_'..v.defenseCountry))
            countryTx3:setColor(COUNTRY_COLOR[v.defenseCountry])
            numTx4:setString(v.npcCount..GlobalApi:getLocalStr('SOLDIER_REN'))
            countryTx4:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_6'))
            countryTx4:setColor(COUNTRY_COLOR[6])
            -- self.cells[currId].flag1:loadTexture('uires/ui/country/country_flag_'..tab[1]..'.png')
            -- self.cells[currId].flag2:loadTexture('uires/ui/country/country_flag_'..tab[2]..'.png')
            -- self.cells[currId].flag3:loadTexture('uires/ui/country/country_flag_'..v.defenseCountry..'.png')
            local timeTx = bgImg:getChildByName('time_tx')
            if timeTx then
                timeTx:removeFromParent()
            end
            self:updateTime(bgImg,endTime - nowTime)
            responseBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    CountryWarMgr:responseCallOfDuty(tonumber(k),function(callback)
                        CountryWarMgr:hideCountryWarOrder()
                        CountryWarMgr:setWinPosition(nil,nil,nil,callback)
                    end)
                end
            end)
        end
    end

    for i=currId + 1,#self.cells do
        self.cells[i].bgImg:setVisible(false)
    end
    local singleSize = self.cells[1].bgImg:getContentSize()
    local size = self.sv:getContentSize()
    local diff = 5
    if currId * (singleSize.width + diff) > size.width then
        self.sv:setInnerContainerSize(cc.size(currId * (singleSize.width + diff),size.height))
    else
        self.sv:setInnerContainerSize(size)
    end
    -- if currId < 5 then
    --     for i=1,currId do
    --         self.cells[i].bgImg:setPosition(cc.p(2,size.height - i*(singleSize.height + 10) + 5))
    --     end
    -- else
        for i=1,currId do
            self.cells[i].bgImg:setPosition(cc.p((currId - i)*(singleSize.width + diff) + 5,0))
        end
    -- end
end

function CountryWarOrderUI:init()
    local bgImg = self.root:getChildByName("countrywar_bg_img")
    local bgImg1 = bgImg:getChildByName("countrywar_img")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarOrder()
        end
    end)

    local titleImg = bgImg1:getChildByName('title_img')
    local descTx = titleImg:getChildByName('title_tx')
    descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_8'))
    local bg2 = bgImg1:getChildByName('bg2')
    self.sv = bg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)

    self:updatePanel()
end

return CountryWarOrderUI