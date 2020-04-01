local PowerEndUI = class("PowerEndUI", BaseUI)
local BASE_YEAR = 221

function PowerEndUI:ctor(name,callback,id)
	self.uiIndex = GAME_UI.UI_POWEREND
    self.callback = callback
    self.name = name
    self.id = id
end

function PowerEndUI:eggsFly()
    local id = MapData.data[self.id]:getDragon() - 1
    local currChipImg
    local currEggImg
    for i=1,10 do
        local chipImg = self.bgImg2:getChildByName('chip_img_'..i)
        local index = i
        if i == 10 then
            index = 9
        end
        if i < id then
            chipImg:setVisible(true)
        elseif i == id then
            chipImg:setOpacity(0)
            currChipImg = chipImg
        else
            chipImg:setVisible(false)
        end
    end
    -- local size = self.bgImg2:getContentSize()
    -- currChipImg:runAction(cc.Sequence:create(
    --     cc.FadeIn:create(2),
    --     cc.CallFunc:create(function()
    --         MapData.data[self.id]:setBfirst(false)
    --         MapMgr:hidePowerEndPanel()
    --         if id == 10 then
    --             if self.callback then
    --                 self.callback()
    --             end
    --         else
    --             if MapData.data[self.id].conf.guideIndex == 0 then
    --                 local treasureInfo = UserData:getUserObj():getTreasure()
    --                 local active = tonumber(treasureInfo.active)
    --                 RoleData:createDragon(id + 1,{level = 1})
    --                 print("get me a umbrellar--------------------->")
    --                 MainSceneMgr:showDragonInfoUI(id + 1,nil,function ()
    --                     local args = {}
    --                     MessageMgr:sendPost('active','treasure',json.encode(args),function (response)
    --                         local code = response.code
    --                         local data = response.data
    --                         if code == 0 then
    --                             RoleData:setAllFightForceDirty()

    --                             treasureInfo.active = treasureInfo.active + 1
    --                             UserData:getUserObj():setTreasure(treasureInfo)

    --                             if data.awards then
    --                                 GlobalApi:parseAwardData(data.awards)
    --                             end
    --                             if data.costs then
    --                                 GlobalApi:parseAwardData(data.costs)
    --                             end

    --                             for i=1,7 do
    --                                 local obj = RoleData:getRoleByPos(i)
    --                                 if obj and obj:getId() > 0 then
    --                                     RoleMgr:popupTips(obj,true)
    --                                 end
    --                             end

    --                             MainSceneMgr:showTreasure(id + 1)
    --                         end
    --                         if self.callback then
    --                             self.callback()
    --                         end
    --                     end)
    --                 end)
    --             else
    --                 if self.callback then
    --                     self.callback()
    --                 end
    --             end
    --         end
    --     end)
    -- ))

    MapData.data[self.id]:setBfirst(false)
    MapMgr:hidePowerEndPanel()
    if id == 10 then
        if self.callback then
            self.callback()
        end
    else
        if MapData.data[self.id].conf.guideIndex == 0 then
            local treasureInfo = UserData:getUserObj():getTreasure()
            local active = tonumber(treasureInfo.active)
            RoleData:createDragon(id + 1,{level = 1})
            MainSceneMgr:showDragonInfoUI(id + 1,nil,function ()
                local args = {}
                MessageMgr:sendPost('active','treasure',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        RoleData:setAllFightForceDirty()

                        treasureInfo.active = treasureInfo.active + 1
                        UserData:getUserObj():setTreasure(treasureInfo)

                        if data.awards then
                            GlobalApi:parseAwardData(data.awards)
                        end
                        if data.costs then
                            GlobalApi:parseAwardData(data.costs)
                        end

                        for i=1,7 do
                            local obj = RoleData:getRoleByPos(i)
                            if obj and obj:getId() > 0 then
                                RoleMgr:popupTips(obj,true)
                            end
                        end

                        MainSceneMgr:showTreasure(id + 1)
                    end
                    if self.callback then
                        self.callback()
                    end
                end)
            end)
        else
            if self.callback then
                self.callback()
            end
        end
    end
end

function PowerEndUI:init()
    self.bgImg1 = self.root:getChildByName("bg_1_img")
    self.bgImg2 = self.root:getChildByName("bg_2_img")

    self.bgImg1:setVisible(false)
    self.bgImg2:setVisible(false)

    GlobalApi:imgScaleWinSize(self.bgImg2)

    self:eggsFly()
end

return PowerEndUI