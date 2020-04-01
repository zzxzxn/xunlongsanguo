local DragonGemTips = class("DragonGemTips", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function DragonGemTips:ctor(position, dragonGem, callback)
    self.uiIndex = GAME_UI.UI_TIPS_DRAGONGEM
    self.tipsPosition = position
    self.dragonGem = dragonGem
    self.callback = callback
end

function DragonGemTips:init()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    bg_img:addClickEventListener(function ()
    	TipsMgr:hideDragonGemTips()
    end)

    local bg_tips = self.root:getChildByName("bg_tips")
    bg_tips:setPosition(cc.pAdd(self.tipsPosition, cc.p(160, -60)))

    local icon_node = bg_tips:getChildByName("icon_node")
    local icon_cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.dragonGem, icon_node)
    icon_cell.awardBgImg:setTouchEnabled(false)
    icon_cell.lvTx:setVisible(false)

    local lv_tx = bg_tips:getChildByName("lv_tx")
    lv_tx:setString(tostring(self.dragonGem:getLevel()))

    local name_tx = bg_tips:getChildByName("name_tx")
    name_tx:setColor(self.dragonGem:getNameColor())
    name_tx:setString(self.dragonGem:getName())

    local mount_btn = bg_tips:getChildByName("mount_btn")
    local mount_text = mount_btn:getChildByName("text")
    mount_text:setString(GlobalApi:getLocalStr("STR_MOUNT"))
    mount_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if self.callback then
        		self.callback()
        	end
        end
    end)

    local desc_1 = bg_tips:getChildByName("desc_1")
    desc_1:setString(GlobalApi:getLocalStr("TRARIN_DRAGON_GET_ATTR"))
    local posx = desc_1:getPositionX() + desc_1:getContentSize().width
    local desc_2 = bg_tips:getChildByName("desc_2")
    desc_2:setString(self.dragonGem:getAttNum() .. "%")
    desc_2:setPositionX(posx)

    posx = posx + desc_2:getContentSize().width
    local attconf = GameData:getConfData('attribute')
    local desc_3 = bg_tips:getChildByName("desc_3")
    desc_3:setString(attconf[self.dragonGem:getAttType()].name)
    desc_3:setPositionX(posx)
end

return DragonGemTips