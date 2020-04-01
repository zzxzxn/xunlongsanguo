local MilitaryUI = class("MilitaryUI", BaseUI)

function MilitaryUI:ctor(id)
	self.uiIndex = GAME_UI.UI_MILITARYGETWAYUI
	self.id = id
end

function MilitaryUI:onShow()
	self:updatePanel()
end

function MilitaryUI:updatePanel()
	local conf = GameData:getConfData("local/resget")[self.id]
	local getway = conf.getway
	local star = conf.star
	for i=1,#getway do
		local item = self.list:getItem(i - 1)
		if not item then
			self.list:pushBackDefaultItem()
			item = self.list:getItem(i - 1)
		end
		local getwayConf = GameData:getConfData("local/resgetway")[getway[i]]
		local awardImg = item:getChildByName('award_img')
		local nameTx = item:getChildByName('name_tx')
		local gotoBtn = item:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		awardImg:loadTexture('uires/icon/dailytask/'..getwayConf.icon)
		nameTx:setString(getwayConf.name)
		for j=1,5 do
			local starBgImg = item:getChildByName('star_bg_'..j..'_img')
			local starImg = starBgImg:getChildByName('star_img')
			starImg:setVisible(j <= star[i])
		end
		gotoBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	if getwayConf.args == 0 then
            		GlobalApi:getGotoByModule(getwayConf.goto,nil,nil)
            	else
            		GlobalApi:getGotoByModule(getwayConf.goto,nil,getwayConf.args)
            	end
            end
        end)
	end
	local tab
	if tonumber(conf.type1) then
		tab = {conf.type,tonumber(conf.type1),1}
	else
		tab = {conf.type,conf.type1,1}
	end
	local award = DisplayData:getDisplayObj(tab)
	local nameTx = self.bgImg1:getChildByName('name_tx')
	local awardImg = self.bgImg1:getChildByName('award_img')
	local frameImg = self.bgImg1:getChildByName('frame_img')
	local descTx = self.bgImg1:getChildByName('desc_tx')
	local numTx = self.bgImg1:getChildByName('num_tx')
	frameImg:loadTexture(award:getBgImg())
	awardImg:loadTexture(award:getIcon())
	nameTx:setString(conf.name)
	if conf.type ~= 'gem' and conf.type ~= 'dress' then
		descTx:setString(GlobalApi:getLocalStr("TAVERN_LIMIT_GET_DES5")..'：')
		numTx:setString(award:getOwnNum())
	else
		descTx:setString('')
		numTx:setString('')
	end
end

function MilitaryUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	self.bgImg1 = bgImg1
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    -- bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideMilitaryGetWay()
	    end
	end)

	self.list = bgImg1:getChildByName('list')
	self.list:setScrollBarEnabled(false)
	local node = cc.CSLoader:createNode('csb/militarygetwaycell.csb')
	local bgImg = node:getChildByName('bg_img')
	bgImg:removeFromParent(false)
	self.list:setItemModel(bgImg)
	self.list:setItemsMargin(4)

	self:updatePanel()
end

return MilitaryUI