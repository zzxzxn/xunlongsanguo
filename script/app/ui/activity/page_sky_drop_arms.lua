local SkyDropArms = class("SkyDropArms")
local ClassItemCell = require('script/app/global/itemcell')

function SkyDropArms:init(msg)
	self.rootBG = self.root:getChildByName("root")
	self.data = msg
	local rightBgImg = self.rootBG:getChildByName('right_bg_img')
	local titleImg = rightBgImg:getChildByName('title_img')
	titleImg:loadTexture('uires/ui/text/tianjiangshengwu.png')
	self.awardSv = rightBgImg:getChildByName('award_sv')
	self.awardSv:setScrollBarEnabled(false)
	self:createItem()
	self:createRichTextDesc()
	self:updateBtn()
	ActivityMgr:showRightSkyDropArmsRemainTime()
end

function SkyDropArms:buy(times)
	local function callback()
		local args = {
			times =  times
		}
		MessageMgr:sendPost("draw_sky_drop_arms",'activity',json.encode(args),function(jsonObj)
			local code = jsonObj.code
			local data = jsonObj.data
			if code == 0 then
				local costs = data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end
				local awards = data.awards
				if awards then
					GlobalApi:parseAwardData(awards)
					GlobalApi:showAwardsCommon(awards, true, nil, true)
				end
			end
		end)
	end
	local nums = {
		[1] = tonumber(GlobalApi:getGlobalValue('skyWeapCost')),
		[10] = tonumber(GlobalApi:getGlobalValue('skyWeapCost'))*10*tonumber(GlobalApi:getGlobalValue('skyWeapDiscount'))
	}
	local str = string.format(GlobalApi:getLocalStr('SKY_DROP_DESC8'),nums[times],times)
	UserData:getUserObj():cost('cash',nums[times],callback,true,str)
end

function SkyDropArms:updateBtn()
	local nums = {
		tonumber(GlobalApi:getGlobalValue('skyWeapCost')),
		tonumber(GlobalApi:getGlobalValue('skyWeapCost'))*10*tonumber(GlobalApi:getGlobalValue('skyWeapDiscount'))
	}
	local rightBgImg = self.rootBG:getChildByName('right_bg_img')
	local times = {1,10}
	for i=1,2 do
		local buyBgImg = rightBgImg:getChildByName('buy_bg_img_'..i)
		local numTx = buyBgImg:getChildByName('num_tx')
		local buyBtn = buyBgImg:getChildByName('buy_btn')
		local infoTx = buyBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('SKY_DROP_BTN_DESC_'..i))
		numTx:setString(nums[i])
		buyBtn:addTouchEventListener(function (sender,eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				self:buy(times[i])
			end
		end)
	end
end

function SkyDropArms:createRichTextDesc()
	local talkImg = self.rootBG:getChildByName('talk_img')
	local richText = xx.RichText:create()
	richText:setAlignment('middle')
	richText:setVerticalAlignment('middle')
	richText:setContentSize(cc.size(500, 52))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC1'), 26, COLOR_TYPE.WHITE)
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC2'), 26, COLOR_TYPE.ORANGE)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_107'), 26, COLOR_TYPE.WHITE)
	local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC3'), 26, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	re2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	re4:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re1:setFont('font/gamefont.ttf')
	re2:setFont('font/gamefont.ttf')
	re3:setFont('font/gamefont.ttf')
	re4:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:addElement(re4)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(222.5,85))
	talkImg:addChild(richText)

	local richText = xx.RichText:create()
	richText:setAlignment('middle')
	richText:setVerticalAlignment('middle')
	richText:setContentSize(cc.size(500, 52))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC4'), 24, COLOR_TYPE.WHITE)
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC5'), 24, COLOR_TYPE.ORANGE)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC6'), 24, COLOR_TYPE.WHITE)
	local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKY_DROP_DESC7'), 24, COLOR_TYPE.RED)
	re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	re2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
	re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	re4:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re1:setFont('font/gamefont.ttf')
	re2:setFont('font/gamefont.ttf')
	re3:setFont('font/gamefont.ttf')
	re4:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:addElement(re4)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(222.5,45))
	talkImg:addChild(richText)
end

function SkyDropArms:updateMark()

end

function SkyDropArms:onShow()

end

function SkyDropArms:createItem()
	local conf = GameData:getConfData("avskyweapheaven")
	local function getPos(index)
		local i = index%2
		local posX,posY
		local diff = (220 - (94*0.78)*2)/3
		if i == 0 then
			posY = diff + (94*0.78)*0.5
		else
			posY = diff*2 + (94*0.78)*1.5
		end
		posX = 10 + (94*0.78 + 20)*(math.ceil(index/2) - 0.5)
		return cc.p(posX,posY)
	end
	local descs = {[0] = GlobalApi:getLocalStr('SKY_DROP_DESC11'),[1] = GlobalApi:getLocalStr('EXCLUSIVE_DESC_114')}
	local types = {[0] = 2,[1] = 1}
	for i,v in ipairs(conf) do
		local node = self.awardSv:getChildByName('node_'..i)
		if not node then
			node = cc.Node:create()
			node:setName('node_'..i)
			self.awardSv:addChild(node)
		end
		local param = {}
		local obj = DisplayData:getDisplayObj(v.rollItem[1])
		local awardBgImg = ClassItemCell:updateAwardFrameByObj(node,obj,param)
		awardBgImg:setScale(0.78)
		awardBgImg:setPosition(getPos(i))
		local surfacetimeImg = awardBgImg:getChildByName('surfacetime_Img')
		if surfacetimeImg then
			surfacetimeImg:setScale9Enabled(true)
			surfacetimeImg:setContentSize(cc.size(40,surfacetimeImg:getContentSize().height - 6))
		end
		awardBgImg:setSwallowTouches(false)
		GlobalApi:regiesterBtnHandler(awardBgImg,function()
			GetWayMgr:showGetwayUI(obj,false)
		end)
		local size = awardBgImg:getContentSize()
		local signImg = ClassItemCell:updateImageView(awardBgImg,'uires/ui/common/corner_blue_'..types[v.probability]..'.png','sign_img',nil,nil,
			cc.p(0,size.height + 2),cc.p(1,1))
		signImg:setScaleX(-0.8)
		signImg:setScaleY(0.8)
		local infoTx = ClassItemCell:updateTTFlabel(signImg,descs[v.probability],"font/gamefont.ttf",16,'info_tx',nil,cc.p(45,45))
		infoTx:setScaleX(-1)
		infoTx:setSkewX(-45.38)
		infoTx:setSkewY(45.38)
	end
	local maxWidth = math.ceil(#conf/2)*(94*0.78 + 20) + 20
	local size = self.awardSv:getContentSize()
	if size.width < maxWidth then
		self.awardSv:setInnerContainerSize(cc.size(maxWidth,size.height))
	else
		self.awardSv:setInnerContainerSize(size)
	end
end

return SkyDropArms