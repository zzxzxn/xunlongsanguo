local RoleProfessTipsUI = class("RoleProfessTipsUI", BaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
function RoleProfessTipsUI:ctor(obj,pos)
	self.uiIndex = GAME_UI.UI_PROFESSTIPS
	self.obj =obj
	self.pos =pos
end

function RoleProfessTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img_1")
	bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideProfessTips()
        end
    end)
    local bgimg1 = bgimg:getChildByName('bg_img_2')
    local bgimg2 = bgimg1:getChildByName('bg_img_3')
    self:adaptUI(bgimg, bgimg1)
    bgimg1:setPosition(cc.p(480,560))
    
	local professimg = bgimg2:getChildByName('profess_img')
	local nametx = bgimg2:getChildByName('name_tx')
	nametx:setString(GlobalApi:getLocalStr('PROFESSION_TITLE')..GlobalApi:getLocalStr(tostring('PROFESSION3_DESC')..self.obj:getSoldierId()))
	professimg:loadTexture(self.obj:getProfessionTypeImg())
	professimg:loadTexture('uires/ui/common/soldier_'..self.obj:getSoldierId()..'.png')
	professimg:ignoreContentAdaptWithSize(true)
	local desctx1 = bgimg2:getChildByName('desc_tx_1')
	desctx1:ignoreContentAdaptWithSize(false)
	desctx1:setTextAreaSize(cc.size(380,120))
	desctx1:setString(GlobalApi:getLocalStr(tostring('PROFESSION_DESC')..self.obj:getSoldierId()))
	local desctx = bgimg2:getChildByName('desc_tx')
	desctx:setString(GlobalApi:getLocalStr(tostring('PROFESSION2_DESC')..self.obj:getSoldierId()))
end

return RoleProfessTipsUI