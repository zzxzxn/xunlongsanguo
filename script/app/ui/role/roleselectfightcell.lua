local RoleSelectFightCell = class("RoleSelectFightCell")

function RoleSelectFightCell:ctor(data, callback)
	self.root = cc.CSLoader:createNode("csb/roleselectfightcell.csb")
	local bg_img = self.root:getChildByName("bg_img")
	self.cellSize = bg_img:getContentSize()

	local icon_img = bg_img:getChildByName("icon_img")
	local icon_bg_img = icon_img:getChildByName("icon_bg_img")
	local icon = icon_bg_img:getChildByName("icon")
	icon_bg_img:loadTexture(data:getBgImg())
	icon:loadTexture(data:getIcon())

	local fightforce_img = bg_img:getChildByName("fightforce_img")
	local posx, posy = fightforce_img:getPosition()
	local fightforceLabel = cc.LabelAtlas:_create(data:getFightForce(), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightforceLabel:setScale(0.8)
	fightforceLabel:setAnchorPoint(cc.p(0, 0.5))
	fightforceLabel:setPosition(cc.p(posx + 20, posy))
	bg_img:addChild(fightforceLabel)

	local namebg_img = bg_img:getChildByName("namebg_img")
	local name_tx = namebg_img:getChildByName("name_tx")
	name_tx:setString(data:getName())
	name_tx:setColor(data:getNameColor())
	local soldiertype_img = namebg_img:getChildByName("soldiertype_img")
	soldiertype_img:loadTexture("uires/ui/common/soldier_" .. data:getSoldierId() .. ".png")
	local lv_tx = namebg_img:getChildByName("lv_tx")
	lv_tx:setString(tostring(data:getLevel()))

	local fight_btn = bg_img:getChildByName("fight_btn")
	local fight_text = fight_btn:getChildByName("text")
	fight_text:setString(GlobalApi:getLocalStr("GO_AND_FIGHT"))
	fight_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if callback then
        		callback()
        	end
        end
    end)
end

function RoleSelectFightCell:getNode()
	return self.root
end

function RoleSelectFightCell:setPosition(p)
	self.root:setPosition(p)
end

function RoleSelectFightCell:getHeight()
	return self.cellSize.height
end

function RoleSelectFightCell:getWidth()
	return self.cellSize.width
end

return RoleSelectFightCell