local RoleLvUpOneLevelPannelUI = class("RoleLvUpOneLevelPannelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleLvUpOneLevelPannelUI:ctor(lvUpData,pos,callBack)
    self.uiIndex = GAME_UI.UI_ROLE_LV_UP_ONE_LEVEL_PANNEL
    self.lvUpData = lvUpData
    self.callBack = callBack
    self.pos = pos
end

function RoleLvUpOneLevelPannelUI:init()
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
            RoleMgr:hideRoleLvUpOneLevelPannel()
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
            RoleMgr:hideRoleLvUpOneLevelPannel()
        end
    end)

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('MINE_DES9'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
		        pos = self.pos
	        }
	        MessageMgr:sendPost("level_upone", "hero", json.encode(args), function (jsonObj)
                self.callBack(jsonObj)
                RoleMgr:hideRoleLvUpOneLevelPannel()
	        end)
        end
    end)

    local descTx = self.neiBgImg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('STR_ROLE_LVUP_DES2'))


	local icon1 = self.neiBgImg:getChildByName('icon1')
	local icon2 = self.neiBgImg:getChildByName('icon2')
	local icon3 = self.neiBgImg:getChildByName('icon3')
	local icon4 = self.neiBgImg:getChildByName('icon4')
	icon4:setVisible(false)

    local num = #self.lvUpData
    local temp = {}

    if num == 1 then
        icon1:setVisible(false)
        icon3:setVisible(false)
        table.insert(temp,icon2)
    elseif num == 2 then
        icon3:setVisible(false)
        icon1:setPositionX(164)
        icon2:setPositionX(298)
        table.insert(temp,icon1)
        table.insert(temp,icon2)
    else
        icon1:setPositionX(112)
        icon3:setPositionX(350)
        table.insert(temp,icon1)
        table.insert(temp,icon2)
        table.insert(temp,icon3)
    end

    local showItemAwards = { ["200001"] = {'material',200001,1},["200002"] = {'material',200002,1},["200003"] = {'material',200003,1}}
    for i = 1,num do
        local data = self.lvUpData[i]
        local id = data.id

        local frame = temp[i]
        local awards = DisplayData:getDisplayObj(showItemAwards[tostring(id)])
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.lvTx:setString(data.needMaxNum)
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
    end

end

return RoleLvUpOneLevelPannelUI