local ChristmasTree = class("christmas_tree")
local ClassItemCell = require('script/app/global/itemcell')

function ChristmasTree:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	self.tempData = GameData:getConfData('avchristmastree')
    UserData:getUserObj().activity.christmas_tree = self.msg.christmas_tree
	ActivityMgr:showRightChristmasTreeRemainTime()
	UserData:getUserObj().tips.christmas_tree = 0
    self:updateMark()
	self.christmasTreeBg = ActivityMgr:getLefChristmasTreeBgCue()
	self.christmasTreeBg:setVisible(true)
	self.showDatas = {
		{"uires/ui/activity/huangxiang1.png","uires/ui/activity/huangxiang2.png","uires/ui/activity/huolishengdan.png","uires/icon/material/scarf.png"},
		{"uires/ui/activity/hongxiang1.png","uires/ui/activity/hongxiang2.png","uires/ui/activity/reqingshengdan.png","uires/icon/material/glove.png"},
		{"uires/ui/activity/lanxiang1.png","uires/ui/activity/lanxiang2.png","uires/ui/activity/kuanghuanshengdan.png","uires/icon/material/snowman.png"}
	}
	self:updateTop()
	self:update()
end

function ChristmasTree:updateMark()
    if UserData:getUserObj():getSignByType('christmas_tree') then
		ActivityMgr:showMark("christmas_tree", true)
	else
		ActivityMgr:showMark("christmas_tree", false)
	end
end

function ChristmasTree:updateTop()
	local help = self.christmasTreeBg:getChildByName('human_wheel_help')
    help:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(43)
        end
    end)

	local num1 = self.christmasTreeBg:getChildByName('own_num')
	local num2 = self.christmasTreeBg:getChildByName('item2'):getChildByName('own_num')
	local num3 = self.christmasTreeBg:getChildByName('item3'):getChildByName('own_num')
	
	num1:setString(BagData:getMaterialById(350023):getNum())
	num2:setString(BagData:getMaterialById(350024):getNum())
	num3:setString(BagData:getMaterialById(350025):getNum())
end

function ChristmasTree:update()
	local bg = self.rootBG:getChildByName('bg')
	for i = 1,3 do
		local frame = bg:getChildByName('frame' .. i)
		local nameImg = frame:getChildByName('name_img')
		local showData = self.showDatas[i]
		local confData = self.tempData[i]
		local serverData = self.msg.christmas_tree.rewards[tostring(i)]
		local aid = 0
		local id = {}
		if serverData then
			aid = serverData.aid or 0
			id = serverData.id or {}
		end
		local posId = aid + 1
		if posId >= 5 then
			posId = 5
		end
		local disPlayData2 = DisplayData:getDisplayObjs(confData[posId].cost)
		local awards3 = disPlayData2[1]
		for j = 1,5 do
			local disPlayData = DisplayData:getDisplayObjs(confData[j].cost)
			local awards = disPlayData[1]
			local box = frame:getChildByName('box_' .. j)
			local guang = frame:getChildByName('guang_' .. j)
			guang:stopAllActions()
			guang:setVisible(false)
			ShaderMgr:restoreWidgetDefaultShader(box)
			local judge = 1
			if j <= aid then
				if id[tostring(j)] and id[tostring(j)] == 1 then
					box:loadTexture(showData[2])
					ShaderMgr:setGrayForWidget(box)
				else
					box:loadTexture(showData[1])
					judge = 2
					guang:setVisible(true)
					guang:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
				end
			else	
				if aid + 1 == j then
					if awards:getOwnNum() >= awards:getNum() then
						box:loadTexture(showData[1])
						judge = 3
					else
						box:loadTexture(showData[1])
					end
				else
					box:loadTexture(showData[1])
				end
			end

			box:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					if judge == 3 then
						local num = awards3:getNum()
						local name = awards3:getName()
						promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_2"), num,name), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
							local args = {
								type = i,
								lid = aid + 1
							}
							MessageMgr:sendPost("active_christmas_tree", "activity", json.encode(args), function (response)
								local code = response.code
								if code == 0 then
									local awards = response.data.awards
									if awards then
										GlobalApi:parseAwardData(awards)
										GlobalApi:showAwardsCommon(awards,nil,nil,true)
									end
									local costs = response.data.costs
									if costs then
										GlobalApi:parseAwardData(costs)
									end
								
									if not self.msg.christmas_tree.rewards[tostring(i)] then
										self.msg.christmas_tree.rewards[tostring(i)] = {}
										self.msg.christmas_tree.rewards[tostring(i)].aid = 0
										self.msg.christmas_tree.rewards[tostring(i)].id = {}
									end
									self.msg.christmas_tree.rewards[tostring(i)].aid = self.msg.christmas_tree.rewards[tostring(i)].aid + 1
									UserData:getUserObj().activity.christmas_tree = self.msg.christmas_tree
									self:updateTop()
									self:update()
								end
							end)
						end)
					elseif judge == 2 then
						local args = {
							type = i,
							lid = j
						}
						MessageMgr:sendPost("get_christmas_tree_awards", "activity", json.encode(args), function (response)
							local code = response.code
							if code == 0 then
								local awards = response.data.awards
								if awards then
									GlobalApi:parseAwardData(awards)
									GlobalApi:showAwardsCommon(awards,nil,nil,true)
								end
								local costs = response.data.costs
								if costs then
									GlobalApi:parseAwardData(costs)
								end

								if not self.msg.christmas_tree.rewards[tostring(i)] then
									self.msg.christmas_tree.rewards[tostring(i)] = {}
									self.msg.christmas_tree.rewards[tostring(i)].aid = 0
									self.msg.christmas_tree.rewards[tostring(i)].id = {}
								end
								self.msg.christmas_tree.rewards[tostring(i)].id[tostring(j)] = 1
								UserData:getUserObj().activity.christmas_tree = self.msg.christmas_tree
								self:updateTop()
								self:update()
							end
						end)
					else
						local disPlayData = DisplayData:getDisplayObjs(confData[j].award)
						local awards2 = disPlayData[1]
						GetWayMgr:showGetWaySpecial2UI(awards2,confData[j].award)
					end
				end
			end)

		end

		local nameImg = frame:getChildByName('name_img')
		nameImg:loadTexture(showData[3])

		local item = frame:getChildByName('item')
		local img = item:getChildByName('img')
		img:loadTexture(showData[4])
		local ownNum = item:getChildByName('own_num')
		ownNum:setString(awards3:getOwnNum() .. '/' .. awards3:getNum())
		local posX = frame:getChildByName('box_' .. posId):getPositionX()
		local posY = frame:getChildByName('box_' .. posId):getPositionY()
		item:setPosition(posX,posY - 45)
	end

	local endBox = bg:getChildByName('box')
	local isGet = 1
	if self.msg.christmas_tree.box and self.msg.christmas_tree.box == 1 then
		ShaderMgr:setGrayForWidget(endBox)
		endBox:setTouchEnabled(false)
		isGet = 2
	else
		local rewards = self.msg.christmas_tree.rewards
		local judge = 0
		for i = 1,3 do
			local aid = 0
			local id = {}
			local serverData = rewards[tostring(i)]
			if serverData then
				aid = serverData.aid or 0
				id = serverData.id or {}
			end
			if aid >= 5 then
				judge = judge + 1
			end
		end
		if judge == 3 then
			ShaderMgr:restoreWidgetDefaultShader(endBox)
			endBox:setTouchEnabled(true)
			isGet = 1
		else
			endBox:setTouchEnabled(true)
			ShaderMgr:restoreWidgetDefaultShader(endBox)
			isGet = 3
		end
	end
	
	if bg:getChildByName('rich_text') then
		bg:removeChildByName('rich_text')
	end

	local reward = GameData:getConfData('specialreward')['christmas_tree'].reward
	local disPlayData = DisplayData:getDisplayObjs(reward)[1]
	local richText = xx.RichText:create()
	richText:setName('rich_text')
	richText:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_CHRISTMAS_TREE_DESC_1'), 24, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
	re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
	re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(disPlayData:getName(), 24, COLOR_TYPE.RED)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
	re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
	re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:setAlignment('right')
	richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(1,0.5))
	richText:setPosition(cc.p(820,15))
	bg:addChild(richText)
	richText:format(true)

	endBox:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			if isGet == 3 then
				GetWayMgr:showGetwayUI(disPlayData,false)
			elseif isGet == 1 then
				MessageMgr:sendPost("get_christmas_tree_end_awards", "activity", json.encode({}), function (response)
					local code = response.code
					if code == 0 then
						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
						end
						local costs = response.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						self.msg.christmas_tree.box = 1
						UserData:getUserObj().activity.christmas_tree = self.msg.christmas_tree
						self:update()
					end
				end)
			end
        end
    end)
	self:updateMark()
end

return ChristmasTree