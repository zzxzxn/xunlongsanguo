local RoleOneLevelPannelUI = class("RoleOneLevelPannelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleOneLevelPannelUI:ctor(data,desc,callBack)
    self.uiIndex = GAME_UI.UI_ROLE_LV_UP_ONE_LEVEL_PANNEL
    self.data = data
    self.callBack = callBack
    self.desc = desc
end

function RoleOneLevelPannelUI:init()
    local activeBgImg = self.root:getChildByName("active_bg_img")
    local activeImg = activeBgImg:getChildByName("active_img")
    self:adaptUI(activeBgImg, activeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    activeImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.neiBgImg = activeImg:getChildByName('nei_bg_img')
    local closeBtn = activeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleOneLevelPannel()
        end
    end)
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('STR_ROLE_LVUP_DES1'))

    local cancleBtn = self.neiBgImg:getChildByName('cancle_btn')
    cancleBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('GIVE_UP_TEXT'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleOneLevelPannel()
        end
    end)

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('MINE_DES9'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.callBack then
                self.callBack()
            end
            RoleMgr:hideRoleOneLevelPannel()
        end
    end)

    local descTx = self.neiBgImg:getChildByName('desc_tx')
    descTx:setString(self.desc)


    local icon1 = self.neiBgImg:getChildByName('icon1')
    local icon2 = self.neiBgImg:getChildByName('icon2')
    local icon3 = self.neiBgImg:getChildByName('icon3')
    local icon4 = self.neiBgImg:getChildByName('icon4')

    local num = #self.data
    local pos = {
	    [1] = {cc.p(231,165)},
	    [2] = {cc.p(164,165),cc.p(298,165)},
	    [3] = {cc.p(121,165),cc.p(231,165),cc.p(341,165)},
	    [4] = {cc.p(66,165),cc.p(176,165),cc.p(286,165),cc.p(396,165)},
	}

	for i=1,4 do
		local icon = self.neiBgImg:getChildByName('icon'..i)
		if self.data[i] then
			icon:setVisible(true)
			local award = DisplayData:getDisplayObj(self.data[i])
			local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, icon)
			cell.awardBgImg:setPosition(cc.p(94/2,94/2))
			icon:setPosition(pos[num][i])
			local godId = award:getGodId()
			award:setLightEffect(cell.awardBgImg)
		else
			icon:setVisible(false)
		end
    end
end

return RoleOneLevelPannelUI