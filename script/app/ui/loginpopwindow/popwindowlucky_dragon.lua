local PopWindowLuckyDragonUI = class("PopWindowLuckyDragonUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowLuckyDragonUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowLuckyDragonUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_lucky_dragon.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bgImg3 = bgImg2:getChildByName("bg_img3")
	
    local temp,time = ActivityMgr:getActivityTime("lucky_dragon")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
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
            ActivityMgr:showGetMoneyDragon()
        end
    end)

    local img1 = bgImg3:getChildByName('img1')
    local nameTx = img1:getChildByName('name_tx')
    nameTx:setString(GlobalApi:getLocalStr('POP_WINDOW_DES17'))
    
    local img3 = bgImg3:getChildByName('img3')
    local nameTx2 = img3:getChildByName('name_tx')
    nameTx2:setString(GlobalApi:getLocalStr('POP_WINDOW_DES18'))
end

function PopWindowLuckyDragonUI:getPanel()
    return self.bgImg
end
            
return PopWindowLuckyDragonUI