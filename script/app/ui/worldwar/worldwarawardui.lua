local WorldWarAwardUI = class("WorldWarAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function WorldWarAwardUI:ctor()
	self.uiIndex = GAME_UI.UI_WORLDWARAWARD
    self.page = 1
    self.conf = {GameData:getConfData('worldwarreward'),GameData:getConfData('worldwarglory')}
    self.cells = {}
end

function WorldWarAwardUI:updateCell()
    local conf = self.conf[self.page]
    local function getRank(id)
        -- for i=1,10 do
        --     print(i)
        -- end
    end
    for i=1,#conf do
        if not self.cells[i] then
            local cellNode = cc.CSLoader:createNode("csb/worldwarawardcell.csb")
            local rankBgImg = cellNode:getChildByName('rank_bg_img')
            local bgImg = rankBgImg:getChildByName('bg_img')
            local rankImg = rankBgImg:getChildByName('rank_img')
            local rankTx = rankBgImg:getChildByName('rank_tx1')
            if not rankTx then
                rankTx = cc.LabelBMFont:create()
                rankTx:setFntFile('uires/ui/number/number2.fnt')
                rankTx:setName('rank_tx1')
                rankTx:setPosition(cc.p(135,55))
                rankBgImg:addChild(rankTx)
            end
            local awards = {}
            for j=1,4 do
                local awardAlphaImg = rankBgImg:getChildByName('award_'..j..'_img')
                local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
                awardCell.awardBgImg:setTouchEnabled(true)
                awardCell.awardBgImg:setScale(0.7)
                awardCell.awardBgImg:setPosition(cc.p(awardAlphaImg:getPosition()))
                rankBgImg:addChild(awardCell.awardBgImg)
                awards[j] = awardCell
            end
            rankBgImg:removeFromParent(false)
            self.rankSv:addChild(rankBgImg)
            bgImg:setVisible(i%2 == 1)
            self.cells[i] = {rankBgImg = rankBgImg,bgImg = bgImg,rankImg = rankImg,awards = awards,rankTx = rankTx}
        end
        local lastConf = conf[i - 1]
        self.cells[i].rankBgImg:setVisible(true)

        self.cells[i].bgImg:setVisible(i%2 == 1)
        if i <= 3 then
            -- self.cells[i].rankTx:setString(conf[i].rank..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC3'))
            self.cells[i].rankTx:setString('')
            self.cells[i].rankImg:loadTexture('uires/ui/rankinglist_v3/rlistv3_rank_'..i..'.png')
        elseif i == #conf then
            self.cells[i].rankImg:setVisible(false)
            self.cells[i].rankTx:setString((conf[i].rank - 1)..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC4'))
        else
            self.cells[i].rankImg:setVisible(false)
            local conf1 = conf[i + 1]
            if conf[i].rank == conf1.rank - 1 then
                self.cells[i].rankTx:setString(conf[i].rank)
            else
                self.cells[i].rankTx:setString(conf[i].rank..'-'..(conf1.rank - 1))
            end
        end
        self.cells[i].rankImg:ignoreContentAdaptWithSize(true)
        local awards = DisplayData:getDisplayObjs(conf[i].awards)
        for i,v in ipairs(self.cells[i].awards) do
            local award = awards[i]
            if award then
                ClassItemCell:updateItem(v, award, 1)
                v.awardBgImg:setVisible(true)
                v.nameTx:setString(award:getName())
                v.nameTx:setColor(award:getNameColor())
                v.nameTx:enableOutline(award:getNameOutlineColor(),1)
                v.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                if award:getType() == 'equip' then
                    ClassItemCell:setGodLight(v.awardBgImg, award:getGodId())
                else
                    ClassItemCell:setGodLight(v.awardBgImg, 0)
                end
                v.awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        local stype = award:getType()
                        GetWayMgr:showGetwayUI(award,false)
                    end
                end)
            else
                v.awardBgImg:setVisible(false)
            end
        end
    end

    for i=#conf + 1,#self.cells do
        self.cells[i].rankBgImg:setVisible(false)
    end
    local singleSize = self.cells[1].rankBgImg:getContentSize()
    local size = self.rankSv:getContentSize()
    if #conf * singleSize.height > size.height then
        self.rankSv:setInnerContainerSize(cc.size(size.width,#conf * singleSize.height))
    else
        self.rankSv:setInnerContainerSize(size)
    end
    for i=1,#conf do
        self.cells[i].rankBgImg:setPosition(cc.p(1,(#conf - i)*singleSize.height))
    end
end

function WorldWarAwardUI:updatePanel()
    for i,v in ipairs(self.pageBtns) do
        local infoTx = v:getChildByName('info_tx')
        if i == self.page then
            v:setBrightStyle(ccui.BrightStyle.highlight)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            v:setBrightStyle(ccui.BrightStyle.normal)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
    self:updateCell()
end

function WorldWarAwardUI:init()
    self.intervalSize = 0
	local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideAward()
        end
    end)

    self.pageBtns = {}
    for i=1,2 do
        local pageBtn = worldwarImg:getChildByName('page_'..i..'_btn')
        local infoTx = pageBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('AWARD_TITLE_'..i))
        self.pageBtns[i] = pageBtn
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
    end

    self.rankSv = worldwarImg:getChildByName('rank_sv')
    self.rankSv:setScrollBarEnabled(false)
    self:updatePanel()
end

return WorldWarAwardUI