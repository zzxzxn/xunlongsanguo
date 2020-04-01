local CloudBuyMyCodeUI = class("CloudBuyMyCodeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CloudBuyMyCodeUI:ctor(data)
	self.uiIndex = GAME_UI.UI_CLOUD_BUY_MY_CODE
	self.data = data
end

function CloudBuyMyCodeUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self:adaptUI(bgImg, bgImg1)
	self.bgImg1 = bgImg1

	local winSize = cc.Director:getInstance():getWinSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

	local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:hideUI()
		end
	end)
	local bgImg2 = bgImg1:getChildByName("bg_img2")
	local sv = bgImg2:getChildByName('sv')
	sv:setScrollBarEnabled(false)
	local titleBgImg = bgImg1:getChildByName("title_bg_img")
	local infoTx = titleBgImg:getChildByName("info_tx")
	infoTx:setString(GlobalApi:getLocalStr("ACTIVITY_CLOUD_BUY_DESC_14"))

	local node = cc.Node:create()
	sv:addChild(node)
	local size = sv:getContentSize()
	local diff = 6
	local maxNum = #self.data.code
	for i=1,maxNum do
		local descTx = ClassItemCell:updateTTFlabel(node,self.data.code[i],nil,26,'code_tx_'..i,nil,
			cc.p(size.width/2,-diff),nil,nil,nil,nil,cc.p(0.5,1))
		diff = diff + descTx:getContentSize().height + 6
		if i ~= maxNum then
			local lineImg = ClassItemCell:updateImageView(node,'uires/ui/common/common_tiao_4.png','line_img_'..i,nil,nil,
				cc.p(0,-diff),cc.p(0,0.5))
			lineImg:setScale9Enabled(true)
			lineImg:setContentSize(cc.size(size.width,lineImg:getContentSize().height))
			diff = diff + 6
		end
	end
	if size.height > diff then
		node:setPosition(cc.p(0,size.height/2 + diff/2))
		sv:setInnerContainerSize(size)
	else
		node:setPosition(cc.p(0,diff))
		sv:setInnerContainerSize(cc.size(size.width,diff))
	end
end

return CloudBuyMyCodeUI