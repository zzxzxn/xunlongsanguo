local PopWindowSingleRechargeUI = class("PopWindowSingleRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowSingleRechargeUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowSingleRechargeUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_single_recharge.csb")
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
            ActivityMgr:showActivityPage('single_recharge')
        end
    end)

    local centerImg = bgImg3:getChildByName('center_img')
    local des = centerImg:getChildByName('des')
    des:setString(GlobalApi:getLocalStr('POP_WINDOW_DES8'))
    local des1 = centerImg:getChildByName('des_1')
    des1:setString(GlobalApi:getLocalStr('POP_WINDOW_DES9'))
    --[[
    local des2 = centerImg:getChildByName('des_2')
    des2:setString(6)
    local des3 = centerImg:getChildByName('des_3')
    des3:setString(GlobalApi:getLocalStr('POP_WINDOW_DES10'))
    local des4 = centerImg:getChildByName('des_4')
    des4:setString(666)
    local des5 = centerImg:getChildByName('des_5')
    des5:setString(GlobalApi:getLocalStr('POP_WINDOW_DES11'))
    --]]

    local time = ActivityMgr:getActivityTime("single_recharge")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
        bgImg3:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)
    end
end

function PopWindowSingleRechargeUI:getPanel()
    return self.bgImg
end
            
return PopWindowSingleRechargeUI