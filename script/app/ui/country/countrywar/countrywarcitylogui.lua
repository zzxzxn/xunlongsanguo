local CountryWarCityLogUI = class('CountryWarCityLogUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local CAMP_COLOR = {
    COLOR_TYPE.BLUE,
    COLOR_TYPE.GREEN,
    COLOR_TYPE.RED,
}

function CountryWarCityLogUI:ctor(data)
	self.uiIndex = GAME_UI.UI_COUNTRYWAR_CITY_LOG
    self.data = data
end

function CountryWarCityLogUI:init()
	local bgImg = self.root:getChildByName('bg_img')
	local bgImg1 = bgImg:getChildByName('bg_img1')
	self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getWinSize()
    bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	local closeBtn = bgImg1:getChildByName('close_btn')
	closeBtn:addClickEventListener(function ()
		CountryWarMgr:hideCountryWarCityLog()
	end)

	local title_bg = bgImg1:getChildByName('title_bg')
	local title_tx = title_bg:getChildByName('title_tx')
	title_tx:setString(GlobalApi:getLocalStr('STR_BATTLE_REPORT1'))

    self.eventBgImg = bgImg1:getChildByName('event_bg_img')
    self.eventSv = self.eventBgImg:getChildByName('event_sv')
    self.eventSv:setScrollBarEnabled(false)
    self.noReport = self.eventBgImg:getChildByName('no_report_img')
    self.noReport:setVisible(#self.data.events <= 0)
    local node = cc.Node:create()
    node:setName('node')
    self.eventSv:addChild(node)
    self:updateEventCell()
end

function CountryWarCityLogUI:createRichtextCell(stype,str,camp)
    local color,colorOutline
    if stype == 'server' then
        color = COLOR_TYPE.ORANGE
        colorOutline = COLOROUTLINE_TYPE.ORANGE
    elseif stype == 'name' then
        color = CAMP_COLOR[camp]
        colorOutline = COLOROUTLINE_TYPE.WHITE
    elseif stype == 'key' then
        color = COLOR_TYPE.ORANGE
        colorOutline = COLOROUTLINE_TYPE.ORANGE
    else
        color = COLOR_TYPE.WHITE
        colorOutline = COLOROUTLINE_TYPE.WHITE
    end
    local re = xx.RichTextLabel:create(str, 24,color)
    re:setStroke(colorOutline, 1)
    return re
end

function CountryWarCityLogUI:updateEventCell()
    local singleSize
    local conf = GameData:getConfData("countrywarcityrecord")
    for i,v in ipairs(self.data.events) do
        local node = self.eventSv:getChildByName('node')
        local bgImg = node:getChildByName('bg_img_'..i)
        if not bgImg then
            local cellNode = cc.CSLoader:createNode("csb/territoralwar_event_cell.csb")
            bgImg = cellNode:getChildByName("pl")
            bgImg:removeFromParent(false)
            bgImg:setName('bg_img_'..i)
            node:addChild(bgImg)
        end
        singleSize = bgImg:getContentSize()
        bgImg:setPosition(cc.p(0,(i - #self.data.events)*singleSize.height))
        local cellBg = bgImg:getChildByName('cell_bg')
        local timeTx = bgImg:getChildByName('time_tx')
        local tempTx = bgImg:getChildByName('temp_tx')
        local titleTx = bgImg:getChildByName('title_tx')
        cellBg:setVisible(i%2 ~= 0)

        local richText = xx.RichText:create()
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
        richText:setContentSize(cc.size(600, 30))
        richText:setAnchorPoint(cc.p(0,1))
        richText:setPosition(cc.p(30,48.5))

        local time = os.date('*t',v.time)
        local re5 = self:createRichtextCell('desc',string.format('%02d',time.hour)..':'..string.format('%02d',time.min))
        local reTab = {}
        if v.id == 1 or v.id == 2 or v.id == 3 then
            local re = self:createRichtextCell('server',' ['..v.param[1]..GlobalApi:getLocalStr('FU')..']')
            local re1 = self:createRichtextCell('name',v.param[2],v.param[3])
            local re2 = self:createRichtextCell('desc',conf[v.id].desc)
            local re3 = self:createRichtextCell('server','['..v.param[4]..GlobalApi:getLocalStr('FU')..']')
            local re4 = self:createRichtextCell('name',v.param[5],v.param[6])
            reTab = {re5,re,re1,re2,re3,re4}
        elseif v.id == 4 then
            local re = self:createRichtextCell('server',' ['..v.param[1]..GlobalApi:getLocalStr('FU')..']')
            local re1 = self:createRichtextCell('name',v.param[2],v.param[3])
            local re2 = self:createRichtextCell('desc',conf[v.id].desc)
            reTab = {re5,re,re1,re2}
        elseif v.id == 5 then
            local re = self:createRichtextCell('server',' ['..v.param[1]..GlobalApi:getLocalStr('FU')..']')
            local re1 = self:createRichtextCell('name',v.param[2],v.param[3])
            local re2 = self:createRichtextCell('desc',conf[v.id].desc)
            local re3 = self:createRichtextCell('key',GlobalApi:getLocalStr('COUNTRY_WAR_DESC_83'))
            reTab = {re5,re,re1,re2,re3}
        elseif v.id == 6 then
            local re = self:createRichtextCell('name',
                ' '..GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..v.param[1])..GlobalApi:getLocalStr('COUNTRY_WAR_LIST_TITLE_DESC_1'),
                v.param[1])
            local re1 = self:createRichtextCell('desc',conf[v.id].desc)
            local conf1 = GameData:getConfData("countrywarcity")[CountryWarMgr.myCity]
            local re2 = self:createRichtextCell('key',conf1.name)
            reTab = {re5,re,re1,re2}
        end
        for i,v in ipairs(reTab) do
            richText:addElement(v)
        end
        bgImg:addChild(richText)
    end
    if singleSize then
        local size = self.eventSv:getContentSize()
        if #self.data.events*singleSize.height > size.height then
            self.eventSv:setInnerContainerSize(cc.size(size.width,#self.data.events*singleSize.height))
        else
            self.eventSv:setInnerContainerSize(size)
        end
    end

    local size1 = self.eventSv:getInnerContainerSize()
    local node = self.eventSv:getChildByName('node')
    node:setPosition(cc.p(size1.width/2,size1.height))
end

return CountryWarCityLogUI
