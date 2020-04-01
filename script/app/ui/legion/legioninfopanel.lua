local LegionInfoUI = class("LegionInfoUI", BaseUI)

function LegionInfoUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONINFOUI
  self.data = data
end

function LegionInfoUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionInfoUI()
    --     end
    -- end)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionInfoUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local legionglobalconf = GameData:getConfData('legion')
    local legionlvconf = GameData:getConfData('legionlevel')
    -- local titlebg = bgimg2:getChildByName('title_bg')
    -- local titletx = titlebg:getChildByName('title_tx')
    -- titletx:setString(GlobalApi:getLocalStr('LEGION_INFO_TITLE'))
    local legionnametx = bgimg2:getChildByName('legion_name_tx')
    legionnametx:setString(self.data.name)

    local iconbg = bgimg2:getChildByName('icon_bg_img')
    local iconimg = iconbg:getChildByName('icon_img')
    iconimg:loadTexture('uires/ui/legion/legion_'..self.data.icon..'_jun.png')

    --local bgimg3 = bgimg2:getChildByName('bg_img2')
    local bgimg3 = bgimg2:getChildByName('bg_img3')
    local leadernametx = bgimg3:getChildByName('leader_name_tx')
    local leaderdesctx = bgimg3:getChildByName('leader_desc_tx')
    leaderdesctx:setString(GlobalApi:getLocalStr('LEGION_POS1')..':')
    leadernametx:setString(self.data.leader)
    local lvbg = bgimg3:getChildByName('lv_bg')
    local lvtx = lvbg:getChildByName('lv_tx')
    -- local lvdesctx = bgimg3:getChildByName('lv_desc_tx')
    -- lvdesctx:setString(GlobalApi:getLocalStr('LEGION_LV')..':')
    lvtx:setString('LV'..self.data.level)
    local activitytx = bgimg3:getChildByName('activity_tx')
    local activitydesctx = bgimg3:getChildByName('activity_desc_tx')
    activitydesctx:setString(GlobalApi:getLocalStr('VITALITY')..':')
    activitytx:setString(self.data.xp..'/'..legionlvconf[self.data.level].xp)
    local numbertx = bgimg3:getChildByName('number_tx')
    local numberdesctx = bgimg3:getChildByName('number_desc_tx')
    numberdesctx:setString(GlobalApi:getLocalStr('LEGION_DESC2'))
    numbertx:setString(LegionMgr:getMemberCount(self.data.members)..'/'..legionlvconf[self.data.level].memberMax)
    local infotx = bgimg2:getChildByName('info_tx')
    infotx:setString(GlobalApi:getLocalStr('LEGION_INFO_DESC'))

    local bgimg4 = bgimg2:getChildByName('bg_img4')
    local legionranktx = bgimg4:getChildByName('rank_tx')
    legionranktx:setString(self.data.rank)
    local legionrankdesctx = bgimg4:getChildByName('rank_desc_tx')
    legionrankdesctx:setString(GlobalApi:getLocalStr('LEGION_DESC4'))
end

return LegionInfoUI