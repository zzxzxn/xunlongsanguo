local ChickenSuitUI = class("ChickenSuitUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ChickenSuitUI:ctor(page)
	self.uiIndex = GAME_UI.UI_CHICKEN_SUIT
	self.page = page or 1
	self.pageBtns = {}
	self.listVs = {}
	self.lockRTs1 = {}
	self.lockRTs2 = {}
end

function ChickenSuitUI:init()
	local chickenBgImg = self.root:getChildByName("chicken_bg_img")
	local bgImg = chickenBgImg:getChildByName("bg_img")
	local lightImg = chickenBgImg:getChildByName("light_img")
    self:adaptUI(chickenBgImg, bgImg)
    self:adaptUI(chickenBgImg, lightImg)
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(8, 360)))
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local equips = {150602,250602,350602,450602,550602,650602}
    local pos = {cc.p(145,95),cc.p(215,95),cc.p(285,95),cc.p(255,20),cc.p(325,20),cc.p(395,20)}
	for i=1,6 do
		local equip = DisplayData:getDisplayObj({'equip',equips[i],0,1})
	    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equip, bgImg)
	    tab.awardBgImg:setScale(0.7)
	    tab.awardBgImg:setPosition(pos[i])
    	tab.lvTx:setString('Lv.'..equip:getLevel())
	end

	local descTx = bgImg:getChildByName("desc_tx")
	descTx:setString(GlobalApi:getLocalStr('CHICKEN_DESC'))

    local closeBtn = bgImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideChickenSuitUI()
	    end
	end)

	local buyBtn = bgImg:getChildByName("buy_btn")
	local infoTx = buyBtn:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr('TAVERN_BUY'))
	buyBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			ActivityMgr:showActivityPage('privilege')
	    end
	end)
end

return ChickenSuitUI