local RoleSelectFightCell = require("script/app/ui/role/roleselectfightcell")

local RoleSelectFightUI = class("RoleSelectFightUI", BaseUI)

function RoleSelectFightUI:ctor(callback)
    self.uiIndex = GAME_UI.UI_ROLE_SELECT_FIGHT
    self.callback = callback
end

function RoleSelectFightUI:init()
	local bg_img = self.root:getChildByName("bg_img")
	local bg_node = bg_img:getChildByName("bg_node")
	self:adaptUI(bg_img, bg_node)

	local bg_img2 = bg_node:getChildByName("bg_img2")
	local sv = bg_img2:getChildByName("sv")
	local close_btn = bg_img2:getChildByName("close_btn")
	close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self:hideUI()
        end
    end)

	self.sv = bg_img2:getChildByName("sv")
	self.sv:setScrollBarEnabled(false)
	self.svSize = self.sv:getContentSize()
	self.svWidget = ccui.Widget:create()
	self.sv:addChild(self.svWidget)
    self:initCell()
end

function RoleSelectFightUI:initCell()
	local function goAndFight(index)
		local customObj = {
			cityId = 1,
			difficulty = 1,
			process = nil,
			selectedHeroes = {index}
		}
		BattleMgr:playBattle(BATTLE_TYPE.TIMELIMITDEFENCE, customObj, function ()
        end)
	end
	local roleArr = RoleData:getRoleMap()
	local totalHeight = 0
	local spacing = 10
	local num = 0
	for i, v in ipairs(roleArr) do
		if v:getId() > 0 then
			num = num + 1
			local cell = RoleSelectFightCell.new(v, function ()
				goAndFight(i)
			end)
			local cellHeight = cell:getHeight()
			local cellWidth = cell:getWidth()
			self.svWidget:addChild(cell:getNode())
			
			local column = math.floor((num-1)/2)
			if num % 2 == 0 then
				cell:setPosition(cc.p(self.svSize.width - cellWidth/2, -column*cellHeight - cellHeight/2 - spacing*column))
			else
				cell:setPosition(cc.p(cellWidth/2, -column*cellHeight - cellHeight/2 - spacing*column))
				totalHeight = totalHeight + cellHeight + spacing
			end
		end
	end
	totalHeight = totalHeight - spacing
	if totalHeight < self.svSize.height then
		totalHeight = self.svSize.height
	end
	self.sv:setInnerContainerSize(cc.size(self.svSize.width, totalHeight))
	self.svWidget:setPosition(cc.p(0, totalHeight))
end

return RoleSelectFightUI