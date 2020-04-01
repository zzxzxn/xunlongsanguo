local DragonGemFragmentTips = class("DragonGemFragmentTips", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function DragonGemFragmentTips:ctor(position, fragment, callback)
    self.uiIndex = GAME_UI.UI_TIPS_DRAGONGEM_FRAGMENT
    self.tipsPosition = position
    self.fragment = fragment
    self.callback = callback
end

function DragonGemFragmentTips:init()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    bg_img:addClickEventListener(function ()
        TipsMgr:hideDragonGemFragmentTips()
    end)

    local bg_tips = self.root:getChildByName("bg_tips")
    bg_tips:setPosition(cc.pAdd(self.tipsPosition, cc.p(160, -60)))

    local icon_node = bg_tips:getChildByName("icon_node")
    local icon_cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.fragment, icon_node)
    icon_cell.awardBgImg:setTouchEnabled(false)
    icon_cell.lvTx:setVisible(false)
    local lv_img = bg_tips:getChildByName("lv_img")
    lv_img:setVisible(false)

    local name_tx = bg_tips:getChildByName("name_tx")
    name_tx:setColor(self.fragment:getNameColor())
    name_tx:setString(self.fragment:getName())

    local mount_btn = bg_tips:getChildByName("mount_btn")
    local mount_text = mount_btn:getChildByName("text")
    mount_text:setString(GlobalApi:getLocalStr("STR_MERGE_ALL"))

    local num =  math.floor(self.fragment:getOwnNum()/self.fragment:getMergeNum())
    if num > 0 then
        mount_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.callback then
                    self.callback()
                end
            end
        end)
    else
        mount_btn:setTouchEnabled(false)
        mount_btn:setBright(false)
        mount_text:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
    end

    local desc_1 = bg_tips:getChildByName("desc_1")
    desc_1:setFontSize(20)
    desc_1:setAnchorPoint(cc.p(0, 1))
    desc_1:setTextAreaSize(cc.size(200,150))
    local posy = desc_1:getPositionY()
    desc_1:setPositionY(posy + 26)
    desc_1:setString(self.fragment:getDesc())
end

return DragonGemFragmentTips