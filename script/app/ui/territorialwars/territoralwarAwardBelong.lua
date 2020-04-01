local TerritoralwarAwardBelongUI = class("TerritoralwarAwardBelongUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local rankImgUrl = "uires/ui/rankinglist_v3/rlistv3_rank_"


function TerritoralwarAwardBelongUI:ctor(type,legionLv)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_BELONG
    self.legionLv = legionLv or 1
    self.type = type
end

function TerritoralwarAwardBelongUI:init()

    release_print(self.legionLv)
    local dfbaseConfig = GameData:getConfData("dfbasepara")
    self.dfbossAward = GameData:getConfData("dfbossselfaward")

    if self.legionLv == nil or self.legionLv < 1 then
        self.legionLv = 1
    end
    local dfbosslegioncfg = GameData:getConfData("dfbosslegionconf")
    if self.legionLv > #dfbosslegioncfg then
        self.legionLv = #dfbosslegioncfg
    end

   -- local dfbosslegioncfg = GameData:getConfData("dfbosslegionconf")[self.legionLv]   

    self.dfbosslegionAward = DisplayData:getDisplayObjs(dfbosslegioncfg[self.legionLv].award)

    local alphaBg = self.root:getChildByName("alpha_img")
    local bg = alphaBg:getChildByName("bg_img")
    self:adaptUI(alphaBg, bg)

    local innerBg = bg:getChildByName("inner_bg")
    local headlineBg = innerBg:getChildByName("headline_img")
    for i=1,2 do
        local tx = headlineBg:getChildByName("headline_text_" .. i)
        local infoId = 16+i
        tx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT" .. infoId))
    end
    local timeTx = headlineBg:getChildByName("headline_time")
    local time = dfbaseConfig["bossAwardTime"].value[1]
    timeTx:setString(time)

    --归属排行奖励
    local svBg = innerBg:getChildByName("sv_img")
    self.rankSv = svBg:getChildByName("rank_sv")
    self.rankSv:setScrollBarEnabled(false)

    --个人归属奖励
    local personBg = innerBg:getChildByName("personal_img")
    for i=1,3 do
        local infoTx = personBg:getChildByName("info_" .. i)
        infoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT" .. (19+i-1)))
    end
    self.awardNode = {}
    for i=1,6 do
        self.awardNode[i] = personBg:getChildByName("award_node_" .. i)
    end

    --按钮事件
    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:closeAwardBelongUI()
        end
    end) 

    self:loadPersonAward()
    self:updateAward()

    local showRank = (self.type == 1) and true or false
    svBg:setVisible(showRank)
    personBg:setVisible(not showRank)
end


function TerritoralwarAwardBelongUI:loadPersonAward()


    for i=1,#self.dfbosslegionAward do

        local award = self.dfbosslegionAward[i]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,award,self.awardNode[i])
        cell.awardBgImg:loadTexture(award:getBgImg())
        cell.chipImg:setVisible(true)
        cell.chipImg:loadTexture(award:getChip())
        cell.lvTx:setString('x'..award:getNum())
        cell.awardImg:loadTexture(award:getIcon())
    end

end

function TerritoralwarAwardBelongUI:updateAward()

    local size1
    for i=1,#self.dfbossAward do
        local cell = self.rankSv:getChildByTag(i + 100)
        local cellBg
        if not cell then
            local cellNode = cc.CSLoader:createNode('csb/territorialwar_belongCell.csb')
            cellBg = cellNode:getChildByName('cell_bg')
            cellBg:removeFromParent(false)
            cell = ccui.Widget:create()
            cell:addChild(cellBg)
            self.rankSv:addChild(cell,1,i+100)
        else
            cellBg = cell:getChildByName('cell_bg')
        end
        cell:setVisible(true)
        size1 = cellBg:getContentSize()

        --显示位次
        local rankImg = cellBg:getChildByName("rank_img")
        local rankTx = cellBg:getChildByName("rank_tx")
        local rankFirst,rankTo = self.dfbossAward[i].rank[1],self.dfbossAward[i].rank[2]
        if not rankFirst then
            return
        end

        if rankFirst <= 3 and not rankTo then
            rankImg:setVisible(true)
            rankTx:setVisible(false)
            rankImg:loadTexture(rankImgUrl .. i .. ".png")
        else
            local text = (rankTo ~= 0) and rankFirst .. "-" .. rankTo or (rankFirst-1) .. GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC4")
            rankImg:setVisible(false)
            rankTx:setVisible(true)
            rankTx:setString(text)
        end

        --显示奖励
        local awards = DisplayData:getDisplayObjs(self.dfbossAward[i].award)
        for j=1,4 do
            local award = awards[j]
            if award then
                local awardNode = cellBg:getChildByName('award_node_' .. j)
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,award,awardNode)
                cell.awardBgImg:loadTexture(award:getBgImg())
                cell.chipImg:setVisible(true)
                cell.chipImg:loadTexture(award:getChip())
                cell.lvTx:setString('x'..award:getNum())
                cell.awardImg:loadTexture(award:getIcon())
                cell.awardBgImg:setScale(0.8)
            end
        end
    end

    if not size1 then
        self.rankSv:setVisible(false)
        return
    end

    local size = self.rankSv:getContentSize()
    if #self.dfbossAward * size1.height > size.height then
        self.rankSv:setInnerContainerSize(cc.size(size.width,(#self.dfbossAward * size1.height+(#self.dfbossAward-1)*14)))
    else
        self.rankSv:setInnerContainerSize(size)
    end

    local function getPos(i)
        local size2 = self.rankSv:getInnerContainerSize()        
        return cc.p(2.5,size2.height - size1.height* i-14*(i-1))
    end
    for i=1,#self.dfbossAward do
        local cell = self.rankSv:getChildByTag(i + 100)
        if cell then
            cell:setPosition(getPos(i))
        end
    end
end

return TerritoralwarAwardBelongUI