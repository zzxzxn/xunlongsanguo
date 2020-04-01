local SurpriseBox = class("surprise_box")
local ClassItemCell = require('script/app/global/itemcell')
local ClassSellTips = require('script/app/ui/tips/selltips')

function SurpriseBox:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	self.tempData = GameData:getConfData('avsurprisebox')
	ActivityMgr:showRightSurpriseBoxRemainTime()
    self:updateMark()
	self:update()
	ActivityMgr:showLefTavernRecruitCue()
end

function SurpriseBox:updateMark()
    if UserData:getUserObj():getSignByType('surprise_box') then
		ActivityMgr:showMark("surprise_box", true)
	else
		ActivityMgr:showMark("surprise_box", false)
	end
end

function SurpriseBox:update()
	local bg = self.rootBG:getChildByName('bg')
	self.bg = bg
	local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    self.sv = sv

	self.cell = bg:getChildByName('cell')
	self.cell:setVisible(false)
	self.frame = bg:getChildByName('frame1')
	self.frame:setVisible(false)

	local num = 3
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 20

    local width = num * self.cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = self.cell:getContentSize().width
	local tabs = {{1,2,3},{4,5,6},{7,8,9}}
    for i = 1,3,1 do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()
        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

		local ids = {}
		for j = 1,3 do
			table.insert(ids,tabs[i][j])
		end
		local nameImg = tempCell:getChildByName('name_img')
		nameImg:loadTexture("uires/ui/activity/" .. i .. ".png")
		nameImg:setVisible(false)

		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(400, 28))
		richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_CHRISTMAS_TREE_DESC_1' .. (i + 1)), 30,COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
		richText:addElement(re1)
		richText:format(true)
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:setPosition(cc.p(nameImg:getPositionX(),nameImg:getPositionY() + 5))
		tempCell:addChild(richText)

		self:updateItem(tempCell,ids)
    end
    innerContainer:setPositionX(0)

	local surpriseBoxSellBegin = tonumber(GlobalApi:getGlobalValue('surpriseBoxSellBegin'))
	local now = os.date('*t', tonumber(GlobalData:getServerTime()))
	local refTime = Time.time({year = now.year, month = now.month, day = now.day, hour = surpriseBoxSellBegin, min = 0, sec = 0})
	local difftime = refTime - tonumber(GlobalData:getServerTime())
    if difftime > 0  and difftime <= (surpriseBoxSellBegin - 5)*3600 then
		self:timeoutCallback(difftime)
	end
end

function SurpriseBox:timeoutCallback(difftime)
    if difftime <= 0 then
        return
    end

	local node = cc.Node:create()
    node:setPosition(cc.p(450,370))
	node:setTag(9527)		 
	if self.bg:getChildByTag(9527) then
        self.bg:removeChildByTag(9527)
    end
	self.bg:addChild(node)

    Utils:createCDLabel(node,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
        CDTXTYPE.FRONT,GlobalApi:getLocalStr('ACTIVITY_CHRISTMAS_TREE_DESC_9'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,22,function()
		if self.bg:getChildByTag(9527) then
			self.bg:removeChildByTag(9527)
		end
    end)
end

function SurpriseBox:updateItem(cell,ids)
	for i = 1,3 do
		if cell:getChildByName('frame_' .. i) then
			cell:removeChildByName('frame_' .. i)
		end
		local frame = self.frame:clone()
		frame:setVisible(true)
		frame:setName('frame_' .. i)
		cell:addChild(frame)
		frame:setPosition(cc.p(13,225 - (i - 1)*82))
		if i == 3 then
			frame:setPosition(cc.p(13,225 - (i - 1)*83))
		end

		local id = ids[i]
		local confData = self.tempData[id]

		local icon = frame:getChildByName('icon')
        local disPlayData = DisplayData:getDisplayObjs(confData.award)
        local awards = disPlayData[1]
        local cell2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell2.awardBgImg:setScale(1.1)
        cell2.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
        cell2.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell2.awardBgImg)

		local oriPrice = frame:getChildByName('ori_price')
		oriPrice:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_3"), confData.origin))
		local cash1 = frame:getChildByName('cash1')
		cash1:setPositionX(oriPrice:getPositionX() + oriPrice:getContentSize().width + 5)
		local curPrice = frame:getChildByName('cur_price')
		curPrice:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_4"), confData.price))
		local cash2 = frame:getChildByName('cash2')
		cash2:setPositionX(curPrice:getPositionX() + curPrice:getContentSize().width + 5)

		local imgDiscount = frame:getChildByName('img_discount')
		imgDiscount:getChildByName('price'):setString(string.format(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_6"), confData.cut))

		local allCount = confData.all
		local selfCount = confData.self
		local hasAllCount = self.msg.world_items[tostring(id)] or 0
		local hasSelfCount = self.msg.self_items[tostring(id)] or 0
		local remainCount = 0
		if hasAllCount >= allCount then
			remainCount = 0
		else
			if hasSelfCount >= selfCount then
				remainCount = 0
			else
				remainCount = selfCount - hasSelfCount
				if remainCount > allCount - hasAllCount then
					remainCount = allCount - hasAllCount
				end
			end
		end

		local limitTx = frame:getChildByName('limit_tx')
		local buyBtn = frame:getChildByName('buy_btn')
		local buyTx = buyBtn:getChildByName('info_tx')
		buyTx:setString(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_5"))
		buyBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				local surpriseBoxSellBegin = tonumber(GlobalApi:getGlobalValue('surpriseBoxSellBegin'))
				local now = os.date('*t', tonumber(GlobalData:getServerTime()))
				local refTime = Time.time({year = now.year, month = now.month, day = now.day, hour = surpriseBoxSellBegin, min = 0, sec = 0})
				local difftime = refTime - tonumber(GlobalData:getServerTime())
				if difftime > 0 and difftime <= (surpriseBoxSellBegin - 5)*3600 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_CHRISTMAS_TREE_DESC_10'), COLOR_TYPE.RED)
					return
				end

				local awardData = confData.award
				local disPlayData = DisplayData:getDisplayObjs(awardData)
				local awards = disPlayData[1]
				local tab = {}
				tab.icon = 'uires/ui/res/res_cash.png'
				tab.num = UserData:getUserObj():getCash()
				tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
				tab.id = 'cash'
				tab.costNum = confData.price
				tab.confId = nil
				tab.sellNum = 1
				self:showTips(awards,tab,nil,function(callback,num,cash)
					if callback then
						callback()
					end

					local function callBack2(buyNum)
						if self.msg.world_items[tostring(id)] == nil then
							self.msg.world_items[tostring(id)] = 0
						end
						if self.msg.self_items[tostring(id)] == nil then
							self.msg.self_items[tostring(id)] = 0
						end

						self.msg.world_items[tostring(id)] = self.msg.world_items[tostring(id)] + buyNum
						self.msg.self_items[tostring(id)] = self.msg.self_items[tostring(id)] + buyNum

						self:updateItem(cell,ids)
					end
					if num == 0 then
					else
						self:buyProp(num,cash,id,callBack2)
					end
					end,nil,remainCount,'show_at_surprise_step')
				end
		end)

		if remainCount <= 0 then
			buyBtn:setTouchEnabled(false)
			buyTx:setColor(COLOR_TYPE.GRAY)
			buyTx:enableOutline(COLOR_TYPE.BLACK)
			ShaderMgr:setGrayForWidget(buyBtn)
		end

		local count = allCount - hasAllCount
		if count <= 0 then
			limitTx:setString(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_8"))
			count = 0
		else
			limitTx:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_7"), count))
		end
	end
end

function SurpriseBox:showTips(award,tab,status,callback,sidebarList,num,showType)
    local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num,showType)
    sellTipsUI:showUI()
end

function SurpriseBox:buyProp(num,cost,id,callBack2)
    local num = num or 1
    local function sendToServer()
        self:sendToServer(num,id,callBack2)
	end
	UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
end

function SurpriseBox:sendToServer(num,id,callBack2)
    MessageMgr:sendPost('buy_surprise_box','activity',json.encode({num = num,id = id}),
	    function(response)
		    if(response.code ~= 0) then
			    return
		    end

            local awards = response.data.awards
		    if awards then
			    GlobalApi:parseAwardData(awards)
			    GlobalApi:showAwardsCommon(awards,nil,nil,true)
		    end

		    local costs = response.data.costs
		    if costs then
			    GlobalApi:parseAwardData(costs)
		    end
            if callBack2 then
				callBack2(num)
			end
	    end)
end

return SurpriseBox