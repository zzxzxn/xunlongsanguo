local CampaignBasePanel = require("script/app/ui/campaign/campaignbasepanel")
local CampaignShipperPanel = class("CampaignShipperPanel", CampaignBasePanel)

function CampaignShipperPanel:ctor(index, showByClick)
    self.root = cc.CSLoader:createNode('csb/campaignshipperpanel.csb')
    self:runBgAction()
end

function CampaignShipperPanel:runBgAction1()
    self.bg1:stopAllActions()
    local size = self.bg1:getContentSize()
    local endPoint = cc.p(-700 - size.width,-384)
    local timeTotal = 30
    local speed = size.width/timeTotal
    local time = 0.1

    local pos = cc.p(self.bg1:getPositionX(),self.bg1:getPositionY())
    local action = cc.MoveTo:create(math.abs(endPoint.x - pos.x)/speed,cc.p(endPoint.x,pos.y))
    local actionFun = cc.CallFunc:create(function () 
        local size = self.bg1:getContentSize()
        local p = cc.p(self.bg2:getPositionX(),self.bg2:getPositionY())
        self.bg1:setPosition(cc.p(p.x + size.width - time*timeTotal - 4,p.y))
        self.bg1:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction1()
        end)))
    end)
    self.bg1:runAction(cc.Sequence:create(action,actionFun))
end

function CampaignShipperPanel:runBgAction2()
    self.bg2:stopAllActions()
    local size = self.bg1:getContentSize()
    local endPoint = cc.p(-700 - size.width,-384)
    local timeTotal = 30
    local speed = size.width/timeTotal
    local time = 0.1

    local pos1 = cc.p(self.bg2:getPositionX(),self.bg2:getPositionY())
    local action1 = cc.MoveTo:create(math.abs(endPoint.x - pos1.x)/speed,cc.p(endPoint.x,pos1.y))
    local actionFun1 = cc.CallFunc:create(function ()
        local size = self.bg1:getContentSize()
        local p = cc.p(self.bg1:getPositionX(),self.bg1:getPositionY())
        self.bg2:setPosition(cc.p(p.x + size.width - time*timeTotal - 4,p.y))
        self.bg2:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction2()
        end)))
    end)

    self.bg2:runAction(cc.Sequence:create(action1,actionFun1))
end

function CampaignShipperPanel:runBgAction()
    self.bg1 = self.root:getChildByName('bg_1_img')
    self.bg2 = self.root:getChildByName('bg_2_img')
    -- local posX1,posY1 = bg1:getPositionX(),bg1:getPositionY()
    -- local posX2,posY2 = bg2:getPositionX(),bg2:getPositionY()
    -- local size = bg1:getContentSize()
    -- local pos1 = cc.p(posX1 - size.width + 6,posY1)
    -- local pos2 = cc.p(posX1,posY1)
    -- local pos3 = cc.p(posX2,posY2)
    -- local speed = size.width/30
    -- local time = math.abs(posX2 - posX1)/speed
    -- local function run(bg)
    --     bg:stopAllActions()
    --     bg:setPosition(pos3)
    --     bg:runAction(
    --         cc.Sequence:create(
    --             cc.MoveTo:create(time,pos2),
    --             cc.CallFunc:create(function()
    --                 bg:setPosition(pos2)
    --             end),
    --             cc.MoveTo:create(time,pos1),
    --             cc.CallFunc:create(function()
    --                 run(bg)
    --             end)))
    -- end
    -- bg1:runAction(cc.Sequence:create(cc.MoveTo:create(time,pos1),cc.CallFunc:create(function()
    --     bg1:setPosition(pos3)
    --     run(bg1)
    -- end)))
    -- run(bg2)

    local spineAni = GlobalApi:createAniByName('biaoche4')
    spineAni:setPosition(cc.p(0, -90))
    spineAni:getAnimation():play('run', -1, 1)
    self.root:addChild(spineAni)
    self:runBgAction1()
    self:runBgAction2()
end

function CampaignShipperPanel:getExtraInfos()
    local shipper = UserData:getUserObj():getShipper()
    local num1 = tonumber(GlobalApi:getGlobalValue("shipperDeliveryCount")) - shipper.delivery
    local num2 = tonumber(GlobalApi:getGlobalValue("shipperRobCount")) - shipper.rob
    local str1 = GlobalApi:getLocalStr("SHIPPER_DELIVERY_TIMES") .. num1 ..  "/" .. GlobalApi:getGlobalValue("shipperDeliveryCount")
    local str2 = GlobalApi:getLocalStr("SHIPPER_ROB_TIMES") .. num2 .. "/" .. GlobalApi:getGlobalValue("shipperRobCount")
    return {str1, str2}
end

function CampaignShipperPanel:enterCampaign()
    GlobalApi:getGotoByModule('shipper')
end

return CampaignShipperPanel