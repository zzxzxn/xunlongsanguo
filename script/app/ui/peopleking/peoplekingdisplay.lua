local NBSkyDisplayUI = class("NBSkyDisplayUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function NBSkyDisplayUI:ctor(conf,pos)
	self.uiIndex = GAME_UI.UI_NB_SKY_DISPLAY
	self.conf = conf
	self.pos = pos
end

function NBSkyDisplayUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	
	local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(self.pos or cc.p(winSize.width/2 + 50,winSize.height/2 - 150))

	bgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			PeopleKingMgr:hidePeopleKingDsiplayUI()
		end
	end)

	local node = bgImg1:getChildByName('node')
	local nameTx = bgImg1:getChildByName('name_tx')
	local descTx1 = bgImg1:getChildByName('desc_tx_1')
	local descTx2 = bgImg1:getChildByName('desc_tx_2')
	local descTx3 = bgImg1:getChildByName('desc_tx_3')
	local descTx4 = bgImg1:getChildByName('desc_tx_4')
	local attrDescs = {'addAtk','addDef','addMdef','addHp'}
	nameTx:setString(self.conf.name)
	descTx1:setString(GlobalApi:getLocalStr("SOLDIER_DESC_2")..GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_"..self.conf.getway[1]))
	descTx4:setString(GlobalApi:getLocalStr("NB_SKY_DISPLAY_DESC_2"))
	local attr = {}
	local conf = GameData:getConfData("attribute")
	for i=1,4 do
		local attrTx = bgImg1:getChildByName('attr_tx_'..i)
		local numTx = bgImg1:getChildByName('num_tx_'..i)
		attrTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_"..self.conf.getway[1])..conf[i].name)
		numTx:setString('+'..self.conf[attrDescs[i]])
		attr[i] = self.conf[attrDescs[i]]
	end
	local fightForce = GlobalApi:getFightForcePre(attr)
	descTx2:setString(GlobalApi:getLocalStr("NB_SKY_DISPLAY_DESC_1")..':'..fightForce)
	local str = self.conf.getway[1] == 1 and 'skyweapon' or 'skywing'
	local param = {}
	local obj = DisplayData:getDisplayObj({str,15,2,1})
	local awardBgImg = ClassItemCell:updateAwardFrameByObj(node,obj,param)
end
return NBSkyDisplayUI