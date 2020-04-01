local ShippersSuccessUI = class("ShippersSuccessUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local function getCurColorText(id)
	local strBuff = ''
	local conf = GameData:getConfData('shipper')
	for k, v in pairs(conf) do
		if tonumber(v.shipper) == id then
			strBuff = v.desc
		end
	end
	return strBuff
end

function ShippersSuccessUI:ctor(type, award,ntype,name)
	self.uiIndex = GAME_UI.UI_SHIPPERSSUCCESS
	self.type = type
	self.ntype = ntype
	self.name = name
	self.award = award
end

function ShippersSuccessUI:init()
	local successBgImg = self.root:getChildByName("success_bg_img")
    self.successImg = successBgImg:getChildByName('success_img')
    self:adaptUI(successBgImg,  self.successImg)

	local OKBtn = self.successImg:getChildByName('ok_btn')
	local okTx = OKBtn:getChildByName('ok_tx')
	okTx:setString(GlobalApi:getLocalStr('STR_OK2'))
	OKBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			ShippersMgr:hideShippersSuccess()
		end
	end)

	local infoIco = self.successImg:getChildByName('info_ico')
	local infoTx = infoIco:getChildByName('info_tx')
	infoTx:setString('')
	local textBgIco = self.successImg:getChildByName('text_bg_ico')
	local textIco = textBgIco:getChildByName('text_ico')
	if self.ntype ~= 2 then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(500, 30))
		richText:setAlignment('middle')
		local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_SUCC'),21,COLOR_TYPE.WHITE)
		re:setStroke(COLOR_TYPE.BLACK, 1)
	    local re1 = xx.RichTextLabel:create(getCurColorText(self.type),21,COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_GET_AWARD'),21,COLOR_TYPE.WHITE)
	    re2:setStroke(COLOR_TYPE.BLACK, 1)
	    richText:addElement(re)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(449.5,27))
	    infoIco:addChild(richText)
	    textIco:loadTexture('uires/ui/text/yunsongchenggong.png')
	    textIco:ignoreContentAdaptWithSize(true)
	else
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(500, 30))
		richText:setAlignment('middle')
		local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_PLUNDER_SUCC'),21,COLOR_TYPE.WHITE)
		re:setStroke(COLOR_TYPE.BLACK, 1)
	    local re1 = xx.RichTextLabel:create(self.name,21,COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SHIPPER_DE'),21,COLOR_TYPE.WHITE)
	    re2:setStroke(COLOR_TYPE.BLACK, 1)
	    local re3 = xx.RichTextLabel:create(getCurColorText(self.type),21,COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	    richText:addElement(re)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:addElement(re3)
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(449.5,27))
	    infoIco:addChild(richText)
	    textIco:loadTexture('uires/ui/text/lueduochenggong.png')
	    textIco:ignoreContentAdaptWithSize(true)
	end

	local awards = DisplayData:getDisplayObjs(self.award)
	local photoNode = self.successImg:getChildByName('photo_node')
	local photoCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[1], photoNode)
    if awards[1]:getExtraBg() then
        photoCell.doubleImg:setVisible(true)
    else
        photoCell.doubleImg:setVisible(false)
    end
    if awards[2] then
    	local photoNode2 = self.successImg:getChildByName('photo_node2')
		local photoCell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[2], photoNode2)
		local posX = photoNode:getPositionX()
        photoCell.awardBgImg:setPositionX(posX - 100)
        if awards[2]:getExtraBg() then
            photoCell2.doubleImg:setVisible(true)
        else
            photoCell2.doubleImg:setVisible(false)
        end
    end
end

return ShippersSuccessUI