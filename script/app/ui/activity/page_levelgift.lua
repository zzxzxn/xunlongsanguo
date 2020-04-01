local PageLevelGift = class("PageLevelGift")
local ClassItemCell = require('script/app/global/itemcell')

function PageLevelGift:init(msg)
    self.rootBG     = self.root:getChildByName("root")
    --self.scrollView = self.rootBG:getChildByName("scrollView")
	self.cfg = GameData:getConfData("avlevelgift")
	
	self.tempCell=ccui.Helper:seekWidgetByName(self.rootBG, 'temp_cell')
    self.tempCell:setVisible(false)
	self.tempCell:setTouchEnabled(false)
	
	self.cells={}
	
	self.sv = self.rootBG:getChildByName('scrollView')
	--local contentWidget = ccui.Widget:create()
    --self.sv:addChild(contentWidget)
    local svSize = self.sv:getContentSize()
    self.sv:setScrollBarEnabled(false)
    --contentWidget:setPosition(cc.p(0, svSize.height))

    local allHeigth = 154 * #self.cfg
    if allHeigth > svSize.height then
        self.sv:setInnerContainerSize(cc.size(svSize.width, allHeigth))
    end

	local innerHeight=0
	for k = 1,#self.cfg do
		local isGetGift=false		
		for m,n in pairs(msg.level_gift) do
			if tonumber(m)==tonumber(k) then
				isGetGift=true
			end
		end
		
		local cell = self:createGiftCell(self.cfg[k], isGetGift)
		self.cells[k]=cell
		innerHeight = k*154
		cell:setPosition(cc.p(0, (#self.cfg - k) * 154))
		self.sv:addChild(cell)
	end

	--innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
	--self.sv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
	--contentWidget:setPosition(cc.p(0, innerHeight))
	
	self:updateMark()
end

function PageLevelGift:createGiftCell(data, isGetGift)
	local newCell = self.tempCell:clone()
	
	local title=ccui.Helper:seekWidgetByName(newCell,"title")
	--title:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_LEVELGIFT_TITLE'), tonumber(data.level)))
	local exTitle=ccui.Helper:seekWidgetByName(newCell,"title_ex")
	exTitle:setString(GlobalApi:getLocalStr('ACTIVITY_LEVELGIFT_EXTITLE'))
	
	local richText = xx.RichText:create()
    title:addChild(richText)
    richText:setContentSize(cc.size(400, 28))
    richText:setPosition(cc.p(0,0))
    richText:setAlignment('left')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LEVELGIFT_TITLE1'), 25, cc.c4b(110,73,48,255))
	re1:setStroke(cc.c4b(255,239,209,255), 1)
	re1:clearShadow()
	re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(data.level, 22, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_LEVELGIFT_TITLE2'), 25, cc.c4b(110,73,48,255))
	re3:setStroke(cc.c4b(255,239,209,255), 1)
	re3:clearShadow()
	re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setContentSize(richText:getElementsSize())
	
	
	newCell.btn=ccui.Helper:seekWidgetByName(newCell,"get_btn")
    newCell.btn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
	newCell.btn:setVisible(false)
	newCell.btn:setTouchEnabled(false)
	newCell.btn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				self:selectGift(data.id)
			end
		end)
	
	newCell.pic=ccui.Helper:seekWidgetByName(newCell,"state")
	newCell.pic:setVisible(true)
	local lv=UserData:getUserObj():getLv()
	
	if lv>=data.level then
		if isGetGift==true then
			newCell.pic:loadTexture("uires/ui/activity/yihuode.png")
			newCell.isCanGet=0
		else
			--newCell.pic:loadTexture("uires/ui/activity/kelingqu.png")
			newCell.pic:setVisible(false)
			newCell.btn:setVisible(true)
			newCell.btn:setTouchEnabled(true)
			newCell.isCanGet=1
		end
	else
		newCell.pic:loadTexture("uires/ui/activity/weidacheng.png")
		newCell.isCanGet=0
	end
	
	local awards = DisplayData:getDisplayObjs(data.awards)
	local awards_ex = DisplayData:getDisplayObjs(data.awardsEx)
	for i=1,3 do
		local bg=newCell:getChildByName('award_'..i)
		if awards[i] then
			bg:setVisible(true)
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[i], bg)
			local bgSize=bg:getContentSize()
			tab.awardBgImg:setPosition(cc.p(bgSize.width/2, bgSize.height/2))
	    	tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
					AudioMgr.PlayAudio(11)
					GetWayMgr:showGetwayUI(awards[i],false)
		        end
		    end)
		else
			bg:setVisible(false)
		end
	end
	
	local exAwardBg=newCell:getChildByName('award_ex')
	local exAwardIcon = exAwardBg:getChildByName('icon')
	local exAwardNum = exAwardBg:getChildByName('num')
	local exAwardMask = exAwardBg:getChildByName('mask')
	if awards_ex[1] then
		exAwardBg:setVisible(true)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards_ex[1], exAwardBg)
		local bgSize=exAwardBg:getContentSize()
		tab.awardBgImg:setPosition(cc.p(bgSize.width/2, bgSize.height/2))
		local createTime = UserData:getUserObj():getCreateTime()
		local nowTime = GlobalData:getServerTime()
		local isOverdue=true
		if (nowTime - createTime) < 7 * 86400 then
			isOverdue=false
		end
		exAwardMask:setLocalZOrder(5)
		exAwardMask:setVisible(isOverdue)
		
		tab.awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				GetWayMgr:showGetwayUI(awards_ex[1],false)
			end
		end)
	else
		exAwardBg:setVisible(false)
	end
	
	newCell:setVisible(true)
	return newCell
end

function PageLevelGift:selectGift(giftId)
	MessageMgr:sendPost('get_level_gift_award','activity',json.encode({id = giftId}),
		function(response)
			
			if(response.code ~= 0) then
				return
			end

			local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end
			
			if self.cells[giftId]~=nil then
				self.cells[giftId].isCanGet=0
				local cell=self.cells[giftId]
				cell.btn:setVisible(false)
				cell.btn:setTouchEnabled(false)
				cell.pic:setVisible(true)
				cell.pic:loadTexture("uires/ui/activity/yihuode.png")
			end
			
            UserData:getUserObj().activity.level_gift[tostring(giftId)] = 1

			self:updateMark()
		end)
end

function PageLevelGift:updateMark()
	local num=0
	for k,v in pairs(self.cells) do
		if v.isCanGet==0 then
			num=num+1
		end
	end
	print("PageLevelGift:updateMark num "..num.." cfg "..#self.cfg)
	if num >= #self.cfg then
		ActivityMgr:showMark("levelgift", false)
	else
		ActivityMgr:showMark("levelgift", true)
	end
end

return PageLevelGift