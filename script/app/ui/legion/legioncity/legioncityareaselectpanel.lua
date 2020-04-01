local LegionCityAreaSelectUI = class("LegionCityAreaSelectUI", BaseUI)

function LegionCityAreaSelectUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONCITYAREASELECTUI
  self.data = data
end

function LegionCityAreaSelectUI:onShow()
    self:update()
end
function LegionCityAreaSelectUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img2')
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionCityAreaSelectUI()
        end
    end)
    for i=1,4 do
        local areabtn = bgimg2:getChildByName('area_'..i..'_btn')
        local areabtntx = areabtn:getChildByName('btn_tx')
        areabtntx:setString(GlobalApi:getLocalStr('LEGION_CITY_AREA'..i))
        local infoimg = areabtn:getChildByName('info_img')
        infoimg:setVisible(false)
        areabtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:ChangePage(i)
                LegionMgr:hideLegionCityAreaSelectUI()
            end
        end)
    end
end

function LegionCityAreaSelectUI:update()

end


return LegionCityAreaSelectUI