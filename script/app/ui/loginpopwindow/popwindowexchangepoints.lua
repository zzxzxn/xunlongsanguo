local PopWindowExchangePointsUI = class("PopWindowExchangePointsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowExchangePointsUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowExchangePointsUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_exchange_points.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bgImg3 = bgImg2:getChildByName("bg_img3")
	
    local time = ActivityMgr:getActivityTime("exchange_points")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
        bgImg3:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)
    end

    local img4 = bgImg3:getChildByName('img4')
    local bg = img4:getChildByName('bg')
    local gotoBtn = bg:getChildByName('goto_btn')
    gotoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('POP_WINDOW_DES3'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ActivityMgr:showActivityPage('exchange_points')
        end
    end)

    local titleTx = bg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('POP_WINDOW_DES12'))

    local confData = GameData:getConfData('avexchangepointsaward')
    for i = 1,2 do
        local index = 4
        if i == 2 then
            index = 6
        end
        if confData[index] then
            local awardData = confData[index].awards
            local disPlayData = DisplayData:getDisplayObjs(awardData)
            local icon = bg:getChildByName('icon_' .. i)
            local awards = disPlayData[1]
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
                cell.awardBgImg:setPosition(cc.p(94/2,94/2))
                cell.awardBgImg:loadTexture(awards:getBgImg())
                cell.chipImg:setVisible(true)
                cell.chipImg:loadTexture(awards:getChip())
                cell.lvTx:setString('x'..awards:getNum())
                cell.awardImg:loadTexture(awards:getIcon())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            else
                icon:setVisible(false)
            end
        end
    end

end

function PopWindowExchangePointsUI:getPanel()
    return self.bgImg
end
            
return PopWindowExchangePointsUI