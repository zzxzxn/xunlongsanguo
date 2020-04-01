local CountryJadeAwardUI = class("CountryJadeAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CountryJadeAwardUI:ctor()
    self.uiIndex = GAME_UI.UI_COUNTRY_JADE_AWARD_PANNEL
    self:initData()
end

function CountryJadeAwardUI:initData()
    self.tempData = clone(GameData:getConfData('countryjaderewardfix')[UserData:getUserObj():getLv()])
end

-- 初始化
function CountryJadeAwardUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)

    bgImg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            CountryJadeMgr:hideCountryJadeAwardUI()
        end
    end)

    local cellTemp = bgImg1:getChildByName('cell')
    cellTemp:setVisible(false)

    local title = bgImg1:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES48'))
    local bg = bgImg1:getChildByName('bg')
    local tx = bg:getChildByName('tx')
    tx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES49'))

    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    -- 添加项到sv里面去
    local num = 4
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 0

    local height = num * cellTemp:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cellTemp:getContentSize().height
    local tempWidth = cellTemp:getContentSize().width

    for i = 1,num do
        local tempCell = cellTemp:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        sv:addChild(tempCell)

        local bg = tempCell:getChildByName('bg')
        if i%2 == 0 then
            bg:setVisible(false)
        else
            bg:setVisible(true)
        end

        local jadeImg = tempCell:getChildByName('jade_img')

        local awardData
        if i == 1 then
            jadeImg:loadTexture('uires/icon/countryjade/lv.png')
            awardData = self.tempData.green
        elseif i == 2 then
            jadeImg:loadTexture('uires/icon/countryjade/lan.png')
            awardData = self.tempData.blue
        elseif i == 3 then
            jadeImg:loadTexture('uires/icon/countryjade/zi.png')
            awardData = self.tempData.purple
        else
            jadeImg:loadTexture('uires/icon/countryjade/cheng.png')
            awardData = self.tempData.orange
        end

        local icon = tempCell:getChildByName('icon')
        local width = icon:getContentSize().width

        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local rightOffset = 40
        local iconOffset = 25
        for j = 1,#disPlayData do
            local frame = icon:clone()
            tempCell:addChild(frame)         
            frame:setPositionX(tempWidth - rightOffset - (j - 1)*iconOffset - (j - 1)*width - width/2)
            local awards = disPlayData[j]
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
                cell.awardBgImg:setPosition(cc.p(34,30))
                cell.awardBgImg:setScale(60/94)
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            end
        end
    end
    innerContainer:setPositionY(size.height - allHeight)

end

return CountryJadeAwardUI