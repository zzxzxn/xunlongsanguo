local CloudBuyNoticeUI = class("CloudBuyNoticeUI", BaseUI)
local CloudBuyMyCodeUI = require("script/app/ui/activity/page_cloud_buy_my_code")
local ClassItemCell = require('script/app/global/itemcell')

function CloudBuyNoticeUI:ctor(data,page)
	self.uiIndex = GAME_UI.UI_CLOUD_BUY_NOTICE
	self.data = data
	self.page = page or 1
end

function CloudBuyNoticeUI:init()
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
	self.sv = bgImg2:getChildByName('sv')
	self.sv:setScrollBarEnabled(false)
	self:updatePanel()

	local titleBgImg = bgImg1:getChildByName("title_bg_img")
	local infoTx = titleBgImg:getChildByName("info_tx")

	if self.page == 1 then
		infoTx:setString(GlobalApi:getLocalStr("ACTIVITY_CLOUD_BUY_DESC_6"))
	else
		infoTx:setString(GlobalApi:getLocalStr("ACTIVITY_CLOUD_BUY_TITLE_2"))
	end
end

function CloudBuyNoticeUI:updateMyAward(bgImg,i)
	local awardsConf = GameData:getConfData("avcloudbuyawards")
	local descTx1 = bgImg:getChildByName('desc_tx_1')
	local descTx2 = bgImg:getChildByName('desc_tx_2')
	local cashTx = bgImg:getChildByName('cash_tx')
	local timesTx = bgImg:getChildByName('times_tx')
	local scoreTx = bgImg:getChildByName('score_tx')

	local data = self.data[i]
	descTx1:setString(GlobalApi:getLocalStr('STR_PRICE'))
	local str = {'LIMIT_DESC','ACTIVITY_CLOUD_BUY_DESC_5'}
	local ntype = 2
	if not data.time or data.time == 0 then
		descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_30'))
	else
		ntype = 1
		local now = os.date('*t',data.time)
		descTx2:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_31'),now.year,now.month,now.day,
			string.format('%02d',now.hour),
			string.format('%02d',now.min),
			string.format('%02d',now.sec)))
	end
	timesTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_12')..data.buy_num)
	scoreTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_13')..data.score)
	local codeBtn = bgImg:getChildByName('code_btn')
	local infoTx = codeBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_14'))
	cashTx:setString(awardsConf[data.aid].costs)
	
	local node = bgImg:getChildByName('node')
	local awardBgImg = node:getChildByName('award_bg_img')
	local award = DisplayData:getDisplayObj(awardsConf[data.aid].awards[1])
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, node)
		awardBgImg = tab.awardBgImg
		local size = awardBgImg:getContentSize()
		local signImg = ClassItemCell:updateImageView(awardBgImg,'uires/ui/common/corner_blue_'..ntype..'.png','sign_img',nil,nil,
			cc.p(size.width + 2,size.height + 2),cc.p(1,1))
		signImg:setScale(0.8)
		local infoTx = ClassItemCell:updateTTFlabel(signImg,GlobalApi:getLocalStr(str[ntype]),"font/gamefont.ttf",16,'info_tx',nil,cc.p(45,45))
		infoTx:setSkewX(45.38)
		infoTx:setSkewY(-45.38)
	end
	local nameTx = awardBgImg:getChildByName('name_tx')
	nameTx:setAnchorPoint(cc.p(0, 0.5))
	nameTx:setPosition(cc.p(110,70))
	nameTx:setString(award:getName())
	nameTx:setColor(award:getNameColor())
	
	local getBtn = bgImg:getChildByName('get_btn')
	local infoTx = getBtn:getChildByName('info_tx')
	-- infoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
	codeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local cloudBuyMyCodeUI = CloudBuyMyCodeUI.new(data,2)
			cloudBuyMyCodeUI:showUI()
		end
	end)
	getBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			local args = {
				aid = data.aid,
				rid = data.rid,
				pid = data.pid,
				id  = data.id,
			}
			MessageMgr:sendPost("get_cloud_buy_awards",'activity',json.encode(args),function(jsonObj)
				local code = jsonObj.code
				local data = jsonObj.data
				if code == 0 then
					local awards = data.awards
					if awards then
						GlobalApi:parseAwardData(awards)
						GlobalApi:showAwardsCommon(awards,nil,nil,true)
					end
					self.data[i].lottery = 2
					self:updatePanel()
				end
			end)
		end
	end)
	local getImg = bgImg:getChildByName('get_img')
	local function updateGetBtn()
		if data.lottery == 0 then
			getImg:setVisible(true)
			getBtn:setVisible(false)
		elseif data.lottery == 1 then
			getImg:setVisible(false)
			getBtn:setVisible(true)
			getBtn:setBright(true)
			getBtn:setTouchEnabled(true)
			infoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
			infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
		else
			getBtn:setBright(false)
			getBtn:setTouchEnabled(false)
			getImg:setVisible(false)
			getBtn:setVisible(true)
			infoTx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
			infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
		end
	end
	if ntype == 1 then
		local nowTime = GlobalData:getServerTime()
		if data.time < nowTime then
			updateGetBtn()
		else
			getImg:setVisible(false)
			getBtn:setVisible(false)
		end
	else
		if data.time and data.time > 0 then
			updateGetBtn()
		else
			getImg:setVisible(false)
			getBtn:setVisible(false)
		end
	end
end

function CloudBuyNoticeUI:updateNotice(bgImg,data)
	local awardsConf = GameData:getConfData("avcloudbuyawards")
	local descTx1 = bgImg:getChildByName('desc_tx_1')
	local descTx2 = bgImg:getChildByName('desc_tx_2')
	local descTx3 = bgImg:getChildByName('desc_tx_3')
	local cashTx = bgImg:getChildByName('cash_tx')
	local roleNameTx = bgImg:getChildByName('name_tx')
	local fuTx = bgImg:getChildByName('fu_tx')

	fuTx:setString(data.sid..GlobalApi:getLocalStr('FU'))
	descTx1:setString(GlobalApi:getLocalStr('STR_PRICE'))
	descTx2:setString(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_14')..'：'..data.code)
	local now = os.date('*t',data.time)
	descTx3:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_31'),now.year,now.month,now.day,
		string.format('%02d',now.hour),
		string.format('%02d',now.min),
		string.format('%02d',now.sec)))
	local awardsConf = GameData:getConfData("avcloudbuyawards")
	local node = bgImg:getChildByName('node')
	local awardBgImg = node:getChildByName('award_bg_img')
	local award = DisplayData:getDisplayObj(awardsConf[data.aid].awards[1])
	local str = {'LIMIT_DESC','ACTIVITY_CLOUD_BUY_DESC_5'}
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, node)
		awardBgImg = tab.awardBgImg
		local size = awardBgImg:getContentSize()
		local signImg = ClassItemCell:updateImageView(awardBgImg,'uires/ui/common/corner_blue_'..(data.type or 1)..'.png','sign_img',nil,nil,
			cc.p(size.width + 2,size.height + 2),cc.p(1,1))
		signImg:setScale(0.8)
		local infoTx = ClassItemCell:updateTTFlabel(signImg,GlobalApi:getLocalStr(str[(data.type or 1)]),"font/gamefont.ttf",16,'info_tx',nil,cc.p(45,45))
		infoTx:setSkewX(45.38)
		infoTx:setSkewY(-45.38)
	end
	local nameTx = awardBgImg:getChildByName('name_tx')
	nameTx:setAnchorPoint(cc.p(0, 0.5))
	nameTx:setPosition(cc.p(110,70))
	nameTx:setString(award:getName())
	nameTx:setColor(award:getNameColor())
	cashTx:setString(awardsConf[data.aid].costs)

	local roleNode = bgImg:getChildByName('role_node')
	local obj = RoleData:getRoleInfoById(data.main_role)
	local awardBgImg = roleNode:getChildByName('award_bg_img')
	if not awardBgImg then
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
		awardBgImg = tab.awardBgImg
		roleNode:addChild(awardBgImg)
		local infoTx = ClassItemCell:updateTTFlabel(awardBgImg,GlobalApi:getLocalStr('ACTIVITY_CLOUD_BUY_DESC_34'),"font/gamefont.ttf",22,
			'info_tx',nil,cc.p(15,85),COLOR_TYPE.YELLOW,cc.c3b(255,0,0),1,cc.c3b(255,0,0))
		infoTx:setSkewX(-17)
		infoTx:setSkewY(17)
	end
	local awardImg = awardBgImg:getChildByName('award_img')
	local headframeImg = awardBgImg:getChildByName('headframeImg')
    awardBgImg:loadTexture(obj:getBgImg())
    local obj1 = RoleData:getHeadPicObj(data.headpic or 1)
    awardImg:loadTexture(obj1:getIcon())
    headframeImg:loadTexture(GlobalApi:getHeadFrame(data.headframe))
	awardBgImg:setTouchEnabled(false)
	roleNameTx:setString(data.name)
	roleNameTx:setColor(obj:getNameColor())
end

function CloudBuyNoticeUI:updatePanel()
	local node = self.sv:getChildByName('node')
	if not node then
		node = cc.Node:create()
		node:setName('node')
		self.sv:addChild(node)
	end
	local size = self.sv:getContentSize()
	local size1
	table.sort( self.data, function(a,b)
		if a.time == 0 then
			return false
		end
		if b.time == 0 then
			return true
		end
		return a.time < b.time
	end )
	for i=1,#self.data do
		local bgImg = node:getChildByName('bg_img_'..i)
		if not bgImg then
			local root = cc.CSLoader:createNode('csb/activity_cloud_buy_notice_cell'..self.page..'.csb')
			bgImg = root:getChildByName('bg_img')
			bgImg:removeFromParent(false)
			node:addChild(bgImg)
			bgImg:setName('bg_img_'..i)
			local size2 = bgImg:getContentSize()
			bgImg:setPosition(cc.p(size.width/2,-(#self.data - i)*(size2.height + 6) - 6))
		end
		size1 = bgImg:getContentSize()
		if self.page == 1 then
			self:updateMyAward(bgImg,i)
		else
			self:updateNotice(bgImg,self.data[i])
		end
	end
	if size1 then
		local maxHeight = #self.data * (size1.height + 6) + 6
		if size.height > maxHeight then
			node:setPosition(cc.p(0,size.height))
			self.sv:setInnerContainerSize(size)
		else
			node:setPosition(cc.p(0,maxHeight))
			self.sv:setInnerContainerSize(cc.size(size.width,maxHeight))
		end
	end
end

return CloudBuyNoticeUI