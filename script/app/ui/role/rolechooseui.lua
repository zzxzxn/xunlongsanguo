--role_exchange.lua

local RoleCellAssist = require("script/app/ui/role/rolecellassist")

local RoleChooseUI = class("RoleChooseUI", BaseUI)

function RoleChooseUI:ctor()
	self.uiIndex = GAME_UI.UI_ROLECHOOSE
end

function RoleChooseUI:init()
	self.roleArr = {}
	self.cellList = {}
	self:initData()
	self:initUI()
	self:createCell()
end

function RoleChooseUI:initUI()

	local bgImg = self.root:getChildByName("bg_img")
	bgImg:setSwallowTouches(false)
	local closeBtn = bgImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleChoose()
        end
    end)

	local btnNode = bgImg:getChildByName("btn_node")
	for i=1,4 do
		self["btn_"..i] = btnNode:getChildByName("btn_"..i)
		self["btn_"..i]:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleList(i)
        end
    end)
	end

	self.roleNode = bgImg:getChildByName("role_node")
end

function RoleChooseUI:initData()
	for k, v in pairs(RoleData:getRoleMap()) do
		if v:getId() < 10000 then
			self.roleArr[tonumber(k)] = v
		end
	end
end

function RoleChooseUI:updateData()

end

function RoleChooseUI:createCell()
	for k,v in ipairs(self.roleArr) do
		self.cellList[k] = RoleCellAssist.new(self.roleNode, k,v)
		local panel = self.cellList[k]:getPanel()
		local bgimg = panel:getChildByName("bg_img")
		local size = bgimg:getContentSize()
		local preWidth = size.width + 10
		local y = 0
		local startX = -math.floor(#self.roleArr/2)*preWidth

		panel:setPosition(cc.p(startX + (k - 1)*preWidth, y))
		self.roleNode:addChild(panel)
	end
end

function RoleChooseUI:updateCell()

end

return RoleChooseUI