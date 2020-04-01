local TerritorialWarsElementUI = class("TerritorialWarsElement", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local accessimg = {  
    accessed = 'uires/ui/territorialwars/terwars_access_yes.png',
    disaccess = 'uires/ui/territorialwars/terwars_access_no.png',
}


function TerritorialWarsElementUI:ctor(resId,cellId,around,visited,myselfLand)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_ELEMENT
    self.resId = resId
    self.cellId = cellId
    self.around = around
    self.visited = visited
end

function TerritorialWarsElementUI:init()
    
    local dfelementConfig = GameData:getConfData("dfelement")[self.resId]
    
    local outbg = self.root:getChildByName('bg')
    local alphabg = outbg:getChildByName('alpha_img')
    self:adaptUI(outbg, alphabg)

    local bgimg1 =  alphabg:getChildByName('bg_img1')
    local neibg = bgimg1:getChildByName('nei_bg_img')
    local tiaobg = neibg:getChildByName('tiao_img')
    --local bgimg2 =  alphabg:getChildByName('bg_img2')

    local closeBtn = alphabg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideElementUI()
        end
    end)

    local titleText = alphabg:getChildByName('title_tx')
    titleText:setString(dfelementConfig.name)

    local infoText = tiaobg:getChildByName('info_text')
    
    infoText:ignoreContentAdaptWithSize(false)
    infoText:setTextAreaSize(cc.size(480,80))

    local rewardCenter = tiaobg:getChildByName('award_node_center')
    local disPlayData = DisplayData:getDisplayObjs(dfelementConfig.award)
    if #disPlayData == 1 then
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, rewardCenter)
        cell.awardBgImg:setScale(0.9)
    elseif #disPlayData == 2  then
        for i=1,2 do 
            local rewardnode = tiaobg:getChildByName('award_node_'..i)
            local awards = disPlayData[i]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, rewardnode)
            cell.awardBgImg:setScale(0.9)
        end
    end
   
    local confirmBtn = neibg:getChildByName('confirm_btn')
    confirmBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:collectElement(self.cellId,dfelementConfig.isCost)
        end
    end)
    local btnText = confirmBtn:getChildByName('info_tx')
    btnText:setString(dfelementConfig.btText)

    local flag = 1
    if self.around == true then
        confirmBtn:setVisible(true)
        flag = 2
    else
        confirmBtn:setVisible(false)
        flag = 1
    end

    --����ͼ��

    if self.visited == true then
        confirmBtn:setVisible(false)
        flag = 3
    end
    
    if TerritorialWarMgr.VisitType.flow_resource == dfelementConfig.event then
       -- accessImg:setVisible(false)
    else
       -- accessImg:setVisible(true)
    end
    infoText:setString(dfelementConfig['desc'..flag])
end

return TerritorialWarsElementUI