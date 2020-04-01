local PopWindowTodayDoubleUI = class("PopWindowTodayDoubleUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowTodayDoubleUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowTodayDoubleUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_todaydouble.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bgImg3 = bgImg2:getChildByName("bg_img3")
	
    local time = ActivityMgr:getActivityTime("todaydouble")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 55,time_desc:getPositionY()))
        bgImg3:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)
    end

    local gotoBtn = bgImg3:getChildByName('goto_btn')
    gotoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('POP_WINDOW_DES3'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ActivityMgr:showActivityPage('todaydouble')
        end
    end)

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES13'), 40, COLOR_TYPE.GREEN)
    re1:setStroke(cc.c4b(130, 87, 31, 255),2)
    re1:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES14'), 40, cc.c4b(246, 255, 0, 255))
    re2:setStroke(cc.c4b(130, 87, 31, 255),2)
    re2:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(20,38))
    richText:format(true)
    bgImg3:addChild(richText)
end

function PopWindowTodayDoubleUI:getPanel()
    return self.bgImg
end
            
return PopWindowTodayDoubleUI