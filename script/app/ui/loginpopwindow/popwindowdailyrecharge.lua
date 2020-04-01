local PopWindowDailyRechargeUI = class("PopWindowDailyRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowDailyRechargeUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowDailyRechargeUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_daily_recharge.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bgImg3 = bgImg2:getChildByName("bg_img3")
	
    local gotoBtn = bgImg3:getChildByName('goto_btn')
    gotoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('POP_WINDOW_DES3'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ActivityMgr:showActivityPage('daily_recharge')
        end
    end)

    local time = ActivityMgr:getActivityTime("daily_recharge")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
        bgImg3:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)
    end

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES4'), 24, COLOR_TYPE.WHITE)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES5'), 24, COLOR_TYPE.YELLOW)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES6'), 24, COLOR_TYPE.WHITE)
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES7'), 24, COLOR_TYPE.YELLOW)
    re4:setFont('font/gamefont.ttf')
    local re5 = xx.RichTextLabel:create('！', 24, COLOR_TYPE.WHITE)
    re5:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:addElement(re5)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(150,80))
    richText:format(true)
    bgImg3:addChild(richText)

    local confData = GameData:getConfData('avdailyrecharge')
    local awardData = confData[#confData].awards
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    for i = 1,2 do
        local icon = bgImg3:getChildByName('icon_' .. i)
        
        local awards = disPlayData[i]
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

function PopWindowDailyRechargeUI:getPanel()
    return self.bgImg
end
            
return PopWindowDailyRechargeUI