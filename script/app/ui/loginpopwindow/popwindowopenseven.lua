local PopWindowOpenSevenUI = class("PopWindowOpenSevenUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowOpenSevenUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowOpenSevenUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_open_seven.csb")
    local bgImg = node:getChildByName("bg_img")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bg = bgImg:getChildByName('bg')
    local infoBtn = bg:getChildByName('info_btn')
    infoBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('POP_WINDOW_DES1'))
    infoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FirstWeekActivityMgr:showUI()
        end
    end)

    local popWindowOpenSeven = GameData:getConfData('oldpopwindowopenseven')
    if FirstWeekActivityMgr:judgeNewOrOldSever() then
        popWindowOpenSeven = GameData:getConfData('popwindowopenseven')
    end

    for i = 1,2 do
        local awardData = popWindowOpenSeven[i].award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        
        local icon = bg:getChildByName('icon_' .. i)
        local desc = bg:getChildByName('desc' .. i)

        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        awards:setLightEffect(cell.awardBgImg)
        
        desc:setString(popWindowOpenSeven[i].desc)
        if i == 2 then
            local guangImg = bg:getChildByName('guang')
            guangImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
        end


        -- 名字
        local name = cc.Label:createWithTTF('', 'font/gamefont.ttf', 22)
		name:setAnchorPoint(cc.p(0.5, 0.5))
		name:setPosition(cc.p(47, -20))
        cell.awardBgImg:addChild(name)
        name:setString(awards:getName())
        name:setColor(awards:getNameColor())
        name:enableOutline(awards:getNameOutlineColor(),1)
        name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

        -- 是否领取
        local state = UserData:getUserObj().activity.open_seven.progress[tostring(popWindowOpenSeven[i].progress)]
        if state and state[2] == 1 then    -- 已经领取
            local yilingqImg = ccui.ImageView:create('uires/ui/activity/yilingq.png')
            yilingqImg:setPosition(cc.p(19.77,73.27))
            cell.awardBgImg:addChild(yilingqImg)
        end

    end

    local temp,time = ActivityMgr:getActivityTime("open_seven")
    if time > 0 then
        local node = cc.Node:create()
        node:setPosition(cc.p(530,60))
        bg:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)

        local time_desc = bg:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))
    end
end

function PopWindowOpenSevenUI:getPanel()
    return self.bgImg
end
            
return PopWindowOpenSevenUI