local LegionCityListUI = class("LegionCityListUI", BaseUI)
local ClassLegionCityCompareUI = require('script/app/ui/legion/legioncity/legioncitycompare')

function LegionCityListUI:ctor(data)
    self.uiIndex = GAME_UI.UI_LEGIONCITYLISTUI
    self.data = data
    table.sort( self.data, function(a,b)
        if a[2].build_progress == b[2].build_progress then
            local f1 = a[2].fight_force
            local f2 = b[2].fight_force
            return f1 > f2
        end
        return a[2].build_progress > b[2].build_progress
    end )
end

function LegionCityListUI:onShow()
    self:update()
end
function LegionCityListUI:init()
    local bgimg = self.root:getChildByName("bg_big_img")
    local bgimg1 = bgimg:getChildByName('bg_img')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionCityListUI()
        end
    end)

    local node = cc.CSLoader:createNode("csb/legion_city_list_cell.csb")
    local cellbgimg = node:getChildByName("bg_img")
    self.listview = bgimg2:getChildByName('list_view')
    self.listview:setItemModel(cellbgimg)
    self.listview:setScrollBarEnabled(false)
    local titlbg = bgimg2:getChildByName('title_bg')
    local titletx =titlbg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC11'))

    local svTitleBg = bgimg2:getChildByName('sv_title_bg')
    svTitleBg:getChildByName('lv_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC25'))
    svTitleBg:getChildByName('name_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC26'))
    svTitleBg:getChildByName('pos_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC27'))
    svTitleBg:getChildByName('city_lv_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC28'))
    svTitleBg:getChildByName('city_state_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC29'))

    self:update()
end

function LegionCityListUI:update()
    self:initListView()
end


function LegionCityListUI:loadBy1FPS(amount, view, callback)
    local index = 0
    local function update()
        if index < amount then
            callback(index)
        else
            view:unscheduleUpdate()
        end
        index = index + 1
    end
    view:scheduleUpdateWithPriorityLua(update, 0)

end

function LegionCityListUI:initListView()
    if table.getn(self.listview:getItems()) == 0 then
        local function callback(index)
            self:initListItem(index)
        end
        print('#self.data'..#self.data)
        self:loadBy1FPS(#self.data, self.root, callback)
    end
end

function LegionCityListUI:initListItem(index)
    self.listview:pushBackDefaultItem()
    self:setListItem(index)
    local item = self.listview:getItem(index)
end

function LegionCityListUI:setListItem( index)
    local item = self.listview:getItem(index)
    local data = self.data[index+1] 
    item:setVisible(true)
    item:setName("legionlistcell_" .. index+1)
    self:updatecell(item,self.data[index+1],index+1)

end

function LegionCityListUI:updatecell( parent,data,pos )
    local bgimg1 = parent:getChildByName('bg_img')
    if pos%2 ~= 0 then
        bgimg1:setVisible(false)
    end
    local nametx = parent:getChildByName('name_tx')
    nametx:setString(data[2].un)
    local lvtx = parent:getChildByName('lv_tx')
    lvtx:setString(data[2].level)
    local postx = parent:getChildByName('pos_tx')
    postx:setString(GlobalApi:getLocalStr('LEGION_POS'..tonumber(data[2].duty)))
    local citylvtx = parent:getChildByName('citylv_tx')
    citylvtx:setString('Lv.'..tonumber(data[2].castle_level))
    local statetx = parent:getChildByName('state_tx')
    statetx:setString(tonumber(data[2].build_progress))
    --if tonumber(data[2].castle_status) == 0 then
        -- statetx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC20'))
        -- statetx:setTextColor(COLOR_TYPE.GREEN)
    -- else
    --     statetx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC21'))
    --     statetx:setTextColor(COLOR_TYPE.RED)
    -- end
    local funcbtn = parent:getChildByName('look_btn')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(data[1]) == UserData:getUserObj():getUid() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC32'), COLOR_TYPE.RED)
                return
            end
            local args = {
                target_uid = tonumber(data[1]),
            }
            MessageMgr:sendPost("get_player_territory_war_info", "territorywar", json.encode(args), function (jsonObj)
                -- print(json.encode(jsonObj))
                local code = jsonObj.code
                if code == 0 then
                    local newUI = ClassLegionCityCompareUI.new(jsonObj.data,data)
                    newUI:showUI()
                end
            end)
        end
    end)
end

return LegionCityListUI