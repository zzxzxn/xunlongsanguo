--===============================================================
-- 武将属性tips
--===============================================================
local RoleAttTipsUI = class("RoleAttTipsUI", BaseUI)
function RoleAttTipsUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_ROLEATTTIPS
	self.obj = obj
end

function RoleAttTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img_1")
	bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideRoleAttTips()
        end
    end)
    local bgimg1 = bgimg:getChildByName('bg_img_2')
    local bgimg2 = bgimg1:getChildByName('bg_img_3')
    self:adaptUI(bgimg, bgimg1)
    bgimg1:setPosition(cc.p(480,560))
    local baseatt = self.obj:getCalBaseAtt()
    local att = RoleData:getPosAttByPos(self.obj)
	local attconf =GameData:getConfData('attribute') 
    for i=1,4 do
    	local attdesc = bgimg2:getChildByName('att_'..i..'_desc')
    	local attnum  = bgimg2:getChildByName('att_'..i..'_num')
    	local attedesc = bgimg2:getChildByName('atte_'..i..'_desc')
    	local attenum = bgimg2:getChildByName('atte_'..i..'_num')
    	attdesc:setString(GlobalApi:getLocalStr('ROLE_ATT_TIPS_DESC1') .. attconf[i].name)
    	attnum:setString(math.floor(baseatt[i]))
    	attedesc:setString(GlobalApi:getLocalStr('ROLE_ATT_TIPS_DESC2') .. attconf[i].name)
    	attenum:setString(math.floor(att[i] - baseatt[i]))
    end
end

return RoleAttTipsUI