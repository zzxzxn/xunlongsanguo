local SoldierEquipTipsUI = class("SoldierEquipTipsUI", BaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
function SoldierEquipTipsUI:ctor(obj,index,pos)
	self.uiIndex = GAME_UI.UI_SOLDIEREQUIPTIPS
	self.obj =obj
	self.index =index
	self.pos =pos
end

function SoldierEquipTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideSoldierEquipTips()
        end
    end)
	local bgimg1 = bgimg:getChildByName('bg_img_1')
	local bgimg2 = bgimg1:getChildByName('bg_img_2')
	self:adaptUI(bgimg, bgimg1)
	local soldierdressConf = GameData:getConfData('dress')
	local equiparr = self.obj:getSoldierArmArr()
	local img = 'uires/icon/dress/' .. soldierdressConf[equiparr[self.index].id]['icon']
	self.equipobj = BagData:getDressById(equiparr[self.index].id) or  ClassDressObj.new(tonumber(equiparr[self.index].id), 0)


	local iconbg = bgimg2:getChildByName('icon_bg_img')
	local iconimg = iconbg:getChildByName('icon_img')
	iconimg:loadTexture(img)
	iconbg:loadTexture(COLOR_ITEMFRAME.YELLOW)
	local nametx = bgimg2:getChildByName('name_tx')
	nametx:setString(self.equipobj:getName())
	-- local att1 = pl:getChildByName('att_1_tx')
	-- local att2 = pl:getChildByName('att_2_tx')	
	local soldierid = self.obj:getSoldierId()
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][self.obj:getSoldier().level]
	local soldconf = GameData:getConfData('soldier')[soldlevelconf['soldierId']]

	local dressconf = GameData:getConfData('dress')[self.equipobj:getId()]
    local attarr = {}
    for i=1,2 do
        local attid = dressconf['att'.. i]
        local attconf = GameData:getConfData('attribute')[attid]
        local value1 = dressconf['value'.. i]
        local desc = bgimg2:getChildByName('desc_'..i)
        local att = bgimg2:getChildByName('att_' .. i)
        if tonumber(attid) == 1 then
        	value1 = value1*soldconf['attPowPercent']/100
        elseif tonumber(attid) == 2 then
        	value1 = value1*soldconf['phyArmPowPercent']/100
        elseif tonumber(attid) == 3 then
        	value1 = value1*soldconf['magArmPowPercent']/100
        elseif tonumber(attid) == 4 then
        	value1 = value1*soldconf['heaPowPercent']/100
        end

        local str = GlobalApi:roundOff(value1,1) 
        if tonumber(str) > 0 then
	        desc:setString(attconf.name)
	        att:setString('+' .. str)
	    else
	    	desc:setString('')
	    	att:setString('')
	    end
    end
    bgimg2:setPosition(self.pos)
end

return SoldierEquipTipsUI