local RolePromoteUpgradeUI = class('RolePromoteUpgradeUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RolePromoteUpgradeUI:ctor(obj, fromAttr, toAttr,name, func)
	self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_UPGRADE_PANEL
	-- logic data
	self.obj = obj
	self.fromAttr = fromAttr
	self.toAttr = toAttr
	self.func = func
	self.name = name 
	-- ui data
	self.bg_node = nil
end

function RolePromoteUpgradeUI:init()
	local bg = self.root:getChildByName('bg')
	local bg1 = bg:getChildByName('bg1')
	self.bg_node = bg1

	self:adaptUI(bg, bg1)

    local winSize = cc.Director:getInstance():getWinSize()

   
	local attribute_bg = bg1:getChildByName('upgrade_bg')
		:getChildByName('attribute_bg')

	for i = 1, 4 do
		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('tx_1')
			:setString(GlobalApi:getLocalStr('STR_ATT' .. i))

		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('num_1')
			:setString(self.fromAttr[i])
	end

	for i = 1, 4 do
		local attbg = attribute_bg:getChildByName('att_' .. i)
		local tx = attbg:getChildByName('tx_2')
		tx:setString(GlobalApi:getLocalStr('STR_ATT' .. i))

		local num = attbg:getChildByName('num_2')
		num:setString(self.toAttr[i])
		local upimg = attbg:getChildByName('up')
		if self.toAttr[i] - self.fromAttr[i] > 0 then
			upimg:setVisible(true)
			num:setTextColor(COLOR_TYPE.GREEN)
		else
			upimg:setVisible(false)
			num:setTextColor(COLOR_TYPE.WHITE)
		end
	end
	local upgradebg = bg1:getChildByName('upgrade_bg')
	local titlebg = upgradebg:getChildByName('title_bg')
	local titilename = titlebg:getChildByName('title_tx')
	titilename:setString(self.name)
	self:inithead()
	-- play effect
	AudioMgr.playEffect("media/effect/soldier_upgrade.mp3", false)
	bg1:getChildByName('light')
		:runAction(cc.RepeatForever:create(
			cc.RotateBy:create(0.5, 20)))

	local bg_size = bg:getContentSize()
	bg:getChildByName('press_tx')
		:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
		:setPositionX(bg_size.width / 2)
		:setLocalZOrder(9999)
		:setVisible(false)
	local tip_frame = bg1:getChildByName('tip_frame')
	tip_frame:setPositionY(tip_frame:getPositionY() + 50)
	bg1:setScale(0.1)
	bg1:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.3, 1), 
		cc.CallFunc:create(function ()
			tip_frame:runAction(cc.Sequence:create(
				cc.JumpBy:create(0.13, cc.p(0, -50), 0, 1),
				cc.JumpBy:create(0.2, cc.p(0, 0), 20, 1),
				cc.JumpBy:create(0.08, cc.p(0, 0), 5, 1),
				cc.CallFunc:create(function ()
					bg:addClickEventListener(function ()
						bg:addClickEventListener(function()end)
							RoleMgr:hideRolePromotedUpgradeUI()
							if self.func ~= nil then
								self.func()
							end
					end)
					bg:getChildByName('press_tx')
						:setVisible(true)
						:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
						:setFontName('font/gamefont.ttf')
						:runAction(cc.RepeatForever:create(
							cc.Sequence:create(cc.FadeOut:create(1.2),
							cc.FadeIn:create(1.2))))
				end)))
		end)))
end

function RolePromoteUpgradeUI:inithead()
	local tip_frame = self.bg_node:getChildByName('tip_frame')
	local name = tip_frame:getChildByName('title_tx')
	if  self.obj:getTalent() > 0  then
		name:setString(self.obj:getName().. ' +' .. self.obj:getTalent())
	else
		name:setString(self.obj:getName())
	end
	name:setTextColor(self.obj:getNameColor())
	local headnode = tip_frame:getChildByName('head_node')
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.obj, headnode)
end

return RolePromoteUpgradeUI