local WorldWarPriceRankUI = class("WorldWarPriceRankUI", BaseUI)

function WorldWarPriceRankUI:ctor(data)
    self.uiIndex = GAME_UI.UI_WORLDWARPRICERANK
    self.data = data.list
end

function WorldWarPriceRankUI:updatePanel()
    table.sort( self.data, function(a,b)
        return a.price > b.price
    end )
    for i,v in ipairs(self.data) do
        local cellNode = cc.CSLoader:createNode("csb/worldwarpricerankcell.csb")
        local priceRankImg = cellNode:getChildByName('price_rank_img')
        local bgImg = priceRankImg:getChildByName('bg_img')
        local nameTx = priceRankImg:getChildByName('name_tx')
        local priceTx = priceRankImg:getChildByName('price_tx')
        bgImg:setVisible(i%2 == 1)
        nameTx:setString(v.name..string.format(GlobalApi:getLocalStr('FU_1'),v.sid))
        priceTx:setString(GlobalApi:toWordsNumber(v.price))
        priceRankImg:setPosition(cc.p(1,(#self.data - i)*50))
        priceRankImg:removeFromParent(false)
        self.rankSv:addChild(priceRankImg,1,1000+i)
    end
    local size = self.rankSv:getContentSize()
    self.rankSv:setInnerContainerSize(cc.size(size.width,#self.data * 50))
    -- for i=1,#self.data do
    --     local img = self.rankSv:getChildByTag(1000 + i)
    --     if img then
    --         img:setPosition(cc.p(2,(#self.data - i)*50))
    --     end
    -- end
end

function WorldWarPriceRankUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hidePriceRank()
        end
    end)

    local titleTx = worldwarImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('PRICE_LIST'))

    local bgImg = worldwarImg:getChildByName('bg_img')
    self.rankSv = bgImg:getChildByName('rank_sv')
    self.rankSv:setScrollBarEnabled(false)

    local teamTx = bgImg:getChildByName('team_tx')
    teamTx:setString(GlobalApi:getLocalStr('TEAM_1'))
    local priceTx = bgImg:getChildByName('price_tx')
    priceTx:setString(GlobalApi:getLocalStr('PRICE'))

    self:updatePanel()
end

return WorldWarPriceRankUI