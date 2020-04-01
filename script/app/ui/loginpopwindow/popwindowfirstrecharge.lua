local PopWindowFirstRechargeUI = class("PopWindowFirstRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowFirstRechargeUI:ctor(data)
    self.data = data
    self.cfg = GameData:getConfData("specialreward")["first_pay"]
    self:init()
end

function PopWindowFirstRechargeUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_firstrecharge.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    self.gotoBtn = bgImg:getChildByName("goto_btn")

	self:updatePanel()
end

function PopWindowFirstRechargeUI:updatePanel()
	local gotoTx=self.gotoBtn:getChildByName("tx")	
	gotoTx:setString(GlobalApi:getLocalStr('POP_WINDOW_DES3'))
	self.gotoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			RechargeMgr:showFirstRecharge()
	    end
	end)
end

function PopWindowFirstRechargeUI:getPanel()
    return self.bgImg
end
            
return PopWindowFirstRechargeUI