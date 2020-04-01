local MilitaryEntranceUI = class("ExclusiveRecruitEntranceUI", BaseUI)

function MilitaryEntranceUI:ctor()
    self.uiIndex = GAME_UI.UI_MILITARY_ENTRANCE

end

function MilitaryEntranceUI:init()
    local mine_bg_img = self.root:getChildByName("mine_bg_img")
    local counter_img = mine_bg_img:getChildByName("counter_img")
    local winSize = cc.Director:getInstance():getWinSize()
    mine_bg_img:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))

    local close_btn = counter_img:getChildByName("close_btn")
    close_btn:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        MainSceneMgr:hideMilitaryEntranceUI()
    end)


    local img_2 = counter_img:getChildByName("img_2")
    local title_tx = img_2:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("OPEN_RANK_RANK_DESC_4"))
    img_2:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        MainSceneMgr:showMilitary()
        MainSceneMgr:hideMilitaryEntranceUI()
    end)
    local info_tx = img_2:getChildByName("info_tx")
    info_tx:setString(GlobalApi:getLocalStr("OPEN_RANK_RANK_DESC_6"))

    local goldImg = img_2:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getMilitarySign())

    local img_3 = counter_img:getChildByName("img_3")
    local title_tx2 = img_3:getChildByName("title_tx")
    title_tx2:setString(GlobalApi:getLocalStr("OPEN_RANK_RANK_DESC_5"))
    img_3:addClickEventListener(function ()
        AudioMgr.PlayAudio(11)
        WarCollegeMgr:showWarCollege()
		MainSceneMgr:hideMilitaryEntranceUI()
    end)
    local info_tx2 = img_3:getChildByName("info_tx")
    info_tx2:setString(GlobalApi:getLocalStr("OPEN_RANK_RANK_DESC_7"))

    local goldImg = img_3:getChildByName("icon"):getChildByName("mark")
    goldImg:setVisible(UserData:getUserObj():getWarCollegeSign())

	--[[if UserData:getUserObj():judgeWarCollegeSign() == false then
		counter_img:setContentSize(cc.size(370,445))
		local img1 = counter_img:getChildByName('img_1')
		img1:setContentSize(cc.size(370,53))
		img1:setPositionX(185.00)
		close_btn:setPosition(cc.p(367.00,438.80))
		img_3:setVisible(false)
	end
	-]]
end

return MilitaryEntranceUI