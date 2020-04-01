local MineEntranceUI = class("MineEntranceUI", BaseUI)

local function getTime(t)
    local h = string.format("%02d", math.floor(t/3600))
    local m = string.format("%02d", math.floor(t%3600/60))
    local s = string.format("%02d", math.floor(t%3600%60%60))
    return h..':'..m..':'..s
end

function MineEntranceUI:ctor()
    self.uiIndex = GAME_UI.UI_MINEENTRANCE
end

function MineEntranceUI:init()
    local mine_bg_img = self.root:getChildByName("mine_bg_img")
    local counter_img = mine_bg_img:getChildByName("counter_img")
    local winSize = cc.Director:getInstance():getWinSize()
    -- mine_bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    self:adaptUI(mine_bg_img, counter_img)

    local close_btn = counter_img:getChildByName("close_btn")
    close_btn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        GoldmineMgr:hideMineEntrance()
    end)

    -- 金矿
    local img_2 = counter_img:getChildByName("img_2")
    local title_tx = img_2:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("GLODMINE_CRAFT"))
    img_2:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        GlobalApi:getGotoByModule("goldmine")
        -- GoldmineMgr:hideMineEntrance()
    end)
    local info_tx = img_2:getChildByName("info_tx")
    info_tx:setString(GlobalApi:getLocalStr("MINE_ENTRANCE_INFO_1"))

    local goldImg = img_2:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getSignByType('goldmine'))

    -- 挖矿
    local img_3 = counter_img:getChildByName("img_3")
    local title_tx2 = img_3:getChildByName("title_tx")
    title_tx2:setString(GlobalApi:getLocalStr("COLLECT_MINE"))
    img_3:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        GlobalApi:getGotoByModule("digging")
        -- GoldmineMgr:hideMineEntrance()
    end)
    local info_tx2 = img_3:getChildByName("info_tx")
    info_tx2:setString(GlobalApi:getLocalStr("MINE_ENTRANCE_INFO_2"))

    local goldImg = img_3:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getSignByType('digging'))
end

return MineEntranceUI