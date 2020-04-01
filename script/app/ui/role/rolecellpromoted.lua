local RoleCellProMotedUI = class("RoleCellProMotedUI")
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function RoleCellProMotedUI:ctor(parentUI, index, obj)
	self.parentUI = parentUI
	self.obj = obj
	self.pos = self.obj:getPosId()
	self.index = index
	self.promote = self.obj:getPromoted()
	self:initPanel()
end

function RoleCellProMotedUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/rolecellpromoted.csb")
	local bgimg = panel:getChildByName("bg_img")
	bgimg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(bgimg)
	self.panel:setName("rolecellassist_" .. self.index)
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.openinfotx = bgimg:getChildByName('openinfo_tx')
	local bgicon = bgimg:getChildByName('icon_img')
	local iconbg = bgicon:getChildByName('icon_bg_img')
	self.icon = iconbg:getChildByName('icon_img')
	self.iconframe = iconbg
	self.probgimg = self.nor_pl:getChildByName('probg_img')
	
	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.info = self.nor_pl:getChildByName('info_img')
	self.info:setVisible(false)
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')

   	bgimg:setTouchEnabled(true)
   	local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    bgimg:addClickEventListener(function ()
		RoleMgr:showRolePromotedUI(self.obj:getPosId())
		RoleMgr:setSelectRolePos(self.obj:getPosId())
    end)
    local barbg = self.nor_pl:getChildByName('bar_bg')
    self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))
    self.bartx = barbg:getChildByName('bar_tx')
    self.typeimg = self.nor_pl:getChildByName('type_img')
end

function RoleCellProMotedUI:getPanel()
	return self.panel
end

function RoleCellProMotedUI:setVisible(vis)
	self.panel:setVisible(vis)
end


function RoleCellProMotedUI:upDateUI()
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.obj, self.icon)
	cell.awardBgImg:setPosition(cc.p(47,47))
	cell.awardBgImg:setTouchEnabled(false)

	if tonumber(self.obj:getId()) and tonumber(self.obj:getId()) > 0 then
		if  self.obj:getTalent() > 0  then
			self.name:setString(self.obj:getName().. ' +' .. self.obj:getTalent())
		else
			self.name:setString(self.obj:getName())
		end
		self.name:setTextColor(self.obj:getNameColor())
		self.soldiertypeimg:loadTexture('uires/ui/common/soldier_'..self.obj:getSoldierId()..'.png')
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
	end
	local lv = 0
	local protype = 0
	if self.promote and self.promote[1] then
		protype = self.promote[1]
		lv = self.promote[2]
	end

	if self.obj:getQuality() == 7 then
		self.bar:setPercent(100)
		self.bartx:setString(MAXPROMOTEDLV..'/'..MAXPROMOTEDLV)
	else
		local percent = math.floor(lv/MAXPROMOTEDLV*100)
		self.bar:setPercent(percent)
		self.bartx:setString(lv..'/'..MAXPROMOTEDLV)
	end
	if self.obj:getQuality() < 6 then
		self.typeimg:loadTexture('uires/ui/common/hero_red_icon.png')
	else
		self.typeimg:loadTexture('uires/ui/common/hero_gold_icon.png')
	end
	self.info:setVisible(self.obj:isCanrPromoted())
end

function RoleCellProMotedUI:setType(isBeassist )
	if self.obj:getId() ~= 0 then
	else
		self.nor_pl:setVisible(false)
		self.icon:ignoreContentAdaptWithSize(true)
	end
	self:upDateUI()
end

return RoleCellProMotedUI