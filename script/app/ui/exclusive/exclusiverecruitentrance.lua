local ExclusiveRecruitEntranceUI = class("ExclusiveRecruitEntranceUI", BaseUI)

function ExclusiveRecruitEntranceUI:ctor()
    self.uiIndex = GAME_UI.UI_EXCLUSIVE_RECRUIT_ENTRANCE

end

function ExclusiveRecruitEntranceUI:init()
    local mine_bg_img = self.root:getChildByName("mine_bg_img")
    local counter_img = mine_bg_img:getChildByName("counter_img")
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- mine_bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    self:adaptUI(mine_bg_img, counter_img)

    local close_btn = counter_img:getChildByName("close_btn")
    close_btn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        ExclusiveMgr:hideExclusiveRecruitEntranceUI()
    end)

    -- 酒馆
    local img_2 = counter_img:getChildByName("img_2")
    local title_tx = img_2:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("EXCLUSIVE_DESC_73"))
    img_2:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        GlobalApi:getGotoByModule("tavern")
        -- ExclusiveMgr:hideExclusiveRecruitEntranceUI()
    end)
    local info_tx = img_2:getChildByName("info_tx")
    info_tx:setString(GlobalApi:getLocalStr("EXCLUSIVE_DESC_75"))

    local goldImg = img_2:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getSignByType('real_tavern'))

    -- 宝物
    local img_3 = counter_img:getChildByName("img_3")
    local title_tx2 = img_3:getChildByName("title_tx")
    title_tx2:setString(GlobalApi:getLocalStr("EXCLUSIVE_DESC_74"))
    img_3:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        GlobalApi:getGotoByModule("exclusive_check")
        -- ExclusiveMgr:hideExclusiveRecruitEntranceUI()
    end)
    local info_tx2 = img_3:getChildByName("info_tx")
    info_tx2:setString(GlobalApi:getLocalStr("EXCLUSIVE_DESC_76"))

    local goldImg = img_3:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getSignByType('exclusive_check'))
end

return ExclusiveRecruitEntranceUI