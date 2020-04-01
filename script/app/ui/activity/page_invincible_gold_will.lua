local InvincibleGoldWill = class("invincible_gold_will")
local ClassItemCell = require('script/app/global/itemcell')

function InvincibleGoldWill:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	--UserData:getUserObj().activity.invincible_gold_will = self.msg.goldWill
	self.tempData = GameData:getConfData('avgoldwill')
	ActivityMgr:showRightInvincibleGoldWillRemainTime()
	ActivityMgr:showLefGoldWillTx()
    self:updateMark()
	self:update()
	self:update2()
	ActivityMgr:showLefTavernRecruitCue()
end

function InvincibleGoldWill:updateMark()
    if UserData:getUserObj():getSignByType('invincible_gold_will') then
		ActivityMgr:showMark("invincible_gold_will", true)
	else
		ActivityMgr:showMark("invincible_gold_will", false)
	end
end

function InvincibleGoldWill:update()
	local bg = self.rootBG:getChildByName('bg')

	local roleId = self.tempData[1].roleId
	local heroconf = GameData:getConfData('hero')
	local cardData = heroconf[roleId]

	local spineAni = GlobalApi:createLittleLossyAniByName(cardData.url .. "_display")
	if spineAni then
	--  spineAni:setScale(0.6)
		local shadow = spineAni:getBone(cardData.url .. "_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
		end
		local effectIndex = 1
		repeat
			local aniEffect = spineAni:getBone(cardData.url .. "_effect" .. effectIndex)
			if aniEffect == nil then
				break
			end
			aniEffect:changeDisplayWithIndex(-1, true)
			aniEffect:setIgnoreMovementBoneData(true)
			effectIndex = effectIndex + 1
		until false
		spineAni:setPosition(cc.p(180,70+cardData.uiOffsetY))
		spineAni:setLocalZOrder(999)
		spineAni:setTag(9527)
		bg:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		local beginPoint = cc.p(0,0)
		local endPoint = cc.p(0,0)

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end

end 

function InvincibleGoldWill:update2()
	local bg = self.rootBG:getChildByName('bg')
	local rightImg = bg:getChildByName('right_img')
	for i = 1,2 do
		local img = rightImg:getChildByName('img' .. i)
		local confData = self.tempData[i]
		local term = confData.term

		local curValue = self.msg.goldWill.money
		local maxValue = term[1] + term[2] + term[3]
		if i == 2 then
			curValue = self.msg.goldWill.cash
		end

		local expBg = img:getChildByName('exp_bg')
		local expBar = expBg:getChildByName('exp_bar')
		expBar:setPercent(curValue/maxValue*100)

		local x1 = img:getChildByName('frame1'):getPositionX()
		local x2 = img:getChildByName('frame2'):getPositionX()
		local x3 = img:getChildByName('frame3'):getPositionX()
		local width = 75.2
		expBar:setPercent(self:getPercent(curValue,expBg:getContentSize().width,expBg:getPositionX(),x1,x2,x3,width,term))
		if curValue >= maxValue then
			expBar:setPercent(100)
		end

		local disPlayData = DisplayData:getDisplayObjs(confData.award)
		for j = 1,3 do
			local frame = img:getChildByName('frame' .. j)
			local iocn = frame:getChildByName('icon')
			if iocn:getChildByName('awardBgImg') then
				iocn:removeChildByName('awardBgImg')
			end
			local awards = disPlayData[j]
			local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, iocn)
			cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
			cell.lvTx:setString('x'..awards:getNum())

			local getImg = frame:getChildByName('get_img')
			getImg:setVisible(false)
			if frame:getChildByName('chip_light') then
				frame:removeChildByName('chip_light')
			end

			local judge = 1
			ShaderMgr:restoreWidgetDefaultShader(cell.awardBgImg)
			ShaderMgr:restoreWidgetDefaultShader(cell.awardImg)
			if curValue >= term[j] then
				if self.msg.goldWill.rewards[tostring(confData.task_type)] and self.msg.goldWill.rewards[tostring(confData.task_type)][tostring(j - 1)] == 1 then	-- 已经领取
					getImg:setVisible(true)
					ShaderMgr:setGrayForWidget(cell.awardBgImg)
					ShaderMgr:setGrayForWidget(cell.awardImg)
				else
					judge = 2
					local size = cell.awardBgImg:getContentSize()
					local effect = GlobalApi:createLittleLossyAniByName("chip_light")
					effect:setScale(0.8)
					effect:getAnimation():playWithIndex(0, -1, 1)
					effect:setName('chip_light')
					effect:setVisible(true)
					effect:setPosition(iocn:getPosition())
					frame:addChild(effect)
				end
			end

			cell.awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					if judge == 2 then
						local args = {
							id = i,
							taskType = confData.task_type,
							taskId = j - 1
						}
						MessageMgr:sendPost("get_gold_will_award", "activity", json.encode(args), function (response)
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
								
								if not self.msg.goldWill.rewards[tostring(confData.task_type)] then
									self.msg.goldWill.rewards[tostring(confData.task_type)] = {}
								end

								self.msg.goldWill.rewards[tostring(confData.task_type)][tostring(j - 1)] = 1
								self:update2()
							end
						end)
					else
						GetWayMgr:showGetwayUI(awards,false)
					end
				end
			end)

			if i == 1 then
				local count = frame:getChildByName('count')
				count:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_GOLD_WILL_DESC_1"), term[j]))
			else
				if frame:getChildByName('rich_text' .. j) then
					frame:removeChildByName('rich_text' .. j)
				end
				local richText = xx.RichText:create()
				richText:setName('rich_text' .. j)
				richText:setContentSize(cc.size(600, 40))
				local re1 = xx.RichTextLabel:create(term[j], 22, COLOR_TYPE.WHITE)
				re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
				re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
				re1:setFont('font/gamefont.ttf')
				local re2 = xx.RichTextImage:create("uires/ui/res/res_cash.png")
				re2:setScale(0.68)
				richText:addElement(re1)
				richText:addElement(re2)
				richText:setAlignment('middle')
				richText:setVerticalAlignment('middle')
				richText:setAnchorPoint(cc.p(0.5,0.5))
				richText:setPosition(cc.p(37.6,-19.2))
				frame:addChild(richText)
				richText:format(true)
			end
		end
	end

end

function InvincibleGoldWill:getPercent(curValue,expBgWidth,posInitX,x1,x2,x3,width,term)
	local nowStage = 1
	local posStartX = posInitX
	local posEndX = x1
	local curMaxValue = term[1]
	local realCurValue = curValue
	if curValue < term[1] then
		nowStage = 1
		posStartX = posInitX
		posEndX = x1
		curMaxValue = term[1]
		realCurValue = curValue
	elseif curValue >= term[1] and curValue <= term[2] then
		nowStage = 2
		posStartX = x1 + width
		posEndX = x2
		curMaxValue = term[2] - term[1]
		realCurValue = curValue - term[1]
	else
		nowStage = 3
		posStartX = x2 + width
		posEndX = x3
		curMaxValue = term[3] - term[2]
		realCurValue = curValue - term[2]
	end
	
	local realOffset = posStartX + (realCurValue/curMaxValue)*(posEndX - posStartX) - posInitX

	return realOffset/expBgWidth*100
end

return InvincibleGoldWill